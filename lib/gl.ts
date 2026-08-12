import { one, all, run, audit } from './db.ts';
import { AppError } from './errors.ts';
import { trialBalance, postJournal, reverseJournal, accountBalance } from './accounting.ts';
import { GL_ACCOUNT_TYPES } from './constants.ts';
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
    `SELECT j.*, m.member_no, m.first_name, m.last_name
     FROM journal j LEFT JOIN member m ON m.id = j.member_id
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
      `SELECT jl.*, a.code, a.name, a.type FROM journal_line jl
       JOIN gl_account a ON a.id = jl.gl_account_id
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

export async function createJournal(
  { valueDate, description, lines }: CreateJournalInput,
  user: Actor,
): Promise<PostedJournal> {
  const clean = (lines || [])
    .map((l) => ({
      account: l.account,
      debit: Math.round(Number(l.debit) || 0),
      credit: Math.round(Number(l.credit) || 0),
      narration: l.narration || null,
    }))
    .filter((l) => l.account && (l.debit || l.credit));
  if (clean.length < 2) throw new AppError('A journal needs at least two lines', 'NO_LINES');

  const j = await postJournal({
    valueDate: valueDate || new Date().toISOString().slice(0, 10),
    module: 'GL',
    eventType: 'MANUAL',
    description,
    lines: clean,
    user,
  });
  await audit(user, 'GL_JOURNAL_CREATE', 'journal', j.id, { amount: j.amount });
  return j;
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
  return { id: Number(info.lastInsertRowid) };
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
