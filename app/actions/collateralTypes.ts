'use server';

import { revalidatePath } from 'next/cache';
import { requireAction } from '@/lib/session';
import { actionResult } from '@/lib/errors';
import * as collateralTypes from '@/lib/collateralTypes';
import type { ActionResult, CollateralType, FormValues } from '@/lib/types';

export async function saveCollateralType(
  id: number | null, values: FormValues,
): Promise<ActionResult<CollateralType | { id: number }>> {
  return actionResult(async () => {
    const user = await requireAction('ADMIN_PRODUCTS_COLLATERAL_MANAGE');
    const body: collateralTypes.CollateralTypeInput = {
      code: String(values.code || ''),
      description: String(values.description || ''),
      category: String(values.category || ''),
      value_multiplier: Number(values.value_multiplier) || 0,
      status: String(values.status || 'ACTIVE'),
    };
    const result = id
      ? await collateralTypes.updateCollateralType(id, body, user)
      : await collateralTypes.createCollateralType(body, user);
    revalidatePath('/admin/products/collateral');
    return result;
  });
}
