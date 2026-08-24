/*
 * Loan Application, Loan Appraisal and Loan Repayment Schedule printouts.
 *
 * Unlike the Member Statement, almost none of this needs new business logic: the qualification
 * engine (lib/loanService.ts's appraise()/saveAppraisal()), the approval trail
 * (lib/workflow.ts's listWorkflowTasksForDocument()), guarantors, collateral and the repayment
 * schedule are all already fully modelled and used by the loan detail page
 * (app/loans/view/[id]/page.tsx) — this module just resolves a *set* of loans from a filter
 * (instead of one loan by id) and re-shapes each loan's existing data into a printable document.
 *
 * A few things the source design doc assumed have no real counterpart here and are deliberately
 * left out rather than fabricated: there is no "witness" concept, no "existing recoveries being
 * refinanced" concept, no payroll-transaction feed (affordability instead uses the member's
 * static gross_income/other_deductions — see appraise() in loanService.ts), no per-approver
 * signature image (only a member's own signature_image exists), and no separate "approved
 * amount" distinct from the applied principal (this system never re-prices a loan at appraisal
 * time — principal is principal throughout).
 */
import { all, one } from './db.ts';
import { getMember } from './members.ts';
import { listLoanAppraisals } from './loanService.ts';
import { listLoanCollateral } from './loanCollateral.ts';
import { listLoanProductCharges } from './loanProductCharges.ts';
import { calculateLoanProductCharges } from './loans.ts';
import { listWorkflowTasksForDocument } from './workflow.ts';
import { amountInWords } from './numberToWords.ts';
import { ageFromDob } from './format.ts';
import type {
  CalculatedLoanCharge, Cents, GuarantorRow, IsoDate, LoanAppraisalRow, LoanCollateralRow, LoanFull,
  LoanScheduleRow, MemberWithDimensions, WorkflowTaskWithApprover,
} from './types.ts';

export interface LoanSelectionFilters {
  loanIds?: number[];
  memberIds?: number[];
  productIds?: number[];
  statuses?: string[];
  appFrom?: IsoDate | null;
  appTo?: IsoDate | null;
}

/**
 * Resolves the set of loans a document batch covers.
 *
 * The design doc frames Loan No. and Member as "alternative entry points" (BC's own request
 * page has no equivalent — see §2 of the doc). Rather than an OR/union of two independently
 * complete result sets — ambiguous once Product/Status are added too — every supplied dimension
 * narrows the same query (AND), matching how every other filter bar in this app already behaves
 * (Member Statement's Account/Loan filters included). At least one dimension is required, so an
 * empty toolbar can never accidentally pull the entire loan book.
 */
async function resolveLoans(filters: LoanSelectionFilters): Promise<LoanFull[]> {
  const {
    loanIds, memberIds, productIds, statuses, appFrom, appTo,
  } = filters;
  if (!loanIds?.length && !memberIds?.length && !productIds?.length && !statuses?.length) return [];

  const clauses: string[] = [];
  if (loanIds?.length) clauses.push('l.id = ANY(@loanIds)');
  if (memberIds?.length) clauses.push('l.member_id = ANY(@memberIds)');
  if (productIds?.length) clauses.push('l.product_id = ANY(@productIds)');
  if (statuses?.length) clauses.push('l.status = ANY(@statuses)');
  if (appFrom) clauses.push('l.applied_date >= @appFrom');
  if (appTo) clauses.push('l.applied_date <= @appTo');

  return all<LoanFull>(
    `SELECT l.*, p.name AS product_name, p.code AS product_code,
            p.gl_receivable_id, p.gl_interest_income_id, p.gl_penalty_income_id,
            m.member_no, m.first_name, m.last_name, m.gross_income, m.other_deductions
     FROM loan l JOIN loan_product p ON p.id = l.product_id JOIN member m ON m.id = l.member_id
     WHERE ${clauses.join(' AND ')}
     ORDER BY l.id`,
    {
      loanIds: loanIds?.length ? loanIds : null,
      memberIds: memberIds?.length ? memberIds : null,
      productIds: productIds?.length ? productIds : null,
      statuses: statuses?.length ? statuses : null,
      appFrom: appFrom || null,
      appTo: appTo || null,
    },
  );
}

/* -------------------------------------------------------------- Loan Application */

export interface ApplicationGuarantor extends GuarantorRow {
  phone: string | null;
  email: string | null;
  identification_no: string | null;
  signature_image: string | null;
}

export interface LoanApplicationDocument {
  loan: LoanFull;
  applicant: MemberWithDimensions;
  age: number | null;
  disbursement: { accountNo: string; productName: string } | null;
  guarantors: ApplicationGuarantor[];
  amountInWords: string;
}

const applicationGuarantors = (loanId: number): Promise<ApplicationGuarantor[]> =>
  all<ApplicationGuarantor>(
    `SELECT g.*, m.member_no, m.first_name, m.last_name, m.phone, m.email, m.identification_no, m.signature_image
     FROM loan_guarantor g JOIN member m ON m.id = g.member_id WHERE g.loan_id = ?`,
    loanId,
  );

export async function buildLoanApplicationDocuments(filters: LoanSelectionFilters): Promise<LoanApplicationDocument[]> {
  const loans = await resolveLoans(filters);
  return Promise.all(loans.map(async (loan): Promise<LoanApplicationDocument> => {
    const [applicant, guarantors, disbursement] = await Promise.all([
      getMember(loan.member_id),
      applicationGuarantors(loan.id),
      loan.disburse_to_account_id
        ? one<{ account_no: string; product_name: string }>(
            `SELECT sa.account_no, p.name AS product_name
             FROM savings_account sa JOIN savings_product p ON p.id = sa.product_id WHERE sa.id = ?`,
            loan.disburse_to_account_id,
          )
        : Promise.resolve(undefined),
    ]);
    return {
      loan,
      applicant: applicant!,
      age: ageFromDob(applicant?.date_of_birth ?? null),
      disbursement: disbursement ? { accountNo: disbursement.account_no, productName: disbursement.product_name } : null,
      guarantors,
      amountInWords: amountInWords(loan.principal),
    };
  }));
}

/* -------------------------------------------------------------------- Loan Appraisal */

export interface ExistingLoanRow {
  loan_no: string;
  product_name: string;
  disbursed_date: IsoDate | null;
  installment: Cents;
  principal: Cents;
  balance: Cents;
  arrears_amount: Cents;
  classification: string;
}

const listOtherDisbursedLoans = (memberId: number, excludeLoanId: number): Promise<ExistingLoanRow[]> =>
  all<ExistingLoanRow>(
    `SELECT l.loan_no, p.name AS product_name, l.disbursed_date, l.installment, l.principal,
            (l.principal_balance + l.interest_balance) AS balance, l.arrears_amount, l.classification
     FROM loan l JOIN loan_product p ON p.id = l.product_id
     WHERE l.member_id = ? AND l.id <> ? AND l.status = 'DISBURSED'
     ORDER BY l.id`,
    memberId, excludeLoanId,
  );

export interface LoanAppraisalDocument {
  loan: LoanFull;
  applicant: MemberWithDimensions;
  age: number | null;
  appraisal: LoanAppraisalRow | null;
  guarantors: GuarantorRow[];
  collateral: LoanCollateralRow[];
  existingLoans: ExistingLoanRow[];
  charges: CalculatedLoanCharge[];
  approvals: WorkflowTaskWithApprover[];
}

export async function buildLoanAppraisalDocuments(filters: LoanSelectionFilters): Promise<LoanAppraisalDocument[]> {
  const loans = await resolveLoans(filters);
  return Promise.all(loans.map(async (loan): Promise<LoanAppraisalDocument> => {
    const [applicant, appraisals, guarantors, collateral, existingLoans, chargeLines, approvals] = await Promise.all([
      getMember(loan.member_id),
      listLoanAppraisals(loan.id),
      all<GuarantorRow>(
        `SELECT g.*, m.member_no, m.first_name, m.last_name
         FROM loan_guarantor g JOIN member m ON m.id = g.member_id WHERE g.loan_id = ?`,
        loan.id,
      ),
      listLoanCollateral(loan.id),
      listOtherDisbursedLoans(loan.member_id, loan.id),
      listLoanProductCharges(loan.product_id),
      listWorkflowTasksForDocument('LOAN', String(loan.id)),
    ]);
    return {
      loan,
      applicant: applicant!,
      age: ageFromDob(applicant?.date_of_birth ?? null),
      appraisal: appraisals[0] ?? null,
      guarantors,
      collateral,
      existingLoans,
      charges: calculateLoanProductCharges(chargeLines, loan.principal, loan.term_months),
      approvals,
    };
  }));
}

/* ------------------------------------------------------------ Loan Repayment Schedule */

export interface ScheduleRowWithBalance extends LoanScheduleRow {
  /** Balance immediately after this instalment — opening_balance minus this row's
   *  principal_due. loan_schedule has no stored running-balance column in this schema
   *  (unlike the design doc's assumed source table), so it is derived here from the two
   *  columns that are stored, which is exact since opening_balance already carries the
   *  correct pre-instalment balance forward row to row. */
  closingBalance: Cents;
}

export interface ScheduleTotals {
  principal: Cents;
  interest: Cents;
  instalment: Cents;
  paid: Cents;
  /** The balance after the last row of the *visible* window, not the loan's live
   *  principal_balance — narrowing expFrom/expTo changes this figure along with the rows,
   *  matching the source RDL's own =Sum(...) aggregates operating over rendered rows only. */
  outstanding: Cents;
}

export interface LoanScheduleDocument {
  loan: LoanFull;
  rows: ScheduleRowWithBalance[];
  totals: ScheduleTotals;
}

export async function buildLoanScheduleDocuments(
  filters: LoanSelectionFilters & { expFrom?: IsoDate | null; expTo?: IsoDate | null },
): Promise<LoanScheduleDocument[]> {
  const { expFrom, expTo, ...selection } = filters;
  const loans = await resolveLoans(selection);
  return Promise.all(loans.map(async (loan): Promise<LoanScheduleDocument> => {
    const rows = await all<LoanScheduleRow>(
      `SELECT * FROM loan_schedule WHERE loan_id = ?
         AND due_date >= COALESCE(?, '0000-01-01') AND due_date <= COALESCE(?, '9999-12-31')
       ORDER BY installment_no`,
      loan.id, expFrom || null, expTo || null,
    );
    const withBalance = rows.map((r) => ({ ...r, closingBalance: r.opening_balance - r.principal_due }));
    const totals = withBalance.reduce(
      (a, r) => ({
        principal: a.principal + r.principal_due,
        interest: a.interest + r.interest_due,
        instalment: a.instalment + r.principal_due + r.interest_due,
        paid: a.paid + r.principal_paid + r.interest_paid,
      }),
      { principal: 0, interest: 0, instalment: 0, paid: 0 },
    );
    const outstanding = withBalance.length
      ? withBalance[withBalance.length - 1].closingBalance
      : loan.principal_balance + loan.interest_balance;
    return { loan, rows: withBalance, totals: { ...totals, outstanding } };
  }));
}

/* --------------------------------------------------------------------- filter pickers */

export interface LoanOption { id: number; loan_no: string; member_no: string; first_name: string; last_name: string; }

/** The Loan filter's typeahead source — every loan, any status, since a batch print run
 *  (e.g. "everything pending my approval") routinely spans several statuses. */
export const listLoansForFilterPicker = (): Promise<LoanOption[]> =>
  all<LoanOption>(
    `SELECT l.id, l.loan_no, m.member_no, m.first_name, m.last_name
     FROM loan l JOIN member m ON m.id = l.member_id ORDER BY l.loan_no`,
  );
