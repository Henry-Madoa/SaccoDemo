/*
 * Official Receipt printout — AL Rep52203569 "Customer Receipt" (./ssrs/CustomerReceipt.rdl), and
 * for a Member receipt the Nation CBS Rep52204075 "Member Cash Receipt".
 *
 * A member's copy has to answer one more question than a customer's: what did this payment leave
 * me owing? So a Member receipt prints the loan balances quoted when the line was captured and
 * what the payment settled, rather than just the amount.
 *
 * Built from a posted_receipt and rendered through the shared document chrome in
 * lib/documentPrint.ts, so the receipt a member walks away with carries the same letterhead and
 * signature strip as the invoice or voucher behind it.
 *
 * Used by /receipt-slip/[no].
 */
import { one, all } from './db.ts';
import { formatDate } from './format.ts';
import { amountInWords } from './numberToWords.ts';
import { signatureFor } from './userSignatures.ts';
import {
  printBrand, documentMoney, currencyLabel, renderDocument,
} from './documentPrint.ts';
import type { PrintDocument, PrintColumn, PrintRow } from './documentPrint.ts';
import type { PostedReceipt, PostedReceiptLine } from './types.ts';

export { renderDocument };

const COLUMNS: PrintColumn[] = [
  { key: 'account', label: 'Account', width: '26%' },
  { key: 'description', label: 'Being payment for' },
  { key: 'applies', label: 'Applied To', width: '16%' },
  { key: 'amount', label: 'Amount', align: 'right', width: '18%' },
];

/** A member's copy: what was owed on the loan, what the charge took, and what was paid. */
const MEMBER_COLUMNS: PrintColumn[] = [
  { key: 'account', label: 'Account', width: '22%' },
  { key: 'description', label: 'Being payment for' },
  { key: 'owing', label: 'Was Owing', align: 'right', width: '15%' },
  { key: 'charge', label: 'Charge', align: 'right', width: '12%' },
  { key: 'amount', label: 'Amount', align: 'right', width: '15%' },
];

/** The same, for a receipt whose lines are spread across several members — then whose account
 *  each line went to is the first thing the person holding it needs to see. */
const SHARED_MEMBER_COLUMNS: PrintColumn[] = [
  { key: 'member', label: 'Member', width: '18%' },
  { key: 'account', label: 'Account', width: '20%' },
  { key: 'description', label: 'Being payment for' },
  { key: 'owing', label: 'Was Owing', align: 'right', width: '14%' },
  { key: 'amount', label: 'Amount', align: 'right', width: '15%' },
];

/** The member numbers behind a receipt's lines, in one read. */
async function memberNumbersFor(lines: PostedReceiptLine[]): Promise<Map<number, string>> {
  const ids = [...new Set(lines.map((l) => Number(l.member_id)).filter(Boolean))];
  if (!ids.length) return new Map();
  const rows = await all<{ id: number; member_no: string }>(
    `SELECT id, member_no FROM member WHERE id IN (${ids.map(() => '?').join(',')})`, ...ids,
  );
  return new Map(rows.map((r) => [Number(r.id), r.member_no]));
}

/** The loan numbers behind a member receipt's lines, in one read. */
async function loanNumbersFor(lines: PostedReceiptLine[]): Promise<Map<number, string>> {
  const ids = [...new Set(lines.map((l) => Number(l.loan_id)).filter(Boolean))];
  if (!ids.length) return new Map();
  const rows = await all<{ id: number; loan_no: string }>(
    `SELECT id, loan_no FROM loan WHERE id IN (${ids.map(() => '?').join(',')})`, ...ids,
  );
  return new Map(rows.map((r) => [Number(r.id), r.loan_no]));
}

export async function buildReceiptDocument(no: string): Promise<PrintDocument | null> {
  const doc = await one<PostedReceipt>(
    'SELECT * FROM posted_receipt WHERE no = ? OR receipt_no = ?', no, no,
  );
  if (!doc) return null;
  const brand = await printBrand();
  if (!brand) return null;
  const money = documentMoney(brand, doc.currency_code);

  const [lines, issuedBy] = await Promise.all([
    all<PostedReceiptLine>(
      'SELECT * FROM posted_receipt_line WHERE posted_receipt_id = ? ORDER BY line_no', doc.id,
    ),
    // The cashier who issued it signs the printout, if they have a signature on file.
    signatureFor(doc.created_by),
  ]);

  const isMember = doc.receipt_type === 'Member';
  const loanNos = isMember ? await loanNumbersFor(lines) : new Map<number, string>();
  // A receipt may collect for several members at once; only then is the member column earned.
  const memberNos = isMember ? await memberNumbersFor(lines) : new Map<number, string>();
  const spansMembers = isMember
    && new Set(lines.map((l) => Number(l.member_id)).filter(Boolean)).size > 1;

  const rows: PrintRow[] = lines.map((l): PrintRow => ({
    cells: isMember
      ? {
        member: memberNos.get(Number(l.member_id)) ?? doc.member_no ?? '',
        account: l.account_name || l.account_no || '',
        description: l.loan_id
          ? `Loan repayment — ${loanNos.get(Number(l.loan_id)) ?? ''}`
          : (l.description || 'Deposit'),
        owing: l.loan_id ? money(l.loan_balance) : '—',
        charge: l.charge_amount ? money(l.charge_amount) : '—',
        amount: money(l.amount),
      }
      : {
        account: [l.account_no, l.account_name].filter(Boolean).join(' — ') || '',
        description: l.description ?? '',
        applies: l.applies_to_doc_no ?? '—',
        amount: money(l.amount),
      },
  }));

  return {
    brand,
    title: 'Official Receipt',
    subtitle: doc.receipt_no && doc.receipt_no !== doc.no ? `Receipt ${doc.receipt_no}` : null,
    status: { label: 'Posted', tone: 'ok' },
    parties: [{
      heading: 'Received from',
      name: (isMember ? doc.member_name : doc.description) || doc.description || '—',
      lines: [
        isMember && doc.member_no ? `Member No. ${doc.member_no}` : '',
        isMember && doc.description ? doc.description : '',
        doc.bank_account_name ? `Banked to ${doc.bank_account_name}` : '',
      ].filter(Boolean),
    }],
    meta: [
      { label: 'Receipt No.', value: doc.no },
      { label: 'Date', value: formatDate(doc.posting_date) },
      ...(doc.pay_mode_code ? [{ label: 'Payment Mode', value: doc.pay_mode_code }] : []),
      ...(doc.external_document_no ? [{ label: 'Cheque / Ref. No.', value: doc.external_document_no }] : []),
      ...(doc.manual_receipt_no ? [{ label: 'Manual Receipt No.', value: doc.manual_receipt_no }] : []),
      { label: 'Currency', value: doc.currency_code },
      { label: 'Amount Received', value: money(doc.amount), strong: true },
    ],
    columns: spansMembers ? SHARED_MEMBER_COLUMNS : isMember ? MEMBER_COLUMNS : COLUMNS,
    rows,
    totals: [{ label: `Total received (${doc.currency_code})`, value: money(doc.amount), grand: true }],
    amount_words: amountInWords(doc.amount, currencyLabel(doc.currency_code)),
    signatures: [
      { label: 'Received by', block: issuedBy },
      { label: 'Authorised signature', block: null },
    ],
    footnote: 'This is a computer-generated receipt and is valid without a rubber stamp.',
  };
}
