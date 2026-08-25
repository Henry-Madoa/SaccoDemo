'use server';

import { revalidatePath } from 'next/cache';
import { requireAction } from '@/lib/session';
import { actionResult } from '@/lib/errors';
import { attachFdToLoan, detachFdFromLoan, listAvailableFdForMember } from '@/lib/loanFdSecurity';
import type { ActionResult, AvailableFdRow } from '@/lib/types';

export async function attachFdToLoanRequest(
  loanId: number, fdNo: string, guaranteeSh: string | number,
): Promise<ActionResult<{ updated: true }>> {
  return actionResult(async () => {
    const user = await requireAction('LOAN_CREATE');
    const guarantee = Math.round(Number(String(guaranteeSh).replace(/,/g, '')) * 100) || 0;
    await attachFdToLoan({ loanId, fdNo, guarantee }, user);
    revalidatePath(`/loans/view/${loanId}`);
    revalidatePath('/fixed-deposits');
    return { updated: true };
  });
}

export async function detachFdFromLoanRequest(
  loanId: number, fdNo: string,
): Promise<ActionResult<{ updated: true }>> {
  return actionResult(async () => {
    const user = await requireAction('LOAN_CREATE');
    await detachFdFromLoan(loanId, fdNo, user);
    revalidatePath(`/loans/view/${loanId}`);
    revalidatePath('/fixed-deposits');
    return { updated: true };
  });
}

/** The Fixed Deposits this member could still pledge for a loan — approved or active, with cover
 *  left over. */
export async function availableFdForMember(memberId: number): Promise<ActionResult<AvailableFdRow[]>> {
  return actionResult(async () => {
    await requireAction('LOAN_CREATE');
    return listAvailableFdForMember(memberId);
  });
}
