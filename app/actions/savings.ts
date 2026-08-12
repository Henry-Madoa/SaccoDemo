'use server';

import { revalidatePath } from 'next/cache';
import { requirePerm } from '@/lib/session';
import { actionResult } from '@/lib/errors';
import * as savings from '@/lib/savings';
import { toCents } from '@/lib/format';
import type { ActionResult, Cents, Channel, FormValues, SavingsAccountFull } from '@/lib/types';

export async function openSavingsAccount(values: FormValues): Promise<ActionResult<SavingsAccountFull>> {
  return actionResult(async () => {
    const user = await requirePerm('SAVINGS:OPEN');
    const account = await savings.openAccount({
      memberId: Number(values.memberId),
      productId: Number(values.productId),
      openingBalance: toCents(values.openingBalance),
      channel: values.channel as Channel,
      user,
    });
    revalidatePath('/savings');
    revalidatePath(`/members/${values.memberId}`);
    return account;
  });
}

export async function postDeposit(values: FormValues): Promise<ActionResult<savings.PostingResult>> {
  return actionResult(async () => {
    const user = await requirePerm('SAVINGS:DEPOSIT');
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
    const user = await requirePerm('SAVINGS:WITHDRAW');
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
    const user = await requirePerm('SAVINGS:REVERSE');
    const result = await savings.reverseTxn({
      txnId: Number(values.txnId),
      reason: String(values.reason || '').trim(),
      user,
    });
    revalidatePath(`/savings/${accountId}`);
    return result;
  });
}
