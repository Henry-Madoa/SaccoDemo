'use server';

import { revalidatePath } from 'next/cache';
import { requirePerm } from '@/lib/session';
import { actionResult } from '@/lib/errors';
import { replaceApplicationSignatories, type SignatoryDraft } from '@/lib/applicationSignatories';
import type { ActionResult } from '@/lib/types';

export async function saveApplicationSignatories(
  applicationNo: string,
  rows: SignatoryDraft[],
): Promise<ActionResult<{ updated: true }>> {
  return actionResult(async () => {
    const user = await requirePerm('MEMBER:UPDATE');
    await replaceApplicationSignatories(applicationNo, rows, user);
    revalidatePath(`/member-applications/view/${applicationNo}`);
    return { updated: true };
  });
}
