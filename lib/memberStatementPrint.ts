/*
 * Member Statement printout — the statement of account rendered through the shared document
 * chrome in lib/documentPrint.ts, the same one behind the Sales Invoice and the Payment Voucher.
 *
 * The figures are lib/memberStatement.ts's: this module does no balance arithmetic of its own,
 * it only decides what goes on the paper. Each member becomes one PrintDocument:
 *
 *   letterhead  ->  member block + statement meta
 *   main table  ->  a summary line per savings account and per loan (opening, movement, closing)
 *   totals      ->  total deposits, total loans outstanding, net position
 *   sections    ->  one ledger per account and per loan, opening and closing carried in bold
 *
 * The member's own signature on file (the same scan the teller sees) prints beside the
 * preparer's, so the statement doubles as the attestation slip the old layout had at the foot.
 */
import { buildMemberStatements } from './memberStatement.ts';
import { formatDate, formatMoney, formatStatementTimestamp } from './format.ts';
import { imageSrc } from './cloudinary.ts';
import { signatureFor } from './userSignatures.ts';
import { printBrand, documentMoney } from './documentPrint.ts';
import type { PrintDocument, PrintColumn, PrintRow, PrintSection } from './documentPrint.ts';
import type { MemberStatementFilters, StatementAccountSection, StatementLoanSection } from './memberStatement.ts';
import type { Cents, MemberWithDimensions } from './types.ts';

/** Who pulled the statement — named and, where they have one on file, signed. */
export interface StatementPreparer {
  username: string;
  full_name: string;
}

const SUMMARY_COLUMNS: PrintColumn[] = [
  { key: 'no', label: 'Account / Loan No.', width: '18%' },
  { key: 'kind', label: 'Type', width: '13%' },
  { key: 'product', label: 'Product' },
  { key: 'opening', label: 'Opening', align: 'right', width: '15%' },
  { key: 'movement', label: 'Movement', align: 'right', width: '15%' },
  { key: 'closing', label: 'Closing', align: 'right', width: '15%' },
];

const LEDGER_COLUMNS: PrintColumn[] = [
  { key: 'date', label: 'Date', width: '11%' },
  { key: 'document', label: 'Document No.', width: '16%' },
  { key: 'description', label: 'Description' },
  { key: 'debit', label: 'Debit', align: 'right', width: '14%' },
  { key: 'credit', label: 'Credit', align: 'right', width: '14%' },
  { key: 'balance', label: 'Balance', align: 'right', width: '15%' },
];

/** Ledger columns carry no currency symbol — the period's figures repeat down six columns and
 *  the currency is already stated in the summary and the totals. */
const bare = (c: Cents): string => formatMoney(c, { showSymbol: false });

const memberName = (m: MemberWithDimensions): string =>
  [m.first_name, m.middle_name, m.last_name].filter(Boolean).join(' ');

/** "01 Jan 2026 — 31 Dec 2026", or the open-ended forms when only one end is filtered. */
function periodLabel(from?: string | null, to?: string | null): string {
  if (from && to) return `${formatDate(from)} — ${formatDate(to)}`;
  if (from) return `From ${formatDate(from)}`;
  if (to) return `Up to ${formatDate(to)}`;
  return 'All activity to date';
}

/**
 * One ledger section. A savings account and a loan share the layout and differ only in which
 * column a positive amount lands in: on an account a positive `amount` is a deposit (credit),
 * on a loan it is a disbursement or charge (debit) — see lib/memberStatement.ts.
 */
function ledgerSection(
  heading: string,
  sub: string,
  opening: Cents,
  closing: Cents,
  lines: (StatementAccountSection | StatementLoanSection)['lines'],
  positiveIsDebit: boolean,
  money: (c: number) => string,
): PrintSection {
  const rows: PrintRow[] = [
    {
      strong: true,
      cells: { date: '', document: '', description: 'Opening balance', debit: '', credit: '', balance: bare(opening) },
    },
    ...lines.map(({ txn: t, running }): PrintRow => ({
      cells: {
        date: formatDate(t.value_date),
        document: t.document_no || '—',
        description: `${t.description || ''}${t.status === 'REVERSED' ? '  (REVERSED)' : ''}`,
        debit: (positiveIsDebit ? t.amount > 0 : t.amount < 0) ? bare(Math.abs(t.amount)) : '',
        credit: (positiveIsDebit ? t.amount < 0 : t.amount > 0) ? bare(Math.abs(t.amount)) : '',
        balance: bare(running),
      },
    })),
    {
      strong: true,
      cells: { date: '', document: '', description: 'Closing balance', debit: '', credit: '', balance: bare(closing) },
    },
  ];
  return { heading, sub, badge: money(closing), columns: LEDGER_COLUMNS, rows };
}

/**
 * One PrintDocument per member, in the order requested — the print counterpart of
 * buildMemberStatements(), which it delegates every figure to.
 */
export async function buildMemberStatementPrints(
  filters: MemberStatementFilters,
  preparer: StatementPreparer,
): Promise<PrintDocument[]> {
  const [brand, docs, preparerSignature] = await Promise.all([
    printBrand(),
    buildMemberStatements(filters),
    signatureFor(preparer.username),
  ]);
  if (!brand) return [];
  const money = documentMoney(brand, brand.currency_code);
  const generatedAt = formatStatementTimestamp();
  const period = periodLabel(filters.from, filters.to);

  return docs.map(({ member, accounts: allAccounts, loans: allLoans }): PrintDocument => {
    // An account or loan with no entry in the period has nothing to state, so it is left off the
    // paper entirely — summary line, ledger and all. The Excel export (which goes straight to
    // buildMemberStatements()) still carries every one of them.
    const accounts = allAccounts.filter((a) => a.lines.length);
    const loans = allLoans.filter((l) => l.lines.length);

    const deposits = accounts.reduce((s, a) => s + a.closing, 0);
    const borrowings = loans.reduce((s, l) => s + l.closing, 0);

    const summary: PrintRow[] = [
      ...accounts.map((a): PrintRow => ({
        cells: {
          no: a.account.account_no,
          kind: 'Savings',
          product: a.account.product_name,
          opening: bare(a.opening),
          movement: bare(a.closing - a.opening),
          closing: bare(a.closing),
        },
      })),
      ...loans.map((l): PrintRow => ({
        cells: {
          no: l.loan.loan_no,
          kind: 'Loan',
          product: l.loan.product_name,
          opening: bare(l.opening),
          movement: bare(l.closing - l.opening),
          closing: bare(l.closing),
        },
      })),
    ];

    return {
      brand,
      title: 'Statement of Account',
      subtitle: period,
      status: { label: member.status, tone: member.status === 'ACTIVE' ? 'ok' : 'warn' },
      parties: [{
        heading: 'Statement for',
        name: memberName(member),
        lines: [
          `Member No. ${member.member_no}`,
          member.identification_no ? `ID No. ${member.identification_no}` : '',
          member.kra_pin ? `KRA PIN ${member.kra_pin}` : '',
          member.staff_no ? `Staff / Payroll No. ${member.staff_no}` : '',
          member.employer || '',
          member.phone || '',
          member.email || '',
        ].filter(Boolean),
      }],
      meta: [
        { label: 'Statement Period', value: period },
        { label: 'Generated On', value: generatedAt },
        { label: 'Generated By', value: preparer.full_name },
        { label: 'Accounts / Loans', value: `${accounts.length} / ${loans.length}` },
        { label: 'Total Deposits', value: money(deposits), strong: true },
        { label: 'Loans Outstanding', value: money(borrowings) },
      ],
      columns: SUMMARY_COLUMNS,
      rows: summary,
      empty: 'No account or loan activity in the selected period.',
      totals: [
        { label: 'Total deposits', value: money(deposits) },
        { label: 'Less: loans outstanding', value: money(borrowings), negative: true },
        { label: `Net position (${brand.currency_code})`, value: money(deposits - borrowings), grand: true },
      ],
      sections: [
        ...accounts.map((a) => ledgerSection(
          `${a.account.account_no} — ${a.account.product_name}`,
          'Savings account activity', a.opening, a.closing, a.lines, false, money,
        )),
        ...loans.map((l) => ledgerSection(
          `${l.loan.loan_no} — ${l.loan.product_name}`,
          'Loan account activity', l.opening, l.closing, l.lines, true, money,
        )),
      ],
      signatures: [
        { label: 'Prepared by', block: preparerSignature },
        {
          label: 'Member',
          block: {
            username: member.member_no,
            full_name: memberName(member),
            src: imageSrc(member.signature_image, { width: 180, height: 70, crop: 'fit' }),
          },
        },
        { label: 'For and on behalf of the Society', block: null },
      ],
      footnote: brand.footer
        || 'This statement is computer-generated. Please report any discrepancy within 30 days.',
    };
  });
}
