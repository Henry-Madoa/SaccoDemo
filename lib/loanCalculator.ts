/*
 * Loan Calculator — a what-if repayment quote (Table 52204036 "Loan Calculator" / Table
 * 52204037 "Loan Calculator Lines" / Codeunit 52204008's GenerateCalculatorSchedule). A loan
 * officer picks a member and product, types a principal and term, and gets back the member's
 * deposit-multiplier headroom plus a full amortisation schedule under whichever Rate Type they
 * want to compare — without ever capturing an actual loan application. Each run is saved as a
 * new row (same shape as lib/loanService.ts's saveAppraisal()) and its own inputs/outputs are
 * never edited or recalculated in place, so a member's calculation history stays an honest
 * record of what was quoted and when. The one exception is status: an Open calculation can be
 * converted, once, into a real loan application (convertLoanCalculatorToLoan() below) — after
 * which it is Converted and permanently linked to the loan it produced.
 */
import {
  one, all, run, tx, nextSequence, hasAnyRow, audit,
} from './db.ts';
import { AppError } from './errors.ts';
import { buildSchedule, addMonths } from './loans.ts';
import { loanableDeposits, existingExposure, apply } from './loanService.ts';
import { buildFilterClause, type FilterCondition, type FilterFieldDef } from './listFilters.ts';
import { buildOrderClause, type SortState } from './listSort.ts';
import type {
  Actor, Cents, IsoDate, LoanCalculatorDetail, LoanCalculatorLine, LoanCalculatorListRow,
  LoanCalculatorRateType, LoanFull, LoanProduct, ScheduleDraftRow,
} from './types.ts';

const SELECT_ROW = `
  SELECT lc.*, m.member_no, m.first_name, m.last_name, p.name AS product_name, p.code AS product_code,
         cl.loan_no AS converted_loan_no
  FROM loan_calculator lc
  JOIN member m ON m.id = lc.member_id
  JOIN loan_product p ON p.id = lc.product_id
  LEFT JOIN loan cl ON cl.id = lc.converted_loan_id`;

export type LoanCalculatorView = 'open' | 'converted';

const VIEW_CLAUSE: Record<LoanCalculatorView, string> = {
  open: "lc.status = 'Open'",
  converted: "lc.status = 'Converted'",
};

/** Loan Calculator list's dynamic-filter registry — status is deliberately left out; the Open /
 *  Converted tabs are the primary way to narrow by it (same shape as lib/memberCharging.ts). */
export const LOAN_CALCULATOR_FILTER_FIELDS: FilterFieldDef[] = [
  { key: 'calc_no', label: 'No.', type: 'text', column: 'lc.calc_no' },
  { key: 'product_id', label: 'Product', type: 'select', column: 'lc.product_id' },
  { key: 'rate_type', label: 'Rate Type', type: 'select', column: 'lc.rate_type' },
  { key: 'principal', label: 'Principal', type: 'number', column: 'lc.principal' },
  { key: 'term_months', label: 'Installments (Months)', type: 'number', column: 'lc.term_months' },
  { key: 'created_by', label: 'Created By', type: 'text', column: 'lc.created_by' },
  { key: 'created_at', label: 'Created', type: 'date', column: 'lc.created_at', datetime: true },
];

const LOAN_CALCULATOR_SORT_COLUMNS: Record<string, string> = {
  calc_no: 'lc.calc_no',
  member: 'm.first_name',
  product_name: 'p.name',
  principal: 'lc.principal',
  rate_type: 'lc.rate_type',
  term_months: 'lc.term_months',
  installment: 'lc.installment',
  created_at: 'lc.created_at',
};

export interface ListLoanCalculatorsOptions {
  view?: LoanCalculatorView;
  search?: string;
  filters?: FilterCondition[];
  sort?: SortState | null;
}

export function listLoanCalculators(
  { view, search = '', filters = [], sort = null }: ListLoanCalculatorsOptions = {},
): Promise<LoanCalculatorListRow[]> {
  const { clause, params } = buildFilterClause(LOAN_CALCULATOR_FILTER_FIELDS, filters);
  const orderBy = buildOrderClause(LOAN_CALCULATOR_SORT_COLUMNS, sort, 'lc.id DESC');
  return all<LoanCalculatorListRow>(
    `${SELECT_ROW}
     WHERE (lc.calc_no LIKE @like OR m.member_no LIKE @like OR m.first_name LIKE @like OR m.last_name LIKE @like)
       ${view ? `AND ${VIEW_CLAUSE[view]}` : ''}
       ${clause}
     ${orderBy} LIMIT 300`,
    { like: `%${String(search).trim()}%`, ...params },
  );
}

/** Whether the current tab has any calculations at all, ignoring search and dynamic filters —
 *  lets the page grey out its filter controls only when there's truly nothing to filter. */
export const hasAnyLoanCalculators = (view?: LoanCalculatorView): Promise<boolean> =>
  hasAnyRow('loan_calculator lc', view ? VIEW_CLAUSE[view] : undefined);

export async function getAdjacentLoanCalculatorNos(
  calcNo: string, view?: LoanCalculatorView,
): Promise<{ prevNo: string | null; nextNo: string | null }> {
  const clause = view ? `AND ${VIEW_CLAUSE[view]}` : '';
  const [prev, next] = await Promise.all([
    one<{ calc_no: string }>(`SELECT lc.calc_no FROM loan_calculator lc WHERE lc.calc_no < ? ${clause} ORDER BY lc.calc_no DESC LIMIT 1`, calcNo),
    one<{ calc_no: string }>(`SELECT lc.calc_no FROM loan_calculator lc WHERE lc.calc_no > ? ${clause} ORDER BY lc.calc_no ASC LIMIT 1`, calcNo),
  ]);
  return { prevNo: prev?.calc_no ?? null, nextNo: next?.calc_no ?? null };
}

export async function getLoanCalculator(calcNo: string): Promise<LoanCalculatorDetail | null> {
  const calculator = await one<LoanCalculatorListRow>(`${SELECT_ROW} WHERE lc.calc_no = ?`, calcNo);
  if (!calculator) return null;
  const lines = await all<LoanCalculatorLine>(
    'SELECT * FROM loan_calculator_line WHERE calculator_id = ? ORDER BY installment_no', calculator.id,
  );
  return { calculator, lines };
}

/**
 * Constant-principal, declining-balance schedule — Table 52204036's "Reducing Balance" Rate
 * Type (Codeunit 52204008: LPrincipal := Principal / Installments; LInterest := Balance x
 * MonthlyRate). The one amortisation style buildSchedule() doesn't already cover: its FLAT is
 * Straight Line (constant interest, computed off the original principal) and its REDUCING is
 * Amortised (a level EMI installment) — see LoanCalculatorRateType's own doc comment.
 */
function buildDecliningPrincipalSchedule(
  principal: Cents, annualRate: number, months: number, firstDue: IsoDate,
): ScheduleDraftRow[] {
  const r = annualRate / 100 / 12;
  const basePrincipal = Math.floor(principal / months);
  const rows: ScheduleDraftRow[] = [];
  let balance = principal;
  for (let i = 1; i <= months; i++) {
    const pDue = i === months ? balance : basePrincipal;
    rows.push({
      installment_no: i,
      due_date: addMonths(firstDue, i - 1),
      opening_balance: balance,
      principal_due: pDue,
      interest_due: Math.round(balance * r),
    });
    balance -= pDue;
  }
  return rows;
}

/** Builds the projected schedule for any of the three Rate Types, sharing buildSchedule()'s
 *  Straight-Line/Amortised math and adding only the genuinely new Reducing-Balance case. */
export function buildLoanCalculatorSchedule(
  principal: Cents, annualRate: number, months: number, rateType: LoanCalculatorRateType, firstDue: IsoDate,
): ScheduleDraftRow[] {
  if (rateType === 'REDUCING_BALANCE') return buildDecliningPrincipalSchedule(principal, annualRate, months, firstDue);
  return buildSchedule(principal, annualRate, months, rateType === 'STRAIGHT_LINE' ? 'FLAT' : 'REDUCING', firstDue).rows;
}

export interface CalculateLoanInput {
  memberId: number;
  productId: number;
  principal: Cents;
  termMonths: number;
  rateType: LoanCalculatorRateType;
  repaymentStartDate: IsoDate;
}

/** Table 52204036's "Deposit Appraisal" group — current deposits, the product's own multiplier
 *  applied to them, existing loan exposure, and the resulting headroom — computed live from the
 *  same lib/loanService.ts readers the New Application form's own appraisal uses, so a
 *  calculator run and a real application never disagree about what a member currently qualifies
 *  for. */
export async function loanCalculatorAppraisal(memberId: number, product: LoanProduct): Promise<{
  currentDeposits: Cents; depositMultiplierAmount: Cents; outstandingLoans: Cents; depositAppraisal: Cents;
}> {
  const [currentDeposits, outstandingLoans] = await Promise.all([
    loanableDeposits(memberId), existingExposure(memberId),
  ]);
  const depositMultiplierAmount = Math.round(currentDeposits * product.deposit_multiplier);
  return {
    currentDeposits, depositMultiplierAmount, outstandingLoans,
    depositAppraisal: depositMultiplierAmount - outstandingLoans,
  };
}

/** Saves one Loan Calculator run: snapshots the deposit appraisal, builds the schedule under
 *  the chosen Rate Type, and persists both — the calculator header and its lines — in one
 *  transaction (Codeunit 52204008's GenerateCalculatorSchedule, folded into a single save
 *  instead of a separate "Calculate" action, since projecting a schedule has no side effect
 *  worth gating behind an extra click the way posting a real document does). */
export async function createLoanCalculator(input: CalculateLoanInput, user: Actor): Promise<{ calcNo: string }> {
  const principal = Math.round(input.principal);
  if (!(principal > 0)) throw new AppError('Principal amount must be greater than zero', 'INVALID_AMOUNT');
  const months = Math.round(input.termMonths);
  if (!(months > 0)) throw new AppError('Installments (months) must be greater than zero', 'INVALID_TERM');

  const member = await one<{ id: number }>('SELECT id FROM member WHERE id = ?', input.memberId);
  if (!member) throw new AppError('Member not found', 'NOT_FOUND');
  const product = await one<LoanProduct>('SELECT * FROM loan_product WHERE id = ?', input.productId);
  if (!product) throw new AppError('Loan product not found', 'PRODUCT_NOT_FOUND');
  if (months > product.max_term_months) {
    throw new AppError(`Installments cannot exceed ${product.max_term_months} months for ${product.name}`, 'INVALID_TERM');
  }

  const appraisal = await loanCalculatorAppraisal(input.memberId, product);
  const rows = buildLoanCalculatorSchedule(
    principal, product.interest_rate, months, input.rateType, input.repaymentStartDate,
  );
  const totalInterest = rows.reduce((sum, r) => sum + r.interest_due, 0);

  const calcNo = await nextSequence('LOAN_CALCULATOR');
  await tx(async () => {
    const header = await run(
      `INSERT INTO loan_calculator
         (calc_no, member_id, product_id, principal, interest_rate, rate_type, term_months, repayment_start_date,
          current_deposits, deposit_multiplier_amount, outstanding_loans, deposit_appraisal,
          installment, total_interest, created_at, created_by)
       VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)`,
      calcNo, input.memberId, input.productId, principal, product.interest_rate, input.rateType, months,
      input.repaymentStartDate, appraisal.currentDeposits, appraisal.depositMultiplierAmount,
      appraisal.outstandingLoans, appraisal.depositAppraisal,
      rows[0] ? rows[0].principal_due + rows[0].interest_due : 0, totalInterest,
      new Date().toISOString(), user.username,
    );
    const calculatorId = header.lastInsertRowid;
    for (const r of rows) {
      await run(
        `INSERT INTO loan_calculator_line
           (calculator_id, installment_no, due_date, opening_balance, principal_due, interest_due,
            installment_amount, closing_balance)
         VALUES (?,?,?,?,?,?,?,?)`,
        calculatorId, r.installment_no, r.due_date, r.opening_balance, r.principal_due, r.interest_due,
        r.principal_due + r.interest_due, r.opening_balance - r.principal_due,
      );
    }
  });

  await audit(user, 'LOAN_CALCULATOR_CREATE', 'loan_calculator', calcNo, { memberId: input.memberId, productId: input.productId, principal, months, rateType: input.rateType });
  return { calcNo };
}

export interface LoanCalculatorPreview {
  currentDeposits: Cents;
  depositMultiplierAmount: Cents;
  outstandingLoans: Cents;
  depositAppraisal: Cents;
  interestRate: number;
  installment: Cents;
  totalInterest: Cents;
  rows: ScheduleDraftRow[];
}

/** The live preview the New Calculation form re-runs on every input change — the same deposit
 *  appraisal and schedule createLoanCalculator() would persist, computed but not saved, so an
 *  officer can compare Rate Types and terms before committing a run to history. */
export async function previewLoanCalculatorSchedule(
  memberId: number, productId: number, principal: Cents, termMonths: number,
  rateType: LoanCalculatorRateType, repaymentStartDate: IsoDate,
): Promise<LoanCalculatorPreview | null> {
  if (!memberId || !productId || !(principal > 0) || !(termMonths > 0) || !repaymentStartDate) return null;
  const product = await one<LoanProduct>('SELECT * FROM loan_product WHERE id = ?', productId);
  if (!product) throw new AppError('Loan product not found', 'PRODUCT_NOT_FOUND');
  if (termMonths > product.max_term_months) {
    throw new AppError(`Installments cannot exceed ${product.max_term_months} months for ${product.name}`, 'INVALID_TERM');
  }
  const appraisal = await loanCalculatorAppraisal(memberId, product);
  const rows = buildLoanCalculatorSchedule(Math.round(principal), product.interest_rate, Math.round(termMonths), rateType, repaymentStartDate);
  return {
    ...appraisal,
    interestRate: product.interest_rate,
    installment: rows[0] ? rows[0].principal_due + rows[0].interest_due : 0,
    totalInterest: rows.reduce((sum, r) => sum + r.interest_due, 0),
    rows,
  };
}

export async function deleteLoanCalculator(calcNo: string, user: Actor): Promise<void> {
  const existing = await one<{ id: number; status: string }>('SELECT id, status FROM loan_calculator WHERE calc_no = ?', calcNo);
  if (!existing) throw new AppError('Loan calculation not found', 'NOT_FOUND');
  if (existing.status !== 'Open') throw new AppError('A calculation that has been converted to a loan application cannot be deleted', 'VALIDATION');
  await tx(async () => {
    await run('DELETE FROM loan_calculator_line WHERE calculator_id = ?', existing.id);
    await run('DELETE FROM loan_calculator WHERE id = ?', existing.id);
  });
  await audit(user, 'LOAN_CALCULATOR_DELETE', 'loan_calculator', calcNo, {});
}

/**
 * Converts an Open calculation into a real loan application — Codeunit 52204008's implicit
 * "the calculator is a pre-application scratchpad" made explicit as a one-way action. Reuses
 * lib/loanService.ts's own apply() rather than re-deriving loan-creation logic, so a converted
 * loan starts out identical to one captured directly on the Loans page (status OPEN, no
 * guarantors yet, product's own interest rate/method — not the calculator's snapshot, in case
 * the product changed since). The calculation itself flips to Converted and is linked to the
 * new loan; like deleteLoanCalculator's own guard, this is checked again here so a second click
 * (or a stale page) can't create two loans from the same calculation.
 */
export async function convertLoanCalculatorToLoan(calcNo: string, user: Actor): Promise<LoanFull> {
  const loan = await tx(async () => {
    const existing = await one<{
      id: number; status: string; member_id: number; product_id: number; principal: number; term_months: number;
    }>('SELECT id, status, member_id, product_id, principal, term_months FROM loan_calculator WHERE calc_no = ?', calcNo);
    if (!existing) throw new AppError('Loan calculation not found', 'NOT_FOUND');
    if (existing.status !== 'Open') throw new AppError('This calculation has already been converted to a loan application', 'VALIDATION');

    const created = await apply({
      memberId: existing.member_id, productId: existing.product_id, principal: existing.principal,
      termMonths: existing.term_months, purpose: `Converted from Loan Calculator ${calcNo}`, user,
    });
    await run(
      `UPDATE loan_calculator SET status = 'Converted', converted_loan_id = ?, converted_at = ?, converted_by = ? WHERE id = ?`,
      created.id, new Date().toISOString(), user.username, existing.id,
    );
    return created;
  });

  await audit(user, 'LOAN_CALCULATOR_CONVERT', 'loan_calculator', calcNo, { loanId: loan.id, loanNo: loan.loan_no });
  return loan;
}
