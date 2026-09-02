/*
 * Cheque Deposit Slip — AL Rep52204082. A print-friendly acknowledgement slip for a captured
 * cheque deposit, rendered as a self-contained HTML fragment (inline styles, own @media print
 * rules, no external assets) the same way lib/tellerSlip.ts's renderSlipHtml() is.
 */
import { getOrg } from './org.ts';
import { amountInWords } from './numberToWords.ts';
import { getChequeDeposit } from './chequeDeposits.ts';
import { formatDate, formatMoney } from './format.ts';
import type { ChequeDepositView, Organisation } from './types.ts';

const esc = (s: unknown): string => String(s ?? '')
  .replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;');

export interface ChequeDepositSlip {
  doc: ChequeDepositView;
  org: Organisation;
  amountWords: string;
}

export async function buildChequeDepositSlip(no: string): Promise<ChequeDepositSlip | null> {
  const doc = await getChequeDeposit(no);
  if (!doc) return null;
  const org = await getOrg();
  if (!org) return null;
  return {
    doc,
    org,
    amountWords: amountInWords(doc.amount, org.currency_code === 'KES' ? 'Kenya Shillings' : org.currency_code),
  };
}

export function renderChequeDepositSlipHtml(slip: ChequeDepositSlip): string {
  const { doc, org } = slip;
  const money = (c: number): string => formatMoney(c, { symbol: org.currency_symbol, locale: org.locale, code: org.currency_code });
  const address = [org.physical_address, org.postal_address, org.city].filter(Boolean).map(esc).join(' · ');
  const contact = [org.phone_primary, org.email].filter(Boolean).map(esc).join(' · ');
  const row = (label: string, value: string): string =>
    `<tr><td class="k">${esc(label)}</td><td class="v">${value}</td></tr>`;

  return `
<style>
  .slip { font-family: Arial, Helvetica, sans-serif; max-width: 620px; margin: 0 auto; color: #111; }
  .slip .org { text-align: center; border-bottom: 2px solid #111; padding-bottom: 12px; margin-bottom: 16px; }
  .slip .org .name { font-size: 20px; font-weight: 700; }
  .slip .org .meta { font-size: 11px; color: #444; margin-top: 4px; }
  .slip .title { text-align: center; font-size: 15px; font-weight: 700; text-transform: uppercase;
    background: #f2f2f2; padding: 8px; margin-bottom: 14px; letter-spacing: .08em; }
  .slip table { width: 100%; border-collapse: collapse; }
  .slip td { padding: 6px 4px; font-size: 13px; vertical-align: top; border-bottom: 1px solid #eee; }
  .slip td.k { color: #555; width: 44%; }
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
  <div class="title">Cheque Deposit Slip</div>
  <table>
    ${row('Document no.', `<span class="mono">${esc(doc.no)}</span>`)}
    ${row('Status', esc(doc.status))}
    ${row('Member', `${esc(doc.member_first_name)} ${esc(doc.member_last_name)} (${esc(doc.member_no)})`)}
    ${row('Account', `${esc(doc.account_no)} — ${esc(doc.account_product_name)}`)}
    ${row('Cheque type', `${esc(doc.cheque_type_code)} — ${esc(doc.description)}`)}
    ${row('Cheque no.', esc(doc.cheque_no || '—'))}
    ${row('Cheque date', esc(doc.cheque_date ? formatDate(doc.cheque_date) : '—'))}
    ${row('Deposit date', esc(formatDate(doc.deposit_date)))}
    ${row('Maturity date', esc(formatDate(doc.maturity_date)))}
    ${row('Express clearing', doc.express_cheque ? 'Yes' : 'No')}
    ${row('Drawer', esc([doc.drawer_account_name, doc.drawer_bank, doc.drawer_branch].filter(Boolean).join(' · ') || '—'))}
    ${row('Drawer account no.', esc(doc.drawer_account_no || '—'))}
    <tr class="amount">${`<td class="k">Amount</td><td class="v">${money(doc.amount)}</td>`}</tr>
  </table>
  <div class="words">${esc(slip.amountWords)}</div>
  <div class="sign">
    <div>Depositor</div>
    <div>Received by</div>
  </div>
  <div class="foot">This is an acknowledgement of receipt only. Funds are available after the cheque clears on its maturity date.</div>
</div>`;
}
