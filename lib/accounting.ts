/*
 * The posting engine. This is the ONLY place in the system that writes to
 * journal / journal_line / gl_account.balance. Every module (savings, loans,
 * FOSA, fees, interest) raises a business event and hands balanced lines to
 * postJournal, which enforces:
 *   - debits == credits, and non-zero
 *   - accounts exist, are ACTIVE and postable
 *   - the accounting period is OPEN
 *   - idempotency keys are never posted twice
 * so member/savings/loan subsidiary balances can never diverge from the GL.
 */
import { one, all, run, nextSequence } from './db.ts';
import { PostingError } from './errors.ts';
import type {
  AccountingPeriod, Actor, Cents, GlAccount, GlAccountType, IsoDate, Journal,
  JournalLine, PostJournalOptions, PostedJournal, TrialBalanceRow,
} from './types.ts';

export { PostingError };

export const NATURAL_DEBIT: ReadonlySet<GlAccountType> = new Set<GlAccountType>(['ASSET', 'EXPENSE']);

async function resolveAccount(ref: number | string): Promise<GlAccount> {
  const row = typeof ref === 'number'
    ? await one<GlAccount>('SELECT * FROM gl_account WHERE id = ?', ref)
    : await one<GlAccount>('SELECT * FROM gl_account WHERE code = ?', String(ref));
  if (!row) throw new PostingError(`GL account not found: ${ref}`, 'GL_ACCOUNT_NOT_FOUND');
  if (!row.is_postable) throw new PostingError(`GL account ${row.code} is a header account and cannot be posted to`, 'GL_NOT_POSTABLE');
  if (row.status !== 'ACTIVE') throw new PostingError(`GL account ${row.code} is not active`, 'GL_INACTIVE');
  return row;
}

async function assertPeriodOpen(valueDate: IsoDate): Promise<void> {
  const code = String(valueDate).slice(0, 7);
  const period = await one<AccountingPeriod>('SELECT * FROM accounting_period WHERE code = ?', code);
  if (period && period.status === 'CLOSED') {
    throw new PostingError(`Accounting period ${code} is closed. Posting rejected.`, 'PERIOD_CLOSED');
  }
}

/** Post a balanced double-entry journal. */
export async function postJournal(opts: PostJournalOptions): Promise<PostedJournal> {
  const {
    valueDate, module: sourceModule, eventType, description,
    reference = null, memberId = null, lines = [], user = null, idempotencyKey = null,
  } = opts;

  if (!valueDate) throw new PostingError('valueDate is required', 'NO_VALUE_DATE');
  if (!lines.length) throw new PostingError('A journal must have at least two lines', 'NO_LINES');

  if (idempotencyKey) {
    const existing = await one<PostedJournal>(
      'SELECT id, journal_no, amount FROM journal WHERE idempotency_key = ?', idempotencyKey,
    );
    if (existing) return { ...existing, duplicate: true };
  }

  await assertPeriodOpen(valueDate);

  let totalDebit = 0;
  let totalCredit = 0;
  // Sequential rather than Promise.all: the line validations must report the
  // first offending line, not whichever lookup happens to reject first.
  const prepared: { lineNo: number; acct: GlAccount; debit: Cents; credit: Cents; narration: string | null }[] = [];
  for (const [i, l] of lines.entries()) {
    const acct = await resolveAccount(l.account);
    const debit = Math.round(l.debit || 0);
    const credit = Math.round(l.credit || 0);
    if (debit < 0 || credit < 0) throw new PostingError('Negative amounts are not permitted in a journal line', 'NEGATIVE_LINE');
    if (debit > 0 && credit > 0) throw new PostingError('A journal line cannot be both debit and credit', 'MIXED_LINE');
    if (debit === 0 && credit === 0) throw new PostingError('A journal line must carry an amount', 'ZERO_LINE');
    totalDebit += debit;
    totalCredit += credit;
    prepared.push({ lineNo: i + 1, acct, debit, credit, narration: l.narration || description || null });
  }

  if (totalDebit !== totalCredit) {
    throw new PostingError(
      `Journal is out of balance: debits ${totalDebit} vs credits ${totalCredit}`,
      'OUT_OF_BALANCE',
    );
  }
  if (totalDebit === 0) throw new PostingError('Journal total cannot be zero', 'ZERO_JOURNAL');

  const journalNo = await nextSequence('JOURNAL');
  const now = new Date().toISOString();
  const info = await run(
    `INSERT INTO journal (journal_no, value_date, posted_at, source_module, event_type,
      description, reference, member_id, amount, posted_by, idempotency_key)
     VALUES (?,?,?,?,?,?,?,?,?,?,?)`,
    journalNo, valueDate, now, sourceModule, eventType,
    description || null, reference, memberId, totalDebit,
    user ? user.username : 'system', idempotencyKey,
  );
  const journalId = Number(info.lastInsertRowid);

  const INS_LINE = `INSERT INTO journal_line (journal_id, line_no, gl_account_id, debit, credit, narration)
     VALUES (?,?,?,?,?,?)`;
  const UPD_BAL = 'UPDATE gl_account SET balance = balance + ? WHERE id = ?';

  for (const p of prepared) {
    await run(INS_LINE, journalId, p.lineNo, p.acct.id, p.debit, p.credit, p.narration);
    const signed = NATURAL_DEBIT.has(p.acct.type) ? p.debit - p.credit : p.credit - p.debit;
    await run(UPD_BAL, signed, p.acct.id);
  }

  return { id: journalId, journal_no: journalNo, amount: totalDebit };
}

/** Reverse a journal with compensating entries. The original is never altered. */
export async function reverseJournal(
  journalId: number,
  user: Actor | null,
  reason?: string,
  valueDate?: IsoDate,
): Promise<PostedJournal> {
  const original = await one<Journal>('SELECT * FROM journal WHERE id = ?', journalId);
  if (!original) throw new PostingError('Journal not found', 'NOT_FOUND');
  if (original.reversed_by_id) throw new PostingError('Journal has already been reversed', 'ALREADY_REVERSED');
  if (original.reverses_id) throw new PostingError('A reversal journal cannot itself be reversed', 'IS_REVERSAL');

  const lines = await all<JournalLine>('SELECT * FROM journal_line WHERE journal_id = ? ORDER BY line_no', journalId);

  const rev = await postJournal({
    valueDate: valueDate || new Date().toISOString().slice(0, 10),
    module: original.source_module,
    eventType: 'REVERSAL',
    description: `Reversal of ${original.journal_no} — ${reason || 'no reason given'}`,
    reference: original.journal_no,
    memberId: original.member_id,
    user,
    lines: lines.map((l) => ({
      account: l.gl_account_id,
      debit: l.credit,
      credit: l.debit,
      narration: `Reversal of ${original.journal_no}: ${reason || ''}`.trim(),
    })),
  });

  await run('UPDATE journal SET reversed_by_id = ? WHERE id = ?', rev.id, journalId);
  await run('UPDATE journal SET reverses_id = ? WHERE id = ?', journalId, rev.id);
  return rev;
}

/**
 * Trial balance across all postable accounts.
 *
 * The `asOf` cut-off belongs in the JOIN, not the WHERE: as a WHERE predicate it
 * discards the NULL rows produced by the LEFT JOIN, so every account with no
 * movement silently vanished from a dated trial balance.
 */
export async function trialBalance(asOf?: IsoDate | null): Promise<TrialBalanceRow[]> {
  const rows = await all<Omit<TrialBalanceRow, 'net' | 'debit_balance' | 'credit_balance'>>(
    `SELECT a.id, a.code, a.name, a.type,
            COALESCE(SUM(jl.debit),0)  AS debit,
            COALESCE(SUM(jl.credit),0) AS credit
     FROM gl_account a
     LEFT JOIN journal_line jl ON jl.gl_account_id = a.id
     LEFT JOIN journal j ON j.id = jl.journal_id
       -- The cast is required: PostgreSQL cannot infer a parameter's type from
       -- "$1 IS NULL" alone and rejects the statement without it.
       AND (@asOf::text IS NULL OR j.value_date <= @asOf::text)
     WHERE a.is_postable = 1
     GROUP BY a.id
     ORDER BY a.code`,
    { asOf: asOf || null },
  );

  return rows.map((r) => {
    const net = NATURAL_DEBIT.has(r.type) ? r.debit - r.credit : r.credit - r.debit;
    return {
      ...r,
      net,
      debit_balance: NATURAL_DEBIT.has(r.type) ? Math.max(net, 0) : Math.max(-net, 0),
      credit_balance: NATURAL_DEBIT.has(r.type) ? Math.max(-net, 0) : Math.max(net, 0),
    };
  });
}

/** Balance of a single account from posted journal lines (the authoritative read). */
export async function accountBalance(code: string): Promise<Cents> {
  const row = await one<{ type: GlAccountType; d: Cents; c: Cents }>(
    `SELECT a.type, COALESCE(SUM(jl.debit),0) d, COALESCE(SUM(jl.credit),0) c
     FROM gl_account a LEFT JOIN journal_line jl ON jl.gl_account_id = a.id
     WHERE a.code = ? GROUP BY a.id`,
    code,
  );
  if (!row) return 0;
  return NATURAL_DEBIT.has(row.type) ? row.d - row.c : row.c - row.d;
}

/**
 * Balances for several accounts in one round trip.
 * The dashboard needed thirteen separate accountBalance() scans; this is one.
 * Codes with no account read 0.
 */
export async function accountBalances(codes: readonly string[]): Promise<Record<string, Cents>> {
  const out: Record<string, Cents> = Object.fromEntries(codes.map((c) => [c, 0]));
  if (!codes.length) return out;

  const rows = await all<{ code: string; type: GlAccountType; d: Cents; c: Cents }>(
    `SELECT a.code, a.type, COALESCE(SUM(jl.debit),0) d, COALESCE(SUM(jl.credit),0) c
     FROM gl_account a LEFT JOIN journal_line jl ON jl.gl_account_id = a.id
     WHERE a.code IN (${codes.map(() => '?').join(',')})
     GROUP BY a.id`,
    ...codes,
  );
  for (const r of rows) out[r.code] = NATURAL_DEBIT.has(r.type) ? r.d - r.c : r.c - r.d;
  return out;
}
