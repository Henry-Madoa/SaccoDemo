'use server';

import { revalidatePath } from 'next/cache';
import { requireAction, requireUser } from '@/lib/session';
import { actionResult } from '@/lib/errors';
import {
  createMemberReadmissionRequest, updateMemberReadmissionRequest, submitMemberReadmissionRequest,
  cancelMemberReadmissionApproval, approveMemberReadmissionRequest, rejectMemberReadmissionRequest,
  processMemberReadmissionRequest, eligibleMembersForReadmission, debitableAccountsForMember,
  getMemberReadmissionJournal, type MemberReadmissionInput,
} from '@/lib/memberReadmission';
import { findPendingRoutedTask, decideWorkflowTask } from '@/lib/workflow';
import type { JournalDetail } from '@/lib/gl';
import type {
  ActionResult, FormValues, MemberReadmissionRequestWithDimensions, PayFromAccountType, SavingsAccountForDebit,
} from '@/lib/types';

const toInput = (values: FormValues): MemberReadmissionInput => ({
  memberId: Number(values.memberId),
  reason: String(values.reason || ''),
  payFromAccountType: (values.payFromAccountType || 'MEMBER_ACCOUNT') as PayFromAccountType,
  paymentReference: values.paymentReference ? String(values.paymentReference) : null,
  transactionChargeId: values.transactionChargeId ? Number(values.transactionChargeId) : null,
  debitAccountId: values.debitAccountId ? Number(values.debitAccountId) : null,
});

/** Starts a new re-admission request against a Withdrawn member. */
export async function requestMemberReadmission(values: FormValues): Promise<ActionResult<{ no: string }>> {
  return actionResult(async () => {
    const user = await requireAction('MEMBER_READMISSIONS_CREATE');
    const result = await createMemberReadmissionRequest(toInput(values), user);
    revalidatePath('/member-readmissions');
    revalidatePath('/members');
    return result;
  });
}

export async function saveMemberReadmissionRequest(
  no: string, values: FormValues,
): Promise<ActionResult<MemberReadmissionRequestWithDimensions>> {
  return actionResult(async () => {
    const user = await requireAction('MEMBER_READMISSIONS_CREATE');
    const saved = await updateMemberReadmissionRequest(no, toInput(values), user);
    revalidatePath('/member-readmissions');
    revalidatePath(`/member-readmissions/view/${no}`);
    return saved;
  });
}

/** Every account the member holds that could fund a re-admission charge — the Debit Account
 *  picklist shown only when paying from a member account. */
export async function accountsForReadmissionDebit(memberId: number): Promise<ActionResult<SavingsAccountForDebit[]>> {
  return actionResult(async () => {
    await requireAction('MEMBER_READMISSIONS_CREATE');
    return debitableAccountsForMember(memberId);
  });
}

export async function submitMemberReadmission(no: string): Promise<ActionResult<{ updated: true; autoApproved: boolean }>> {
  return actionResult(async () => {
    const user = await requireAction('MEMBER_READMISSIONS_CREATE');
    const { autoApproved } = await submitMemberReadmissionRequest(no, user);
    revalidatePath('/member-readmissions');
    revalidatePath(`/member-readmissions/view/${no}`);
    return { updated: true, autoApproved };
  });
}

export async function cancelMemberReadmissionApprovalRequest(no: string): Promise<ActionResult<{ updated: true }>> {
  return actionResult(async () => {
    const user = await requireAction('MEMBER_READMISSIONS_CREATE');
    await cancelMemberReadmissionApproval(no, user);
    revalidatePath('/member-readmissions');
    revalidatePath(`/member-readmissions/view/${no}`);
    return { updated: true };
  });
}

/**
 * Delegates to whichever approval path actually governs this request: if a workflow routed it
 * to a specific approver, only that assignee may decide it; otherwise this falls back to the
 * flat MEMBER_READMISSIONS_APPROVE permission — same shape as memberActivation's own actions.
 */
export async function approveMemberReadmission(no: string): Promise<ActionResult<{ updated: true }>> {
  return actionResult(async () => {
    const routed = await findPendingRoutedTask('MEMBER_READMISSION', no);
    if (routed) {
      const user = await requireUser();
      await decideWorkflowTask(routed.id, true, null, user);
    } else {
      const user = await requireAction('MEMBER_READMISSIONS_APPROVE');
      await approveMemberReadmissionRequest(no, user);
    }
    revalidatePath('/member-readmissions');
    revalidatePath(`/member-readmissions/view/${no}`);
    return { updated: true };
  });
}

export async function rejectMemberReadmission(no: string, reason: string): Promise<ActionResult<{ updated: true }>> {
  return actionResult(async () => {
    const routed = await findPendingRoutedTask('MEMBER_READMISSION', no);
    if (routed) {
      const user = await requireUser();
      await decideWorkflowTask(routed.id, false, reason || null, user);
    } else {
      const user = await requireAction('MEMBER_READMISSIONS_APPROVE');
      await rejectMemberReadmissionRequest(no, reason, user);
    }
    revalidatePath('/member-readmissions');
    revalidatePath(`/member-readmissions/view/${no}`);
    return { updated: true };
  });
}

export async function processMemberReadmission(no: string): Promise<ActionResult<{ memberId: number }>> {
  return actionResult(async () => {
    const user = await requireAction('MEMBER_READMISSIONS_APPROVE');
    const result = await processMemberReadmissionRequest(no, user);
    revalidatePath('/member-readmissions');
    revalidatePath(`/member-readmissions/view/${no}`);
    revalidatePath('/members');
    revalidatePath(`/members/${result.memberId}`);
    revalidatePath('/savings');
    return result;
  });
}

/** The Withdrawn members a new (or an Open request's edited) member picklist offers. */
export async function eligibleMembersForReadmissionRequest(): Promise<ActionResult<{ id: number; member_no: string; first_name: string; last_name: string }[]>> {
  return actionResult(async () => {
    await requireAction('MEMBER_READMISSIONS_CREATE');
    return eligibleMembersForReadmission();
  });
}

/** The posted re-admission-fee journal for a processed request, if any. */
export async function memberReadmissionJournal(no: string): Promise<ActionResult<JournalDetail | null>> {
  return actionResult(async () => {
    await requireAction('MEMBER_READMISSIONS_READ');
    return getMemberReadmissionJournal(no);
  });
}
