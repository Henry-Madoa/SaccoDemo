'use server';

import { revalidatePath } from 'next/cache';
import { requireAction, requireUser } from '@/lib/session';
import { actionResult } from '@/lib/errors';
import {
  createCheckoffBatch, updateCheckoffBatch, refreshCheckoffBatchLines, recordRemittedAmount, submitCheckoffBatch,
  cancelCheckoffBatchApproval, approveCheckoffBatch, rejectCheckoffBatch, processCheckoffBatch,
  applyCheckoffCsvUpload, validateCheckoffBatch, calculateCheckoffRecoveries,
} from '@/lib/checkoffBatches';
import type { CheckoffCsvUploadResult, CheckoffValidationResult } from '@/lib/checkoffBatches';
import { findPendingRoutedTask, decideWorkflowTask } from '@/lib/workflow';
import { CHECKOFF_SEARCH_TYPES } from '@/lib/constants';
import type { ActionResult, CheckoffSearchType, FormValues } from '@/lib/types';

const toSearchType = (value: unknown): CheckoffSearchType =>
  CHECKOFF_SEARCH_TYPES.some((t) => t.value === value) ? (value as CheckoffSearchType) : 'PAYROLL_NO';

export async function requestCheckoffBatch(
  employerId: number, batchType: string, period: string, transactionChargeId?: number | null,
  searchType?: string,
): Promise<ActionResult<{ no: string }>> {
  return actionResult(async () => {
    const user = await requireAction('CHECKOFF_BATCHES_CREATE');
    const result = await createCheckoffBatch(
      employerId, batchType as 'CHECKOFF' | 'SALARY', period, user, transactionChargeId, toSearchType(searchType),
    );
    revalidatePath('/checkoff-batches');
    return result;
  });
}

export async function updateCheckoffBatchRequest(no: string, values: FormValues): Promise<ActionResult<{ updated: true }>> {
  return actionResult(async () => {
    const user = await requireAction('CHECKOFF_BATCHES_CREATE');
    const period = String(values.period || '');
    await updateCheckoffBatch(no, {
      employerId: Number(values.employerId),
      period: period ? `${period}-01` : '',
      postingDate: String(values.postingDate || '') || null,
      description: String(values.description || '') || null,
      searchType: toSearchType(values.searchType),
      transactionChargeId: values.transactionChargeId ? Number(values.transactionChargeId) : null,
    }, user);
    revalidatePath('/checkoff-batches');
    revalidatePath(`/checkoff-batches/view/${no}`);
    return { updated: true };
  });
}

export interface CheckoffCsvUploadState {
  result?: CheckoffCsvUploadResult;
  error?: string;
}

/** Plain FormData action (not a FormModal — its readForm() drops File objects), same pattern as
 *  app/actions/configPackages.ts's importConfigPackageAction(). */
export async function applyCheckoffCsvUploadAction(
  _prevState: CheckoffCsvUploadState, formData: FormData,
): Promise<CheckoffCsvUploadState> {
  try {
    const user = await requireAction('CHECKOFF_BATCHES_CREATE');
    const no = String(formData.get('no') || '');
    const file = formData.get('file');
    if (!(file instanceof File) || !file.size) return { error: 'Choose a CSV file to upload' };
    const text = await file.text();
    const result = await applyCheckoffCsvUpload(no, text, user);
    revalidatePath(`/checkoff-batches/view/${no}`);
    return { result };
  } catch (err) {
    return { error: err instanceof Error ? err.message : 'Upload failed' };
  }
}

export async function validateCheckoffBatchRequest(no: string): Promise<ActionResult<CheckoffValidationResult>> {
  return actionResult(async () => {
    const user = await requireAction('CHECKOFF_BATCHES_CREATE');
    return validateCheckoffBatch(no, user);
  });
}

export async function calculateCheckoffRecoveriesRequest(no: string): Promise<ActionResult<{ linesCalculated: number }>> {
  return actionResult(async () => {
    const user = await requireAction('CHECKOFF_BATCHES_CREATE');
    const result = await calculateCheckoffRecoveries(no, user);
    revalidatePath(`/checkoff-batches/view/${no}`);
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
