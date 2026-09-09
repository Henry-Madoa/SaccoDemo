/*
 * Loan Documents printouts — the Loan Application form, the Loan Appraisal and the Repayment
 * Schedule, rendered through the shared document chrome in lib/documentPrint.ts.
 *
 * Same split as lib/memberStatementPrint.ts: every figure comes from lib/loanDocuments.ts, which
 * the Excel exports also read, so the paper and the spreadsheet can never disagree. This module
 * only decides what goes on the page.
 */
import { formatDate, formatDateTime, formatMoney } from './format.ts';
import { imageSrc } from './cloudinary.ts';
import {
  buildLoanApplicationDocuments, buildLoanAppraisalDocuments, buildLoanScheduleDocuments,
} from './loanDocuments.ts';
import { printBrand, documentMoney } from './documentPrint.ts';
import type { PrintBrand, PrintDocument, PrintColumn, PrintRow, PrintSection } from './documentPrint.ts';
import type { LoanSelectionFilters } from './loanDocuments.ts';
import type { Cents, IsoDate, LoanFull, MemberWithDimensions } from './types.ts';

const bare = (c: Cents): string => formatMoney(c, { showSymbol: false });

const memberName = (m: { first_name: string; middle_name?: string | null; last_name: string }): string =>
  [m.first_name, m.middle_name, m.last_name].filter(Boolean).join(' ');

const sig = (url: string | null | undefined): string =>
  imageSrc(url, { width: 180, height: 70, crop: 'fit' }) ?? '';

/** The applicant block every loan document opens with. */
function applicantParty(loan: LoanFull, m: MemberWithDimensions, age: number | null) {
  return {
    heading: 'Applicant',
    name: memberName(m),
    lines: [
      `Member No. ${loan.member_no}`,
      m.identification_no ? `ID No. ${m.identification_no}` : '',
      age != null ? `Age ${age} years` : '',
      m.staff_no ? `Staff / Payroll No. ${m.staff_no}` : '',
      m.employer || '',
      m.phone || '',
      m.email || '',
    ].filter(Boolean),
  };
}

/* ------------------------------------------------------------------ Loan Application */

const GUARANTOR_COLUMNS: PrintColumn[] = [
  { key: 'member_no', label: 'Member No.', width: '13%' },
  { key: 'name', label: 'Name' },
  { key: 'phone', label: 'Phone', width: '14%' },
  { key: 'id_no', label: 'ID No.', width: '13%' },
  { key: 'amount', label: 'Guaranteed', align: 'right', width: '15%' },
  { key: 'signature', label: 'Signature', width: '17%', kind: 'signature' },
];

export async function buildLoanApplicationPrints(filters: LoanSelectionFilters): Promise<PrintDocument[]> {
  const [brand, docs] = await Promise.all([printBrand(), buildLoanApplicationDocuments(filters)]);
  if (!brand) return [];
  const money = documentMoney(brand, brand.currency_code);

  return docs.map(({ loan: l, applicant: m, age, disbursement, guarantors, amountInWords }): PrintDocument => ({
    brand,
    title: 'Loan Application',
    subtitle: `Loan ${l.loan_no}`,
    status: {
      label: l.status,
      tone: l.status === 'DISBURSED' ? 'ok' : l.status === 'WRITTEN OFF' ? 'bad' : 'info',
    },
    parties: [applicantParty(l, m, age)],
    meta: [
      { label: 'Loan No.', value: l.loan_no },
      { label: 'Applied On', value: formatDate(l.applied_date) },
      { label: 'Product', value: l.product_name },
      { label: 'Term', value: `${l.term_months} months` },
      { label: 'Interest', value: `${l.interest_rate}% ${l.interest_method.toLowerCase()}` },
      { label: 'Monthly Instalment', value: money(l.installment) },
      {
        label: 'Disburse To',
        value: disbursement ? `${disbursement.accountNo} — ${disbursement.productName}` : 'Cash / bank',
      },
      { label: 'Amount Applied For', value: money(l.principal), strong: true },
    ],
    columns: [
      { key: 'item', label: 'Particulars' },
      { key: 'detail', label: 'Detail', width: '32%' },
      { key: 'amount', label: 'Amount', align: 'right', width: '22%' },
    ],
    rows: [
      { cells: { item: 'Principal applied for', detail: l.product_name, amount: money(l.principal) } },
      { cells: { item: 'Total interest over the term', detail: `${l.interest_rate}% ${l.interest_method.toLowerCase()}`, amount: money(l.total_interest) } },
      { cells: { item: 'Monthly instalment', detail: `${l.term_months} months`, amount: money(l.installment) } },
      ...(l.purpose ? [{ muted: true, cells: { detail: `Purpose: ${l.purpose}` } }] : []),
    ],
    totals: [
      { label: 'Principal', value: money(l.principal) },
      { label: 'Interest', value: money(l.total_interest) },
      { label: 'Total repayable', value: money(l.principal + l.total_interest), grand: true },
    ],
    amount_words: amountInWords,
    sections: [{
      heading: 'Guarantors',
      sub: `${guarantors.length} committed`,
      badge: money(guarantors.reduce((s, g) => s + g.amount, 0)),
      columns: GUARANTOR_COLUMNS,
      empty: 'No guarantors committed to this application.',
      rows: guarantors.map((g): PrintRow => ({
        cells: {
          member_no: g.member_no,
          name: `${g.first_name} ${g.last_name}`,
          phone: g.phone || '—',
          id_no: g.identification_no || '—',
          amount: bare(g.amount),
          signature: sig(g.signature_image),
        },
      })),
    }],
    notes: [{
      heading: 'Declaration',
      body: 'I confirm that the information given above is true and complete, and I undertake to repay '
        + 'this loan on the terms stated, authorising the Society to recover any amount due from my '
        + 'deposits or from my guarantors should I default.',
    }],
    signatures: [
      {
        label: 'Applicant',
        block: { username: l.member_no, full_name: memberName(m), src: sig(m.signature_image) || null },
      },
      { label: 'Witnessed by', block: null },
      { label: 'For and on behalf of the Society', block: null },
    ],
  }));
}

/* -------------------------------------------------------------------- Loan Appraisal */

export async function buildLoanAppraisalPrints(filters: LoanSelectionFilters): Promise<PrintDocument[]> {
  const [brand, docs] = await Promise.all([printBrand(), buildLoanAppraisalDocuments(filters)]);
  if (!brand) return [];
  const money = documentMoney(brand, brand.currency_code);

  return docs.map((d): PrintDocument => {
    const { loan: l, applicant: m, age, appraisal, guarantors, collateral, existingLoans, charges, approvals } = d;
    const sections: PrintSection[] = [];

    if (appraisal) {
      sections.push({
        heading: 'Credit appraisal factors',
        sub: `Policy score ${appraisal.score}/100 — every factor is shown so the decision is explainable`,
        badge: appraisal.decision,
        columns: [
          { key: 'result', label: '', width: '7%', align: 'center' },
          { key: 'factor', label: 'Factor', width: '32%' },
          { key: 'detail', label: 'Assessment' },
        ],
        rows: appraisal.factors.map((f): PrintRow => ({
          cells: { result: f.pass ? 'PASS' : 'FAIL', factor: f.label, detail: f.detail ?? '' },
        })),
      });
    }

    sections.push({
      heading: 'Guarantor coverage',
      badge: money(guarantors.reduce((s, g) => s + g.amount, 0)),
      columns: [
        { key: 'member', label: 'Member' },
        { key: 'amount', label: 'Guaranteed', align: 'right', width: '20%' },
        { key: 'status', label: 'Status', width: '18%' },
      ],
      empty: 'No guarantors on this loan.',
      rows: guarantors.map((g): PrintRow => ({
        cells: {
          member: `${g.first_name} ${g.last_name} (${g.member_no})`,
          amount: bare(g.amount),
          status: g.status,
        },
      })),
    });

    sections.push({
      heading: 'Security coverage',
      badge: money(collateral.reduce((s, c) => s + c.guarantee, 0)),
      columns: [
        { key: 'no', label: 'Collateral No.', width: '18%' },
        { key: 'description', label: 'Description' },
        { key: 'cover', label: 'Cover', align: 'right', width: '20%' },
        { key: 'status', label: 'Status', width: '16%' },
      ],
      empty: 'No collateral attached to this loan.',
      rows: collateral.map((c): PrintRow => ({
        cells: {
          no: c.collateral_no,
          description: c.collateral_description || '—',
          cover: bare(c.guarantee),
          status: c.status,
        },
      })),
    });

    sections.push({
      heading: 'Existing loan exposure',
      sub: 'The member’s other disbursed loans',
      badge: money(existingLoans.reduce((s, x) => s + x.balance, 0)),
      columns: [
        { key: 'no', label: 'Loan No.', width: '13%' },
        { key: 'product', label: 'Product' },
        { key: 'disbursed', label: 'Disbursed', width: '13%' },
        { key: 'installment', label: 'Instalment', align: 'right', width: '13%' },
        { key: 'balance', label: 'Balance', align: 'right', width: '13%' },
        { key: 'arrears', label: 'Arrears', align: 'right', width: '13%' },
        { key: 'class', label: 'Class', width: '12%' },
      ],
      empty: 'No other disbursed loans.',
      rows: existingLoans.map((x): PrintRow => ({
        cells: {
          no: x.loan_no,
          product: x.product_name,
          disbursed: formatDate(x.disbursed_date),
          installment: bare(x.installment),
          balance: bare(x.balance),
          arrears: bare(x.arrears_amount),
          class: x.classification,
        },
      })),
    });

    sections.push({
      heading: 'Loan charges',
      badge: money(charges.reduce((s, c) => s + c.amount, 0)),
      columns: [
        { key: 'code', label: 'Code', width: '16%' },
        { key: 'description', label: 'Description' },
        { key: 'amount', label: 'Amount', align: 'right', width: '20%' },
      ],
      empty: 'No charges configured on this product.',
      rows: charges.map((c): PrintRow => ({
        cells: { code: c.chargeCode, description: c.chargeDescription, amount: bare(c.amount) },
      })),
    });

    // The approval trail, flattened the way the on-screen card shows it: each cleared level of a
    // group-sequence step first, then the step's own row.
    const approvalRows: PrintRow[] = approvals.flatMap((t) => [
      ...t.level_decisions.map((ld): PrintRow => ({
        muted: false,
        cells: {
          sender: '—',
          sent: '—',
          approver: `Level ${ld.sequence}: ${ld.decided_by}${ld.comment ? ` — “${ld.comment}”` : ''}`,
          decided: formatDateTime(ld.decided_at),
          status: 'CLEARED',
        },
      })),
      {
        cells: {
          sender: t.requested_by || '—',
          sent: formatDateTime(t.requested_at),
          approver: t.decided_by || t.pending_with || '—',
          decided: t.decided_at ? formatDateTime(t.decided_at) : '—',
          status: t.status,
        },
      },
    ]);
    sections.push({
      heading: 'Approval trail',
      sub: `${approvals.length} step${approvals.length === 1 ? '' : 's'} routed`,
      columns: [
        { key: 'sender', label: 'Sent by', width: '15%' },
        { key: 'sent', label: 'Sent', width: '17%' },
        { key: 'approver', label: 'Approver' },
        { key: 'decided', label: 'Decided', width: '17%' },
        { key: 'status', label: 'Status', width: '13%' },
      ],
      empty: 'Not yet sent for approval.',
      rows: approvalRows,
    });

    return {
      brand,
      title: 'Loan Appraisal',
      subtitle: `Loan ${l.loan_no} — ${l.product_name}`,
      status: appraisal
        ? { label: appraisal.decision, tone: appraisal.decision === 'ELIGIBLE' ? 'ok' : 'warn' }
        : { label: 'Not appraised', tone: 'warn' },
      parties: [applicantParty(l, m, age)],
      meta: [
        { label: 'Loan No.', value: l.loan_no },
        { label: 'Product', value: l.product_name },
        { label: 'Applied On', value: formatDate(l.applied_date) },
        { label: 'Term', value: `${l.term_months} months` },
        ...(appraisal
          ? [
            { label: 'Appraised By', value: appraisal.appraised_by || '—' },
            { label: 'Appraised On', value: formatDateTime(appraisal.appraised_at) },
            { label: 'Policy Score', value: `${appraisal.score} / 100` },
          ]
          : []),
        { label: 'Amount Applied For', value: money(l.principal), strong: true },
      ],
      // The affordability headline the appraisal card carries above its factor table.
      columns: [
        { key: 'metric', label: 'Affordability' },
        { key: 'value', label: 'Value', align: 'right', width: '25%' },
      ],
      rows: appraisal
        ? [
          { cells: { metric: 'Monthly instalment', value: money(appraisal.installment) } },
          { cells: { metric: 'Member deposits', value: money(appraisal.deposits) } },
          { cells: { metric: 'Deposit ceiling (multiplier)', value: money(appraisal.max_by_multiplier) } },
          { cells: { metric: 'Existing exposure', value: money(appraisal.exposure) } },
          { cells: { metric: 'Monthly obligations', value: money(appraisal.monthly_obligations) } },
          { cells: { metric: 'Deduction ratio (DSR)', value: `${appraisal.dsr}%` } },
        ]
        : [],
      empty: 'This loan has not been appraised yet.',
      totals: [],
      sections,
      signatures: [
        { label: 'Appraised by', block: null },
        { label: 'Recommended by', block: null },
        { label: 'Approved by', block: null },
      ],
    };
  });
}

/* ------------------------------------------------------------ Loan Repayment Schedule */

const SCHEDULE_COLUMNS: PrintColumn[] = [
  { key: 'no', label: '#', align: 'right', width: '5%' },
  { key: 'due', label: 'Due Date', width: '12%' },
  { key: 'opening', label: 'Opening', align: 'right', width: '13%' },
  { key: 'principal', label: 'Principal', align: 'right', width: '12%' },
  { key: 'interest', label: 'Interest', align: 'right', width: '12%' },
  { key: 'instalment', label: 'Instalment', align: 'right', width: '13%' },
  { key: 'paid', label: 'Paid', align: 'right', width: '12%' },
  { key: 'balance', label: 'Balance', align: 'right', width: '13%' },
  { key: 'status', label: 'Status', width: '10%' },
];

export async function buildLoanSchedulePrints(
  filters: LoanSelectionFilters & { expFrom?: IsoDate | null; expTo?: IsoDate | null },
): Promise<PrintDocument[]> {
  const [brand, docs] = await Promise.all([printBrand(), buildLoanScheduleDocuments(filters)]);
  if (!brand) return [];
  const money = documentMoney(brand, brand.currency_code);

  return docs.map(({ loan: l, rows, totals }): PrintDocument => ({
    brand,
    title: 'Repayment Schedule',
    subtitle: `Loan ${l.loan_no} — ${l.product_name}`,
    status: { label: l.status, tone: l.status === 'DISBURSED' ? 'ok' : 'info' },
    parties: [{
      heading: 'Borrower',
      name: `${l.first_name} ${l.last_name}`,
      lines: [`Member No. ${l.member_no}`, `Loan No. ${l.loan_no}`, l.product_name],
    }],
    meta: [
      { label: 'Principal Disbursed', value: money(l.principal) },
      { label: 'Disbursed On', value: formatDate(l.disbursed_date) },
      { label: 'Term', value: `${l.term_months} months` },
      { label: 'Interest', value: `${l.interest_rate}% ${l.interest_method.toLowerCase()}` },
      { label: 'Monthly Instalment', value: money(l.installment) },
      { label: 'Instalments Shown', value: String(rows.length) },
      { label: 'Outstanding', value: money(totals.outstanding), strong: true },
    ],
    columns: SCHEDULE_COLUMNS,
    empty: 'No instalments in the selected window — the schedule is generated on disbursement.',
    rows: [
      ...rows.map((r): PrintRow => ({
        cells: {
          no: String(r.installment_no),
          due: formatDate(r.due_date),
          opening: bare(r.opening_balance),
          principal: bare(r.principal_due),
          interest: bare(r.interest_due),
          instalment: bare(r.principal_due + r.interest_due),
          paid: bare(r.principal_paid + r.interest_paid),
          balance: bare(r.closingBalance),
          status: r.status,
        },
      })),
      ...(rows.length
        ? [{
          strong: true,
          cells: {
            no: '', due: 'Totals', opening: '',
            principal: bare(totals.principal),
            interest: bare(totals.interest),
            instalment: bare(totals.instalment),
            paid: bare(totals.paid),
            balance: bare(totals.outstanding),
            status: '',
          },
        } satisfies PrintRow]
        : []),
    ],
    totals: [
      { label: 'Principal', value: money(totals.principal) },
      { label: 'Interest', value: money(totals.interest) },
      { label: 'Less: paid to date', value: money(totals.paid), negative: true },
      { label: 'Outstanding', value: money(totals.outstanding), grand: true },
    ],
    signatures: [
      { label: 'Prepared by', block: null },
      { label: 'Borrower acknowledgement', block: null },
    ],
    footnote: scheduleFootnote(brand),
  }));
}

const scheduleFootnote = (brand: PrintBrand): string =>
  brand.footer || 'Instalments shown are as scheduled; interest accrued after the last posting date is not included.';
