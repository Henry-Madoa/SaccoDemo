'use server';

import { revalidatePath } from 'next/cache';
import { requireAction, requireUser } from '@/lib/session';
import { actionResult } from '@/lib/errors';
import {
  createMemberApplication, updateMemberApplication, submitMemberApplication, cancelApplicationApproval,
  approveMemberApplication, rejectMemberApplication, createMemberFromApplication,
  type MemberApplicationInput,
} from '@/lib/memberApplications';
import { findPendingRoutedTask, decideWorkflowTask } from '@/lib/workflow';
import { toCents } from '@/lib/format';
import type { ActionResult, FormValues, MemberApplicationWithDimensions } from '@/lib/types';

/** Money arrives from the form as shillings; the database only ever holds integer minor units. */
function normalise(values: FormValues): MemberApplicationInput {
  const { gross_income_sh, other_deductions_sh, ...rest } = values;
  const body = rest as MemberApplicationInput;
  if (gross_income_sh !== undefined) body.gross_income = toCents(gross_income_sh);
  if (other_deductions_sh !== undefined) body.other_deductions = toCents(other_deductions_sh);
  if (body.county_id !== undefined) body.county_id = Number(body.county_id) || null;
  if (body.sub_county_id !== undefined) body.sub_county_id = Number(body.sub_county_id) || null;
  if (body.member_category_id !== undefined) body.member_category_id = Number(body.member_category_id) || null;
  if (body.global_dimension_1_id !== undefined) body.global_dimension_1_id = Number(body.global_dimension_1_id) || null;
  if (body.global_dimension_2_id !== undefined) body.global_dimension_2_id = Number(body.global_dimension_2_id) || null;
  if (body.kyc_verified !== undefined) body.kyc_verified = Number(body.kyc_verified) ? 1 : 0;
  if (body.member_count !== undefined) body.member_count = body.member_count === '' ? null : Number(body.member_count);
  return body;
}

export async function saveMemberApplication(
  no: string | null,
  values: FormValues,
): Promise<ActionResult<MemberApplicationWithDimensions | { no: string }>> {
  return actionResult(async () => {
    const user = await requireAction(no ? 'MEMBER_APPLICATIONS_UPDATE' : 'MEMBER_APPLICATIONS_CREATE');
    const body = normalise(values);
    const saved = no ? await updateMemberApplication(no, body, user) : await createMemberApplication(body, user);
    revalidatePath('/member-applications');
    return saved;
  });
}

export async function submitApplication(no: string): Promise<ActionResult<{ updated: true; autoApproved: boolean }>> {
  return actionResult(async () => {
    const user = await requireAction('MEMBER_APPLICATIONS_CREATE');
    const { autoApproved } = await submitMemberApplication(no, user);
    revalidatePath('/member-applications');
    revalidatePath(`/member-applications/view/${no}`);
    return { updated: true, autoApproved };
  });
}

export async function cancelApprovalRequest(no: string): Promise<ActionResult<{ updated: true }>> {
  return actionResult(async () => {
    const user = await requireAction('MEMBER_APPLICATIONS_CREATE');
    await cancelApplicationApproval(no, user);
    revalidatePath('/member-applications');
    revalidatePath(`/member-applications/view/${no}`);
    return { updated: true };
  });
}

/**
 * Delegates to whichever approval path actually governs this application: if a
 * workflow routed it to a specific approver, only that assignee may decide it
 * (via decideWorkflowTask); otherwise this falls back to the original
 * MEMBER:APPROVE-gated behavior untouched.
 */
export async function approveApplication(no: string): Promise<ActionResult<{ updated: true }>> {
  return actionResult(async () => {
    const routed = await findPendingRoutedTask('MEMBER_APPLICATION', no);
    if (routed) {
      const user = await requireUser();
      await decideWorkflowTask(routed.id, true, null, user);
    } else {
      const user = await requireAction('MEMBER_APPLICATIONS_APPROVE');
      await approveMemberApplication(no, user);
    }
    revalidatePath('/member-applications');
    revalidatePath(`/member-applications/view/${no}`);
    return { updated: true };
  });
}

export async function rejectApplication(no: string, reason: string): Promise<ActionResult<{ updated: true }>> {
  return actionResult(async () => {
    const routed = await findPendingRoutedTask('MEMBER_APPLICATION', no);
    if (routed) {
      const user = await requireUser();
      await decideWorkflowTask(routed.id, false, reason || null, user);
    } else {
      const user = await requireAction('MEMBER_APPLICATIONS_APPROVE');
      await rejectMemberApplication(no, reason, user);
    }
    revalidatePath('/member-applications');
    revalidatePath(`/member-applications/view/${no}`);
    return { updated: true };
  });
}

export async function processApplication(no: string): Promise<ActionResult<{ memberId: number }>> {
  return actionResult(async () => {
    const user = await requireAction('MEMBER_APPLICATIONS_APPROVE');
    const result = await createMemberFromApplication(no, user);
    revalidatePath('/member-applications');
    revalidatePath(`/member-applications/view/${no}`);
    revalidatePath('/members');
    return result;
  });
}
