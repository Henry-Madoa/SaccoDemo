/*
 * Banker's Cheque Schedule — AL Rep52204097. A register of posted banker's cheques, filtered by
 * posting-date range and/or document No., rendered through the shared document chrome in
 * lib/documentPrint.ts. A register has no trading party, so the filter it was run under stands
 * in the header grid where an invoice puts its customer.
 *
 * Used by /bankers-cheques/schedule.
 */
import { formatDate } from './format.ts';
import { bankersChequeSchedule } from './bankersCheques.ts';
import { printBrand, documentMoney, renderDocument } from './documentPrint.ts';
import type { PrintDocument, PrintColumn, PrintRow } from './documentPrint.ts';

export { renderDocument };

export interface ScheduleMeta {
  from?: string | null;
  to?: string | null;
  no?: string | null;
}

const COLUMNS: PrintColumn[] = [
  { key: 'no', label: 'No.', width: '11%' },
  { key: 'date', label: 'Posting Date', width: '11%' },
  { key: 'cheque_no', label: 'Cheque No.', width: '11%' },
  { key: 'account', label: 'Account' },
  { key: 'payee', label: 'Payee Details' },
  { key: 'amount', label: 'Amount', align: 'right', width: '11%' },
  { key: 'charge', label: 'Charge', align: 'right', width: '10%' },
  { key: 'net', label: 'Net Amount', align: 'right', width: '11%' },
];

export async function buildBankersChequeScheduleDocument(meta: ScheduleMeta = {}): Promise<PrintDocument | null> {
  const [brand, rows] = await Promise.all([
    printBrand(),
    bankersChequeSchedule({ from: meta.from ?? undefined, to: meta.to ?? undefined, no: meta.no ?? undefined }),
  ]);
  if (!brand) return null;
  const money = documentMoney(brand, brand.currency_code);

  const total = rows.reduce(
    (t, r) => ({ amount: t.amount + r.amount, charge: t.charge + r.charge_amount, net: t.net + r.net_amount }),
    { amount: 0, charge: 0, net: 0 },
  );

  return {
    brand,
    title: "Banker's Cheque Schedule",
    subtitle: 'Posted cheques',
    landscape: true,
    parties: [],
    meta: [
      { label: 'From', value: meta.from ? formatDate(meta.from) : 'Earliest posted' },
      { label: 'To', value: meta.to ? formatDate(meta.to) : 'Latest posted' },
      ...(meta.no ? [{ label: 'Document No. like', value: meta.no }] : []),
      { label: 'Cheques', value: String(rows.length) },
      { label: 'Total Net Amount', value: money(total.net), strong: true },
    ],
    columns: COLUMNS,
    empty: "No posted banker's cheques match this filter.",
    rows: [
      ...rows.map((r): PrintRow => ({
        cells: {
          no: r.no,
          date: formatDate(r.posting_date),
          cheque_no: r.cheque_no || '—',
          account: `${r.account_name}\n${r.account_no}`,
          payee: r.payee_details || '—',
          amount: money(r.amount),
          charge: money(r.charge_amount),
          net: money(r.net_amount),
        },
      })),
      ...(rows.length
        ? [{
          strong: true,
          cells: {
            no: '', date: '', cheque_no: '', account: '',
            payee: `Total — ${rows.length} cheque${rows.length === 1 ? '' : 's'}`,
            amount: money(total.amount),
            charge: money(total.charge),
            net: money(total.net),
          },
        } satisfies PrintRow]
        : []),
    ],
    totals: [
      { label: 'Face value', value: money(total.amount) },
      { label: 'Charges', value: money(total.charge) },
      { label: 'Net amount', value: money(total.net), grand: true },
    ],
    // A schedule covers many cheques, so it carries the three roles as blank rules for whoever
    // signs the batch rather than any one document's approval trail.
    signatures: [
      { label: 'Checked by', block: null },
      { label: 'Approved by', block: null },
      { label: 'Authorised by', block: null },
    ],
  };
}
