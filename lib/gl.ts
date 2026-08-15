import { one, all, run, nextSequence, audit } from './db.ts';
import { AppError } from './errors.ts';
import { trialBalance, postJournal, reverseJournal } from './accounting.ts';
import { GL_ACCOUNT_TYPES, GL_ACCOUNT_STRUCTURE_TYPES, PRODUCT_STATUSES } from './constants.ts';
import { diffFields, logTableChange } from './changeLog.ts';
import { findMatchingWorkflow, startWorkflow } from './workflow.ts';
import { buildFilterClause, type FilterCondition, type FilterFieldDef } from './listFilters.ts';
import { buildOrderClause, type SortState } from './listSort.ts';
import type {
  AccountingPeriod, Actor, Cents, GlAccount, GlAccountStructureType, GlAccountType, IsoDate, Journal,
  JournalLineInput, JournalLineWithAccount, JournalListRow, LedgerLine, PostedJournal, TrialBalanceRow,
} from './types.ts';

export interface TrialBalanceReport {
  rows: TrialBalanceRow[];
  totals: { debit: Cents; credit: Cents };
  balanced: boolean;
}

/** Global Dimension 1/2 filters shared by the Chart of Accounts and Trial Balance screens —
 *  both narrow through journal_line's own per-line dimensions (as opposed to Journals'
 *  header-level j.global_dimension_1/2_id above). Options ship empty; the page fills them
 *  in from listActiveDimensionValues(). Reused as-is by getAccountLedger()'s drill-down so
 *  a filtered balance and the ledger entries behind it always agree. */
export const GL_DIMENSION_FILTER_FIELDS: FilterFieldDef[] = [
  { key: 'global_dimension_1_id', label: 'Global Dimension 1', type: 'select', column: 'jl.global_dimension_1_id' },
  { key: 'global_dimension_2_id', label: 'Global Dimension 2', type: 'select', column: 'jl.global_dimension_2_id' },
];

/** Trial balance's dynamic-filter registry — code/name/type are restricted to the account
 *  columns queried before aggregation (a.code/a.name/a.type); the computed balances can't be
 *  filtered in SQL without a HAVING clause the generic builder doesn't support. */
export const TRIAL_BALANCE_FILTER_FIELDS: FilterFieldDef[] = [
  { key: 'code', label: 'Code', type: 'text', column: 'a.code' },
  { key: 'name', label: 'Account Name', type: 'text', column: 'a.name' },
  { key: 'type', label: 'Type', type: 'select', column: 'a.type', options: GL_ACCOUNT_TYPES.map((t) => ({ value: t, label: t })) },
  ...GL_DIMENSION_FILTER_FIELDS,
];

export interface GetTrialBalanceOptions {
  asOf?: IsoDate | null;
  filters?: FilterCondition[];
}

/** Trial balance plus the totals and the in-balance assertion the screen shows. */
export async function getTrialBalance({ asOf, filters = [] }: GetTrialBalanceOptions = {}): Promise<TrialBalanceReport> {
  const { clause, params } = buildFilterClause(TRIAL_BALANCE_FILTER_FIELDS, filters, 'tb');
  const rows = await trialBalance(asOf, clause, params);
  const totals = rows.reduce(
    (a, r) => ({ debit: a.debit + r.debit_balance, credit: a.credit + r.credit_balance }),
    { debit: 0, credit: 0 },
  );
  return { rows, totals, balanced: totals.debit === totals.credit };
}

/** Journals list's dynamic-filter registry — every meaningful column. Global dimension fields
 *  ship without `options` since they're DB-driven; the page fills them in. Excludes purely
 *  internal columns (id, member_id — redundant with search, reverses_id/reversed_by_id — raw
 *  ids with no friendly picker, idempotency_key — a technical dedupe token). */
export const JOURNAL_FILTER_FIELDS: FilterFieldDef[] = [
  { key: 'journal_no', label: 'Journal No.', type: 'text', column: 'j.journal_no' },
  { key: 'value_date', label: 'Value Date', type: 'date', column: 'j.value_date' },
  { key: 'posted_at', label: 'Posted At', type: 'date', column: 'j.posted_at', datetime: true },
  { key: 'source_module', label: 'Source', type: 'text', column: 'j.source_module' },
  { key: 'event_type', label: 'Event', type: 'text', column: 'j.event_type' },
  { key: 'description', label: 'Description', type: 'text', column: 'j.description' },
  { key: 'reference', label: 'Reference', type: 'text', column: 'j.reference' },
  { key: 'amount', label: 'Amount', type: 'number', column: 'j.amount' },
  { key: 'posted_by', label: 'Posted By', type: 'text', column: 'j.posted_by' },
  { key: 'global_dimension_1_id', label: 'Global Dimension 1', type: 'select', column: 'j.global_dimension_1_id' },
  { key: 'global_dimension_2_id', label: 'Global Dimension 2', type: 'select', column: 'j.global_dimension_2_id' },
];

/** Journals list's sortable columns — every column shown in the table. */
const JOURNAL_SORT_COLUMNS: Record<string, string> = {
  journal_no: 'j.journal_no',
  value_date: 'j.value_date',
  source_module: 'j.source_module',
  event_type: 'j.event_type',
  description: 'j.description',
  member: 'm.first_name',
  gd1: 'gd1.code',
  gd2: 'gd2.code',
  amount: 'j.amount',
  posted_by: 'j.posted_by',
};

export interface ListJournalsOptions {
  search?: string;
  filters?: FilterCondition[];
  sort?: SortState | null;
}

export function listJournals({ search = '', filters = [], sort = null }: ListJournalsOptions = {}): Promise<JournalListRow[]> {
  const { clause, params } = buildFilterClause(JOURNAL_FILTER_FIELDS, filters);
  const orderBy = buildOrderClause(JOURNAL_SORT_COLUMNS, sort, 'j.id DESC');
  return all<JournalListRow>(
    `SELECT j.*, m.member_no, m.first_name, m.last_name,
            gd1.code AS global_dimension_1_code, gd2.code AS global_dimension_2_code
     FROM journal j
     LEFT JOIN member m ON m.id = j.member_id
     LEFT JOIN global_dimension_1_value gd1 ON gd1.id = j.global_dimension_1_id
     LEFT JOIN global_dimension_2_value gd2 ON gd2.id = j.global_dimension_2_id
     WHERE (j.journal_no LIKE @like OR j.description LIKE @like OR j.reference LIKE @like)
       ${clause}
     ${orderBy} LIMIT 200`,
    { like: `%${String(search).trim()}%`, ...params },
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

export interface AccountLedgerOptions {
  asOf?: IsoDate | null;
  filters?: FilterCondition[];
}

/** Drives the Chart of Accounts / Trial Balance balance drill-down. Applies the same As Of
 *  date and Global Dimension filters as the balance being drilled into (via the shared
 *  GL_DIMENSION_FILTER_FIELDS registry), so the ledger entries shown always reconcile to the
 *  figure the user clicked rather than the account's unfiltered lifetime balance. */
export async function getAccountLedger(code: string, { asOf, filters = [] }: AccountLedgerOptions = {}): Promise<AccountLedger | null> {
  const account = await one<GlAccount>('SELECT * FROM gl_account WHERE code = ?', code);
  if (!account) return null;

  const { clause: gdClause, params: gdParams } = buildFilterClause(GL_DIMENSION_FILTER_FIELDS, filters, 'lgd');
  const params = { id: account.id, asOf: asOf || null, ...gdParams };

  const [lines, tb] = await Promise.all([
    all<LedgerLine>(
      `SELECT jl.*, j.journal_no, j.value_date, j.description, j.source_module
       FROM journal_line jl JOIN journal j ON j.id = jl.journal_id
       WHERE jl.gl_account_id = @id
         AND (@asOf::text IS NULL OR j.value_date <= @asOf::text)
         ${gdClause}
       ORDER BY j.value_date, j.id LIMIT 500`,
      params,
    ),
    trialBalance(asOf, `AND a.code = @lgcode ${gdClause}`, { lgcode: code, ...gdParams }),
  ]);
  return { account, lines, balance: tb[0]?.net ?? 0 };
}

/** Chart of accounts list's dynamic-filter registry — every meaningful column (id is excluded
 *  as purely internal). */
export const GL_ACCOUNT_FILTER_FIELDS: FilterFieldDef[] = [
  { key: 'code', label: 'Code', type: 'text' },
  { key: 'name', label: 'Account Name', type: 'text' },
  { key: 'type', label: 'Type', type: 'select', options: GL_ACCOUNT_TYPES.map((t) => ({ value: t, label: t })) },
  { key: 'account_type', label: 'Account Type', type: 'select', options: GL_ACCOUNT_STRUCTURE_TYPES },
  { key: 'parent_code', label: 'Parent Code', type: 'text' },
  { key: 'is_postable', label: 'Postable', type: 'select', options: [{ value: 1, label: 'Yes' }, { value: 0, label: 'Header' }] },
  { key: 'balance', label: 'Balance', type: 'number' },
  { key: 'status', label: 'Status', type: 'select', options: PRODUCT_STATUSES.map((s) => ({ value: s, label: s })) },
];

/** Chart of accounts list's sortable columns — every column shown in the table. */
const GL_ACCOUNT_SORT_COLUMNS: Record<string, string> = {
  code: 'code',
  name: 'name',
  type: 'type',
  account_type: 'account_type',
  parent_code: 'parent_code',
  is_postable: 'is_postable',
  balance: 'balance',
  status: 'status',
};

/** Parses a Business Central-style Totaling filter — `|`-separated terms, each a single
 *  account code or a `FROM..TO` inclusive range — and reports whether `code` falls in it. */
export function matchesTotaling(code: string, totaling: string | null | undefined): boolean {
  if (!totaling) return false;
  return totaling.split('|').map((t) => t.trim()).filter(Boolean).some((term) => {
    const [from, to] = term.split('..');
    return code >= from.trim() && code <= (to ?? from).trim();
  });
}

/** Sums the (already filter-aware) balances of every Posting account a Total/End-Total row's
 *  Totaling range names. Always resolved against Posting accounts specifically — a numeric
 *  range spanning a nested Heading or Total row must not double-count that row's own
 *  (separately rolled-up) figure. */
export function totalingBalance(
  accounts: GlAccount[], balanceByCode: Map<string, Cents>, totaling: string | null | undefined,
): Cents {
  return accounts
    .filter((a) => a.account_type === 'POSTING' && matchesTotaling(a.code, totaling))
    .reduce((sum, a) => sum + (balanceByCode.get(a.code) ?? 0), 0);
}

export interface ListGlAccountsOptions {
  search?: string;
  filters?: FilterCondition[];
  sort?: SortState | null;
}

export const listGlAccounts = (
  { search = '', filters = [], sort = null }: ListGlAccountsOptions = {},
): Promise<GlAccount[]> => {
  const { clause, params } = buildFilterClause(GL_ACCOUNT_FILTER_FIELDS, filters);
  const orderBy = buildOrderClause(GL_ACCOUNT_SORT_COLUMNS, sort, 'code');
  return all<GlAccount>(
    `SELECT * FROM gl_account
     WHERE (code LIKE @like OR name LIKE @like)
       ${clause}
     ${orderBy}`,
    { like: `%${String(search).trim()}%`, ...params },
  );
};

export const listPostableAccounts = (): Promise<GlAccount[]> =>
  all<GlAccount>("SELECT * FROM gl_account WHERE is_postable = 1 AND status = 'ACTIVE' ORDER BY code");

/** account_type drives is_postable rather than the other way round: only a Posting
 *  account is ever postable, so there is exactly one place this is decided. Totaling
 *  only means anything for Total/End-Total, so it's dropped for every other type
 *  rather than left stale for a later type change to pick back up. */
function normaliseStructure(
  accountType: GlAccountStructureType, totaling: string | null | undefined,
): { isPostable: 0 | 1; totaling: string | null } {
  if (!GL_ACCOUNT_STRUCTURE_TYPES.some((t) => t.value === accountType)) {
    throw new AppError('Invalid account type', 'VALIDATION');
  }
  const needsTotaling = accountType === 'TOTAL' || accountType === 'END_TOTAL';
  if (needsTotaling && !totaling?.trim()) {
    throw new AppError('A Totaling range is required for Total and End-Total accounts', 'VALIDATION');
  }
  return { isPostable: accountType === 'POSTING' ? 1 : 0, totaling: needsTotaling ? totaling!.trim() : null };
}

export interface CreateGlAccountInput {
  code: string;
  name: string;
  type: GlAccountType;
  parent_code?: string | null;
  account_type?: GlAccountStructureType;
  totaling?: string | null;
}

export async function createGlAccount(
  { code, name, type, parent_code = null, account_type = 'POSTING', totaling = null }: CreateGlAccountInput,
  user: Actor,
): Promise<{ id: number }> {
  if (!code || !name || !type) throw new AppError('Code, name and type are required', 'VALIDATION');
  if (!GL_ACCOUNT_TYPES.includes(type)) throw new AppError('Invalid account type', 'VALIDATION');
  const { isPostable, totaling: cleanTotaling } = normaliseStructure(account_type, totaling);
  if (await one('SELECT 1 FROM gl_account WHERE code = ?', code)) {
    throw new AppError('Account code already exists', 'DUPLICATE');
  }
  const info = await run(
    'INSERT INTO gl_account (code, name, type, parent_code, is_postable, account_type, totaling) VALUES (?,?,?,?,?,?,?)',
    code, name, type, parent_code || null, isPostable, account_type, cleanTotaling,
  );
  await audit(user, 'GL_ACCOUNT_CREATE', 'gl_account', info.lastInsertRowid, { code, name, type });
  await logTableChange('gl_account', code, 'Insertion', [
    { field: 'code', oldValue: null, newValue: code },
    { field: 'name', oldValue: null, newValue: name },
    { field: 'type', oldValue: null, newValue: type },
    { field: 'parent_code', oldValue: null, newValue: parent_code || null },
    { field: 'account_type', oldValue: null, newValue: account_type },
    { field: 'totaling', oldValue: null, newValue: cleanTotaling },
  ], user);
  return { id: Number(info.lastInsertRowid) };
}

export interface UpdateGlAccountInput {
  name: string;
  type: GlAccountType;
  parent_code?: string | null;
  account_type?: GlAccountStructureType;
  totaling?: string | null;
  status?: 'ACTIVE' | 'INACTIVE';
}

/** Code is the natural key referenced throughout the ledger and by other admin
 *  screens (products' GL mappings) — it's set at creation and never renamed here. */
export async function updateGlAccount(
  code: string,
  { name, type, parent_code = null, account_type = 'POSTING', totaling = null, status = 'ACTIVE' }: UpdateGlAccountInput,
  user: Actor,
): Promise<GlAccount> {
  const before = await one<GlAccount>('SELECT * FROM gl_account WHERE code = ?', code);
  if (!before) throw new AppError('Account not found', 'NOT_FOUND');
  if (!name || !type) throw new AppError('Name and type are required', 'VALIDATION');
  if (!GL_ACCOUNT_TYPES.includes(type)) throw new AppError('Invalid account type', 'VALIDATION');
  const { isPostable, totaling: cleanTotaling } = normaliseStructure(account_type, totaling);

  if (before.account_type === 'POSTING' && account_type !== 'POSTING') {
    if (await one('SELECT 1 FROM journal_line WHERE gl_account_id = ?', before.id)) {
      throw new AppError('Cannot change a Posting account with ledger entries to a non-Posting type', 'VALIDATION');
    }
  }

  const patch = {
    name, type, parent_code: parent_code || null, is_postable: isPostable,
    account_type, totaling: cleanTotaling, status,
  };
  await run(
    `UPDATE gl_account SET name=?, type=?, parent_code=?, is_postable=?, account_type=?, totaling=?, status=?
     WHERE code=?`,
    patch.name, patch.type, patch.parent_code, patch.is_postable, patch.account_type, patch.totaling,
    patch.status, code,
  );
  const changes = diffFields(before as unknown as Record<string, unknown>, patch);
  await logTableChange('gl_account', code, 'Modification', changes, user);
  if (changes.length) {
    await audit(user, 'GL_ACCOUNT_UPDATE', 'gl_account', before.id, { code, fields: changes.map((c) => c.field) });
  }
  return (await one<GlAccount>('SELECT * FROM gl_account WHERE code = ?', code))!;
}

/** Accounting periods list's dynamic-filter registry — every meaningful column. */
export const PERIOD_FILTER_FIELDS: FilterFieldDef[] = [
  { key: 'code', label: 'Period', type: 'text' },
  { key: 'start_date', label: 'From', type: 'date' },
  { key: 'end_date', label: 'To', type: 'date' },
  { key: 'status', label: 'Status', type: 'select', options: [{ value: 'OPEN', label: 'Open' }, { value: 'CLOSED', label: 'Closed' }] },
];

/** Accounting periods list's sortable columns — every column shown in the table. */
const PERIOD_SORT_COLUMNS: Record<string, string> = {
  code: 'code',
  start_date: 'start_date',
  end_date: 'end_date',
  status: 'status',
};

export interface ListPeriodsOptions {
  search?: string;
  filters?: FilterCondition[];
  sort?: SortState | null;
}

export const listPeriods = (
  { search = '', filters = [], sort = null }: ListPeriodsOptions = {},
): Promise<AccountingPeriod[]> => {
  const { clause, params } = buildFilterClause(PERIOD_FILTER_FIELDS, filters);
  const orderBy = buildOrderClause(PERIOD_SORT_COLUMNS, sort, 'code DESC');
  return all<AccountingPeriod>(
    `SELECT * FROM accounting_period
     WHERE code LIKE @like
       ${clause}
     ${orderBy}`,
    { like: `%${String(search).trim()}%`, ...params },
  );
};

export async function setPeriodStatus(code: string, status: string, user: Actor): Promise<AccountingPeriod> {
  if (status !== 'OPEN' && status !== 'CLOSED') {
    throw new AppError('Status must be OPEN or CLOSED', 'VALIDATION');
  }
  const info = await run('UPDATE accounting_period SET status = ? WHERE code = ?', status, code);
  if (!info.changes) throw new AppError('Period not found', 'NOT_FOUND');
  await audit(user, status === 'CLOSED' ? 'PERIOD_CLOSE' : 'PERIOD_REOPEN', 'accounting_period', code);
  return (await one<AccountingPeriod>('SELECT * FROM accounting_period WHERE code = ?', code))!;
}
