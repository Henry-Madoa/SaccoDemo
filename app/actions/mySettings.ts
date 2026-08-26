'use server';

import { revalidatePath } from 'next/cache';
import { requireUser } from '@/lib/session';
import { actionResult } from '@/lib/errors';
import { setWorkDate, getWorkDate } from '@/lib/postingDates';
import type { ActionResult } from '@/lib/types';

/** Sets (or, given an empty string, clears back to the real system date) the current user's own
 *  Work Date — validated server-side against their effective Allow Posting range regardless of
 *  what the client's date input already enforced. */
export async function saveWorkDate(date: string): Promise<ActionResult<{ workDate: string }>> {
  return actionResult(async () => {
    const user = await requireUser();
    await setWorkDate(user.id, date, user);
    revalidatePath('/my-settings');
    return { workDate: await getWorkDate(user.id) };
  });
}
