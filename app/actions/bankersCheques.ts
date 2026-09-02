'use server';

import { revalidatePath } from 'next/cache';
import { requireAction, requireUser } from '@/lib/session';
import { actionResult } from '@/lib/errors';
import {
  createBankersCheque, updateBankersCheque, deleteBankersCheque, submitBankersCheque,
  cancelBankersChequeApproval, approveBankersCheque, rejectBankersCheque, reopenBankersCheque,
  postBankersCheque, bankersChequeAccountsForMember, previewBankersChequeCharge, type BankersChequeInput,
} from '@/lib/bankersCheques';
import { findPendingRoutedTask, decideWorkflowTask } from '@/lib/workflow';
import type { ActionResult, FormValues } from '@/lib/types';

const revalidate = (no?: string) => {
  for (const p of ['/bankers-cheques', '/approvals', '/savings']) revalidatePath(p);
  if (no) revalidatePath(`/bankers-cheques/view/${no}`);
};

const toInput = (values: FormValues): BankersChequeInput => ({
  chequeTypeId: Number(values.chequeTypeId),
  memberId: Number(values.memberId),
  savingsAccountId: Number(values.savingsAccountId),
  payeeDetails: values.payeeDetails ? String(values.payeeDetails) : null,
  chequeNo: values.chequeNo ? String(values.chequeNo) : null,
  amount: values.amount ? Math.round(Number(values.amount) * 100) : 0,
  postingDate: String(values.postingDate || ''),
});

export async function requestBankersCheque(values: FormValues): Promise<ActionResult<{ no: string }>> {
  return actionResult(async () => {
    const user = await requireAction('BANKERS_CHEQUES_CREATE');
    const res = await createBankersCheque(toInput(values), user);
    revalidate();
    return res;
  });
}

export async function saveBankersCheque(no: string, values: FormValues): Promise<ActionResult<{ updated: true }>> {
  return actionResult(async () => {
    const user = await requireAction('BANKERS_CHEQUES_CREATE');
    await updateBankersCheque(no, toInput(values), user);
    revalidate(no);
    return { updated: true };
  });
}

export async function deleteBankersChequeRequest(no: string): Promise<ActionResult<{ deleted: true }>> {
  return actionResult(async () => {
    const user = await requireAction('BANKERS_CHEQUES_CREATE');
    await deleteBankersCheque(no, user);
    revalidate();
    return { deleted: true };
  });
}

export async function submitBankersChequeRequest(no: string): Promise<ActionResult<{ updated: true; autoApproved: boolean }>> {
  return actionResult(async () => {
    const user = await requireAction('BANKERS_CHEQUES_CREATE');
    const { autoApproved } = await submitBankersCheque(no, user);
    revalidate(no);
    return { updated: true, autoApproved };
  });
}

export async function cancelBankersChequeApprovalRequest(no: string): Promise<ActionResult<{ updated: true }>> {
  return actionResult(async () => {
    const user = await requireAction('BANKERS_CHEQUES_CREATE');
    await cancelBankersChequeApproval(no, user);
    revalidate(no);
    return { updated: true };
  });
}

export async function approveBankersChequeRequest(no: string): Promise<ActionResult<{ updated: true }>> {
  return actionResult(async () => {
    const routed = await findPendingRoutedTask('BANKERS_CHEQUE', no);
    if (routed) {
      const user = await requireUser();
      await decideWorkflowTask(routed.id, true, null, user);
    } else {
      const user = await requireAction('BANKERS_CHEQUES_APPROVE');
      await approveBankersCheque(no, user);
    }
    revalidate(no);
    return { updated: true };
  });
}

export async function rejectBankersChequeRequest(no: string, reason: string): Promise<ActionResult<{ updated: true }>> {
  return actionResult(async () => {
    const routed = await findPendingRoutedTask('BANKERS_CHEQUE', no);
    if (routed) {
      const user = await requireUser();
      await decideWorkflowTask(routed.id, false, reason || null, user);
    } else {
      const user = await requireAction('BANKERS_CHEQUES_APPROVE');
      await rejectBankersCheque(no, reason || null, user);
    }
    revalidate(no);
    return { updated: true };
  });
}

export async function reopenBankersChequeRequest(no: string): Promise<ActionResult<{ updated: true }>> {
  return actionResult(async () => {
    const user = await requireAction('BANKERS_CHEQUES_APPROVE');
    await reopenBankersCheque(no, user);
    revalidate(no);
    return { updated: true };
  });
}

export async function postBankersChequeRequest(
  no: string,
): Promise<ActionResult<{ journalNo: string; balance: number; charged: number }>> {
  return actionResult(async () => {
    const user = await requireAction('BANKERS_CHEQUES_POST');
    const res = await postBankersCheque(no, user);
    revalidate(no);
    return res;
  });
}

export async function accountsForBankersCheque(memberId: number) {
  return actionResult(async () => {
    await requireAction('BANKERS_CHEQUES_CREATE');
    return bankersChequeAccountsForMember(memberId);
  });
}

export async function previewChequeCharge(chequeTypeId: number, amount: number) {
  return actionResult(async () => {
    await requireAction('BANKERS_CHEQUES_CREATE');
    return previewBankersChequeCharge(chequeTypeId, Math.round(amount * 100));
  });
}
