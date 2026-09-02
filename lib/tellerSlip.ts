/*
 * Deposit / Withdrawal slip — AL Rep52204068 "Cash Deposit Receipt" / Rep52204069
 * "Cash Withdrawal". Builds the view-model from a posted teller_transaction and renders it as a
 * self-contained HTML fragment used by BOTH the print-friendly page
 * (/teller-transactions/view/[no]/slip) and the email sent to the member after posting.
 */
import { one } from './db.ts';
import { getOrg } from './org.ts';
import { amountInWords } from './numberToWords.ts';
import { getTellerTransaction } from './tellerTransactions.ts';
import { formatDate, formatMoney } from './format.ts';
import type { TellerSlip, TellerTransactionView } from './types.ts';

const esc = (s: unknown): string => String(s ?? '')
  .replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;');

export async function buildTellerSlip(no: string): Promise<TellerSlip | null> {
  const doc = await getTellerTransaction(no);
  if (!doc || !doc.posted) return null;
  const org = await getOrg();
  if (!org) return null;

  // The slip is issued after posting, so account_balance already reflects this transaction.
  const isDeposit = doc.transaction_type === 'CASH_DEPOSIT';
  const bookBalanceAfter = doc.account_balance;
  const bookBalanceBefore = isDeposit
    ? bookBalanceAfter - doc.amount + doc.charge_amount
    : bookBalanceAfter + doc.amount + doc.charge_amount;
  const availableAfter = Math.max(bookBalanceAfter - doc.account_hold_amount - doc.account_min_balance, 0);

  return {
    doc,
    org,
    amountWords: amountInWords(doc.amount, org.currency_code === 'KES' ? 'Kenya Shillings' : org.currency_code),
    bookBalanceBefore,
    bookBalanceAfter,
    availableAfter,
  };
}

export const slipSubject = (doc: TellerTransactionView): string =>
  `${doc.transaction_type === 'CASH_DEPOSIT' ? 'Cash Deposit Receipt' : 'Cash Withdrawal Advice'} — ${doc.no}`;

/** The slip body — inline styles only, its own `@media print` rules, no external assets. */
export function renderSlipHtml(slip: TellerSlip): string {
  const { doc, org } = slip;
  const isDeposit = doc.transaction_type === 'CASH_DEPOSIT';
  const money = (c: number): string => formatMoney(c, { symbol: org.currency_symbol, locale: org.locale, code: org.currency_code });
  const address = [org.physical_address, org.postal_address, org.city].filter(Boolean).map(esc).join(' · ');
  const contact = [org.phone_primary, org.email].filter(Boolean).map(esc).join(' · ');

  const row = (label: string, value: string, cls = ''): string =>
    `<tr class="${cls}"><td class="k">${esc(label)}</td><td class="v">${value}</td></tr>`;

  return `
<style>
  .slip { font-family: Arial, Helvetica, sans-serif; max-width: 620px; margin: 0 auto; color: #111; }
  .slip h1 { font-size: 18px; margin: 0; letter-spacing: .04em; }
  .slip .org { text-align: center; border-bottom: 2px solid #111; padding-bottom: 12px; margin-bottom: 16px; }
  .slip .org .name { font-size: 20px; font-weight: 700; }
  .slip .org .meta { font-size: 11px; color: #444; margin-top: 4px; }
  .slip .title { text-align: center; font-size: 15px; font-weight: 700; text-transform: uppercase;
    background: #f2f2f2; padding: 8px; margin-bottom: 14px; letter-spacing: .08em; }
  .slip table { width: 100%; border-collapse: collapse; }
  .slip td { padding: 6px 4px; font-size: 13px; vertical-align: top; border-bottom: 1px solid #eee; }
  .slip td.k { color: #555; width: 42%; }
  .slip td.v { font-weight: 600; }
  .slip tr.amount td.v { font-size: 16px; }
  .slip .words { font-size: 12px; font-style: italic; color: #333; margin: 8px 0 16px; }
  .slip .sign { display: flex; justify-content: space-between; margin-top: 40px; font-size: 12px; }
  .slip .sign div { width: 45%; border-top: 1px solid #111; padding-top: 4px; text-align: center; }
  .slip .foot { margin-top: 24px; font-size: 10px; color: #777; text-align: center; }
  @media print { .no-print { display: none !important; } body { margin: 0; } .slip { max-width: none; } }
</style>
<div class="slip">
  <div class="org">
    <div class="name">${esc(org.name)}</div>
    ${address ? `<div class="meta">${address}</div>` : ''}
    ${contact ? `<div class="meta">${contact}</div>` : ''}
  </div>
  <div class="title">${isDeposit ? 'Cash Deposit Receipt' : 'Cash Withdrawal Advice'}</div>
  <table>
    ${row('Document No.', esc(doc.no))}
    ${row('Date', esc(formatDate(doc.posted_at ? doc.posted_at.slice(0, 10) : null)))}
    ${row('Member', `${esc(doc.member_first_name)} ${esc(doc.member_last_name)} (${esc(doc.member_no)})`)}
    ${row('Account', `${esc(doc.account_no)} — ${esc(doc.account_product_name)}`)}
    ${isDeposit && doc.source_of_funds ? row('Source of funds', esc(doc.source_of_funds)) : ''}
    ${doc.transacted_by_name ? row('Transacted by', `${esc(doc.transacted_by_name)}${doc.transacted_by_id_no ? ` — ID ${esc(doc.transacted_by_id_no)}` : ''}`) : ''}
    ${row(isDeposit ? 'Amount deposited' : 'Amount withdrawn', money(doc.amount), 'amount')}
    ${doc.charge_amount ? row('Transaction charge', money(doc.charge_amount)) : ''}
    ${row('Book balance before', money(slip.bookBalanceBefore))}
    ${row('Book balance after', money(slip.bookBalanceAfter))}
    ${row('Available balance', money(slip.availableAfter))}
    ${row('Teller / Till', `${esc(doc.teller_username)} — ${esc(doc.till_name)}`)}
  </table>
  <div class="words">${esc(slip.amountWords)}</div>
  <div class="sign">
    <div>Member signature</div>
    <div>Teller signature</div>
  </div>
  <div class="foot">${esc(org.statement_footer || 'This slip is computer generated.')}</div>
</div>`;
}
