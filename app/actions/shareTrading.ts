'use server';

import { revalidatePath } from 'next/cache';
import { requireAction, requireUser } from '@/lib/session';
import { actionResult } from '@/lib/errors';
import {
  createShareTradingWindow, updateShareTradingWindow, deleteShareTradingWindow, publishShareTradingWindow,
  retireShareTradingWindow, createShareFloating, updateShareFloating, deleteShareFloating, submitShareFloating,
  cancelShareFloatingApproval, approveShareFloating, rejectShareFloating, reopenShareFloating,
  publishShareFloating, placeShareBid, withdrawShareBid, analyseShareBids, notifyShareAward, postSharePurchase,
  addShareTransferReceipt, removeShareTransferReceipt, transferShares, takeDownShareFloating,
  applyShareNoBidRule, processExpiredShareFloatings, shareMemberPosition, shareProceedsAccountsForMember,
  sharePaymentAccountsForMember, type ShareWindowInput, type ShareFloatingInput, type ShareMemberPosition,
  type ShareProceedsAccount, type SharePaymentAccount,
} from '@/lib/shareTrading';
import { findPendingRoutedTask, decideWorkflowTask } from '@/lib/workflow';
import type {
  ActionResult, Cents, FormValues, IsoDate, ShareBidView, ShareFloatType, ShareOnNoBid, ShareProceedsType,
  ShareTradeSource,
} from '@/lib/types';

const revalidate = (no?: string) => {
  for (const p of ['/share-trading', '/approvals', '/savings']) revalidatePath(p);
  if (no) revalidatePath(`/share-trading/view/${no}`);
};

const money = (v: unknown): Cents => (v === '' || v == null ? 0 : Math.round(Number(v) * 100));

/* ------------------------------------------------------------------ windows */

const toWindowInput = (v: FormValues): ShareWindowInput => ({
  description: String(v.description || ''),
  startDate: String(v.startDate || ''),
  endDate: String(v.endDate || ''),
  basePrice: money(v.basePrice),
  reservePrice: money(v.reservePrice),
  transactionChargeId: v.transactionChargeId ? Number(v.transactionChargeId) : null,
  clearingAccountId: Number(v.clearingAccountId),
  holdingAccountId: Number(v.holdingAccountId),
  shareLife: v.shareLife ? String(v.shareLife) : null,
  tolerancePeriod: v.tolerancePeriod ? String(v.tolerancePeriod) : null,
  onNoBid: String(v.onNoBid || 'Extend') as ShareOnNoBid,
  minimumSharesToFloat: Number(v.minimumSharesToFloat || 0),
});

export async function createShareWindowRequest(values: FormValues): Promise<ActionResult<{ no: string }>> {
  return actionResult(async () => {
    const user = await requireAction('SHARE_TRADING_WINDOW_MANAGE');
    const res = await createShareTradingWindow(toWindowInput(values), user);
    revalidate();
    return res;
  });
}

export async function saveShareWindow(no: string, values: FormValues): Promise<ActionResult<{ updated: true }>> {
  return actionResult(async () => {
    const user = await requireAction('SHARE_TRADING_WINDOW_MANAGE');
    await updateShareTradingWindow(no, toWindowInput(values), user);
    revalidate();
    return { updated: true };
  });
}

export async function deleteShareWindowRequest(no: string): Promise<ActionResult<{ deleted: true }>> {
  return actionResult(async () => {
    const user = await requireAction('SHARE_TRADING_WINDOW_MANAGE');
    await deleteShareTradingWindow(no, user);
    revalidate();
    return { deleted: true };
  });
}

export async function publishShareWindowRequest(no: string): Promise<ActionResult<{ updated: true }>> {
  return actionResult(async () => {
    const user = await requireAction('SHARE_TRADING_WINDOW_MANAGE');
    await publishShareTradingWindow(no, user);
    revalidate();
    return { updated: true };
  });
}

export async function retireShareWindowRequest(no: string): Promise<ActionResult<{ updated: true }>> {
  return actionResult(async () => {
    const user = await requireAction('SHARE_TRADING_WINDOW_MANAGE');
    await retireShareTradingWindow(no, user);
    revalidate();
    return { updated: true };
  });
}

/* ---------------------------------------------------------------- floatings */

const toFloatingInput = (v: FormValues): ShareFloatingInput => ({
  windowNo: v.windowNo ? String(v.windowNo) : null,
  memberId: Number(v.memberId),
  floatType: String(v.floatType || 'Partial') as ShareFloatType,
  sharesToFloat: Number(v.sharesToFloat || 0),
  minimumAcceptablePrice: money(v.minimumAcceptablePrice),
  proceedsType: String(v.proceedsType || 'FOSA Account') as ShareProceedsType,
  proceedsAccountId: v.proceedsAccountId ? Number(v.proceedsAccountId) : null,
  paymentMethodCode: v.paymentMethodCode ? String(v.paymentMethodCode) : null,
  externalReferenceNo: v.externalReferenceNo ? String(v.externalReferenceNo) : null,
  narration: v.narration ? String(v.narration) : null,
  source: String(v.source || 'Walking') as ShareTradeSource,
});

export async function requestShareFloating(values: FormValues): Promise<ActionResult<{ no: string }>> {
  return actionResult(async () => {
    const user = await requireAction('SHARE_TRADING_CREATE');
    const res = await createShareFloating(toFloatingInput(values), user);
    revalidate();
    return res;
  });
}

export async function saveShareFloating(no: string, values: FormValues): Promise<ActionResult<{ updated: true }>> {
  return actionResult(async () => {
    const user = await requireAction('SHARE_TRADING_CREATE');
    await updateShareFloating(no, toFloatingInput(values), user);
    revalidate(no);
    return { updated: true };
  });
}

export async function deleteShareFloatingRequest(no: string): Promise<ActionResult<{ deleted: true }>> {
  return actionResult(async () => {
    const user = await requireAction('SHARE_TRADING_CREATE');
    await deleteShareFloating(no, user);
    revalidate();
    return { deleted: true };
  });
}

export async function submitShareFloatingRequest(no: string): Promise<ActionResult<{ updated: true; autoApproved: boolean }>> {
  return actionResult(async () => {
    const user = await requireAction('SHARE_TRADING_CREATE');
    const { autoApproved } = await submitShareFloating(no, user);
    revalidate(no);
    return { updated: true, autoApproved };
  });
}

export async function cancelShareFloatingApprovalRequest(no: string): Promise<ActionResult<{ updated: true }>> {
  return actionResult(async () => {
    const user = await requireAction('SHARE_TRADING_CREATE');
    await cancelShareFloatingApproval(no, user);
    revalidate(no);
    return { updated: true };
  });
}

export async function approveShareFloatingRequest(no: string): Promise<ActionResult<{ updated: true }>> {
  return actionResult(async () => {
    const routed = await findPendingRoutedTask('SHARE_FLOATING', no);
    if (routed) {
      const user = await requireUser();
      await decideWorkflowTask(routed.id, true, null, user);
    } else {
      const user = await requireAction('SHARE_TRADING_APPROVE');
      await approveShareFloating(no, user);
    }
    revalidate(no);
    return { updated: true };
  });
}

export async function rejectShareFloatingRequest(no: string, reason: string): Promise<ActionResult<{ updated: true }>> {
  return actionResult(async () => {
    const routed = await findPendingRoutedTask('SHARE_FLOATING', no);
    if (routed) {
      const user = await requireUser();
      await decideWorkflowTask(routed.id, false, reason || null, user);
    } else {
      const user = await requireAction('SHARE_TRADING_APPROVE');
      await rejectShareFloating(no, reason || null, user);
    }
    revalidate(no);
    return { updated: true };
  });
}

export async function reopenShareFloatingRequest(no: string): Promise<ActionResult<{ updated: true }>> {
  return actionResult(async () => {
    const user = await requireAction('SHARE_TRADING_APPROVE');
    await reopenShareFloating(no, user);
    revalidate(no);
    return { updated: true };
  });
}

/* ------------------------------------------------------------------- market */

export async function publishShareFloatingRequest(no: string): Promise<ActionResult<{ journalNo: string; expiryDate: IsoDate }>> {
  return actionResult(async () => {
    const user = await requireAction('SHARE_TRADING_PROCESS');
    const res = await publishShareFloating(no, user);
    revalidate(no);
    return res;
  });
}

export async function placeShareBidRequest(no: string, values: FormValues): Promise<ActionResult<{ total: Cents }>> {
  return actionResult(async () => {
    const user = await requireAction('SHARE_TRADING_BID');
    const res = await placeShareBid(no, {
      memberId: Number(values.memberId), bidPrice: money(values.bidPrice),
      source: String(values.source || 'Walking') as ShareTradeSource,
    }, user);
    revalidate(no);
    return res;
  });
}

export async function withdrawShareBidRequest(no: string, bidId: number): Promise<ActionResult<{ deleted: true }>> {
  return actionResult(async () => {
    const user = await requireAction('SHARE_TRADING_BID');
    await withdrawShareBid(bidId, user);
    revalidate(no);
    return { deleted: true };
  });
}

export async function analyseShareBidsRequest(no: string): Promise<ActionResult<{ winner: ShareBidView | null }>> {
  return actionResult(async () => {
    const user = await requireAction('SHARE_TRADING_PROCESS');
    const res = await analyseShareBids(no, user);
    revalidate(no);
    return res;
  });
}

export async function notifyShareAwardRequest(no: string): Promise<ActionResult<{ sent: true }>> {
  return actionResult(async () => {
    const user = await requireAction('SHARE_TRADING_PROCESS');
    await notifyShareAward(no, user);
    return { sent: true };
  });
}

export async function postSharePurchaseRequest(no: string): Promise<ActionResult<{ journalNo: string; dueDate: IsoDate | null }>> {
  return actionResult(async () => {
    const user = await requireAction('SHARE_TRADING_PROCESS');
    const res = await postSharePurchase(no, user);
    revalidate(no);
    return res;
  });
}

export async function allocateSharePaymentRequest(no: string, values: FormValues): Promise<ActionResult<{ updated: true }>> {
  return actionResult(async () => {
    const user = await requireAction('SHARE_TRADING_PROCESS');
    await addShareTransferReceipt(no, Number(values.savingsAccountId), money(values.amount), user);
    revalidate(no);
    return { updated: true };
  });
}

export async function removeSharePaymentRequest(no: string, id: number): Promise<ActionResult<{ deleted: true }>> {
  return actionResult(async () => {
    const user = await requireAction('SHARE_TRADING_PROCESS');
    await removeShareTransferReceipt(id, user);
    revalidate(no);
    return { deleted: true };
  });
}

export async function transferSharesRequest(no: string): Promise<ActionResult<{ journalNo: string; proceeds: Cents; sellerCharge: Cents }>> {
  return actionResult(async () => {
    const user = await requireAction('SHARE_TRADING_PROCESS');
    const res = await transferShares(no, user);
    revalidate(no);
    return res;
  });
}

export async function takeDownShareFloatingRequest(no: string): Promise<ActionResult<{ journalNo: string }>> {
  return actionResult(async () => {
    const user = await requireAction('SHARE_TRADING_PROCESS');
    const res = await takeDownShareFloating(no, user);
    revalidate(no);
    return res;
  });
}

export async function applyShareNoBidRuleRequest(no: string): Promise<ActionResult<{ action: string; expiryDate?: IsoDate }>> {
  return actionResult(async () => {
    const user = await requireAction('SHARE_TRADING_PROCESS');
    const res = await applyShareNoBidRule(no, user);
    revalidate(no);
    return res;
  });
}

export async function processExpiredShareFloatingsRequest(): Promise<ActionResult<{ extended: number; reversed: number; withBids: number }>> {
  return actionResult(async () => {
    const user = await requireAction('SHARE_TRADING_PROCESS');
    const res = await processExpiredShareFloatings(user);
    revalidate();
    return res;
  });
}

/* ------------------------------------------------------------------ lookups */

export async function shareMemberPositionRequest(memberId: number, windowNo?: string | null): Promise<ActionResult<ShareMemberPosition>> {
  return actionResult(async () => {
    await requireAction('SHARE_TRADING_READ');
    return shareMemberPosition(memberId, windowNo);
  });
}

export async function shareProceedsAccountsRequest(memberId: number, type: ShareProceedsType): Promise<ActionResult<ShareProceedsAccount[]>> {
  return actionResult(async () => {
    await requireAction('SHARE_TRADING_READ');
    return shareProceedsAccountsForMember(memberId, type);
  });
}

export async function sharePaymentAccountsRequest(memberId: number): Promise<ActionResult<SharePaymentAccount[]>> {
  return actionResult(async () => {
    await requireAction('SHARE_TRADING_READ');
    return sharePaymentAccountsForMember(memberId);
  });
}
