'use server';

import { revalidatePath } from 'next/cache';
import { requireAction } from '@/lib/session';
import { actionResult } from '@/lib/errors';
import * as savings from '@/lib/savings';
import type { ActionResult, Cents, FormValues } from '@/lib/types';

// Manual counter deposits/withdrawals moved to the Cash Deposits & Withdrawals (teller) module —
// see app/actions/tellerTransactions.ts. Reversal of an already-posted savings entry stays here.

export async function reverseTransaction(
  accountId: number,
  values: FormValues,
): Promise<ActionResult<{ balance: Cents; journal_no: string }>> {
  return actionResult(async () => {
    const user = await requireAction('SAVINGS_REVERSE');
    const result = await savings.reverseTxn({
      txnId: Number(values.txnId),
      reason: String(values.reason || '').trim(),
      user,
    });
    revalidatePath(`/savings/${accountId}`);
    return result;
  });
}
