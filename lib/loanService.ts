/*
 * Loan origination, appraisal, approval, disbursement and repayment.
 * Per section 11 of the design: the loan module raises business events and the
 * posting engine writes the money. Loan balances are derived from those events.
 */
import {
  one, all, run, tx, nextSequence, audit, hasAnyRow,
} from './db.ts';
import { postJournal } from './accounting.ts';
import { PostingError } from './errors.ts';
import { resolvePostingDate } from './postingDates.ts';
import {
  buildSchedule, allocateRepayment, repaymentStartDate, daysBetween, classify, calculateLoanProductCharges, addMonths,
} from './loans.ts';
import { CHANNEL_GL } from './savings.ts';
import { assertMemberNotDormant } from './memberDormancy.ts';
import { findMatchingWorkflow, startWorkflow } from './workflow.ts';
import { listLoanCollateral } from './loanCollateral.ts';
import { listLoanProductCharges } from './loanProductCharges.ts';
import { ensureSalaryAppraisalLines, computeSalaryTotals, listLoanSalaryAppraisalLines } from './salaryAppraisal.ts';
import { guarantorCapacity, selfGuaranteeCapacity } from './guarantors.ts';
import { assertSectorSelection } from './economicSectors.ts';
import { buildFilterClause, type FilterCondition, type FilterFieldDef } from './listFilters.ts';
import { buildOrderClause, type SortState } from './listSort.ts';
import { LOAN_STATUSES, INTEREST_METHODS } from './constants.ts';
import type {
  Actor, Appraisal, AppraisalFactor, CalculatedLoanCharge, Cents, Channel, GuarantorRow, IsoDate,
  JournalLineInput, LoanAppraisalFactorRow, LoanAppraisalRow, LoanDetail, LoanFull, LoanListRow,
  LoanProduct, LoanRecoveryMode, LoanScheduleRow, Member, PayMode, SavingsAccount, Txn, TxnWithDocument,
} from './types.ts';

/** How CASH/MPESA/BANK/EFT/CHEQUE map onto the legacy `channel` column still used for
 *  reporting/filtering elsewhere — the Bank/Cashbook account picked (Payment Channel) is what
 *  actually decides the G/L posting now; this only keeps `txn.channel` populated sensibly for
 *  a manual external disbursement/repayment. */
const CHANNEL_FOR_PAY_MODE: Record<PayMode, Channel> = {
  CASH: 'TELLER', MPESA: 'MPESA', BANK: 'BANK', EFT: 'BANK', CHEQUE: 'BANK',
};

const today = (): IsoDate => new Date().toISOString().slice(0, 10);

export function getLoan(id: number): Promise<LoanFull | undefined> {
  return one<LoanFull>(
    `SELECT l.*, p.name AS product_name, p.code AS product_code,
            p.gl_receivable_id, p.gl_interest_income_id, p.gl_penalty_income_id, p.salary_based,
            p.min_salary_count, p.salary_appraisal_type,
            m.member_no, m.first_name, m.last_name,
            es.name AS sector_name, ess.name AS sub_sector_name, esss.description AS sub_subsector_name
     FROM loan l JOIN loan_product p ON p.id = l.product_id
     JOIN member m ON m.id = l.member_id
     LEFT JOIN economic_sector es ON es.code = l.sector_code
     LEFT JOIN economic_subsector ess ON ess.sector_code = l.sector_code AND ess.code = l.sub_sector_code
     LEFT JOIN economic_subsubsector esss ON esss.sector_code = l.sector_code AND esss.subsector_code = l.sub_sector_code AND esss.code = l.sub_subsector_code
     WHERE l.id = ?`,
    id,
  );
}

/** The Loans list's tab keys, and the status each pins down — "all" contributes no filter.
 *  Shared between the list page's tab links and the detail card's Previous/Next, so paging
 *  through a tab never steps outside the status it was opened from. */
export const LOAN_TAB_STATUS: Record<string, string | undefined> = {
  all: undefined,
  open: 'OPEN',
  pending: 'PENDING APPROVAL',
  approved: 'APPROVED',
  disbursed: 'DISBURSED',
  closed: 'CLOSED',
  'written-off': 'WRITTEN OFF',
  archived: 'ARCHIVED',
};

/** Whether the current Status tab has any loans at all, ignoring search and dynamic filters —
 *  lets the page grey out its filter controls only when there's truly nothing to filter. */
export const hasAnyLoans = (status?: string): Promise<boolean> =>
  hasAnyRow('loan l', status ? 'l.status = ?' : undefined, ...(status ? [status] : []));

/** The loan immediately before/after this one by id — for the card's Business-Central-style
 *  Previous/Next navigation. Scoped to `status` (a LOAN_TAB_STATUS value) when given, so paging
 *  never steps outside the tab the record was opened from. */
export async function getAdjacentLoanIds(
  id: number, status?: string,
): Promise<{ prevId: number | null; nextId: number | null }> {
  const clause = status ? 'AND status = ?' : '';
  const prevArgs = status ? [id, status] : [id];
  const nextArgs = status ? [id, status] : [id];
  const [prev, next] = await Promise.all([
    one<{ id: number }>(`SELECT id FROM loan WHERE id < ? ${clause} ORDER BY id DESC LIMIT 1`, ...prevArgs),
    one<{ id: number }>(`SELECT id FROM loan WHERE id > ? ${clause} ORDER BY id ASC LIMIT 1`, ...nextArgs),
  ]);
  return { prevId: prev?.id ?? null, nextId: next?.id ?? null };
}

/** Loans list's dynamic-filter registry — every meaningful column. product_id ships without
 *  `options` since it's DB-driven; the page fills it in from listActiveLoanProducts(), which
 *  it already fetches. Excludes purely internal columns (id, member_id — redundant with the
 *  free-text search, disburse_to_account_id, version — an optimistic-lock counter). */
export const LOAN_FILTER_FIELDS: FilterFieldDef[] = [
  { key: 'loan_no', label: 'Loan No.', type: 'text', column: 'l.loan_no' },
  { key: 'product_id', label: 'Product', type: 'select', column: 'l.product_id' },
  { key: 'interest_rate', label: 'Interest Rate', type: 'number', column: 'l.interest_rate' },
  { key: 'interest_method', label: 'Interest Method', type: 'select', column: 'l.interest_method', options: INTEREST_METHODS.map((m) => ({ value: m, label: m })) },
  { key: 'term_months', label: 'Term (Months)', type: 'number', column: 'l.term_months' },
  { key: 'purpose', label: 'Purpose', type: 'text', column: 'l.purpose' },
  { key: 'status', label: 'Status', type: 'select', column: 'l.status', options: LOAN_STATUSES.map((s) => ({ value: s, label: s })) },
  { key: 'applied_date', label: 'Applied Date', type: 'date', column: 'l.applied_date' },
  { key: 'approved_date', label: 'Approved Date', type: 'date', column: 'l.approved_date' },
  { key: 'approved_by', label: 'Approved By', type: 'text', column: 'l.approved_by' },
  { key: 'rejected_reason', label: 'Rejected Reason', type: 'text', column: 'l.rejected_reason' },
  { key: 'disbursed_date', label: 'Disbursed Date', type: 'date', column: 'l.disbursed_date' },
  { key: 'first_due_date', label: 'First Due Date', type: 'date', column: 'l.first_due_date' },
  { key: 'principal', label: 'Principal', type: 'number', column: 'l.principal' },
  { key: 'installment', label: 'Instalment', type: 'number', column: 'l.installment' },
  { key: 'total_interest', label: 'Total Interest', type: 'number', column: 'l.total_interest' },
  { key: 'fees_charged', label: 'Fees Charged', type: 'number', column: 'l.fees_charged' },
  { key: 'principal_balance', label: 'Principal Balance', type: 'number', column: 'l.principal_balance' },
  { key: 'interest_balance', label: 'Interest Balance', type: 'number', column: 'l.interest_balance' },
  { key: 'penalty_balance', label: 'Penalty Balance', type: 'number', column: 'l.penalty_balance' },
  { key: 'principal_paid', label: 'Principal Paid', type: 'number', column: 'l.principal_paid' },
  { key: 'interest_paid', label: 'Interest Paid', type: 'number', column: 'l.interest_paid' },
  { key: 'arrears_amount', label: 'Arrears', type: 'number', column: 'l.arrears_amount' },
  { key: 'days_in_arrears', label: 'Days in Arrears', type: 'number', column: 'l.days_in_arrears' },
  {
    key: 'classification', label: 'Classification', type: 'select', column: 'l.classification',
    options: ['PERFORMING', 'WATCH', 'SUBSTANDARD', 'DOUBTFUL', 'LOSS'].map((c) => ({ value: c, label: c })),
  },
  { key: 'created_by', label: 'Created By', type: 'text', column: 'l.created_by' },
];

/** Loans list's sortable columns — every column shown in the table. */
const LOAN_SORT_COLUMNS: Record<string, string> = {
  loan_no: 'l.loan_no',
  member: 'm.first_name',
  product_name: 'p.name',
  principal: 'l.principal',
  outstanding: '(l.principal_balance + l.interest_balance)',
  installment: 'l.installment',
  arrears_amount: 'l.arrears_amount',
  status: 'l.status',
  classification: 'l.classification',
};

/** Loans matching a free-text search, further narrowed by any dynamic filter conditions. */
export function listLoans(
  { search = '', filters = [], sort = null }: { search?: string; filters?: FilterCondition[]; sort?: SortState | null } = {},
): Promise<LoanListRow[]> {
  const { clause, params } = buildFilterClause(LOAN_FILTER_FIELDS, filters);
  const orderBy = buildOrderClause(LOAN_SORT_COLUMNS, sort, 'l.id DESC');
  return all<LoanListRow>(
    `SELECT l.*, p.name AS product_name, p.code AS product_code,
            m.member_no, m.first_name, m.last_name
     FROM loan l JOIN loan_product p ON p.id = l.product_id JOIN member m ON m.id = l.member_id
     WHERE (l.loan_no LIKE @like OR m.member_no LIKE @like OR m.first_name LIKE @like OR m.last_name LIKE @like)
       ${clause}
     ${orderBy} LIMIT 300`,
    { like: `%${String(search).trim()}%`, ...params },
  );
}

/** Every loan_appraisal run on record for a loan, newest first, each with its factor
 *  breakdown attached — the Appraisal tab's history and the printable Appraisal Report both
 *  read this. */
export async function listLoanAppraisals(loanId: number): Promise<LoanAppraisalRow[]> {
  const [appraisals, factors] = await Promise.all([
    all<Omit<LoanAppraisalRow, 'factors'>>(
      'SELECT * FROM loan_appraisal WHERE loan_id = ? ORDER BY id DESC', loanId,
    ),
    all<LoanAppraisalFactorRow & { appraisal_id: number }>(
      `SELECT f.* FROM loan_appraisal_factor f
       JOIN loan_appraisal a ON a.id = f.appraisal_id
       WHERE a.loan_id = ? ORDER BY f.appraisal_id, f.seq`,
      loanId,
    ),
  ]);
  return appraisals.map((a) => ({ ...a, factors: factors.filter((f) => f.appraisal_id === a.id) }));
}

export async function getLoanDetail(id: number): Promise<LoanDetail | null> {
  const loan = await getLoan(id);
  if (!loan) return null;
  const [schedule, guarantors, collateral, transactions, appraisals] = await Promise.all([
    all<LoanScheduleRow>('SELECT * FROM loan_schedule WHERE loan_id = ? ORDER BY installment_no', id),
    all<GuarantorRow>(
      `SELECT g.*, m.member_no, m.first_name, m.last_name
       FROM loan_guarantor g JOIN member m ON m.id = g.member_id
       WHERE g.loan_id = ? AND g.status = 'COMMITTED'`,
      id,
    ),
    listLoanCollateral(id),
    all<TxnWithDocument>(
      `SELECT t.*, j.reference AS document_no,
              gd1.code AS global_dimension_1_code, gd2.code AS global_dimension_2_code,
              ba.code AS bank_account_code, ba.name AS bank_account_name
       FROM txn t
       LEFT JOIN journal j ON j.id = t.journal_id
       LEFT JOIN global_dimension_1_value gd1 ON gd1.id = j.global_dimension_1_id
       LEFT JOIN global_dimension_2_value gd2 ON gd2.id = j.global_dimension_2_id
       LEFT JOIN bank_account ba ON ba.id = t.bank_account_id
       WHERE t.loan_id = ? ORDER BY t.id DESC`,
      id,
    ),
    listLoanAppraisals(id),
  ]);
  return { loan, schedule, guarantors, collateral, transactions, appraisals };
}

/** Deposits that count toward the loan multiplier. */
export async function loanableDeposits(memberId: number): Promise<Cents> {
  return (await one<{ s: Cents }>(
    `SELECT COALESCE(SUM(sa.balance),0) s FROM savings_account sa
     JOIN savings_product p ON p.id = sa.product_id
     WHERE sa.member_id = ? AND p.is_loanable_base = 1 AND sa.status <> 'CLOSED'`,
    memberId,
  ))!.s;
}

export async function existingExposure(memberId: number): Promise<Cents> {
  return (await one<{ s: Cents }>(
    `SELECT COALESCE(SUM(principal_balance + interest_balance + penalty_balance),0) s
     FROM loan WHERE member_id = ? AND status = 'DISBURSED'`,
    memberId,
  ))!.s;
}

async function monthlyObligations(memberId: number): Promise<Cents> {
  return (await one<{ s: Cents }>(
    "SELECT COALESCE(SUM(installment),0) s FROM loan WHERE member_id = ? AND status = 'DISBURSED'",
    memberId,
  ))!.s;
}

export interface ProcessedSalarySummary {
  count: number;
  base: Cents;
  windowMonths: number;
  sufficient: boolean;
}

/** A salary-based product's AFFORDABILITY source: the member's own actually-processed payroll,
 *  not a typed-in mimic of it — one row per SALARY-type Checkoff & Salary Processing batch this
 *  member was paid through (see lib/checkoffBatches.ts), `Processed` only. Ported from AL's
 *  AppraiseFosaSalary: looks back `minSalaryCount` months (at least 1), reduces whatever it finds
 *  to a single base figure per `appraisalType`, and is `sufficient` only once at least
 *  `minSalaryCount` distinct months are on file — an unmet minimum fails the factor outright
 *  rather than quietly averaging over too little history. */
export async function processedSalarySummary(
  memberId: number, minSalaryCount: number, appraisalType: 'AVERAGE_NET' | 'LOWEST_NET',
): Promise<ProcessedSalarySummary> {
  const windowMonths = Math.max(minSalaryCount, 1);
  // Normalized to the 1st of that month (matching AL's DMY2Date(1, ...) call on the same
  // CalcDate('-%1M', ...) result) — otherwise a lookback anchored on today's day-of-month would
  // clip out an otherwise-in-window batch whose period falls earlier in that same calendar month.
  const since = `${addMonths(today(), -windowMonths).slice(0, 7)}-01`;
  const rows = await all<{ remitted_amount: number }>(
    `SELECT l.remitted_amount
     FROM checkoff_batch_line l JOIN checkoff_batch b ON b.no = l.batch_no
     WHERE l.member_id = ? AND b.batch_type = 'SALARY' AND b.status = 'Processed'
       AND b.period >= ? AND l.remitted_amount > 0
     ORDER BY b.period`,
    memberId, since,
  );
  const count = rows.length;
  const base = count === 0 ? 0
    : appraisalType === 'LOWEST_NET' ? Math.min(...rows.map((r) => r.remitted_amount))
    : Math.round(rows.reduce((s, r) => s + r.remitted_amount, 0) / count);
  return { count, base, windowMonths, sufficient: count > 0 && count >= minSalaryCount };
}

export interface AppraiseInput {
  memberId: number;
  productId: number;
  principal: Cents;
  termMonths: number;
  /** When appraising an already-captured loan, its committed guarantors and attached
   *  collateral count toward the SECURITY_COVER factor below. Omitted for the ephemeral
   *  pre-save preview in the New Application modal, before a loan_id exists to read either
   *  from — the factor then falls back to self-guarantee (deposits) alone. */
  loanId?: number;
}

/** Committed guarantee amounts + attached collateral cover on file for a loan — the "from
 *  other members" and "through collateral" halves of the SECURITY_COVER factor below. */
async function committedSecurity(loanId: number): Promise<{ guarantors: Cents; collateral: Cents }> {
  const [g, c] = await Promise.all([
    one<{ s: Cents }>("SELECT COALESCE(SUM(amount),0) s FROM loan_guarantor WHERE loan_id = ? AND status = 'COMMITTED'", loanId),
    one<{ s: Cents }>("SELECT COALESCE(SUM(guarantee),0) s FROM loan_collateral WHERE loan_id = ? AND status = 'ACTIVE'", loanId),
  ]);
  return { guarantors: g!.s, collateral: c!.s };
}

/** Credit appraisal — returns an explainable decision with individual factor results. */
export async function appraise({ memberId, productId, principal, termMonths, loanId }: AppraiseInput): Promise<Appraisal> {
  const [member, product, deposits, exposure, obligations, security] = await Promise.all([
    one<Member>('SELECT * FROM member WHERE id = ?', memberId),
    one<LoanProduct>('SELECT * FROM loan_product WHERE id = ?', productId),
    loanableDeposits(memberId),
    existingExposure(memberId),
    monthlyObligations(memberId),
    loanId ? committedSecurity(loanId) : Promise.resolve({ guarantors: 0, collateral: 0 }),
  ]);
  if (!member) throw new PostingError('Member not found', 'MEMBER_NOT_FOUND');
  if (!product) throw new PostingError('Loan product not found', 'PRODUCT_NOT_FOUND');

  const maxByMultiplier = Math.round(deposits * product.deposit_multiplier);
  const monthsAsMember = member.join_date
    ? Math.floor(daysBetween(member.join_date, today()) / 30.44)
    : 0;
  const { installment } = buildSchedule(
    Math.max(principal, 1), product.interest_rate, Math.max(termMonths, 1), product.interest_method, today(),
  );

  // AFFORDABILITY's income source depends entirely on the product: a salary_based product is
  // checked against the member's actually-processed payroll (processedSalarySummary, below —
  // available even pre-save, since it needs only memberId, not a loanId to attach lines to); any
  // other product is checked against the loan card's itemised Salary Appraisal section, the only
  // source of affordability data now that members no longer carry a static gross_income/
  // other_deductions pair — every such product auto-seeds it (lib/salaryAppraisal.ts's
  // ensureSalaryAppraisalLines, called from apply()/update() below), so it's on file as soon as
  // the loan itself exists. Pre-save (the New Application modal preview, no loanId yet) there is
  // nothing to read it off yet — AFFORDABILITY is reported as not-yet-known rather than guessed at.
  const processedSalary = product.salary_based
    ? await processedSalarySummary(memberId, product.min_salary_count, product.salary_appraisal_type)
    : null;
  const salaryLines = !product.salary_based && loanId ? await listLoanSalaryAppraisalLines(loanId) : [];
  const salaryTotals = salaryLines.length ? computeSalaryTotals(salaryLines) : null;
  // salaryTotals.totalDeductions already includes the member's other loans (auto-derived
  // LOAN_DEDUCTION lines) alongside PAYE/NHIF/etc — folding in `obligations` on top of it would
  // double-count those same obligations. Processed-salary history carries no such derived lines,
  // so that path always adds `obligations` explicitly.
  const totalDeductions = product.salary_based
    ? obligations + installment
    : salaryTotals ? salaryTotals.totalDeductions + installment : obligations + installment;
  const baseIncome = product.salary_based ? (processedSalary?.base ?? 0) : (salaryTotals?.gross ?? 0);
  const dsr = baseIncome > 0 ? (totalDeductions / baseIncome) * 100 : 999;

  // Fully secured = self-guarantee (the applicant's own deposits, run through the Self Guarantor
  // Multiplier — lib/guarantors.ts's selfGuaranteeCapacity, mirroring AL's
  // GetSelfGuaranteeEligibility) plus whatever other members have committed as guarantors plus
  // whatever collateral is attached — section 6/7's guarantee and security-management rules
  // narrowed to a single pass/fail cover check. Pre-save (no loanId yet) only self-guarantee is
  // known; guarantors/collateral read as zero until the officer attaches them and re-runs the
  // appraisal against the saved loan.
  const selfGuarantee = Math.min(await selfGuaranteeCapacity(memberId), principal);
  const securityCover = selfGuarantee + security.guarantors + security.collateral;

  const factors: AppraisalFactor[] = [
    { code: 'MEMBER_STATUS', label: 'Member in good standing', pass: member.status === 'ACTIVE',
      detail: `Status is ${member.status}` },
    { code: 'KYC', label: 'KYC verified', pass: !!member.kyc_verified,
      detail: member.kyc_verified ? 'Documents verified' : 'KYC not yet verified' },
    { code: 'MEMBERSHIP_PERIOD', label: `Minimum ${product.min_membership_months} months membership`,
      pass: monthsAsMember >= product.min_membership_months, detail: `${monthsAsMember} months as a member` },
    { code: 'PRODUCT_LIMITS', label: 'Within product amount limits',
      pass: principal >= product.min_amount && principal <= product.max_amount,
      detail: `Product range ${(product.min_amount / 100).toLocaleString()} – ${(product.max_amount / 100).toLocaleString()}` },
    { code: 'TERM', label: `Term within ${product.max_term_months} months`,
      pass: termMonths > 0 && termMonths <= product.max_term_months, detail: `${termMonths} months requested` },
    { code: 'DEPOSIT_MULTIPLIER', label: `Within ${product.deposit_multiplier}× deposits`,
      pass: principal <= maxByMultiplier,
      detail: `Deposits ${(deposits / 100).toLocaleString()} → ceiling ${(maxByMultiplier / 100).toLocaleString()}` },
    // Every product is affordability-assessed, but the two paths never both apply to the same
    // one: a salary_based product is checked against actually-processed payroll (never the
    // manually-typed card, since the system already has real income data for it); any other
    // product is checked against the Salary Appraisal card. Either way, data that hasn't
    // actually been captured/processed yet must fail rather than pass — affordability that
    // hasn't been assessed is not the same thing as affordability that's been confirmed, and
    // treating the two the same let a loan read as ELIGIBLE without ever being checked.
    { code: 'AFFORDABILITY', label: `Deduction ratio ≤ ${product.max_dsr_pct}%`,
      pass: product.salary_based
        ? !!(processedSalary?.sufficient && dsr <= product.max_dsr_pct)
        : (salaryTotals ? dsr <= product.max_dsr_pct : false),
      detail: product.salary_based
        ? (processedSalary?.sufficient
          ? `${product.salary_appraisal_type === 'LOWEST_NET' ? 'Lowest' : 'Average'} processed net salary `
            + `${(processedSalary.base / 100).toLocaleString()} over ${processedSalary.count} month${processedSalary.count === 1 ? '' : 's'}`
            + ` — total deductions ${(totalDeductions / 100).toLocaleString()} = ${dsr.toFixed(1)}%`
          : `Not yet available — needs at least ${product.min_salary_count} processed salary payment`
            + `${product.min_salary_count === 1 ? '' : 's'} via Checkoff & Salary Processing`
            + ` (found ${processedSalary?.count ?? 0} in the last ${processedSalary?.windowMonths ?? product.min_salary_count} months)`)
        : salaryTotals
          ? `Total deductions ${(totalDeductions / 100).toLocaleString()} of income ${(salaryTotals.gross / 100).toLocaleString()} = ${dsr.toFixed(1)}%`
          : 'Not yet available — save the application, fill in the Salary Appraisal card, then re-run appraisal' },
    { code: 'SECURITY_COVER', label: 'Fully secured — guarantors and/or collateral cover the principal',
      pass: securityCover >= principal,
      detail: `Self guarantee capacity ${(selfGuarantee / 100).toLocaleString()} + guarantors ${(security.guarantors / 100).toLocaleString()}`
        + ` + collateral ${(security.collateral / 100).toLocaleString()} = ${(securityCover / 100).toLocaleString()}`
        + ` against principal ${(principal / 100).toLocaleString()}`
        + (loanId ? '' : ' (attach guarantors/collateral on the saved application, then re-run)') },
  ];

  const passed = factors.filter((f) => f.pass).length;
  return {
    decision: factors.every((f) => f.pass) ? 'ELIGIBLE' : 'REFERRED',
    score: Math.round((passed / factors.length) * 100),
    factors,
    installment,
    deposits,
    exposure,
    maxByMultiplier,
    dsr: Number(dsr.toFixed(1)),
    monthlyObligations: obligations,
  };
}

export interface SaveAppraisalInput {
  loanId: number;
  user: Actor;
}

/**
 * Runs the same explainable appraisal as appraise() above, but against an already-captured loan,
 * and persists the result as a new loan_appraisal row instead of letting it evaporate once the
 * screen closes. Never overwrites a prior run — each call adds one more dated entry — so the
 * loan's Appraisal tab always shows exactly what was known and decided at each point in time
 * (section 5's "dated immutable result"), right through to a final re-check before disbursement.
 */
export async function saveAppraisal({ loanId, user }: SaveAppraisalInput): Promise<LoanAppraisalRow> {
  const loan = await getLoan(loanId);
  if (!loan) throw new PostingError('Loan not found', 'NOT_FOUND');
  if (!['OPEN', 'PENDING APPROVAL', 'APPROVED'].includes(loan.status)) {
    throw new PostingError(`Loan is ${loan.status} and cannot be appraised`, 'BAD_STATUS');
  }

  const result = await appraise({
    memberId: loan.member_id, productId: loan.product_id, principal: loan.principal, termMonths: loan.term_months,
    loanId,
  });
  const appraisedAt = new Date().toISOString();
  const product = (await one<LoanProduct>('SELECT * FROM loan_product WHERE id = ?', loan.product_id))!;

  const id = await tx(async () => {
    const info = await run(
      `INSERT INTO loan_appraisal
         (loan_id, decision, score, installment, deposits, exposure, max_by_multiplier, dsr,
          monthly_obligations, appraised_by, appraised_at)
       VALUES (?,?,?,?,?,?,?,?,?,?,?)`,
      loanId, result.decision, result.score, result.installment, result.deposits, result.exposure,
      result.maxByMultiplier, result.dsr, result.monthlyObligations, user.username, appraisedAt,
    );
    const appraisalId = Number(info.lastInsertRowid);
    let seq = 0;
    for (const f of result.factors) {
      await run(
        'INSERT INTO loan_appraisal_factor (appraisal_id, seq, code, label, pass, detail) VALUES (?,?,?,?,?,?)',
        appraisalId, seq++, f.code, f.label, f.pass, f.detail,
      );
    }

    // A projected repayment schedule, keyed off the Application Date (Posting Date doesn't
    // exist yet — the loan isn't disbursed) — mirrors AL's GetRepaymentStartDate falling back to
    // Application Date pre-disbursement. disburse() later deletes and rebuilds this same table
    // off the actual Disbursement Date, so nothing here needs to survive past that point.
    const firstDue = repaymentStartDate(loan.applied_date || today(), product.repayment_cutoff_date);
    const sched = buildSchedule(loan.principal, loan.interest_rate, loan.term_months, loan.interest_method, firstDue);
    await run('DELETE FROM loan_schedule WHERE loan_id = ?', loanId);
    const INS_SCHEDULE =
      `INSERT INTO loan_schedule (loan_id, installment_no, due_date, opening_balance, principal_due, interest_due)
       VALUES (?,?,?,?,?,?)`;
    for (const r of sched.rows) {
      await run(INS_SCHEDULE, loanId, r.installment_no, r.due_date, r.opening_balance, r.principal_due, r.interest_due);
    }
    // Installment/total interest/first due date are a projection here, not a disbursement —
    // status, disbursed_date and the balance columns stay untouched since no money has moved.
    await run(
      'UPDATE loan SET installment=?, total_interest=?, first_due_date=? WHERE id=?',
      sched.installment, sched.totalInterest, firstDue, loanId,
    );

    return appraisalId;
  });

  await audit(user, 'LOAN_APPRAISE', 'loan_appraisal', id, { loanId, decision: result.decision, score: result.score });
  return {
    id,
    loan_id: loanId,
    decision: result.decision,
    score: result.score,
    installment: result.installment,
    deposits: result.deposits,
    exposure: result.exposure,
    max_by_multiplier: result.maxByMultiplier,
    dsr: result.dsr,
    monthly_obligations: result.monthlyObligations,
    appraised_by: user.username,
    appraised_at: appraisedAt,
    factors: result.factors.map((f): LoanAppraisalFactorRow => ({ ...f })),
  };
}

export interface ApplyInput extends AppraiseInput {
  purpose?: string | null;
  /** SASRA Sectorial Lending classification (lib/economicSectors.ts) — optional at this stage,
   *  but required before the application can be submitted for approval (see submit() below). */
  sectorCode?: string | null;
  subSectorCode?: string | null;
  subSubsectorCode?: string | null;
  guarantors?: { memberId: number; amount?: Cents }[];
  disburseToAccountId?: number | null;
  /** See lib/checkoffBatches.ts (CHECKOFF) and disburse()'s own doc comment (STANDING_ORDER).
   *  Defaults to DIRECT. */
  recoveryMode?: LoanRecoveryMode;
  user: Actor;
}

/** Captures a loan application as a draft (status OPEN) — no workflow is required to exist yet;
 *  that's only checked once the applicant actually submits it (see submit() below), mirroring
 *  memberApplications.ts's createMemberApplication()/submitMemberApplication() split. */
export async function apply({
  memberId, productId, principal, termMonths, purpose,
  sectorCode = null, subSectorCode = null, subSubsectorCode = null,
  guarantors = [], disburseToAccountId = null, recoveryMode = 'DIRECT', user,
}: ApplyInput): Promise<LoanFull> {
  principal = Math.round(principal);
  const product = await one<LoanProduct>('SELECT * FROM loan_product WHERE id = ?', productId);
  if (!product) throw new PostingError('Loan product not found', 'PRODUCT_NOT_FOUND');
  if (principal <= 0) throw new PostingError('Loan amount must be greater than zero', 'INVALID_AMOUNT');
  if (termMonths <= 0 || termMonths > product.max_term_months) {
    throw new PostingError(`Term must be between 1 and ${product.max_term_months} months`, 'INVALID_TERM');
  }
  await assertSectorSelection(sectorCode, subSectorCode, subSubsectorCode);

  const id = await tx(async () => {
    const loanNo = await nextSequence('LOAN');
    const info = await run(
      `INSERT INTO loan (loan_no, member_id, product_id, principal, interest_rate, interest_method,
         term_months, purpose, sector_code, sub_sector_code, sub_subsector_code,
         status, applied_date, disburse_to_account_id, recovery_mode, created_by)
       VALUES (?,?,?,?,?,?,?,?,?,?,?,'OPEN',?,?,?,?)`,
      loanNo, memberId, productId, principal, product.interest_rate, product.interest_method,
      termMonths, purpose || null, sectorCode, subSectorCode, subSubsectorCode,
      today(), disburseToAccountId || null, recoveryMode, user.username,
    );
    const loanId = Number(info.lastInsertRowid);
    for (const g of guarantors) {
      // A member named twice on one application is a duplicate, not an error.
      await run(
        `INSERT INTO loan_guarantor (loan_id, member_id, amount) VALUES (?,?,?)
         ON CONFLICT (loan_id, member_id) DO NOTHING`,
        loanId, g.memberId, Math.round(g.amount || 0),
      );
    }

    return loanId;
  });

  if (!product.salary_based) await ensureSalaryAppraisalLines(id, memberId);

  await audit(user, 'LOAN_APPLY', 'loan', id, { principal, termMonths, productId });
  return (await getLoan(id))!;
}

export interface UpdateLoanInput {
  loanId: number;
  memberId: number;
  productId: number;
  principal: Cents;
  termMonths: number;
  purpose?: string | null;
  sectorCode?: string | null;
  subSectorCode?: string | null;
  subSubsectorCode?: string | null;
  disburseToAccountId?: number | null;
  recoveryMode?: LoanRecoveryMode;
  user: Actor;
}

/** Edits a captured application — only while it is still OPEN, the same window apply()'s own
 *  guarantor/collateral attachments stay open, so a draft can be corrected before it is ever
 *  routed for approval. Re-validates against the (possibly newly chosen) product exactly as
 *  apply() does, and re-copies its interest rate/method, since switching products mid-edit
 *  should re-price the loan the same way starting a fresh application would. */
export async function update({
  loanId, memberId, productId, principal, termMonths, purpose = null,
  sectorCode = null, subSectorCode = null, subSubsectorCode = null,
  disburseToAccountId = null, recoveryMode, user,
}: UpdateLoanInput): Promise<LoanFull> {
  const loan = await getLoan(loanId);
  if (!loan) throw new PostingError('Loan not found', 'NOT_FOUND');
  if (loan.status !== 'OPEN') throw new PostingError(`Loan is ${loan.status} and cannot be edited`, 'BAD_STATUS');

  principal = Math.round(principal);
  const product = await one<LoanProduct>('SELECT * FROM loan_product WHERE id = ?', productId);
  if (!product) throw new PostingError('Loan product not found', 'PRODUCT_NOT_FOUND');
  if (principal <= 0) throw new PostingError('Loan amount must be greater than zero', 'INVALID_AMOUNT');
  if (termMonths <= 0 || termMonths > product.max_term_months) {
    throw new PostingError(`Term must be between 1 and ${product.max_term_months} months`, 'INVALID_TERM');
  }
  await assertSectorSelection(sectorCode, subSectorCode, subSubsectorCode);

  await run(
    `UPDATE loan SET member_id=?, product_id=?, principal=?, interest_rate=?, interest_method=?,
       term_months=?, purpose=?, sector_code=?, sub_sector_code=?, sub_subsector_code=?,
       disburse_to_account_id=?, recovery_mode=?, version = version + 1
     WHERE id=?`,
    memberId, productId, principal, product.interest_rate, product.interest_method,
    termMonths, purpose || null, sectorCode, subSectorCode, subSubsectorCode,
    disburseToAccountId || null, recoveryMode ?? loan.recovery_mode, loanId,
  );

  // Only reseed the Salary Appraisal section when the product actually changed to a non-salary-
  // based one — an unrelated edit (principal, term…) must never wipe out amounts the officer
  // already typed in.
  if (!product.salary_based && productId !== loan.product_id) await ensureSalaryAppraisalLines(loanId, memberId);

  await audit(user, 'LOAN_UPDATE', 'loan', loanId, { principal, termMonths, productId, memberId });
  return (await getLoan(loanId))!;
}

export interface CommitGuarantorInput {
  loanId: number;
  memberId: number;
  amount: Cents;
}

/** Commits a member's guarantee to a loan application — the "from other members" half of
 *  SECURITY_COVER above, and only while the loan is still OPEN, the same point loan_collateral
 *  is fixed (section 6's "lock guarantor capacity in one transaction"). The applicant's own
 *  self-guarantee is already counted from their deposits, so they cannot also guarantee their
 *  own loan here. */
export async function commitGuarantor({ loanId, memberId, amount }: CommitGuarantorInput, user: Actor): Promise<void> {
  const loan = await one<{ member_id: number; status: string }>('SELECT member_id, status FROM loan WHERE id = ?', loanId);
  if (!loan) throw new PostingError('Loan not found', 'NOT_FOUND');
  if (loan.status !== 'OPEN') throw new PostingError('Guarantors can only be committed while the loan is still open', 'BAD_STATUS');
  if (memberId === loan.member_id) {
    throw new PostingError('A member cannot guarantee their own loan — that capacity is already counted as self-guarantee', 'VALIDATION');
  }
  if (!(await one('SELECT 1 FROM member WHERE id = ?', memberId))) throw new PostingError('Member not found', 'NOT_FOUND');

  const amt = Math.round(amount);
  if (amt <= 0) throw new PostingError('Guarantee amount must be greater than zero', 'INVALID_AMOUNT');

  // Mirrors AL's Guaranteed Amount validation (Tab52204048.LoanGuarantees.al): a member may
  // never commit more than their own guarantee-capacity engine (lib/guarantors.ts) says they
  // currently qualify for, across everything else they already guarantee.
  const capacity = await guarantorCapacity(memberId);
  if (amt > capacity.available) {
    throw new PostingError(
      `This member can only guarantee up to ${(capacity.available / 100).toLocaleString()}`, 'OVER_CAPACITY',
    );
  }

  await run(
    `INSERT INTO loan_guarantor (loan_id, member_id, amount) VALUES (?,?,?)
     ON CONFLICT (loan_id, member_id) DO UPDATE SET amount = EXCLUDED.amount, status = 'COMMITTED'`,
    loanId, memberId, amt,
  );
  await audit(user, 'LOAN_GUARANTOR_COMMIT', 'loan', loanId, { memberId, amount: amt });
}

export async function releaseGuarantor(loanId: number, memberId: number, user: Actor): Promise<void> {
  const loan = await one<{ status: string }>('SELECT status FROM loan WHERE id = ?', loanId);
  if (!loan) throw new PostingError('Loan not found', 'NOT_FOUND');
  if (loan.status !== 'OPEN') throw new PostingError('Guarantors can only be released while the loan is still open', 'BAD_STATUS');

  await run('DELETE FROM loan_guarantor WHERE loan_id = ? AND member_id = ?', loanId, memberId);
  await audit(user, 'LOAN_GUARANTOR_RELEASE', 'loan', loanId, { memberId });
}

export interface SubmitInput {
  loanId: number;
  user: Actor;
}

/** Sends a captured (OPEN) loan for approval — always requires routing through an admin-defined,
 *  enabled workflow, with no falling back to a flat permission check. Keys passed here must match
 *  RUNTIME_FIELD_CAP.LOAN (lib/workflowConstants.ts) — that cap is what stops an admin from
 *  enabling a Table Relation field here that would never actually match. Also requires the loan
 *  to have been *fully* appraised: not merely that a loan_appraisal row exists, but that its
 *  latest run actually came back ELIGIBLE — a REFERRED loan must be fixed and re-appraised
 *  before it can go up, the same precondition DocumentActionsMenu's own Appraisal Report export
 *  reflects by staying disabled until an appraisal is on file at all. On top of that, security
 *  cover is re-checked live rather than trusted from that stored decision: a guarantor can be
 *  released or collateral detached (both allowed while OPEN, same as this submit window) after
 *  an ELIGIBLE appraisal ran, which would otherwise leave a stale pass on file for a loan that
 *  is no longer actually secured. */
export async function submit({ loanId, user }: SubmitInput): Promise<LoanFull> {
  const loan = await getLoan(loanId);
  if (!loan) throw new PostingError('Loan not found', 'NOT_FOUND');
  if (loan.status !== 'OPEN') throw new PostingError(`Loan is ${loan.status} and cannot be submitted`, 'BAD_STATUS');
  const latestAppraisal = await one<{ decision: string }>(
    'SELECT decision FROM loan_appraisal WHERE loan_id = ? ORDER BY id DESC LIMIT 1', loanId,
  );
  if (!latestAppraisal) {
    throw new PostingError('Run the credit appraisal report before sending this loan for approval', 'NO_APPRAISAL');
  }
  if (latestAppraisal.decision !== 'ELIGIBLE') {
    throw new PostingError(
      'This loan has not been fully appraised — resolve the failing factors and re-run appraisal before sending it for approval',
      'NOT_FULLY_APPRAISED',
    );
  }
  const security = await committedSecurity(loanId);
  const selfGuarantee = Math.min(await selfGuaranteeCapacity(loan.member_id), loan.principal);
  if (selfGuarantee + security.guarantors + security.collateral < loan.principal) {
    throw new PostingError(
      'This loan is not fully secured — self-guarantee, committed guarantors and collateral together must cover the full principal before it can be sent for approval',
      'NOT_FULLY_SECURED',
    );
  }

  const matched = await findMatchingWorkflow('LOAN', {
    principal: loan.principal, product_id: loan.product_id, term_months: loan.term_months,
  });
  if (!matched) throw new PostingError('There is no enabled workflow for this document', 'NO_WORKFLOW');

  await tx(async () => {
    await run("UPDATE loan SET status='PENDING APPROVAL' WHERE id=?", loanId);
    await startWorkflow(matched.workflow, matched.steps, {
      documentType: 'LOAN', entityId: String(loanId), requestedBy: user.username, amount: loan.principal,
    });
  });

  await audit(user, 'LOAN_SUBMIT', 'loan', loanId, {});
  return (await getLoan(loanId))!;
}

export interface ApproveInput {
  loanId: number;
  user: Actor;
  approve?: boolean;
  reason?: string | null;
}

/** Maker-checker, routed entirely through the workflow engine — same as every other document
 *  type (member edits, collateral releases, account opening, …), none of which layer a second
 *  self-approval guard on top of it here. Who may actually call this is decided by
 *  lib/workflow.ts: a routed decision only reaches finalizeDocument() after isEligibleApprover()
 *  has cleared the decider, and the requester auto-clears a level at submission time only when
 *  requesterClearsLevel() finds them the sole configured approver there (see
 *  createTaskForStep()/advanceWorkflowLevel() there) — if that level is shared with someone else,
 *  the requester's own membership is excluded and a different approver has to decide it. The
 *  legacy flat-permission fallback in app/actions/loans.ts's decideLoan() (pre-dating every
 *  submission requiring a matched workflow) is the one path with no such check, exactly like the
 *  equivalent fallback on every other document's own approve action. */
export async function approve(
  { loanId, user, approve: decision = true, reason = null }: ApproveInput,
): Promise<LoanFull> {
  const loan = await getLoan(loanId);
  if (!loan) throw new PostingError('Loan not found', 'NOT_FOUND');
  if (loan.status !== 'PENDING APPROVAL') {
    throw new PostingError(`Loan is ${loan.status} and cannot be appraised`, 'BAD_STATUS');
  }
  if (!decision && (!reason || !reason.trim())) {
    throw new PostingError('A reason is required to reject a loan application', 'VALIDATION');
  }

  await tx(async () => {
    if (!decision) {
      // Rejection sends the loan back to OPEN rather than a terminal state — the applicant
      // can amend and resubmit it, the same shape as a self-service cancel-approval pull-back.
      await run(
        "UPDATE loan SET status='OPEN', rejected_reason=?, approved_by=?, approved_date=? WHERE id=?",
        reason, user.username, today(), loanId,
      );
    } else {
      await run(
        "UPDATE loan SET status='APPROVED', approved_by=?, approved_date=? WHERE id=?",
        user.username, today(), loanId,
      );
    }
  });

  await audit(user, decision ? 'LOAN_APPROVE' : 'LOAN_REJECT', 'loan', loanId, { reason });
  return (await getLoan(loanId))!;
}

export interface DisburseInput {
  loanId: number;
  valueDate?: IsoDate;
  channel?: Channel;
  /** The Bank/Cashbook account the payout actually left from — meaningful only when the loan
   *  has no disburse_to_account_id (a manual external payout, not a credit to a member's own
   *  savings account). app/actions/loans.ts's disburseLoan() enforces that a real user picks
   *  one in that case; passed straight through here so internal/system callers (seed data,
   *  tests) that have no such concept keep working unchanged. */
  bankAccountId?: number | null;
  payMode?: PayMode | null;
  /** Pay Mode = CHEQUE only. */
  chequeNo?: string | null;
  /** Pay Mode = CHEQUE only. */
  chequeDate?: IsoDate | null;
  /** Pay Mode = MPESA | BANK | EFT only. */
  referenceNo?: string | null;
  user: Actor;
}

export async function disburse({
  loanId, valueDate, channel = 'BANK', bankAccountId = null, payMode = null,
  chequeNo = null, chequeDate = null, referenceNo = null, user,
}: DisburseInput): Promise<LoanFull> {
  const loan = await getLoan(loanId);
  if (!loan) throw new PostingError('Loan not found', 'NOT_FOUND');
  if (loan.status !== 'APPROVED') {
    throw new PostingError(`Loan must be APPROVED before disbursement (currently ${loan.status})`, 'BAD_STATUS');
  }
  await assertMemberNotDormant(loan.member_id, 'disbursement');
  const product = (await one<LoanProduct>('SELECT * FROM loan_product WHERE id = ?', loan.product_id))!;
  const vd = valueDate || await resolvePostingDate(user);
  const firstDue = repaymentStartDate(vd, product.repayment_cutoff_date);
  const sched = buildSchedule(loan.principal, loan.interest_rate, loan.term_months, loan.interest_method, firstDue);

  // The Loan Product Charges computation module (lib/loans.ts's calculateLoanProductCharges):
  // every configured charge line, each posting to its own revenue account.
  const chargeLines = await listLoanProductCharges(product.id);
  const charges = calculateLoanProductCharges(chargeLines, loan.principal, loan.term_months);
  const fees = charges.reduce((sum, c) => sum + c.amount, 0);

  const target = loan.disburse_to_account_id
    ? await one<SavingsAccount & { gl_control_id: number }>(
        `SELECT sa.*, p.gl_control_id FROM savings_account sa
         JOIN savings_product p ON p.id = sa.product_id WHERE sa.id = ?`,
        loan.disburse_to_account_id,
      )
    : undefined;

  // A Bank/Cashbook payout (Payment Channel) — only sought, and only ever supplied, when
  // there's no member account target to credit instead.
  const bankAccount = !target && bankAccountId
    ? await one<{ id: number; gl_account_id: number }>(
        "SELECT id, gl_account_id FROM bank_account WHERE id = ? AND status = 'ACTIVE'", bankAccountId,
      )
    : undefined;
  if (!target && bankAccountId && !bankAccount) {
    throw new PostingError('Bank/Cashbook account not found or inactive', 'ACCOUNT_NOT_FOUND');
  }

  await tx(async () => {
    const lines: JournalLineInput[] = [
      { account: loan.gl_receivable_id, debit: loan.principal, credit: 0, narration: `Disbursement ${loan.loan_no}` },
    ];
    if (target) {
      lines.push({ account: target.gl_control_id, debit: 0, credit: loan.principal, narration: 'Credit to member account' });
      if (fees > 0) lines.push({ account: target.gl_control_id, debit: fees, credit: 0, narration: 'Loan charges recovered' });
    } else {
      const creditAccount = bankAccount ? bankAccount.gl_account_id : (CHANNEL_GL[channel] || CHANNEL_GL.BANK);
      lines.push({ account: creditAccount, debit: 0, credit: loan.principal - fees, narration: 'Net paid out' });
    }
    // One credit line per charge, to its own configured revenue account — Loan Product
    // Charges' "Revenue account" only means something if it's actually where the money lands.
    for (const c of charges) {
      lines.push({ account: c.glAccountId, debit: 0, credit: c.amount, narration: c.chargeDescription || c.chargeCode });
    }

    const j = await postJournal({
      valueDate: vd, module: 'LOAN', eventType: 'DISBURSEMENT',
      description: `Loan disbursement ${loan.loan_no}`, reference: loan.loan_no,
      memberId: loan.member_id, user, lines,
    });

    await run('DELETE FROM loan_schedule WHERE loan_id = ?', loanId);
    const INS_SCHEDULE =
      `INSERT INTO loan_schedule (loan_id, installment_no, due_date, opening_balance, principal_due, interest_due)
       VALUES (?,?,?,?,?,?)`;
    for (const r of sched.rows) {
      await run(INS_SCHEDULE, loanId, r.installment_no, r.due_date, r.opening_balance, r.principal_due, r.interest_due);
    }

    await run(
      `UPDATE loan SET status='DISBURSED', disbursed_date=?, first_due_date=?, installment=?,
        total_interest=?, fees_charged=?, principal_balance=?, interest_balance=?, version = version + 1
       WHERE id = ?`,
      vd, firstDue, sched.installment, sched.totalInterest, fees, loan.principal, sched.totalInterest, loanId,
    );

    if (target) {
      const newBal = target.balance + loan.principal - fees;
      await run(
        'UPDATE savings_account SET balance = ?, last_activity = ?, version = version + 1 WHERE id = ?',
        newBal, vd, target.id,
      );
      await run(
        `INSERT INTO txn (txn_ref, value_date, created_at, module, txn_type, member_id,
           savings_account_id, loan_id, amount, running_balance, channel, description, journal_id, created_by)
         VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?)`,
        await nextSequence('TXN'), vd, new Date().toISOString(), 'SAVINGS', 'DISBURSEMENT', loan.member_id,
        target.id, loanId, loan.principal - fees, newBal, 'SYSTEM',
        `Loan ${loan.loan_no} net of charges`, j.id, user.username,
      );
    }

    const effectiveChannel = bankAccount && payMode ? CHANNEL_FOR_PAY_MODE[payMode] : channel;
    await run(
      `INSERT INTO txn (txn_ref, value_date, created_at, module, txn_type, member_id, loan_id,
         amount, running_balance, channel, bank_account_id, pay_mode, cheque_no, cheque_date, reference_no,
         description, journal_id, created_by)
       VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)`,
      await nextSequence('TXN'), vd, new Date().toISOString(), 'LOAN', 'DISBURSEMENT', loan.member_id, loanId,
      loan.principal, loan.principal, effectiveChannel,
      bankAccount ? bankAccount.id : null, bankAccount ? payMode : null,
      bankAccount && payMode === 'CHEQUE' ? chequeNo : null,
      bankAccount && payMode === 'CHEQUE' ? chequeDate : null,
      bankAccount && (payMode === 'MPESA' || payMode === 'BANK' || payMode === 'EFT') ? referenceNo : null,
      `Disbursement ${loan.loan_no}`, j.id, user.username,
    );
  });

  await audit(user, 'LOAN_DISBURSE', 'loan', loanId, {
    amount: loan.principal, fees, bankAccountId: bankAccount?.id ?? null, payMode: bankAccount ? payMode : null,
  });

  // recovery_mode = STANDING_ORDER: auto-create (and immediately activate) the recurring
  // installment collection lib/standingOrders.ts's own run engine then takes over — see
  // createRecoveryStandingOrderForLoan()'s own doc comment for why this skips the normal
  // maker-checker cycle. A dynamic import, not a top-of-file one: lib/standingOrders.ts already
  // imports repay() from this module for its own run engine, and a static import back here would
  // make the two files circular. Best-effort: the disbursement itself already committed, so a
  // failure here is logged rather than surfaced as a disbursement failure — an officer can still
  // set up the standing order by hand from the loan.
  if (loan.recovery_mode === 'STANDING_ORDER') {
    try {
      const { createRecoveryStandingOrderForLoan } = await import('./standingOrders.ts');
      await createRecoveryStandingOrderForLoan(loanId, user);
    } catch (e) {
      await audit(user, 'LOAN_DISBURSE_STO_AUTO_CREATE_FAILED', 'loan', loanId, {
        message: (e as Error).message || 'Unknown error',
      });
    }
  }

  return (await getLoan(loanId))!;
}

export interface RepayInput {
  loanId: number;
  amount: Cents;
  channel?: Channel;
  valueDate?: IsoDate;
  description?: string;
  fromSavingsAccountId?: number | null;
  /** The Bank/Cashbook account this repayment was actually received into — meaningful only
   *  when it isn't debited from a member's own savings account. See DisburseInput's own
   *  bankAccountId for the same enforcement/scoping rationale. */
  bankAccountId?: number | null;
  payMode?: PayMode | null;
  /** Pay Mode = CHEQUE only. */
  chequeNo?: string | null;
  /** Pay Mode = CHEQUE only. */
  chequeDate?: IsoDate | null;
  /** Pay Mode = MPESA | BANK | EFT only. */
  referenceNo?: string | null;
  user: Actor;
  idempotencyKey?: string | null;
}

export interface RepayResult {
  principal: Cents;
  interest: Cents;
  penalty: Cents;
  closed: boolean;
  journal_no: string;
  loan: LoanFull;
}

export async function repay({
  loanId, amount, channel = 'TELLER', valueDate, description,
  fromSavingsAccountId = null, bankAccountId = null, payMode = null,
  chequeNo = null, chequeDate = null, referenceNo = null, user, idempotencyKey = null,
}: RepayInput): Promise<RepayResult> {
  amount = Math.round(amount);
  if (!(amount > 0)) throw new PostingError('Repayment must be greater than zero', 'INVALID_AMOUNT');
  const loan = await getLoan(loanId);
  if (!loan) throw new PostingError('Loan not found', 'NOT_FOUND');
  if (loan.status !== 'DISBURSED') throw new PostingError(`Loan is ${loan.status}; no repayment due`, 'BAD_STATUS');
  // Checkoff & Salary Processing is one of this restriction's explicit exceptions — an
  // employer's payroll deduction still reaches the loan even while the borrower is Dormant.
  if (channel !== 'CHECKOFF') await assertMemberNotDormant(loan.member_id, 'a repayment');

  const totalOwed = loan.principal_balance + loan.interest_balance + loan.penalty_balance;
  if (amount > totalOwed) {
    throw new PostingError(
      `Repayment ${(amount / 100).toFixed(2)} exceeds the outstanding balance ${(totalOwed / 100).toFixed(2)}`,
      'OVERPAYMENT',
    );
  }

  const vd = valueDate || await resolvePostingDate(user);
  const schedule = await all<LoanScheduleRow>(
    'SELECT * FROM loan_schedule WHERE loan_id = ? ORDER BY installment_no', loanId,
  );

  let source: (SavingsAccount & { gl_control_id: number; min_balance: Cents }) | undefined;
  if (fromSavingsAccountId) {
    source = await one<SavingsAccount & { gl_control_id: number; min_balance: Cents }>(
      `SELECT sa.*, p.gl_control_id, p.min_balance FROM savings_account sa
       JOIN savings_product p ON p.id = sa.product_id WHERE sa.id = ?`,
      fromSavingsAccountId,
    );
    if (!source) throw new PostingError('Source savings account not found', 'ACCOUNT_NOT_FOUND');
    const available = source.balance - source.hold_amount - source.min_balance;
    if (amount > available) {
      throw new PostingError(
        `Insufficient funds in ${source.account_no}. Available ${(available / 100).toFixed(2)}`, 'INSUFFICIENT_FUNDS',
      );
    }
  }

  // A Bank/Cashbook receipt (Payment Channel) — only sought, and only ever supplied, when
  // there's no member account source to debit instead.
  const bankAccount = !source && bankAccountId
    ? await one<{ id: number; gl_account_id: number }>(
        "SELECT id, gl_account_id FROM bank_account WHERE id = ? AND status = 'ACTIVE'", bankAccountId,
      )
    : undefined;
  if (!source && bankAccountId && !bankAccount) {
    throw new PostingError('Bank/Cashbook account not found or inactive', 'ACCOUNT_NOT_FOUND');
  }

  const res = await tx(async () => {
    let remaining = amount;
    const penaltyPaid = Math.min(loan.penalty_balance, remaining);
    remaining -= penaltyPaid;
    const alloc = allocateRepayment(schedule, remaining);

    const lines: JournalLineInput[] = [
      source
        ? { account: source.gl_control_id, debit: amount, credit: 0, narration: 'Repayment from member account' }
        : {
            account: bankAccount ? bankAccount.gl_account_id : (CHANNEL_GL[channel] || CHANNEL_GL.TELLER),
            debit: amount, credit: 0, narration: 'Loan repayment received',
          },
    ];
    if (penaltyPaid > 0) lines.push({ account: loan.gl_penalty_income_id, debit: 0, credit: penaltyPaid, narration: 'Penalty recovered' });
    if (alloc.interest > 0) lines.push({ account: loan.gl_interest_income_id, debit: 0, credit: alloc.interest, narration: 'Interest income' });
    if (alloc.principal > 0) lines.push({ account: loan.gl_receivable_id, debit: 0, credit: alloc.principal, narration: 'Principal recovered' });
    if (alloc.unallocated > 0) {
      // Nothing left to apply against — treat as principal prepayment.
      lines.push({ account: loan.gl_receivable_id, debit: 0, credit: alloc.unallocated, narration: 'Principal prepayment' });
    }

    const j = await postJournal({
      valueDate: vd, module: 'LOAN', eventType: 'REPAYMENT',
      description: description || `Repayment ${loan.loan_no}`, reference: loan.loan_no,
      memberId: loan.member_id, user, idempotencyKey, lines,
    });

    const UPD_SCHEDULE =
      `UPDATE loan_schedule SET principal_paid = principal_paid + ?, interest_paid = interest_paid + ?,
        status = CASE WHEN principal_paid + ? >= principal_due AND interest_paid + ? >= interest_due
                      THEN 'PAID' ELSE 'PARTIAL' END
       WHERE loan_id = ? AND installment_no = ?`;
    for (const a of alloc.allocations) {
      await run(UPD_SCHEDULE, a.principal, a.interest, a.principal, a.interest, loanId, a.installment_no);
    }

    const principalApplied = alloc.principal + alloc.unallocated;
    const newPrincipal = loan.principal_balance - principalApplied;
    const newInterest = loan.interest_balance - alloc.interest;
    const newPenalty = loan.penalty_balance - penaltyPaid;
    const closed = newPrincipal <= 0 && newInterest <= 0 && newPenalty <= 0;

    await run(
      `UPDATE loan SET principal_balance=?, interest_balance=?, penalty_balance=?,
        principal_paid = principal_paid + ?, interest_paid = interest_paid + ?,
        status = CASE WHEN ? THEN 'CLOSED' ELSE status END, version = version + 1
       WHERE id = ?`,
      newPrincipal, newInterest, newPenalty, principalApplied, alloc.interest, closed, loanId,
    );

    if (source) {
      const newBal = source.balance - amount;
      await run(
        'UPDATE savings_account SET balance=?, last_activity=?, version=version+1 WHERE id=?',
        newBal, vd, source.id,
      );
      await run(
        `INSERT INTO txn (txn_ref, value_date, created_at, module, txn_type, member_id,
           savings_account_id, loan_id, amount, running_balance, channel, description, journal_id, created_by)
         VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?)`,
        await nextSequence('TXN'), vd, new Date().toISOString(), 'SAVINGS', 'REPAYMENT', loan.member_id,
        source.id, loanId, -amount, newBal, 'SYSTEM', `Loan repayment ${loan.loan_no}`, j.id, user.username,
      );
    }

    const effectiveChannel = bankAccount && payMode ? CHANNEL_FOR_PAY_MODE[payMode] : channel;
    await run(
      `INSERT INTO txn (txn_ref, value_date, created_at, module, txn_type, member_id, loan_id,
         amount, running_balance, channel, bank_account_id, pay_mode, cheque_no, cheque_date, reference_no,
         description, journal_id, created_by)
       VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)`,
      await nextSequence('TXN'), vd, new Date().toISOString(), 'LOAN', 'REPAYMENT', loan.member_id, loanId,
      -amount, newPrincipal, effectiveChannel,
      bankAccount ? bankAccount.id : null, bankAccount ? payMode : null,
      bankAccount && payMode === 'CHEQUE' ? chequeNo : null,
      bankAccount && payMode === 'CHEQUE' ? chequeDate : null,
      bankAccount && (payMode === 'MPESA' || payMode === 'BANK' || payMode === 'EFT') ? referenceNo : null,
      `Repayment: principal ${(principalApplied / 100).toFixed(2)}, interest ${(alloc.interest / 100).toFixed(2)}`,
      j.id, user.username,
    );

    return {
      principal: principalApplied,
      interest: alloc.interest,
      penalty: penaltyPaid,
      closed,
      journal_no: j.journal_no,
    };
  });

  await audit(user, 'LOAN_REPAY', 'loan', loanId, { amount, ...res });
  return { ...res, loan: (await getLoan(loanId))! };
}

/** Recompute arrears and SASRA-style classification for every live loan. */
export async function runArrearsAging(asOf?: IsoDate): Promise<{ asOf: IsoDate; loansProcessed: number }> {
  const d = asOf || today();
  const loans = await all<{ id: number }>("SELECT id FROM loan WHERE status = 'DISBURSED'");
  const OVERDUE_FOR =
    `SELECT COALESCE(SUM((principal_due - principal_paid) + (interest_due - interest_paid)),0) amt,
            MIN(due_date) oldest
     FROM loan_schedule WHERE loan_id = ? AND due_date <= ? AND status <> 'PAID'`;
  const UPD = 'UPDATE loan SET arrears_amount=?, days_in_arrears=?, classification=? WHERE id=?';

  const loansProcessed = await tx(async () => {
    let n = 0;
    for (const l of loans) {
      const overdue = (await one<{ amt: Cents; oldest: IsoDate | null }>(OVERDUE_FOR, l.id, d))!;
      const amt = Math.max(overdue.amt || 0, 0);
      const days = amt > 0 && overdue.oldest ? Math.max(daysBetween(overdue.oldest, d), 0) : 0;
      await run(UPD, amt, days, classify(days), l.id);
      n++;
    }
    return n;
  });

  return { asOf: d, loansProcessed };
}
