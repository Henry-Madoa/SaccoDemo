'use server';

import { revalidatePath } from 'next/cache';
import { requireAction } from '@/lib/session';
import { actionResult } from '@/lib/errors';
import { upsertTellerSetup, deleteTellerSetup } from '@/lib/tellerSetup';
import { listActiveBankAccounts } from '@/lib/gl';
import type { ActionResult, BankAccount, FormValues } from '@/lib/types';

export async function saveTellerSetup(values: FormValues): Promise<ActionResult<{ id: number }>> {
  return actionResult(async () => {
    const user = await requireAction('TELLER_SETUP_MANAGE');
    const res = await upsertTellerSetup({
      userUsername: String(values.userUsername || ''),
      setupType: String(values.setupType || 'TELLER') as 'TELLER' | 'TREASURY',
      bankAccountId: Number(values.bankAccountId),
      maxCapacity: values.maxCapacity ? Math.round(Number(values.maxCapacity) * 100) : 0,
      minCapacity: values.minCapacity ? Math.round(Number(values.minCapacity) * 100) : 0,
      approvalLimit: values.approvalLimit ? Math.round(Number(values.approvalLimit) * 100) : 0,
    }, user);
    revalidatePath('/admin/pool/teller-setup');
    return res;
  });
}

export async function removeTellerSetup(id: number): Promise<ActionResult<{ deleted: true }>> {
  return actionResult(async () => {
    const user = await requireAction('TELLER_SETUP_MANAGE');
    await deleteTellerSetup(id, user);
    revalidatePath('/admin/pool/teller-setup');
    return { deleted: true };
  });
}

/** Bank/cash accounts — the picker filters by account_type client-side per the chosen setup type. */
export async function bankAccountsForTellerSetup(): Promise<ActionResult<BankAccount[]>> {
  return actionResult(async () => {
    await requireAction('TELLER_SETUP_MANAGE');
    return listActiveBankAccounts();
  });
}
