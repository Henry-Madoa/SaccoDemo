'use server';

import { revalidatePath } from 'next/cache';
import { requireAction } from '@/lib/session';
import { actionResult } from '@/lib/errors';
import { replaceNextOfKin, replaceNominees, type NextOfKinDraft, type NomineeDraft } from '@/lib/nominees';
import type { ActionResult } from '@/lib/types';

export async function saveNextOfKin(
  memberId: number,
  rows: NextOfKinDraft[],
): Promise<ActionResult<{ updated: true }>> {
  return actionResult(async () => {
    const user = await requireAction('MEMBERS_UPDATE');
    await replaceNextOfKin(memberId, rows, user);
    revalidatePath(`/members/${memberId}`);
    return { updated: true };
  });
}

export async function saveNominees(
  memberId: number,
  rows: NomineeDraft[],
): Promise<ActionResult<{ updated: true }>> {
  return actionResult(async () => {
    const user = await requireAction('MEMBERS_UPDATE');
    await replaceNominees(memberId, rows, user);
    revalidatePath(`/members/${memberId}`);
    return { updated: true };
  });
}
