'use server';

import { revalidatePath } from 'next/cache';
import { requireAction } from '@/lib/session';
import { actionResult } from '@/lib/errors';
import {
  replaceApplicationNextOfKin, replaceApplicationNominees, type NextOfKinDraft, type NomineeDraft,
} from '@/lib/applicationNominees';
import type { ActionResult } from '@/lib/types';

export async function saveApplicationNextOfKin(
  applicationNo: string,
  rows: NextOfKinDraft[],
): Promise<ActionResult<{ updated: true }>> {
  return actionResult(async () => {
    await requireAction('MEMBER_APPLICATIONS_UPDATE');
    await replaceApplicationNextOfKin(applicationNo, rows);
    revalidatePath(`/member-applications/view/${applicationNo}`);
    return { updated: true };
  });
}

export async function saveApplicationNominees(
  applicationNo: string,
  rows: NomineeDraft[],
): Promise<ActionResult<{ updated: true }>> {
  return actionResult(async () => {
    await requireAction('MEMBER_APPLICATIONS_UPDATE');
    await replaceApplicationNominees(applicationNo, rows);
    revalidatePath(`/member-applications/view/${applicationNo}`);
    return { updated: true };
  });
}
