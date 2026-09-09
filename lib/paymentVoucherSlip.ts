/*
 * Payment Voucher printout — AL Rep52203568 "Payment Voucher" (./ssrs/PaymentVoucher.rdl).
 *
 * Built from a posted_payment_voucher and rendered through the shared document chrome in
 * lib/documentPrint.ts, so it carries the same letterhead, line table and signature strip as
 * every Sales and Purchase document. The AL layout's deduction block is reproduced in the
 * totals: gross, VAT included, withholding tax and withholding VAT deducted, net paid.
 *
 * Used by /pv-slip/[no].
 */
import { one, all } from './db.ts';
import { formatDate, formatMoney } from './format.ts';
import { amountInWords } from './numberToWords.ts';
import { signaturesFor } from './userSignatures.ts';
import {
  printBrand, documentMoney, currencyLabel, renderDocument,
} from './documentPrint.ts';
import type { PrintDocument, PrintColumn, PrintRow } from './documentPrint.ts';
import type { PostedPaymentVoucher, PostedPaymentVoucherLine } from './types.ts';

export { renderDocument };

const COLUMNS: PrintColumn[] = [
  { key: 'account', label: 'Account', width: '22%' },
  { key: 'description', label: 'Details' },
  { key: 'applies', label: 'Applied To', width: '13%' },
  { key: 'amount', label: 'Gross', align: 'right', width: '13%' },
  { key: 'deductions', label: 'VAT / WHT', align: 'right', width: '14%' },
  { key: 'net', label: 'Net', align: 'right', width: '13%' },
];

export async function buildPaymentVoucherDocument(no: string): Promise<PrintDocument | null> {
  const doc = await one<PostedPaymentVoucher & { paying_bank_name: string }>(
    `SELECT ppv.*, ba.name AS paying_bank_name
     FROM posted_payment_voucher ppv JOIN bank_account ba ON ba.id = ppv.paying_bank_account_id
     WHERE ppv.no = ? OR ppv.pv_no = ?`, no, no,
  );
  if (!doc) return null;
  const brand = await printBrand();
  if (!brand) return null;
  const money = documentMoney(brand, doc.currency_code);
  const bare = (c: number): string => formatMoney(c, { showSymbol: false });

  const [lines, bank, branch, signatures] = await Promise.all([
    all<PostedPaymentVoucherLine>(
      'SELECT * FROM posted_payment_voucher_line WHERE posted_payment_voucher_id = ? ORDER BY line_no',
      doc.id,
    ),
    doc.payee_external_bank_code
      ? one<{ name: string }>('SELECT name FROM external_bank WHERE code = ?', doc.payee_external_bank_code)
      : Promise.resolve(undefined),
    doc.payee_bank_branch_code
      ? one<{ branch_name: string }>(
        'SELECT branch_name FROM external_bank_branch WHERE bank_code = ? AND branch_code = ?',
        doc.payee_external_bank_code, doc.payee_bank_branch_code,
      )
      : Promise.resolve(undefined),
    // Whoever prepared, approved and paid it signs the printout, if they have a signature on file.
    signaturesFor([doc.prepared_by, doc.approved_by, doc.created_by]),
  ]);

  const gross = lines.reduce((s, l) => s + l.amount, 0);
  const vat = lines.reduce((s, l) => s + l.vat_amount, 0);
  const wht = lines.reduce((s, l) => s + l.wht_amount_one + l.wht_amount_two, 0);

  const rows: PrintRow[] = lines.map((l) => ({
    cells: {
      account: [l.account_no, l.account_name].filter(Boolean).join(' — ') || '',
      description: l.description ?? '',
      applies: l.applies_to_doc_no ?? '—',
      amount: money(l.amount),
      // Narrow column: the currency is already on the Gross and Net figures beside it.
      deductions: [
        l.vat_amount ? `VAT ${bare(l.vat_amount)}` : null,
        l.wht_amount_one + l.wht_amount_two ? `WHT ${bare(l.wht_amount_one + l.wht_amount_two)}` : null,
      ].filter(Boolean).join('\n') || '—',
      net: money(l.net_amount),
    },
  }));

  return {
    brand,
    title: 'Payment Voucher',
    subtitle: doc.pv_no && doc.pv_no !== doc.no ? `Voucher ${doc.pv_no}` : null,
    status: { label: 'Posted', tone: 'ok' },
    parties: [{
      heading: 'Pay to',
      name: doc.payee_name || '',
      lines: [
        bank?.name ?? doc.payee_external_bank_code ?? '',
        branch?.branch_name ?? doc.payee_bank_branch_code ?? '',
        doc.payee_account_no ? `A/C No. ${doc.payee_account_no}` : '',
      ].filter(Boolean),
    }],
    meta: [
      { label: 'Voucher No.', value: doc.no },
      { label: 'Date', value: formatDate(doc.date) },
      { label: 'Posting Date', value: formatDate(doc.posting_date) },
      { label: 'Paying Bank', value: doc.paying_bank_name },
      ...(doc.pay_mode_code ? [{ label: 'Payment Mode', value: doc.pay_mode_code }] : []),
      ...(doc.cheque_no
        ? [{
          label: 'Cheque / EFT No.',
          value: doc.cheque_date ? `${doc.cheque_no} (${formatDate(doc.cheque_date)})` : doc.cheque_no,
        }]
        : []),
      { label: 'Currency', value: doc.currency_code },
      { label: 'Net Paid', value: money(doc.total_amount), strong: true },
    ],
    columns: COLUMNS,
    rows,
    totals: [
      { label: 'Gross amount', value: money(gross) },
      ...(vat ? [{ label: 'VAT included', value: money(vat) }] : []),
      ...(wht ? [{ label: 'Less: withholding tax', value: money(wht), negative: true }] : []),
      { label: `Net paid (${doc.currency_code})`, value: money(doc.total_amount), grand: true },
    ],
    amount_words: amountInWords(doc.total_amount, currencyLabel(doc.currency_code)),
    notes: doc.description ? [{ heading: 'Being payment for', body: doc.description }] : [],
    signatures: [
      { label: 'Prepared by', block: signatures.get(doc.prepared_by?.trim() ?? '') ?? null },
      { label: 'Approved by', block: signatures.get(doc.approved_by?.trim() ?? '') ?? null },
      { label: 'Paid by', block: signatures.get(doc.created_by?.trim() ?? '') ?? null },
      { label: 'Received by (payee)', block: null },
    ],
  };
}
