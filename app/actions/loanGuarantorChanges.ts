'use server';

import { revalidatePath } from 'next/cache';
import { requireAction, requireUser } from '@/lib/session';
import { actionResult, AppError } from '@/lib/errors';
import {
  createGuarantorChange, refreshGuarantorChangeLines, setLineRelease, addReplacement, removeReplacement,
  submitGuarantorChange, cancelGuarantorChangeApproval, approveGuarantorChange, rejectGuarantorChange,
  processGuarantorChange, getGuarantorChange, type AddReplacementInput,
} from '@/lib/loanGuarantorChanges';
import { findPendingRoutedTask, decideWorkflowTask } from '@/lib/workflow';
import { listActiveMembers } from '@/lib/members';
import { guarantorCapacity } from '@/lib/guarantors';
import { listAvailableCollateralForMember } from '@/lib/collateralRegister';
import { listAvailableFdForMember } from '@/lib/loanFdSecurity';
import type {
  ActionResult, AvailableCollateralRow, AvailableFdRow, GuarantorCandidate, ReplacementType,
} from '@/lib/types';

export async function requestGuarantorChange(loanId: number): Promise<ActionResult<{ no: string }>> {
  return actionResult(async () => {
    const user = await requireAction('GUARANTOR_CHANGES_CREATE');
    const result = await createGuarantorChange(loanId, user);
    revalidatePath('/guarantor-changes');
    revalidatePath(`/loans/view/${loanId}`);
    return result;
  });
}

export async function refreshGuarantorChangeLinesRequest(no: string): Promise<ActionResult<{ updated: true }>> {
  return actionResult(async () => {
    const user = await requireAction('GUARANTOR_CHANGES_CREATE');
    await refreshGuarantorChangeLines(no, user);
    revalidatePath(`/guarantor-changes/view/${no}`);
    return { updated: true };
  });
}

export async function setLineReleaseRequest(
  no: string, lineId: number, release: boolean,
): Promise<ActionResult<{ updated: true }>> {
  return actionResult(async () => {
    const user = await requireAction('GUARANTOR_CHANGES_CREATE');
    await setLineRelease(no, lineId, release, user);
    revalidatePath(`/guarantor-changes/view/${no}`);
    return { updated: true };
  });
}

export async function addReplacementRequest(
  no: string, lineId: number, type: ReplacementType, code: string, amountSh: string | number,
): Promise<ActionResult<{ updated: true }>> {
  return actionResult(async () => {
    const user = await requireAction('GUARANTOR_CHANGES_CREATE');
    const amount = Math.round(Number(String(amountSh).replace(/,/g, '')) * 100) || 0;
    const input: AddReplacementInput = { type };
    if (type === 'GUARANTOR') input.memberId = Number(code);
    else if (type === 'COLLATERAL') input.collateralNo = code;
    else if (type === 'FIXED_DEPOSIT') input.fdNo = code;
    await addReplacement(no, lineId, input, amount, user);
    revalidatePath(`/guarantor-changes/view/${no}`);
    return { updated: true };
  });
}

export async function removeReplacementRequest(no: string, replacementId: number): Promise<ActionResult<{ updated: true }>> {
  return actionResult(async () => {
    const user = await requireAction('GUARANTOR_CHANGES_CREATE');
    await removeReplacement(no, replacementId, user);
    revalidatePath(`/guarantor-changes/view/${no}`);
    return { updated: true };
  });
}

export async function submitGuarantorChangeRequest(no: string): Promise<ActionResult<{ updated: true; autoApproved: boolean }>> {
  return actionResult(async () => {
    const user = await requireAction('GUARANTOR_CHANGES_CREATE');
    const { autoApproved } = await submitGuarantorChange(no, user);
    revalidatePath('/guarantor-changes');
    revalidatePath(`/guarantor-changes/view/${no}`);
    return { updated: true, autoApproved };
  });
}

export async function cancelGuarantorChangeApprovalRequest(no: string): Promise<ActionResult<{ updated: true }>> {
  return actionResult(async () => {
    const user = await requireAction('GUARANTOR_CHANGES_CREATE');
    await cancelGuarantorChangeApproval(no, user);
    revalidatePath('/guarantor-changes');
    revalidatePath(`/guarantor-changes/view/${no}`);
    return { updated: true };
  });
}

export async function approveGuarantorChangeRequest(no: string): Promise<ActionResult<{ updated: true }>> {
  return actionResult(async () => {
    const routed = await findPendingRoutedTask('GUARANTOR_CHANGE', no);
    if (routed) {
      const user = await requireUser();
      await decideWorkflowTask(routed.id, true, null, user);
    } else {
      const user = await requireAction('GUARANTOR_CHANGES_APPROVE');
      await approveGuarantorChange(no, user);
    }
    revalidatePath('/guarantor-changes');
    revalidatePath(`/guarantor-changes/view/${no}`);
    return { updated: true };
  });
}

export async function rejectGuarantorChangeRequest(no: string, reason: string): Promise<ActionResult<{ updated: true }>> {
  return actionResult(async () => {
    const routed = await findPendingRoutedTask('GUARANTOR_CHANGE', no);
    if (routed) {
      const user = await requireUser();
      await decideWorkflowTask(routed.id, false, reason || null, user);
    } else {
      const user = await requireAction('GUARANTOR_CHANGES_APPROVE');
      await rejectGuarantorChange(no, reason, user);
    }
    revalidatePath('/guarantor-changes');
    revalidatePath(`/guarantor-changes/view/${no}`);
    return { updated: true };
  });
}

/** Active members who could stand in as a replacement guarantor on this document's loan —
 *  everyone except the loan's own borrower (this schema has no self-guarantee row, see
 *  lib/loanGuarantorChanges.ts's addReplacement()) — each with how much they currently qualify to
 *  guarantee (lib/guarantors.ts's guarantorCapacity). Mirrors availableGuarantorsForLoan in
 *  app/actions/loanGuarantors.ts, the same picker used for pre-disbursement commitments. */
export async function availableReplacementsForChange(no: string): Promise<ActionResult<GuarantorCandidate[]>> {
  return actionResult(async () => {
    await requireAction('GUARANTOR_CHANGES_CREATE');
    const change = await getGuarantorChange(no);
    if (!change) throw new AppError('Guarantor change not found', 'NOT_FOUND');
    const candidates = (await listActiveMembers()).filter((m) => m.id !== change.member_id);
    return Promise.all(candidates.map(async (m) => ({
      id: m.id, member_no: m.member_no, first_name: m.first_name, last_name: m.last_name,
      availableGuarantee: (await guarantorCapacity(m.id)).available,
    })));
  });
}

/** The loan's own borrower's registered collateral with cover left — a replacement of type
 *  COLLATERAL can only ever be one of these, matching AL's Det. Lines TableRelation. */
export async function availableCollateralForGuarantorChange(no: string): Promise<ActionResult<AvailableCollateralRow[]>> {
  return actionResult(async () => {
    await requireAction('GUARANTOR_CHANGES_CREATE');
    const change = await getGuarantorChange(no);
    if (!change) throw new AppError('Guarantor change not found', 'NOT_FOUND');
    return listAvailableCollateralForMember(change.member_id);
  });
}

/** The loan's own borrower's approved/active fixed deposits with cover left — a replacement of
 *  type FIXED_DEPOSIT can only ever be one of these. */
export async function availableFdForGuarantorChange(no: string): Promise<ActionResult<AvailableFdRow[]>> {
  return actionResult(async () => {
    await requireAction('GUARANTOR_CHANGES_CREATE');
    const change = await getGuarantorChange(no);
    if (!change) throw new AppError('Guarantor change not found', 'NOT_FOUND');
    return listAvailableFdForMember(change.member_id);
  });
}

export async function processGuarantorChangeRequest(no: string): Promise<ActionResult<{ loanId: number }>> {
  return actionResult(async () => {
    const user = await requireAction('GUARANTOR_CHANGES_APPROVE');
    const result = await processGuarantorChange(no, user);
    revalidatePath('/guarantor-changes');
    revalidatePath(`/guarantor-changes/view/${no}`);
    revalidatePath(`/loans/view/${result.loanId}`);
    return result;
  });
}
