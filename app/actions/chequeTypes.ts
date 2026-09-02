'use server';

import { revalidatePath } from 'next/cache';
import { requireAction } from '@/lib/session';
import { actionResult } from '@/lib/errors';
import { createChequeType, updateChequeType, type ChequeTypeInput } from '@/lib/chequeTypes';
import type { ActionResult, ChequeTypeKind, FormValues } from '@/lib/types';

const toInput = (values: FormValues): ChequeTypeInput => ({
  code: String(values.code || ''),
  type: String(values.type || 'BANKERS') as ChequeTypeKind,
  description: String(values.description || ''),
  maximumAmount: values.maximumAmount ? Math.round(Number(values.maximumAmount) * 100) : 0,
  clearingGlAccountId: Number(values.clearingGlAccountId),
  clearingChargeId: values.clearingChargeId ? Number(values.clearingChargeId) : null,
  bouncingChargeId: values.bouncingChargeId ? Number(values.bouncingChargeId) : null,
  expressChargeId: values.expressChargeId ? Number(values.expressChargeId) : null,
  inHouse: Number(values.inHouse) ? true : false,
  maturityDays: values.maturityDays ? Number(values.maturityDays) : 3,
  status: String(values.status || 'ACTIVE') as 'ACTIVE' | 'INACTIVE',
});

export async function saveChequeType(id: number | null, values: FormValues): Promise<ActionResult<{ id: number } | { updated: true }>> {
  return actionResult(async () => {
    const user = await requireAction('BANKERS_CHEQUES_TYPES_MANAGE');
    const res = id
      ? (await updateChequeType(id, toInput(values), user), { updated: true as const })
      : await createChequeType(toInput(values), user);
    revalidatePath('/bankers-cheques/cheque-types');
    revalidatePath('/bankers-cheques');
    revalidatePath('/cheque-deposits/cheque-types');
    revalidatePath('/cheque-deposits');
    return res;
  });
}
