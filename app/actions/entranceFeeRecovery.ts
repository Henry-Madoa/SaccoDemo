'use server';

import { revalidatePath } from 'next/cache';
import { requireAction } from '@/lib/session';
import { actionResult } from '@/lib/errors';
import { listEntranceFeeRecoveryCandidates, runEntranceFeeRecovery } from '@/lib/entranceFeeRecovery';
import type { ActionResult, EntranceFeeRecoveryCandidate, EntranceFeeRecoveryRunSummary } from '@/lib/types';

export async function entranceFeeRecoveryCandidates(): Promise<ActionResult<EntranceFeeRecoveryCandidate[]>> {
  return actionResult(async () => {
    await requireAction('ENTRANCE_FEE_RECOVERY_READ');
    return listEntranceFeeRecoveryCandidates();
  });
}

/** The manual screen's own "Run recovery" button — same underlying runner the Job Queue's
 *  unattended poller calls (lib/jobQueue.ts), just triggered by a signed-in officer instead. */
export async function runEntranceFeeRecoveryNow(): Promise<ActionResult<EntranceFeeRecoveryRunSummary>> {
  return actionResult(async () => {
    const user = await requireAction('ENTRANCE_FEE_RECOVERY_RUN');
    const result = await runEntranceFeeRecovery(user);
    revalidatePath('/entrance-fee-recovery');
    revalidatePath('/members');
    revalidatePath('/savings');
    return result;
  });
}
