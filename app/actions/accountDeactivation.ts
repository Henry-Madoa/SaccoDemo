'use server';

import { revalidatePath } from 'next/cache';
import { requireAction, requireUser } from '@/lib/session';
import { actionResult } from '@/lib/errors';
import {
  createAccountDeactivationRequest, updateAccountDeactivationRequest, submitAccountDeactivationRequest,
  cancelAccountDeactivationApproval, approveAccountDeactivationRequest, rejectAccountDeactivationRequest,
  processAccountDeactivationRequest, eligibleAccountsForMember,
} from '@/lib/accountDeactivation';
import { findPendingRoutedTask, decideWorkflowTask } from '@/lib/workflow';
import type {
  AccountDeactivationRequestWithDimensions, ActionResult, FormValues, SavingsAccountWithProduct,
} from '@/lib/types';

/** Starts a new deactivation request against one of a member's non-default active accounts. */
export async function requestAccountDeactivation(values: FormValues): Promise<ActionResult<{ no: string }>> {
  return actionResult(async () => {
    const user = await requireAction('ACCOUNT_DEACTIVATION_CREATE');
    const result = await createAccountDeactivationRequest({
      accountId: Number(values.accountId),
      reason: String(values.reason || ''),
    }, user);
    revalidatePath('/account-deactivations');
    revalidatePath('/savings');
    return result;
  });
}

export async function saveAccountDeactivationRequest(
  no: string, values: FormValues,
): Promise<ActionResult<AccountDeactivationRequestWithDimensions>> {
  return actionResult(async () => {
    const user = await requireAction('ACCOUNT_DEACTIVATION_CREATE');
    const saved = await updateAccountDeactivationRequest(no, String(values.reason || ''), user);
    revalidatePath('/account-deactivations');
    return saved;
  });
}

export async function submitAccountDeactivation(no: string): Promise<ActionResult<{ updated: true; autoApproved: boolean }>> {
  return actionResult(async () => {
    const user = await requireAction('ACCOUNT_DEACTIVATION_CREATE');
    const { autoApproved } = await submitAccountDeactivationRequest(no, user);
    revalidatePath('/account-deactivations');
    revalidatePath(`/account-deactivations/view/${no}`);
    return { updated: true, autoApproved };
  });
}

export async function cancelAccountDeactivationApprovalRequest(no: string): Promise<ActionResult<{ updated: true }>> {
  return actionResult(async () => {
    const user = await requireAction('ACCOUNT_DEACTIVATION_CREATE');
    await cancelAccountDeactivationApproval(no, user);
    revalidatePath('/account-deactivations');
    revalidatePath(`/account-deactivations/view/${no}`);
    return { updated: true };
  });
}

/**
 * Delegates to whichever approval path actually governs this request: if a workflow
 * routed it to a specific approver, only that assignee may decide it (via
 * decideWorkflowTask); otherwise this falls back to the flat ACCOUNT_DEACTIVATION_APPROVE
 * permission.
 */
export async function approveAccountDeactivation(no: string): Promise<ActionResult<{ updated: true }>> {
  return actionResult(async () => {
    const routed = await findPendingRoutedTask('ACCOUNT_DEACTIVATION', no);
    if (routed) {
      const user = await requireUser();
      await decideWorkflowTask(routed.id, true, null, user);
    } else {
      const user = await requireAction('ACCOUNT_DEACTIVATION_APPROVE');
      await approveAccountDeactivationRequest(no, user);
    }
    revalidatePath('/account-deactivations');
    revalidatePath(`/account-deactivations/view/${no}`);
    return { updated: true };
  });
}

export async function rejectAccountDeactivation(no: string, reason: string): Promise<ActionResult<{ updated: true }>> {
  return actionResult(async () => {
    const routed = await findPendingRoutedTask('ACCOUNT_DEACTIVATION', no);
    if (routed) {
      const user = await requireUser();
      await decideWorkflowTask(routed.id, false, reason || null, user);
    } else {
      const user = await requireAction('ACCOUNT_DEACTIVATION_APPROVE');
      await rejectAccountDeactivationRequest(no, reason, user);
    }
    revalidatePath('/account-deactivations');
    revalidatePath(`/account-deactivations/view/${no}`);
    return { updated: true };
  });
}

export async function processAccountDeactivation(no: string): Promise<ActionResult<{ accountId: number }>> {
  return actionResult(async () => {
    const user = await requireAction('ACCOUNT_DEACTIVATION_APPROVE');
    const result = await processAccountDeactivationRequest(no, user);
    revalidatePath('/account-deactivations');
    revalidatePath(`/account-deactivations/view/${no}`);
    revalidatePath('/savings');
    revalidatePath(`/savings/${result.accountId}`);
    return result;
  });
}

/** The non-default, ACTIVE accounts a member could still request deactivation for. Fetched
 *  per-member since the New Request form's account list depends on whichever member is
 *  currently selected. */
export async function eligibleAccountsForDeactivation(memberId: number): Promise<ActionResult<SavingsAccountWithProduct[]>> {
  return actionResult(async () => {
    await requireAction('ACCOUNT_DEACTIVATION_CREATE');
    return eligibleAccountsForMember(memberId);
  });
}
