'use server';

import { revalidatePath } from 'next/cache';
import { requireAction, requireUser } from '@/lib/session';
import { actionResult } from '@/lib/errors';
import {
  createStandingOrder, updateStandingOrder, submitStandingOrder, cancelStandingOrderApproval,
  approveStandingOrder, rejectStandingOrder, terminateStandingOrder, freezeStandingOrder, unfreezeStandingOrder,
  runStandingOrders, eligibleSourceAccountsForMember, eligibleDestinationAccountsForMember,
  eligibleDestinationLoansForMember, listDistinctStoTypes, type StandingOrderInput,
} from '@/lib/standingOrders';
import { findPendingRoutedTask, decideWorkflowTask } from '@/lib/workflow';
import { listTransactionChargesByType, previewTransactionChargeById } from '@/lib/charges';
import type {
  ActionResult, CalculatedCharge, FormValues, StandingOrderAmountType, StandingOrderClass,
  StandingOrderRunSummary, StandingOrderRunType, StandingOrderWithDimensions, TransactionCharge,
} from '@/lib/types';

const toInput = (values: FormValues): StandingOrderInput => ({
  memberId: Number(values.memberId),
  accountId: Number(values.accountId),
  standingOrderClass: values.standingOrderClass as StandingOrderClass,
  amountType: values.amountType as StandingOrderAmountType,
  amount: values.amount ? Math.round(Number(values.amount) * 100) : 0,
  amountLimit: values.amountLimit ? Math.round(Number(values.amountLimit) * 100) : 0,
  destinationMemberId: values.destinationMemberId ? Number(values.destinationMemberId) : null,
  destinationAccountId: values.destinationAccountId ? Number(values.destinationAccountId) : null,
  destinationLoanId: values.destinationLoanId ? Number(values.destinationLoanId) : null,
  postingDescription: String(values.postingDescription || ''),
  runType: (values.runType || 'DAILY') as StandingOrderRunType,
  runFromDay: values.runFromDay ? Number(values.runFromDay) : null,
  startDate: String(values.startDate || ''),
  tillFurtherNotice: !!Number(values.tillFurtherNotice || 0),
  periodMonths: values.periodMonths ? Number(values.periodMonths) : null,
  transactionChargeId: values.transactionChargeId ? Number(values.transactionChargeId) : null,
  salaryBased: !!Number(values.salaryBased || 0),
  stoType: values.stoType ? String(values.stoType) : null,
});

export async function requestStandingOrder(values: FormValues): Promise<ActionResult<{ no: string }>> {
  return actionResult(async () => {
    const user = await requireAction('STANDING_ORDERS_CREATE');
    const result = await createStandingOrder(toInput(values), user);
    revalidatePath('/standing-orders');
    return result;
  });
}

export async function saveStandingOrder(no: string, values: FormValues): Promise<ActionResult<StandingOrderWithDimensions>> {
  return actionResult(async () => {
    const user = await requireAction('STANDING_ORDERS_CREATE');
    const saved = await updateStandingOrder(no, toInput(values), user);
    revalidatePath('/standing-orders');
    revalidatePath(`/standing-orders/view/${no}`);
    return saved;
  });
}

export async function submitStandingOrderRequest(no: string): Promise<ActionResult<{ updated: true; autoApproved: boolean }>> {
  return actionResult(async () => {
    const user = await requireAction('STANDING_ORDERS_CREATE');
    const { autoApproved } = await submitStandingOrder(no, user);
    revalidatePath('/standing-orders');
    revalidatePath(`/standing-orders/view/${no}`);
    return { updated: true, autoApproved };
  });
}

export async function cancelStandingOrderApprovalRequest(no: string): Promise<ActionResult<{ updated: true }>> {
  return actionResult(async () => {
    const user = await requireAction('STANDING_ORDERS_CREATE');
    await cancelStandingOrderApproval(no, user);
    revalidatePath('/standing-orders');
    revalidatePath(`/standing-orders/view/${no}`);
    return { updated: true };
  });
}

export async function approveStandingOrderRequest(no: string): Promise<ActionResult<{ updated: true }>> {
  return actionResult(async () => {
    const routed = await findPendingRoutedTask('STANDING_ORDER', no);
    if (routed) {
      const user = await requireUser();
      await decideWorkflowTask(routed.id, true, null, user);
    } else {
      const user = await requireAction('STANDING_ORDERS_APPROVE');
      await approveStandingOrder(no, user);
    }
    revalidatePath('/standing-orders');
    revalidatePath(`/standing-orders/view/${no}`);
    return { updated: true };
  });
}

export async function rejectStandingOrderRequest(no: string, reason: string): Promise<ActionResult<{ updated: true }>> {
  return actionResult(async () => {
    const routed = await findPendingRoutedTask('STANDING_ORDER', no);
    if (routed) {
      const user = await requireUser();
      await decideWorkflowTask(routed.id, false, reason || null, user);
    } else {
      const user = await requireAction('STANDING_ORDERS_APPROVE');
      await rejectStandingOrder(no, reason, user);
    }
    revalidatePath('/standing-orders');
    revalidatePath(`/standing-orders/view/${no}`);
    return { updated: true };
  });
}

export async function terminateStandingOrderRequest(no: string): Promise<ActionResult<{ updated: true }>> {
  return actionResult(async () => {
    const user = await requireAction('STANDING_ORDERS_APPROVE');
    await terminateStandingOrder(no, user);
    revalidatePath('/standing-orders');
    revalidatePath(`/standing-orders/view/${no}`);
    return { updated: true };
  });
}

export async function freezeStandingOrderRequest(no: string, freezeEndDate: string): Promise<ActionResult<{ updated: true }>> {
  return actionResult(async () => {
    const user = await requireAction('STANDING_ORDERS_APPROVE');
    await freezeStandingOrder(no, freezeEndDate, user);
    revalidatePath('/standing-orders');
    revalidatePath(`/standing-orders/view/${no}`);
    return { updated: true };
  });
}

export async function unfreezeStandingOrderRequest(no: string): Promise<ActionResult<{ updated: true }>> {
  return actionResult(async () => {
    const user = await requireAction('STANDING_ORDERS_APPROVE');
    await unfreezeStandingOrder(no, user);
    revalidatePath('/standing-orders');
    revalidatePath(`/standing-orders/view/${no}`);
    return { updated: true };
  });
}

/** The manual "Run now" — same underlying runner the Job Queue's unattended poller calls. */
export async function runStandingOrdersNow(): Promise<ActionResult<StandingOrderRunSummary>> {
  return actionResult(async () => {
    const user = await requireAction('STANDING_ORDERS_RUN');
    const result = await runStandingOrders(user);
    revalidatePath('/standing-orders');
    revalidatePath('/savings');
    revalidatePath('/loans');
    return result;
  });
}

export async function accountsForStandingOrderSource(memberId: number) {
  return actionResult(async () => {
    await requireAction('STANDING_ORDERS_CREATE');
    return eligibleSourceAccountsForMember(memberId);
  });
}

export async function accountsForStandingOrderDestination(memberId: number) {
  return actionResult(async () => {
    await requireAction('STANDING_ORDERS_CREATE');
    return eligibleDestinationAccountsForMember(memberId);
  });
}

export async function loansForStandingOrderDestination(memberId: number) {
  return actionResult(async () => {
    await requireAction('STANDING_ORDERS_CREATE');
    return eligibleDestinationLoansForMember(memberId);
  });
}

/** Same 'General' Charge Code pool as Account/Member Activation's own picker. */
export async function standingOrderChargeCodes(): Promise<ActionResult<TransactionCharge[]>> {
  return actionResult(async () => {
    await requireAction('STANDING_ORDERS_CREATE');
    return listTransactionChargesByType('General');
  });
}

export async function previewStandingOrderChargeAmount(transactionChargeId: number): Promise<ActionResult<CalculatedCharge[]>> {
  return actionResult(async () => {
    await requireAction('STANDING_ORDERS_CREATE');
    return previewTransactionChargeById(transactionChargeId, 0);
  });
}

/** Autocomplete source for a salary-based order's own "Standing order type" tag — every
 *  distinct tag already in use, so an officer can match an existing one instead of retyping
 *  (and risking a typo that would silently exclude it from a Transaction Recovery's own match).
 *  Used from both the Standing Order form and the Transaction Charges admin form (configuring a
 *  STANDING_ORDER recovery's own tag), which don't share a single permission — just a signed-in
 *  user, since this exposes nothing beyond a handful of free-text tags. */
export async function listStandingOrderStoTypes(): Promise<ActionResult<string[]>> {
  return actionResult(async () => {
    await requireUser();
    return listDistinctStoTypes();
  });
}
