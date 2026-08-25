/*
 * Pure Salary Appraisal arithmetic — no database import, so the loan card's Salary Appraisal
 * section can recompute its live summary in the browser on every keystroke, the same reason
 * lib/loans.ts's calculateLoanProductCharges is split out from lib/loanProductCharges.ts's
 * server-only CRUD.
 */
import type { LoanSalaryAppraisalLine, SalaryAppraisalTotals } from './types.ts';

/** Gross, deductions, the Basic Salary line, and the one-third affordability cap derived from
 *  it — shared by the loan card's live summary and appraise()'s AFFORDABILITY factor, so both
 *  read the same numbers off the same lines. */
export function computeSalaryTotals(
  lines: Pick<LoanSalaryAppraisalLine, 'type' | 'special_type' | 'amount'>[],
): SalaryAppraisalTotals {
  const gross = lines.filter((l) => l.type === 'EARNING').reduce((s, l) => s + l.amount, 0);
  const totalDeductions = lines.filter((l) => l.type === 'DEDUCTION').reduce((s, l) => s + l.amount, 0);
  const basicSalary = lines.find((l) => l.special_type === 'BASIC_SALARY')?.amount ?? 0;
  const oneThirdCap = Math.round(basicSalary / 3);
  return { gross, totalDeductions, basicSalary, oneThirdCap, headroom: oneThirdCap - totalDeductions };
}
