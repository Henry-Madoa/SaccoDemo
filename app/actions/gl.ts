'use server';

import { revalidatePath } from 'next/cache';
import { requireAction } from '@/lib/session';
import { actionResult, AppError } from '@/lib/errors';
import * as gl from '@/lib/gl';
import { toCents } from '@/lib/format';
import type { FilterCondition } from '@/lib/listFilters';
import type {
  AccountingPeriod, ActionResult, FormValues, GlAccount, GlAccountStructureType, GlAccountType,
  JournalLineInput, JournalRelatedEntries, PostedJournal,
} from '@/lib/types';

/*
 * The ledger and journal drill-downs open as modals over the list, as they did
 * in the SPA. They fetch on open rather than shipping every account's 500-line
 * ledger with the page.
 */
export async function fetchAccountLedger(
  code: string,
  opts: { from?: string; asOf?: string; filters?: FilterCondition[] } = {},
): Promise<ActionResult<gl.AccountLedger>> {
  return actionResult(async () => {
    await requireAction('GL_READ');
    const ledger = await gl.getAccountLedger(code, {
      from: opts.from || null, asOf: opts.asOf || null, filters: opts.filters,
    });
    if (!ledger) throw new AppError('Account not found', 'NOT_FOUND');
    return ledger;
  });
}

export async function fetchJournal(id: number): Promise<ActionResult<gl.JournalDetail>> {
  return actionResult(async () => {
    await requireAction('GL_READ');
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
    const user = await requireAction('GL_JOURNAL_CREATE');
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
    const user = await requireAction('GL_JOURNAL_REVERSE');
    const rev = await gl.reverseJournalEntry(id, String(values.reason || '').trim(), user);
    revalidatePath('/accounting');
    revalidatePath('/reports');
    return rev;
  });
}

/** Find Entries / Navigate — every subledger entry sharing this journal, for the "Related
 *  entries" section of the journal modal. */
export async function fetchJournalRelatedEntries(journalId: number): Promise<ActionResult<JournalRelatedEntries>> {
  return actionResult(async () => {
    await requireAction('GL_READ');
    return gl.getJournalRelatedEntries(journalId);
  });
}

export async function createBankAccount(values: FormValues): Promise<ActionResult<{ id: number }>> {
  return actionResult(async () => {
    const user = await requireAction('GL_ACCOUNT_MANAGE');
    const created = await gl.createBankAccount({
      code: String(values.code || ''),
      name: String(values.name || ''),
      gl_account_id: Number(values.gl_account_id),
      bank_name: String(values.bank_name || '') || null,
      account_no: String(values.account_no || '') || null,
    }, user);
    revalidatePath('/accounting');
    return created;
  });
}

export async function updateBankAccount(id: number, values: FormValues): Promise<ActionResult<{ id: number }>> {
  return actionResult(async () => {
    const user = await requireAction('GL_ACCOUNT_MANAGE');
    await gl.updateBankAccount(id, {
      name: String(values.name || ''),
      bank_name: String(values.bank_name || '') || null,
      account_no: String(values.account_no || '') || null,
      status: (String(values.status || 'ACTIVE') as 'ACTIVE' | 'INACTIVE'),
    }, user);
    revalidatePath('/accounting');
    return { id };
  });
}

export async function startBankReconciliation(
  bankAccountId: number, values: FormValues,
): Promise<ActionResult<{ id: number }>> {
  return actionResult(async () => {
    const user = await requireAction('GL_BANK_RECONCILE');
    const rec = await gl.startBankReconciliation(
      bankAccountId, String(values.statementDate || ''), toCents(String(values.statementBalance || '0')), user,
    );
    revalidatePath('/accounting');
    return rec;
  });
}

export async function toggleReconciledEntry(
  entryId: number, reconciliationId: number, reconciled: boolean,
): Promise<ActionResult<{ ok: true }>> {
  return actionResult(async () => {
    const user = await requireAction('GL_BANK_RECONCILE');
    await gl.setEntryReconciled(entryId, reconciliationId, reconciled, user);
    revalidatePath(`/accounting/bank-reconciliation/${reconciliationId}`);
    return { ok: true };
  });
}

export async function completeBankReconciliation(id: number): Promise<ActionResult<{ ok: true }>> {
  return actionResult(async () => {
    const user = await requireAction('GL_BANK_RECONCILE');
    await gl.completeBankReconciliation(id, user);
    revalidatePath(`/accounting/bank-reconciliation/${id}`);
    revalidatePath('/accounting');
    return { ok: true };
  });
}

export async function createGlAccount(values: FormValues): Promise<ActionResult<{ id: number }>> {
  return actionResult(async () => {
    const user = await requireAction('GL_ACCOUNT_MANAGE');
    const created = await gl.createGlAccount({
      code: String(values.code || '').trim(),
      name: String(values.name || '').trim(),
      type: values.type as GlAccountType,
      parent_code: String(values.parent_code || '') || null,
      account_type: (values.account_type || 'POSTING') as GlAccountStructureType,
      totaling: String(values.totaling || '').trim() || null,
    }, user);
    revalidatePath('/accounting/accounts');
    return created;
  });
}

export async function updateGlAccount(code: string, values: FormValues): Promise<ActionResult<GlAccount>> {
  return actionResult(async () => {
    const user = await requireAction('GL_ACCOUNT_MANAGE');
    const updated = await gl.updateGlAccount(code, {
      name: String(values.name || '').trim(),
      type: values.type as GlAccountType,
      parent_code: String(values.parent_code || '') || null,
      account_type: (values.account_type || 'POSTING') as GlAccountStructureType,
      totaling: String(values.totaling || '').trim() || null,
      status: (String(values.status || 'ACTIVE') as 'ACTIVE' | 'INACTIVE'),
    }, user);
    revalidatePath('/accounting/accounts');
    return updated;
  });
}

export async function setPeriodStatus(code: string, status: string): Promise<ActionResult<AccountingPeriod>> {
  return actionResult(async () => {
    const user = await requireAction('GL_PERIOD_CLOSE');
    const period = await gl.setPeriodStatus(code, status, user);
    revalidatePath('/accounting/periods');
    return period;
  });
}
