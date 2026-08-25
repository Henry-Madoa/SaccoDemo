'use server';

import { revalidatePath } from 'next/cache';
import { requireAction, requireUser } from '@/lib/session';
import { actionResult } from '@/lib/errors';
import {
  createMemberExit, refreshMemberExitLines, saveMemberExit, submitMemberExit,
  cancelMemberExitApproval, approveMemberExit, rejectMemberExit, reopenMemberExit, processMemberExit,
  type SaveMemberExitInput,
} from '@/lib/memberExits';
import { findPendingRoutedTask, decideWorkflowTask } from '@/lib/workflow';
import type { ActionResult, FormValues, MemberExitWithDetails } from '@/lib/types';

export async function requestMemberExit(
  memberId: number, exitType: string,
): Promise<ActionResult<{ no: string }>> {
  return actionResult(async () => {
    const user = await requireAction('MEMBER_EXITS_CREATE');
    const result = await createMemberExit(memberId, exitType as 'GENERAL' | 'RETIREE' | 'DECEASED', user);
    revalidatePath('/member-exits');
    revalidatePath(`/members/${memberId}`);
    return result;
  });
}

export async function refreshMemberExitLinesRequest(no: string): Promise<ActionResult<{ updated: true }>> {
  return actionResult(async () => {
    const user = await requireAction('MEMBER_EXITS_CREATE');
    await refreshMemberExitLines(no, user);
    revalidatePath(`/member-exits/view/${no}`);
    return { updated: true };
  });
}

function normalise(values: FormValues): SaveMemberExitInput {
  const body: SaveMemberExitInput = {};
  if (values.memberId !== undefined) body.memberId = Number(values.memberId);
  if (values.exitType !== undefined) body.exitType = values.exitType as SaveMemberExitInput['exitType'];
  if (values.payoutMethod !== undefined) body.payoutMethod = values.payoutMethod as SaveMemberExitInput['payoutMethod'];
  if (values.reason !== undefined) body.reason = String(values.reason || '') || null;
  if (values.transactionChargeId !== undefined) {
    body.transactionChargeId = values.transactionChargeId ? Number(values.transactionChargeId) : null;
  }
  return body;
}

export async function saveMemberExitRequest(
  no: string, values: FormValues,
): Promise<ActionResult<MemberExitWithDetails>> {
  return actionResult(async () => {
    const user = await requireAction('MEMBER_EXITS_CREATE');
    const saved = await saveMemberExit(no, normalise(values), user);
    revalidatePath('/member-exits');
    revalidatePath(`/member-exits/view/${no}`);
    return saved;
  });
}

export async function submitMemberExitRequest(no: string): Promise<ActionResult<{ updated: true; autoApproved: boolean }>> {
  return actionResult(async () => {
    const user = await requireAction('MEMBER_EXITS_CREATE');
    const { autoApproved } = await submitMemberExit(no, user);
    revalidatePath('/member-exits');
    revalidatePath(`/member-exits/view/${no}`);
    return { updated: true, autoApproved };
  });
}

export async function cancelMemberExitApprovalRequest(no: string): Promise<ActionResult<{ updated: true }>> {
  return actionResult(async () => {
    const user = await requireAction('MEMBER_EXITS_CREATE');
    await cancelMemberExitApproval(no, user);
    revalidatePath('/member-exits');
    revalidatePath(`/member-exits/view/${no}`);
    return { updated: true };
  });
}

export async function approveMemberExitRequest(no: string): Promise<ActionResult<{ updated: true }>> {
  return actionResult(async () => {
    const routed = await findPendingRoutedTask('MEMBER_EXIT', no);
    if (routed) {
      const user = await requireUser();
      await decideWorkflowTask(routed.id, true, null, user);
    } else {
      const user = await requireAction('MEMBER_EXITS_APPROVE');
      await approveMemberExit(no, user);
    }
    revalidatePath('/member-exits');
    revalidatePath(`/member-exits/view/${no}`);
    return { updated: true };
  });
}

export async function rejectMemberExitRequest(no: string, reason: string): Promise<ActionResult<{ updated: true }>> {
  return actionResult(async () => {
    const routed = await findPendingRoutedTask('MEMBER_EXIT', no);
    if (routed) {
      const user = await requireUser();
      await decideWorkflowTask(routed.id, false, reason || null, user);
    } else {
      const user = await requireAction('MEMBER_EXITS_APPROVE');
      await rejectMemberExit(no, reason, user);
    }
    revalidatePath('/member-exits');
    revalidatePath(`/member-exits/view/${no}`);
    return { updated: true };
  });
}

export async function reopenMemberExitRequest(no: string): Promise<ActionResult<{ updated: true }>> {
  return actionResult(async () => {
    const user = await requireAction('MEMBER_EXITS_APPROVE');
    await reopenMemberExit(no, user);
    revalidatePath('/member-exits');
    revalidatePath(`/member-exits/view/${no}`);
    return { updated: true };
  });
}

export async function processMemberExitRequest(no: string): Promise<ActionResult<{ memberId: number }>> {
  return actionResult(async () => {
    const user = await requireAction('MEMBER_EXITS_APPROVE');
    const result = await processMemberExit(no, user);
    revalidatePath('/member-exits');
    revalidatePath(`/member-exits/view/${no}`);
    revalidatePath(`/members/${result.memberId}`);
    revalidatePath('/members');
    return result;
  });
}
