/*
 * Bankers Cheque Schedule — AL Rep52204097. A print-friendly register of posted banker's
 * cheques, filtered by posting-date range and/or document No., with a society header. Rendered
 * as a self-contained HTML fragment (inline styles, own @media print rules, no external assets)
 * the same way lib/tellerSlip.ts's renderSlipHtml() is.
 */
import { formatDate, formatMoney } from './format.ts';
import type { BankersChequeScheduleRow, Organisation } from './types.ts';

const esc = (s: unknown): string => String(s ?? '')
  .replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;');

export interface ScheduleMeta {
  from?: string | null;
  to?: string | null;
  no?: string | null;
}

export function renderBankersChequeScheduleHtml(
  org: Organisation, rows: BankersChequeScheduleRow[], meta: ScheduleMeta = {},
): string {
  const money = (c: number): string =>
    formatMoney(c, { symbol: org.currency_symbol, locale: org.locale, code: org.currency_code });
  const address = [org.physical_address, org.postal_address, org.city].filter(Boolean).map(esc).join(' · ');
  const contact = [org.phone_primary, org.email].filter(Boolean).map(esc).join(' · ');

  const period = [
    meta.from ? `From ${esc(formatDate(meta.from))}` : null,
    meta.to ? `To ${esc(formatDate(meta.to))}` : null,
    meta.no ? `No. like “${esc(meta.no)}”` : null,
  ].filter(Boolean).join(' · ') || 'All posted banker’s cheques';

  const total = rows.reduce((t, r) => ({
    amount: t.amount + r.amount, charge: t.charge + r.charge_amount, net: t.net + r.net_amount,
  }), { amount: 0, charge: 0, net: 0 });

  const body = rows.length
    ? rows.map((r) => `
        <tr>
          <td class="mono">${esc(r.no)}</td>
          <td>${esc(formatDate(r.posting_date))}</td>
          <td class="mono">${esc(r.cheque_no || '—')}</td>
          <td>${esc(r.account_name)}<div class="sub mono">${esc(r.account_no)}</div></td>
          <td>${esc(r.payee_details || '—')}</td>
          <td class="num">${money(r.amount)}</td>
          <td class="num">${money(r.charge_amount)}</td>
          <td class="num">${money(r.net_amount)}</td>
        </tr>`).join('')
    : '<tr><td colspan="8" class="empty">No posted banker’s cheques match this filter.</td></tr>';

  return `
<style>
  .sched { font-family: Arial, Helvetica, sans-serif; max-width: 1000px; margin: 0 auto; color: #111; }
  .sched .org { text-align: center; border-bottom: 2px solid #111; padding-bottom: 12px; margin-bottom: 12px; }
  .sched .org .name { font-size: 20px; font-weight: 700; }
  .sched .org .meta { font-size: 11px; color: #444; margin-top: 4px; }
  .sched .title { text-align: center; font-size: 15px; font-weight: 700; text-transform: uppercase;
    background: #f2f2f2; padding: 8px; margin-bottom: 6px; letter-spacing: .08em; }
  .sched .period { text-align: center; font-size: 12px; color: #444; margin-bottom: 14px; }
  .sched table { width: 100%; border-collapse: collapse; }
  .sched th, .sched td { padding: 6px 8px; font-size: 12px; vertical-align: top; border-bottom: 1px solid #e6e6e6; text-align: left; }
  .sched th { background: #f2f2f2; border-bottom: 1px solid #bbb; }
  .sched td.num, .sched th.num { text-align: right; white-space: nowrap; }
  .sched td.mono, .sched .mono { font-family: 'Courier New', monospace; }
  .sched .sub { font-size: 10px; color: #777; }
  .sched tr.total td { font-weight: 700; border-top: 2px solid #111; border-bottom: none; }
  .sched td.empty { text-align: center; color: #777; padding: 24px; }
  .sched .foot { margin-top: 18px; font-size: 10px; color: #777; text-align: center; }
  @media print { .no-print { display: none !important; } body { margin: 0; } .sched { max-width: none; } }
</style>
<div class="sched">
  <div class="org">
    <div class="name">${esc(org.name)}</div>
    ${address ? `<div class="meta">${address}</div>` : ''}
    ${contact ? `<div class="meta">${contact}</div>` : ''}
  </div>
  <div class="title">Banker's Cheque Schedule</div>
  <div class="period">${period}</div>
  <table>
    <thead>
      <tr>
        <th>No.</th><th>Posting date</th><th>Cheque no.</th><th>Account name</th><th>Payee details</th>
        <th class="num">Amount</th><th class="num">Charge</th><th class="num">Net amount</th>
      </tr>
    </thead>
    <tbody>
      ${body}
      ${rows.length ? `
        <tr class="total">
          <td colspan="5">Total — ${rows.length} cheque${rows.length === 1 ? '' : 's'}</td>
          <td class="num">${money(total.amount)}</td>
          <td class="num">${money(total.charge)}</td>
          <td class="num">${money(total.net)}</td>
        </tr>` : ''}
    </tbody>
  </table>
  <div class="foot">Generated ${esc(formatDate(new Date().toISOString().slice(0, 10)))} · ${esc(org.name)}</div>
</div>`;
}
