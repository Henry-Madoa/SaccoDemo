'use server';

import { revalidatePath } from 'next/cache';
import { requireAction, requireUser } from '@/lib/session';
import { actionResult } from '@/lib/errors';
import {
  createEmployeeEditRequest, updateEmployeeEditRequest, submitEmployeeEditRequest, cancelEmployeeEditApproval,
  approveEmployeeEdit, rejectEmployeeEdit, processEmployeeEdit, getEmployeeEditRequest,
  replaceEditNextOfKin, replaceEditBeneficiaries, replaceEditDependants, replaceEditEmergencyContacts,
  replaceEditProfessionalBodies, replaceEditWorkHistory, replaceEditBankAccounts,
} from '@/lib/employeeEdits';
import type { EmployeeInput } from '@/lib/employees';
import { findPendingRoutedTask, decideWorkflowTask } from '@/lib/workflow';
import type {
  ActionResult, FormValues, EmployeeEditNextOfKin, EmployeeEditBeneficiary, EmployeeEditDependant,
  EmployeeEditEmergencyContact, EmployeeEditProfessionalBody, EmployeeEditWorkHistory, EmployeeEditBankAccount,
} from '@/lib/types';

const revalidate = (no?: string) => {
  for (const p of ['/employee-edits', '/approvals', '/employees']) revalidatePath(p);
  if (no) revalidatePath(`/employee-edits/view/${no}`);
};

export async function createEmployeeEditRequestAction(employeeId: number): Promise<ActionResult<{ no: string }>> {
  return actionResult(async () => {
    const user = await requireAction('EMPLOYEE_EDITS_UPDATE');
    const res = await createEmployeeEditRequest(employeeId, user);
    revalidate();
    return res;
  });
}

/** A cleared picker posts '', which no integer column will take — the id fields have to come
 *  back as a number or a null. */
function toEditInput(values: FormValues): EmployeeInput {
  const body: EmployeeInput = { ...values } as EmployeeInput;
  for (const k of ['county_id', 'sub_county_id', 'job_grade_id', 'global_dimension_1_id', 'global_dimension_2_id'] as const) {
    if (values[k] !== undefined) (body as Record<string, unknown>)[k] = values[k] ? Number(values[k]) : null;
  }
  return body;
}

export async function updateEmployeeEditRequestAction(no: string, values: FormValues): Promise<ActionResult<{ updated: true }>> {
  return actionResult(async () => {
    const user = await requireAction('EMPLOYEE_EDITS_UPDATE');
    await updateEmployeeEditRequest(no, toEditInput(values), user);
    revalidate(no);
    return { updated: true };
  });
}

async function guardOpenEdit(no: string): Promise<void> {
  const req = await getEmployeeEditRequest(no);
  if (!req) throw new Error('Edit request not found');
  if (req.status !== 'Open') throw new Error('Only an open edit request can be edited');
}

export async function saveEditNextOfKin(no: string, rows: Omit<EmployeeEditNextOfKin, 'id' | 'edit_no'>[]): Promise<ActionResult<{ saved: true }>> {
  return actionResult(async () => {
    await requireAction('EMPLOYEE_EDITS_UPDATE');
    await guardOpenEdit(no);
    await replaceEditNextOfKin(no, rows);
    revalidate(no);
    return { saved: true };
  });
}
export async function saveEditBeneficiaries(no: string, rows: Omit<EmployeeEditBeneficiary, 'id' | 'edit_no'>[]): Promise<ActionResult<{ saved: true }>> {
  return actionResult(async () => {
    await requireAction('EMPLOYEE_EDITS_UPDATE');
    await guardOpenEdit(no);
    await replaceEditBeneficiaries(no, rows);
    revalidate(no);
    return { saved: true };
  });
}
export async function saveEditDependants(no: string, rows: Omit<EmployeeEditDependant, 'id' | 'edit_no'>[]): Promise<ActionResult<{ saved: true }>> {
  return actionResult(async () => {
    await requireAction('EMPLOYEE_EDITS_UPDATE');
    await guardOpenEdit(no);
    await replaceEditDependants(no, rows);
    revalidate(no);
    return { saved: true };
  });
}
export async function saveEditEmergencyContacts(no: string, rows: Omit<EmployeeEditEmergencyContact, 'id' | 'edit_no'>[]): Promise<ActionResult<{ saved: true }>> {
  return actionResult(async () => {
    await requireAction('EMPLOYEE_EDITS_UPDATE');
    await guardOpenEdit(no);
    await replaceEditEmergencyContacts(no, rows);
    revalidate(no);
    return { saved: true };
  });
}
export async function saveEditProfessionalBodies(no: string, rows: Omit<EmployeeEditProfessionalBody, 'id' | 'edit_no'>[]): Promise<ActionResult<{ saved: true }>> {
  return actionResult(async () => {
    await requireAction('EMPLOYEE_EDITS_UPDATE');
    await guardOpenEdit(no);
    await replaceEditProfessionalBodies(no, rows);
    revalidate(no);
    return { saved: true };
  });
}
export async function saveEditWorkHistory(no: string, rows: Omit<EmployeeEditWorkHistory, 'id' | 'edit_no'>[]): Promise<ActionResult<{ saved: true }>> {
  return actionResult(async () => {
    await requireAction('EMPLOYEE_EDITS_UPDATE');
    await guardOpenEdit(no);
    await replaceEditWorkHistory(no, rows);
    revalidate(no);
    return { saved: true };
  });
}
export async function saveEditBankAccounts(no: string, rows: Omit<EmployeeEditBankAccount, 'id' | 'edit_no'>[]): Promise<ActionResult<{ saved: true }>> {
  return actionResult(async () => {
    await requireAction('EMPLOYEE_EDITS_UPDATE');
    await guardOpenEdit(no);
    await replaceEditBankAccounts(no, rows);
    revalidate(no);
    return { saved: true };
  });
}

export async function submitEmployeeEditRequestAction(no: string): Promise<ActionResult<{ updated: true; autoApproved: boolean }>> {
  return actionResult(async () => {
    const user = await requireAction('EMPLOYEE_EDITS_UPDATE');
    const { autoApproved } = await submitEmployeeEditRequest(no, user);
    revalidate(no);
    return { updated: true, autoApproved };
  });
}

export async function cancelEmployeeEditApprovalAction(no: string): Promise<ActionResult<{ updated: true }>> {
  return actionResult(async () => {
    const user = await requireAction('EMPLOYEE_EDITS_UPDATE');
    await cancelEmployeeEditApproval(no, user);
    revalidate(no);
    return { updated: true };
  });
}

export async function approveEmployeeEditAction(no: string): Promise<ActionResult<{ updated: true }>> {
  return actionResult(async () => {
    const routed = await findPendingRoutedTask('EMPLOYEE_EDIT', no);
    if (routed) {
      const user = await requireUser();
      await decideWorkflowTask(routed.id, true, null, user);
    } else {
      const user = await requireAction('EMPLOYEE_EDITS_APPROVE');
      await approveEmployeeEdit(no, user);
    }
    revalidate(no);
    return { updated: true };
  });
}

export async function rejectEmployeeEditAction(no: string, reason: string): Promise<ActionResult<{ updated: true }>> {
  return actionResult(async () => {
    const routed = await findPendingRoutedTask('EMPLOYEE_EDIT', no);
    if (routed) {
      const user = await requireUser();
      await decideWorkflowTask(routed.id, false, reason || null, user);
    } else {
      const user = await requireAction('EMPLOYEE_EDITS_APPROVE');
      await rejectEmployeeEdit(no, reason || null, user);
    }
    revalidate(no);
    return { updated: true };
  });
}

export async function processEmployeeEditAction(no: string): Promise<ActionResult<{ employeeId: number }>> {
  return actionResult(async () => {
    const user = await requireAction('EMPLOYEE_EDITS_APPROVE');
    const res = await processEmployeeEdit(no, user);
    revalidate(no);
    revalidatePath(`/employees/view/${res.employeeId}`);
    return res;
  });
}
