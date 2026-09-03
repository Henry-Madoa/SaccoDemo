'use server';

import { revalidatePath } from 'next/cache';
import { requireAction, requireUser } from '@/lib/session';
import { actionResult } from '@/lib/errors';
import { toCents } from '@/lib/format';
import {
  listVendorPostingGroups, createVendorPostingGroup, updateVendorPostingGroup, type VendorPostingGroupInput,
  getPurchasesPayablesSetup, savePurchasesPayablesSetup, type PurchasesPayablesSetupInput,
} from '@/lib/payablesSetup';
import {
  listVendors, getVendor, createVendor, updateVendor, vendorStatistics, getVendorLedgerEntries,
  type VendorInput,
} from '@/lib/vendors';
import {
  listPurchaseDocuments, getPurchaseDocument, createPurchaseDocument, updatePurchaseDocumentHeader, deletePurchaseDocument,
  setPurchaseLines, makeOrder, submitPurchaseDocument, cancelPurchaseDocumentApproval, approvePurchaseDocument,
  rejectPurchaseDocument, reopenPurchaseDocument, postPurchaseDocument,
  type PurchaseHeaderInput, type PurchaseLineInput,
} from '@/lib/purchaseDocuments';
import {
  listPaymentJournals, getPaymentJournal, createPaymentJournal, updatePaymentJournal, deletePaymentJournal,
  submitPaymentJournal, cancelPaymentJournalApproval, approvePaymentJournal, rejectPaymentJournal, reopenPaymentJournal,
  postPaymentJournal, suggestVendorPayments, type PaymentJournalInput,
} from '@/lib/paymentJournal';
import { applyVendorEntries, unapplyVendorEntry } from '@/lib/vendLedger';
import { getAgedAccountsPayable, getVendorStatement } from '@/lib/payablesReports';
import { findPendingRoutedTask, decideWorkflowTask } from '@/lib/workflow';
import type {
  ActionResult, FormValues, PurchaseDocumentType, PurchaseLineType, VendorBlocked,
} from '@/lib/types';

const revalidate = (): void => revalidatePath('/payables', 'layout');
const str = (v: unknown): string => String(v ?? '').trim();
const opt = (v: unknown): string | null => (str(v) === '' ? null : str(v));
const numOrNull = (v: unknown): number | null => (v === undefined || v === '' || v === null ? null : Number(v));
const bool = (v: unknown): boolean => v === 'on' || v === 'true' || v === true;

/* ------------------------------------------------------------------ setup masters */

export async function listVendorPostingGroupsRequest() {
  return actionResult(async () => { await requireAction('PAYABLES_READ'); return listVendorPostingGroups(); });
}
const toVpg = (v: FormValues): VendorPostingGroupInput => ({
  code: str(v.code), description: str(v.description),
  payablesAccountId: Number(v.payables_account_id),
  serviceChargeAccountId: Number(v.service_charge_account_id),
  paymentDiscDebitAccountId: Number(v.payment_disc_debit_account_id),
  paymentDiscCreditAccountId: Number(v.payment_disc_credit_account_id),
  invoiceRoundingAccountId: Number(v.invoice_rounding_account_id),
});
export async function createVpgRequest(v: FormValues): Promise<ActionResult<{ id: number }>> {
  return actionResult(async () => { const u = await requireAction('PAYABLES_SETUP_MANAGE'); const r = await createVendorPostingGroup(toVpg(v), u); revalidate(); return r; });
}
export async function updateVpgRequest(id: number, v: FormValues): Promise<ActionResult<{ id: number }>> {
  return actionResult(async () => { const u = await requireAction('PAYABLES_SETUP_MANAGE'); await updateVendorPostingGroup(id, toVpg(v), u); revalidate(); return { id }; });
}

export async function getPurchasesPayablesSetupRequest() {
  return actionResult(async () => { await requireAction('PAYABLES_READ'); return getPurchasesPayablesSetup(); });
}
export async function savePurchasesPayablesSetupRequest(v: FormValues): Promise<ActionResult<{ saved: true }>> {
  return actionResult(async () => {
    const u = await requireAction('PAYABLES_SETUP_MANAGE');
    const input: PurchasesPayablesSetupInput = {
      defaultVendorPostingGroupCode: opt(v.default_vendor_posting_group_code),
      defaultPaymentTermsCode: opt(v.default_payment_terms_code),
      receiptOnInvoice: bool(v.receipt_on_invoice),
      exactCostReversingMandatory: bool(v.exact_cost_reversing_mandatory),
      allowPayablesPostingFrom: opt(v.allow_payables_posting_from),
      allowPayablesPostingTo: opt(v.allow_payables_posting_to),
    };
    await savePurchasesPayablesSetup(input, u); revalidate(); return { saved: true };
  });
}

/* ------------------------------------------------------------------- vendors */

const toVendorInput = (v: FormValues): VendorInput => ({
  name: str(v.name), name2: opt(v.name2), address: opt(v.address), address2: opt(v.address2), city: opt(v.city),
  postCode: opt(v.postCode), country: opt(v.country), contact: opt(v.contact), phone: opt(v.phone), email: opt(v.email),
  vendorPostingGroupCode: opt(v.vendorPostingGroupCode), paymentTermsCode: opt(v.paymentTermsCode),
  paymentMethodCode: opt(v.paymentMethodCode), purchaser: opt(v.purchaser), ourAccountNo: opt(v.ourAccountNo),
  creditLimit: toCents(v.creditLimit), blocked: (str(v.blocked || '') as VendorBlocked),
  globalDimension1Id: numOrNull(v.globalDimension1Id), globalDimension2Id: numOrNull(v.globalDimension2Id),
});
export async function listVendorsRequest(opts: Parameters<typeof listVendors>[0]) {
  return actionResult(async () => { await requireAction('PAYABLES_READ'); return listVendors(opts); });
}
export async function getVendorRequest(no: string) {
  return actionResult(async () => { await requireAction('PAYABLES_READ'); const v = await getVendor(no); if (!v) return null; return { vendor: v, stats: await vendorStatistics(v.id) }; });
}
export async function vendorLedgerEntriesRequest(vendorId: number) {
  return actionResult(async () => { await requireAction('PAYABLES_READ'); return getVendorLedgerEntries({ vendorId }); });
}
export async function requestVendor(v: FormValues): Promise<ActionResult<{ no: string }>> {
  return actionResult(async () => { const u = await requireAction('PAYABLES_VENDOR_MANAGE'); const r = await createVendor(toVendorInput(v), u); revalidate(); return r; });
}
export async function saveVendor(no: string, v: FormValues): Promise<ActionResult<{ no: string }>> {
  return actionResult(async () => { const u = await requireAction('PAYABLES_VENDOR_MANAGE'); await updateVendor(no, toVendorInput(v), u); revalidate(); return { no }; });
}

/* ------------------------------------------------------------- purchase documents */

export async function listPurchaseDocumentsRequest(opts: Parameters<typeof listPurchaseDocuments>[0]) {
  return actionResult(async () => { await requireAction('PAYABLES_READ'); return listPurchaseDocuments(opts); });
}
export async function getPurchaseDocumentRequest(no: string) {
  return actionResult(async () => { await requireAction('PAYABLES_READ'); return getPurchaseDocument(no); });
}
const toPurchaseHeaderInput = (v: FormValues): PurchaseHeaderInput => ({
  documentType: (str(v.documentType || 'Invoice') as PurchaseDocumentType),
  vendorId: Number(v.vendorId),
  postingDate: str(v.postingDate), documentDate: str(v.documentDate || v.postingDate),
  paymentTermsCode: opt(v.paymentTermsCode), paymentMethodCode: opt(v.paymentMethodCode),
  vendorInvoiceNo: opt(v.vendorInvoiceNo), purchaser: opt(v.purchaser),
});
export interface PurchaseLineDraft {
  type: string; no: string; description: string; quantity: string; directUnitCost: string; lineDiscountPct: string;
  locationCode: string; faDepreciationBookCode: string;
}
const toPurchaseLines = (lines: PurchaseLineDraft[]): PurchaseLineInput[] => lines
  .filter((l) => l.type === 'Comment' || l.no)
  .map((l) => ({
    type: (l.type as PurchaseLineType), no: l.no || null, description: l.description || null,
    quantity: Number(l.quantity || 0), directUnitCost: toCents(l.directUnitCost), lineDiscountPct: Number(l.lineDiscountPct || 0),
    locationCode: l.locationCode || null, faDepreciationBookCode: l.faDepreciationBookCode || null,
  }));

export async function requestPurchaseDocument(v: FormValues, lines: PurchaseLineDraft[]): Promise<ActionResult<{ no: string }>> {
  return actionResult(async () => {
    const u = await requireAction('PAYABLES_PURCHASE_CREATE');
    const res = await createPurchaseDocument(toPurchaseHeaderInput(v), u);
    await setPurchaseLines(res.no, toPurchaseLines(lines), u);
    revalidate();
    return res;
  });
}
export async function savePurchaseDocument(no: string, v: FormValues, lines: PurchaseLineDraft[]): Promise<ActionResult<{ no: string }>> {
  return actionResult(async () => {
    const u = await requireAction('PAYABLES_PURCHASE_CREATE');
    await updatePurchaseDocumentHeader(no, toPurchaseHeaderInput(v), u);
    await setPurchaseLines(no, toPurchaseLines(lines), u);
    revalidate();
    return { no };
  });
}
export async function deletePurchaseDocumentRequest(no: string): Promise<ActionResult<{ deleted: true }>> {
  return actionResult(async () => { const u = await requireAction('PAYABLES_PURCHASE_CREATE'); await deletePurchaseDocument(no, u); revalidate(); return { deleted: true }; });
}
export async function makeOrderRequest(quoteNo: string): Promise<ActionResult<{ no: string }>> {
  return actionResult(async () => { const u = await requireAction('PAYABLES_PURCHASE_CREATE'); const r = await makeOrder(quoteNo, u); revalidate(); return r; });
}
export async function submitPurchaseDocumentRequest(no: string): Promise<ActionResult<{ updated: true; autoApproved: boolean }>> {
  return actionResult(async () => { const u = await requireAction('PAYABLES_PURCHASE_CREATE'); const { autoApproved } = await submitPurchaseDocument(no, u); revalidate(); return { updated: true, autoApproved }; });
}
export async function cancelPurchaseDocumentApprovalRequest(no: string): Promise<ActionResult<{ updated: true }>> {
  return actionResult(async () => { const u = await requireAction('PAYABLES_PURCHASE_CREATE'); await cancelPurchaseDocumentApproval(no, u); revalidate(); return { updated: true }; });
}
export async function approvePurchaseDocumentRequest(no: string): Promise<ActionResult<{ updated: true }>> {
  return actionResult(async () => {
    const routed = await findPendingRoutedTask('PURCHASE_DOCUMENT', no);
    if (routed) { const u = await requireUser(); await decideWorkflowTask(routed.id, true, null, u); }
    else { const u = await requireAction('PAYABLES_PURCHASE_APPROVE'); await approvePurchaseDocument(no, u); }
    revalidate(); return { updated: true };
  });
}
export async function rejectPurchaseDocumentRequest(no: string, reason: string): Promise<ActionResult<{ updated: true }>> {
  return actionResult(async () => {
    const routed = await findPendingRoutedTask('PURCHASE_DOCUMENT', no);
    if (routed) { const u = await requireUser(); await decideWorkflowTask(routed.id, false, reason || null, u); }
    else { const u = await requireAction('PAYABLES_PURCHASE_APPROVE'); await rejectPurchaseDocument(no, reason || null, u); }
    revalidate(); return { updated: true };
  });
}
export async function reopenPurchaseDocumentRequest(no: string): Promise<ActionResult<{ updated: true }>> {
  return actionResult(async () => { const u = await requireAction('PAYABLES_PURCHASE_APPROVE'); await reopenPurchaseDocument(no, u); revalidate(); return { updated: true }; });
}
export async function postPurchaseDocumentRequest(no: string, receive: boolean, invoice: boolean): Promise<ActionResult<Awaited<ReturnType<typeof postPurchaseDocument>>>> {
  return actionResult(async () => { const u = await requireAction('PAYABLES_PURCHASE_POST'); const r = await postPurchaseDocument(no, { receive, invoice }, u); revalidate(); return r; });
}

/* --------------------------------------------------------------- payment journal */

export async function listPaymentJournalsRequest(opts: Parameters<typeof listPaymentJournals>[0]) {
  return actionResult(async () => { await requireAction('PAYABLES_READ'); return listPaymentJournals(opts); });
}
export async function getPaymentJournalRequest(no: string) {
  return actionResult(async () => { await requireAction('PAYABLES_READ'); return getPaymentJournal(no); });
}
export interface PaymentJournalLineDraft { vendorId: string; amount: string; paymentMethodCode: string; appliesToDocNo: string; externalDocumentNo: string; description: string }
const toPaymentJournalInput = (v: FormValues, lines: PaymentJournalLineDraft[]): PaymentJournalInput => ({
  postingDate: str(v.postingDate), documentDate: str(v.documentDate || v.postingDate),
  bankAccountId: Number(v.bankAccountId), description: opt(v.description),
  lines: lines.filter((l) => l.vendorId && l.amount).map((l) => ({
    vendorId: Number(l.vendorId), amount: toCents(l.amount), paymentMethodCode: l.paymentMethodCode || null,
    appliesToDocNo: l.appliesToDocNo || null, externalDocumentNo: l.externalDocumentNo || null, description: l.description || null,
  })),
});
export async function requestPaymentJournal(v: FormValues, lines: PaymentJournalLineDraft[]): Promise<ActionResult<{ no: string }>> {
  return actionResult(async () => { const u = await requireAction('PAYABLES_PAYMENT_CREATE'); const r = await createPaymentJournal(toPaymentJournalInput(v, lines), u); revalidate(); return r; });
}
export async function savePaymentJournal(no: string, v: FormValues, lines: PaymentJournalLineDraft[]): Promise<ActionResult<{ updated: true }>> {
  return actionResult(async () => { const u = await requireAction('PAYABLES_PAYMENT_CREATE'); await updatePaymentJournal(no, toPaymentJournalInput(v, lines), u); revalidate(); return { updated: true }; });
}
export async function deletePaymentJournalRequest(no: string): Promise<ActionResult<{ deleted: true }>> {
  return actionResult(async () => { const u = await requireAction('PAYABLES_PAYMENT_CREATE'); await deletePaymentJournal(no, u); revalidate(); return { deleted: true }; });
}
export async function suggestVendorPaymentsRequest(v: FormValues): Promise<ActionResult<{ no: string; lineCount: number }>> {
  return actionResult(async () => {
    const u = await requireAction('PAYABLES_PAYMENT_CREATE');
    const r = await suggestVendorPayments({
      lastPaymentDate: str(v.lastPaymentDate), findPaymentDiscounts: bool(v.findPaymentDiscounts),
      bankAccountId: Number(v.bankAccountId), postingDate: opt(v.postingDate) ?? undefined,
      onlyVendorId: numOrNull(v.onlyVendorId),
    }, u);
    revalidate();
    return r;
  });
}
export async function submitPaymentJournalRequest(no: string): Promise<ActionResult<{ updated: true; autoApproved: boolean }>> {
  return actionResult(async () => { const u = await requireAction('PAYABLES_PAYMENT_CREATE'); const { autoApproved } = await submitPaymentJournal(no, u); revalidate(); return { updated: true, autoApproved }; });
}
export async function cancelPaymentJournalApprovalRequest(no: string): Promise<ActionResult<{ updated: true }>> {
  return actionResult(async () => { const u = await requireAction('PAYABLES_PAYMENT_CREATE'); await cancelPaymentJournalApproval(no, u); revalidate(); return { updated: true }; });
}
export async function approvePaymentJournalRequest(no: string): Promise<ActionResult<{ updated: true }>> {
  return actionResult(async () => {
    const routed = await findPendingRoutedTask('PAYMENT_JOURNAL', no);
    if (routed) { const u = await requireUser(); await decideWorkflowTask(routed.id, true, null, u); }
    else { const u = await requireAction('PAYABLES_PAYMENT_POST'); await approvePaymentJournal(no, u); }
    revalidate(); return { updated: true };
  });
}
export async function rejectPaymentJournalRequest(no: string, reason: string): Promise<ActionResult<{ updated: true }>> {
  return actionResult(async () => {
    const routed = await findPendingRoutedTask('PAYMENT_JOURNAL', no);
    if (routed) { const u = await requireUser(); await decideWorkflowTask(routed.id, false, reason || null, u); }
    else { const u = await requireAction('PAYABLES_PAYMENT_POST'); await rejectPaymentJournal(no, reason || null, u); }
    revalidate(); return { updated: true };
  });
}
export async function reopenPaymentJournalRequest(no: string): Promise<ActionResult<{ updated: true }>> {
  return actionResult(async () => { const u = await requireAction('PAYABLES_PAYMENT_POST'); await reopenPaymentJournal(no, u); revalidate(); return { updated: true }; });
}
export async function postPaymentJournalRequest(no: string): Promise<ActionResult<{ journalNo: string | null; applied: number }>> {
  return actionResult(async () => { const u = await requireAction('PAYABLES_PAYMENT_POST'); const r = await postPaymentJournal(no, u); revalidate(); return r; });
}

/* -------------------------------------------------------------- apply entries */

export async function applyEntriesRequest(applyingEntryId: number, appliedTo: number[] | 'auto', postingDate: string): Promise<ActionResult<{ closedEntryNos: string[]; discountTaken: number }>> {
  return actionResult(async () => { const u = await requireAction('PAYABLES_APPLY_ENTRIES'); const r = await applyVendorEntries({ applyingEntryId, appliedTo, postingDate }, u); revalidate(); return r; });
}
export async function unapplyEntryRequest(entryId: number): Promise<ActionResult<{ done: true }>> {
  return actionResult(async () => { const u = await requireAction('PAYABLES_APPLY_ENTRIES'); await unapplyVendorEntry(entryId, u); revalidate(); return { done: true }; });
}

/* ------------------------------------------------------------------ reports */

export async function agedApRequest(opts: Parameters<typeof getAgedAccountsPayable>[0]) {
  return actionResult(async () => { await requireAction('PAYABLES_READ'); return getAgedAccountsPayable(opts); });
}
export async function vendorStatementRequest(opts: Parameters<typeof getVendorStatement>[0]) {
  return actionResult(async () => { await requireAction('PAYABLES_READ'); return getVendorStatement(opts); });
}
