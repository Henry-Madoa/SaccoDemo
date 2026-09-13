/*
 * Share Trading printouts — AL Rep52204077 "Share Transfer" (the certificate of a completed
 * transfer: who sold, who bought, how many shares, at what price, less what charges) and
 * Rep52204076 "Share Trading Details" (a trading window and every floating sold in it).
 */
import { one } from './db.ts';
import { formatDate, formatDateTime } from './format.ts';
import { amountInWords } from './numberToWords.ts';
import {
  printBrand, documentMoney, documentSignatories, currencyLabel, type PrintDocument,
} from './documentPrint.ts';
import { getShareFloatingDetail, getShareTradingWindow, listShareFloatings } from './shareTrading.ts';

/** Rep52204077 — printed once the shares have moved. */
export async function buildShareTransferPrint(no: string): Promise<PrintDocument | null> {
  const f = await getShareFloatingDetail(no);
  if (!f || f.outcome !== 'Transferred') return null;
  const brand = await printBrand();
  if (!brand) return null;
  const money = documentMoney(brand, brand.currency_code);
  const winner = f.bid_lines.find((b) => b.awarded && b.bought);
  if (!winner) return null;
  const ids = await one<{ seller: string | null; buyer: string | null }>(
    `SELECT (SELECT identification_no FROM member WHERE id = ?) AS seller,
            (SELECT identification_no FROM member WHERE id = ?) AS buyer`, f.member_id, winner.member_id);

  const proceeds = f.shares_to_float * Number(winner.bid_price);
  const premium = proceeds - Number(f.floated_value);

  return {
    brand,
    title: 'Share Transfer Certificate',
    subtitle: `${f.window_no} — ${f.window_description}`,
    status: { label: 'Transferred', tone: 'ok' },
    parties: [{
      heading: 'Transferred from (seller)',
      name: `${f.first_name} ${f.last_name}`,
      lines: [`Member No. ${f.member_no}`, ids?.seller ? `ID No. ${ids.seller}` : '', `Share account ${f.share_account_no}`].filter(Boolean),
    }, {
      heading: 'Transferred to (buyer)',
      name: `${winner.first_name} ${winner.last_name}`,
      lines: [`Member No. ${winner.member_no}`, ids?.buyer ? `ID No. ${ids.buyer}` : '', `Share account ${winner.share_account_no}`].filter(Boolean),
    }],
    meta: [
      { label: 'Document No.', value: f.no },
      { label: 'Transfer Date', value: f.transferred_at ? formatDate(f.transferred_at.slice(0, 10)) : '—' },
      { label: 'Published On', value: f.published_on ? formatDate(f.published_on) : '—' },
      { label: 'Purchase Posted', value: f.purchase_date ? formatDate(f.purchase_date) : '—' },
      { label: 'Shares Transferred', value: String(f.shares_to_float) },
      { label: 'Par Value / Share', value: money(f.par_value) },
      { label: 'Price Paid / Share', value: money(winner.bid_price) },
      { label: 'Journal', value: f.transfer_journal_no || '—' },
      { label: 'Consideration', value: money(winner.total_amount), strong: true },
    ],
    columns: [
      { key: 'item', label: 'Particulars' },
      { key: 'amount', label: 'Amount', align: 'right', width: '28%' },
    ],
    rows: [
      { cells: { item: `${f.shares_to_float} shares transferred at par (${money(f.par_value)} each)`, amount: money(f.floated_value) } },
      { cells: { item: `Premium over par (${money(winner.bid_price)} bid less ${money(f.par_value)} par × ${f.shares_to_float})`, amount: money(premium) } },
      ...(Number(winner.charges) ? [{ cells: { item: 'Share trading charge borne by the buyer', amount: money(winner.charges) } }] : []),
    ],
    totals: [
      { label: 'Proceeds credited to the seller', value: money(proceeds) },
      { label: 'Paid by the buyer', value: money(winner.total_amount), grand: true },
    ],
    amount_words: amountInWords(Number(winner.total_amount), currencyLabel(brand.currency_code)),
    notes: [
      { heading: 'Paid from', body: f.receipts.map((r) => `${r.account_no} — ${r.product_name}: ${money(r.allocated_amount)}`).join('\n') || '—' },
      { heading: 'Proceeds paid to', body: f.proceeds_account_no ? `${f.proceeds_account_no} — ${f.proceeds_product_name}` : f.proceeds_type },
    ],
    approvals: await documentSignatories('SHARE_FLOATING', f.no, f.created_by, {
      raisedAt: f.created_at, clearedBy: f.transferred_by ?? f.created_by,
    }),
    acknowledgement: { title: 'Acknowledged by the buyer' },
    footnote: 'This certificate records a transfer of share capital between members through the SACCO’s share trading market.',
  };
}

/** Rep52204076 — a trading window with every floating sold in it. */
export async function buildShareMarketPrint(no: string): Promise<PrintDocument | null> {
  const w = await getShareTradingWindow(no);
  if (!w) return null;
  const brand = await printBrand();
  if (!brand) return null;
  const money = documentMoney(brand, brand.currency_code);
  const rows = await listShareFloatings({ view: 'all', filters: [{ field: 'window_no', operator: '=', value: no }] });

  return {
    brand,
    title: 'Share Trading Details',
    subtitle: `${w.no} — ${w.description}`,
    landscape: true,
    status: w.published ? { label: 'Published', tone: 'ok' } : { label: w.status, tone: 'info' },
    parties: [],
    meta: [
      { label: 'Window No.', value: w.no },
      { label: 'Trading Period', value: `${formatDate(w.start_date)} – ${formatDate(w.end_date)}` },
      { label: 'Base (Par) Price', value: money(w.base_price) },
      { label: 'Reserve Price', value: money(w.reserve_price) },
      { label: 'Holding Account', value: `${w.holding_account_code} — ${w.holding_account_name}` },
      { label: 'Clearing Account', value: `${w.clearing_account_code} — ${w.clearing_account_name}` },
      { label: 'Charge', value: w.transaction_charge_code || '—' },
      { label: 'Share Life / Tolerance', value: `${w.share_life || '30D'} / ${w.tolerance_period || '—'}` },
      { label: 'On No Bid', value: w.on_no_bid },
      { label: 'Shares On Market', value: String(w.shares_on_market) },
      { label: 'Value On Market', value: money(w.value_on_market), strong: true },
    ],
    columns: [
      { key: 'no', label: 'Floating', width: '9%' },
      { key: 'member', label: 'Seller' },
      { key: 'account', label: 'Account', width: '10%' },
      { key: 'type', label: 'Type', width: '7%' },
      { key: 'shares', label: 'Shares', align: 'right', width: '7%' },
      { key: 'min', label: 'Min. Price', align: 'right', width: '9%' },
      { key: 'value', label: 'Floated Value', align: 'right', width: '11%' },
      { key: 'bids', label: 'Bids', align: 'right', width: '5%' },
      { key: 'best', label: 'Best Bid', align: 'right', width: '9%' },
      { key: 'published', label: 'Published', width: '9%' },
      { key: 'stage', label: 'Stage', width: '9%' },
    ],
    rows: rows.map((f) => ({
      cells: {
        no: f.no, member: `${f.first_name} ${f.last_name} (${f.member_no})`, account: f.share_account_no, type: f.float_type,
        shares: String(f.shares_to_float), min: money(f.minimum_acceptable_price), value: money(f.floated_value),
        bids: String(f.bids), best: f.maximum_bid_price ? money(f.maximum_bid_price) : '—',
        published: f.published_on ? formatDate(f.published_on) : '—', stage: f.archived ? (f.outcome ?? 'Closed') : f.stage,
      },
    })),
    empty: 'No floatings have been raised in this window.',
    totals: [
      { label: 'Floatings', value: String(rows.length) },
      { label: 'Shares floated', value: String(rows.reduce((s, f) => s + f.shares_to_float, 0)) },
      { label: 'Value floated', value: money(rows.reduce((s, f) => s + Number(f.floated_value), 0)), grand: true },
    ],
    footnote: `Printed ${formatDateTime(new Date().toISOString())}`,
  };
}
