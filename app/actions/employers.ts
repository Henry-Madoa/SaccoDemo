'use server';

import { revalidatePath } from 'next/cache';
import { requireAction } from '@/lib/session';
import { actionResult } from '@/lib/errors';
import {
  createEmployer, updateEmployer, setMemberEmployer, type EmployerInput,
} from '@/lib/employers';
import type { ActionResult, Employer, FormValues } from '@/lib/types';

function normalise(values: FormValues): EmployerInput {
  const body: EmployerInput = { ...values } as EmployerInput;
  if (values.payroll_no_mandatory !== undefined) {
    body.payroll_no_mandatory = !!Number(values.payroll_no_mandatory);
  }
  return body;
}

export async function createEmployerRequest(values: FormValues): Promise<ActionResult<{ id: number }>> {
  return actionResult(async () => {
    const user = await requireAction('EMPLOYERS_MANAGE');
    const result = await createEmployer(normalise(values), user);
    revalidatePath('/admin/products/employers');
    return result;
  });
}

export async function updateEmployerRequest(id: number, values: FormValues): Promise<ActionResult<Employer>> {
  return actionResult(async () => {
    const user = await requireAction('EMPLOYERS_MANAGE');
    const result = await updateEmployer(id, normalise(values), user);
    revalidatePath('/admin/products/employers');
    return result;
  });
}

export async function setMemberEmployerRequest(
  memberId: number, employerId: number | null,
): Promise<ActionResult<{ updated: true }>> {
  return actionResult(async () => {
    const user = await requireAction('MEMBERS_UPDATE');
    await setMemberEmployer(memberId, employerId, user);
    revalidatePath(`/members/${memberId}`);
    return { updated: true };
  });
}
