/*
 * The Dividend Slip — AL Rep52204060 "Dividend Statement" / Rep52204080 "Members Dividend Slip",
 * rebuilt on the shared print engine (lib/documentPrint.ts).
 *
 * One slip per member account, and it has to answer three questions without the member having to
 * ask anyone: what did I earn, how was it worked out, and where did the rest of it go. So the main
 * table is the month-by-month working (dividend_det_entry) exactly as the engine computed it, the
 * first section is every recovery taken off the line, and the totals block reconciles the two into
 * the net payable.
 *
 *   buildDividendSlipPrint('<no>:<lineId>')  one member's slip
 *   buildDividendSlipBatch('<no>')           every earning line, one sheet each
 */
import { one, all } from './db.ts';
import { formatDate } from './format.ts';
import { amountInWords } from './numberToWords.ts';
import {
  printBrand, documentSignatories, documentMoney, currencyLabel, renderDocument, renderDocuments,
} from './documentPrint.ts';
import type { PrintDocument, PrintColumn, PrintRow, PrintSection, PrintTotal } from './documentPrint.ts';
import type {
  Cents, Dividend, DividendDetEntry, DividendRateType, DividendRecoveryEntryType,
} from './types.ts';

export { renderDocument, renderDocuments };

/** How each recovery type is captioned on the slip — plain English, not the enum. */
const RECOVERY_LABELS: Record<DividendRecoveryEntryType, string> = {
  CHARGES: 'Charge',
  PENALTY: 'Loan penalty',
  INTEREST_ARREARS: 'Loan interest in arrears',
  PRINCIPAL_ARREARS: 'Loan principal in arrears',
  INTEREST_PAID: 'Loan interest',
  PRINCIPAL_PAID: 'Loan principal',
  BOOST: 'Share capital top-up',
  PREFERENTIAL_BOOST: 'Preferential share boost',
};

const RATE_TYPE_LABELS: Record<DividendRateType, string> = {
  'Pro Rated': 'Pro-rated on monthly growth',
  'Minimum Balance': 'Monthly minimum balance',
  'Straight Line': 'Flat rate on the closing balance',
};

/** What the member is owed an explanation of — in their words, not the system's. */
const MODEL_NOTES: Record<DividendRateType, string> = {
  'Pro Rated':
    'Your opening balance earns for the whole year. Every deposit after that earns from the month '
    + 'you made it — one made in March earns ten twelfths of the annual rate, one made in December '
    + 'earns one twelfth. A withdrawal never takes back what earlier months have already earned.',
  'Minimum Balance':
    'Each month earns on the lowest balance your account held at any point during that month, '
    + 'above the minimum interest-earning balance, at one twelfth of the annual rate. Money paid in '
    + 'and drawn out again within the same month does not earn.',
  'Straight Line':
    'The full annual rate applied to your closing balance for the year.',
};

const WORKING_COLUMNS: PrintColumn[] = [
  { key: 'month', label: 'Month', width: '12%' },
  { key: 'description', label: 'Description' },
  { key: 'opening', label: 'Opening', align: 'right', width: '14%' },
  { key: 'closing', label: 'Closing', align: 'right', width: '14%' },
  { key: 'base', label: 'Earning On', align: 'right', width: '14%' },
  { key: 'rate', label: 'Rate', align: 'right', width: '9%' },
  { key: 'amount', label: 'Amount', align: 'right', width: '14%' },
];

const RECOVERY_COLUMNS: PrintColumn[] = [
  { key: 'type', label: 'Recovery', width: '26%' },
  { key: 'description', label: 'Details' },
  { key: 'amount', label: 'Amount', align: 'right', width: '18%' },
];

interface SlipLine {
  id: number;
  dividend_id: number;
  member_no: string;
  member_name: string;
  account_no: string;
  phone_no: string | null;
  posting_description: string | null;
  account_balance: Cents;
  amount_earned: Cents;
  total_recoveries: Cents;
  net_amount: Cents;
  deceased: number;
  product_code: string;
  product_name: string;
  destination_account_no: string | null;
  rate: number | null;
  post_to: string | null;
}

const LINE_SELECT = `
  SELECT l.id, l.dividend_id, l.member_no, l.member_name, l.account_no, l.phone_no,
         l.posting_description, l.account_balance, l.amount_earned, l.total_recoveries,
         l.net_amount, l.deceased,
         sp.code AS product_code, sp.name AS product_name,
         da.account_no AS destination_account_no,
         p.rate, p.post_to
  FROM dividend_line l
  JOIN savings_product sp ON sp.id = l.product_id
  LEFT JOIN savings_account da ON da.id = l.destination_account_id
  LEFT JOIN dividend_param p ON p.dividend_id = l.dividend_id AND p.product_id = l.product_id`;

const pct = (n: number | null | undefined): string =>
  `${Number(n ?? 0).toLocaleString('en-KE', { minimumFractionDigits: 2, maximumFractionDigits: 4 })}%`;

/** One member's slip. `ref` is "<dividend no>:<line id>". */
export async function buildDividendSlipPrint(ref: string): Promise<PrintDocument | null> {
  const [no, rawLineId] = ref.split(':');
  const lineId = Number(rawLineId);
  if (!no || !Number.isFinite(lineId)) return null;

  const header = await one<Dividend>('SELECT * FROM dividend WHERE no = ?', no);
  if (!header) return null;
  const line = await one<SlipLine>(`${LINE_SELECT} WHERE l.id = ? AND l.dividend_id = ?`, lineId, header.id);
  if (!line) return null;
  return buildSlip(header, line);
}

/**
 * Every earning line on the dividend, one sheet each — the run an officer prints once and hands
 * out. Lines that earned nothing are left out: a slip stating zero tells the member nothing they
 * did not already know, and printing thousands of them wastes the paper the real ones need.
 */
export async function buildDividendSlipBatch(no: string, limit = 2000): Promise<PrintDocument[]> {
  const header = await one<Dividend>('SELECT * FROM dividend WHERE no = ?', no);
  if (!header) return [];
  const lines = await all<SlipLine>(
    `${LINE_SELECT} WHERE l.dividend_id = @id AND l.amount_earned <> 0
     ORDER BY l.member_no, l.account_no LIMIT @limit`,
    { id: header.id, limit },
  );
  const docs: PrintDocument[] = [];
  for (const line of lines) {
    const doc = await buildSlip(header, line);
    if (doc) docs.push(doc);
  }
  return docs;
}

async function buildSlip(header: Dividend, line: SlipLine): Promise<PrintDocument | null> {
  const brand = await printBrand();
  if (!brand) return null;
  const money = documentMoney(brand, brand.currency_code);

  const [detail, recoveries] = await Promise.all([
    all<DividendDetEntry>(
      'SELECT * FROM dividend_det_entry WHERE dividend_line_id = ? ORDER BY month_no', line.id,
    ),
    all<{ entry_type: DividendRecoveryEntryType; description: string; amount: Cents }>(
      'SELECT entry_type, description, amount FROM dividend_recovery WHERE dividend_line_id = ? ORDER BY priority, id',
      line.id,
    ),
  ]);

  // Which model produced this line is a property of the product, so it is read off the working
  // itself rather than off the document's book — one declaration can carry both.
  const model: DividendRateType = detail[0]?.posting_type ?? 'Pro Rated';
  const rows: PrintRow[] = detail.map((d): PrintRow => ({
    cells: {
      month: d.month_code,
      description: d.description ?? '',
      opening: money(Number(d.previous_month_balance)),
      closing: money(Number(d.current_month_balance)),
      // What the month's earning was actually computed on — the balance that never left on the
      // bank model, the month's own increase on the pro-rated one.
      base: money(Number(d.posting_type === 'Minimum Balance' ? d.minimum_running_balance : d.net_change)),
      rate: d.posting_type === 'Pro Rated' ? `${pct(d.rate)} x ${Number(d.ratio).toFixed(4)}` : pct(d.rate),
      amount: money(Number(d.amount)),
    },
  }));

  const sections: PrintSection[] = recoveries.length
    ? [{
      heading: 'Recovered from this dividend',
      sub: 'Deducted before the balance was paid over',
      badge: money(Math.abs(Number(line.total_recoveries))),
      columns: RECOVERY_COLUMNS,
      rows: recoveries.map((r): PrintRow => ({
        cells: {
          type: RECOVERY_LABELS[r.entry_type] ?? r.entry_type,
          description: r.description,
          amount: money(Math.abs(Number(r.amount))),
        },
      })),
    }]
    : [];

  const totals: PrintTotal[] = [
    { label: 'Amount earned', value: money(Number(line.amount_earned)) },
    ...(Number(line.total_recoveries)
      ? [{ label: 'Less recoveries', value: money(Math.abs(Number(line.total_recoveries))), negative: true }]
      : []),
    { label: 'Net payable', value: money(Number(line.net_amount)), grand: true },
  ];

  const posted = Number(header.posted) === 1;
  return {
    brand,
    title: header.document_type === 'FOSA' ? 'FOSA Interest Slip' : 'Dividend Slip',
    subtitle: `${header.description} — year ended ${formatDate(header.end_date)}`,
    watermark: posted ? null : header.status === 'Approved' ? 'Not yet posted' : 'Draft',
    status: posted
      ? { label: 'Posted', tone: 'ok' }
      : { label: header.status, tone: header.status === 'Approved' ? 'info' : 'warn' },
    parties: [{
      heading: 'Member',
      name: line.member_name,
      lines: [
        `Member No. ${line.member_no}`,
        `${line.product_name} — ${line.account_no}`,
        line.phone_no ?? '',
        line.deceased ? 'Estate of the late member' : '',
      ].filter(Boolean),
    }],
    meta: [
      { label: 'Dividend No.', value: header.no },
      { label: 'Year', value: String(header.dividend_year) },
      { label: 'Period', value: `${formatDate(header.start_date)} — ${formatDate(header.end_date)}` },
      { label: 'Book', value: header.document_type },
      { label: 'Basis', value: RATE_TYPE_LABELS[model] },
      { label: 'Rate', value: pct(line.rate) },
      { label: 'Closing Balance', value: money(Number(line.account_balance)) },
      { label: 'Posting Date', value: formatDate(header.posting_date) },
      ...(line.destination_account_no
        ? [{ label: 'Paid To', value: line.destination_account_no }]
        : [{ label: 'Paid To', value: 'Held on account' }]),
      { label: 'Net Payable', value: money(Number(line.net_amount)), strong: true },
    ],
    columns: WORKING_COLUMNS,
    rows,
    empty: 'No monthly working — this amount was uploaded rather than calculated.',
    sections,
    totals,
    amount_words: amountInWords(Number(line.net_amount), currencyLabel(brand.currency_code)),
    notes: [{ heading: 'How this was worked out', body: MODEL_NOTES[model] }],
    approvals: await documentSignatories('DIVIDEND', header.no, header.created_by, {
      raisedAt: header.created_at, clearedBy: header.posted_by ?? header.created_by,
    }),
    footnote: posted ? null : 'Provisional — this dividend has not yet been posted.',
  };
}
