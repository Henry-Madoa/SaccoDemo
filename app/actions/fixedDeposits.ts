'use server';

import { revalidatePath } from 'next/cache';
import { requireAction, requireUser } from '@/lib/session';
import { actionResult } from '@/lib/errors';
import {
  createFixedDeposit, submitFixedDeposit, cancelFixedDepositApproval, approveFixedDeposit, rejectFixedDeposit,
  activateFixedDeposit, accrueFixedDepositInterest, matureFixedDeposit, terminateFixedDeposit,
  type CreateFixedDepositInput,
} from '@/lib/fixedDeposits';
import { findPendingRoutedTask, decideWorkflowTask } from '@/lib/workflow';
import { toCents } from '@/lib/format';
import type { ActionResult, FormValues } from '@/lib/types';

export async function requestFixedDeposit(values: FormValues): Promise<ActionResult<{ no: string }>> {
  return actionResult(async () => {
    const user = await requireAction('FIXED_DEPOSITS_CREATE');
    const input: CreateFixedDepositInput = {
      memberId: Number(values.memberId),
      fdTypeId: Number(values.fdTypeId),
      rate: Number(values.rate),
      amount: toCents(values.amount),
      maturityInstructions: values.maturityInstructions as CreateFixedDepositInput['maturityInstructions'],
      startDate: String(values.startDate || ''),
      termMonths: Number(values.termMonths),
    };
    const result = await createFixedDeposit(input, user);
    revalidatePath('/fixed-deposits');
    revalidatePath(`/members/${input.memberId}`);
    return result;
  });
}

export async function submitFixedDepositRequest(no: string): Promise<ActionResult<{ updated: true; autoApproved: boolean }>> {
  return actionResult(async () => {
    const user = await requireAction('FIXED_DEPOSITS_CREATE');
    const { autoApproved } = await submitFixedDeposit(no, user);
    revalidatePath('/fixed-deposits');
    revalidatePath(`/fixed-deposits/view/${no}`);
    return { updated: true, autoApproved };
  });
}

export async function cancelFixedDepositApprovalRequest(no: string): Promise<ActionResult<{ updated: true }>> {
  return actionResult(async () => {
    const user = await requireAction('FIXED_DEPOSITS_CREATE');
    await cancelFixedDepositApproval(no, user);
    revalidatePath('/fixed-deposits');
    revalidatePath(`/fixed-deposits/view/${no}`);
    return { updated: true };
  });
}

export async function approveFixedDepositRequest(no: string): Promise<ActionResult<{ updated: true }>> {
  return actionResult(async () => {
    const routed = await findPendingRoutedTask('FIXED_DEPOSIT', no);
    if (routed) {
      const user = await requireUser();
      await decideWorkflowTask(routed.id, true, null, user);
    } else {
      const user = await requireAction('FIXED_DEPOSITS_APPROVE');
      await approveFixedDeposit(no, user);
    }
    revalidatePath('/fixed-deposits');
    revalidatePath(`/fixed-deposits/view/${no}`);
    return { updated: true };
  });
}

export async function rejectFixedDepositRequest(no: string, reason: string): Promise<ActionResult<{ updated: true }>> {
  return actionResult(async () => {
    const routed = await findPendingRoutedTask('FIXED_DEPOSIT', no);
    if (routed) {
      const user = await requireUser();
      await decideWorkflowTask(routed.id, false, reason || null, user);
    } else {
      const user = await requireAction('FIXED_DEPOSITS_APPROVE');
      await rejectFixedDeposit(no, reason, user);
    }
    revalidatePath('/fixed-deposits');
    revalidatePath(`/fixed-deposits/view/${no}`);
    return { updated: true };
  });
}

export async function activateFixedDepositRequest(no: string): Promise<ActionResult<{ updated: true }>> {
  return actionResult(async () => {
    const user = await requireAction('FIXED_DEPOSITS_APPROVE');
    await activateFixedDeposit(no, user);
    revalidatePath('/fixed-deposits');
    revalidatePath(`/fixed-deposits/view/${no}`);
    return { updated: true };
  });
}

export async function accrueFixedDepositInterestRequest(no: string): Promise<ActionResult<{ postedLines: number }>> {
  return actionResult(async () => {
    const user = await requireAction('FIXED_DEPOSITS_APPROVE');
    const result = await accrueFixedDepositInterest(no, user);
    revalidatePath(`/fixed-deposits/view/${no}`);
    return result;
  });
}

export async function matureFixedDepositRequest(no: string): Promise<ActionResult<{ updated: true }>> {
  return actionResult(async () => {
    const user = await requireAction('FIXED_DEPOSITS_APPROVE');
    await matureFixedDeposit(no, user);
    revalidatePath('/fixed-deposits');
    revalidatePath(`/fixed-deposits/view/${no}`);
    return { updated: true };
  });
}

export async function terminateFixedDepositRequest(no: string): Promise<ActionResult<{ updated: true }>> {
  return actionResult(async () => {
    const user = await requireAction('FIXED_DEPOSITS_APPROVE');
    await terminateFixedDeposit(no, user);
    revalidatePath('/fixed-deposits');
    revalidatePath(`/fixed-deposits/view/${no}`);
    return { updated: true };
  });
}
