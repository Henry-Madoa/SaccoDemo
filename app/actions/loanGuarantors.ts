'use server';

import { revalidatePath } from 'next/cache';
import { requireAction } from '@/lib/session';
import { actionResult } from '@/lib/errors';
import { commitGuarantor, releaseGuarantor } from '@/lib/loanService';
import { listActiveMembers } from '@/lib/members';
import { guarantorCapacity } from '@/lib/guarantors';
import type { ActionResult, GuarantorCandidate } from '@/lib/types';

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
 *  whoever has already committed — each with how much they currently qualify to guarantee
 *  (lib/guarantors.ts's guarantorCapacity). The picker behind "Add guarantor" on a loan. */
export async function availableGuarantorsForLoan(
  borrowerMemberId: number, existingMemberIds: number[],
): Promise<ActionResult<GuarantorCandidate[]>> {
  return actionResult(async () => {
    await requireAction('LOAN_CREATE');
    const exclude = new Set([borrowerMemberId, ...existingMemberIds]);
    const candidates = (await listActiveMembers()).filter((m) => !exclude.has(m.id));
    return Promise.all(candidates.map(async (m) => ({
      id: m.id, member_no: m.member_no, first_name: m.first_name, last_name: m.last_name,
      availableGuarantee: (await guarantorCapacity(m.id)).available,
    })));
  });
}
