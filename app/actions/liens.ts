'use server';

import { revalidatePath } from 'next/cache';
import { requireAction, requireUser } from '@/lib/session';
import { actionResult } from '@/lib/errors';
import {
  createLien, updateLien, deleteLien, submitLien, cancelLienApproval, approveLien, rejectLien,
  reopenLien, processLien, lienableAccountsForMember, type LienInput,
} from '@/lib/liens';
import { findPendingRoutedTask, decideWorkflowTask } from '@/lib/workflow';
import type { ActionResult, FormValues, LienTransactionType } from '@/lib/types';

const revalidate = (no?: string) => {
  for (const p of ['/liens', '/approvals', '/savings']) revalidatePath(p);
  if (no) revalidatePath(`/liens/view/${no}`);
};

const toInput = (values: FormValues): LienInput => ({
  memberId: Number(values.memberId),
  savingsAccountId: Number(values.savingsAccountId),
  transactionType: String(values.transactionType || 'HOLD') as LienTransactionType,
  amount: values.amount ? Math.round(Number(values.amount) * 100) : 0,
  postingDate: String(values.postingDate || ''),
  narration: values.narration ? String(values.narration) : null,
});

export async function requestLien(values: FormValues): Promise<ActionResult<{ no: string }>> {
  return actionResult(async () => {
    const user = await requireAction('LIENS_CREATE');
    const res = await createLien(toInput(values), user);
    revalidate();
    return res;
  });
}

export async function saveLien(no: string, values: FormValues): Promise<ActionResult<{ updated: true }>> {
  return actionResult(async () => {
    const user = await requireAction('LIENS_CREATE');
    await updateLien(no, toInput(values), user);
    revalidate(no);
    return { updated: true };
  });
}

export async function deleteLienRequest(no: string): Promise<ActionResult<{ deleted: true }>> {
  return actionResult(async () => {
    const user = await requireAction('LIENS_CREATE');
    await deleteLien(no, user);
    revalidate();
    return { deleted: true };
  });
}

export async function submitLienRequest(no: string): Promise<ActionResult<{ updated: true; autoApproved: boolean }>> {
  return actionResult(async () => {
    const user = await requireAction('LIENS_CREATE');
    const { autoApproved } = await submitLien(no, user);
    revalidate(no);
    return { updated: true, autoApproved };
  });
}

export async function cancelLienApprovalRequest(no: string): Promise<ActionResult<{ updated: true }>> {
  return actionResult(async () => {
    const user = await requireAction('LIENS_CREATE');
    await cancelLienApproval(no, user);
    revalidate(no);
    return { updated: true };
  });
}

export async function approveLienRequest(no: string): Promise<ActionResult<{ updated: true }>> {
  return actionResult(async () => {
    const routed = await findPendingRoutedTask('MEMBER_LIEN', no);
    if (routed) {
      const user = await requireUser();
      await decideWorkflowTask(routed.id, true, null, user);
    } else {
      const user = await requireAction('LIENS_APPROVE');
      await approveLien(no, user);
    }
    revalidate(no);
    return { updated: true };
  });
}

export async function rejectLienRequest(no: string, reason: string): Promise<ActionResult<{ updated: true }>> {
  return actionResult(async () => {
    const routed = await findPendingRoutedTask('MEMBER_LIEN', no);
    if (routed) {
      const user = await requireUser();
      await decideWorkflowTask(routed.id, false, reason || null, user);
    } else {
      const user = await requireAction('LIENS_APPROVE');
      await rejectLien(no, reason || null, user);
    }
    revalidate(no);
    return { updated: true };
  });
}

export async function reopenLienRequest(no: string): Promise<ActionResult<{ updated: true }>> {
  return actionResult(async () => {
    const user = await requireAction('LIENS_APPROVE');
    await reopenLien(no, user);
    revalidate(no);
    return { updated: true };
  });
}

export async function processLienRequest(no: string): Promise<ActionResult<{ heldBefore: number; heldAfter: number; available: number }>> {
  return actionResult(async () => {
    const user = await requireAction('LIENS_POST');
    const res = await processLien(no, user);
    revalidate(no);
    return res;
  });
}

export async function accountsForLien(memberId: number) {
  return actionResult(async () => {
    await requireAction('LIENS_CREATE');
    return lienableAccountsForMember(memberId);
  });
}
