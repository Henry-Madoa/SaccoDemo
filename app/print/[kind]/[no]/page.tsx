import { notFound } from 'next/navigation';
import { requireAction } from '@/lib/session';
import { renderDocument } from '@/lib/documentPrint';
import {
  buildSalesDocumentPrint, buildPostedSalesDocumentPrint, buildCashReceiptPrint,
} from '@/lib/salesDocumentPrint';
import {
  buildPurchaseDocumentPrint, buildPostedPurchaseDocumentPrint, buildPaymentJournalPrint,
} from '@/lib/purchaseDocumentPrint';
import { buildPaymentVoucherDocument } from '@/lib/paymentVoucherSlip';
import { buildReceiptDocument } from '@/lib/receiptSlip';
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
const KINDS: Record<string, { action: ActionKey; build: (no: string) => Promise<PrintDocument | null> }> = {
  sales: { action: 'RECEIVABLES_READ', build: buildSalesDocumentPrint },
  'posted-sales': { action: 'RECEIVABLES_READ', build: buildPostedSalesDocumentPrint },
  'cash-receipt': { action: 'RECEIVABLES_READ', build: buildCashReceiptPrint },
  purchase: { action: 'PAYABLES_READ', build: buildPurchaseDocumentPrint },
  'posted-purchase': { action: 'PAYABLES_READ', build: buildPostedPurchaseDocumentPrint },
  'payment-journal': { action: 'PAYABLES_READ', build: buildPaymentJournalPrint },
  'payment-voucher': { action: 'CASH_MGMT_READ', build: buildPaymentVoucherDocument },
  receipt: { action: 'CASH_MGMT_READ', build: buildReceiptDocument },
};

export default async function PrintDocumentPage({ params }: { params: Promise<{ kind: string; no: string }> }) {
  const { kind, no } = await params;
  const entry = KINDS[kind];
  if (!entry) notFound();
  await requireAction(entry.action);
  const doc = await entry.build(decodeURIComponent(no));
  if (!doc) notFound();
  return <Printable html={renderDocument(doc)} />;
}
