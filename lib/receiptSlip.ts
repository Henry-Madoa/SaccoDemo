/*
 * Official Receipt printout — AL Rep52203428 / Rep52203423 ("Receipt"). Builds a plain
 * view-model from a posted receipt and renders it as a self-contained, print-styled HTML
 * fragment (mirror of lib/tellerSlip.ts). Used by /cash-management/receipts/[no]/print.
 */
import { one, all } from './db.ts';
import { getOrg } from './org.ts';
import { amountInWords } from './numberToWords.ts';
import { formatDate, formatMoney } from './format.ts';
import type { PostedReceipt, PostedReceiptLine, ReceiptSlip } from './types.ts';

const esc = (s: unknown): string => String(s ?? '')
  .replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;');

export async function buildReceiptSlip(no: string): Promise<ReceiptSlip | null> {
  const doc = await one<PostedReceipt>('SELECT * FROM posted_receipt WHERE no = ? OR receipt_no = ?', no, no);
  if (!doc) return null;
  const org = await getOrg();
  if (!org) return null;
  const lines = await all<PostedReceiptLine>(
    'SELECT * FROM posted_receipt_line WHERE posted_receipt_id = ? ORDER BY line_no', doc.id,
  );
  const currencyLabel = doc.currency_code === 'KES' ? 'Kenya Shillings' : doc.currency_code;
  return {
    org_name: org.name,
    org_address: [org.physical_address, org.postal_address, org.city].filter(Boolean).join(' · '),
    org_phone: [org.phone_primary, org.email].filter(Boolean).join(' · ') || null,
    receipt_no: doc.no,
    date: doc.posting_date,
    received_from: doc.description || '',
    pay_mode: doc.pay_mode_code,
    cheque_ref: doc.external_document_no,
    manual_no: doc.manual_receipt_no,
    currency_code: doc.currency_code,
    currency_symbol: org.currency_symbol,
    amount: doc.amount,
    amount_words: amountInWords(doc.amount, currencyLabel),
    being_for: lines.map((l) => l.description || l.account_name || l.account_no).filter(Boolean).join('; '),
    lines: lines.map((l) => ({ description: l.description || l.account_name || l.account_no || '', amount: l.amount })),
    issued_by: doc.created_by,
  };
}

/** The receipt body — inline styles only, its own `@media print` rules, no external assets. */
export function renderReceiptHtml(slip: ReceiptSlip): string {
  const money = (c: number): string =>
    formatMoney(c, { symbol: slip.currency_symbol, code: slip.currency_code });
  const row = (label: string, value: string): string =>
    `<tr><td class="k">${esc(label)}</td><td class="v">${value}</td></tr>`;

  return `
<style>
  .slip { font-family: Arial, Helvetica, sans-serif; max-width: 560px; margin: 0 auto; color: #111; }
  .slip .org { text-align: center; border-bottom: 2px solid #111; padding-bottom: 12px; margin-bottom: 14px; }
  .slip .org .name { font-size: 20px; font-weight: 700; }
  .slip .org .meta { font-size: 11px; color: #444; margin-top: 4px; }
  .slip .title { text-align: center; font-size: 15px; font-weight: 700; text-transform: uppercase;
    background: #f2f2f2; padding: 8px; margin-bottom: 14px; letter-spacing: .1em; }
  .slip table { width: 100%; border-collapse: collapse; }
  .slip td { padding: 6px 4px; font-size: 13px; vertical-align: top; border-bottom: 1px solid #eee; }
  .slip td.k { color: #555; width: 40%; }
  .slip td.v { font-weight: 600; }
  .slip tr.amount td.v { font-size: 17px; }
  .slip .words { font-size: 12px; font-style: italic; color: #333; margin: 10px 0 18px; }
  .slip .sign { display: flex; justify-content: space-between; margin-top: 44px; font-size: 12px; }
  .slip .sign div { width: 45%; border-top: 1px solid #111; padding-top: 4px; text-align: center; }
  .slip .foot { margin-top: 24px; font-size: 10px; color: #777; text-align: center; }
  @media print { .no-print { display: none !important; } body { margin: 0; } .slip { max-width: none; } }
</style>
<div class="slip">
  <div class="org">
    <div class="name">${esc(slip.org_name)}</div>
    ${slip.org_address ? `<div class="meta">${esc(slip.org_address)}</div>` : ''}
    ${slip.org_phone ? `<div class="meta">${esc(slip.org_phone)}</div>` : ''}
  </div>
  <div class="title">Official Receipt</div>
  <table>
    ${row('Receipt No.', esc(slip.receipt_no))}
    ${row('Date', esc(formatDate(slip.date)))}
    ${row('Received from', esc(slip.received_from))}
    ${slip.pay_mode ? row('Payment mode', esc(slip.pay_mode)) : ''}
    ${slip.cheque_ref ? row('Cheque / Ref. No.', esc(slip.cheque_ref)) : ''}
    ${slip.manual_no ? row('Manual Receipt No.', esc(slip.manual_no)) : ''}
    ${row('Being payment for', esc(slip.being_for))}
    <tr class="amount"><td class="k">Amount</td><td class="v">${money(slip.amount)}</td></tr>
  </table>
  <div class="words">${esc(slip.amount_words)}</div>
  <div class="sign">
    <div>Received by${slip.issued_by ? ` — ${esc(slip.issued_by)}` : ''}</div>
    <div>Authorised signature</div>
  </div>
  <div class="foot">This is a computer-generated receipt.</div>
</div>`;
}
