'use server';

import { requireAction } from '@/lib/session';
import { actionResult } from '@/lib/errors';
import { findMemberByIdentificationNo } from '@/lib/members';
import type { ActionResult } from '@/lib/types';

export interface MemberIdentityMatch {
  id: number;
  member_no: string;
  first_name: string;
  last_name: string;
  phone: string | null;
}

/** Looks up a live member by Identification No. — used by the Next of Kin / Nominee forms
 *  (Member Application, Member Edit) to auto-populate a row's name/phone when the person being
 *  listed turns out to already be a SACCO member. Returns null (not an error) when nothing
 *  matches, since "not an existing member" is the ordinary case, not a failure. */
export async function lookupMemberByIdentificationNo(
  identificationNo: string,
): Promise<ActionResult<MemberIdentityMatch | null>> {
  return actionResult(async () => {
    await requireAction('MEMBERS_READ');
    const trimmed = identificationNo.trim();
    if (!trimmed) return null;
    const match = await findMemberByIdentificationNo(trimmed);
    return match ?? null;
  });
}
