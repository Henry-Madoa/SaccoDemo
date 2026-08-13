'use server';

import { revalidatePath } from 'next/cache';
import { requirePerm } from '@/lib/session';
import { actionResult, AppError } from '@/lib/errors';
import * as gl from '@/lib/gl';
import { toCents } from '@/lib/format';
import type {
  AccountingPeriod, ActionResult, FormValues, GlAccountType, JournalLineInput, PostedJournal,
} from '@/lib/types';

/*
 * The ledger and journal drill-downs open as modals over the list, as they did
 * in the SPA. They fetch on open rather than shipping every account's 500-line
 * ledger with the page.
 */
export async function fetchAccountLedger(code: string): Promise<ActionResult<gl.AccountLedger>> {
  return actionResult(async () => {
    await requirePerm('GL:READ');
    const ledger = await gl.getAccountLedger(code);
    if (!ledger) throw new AppError('Account not found', 'NOT_FOUND');
    return ledger;
  });
}

export async function fetchJournal(id: number): Promise<ActionResult<gl.JournalDetail>> {
  return actionResult(async () => {
    await requirePerm('GL:READ');
    const journal = await gl.getJournal(id);
    if (!journal) throw new AppError('Journal not found', 'NOT_FOUND');
    return journal;
  });
}

/** A manual journal line as typed into the entry grid. */
export interface JournalLineDraft {
  account: string;
  narration: string;
  debit: string;
  credit: string;
  globalDimension1Id: number | '';
  globalDimension2Id: number | '';
}

export async function createJournal(
  values: FormValues,
  lines: JournalLineDraft[],
): Promise<ActionResult<gl.CreateJournalResult>> {
  return actionResult(async () => {
    const user = await requirePerm('GL:JOURNAL_CREATE');
    const result = await gl.createJournal({
      valueDate: String(values.valueDate || ''),
      description: String(values.description || ''),
      lines: lines.map((l): JournalLineInput => ({
        account: l.account,
        narration: l.narration,
        debit: toCents(l.debit),
        credit: toCents(l.credit),
        globalDimension1Id: l.globalDimension1Id || null,
        globalDimension2Id: l.globalDimension2Id || null,
      })),
    }, user);
    revalidatePath('/accounting');
    revalidatePath('/reports');
    revalidatePath('/approvals');
    return result;
  });
}

export async function reverseJournal(id: number, values: FormValues): Promise<ActionResult<PostedJournal>> {
  return actionResult(async () => {
    const user = await requirePerm('GL:JOURNAL_APPROVE');
    const rev = await gl.reverseJournalEntry(id, String(values.reason || '').trim(), user);
    revalidatePath('/accounting');
    revalidatePath('/reports');
    return rev;
  });
}

export async function createGlAccount(values: FormValues): Promise<ActionResult<{ id: number }>> {
  return actionResult(async () => {
    const user = await requirePerm('ADMIN:COA_MANAGE');
    const created = await gl.createGlAccount({
      code: String(values.code || '').trim(),
      name: String(values.name || '').trim(),
      type: values.type as GlAccountType,
      parent_code: String(values.parent_code || '') || null,
      is_postable: Number(values.is_postable) ? 1 : 0,
    }, user);
    revalidatePath('/accounting/accounts');
    return created;
  });
}

export async function setPeriodStatus(code: string, status: string): Promise<ActionResult<AccountingPeriod>> {
  return actionResult(async () => {
    const user = await requirePerm('GL:PERIOD_CLOSE');
    const period = await gl.setPeriodStatus(code, status, user);
    revalidatePath('/accounting/periods');
    return period;
  });
}
