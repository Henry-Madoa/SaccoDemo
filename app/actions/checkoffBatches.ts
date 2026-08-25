'use server';

import { revalidatePath } from 'next/cache';
import { requireAction, requireUser } from '@/lib/session';
import { actionResult } from '@/lib/errors';
import {
  createCheckoffBatch, refreshCheckoffBatchLines, recordRemittedAmount, submitCheckoffBatch,
  cancelCheckoffBatchApproval, approveCheckoffBatch, rejectCheckoffBatch, processCheckoffBatch,
} from '@/lib/checkoffBatches';
import { findPendingRoutedTask, decideWorkflowTask } from '@/lib/workflow';
import type { ActionResult } from '@/lib/types';

export async function requestCheckoffBatch(
  employerId: number, batchType: string, period: string,
): Promise<ActionResult<{ no: string }>> {
  return actionResult(async () => {
    const user = await requireAction('CHECKOFF_BATCHES_CREATE');
    const result = await createCheckoffBatch(employerId, batchType as 'CHECKOFF' | 'SALARY', period, user);
    revalidatePath('/checkoff-batches');
    return result;
  });
}

export async function refreshCheckoffBatchLinesRequest(no: string): Promise<ActionResult<{ updated: true }>> {
  return actionResult(async () => {
    const user = await requireAction('CHECKOFF_BATCHES_CREATE');
    await refreshCheckoffBatchLines(no, user);
    revalidatePath(`/checkoff-batches/view/${no}`);
    return { updated: true };
  });
}

export async function recordRemittedAmountRequest(
  no: string, lineId: number, amountSh: string | number,
): Promise<ActionResult<{ updated: true }>> {
  return actionResult(async () => {
    const user = await requireAction('CHECKOFF_BATCHES_CREATE');
    const amount = Math.round(Number(String(amountSh).replace(/,/g, '')) * 100) || 0;
    await recordRemittedAmount(no, lineId, amount, user);
    revalidatePath(`/checkoff-batches/view/${no}`);
    return { updated: true };
  });
}

export async function submitCheckoffBatchRequest(no: string): Promise<ActionResult<{ updated: true; autoApproved: boolean }>> {
  return actionResult(async () => {
    const user = await requireAction('CHECKOFF_BATCHES_CREATE');
    const { autoApproved } = await submitCheckoffBatch(no, user);
    revalidatePath('/checkoff-batches');
    revalidatePath(`/checkoff-batches/view/${no}`);
    return { updated: true, autoApproved };
  });
}

export async function cancelCheckoffBatchApprovalRequest(no: string): Promise<ActionResult<{ updated: true }>> {
  return actionResult(async () => {
    const user = await requireAction('CHECKOFF_BATCHES_CREATE');
    await cancelCheckoffBatchApproval(no, user);
    revalidatePath('/checkoff-batches');
    revalidatePath(`/checkoff-batches/view/${no}`);
    return { updated: true };
  });
}

export async function approveCheckoffBatchRequest(no: string): Promise<ActionResult<{ updated: true }>> {
  return actionResult(async () => {
    const routed = await findPendingRoutedTask('CHECKOFF_BATCH', no);
    if (routed) {
      const user = await requireUser();
      await decideWorkflowTask(routed.id, true, null, user);
    } else {
      const user = await requireAction('CHECKOFF_BATCHES_APPROVE');
      await approveCheckoffBatch(no, user);
    }
    revalidatePath('/checkoff-batches');
    revalidatePath(`/checkoff-batches/view/${no}`);
    return { updated: true };
  });
}

export async function rejectCheckoffBatchRequest(no: string, reason: string): Promise<ActionResult<{ updated: true }>> {
  return actionResult(async () => {
    const routed = await findPendingRoutedTask('CHECKOFF_BATCH', no);
    if (routed) {
      const user = await requireUser();
      await decideWorkflowTask(routed.id, false, reason || null, user);
    } else {
      const user = await requireAction('CHECKOFF_BATCHES_APPROVE');
      await rejectCheckoffBatch(no, reason, user);
    }
    revalidatePath('/checkoff-batches');
    revalidatePath(`/checkoff-batches/view/${no}`);
    return { updated: true };
  });
}

export async function processCheckoffBatchRequest(no: string): Promise<ActionResult<{ employerId: number }>> {
  return actionResult(async () => {
    const user = await requireAction('CHECKOFF_BATCHES_APPROVE');
    const result = await processCheckoffBatch(no, user);
    revalidatePath('/checkoff-batches');
    revalidatePath(`/checkoff-batches/view/${no}`);
    return result;
  });
}
