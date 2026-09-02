'use server';

import { revalidatePath } from 'next/cache';
import { requireAction, requireUser, currentCanAction } from '@/lib/session';
import { actionResult, AppError } from '@/lib/errors';
import {
  createInterAccountTransfer, updateInterAccountTransfer, deleteInterAccountTransfer,
  submitInterAccountTransfer, cancelInterAccountTransferApproval, approveInterAccountTransfer,
  rejectInterAccountTransfer, reopenInterAccountTransfer, postInterAccountTransfer,
  transferSourceAccountsForMember, transferDestinationAccountsForMember, previewInterAccountTransferCharge,
  type TransferInput,
} from '@/lib/interAccountTransfer';
import { findPendingRoutedTask, decideWorkflowTask } from '@/lib/workflow';
import type { ActionResult, FormValues, InterAccountTransferAmountType } from '@/lib/types';

const revalidate = (no?: string) => {
  for (const p of ['/inter-account-transfers', '/approvals', '/savings']) revalidatePath(p);
  if (no) revalidatePath(`/inter-account-transfers/view/${no}`);
};

const toInput = (values: FormValues): TransferInput => ({
  sourceMemberId: Number(values.sourceMemberId),
  sourceAccountId: Number(values.sourceAccountId),
  destinationMemberId: Number(values.destinationMemberId || values.sourceMemberId),
  destinationAccountId: Number(values.destinationAccountId),
  amountType: String(values.amountType || 'PARTIAL') as InterAccountTransferAmountType,
  amount: values.amount ? Math.round(Number(values.amount) * 100) : 0,
  postingDate: String(values.postingDate || ''),
  narration: values.narration ? String(values.narration) : null,
});

/** AL User Setup "Can Transfer To Other Members" — block a cross-member destination unless held. */
async function assertCrossMemberAllowed(input: TransferInput): Promise<void> {
  if (input.destinationMemberId && input.destinationMemberId !== input.sourceMemberId) {
    if (!(await currentCanAction('INTER_ACCOUNT_TRANSFERS_CROSS_MEMBER'))) {
      throw new AppError('You can only transfer between one member’s own accounts', 'FORBIDDEN');
    }
  }
}

export async function requestInterAccountTransfer(values: FormValues): Promise<ActionResult<{ no: string }>> {
  return actionResult(async () => {
    const user = await requireAction('INTER_ACCOUNT_TRANSFERS_CREATE');
    const input = toInput(values);
    await assertCrossMemberAllowed(input);
    const res = await createInterAccountTransfer(input, user);
    revalidate();
    return res;
  });
}

export async function saveInterAccountTransfer(no: string, values: FormValues): Promise<ActionResult<{ updated: true }>> {
  return actionResult(async () => {
    const user = await requireAction('INTER_ACCOUNT_TRANSFERS_CREATE');
    const input = toInput(values);
    await assertCrossMemberAllowed(input);
    await updateInterAccountTransfer(no, input, user);
    revalidate(no);
    return { updated: true };
  });
}

export async function deleteInterAccountTransferRequest(no: string): Promise<ActionResult<{ deleted: true }>> {
  return actionResult(async () => {
    const user = await requireAction('INTER_ACCOUNT_TRANSFERS_CREATE');
    await deleteInterAccountTransfer(no, user);
    revalidate();
    return { deleted: true };
  });
}

export async function submitInterAccountTransferRequest(no: string): Promise<ActionResult<{ updated: true; autoApproved: boolean }>> {
  return actionResult(async () => {
    const user = await requireAction('INTER_ACCOUNT_TRANSFERS_CREATE');
    const { autoApproved } = await submitInterAccountTransfer(no, user);
    revalidate(no);
    return { updated: true, autoApproved };
  });
}

export async function cancelInterAccountTransferApprovalRequest(no: string): Promise<ActionResult<{ updated: true }>> {
  return actionResult(async () => {
    const user = await requireAction('INTER_ACCOUNT_TRANSFERS_CREATE');
    await cancelInterAccountTransferApproval(no, user);
    revalidate(no);
    return { updated: true };
  });
}

export async function approveInterAccountTransferRequest(no: string): Promise<ActionResult<{ updated: true }>> {
  return actionResult(async () => {
    const routed = await findPendingRoutedTask('INTER_ACCOUNT_TRANSFER', no);
    if (routed) {
      const user = await requireUser();
      await decideWorkflowTask(routed.id, true, null, user);
    } else {
      const user = await requireAction('INTER_ACCOUNT_TRANSFERS_APPROVE');
      await approveInterAccountTransfer(no, user);
    }
    revalidate(no);
    return { updated: true };
  });
}

export async function rejectInterAccountTransferRequest(no: string, reason: string): Promise<ActionResult<{ updated: true }>> {
  return actionResult(async () => {
    const routed = await findPendingRoutedTask('INTER_ACCOUNT_TRANSFER', no);
    if (routed) {
      const user = await requireUser();
      await decideWorkflowTask(routed.id, false, reason || null, user);
    } else {
      const user = await requireAction('INTER_ACCOUNT_TRANSFERS_APPROVE');
      await rejectInterAccountTransfer(no, reason || null, user);
    }
    revalidate(no);
    return { updated: true };
  });
}

export async function reopenInterAccountTransferRequest(no: string): Promise<ActionResult<{ updated: true }>> {
  return actionResult(async () => {
    const user = await requireAction('INTER_ACCOUNT_TRANSFERS_APPROVE');
    await reopenInterAccountTransfer(no, user);
    revalidate(no);
    return { updated: true };
  });
}

export async function postInterAccountTransferRequest(
  no: string,
): Promise<ActionResult<{ journalNo: string; sourceBalance: number; destinationBalance: number; charged: number }>> {
  return actionResult(async () => {
    const user = await requireAction('INTER_ACCOUNT_TRANSFERS_POST');
    const res = await postInterAccountTransfer(no, user);
    revalidate(no);
    return res;
  });
}

export async function sourceAccountsForTransfer(memberId: number) {
  return actionResult(async () => {
    await requireAction('INTER_ACCOUNT_TRANSFERS_CREATE');
    return transferSourceAccountsForMember(memberId);
  });
}

export async function destinationAccountsForTransfer(memberId: number, excludeAccountId?: number) {
  return actionResult(async () => {
    await requireAction('INTER_ACCOUNT_TRANSFERS_CREATE');
    return transferDestinationAccountsForMember(memberId, excludeAccountId);
  });
}

export async function previewTransferCharge(amount: number) {
  return actionResult(async () => {
    await requireAction('INTER_ACCOUNT_TRANSFERS_CREATE');
    return previewInterAccountTransferCharge(Math.round(amount * 100));
  });
}
