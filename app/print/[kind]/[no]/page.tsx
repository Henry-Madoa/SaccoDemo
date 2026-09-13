import { notFound } from 'next/navigation';
import { requireAction } from '@/lib/session';
import { renderDocument, renderDocuments } from '@/lib/documentPrint';
import { buildSalesDocumentPrint, buildPostedSalesDocumentPrint } from '@/lib/salesDocumentPrint';
import { buildPurchaseDocumentPrint, buildPostedPurchaseDocumentPrint } from '@/lib/purchaseDocumentPrint';
import { buildPaymentVoucherDocument } from '@/lib/paymentVoucherSlip';
import { buildReceiptDocument } from '@/lib/receiptSlip';
import { buildDividendSlipPrint, buildDividendSlipBatch } from '@/lib/dividendSlip';
import { buildShareTransferPrint, buildShareMarketPrint } from '@/lib/shareTradingPrint';
import { buildImprestRequestPrint, buildImprestSurrenderPrint, buildPettyCashPrint, buildStaffClaimPrint } from '@/lib/imprestPrint';
import { buildStoreRequisitionPrint, buildPurchaseRequisitionPrint } from '@/lib/requisitionPrint';
import { Printable } from '@/components/ui/printable';
import type { PrintDocument } from '@/lib/documentPrint';
import type { ActionKey } from '@/lib/permissions';

export const dynamic = 'force-dynamic';

/**
 * Every printable business document, behind one route.
 *
 * The AL application has a separate report object per document (Rep52204455 "Sales Invoice",
 * Rep52204456 "Purchase Receipt (GRN)", Rep52203568 "Payment Voucher" …). Here they are all the
 * same pipeline — build a PrintDocument, render it through the shared chrome — so the only thing
 * that varies per kind is which builder runs and which permission opens it.
 */
const KINDS: Record<string, {
  action: ActionKey;
  /** A single sheet, or a batch — a dividend run prints one slip per member off one URL. */
  build: (no: string) => Promise<PrintDocument | PrintDocument[] | null>;
}> = {
  sales: { action: 'RECEIVABLES_READ', build: buildSalesDocumentPrint },
  'posted-sales': { action: 'RECEIVABLES_READ', build: buildPostedSalesDocumentPrint },
  purchase: { action: 'PAYABLES_READ', build: buildPurchaseDocumentPrint },
  'posted-purchase': { action: 'PAYABLES_READ', build: buildPostedPurchaseDocumentPrint },
  'payment-voucher': { action: 'CASH_MGMT_READ', build: buildPaymentVoucherDocument },
  receipt: { action: 'CASH_MGMT_READ', build: buildReceiptDocument },
  'dividend-slip': { action: 'DIVIDENDS_READ', build: buildDividendSlipPrint },
  'dividend-slips': { action: 'DIVIDENDS_READ', build: buildDividendSlipBatch },
  'share-transfer': { action: 'SHARE_TRADING_READ', build: buildShareTransferPrint },
  'share-market': { action: 'SHARE_TRADING_READ', build: buildShareMarketPrint },
  'imprest-request': { action: 'IMPREST_READ', build: buildImprestRequestPrint },
  'imprest-surrender': { action: 'IMPREST_READ', build: buildImprestSurrenderPrint },
  'petty-cash': { action: 'IMPREST_READ', build: buildPettyCashPrint },
  'staff-claim': { action: 'IMPREST_READ', build: buildStaffClaimPrint },
  'store-requisition': { action: 'REQUISITIONS_READ', build: buildStoreRequisitionPrint },
  'purchase-requisition': { action: 'REQUISITIONS_READ', build: buildPurchaseRequisitionPrint },
};

export default async function PrintDocumentPage({ params }: { params: Promise<{ kind: string; no: string }> }) {
  const { kind, no } = await params;
  const entry = KINDS[kind];
  if (!entry) notFound();
  await requireAction(entry.action);
  const doc = await entry.build(decodeURIComponent(no));
  if (!doc || (Array.isArray(doc) && !doc.length)) notFound();
  return <Printable html={Array.isArray(doc) ? renderDocuments(doc) : renderDocument(doc)} />;
}
