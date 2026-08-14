'use server';

import { revalidatePath } from 'next/cache';
import { requirePerm, requireUser } from '@/lib/session';
import { actionResult } from '@/lib/errors';
import * as workflow from '@/lib/workflow';
import { decideWorkflowTask, delegateWorkflowTask } from '@/lib/workflow';
import type { ActionResult, FormValues, Workflow, WorkflowUserGroup, WorkflowDocumentType } from '@/lib/types';

export async function saveWorkflow(
  id: number | null,
  values: FormValues,
  conditions: workflow.ConditionDraft[],
  steps: workflow.StepDraft[],
): Promise<ActionResult<Workflow | { id: number }>> {
  return actionResult(async () => {
    const user = await requirePerm('ADMIN:WORKFLOW_MANAGE');
    const body: workflow.WorkflowInput = {
      name: String(values.name || '').trim(),
      document_type: values.document_type as WorkflowDocumentType,
      enabled: values.enabled === undefined ? null : (Number(values.enabled) ? 1 : 0),
    };
    const result = id
      ? await workflow.updateWorkflow(id, body, conditions, steps, user)
      : await workflow.createWorkflow(body, conditions, steps, user);
    revalidatePath('/admin/workflows');
    return result;
  });
}

export async function saveWorkflowUserGroup(
  id: number | null,
  values: FormValues,
  members: workflow.GroupMemberDraft[],
): Promise<ActionResult<WorkflowUserGroup | { id: number }>> {
  return actionResult(async () => {
    const user = await requirePerm('ADMIN:WORKFLOW_MANAGE');
    const body: workflow.WorkflowUserGroupInput = {
      name: String(values.name || '').trim(),
      status: values.status ? String(values.status) : null,
    };
    const result = id
      ? await workflow.updateWorkflowUserGroup(id, body, members, user)
      : await workflow.createWorkflowUserGroup(body, members, user);
    revalidatePath('/admin/workflows');
    return result;
  });
}

/** Replaces the enabled condition-field set for a document type's table relation — creating the
 *  relation (against its fixed, non-editable table) the first time that document type is configured. */
export async function saveWorkflowTableRelationFields(
  documentType: WorkflowDocumentType, fieldNames: string[],
): Promise<ActionResult<{ saved: true }>> {
  return actionResult(async () => {
    const user = await requirePerm('ADMIN:WORKFLOW_MANAGE');
    await workflow.saveWorkflowTableRelationFields(documentType, fieldNames, user);
    revalidatePath('/admin/workflows');
    return { saved: true };
  });
}

export async function saveApprovalUserSetupRow(
  userId: number,
  values: FormValues,
): Promise<ActionResult<{ updated: true }>> {
  return actionResult(async () => {
    const user = await requirePerm('ADMIN:WORKFLOW_MANAGE');
    await workflow.saveApprovalUserSetup(userId, {
      approver_id: Number(values.approver_id) || null,
      substitute_id: Number(values.substitute_id) || null,
      is_approval_administrator: Number(values.is_approval_administrator) ? 1 : 0,
    }, user);
    revalidatePath('/admin/workflows');
    return { updated: true };
  });
}

/** Act on a task assigned to me (or my group / the approver I substitute for). */
export async function decideMyTask(
  taskId: number, approve: boolean, comment: string,
): Promise<ActionResult<workflow.DecideResult>> {
  return actionResult(async () => {
    const user = await requireUser();
    const result = await decideWorkflowTask(taskId, approve, comment.trim() || null, user);
    revalidatePath('/approvals');
    revalidatePath('/member-applications');
    revalidatePath('/loans');
    revalidatePath('/accounting');
    return result;
  });
}

/** Hand a task I'm currently eligible to decide off to my own configured substitute. */
export async function delegateMyTask(taskId: number): Promise<ActionResult<{ delegated: true }>> {
  return actionResult(async () => {
    const user = await requireUser();
    await delegateWorkflowTask(taskId, user);
    revalidatePath('/approvals');
    revalidatePath('/member-applications');
    revalidatePath('/loans');
    revalidatePath('/accounting');
    return { delegated: true };
  });
}
