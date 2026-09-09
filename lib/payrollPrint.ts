/*
 * Payroll printouts — the employee Payslip and the annual P9 tax-deduction card, rendered
 * through the shared document chrome in lib/documentPrint.ts.
 *
 * Both delegate every figure to lib/payroll.ts (getPayslip / getP9Annual), which the payroll
 * period reports read too, so the payslip, the P9 and the period report can never disagree.
 */
import { getPayslip, getP9Annual } from './payroll.ts';
import { formatDate, formatMoney } from './format.ts';
import { amountInWords } from './numberToWords.ts';
import { printBrand, documentMoney, currencyLabel, renderDocument } from './documentPrint.ts';
import type { PrintDocument, PrintColumn, PrintRow, PrintSection } from './documentPrint.ts';
import type { Cents } from './types.ts';

export { renderDocument };

const bare = (c: Cents): string => formatMoney(c, { showSymbol: false });

/** The payslip's sections, in the order a payslip reads: what was earned, then what was taken. */
const SECTION_LABELS: Record<string, string> = {
  BASIC: 'Basic Pay',
  ALLOWANCE: 'Allowances',
  STATUTORY: 'Statutory Deductions',
  DEDUCTION: 'Other Deductions',
  EMPLOYER: 'Employer Contributions',
  NET: 'Net Pay',
};
const SECTION_ORDER = ['BASIC', 'ALLOWANCE', 'STATUTORY', 'DEDUCTION', 'EMPLOYER', 'NET'];

const LINE_COLUMNS: PrintColumn[] = [
  { key: 'code', label: 'Code', width: '18%' },
  { key: 'name', label: 'Description' },
  { key: 'amount', label: 'Amount', align: 'right', width: '25%' },
];

/* ------------------------------------------------------------------------- Payslip */

export async function buildPayslipDocument(periodId: number, employeeId: number): Promise<PrintDocument | null> {
  const [brand, slip] = await Promise.all([printBrand(), getPayslip(periodId, employeeId)]);
  if (!brand) return null;
  const money = documentMoney(brand, brand.currency_code);
  const { employee, period, lines, p9 } = slip;

  const bySection = new Map<string, typeof lines>();
  for (const l of lines) {
    if (!bySection.has(l.section)) bySection.set(l.section, []);
    bySection.get(l.section)!.push(l);
  }

  // The summary the payslip leads with is the P9 line for the period; the per-code detail
  // follows underneath, one section per pay element group.
  const sections: PrintSection[] = SECTION_ORDER.filter((s) => bySection.has(s)).map((section) => {
    const rows = bySection.get(section)!;
    return {
      heading: SECTION_LABELS[section] || section,
      badge: money(rows.reduce((s, l) => s + l.amountCents, 0)),
      columns: LINE_COLUMNS,
      rows: rows.map((l): PrintRow => ({
        cells: { code: l.code, name: l.name, amount: bare(l.amountCents) },
      })),
    };
  });

  return {
    brand,
    title: 'Payslip',
    subtitle: period.period_name,
    status: {
      label: period.status,
      tone: period.status === 'CLOSED' || period.status === 'APPROVED' ? 'ok' : 'info',
    },
    parties: [{
      heading: 'Employee',
      name: `${employee.first_name} ${employee.last_name}`,
      lines: [
        `Employee No. ${employee.employee_no}`,
        employee.job_title || '',
      ].filter(Boolean),
    }],
    meta: [
      { label: 'Pay Period', value: period.period_name },
      { label: 'Period Start', value: formatDate(period.start_date) },
      { label: 'Period End', value: formatDate(period.end_date) },
      ...(p9 ? [{ label: 'Gross Pay', value: money(p9.gross_pay_cents) }] : []),
      ...(p9 ? [{ label: 'Net Pay', value: money(p9.net_pay_cents), strong: true }] : []),
    ],
    columns: [
      { key: 'item', label: 'Summary' },
      { key: 'amount', label: 'Amount', align: 'right', width: '28%' },
    ],
    empty: 'This employee was not processed in the selected period.',
    rows: p9
      ? [
        { cells: { item: 'Gross pay', amount: money(p9.gross_pay_cents) } },
        { cells: { item: 'Taxable pay', amount: money(p9.taxable_pay_cents) } },
        { cells: { item: 'PAYE', amount: money(p9.paye_cents) } },
        { cells: { item: 'NSSF', amount: money(p9.nssf_cents) } },
        { cells: { item: 'SHIF', amount: money(p9.shif_cents) } },
        { cells: { item: 'Housing Levy', amount: money(p9.housing_levy_cents) } },
        { cells: { item: 'Other deductions', amount: money(p9.deductions_cents) } },
      ]
      : [],
    totals: p9
      ? [
        { label: 'Gross pay', value: money(p9.gross_pay_cents) },
        {
          label: 'Less: total deductions',
          value: money(p9.gross_pay_cents - p9.net_pay_cents),
          negative: true,
        },
        { label: `Net pay (${brand.currency_code})`, value: money(p9.net_pay_cents), grand: true },
      ]
      : [],
    amount_words: p9 ? amountInWords(p9.net_pay_cents, currencyLabel(brand.currency_code)) : null,
    sections,
    signatures: [
      { label: 'Prepared by', block: null },
      { label: 'Employee', block: null },
    ],
    footnote: brand.footer || 'This payslip is computer-generated and does not require a signature.',
  };
}

/* ----------------------------------------------------------------------------- P9 */

const P9_COLUMNS: PrintColumn[] = [
  { key: 'period', label: 'Period', width: '14%' },
  { key: 'gross', label: 'Gross Pay', align: 'right' },
  { key: 'taxable', label: 'Taxable Pay', align: 'right' },
  { key: 'nssf', label: 'NSSF', align: 'right' },
  { key: 'shif', label: 'SHIF', align: 'right' },
  { key: 'relief', label: 'Personal Relief', align: 'right' },
  { key: 'ins', label: 'Insurance Relief', align: 'right' },
  { key: 'paye', label: 'PAYE', align: 'right' },
  { key: 'net', label: 'Net Pay', align: 'right' },
];

export async function buildP9Document(employeeId: number, year: string): Promise<PrintDocument | null> {
  const [brand, p9] = await Promise.all([printBrand(), getP9Annual(employeeId, year)]);
  if (!brand) return null;
  const money = documentMoney(brand, brand.currency_code);
  const { employee, rows, totals } = p9;

  return {
    brand,
    title: 'P9 Tax Deduction Card',
    subtitle: `Tax year ${year}`,
    landscape: true,
    parties: [{
      heading: 'Employee',
      name: `${employee.first_name} ${employee.last_name}`,
      lines: [
        `Employee No. ${employee.employee_no}`,
        employee.kra_pin ? `KRA PIN ${employee.kra_pin}` : '',
      ].filter(Boolean),
    }],
    meta: [
      { label: 'Tax Year', value: year },
      { label: 'Periods Processed', value: String(rows.length) },
      { label: 'Total Gross Pay', value: money(totals.grossCents) },
      { label: 'Total PAYE', value: money(totals.payeCents), strong: true },
    ],
    columns: P9_COLUMNS,
    empty: `No payroll runs found for ${year}.`,
    rows: [
      ...rows.map((r): PrintRow => ({
        cells: {
          period: r.periodName,
          gross: bare(r.grossCents),
          taxable: bare(r.taxableCents),
          nssf: bare(r.nssfCents),
          shif: bare(r.shifCents),
          relief: bare(r.personalReliefCents),
          ins: bare(r.insuranceReliefCents),
          paye: bare(r.payeCents),
          net: bare(r.netCents),
        },
      })),
      ...(rows.length
        ? [{
          strong: true,
          cells: {
            period: 'Total',
            gross: bare(totals.grossCents),
            taxable: bare(totals.taxableCents),
            nssf: bare(totals.nssfCents),
            shif: bare(totals.shifCents),
            relief: bare(totals.personalReliefCents),
            ins: bare(totals.insuranceReliefCents),
            paye: bare(totals.payeCents),
            net: bare(totals.netCents),
          },
        } satisfies PrintRow]
        : []),
    ],
    totals: [
      { label: 'Total taxable pay', value: money(totals.taxableCents) },
      { label: 'Total relief', value: money(totals.personalReliefCents + totals.insuranceReliefCents), negative: true },
      { label: `Total PAYE (${brand.currency_code})`, value: money(totals.payeCents), grand: true },
    ],
    signatures: [
      { label: 'Employer', block: null },
      { label: 'Official stamp', block: null },
    ],
    footnote: 'Issued under the Income Tax Act. Figures are as processed in the payroll periods '
      + 'shown above.',
  };
}
