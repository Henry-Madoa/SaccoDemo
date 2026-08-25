'use server';

import { revalidatePath } from 'next/cache';
import { requireAction } from '@/lib/session';
import { actionResult } from '@/lib/errors';
import { listMemberStatusUpdateCandidates, runMemberStatusUpdate } from '@/lib/memberStatusUpdate';
import type { ActionResult, MemberStatusUpdateCandidate, MemberStatusUpdateRunSummary } from '@/lib/types';

export async function memberStatusUpdateCandidates(): Promise<ActionResult<MemberStatusUpdateCandidate[]>> {
  return actionResult(async () => {
    await requireAction('MEMBER_STATUS_UPDATE_READ');
    return listMemberStatusUpdateCandidates();
  });
}

/** The manual screen's own "Run update" button — same underlying runner the Job Queue's
 *  unattended poller calls (lib/jobQueue.ts), just triggered by a signed-in officer instead. */
export async function runMemberStatusUpdateNow(): Promise<ActionResult<MemberStatusUpdateRunSummary>> {
  return actionResult(async () => {
    const user = await requireAction('MEMBER_STATUS_UPDATE_RUN');
    const result = await runMemberStatusUpdate(user);
    revalidatePath('/member-status-update');
    revalidatePath('/members');
    revalidatePath('/savings');
    return result;
  });
}
