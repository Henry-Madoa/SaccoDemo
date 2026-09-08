'use server';

import { revalidatePath } from 'next/cache';
import { requireAction, requireUser } from '@/lib/session';
import { actionResult } from '@/lib/errors';
import {
  createLeaveApplication, deleteLeaveApplication, submitLeaveApplication, cancelLeaveApplicationApproval,
  approveLeaveApplication, rejectLeaveApplication, getLeaveBalance, type LeaveApplicationInput,
} from '@/lib/leaveManagement';
import { findPendingRoutedTask, decideWorkflowTask } from '@/lib/workflow';
import type { ActionResult, FormValues, LeaveApplicationNature } from '@/lib/types';

const revalidate = (no?: string) => {
  for (const p of ['/leave-applications', '/approvals']) revalidatePath(p);
  if (no) revalidatePath(`/leave-applications/view/${no}`);
};

function toInput(values: FormValues): LeaveApplicationInput {
  return {
    employeeId: Number(values.employeeId), leaveTypeId: Number(values.leaveTypeId),
    nature: String(values.nature || 'APPLICATION') as LeaveApplicationNature,
    startDate: String(values.startDate || ''), endDate: String(values.endDate || ''),
    relieverId: values.relieverId ? Number(values.relieverId) : null,
    leaveAllowancePayable: !!Number(values.leaveAllowancePayable),
    daysDropped: values.daysDropped ? Number(values.daysDropped) : null,
    daysToReimburse: values.daysToReimburse ? Number(values.daysToReimburse) : null,
    justification: values.justification ? String(values.justification) : null,
  };
}

export async function requestLeaveApplication(values: FormValues): Promise<ActionResult<{ no: string }>> {
  return actionResult(async () => {
    const user = await requireAction('LEAVE_APPLICATIONS_CREATE');
    const res = await createLeaveApplication(toInput(values), user);
    revalidate();
    return res;
  });
}

export async function deleteLeaveApplicationRequest(no: string): Promise<ActionResult<{ deleted: true }>> {
  return actionResult(async () => {
    const user = await requireAction('LEAVE_APPLICATIONS_CREATE');
    await deleteLeaveApplication(no, user);
    revalidate();
    return { deleted: true };
  });
}

export async function submitLeaveApplicationRequest(no: string): Promise<ActionResult<{ updated: true; autoApproved: boolean }>> {
  return actionResult(async () => {
    const user = await requireAction('LEAVE_APPLICATIONS_CREATE');
    const { autoApproved } = await submitLeaveApplication(no, user);
    revalidate(no);
    return { updated: true, autoApproved };
  });
}

export async function cancelLeaveApplicationApprovalRequest(no: string): Promise<ActionResult<{ updated: true }>> {
  return actionResult(async () => {
    const user = await requireAction('LEAVE_APPLICATIONS_CREATE');
    await cancelLeaveApplicationApproval(no, user);
    revalidate(no);
    return { updated: true };
  });
}

export async function approveLeaveApplicationRequest(no: string): Promise<ActionResult<{ updated: true }>> {
  return actionResult(async () => {
    const routed = await findPendingRoutedTask('LEAVE_APPLICATION', no);
    if (routed) {
      const user = await requireUser();
      await decideWorkflowTask(routed.id, true, null, user);
    } else {
      const user = await requireAction('LEAVE_APPLICATIONS_APPROVE');
      await approveLeaveApplication(no, user);
    }
    revalidate(no);
    return { updated: true };
  });
}

export async function rejectLeaveApplicationRequest(no: string, reason: string): Promise<ActionResult<{ updated: true }>> {
  return actionResult(async () => {
    const routed = await findPendingRoutedTask('LEAVE_APPLICATION', no);
    if (routed) {
      const user = await requireUser();
      await decideWorkflowTask(routed.id, false, reason || null, user);
    } else {
      const user = await requireAction('LEAVE_APPLICATIONS_APPROVE');
      await rejectLeaveApplication(no, reason || null, user);
    }
    revalidate(no);
    return { updated: true };
  });
}

export async function balanceForEmployeeType(employeeId: number, leaveTypeId: number, calendarId: number) {
  return actionResult(async () => {
    await requireAction('LEAVE_APPLICATIONS_READ');
    const balance = await getLeaveBalance(employeeId, leaveTypeId, calendarId);
    return { balance };
  });
}
