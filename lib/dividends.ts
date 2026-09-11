/*
 * Dividend Module — ported from the Nation CBS AL extension (Sacco CBS/src), principally
 * Codeunit 52204023 "Dividend Management" and tables 52204067-74.
 *
 * A dividend is declared for a year over one or more savings products, each with its own rate.
 * Running it produces, per member account:
 *
 *   dividend_line        what this account earned, what was recovered from it, what is net payable
 *   dividend_det_entry   the month-by-month working the earning was derived from
 *   dividend_recovery    every charge, loan recovery and share-capital boost taken off the line
 *
 * The pipeline mirrors AL's CalculateDividend() step for step:
 *
 *   prepare -> lines -> withdrawn members -> monthly detail -> charges
 *           -> loan recoveries -> share boost -> preferential boost -> net amount
 *
 * and posting mirrors PostDividend()'s two modes — Provisioning (raise the expense and the
 * payable) and Payout (settle the payable to the members, net of recoveries).
 *
 * Deviations from the AL, each deliberate and marked at the point it happens:
 *   - money is in cents, not Decimal;
 *   - AL's Pro-Rated ratio is written `Round(11/12)` etc., which in AL rounds to whole numbers
 *     and collapses every month to 1 or 0. The evident intent — and what this implements — is
 *     the fraction (13 - month) / 12;
 *   - the AL reads balances off Detailed Vendor Ledger Entries; here the equivalent ledger is
 *     `txn` scoped by savings_account_id;
 *   - AL excludes members flagged "Dividend Exempt"; this schema has no such flag, so every
 *     member holding an account on a participating product is included.
 */
import { one, all, run, tx, audit, nextSequence, nextSequenceBatch } from './db.ts';
import { AppError } from './errors.ts';
import { postJournal } from './accounting.ts';
import { calculateTransactionCharges, getTransactionCharge } from './charges.ts';
import { repay } from './loanService.ts';
import { findMatchingWorkflow, findPendingRoutedTask, pickConditionFields, startWorkflow } from './workflow.ts';
import { buildFilterClause, type FilterCondition, type FilterFieldDef } from './listFilters.ts';
import { buildOrderClause, type SortState } from './listSort.ts';
import type {
  Actor, Cents, Dividend, DividendDetEntry, DividendDetail, DividendLineView,
  DividendListRow, DividendParamView, DividendPostingType, DividendRecoveryEntryType,
  DividendRateType, DividendRecoveryView, DividendWithdrawnMember, IsoDate, JournalLineInput,
  TransactionChargeWithDetail,
} from './types.ts';

/* --------------------------------------------------------------------------- lists */

export type DividendView = 'all' | 'open' | 'pending' | 'approved' | 'posted';

const VIEW_CLAUSE: Record<Exclude<DividendView, 'all'>, string> = {
  open: "d.status = 'Open'",
  pending: "d.status = 'Pending Approval'",
  approved: "d.status = 'Approved' AND d.posted = 0",
  posted: 'd.posted = 1',
};

export const DIVIDEND_VIEWS: DividendView[] = ['all', 'open', 'pending', 'approved', 'posted'];

export const DIVIDEND_FILTER_FIELDS: FilterFieldDef[] = [
  { key: 'no', label: 'No.', type: 'text', column: 'd.no' },
  { key: 'description', label: 'Description', type: 'text', column: 'd.description' },
  { key: 'dividend_year', label: 'Year', type: 'number', column: 'd.dividend_year' },
  {
    key: 'document_type', label: 'Book', type: 'select', column: 'd.document_type',
    options: [{ value: 'BOSA', label: 'BOSA' }, { value: 'FOSA', label: 'FOSA' }],
  },
  {
    key: 'posting_type', label: 'Posting Type', type: 'select', column: 'd.posting_type',
    options: [{ value: 'Provisioning', label: 'Provisioning' }, { value: 'Payout', label: 'Payout' }],
  },
  { key: 'posting_date', label: 'Posting Date', type: 'date', column: 'd.posting_date' },
];

const DIVIDEND_SORT_COLUMNS: Record<string, string> = {
  no: 'd.no', description: 'd.description', dividend_year: 'd.dividend_year',
  posting_date: 'd.posting_date', status: 'd.status',
};

const SELECT_ROW = `
  SELECT d.*,
         (SELECT COUNT(*) FROM dividend_line l WHERE l.dividend_id = d.id) AS line_count,
         (SELECT COALESCE(SUM(l.amount_earned), 0) FROM dividend_line l WHERE l.dividend_id = d.id) AS total_earned,
         (SELECT COALESCE(SUM(l.total_recoveries), 0) FROM dividend_line l WHERE l.dividend_id = d.id) AS total_recoveries,
         (SELECT COALESCE(SUM(l.net_amount), 0) FROM dividend_line l WHERE l.dividend_id = d.id) AS total_net,
         j.journal_no
  FROM dividend d
  LEFT JOIN journal j ON j.id = d.journal_id`;

export interface ListDividendsOptions {
  view?: DividendView;
  search?: string;
  filters?: FilterCondition[];
  sort?: SortState | null;
}

export const listDividends = (
  { view = 'all', search = '', filters = [], sort = null }: ListDividendsOptions = {},
): Promise<DividendListRow[]> => {
  const { clause, params } = buildFilterClause(DIVIDEND_FILTER_FIELDS, filters);
  const orderBy = buildOrderClause(DIVIDEND_SORT_COLUMNS, sort, 'd.no DESC');
  return all<DividendListRow>(
    `${SELECT_ROW}
     WHERE (d.no LIKE @like OR d.description LIKE @like)
       ${view === 'all' ? '' : `AND ${VIEW_CLAUSE[view]}`}
       ${clause}
     ${orderBy}`,
    { like: `%${String(search).trim()}%`, ...params },
  );
};

export const hasAnyDividends = (): Promise<boolean> =>
  one<{ n: number }>('SELECT COUNT(*) AS n FROM dividend').then((r) => Number(r?.n ?? 0) > 0);

export async function dividendCounts(): Promise<Record<DividendView, number>> {
  const rows = await all<{ status: string; posted: number; n: number }>(
    'SELECT status, posted, COUNT(*) AS n FROM dividend GROUP BY status, posted',
  );
  const counts = { all: 0, open: 0, pending: 0, approved: 0, posted: 0 } as Record<DividendView, number>;
  for (const r of rows) {
    const n = Number(r.n);
    counts.all += n;
    if (Number(r.posted)) counts.posted += n;
    else if (r.status === 'Open') counts.open += n;
    else if (r.status === 'Pending Approval') counts.pending += n;
    else if (r.status === 'Approved') counts.approved += n;
  }
  return counts;
}

/** Previous / next document within the active tab — the card's ‹ › pager. */
export async function getAdjacentDividendNos(
  no: string, view?: DividendView,
): Promise<{ prevNo: string | null; nextNo: string | null }> {
  const clause = view && view !== 'all' ? `AND ${VIEW_CLAUSE[view]}` : '';
  const [prev, next] = await Promise.all([
    one<{ no: string }>(`SELECT d.no FROM dividend d WHERE d.no < ? ${clause} ORDER BY d.no DESC LIMIT 1`, no),
    one<{ no: string }>(`SELECT d.no FROM dividend d WHERE d.no > ? ${clause} ORDER BY d.no ASC LIMIT 1`, no),
  ]);
  return { prevNo: prev?.no ?? null, nextNo: next?.no ?? null };
}

export async function getDividend(no: string): Promise<DividendDetail | undefined> {
  const header = await one<DividendListRow>(`${SELECT_ROW} WHERE d.no = ?`, no);
  if (!header) return undefined;
  const [params, withdrawn] = await Promise.all([
    listDividendParams(header.id),
    all<DividendWithdrawnMember>(
      'SELECT * FROM dividend_withdrawn_member WHERE dividend_id = ? ORDER BY member_no', header.id,
    ),
  ]);
  return { ...header, params, withdrawn };
}

export const listDividendParams = (dividendId: number): Promise<DividendParamView[]> =>
  all<DividendParamView>(
    `SELECT p.*, sp.code AS product_code, sp.name AS product_name,
            (SELECT COALESCE(SUM(l.amount_earned), 0) FROM dividend_line l
              WHERE l.dividend_id = p.dividend_id AND l.product_id = p.product_id) AS calculated_amount,
            (SELECT COALESCE(SUM(l.account_balance), 0) FROM dividend_line l
              WHERE l.dividend_id = p.dividend_id AND l.product_id = p.product_id) AS account_balances
     FROM dividend_param p JOIN savings_product sp ON sp.id = p.product_id
     WHERE p.dividend_id = ? ORDER BY sp.code`,
    dividendId,
  );

export interface ListDividendLinesOptions { search?: string; onlyEarning?: boolean; limit?: number }

export const listDividendLines = (
  dividendId: number, { search = '', onlyEarning = false, limit = 500 }: ListDividendLinesOptions = {},
): Promise<DividendLineView[]> =>
  all<DividendLineView>(
    `SELECT l.*, sp.code AS product_code, sp.name AS product_name, da.account_no AS destination_account_no
     FROM dividend_line l
     JOIN savings_product sp ON sp.id = l.product_id
     LEFT JOIN savings_account da ON da.id = l.destination_account_id
     WHERE l.dividend_id = @dividendId
       AND (l.member_no LIKE @like OR l.member_name LIKE @like OR l.account_no LIKE @like)
       ${onlyEarning ? 'AND l.net_amount <> 0' : ''}
     ORDER BY l.member_no, l.account_no
     LIMIT @limit`,
    { dividendId, like: `%${String(search).trim()}%`, limit },
  );

export const listDividendDetEntries = (lineId: number): Promise<DividendDetEntry[]> =>
  all<DividendDetEntry>('SELECT * FROM dividend_det_entry WHERE dividend_line_id = ? ORDER BY month_no', lineId);

export const listDividendRecoveries = (lineId: number): Promise<DividendRecoveryView[]> =>
  all<DividendRecoveryView>(
    `SELECT r.*, l.loan_no, sa.account_no AS target_account_no
     FROM dividend_recovery r
     LEFT JOIN loan l ON l.id = r.loan_id
     LEFT JOIN savings_account sa ON sa.id = r.target_account_id
     WHERE r.dividend_line_id = ? ORDER BY r.priority, r.id`,
    lineId,
  );

/* ------------------------------------------------------------------- create / update */

export interface DividendInput {
  documentType: 'BOSA' | 'FOSA';
  description: string;
  postingDescription?: string | null;
  dividendYear: number;
  startDate: IsoDate;
  endDate: IsoDate;
  postingDate: IsoDate;
  postingType: 'Provisioning' | 'Payout';
  computationType: 'Automatic' | 'Manual Upload';
  transactionChargeId?: number | null;
  expenseAccountId?: number | null;
  payableAccountId?: number | null;
  recoverLoans?: boolean;
  boostToMinimum?: boolean;
  maximumBoostAmount?: Cents;
  preferentialBoost?: boolean;
  globalDimension1Id?: number | null;
  globalDimension2Id?: number | null;
}

const assertOpen = (d: { status: string; posted: number }): void => {
  if (Number(d.posted)) throw new AppError('This dividend has already been posted', 'VALIDATION');
  if (d.status !== 'Open') throw new AppError('Only an open dividend can be changed', 'VALIDATION');
};

export async function createDividend(input: DividendInput, user: Actor): Promise<{ no: string }> {
  if (!input.description.trim()) throw new AppError('A description is required', 'VALIDATION');
  if (input.endDate < input.startDate) throw new AppError('The end date cannot precede the start date', 'VALIDATION');
  const no = await nextSequence(input.documentType === 'FOSA' ? 'FOSA_DIVIDEND' : 'BOSA_DIVIDEND');
  await run(
    `INSERT INTO dividend
       (no, document_type, description, posting_description, dividend_year, start_date, end_date,
        posting_date, posting_type, computation_type, transaction_charge_id, expense_account_id,
        payable_account_id, recover_loans, boost_to_minimum, maximum_boost_amount, preferential_boost,
        global_dimension_1_id, global_dimension_2_id, created_at, created_by)
     VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)`,
    no, input.documentType, input.description.trim(),
    input.postingDescription?.trim() || input.description.trim(), input.dividendYear,
    input.startDate, input.endDate, input.postingDate, input.postingType, input.computationType,
    input.transactionChargeId ?? null, input.expenseAccountId ?? null, input.payableAccountId ?? null,
    input.recoverLoans ? 1 : 0, input.boostToMinimum ? 1 : 0, Math.round(input.maximumBoostAmount ?? 0),
    input.preferentialBoost ? 1 : 0, input.globalDimension1Id ?? null, input.globalDimension2Id ?? null,
    new Date().toISOString(), user.username,
  );
  await audit(user, 'DIVIDEND_CREATE', 'dividend', no, { year: input.dividendYear });
  return { no };
}

export async function updateDividend(no: string, input: DividendInput, user: Actor): Promise<void> {
  const before = await one<Dividend>('SELECT * FROM dividend WHERE no = ?', no);
  if (!before) throw new AppError('Dividend not found', 'NOT_FOUND');
  assertOpen(before);
  await run(
    `UPDATE dividend SET description = ?, posting_description = ?, dividend_year = ?, start_date = ?,
       end_date = ?, posting_date = ?, posting_type = ?, computation_type = ?, transaction_charge_id = ?,
       expense_account_id = ?, payable_account_id = ?, recover_loans = ?, boost_to_minimum = ?,
       maximum_boost_amount = ?, preferential_boost = ?, global_dimension_1_id = ?, global_dimension_2_id = ?
     WHERE no = ?`,
    input.description.trim(), input.postingDescription?.trim() || input.description.trim(),
    input.dividendYear, input.startDate, input.endDate, input.postingDate, input.postingType,
    input.computationType, input.transactionChargeId ?? null, input.expenseAccountId ?? null,
    input.payableAccountId ?? null, input.recoverLoans ? 1 : 0, input.boostToMinimum ? 1 : 0,
    Math.round(input.maximumBoostAmount ?? 0), input.preferentialBoost ? 1 : 0,
    input.globalDimension1Id ?? null, input.globalDimension2Id ?? null, no,
  );
  await audit(user, 'DIVIDEND_UPDATE', 'dividend', no, {});
}

export async function deleteDividend(no: string, user: Actor): Promise<void> {
  const before = await one<Dividend>('SELECT * FROM dividend WHERE no = ?', no);
  if (!before) throw new AppError('Dividend not found', 'NOT_FOUND');
  assertOpen(before);
  if (before.created_by !== user.username) {
    throw new AppError('Only the person who created this can delete it', 'NOT_CREATOR');
  }
  await run('DELETE FROM dividend WHERE no = ?', no);
  await audit(user, 'DIVIDEND_DELETE', 'dividend', no, {});
}

export interface DividendParamInput {
  productId: number;
  postingDescription: string;
  rate: number;
  rateType: DividendRateType;
  postTo: 'Savings' | 'Same Account' | 'Accrue';
  minimumBalance?: Cents;
  qualifiedMinimumBalance?: Cents;
  maximumBoostAmount?: Cents;
}

/** Replaces the whole parameter set — the grid is edited as a block, as on the AL subpage. */
export async function setDividendParams(no: string, params: DividendParamInput[], user: Actor): Promise<void> {
  const header = await one<Dividend>('SELECT * FROM dividend WHERE no = ?', no);
  if (!header) throw new AppError('Dividend not found', 'NOT_FOUND');
  assertOpen(header);
  await tx(async () => {
    await run('DELETE FROM dividend_param WHERE dividend_id = ?', header.id);
    for (const p of params) {
      if (!p.productId) continue;
      if (!p.postingDescription?.trim()) {
        throw new AppError('Every parameter line needs a posting description', 'VALIDATION');
      }
      const product = await one<{ id: number; category: string; min_balance: Cents }>(
        'SELECT id, category, min_balance FROM savings_product WHERE id = ?', p.productId,
      );
      if (!product) throw new AppError('Savings product not found', 'NOT_FOUND');
      await run(
        `INSERT INTO dividend_param
           (dividend_id, product_id, posting_description, rate, rate_type, post_to, is_share_capital,
            minimum_balance, qualified_minimum_balance, maximum_boost_amount)
         VALUES (?,?,?,?,?,?,?,?,?,?)`,
        header.id, p.productId, p.postingDescription.trim(), p.rate, p.rateType, p.postTo,
        product.category === 'SHARE CAPITAL ACCOUNT' ? 1 : 0,
        Math.round(p.minimumBalance ?? product.min_balance),
        Math.round(p.qualifiedMinimumBalance ?? product.min_balance),
        Math.round(p.maximumBoostAmount ?? 0),
      );
    }
  });
  await audit(user, 'DIVIDEND_PARAMS_SET', 'dividend', no, { count: params.length });
}

/* ------------------------------------------------------------------------ calculate */

const MONTH_CODES = ['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'];

const pad2 = (n: number): string => (n < 10 ? `0${n}` : String(n));

/** AL's GetPrefixCode() — "MAR-2026". */
const monthCode = (year: number, monthNo: number): string => `${MONTH_CODES[monthNo - 1]}-${year}`;

const startOfMonth = (year: number, monthNo: number): IsoDate => `${year}-${pad2(monthNo)}-01` as IsoDate;

/** Last calendar day of a month, as an ISO date. */
const endOfMonth = (year: number, monthNo: number): IsoDate =>
  new Date(Date.UTC(year, monthNo, 0)).toISOString().slice(0, 10) as IsoDate;

/**
 * AL's Ratio: month 1 earns a full year, month 12 earns one twelfth — (13 - month) / 12.
 *
 * The AL writes this as `Round(12/12)`, `Round(11/12)` … which, with AL's default whole-number
 * precision, collapses every month to 1 or 0. The fraction is plainly what was meant, and is
 * what a pro-rated dividend has to do to be worth anything, so it is what runs here.
 */
const proRataRatio = (monthNo: number): number => (13 - monthNo) / 12;

interface LedgerRow { value_date: IsoDate; amount: Cents }

/**
 * Every account's balance as at `date`, in one pass.
 *
 * The AL re-reads the ledger per member inside its month loop. A dividend run here touches every
 * account on every participating product, so the balance sweep is done once and indexed instead —
 * same numbers, one query rather than tens of thousands.
 */
async function balancesAsAt(date: IsoDate): Promise<Map<number, Cents>> {
  const rows = await all<{ id: number; s: Cents }>(
    `SELECT savings_account_id AS id, COALESCE(SUM(amount), 0) AS s
     FROM txn WHERE savings_account_id IS NOT NULL AND value_date <= ?
     GROUP BY savings_account_id`,
    date,
  );
  return new Map(rows.map((r) => [Number(r.id), Number(r.s)]));
}


/** The month-by-month working for one account: what it closed at, what moved, and how low it fell. */
interface MonthWork {
  monthNo: number;
  opening: Cents;
  closing: Cents;
  netChange: Cents;
  minRunning: Cents;
}

/**
 * Turns a ledger into one MonthWork per month in [fromMonth, toMonth].
 *
 * Month 1's Net Change is the whole closing balance, not just January's movement — the AL does the
 * same, because a balance brought forward from prior years has been invested for the full year and
 * has to earn the full-year ratio. From month 2 on, Net Change is that month's movement alone.
 */
function monthlyWork(ledger: LedgerRow[], year: number, fromMonth: number, toMonth: number): MonthWork[] {
  const firstDay = startOfMonth(year, fromMonth);
  let brought = 0;
  let i = 0;
  while (i < ledger.length && ledger[i].value_date < firstDay) {
    brought += Number(ledger[i].amount);
    i += 1;
  }

  const work: MonthWork[] = [];
  let previousClosing = brought;
  for (let m = fromMonth; m <= toMonth; m += 1) {
    const last = endOfMonth(year, m);
    let running = previousClosing;
    let minRunning = previousClosing;
    while (i < ledger.length && ledger[i].value_date <= last) {
      running += Number(ledger[i].amount);
      if (running < minRunning) minRunning = running;
      i += 1;
    }
    work.push({
      monthNo: m,
      opening: previousClosing,
      closing: running,
      netChange: m === fromMonth ? running : running - previousClosing,
      minRunning,
    });
    previousClosing = running;
  }
  return work;
}

interface ParamRow {
  id: number;
  product_id: number;
  posting_description: string;
  rate: number;
  rate_type: DividendRateType;
  post_to: 'Savings' | 'Same Account' | 'Accrue';
  is_share_capital: number;
  minimum_balance: Cents;
  qualified_minimum_balance: Cents;
  maximum_boost_amount: Cents;
}

interface LineRow {
  id: number;
  member_id: number;
  member_no: string;
  member_name: string;
  product_id: number;
  savings_account_id: number;
  account_no: string;
  destination_account_id: number | null;
  account_balance: Cents;
  amount_earned: Cents;
  preferential_boost: number;
  preferential_boost_pct: number;
}

interface CalcContext {
  header: Dividend;
  paramById: Map<number, ParamRow>;
  /** The member's FOSA / withdrawable account, where a Post To = Savings earning lands. */
  destinationByMember: Map<number, number>;
  /** The member's share-capital account, the target of a boost. */
  shareAccountByMember: Map<number, number>;
  /** Balances as at the dividend's end date, keyed by savings account. */
  balances: Map<number, Cents>;
  /** Every live loan in the SACCO, keyed by member — loaded once, not per member. */
  loansByMember: Map<number, LoanExposure[]>;
  /** The header's Transaction Charge, resolved once and applied in memory per line. */
  chargeDetail: TransactionChargeWithDetail | null;
  /** The minimum share capital a boost tops a member up to. */
  minimumShareCapital: Cents;
  fromMonth: number;
  toMonth: number;
}

/* ------------------------------------------------------------------ bulk writes */

/**
 * Multi-row INSERT in chunks.
 *
 * A dividend run writes a line per member account and up to twelve detail rows behind each. One
 * round trip per row is the difference between seconds and minutes against a hosted database, so
 * every write in this module goes through here or its returning-ids sibling. The chunk size keeps
 * each statement well inside PostgreSQL's 65 535 bind-parameter ceiling.
 */
async function insertRows(table: string, columns: string[], rows: unknown[][], chunk = 400): Promise<void> {
  if (!rows.length) return;
  const cols = columns.map((c) => `"${c}"`).join(', ');
  const tuple = `(${columns.map(() => '?').join(',')})`;
  for (let i = 0; i < rows.length; i += chunk) {
    const slice = rows.slice(i, i + chunk);
    await run(`INSERT INTO "${table}" (${cols}) VALUES ${slice.map(() => tuple).join(', ')}`, ...slice.flat());
  }
}

/** Same, but hands back the new ids in insert order — the dividend lines everything else keys off. */
async function insertRowsReturningIds(
  table: string, columns: string[], rows: unknown[][], chunk = 400,
): Promise<number[]> {
  if (!rows.length) return [];
  const cols = columns.map((c) => `"${c}"`).join(', ');
  const tuple = `(${columns.map(() => '?').join(',')})`;
  const ids: number[] = [];
  for (let i = 0; i < rows.length; i += chunk) {
    const slice = rows.slice(i, i + chunk);
    const inserted = await all<{ id: number }>(
      `INSERT INTO "${table}" (${cols}) VALUES ${slice.map(() => tuple).join(', ')} RETURNING id`,
      ...slice.flat(),
    );
    for (const r of inserted) ids.push(Number(r.id));
  }
  return ids;
}

/** AL PrepareDividendCalculation() — a re-run starts from a clean sheet. */
async function prepareCalculation(dividendId: number): Promise<void> {
  await run('DELETE FROM dividend_recovery WHERE dividend_id = ?', dividendId);
  await run('DELETE FROM dividend_det_entry WHERE dividend_id = ?', dividendId);
  await run('DELETE FROM dividend_line WHERE dividend_id = ?', dividendId);
  await run('DELETE FROM dividend_withdrawn_member WHERE dividend_id = ?', dividendId);
}

const tidyName = (name: string): string => name.split(' ').filter(Boolean).join(' ');

/**
 * AL PopulateWithdrawnMembers() — members whose exit matured inside the dividend year. They are
 * recorded for the officer to see rather than excluded automatically: the AL lists them the same
 * way, and whether a leaver still earns is a policy call, not an arithmetic one.
 */
async function populateWithdrawnMembers(header: Dividend): Promise<number> {
  const rows = await all<{ member_id: number; member_no: string; name: string; no: string; maturity_date: string }>(
    `SELECT e.member_id, m.member_no,
            TRIM(COALESCE(m.first_name,'') || ' ' || COALESCE(m.middle_name,'') || ' ' || COALESCE(m.last_name,'')) AS name,
            e.no, e.maturity_date
     FROM member_exit e JOIN member m ON m.id = e.member_id
     WHERE e.status = 'Processed' AND e.maturity_date >= ? AND e.maturity_date <= ?`,
    `${header.dividend_year}-01-01`, `${header.dividend_year}-12-31`,
  );
  // One row per member: a member can only have one processed exit, but the unique index is what
  // guarantees it, so distinct-by-member here keeps the batch insert from tripping over itself.
  const seen = new Set<number>();
  const values: unknown[][] = [];
  for (const r of rows) {
    if (seen.has(Number(r.member_id))) continue;
    seen.add(Number(r.member_id));
    values.push([header.id, r.member_id, r.member_no, tidyName(r.name), r.no, r.maturity_date]);
  }
  await insertRows(
    'dividend_withdrawn_member',
    ['dividend_id', 'member_id', 'member_no', 'member_name', 'exit_no', 'maturity_date'],
    values,
  );
  return values.length;
}

/**
 * AL PopulateDivindedMembers() + PopulateMemberList(): one line per member account held on a
 * participating product. AL skips members flagged "Dividend Exempt"; this schema has no such
 * flag, so a closed account is the only exclusion.
 *
 * Returns the lines it created, so nothing downstream has to read them back.
 */
async function populateLines(ctx: CalcContext): Promise<LineRow[]> {
  const created: LineRow[] = [];
  for (const p of ctx.paramById.values()) {
    const accounts = await all<{
      id: number; account_no: string; member_id: number; member_no: string; name: string;
      status: string; phone: string | null; member_status: string;
    }>(
      `SELECT sa.id, sa.account_no, sa.member_id, m.member_no, sa.status,
              TRIM(COALESCE(m.first_name,'') || ' ' || COALESCE(m.middle_name,'') || ' ' || COALESCE(m.last_name,'')) AS name,
              m.phone, m.status AS member_status
       FROM savings_account sa JOIN member m ON m.id = sa.member_id
       WHERE sa.product_id = ? AND sa.status <> 'CLOSED'
       ORDER BY m.member_no, sa.account_no`,
      p.product_id,
    );
    if (!accounts.length) continue;

    const pending = accounts.map((a) => {
      // Post To = Same Account credits the earning account itself; Savings looks for the member's
      // withdrawable account and falls back to the earning account when they hold none, rather
      // than silently dropping the earning. Accrue credits nobody — it stays in the payable.
      const destination = p.post_to === 'Same Account'
        ? a.id
        : p.post_to === 'Savings' ? (ctx.destinationByMember.get(a.member_id) ?? a.id) : null;
      return {
        member_id: Number(a.member_id),
        member_no: a.member_no,
        member_name: tidyName(a.name),
        product_id: p.product_id,
        savings_account_id: Number(a.id),
        account_no: a.account_no,
        destination_account_id: destination,
        account_balance: ctx.balances.get(Number(a.id)) ?? 0,
        deceased: a.member_status === 'DECEASED' ? 1 : 0,
        blocked: a.status === 'FROZEN' ? 1 : 0,
        phone: a.phone,
      };
    });

    const ids = await insertRowsReturningIds(
      'dividend_line',
      ['dividend_id', 'member_id', 'member_no', 'member_name', 'product_id', 'savings_account_id',
        'account_no', 'destination_account_id', 'posting_description', 'account_balance',
        'deceased', 'blocked_account', 'phone_no'],
      pending.map((r) => [
        ctx.header.id, r.member_id, r.member_no, r.member_name, r.product_id, r.savings_account_id,
        r.account_no, r.destination_account_id, p.posting_description, r.account_balance,
        r.deceased, r.blocked, r.phone,
      ]),
    );

    pending.forEach((r, i) => created.push({
      id: ids[i],
      member_id: r.member_id,
      member_no: r.member_no,
      member_name: r.member_name,
      product_id: r.product_id,
      savings_account_id: r.savings_account_id,
      account_no: r.account_no,
      destination_account_id: r.destination_account_id,
      account_balance: r.account_balance,
      amount_earned: 0,
      preferential_boost: 0,
      preferential_boost_pct: 0,
    }));
  }
  return created;
}

/** One account per member on a given product category — the Post To = Savings destination
 *  (WITHDRAWABLE DEPOSIT) and the boost target (SHARE CAPITAL ACCOUNT). */
async function loadAccountsByCategory(category: string): Promise<Map<number, number>> {
  const rows = await all<{ member_id: number; id: number }>(
    `SELECT DISTINCT ON (sa.member_id) sa.member_id, sa.id
     FROM savings_account sa JOIN savings_product sp ON sp.id = sa.product_id
     WHERE sa.status <> 'CLOSED' AND sp.category = ?
     ORDER BY sa.member_id, sa.id`,
    category,
  );
  return new Map(rows.map((r) => [Number(r.member_id), Number(r.id)]));
}

/** Every participating account's ledger for one product, in a single read, keyed by account. */
async function loadProductLedgers(productId: number, to: IsoDate): Promise<Map<number, LedgerRow[]>> {
  const rows = await all<{ savings_account_id: number; value_date: IsoDate; amount: Cents }>(
    `SELECT t.savings_account_id, t.value_date, t.amount
     FROM txn t JOIN savings_account sa ON sa.id = t.savings_account_id
     WHERE sa.product_id = ? AND t.value_date <= ?
     ORDER BY t.savings_account_id, t.value_date, t.id`,
    productId, to,
  );
  const byAccount = new Map<number, LedgerRow[]>();
  for (const r of rows) {
    const key = Number(r.savings_account_id);
    const list = byAccount.get(key);
    if (list) list.push({ value_date: r.value_date, amount: Number(r.amount) });
    else byAccount.set(key, [{ value_date: r.value_date, amount: Number(r.amount) }]);
  }
  return byAccount;
}

const DET_COLUMNS = [
  'dividend_id', 'dividend_line_id', 'member_id', 'savings_account_id', 'month_no', 'year',
  'month_code', 'description', 'posting_type', 'rate', 'ratio', 'min_balance',
  'previous_month_balance', 'current_month_balance', 'net_change', 'minimum_running_balance', 'amount',
];

/**
 * AL PopulatePreviousAccounts() and the monthly earning loop, for one line.
 *
 * Three models, and which one runs is the parameter line's Rate Type — set per savings product:
 *
 *   Pro Rated         AL's BOSA model, for Non-Withdrawable Deposits and Share Capital. The
 *                     balance standing at the end of the first month earns the full year; every
 *                     later month earns on its own *increase*, weighted by how much of the year
 *                     is left — (13 - month)/12, so a deposit made in March earns ten twelfths.
 *                     A later month only counts as a genuine increase on an account already above
 *                     the product's Minimum Balance. A withdrawal never claws back what earlier
 *                     months earned; it simply earns nothing itself.
 *
 *   Minimum Balance   AL's FOSA model — the bank passbook rule, for withdrawable accounts. Each
 *                     month earns on the *lowest* balance the account held during that month,
 *                     above the product's Min. Interest Earning Balance, at one twelfth of the
 *                     annual rate. A balance that dipped mid-month is only rewarded for the part
 *                     that actually stayed.
 *
 *   Straight Line     One entry on the closing balance at the full rate — a flat declaration on
 *                     share capital, where no monthly working is wanted.
 *
 * The model is a property of the *product*, not of the document: a single declaration can cover
 * BOSA deposits pro-rated and FOSA savings on the bank model at the same time, which is why this
 * reads the parameter line's Rate Type and never the header's book.
 *
 * Returns what the account earned and appends the working to `det`, which is written in bulk once
 * the whole product has been walked — that working is what the member's dividend slip prints.
 */
function computeLineEarning(
  ctx: CalcContext, line: LineRow, p: ParamRow, ledger: LedgerRow[], det: unknown[][],
): Cents {
  const { header } = ctx;
  const year = header.dividend_year;
  const rate = Number(p.rate) || 0;

  if (p.rate_type === 'Straight Line') {
    const closing = Number(line.account_balance);
    const amount = closing >= Number(p.minimum_balance) ? Math.round(closing * (rate / 100)) : 0;
    det.push([
      header.id, line.id, line.member_id, line.savings_account_id, ctx.toMonth, year,
      monthCode(year, ctx.toMonth), `${p.posting_description} — closing balance`, 'Straight Line',
      rate, 1, p.minimum_balance, 0, closing, closing, closing, amount,
    ]);
    return amount;
  }

  const onMinimumBalance = p.rate_type === 'Minimum Balance';
  let earned = 0;
  for (const w of monthlyWork(ledger, year, ctx.fromMonth, ctx.toMonth)) {
    let amount = 0;
    let ratio = 1;

    if (onMinimumBalance) {
      const base = w.minRunning - Number(p.qualified_minimum_balance);
      ratio = 1 / 12;
      amount = base > 0 ? Math.round(base * (rate / 100) * ratio) : 0;
    } else {
      ratio = proRataRatio(w.monthNo);
      const qualifies = w.monthNo === ctx.fromMonth
        || (w.netChange > 0 && w.closing > Number(p.minimum_balance));
      amount = qualifies && w.netChange > 0 ? Math.round(w.netChange * (rate / 100) * ratio) : 0;
    }

    if (amount < 0) amount = 0;
    earned += amount;
    det.push([
      header.id, line.id, line.member_id, line.savings_account_id, w.monthNo, year,
      monthCode(year, w.monthNo), p.posting_description, p.rate_type,
      rate, ratio, onMinimumBalance ? p.qualified_minimum_balance : p.minimum_balance,
      w.opening, w.closing, w.netChange, w.minRunning, amount,
    ]);
  }
  return earned;
}

/* ------------------------------------------------------------------- recoveries */

const RECOVERY_COLUMNS = [
  'dividend_id', 'dividend_line_id', 'member_id', 'entry_type', 'recovery_code', 'description',
  'loan_id', 'target_account_id', 'charge_id', 'amount', 'priority',
];

/**
 * AL CalculateDividendCharges() — the header's Charge Code run against what the account earned.
 *
 * The stored rows are the *plan*: posting re-runs the same Transaction Charge setup, so the G/L
 * split always comes from the live configuration rather than a snapshot that could have drifted
 * between calculation and posting.
 */
function calculateCharges(
  ctx: CalcContext, line: LineRow, earned: Cents, out: unknown[][],
): Cents {
  if (!ctx.chargeDetail || earned <= 0) return 0;
  let total = 0;
  for (const c of calculateTransactionCharges(ctx.chargeDetail, earned)) {
    const amount = Math.min(c.amount, earned + total);
    if (amount <= 0) continue;
    total -= amount;
    out.push([
      ctx.header.id, line.id, line.member_id, 'CHARGES', c.chargeCode, c.chargeDescription,
      null, null, ctx.header.transaction_charge_id, -amount, 10,
    ]);
  }
  return total;
}

/** What a loan still owes, split into what is overdue and what is merely outstanding. */
interface LoanExposure {
  id: number;
  member_id: number;
  loan_no: string;
  principal_balance: Cents;
  interest_balance: Cents;
  penalty_balance: Cents;
  arrears_interest: Cents;
  arrears_principal: Cents;
}

/** Every live loan in the SACCO with its arrears split, in one read, keyed by member. */
async function loadLoanExposure(asAt: IsoDate): Promise<Map<number, LoanExposure[]>> {
  const rows = await all<LoanExposure>(
    `SELECT l.id, l.member_id, l.loan_no, l.principal_balance, l.interest_balance, l.penalty_balance,
            COALESCE((SELECT SUM(GREATEST(s.interest_due - s.interest_paid, 0)) FROM loan_schedule s
                       WHERE s.loan_id = l.id AND s.due_date <= ? AND s.status <> 'PAID'), 0) AS arrears_interest,
            COALESCE((SELECT SUM(GREATEST(s.principal_due - s.principal_paid, 0)) FROM loan_schedule s
                       WHERE s.loan_id = l.id AND s.due_date <= ? AND s.status <> 'PAID'), 0) AS arrears_principal
     FROM loan l
     WHERE l.status = 'DISBURSED' AND (l.principal_balance + l.interest_balance + l.penalty_balance) > 0
     ORDER BY l.member_id, l.days_in_arrears DESC, l.id`,
    asAt, asAt,
  );
  const byMember = new Map<number, LoanExposure[]>();
  for (const r of rows) {
    const key = Number(r.member_id);
    const list = byMember.get(key);
    if (list) list.push(r);
    else byMember.set(key, [r]);
  }
  return byMember;
}

/**
 * AL LoanRecoveries() — the member's dividend is applied against what they owe before any of it
 * is paid out, in the order a repayment itself is allocated: penalties, then overdue interest and
 * principal, then the balance of each.
 *
 * Run once per member (on their largest-earning line), not once per account: a member with three
 * participating accounts owes one set of loans, and recovering against each line in turn would
 * take the debt three times over.
 *
 * The stored rows are a plan, as with charges. Posting hands the per-loan total to
 * lib/loanService.ts's repay(), which does the authoritative interest/principal allocation against
 * the live schedule — so a line's recovery *total* always posts exactly, even where repay() splits
 * it between interest and principal a shilling differently from the plan below.
 */
function loanRecoveries(ctx: CalcContext, line: LineRow, available: Cents, out: unknown[][]): Cents {
  if (!Number(ctx.header.recover_loans) || available <= 0) return 0;
  const loans = ctx.loansByMember.get(line.member_id);
  if (!loans?.length) return 0;

  let pool = available;
  let total = 0;
  for (const loan of loans) {
    if (pool <= 0) break;
    const arrearsInterest = Math.min(Number(loan.arrears_interest), Number(loan.interest_balance));
    const arrearsPrincipal = Math.min(Number(loan.arrears_principal), Number(loan.principal_balance));
    const buckets: { type: DividendRecoveryEntryType; label: string; cap: Cents; priority: number }[] = [
      { type: 'PENALTY', label: 'Penalties', cap: Number(loan.penalty_balance), priority: 20 },
      { type: 'INTEREST_ARREARS', label: 'Interest in arrears', cap: arrearsInterest, priority: 21 },
      { type: 'PRINCIPAL_ARREARS', label: 'Principal in arrears', cap: arrearsPrincipal, priority: 22 },
      { type: 'INTEREST_PAID', label: 'Interest outstanding', cap: Number(loan.interest_balance) - arrearsInterest, priority: 23 },
      { type: 'PRINCIPAL_PAID', label: 'Principal outstanding', cap: Number(loan.principal_balance) - arrearsPrincipal, priority: 24 },
    ];
    for (const b of buckets) {
      if (pool <= 0) break;
      const amount = Math.min(pool, Math.max(0, b.cap));
      if (amount <= 0) continue;
      pool -= amount;
      total -= amount;
      out.push([
        ctx.header.id, line.id, line.member_id, b.type, loan.loan_no,
        `${b.label} — loan ${loan.loan_no}`, loan.id, null, null, -amount, b.priority,
      ]);
    }
  }
  return total;
}

/**
 * AL ComputeDividendBoosts() — top a member's share capital up to the statutory minimum out of
 * their dividend before any of it is paid away. Capped by the header's Maximum Boost Amount and,
 * where set, the parameter's own.
 */
function computeDividendBoost(
  ctx: CalcContext, line: LineRow, p: ParamRow, available: Cents, out: unknown[][],
): Cents {
  if (!Number(ctx.header.boost_to_minimum) || available <= 0 || ctx.minimumShareCapital <= 0) return 0;
  const target = ctx.shareAccountByMember.get(line.member_id);
  if (!target) return 0;
  const held = ctx.balances.get(target) ?? 0;
  const shortfall = ctx.minimumShareCapital - held;
  if (shortfall <= 0) return 0;

  const caps = [available, shortfall];
  if (Number(ctx.header.maximum_boost_amount) > 0) caps.push(Number(ctx.header.maximum_boost_amount));
  if (Number(p.maximum_boost_amount) > 0) caps.push(Number(p.maximum_boost_amount));
  const amount = Math.min(...caps);
  if (amount <= 0) return 0;

  // The boost counts against the share account immediately, so a member with several earning
  // accounts is topped up to the minimum once rather than once per account.
  ctx.balances.set(target, held + amount);
  out.push([
    ctx.header.id, line.id, line.member_id, 'BOOST', 'SHARE-BOOST',
    'Share capital boost to minimum', null, target, null, -amount, 30,
  ]);
  return -amount;
}

/**
 * AL ComputePreferentialBoost() — a member who has elected to plough a fixed percentage of their
 * dividend back into share capital, over and above any top-up to the minimum.
 */
function computePreferentialBoost(
  ctx: CalcContext, line: LineRow, earned: Cents, available: Cents, out: unknown[][],
): Cents {
  if (!Number(ctx.header.preferential_boost) || !Number(line.preferential_boost)) return 0;
  const pct = Number(line.preferential_boost_pct) || 0;
  if (pct <= 0 || available <= 0) return 0;
  const target = ctx.shareAccountByMember.get(line.member_id);
  if (!target) return 0;
  const amount = Math.min(available, Math.round(earned * (pct / 100)));
  if (amount <= 0) return 0;
  ctx.balances.set(target, (ctx.balances.get(target) ?? 0) + amount);
  out.push([
    ctx.header.id, line.id, line.member_id, 'PREFERENTIAL_BOOST', 'PREF-BOOST',
    `Preferential boost at ${pct}% to share capital`, null, target, null, -amount, 31,
  ]);
  return -amount;
}

/* ---------------------------------------------------------------- orchestration */

export interface DividendCalculationResult {
  lines: number;
  members: number;
  withdrawn: number;
  totalEarned: Cents;
  totalRecoveries: Cents;
  totalNet: Cents;
}

/** A whole-membership sweep is legitimately longer than a document posting. */
const CALCULATION_TIMEOUT_MS = 10 * 60 * 1000;

/**
 * AL CalculateDividend(): prepare -> lines -> withdrawn members -> monthly detail -> charges
 * -> boosts -> preferential boost -> loan recoveries -> net amount.
 *
 * Idempotent: every run starts by clearing the previous one's working, so an officer can adjust a
 * rate and recalculate as many times as they like until the figures are right.
 *
 * Every read is per product or per SACCO, never per member, and every write is batched — the AL
 * loops row by row, which against a hosted database would spend the whole run waiting on round
 * trips rather than computing.
 */
export async function calculateDividend(no: string, user: Actor): Promise<DividendCalculationResult> {
  const header = await one<Dividend>('SELECT * FROM dividend WHERE no = ?', no);
  if (!header) throw new AppError('Dividend not found', 'NOT_FOUND');
  assertOpen(header);

  const params = await all<ParamRow>('SELECT * FROM dividend_param WHERE dividend_id = ?', header.id);
  if (!params.length) throw new AppError('Add at least one calculation parameter first', 'VALIDATION');

  const result = await tx(async (): Promise<DividendCalculationResult> => {
    await prepareCalculation(header.id);

    const [destinations, shares, balances, shareMinimum, loansByMember, chargeDetail] = await Promise.all([
      loadAccountsByCategory('WITHDRAWABLE DEPOSIT'),
      loadAccountsByCategory('SHARE CAPITAL ACCOUNT'),
      balancesAsAt(header.end_date),
      // The statutory minimum share capital: the share-capital product's own floor, taking the
      // higher of Minimum Balance and Minimum Opening — this schema keeps both, AL keeps one.
      one<{ m: Cents }>(
        `SELECT COALESCE(MAX(GREATEST(min_balance, min_opening)), 0) AS m
         FROM savings_product WHERE category = 'SHARE CAPITAL ACCOUNT'`,
      ),
      Number(header.recover_loans) ? loadLoanExposure(header.posting_date) : new Map<number, LoanExposure[]>(),
      header.transaction_charge_id ? getTransactionCharge(header.transaction_charge_id) : null,
    ]);

    const ctx: CalcContext = {
      header,
      paramById: new Map(params.map((p) => [p.product_id, p])),
      destinationByMember: destinations,
      shareAccountByMember: shares,
      balances,
      loansByMember,
      chargeDetail,
      minimumShareCapital: Number(shareMinimum?.m ?? 0),
      fromMonth: Number(header.start_date.slice(5, 7)),
      toMonth: Number(header.end_date.slice(5, 7)),
    };

    const withdrawn = await populateWithdrawnMembers(header);
    const lines = await populateLines(ctx);

    // Manual Upload takes the earnings as given rather than deriving them, so the monthly walk is
    // skipped entirely — everything downstream (charges, boosts, recoveries) still applies.
    const manual = new Map<number, Cents>();
    if (header.computation_type === 'Manual Upload') {
      const rows = await all<{ savings_account_id: number; amount: Cents }>(
        'SELECT savings_account_id, amount FROM dividend_earned_entry WHERE dividend_id = ?', header.id,
      );
      for (const r of rows) manual.set(Number(r.savings_account_id), Number(r.amount));
    }

    const earnedByLine = new Map<number, Cents>();
    if (header.computation_type === 'Manual Upload') {
      for (const line of lines) {
        const earned = manual.get(line.savings_account_id) ?? 0;
        line.amount_earned = earned;
        earnedByLine.set(line.id, earned);
      }
    } else {
      // Product by product: one ledger read covers every account on it, and the whole product's
      // monthly working goes back in one batch.
      for (const p of ctx.paramById.values()) {
        const productLines = lines.filter((l) => l.product_id === p.product_id);
        if (!productLines.length) continue;
        const ledgers = p.rate_type === 'Straight Line'
          ? new Map<number, LedgerRow[]>()
          : await loadProductLedgers(p.product_id, header.end_date);
        const det: unknown[][] = [];
        for (const line of productLines) {
          const earned = computeLineEarning(ctx, line, p, ledgers.get(line.savings_account_id) ?? [], det);
          line.amount_earned = earned;
          earnedByLine.set(line.id, earned);
        }
        await insertRows('dividend_det_entry', DET_COLUMNS, det);
      }
    }

    const earnedUpdates = lines
      .filter((l) => l.amount_earned !== 0)
      .map((l) => [l.id, l.amount_earned] as const);
    await applyEarnedAmounts(earnedUpdates);

    // Loan recovery and the share boosts are member-level concerns; they attach to whichever of
    // the member's lines earns the most, so a member's debt is never taken twice over.
    const primaryByMember = new Map<number, LineRow>();
    for (const line of lines) {
      const current = primaryByMember.get(line.member_id);
      if (!current || line.amount_earned > current.amount_earned) primaryByMember.set(line.member_id, line);
    }

    const recoveries: unknown[][] = [];
    for (const line of lines) {
      const p = ctx.paramById.get(line.product_id);
      if (!p || line.amount_earned <= 0) continue;
      let taken = calculateCharges(ctx, line, line.amount_earned, recoveries);
      if (primaryByMember.get(line.member_id)?.id === line.id) {
        taken += computeDividendBoost(ctx, line, p, line.amount_earned + taken, recoveries);
        taken += computePreferentialBoost(ctx, line, line.amount_earned, line.amount_earned + taken, recoveries);
        taken += loanRecoveries(ctx, line, line.amount_earned + taken, recoveries);
      }
    }
    await insertRows('dividend_recovery', RECOVERY_COLUMNS, recoveries);

    // AL CalculateNetAmount(): earnings less everything recovered, in one sweep.
    await run(
      `UPDATE dividend_line l SET
         total_recoveries = COALESCE((SELECT SUM(r.amount) FROM dividend_recovery r WHERE r.dividend_line_id = l.id), 0),
         net_amount = l.amount_earned
           + COALESCE((SELECT SUM(r.amount) FROM dividend_recovery r WHERE r.dividend_line_id = l.id), 0)
       WHERE l.dividend_id = ?`,
      header.id,
    );
    await run('UPDATE dividend SET calculated_at = ? WHERE id = ?', new Date().toISOString(), header.id);

    const totals = await one<{ earned: Cents; recoveries: Cents; net: Cents; members: number }>(
      `SELECT COALESCE(SUM(amount_earned), 0) AS earned, COALESCE(SUM(total_recoveries), 0) AS recoveries,
              COALESCE(SUM(net_amount), 0) AS net, COUNT(DISTINCT member_id) AS members
       FROM dividend_line WHERE dividend_id = ?`,
      header.id,
    );
    return {
      lines: lines.length,
      members: Number(totals?.members ?? 0),
      withdrawn,
      totalEarned: Number(totals?.earned ?? 0),
      totalRecoveries: Number(totals?.recoveries ?? 0),
      totalNet: Number(totals?.net ?? 0),
    };
  }, { timeout: CALCULATION_TIMEOUT_MS });

  await audit(user, 'DIVIDEND_CALCULATE', 'dividend', no, result);
  return result;
}

/** Writes the computed earnings back in bulk — one UPDATE ... FROM (VALUES ...) per chunk rather
 *  than one statement per line. */
async function applyEarnedAmounts(updates: readonly (readonly [number, Cents])[], chunk = 500): Promise<void> {
  for (let i = 0; i < updates.length; i += chunk) {
    const slice = updates.slice(i, i + chunk);
    await run(
      `UPDATE dividend_line l SET amount_earned = v.amount
       FROM (VALUES ${slice.map(() => '(?::int, ?::bigint)').join(', ')}) AS v(id, amount)
       WHERE l.id = v.id`,
      ...slice.flatMap(([id, amount]) => [id, amount]),
    );
  }
}

/* ------------------------------------------------------------- line adjustments */

/** A manual override on one line — the AL subpage lets the officer type an Amount Earned and flag
 *  a member for the preferential boost before the document goes for approval. */
export async function updateDividendLine(
  no: string,
  lineId: number,
  input: { amountEarned?: Cents; preferentialBoost?: boolean; preferentialBoostPct?: number },
  user: Actor,
): Promise<void> {
  const header = await one<Dividend>('SELECT * FROM dividend WHERE no = ?', no);
  if (!header) throw new AppError('Dividend not found', 'NOT_FOUND');
  assertOpen(header);
  const line = await one<{ id: number }>(
    'SELECT id FROM dividend_line WHERE id = ? AND dividend_id = ?', lineId, header.id,
  );
  if (!line) throw new AppError('Dividend line not found', 'NOT_FOUND');
  if (input.amountEarned != null && input.amountEarned < 0) {
    throw new AppError('An amount earned cannot be negative', 'VALIDATION');
  }
  const pct = input.preferentialBoostPct ?? 0;
  if (pct < 0 || pct > 100) throw new AppError('The preferential boost must be between 0 and 100%', 'VALIDATION');

  await run(
    `UPDATE dividend_line SET
       amount_earned = COALESCE(?, amount_earned),
       preferential_boost = ?, preferential_boost_pct = ?,
       net_amount = COALESCE(?, amount_earned) + total_recoveries
     WHERE id = ?`,
    input.amountEarned ?? null, input.preferentialBoost ? 1 : 0, pct, input.amountEarned ?? null, lineId,
  );
  await audit(user, 'DIVIDEND_LINE_UPDATE', 'dividend', no, { lineId, ...input });
}

/* --------------------------------------------------------------------- workflow */

export async function submitDividend(no: string, user: Actor): Promise<{ autoApproved: boolean }> {
  const header = await one<Dividend>('SELECT * FROM dividend WHERE no = ?', no);
  if (!header) throw new AppError('Dividend not found', 'NOT_FOUND');
  if (header.status !== 'Open') throw new AppError('Only an open dividend can be submitted for approval', 'VALIDATION');
  if (!header.calculated_at) throw new AppError('Calculate the dividend before submitting it for approval', 'VALIDATION');
  await assertPostable(header);

  const totals = await one<{ net: Cents }>(
    'SELECT COALESCE(SUM(net_amount), 0) AS net FROM dividend_line WHERE dividend_id = ?', header.id,
  );
  const matched = await findMatchingWorkflow('DIVIDEND', await pickConditionFields('DIVIDEND', header));
  if (!matched) throw new AppError('There is no enabled workflow for this document', 'NO_WORKFLOW');

  await tx(async () => {
    await run("UPDATE dividend SET status = 'Pending Approval' WHERE no = ?", no);
    await startWorkflow(matched.workflow, matched.steps, {
      documentType: 'DIVIDEND', entityId: no, requestedBy: user.username, amount: Number(totals?.net ?? 0),
    });
  });

  const after = await one<{ status: string }>('SELECT status FROM dividend WHERE no = ?', no);
  return { autoApproved: after?.status === 'Approved' };
}

export async function cancelDividendApproval(no: string, user: Actor): Promise<void> {
  const header = await one<Pick<Dividend, 'status' | 'created_by'>>(
    'SELECT status, created_by FROM dividend WHERE no = ?', no,
  );
  if (!header) throw new AppError('Dividend not found', 'NOT_FOUND');
  if (header.status !== 'Pending Approval') throw new AppError('Only a dividend pending approval can be recalled', 'VALIDATION');
  const routed = await findPendingRoutedTask('DIVIDEND', no);
  const requestedBy = routed?.requested_by ?? header.created_by;
  if (requestedBy !== user.username) {
    throw new AppError('Only the person who submitted this dividend can recall it', 'NOT_REQUESTER');
  }
  await run("UPDATE dividend SET status = 'Open' WHERE no = ?", no);
  await audit(user, 'DIVIDEND_CANCEL_APPROVAL', 'dividend', no, {});
}

export async function approveDividend(no: string, user: Actor): Promise<void> {
  const header = await one<Dividend>('SELECT * FROM dividend WHERE no = ?', no);
  if (!header) throw new AppError('Dividend not found', 'NOT_FOUND');
  if (header.status !== 'Pending Approval') throw new AppError('Only a dividend pending approval can be approved', 'VALIDATION');
  await run("UPDATE dividend SET status = 'Approved', decision_reason = NULL WHERE no = ?", no);
  await audit(user, 'DIVIDEND_APPROVE', 'dividend', no, {});
}

export async function rejectDividend(no: string, reason: string | null, user: Actor): Promise<void> {
  if (!reason || !reason.trim()) throw new AppError('A reason is required to reject a dividend', 'VALIDATION');
  const header = await one<Dividend>('SELECT * FROM dividend WHERE no = ?', no);
  if (!header) throw new AppError('Dividend not found', 'NOT_FOUND');
  if (header.status !== 'Pending Approval') throw new AppError('Only a dividend pending approval can be rejected', 'VALIDATION');
  await run("UPDATE dividend SET status = 'Open', decision_reason = ? WHERE no = ?", reason.trim(), no);
  await audit(user, 'DIVIDEND_REJECT', 'dividend', no, { reason });
}

/** An Approved, not-yet-posted dividend back to Open for amendment (AL's "Re&open"). */
export async function reopenDividend(no: string, user: Actor): Promise<void> {
  const header = await one<Dividend>('SELECT * FROM dividend WHERE no = ?', no);
  if (!header) throw new AppError('Dividend not found', 'NOT_FOUND');
  if (header.status !== 'Approved' || Number(header.posted)) {
    throw new AppError('Only an approved dividend that has not been posted can be reopened', 'VALIDATION');
  }
  await run("UPDATE dividend SET status = 'Open' WHERE no = ?", no);
  await audit(user, 'DIVIDEND_REOPEN', 'dividend', no, {});
}

/* ---------------------------------------------------------------------- posting */

/** The G/L accounts each posting type needs before it can run. */
async function assertPostable(header: Dividend): Promise<void> {
  if (!header.payable_account_id) {
    throw new AppError('Set the Dividend Payable account on the header first', 'VALIDATION');
  }
  if (header.posting_type === 'Provisioning' && !header.expense_account_id) {
    throw new AppError('Set the Dividend Expense account on the header first', 'VALIDATION');
  }
}

interface PayoutLine {
  id: number;
  member_id: number;
  member_no: string;
  member_name: string;
  savings_account_id: number;
  account_no: string;
  destination_account_id: number | null;
  destination_control_id: number | null;
  destination_balance: Cents;
  destination_status: string | null;
  posting_description: string | null;
  amount_earned: Cents;
  total_recoveries: Cents;
  net_amount: Cents;
}

const PAYOUT_LINE_SELECT = `
  SELECT l.id, l.member_id, l.member_no, l.member_name, l.savings_account_id, l.account_no,
         l.destination_account_id, sp.gl_control_id AS destination_control_id,
         da.balance AS destination_balance, da.status AS destination_status,
         l.posting_description, l.amount_earned, l.total_recoveries, l.net_amount
  FROM dividend_line l
  LEFT JOIN savings_account da ON da.id = l.destination_account_id
  LEFT JOIN savings_product sp ON sp.id = da.product_id
  WHERE l.dividend_id = ? AND l.posted = 0 AND l.amount_earned > 0
  ORDER BY l.member_no, l.account_no`;

/** How many member accounts one committed slice of a payout covers, and how many loan recoveries
 *  are queried at a time. Small enough that a slice finishes well inside a transaction timeout,
 *  large enough that the per-chunk journals stay few. */
const PAYOUT_CHUNK = 200;
const RECOVERY_CHUNK = 100;

export interface DividendPostResult {
  journalNo: string;
  postingType: DividendPostingType;
  lines: number;
  gross: Cents;
  charged: Cents;
  boosted: Cents;
  recovered: Cents;
  net: Cents;
}

/**
 * AL PostDividend(), in its two modes.
 *
 * **Provisioning** raises the liability: Dr Dividend Expense, Cr Dividend Payable, one pair of
 * journal lines per participating product so the G/L narration carries each product's own posting
 * description. (AL posts a line per member; at SACCO scale that is tens of thousands of G/L
 * entries saying the same thing, and the member-level detail already lives in dividend_line.)
 *
 * **Payout** settles it. Each earning account is credited its *gross* earning, and the recoveries
 * are then taken out of the receiving account in turn — charges, share-capital boosts, then loans.
 * The AL nets them off before crediting; posting them as real movements instead means the member's
 * statement shows what they earned and what each deduction was for, and the loan recovery goes
 * through lib/loanService.ts's repay(), so schedules, arrears and interest/principal allocation
 * are all maintained by the one engine that owns them. The account is left with the same net.
 */
export async function postDividend(no: string, user: Actor): Promise<DividendPostResult> {
  const header = await one<Dividend>('SELECT * FROM dividend WHERE no = ?', no);
  if (!header) throw new AppError('Dividend not found', 'NOT_FOUND');
  if (Number(header.posted)) throw new AppError('This dividend has already been posted', 'VALIDATION');
  if (header.status !== 'Approved') throw new AppError('Only an approved dividend can be posted', 'VALIDATION');
  await assertPostable(header);

  const valueDate = header.posting_date;
  const description = header.posting_description || header.description;

  // Provisioning is a handful of G/L lines and posts atomically. A payout touches every member and
  // commits in chunks instead — see postPayout().
  const result = header.posting_type === 'Provisioning'
    ? await tx(async () => postProvisioning(header, valueDate, description, user))
    : await postPayout(header, valueDate, description, user);

  await audit(user, 'DIVIDEND_POST', 'dividend', no, result);
  return result;
}

/** Dr Dividend Expense / Cr Dividend Payable, per participating product. */
async function postProvisioning(
  header: Dividend, valueDate: IsoDate, description: string, user: Actor,
): Promise<DividendPostResult> {
  const byProduct = await all<{ posting_description: string; earned: Cents }>(
    `SELECT COALESCE(MAX(l.posting_description), sp.name) AS posting_description,
            COALESCE(SUM(l.amount_earned), 0) AS earned
     FROM dividend_line l JOIN savings_product sp ON sp.id = l.product_id
     WHERE l.dividend_id = ? GROUP BY sp.id ORDER BY sp.code`,
    header.id,
  );
  const lines: JournalLineInput[] = [];
  let gross = 0;
  for (const p of byProduct) {
    const amount = Number(p.earned);
    if (amount <= 0) continue;
    gross += amount;
    lines.push({ account: header.expense_account_id!, debit: amount, credit: 0, narration: p.posting_description });
    lines.push({ account: header.payable_account_id!, debit: 0, credit: amount, narration: p.posting_description });
  }
  if (!gross) throw new AppError('This dividend has nothing to post — calculate it first', 'VALIDATION');

  const journal = await postJournal({
    valueDate, module: 'DIVIDEND', eventType: 'DIVIDEND_PROVISION', description, reference: header.no,
    user, lines, idempotencyKey: `DIVIDEND-PROV-${header.no}`,
    globalDimension1Id: header.global_dimension_1_id, globalDimension2Id: header.global_dimension_2_id,
  });

  await run(
    `UPDATE dividend SET posted = 1, posted_at = ?, posted_by = ?, journal_id = ? WHERE id = ?`,
    new Date().toISOString(), user.username, journal.id, header.id,
  );
  const count = await one<{ n: number }>(
    'SELECT COUNT(*) AS n FROM dividend_line WHERE dividend_id = ? AND amount_earned > 0', header.id,
  );
  return {
    journalNo: journal.journal_no, postingType: 'Provisioning', lines: Number(count?.n ?? 0),
    gross, charged: 0, boosted: 0, recovered: 0, net: gross,
  };
}

/** Credit each member, then take the recoveries back out of the receiving account.
 *
 * Posted in chunks that each commit on their own, because a whole membership will not fit in one
 * transaction against a hosted database — the earlier single-transaction version timed out on a
 * 115-member test set, and a real SACCO has thousands. Each chunk marks what it has done
 * (dividend_line.posted, dividend_recovery.posted), so a run that is interrupted picks up exactly
 * where it stopped when it is run again, and nothing can post twice.
 */
async function postPayout(
  header: Dividend, valueDate: IsoDate, description: string, user: Actor,
): Promise<DividendPostResult> {
  const totals = { gross: 0, charged: 0, boosted: 0, recovered: 0, lines: 0 };
  let firstJournalNo: string | null = null;
  let firstJournalId: number | null = null;

  const chargeDetail = header.transaction_charge_id
    ? await getTransactionCharge(header.transaction_charge_id)
    : null;

  // Pre-flight: repay() refuses to touch a Dormant member's loan, so a dividend that plans a loan
  // recovery for one would stop halfway through. Surface it up front, with the members named,
  // rather than leaving a half-posted payout behind.
  const dormant = await all<{ member_no: string; member_name: string }>(
    `SELECT DISTINCT l.member_no, l.member_name
     FROM dividend_recovery r JOIN dividend_line l ON l.id = r.dividend_line_id
     JOIN member m ON m.id = r.member_id
     WHERE r.dividend_id = ? AND r.posted = 0 AND r.loan_id IS NOT NULL AND m.status = 'DORMANT'
     ORDER BY l.member_no LIMIT 10`,
    header.id,
  );
  if (dormant.length) {
    throw new AppError(
      `Loan recovery is planned for Dormant members (${dormant.map((d) => `${d.member_no} ${d.member_name}`).join(', ')}). `
      + 'Update their status, or clear Recover Loans and recalculate, before posting.',
      'MEMBER_DORMANT',
    );
  }

  /* ---- 1. the member credits, and the charges and boosts taken back out of them */

  for (;;) {
    const chunk = await all<PayoutLine>(`${PAYOUT_LINE_SELECT} LIMIT ${PAYOUT_CHUNK}`, header.id);
    if (!chunk.length) break;

    const posted = await tx(async () => postPayoutChunk(header, chunk, chargeDetail, valueDate, description, user));
    if (!firstJournalNo) {
      firstJournalNo = posted.journalNo;
      firstJournalId = posted.journalId;
    }
    totals.gross += posted.gross;
    totals.charged += posted.charged;
    totals.boosted += posted.boosted;
    totals.lines += chunk.length;
  }

  /* ---- 2. loan recoveries, through the repayment engine, one loan per transaction */

  for (;;) {
    const plan = await all<{ dividend_line_id: number; loan_id: number; loan_no: string; amount: Cents; account_id: number }>(
      `SELECT r.dividend_line_id, r.loan_id, l.loan_no, SUM(ABS(r.amount)) AS amount,
              MAX(dl.destination_account_id) AS account_id
       FROM dividend_recovery r
       JOIN loan l ON l.id = r.loan_id
       JOIN dividend_line dl ON dl.id = r.dividend_line_id
       WHERE r.dividend_id = ? AND r.posted = 0 AND r.loan_id IS NOT NULL
       GROUP BY r.dividend_line_id, r.loan_id, l.loan_no
       ORDER BY r.dividend_line_id, r.loan_id
       LIMIT ${RECOVERY_CHUNK}`,
      header.id,
    );
    if (!plan.length) break;

    for (const p of plan) {
      totals.recovered += await tx(async (): Promise<Cents> => {
        const owed = await one<{ owed: Cents; status: string }>(
          'SELECT (principal_balance + interest_balance + penalty_balance) AS owed, status FROM loan WHERE id = ?',
          p.loan_id,
        );
        // The loan may have been settled between calculation and posting; recover only what is
        // still due, and mark the plan done either way so the run can move on.
        const amount = Math.min(Number(p.amount), Number(owed?.owed ?? 0));
        if (owed && owed.status === 'DISBURSED' && amount > 0 && p.account_id) {
          await repay({
            loanId: Number(p.loan_id), amount, valueDate, channel: 'SYSTEM',
            description: `Dividend recovery ${header.no} — ${p.loan_no}`,
            fromSavingsAccountId: Number(p.account_id), user,
          });
        }
        await run(
          'UPDATE dividend_recovery SET posted = 1 WHERE dividend_id = ? AND dividend_line_id = ? AND loan_id = ?',
          header.id, p.dividend_line_id, p.loan_id,
        );
        return owed && owed.status === 'DISBURSED' && p.account_id ? amount : 0;
      });
    }
  }

  /* ---- 3. close the document once nothing is left unposted */

  const outstanding = await one<{ lines: number; recoveries: number }>(
    `SELECT (SELECT COUNT(*) FROM dividend_line WHERE dividend_id = ? AND posted = 0 AND amount_earned > 0) AS lines,
            (SELECT COUNT(*) FROM dividend_recovery WHERE dividend_id = ? AND posted = 0) AS recoveries`,
    header.id, header.id,
  );
  if (Number(outstanding?.lines ?? 0) || Number(outstanding?.recoveries ?? 0)) {
    throw new AppError(
      'The payout stopped part way through. Nothing already posted was lost — post again to continue '
      + `from where it stopped (${Number(outstanding?.lines ?? 0)} accounts and `
      + `${Number(outstanding?.recoveries ?? 0)} recoveries still to go).`,
      'PARTIALLY_POSTED',
    );
  }
  await run(
    'UPDATE dividend SET posted = 1, posted_at = ?, posted_by = ?, journal_id = COALESCE(journal_id, ?) WHERE id = ?',
    new Date().toISOString(), user.username, firstJournalId, header.id,
  );

  return {
    journalNo: firstJournalNo ?? '',
    postingType: 'Payout',
    lines: totals.lines,
    gross: totals.gross,
    charged: totals.charged,
    boosted: totals.boosted,
    recovered: totals.recovered,
    net: totals.gross - totals.charged - totals.boosted - totals.recovered,
  };
}

interface ChunkResult { journalNo: string; journalId: number; gross: Cents; charged: Cents; boosted: Cents }

/**
 * One committed slice of a payout: the gross credit, its charges and its share-capital boosts, for
 * up to PAYOUT_CHUNK member accounts.
 *
 * Every member movement is a real ledger entry rather than a netted-off figure, so a member's
 * statement shows what they earned and what each deduction was for — the AL nets them before
 * crediting, which leaves the member no way to see where the rest of it went.
 */
async function postPayoutChunk(
  header: Dividend,
  lines: PayoutLine[],
  chargeDetail: TransactionChargeWithDetail | null,
  valueDate: IsoDate,
  description: string,
  user: Actor,
): Promise<ChunkResult> {
  const creditable = lines.filter((l) => l.destination_account_id && l.destination_control_id);
  const accrued = lines.filter((l) => !l.destination_account_id);

  // Running per-account balances, so several lines paying into one account (a member with two
  // participating products, both posting to their FOSA) stay in step.
  const balances = new Map<number, Cents>();
  for (const l of creditable) balances.set(l.destination_account_id!, Number(l.destination_balance ?? 0));

  /** A member ledger entry to write — buffered so the whole chunk goes back in one statement. */
  interface Movement {
    accountId: number; memberId: number; amount: Cents; txnType: string; narration: string; journalId: number;
  }
  const movements: Movement[] = [];
  const move = (m: Movement): void => {
    balances.set(m.accountId, (balances.get(m.accountId) ?? 0) + m.amount);
    movements.push(m);
  };

  /* the gross credit: Dr Dividend Payable, Cr each receiving deposit control */

  const byControl = new Map<number, Cents>();
  let gross = 0;
  for (const l of creditable) {
    const amount = Number(l.amount_earned);
    gross += amount;
    byControl.set(l.destination_control_id!, (byControl.get(l.destination_control_id!) ?? 0) + amount);
  }

  const journal = await postJournal({
    valueDate, module: 'DIVIDEND', eventType: 'DIVIDEND_PAYOUT', description, reference: header.no, user,
    globalDimension1Id: header.global_dimension_1_id, globalDimension2Id: header.global_dimension_2_id,
    lines: [
      { account: header.payable_account_id!, debit: gross, credit: 0, narration: description },
      ...[...byControl.entries()].map(([account, amount]): JournalLineInput => (
        { account, debit: 0, credit: amount, narration: description }
      )),
    ],
  });
  for (const l of creditable) {
    move({
      accountId: l.destination_account_id!, memberId: l.member_id, amount: Number(l.amount_earned),
      txnType: 'DIVIDEND', narration: `${l.posting_description || description} — ${l.account_no}`,
      journalId: journal.id,
    });
  }

  /* charges, taken back out of the receiving account */

  let charged = 0;
  if (chargeDetail) {
    const perLine: { line: PayoutLine; codes: string; total: Cents }[] = [];
    const byChargeAccount = new Map<number, Cents>();
    const byDepositControl = new Map<number, Cents>();
    for (const l of creditable) {
      const components = calculateTransactionCharges(chargeDetail, Number(l.amount_earned));
      const total = components.reduce((s, c) => s + c.amount, 0);
      if (total <= 0) continue;
      perLine.push({ line: l, codes: components.map((c) => c.chargeCode).join(', '), total });
      charged += total;
      for (const c of components) byChargeAccount.set(c.glAccountId, (byChargeAccount.get(c.glAccountId) ?? 0) + c.amount);
      byDepositControl.set(l.destination_control_id!, (byDepositControl.get(l.destination_control_id!) ?? 0) + total);
    }
    if (charged > 0) {
      const chargeJournal = await postJournal({
        valueDate, module: 'DIVIDEND', eventType: 'DIVIDEND_CHARGE',
        description: `${description} — charges`, reference: header.no, user,
        globalDimension1Id: header.global_dimension_1_id, globalDimension2Id: header.global_dimension_2_id,
        lines: [
          ...[...byDepositControl.entries()].map(([account, amount]): JournalLineInput => (
            { account, debit: amount, credit: 0, narration: 'Dividend charge' }
          )),
          ...[...byChargeAccount.entries()].map(([account, amount]): JournalLineInput => (
            { account, debit: 0, credit: amount, narration: 'Dividend charge' }
          )),
        ],
      });
      for (const p of perLine) {
        move({
          accountId: p.line.destination_account_id!, memberId: p.line.member_id, amount: -p.total,
          txnType: 'FEE', narration: `Dividend charge — ${p.codes}`, journalId: chargeJournal.id,
        });
      }
    }
  }

  /* share-capital boosts: out of the receiving account, into the share account */

  const lineById = new Map(creditable.map((l) => [l.id, l]));
  const boosts = creditable.length
    ? await all<{
      dividend_line_id: number; member_id: number; target_account_id: number; description: string;
      amount: Cents; control_id: number; balance: Cents;
    }>(
      `SELECT r.dividend_line_id, r.member_id, r.target_account_id, r.description, r.amount,
              sp.gl_control_id AS control_id, sa.balance
       FROM dividend_recovery r
       JOIN savings_account sa ON sa.id = r.target_account_id
       JOIN savings_product sp ON sp.id = sa.product_id
       WHERE r.dividend_id = ? AND r.posted = 0 AND r.entry_type IN ('BOOST', 'PREFERENTIAL_BOOST')
         AND r.dividend_line_id IN (${creditable.map(() => '?').join(',')})
       ORDER BY r.dividend_line_id, r.id`,
      header.id, ...creditable.map((l) => l.id),
    )
    : [];

  let boosted = 0;
  if (boosts.length) {
    const fromControl = new Map<number, Cents>();
    const toControl = new Map<number, Cents>();
    for (const b of boosts) {
      const line = lineById.get(Number(b.dividend_line_id));
      if (!line?.destination_control_id) continue;
      const amount = Math.abs(Number(b.amount));
      boosted += amount;
      fromControl.set(line.destination_control_id, (fromControl.get(line.destination_control_id) ?? 0) + amount);
      toControl.set(Number(b.control_id), (toControl.get(Number(b.control_id)) ?? 0) + amount);
    }
    if (boosted > 0) {
      const boostJournal = await postJournal({
        valueDate, module: 'DIVIDEND', eventType: 'DIVIDEND_BOOST',
        description: `${description} — share capital boost`, reference: header.no, user,
        globalDimension1Id: header.global_dimension_1_id, globalDimension2Id: header.global_dimension_2_id,
        lines: [
          ...[...fromControl.entries()].map(([account, amount]): JournalLineInput => (
            { account, debit: amount, credit: 0, narration: 'Share capital boost' }
          )),
          ...[...toControl.entries()].map(([account, amount]): JournalLineInput => (
            { account, debit: 0, credit: amount, narration: 'Share capital boost' }
          )),
        ],
      });
      for (const b of boosts) {
        const line = lineById.get(Number(b.dividend_line_id));
        if (!line?.destination_control_id) continue;
        const amount = Math.abs(Number(b.amount));
        if (!balances.has(Number(b.target_account_id))) balances.set(Number(b.target_account_id), Number(b.balance));
        move({
          accountId: line.destination_account_id!, memberId: line.member_id, amount: -amount,
          txnType: 'TRANSFER', narration: b.description, journalId: boostJournal.id,
        });
        move({
          accountId: Number(b.target_account_id), memberId: Number(b.member_id), amount,
          txnType: 'TRANSFER', narration: b.description, journalId: boostJournal.id,
        });
      }
      await run(
        `UPDATE dividend_recovery SET posted = 1
         WHERE dividend_id = ? AND entry_type IN ('BOOST', 'PREFERENTIAL_BOOST')
           AND dividend_line_id IN (${creditable.map(() => '?').join(',')})`,
        header.id, ...creditable.map((l) => l.id),
      );
    }
  }

  /* write the member ledger in bulk — the running balance on each entry is the one this chunk
     arrived at, in the order the movements were made */

  const running = new Map<number, Cents>();
  for (const l of creditable) running.set(l.destination_account_id!, Number(l.destination_balance ?? 0));
  for (const b of boosts) {
    if (!running.has(Number(b.target_account_id))) running.set(Number(b.target_account_id), Number(b.balance));
  }
  const refs = await nextSequenceBatch('TXN', movements.length);
  const now = new Date().toISOString();
  const txnRows = movements.map((m, i) => {
    const next = (running.get(m.accountId) ?? 0) + m.amount;
    running.set(m.accountId, next);
    return [
      refs[i], valueDate, now, 'DIVIDEND', m.txnType, m.memberId, m.accountId,
      m.amount, next, 'SYSTEM', m.narration, m.journalId, user.username,
    ];
  });
  await insertRows(
    'txn',
    ['txn_ref', 'value_date', 'created_at', 'module', 'txn_type', 'member_id', 'savings_account_id',
      'amount', 'running_balance', 'channel', 'description', 'journal_id', 'created_by'],
    txnRows,
  );

  // Balances, in one statement. A credit also wakes a dormant account, exactly as a deposit does.
  const finals = [...balances.entries()];
  if (finals.length) {
    await run(
      `UPDATE savings_account sa SET balance = v.balance, last_activity = ?, version = sa.version + 1,
         status = CASE WHEN sa.status = 'DORMANT' THEN 'ACTIVE' ELSE sa.status END
       FROM (VALUES ${finals.map(() => '(?::int, ?::bigint)').join(', ')}) AS v(id, balance)
       WHERE sa.id = v.id`,
      valueDate, ...finals.flatMap(([id, balance]) => [id, balance]),
    );
  }

  const done = [...creditable, ...accrued].map((l) => l.id);
  await run(
    `UPDATE dividend_line SET posted = 1 WHERE id IN (${done.map(() => '?').join(',')})`, ...done,
  );

  return { journalNo: journal.journal_no, journalId: journal.id, gross, charged, boosted };
}

/* --------------------------------------------------------------- manual upload */

/** AL "Dividend Earned Entries" — the amounts a Manual Upload dividend takes as given, keyed by
 *  member account. Replaces the whole set, the same way setDividendParams() does. */
export async function setDividendEarnedEntries(
  no: string, rows: { savingsAccountId: number; amount: Cents; description?: string | null }[], user: Actor,
): Promise<{ count: number; total: Cents }> {
  const header = await one<Dividend>('SELECT * FROM dividend WHERE no = ?', no);
  if (!header) throw new AppError('Dividend not found', 'NOT_FOUND');
  assertOpen(header);
  if (header.computation_type !== 'Manual Upload') {
    throw new AppError('Amounts can only be uploaded onto a Manual Upload dividend', 'VALIDATION');
  }

  let total = 0;
  await tx(async () => {
    await run('DELETE FROM dividend_earned_entry WHERE dividend_id = ?', header.id);
    for (const r of rows) {
      const account = await one<{ id: number; member_id: number }>(
        'SELECT id, member_id FROM savings_account WHERE id = ?', r.savingsAccountId,
      );
      if (!account) throw new AppError(`Savings account ${r.savingsAccountId} not found`, 'NOT_FOUND');
      const amount = Math.round(r.amount);
      if (amount < 0) throw new AppError('An uploaded amount cannot be negative', 'VALIDATION');
      total += amount;
      await run(
        `INSERT INTO dividend_earned_entry (dividend_id, member_id, savings_account_id, description, amount, created_at, created_by)
         VALUES (?,?,?,?,?,?,?)
         ON CONFLICT (dividend_id, savings_account_id) DO UPDATE SET amount = EXCLUDED.amount, description = EXCLUDED.description`,
        header.id, account.member_id, account.id, r.description ?? null, amount,
        new Date().toISOString(), user.username,
      );
    }
  });
  await audit(user, 'DIVIDEND_EARNED_UPLOAD', 'dividend', no, { count: rows.length, total });
  return { count: rows.length, total };
}

export const listDividendEarnedEntries = (
  dividendId: number,
): Promise<{ id: number; member_no: string; member_name: string; account_no: string; description: string | null; amount: Cents }[]> =>
  all(
    `SELECT e.id, m.member_no,
            TRIM(COALESCE(m.first_name,'') || ' ' || COALESCE(m.last_name,'')) AS member_name,
            sa.account_no, e.description, e.amount
     FROM dividend_earned_entry e
     JOIN member m ON m.id = e.member_id
     JOIN savings_account sa ON sa.id = e.savings_account_id
     WHERE e.dividend_id = ? ORDER BY m.member_no`,
    dividendId,
  );
