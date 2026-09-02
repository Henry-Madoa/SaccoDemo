'use server';

import { revalidatePath } from 'next/cache';
import { requireAction, requireUser } from '@/lib/session';
import { actionResult } from '@/lib/errors';
import {
  createTellerTransaction, updateTellerTransaction, deleteTellerTransaction, setTellerDenominations,
  submitTellerTransaction, cancelTellerTransactionApproval, approveTellerTransaction, rejectTellerTransaction,
  postTellerTransaction, emailSlip, eligibleAccountsForMember,
  type TellerTransactionInput,
} from '@/lib/tellerTransactions';
import { findPendingRoutedTask, decideWorkflowTask } from '@/lib/workflow';
import type { ActionResult, FormValues, SavingsAccountForDebit, TellerTransactionType } from '@/lib/types';

const revalidate = (no?: string) => {
  for (const p of ['/teller-transactions', '/approvals', '/accounting', '/savings']) revalidatePath(p);
  if (no) revalidatePath(`/teller-transactions/view/${no}`);
};

const toInput = (values: FormValues): TellerTransactionInput => ({
  transactionType: String(values.transactionType) as TellerTransactionType,
  memberId: Number(values.memberId),
  savingsAccountId: Number(values.savingsAccountId),
  amount: values.amount ? Math.round(Number(values.amount) * 100) : 0,
  sourceOfFunds: values.sourceOfFunds ? String(values.sourceOfFunds) : null,
  transactedByName: values.transactedByName ? String(values.transactedByName) : null,
  transactedByIdNo: values.transactedByIdNo ? String(values.transactedByIdNo) : null,
});

/** Create, and — when the amount is within the teller's Approval Limit — post immediately. */
export async function requestTellerTransaction(
  values: FormValues,
): Promise<ActionResult<{ no: string; posted: boolean; approvalRequired: boolean; journalNo?: string; emailed?: boolean }>> {
  return actionResult(async () => {
    const user = await requireAction('TELLER_TRANSACTIONS_CREATE');
    const { no, approvalRequired } = await createTellerTransaction(toInput(values), user);
    if (!approvalRequired) {
      const poster = await requireAction('TELLER_TRANSACTIONS_POST');
      const posted = await postTellerTransaction(no, poster);
      revalidate(no);
      return { no, posted: true, approvalRequired: false, journalNo: posted.journalNo, emailed: posted.emailed };
    }
    revalidate(no);
    return { no, posted: false, approvalRequired: true };
  });
}

export async function saveTellerTransaction(no: string, values: FormValues): Promise<ActionResult<{ updated: true }>> {
  return actionResult(async () => {
    const user = await requireAction('TELLER_TRANSACTIONS_CREATE');
    await updateTellerTransaction(no, toInput(values), user);
    revalidate(no);
    return { updated: true };
  });
}

export async function saveTellerDenominations(
  no: string, lines: { denominationId: number; quantity: number }[],
): Promise<ActionResult<{ updated: true }>> {
  return actionResult(async () => {
    const user = await requireAction('TELLER_TRANSACTIONS_CREATE');
    await setTellerDenominations(no, lines, user);
    revalidate(no);
    return { updated: true };
  });
}

export async function deleteTellerTransactionRequest(no: string): Promise<ActionResult<{ deleted: true }>> {
  return actionResult(async () => {
    const user = await requireAction('TELLER_TRANSACTIONS_CREATE');
    await deleteTellerTransaction(no, user);
    revalidate();
    return { deleted: true };
  });
}

export async function submitTellerTransactionRequest(no: string): Promise<ActionResult<{ updated: true; autoApproved: boolean }>> {
  return actionResult(async () => {
    const user = await requireAction('TELLER_TRANSACTIONS_CREATE');
    const { autoApproved } = await submitTellerTransaction(no, user);
    revalidate(no);
    return { updated: true, autoApproved };
  });
}

export async function cancelTellerTransactionApprovalRequest(no: string): Promise<ActionResult<{ updated: true }>> {
  return actionResult(async () => {
    const user = await requireAction('TELLER_TRANSACTIONS_CREATE');
    await cancelTellerTransactionApproval(no, user);
    revalidate(no);
    return { updated: true };
  });
}

export async function approveTellerTransactionRequest(no: string): Promise<ActionResult<{ updated: true }>> {
  return actionResult(async () => {
    const routed = await findPendingRoutedTask('TELLER_TRANSACTION', no);
    if (routed) {
      const user = await requireUser();
      await decideWorkflowTask(routed.id, true, null, user);
    } else {
      const user = await requireAction('TELLER_TRANSACTIONS_APPROVE');
      await approveTellerTransaction(no, user);
    }
    revalidate(no);
    return { updated: true };
  });
}

export async function rejectTellerTransactionRequest(no: string, reason: string): Promise<ActionResult<{ updated: true }>> {
  return actionResult(async () => {
    const routed = await findPendingRoutedTask('TELLER_TRANSACTION', no);
    if (routed) {
      const user = await requireUser();
      await decideWorkflowTask(routed.id, false, reason || null, user);
    } else {
      const user = await requireAction('TELLER_TRANSACTIONS_APPROVE');
      await rejectTellerTransaction(no, reason || null, user);
    }
    revalidate(no);
    return { updated: true };
  });
}

export async function postTellerTransactionRequest(no: string): Promise<ActionResult<{ journalNo: string; balance: number; emailed: boolean }>> {
  return actionResult(async () => {
    const user = await requireAction('TELLER_TRANSACTIONS_POST');
    const res = await postTellerTransaction(no, user);
    revalidate(no);
    return res;
  });
}

export async function resendTellerSlip(no: string): Promise<ActionResult<{ emailed: boolean }>> {
  return actionResult(async () => {
    await requireAction('TELLER_TRANSACTIONS_READ');
    const emailed = await emailSlip(no);
    revalidate(no);
    return { emailed };
  });
}

export async function accountsForTellerTransaction(
  memberId: number, transactionType?: TellerTransactionType,
): Promise<ActionResult<SavingsAccountForDebit[]>> {
  return actionResult(async () => {
    await requireAction('TELLER_TRANSACTIONS_CREATE');
    return eligibleAccountsForMember(memberId, transactionType);
  });
}
