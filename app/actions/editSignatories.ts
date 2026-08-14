'use server';

import { revalidatePath } from 'next/cache';
import { requirePerm } from '@/lib/session';
import { actionResult } from '@/lib/errors';
import { replaceEditSignatories, type SignatoryDraft } from '@/lib/editSignatories';
import type { ActionResult } from '@/lib/types';

export async function saveEditSignatories(
  editNo: string,
  rows: SignatoryDraft[],
): Promise<ActionResult<{ updated: true }>> {
  return actionResult(async () => {
    await requirePerm('MEMBER:UPDATE');
    await replaceEditSignatories(editNo, rows);
    revalidatePath(`/member-edits/view/${editNo}`);
    return { updated: true };
  });
}
