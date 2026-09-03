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
import { canReverseJournal } from './workflow.ts';
import { assertPostingDateAllowed, resolvePostingDate } from './postingDates.ts';
import { currentExchangeFactor, isBaseCurrency, baseCurrencyCode } from './currency.ts';
import type {
  AccountingPeriod, Actor, Cents, GlAccount, GlAccountType, IsoDate, Journal,
  JournalLine, PostJournalOptions, PostedJournal, TrialBalanceRow,
} from './types.ts';

const NATURAL_DEBIT: ReadonlySet<GlAccountType> = new Set<GlAccountType>(['ASSET', 'EXPENSE']);

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

/**
 * The member's own Global Dimension 1/2 — the default source when a posting
 * doesn't say otherwise, mirroring Business Central's default-dimension copy
 * from a master record onto the transactions that reference it.
 */
async function resolveMemberDimensions(
  memberId: number | null,
): Promise<{ gd1: number | null; gd2: number | null }> {
  if (!memberId) return { gd1: null, gd2: null };
  const row = await one<{ global_dimension_1_id: number | null; global_dimension_2_id: number | null }>(
    'SELECT global_dimension_1_id, global_dimension_2_id FROM member WHERE id = ?', memberId,
  );
  return { gd1: row?.global_dimension_1_id ?? null, gd2: row?.global_dimension_2_id ?? null };
}

/** Post a balanced double-entry journal. */
export async function postJournal(opts: PostJournalOptions): Promise<PostedJournal> {
  const {
    valueDate, module: sourceModule, eventType, description,
    reference = null, memberId = null, lines = [], user = null, idempotencyKey = null,
    globalDimension1Id = null, globalDimension2Id = null,
    currencyCode: rawCurrencyCode = null, currencyFactor: rawCurrencyFactor = null,
  } = opts;

  if (!valueDate) throw new PostingError('valueDate is required', 'NO_VALUE_DATE');
  if (!lines.length) throw new PostingError('A journal must have at least two lines', 'NO_LINES');

  // Multi-currency: line amounts are in `currencyCode`; `currencyFactor` is LCY per 1 unit of it.
  // Omitted currency → the base currency (KES) and factor 1, so every existing caller is unchanged.
  const currencyCode = (await isBaseCurrency(rawCurrencyCode)) ? await baseCurrencyCode() : rawCurrencyCode!;
  const isFcy = !(await isBaseCurrency(currencyCode));
  const currencyFactor = !isFcy
    ? 1
    : (rawCurrencyFactor && rawCurrencyFactor > 0
      ? rawCurrencyFactor
      : await currentExchangeFactor(currencyCode, valueDate));

  if (idempotencyKey) {
    const existing = await one<PostedJournal>(
      'SELECT id, journal_no, amount FROM journal WHERE idempotency_key = ?', idempotencyKey,
    );
    if (existing) return { ...existing, duplicate: true };
  }

  await assertPeriodOpen(valueDate);
  // A null or system-actor user (interest accrual, entrance fee recovery, standing orders, ...)
  // is never subject to a per-user posting-date restriction — assertPostingDateAllowed() itself
  // skips those, the same way canReverseJournal()'s own check above is skipped for a null one.
  await assertPostingDateAllowed(valueDate, user);

  // Business-Central-style default dimensions: an explicit header value always
  // wins; anything left unset is filled from the member the journal is for, so
  // every existing caller that already passes memberId gets this for free.
  let headerGd1 = globalDimension1Id;
  let headerGd2 = globalDimension2Id;
  if (memberId && (headerGd1 == null || headerGd2 == null)) {
    const memberDims = await resolveMemberDimensions(memberId);
    headerGd1 = headerGd1 ?? memberDims.gd1;
    headerGd2 = headerGd2 ?? memberDims.gd2;
  }

  let totalDebit = 0;
  let totalCredit = 0;
  let totalDebitLcy = 0;
  let totalCreditLcy = 0;
  // Sequential rather than Promise.all: the line validations must report the
  // first offending line, not whichever lookup happens to reject first.
  const prepared: {
    lineNo: number; acct: GlAccount; debit: Cents; credit: Cents; debitLcy: Cents; creditLcy: Cents;
    narration: string | null; gd1: number | null; gd2: number | null; line: (typeof lines)[number];
  }[] = [];
  for (const [i, l] of lines.entries()) {
    const acct = await resolveAccount(l.account);
    const debit = Math.round(l.debit || 0);
    const credit = Math.round(l.credit || 0);
    if (debit < 0 || credit < 0) throw new PostingError('Negative amounts are not permitted in a journal line', 'NEGATIVE_LINE');
    if (debit > 0 && credit > 0) throw new PostingError('A journal line cannot be both debit and credit', 'MIXED_LINE');
    if (debit === 0 && credit === 0) throw new PostingError('A journal line must carry an amount', 'ZERO_LINE');
    const debitLcy = isFcy ? Math.round(debit * currencyFactor) : debit;
    const creditLcy = isFcy ? Math.round(credit * currencyFactor) : credit;
    totalDebit += debit;
    totalCredit += credit;
    totalDebitLcy += debitLcy;
    totalCreditLcy += creditLcy;
    prepared.push({
      lineNo: i + 1, acct, debit, credit, debitLcy, creditLcy, narration: l.narration || description || null,
      gd1: l.globalDimension1Id ?? headerGd1, gd2: l.globalDimension2Id ?? headerGd2, line: l,
    });
  }

  if (totalDebit !== totalCredit) {
    throw new PostingError(
      `Journal is out of balance: debits ${totalDebit} vs credits ${totalCredit}`,
      'OUT_OF_BALANCE',
    );
  }
  if (totalDebit === 0) throw new PostingError('Journal total cannot be zero', 'ZERO_JOURNAL');

  // Per-line rounding of `debit * factor` can leave the LCY totals a few cents apart even though
  // the FCY totals balance exactly. BC absorbs that "Currency Application Rounding" onto a line;
  // here it is snapped onto the largest-magnitude line of the short side. A larger gap is a real
  // imbalance and still an error.
  if (isFcy) {
    const lcyResidual = totalDebitLcy - totalCreditLcy;
    if (lcyResidual !== 0) {
      if (Math.abs(lcyResidual) > prepared.length + 1) {
        throw new PostingError(`Journal is out of balance in ${await baseCurrencyCode()}: ${lcyResidual}`, 'OUT_OF_BALANCE');
      }
      const side = lcyResidual > 0 ? 'creditLcy' : 'debitLcy';
      let target = prepared[0];
      for (const p of prepared) if (p[side] > target[side]) target = p;
      target[side] += Math.abs(lcyResidual);
      if (lcyResidual > 0) totalCreditLcy += Math.abs(lcyResidual);
      else totalDebitLcy += Math.abs(lcyResidual);
    }
  }

  const journalNo = await nextSequence('JOURNAL');
  const now = new Date().toISOString();
  // Document No. convention: a caller with its own source document (Member Charging, Account
  // Activation, a loan disbursement/repayment, ...) always passes its own document number as
  // `reference` — that's what should trace a G/L Entry back to where it came from. Only a
  // manual G/L journal has no such document, so it's the one case this falls back to the
  // journal's own auto-generated number instead of staying blank.
  const effectiveReference = reference ?? (sourceModule === 'GL' && eventType === 'MANUAL' ? journalNo : null);
  const info = await run(
    `INSERT INTO journal (journal_no, value_date, posted_at, source_module, event_type,
      description, reference, member_id, amount, posted_by, idempotency_key,
      global_dimension_1_id, global_dimension_2_id, currency_code, currency_factor)
     VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)`,
    journalNo, valueDate, now, sourceModule, eventType,
    description || null, effectiveReference, memberId, totalDebitLcy,
    user ? user.username : 'system', idempotencyKey,
    headerGd1, headerGd2, currencyCode, currencyFactor,
  );
  const journalId = Number(info.lastInsertRowid);

  const INS_LINE = `INSERT INTO journal_line
     (journal_id, line_no, gl_account_id, debit, credit, debit_lcy, credit_lcy, currency_code, currency_factor,
      narration, global_dimension_1_id, global_dimension_2_id)
     VALUES (?,?,?,?,?,?,?,?,?,?,?,?)`;
  const UPD_BAL = 'UPDATE gl_account SET balance = balance + ? WHERE id = ?';

  // Business-Central-style subledger posting: a line against a Bank Account's control
  // account also lands a bank_account_ledger_entry, automatically and for every caller
  // (savings/loan/charge postings and manual journals alike) — see lib/gl.ts's Bank
  // Account CRUD for where these rows come from, and no-direct-posting for the other
  // half of the picture (blocking a manual journal from bypassing the subledger).
  const bankAccounts = await all<{ id: number; gl_account_id: number; currency_code: string }>(
    "SELECT id, gl_account_id, currency_code FROM bank_account WHERE status = 'ACTIVE'",
  );
  const bankByGlAccount = new Map(bankAccounts.map((b) => [b.gl_account_id, b]));
  const INS_BANK_ENTRY = `INSERT INTO bank_account_ledger_entry
     (bank_account_id, journal_id, journal_line_id, posting_date, description, amount, running_balance,
      amount_lcy, currency_code, currency_factor, document_type, document_no, external_document_no, open, created_at)
     VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,1,?)`;
  const UPD_BANK_BAL = 'UPDATE bank_account SET balance = balance + ?, balance_lcy = balance_lcy + ? WHERE id = ? RETURNING balance';

  for (const p of prepared) {
    const lineInfo = await run(
      INS_LINE, journalId, p.lineNo, p.acct.id, p.debit, p.credit, p.debitLcy, p.creditLcy,
      currencyCode, currencyFactor, p.narration, p.gd1, p.gd2,
    );
    // gl_account.balance is always LCY.
    const signedLcy = NATURAL_DEBIT.has(p.acct.type) ? p.debitLcy - p.creditLcy : p.creditLcy - p.debitLcy;
    await run(UPD_BAL, signedLcy, p.acct.id);

    const bank = bankByGlAccount.get(p.acct.id);
    if (bank != null) {
      // A bank_account_ledger_entry is denominated in the bank account's own currency.
      if (isFcy && currencyCode !== bank.currency_code) {
        throw new PostingError(
          `This journal is in ${currencyCode} but bank account ${bank.id} is a ${bank.currency_code} account`,
          'BANK_CURRENCY_MISMATCH',
        );
      }
      const signed = NATURAL_DEBIT.has(p.acct.type) ? p.debit - p.credit : p.credit - p.debit;
      const updated = await one<{ balance: Cents }>(UPD_BANK_BAL, signed, signedLcy, bank.id);
      await run(
        INS_BANK_ENTRY, bank.id, journalId, lineInfo.lastInsertRowid, valueDate,
        p.narration, signed, updated!.balance, signedLcy, currencyCode, currencyFactor,
        p.line.bankDocumentType ?? '', p.line.bankDocumentNo ?? null, p.line.bankExternalDocumentNo ?? null, now,
      );
    }
  }

  return { id: journalId, journal_no: journalNo, amount: totalDebitLcy };
}

/** Reverse a journal with compensating entries. The original is never altered. */
export async function reverseJournal(
  journalId: number,
  user: Actor | null,
  reason?: string,
  valueDate?: IsoDate,
): Promise<PostedJournal> {
  // The one choke point every reversal path posts its compensating entry through (GL's own
  // reversal, a savings transaction reversal, ...), so the per-user "Can Reverse Journal" grant
  // from User Setup is enforced once, here, rather than duplicated in each caller. A null user
  // (system-driven reversal, if one is ever added) is left ungated, same as elsewhere in this
  // module — there is no session to check a grant against.
  if (user && !(await canReverseJournal(user.id))) {
    throw new PostingError(
      'You are not set up to reverse journals — ask an administrator to grant "Can Reverse Journal" in User Setup',
      'FORBIDDEN',
    );
  }
  const original = await one<Journal>('SELECT * FROM journal WHERE id = ?', journalId);
  if (!original) throw new PostingError('Journal not found', 'NOT_FOUND');
  if (original.reversed_by_id) throw new PostingError('Journal has already been reversed', 'ALREADY_REVERSED');
  if (original.reverses_id) throw new PostingError('A reversal journal cannot itself be reversed', 'IS_REVERSAL');

  const lines = await all<JournalLine>('SELECT * FROM journal_line WHERE journal_id = ? ORDER BY line_no', journalId);

  const rev = await postJournal({
    valueDate: valueDate || await resolvePostingDate(user),
    module: original.source_module,
    eventType: 'REVERSAL',
    description: `Reversal of ${original.journal_no} — ${reason || 'no reason given'}`,
    reference: original.journal_no,
    memberId: original.member_id,
    globalDimension1Id: original.global_dimension_1_id,
    globalDimension2Id: original.global_dimension_2_id,
    currencyCode: original.currency_code,
    currencyFactor: original.currency_factor,
    user,
    lines: lines.map((l) => ({
      account: l.gl_account_id,
      debit: l.credit,
      credit: l.debit,
      narration: `Reversal of ${original.journal_no}: ${reason || ''}`.trim(),
      globalDimension1Id: l.global_dimension_1_id,
      globalDimension2Id: l.global_dimension_2_id,
    })),
  });

  await run('UPDATE journal SET reversed_by_id = ? WHERE id = ?', rev.id, journalId);
  await run('UPDATE journal SET reverses_id = ? WHERE id = ?', journalId, rev.id);
  return rev;
}

export interface TrialBalanceOptions {
  /** Only sum activity on/after this date. Left unset, the report is the usual cumulative
   *  Balance at Date; paired with `asOf`, it becomes a Net Change (period) trial balance —
   *  Business Central's Date Filter FlowField applied to a G/L account's Net Change. */
  from?: IsoDate | null;
  asOf?: IsoDate | null;
  /** Spliced into the WHERE clause — safe only for gl_account's own columns (a.code/a.name/
   *  a.type and the like). A condition on a journal_line/journal column belongs in
   *  `joinClause` instead: see the note below. */
  whereClause?: string;
  whereParams?: Record<string, unknown>;
  /** Spliced into the combined (journal_line join journal)'s own ON condition, alongside
   *  `asOf`/`from` above — the only safe place for a journal_line/journal-column condition
   *  (dimensions, ...). Tested in WHERE instead, it would discard the NULL rows the LEFT JOIN
   *  produces for an account with no matching movement, silently dropping that account from the
   *  report instead of showing it at zero — the same hazard `asOf` itself was written to avoid. */
  joinClause?: string;
  joinParams?: Record<string, unknown>;
}

/** Trial balance across all postable accounts. */
export async function trialBalance({
  from = null, asOf = null, whereClause = '', whereParams = {}, joinClause = '', joinParams = {},
}: TrialBalanceOptions = {}): Promise<TrialBalanceRow[]> {
  const rows = await all<Omit<TrialBalanceRow, 'net' | 'debit_balance' | 'credit_balance'>>(
    `SELECT a.id, a.code, a.name, a.type,
            COALESCE(SUM(jl.debit_lcy),0)  AS debit,
            COALESCE(SUM(jl.credit_lcy),0) AS credit
     FROM gl_account a
     -- journal_line and journal are joined to each other FIRST, as one unit, and that whole
     -- unit is then LEFT JOINed to the account with every date/dimension condition attached
     -- HERE — never as a later join's own ON clause. A condition placed on a later join (e.g.
     -- one from journal_line to journal) only ever nulls that later join's own columns; it
     -- cannot retroactively exclude journal_line's jl.debit/jl.credit from the SUM, since those
     -- already belong to an earlier, unconditional join. That was a real, silent bug: every
     -- "as of" trial balance before this returned the exact same lifetime total regardless of
     -- the date, because the cutoff sat on the wrong join.
     LEFT JOIN (journal_line jl JOIN journal j ON j.id = jl.journal_id)
       ON jl.gl_account_id = a.id
       -- The cast is required: PostgreSQL cannot infer a parameter's type from
       -- "$1 IS NULL" alone and rejects the statement without it.
       AND (@asOf::text IS NULL OR j.value_date <= @asOf::text)
       AND (@from::text IS NULL OR j.value_date >= @from::text)
       ${joinClause}
     WHERE a.is_postable = 1
       ${whereClause}
     GROUP BY a.id
     ORDER BY a.code`,
    { asOf: asOf || null, from: from || null, ...whereParams, ...joinParams },
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
    `SELECT a.type, COALESCE(SUM(jl.debit_lcy),0) d, COALESCE(SUM(jl.credit_lcy),0) c
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
    `SELECT a.code, a.type, COALESCE(SUM(jl.debit_lcy),0) d, COALESCE(SUM(jl.credit_lcy),0) c
     FROM gl_account a LEFT JOIN journal_line jl ON jl.gl_account_id = a.id
     WHERE a.code IN (${codes.map(() => '?').join(',')})
     GROUP BY a.id`,
    ...codes,
  );
  for (const r of rows) out[r.code] = NATURAL_DEBIT.has(r.type) ? r.d - r.c : r.c - r.d;
  return out;
}
