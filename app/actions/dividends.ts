'use server';

import { revalidatePath } from 'next/cache';
import { requireAction, requireUser } from '@/lib/session';
import { actionResult } from '@/lib/errors';
import {
  createDividend, updateDividend, deleteDividend, setDividendParams, updateDividendLine,
  setDividendEarnedEntries, calculateDividend, submitDividend, cancelDividendApproval,
  approveDividend, rejectDividend, reopenDividend, postDividend,
  listDividendLines, listDividendDetEntries, listDividendRecoveries,
  type DividendInput, type DividendParamInput, type DividendCalculationResult, type DividendPostResult,
} from '@/lib/dividends';
import { findPendingRoutedTask, decideWorkflowTask } from '@/lib/workflow';
import type { ActionResult, FormValues } from '@/lib/types';

const revalidate = (no?: string) => {
  for (const p of ['/dividends', '/approvals']) revalidatePath(p);
  if (no) revalidatePath(`/dividends/view/${no}`);
};

const money = (v: unknown): number => (v === '' || v == null ? 0 : Math.round(Number(v) * 100));

const toInput = (values: FormValues): DividendInput => ({
  documentType: String(values.documentType || 'BOSA') as DividendInput['documentType'],
  description: String(values.description || ''),
  postingDescription: values.postingDescription ? String(values.postingDescription) : null,
  dividendYear: Number(values.dividendYear),
  startDate: String(values.startDate || ''),
  endDate: String(values.endDate || ''),
  postingDate: String(values.postingDate || ''),
  postingType: String(values.postingType || 'Provisioning') as DividendInput['postingType'],
  computationType: String(values.computationType || 'Automatic') as DividendInput['computationType'],
  transactionChargeId: values.transactionChargeId ? Number(values.transactionChargeId) : null,
  expenseAccountId: values.expenseAccountId ? Number(values.expenseAccountId) : null,
  payableAccountId: values.payableAccountId ? Number(values.payableAccountId) : null,
  recoverLoans: !!Number(values.recoverLoans),
  boostToMinimum: !!Number(values.boostToMinimum),
  maximumBoostAmount: money(values.maximumBoostAmount),
  preferentialBoost: !!Number(values.preferentialBoost),
  globalDimension1Id: values.globalDimension1Id ? Number(values.globalDimension1Id) : null,
  globalDimension2Id: values.globalDimension2Id ? Number(values.globalDimension2Id) : null,
});

export async function createDividendRequest(values: FormValues): Promise<ActionResult<{ no: string }>> {
  return actionResult(async () => {
    const user = await requireAction('DIVIDENDS_CREATE');
    const res = await createDividend(toInput(values), user);
    revalidate();
    return res;
  });
}

export async function saveDividend(no: string, values: FormValues): Promise<ActionResult<{ updated: true }>> {
  return actionResult(async () => {
    const user = await requireAction('DIVIDENDS_CREATE');
    await updateDividend(no, toInput(values), user);
    revalidate(no);
    return { updated: true };
  });
}

export async function deleteDividendRequest(no: string): Promise<ActionResult<{ deleted: true }>> {
  return actionResult(async () => {
    const user = await requireAction('DIVIDENDS_CREATE');
    await deleteDividend(no, user);
    revalidate();
    return { deleted: true };
  });
}

/** The whole parameter grid at once — one row per participating savings product. */
export async function saveDividendParams(
  no: string, params: DividendParamInput[],
): Promise<ActionResult<{ updated: true }>> {
  return actionResult(async () => {
    const user = await requireAction('DIVIDENDS_CREATE');
    await setDividendParams(no, params, user);
    revalidate(no);
    return { updated: true };
  });
}

export async function runDividendCalculation(no: string): Promise<ActionResult<DividendCalculationResult>> {
  return actionResult(async () => {
    const user = await requireAction('DIVIDENDS_CALCULATE');
    const res = await calculateDividend(no, user);
    revalidate(no);
    return res;
  });
}

export async function saveDividendLine(
  no: string, lineId: number, values: FormValues,
): Promise<ActionResult<{ updated: true }>> {
  return actionResult(async () => {
    const user = await requireAction('DIVIDENDS_CALCULATE');
    await updateDividendLine(no, lineId, {
      amountEarned: values.amountEarned === '' || values.amountEarned == null ? undefined : money(values.amountEarned),
      preferentialBoost: !!Number(values.preferentialBoost),
      preferentialBoostPct: Number(values.preferentialBoostPct || 0),
    }, user);
    revalidate(no);
    return { updated: true };
  });
}

export async function uploadDividendAmounts(
  no: string, rows: { savingsAccountId: number; amount: number; description?: string | null }[],
): Promise<ActionResult<{ count: number; total: number }>> {
  return actionResult(async () => {
    const user = await requireAction('DIVIDENDS_CALCULATE');
    const res = await setDividendEarnedEntries(
      no, rows.map((r) => ({ ...r, amount: Math.round(r.amount) })), user,
    );
    revalidate(no);
    return res;
  });
}

export async function submitDividendRequest(no: string): Promise<ActionResult<{ updated: true; autoApproved: boolean }>> {
  return actionResult(async () => {
    const user = await requireAction('DIVIDENDS_CREATE');
    const { autoApproved } = await submitDividend(no, user);
    revalidate(no);
    return { updated: true, autoApproved };
  });
}

export async function cancelDividendApprovalRequest(no: string): Promise<ActionResult<{ updated: true }>> {
  return actionResult(async () => {
    const user = await requireAction('DIVIDENDS_CREATE');
    await cancelDividendApproval(no, user);
    revalidate(no);
    return { updated: true };
  });
}

export async function approveDividendRequest(no: string): Promise<ActionResult<{ updated: true }>> {
  return actionResult(async () => {
    const routed = await findPendingRoutedTask('DIVIDEND', no);
    if (routed) {
      const user = await requireUser();
      await decideWorkflowTask(routed.id, true, null, user);
    } else {
      const user = await requireAction('DIVIDENDS_APPROVE');
      await approveDividend(no, user);
    }
    revalidate(no);
    return { updated: true };
  });
}

export async function rejectDividendRequest(no: string, reason: string): Promise<ActionResult<{ updated: true }>> {
  return actionResult(async () => {
    const routed = await findPendingRoutedTask('DIVIDEND', no);
    if (routed) {
      const user = await requireUser();
      await decideWorkflowTask(routed.id, false, reason || null, user);
    } else {
      const user = await requireAction('DIVIDENDS_APPROVE');
      await rejectDividend(no, reason || null, user);
    }
    revalidate(no);
    return { updated: true };
  });
}

export async function reopenDividendRequest(no: string): Promise<ActionResult<{ updated: true }>> {
  return actionResult(async () => {
    const user = await requireAction('DIVIDENDS_APPROVE');
    await reopenDividend(no, user);
    revalidate(no);
    return { updated: true };
  });
}

export async function postDividendRequest(no: string): Promise<ActionResult<DividendPostResult>> {
  return actionResult(async () => {
    const user = await requireAction('DIVIDENDS_POST');
    const res = await postDividend(no, user);
    revalidate(no);
    return res;
  });
}

/* ------------------------------------------------------------------ line inquiry */

export async function fetchDividendLines(dividendId: number, search: string, onlyEarning: boolean) {
  return actionResult(async () => {
    await requireAction('DIVIDENDS_READ');
    return listDividendLines(dividendId, { search, onlyEarning });
  });
}

/** The monthly working and the recoveries behind one line — the drill-down on the Lines tab. */
export async function fetchDividendLineDetail(lineId: number) {
  return actionResult(async () => {
    await requireAction('DIVIDENDS_READ');
    const [detail, recoveries] = await Promise.all([
      listDividendDetEntries(lineId), listDividendRecoveries(lineId),
    ]);
    return { detail, recoveries };
  });
}
