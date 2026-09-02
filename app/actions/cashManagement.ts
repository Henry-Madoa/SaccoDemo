'use server';

import { revalidatePath } from 'next/cache';
import { requireAction, requireUser } from '@/lib/session';
import { actionResult } from '@/lib/errors';
import {
  createFosaTransaction, updateFosaTransaction, deleteFosaTransaction, setFosaDenominations,
  submitFosaTransaction, cancelFosaApproval, approveFosaTransaction, rejectFosaTransaction,
  processFosaTransaction, listBankAccountsByType, listOtherTills, myFosaAutoAccount,
  type FosaTransactionInput, type FosaAccountBrief,
} from '@/lib/cashManagement';
import { tellerSetupForUser } from '@/lib/tellerSetup';
import { findPendingRoutedTask, decideWorkflowTask } from '@/lib/workflow';
import type { ActionResult, BankAccountType, FormValues, FosaDocumentType } from '@/lib/types';

const REVALIDATE = ['/cash-management', '/approvals', '/accounting'];
const revalidate = (no?: string) => {
  for (const p of REVALIDATE) revalidatePath(p);
  if (no) revalidatePath(`/cash-management/view/${no}`);
};

const toInput = (values: FormValues): FosaTransactionInput => ({
  documentType: String(values.documentType) as FosaDocumentType,
  counterpartyBankAccountId: Number(values.counterpartyBankAccountId),
  amount: values.amount ? Math.round(Number(values.amount) * 100) : 0,
});

export async function requestFosaTransaction(values: FormValues): Promise<ActionResult<{ no: string }>> {
  return actionResult(async () => {
    const user = await requireAction('CASH_MANAGEMENT_CREATE');
    const res = await createFosaTransaction(toInput(values), user);
    revalidate();
    return res;
  });
}

export async function saveFosaTransaction(no: string, values: FormValues): Promise<ActionResult<{ updated: true }>> {
  return actionResult(async () => {
    const user = await requireAction('CASH_MANAGEMENT_CREATE');
    await updateFosaTransaction(no, toInput(values), user);
    revalidate(no);
    return { updated: true };
  });
}

export async function saveFosaDenominations(
  no: string, lines: { denominationId: number; quantity: number }[],
): Promise<ActionResult<{ updated: true }>> {
  return actionResult(async () => {
    const user = await requireAction('CASH_MANAGEMENT_CREATE');
    await setFosaDenominations(no, lines, user);
    revalidate(no);
    return { updated: true };
  });
}

export async function deleteFosaTransactionRequest(no: string): Promise<ActionResult<{ deleted: true }>> {
  return actionResult(async () => {
    const user = await requireAction('CASH_MANAGEMENT_CREATE');
    await deleteFosaTransaction(no, user);
    revalidate();
    return { deleted: true };
  });
}

export async function submitFosaTransactionRequest(no: string): Promise<ActionResult<{ updated: true; autoApproved: boolean }>> {
  return actionResult(async () => {
    const user = await requireAction('CASH_MANAGEMENT_CREATE');
    const { autoApproved } = await submitFosaTransaction(no, user);
    revalidate(no);
    return { updated: true, autoApproved };
  });
}

export async function cancelFosaApprovalRequest(no: string): Promise<ActionResult<{ updated: true }>> {
  return actionResult(async () => {
    const user = await requireAction('CASH_MANAGEMENT_CREATE');
    await cancelFosaApproval(no, user);
    revalidate(no);
    return { updated: true };
  });
}

export async function approveFosaTransactionRequest(no: string): Promise<ActionResult<{ updated: true }>> {
  return actionResult(async () => {
    const routed = await findPendingRoutedTask('FOSA_TRANSACTION', no);
    if (routed) {
      const user = await requireUser();
      await decideWorkflowTask(routed.id, true, null, user);
    } else {
      const user = await requireAction('CASH_MANAGEMENT_APPROVE');
      await approveFosaTransaction(no, user);
    }
    revalidate(no);
    return { updated: true };
  });
}

export async function rejectFosaTransactionRequest(no: string, reason: string): Promise<ActionResult<{ updated: true }>> {
  return actionResult(async () => {
    const routed = await findPendingRoutedTask('FOSA_TRANSACTION', no);
    if (routed) {
      const user = await requireUser();
      await decideWorkflowTask(routed.id, false, reason || null, user);
    } else {
      const user = await requireAction('CASH_MANAGEMENT_APPROVE');
      await rejectFosaTransaction(no, reason || null, user);
    }
    revalidate(no);
    return { updated: true };
  });
}

export async function postFosaTransactionRequest(no: string): Promise<ActionResult<{ journalNo: string; amount: number }>> {
  return actionResult(async () => {
    const user = await requireAction('CASH_MANAGEMENT_POST');
    const res = await processFosaTransaction(no, user);
    revalidate(no);
    revalidatePath('/savings');
    return res;
  });
}

/** The end of the movement auto-resolved from the user's own Teller Setup (with capacity
 *  limits) — the New form uses it to pre-fill / cap the Amount against the real ceiling. */
export async function myFosaAutoAccountFor(
  documentType: FosaDocumentType,
): Promise<ActionResult<(FosaAccountBrief & { role: 'SOURCE' | 'DESTINATION' }) | null>> {
  return actionResult(async () => {
    const user = await requireAction('CASH_MANAGEMENT_CREATE');
    return myFosaAutoAccount(documentType, user);
  });
}

/** The counterparty account picklist for a given document type — the side the creator picks. */
export async function counterpartyAccountsFor(
  documentType: FosaDocumentType, counterpartyType: BankAccountType,
): Promise<ActionResult<FosaAccountBrief[]>> {
  return actionResult(async () => {
    const user = await requireAction('CASH_MANAGEMENT_CREATE');
    if (documentType === 'INTER_TILL') {
      const mine = await tellerSetupForUser(user.username);
      return listOtherTills(mine?.bank_account_id ?? 0);
    }
    return listBankAccountsByType(counterpartyType);
  });
}
