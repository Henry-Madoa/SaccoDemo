'use server';

import { revalidatePath } from 'next/cache';
import { requireAction } from '@/lib/session';
import { actionResult } from '@/lib/errors';
import * as salaryAppraisal from '@/lib/salaryAppraisal';
import type { SalaryAppraisalLineInput } from '@/lib/salaryAppraisal';
import type {
  ActionResult, FormValues, LoanSalaryAppraisalLine,
  SalaryAppraisalLineType, SalaryAppraisalParameter, SalaryAppraisalSpecialType,
} from '@/lib/types';

export async function createSalaryAppraisalParameter(values: FormValues): Promise<ActionResult<{ id: number }>> {
  return actionResult(async () => {
    const user = await requireAction('ADMIN_PRODUCTS_SALARY_PARAMS_MANAGE');
    const created = await salaryAppraisal.createSalaryAppraisalParameter(
      String(values.code || ''), String(values.name || ''),
      values.type as SalaryAppraisalLineType, (values.special_type || 'NONE') as SalaryAppraisalSpecialType,
      user,
    );
    revalidatePath('/admin/products/salary');
    return created;
  });
}

export async function updateSalaryAppraisalParameter(
  id: number, values: FormValues,
): Promise<ActionResult<SalaryAppraisalParameter>> {
  return actionResult(async () => {
    const user = await requireAction('ADMIN_PRODUCTS_SALARY_PARAMS_MANAGE');
    const updated = await salaryAppraisal.updateSalaryAppraisalParameter(
      id, String(values.name || ''), values.type as SalaryAppraisalLineType,
      (values.special_type || 'NONE') as SalaryAppraisalSpecialType,
      String(values.status || 'ACTIVE') as 'ACTIVE' | 'INACTIVE', user,
    );
    revalidatePath('/admin/products/salary');
    return updated;
  });
}

/** Bulk-saves the officer's typed-in Salary Appraisal amounts — the loan card's own "Save
 *  salary details" button, gated by the same LOAN_CREATE right Guarantors/Collateral edits use
 *  (this is a loan-application-drafting action, not a distinct permission of its own). */
export async function saveSalaryAppraisalLines(
  loanId: number, lines: SalaryAppraisalLineInput[],
): Promise<ActionResult<LoanSalaryAppraisalLine[]>> {
  return actionResult(async () => {
    const user = await requireAction('LOAN_CREATE');
    const result = await salaryAppraisal.saveSalaryAppraisalLines(loanId, lines, user);
    revalidatePath(`/loans/view/${loanId}`);
    return result;
  });
}
