'use server';

import { revalidatePath } from 'next/cache';
import { requireAction, requireUser } from '@/lib/session';
import { actionResult } from '@/lib/errors';
import {
  createAccountOpeningRequest, updateAccountOpeningRequest, submitAccountOpeningRequest,
  cancelAccountOpeningApproval, approveAccountOpeningRequest, rejectAccountOpeningRequest,
  processAccountOpeningRequest, eligibleProducts,
} from '@/lib/accountOpening';
import { findPendingRoutedTask, decideWorkflowTask } from '@/lib/workflow';
import type {
  AccountOpeningRequestWithDimensions, ActionResult, FormValues, SavingsProduct,
} from '@/lib/types';

/** Starts a new account opening request for an existing member. Always opens at a zero
 *  balance — funding the account is a separate Savings & FOSA deposit, done afterwards. */
export async function requestAccountOpening(values: FormValues): Promise<ActionResult<{ no: string }>> {
  return actionResult(async () => {
    const user = await requireAction('ACCOUNT_OPENING_CREATE');
    const result = await createAccountOpeningRequest({
      memberId: Number(values.memberId),
      productId: Number(values.productId),
      notes: values.notes ? String(values.notes) : null,
      businessName: values.businessName ? String(values.businessName) : null,
      businessLocation: values.businessLocation ? String(values.businessLocation) : null,
      businessPaybillTillNo: values.businessPaybillTillNo ? String(values.businessPaybillTillNo) : null,
      businessPhoneNo: values.businessPhoneNo ? String(values.businessPhoneNo) : null,
      juniorName: values.juniorName ? String(values.juniorName) : null,
      juniorBirthCertNo: values.juniorBirthCertNo ? String(values.juniorBirthCertNo) : null,
      juniorDateOfBirth: values.juniorDateOfBirth ? String(values.juniorDateOfBirth) : null,
    }, user);
    revalidatePath('/account-openings');
    revalidatePath(`/members/${values.memberId}`);
    return result;
  });
}

export async function saveAccountOpeningRequest(
  no: string, values: FormValues,
): Promise<ActionResult<AccountOpeningRequestWithDimensions>> {
  return actionResult(async () => {
    const user = await requireAction('ACCOUNT_OPENING_CREATE');
    const saved = await updateAccountOpeningRequest(no, {
      productId: values.productId !== undefined ? Number(values.productId) : undefined,
      notes: values.notes !== undefined ? String(values.notes) : undefined,
      businessName: values.businessName !== undefined ? String(values.businessName) : undefined,
      businessLocation: values.businessLocation !== undefined ? String(values.businessLocation) : undefined,
      businessPaybillTillNo: values.businessPaybillTillNo !== undefined ? String(values.businessPaybillTillNo) : undefined,
      businessPhoneNo: values.businessPhoneNo !== undefined ? String(values.businessPhoneNo) : undefined,
      juniorName: values.juniorName !== undefined ? String(values.juniorName) : undefined,
      juniorBirthCertNo: values.juniorBirthCertNo !== undefined ? String(values.juniorBirthCertNo) : undefined,
      juniorDateOfBirth: values.juniorDateOfBirth !== undefined ? String(values.juniorDateOfBirth) : undefined,
    }, user);
    revalidatePath('/account-openings');
    return saved;
  });
}

export async function submitAccountOpening(no: string): Promise<ActionResult<{ updated: true; autoApproved: boolean }>> {
  return actionResult(async () => {
    const user = await requireAction('ACCOUNT_OPENING_CREATE');
    const { autoApproved } = await submitAccountOpeningRequest(no, user);
    revalidatePath('/account-openings');
    revalidatePath(`/account-openings/view/${no}`);
    return { updated: true, autoApproved };
  });
}

export async function cancelAccountOpeningApprovalRequest(no: string): Promise<ActionResult<{ updated: true }>> {
  return actionResult(async () => {
    const user = await requireAction('ACCOUNT_OPENING_CREATE');
    await cancelAccountOpeningApproval(no, user);
    revalidatePath('/account-openings');
    revalidatePath(`/account-openings/view/${no}`);
    return { updated: true };
  });
}

/**
 * Delegates to whichever approval path actually governs this request: if a workflow
 * routed it to a specific approver, only that assignee may decide it (via
 * decideWorkflowTask); otherwise this falls back to the flat ACCOUNT_OPENING_APPROVE permission.
 */
export async function approveAccountOpening(no: string): Promise<ActionResult<{ updated: true }>> {
  return actionResult(async () => {
    const routed = await findPendingRoutedTask('ACCOUNT_OPENING', no);
    if (routed) {
      const user = await requireUser();
      await decideWorkflowTask(routed.id, true, null, user);
    } else {
      const user = await requireAction('ACCOUNT_OPENING_APPROVE');
      await approveAccountOpeningRequest(no, user);
    }
    revalidatePath('/account-openings');
    revalidatePath(`/account-openings/view/${no}`);
    return { updated: true };
  });
}

export async function rejectAccountOpening(no: string, reason: string): Promise<ActionResult<{ updated: true }>> {
  return actionResult(async () => {
    const routed = await findPendingRoutedTask('ACCOUNT_OPENING', no);
    if (routed) {
      const user = await requireUser();
      await decideWorkflowTask(routed.id, false, reason || null, user);
    } else {
      const user = await requireAction('ACCOUNT_OPENING_APPROVE');
      await rejectAccountOpeningRequest(no, reason, user);
    }
    revalidatePath('/account-openings');
    revalidatePath(`/account-openings/view/${no}`);
    return { updated: true };
  });
}

export async function processAccountOpening(no: string): Promise<ActionResult<{ accountId: number }>> {
  return actionResult(async () => {
    const user = await requireAction('ACCOUNT_OPENING_APPROVE');
    const result = await processAccountOpeningRequest(no, user);
    revalidatePath('/account-openings');
    revalidatePath(`/account-openings/view/${no}`);
    revalidatePath('/savings');
    return result;
  });
}

/** The savings products a member could still request through this module — every active
 *  product except their category's default accounts. Fetched per-member since the New Request
 *  form's product list depends on whichever member is currently selected. */
export async function eligibleProductsForMember(memberId: number): Promise<ActionResult<SavingsProduct[]>> {
  return actionResult(async () => {
    await requireAction('ACCOUNT_OPENING_CREATE');
    return eligibleProducts(memberId);
  });
}
