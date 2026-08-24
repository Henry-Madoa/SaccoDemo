'use server';

import { revalidatePath } from 'next/cache';
import { requireAction, requireUser } from '@/lib/session';
import { actionResult } from '@/lib/errors';
import {
  createMemberEditRequest, updateMemberEditRequest, changeMemberEditRequestMember,
  getMemberEditRequestMemberId, submitMemberEditRequest, cancelEditApproval,
  approveMemberEdit, rejectMemberEdit, processMemberEdit, type MemberEditInput,
} from '@/lib/memberEdits';
import { findPendingRoutedTask, decideWorkflowTask } from '@/lib/workflow';
import { toCents } from '@/lib/format';
import type { ActionResult, FormValues, MemberEditRequestWithDimensions } from '@/lib/types';

/** Money arrives from the form as shillings; the database only ever holds integer minor units. */
function normalise(values: FormValues): MemberEditInput {
  const { gross_income_sh, other_deductions_sh, ...rest } = values;
  const body = rest as MemberEditInput;
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

/** Starts a new edit request for an existing member, snapshotting its current values. */
export async function requestMemberEdit(memberId: number): Promise<ActionResult<{ no: string }>> {
  return actionResult(async () => {
    const user = await requireAction('MEMBER_EDITS_UPDATE');
    const result = await createMemberEditRequest(memberId, user);
    revalidatePath('/member-edits');
    revalidatePath(`/members/${memberId}`);
    return result;
  });
}

export async function saveMemberEditRequest(
  no: string, values: FormValues,
): Promise<ActionResult<MemberEditRequestWithDimensions>> {
  return actionResult(async () => {
    const user = await requireAction('MEMBER_EDITS_UPDATE');

    // GeneralInfoCard's Member picker submits member_id alongside its own other fields
    // (category, join date, dimensions). A changed member re-targets — and re-snapshots — the
    // whole request instead of patching individual fields; whatever else was picked in that
    // same submission is discarded along with it, same as the card's own warning says.
    if (values.member_id !== undefined) {
      const currentMemberId = await getMemberEditRequestMemberId(no);
      const newMemberId = Number(values.member_id);
      if (currentMemberId !== undefined && newMemberId !== currentMemberId) {
        const saved = await changeMemberEditRequestMember(no, newMemberId, user);
        revalidatePath('/member-edits');
        return saved;
      }
    }

    const body = normalise(values);
    const saved = await updateMemberEditRequest(no, body, user);
    revalidatePath('/member-edits');
    return saved;
  });
}

export async function submitMemberEdit(no: string): Promise<ActionResult<{ updated: true; autoApproved: boolean }>> {
  return actionResult(async () => {
    const user = await requireAction('MEMBER_EDITS_UPDATE');
    const { autoApproved } = await submitMemberEditRequest(no, user);
    revalidatePath('/member-edits');
    revalidatePath(`/member-edits/view/${no}`);
    return { updated: true, autoApproved };
  });
}

export async function cancelMemberEditApproval(no: string): Promise<ActionResult<{ updated: true }>> {
  return actionResult(async () => {
    const user = await requireAction('MEMBER_EDITS_UPDATE');
    await cancelEditApproval(no, user);
    revalidatePath('/member-edits');
    revalidatePath(`/member-edits/view/${no}`);
    return { updated: true };
  });
}

/**
 * Delegates to whichever approval path actually governs this request: if a workflow
 * routed it to a specific approver, only that assignee may decide it (via
 * decideWorkflowTask); otherwise this falls back to the flat MEMBER:APPROVE permission.
 */
export async function approveMemberEditRequest(no: string): Promise<ActionResult<{ updated: true }>> {
  return actionResult(async () => {
    const routed = await findPendingRoutedTask('MEMBER_EDIT', no);
    if (routed) {
      const user = await requireUser();
      await decideWorkflowTask(routed.id, true, null, user);
    } else {
      const user = await requireAction('MEMBER_EDITS_APPROVE');
      await approveMemberEdit(no, user);
    }
    revalidatePath('/member-edits');
    revalidatePath(`/member-edits/view/${no}`);
    return { updated: true };
  });
}

export async function rejectMemberEditRequest(no: string, reason: string): Promise<ActionResult<{ updated: true }>> {
  return actionResult(async () => {
    const routed = await findPendingRoutedTask('MEMBER_EDIT', no);
    if (routed) {
      const user = await requireUser();
      await decideWorkflowTask(routed.id, false, reason || null, user);
    } else {
      const user = await requireAction('MEMBER_EDITS_APPROVE');
      await rejectMemberEdit(no, reason, user);
    }
    revalidatePath('/member-edits');
    revalidatePath(`/member-edits/view/${no}`);
    return { updated: true };
  });
}

export async function processMemberEditRequest(no: string): Promise<ActionResult<{ memberId: number }>> {
  return actionResult(async () => {
    const user = await requireAction('MEMBER_EDITS_APPROVE');
    const result = await processMemberEdit(no, user);
    revalidatePath('/member-edits');
    revalidatePath(`/member-edits/view/${no}`);
    revalidatePath(`/members/${result.memberId}`);
    revalidatePath('/members');
    return result;
  });
}
