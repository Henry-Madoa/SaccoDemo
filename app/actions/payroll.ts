'use server';

import { revalidatePath } from 'next/cache';
import { requireAction, requireUser } from '@/lib/session';
import { actionResult } from '@/lib/errors';
import {
  createPayrollPeriod, submitPayrollPeriod, cancelPayrollPeriodApproval, approvePayrollPeriod,
  rejectPayrollPeriod, closePayrollPeriod, runPayrollForEmployee, runPayrollForPeriod,
  addEmployeeTransaction, removeEmployeeTransaction, stopEmployeeTransaction, type EmployeeTransactionInput,
} from '@/lib/payroll';
import { findPendingRoutedTask, decideWorkflowTask } from '@/lib/workflow';
import type { ActionResult, FormValues } from '@/lib/types';

const revalidate = (periodId?: number) => {
  for (const p of ['/payroll', '/payroll/periods', '/approvals']) revalidatePath(p);
  if (periodId) revalidatePath(`/payroll/periods/view/${periodId}`);
};

export async function createPayrollPeriodRequest(values: FormValues): Promise<ActionResult<{ id: number }>> {
  return actionResult(async () => {
    const user = await requireAction('PAYROLL_PERIODS_CREATE');
    const res = await createPayrollPeriod({
      periodName: String(values.periodName || ''), startDate: String(values.startDate || ''), endDate: String(values.endDate || ''),
    }, user);
    revalidate();
    return res;
  });
}

export async function runPayrollForEmployeeRequest(periodId: number, employeeId: number): Promise<ActionResult<{ ran: true }>> {
  return actionResult(async () => {
    const user = await requireAction('PAYROLL_PERIODS_RUN');
    await runPayrollForEmployee(periodId, employeeId, user);
    revalidate(periodId);
    return { ran: true };
  });
}

export async function runPayrollForPeriodRequest(periodId: number): Promise<ActionResult<{ processed: number; failed: { employeeId: number; error: string }[] }>> {
  return actionResult(async () => {
    const user = await requireAction('PAYROLL_PERIODS_RUN');
    const res = await runPayrollForPeriod(periodId, user);
    revalidate(periodId);
    return res;
  });
}

export async function submitPayrollPeriodRequest(id: number): Promise<ActionResult<{ updated: true; autoApproved: boolean }>> {
  return actionResult(async () => {
    const user = await requireAction('PAYROLL_PERIODS_CREATE');
    const { autoApproved } = await submitPayrollPeriod(id, user);
    revalidate(id);
    return { updated: true, autoApproved };
  });
}

export async function cancelPayrollPeriodApprovalRequest(id: number): Promise<ActionResult<{ updated: true }>> {
  return actionResult(async () => {
    const user = await requireAction('PAYROLL_PERIODS_CREATE');
    await cancelPayrollPeriodApproval(id, user);
    revalidate(id);
    return { updated: true };
  });
}

export async function approvePayrollPeriodRequest(id: number): Promise<ActionResult<{ updated: true }>> {
  return actionResult(async () => {
    const routed = await findPendingRoutedTask('PAYROLL_PERIOD', String(id));
    if (routed) {
      const user = await requireUser();
      await decideWorkflowTask(routed.id, true, null, user);
    } else {
      const user = await requireAction('PAYROLL_PERIODS_APPROVE');
      await approvePayrollPeriod(id, user);
    }
    revalidate(id);
    return { updated: true };
  });
}

export async function rejectPayrollPeriodRequest(id: number, reason: string): Promise<ActionResult<{ updated: true }>> {
  return actionResult(async () => {
    const routed = await findPendingRoutedTask('PAYROLL_PERIOD', String(id));
    if (routed) {
      const user = await requireUser();
      await decideWorkflowTask(routed.id, false, reason || null, user);
    } else {
      const user = await requireAction('PAYROLL_PERIODS_APPROVE');
      await rejectPayrollPeriod(id, reason || null, user);
    }
    revalidate(id);
    return { updated: true };
  });
}

export async function closePayrollPeriodRequest(id: number, values: FormValues): Promise<ActionResult<{ nextPeriodId: number; journalNo: string }>> {
  return actionResult(async () => {
    const user = await requireAction('PAYROLL_PERIODS_CLOSE');
    const res = await closePayrollPeriod(id, {
      periodName: String(values.periodName || ''), startDate: String(values.startDate || ''), endDate: String(values.endDate || ''),
    }, user);
    revalidate(id);
    return res;
  });
}

export async function addEmployeeTransactionRequest(input: EmployeeTransactionInput): Promise<ActionResult<{ id: number }>> {
  return actionResult(async () => {
    const user = await requireAction('PAYROLL_MANAGE_TRANSACTIONS');
    const res = await addEmployeeTransaction(input, user);
    revalidatePath('/payroll');
    return res;
  });
}

export async function removeEmployeeTransactionRequest(id: number): Promise<ActionResult<{ deleted: true }>> {
  return actionResult(async () => {
    const user = await requireAction('PAYROLL_MANAGE_TRANSACTIONS');
    await removeEmployeeTransaction(id, user);
    revalidatePath('/payroll');
    return { deleted: true };
  });
}

export async function stopEmployeeTransactionRequest(id: number, stopped: boolean): Promise<ActionResult<{ updated: true }>> {
  return actionResult(async () => {
    const user = await requireAction('PAYROLL_MANAGE_TRANSACTIONS');
    await stopEmployeeTransaction(id, stopped, user);
    revalidatePath('/payroll');
    return { updated: true };
  });
}
