'use server';

import { revalidatePath } from 'next/cache';
import { requireAction } from '@/lib/session';
import { actionResult } from '@/lib/errors';
import {
  createLoanCalculator, deleteLoanCalculator, convertLoanCalculatorToLoan, previewLoanCalculatorSchedule,
  type CalculateLoanInput, type LoanCalculatorPreview,
} from '@/lib/loanCalculator';
import type { ActionResult, Cents, FormValues, IsoDate, LoanCalculatorRateType } from '@/lib/types';

const toInput = (values: FormValues): CalculateLoanInput => ({
  memberId: Number(values.memberId),
  productId: Number(values.productId),
  principal: Number(values.principal),
  termMonths: Number(values.termMonths),
  rateType: String(values.rateType) as LoanCalculatorRateType,
  repaymentStartDate: String(values.repaymentStartDate),
});

export async function saveLoanCalculation(values: FormValues): Promise<ActionResult<{ calcNo: string }>> {
  return actionResult(async () => {
    const user = await requireAction('LOAN_CALCULATOR_CREATE');
    const result = await createLoanCalculator(toInput(values), user);
    revalidatePath('/loan-calculator');
    return result;
  });
}

export async function deleteLoanCalculation(calcNo: string): Promise<ActionResult<{ deleted: true }>> {
  return actionResult(async () => {
    const user = await requireAction('LOAN_CALCULATOR_DELETE');
    await deleteLoanCalculator(calcNo, user);
    revalidatePath('/loan-calculator');
    return { deleted: true };
  });
}

export async function convertLoanCalculation(calcNo: string): Promise<ActionResult<{ loanId: number; loanNo: string }>> {
  return actionResult(async () => {
    const user = await requireAction('LOAN_CALCULATOR_CONVERT');
    const loan = await convertLoanCalculatorToLoan(calcNo, user);
    revalidatePath('/loan-calculator');
    revalidatePath(`/loan-calculator/view/${calcNo}`);
    revalidatePath('/loans');
    return { loanId: loan.id, loanNo: loan.loan_no };
  });
}

/** Live preview the New Calculation form re-runs on every input change. */
export async function previewLoanCalculation(
  memberId: number, productId: number, principal: Cents, termMonths: number,
  rateType: LoanCalculatorRateType, repaymentStartDate: IsoDate,
): Promise<ActionResult<LoanCalculatorPreview | null>> {
  return actionResult(async () => {
    await requireAction('LOAN_CALCULATOR_CREATE');
    return previewLoanCalculatorSchedule(memberId, productId, principal, termMonths, rateType, repaymentStartDate);
  });
}
