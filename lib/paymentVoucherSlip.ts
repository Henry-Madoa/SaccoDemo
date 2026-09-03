/*
 * Payment Voucher slip — AL Rep52203425 "Payment Voucher". Built from a posted_payment_voucher.
 * Mirror of lib/receiptSlip.ts, with a Deductions block (VAT / WHT) and prepared / approved /
 * paid-by signatures. Used by /cash-management/payment-vouchers/[no]/slip.
 */
import { one, all } from './db.ts';
import { getOrg } from './org.ts';
import { amountInWords } from './numberToWords.ts';
import { formatDate, formatMoney } from './format.ts';
import type { PaymentVoucherSlip, PostedPaymentVoucher, PostedPaymentVoucherLine } from './types.ts';

const esc = (s: unknown): string => String(s ?? '')
  .replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;');

export async function buildPaymentVoucherSlip(no: string): Promise<PaymentVoucherSlip | null> {
  const doc = await one<PostedPaymentVoucher & { paying_bank_name: string }>(
    `SELECT ppv.*, ba.name AS paying_bank_name
     FROM posted_payment_voucher ppv JOIN bank_account ba ON ba.id = ppv.paying_bank_account_id
     WHERE ppv.no = ? OR ppv.pv_no = ?`, no, no,
  );
  if (!doc) return null;
  const org = await getOrg();
  if (!org) return null;
  const lines = await all<PostedPaymentVoucherLine>(
    'SELECT * FROM posted_payment_voucher_line WHERE posted_payment_voucher_id = ? ORDER BY line_no', doc.id,
  );
  const branch = doc.payee_bank_branch_code
    ? await one<{ branch_name: string }>('SELECT branch_name FROM external_bank_branch WHERE bank_code = ? AND branch_code = ?', doc.payee_external_bank_code, doc.payee_bank_branch_code)
    : null;
  const bank = doc.payee_external_bank_code
    ? await one<{ name: string }>('SELECT name FROM external_bank WHERE code = ?', doc.payee_external_bank_code)
    : null;
  const currencyLabel = doc.currency_code === 'KES' ? 'Kenya Shillings' : doc.currency_code;
  const grossTotal = lines.reduce((s, l) => s + l.amount, 0);
  const vatTotal = lines.reduce((s, l) => s + l.vat_amount, 0);
  const whtTotal = lines.reduce((s, l) => s + l.wht_amount_one + l.wht_amount_two, 0);

  return {
    org_name: org.name,
    org_address: [org.physical_address, org.postal_address, org.city].filter(Boolean).join(' · '),
    org_phone: [org.phone_primary, org.email].filter(Boolean).join(' · ') || null,
    pv_no: doc.pv_no,
    date: doc.posting_date,
    payee: doc.payee_name || '',
    payee_bank: bank?.name ?? doc.payee_external_bank_code,
    payee_branch: branch?.branch_name ?? doc.payee_bank_branch_code,
    payee_account_no: doc.payee_account_no,
    pay_mode: doc.pay_mode_code,
    paying_bank: doc.paying_bank_name,
    cheque_no: doc.cheque_no,
    cheque_date: doc.cheque_date,
    narration: doc.description || '',
    currency_code: doc.currency_code,
    currency_symbol: org.currency_symbol,
    total: doc.total_amount,
    total_words: amountInWords(doc.total_amount, currencyLabel),
    lines: lines.map((l) => ({
      account_no: l.account_no || '', account_name: l.account_name || '', description: l.description || '', amount: l.amount,
    })),
    prepared_by: doc.prepared_by,
    approved_by: doc.approved_by,
    paid_by: doc.created_by,
    vat_total: vatTotal,
    wht_total: whtTotal,
    net_paid: grossTotal - whtTotal,
  };
}

export function renderVoucherHtml(slip: PaymentVoucherSlip): string {
  const money = (c: number): string => formatMoney(c, { symbol: slip.currency_symbol, code: slip.currency_code });
  const lineRows = slip.lines.map((l) => `
    <tr><td>${esc(l.account_name || l.account_no)}</td><td>${esc(l.description)}</td><td class="r">${money(l.amount)}</td></tr>`).join('');
  const detail = (label: string, value: string): string =>
    `<tr><td class="k">${esc(label)}</td><td class="v">${value}</td></tr>`;
  return `
<style>
  .pv { font-family: Arial, Helvetica, sans-serif; max-width: 640px; margin: 0 auto; color: #111; }
  .pv .org { text-align: center; border-bottom: 2px solid #111; padding-bottom: 12px; margin-bottom: 14px; }
  .pv .org .name { font-size: 20px; font-weight: 700; }
  .pv .org .meta { font-size: 11px; color: #444; margin-top: 4px; }
  .pv .title { text-align: center; font-size: 15px; font-weight: 700; text-transform: uppercase;
    background: #f2f2f2; padding: 8px; margin-bottom: 14px; letter-spacing: .1em; }
  .pv table { width: 100%; border-collapse: collapse; }
  .pv td { padding: 6px 4px; font-size: 12px; vertical-align: top; border-bottom: 1px solid #eee; }
  .pv td.k { color: #555; width: 38%; } .pv td.v { font-weight: 600; }
  .pv table.lines th { text-align: left; font-size: 11px; color: #555; border-bottom: 1px solid #999; padding: 6px 4px; }
  .pv table.lines td.r, .pv table.lines th.r { text-align: right; }
  .pv .ded { margin-top: 10px; width: 60%; margin-left: auto; }
  .pv .ded td { border: none; padding: 3px 4px; }
  .pv .ded td.r { text-align: right; }
  .pv .words { font-size: 12px; font-style: italic; color: #333; margin: 10px 0 18px; }
  .pv .sign { display: flex; justify-content: space-between; margin-top: 40px; font-size: 11px; }
  .pv .sign div { width: 30%; border-top: 1px solid #111; padding-top: 4px; text-align: center; }
  @media print { .no-print { display: none !important; } body { margin: 0; } .pv { max-width: none; } }
</style>
<div class="pv">
  <div class="org">
    <div class="name">${esc(slip.org_name)}</div>
    ${slip.org_address ? `<div class="meta">${esc(slip.org_address)}</div>` : ''}
    ${slip.org_phone ? `<div class="meta">${esc(slip.org_phone)}</div>` : ''}
  </div>
  <div class="title">Payment Voucher</div>
  <table>
    ${detail('Voucher No.', esc(slip.pv_no))}
    ${detail('Date', esc(formatDate(slip.date)))}
    ${detail('Pay to', esc(slip.payee))}
    ${slip.payee_bank ? detail('Bank / Branch', `${esc(slip.payee_bank)}${slip.payee_branch ? ` — ${esc(slip.payee_branch)}` : ''}`) : ''}
    ${slip.payee_account_no ? detail('Account No.', esc(slip.payee_account_no)) : ''}
    ${detail('Paying bank', esc(slip.paying_bank))}
    ${slip.pay_mode ? detail('Payment mode', esc(slip.pay_mode)) : ''}
    ${slip.cheque_no ? detail('Cheque No.', `${esc(slip.cheque_no)}${slip.cheque_date ? ` (${esc(formatDate(slip.cheque_date))})` : ''}`) : ''}
    ${detail('Narration', esc(slip.narration))}
  </table>
  <table class="lines">
    <thead><tr><th>Account</th><th>Details</th><th class="r">Amount</th></tr></thead>
    <tbody>${lineRows}</tbody>
  </table>
  <table class="ded">
    ${slip.vat_total ? `<tr><td>VAT included</td><td class="r">${money(slip.vat_total)}</td></tr>` : ''}
    ${slip.wht_total ? `<tr><td>Less: Withholding Tax</td><td class="r">(${money(slip.wht_total)})</td></tr>` : ''}
    <tr><td><strong>Net paid</strong></td><td class="r"><strong>${money(slip.total)}</strong></td></tr>
  </table>
  <div class="words">${esc(slip.total_words)}</div>
  <div class="sign">
    <div>Prepared by${slip.prepared_by ? ` — ${esc(slip.prepared_by)}` : ''}</div>
    <div>Approved by${slip.approved_by ? ` — ${esc(slip.approved_by)}` : ''}</div>
    <div>Paid by${slip.paid_by ? ` — ${esc(slip.paid_by)}` : ''}</div>
  </div>
</div>`;
}
