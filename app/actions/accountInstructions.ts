'use server';

import { revalidatePath } from 'next/cache';
import { requireAction } from '@/lib/session';
import { actionResult } from '@/lib/errors';
import {
  saveAccountInstruction, deleteAccountInstruction,
  replaceApplicationAccountInstructions, replaceEditAccountInstructions,
  type AccountInstructionDraft,
} from '@/lib/accountInstructions';
import type { ActionResult, FormValues } from '@/lib/types';

const bool = (v: unknown): boolean => v === true || v === 'on' || v === '1' || v === 1;

/* ---------------------------------------------------------------- admin master */

export async function saveAccountInstructionRequest(values: FormValues): Promise<ActionResult<{ saved: true }>> {
  return actionResult(async () => {
    const user = await requireAction('ADMIN_ACCOUNT_INSTRUCTIONS_MANAGE');
    await saveAccountInstruction(
      {
        code: String(values.code || ''),
        description: String(values.description || ''),
        active: bool(values.active),
        sort: Number(values.sort || 0),
      },
      values.id ? Number(values.id) : null,
      user,
    );
    revalidatePath('/admin/pool/membership/account-instructions');
    return { saved: true };
  });
}

export async function deleteAccountInstructionRequest(id: number): Promise<ActionResult<{ deleted: true }>> {
  return actionResult(async () => {
    const user = await requireAction('ADMIN_ACCOUNT_INSTRUCTIONS_MANAGE');
    await deleteAccountInstruction(id, user);
    revalidatePath('/admin/pool/membership/account-instructions');
    return { deleted: true };
  });
}

/* ------------------------------------------------------------- document lines */

export async function saveApplicationAccountInstructions(
  applicationNo: string, rows: AccountInstructionDraft[],
): Promise<ActionResult<{ updated: true }>> {
  return actionResult(async () => {
    await requireAction('MEMBER_APPLICATIONS_UPDATE');
    await replaceApplicationAccountInstructions(applicationNo, rows);
    revalidatePath(`/member-applications/view/${applicationNo}`);
    return { updated: true };
  });
}

export async function saveEditAccountInstructions(
  editNo: string, rows: AccountInstructionDraft[],
): Promise<ActionResult<{ updated: true }>> {
  return actionResult(async () => {
    await requireAction('MEMBER_EDITS_UPDATE');
    await replaceEditAccountInstructions(editNo, rows);
    revalidatePath(`/member-edits/view/${editNo}`);
    return { updated: true };
  });
}

