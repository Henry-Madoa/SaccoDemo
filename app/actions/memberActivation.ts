'use server';

import { revalidatePath } from 'next/cache';
import { requireAction, requireUser } from '@/lib/session';
import { actionResult } from '@/lib/errors';
import {
  createMemberActivationRequest, updateMemberActivationRequest, submitMemberActivationRequest,
  cancelMemberActivationApproval, approveMemberActivationRequest, rejectMemberActivationRequest,
  processMemberActivationRequest, eligibleMembersForActivation, debitableAccountsForMember,
  getMemberActivationJournal, type MemberActivationInput,
} from '@/lib/memberActivation';
import { findPendingRoutedTask, decideWorkflowTask } from '@/lib/workflow';
import type { JournalDetail } from '@/lib/gl';
import type {
  ActionResult, FormValues, MemberActivationRequestWithDimensions, PayFromAccountType, SavingsAccountForDebit,
} from '@/lib/types';

const toInput = (values: FormValues): MemberActivationInput => ({
  memberId: Number(values.memberId),
  reason: String(values.reason || ''),
  payFromAccountType: (values.payFromAccountType || 'MEMBER_ACCOUNT') as PayFromAccountType,
  paymentReference: values.paymentReference ? String(values.paymentReference) : null,
  transactionChargeId: values.transactionChargeId ? Number(values.transactionChargeId) : null,
  debitAccountId: values.debitAccountId ? Number(values.debitAccountId) : null,
});

/** Starts a new activation request against a Dormant member. */
export async function requestMemberActivation(values: FormValues): Promise<ActionResult<{ no: string }>> {
  return actionResult(async () => {
    const user = await requireAction('MEMBER_ACTIVATIONS_CREATE');
    const result = await createMemberActivationRequest(toInput(values), user);
    revalidatePath('/member-activations');
    revalidatePath('/members');
    return result;
  });
}

export async function saveMemberActivationRequest(
  no: string, values: FormValues,
): Promise<ActionResult<MemberActivationRequestWithDimensions>> {
  return actionResult(async () => {
    const user = await requireAction('MEMBER_ACTIVATIONS_CREATE');
    const saved = await updateMemberActivationRequest(no, toInput(values), user);
    revalidatePath('/member-activations');
    revalidatePath(`/member-activations/view/${no}`);
    return saved;
  });
}

/** Every account the member holds that could fund a reactivation charge — the Debit Account
 *  picklist shown only when paying from a member account. */
export async function accountsForActivationDebit(memberId: number): Promise<ActionResult<SavingsAccountForDebit[]>> {
  return actionResult(async () => {
    await requireAction('MEMBER_ACTIVATIONS_CREATE');
    return debitableAccountsForMember(memberId);
  });
}

export async function submitMemberActivation(no: string): Promise<ActionResult<{ updated: true; autoApproved: boolean }>> {
  return actionResult(async () => {
    const user = await requireAction('MEMBER_ACTIVATIONS_CREATE');
    const { autoApproved } = await submitMemberActivationRequest(no, user);
    revalidatePath('/member-activations');
    revalidatePath(`/member-activations/view/${no}`);
    return { updated: true, autoApproved };
  });
}

export async function cancelMemberActivationApprovalRequest(no: string): Promise<ActionResult<{ updated: true }>> {
  return actionResult(async () => {
    const user = await requireAction('MEMBER_ACTIVATIONS_CREATE');
    await cancelMemberActivationApproval(no, user);
    revalidatePath('/member-activations');
    revalidatePath(`/member-activations/view/${no}`);
    return { updated: true };
  });
}

/**
 * Delegates to whichever approval path actually governs this request: if a workflow routed it
 * to a specific approver, only that assignee may decide it; otherwise this falls back to the
 * flat MEMBER_ACTIVATIONS_APPROVE permission — same shape as accountActivation's own actions.
 */
export async function approveMemberActivation(no: string): Promise<ActionResult<{ updated: true }>> {
  return actionResult(async () => {
    const routed = await findPendingRoutedTask('MEMBER_ACTIVATION', no);
    if (routed) {
      const user = await requireUser();
      await decideWorkflowTask(routed.id, true, null, user);
    } else {
      const user = await requireAction('MEMBER_ACTIVATIONS_APPROVE');
      await approveMemberActivationRequest(no, user);
    }
    revalidatePath('/member-activations');
    revalidatePath(`/member-activations/view/${no}`);
    return { updated: true };
  });
}

export async function rejectMemberActivation(no: string, reason: string): Promise<ActionResult<{ updated: true }>> {
  return actionResult(async () => {
    const routed = await findPendingRoutedTask('MEMBER_ACTIVATION', no);
    if (routed) {
      const user = await requireUser();
      await decideWorkflowTask(routed.id, false, reason || null, user);
    } else {
      const user = await requireAction('MEMBER_ACTIVATIONS_APPROVE');
      await rejectMemberActivationRequest(no, reason, user);
    }
    revalidatePath('/member-activations');
    revalidatePath(`/member-activations/view/${no}`);
    return { updated: true };
  });
}

export async function processMemberActivation(no: string): Promise<ActionResult<{ memberId: number }>> {
  return actionResult(async () => {
    const user = await requireAction('MEMBER_ACTIVATIONS_APPROVE');
    const result = await processMemberActivationRequest(no, user);
    revalidatePath('/member-activations');
    revalidatePath(`/member-activations/view/${no}`);
    revalidatePath('/members');
    revalidatePath(`/members/${result.memberId}`);
    revalidatePath('/savings');
    return result;
  });
}

/** The Dormant members a new (or an Open request's edited) member picklist offers. */
export async function eligibleMembersForActivationRequest(): Promise<ActionResult<{ id: number; member_no: string; first_name: string; last_name: string }[]>> {
  return actionResult(async () => {
    await requireAction('MEMBER_ACTIVATIONS_CREATE');
    return eligibleMembersForActivation();
  });
}

/** Table 52204262/263-style "Navigate" — the posted reactivation-fee journal for a processed
 *  request, if any. */
export async function memberActivationJournal(no: string): Promise<ActionResult<JournalDetail | null>> {
  return actionResult(async () => {
    await requireAction('MEMBER_ACTIVATIONS_READ');
    return getMemberActivationJournal(no);
  });
}
