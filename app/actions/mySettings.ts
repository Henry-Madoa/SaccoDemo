'use server';

import { revalidatePath } from 'next/cache';
import { requireUser } from '@/lib/session';
import { actionResult } from '@/lib/errors';
import { setWorkDate, getWorkDate } from '@/lib/postingDates';
import { setActiveProfile } from '@/lib/profiles';
import type { ActionResult, Profile } from '@/lib/types';

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

/** My Settings → Role Centre: switch which Profile's dashboard `/dashboard` renders. Only a
 *  Profile the user has been assigned may be chosen; no permission is required, exactly like the
 *  Work Date. Revalidates the whole shell so the sidebar and dashboard update immediately. */
export async function saveActiveProfile(profileId: number | null): Promise<ActionResult<{ profile: Profile }>> {
  return actionResult(async () => {
    const user = await requireUser();
    const profile = await setActiveProfile(user.id, profileId, user);
    revalidatePath('/', 'layout');
    return { profile };
  });
}
