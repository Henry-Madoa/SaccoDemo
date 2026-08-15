'use server';

import { revalidatePath } from 'next/cache';
import { requireAction } from '@/lib/session';
import { actionResult } from '@/lib/errors';
import * as savings from '@/lib/savings';
import { toCents } from '@/lib/format';
import type { ActionResult, Cents, Channel, FormValues } from '@/lib/types';

export async function postDeposit(values: FormValues): Promise<ActionResult<savings.PostingResult>> {
  return actionResult(async () => {
    const user = await requireAction('SAVINGS_DEPOSIT');
    const result = await savings.deposit({
      accountId: Number(values.accountId),
      amount: toCents(values.amount),
      channel: values.channel as Channel,
      valueDate: String(values.valueDate || ''),
      description: String(values.description || ''),
      user,
    });
    revalidatePath('/savings');
    revalidatePath(`/savings/${values.accountId}`);
    return result;
  });
}

export async function postWithdrawal(values: FormValues): Promise<ActionResult<savings.PostingResult>> {
  return actionResult(async () => {
    const user = await requireAction('SAVINGS_WITHDRAW');
    const result = await savings.withdraw({
      accountId: Number(values.accountId),
      amount: toCents(values.amount),
      channel: values.channel as Channel,
      valueDate: String(values.valueDate || ''),
      description: String(values.description || ''),
      user,
    });
    revalidatePath('/savings');
    revalidatePath(`/savings/${values.accountId}`);
    return result;
  });
}

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
