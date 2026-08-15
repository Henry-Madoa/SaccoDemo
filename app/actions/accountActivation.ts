'use server';

import { revalidatePath } from 'next/cache';
import { requireAction, requireUser } from '@/lib/session';
import { actionResult } from '@/lib/errors';
import {
  createAccountActivationRequest, updateAccountActivationRequest, submitAccountActivationRequest,
  cancelAccountActivationApproval, approveAccountActivationRequest, rejectAccountActivationRequest,
  processAccountActivationRequest, eligibleAccountsForMember, debitableAccountsForMember,
} from '@/lib/accountActivation';
import { findPendingRoutedTask, decideWorkflowTask } from '@/lib/workflow';
import type {
  AccountActivationRequestWithDimensions, ActionResult, FormValues, SavingsAccountForDebit, SavingsAccountWithProduct,
} from '@/lib/types';

/** Starts a new activation request against one of a member's INACTIVE accounts. */
export async function requestAccountActivation(values: FormValues): Promise<ActionResult<{ no: string }>> {
  return actionResult(async () => {
    const user = await requireAction('ACCOUNT_ACTIVATION_CREATE');
    const result = await createAccountActivationRequest({
      accountId: Number(values.accountId),
      reason: String(values.reason || ''),
      transactionChargeId: values.transactionChargeId ? Number(values.transactionChargeId) : null,
      debitAccountId: values.debitAccountId ? Number(values.debitAccountId) : null,
    }, user);
    revalidatePath('/account-activations');
    revalidatePath('/savings');
    return result;
  });
}

export async function saveAccountActivationRequest(
  no: string, values: FormValues,
): Promise<ActionResult<AccountActivationRequestWithDimensions>> {
  return actionResult(async () => {
    const user = await requireAction('ACCOUNT_ACTIVATION_CREATE');
    const saved = await updateAccountActivationRequest(no, {
      reason: String(values.reason || ''),
      transactionChargeId: values.transactionChargeId ? Number(values.transactionChargeId) : null,
      debitAccountId: values.debitAccountId ? Number(values.debitAccountId) : null,
    }, user);
    revalidatePath('/account-activations');
    revalidatePath(`/account-activations/view/${no}`);
    return saved;
  });
}

/** Every account the member holds — the Debit Account picklist for a reactivation charge,
 *  deliberately unfiltered by status (see debitableAccountsForMember()). */
export async function accountsForActivationDebit(memberId: number): Promise<ActionResult<SavingsAccountForDebit[]>> {
  return actionResult(async () => {
    await requireAction('ACCOUNT_ACTIVATION_CREATE');
    return debitableAccountsForMember(memberId);
  });
}

export async function submitAccountActivation(no: string): Promise<ActionResult<{ updated: true; autoApproved: boolean }>> {
  return actionResult(async () => {
    const user = await requireAction('ACCOUNT_ACTIVATION_CREATE');
    const { autoApproved } = await submitAccountActivationRequest(no, user);
    revalidatePath('/account-activations');
    revalidatePath(`/account-activations/view/${no}`);
    return { updated: true, autoApproved };
  });
}

export async function cancelAccountActivationApprovalRequest(no: string): Promise<ActionResult<{ updated: true }>> {
  return actionResult(async () => {
    const user = await requireAction('ACCOUNT_ACTIVATION_CREATE');
    await cancelAccountActivationApproval(no, user);
    revalidatePath('/account-activations');
    revalidatePath(`/account-activations/view/${no}`);
    return { updated: true };
  });
}

/**
 * Delegates to whichever approval path actually governs this request: if a workflow
 * routed it to a specific approver, only that assignee may decide it (via
 * decideWorkflowTask); otherwise this falls back to the flat ACCOUNT_ACTIVATION_APPROVE
 * permission.
 */
export async function approveAccountActivation(no: string): Promise<ActionResult<{ updated: true }>> {
  return actionResult(async () => {
    const routed = await findPendingRoutedTask('ACCOUNT_ACTIVATION', no);
    if (routed) {
      const user = await requireUser();
      await decideWorkflowTask(routed.id, true, null, user);
    } else {
      const user = await requireAction('ACCOUNT_ACTIVATION_APPROVE');
      await approveAccountActivationRequest(no, user);
    }
    revalidatePath('/account-activations');
    revalidatePath(`/account-activations/view/${no}`);
    return { updated: true };
  });
}

export async function rejectAccountActivation(no: string, reason: string): Promise<ActionResult<{ updated: true }>> {
  return actionResult(async () => {
    const routed = await findPendingRoutedTask('ACCOUNT_ACTIVATION', no);
    if (routed) {
      const user = await requireUser();
      await decideWorkflowTask(routed.id, false, reason || null, user);
    } else {
      const user = await requireAction('ACCOUNT_ACTIVATION_APPROVE');
      await rejectAccountActivationRequest(no, reason, user);
    }
    revalidatePath('/account-activations');
    revalidatePath(`/account-activations/view/${no}`);
    return { updated: true };
  });
}

export async function processAccountActivation(no: string): Promise<ActionResult<{ accountId: number }>> {
  return actionResult(async () => {
    const user = await requireAction('ACCOUNT_ACTIVATION_APPROVE');
    const result = await processAccountActivationRequest(no, user);
    revalidatePath('/account-activations');
    revalidatePath(`/account-activations/view/${no}`);
    revalidatePath('/savings');
    revalidatePath(`/savings/${result.accountId}`);
    return result;
  });
}

/** The INACTIVE accounts a member could still request activation for. Fetched per-member since
 *  the New Request form's account list depends on whichever member is currently selected. */
export async function eligibleAccountsForActivation(memberId: number): Promise<ActionResult<SavingsAccountWithProduct[]>> {
  return actionResult(async () => {
    await requireAction('ACCOUNT_ACTIVATION_CREATE');
    return eligibleAccountsForMember(memberId);
  });
}
