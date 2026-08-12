'use server';

import { revalidatePath } from 'next/cache';
import { requirePerm } from '@/lib/session';
import { actionResult } from '@/lib/errors';
import { createMember, updateMember, type MemberInput } from '@/lib/members';
import { toCents } from '@/lib/format';
import type { ActionResult, FormValues, MemberWithBranch } from '@/lib/types';

/**
 * Money arrives from the form as shillings typed by a user; the database only
 * ever holds integer minor units, so the conversion happens here rather than in
 * the browser, where a tampered payload could smuggle in a float.
 */
function normalise(values: FormValues): MemberInput {
  const { gross_income_sh, other_deductions_sh, ...rest } = values;
  const body = rest as MemberInput;
  if (gross_income_sh !== undefined) body.gross_income = toCents(gross_income_sh);
  if (other_deductions_sh !== undefined) body.other_deductions = toCents(other_deductions_sh);
  if (body.branch_id !== undefined) body.branch_id = Number(body.branch_id) || null;
  if (body.kyc_verified !== undefined) body.kyc_verified = Number(body.kyc_verified) ? 1 : 0;
  return body;
}

export async function saveMember(
  id: number | null,
  values: FormValues,
): Promise<ActionResult<MemberWithBranch>> {
  return actionResult(async () => {
    const user = await requirePerm(id ? 'MEMBER:UPDATE' : 'MEMBER:CREATE');
    const body = normalise(values);
    const saved = id ? await updateMember(id, body, user) : await createMember(body, user);
    revalidatePath('/members');
    if (id) revalidatePath(`/members/${id}`);
    return saved;
  });
}
