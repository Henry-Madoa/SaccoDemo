'use server';

import { revalidatePath } from 'next/cache';
import { requireAction, requireUser } from '@/lib/session';
import { actionResult, AppError } from '@/lib/errors';
import * as loanSvc from '@/lib/loanService';
import { getMemberDetail } from '@/lib/members';
import { findPendingRoutedTask, decideWorkflowTask, recordLegacyDecision } from '@/lib/workflow';
import { toCents } from '@/lib/format';
import { RECOVERY_MODES, PAY_MODES } from '@/lib/constants';
import type {
  ActionResult, Appraisal, FormValues, LoanAppraisalRow, LoanFull, LoanRecoveryMode, PayMode, SavingsAccountWithProduct,
} from '@/lib/types';

const toRecoveryMode = (value: unknown): LoanRecoveryMode =>
  RECOVERY_MODES.some((m) => m.value === value) ? (value as LoanRecoveryMode) : 'DIRECT';

const toPayMode = (value: unknown): PayMode | null =>
  PAY_MODES.some((m) => m.value === value) ? (value as PayMode) : null;

/** Whenever a loan disbursement/repayment doesn't move through a member's own savings account,
 *  it must say which real Bank/Cashbook account it did move through and how (Pay Mode) —
 *  per-Pay-Mode extras (Cheque No./Date, or a Reference No.) required in turn. Enforced here,
 *  not in lib/loanService.ts itself, since that's where every *other* caller lives — Standing
 *  Orders, Checkoff & Salary Processing, Member Exit, seed data — none of which involve a human
 *  naming a specific till/bank account at all. */
function assertPaymentDetails(
  payMode: PayMode | null, bankAccountId: number | null, chequeNo: string, chequeDate: string, referenceNo: string,
): void {
  if (!bankAccountId) throw new AppError('Select the Bank/Cashbook account this payment moved through', 'VALIDATION');
  if (!payMode) throw new AppError('Select a Pay Mode', 'VALIDATION');
  if (payMode === 'CHEQUE' && (!chequeNo.trim() || !chequeDate)) {
    throw new AppError('Cheque No. and Cheque Date are required for a Cheque payment', 'VALIDATION');
  }
  if ((payMode === 'MPESA' || payMode === 'BANK' || payMode === 'EFT') && !referenceNo.trim()) {
    throw new AppError('A Reference No. is required for this Pay Mode', 'VALIDATION');
  }
}

/** Active savings accounts a disbursement may be credited to. */
export async function memberDisbursementAccounts(
  memberId: number,
): Promise<ActionResult<SavingsAccountWithProduct[]>> {
  return actionResult(async () => {
    await requireAction('LOAN_READ');
    const detail = await getMemberDetail(memberId);
    return (detail?.accounts ?? []).filter((a) => a.status === 'ACTIVE');
  });
}

export async function appraiseLoan(values: FormValues): Promise<ActionResult<Appraisal>> {
  return actionResult(async () => {
    await requireAction('LOAN_READ');
    return loanSvc.appraise({
      memberId: Number(values.memberId),
      productId: Number(values.productId),
      principal: toCents(values.principal),
      termMonths: Number(values.termMonths),
    });
  });
}

/** Re-runs the credit appraisal against an already-captured loan and files the result — the
 *  persisted counterpart to appraiseLoan() above, which is used only for the pre-save preview
 *  in the New Application modal, before a loan_id exists to attach a record to. */
export async function runLoanAppraisal(loanId: number): Promise<ActionResult<LoanAppraisalRow>> {
  return actionResult(async () => {
    const user = await requireAction('LOAN_CREATE');
    const record = await loanSvc.saveAppraisal({ loanId, user });
    revalidatePath(`/loans/view/${loanId}`);
    return record;
  });
}

export async function applyForLoan(values: FormValues): Promise<ActionResult<LoanFull>> {
  return actionResult(async () => {
    const user = await requireAction('LOAN_CREATE');
    const loan = await loanSvc.apply({
      memberId: Number(values.memberId),
      productId: Number(values.productId),
      principal: toCents(values.principal),
      termMonths: Number(values.termMonths),
      purpose: String(values.purpose || ''),
      sectorCode: values.sectorCode ? String(values.sectorCode) : null,
      subSectorCode: values.subSectorCode ? String(values.subSectorCode) : null,
      subSubsectorCode: values.subSubsectorCode ? String(values.subSubsectorCode) : null,
      disburseToAccountId: values.disburseToAccountId ? Number(values.disburseToAccountId) : null,
      recoveryMode: toRecoveryMode(values.recoveryMode),
      user,
    });
    revalidatePath('/loans');
    revalidatePath(`/members/${values.memberId}`);
    return loan;
  });
}

export async function updateLoanApplication(loanId: number, values: FormValues): Promise<ActionResult<LoanFull>> {
  return actionResult(async () => {
    const user = await requireAction('LOAN_CREATE');
    const loan = await loanSvc.update({
      loanId,
      memberId: Number(values.memberId),
      productId: Number(values.productId),
      principal: toCents(values.principal),
      termMonths: Number(values.termMonths),
      purpose: String(values.purpose || ''),
      sectorCode: values.sectorCode ? String(values.sectorCode) : null,
      subSectorCode: values.subSectorCode ? String(values.subSectorCode) : null,
      subSubsectorCode: values.subSubsectorCode ? String(values.subSubsectorCode) : null,
      disburseToAccountId: values.disburseToAccountId ? Number(values.disburseToAccountId) : null,
      recoveryMode: toRecoveryMode(values.recoveryMode),
      user,
    });
    revalidatePath('/loans');
    revalidatePath(`/loans/view/${loanId}`);
    revalidatePath(`/members/${values.memberId}`);
    return loan;
  });
}

export async function submitLoan(loanId: number): Promise<ActionResult<LoanFull>> {
  return actionResult(async () => {
    const user = await requireAction('LOAN_CREATE');
    const loan = await loanSvc.submit({ loanId, user });
    revalidatePath('/loans');
    revalidatePath(`/loans/view/${loanId}`);
    revalidatePath('/approvals');
    return loan;
  });
}

/**
 * Delegates to whichever approval path actually governs this loan: if a
 * workflow routed it to a specific approver, only that assignee may decide it
 * (via decideWorkflowTask); otherwise this falls back to the original
 * LOAN:APPROVE-gated behavior, unchanged.
 */
export async function decideLoan(
  loanId: number,
  approve: boolean,
  reason: string,
): Promise<ActionResult<LoanFull | { decided: true }>> {
  return actionResult(async () => {
    const routed = await findPendingRoutedTask('LOAN', String(loanId));
    let result: LoanFull | { decided: true };
    if (routed) {
      const user = await requireUser();
      await decideWorkflowTask(routed.id, approve, reason || null, user);
      result = { decided: true };
    } else {
      const user = await requireAction('LOAN_APPROVE');
      const loan = await loanSvc.approve({ loanId, user, approve, reason });
      await recordLegacyDecision('LOAN', String(loanId), approve, reason || null, user);
      result = loan;
    }
    revalidatePath('/loans');
    revalidatePath(`/loans/view/${loanId}`);
    revalidatePath('/approvals');
    return result;
  });
}

export async function disburseLoan(loanId: number, values: FormValues): Promise<ActionResult<LoanFull>> {
  return actionResult(async () => {
    const user = await requireAction('LOAN_DISBURSE');
    const existing = await loanSvc.getLoan(loanId);
    if (!existing) throw new AppError('Loan not found', 'NOT_FOUND');

    const bankAccountId = values.bankAccountId ? Number(values.bankAccountId) : null;
    const payMode = toPayMode(values.payMode);
    const chequeNo = String(values.chequeNo || '');
    const chequeDate = String(values.chequeDate || '');
    const referenceNo = String(values.referenceNo || '');
    // A disbursement straight to a member's own savings account never touches a bank/cashbook
    // at all — Payment Channel/Pay Mode are simply not offered in that case (see the form).
    if (!existing.disburse_to_account_id) {
      assertPaymentDetails(payMode, bankAccountId, chequeNo, chequeDate, referenceNo);
    }

    const loan = await loanSvc.disburse({
      loanId,
      valueDate: String(values.valueDate || ''),
      bankAccountId, payMode, chequeNo: chequeNo || null, chequeDate: chequeDate || null, referenceNo: referenceNo || null,
      user,
    });
    revalidatePath('/loans');
    revalidatePath(`/loans/view/${loanId}`);
    revalidatePath(`/members/${loan.member_id}`);
    return loan;
  });
}

export async function repayLoan(
  loanId: number,
  values: FormValues,
): Promise<ActionResult<loanSvc.RepayResult>> {
  return actionResult(async () => {
    const user = await requireAction('LOAN_REPAY');
    const fromSavingsAccountId = values.fromSavingsAccountId ? Number(values.fromSavingsAccountId) : null;
    const bankAccountId = values.bankAccountId ? Number(values.bankAccountId) : null;
    const payMode = toPayMode(values.payMode);
    const chequeNo = String(values.chequeNo || '');
    const chequeDate = String(values.chequeDate || '');
    const referenceNo = String(values.referenceNo || '');
    // Repaying from a member's own savings account never touches a bank/cashbook either.
    if (!fromSavingsAccountId) {
      assertPaymentDetails(payMode, bankAccountId, chequeNo, chequeDate, referenceNo);
    }

    const result = await loanSvc.repay({
      loanId,
      amount: toCents(values.amount),
      valueDate: String(values.valueDate || ''),
      description: String(values.description || ''),
      fromSavingsAccountId,
      bankAccountId, payMode, chequeNo: chequeNo || null, chequeDate: chequeDate || null, referenceNo: referenceNo || null,
      user,
    });
    revalidatePath('/loans');
    revalidatePath(`/loans/view/${loanId}`);
    revalidatePath(`/members/${result.loan.member_id}`);
    return result;
  });
}

export async function runAging(): Promise<ActionResult<{ asOf: string; loansProcessed: number }>> {
  return actionResult(async () => {
    await requireAction('LOAN_READ');
    const result = await loanSvc.runArrearsAging();
    revalidatePath('/loans');
    revalidatePath('/reports/par');
    return result;
  });
}
