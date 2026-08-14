import { one, all, run, nextSequence, audit } from './db.ts';
import { AppError } from './errors.ts';
import { trialBalance, postJournal, reverseJournal, accountBalance } from './accounting.ts';
import { GL_ACCOUNT_TYPES } from './constants.ts';
import { diffFields, logTableChange } from './changeLog.ts';
import { findMatchingWorkflow, startWorkflow } from './workflow.ts';
import type {
  AccountingPeriod, Actor, Cents, GlAccount, GlAccountType, IsoDate, Journal, JournalLineInput,
  JournalLineWithAccount, JournalListRow, LedgerLine, PostedJournal, TrialBalanceRow,
} from './types.ts';

export interface TrialBalanceReport {
  rows: TrialBalanceRow[];
  totals: { debit: Cents; credit: Cents };
  balanced: boolean;
}

/** Trial balance plus the totals and the in-balance assertion the screen shows. */
export async function getTrialBalance(asOf?: IsoDate | null): Promise<TrialBalanceReport> {
  const rows = await trialBalance(asOf);
  const totals = rows.reduce(
    (a, r) => ({ debit: a.debit + r.debit_balance, credit: a.credit + r.credit_balance }),
    { debit: 0, credit: 0 },
  );
  return { rows, totals, balanced: totals.debit === totals.credit };
}

export function listJournals(search = ''): Promise<JournalListRow[]> {
  return all<JournalListRow>(
    `SELECT j.*, m.member_no, m.first_name, m.last_name,
            gd1.code AS global_dimension_1_code, gd2.code AS global_dimension_2_code
     FROM journal j
     LEFT JOIN member m ON m.id = j.member_id
     LEFT JOIN global_dimension_1_value gd1 ON gd1.id = j.global_dimension_1_id
     LEFT JOIN global_dimension_2_value gd2 ON gd2.id = j.global_dimension_2_id
     WHERE j.journal_no LIKE @like OR j.description LIKE @like OR j.reference LIKE @like
     ORDER BY j.id DESC LIMIT 200`,
    { like: `%${String(search).trim()}%` },
  );
}

export interface JournalDetail {
  journal: Journal;
  lines: JournalLineWithAccount[];
}

export async function getJournal(id: number): Promise<JournalDetail | null> {
  const journal = await one<Journal>('SELECT * FROM journal WHERE id = ?', id);
  if (!journal) return null;
  return {
    journal,
    lines: await all<JournalLineWithAccount>(
      `SELECT jl.*, a.code, a.name, a.type,
              gd1.code AS global_dimension_1_code, gd2.code AS global_dimension_2_code
       FROM journal_line jl
       JOIN gl_account a ON a.id = jl.gl_account_id
       LEFT JOIN global_dimension_1_value gd1 ON gd1.id = jl.global_dimension_1_id
       LEFT JOIN global_dimension_2_value gd2 ON gd2.id = jl.global_dimension_2_id
       WHERE jl.journal_id = ? ORDER BY jl.line_no`,
      id,
    ),
  };
}

export interface CreateJournalInput {
  valueDate?: IsoDate;
  description?: string;
  lines: JournalLineInput[];
}

/** The actual posting — shared by an immediate manual entry and a workflow's finalize step. */
export async function postManualJournal(input: CreateJournalInput, user: Actor): Promise<PostedJournal> {
  const clean = (input.lines || [])
    .map((l) => ({
      account: l.account,
      debit: Math.round(Number(l.debit) || 0),
      credit: Math.round(Number(l.credit) || 0),
      narration: l.narration || null,
      globalDimension1Id: l.globalDimension1Id ?? null,
      globalDimension2Id: l.globalDimension2Id ?? null,
    }))
    .filter((l) => l.account && (l.debit || l.credit));
  if (clean.length < 2) throw new AppError('A journal needs at least two lines', 'NO_LINES');

  const j = await postJournal({
    valueDate: input.valueDate || new Date().toISOString().slice(0, 10),
    module: 'GL',
    eventType: 'MANUAL',
    description: input.description,
    lines: clean,
    user,
  });
  await audit(user, 'GL_JOURNAL_CREATE', 'journal', j.id, { amount: j.amount });
  return j;
}

export type CreateJournalResult =
  | { posted: true; journal: PostedJournal }
  | { posted: false; taskId: number };

/**
 * Entry point for the manual-entry screen: posts immediately unless an
 * admin-defined workflow matches, in which case the journal is held as a
 * pending task's payload and only actually posted once every step approves.
 */
export async function createJournal(input: CreateJournalInput, user: Actor): Promise<CreateJournalResult> {
  const amount = (input.lines || []).reduce((a, l) => a + Math.round(Number(l.debit) || 0), 0);
  const gd1 = input.lines?.find((l) => l.globalDimension1Id != null)?.globalDimension1Id ?? null;
  const gd2 = input.lines?.find((l) => l.globalDimension2Id != null)?.globalDimension2Id ?? null;

  // Keys here must match RUNTIME_FIELD_CAP.JOURNAL (lib/workflow.ts) — that cap is what stops
  // an admin from enabling a Table Relation field here that would never actually match.
  const matched = await findMatchingWorkflow('JOURNAL', {
    amount, global_dimension_1_id: gd1, global_dimension_2_id: gd2,
  });
  if (!matched) {
    return { posted: true, journal: await postManualJournal(input, user) };
  }

  // No journal exists yet to key the task on — mint a draft reference instead.
  const draftNo = await nextSequence('JOURNAL_DRAFT');
  const taskId = await startWorkflow(matched.workflow, matched.steps, {
    documentType: 'JOURNAL', entityId: draftNo, requestedBy: user.username, amount,
    payload: JSON.stringify(input),
  });
  await audit(user, 'GL_JOURNAL_SUBMIT', 'workflow_task', taskId, { amount, draftNo });
  return { posted: false, taskId };
}

export async function reverseJournalEntry(id: number, reason: string, user: Actor): Promise<PostedJournal> {
  if (!reason) throw new AppError('A reversal reason is required', 'REASON_REQUIRED');
  const rev = await reverseJournal(Number(id), user, reason);
  await audit(user, 'GL_JOURNAL_REVERSE', 'journal', id, { reason });
  return rev;
}

export interface AccountLedger {
  account: GlAccount;
  lines: LedgerLine[];
  balance: Cents;
}

export async function getAccountLedger(code: string): Promise<AccountLedger | null> {
  const account = await one<GlAccount>('SELECT * FROM gl_account WHERE code = ?', code);
  if (!account) return null;
  const [lines, balance] = await Promise.all([
    all<LedgerLine>(
      `SELECT jl.*, j.journal_no, j.value_date, j.description, j.source_module
       FROM journal_line jl JOIN journal j ON j.id = jl.journal_id
       WHERE jl.gl_account_id = ? ORDER BY j.value_date, j.id LIMIT 500`,
      account.id,
    ),
    accountBalance(account.code),
  ]);
  return { account, lines, balance };
}

export const listGlAccounts = (): Promise<GlAccount[]> =>
  all<GlAccount>('SELECT * FROM gl_account ORDER BY code');

export const listPostableAccounts = (): Promise<GlAccount[]> =>
  all<GlAccount>("SELECT * FROM gl_account WHERE is_postable = 1 AND status = 'ACTIVE' ORDER BY code");

export interface CreateGlAccountInput {
  code: string;
  name: string;
  type: GlAccountType;
  parent_code?: string | null;
  is_postable?: number;
}

export async function createGlAccount(
  { code, name, type, parent_code = null, is_postable = 1 }: CreateGlAccountInput,
  user: Actor,
): Promise<{ id: number }> {
  if (!code || !name || !type) throw new AppError('Code, name and type are required', 'VALIDATION');
  if (!GL_ACCOUNT_TYPES.includes(type)) throw new AppError('Invalid account type', 'VALIDATION');
  if (await one('SELECT 1 FROM gl_account WHERE code = ?', code)) {
    throw new AppError('Account code already exists', 'DUPLICATE');
  }
  const info = await run(
    'INSERT INTO gl_account (code, name, type, parent_code, is_postable) VALUES (?,?,?,?,?)',
    code, name, type, parent_code || null, is_postable ? 1 : 0,
  );
  await audit(user, 'GL_ACCOUNT_CREATE', 'gl_account', info.lastInsertRowid, { code, name, type });
  await logTableChange('gl_account', code, 'Insertion', [
    { field: 'code', oldValue: null, newValue: code },
    { field: 'name', oldValue: null, newValue: name },
    { field: 'type', oldValue: null, newValue: type },
    { field: 'parent_code', oldValue: null, newValue: parent_code || null },
    { field: 'is_postable', oldValue: null, newValue: is_postable ? 1 : 0 },
  ], user);
  return { id: Number(info.lastInsertRowid) };
}

export interface UpdateGlAccountInput {
  name: string;
  type: GlAccountType;
  parent_code?: string | null;
  is_postable?: number;
  status?: 'ACTIVE' | 'INACTIVE';
}

/** Code is the natural key referenced throughout the ledger and by other admin
 *  screens (products' GL mappings) — it's set at creation and never renamed here. */
export async function updateGlAccount(
  code: string, { name, type, parent_code = null, is_postable = 1, status = 'ACTIVE' }: UpdateGlAccountInput,
  user: Actor,
): Promise<GlAccount> {
  const before = await one<GlAccount>('SELECT * FROM gl_account WHERE code = ?', code);
  if (!before) throw new AppError('Account not found', 'NOT_FOUND');
  if (!name || !type) throw new AppError('Name and type are required', 'VALIDATION');
  if (!GL_ACCOUNT_TYPES.includes(type)) throw new AppError('Invalid account type', 'VALIDATION');

  const patch = {
    name, type, parent_code: parent_code || null, is_postable: is_postable ? 1 : 0, status,
  };
  await run(
    'UPDATE gl_account SET name=?, type=?, parent_code=?, is_postable=?, status=? WHERE code=?',
    patch.name, patch.type, patch.parent_code, patch.is_postable, patch.status, code,
  );
  const changes = diffFields(before as unknown as Record<string, unknown>, patch);
  await logTableChange('gl_account', code, 'Modification', changes, user);
  if (changes.length) {
    await audit(user, 'GL_ACCOUNT_UPDATE', 'gl_account', before.id, { code, fields: changes.map((c) => c.field) });
  }
  return (await one<GlAccount>('SELECT * FROM gl_account WHERE code = ?', code))!;
}

export const listPeriods = (): Promise<AccountingPeriod[]> =>
  all<AccountingPeriod>('SELECT * FROM accounting_period ORDER BY code DESC');

export async function setPeriodStatus(code: string, status: string, user: Actor): Promise<AccountingPeriod> {
  if (status !== 'OPEN' && status !== 'CLOSED') {
    throw new AppError('Status must be OPEN or CLOSED', 'VALIDATION');
  }
  const info = await run('UPDATE accounting_period SET status = ? WHERE code = ?', status, code);
  if (!info.changes) throw new AppError('Period not found', 'NOT_FOUND');
  await audit(user, status === 'CLOSED' ? 'PERIOD_CLOSE' : 'PERIOD_REOPEN', 'accounting_period', code);
  return (await one<AccountingPeriod>('SELECT * FROM accounting_period WHERE code = ?', code))!;
}
