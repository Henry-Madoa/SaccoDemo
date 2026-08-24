'use server';

import { revalidatePath } from 'next/cache';
import { requireAction } from '@/lib/session';
import { actionResult } from '@/lib/errors';
import { commitGuarantor, releaseGuarantor } from '@/lib/loanService';
import { listActiveMembers } from '@/lib/members';
import type { ActionResult, Member } from '@/lib/types';

export async function commitGuarantorToLoanRequest(
  loanId: number, memberId: number, amountSh: string | number,
): Promise<ActionResult<{ updated: true }>> {
  return actionResult(async () => {
    const user = await requireAction('LOAN_CREATE');
    const amount = Math.round(Number(String(amountSh).replace(/,/g, '')) * 100) || 0;
    await commitGuarantor({ loanId, memberId, amount }, user);
    revalidatePath(`/loans/view/${loanId}`);
    return { updated: true };
  });
}

export async function releaseGuarantorFromLoanRequest(
  loanId: number, memberId: number,
): Promise<ActionResult<{ updated: true }>> {
  return actionResult(async () => {
    const user = await requireAction('LOAN_CREATE');
    await releaseGuarantor(loanId, memberId, user);
    revalidatePath(`/loans/view/${loanId}`);
    return { updated: true };
  });
}

/** Active members who could still guarantee this loan — everyone except the applicant and
 *  whoever has already committed. The picker behind "Add guarantor" on a loan. */
export async function availableGuarantorsForLoan(
  borrowerMemberId: number, existingMemberIds: number[],
): Promise<ActionResult<Pick<Member, 'id' | 'member_no' | 'first_name' | 'last_name'>[]>> {
  return actionResult(async () => {
    await requireAction('LOAN_CREATE');
    const exclude = new Set([borrowerMemberId, ...existingMemberIds]);
    return (await listActiveMembers()).filter((m) => !exclude.has(m.id));
  });
}
