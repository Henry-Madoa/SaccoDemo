'use server';

import { revalidatePath } from 'next/cache';
import { requirePerm } from '@/lib/session';
import { actionResult } from '@/lib/errors';
import {
  replaceEditNextOfKin, replaceEditNominees, type NextOfKinDraft, type NomineeDraft,
} from '@/lib/editNominees';
import type { ActionResult } from '@/lib/types';

export async function saveEditNextOfKin(
  editNo: string,
  rows: NextOfKinDraft[],
): Promise<ActionResult<{ updated: true }>> {
  return actionResult(async () => {
    await requirePerm('MEMBER:UPDATE');
    await replaceEditNextOfKin(editNo, rows);
    revalidatePath(`/member-edits/view/${editNo}`);
    return { updated: true };
  });
}

export async function saveEditNominees(
  editNo: string,
  rows: NomineeDraft[],
): Promise<ActionResult<{ updated: true }>> {
  return actionResult(async () => {
    await requirePerm('MEMBER:UPDATE');
    await replaceEditNominees(editNo, rows);
    revalidatePath(`/member-edits/view/${editNo}`);
    return { updated: true };
  });
}
