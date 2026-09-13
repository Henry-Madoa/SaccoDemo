/*
 * Share Trading — AL Tab52204133 "Share Trading Setup", Tab52204134 "Share Floating",
 * Tab52204135 "Share Trading Lines", Tab52204136 "Share Transfer Receipt",
 * Cod52204022 "Share Trading Mgmt", Pag52204212-24, Rep52204076-77.
 *
 * A member who wants out of some of their share capital cannot simply withdraw it — share
 * capital is the SACCO's equity — so they sell it to another member. This module is that market.
 *
 *   Trading window  (share_trading_window)  the terms every sale in the window runs on: par
 *                                            (base) price, reserve price, holding and clearing
 *                                            G/L, charge, how long a sale stays up, how long a
 *                                            buyer has to pay, what to do when nobody bids.
 *                                            Only one window is Published at a time.
 *   Floating        (share_floating)         one member's offer: how many shares and the least
 *                                            they will take per share.
 *   Bid             (share_bid)              another member's price for the whole lot.
 *   Receipt         (share_transfer_receipt) the winning buyer's payment, allocated from their
 *                                            deposit accounts.
 *
 * Lifecycle (the AL keeps Published / Awarded / Archived as flags beside the document status;
 * `stage` below reads them as one word):
 *
 *   Open → Pending Approval → Approved                        maker-checker on the offer
 *   Publish Sale       shares leave the seller at par into the Holding account      [On Market]
 *   Bids               members bid between the seller's minimum and par
 *   Analyse Bids       the highest bid wins; the earliest on a tie
 *   Post Purchase      the buyer's debt is raised on the Clearing account           [Awarded]
 *   Allocate payment   from the buyer's deposit accounts, up to the bid total
 *   Transfer Shares    the buyer pays, receives the shares at par, the seller is paid
 *                      at the bid price, and the charge goes to income               [Closed]
 *   Take Down          a published, un-awarded floating is reversed                  [Closed]
 *   No-bid rule        an expired floating with no bids is extended or reversed
 *
 * The G/L, with F = shares × par, P = shares × bid, C = the buyer's charge, T = P + C:
 *   Publish    Dr seller share control F      Cr Holding F
 *   Purchase   Dr Clearing T                  Cr Holding T
 *   Transfer   Dr buyer deposit controls T    Cr Clearing T
 *              Dr Holding F                   Cr buyer share control F
 *              Dr Holding P                   Cr seller proceeds control P
 *              Dr Holding C                   Cr charge income C
 *   Holding nets to zero on a completed trade; Clearing nets to zero once the buyer has paid.
 *   The seller's own charge on the premium (P − F), if the window has one, is a separate
 *   self-balancing charge journal — Cod52204022's AddCharges on the Proceeds Account.
 */
import { one, all, run, tx, nextSequence, audit, hasAnyRow } from './db.ts';
import { AppError } from './errors.ts';
import { postJournal } from './accounting.ts';
import { getJournal, type JournalDetail } from './gl.ts';
import {
  getTransactionCharge, calculateTransactionCharges, postTransactionCharges,
} from './charges.ts';
import { resolvePostingDate } from './postingDates.ts';
import { applyDateFormula } from './dateFormula.ts';
import { assertMemberNotDormant } from './memberDormancy.ts';
import { findMatchingWorkflow, findPendingRoutedTask, pickConditionFields, startWorkflow } from './workflow.ts';
import { buildFilterClause, type FilterCondition, type FilterFieldDef } from './listFilters.ts';
import { buildOrderClause, type SortState } from './listSort.ts';
import { formatDate, formatMoney, today } from './format.ts';
import { sendSms } from './sms.ts';
import { sendMail } from './mailer.ts';
import type {
  Actor, Cents, IsoDate, JournalLineInput, ShareBidView, ShareFloating, ShareFloatingDetail, ShareFloatingStage,
  ShareFloatingView, ShareFloatType, ShareOnNoBid, ShareProceedsType, ShareTradeSource,
  ShareTradingWindow, ShareTradingWindowView, ShareTransferReceiptView,
} from './types.ts';

export const SHARE_FLOAT_TYPES: ShareFloatType[] = ['Partial', 'Full'];
export const SHARE_PROCEEDS_TYPES: ShareProceedsType[] = ['FOSA Account', 'NWD Account'];
export const SHARE_ON_NO_BID: ShareOnNoBid[] = ['Extend', 'Reverse'];
export const SHARE_TRADE_SOURCES: ShareTradeSource[] = ['Walking', 'App', 'USSD', 'Portal'];

/** When a window sets no Share Life, a published floating stays up this long. */
const DEFAULT_SHARE_LIFE = '30D';

/* ------------------------------------------------------------------ windows */

const SELECT_WINDOW = `
  SELECT w.*,
         tc.code AS transaction_charge_code,
         ca.code AS clearing_account_code, ca.name AS clearing_account_name,
         ha.code AS holding_account_code, ha.name AS holding_account_name,
         COALESCE((SELECT SUM(f.shares_to_float) FROM share_floating f WHERE f.window_no = w.no AND f.published), 0)::int AS shares_on_market,
         COALESCE((SELECT SUM(f.floated_value) FROM share_floating f WHERE f.window_no = w.no AND f.published), 0)::bigint AS value_on_market,
         (SELECT COUNT(*) FROM share_floating f WHERE f.window_no = w.no)::int AS floatings
  FROM share_trading_window w
  LEFT JOIN transaction_charge tc ON tc.id = w.transaction_charge_id
  JOIN gl_account ca ON ca.id = w.clearing_account_id
  JOIN gl_account ha ON ha.id = w.holding_account_id`;

export const listShareTradingWindows = (): Promise<ShareTradingWindowView[]> =>
  all<ShareTradingWindowView>(`${SELECT_WINDOW} ORDER BY w.published DESC, w.start_date DESC, w.no DESC`);

export const getShareTradingWindow = (no: string): Promise<ShareTradingWindowView | undefined> =>
  one<ShareTradingWindowView>(`${SELECT_WINDOW} WHERE w.no = ?`, no);

/** The one window on the market — what a new floating is sold in (AL Share Floating OnInsert). */
export const publishedShareTradingWindow = (): Promise<ShareTradingWindowView | undefined> =>
  one<ShareTradingWindowView>(`${SELECT_WINDOW} WHERE w.published ORDER BY w.no DESC LIMIT 1`);

export interface ShareWindowInput {
  description: string;
  startDate: IsoDate;
  endDate: IsoDate;
  basePrice: Cents;
  reservePrice: Cents;
  transactionChargeId: number | null;
  clearingAccountId: number;
  holdingAccountId: number;
  shareLife: string | null;
  tolerancePeriod: string | null;
  onNoBid: ShareOnNoBid;
  minimumSharesToFloat: number;
}

async function assertWindowInput(input: ShareWindowInput): Promise<void> {
  if (!input.description?.trim()) throw new AppError('A description is required', 'VALIDATION');
  if (!input.startDate || !input.endDate) throw new AppError('The trading period needs a start and an end date', 'VALIDATION');
  if (input.endDate < input.startDate) throw new AppError('The end date cannot be before the start date', 'VALIDATION');
  if (!(input.basePrice > 0)) throw new AppError('The base (par) price per share must be more than zero', 'VALIDATION');
  if (input.reservePrice < 0) throw new AppError('The reserve price cannot be negative', 'VALIDATION');
  if (input.reservePrice > input.basePrice) throw new AppError('The reserve price cannot be above the base price', 'VALIDATION');
  if (!SHARE_ON_NO_BID.includes(input.onNoBid)) throw new AppError('Choose what happens when nobody bids', 'VALIDATION');
  if (input.minimumSharesToFloat < 0) throw new AppError('The minimum shares to float cannot be negative', 'VALIDATION');
  for (const [label, formula] of [['Share life', input.shareLife], ['Tolerance period', input.tolerancePeriod]] as const) {
    if (formula && applyDateFormula(today(), formula) === today() && !/^\s*0/.test(formula)) {
      throw new AppError(`${label} "${formula}" is not a date formula — use 30D, 2W, 1M …`, 'VALIDATION');
    }
  }
  for (const [label, id] of [['clearing', input.clearingAccountId], ['holding', input.holdingAccountId]] as const) {
    const acct = await one<{ is_postable: number; status: string }>('SELECT is_postable, status FROM gl_account WHERE id = ?', id);
    if (!acct || !acct.is_postable || acct.status !== 'ACTIVE') throw new AppError(`Pick an active posting G/L account for the ${label} account`, 'VALIDATION');
  }
  if (input.transactionChargeId != null && !(await getTransactionCharge(input.transactionChargeId))) {
    throw new AppError('Transaction charge not found', 'NOT_FOUND');
  }
}

export async function createShareTradingWindow(input: ShareWindowInput, user: Actor): Promise<{ no: string }> {
  await assertWindowInput(input);
  const no = await nextSequence('SHARE_TRADING_WINDOW');
  await run(
    `INSERT INTO share_trading_window
       (no, description, start_date, end_date, base_price, reserve_price, transaction_charge_id,
        clearing_account_id, holding_account_id, share_life, tolerance_period, on_no_bid,
        minimum_shares_to_float, created_at, created_by)
     VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)`,
    no, input.description.trim(), input.startDate, input.endDate, Math.round(input.basePrice),
    Math.round(input.reservePrice), input.transactionChargeId, input.clearingAccountId, input.holdingAccountId,
    input.shareLife?.trim() || null, input.tolerancePeriod?.trim() || null, input.onNoBid,
    Math.round(input.minimumSharesToFloat), new Date().toISOString(), user.username,
  );
  await audit(user, 'SHARE_WINDOW_CREATE', 'share_trading_window', no, { basePrice: input.basePrice });
  return { no };
}

export async function updateShareTradingWindow(no: string, input: ShareWindowInput, user: Actor): Promise<void> {
  const w = await one<ShareTradingWindow>('SELECT * FROM share_trading_window WHERE no = ?', no);
  if (!w) throw new AppError('Trading window not found', 'NOT_FOUND');
  await assertWindowInput(input);
  // A floating copies the window's terms when it is raised, so a published window may still be
  // edited — a change only reaches sales raised after it.
  await run(
    `UPDATE share_trading_window
     SET description = ?, start_date = ?, end_date = ?, base_price = ?, reserve_price = ?,
         transaction_charge_id = ?, clearing_account_id = ?, holding_account_id = ?, share_life = ?,
         tolerance_period = ?, on_no_bid = ?, minimum_shares_to_float = ?
     WHERE no = ?`,
    input.description.trim(), input.startDate, input.endDate, Math.round(input.basePrice),
    Math.round(input.reservePrice), input.transactionChargeId, input.clearingAccountId, input.holdingAccountId,
    input.shareLife?.trim() || null, input.tolerancePeriod?.trim() || null, input.onNoBid,
    Math.round(input.minimumSharesToFloat), no,
  );
  await audit(user, 'SHARE_WINDOW_UPDATE', 'share_trading_window', no, {});
}

export async function deleteShareTradingWindow(no: string, user: Actor): Promise<void> {
  if (await hasAnyRow('share_floating', 'window_no = ?', no)) {
    throw new AppError('This window has floatings under it and cannot be deleted — retire it instead', 'VALIDATION');
  }
  await run('DELETE FROM share_trading_window WHERE no = ?', no);
  await audit(user, 'SHARE_WINDOW_DELETE', 'share_trading_window', no, {});
}

/** Cod52204022.PublishShareTradingSetup: put this window on the market; whichever was there
 *  comes down (Tab52204133 Published.OnValidate keeps exactly one published). */
export async function publishShareTradingWindow(no: string, user: Actor): Promise<void> {
  const w = await one<ShareTradingWindow>('SELECT * FROM share_trading_window WHERE no = ?', no);
  if (!w) throw new AppError('Trading window not found', 'NOT_FOUND');
  if (w.published) throw new AppError('This window is already published', 'VALIDATION');
  if (w.end_date < today()) throw new AppError('This window has already ended — extend its end date first', 'VALIDATION');
  await tx(async () => {
    await run("UPDATE share_trading_window SET published = false, status = 'Retired' WHERE published = true AND no <> ?", no);
    await run("UPDATE share_trading_window SET published = true, status = 'Published' WHERE no = ?", no);
  });
  await audit(user, 'SHARE_WINDOW_PUBLISH', 'share_trading_window', no, {});
}

/** Cod52204022.TakeDownShareTradingSetup. Floatings already on the market stay up — they carry
 *  their own copy of the terms. */
export async function retireShareTradingWindow(no: string, user: Actor): Promise<void> {
  const w = await one<ShareTradingWindow>('SELECT * FROM share_trading_window WHERE no = ?', no);
  if (!w) throw new AppError('Trading window not found', 'NOT_FOUND');
  if (!w.published) throw new AppError('This window is not published', 'VALIDATION');
  await run("UPDATE share_trading_window SET published = false, status = 'Retired' WHERE no = ?", no);
  await audit(user, 'SHARE_WINDOW_RETIRE', 'share_trading_window', no, {});
}

/* ----------------------------------------------------------------- floatings */

export type ShareFloatingListView = 'open' | 'pending' | 'approved' | 'market' | 'awarded' | 'closed' | 'all';

const VIEW_CLAUSE: Record<ShareFloatingListView, string> = {
  open: "f.status = 'Open' AND NOT f.archived",
  pending: "f.status = 'Pending Approval'",
  approved: "f.status = 'Approved' AND NOT f.published AND NOT f.archived",
  market: 'f.published AND NOT f.awarded AND NOT f.archived',
  awarded: 'f.awarded AND NOT f.archived',
  closed: 'f.archived',
  all: 'TRUE',
};

const STAGE_EXPR = `CASE
  WHEN f.archived THEN 'Closed'
  WHEN f.awarded THEN 'Awarded'
  WHEN f.published THEN 'On Market'
  ELSE 'Draft' END`;

const SELECT_FLOATING = `
  SELECT f.*,
         m.member_no, m.first_name, m.last_name, m.phone AS member_phone, m.email AS member_email,
         sa.account_no AS share_account_no, sp.name AS share_product_name, sa.balance AS share_balance,
         pa.account_no AS proceeds_account_no, pp.name AS proceeds_product_name,
         w.description AS window_description, w.status AS window_status,
         tc.code AS transaction_charge_code,
         ${STAGE_EXPR} AS stage,
         (SELECT COUNT(*) FROM share_bid b WHERE b.floating_no = f.no)::int AS bids,
         COALESCE((SELECT MAX(b.bid_price) FROM share_bid b WHERE b.floating_no = f.no), 0)::bigint AS maximum_bid_price,
         COALESCE((SELECT SUM(b.total_amount) FROM share_bid b WHERE b.floating_no = f.no AND b.awarded), 0)::bigint AS payment_amount,
         COALESCE((SELECT SUM(r.allocated_amount) FROM share_transfer_receipt r WHERE r.floating_no = f.no), 0)::bigint AS allocated_amount,
         pj.journal_no AS publish_journal_no, uj.journal_no AS purchase_journal_no,
         tj.journal_no AS transfer_journal_no, dj.journal_no AS takedown_journal_no
  FROM share_floating f
  JOIN member m ON m.id = f.member_id
  JOIN savings_account sa ON sa.id = f.share_account_id
  JOIN savings_product sp ON sp.id = sa.product_id
  LEFT JOIN savings_account pa ON pa.id = f.proceeds_account_id
  LEFT JOIN savings_product pp ON pp.id = pa.product_id
  JOIN share_trading_window w ON w.no = f.window_no
  LEFT JOIN transaction_charge tc ON tc.id = w.transaction_charge_id
  LEFT JOIN journal pj ON pj.id = f.publish_journal_id
  LEFT JOIN journal uj ON uj.id = f.purchase_journal_id
  LEFT JOIN journal tj ON tj.id = f.transfer_journal_id
  LEFT JOIN journal dj ON dj.id = f.takedown_journal_id`;

export const SHARE_FLOATING_FILTER_FIELDS: FilterFieldDef[] = [
  { key: 'member_id', label: 'Seller', type: 'select', column: 'f.member_id' },
  { key: 'window_no', label: 'Window', type: 'select', column: 'f.window_no' },
  { key: 'float_type', label: 'Float type', type: 'select', column: 'f.float_type', options: SHARE_FLOAT_TYPES.map((v) => ({ value: v, label: v })) },
  { key: 'shares_to_float', label: 'Shares', type: 'number', column: 'f.shares_to_float' },
  { key: 'floated_value', label: 'Floated value', type: 'number', column: 'f.floated_value' },
  { key: 'published_on', label: 'Published on', type: 'date', column: 'f.published_on' },
];

const SORT_COLUMNS: Record<string, string> = {
  no: 'f.no', member: 'm.last_name, m.first_name', shares: 'f.shares_to_float', value: 'f.floated_value',
  price: 'f.minimum_acceptable_price', published_on: 'f.published_on', expiry: 'f.expiry_date', status: 'f.status',
};

export interface ListShareFloatingsOptions {
  view?: ShareFloatingListView;
  search?: string;
  filters?: FilterCondition[];
  sort?: SortState | null;
  memberId?: number;
}

export const listShareFloatings = ({ view = 'all', search = '', filters = [], sort = null, memberId }: ListShareFloatingsOptions = {}): Promise<ShareFloatingView[]> => {
  const { clause, params } = buildFilterClause(SHARE_FLOATING_FILTER_FIELDS, filters);
  const orderBy = buildOrderClause(SORT_COLUMNS, sort, 'f.no DESC');
  return all<ShareFloatingView>(
    `${SELECT_FLOATING}
     WHERE ${VIEW_CLAUSE[view]}
       AND (f.no LIKE @like OR m.member_no LIKE @like OR m.first_name LIKE @like OR m.last_name LIKE @like OR sa.account_no LIKE @like)
       ${memberId ? 'AND f.member_id = @memberId' : ''}
       ${clause}
     ${orderBy} LIMIT 500`,
    { like: `%${String(search).trim()}%`, memberId: memberId ?? null, ...params },
  );
};

export const hasAnyShareFloatings = (view: ShareFloatingListView = 'all'): Promise<boolean> =>
  hasAnyRow('share_floating f', VIEW_CLAUSE[view]);

export const getShareFloating = (no: string): Promise<ShareFloatingView | undefined> =>
  one<ShareFloatingView>(`${SELECT_FLOATING} WHERE f.no = ?`, no);

export const listShareBids = (no: string): Promise<ShareBidView[]> =>
  all<ShareBidView>(
    `SELECT b.*, m.member_no, m.first_name, m.last_name, m.phone AS member_phone, m.email AS member_email,
            sa.account_no AS share_account_no, sa.balance AS share_balance
     FROM share_bid b JOIN member m ON m.id = b.member_id JOIN savings_account sa ON sa.id = b.share_account_id
     WHERE b.floating_no = ? ORDER BY b.bid_price DESC, b.bid_date ASC`,
    no,
  );

export const listShareTransferReceipts = (no: string): Promise<ShareTransferReceiptView[]> =>
  all<ShareTransferReceiptView>(
    `SELECT r.*, sa.account_no, sp.name AS product_name, sa.balance,
            GREATEST(sa.balance - sa.hold_amount - sp.min_balance, 0)::bigint AS available
     FROM share_transfer_receipt r JOIN savings_account sa ON sa.id = r.savings_account_id
     JOIN savings_product sp ON sp.id = sa.product_id
     WHERE r.floating_no = ? ORDER BY r.id`,
    no,
  );

export async function getShareFloatingDetail(no: string): Promise<ShareFloatingDetail | undefined> {
  const head = await getShareFloating(no);
  if (!head) return undefined;
  const [bid_lines, receipts] = await Promise.all([listShareBids(no), listShareTransferReceipts(no)]);
  return { ...head, bid_lines, receipts };
}

export async function getAdjacentShareFloatingNos(
  no: string, view?: ShareFloatingListView,
): Promise<{ prevNo: string | null; nextNo: string | null }> {
  const clause = VIEW_CLAUSE[view ?? 'all'];
  const [prev, next] = await Promise.all([
    one<{ no: string }>(`SELECT f.no FROM share_floating f WHERE ${clause} AND f.no > ? ORDER BY f.no ASC LIMIT 1`, no),
    one<{ no: string }>(`SELECT f.no FROM share_floating f WHERE ${clause} AND f.no < ? ORDER BY f.no DESC LIMIT 1`, no),
  ]);
  return { prevNo: prev?.no ?? null, nextNo: next?.no ?? null };
}

/* ------------------------------------------------------------ member lookups */

interface MemberShareAccount {
  id: number; account_no: string; product_name: string; balance: Cents; hold_amount: Cents;
  min_balance: Cents; gl_control_id: number;
}

/** The member's share capital account — where shares are, and where a buyer's land. */
async function shareCapitalAccountOf(memberId: number): Promise<MemberShareAccount | undefined> {
  return one<MemberShareAccount>(
    `SELECT sa.id, sa.account_no, sp.name AS product_name, sa.balance, sa.hold_amount, sp.min_balance, sp.gl_control_id
     FROM savings_account sa JOIN savings_product sp ON sp.id = sa.product_id
     WHERE sa.member_id = ? AND sa.status = 'ACTIVE' AND sp.category = 'SHARE CAPITAL ACCOUNT'
     ORDER BY sa.id LIMIT 1`,
    memberId,
  );
}

export interface ShareMemberPosition {
  account: { id: number; account_no: string; product_name: string; balance: Cents; min_balance: Cents } | null;
  parValue: Cents;
  totalShares: number;
  /** Shares the member can float and still keep the product's minimum balance. */
  partialCeiling: number;
}

/** What a member has to sell in the published window — the form's read-only Total Shares. */
export async function shareMemberPosition(memberId: number, windowNo?: string | null): Promise<ShareMemberPosition> {
  const w = windowNo ? await getShareTradingWindow(windowNo) : await publishedShareTradingWindow();
  const account = await shareCapitalAccountOf(memberId);
  const par = Number(w?.base_price ?? 0);
  const totalShares = account && par > 0 ? Math.floor(Number(account.balance) / par) : 0;
  const keep = account && par > 0 ? Math.ceil(Number(account.min_balance) / par) : 0;
  return {
    account: account ? { id: account.id, account_no: account.account_no, product_name: account.product_name, balance: account.balance, min_balance: account.min_balance } : null,
    parValue: par,
    totalShares,
    partialCeiling: Math.max(totalShares - keep, 0),
  };
}

export interface ShareProceedsAccount { id: number; account_no: string; product_name: string; category: string; balance: Cents }

/** The seller's own deposit accounts that may take the proceeds (AL: FOSA Account = withdrawable,
 *  NWD Account = non-withdrawable). */
export const shareProceedsAccountsForMember = (memberId: number, type: ShareProceedsType): Promise<ShareProceedsAccount[]> =>
  all<ShareProceedsAccount>(
    `SELECT sa.id, sa.account_no, sp.name AS product_name, sp.category, sa.balance
     FROM savings_account sa JOIN savings_product sp ON sp.id = sa.product_id
     WHERE sa.member_id = ? AND sa.status = 'ACTIVE' AND sp.category = ?
     ORDER BY sa.account_no`,
    memberId, type === 'NWD Account' ? 'NON WITHDRAWABLE DEPOSIT' : 'WITHDRAWABLE DEPOSIT',
  );

export interface SharePaymentAccount { id: number; account_no: string; product_name: string; balance: Cents; available: Cents }

/** The buyer's deposit accounts a payment can be allocated from — withdrawable products only. */
export const sharePaymentAccountsForMember = (memberId: number): Promise<SharePaymentAccount[]> =>
  all<SharePaymentAccount>(
    `SELECT sa.id, sa.account_no, sp.name AS product_name, sa.balance,
            GREATEST(sa.balance - sa.hold_amount - sp.min_balance, 0)::bigint AS available
     FROM savings_account sa JOIN savings_product sp ON sp.id = sa.product_id
     WHERE sa.member_id = ? AND sa.status = 'ACTIVE' AND sp.allow_withdrawal = 1
       AND sp.category IN ('WITHDRAWABLE DEPOSIT', 'HOLIDAY ACCOUNT')
     ORDER BY sa.account_no`,
    memberId,
  );

/* ------------------------------------------------------------- create / edit */

export interface ShareFloatingInput {
  windowNo?: string | null;
  memberId: number;
  floatType: ShareFloatType;
  sharesToFloat: number;
  minimumAcceptablePrice: Cents;
  proceedsType: ShareProceedsType;
  proceedsAccountId: number | null;
  paymentMethodCode?: string | null;
  externalReferenceNo?: string | null;
  narration?: string | null;
  source?: ShareTradeSource;
}

interface ResolvedFloating {
  window: ShareTradingWindowView;
  account: MemberShareAccount;
  totalShares: number;
  sharesToFloat: number;
  floatedValue: Cents;
  chargeAmount: Cents;
}

/** Tab52204134's OnValidate triggers, run together: Share Type, Shares to Float, Minimum
 *  Acceptable Price, Floated Value and Charge Amount. */
async function resolveFloating(input: ShareFloatingInput): Promise<ResolvedFloating> {
  const window = input.windowNo ? await getShareTradingWindow(input.windowNo) : await publishedShareTradingWindow();
  if (!window) throw new AppError('There is no published trading window — publish one first', 'VALIDATION');
  if (!window.published) throw new AppError(`Trading window ${window.no} is not published`, 'VALIDATION');
  if (!SHARE_FLOAT_TYPES.includes(input.floatType)) throw new AppError('Choose Partial or Full', 'VALIDATION');
  if (!SHARE_PROCEEDS_TYPES.includes(input.proceedsType)) throw new AppError('Choose where the proceeds go', 'VALIDATION');

  const member = await one<{ status: string }>('SELECT status FROM member WHERE id = ?', input.memberId);
  if (!member) throw new AppError('Member not found', 'NOT_FOUND');
  if (member.status !== 'ACTIVE') throw new AppError('Only an active member can float shares', 'VALIDATION');
  const account = await shareCapitalAccountOf(input.memberId);
  if (!account) throw new AppError('This member has no active share capital account', 'VALIDATION');

  const par = Number(window.base_price);
  const totalShares = Math.floor(Number(account.balance) / par);
  if (totalShares <= 0) throw new AppError('This member holds no shares to float', 'VALIDATION');

  // Full floats the lot; Partial is what the member typed, kept above the product minimum.
  const sharesToFloat = input.floatType === 'Full' ? totalShares : Math.floor(Number(input.sharesToFloat));
  if (!(sharesToFloat > 0)) throw new AppError('Shares to float must be more than zero', 'VALIDATION');
  if (sharesToFloat > totalShares) throw new AppError(`You can only float up to ${totalShares} shares`, 'VALIDATION');
  if (sharesToFloat < window.minimum_shares_to_float) {
    throw new AppError(`The window's minimum is ${window.minimum_shares_to_float} shares per floating`, 'VALIDATION');
  }
  const floatedValue = sharesToFloat * par;
  if (input.floatType === 'Partial' && Number(account.balance) - floatedValue < Number(account.min_balance)) {
    throw new AppError(
      `For partial trading you cannot trade below the minimum share capital of ${formatMoney(account.min_balance)}`, 'VALIDATION',
    );
  }

  const price = Math.round(Number(input.minimumAcceptablePrice));
  if (!(price > 0)) throw new AppError('A minimum acceptable price per share is required', 'VALIDATION');
  if (price > par) throw new AppError(`You cannot ask more than the par value of ${formatMoney(par)}`, 'VALIDATION');
  if (price < Number(window.reserve_price)) throw new AppError(`You cannot go lower than the reserve price of ${formatMoney(window.reserve_price)}`, 'VALIDATION');

  if (input.proceedsAccountId != null) {
    const ok = (await shareProceedsAccountsForMember(input.memberId, input.proceedsType)).some((a) => a.id === input.proceedsAccountId);
    if (!ok) throw new AppError('The proceeds account must be one of the seller’s own accounts of the chosen type', 'VALIDATION');
  }

  // Charge Amount: the window's charge on Par × Shares (Tab52204134 field 36).
  let chargeAmount = 0;
  if (window.transaction_charge_id) {
    const detail = await getTransactionCharge(window.transaction_charge_id);
    if (detail) chargeAmount = calculateTransactionCharges(detail, floatedValue).reduce((s, c) => s + c.amount, 0);
  }
  return { window, account, totalShares, sharesToFloat, floatedValue, chargeAmount };
}

export async function createShareFloating(input: ShareFloatingInput, user: Actor): Promise<{ no: string }> {
  const r = await resolveFloating(input);
  const no = await nextSequence('SHARE_FLOATING');
  await run(
    `INSERT INTO share_floating
       (no, window_no, member_id, share_account_id, float_type, par_value, reserve_price, share_life,
        tolerance_period, on_no_bid, total_shares, shares_to_float, minimum_acceptable_price, floated_value,
        charge_amount, proceeds_type, proceeds_account_id, payment_method_code, external_reference_no,
        source, narration, created_at, created_by)
     VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)`,
    no, r.window.no, input.memberId, r.account.id, input.floatType, r.window.base_price, r.window.reserve_price,
    r.window.share_life, r.window.tolerance_period, r.window.on_no_bid, r.totalShares, r.sharesToFloat,
    Math.round(input.minimumAcceptablePrice), r.floatedValue, r.chargeAmount, input.proceedsType,
    input.proceedsAccountId, input.paymentMethodCode?.trim() || null, input.externalReferenceNo?.trim() || null,
    input.source && SHARE_TRADE_SOURCES.includes(input.source) ? input.source : 'Walking',
    input.narration?.trim() || null, new Date().toISOString(), user.username,
  );
  await audit(user, 'SHARE_FLOATING_CREATE', 'share_floating', no, { shares: r.sharesToFloat, value: r.floatedValue });
  return { no };
}

async function editableFloating(no: string, user: Actor): Promise<ShareFloating> {
  const f = await one<ShareFloating>('SELECT * FROM share_floating WHERE no = ?', no);
  if (!f) throw new AppError('Share floating not found', 'NOT_FOUND');
  if (f.status !== 'Open') throw new AppError('Only an open floating can be changed', 'VALIDATION');
  if (f.created_by !== user.username) throw new AppError('Only the person who raised this floating can change it', 'NOT_CREATOR');
  return f;
}

export async function updateShareFloating(no: string, input: ShareFloatingInput, user: Actor): Promise<void> {
  const before = await editableFloating(no, user);
  const r = await resolveFloating({ ...input, windowNo: input.windowNo ?? before.window_no });
  await run(
    `UPDATE share_floating
     SET window_no = ?, member_id = ?, share_account_id = ?, float_type = ?, par_value = ?, reserve_price = ?,
         share_life = ?, tolerance_period = ?, on_no_bid = ?, total_shares = ?, shares_to_float = ?,
         minimum_acceptable_price = ?, floated_value = ?, charge_amount = ?, proceeds_type = ?,
         proceeds_account_id = ?, payment_method_code = ?, external_reference_no = ?, source = ?, narration = ?
     WHERE no = ?`,
    r.window.no, input.memberId, r.account.id, input.floatType, r.window.base_price, r.window.reserve_price,
    r.window.share_life, r.window.tolerance_period, r.window.on_no_bid, r.totalShares, r.sharesToFloat,
    Math.round(input.minimumAcceptablePrice), r.floatedValue, r.chargeAmount, input.proceedsType,
    input.proceedsAccountId, input.paymentMethodCode?.trim() || null, input.externalReferenceNo?.trim() || null,
    input.source && SHARE_TRADE_SOURCES.includes(input.source) ? input.source : before.source,
    input.narration?.trim() || null, no,
  );
  await audit(user, 'SHARE_FLOATING_UPDATE', 'share_floating', no, { shares: r.sharesToFloat });
}

export async function deleteShareFloating(no: string, user: Actor): Promise<void> {
  await editableFloating(no, user);
  await run('DELETE FROM share_floating WHERE no = ?', no);
  await audit(user, 'SHARE_FLOATING_DELETE', 'share_floating', no, {});
}

/* -------------------------------------------------------------- maker-checker */

export async function submitShareFloating(no: string, user: Actor): Promise<{ autoApproved: boolean }> {
  const f = await one<ShareFloating>('SELECT * FROM share_floating WHERE no = ?', no);
  if (!f) throw new AppError('Share floating not found', 'NOT_FOUND');
  if (f.status !== 'Open') throw new AppError('Only an open floating can be sent for approval', 'VALIDATION');
  // Re-run the terms: the member's holding may have moved since it was raised.
  await resolveFloating({
    windowNo: f.window_no, memberId: f.member_id, floatType: f.float_type, sharesToFloat: f.shares_to_float,
    minimumAcceptablePrice: f.minimum_acceptable_price, proceedsType: f.proceeds_type, proceedsAccountId: f.proceeds_account_id,
  });
  const matched = await findMatchingWorkflow('SHARE_FLOATING', await pickConditionFields('SHARE_FLOATING', f));
  if (!matched) throw new AppError('There is no enabled workflow for this document', 'NO_WORKFLOW');
  await tx(async () => {
    await run("UPDATE share_floating SET status = 'Pending Approval' WHERE no = ?", no);
    await startWorkflow(matched.workflow, matched.steps, {
      documentType: 'SHARE_FLOATING', entityId: no, requestedBy: user.username, amount: Number(f.floated_value),
    });
  });
  const after = await one<{ status: string }>('SELECT status FROM share_floating WHERE no = ?', no);
  return { autoApproved: after?.status === 'Approved' };
}

export async function cancelShareFloatingApproval(no: string, user: Actor): Promise<void> {
  const f = await one<Pick<ShareFloating, 'status' | 'created_by'>>('SELECT status, created_by FROM share_floating WHERE no = ?', no);
  if (!f) throw new AppError('Share floating not found', 'NOT_FOUND');
  if (f.status !== 'Pending Approval') throw new AppError('Only a floating pending approval can be recalled', 'VALIDATION');
  const routed = await findPendingRoutedTask('SHARE_FLOATING', no);
  if ((routed?.requested_by ?? f.created_by) !== user.username) throw new AppError('Only the person who submitted this floating can recall it', 'NOT_REQUESTER');
  await run("UPDATE share_floating SET status = 'Open' WHERE no = ?", no);
  await audit(user, 'SHARE_FLOATING_CANCEL_APPROVAL', 'share_floating', no, {});
}

export async function approveShareFloating(no: string, user: Actor): Promise<void> {
  const f = await one<ShareFloating>('SELECT * FROM share_floating WHERE no = ?', no);
  if (!f) throw new AppError('Share floating not found', 'NOT_FOUND');
  if (f.status !== 'Pending Approval') throw new AppError('Only a floating pending approval can be approved', 'VALIDATION');
  await run("UPDATE share_floating SET status = 'Approved', decision_reason = NULL WHERE no = ?", no);
  await audit(user, 'SHARE_FLOATING_APPROVE', 'share_floating', no, {});
}

export async function rejectShareFloating(no: string, reason: string | null, user: Actor): Promise<void> {
  if (!reason?.trim()) throw new AppError('A reason is required to reject a floating', 'VALIDATION');
  const f = await one<ShareFloating>('SELECT * FROM share_floating WHERE no = ?', no);
  if (!f) throw new AppError('Share floating not found', 'NOT_FOUND');
  if (f.status !== 'Pending Approval') throw new AppError('Only a floating pending approval can be rejected', 'VALIDATION');
  await run("UPDATE share_floating SET status = 'Open', decision_reason = ? WHERE no = ?", reason, no);
  await audit(user, 'SHARE_FLOATING_REJECT', 'share_floating', no, { reason });
}

/** Pag52204218 "Reopen": Approved, not yet published → Open. */
export async function reopenShareFloating(no: string, user: Actor): Promise<void> {
  const f = await one<ShareFloating>('SELECT * FROM share_floating WHERE no = ?', no);
  if (!f) throw new AppError('Share floating not found', 'NOT_FOUND');
  if (f.status !== 'Approved' || f.published || f.archived) throw new AppError('Only an approved floating that is not yet on the market can be reopened', 'VALIDATION');
  await run("UPDATE share_floating SET status = 'Open' WHERE no = ?", no);
  await audit(user, 'SHARE_FLOATING_REOPEN', 'share_floating', no, {});
}

/* ------------------------------------------------------------- ledger helpers */

/** One savings movement — the balance and its `txn` row — inside the caller's transaction. */
async function moveSavings(opts: {
  accountId: number; memberId: number; delta: Cents; txnType: 'DEPOSIT' | 'WITHDRAWAL' | 'FEE';
  description: string; journalId: number; valueDate: IsoDate; user: Actor;
}): Promise<Cents> {
  const acct = await one<{ balance: Cents }>('SELECT balance FROM savings_account WHERE id = ? FOR UPDATE', opts.accountId);
  if (!acct) throw new AppError('Savings account not found', 'NOT_FOUND');
  const next = Number(acct.balance) + opts.delta;
  await run('UPDATE savings_account SET balance = ?, last_activity = ?, version = version + 1 WHERE id = ?', next, opts.valueDate, opts.accountId);
  await run(
    `INSERT INTO txn (txn_ref, value_date, created_at, module, txn_type, member_id, savings_account_id,
       amount, running_balance, channel, description, journal_id, created_by)
     VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?)`,
    await nextSequence('TXN'), opts.valueDate, new Date().toISOString(), 'SHARES', opts.txnType, opts.memberId,
    opts.accountId, opts.delta, next, 'SHARE_TRADE', opts.description, opts.journalId, opts.user.username,
  );
  return next;
}

async function memberContact(memberId: number): Promise<{ first_name: string; last_name: string; phone: string | null; email: string | null } | undefined> {
  return one('SELECT first_name, last_name, phone, email FROM member WHERE id = ?', memberId);
}

/** SMS + email, best effort and after the commit — a dead gateway must never undo a posting. */
async function tell(memberId: number, subject: string, message: string, source: string): Promise<void> {
  try {
    const m = await memberContact(memberId);
    if (!m) return;
    if (m.phone) await sendSms({ to: m.phone, message, source });
    if (m.email) await sendMail({ to: m.email, subject, html: `<p>${message}</p>` });
  } catch (err) {
    console.error(`[shareTrading] notification failed for member ${memberId}:`, err);
  }
}

async function saccoName(): Promise<string> {
  const org = await one<{ name: string }>('SELECT name FROM organisation LIMIT 1');
  return org?.name ?? 'your SACCO';
}

/* -------------------------------------------------------------------- publish */

/** Cod52204022.PublishSale — the shares leave the seller at par into Holding; the floating is
 *  on the market until its expiry. */
export async function publishShareFloating(no: string, user: Actor): Promise<{ journalNo: string; expiryDate: IsoDate }> {
  const result = await tx(async () => {
    const f = await one<ShareFloating>('SELECT * FROM share_floating WHERE no = ? FOR UPDATE', no);
    if (!f) throw new AppError('Share floating not found', 'NOT_FOUND');
    if (f.status !== 'Approved') throw new AppError('Only an approved floating can be published', 'VALIDATION');
    if (f.published || f.archived) throw new AppError('This floating is already on the market or closed', 'VALIDATION');
    await assertMemberNotDormant(f.member_id, 'a share sale');
    const r = await resolveFloating({
      windowNo: f.window_no, memberId: f.member_id, floatType: f.float_type, sharesToFloat: f.shares_to_float,
      minimumAcceptablePrice: f.minimum_acceptable_price, proceedsType: f.proceeds_type, proceedsAccountId: f.proceeds_account_id,
    });
    if (r.sharesToFloat !== f.shares_to_float || r.floatedValue !== Number(f.floated_value)) {
      throw new AppError('The member’s holding has changed since this floating was raised — reopen and amend it', 'VALIDATION');
    }
    const holding = await one<{ id: number }>('SELECT id FROM gl_account WHERE id = ?', r.window.holding_account_id);
    if (!holding) throw new AppError('The window’s holding account is missing', 'VALIDATION');

    const vd = await resolvePostingDate(user);
    const narration = `S: Share sale ${no} — ${f.shares_to_float} shares at a minimum of ${formatMoney(f.minimum_acceptable_price)}`;
    const j = await postJournal({
      valueDate: vd, module: 'SHARES', eventType: 'SHARE_FLOAT', description: narration, reference: no,
      memberId: f.member_id, user, idempotencyKey: `SHARE_FLOATING-PUBLISH-${no}`,
      lines: [
        { account: r.account.gl_control_id, debit: r.floatedValue, credit: 0, narration },
        { account: r.window.holding_account_id, debit: 0, credit: r.floatedValue, narration },
      ],
    });
    await moveSavings({ accountId: r.account.id, memberId: f.member_id, delta: -r.floatedValue, txnType: 'WITHDRAWAL', description: narration, journalId: j.id, valueDate: vd, user });

    const expiry = applyDateFormula(vd, f.share_life || DEFAULT_SHARE_LIFE);
    await run(
      `UPDATE share_floating SET published = true, published_on = ?, expiry_date = ?, publish_journal_id = ? WHERE no = ?`,
      vd, expiry, j.id, no,
    );
    await audit(user, 'SHARE_FLOATING_PUBLISH', 'share_floating', no, { journalNo: j.journal_no, value: r.floatedValue });
    return { journalNo: j.journal_no, expiryDate: expiry, f, price: f.minimum_acceptable_price };
  });

  const sacco = await saccoName();
  await tell(result.f.member_id, `Shares floated — ${no}`,
    `Dear member, you have successfully floated ${result.f.shares_to_float} shares worth ${formatMoney(result.f.floated_value)} with ${sacco}`
    + ` at a minimum price of ${formatMoney(result.price)} per share (ref ${no}). Bidding closes on ${formatDate(result.expiryDate)}.`, 'SHARE_TRADING');
  return { journalNo: result.journalNo, expiryDate: result.expiryDate };
}

/* ----------------------------------------------------------------------- bids */

export interface ShareBidInput { memberId: number; bidPrice: Cents; source?: ShareTradeSource }

/** Tab52204135's OnValidate of Member No. and Bid Price. One bid per member; a repeat replaces it. */
export async function placeShareBid(no: string, input: ShareBidInput, user: Actor): Promise<{ total: Cents }> {
  return tx(async () => {
    const f = await one<ShareFloating>('SELECT * FROM share_floating WHERE no = ? FOR UPDATE', no);
    if (!f) throw new AppError('Share floating not found', 'NOT_FOUND');
    if (!f.published || f.awarded || f.archived) throw new AppError('This floating is not taking bids', 'VALIDATION');
    if (f.expiry_date && f.expiry_date < today()) throw new AppError(`Bidding closed on ${formatDate(f.expiry_date)}`, 'VALIDATION');
    if (input.memberId === f.member_id) throw new AppError('You cannot buy your own shares', 'VALIDATION');
    const member = await one<{ status: string }>('SELECT status FROM member WHERE id = ?', input.memberId);
    if (!member) throw new AppError('Member not found', 'NOT_FOUND');
    if (member.status !== 'ACTIVE') throw new AppError('Only an active member can bid', 'VALIDATION');
    const account = await shareCapitalAccountOf(input.memberId);
    if (!account) throw new AppError('The bidder has no active share capital account to receive the shares', 'VALIDATION');
    if (Number(account.balance) < Number(account.min_balance)) throw new AppError('The bidder does not hold the minimum share capital balance to bid', 'VALIDATION');

    const price = Math.round(Number(input.bidPrice));
    if (price < Number(f.minimum_acceptable_price)) throw new AppError(`You can only bid from ${formatMoney(f.minimum_acceptable_price)} per share`, 'VALIDATION');
    if (price > Number(f.par_value)) throw new AppError(`You can only bid up to the par value of ${formatMoney(f.par_value)} per share`, 'VALIDATION');
    const total = f.shares_to_float * price + Number(f.charge_amount);

    await run(
      `INSERT INTO share_bid (floating_no, member_id, share_account_id, bid_price, bid_date, shares, charges, total_amount, source, created_by)
       VALUES (?,?,?,?,?,?,?,?,?,?)
       ON CONFLICT (floating_no, member_id) DO UPDATE SET
         bid_price = EXCLUDED.bid_price, bid_date = EXCLUDED.bid_date, shares = EXCLUDED.shares,
         charges = EXCLUDED.charges, total_amount = EXCLUDED.total_amount, source = EXCLUDED.source,
         created_by = EXCLUDED.created_by, awarded = false, bought = false`,
      no, input.memberId, account.id, price, new Date().toISOString(), f.shares_to_float, f.charge_amount, total,
      input.source && SHARE_TRADE_SOURCES.includes(input.source) ? input.source : 'Walking', user.username,
    );
    // A new or changed bid unsettles any award not yet posted as a purchase.
    await run('UPDATE share_bid SET awarded = false WHERE floating_no = ? AND NOT bought', no);
    await audit(user, 'SHARE_BID_PLACE', 'share_floating', no, { memberId: input.memberId, price, total });
    return { total };
  });
}

export async function withdrawShareBid(bidId: number, user: Actor): Promise<void> {
  const b = await one<{ floating_no: string; bought: boolean; awarded: boolean }>('SELECT floating_no, bought, awarded FROM share_bid WHERE id = ?', bidId);
  if (!b) throw new AppError('Bid not found', 'NOT_FOUND');
  const f = await one<Pick<ShareFloating, 'awarded' | 'archived'>>('SELECT awarded, archived FROM share_floating WHERE no = ?', b.floating_no);
  if (!f || f.awarded || f.archived || b.bought) throw new AppError('This bid can no longer be withdrawn', 'VALIDATION');
  await run('DELETE FROM share_bid WHERE id = ?', bidId);
  await audit(user, 'SHARE_BID_WITHDRAW', 'share_floating', b.floating_no, { bidId });
}

/** Cod52204022.AnalyseShareTrade — the highest bid wins; on a tie, the earliest. */
export async function analyseShareBids(no: string, user: Actor): Promise<{ winner: ShareBidView | null }> {
  const f = await one<ShareFloating>('SELECT * FROM share_floating WHERE no = ?', no);
  if (!f) throw new AppError('Share floating not found', 'NOT_FOUND');
  if (!f.published || f.awarded || f.archived) throw new AppError('Only a floating on the market can be analysed', 'VALIDATION');
  await tx(async () => {
    await run('UPDATE share_bid SET awarded = false WHERE floating_no = ?', no);
    await run(
      `UPDATE share_bid SET awarded = true WHERE id = (
         SELECT id FROM share_bid WHERE floating_no = ? ORDER BY bid_price DESC, bid_date ASC, id ASC LIMIT 1)`,
      no,
    );
  });
  const winner = (await listShareBids(no)).find((b) => b.awarded) ?? null;
  await audit(user, 'SHARE_BIDS_ANALYSE', 'share_floating', no, { winner: winner?.member_no ?? null });
  return { winner };
}

/** Cod52204022.NotifyAward. */
export async function notifyShareAward(no: string, user: Actor): Promise<void> {
  const f = await getShareFloating(no);
  if (!f) throw new AppError('Share floating not found', 'NOT_FOUND');
  const winner = (await listShareBids(no)).find((b) => b.awarded);
  if (!winner) throw new AppError('No bid has been awarded — analyse the bids first', 'VALIDATION');
  const sacco = await saccoName();
  await tell(winner.member_id, `Share bid won — ${no}`,
    `Dear ${winner.first_name}, you have won the bid to purchase ${f.shares_to_float} shares worth ${formatMoney(f.floated_value)} at ${sacco}.`
    + ` Please pay ${formatMoney(winner.total_amount)} using reference ${no}${f.payment_due_date ? ` on or before ${formatDate(f.payment_due_date)}` : ''}.`,
    'SHARE_TRADING');
  await audit(user, 'SHARE_AWARD_NOTIFY', 'share_floating', no, { memberId: winner.member_id });
}

/* ------------------------------------------------------------------- purchase */

/** Cod52204022.PostPurchase — the winner's debt goes on the Clearing account; the floating is
 *  Awarded and the payment clock starts. */
export async function postSharePurchase(no: string, user: Actor): Promise<{ journalNo: string; dueDate: IsoDate | null }> {
  const result = await tx(async () => {
    const f = await one<ShareFloating>('SELECT * FROM share_floating WHERE no = ? FOR UPDATE', no);
    if (!f) throw new AppError('Share floating not found', 'NOT_FOUND');
    if (!f.published || f.awarded || f.archived) throw new AppError('Only a floating on the market can be posted as a purchase', 'VALIDATION');
    const winner = (await listShareBids(no)).find((b) => b.awarded);
    if (!winner) throw new AppError('You need to award a bid before posting the purchase', 'VALIDATION');
    const window = await getShareTradingWindow(f.window_no);
    if (!window) throw new AppError('Trading window not found', 'NOT_FOUND');

    const vd = await resolvePostingDate(user);
    const narration = `P: Share purchase ${no} — ${f.shares_to_float} shares at ${formatMoney(winner.bid_price)} by ${winner.member_no}`;
    const j = await postJournal({
      valueDate: vd, module: 'SHARES', eventType: 'SHARE_PURCHASE', description: narration, reference: no,
      memberId: winner.member_id, user, idempotencyKey: `SHARE_FLOATING-PURCHASE-${no}`,
      lines: [
        { account: window.clearing_account_id, debit: Number(winner.total_amount), credit: 0, narration },
        { account: window.holding_account_id, debit: 0, credit: Number(winner.total_amount), narration },
      ],
    });
    const dueDate = f.tolerance_period ? applyDateFormula(vd, f.tolerance_period) : null;
    await run('UPDATE share_bid SET bought = true WHERE id = ?', winner.id);
    await run(
      'UPDATE share_floating SET awarded = true, purchase_date = ?, payment_due_date = ?, purchase_journal_id = ? WHERE no = ?',
      vd, dueDate, j.id, no,
    );
    await audit(user, 'SHARE_PURCHASE_POST', 'share_floating', no, { journalNo: j.journal_no, total: winner.total_amount });
    return { journalNo: j.journal_no, dueDate, winner };
  });

  const sacco = await saccoName();
  await tell(result.winner.member_id, `Share purchase — pay ${no}`,
    `Dear ${result.winner.first_name}, you have won the bid on the purchase of shares at ${sacco}. Please pay ${formatMoney(result.winner.total_amount)}`
    + ` using reference ${no}${result.dueDate ? ` on or before ${formatDate(result.dueDate)}` : ''}.`, 'SHARE_TRADING');
  return { journalNo: result.journalNo, dueDate: result.dueDate };
}

/* ------------------------------------------------------------ payment receipts */

/** Pag52204224 "Deposits Lookup" → Tab52204136: allocate part of the buyer's payment from one
 *  of their deposit accounts. */
export async function addShareTransferReceipt(no: string, savingsAccountId: number, amount: Cents, user: Actor): Promise<void> {
  const f = await getShareFloating(no);
  if (!f) throw new AppError('Share floating not found', 'NOT_FOUND');
  if (!f.awarded || f.archived) throw new AppError('Payments are only allocated to an awarded floating', 'VALIDATION');
  const winner = (await listShareBids(no)).find((b) => b.awarded);
  if (!winner) throw new AppError('No awarded bid', 'VALIDATION');
  const account = (await sharePaymentAccountsForMember(winner.member_id)).find((a) => a.id === savingsAccountId);
  if (!account) throw new AppError('Pick one of the buyer’s own withdrawable deposit accounts', 'VALIDATION');
  const alloc = Math.round(Number(amount));
  if (!(alloc > 0)) throw new AppError('The allocated amount must be more than zero', 'VALIDATION');
  if (alloc > Number(account.available)) throw new AppError(`Only ${formatMoney(account.available)} is available on ${account.account_no}`, 'VALIDATION');
  // Allocations on the other accounts stand; this one replaces whatever was on this account.
  const already = (await listShareTransferReceipts(no)).filter((r) => r.savings_account_id !== savingsAccountId)
    .reduce((s, r) => s + Number(r.allocated_amount), 0);
  const remaining = Number(f.payment_amount) - already;
  if (alloc > remaining) throw new AppError(`You can only allocate up to ${formatMoney(remaining)} more`, 'VALIDATION');
  await run(
    `INSERT INTO share_transfer_receipt (floating_no, savings_account_id, allocated_amount, description, created_at, created_by)
     VALUES (?,?,?,?,?,?)
     ON CONFLICT (floating_no, savings_account_id) DO UPDATE SET allocated_amount = EXCLUDED.allocated_amount,
       description = EXCLUDED.description, created_at = EXCLUDED.created_at, created_by = EXCLUDED.created_by`,
    no, savingsAccountId, alloc, `Payment for shares — ${no}`, new Date().toISOString(), user.username,
  );
  await audit(user, 'SHARE_RECEIPT_ALLOCATE', 'share_floating', no, { savingsAccountId, amount: alloc });
}

export async function removeShareTransferReceipt(id: number, user: Actor): Promise<void> {
  const r = await one<{ floating_no: string }>('SELECT floating_no FROM share_transfer_receipt WHERE id = ?', id);
  if (!r) throw new AppError('Allocation not found', 'NOT_FOUND');
  const f = await one<Pick<ShareFloating, 'archived'>>('SELECT archived FROM share_floating WHERE no = ?', r.floating_no);
  if (!f || f.archived) throw new AppError('This floating is closed', 'VALIDATION');
  await run('DELETE FROM share_transfer_receipt WHERE id = ?', id);
  await audit(user, 'SHARE_RECEIPT_REMOVE', 'share_floating', r.floating_no, { id });
}

/* ------------------------------------------------------------------- transfer */

/** Cod52204022.TransferShares — the buyer pays, the shares move, the seller is paid. */
export async function transferShares(no: string, user: Actor): Promise<{ journalNo: string; proceeds: Cents; sellerCharge: Cents }> {
  const result = await tx(async () => {
    const f = await one<ShareFloating>('SELECT * FROM share_floating WHERE no = ? FOR UPDATE', no);
    if (!f) throw new AppError('Share floating not found', 'NOT_FOUND');
    if (!f.awarded || f.archived) throw new AppError('Only an awarded floating can be transferred', 'VALIDATION');
    const winner = (await listShareBids(no)).find((b) => b.awarded && b.bought);
    if (!winner) throw new AppError('The purchase has not been posted', 'VALIDATION');
    const window = await getShareTradingWindow(f.window_no);
    if (!window) throw new AppError('Trading window not found', 'NOT_FOUND');
    await assertMemberNotDormant(winner.member_id, 'a share purchase');

    const receipts = await listShareTransferReceipts(no);
    const paid = receipts.reduce((s, r) => s + Number(r.allocated_amount), 0);
    const total = Number(winner.total_amount);
    if (paid !== total) throw new AppError(`The buyer's allocated payments come to ${formatMoney(paid)}; ${formatMoney(total)} is due`, 'VALIDATION');
    for (const r of receipts) {
      if (Number(r.allocated_amount) > Number(r.available)) throw new AppError(`Only ${formatMoney(r.available)} is now available on ${r.account_no}`, 'VALIDATION');
    }

    const buyerShares = await shareCapitalAccountOf(winner.member_id);
    if (!buyerShares) throw new AppError('The buyer no longer has an active share capital account', 'VALIDATION');
    const proceedsAccount = f.proceeds_account_id
      ? await one<{ id: number; account_no: string; gl_control_id: number }>(
        `SELECT sa.id, sa.account_no, sp.gl_control_id FROM savings_account sa JOIN savings_product sp ON sp.id = sa.product_id
         WHERE sa.id = ? AND sa.member_id = ? AND sa.status = 'ACTIVE'`, f.proceeds_account_id, f.member_id)
      : (await shareProceedsAccountsForMember(f.member_id, f.proceeds_type)).map((a) => ({ id: a.id, account_no: a.account_no, gl_control_id: 0 }))[0];
    if (!proceedsAccount) throw new AppError('The seller has no account to receive the proceeds — set one on the floating', 'VALIDATION');
    const proceedsGl = proceedsAccount.gl_control_id || (await one<{ gl_control_id: number }>(
      'SELECT sp.gl_control_id FROM savings_account sa JOIN savings_product sp ON sp.id = sa.product_id WHERE sa.id = ?', proceedsAccount.id))?.gl_control_id;
    if (!proceedsGl) throw new AppError('The proceeds account’s product has no G/L control account', 'VALIDATION');

    const F = Number(f.floated_value);
    const P = f.shares_to_float * Number(winner.bid_price);
    const C = Number(winner.charges);
    const vd = await resolvePostingDate(user);
    const label = `${f.shares_to_float} shares at ${formatMoney(winner.bid_price)}`;

    // The buyer's charge, component by component to each charge's own income account.
    let chargeLines: JournalLineInput[] = [];
    if (C > 0) {
      const detail = window.transaction_charge_id ? await getTransactionCharge(window.transaction_charge_id) : null;
      const parts = detail ? calculateTransactionCharges(detail, F) : [];
      const sum = parts.reduce((s, c) => s + c.amount, 0);
      if (sum !== C) throw new AppError('The window’s charge has changed since the bid was placed — re-analyse the bids', 'VALIDATION');
      chargeLines = parts.map((c) => ({ account: c.glAccountId, debit: 0, credit: c.amount, narration: `Share trading charge — ${c.chargeCode}` }));
    }

    const accts = new Map<number, { gl_control_id: number; account_no: string }>();
    for (const r of receipts) {
      const a = await one<{ gl_control_id: number; account_no: string }>(
        'SELECT sp.gl_control_id, sa.account_no FROM savings_account sa JOIN savings_product sp ON sp.id = sa.product_id WHERE sa.id = ?', r.savings_account_id);
      if (!a) throw new AppError('Payment account not found', 'NOT_FOUND');
      accts.set(r.savings_account_id, a);
    }

    const lines: JournalLineInput[] = [
      ...receipts.map((r) => ({ account: accts.get(r.savings_account_id)!.gl_control_id, debit: Number(r.allocated_amount), credit: 0, narration: `P: Payment for shares bought — ${accts.get(r.savings_account_id)!.account_no}` })),
      { account: window.clearing_account_id, debit: 0, credit: total, narration: `P: Payment for shares bought ${label}` },
      { account: window.holding_account_id, debit: F, credit: 0, narration: `P: Shares bought at par — ${winner.member_no}` },
      { account: buyerShares.gl_control_id, debit: 0, credit: F, narration: `P: Shares bought ${f.shares_to_float} at ${formatMoney(f.par_value)}` },
      { account: window.holding_account_id, debit: P, credit: 0, narration: `P: Shares sold ${label}` },
      { account: proceedsGl, debit: 0, credit: P, narration: `P: Proceeds of shares sold ${label}` },
      ...(C > 0 ? [{ account: window.holding_account_id, debit: C, credit: 0, narration: 'Share trading charge' }, ...chargeLines] : []),
    ];
    const j = await postJournal({
      valueDate: vd, module: 'SHARES', eventType: 'SHARE_TRANSFER', description: `Share transfer ${no}: ${label}`,
      reference: no, memberId: winner.member_id, user, idempotencyKey: `SHARE_FLOATING-TRANSFER-${no}`, lines,
    });

    for (const r of receipts) {
      await moveSavings({ accountId: r.savings_account_id, memberId: winner.member_id, delta: -Number(r.allocated_amount), txnType: 'WITHDRAWAL', description: `Payment for shares bought — ${no}`, journalId: j.id, valueDate: vd, user });
    }
    await moveSavings({ accountId: buyerShares.id, memberId: winner.member_id, delta: F, txnType: 'DEPOSIT', description: `Shares bought — ${no}: ${f.shares_to_float} at par`, journalId: j.id, valueDate: vd, user });
    await moveSavings({ accountId: proceedsAccount.id, memberId: f.member_id, delta: P, txnType: 'DEPOSIT', description: `Proceeds of shares sold — ${no}: ${label}`, journalId: j.id, valueDate: vd, user });

    // The seller's own charge on the premium — AddCharges(Charges, Proceeds Account, Payment − Par×Shares).
    let sellerCharge = 0;
    const premium = P - F;
    if (window.transaction_charge_id && premium > 0) {
      const posted = await postTransactionCharges({
        transactionChargeId: window.transaction_charge_id, baseAmount: premium, debitAccountCode: proceedsGl,
        valueDate: vd, module: 'SHARES', eventType: 'SHARE_TRANSFER_CHARGE', memberId: f.member_id,
        description: `Share trading charge on premium — ${no}`, reference: no, user, idempotencyKey: `SHARE_FLOATING-SELLER-CHG-${no}`,
      });
      if (posted) {
        sellerCharge = posted.charges.reduce((s, c) => s + c.amount, 0);
        await moveSavings({ accountId: proceedsAccount.id, memberId: f.member_id, delta: -sellerCharge, txnType: 'FEE', description: `Share trading charge on premium — ${no}`, journalId: posted.journal.id, valueDate: vd, user });
      }
    }

    await run(
      `UPDATE share_floating SET archived = true, published = false, outcome = 'Transferred', transfer_journal_id = ?,
         payment_date = COALESCE(payment_date, ?), transferred_at = ?, transferred_by = ? WHERE no = ?`,
      j.id, vd, new Date().toISOString(), user.username, no,
    );
    await audit(user, 'SHARE_TRANSFER_POST', 'share_floating', no, { journalNo: j.journal_no, proceeds: P, sellerCharge });
    return { journalNo: j.journal_no, proceeds: P, sellerCharge, f, winner };
  });

  const sacco = await saccoName();
  await tell(result.f.member_id, `Shares sold — ${no}`,
    `Dear member, your ${result.f.shares_to_float} shares floated with ${sacco} have been sold. ${formatMoney(result.proceeds)} has been credited to your account (ref ${no}).`, 'SHARE_TRADING');
  await tell(result.winner.member_id, `Shares transferred — ${no}`,
    `Dear ${result.winner.first_name}, ${result.f.shares_to_float} shares have been transferred to your share capital account at ${sacco} (ref ${no}).`, 'SHARE_TRADING');
  return { journalNo: result.journalNo, proceeds: result.proceeds, sellerCharge: result.sellerCharge };
}

/* ------------------------------------------------------------------ take down */

/** Cod52204022.TakeDownSale — a published, un-awarded floating comes off the market; the publish
 *  posting is reversed and the shares go back to the seller. `outcome` says whether an officer
 *  did it or the window's no-bid rule. */
export async function takeDownShareFloating(no: string, user: Actor, outcome: 'Taken Down' | 'Reversed' = 'Taken Down'): Promise<{ journalNo: string }> {
  const result = await tx(async () => {
    const f = await one<ShareFloating>('SELECT * FROM share_floating WHERE no = ? FOR UPDATE', no);
    if (!f) throw new AppError('Share floating not found', 'NOT_FOUND');
    if (!f.published || f.awarded || f.archived) throw new AppError('Only a floating on the market that has not been awarded can be taken down', 'VALIDATION');
    const window = await getShareTradingWindow(f.window_no);
    if (!window) throw new AppError('Trading window not found', 'NOT_FOUND');
    const seller = await one<{ gl_control_id: number }>(
      'SELECT sp.gl_control_id FROM savings_account sa JOIN savings_product sp ON sp.id = sa.product_id WHERE sa.id = ?', f.share_account_id);
    if (!seller) throw new AppError('Seller’s share account not found', 'NOT_FOUND');

    const vd = await resolvePostingDate(user);
    const F = Number(f.floated_value);
    const narration = `R: Share sale reversal ${no} — ${f.shares_to_float} shares at a minimum of ${formatMoney(f.minimum_acceptable_price)}`;
    const j = await postJournal({
      valueDate: vd, module: 'SHARES', eventType: 'SHARE_FLOAT_REVERSAL', description: narration, reference: no,
      memberId: f.member_id, user, idempotencyKey: `SHARE_FLOATING-TAKEDOWN-${no}`,
      lines: [
        { account: window.holding_account_id, debit: F, credit: 0, narration },
        { account: seller.gl_control_id, debit: 0, credit: F, narration },
      ],
    });
    await moveSavings({ accountId: f.share_account_id, memberId: f.member_id, delta: F, txnType: 'DEPOSIT', description: narration, journalId: j.id, valueDate: vd, user });
    await run(
      'UPDATE share_floating SET published = false, archived = true, outcome = ?, takedown_journal_id = ? WHERE no = ?',
      outcome, j.id, no,
    );
    await audit(user, 'SHARE_FLOATING_TAKE_DOWN', 'share_floating', no, { journalNo: j.journal_no, outcome });
    return { journalNo: j.journal_no, f };
  });

  const sacco = await saccoName();
  await tell(result.f.member_id, `Share floating ${outcome.toLowerCase()} — ${no}`,
    `Dear member, your ${result.f.shares_to_float} shares floated on ${sacco} (ref ${no}) have been ${outcome.toLowerCase()} and returned to your share capital account.`, 'SHARE_TRADING');
  return { journalNo: result.journalNo };
}

/* ---------------------------------------------------------------- no-bid rule */

/** Tab52204133 "On No Bid": a floating past its expiry with no bids is extended by another share
 *  life, or reversed. One with bids is left for the officer to analyse. */
export async function applyShareNoBidRule(no: string, user: Actor): Promise<{ action: 'Extended' | 'Reversed' | 'Has bids' | 'Not expired'; expiryDate?: IsoDate }> {
  const f = await getShareFloating(no);
  if (!f) throw new AppError('Share floating not found', 'NOT_FOUND');
  if (!f.published || f.awarded || f.archived) throw new AppError('Only a floating on the market can be expired', 'VALIDATION');
  if (!f.expiry_date || f.expiry_date >= today()) return { action: 'Not expired' };
  if (f.bids > 0) return { action: 'Has bids' };
  if (f.on_no_bid === 'Reverse') {
    await takeDownShareFloating(no, user, 'Reversed');
    return { action: 'Reversed' };
  }
  const expiry = applyDateFormula(today(), f.share_life || DEFAULT_SHARE_LIFE);
  await run('UPDATE share_floating SET expiry_date = ? WHERE no = ?', expiry, no);
  await audit(user, 'SHARE_FLOATING_EXTEND', 'share_floating', no, { expiry });
  return { action: 'Extended', expiryDate: expiry };
}

/** Every expired floating on the market, through the rule — for the list's button or a job. */
export async function processExpiredShareFloatings(user: Actor): Promise<{ extended: number; reversed: number; withBids: number }> {
  const rows = await all<{ no: string }>(
    "SELECT no FROM share_floating WHERE published AND NOT awarded AND NOT archived AND expiry_date IS NOT NULL AND expiry_date < ? ORDER BY no", today());
  const out = { extended: 0, reversed: 0, withBids: 0 };
  for (const r of rows) {
    const res = await applyShareNoBidRule(r.no, user);
    if (res.action === 'Extended') out.extended += 1;
    else if (res.action === 'Reversed') out.reversed += 1;
    else if (res.action === 'Has bids') out.withBids += 1;
  }
  return out;
}

/* ------------------------------------------------------------------- history */

export const listShareFloatingJournals = (no: string): Promise<{ journal_no: string; value_date: IsoDate; description: string | null; amount: Cents }[]> =>
  all('SELECT journal_no, value_date, description, amount FROM journal WHERE reference = ? ORDER BY value_date, id', no);

export async function getShareFloatingJournal(no: string, which: 'publish' | 'purchase' | 'transfer' | 'takedown'): Promise<JournalDetail | null> {
  const row = await one<Record<string, number | null>>(`SELECT ${which}_journal_id AS id FROM share_floating WHERE no = ?`, no);
  return row?.id ? getJournal(row.id) : null;
}

export const shareStageOf = (f: Pick<ShareFloating, 'archived' | 'awarded' | 'published'>): ShareFloatingStage =>
  (f.archived ? 'Closed' : f.awarded ? 'Awarded' : f.published ? 'On Market' : 'Draft');
