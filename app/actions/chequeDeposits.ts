'use server';

import { revalidatePath } from 'next/cache';
import { requireAction, requireUser } from '@/lib/session';
import { actionResult } from '@/lib/errors';
import {
  createChequeDeposit, updateChequeDeposit, deleteChequeDeposit, submitChequeDeposit,
  cancelChequeDepositApproval, approveChequeDeposit, rejectChequeDeposit, reopenChequeDeposit,
  clearChequeDeposit, expressClearChequeDeposit, releaseChequeDepositHold, bounceChequeDeposit,
  chequeDepositAccountsForMember, previewChequeDepositCharges, computeMaturityDate,
  addChequeInstruction, deleteChequeInstruction, instructionTargetsForMember,
  type ChequeDepositInput,
} from '@/lib/chequeDeposits';
import { getChequeType } from '@/lib/chequeTypes';
import { findPendingRoutedTask, decideWorkflowTask } from '@/lib/workflow';
import type { ActionResult, FormValues } from '@/lib/types';

const revalidate = (no?: string) => {
  for (const p of ['/cheque-deposits', '/approvals', '/savings']) revalidatePath(p);
  if (no) revalidatePath(`/cheque-deposits/view/${no}`);
};

const toInput = (values: FormValues): ChequeDepositInput => ({
  chequeTypeId: Number(values.chequeTypeId),
  memberId: Number(values.memberId),
  savingsAccountId: Number(values.savingsAccountId),
  chequeNo: values.chequeNo ? String(values.chequeNo) : null,
  chequeDate: values.chequeDate ? String(values.chequeDate) : null,
  depositDate: String(values.depositDate || ''),
  amount: values.amount ? Math.round(Number(values.amount) * 100) : 0,
  expressCheque: Number(values.expressCheque) ? true : false,
  drawerAccountName: values.drawerAccountName ? String(values.drawerAccountName) : null,
  drawerBank: values.drawerBank ? String(values.drawerBank) : null,
  drawerBranch: values.drawerBranch ? String(values.drawerBranch) : null,
  drawerAccountNo: values.drawerAccountNo ? String(values.drawerAccountNo) : null,
});

export async function requestChequeDeposit(values: FormValues): Promise<ActionResult<{ no: string; maturityDate: string }>> {
  return actionResult(async () => {
    const user = await requireAction('CHEQUE_DEPOSITS_CREATE');
    const res = await createChequeDeposit(toInput(values), user);
    revalidate();
    return res;
  });
}

export async function saveChequeDeposit(no: string, values: FormValues): Promise<ActionResult<{ updated: true }>> {
  return actionResult(async () => {
    const user = await requireAction('CHEQUE_DEPOSITS_CREATE');
    await updateChequeDeposit(no, toInput(values), user);
    revalidate(no);
    return { updated: true };
  });
}

export async function deleteChequeDepositRequest(no: string): Promise<ActionResult<{ deleted: true }>> {
  return actionResult(async () => {
    const user = await requireAction('CHEQUE_DEPOSITS_CREATE');
    await deleteChequeDeposit(no, user);
    revalidate();
    return { deleted: true };
  });
}

export async function submitChequeDepositRequest(no: string): Promise<ActionResult<{ updated: true; autoApproved: boolean }>> {
  return actionResult(async () => {
    const user = await requireAction('CHEQUE_DEPOSITS_CREATE');
    const { autoApproved } = await submitChequeDeposit(no, user);
    revalidate(no);
    return { updated: true, autoApproved };
  });
}

export async function cancelChequeDepositApprovalRequest(no: string): Promise<ActionResult<{ updated: true }>> {
  return actionResult(async () => {
    const user = await requireAction('CHEQUE_DEPOSITS_CREATE');
    await cancelChequeDepositApproval(no, user);
    revalidate(no);
    return { updated: true };
  });
}

export async function approveChequeDepositRequest(no: string): Promise<ActionResult<{ updated: true }>> {
  return actionResult(async () => {
    const routed = await findPendingRoutedTask('CHEQUE_DEPOSIT', no);
    if (routed) {
      const user = await requireUser();
      await decideWorkflowTask(routed.id, true, null, user);
    } else {
      const user = await requireAction('CHEQUE_DEPOSITS_APPROVE');
      await approveChequeDeposit(no, user);
    }
    revalidate(no);
    return { updated: true };
  });
}

export async function rejectChequeDepositRequest(no: string, reason: string): Promise<ActionResult<{ updated: true }>> {
  return actionResult(async () => {
    const routed = await findPendingRoutedTask('CHEQUE_DEPOSIT', no);
    if (routed) {
      const user = await requireUser();
      await decideWorkflowTask(routed.id, false, reason || null, user);
    } else {
      const user = await requireAction('CHEQUE_DEPOSITS_APPROVE');
      await rejectChequeDeposit(no, reason || null, user);
    }
    revalidate(no);
    return { updated: true };
  });
}

export async function reopenChequeDepositRequest(no: string): Promise<ActionResult<{ updated: true }>> {
  return actionResult(async () => {
    const user = await requireAction('CHEQUE_DEPOSITS_APPROVE');
    await reopenChequeDeposit(no, user);
    revalidate(no);
    return { updated: true };
  });
}

export async function clearChequeDepositRequest(no: string): Promise<ActionResult<{ journalNo: string; balance: number; charged: number }>> {
  return actionResult(async () => {
    const user = await requireAction('CHEQUE_DEPOSITS_CLEAR');
    const res = await clearChequeDeposit(no, user);
    revalidate(no);
    return res;
  });
}

export async function expressClearChequeDepositRequest(no: string): Promise<ActionResult<{ journalNo: string; balance: number; charged: number; held: number }>> {
  return actionResult(async () => {
    const user = await requireAction('CHEQUE_DEPOSITS_CLEAR');
    const res = await expressClearChequeDeposit(no, user);
    revalidate(no);
    return res;
  });
}

export async function releaseChequeDepositHoldRequest(no: string): Promise<ActionResult<{ held: number }>> {
  return actionResult(async () => {
    const user = await requireAction('CHEQUE_DEPOSITS_CLEAR');
    const res = await releaseChequeDepositHold(no, user);
    revalidate(no);
    return res;
  });
}

export async function bounceChequeDepositRequest(no: string, reason: string): Promise<ActionResult<{ charged: number; reversed: boolean }>> {
  return actionResult(async () => {
    const user = await requireAction('CHEQUE_DEPOSITS_CLEAR');
    const res = await bounceChequeDeposit(no, reason || null, user);
    revalidate(no);
    return res;
  });
}

export async function accountsForChequeDeposit(memberId: number) {
  return actionResult(async () => {
    await requireAction('CHEQUE_DEPOSITS_CREATE');
    return chequeDepositAccountsForMember(memberId);
  });
}

export async function targetsForChequeInstruction(memberId: number, excludeAccountId?: number) {
  return actionResult(async () => {
    await requireAction('CHEQUE_DEPOSITS_CREATE');
    return instructionTargetsForMember(memberId, excludeAccountId);
  });
}

export async function addChequeInstructionRequest(no: string, values: FormValues): Promise<ActionResult<{ id: number }>> {
  return actionResult(async () => {
    const user = await requireAction('CHEQUE_DEPOSITS_CREATE');
    const res = await addChequeInstruction(no, {
      targetType: String(values.targetType || 'ACCOUNT') as 'ACCOUNT' | 'LOAN',
      targetId: Number(values.targetId),
      amount: values.amount ? Math.round(Number(values.amount) * 100) : 0,
    }, user);
    revalidate(no);
    return res;
  });
}

export async function deleteChequeInstructionRequest(no: string, id: number): Promise<ActionResult<{ deleted: true }>> {
  return actionResult(async () => {
    const user = await requireAction('CHEQUE_DEPOSITS_CREATE');
    await deleteChequeInstruction(no, id, user);
    revalidate(no);
    return { deleted: true };
  });
}

export async function previewChequeDeposit(chequeTypeId: number, amount: number, depositDate: string) {
  return actionResult(async () => {
    await requireAction('CHEQUE_DEPOSITS_CREATE');
    const type = chequeTypeId ? await getChequeType(chequeTypeId) : null;
    const charges = await previewChequeDepositCharges(chequeTypeId, Math.round(amount * 100));
    const maturityDate = type && depositDate
      ? computeMaturityDate(depositDate, type.maturity_days, type.in_house)
      : null;
    return { charges, maturityDate, maxAmount: type ? Number(type.maximum_amount) : 0, hasExpress: !!type?.express_charge_id };
  });
}
