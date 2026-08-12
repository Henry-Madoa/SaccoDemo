'use server';

import { revalidatePath } from 'next/cache';
import { requirePerm } from '@/lib/session';
import { actionResult } from '@/lib/errors';
import * as loanSvc from '@/lib/loanService';
import { getMemberDetail } from '@/lib/members';
import { toCents } from '@/lib/format';
import type {
  ActionResult, Appraisal, Channel, FormValues, LoanFull, SavingsAccountWithProduct,
} from '@/lib/types';

/** Active savings accounts a disbursement may be credited to. */
export async function memberDisbursementAccounts(
  memberId: number,
): Promise<ActionResult<SavingsAccountWithProduct[]>> {
  return actionResult(async () => {
    await requirePerm('LOAN:READ');
    const detail = await getMemberDetail(memberId);
    return (detail?.accounts ?? []).filter((a) => a.status === 'ACTIVE');
  });
}

export async function appraiseLoan(values: FormValues): Promise<ActionResult<Appraisal>> {
  return actionResult(async () => {
    await requirePerm('LOAN:READ');
    return loanSvc.appraise({
      memberId: Number(values.memberId),
      productId: Number(values.productId),
      principal: toCents(values.principal),
      termMonths: Number(values.termMonths),
    });
  });
}

export async function applyForLoan(values: FormValues): Promise<ActionResult<LoanFull>> {
  return actionResult(async () => {
    const user = await requirePerm('LOAN:CREATE');
    const loan = await loanSvc.apply({
      memberId: Number(values.memberId),
      productId: Number(values.productId),
      principal: toCents(values.principal),
      termMonths: Number(values.termMonths),
      purpose: String(values.purpose || ''),
      disburseToAccountId: values.disburseToAccountId ? Number(values.disburseToAccountId) : null,
      user,
    });
    revalidatePath('/loans');
    revalidatePath('/approvals');
    revalidatePath(`/members/${values.memberId}`);
    return loan;
  });
}

export async function decideLoan(
  loanId: number,
  approve: boolean,
  reason: string,
): Promise<ActionResult<LoanFull>> {
  return actionResult(async () => {
    const user = await requirePerm('LOAN:APPROVE');
    const loan = await loanSvc.approve({ loanId, user, approve, reason });
    revalidatePath('/loans');
    revalidatePath(`/loans/${loanId}`);
    revalidatePath('/approvals');
    return loan;
  });
}

export async function disburseLoan(loanId: number, values: FormValues): Promise<ActionResult<LoanFull>> {
  return actionResult(async () => {
    const user = await requirePerm('LOAN:DISBURSE');
    const loan = await loanSvc.disburse({
      loanId,
      valueDate: String(values.valueDate || ''),
      channel: values.channel as Channel,
      user,
    });
    revalidatePath('/loans');
    revalidatePath(`/loans/${loanId}`);
    revalidatePath(`/members/${loan.member_id}`);
    return loan;
  });
}

export async function repayLoan(
  loanId: number,
  values: FormValues,
): Promise<ActionResult<loanSvc.RepayResult>> {
  return actionResult(async () => {
    const user = await requirePerm('LOAN:REPAY');
    const result = await loanSvc.repay({
      loanId,
      amount: toCents(values.amount),
      channel: values.channel as Channel,
      valueDate: String(values.valueDate || ''),
      description: String(values.description || ''),
      fromSavingsAccountId: values.fromSavingsAccountId ? Number(values.fromSavingsAccountId) : null,
      user,
    });
    revalidatePath('/loans');
    revalidatePath(`/loans/${loanId}`);
    revalidatePath(`/members/${result.loan.member_id}`);
    return result;
  });
}

export async function runAging(): Promise<ActionResult<{ asOf: string; loansProcessed: number }>> {
  return actionResult(async () => {
    await requirePerm('LOAN:READ');
    const result = await loanSvc.runArrearsAging();
    revalidatePath('/loans');
    revalidatePath('/reports/par');
    return result;
  });
}
