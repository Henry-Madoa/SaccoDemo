'use server';

import { revalidatePath } from 'next/cache';
import { requireAction } from '@/lib/session';
import { actionResult } from '@/lib/errors';
import { attachCollateralToLoan, detachCollateralFromLoan } from '@/lib/loanCollateral';
import { listAvailableCollateralForMember } from '@/lib/collateralRegister';
import type { ActionResult, AvailableCollateralRow } from '@/lib/types';

export async function attachCollateralToLoanRequest(
  loanId: number, collateralNo: string, guaranteeSh: string | number,
): Promise<ActionResult<{ updated: true }>> {
  return actionResult(async () => {
    const user = await requireAction('LOAN_CREATE');
    const guarantee = Math.round(Number(String(guaranteeSh).replace(/,/g, '')) * 100) || 0;
    await attachCollateralToLoan({ loanId, collateralNo, guarantee }, user);
    revalidatePath(`/loans/view/${loanId}`);
    revalidatePath('/collateral-register');
    return { updated: true };
  });
}

export async function detachCollateralFromLoanRequest(
  loanId: number, collateralNo: string,
): Promise<ActionResult<{ updated: true }>> {
  return actionResult(async () => {
    const user = await requireAction('LOAN_CREATE');
    await detachCollateralFromLoan(loanId, collateralNo, user);
    revalidatePath(`/loans/view/${loanId}`);
    revalidatePath('/collateral-register');
    return { updated: true };
  });
}

/** The collateral register items this member could still pledge for a loan — registered, not
 *  collected, with cover left over. */
export async function availableCollateralForMember(memberId: number): Promise<ActionResult<AvailableCollateralRow[]>> {
  return actionResult(async () => {
    await requireAction('LOAN_CREATE');
    return listAvailableCollateralForMember(memberId);
  });
}
