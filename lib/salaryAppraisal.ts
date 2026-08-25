/*
 * Salary Appraisal Parameters — modeled on the reference AL system's "Loanees Payroll Codes" /
 * "Loanees Payroll Transactions" (Tables 52204034/52204035): a global master list of predefined
 * payslip line items (earnings like Basic Salary, deductions like PAYE/NHIF/loan repayments)
 * that gets auto-seeded onto a loan the moment a "salary based" product (loan_product.
 * salary_based) is chosen, so the officer can type in amounts to mimic the member's actual
 * payslip instead of typing one opaque gross-income figure.
 *
 * Unlike the AL reference, the "1/3 rule" cap is never stored as a fake deduction row (that
 * whole procedure is dead/commented-out code there) — it is always a derived read-only figure,
 * computeSalaryTotals()'s oneThirdCap, so the totals stay honest.
 */
import { all, one, run, audit } from './db.ts';
import { AppError, PostingError } from './errors.ts';
import { diffFields, logTableChange } from './changeLog.ts';
import type {
  Actor, Cents, LoanSalaryAppraisalLine, SalaryAppraisalLineType, SalaryAppraisalParameter,
  SalaryAppraisalSpecialType,
} from './types.ts';

/** Re-exported so server callers (loanService.ts's appraise()) can import both the CRUD and the
 *  totals arithmetic from this one module — the pure calculation itself lives in
 *  salaryAppraisalCalc.ts so the loan card can also import it directly into the browser bundle. */
export { computeSalaryTotals } from './salaryAppraisalCalc.ts';

/* --------------------------------------------------------------- parameter master */

export const listSalaryAppraisalParameters = (): Promise<SalaryAppraisalParameter[]> =>
  all<SalaryAppraisalParameter>('SELECT * FROM salary_appraisal_parameter ORDER BY sort_order, code');

export const listActiveSalaryAppraisalParameters = (): Promise<SalaryAppraisalParameter[]> =>
  all<SalaryAppraisalParameter>(
    "SELECT * FROM salary_appraisal_parameter WHERE status = 'ACTIVE' ORDER BY sort_order, code",
  );

export async function createSalaryAppraisalParameter(
  code: string, name: string, type: SalaryAppraisalLineType, specialType: SalaryAppraisalSpecialType,
  user: Actor,
): Promise<{ id: number }> {
  code = code.trim().toUpperCase();
  name = name.trim();
  if (!code || !name) throw new AppError('Code and name are required', 'VALIDATION');
  if (await one('SELECT 1 FROM salary_appraisal_parameter WHERE code = ?', code)) {
    throw new AppError('Parameter code already exists', 'DUPLICATE');
  }
  if (specialType === 'BASIC_SALARY' && type !== 'EARNING') {
    throw new AppError('Only an Earning line can be flagged Basic Salary', 'VALIDATION');
  }
  const info = await run(
    `INSERT INTO salary_appraisal_parameter (code, name, type, special_type) VALUES (?,?,?,?)`,
    code, name, type, specialType,
  );
  await audit(user, 'SALARY_APPRAISAL_PARAMETER_CREATE', 'salary_appraisal_parameter', info.lastInsertRowid, { code });
  return { id: Number(info.lastInsertRowid) };
}

export async function updateSalaryAppraisalParameter(
  id: number, name: string, type: SalaryAppraisalLineType, specialType: SalaryAppraisalSpecialType,
  status: 'ACTIVE' | 'INACTIVE', user: Actor,
): Promise<SalaryAppraisalParameter> {
  const before = await one<SalaryAppraisalParameter>('SELECT * FROM salary_appraisal_parameter WHERE id = ?', id);
  if (!before) throw new AppError('Parameter not found', 'NOT_FOUND');
  name = name.trim();
  if (!name) throw new AppError('Name is required', 'VALIDATION');
  if (specialType === 'BASIC_SALARY' && type !== 'EARNING') {
    throw new AppError('Only an Earning line can be flagged Basic Salary', 'VALIDATION');
  }
  await run(
    'UPDATE salary_appraisal_parameter SET name = ?, type = ?, special_type = ?, status = ? WHERE id = ?',
    name, type, specialType, status, id,
  );
  const changes = diffFields(
    before as unknown as Record<string, unknown>, { name, type, special_type: specialType, status },
  );
  await logTableChange('salary_appraisal_parameter', before.code, 'Modification', changes, user);
  return (await one<SalaryAppraisalParameter>('SELECT * FROM salary_appraisal_parameter WHERE id = ?', id))!;
}

/* -------------------------------------------------------------- per-loan lines */

export const listLoanSalaryAppraisalLines = (loanId: number): Promise<LoanSalaryAppraisalLine[]> =>
  all<LoanSalaryAppraisalLine>(
    `SELECT l.*, COALESCE(p.sort_order, 999) AS sort_order
     FROM loan_salary_appraisal_line l LEFT JOIN salary_appraisal_parameter p ON p.id = l.parameter_id
     WHERE l.loan_id = ? ORDER BY l.type, sort_order, l.code`,
    loanId,
  );

/**
 * Seeds a loan's Salary Appraisal section, and keeps its auto-derived rows current. Called
 * whenever the loan card is viewed for a salary-based product, and after apply()/update() pick
 * one — so it is always safe to call and always cheap to no-op:
 *
 *  1. If no parameter-linked line exists yet for this loan, seed one per active
 *     salary_appraisal_parameter at amount 0, snapshotting its code/name/type so a later edit
 *     to the master parameter never rewrites an already-captured loan's history.
 *  2. Always resync the LOAN_DEDUCTION rows: delete the ones on file and reinsert one per the
 *     member's *other* DISBURSED loans, amount = that loan's installment, read-only — so
 *     obligations always reflect current state while hand-typed earning/deduction amounts are
 *     left untouched.
 */
export async function ensureSalaryAppraisalLines(loanId: number, memberId: number): Promise<LoanSalaryAppraisalLine[]> {
  const hasLines = await one('SELECT 1 FROM loan_salary_appraisal_line WHERE loan_id = ? AND parameter_id IS NOT NULL', loanId);
  if (!hasLines) {
    const params = await listActiveSalaryAppraisalParameters();
    for (const p of params) {
      await run(
        `INSERT INTO loan_salary_appraisal_line (loan_id, parameter_id, code, name, type, special_type, amount, editable)
         VALUES (?,?,?,?,?,?,0,true)
         ON CONFLICT (loan_id, code) DO NOTHING`,
        loanId, p.id, p.code, p.name, p.type, p.special_type,
      );
    }
  }

  await run("DELETE FROM loan_salary_appraisal_line WHERE loan_id = ? AND special_type = 'LOAN_DEDUCTION'", loanId);
  const otherLoans = await all<{ loan_no: string; product_description: string; installment: Cents }>(
    `SELECT o.loan_no, p.name AS product_description, o.installment
     FROM loan o JOIN loan_product p ON p.id = o.product_id
     WHERE o.member_id = ? AND o.id <> ? AND o.status = 'DISBURSED' AND o.installment > 0`,
    memberId, loanId,
  );
  for (const o of otherLoans) {
    await run(
      `INSERT INTO loan_salary_appraisal_line (loan_id, parameter_id, code, name, type, special_type, amount, editable)
       VALUES (?,NULL,?,?,'DEDUCTION','LOAN_DEDUCTION',?,false)
       ON CONFLICT (loan_id, code) DO UPDATE SET amount = EXCLUDED.amount`,
      loanId, `LOAN-${o.loan_no}`, `${o.product_description} (${o.loan_no})`, o.installment,
    );
  }

  return listLoanSalaryAppraisalLines(loanId);
}

export interface SalaryAppraisalLineInput {
  code: string;
  amount: Cents;
}

/** Bulk-saves the officer's typed-in amounts — only ever the editable (parameter-linked) rows;
 *  the auto-derived LOAN_DEDUCTION rows are silently ignored if submitted, since they are never
 *  user input. Only while the loan is still OPEN, the same window Guarantors/Collateral stay
 *  editable in. */
export async function saveSalaryAppraisalLines(
  loanId: number, lines: SalaryAppraisalLineInput[], user: Actor,
): Promise<LoanSalaryAppraisalLine[]> {
  const loan = await one<{ status: string }>('SELECT status FROM loan WHERE id = ?', loanId);
  if (!loan) throw new PostingError('Loan not found', 'NOT_FOUND');
  if (loan.status !== 'OPEN') throw new PostingError(`Loan is ${loan.status} and its salary appraisal can no longer be edited`, 'BAD_STATUS');

  for (const l of lines) {
    await run(
      "UPDATE loan_salary_appraisal_line SET amount = ? WHERE loan_id = ? AND code = ? AND editable = true",
      Math.round(l.amount) || 0, loanId, l.code,
    );
  }
  await audit(user, 'SALARY_APPRAISAL_LINES_SAVE', 'loan', loanId, { lines: lines.length });
  return listLoanSalaryAppraisalLines(loanId);
}
