'use server';

import { revalidatePath } from 'next/cache';
import { requireAction } from '@/lib/session';
import { actionResult } from '@/lib/errors';
import * as fixedDepositTypes from '@/lib/fixedDepositTypes';
import type { ActionResult, FormValues, MemberFixedDepositType } from '@/lib/types';

export async function saveFixedDepositType(
  id: number | null, values: FormValues,
): Promise<ActionResult<MemberFixedDepositType | { id: number }>> {
  return actionResult(async () => {
    const user = await requireAction('ADMIN_PRODUCTS_FD_MANAGE');
    const body: fixedDepositTypes.MemberFixedDepositTypeInput = {
      code: String(values.code || ''),
      description: String(values.description || ''),
      min_interest_rate: Number(values.min_interest_rate) || 0,
      max_interest_rate: Number(values.max_interest_rate) || 0,
      interest_calc_type: String(values.interest_calc_type || 'FLAT'),
      linked_product_id: Number(values.linked_product_id) || null,
      interest_expense_gl_id: Number(values.interest_expense_gl_id) || null,
      interest_payable_gl_id: Number(values.interest_payable_gl_id) || null,
      withholding_tax_rate: Number(values.withholding_tax_rate) || 0,
      withholding_tax_gl_id: values.withholding_tax_gl_id ? Number(values.withholding_tax_gl_id) : null,
      status: String(values.status || 'ACTIVE'),
    };
    const result = id
      ? await fixedDepositTypes.updateFixedDepositType(id, body, user)
      : await fixedDepositTypes.createFixedDepositType(body, user);
    revalidatePath('/admin/products/fixed-deposit-types');
    return result;
  });
}

/** Active fixed deposit types, for the New Fixed Deposit form's picklist. */
export async function activeFixedDepositTypes(): Promise<ActionResult<MemberFixedDepositType[]>> {
  return actionResult(async () => {
    await requireAction('FIXED_DEPOSITS_CREATE');
    return fixedDepositTypes.listActiveFixedDepositTypes();
  });
}
