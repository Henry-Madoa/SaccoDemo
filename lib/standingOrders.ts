/*
 * Standing Order — a maker-checker instruction, ported from the AL reference's "Standing Order"
 * card (Pag52204124 / Tab52204076), that moves money out of a member's own account on its own
 * schedule once Approved — unlike this app's other maker-checker documents, approval directly
 * sets `running = true` (AL's own Cod52204000.ApprovalMgmtCBSExt.al behaviour) rather than
 * needing a separate Process step; runStandingOrders() below (wired into lib/jobQueue.ts and
 * runnable on demand from app/standing-orders) is what actually executes it, once a day, from
 * then on.
 *
 * Narrowed from AL's fuller scope, matching how every other module in this port trims AL
 * features this schema/domain has no infrastructure for:
 *   - standing_order_class is INTERNAL (to any of the destination member's own accounts, via a
 *     single self-balancing journal — the same "Acc. Transfer" shape lib/memberExits.ts already
 *     uses for its own account-to-account moves) or LOAN_REPAYMENT (through
 *     lib/loanService.ts's own repay(), which already allocates interest-then-principal
 *     oldest-first and already accepts a `fromSavingsAccountId` to debit in the same posting —
 *     AL's separate Loan-Principal/Loan-Interest/Loan Principal+Interest classes collapse into
 *     this one, since a bespoke principal-only or interest-only posting exists nowhere else in
 *     this app). AL's External (EFT to an outside bank) is dropped — no external bank/branch
 *     master data exists here.
 *   - "Salary Based" is dropped — lib/checkoffBatches.ts's own header already excludes Standing
 *     Orders from that module for lack of an Employer Payroll Details staging table to
 *     prioritise a deduction against.
 *   - AL's Period DateFormula is a plain month count (period_months) — the same simplification
 *     organisation.member_exit_notice_days already applies elsewhere.
 *   - The optional Charge Code is freely chosen from the 'General' Transaction Charge pool, the
 *     same reuse lib/memberActivation.ts/lib/memberExits.ts's own charge pickers already use.
 */
import {
  one, all, run, tx, nextSequence, audit, hasAnyRow,
} from './db.ts';
import { AppError, PostingError } from './errors.ts';
import { postJournal } from './accounting.ts';
import { postTransactionCharges, previewTransactionChargeById } from './charges.ts';
import { repay } from './loanService.ts';
import { addMonths } from './loans.ts';
import { assertMemberNotDormant } from './memberDormancy.ts';
import { findMatchingWorkflow, findPendingRoutedTask, pickConditionFields, startWorkflow } from './workflow.ts';
import { buildFilterClause, type FilterCondition, type FilterFieldDef } from './listFilters.ts';
import { buildOrderClause, type SortState } from './listSort.ts';
import type {
  Actor, Cents, IsoDate, StandingOrder, StandingOrderClass, StandingOrderRunResult,
  StandingOrderRunSummary, StandingOrderWithDimensions,
} from './types.ts';

const today = (): IsoDate => new Date().toISOString().slice(0, 10);

export type StandingOrderView = 'open' | 'pending' | 'live' | 'terminated';

const VIEW_CLAUSE: Record<StandingOrderView, string> = {
  open: "s.status = 'Open'",
  pending: "s.status = 'Pending Approval'",
  live: "s.status = 'Approved' AND s.terminated = false",
  terminated: 's.terminated = true',
};

const SELECT_ORDER = `
  SELECT s.*, m.member_no AS member_no, m.first_name AS member_first_name, m.last_name AS member_last_name,
         sa.account_no AS account_no, sa.balance AS account_balance, sa.hold_amount AS account_hold_amount,
         sp.min_balance AS account_min_balance,
         dm.member_no AS destination_member_no, dm.first_name AS destination_first_name, dm.last_name AS destination_last_name,
         da.account_no AS destination_account_no, dl.loan_no AS destination_loan_no,
         tc.code AS transaction_charge_code, tc.description AS transaction_charge_description
  FROM standing_order s
  JOIN member m ON m.id = s.member_id
  JOIN savings_account sa ON sa.id = s.account_id
  JOIN savings_product sp ON sp.id = sa.product_id
  LEFT JOIN member dm ON dm.id = s.destination_member_id
  LEFT JOIN savings_account da ON da.id = s.destination_account_id
  LEFT JOIN loan dl ON dl.id = s.destination_loan_id
  LEFT JOIN transaction_charge tc ON tc.id = s.transaction_charge_id`;

export const STANDING_ORDER_FILTER_FIELDS: FilterFieldDef[] = [
  { key: 'no', label: 'No.', type: 'text', column: 's.no' },
  { key: 'member_id', label: 'Member', type: 'select', column: 'm.id' },
  { key: 'standing_order_class', label: 'Class', type: 'select', column: 's.standing_order_class' },
  { key: 'amount_type', label: 'Amount Type', type: 'select', column: 's.amount_type' },
  { key: 'created_by', label: 'Created By', type: 'text', column: 's.created_by' },
  { key: 'created_at', label: 'Created', type: 'date', column: 's.created_at', datetime: true },
];

const SORT_COLUMNS: Record<string, string> = {
  no: 's.no',
  member: 'm.first_name',
  status: 's.status',
  amount: 's.amount',
};

export interface ListStandingOrdersOptions {
  view?: StandingOrderView;
  search?: string;
  filters?: FilterCondition[];
  sort?: SortState | null;
}

export const listStandingOrders = (
  { view, search = '', filters = [], sort = null }: ListStandingOrdersOptions = {},
): Promise<StandingOrderWithDimensions[]> => {
  const { clause, params } = buildFilterClause(STANDING_ORDER_FILTER_FIELDS, filters);
  const orderBy = buildOrderClause(SORT_COLUMNS, sort, 's.no DESC');
  return all<StandingOrderWithDimensions>(
    `${SELECT_ORDER}
     WHERE (s.no LIKE @like OR m.first_name LIKE @like OR m.last_name LIKE @like OR m.member_no LIKE @like)
       ${view ? `AND ${VIEW_CLAUSE[view]}` : ''}
       ${clause}
     ${orderBy}`,
    { like: `%${String(search).trim()}%`, ...params },
  );
};

export const getStandingOrder = (no: string): Promise<StandingOrderWithDimensions | undefined> =>
  one<StandingOrderWithDimensions>(`${SELECT_ORDER} WHERE s.no = ?`, no);

export const hasAnyStandingOrders = (view?: StandingOrderView): Promise<boolean> =>
  hasAnyRow('standing_order s', view ? VIEW_CLAUSE[view] : undefined);

export async function getAdjacentStandingOrderNos(
  no: string, view?: StandingOrderView,
): Promise<{ prevNo: string | null; nextNo: string | null }> {
  const clause = view ? `AND ${VIEW_CLAUSE[view]}` : '';
  const [prev, next] = await Promise.all([
    one<{ no: string }>(`SELECT s.no FROM standing_order s WHERE s.no < ? ${clause} ORDER BY s.no DESC LIMIT 1`, no),
    one<{ no: string }>(`SELECT s.no FROM standing_order s WHERE s.no > ? ${clause} ORDER BY s.no ASC LIMIT 1`, no),
  ]);
  return { prevNo: prev?.no ?? null, nextNo: next?.no ?? null };
}

/** History of what's actually run — every journal this order has ever posted (AL's own "Find
 *  Entries" over ledger entries carrying this document number), newest first. */
export const listStandingOrderHistory = (no: string): Promise<{ journal_no: string; value_date: IsoDate; description: string | null; amount: Cents }[]> =>
  all(
    `SELECT journal_no, value_date, description, amount FROM journal WHERE reference = ? ORDER BY value_date DESC, id DESC`,
    no,
  );

/** The member's own accounts that could fund a standing order — withdrawable, active, any
 *  product that actually permits a withdrawal (AL's own TableRelation: Withdrawable Deposit or
 *  Holding Account). */
export const eligibleSourceAccountsForMember = (memberId: number) => all<{
  id: number; account_no: string; product_name: string; balance: Cents; hold_amount: Cents; min_balance: Cents;
}>(
  `SELECT sa.id, sa.account_no, sp.name AS product_name, sa.balance, sa.hold_amount, sp.min_balance
   FROM savings_account sa JOIN savings_product sp ON sp.id = sa.product_id
   WHERE sa.member_id = ? AND sa.status = 'ACTIVE' AND sp.allow_withdrawal = 1
     AND sp.category IN ('WITHDRAWABLE DEPOSIT', 'HOLDING ACCOUNT')
   ORDER BY sa.account_no`,
  memberId,
);

/** Every active account a destination member holds — for an INTERNAL order's own picker. */
export const eligibleDestinationAccountsForMember = (memberId: number) => all<{
  id: number; account_no: string; product_name: string;
}>(
  `SELECT sa.id, sa.account_no, sp.name AS product_name
   FROM savings_account sa JOIN savings_product sp ON sp.id = sa.product_id
   WHERE sa.member_id = ? AND sa.status = 'ACTIVE'
   ORDER BY sa.account_no`,
  memberId,
);

/** Every disbursed, still-owing loan a member holds — for a LOAN_REPAYMENT order's own picker. */
export const eligibleDestinationLoansForMember = (memberId: number) => all<{
  id: number; loan_no: string; outstanding_balance: Cents;
}>(
  `SELECT id, loan_no, (principal_balance + interest_balance + penalty_balance) AS outstanding_balance
   FROM loan WHERE member_id = ? AND status = 'DISBURSED' AND (principal_balance + interest_balance + penalty_balance) > 0
   ORDER BY loan_no`,
  memberId,
);

export interface StandingOrderInput {
  memberId: number;
  accountId: number;
  standingOrderClass: StandingOrderClass;
  amountType: 'FIXED' | 'SWEEP' | 'AMOUNT_BASED';
  amount?: number;
  amountLimit?: number;
  destinationMemberId?: number | null;
  destinationAccountId?: number | null;
  destinationLoanId?: number | null;
  postingDescription: string;
  runType?: 'SPECIFIC_DAY' | 'END_MONTH' | 'DAILY';
  runFromDay?: number | null;
  startDate: IsoDate;
  tillFurtherNotice?: boolean;
  periodMonths?: number | null;
  transactionChargeId?: number | null;
}

function assertMandatoryFields(input: StandingOrderInput): void {
  if (!input.postingDescription?.trim()) throw new AppError('Posting description is required', 'VALIDATION');
  if (input.startDate < today()) throw new AppError('The start date cannot be in the past', 'VALIDATION');
  if (!input.tillFurtherNotice && !(input.periodMonths && input.periodMonths > 0)) {
    throw new AppError('Either Till Further Notice, or a period in months, is required', 'VALIDATION');
  }
  if (input.standingOrderClass === 'INTERNAL') {
    if (!input.destinationMemberId || !input.destinationAccountId) {
      throw new AppError('A destination member and account are required for a transfer', 'VALIDATION');
    }
  } else if (input.standingOrderClass === 'LOAN_REPAYMENT') {
    if (!input.destinationLoanId) throw new AppError('A destination loan is required for a loan repayment', 'VALIDATION');
  }
  if (input.amountType === 'FIXED' && !(input.amount && input.amount > 0)) {
    throw new AppError('An amount is required for a fixed standing order', 'VALIDATION');
  }
  if (input.amountType === 'AMOUNT_BASED' && !(input.amountLimit && input.amountLimit > 0)) {
    throw new AppError('An amount limit is required for an amount-based standing order', 'VALIDATION');
  }
  if (input.amountType === 'FIXED' && (input.runType ?? 'DAILY') === 'SPECIFIC_DAY' && !input.runFromDay) {
    throw new AppError('A day of the month is required for a Specific Day standing order', 'VALIDATION');
  }
}

async function assertSourceAccount(accountId: number, memberId: number): Promise<void> {
  const acct = await one<{ member_id: number; status: string; allow_withdrawal: number; category: string }>(
    `SELECT sa.member_id, sa.status, sp.allow_withdrawal, sp.category
     FROM savings_account sa JOIN savings_product sp ON sp.id = sa.product_id WHERE sa.id = ?`,
    accountId,
  );
  if (!acct) throw new AppError('Source account not found', 'NOT_FOUND');
  if (acct.member_id !== memberId) throw new AppError('The source account does not belong to this member', 'VALIDATION');
  if (!acct.allow_withdrawal || !['WITHDRAWABLE DEPOSIT', 'HOLDING ACCOUNT'].includes(acct.category)) {
    throw new AppError('This account cannot fund a standing order', 'VALIDATION');
  }
}

/** AL's own "You have a similar Standing Order" guard — one non-terminated INTERNAL order per
 *  (member, destination account) pair. */
async function assertNoDuplicate(
  memberId: number, standingOrderClass: StandingOrderClass, destinationAccountId: number | null | undefined, excludeNo?: string,
): Promise<void> {
  if (standingOrderClass !== 'INTERNAL' || !destinationAccountId) return;
  const dup = await one(
    `SELECT 1 FROM standing_order
     WHERE member_id = ? AND destination_account_id = ? AND terminated = false ${excludeNo ? 'AND no != ?' : ''}`,
    ...(excludeNo ? [memberId, destinationAccountId, excludeNo] : [memberId, destinationAccountId]),
  );
  if (dup) throw new AppError('A standing order to this destination account already exists for this member', 'DUPLICATE');
}

export async function createStandingOrder(input: StandingOrderInput, user: Actor): Promise<{ no: string }> {
  assertMandatoryFields(input);
  await assertSourceAccount(input.accountId, input.memberId);
  await assertNoDuplicate(input.memberId, input.standingOrderClass, input.destinationAccountId);

  const no = await nextSequence('STANDING_ORDER');
  const endDate = input.tillFurtherNotice ? null : addMonths(input.startDate, input.periodMonths!);
  await run(
    `INSERT INTO standing_order
       (no, member_id, account_id, standing_order_class, amount_type, amount, amount_limit,
        destination_member_id, destination_account_id, destination_loan_id, posting_description,
        run_type, run_from_day, start_date, till_further_notice, period_months, end_date,
        transaction_charge_id, created_at, created_by)
     VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)`,
    no, input.memberId, input.accountId, input.standingOrderClass, input.amountType,
    Math.round(input.amount || 0), Math.round(input.amountLimit || 0),
    input.standingOrderClass === 'INTERNAL' ? input.destinationMemberId : null,
    input.standingOrderClass === 'INTERNAL' ? input.destinationAccountId : null,
    input.standingOrderClass === 'LOAN_REPAYMENT' ? input.destinationLoanId : null,
    input.postingDescription.trim(), input.runType || 'DAILY', input.runFromDay || null,
    input.startDate, !!input.tillFurtherNotice, input.tillFurtherNotice ? null : input.periodMonths, endDate,
    input.transactionChargeId || null, new Date().toISOString(), user.username,
  );
  await audit(user, 'STANDING_ORDER_CREATE', 'standing_order', no, { memberId: input.memberId, class: input.standingOrderClass });
  return { no };
}

export async function updateStandingOrder(no: string, input: StandingOrderInput, user: Actor): Promise<StandingOrderWithDimensions> {
  const before = await one<StandingOrder>('SELECT * FROM standing_order WHERE no = ?', no);
  if (!before) throw new AppError('Standing order not found', 'NOT_FOUND');
  if (before.status !== 'Open') throw new AppError('Only an open standing order can be edited', 'VALIDATION');
  assertMandatoryFields(input);
  await assertSourceAccount(input.accountId, input.memberId);
  await assertNoDuplicate(input.memberId, input.standingOrderClass, input.destinationAccountId, no);

  const endDate = input.tillFurtherNotice ? null : addMonths(input.startDate, input.periodMonths!);
  await run(
    `UPDATE standing_order
     SET member_id=?, account_id=?, standing_order_class=?, amount_type=?, amount=?, amount_limit=?,
         destination_member_id=?, destination_account_id=?, destination_loan_id=?, posting_description=?,
         run_type=?, run_from_day=?, start_date=?, till_further_notice=?, period_months=?, end_date=?,
         transaction_charge_id=?
     WHERE no=?`,
    input.memberId, input.accountId, input.standingOrderClass, input.amountType,
    Math.round(input.amount || 0), Math.round(input.amountLimit || 0),
    input.standingOrderClass === 'INTERNAL' ? input.destinationMemberId : null,
    input.standingOrderClass === 'INTERNAL' ? input.destinationAccountId : null,
    input.standingOrderClass === 'LOAN_REPAYMENT' ? input.destinationLoanId : null,
    input.postingDescription.trim(), input.runType || 'DAILY', input.runFromDay || null,
    input.startDate, !!input.tillFurtherNotice, input.tillFurtherNotice ? null : input.periodMonths, endDate,
    input.transactionChargeId || null, no,
  );
  await audit(user, 'STANDING_ORDER_UPDATE', 'standing_order', no, {});
  return (await getStandingOrder(no))!;
}

/**
 * Auto-creates and immediately activates a Loan Repayment standing order for a freshly
 * disbursed loan whose recovery_mode is STANDING_ORDER — called by lib/loanService.ts's
 * disburse() right after a successful disbursement, never by a person directly. Skips the
 * normal Open -> Pending Approval -> Approved cycle entirely and goes straight to Approved +
 * running: the loan itself already went through its own approval to reach disbursement, so a
 * second sign-off on the mechanical follow-up of "collect this loan's own installment" would be
 * redundant — the same "the triggering event already carried its own authorisation" reasoning
 * lib/memberApplications.ts's createMemberFromApplication() already applies when it opens a new
 * member's category default accounts without a fresh approval of its own.
 *
 * The order runs FIXED, for the loan's own installment amount, on the day of the month its first
 * (or next) instalment falls due, till further notice — runStandingOrders()'s own per-run check
 * (`processOne()` above) already auto-terminates a LOAN_REPAYMENT order the moment its
 * destination loan's balance reaches zero or it leaves DISBURSED status, so this never needs its
 * own end date. Idempotent: a loan that already has a live order against it (e.g. disburse() were
 * ever retried) is left alone rather than given a second one. Returns null — logged by the
 * caller, not thrown — when there's nothing eligible to fund it from, so a disbursement itself
 * never fails over this secondary automation.
 */
export async function createRecoveryStandingOrderForLoan(loanId: number, user: Actor): Promise<{ no: string } | null> {
  const loan = await one<{
    member_id: number; loan_no: string; status: string; installment: Cents; first_due_date: IsoDate | null;
  }>('SELECT member_id, loan_no, status, installment, first_due_date FROM loan WHERE id = ?', loanId);
  if (!loan || loan.status !== 'DISBURSED' || !(loan.installment > 0)) return null;

  const already = await one(
    "SELECT 1 FROM standing_order WHERE destination_loan_id = ? AND terminated = false", loanId,
  );
  if (already) return null;

  const source = await one<{ id: number }>(
    `SELECT sa.id FROM savings_account sa JOIN savings_product sp ON sp.id = sa.product_id
     WHERE sa.member_id = ? AND sa.status = 'ACTIVE' AND sp.allow_withdrawal = 1
       AND sp.category IN ('WITHDRAWABLE DEPOSIT', 'HOLDING ACCOUNT')
     ORDER BY sa.id LIMIT 1`,
    loan.member_id,
  );
  // Unlike the guards above (nothing genuinely went wrong, there's just nothing to do), this one
  // is a real setup gap worth surfacing — thrown so lib/loanService.ts's disburse() logs it via
  // audit rather than the member silently ending up with no recovery mechanism at all.
  if (!source) {
    throw new AppError(
      `${loan.loan_no}: no active withdrawable deposit/holding account to fund the recovery standing order from`,
      'NO_ELIGIBLE_ACCOUNT',
    );
  }

  const startDate = loan.first_due_date && loan.first_due_date > today() ? loan.first_due_date : today();
  const runFromDay = Number(startDate.slice(8, 10));

  const { no } = await createStandingOrder(
    {
      memberId: loan.member_id, accountId: source.id, standingOrderClass: 'LOAN_REPAYMENT',
      amountType: 'FIXED', amount: loan.installment, destinationLoanId: loanId,
      postingDescription: `Loan repayment — ${loan.loan_no}`, runType: 'SPECIFIC_DAY', runFromDay,
      startDate, tillFurtherNotice: true,
    },
    user,
  );
  await run("UPDATE standing_order SET status = 'Approved', running = true WHERE no = ?", no);
  await audit(user, 'STANDING_ORDER_AUTO_CREATE', 'standing_order', no, { loanId, loanNo: loan.loan_no });
  return { no };
}

export async function submitStandingOrder(no: string, user: Actor): Promise<{ autoApproved: boolean }> {
  const req = await one<StandingOrder>('SELECT * FROM standing_order WHERE no = ?', no);
  if (!req) throw new AppError('Standing order not found', 'NOT_FOUND');
  if (req.status !== 'Open') throw new AppError('Only an open standing order can be submitted for approval', 'VALIDATION');
  if (req.start_date < today()) throw new AppError('The start date cannot be in the past', 'VALIDATION');

  const matched = await findMatchingWorkflow('STANDING_ORDER', await pickConditionFields('STANDING_ORDER', req));
  if (!matched) throw new AppError('There is no enabled workflow for this document', 'NO_WORKFLOW');

  await tx(async () => {
    await run("UPDATE standing_order SET status = 'Pending Approval' WHERE no = ?", no);
    await startWorkflow(matched.workflow, matched.steps, {
      documentType: 'STANDING_ORDER', entityId: no, requestedBy: user.username, amount: 0,
    });
  });

  const after = await one<{ status: string }>('SELECT status FROM standing_order WHERE no = ?', no);
  return { autoApproved: after?.status === 'Approved' };
}

export async function cancelStandingOrderApproval(no: string, user: Actor): Promise<void> {
  const req = await one<Pick<StandingOrder, 'status' | 'created_by'>>('SELECT status, created_by FROM standing_order WHERE no = ?', no);
  if (!req) throw new AppError('Standing order not found', 'NOT_FOUND');
  if (req.status !== 'Pending Approval') {
    throw new AppError('Only a request pending approval can have its approval request cancelled', 'VALIDATION');
  }
  const routed = await findPendingRoutedTask('STANDING_ORDER', no);
  const requestedBy = routed?.requested_by ?? req.created_by;
  if (requestedBy !== user.username) {
    throw new AppError('Only the person who submitted this request for approval can cancel it', 'NOT_REQUESTER');
  }
  await run("UPDATE standing_order SET status = 'Open' WHERE no = ?", no);
  await audit(user, 'STANDING_ORDER_CANCEL_APPROVAL', 'standing_order', no, {});
}

/** Approval sets `running = true` directly — AL's own behaviour; there is no separate Process
 *  step for a Standing Order, unlike Account/Member Activation. */
export async function approveStandingOrder(no: string, user: Actor): Promise<void> {
  const req = await one<StandingOrder>('SELECT * FROM standing_order WHERE no = ?', no);
  if (!req) throw new AppError('Standing order not found', 'NOT_FOUND');
  if (req.status !== 'Pending Approval') throw new AppError('Only a request pending approval can be approved', 'VALIDATION');
  await run("UPDATE standing_order SET status = 'Approved', running = true, decision_reason = NULL WHERE no = ?", no);
  await audit(user, 'STANDING_ORDER_APPROVE', 'standing_order', no, {});
}

export async function rejectStandingOrder(no: string, reason: string | null, user: Actor): Promise<void> {
  if (!reason || !reason.trim()) throw new AppError('A reason is required to reject a request', 'VALIDATION');
  const req = await one<StandingOrder>('SELECT * FROM standing_order WHERE no = ?', no);
  if (!req) throw new AppError('Standing order not found', 'NOT_FOUND');
  if (req.status !== 'Pending Approval') throw new AppError('Only a request pending approval can be rejected', 'VALIDATION');
  await run("UPDATE standing_order SET status = 'Open', decision_reason = ? WHERE no = ?", reason, no);
  await audit(user, 'STANDING_ORDER_REJECT', 'standing_order', no, { reason });
}

/** An officer's own decision to stop the order for good — AL's Terminate action, available any
 *  time it's live. Distinct from the system terminating it automatically (see runOne() below). */
export async function terminateStandingOrder(no: string, user: Actor): Promise<void> {
  const req = await one<StandingOrder>('SELECT * FROM standing_order WHERE no = ?', no);
  if (!req) throw new AppError('Standing order not found', 'NOT_FOUND');
  if (req.status !== 'Approved' || !req.running || req.terminated) {
    throw new AppError('Only a live standing order can be terminated', 'VALIDATION');
  }
  await run("UPDATE standing_order SET running = false, terminated = true WHERE no = ?", no);
  await audit(user, 'STANDING_ORDER_TERMINATE', 'standing_order', no, {});
}

/** A temporary pause — auto-lifted by runStandingOrders() once freezeEndDate passes, mirroring
 *  AL's own UpdateSTO. */
export async function freezeStandingOrder(no: string, freezeEndDate: IsoDate, user: Actor): Promise<void> {
  const req = await one<StandingOrder>('SELECT * FROM standing_order WHERE no = ?', no);
  if (!req) throw new AppError('Standing order not found', 'NOT_FOUND');
  if (req.status !== 'Approved' || !req.running || req.terminated) {
    throw new AppError('Only a live standing order can be frozen', 'VALIDATION');
  }
  if (!freezeEndDate || freezeEndDate <= today()) throw new AppError('The freeze end date must be in the future', 'VALIDATION');
  await run('UPDATE standing_order SET freezed = true, freeze_end_date = ? WHERE no = ?', freezeEndDate, no);
  await audit(user, 'STANDING_ORDER_FREEZE', 'standing_order', no, { freezeEndDate });
}

export async function unfreezeStandingOrder(no: string, user: Actor): Promise<void> {
  const req = await one<StandingOrder>('SELECT * FROM standing_order WHERE no = ?', no);
  if (!req) throw new AppError('Standing order not found', 'NOT_FOUND');
  if (!req.freezed) throw new AppError('This standing order is not frozen', 'VALIDATION');
  await run('UPDATE standing_order SET freezed = false, freeze_end_date = NULL WHERE no = ?', no);
  await audit(user, 'STANDING_ORDER_UNFREEZE', 'standing_order', no, {});
}

/* ------------------------------------------------------------------ automation */

/** Whether a FIXED order is due to run today — Sweep/Amount Based have no schedule of their own
 *  and are simply checked every day (AL's own report only gates Fixed postings this way). A day
 *  of the month past the current month's last day runs on that last day instead (AL's own Next
 *  Run Date carry-forward, simplified to a live check — see the model's own doc comment). */
function isDueToday(order: Pick<StandingOrder, 'amount_type' | 'run_type' | 'run_from_day'>, dateStr: IsoDate): boolean {
  if (order.amount_type !== 'FIXED') return true;
  const d = new Date(`${dateStr}T00:00:00Z`);
  const day = d.getUTCDate();
  const lastDayOfMonth = new Date(Date.UTC(d.getUTCFullYear(), d.getUTCMonth() + 1, 0)).getUTCDate();
  if (order.run_type === 'DAILY') return true;
  if (order.run_type === 'END_MONTH') return day === lastDayOfMonth;
  // SPECIFIC_DAY
  const targetDay = Math.min(order.run_from_day || 1, lastDayOfMonth);
  return day === targetDay;
}

/** Re-fetches and re-evaluates one order from scratch inside its own transaction — never trusts
 *  the caller's own (possibly stale) snapshot, the same discipline every other automated run in
 *  this app follows. Returns null when there is genuinely nothing to report (not due, no
 *  available balance, ...); a result row is only produced for something worth surfacing
 *  (posted, auto-terminated, or explicitly blocked). */
async function processOne(no: string, dateStr: IsoDate, user: Actor): Promise<StandingOrderRunResult | null> {
  return tx(async () => {
    const o = await one<StandingOrder & { account_gl_control_id: number }>(
      `SELECT s.*, sp.gl_control_id AS account_gl_control_id
       FROM standing_order s JOIN savings_account sa ON sa.id = s.account_id JOIN savings_product sp ON sp.id = sa.product_id
       WHERE s.no = ?`,
      no,
    );
    if (!o || !o.running || o.terminated) return null;
    // AL's own `RunDate >= StandingOrder."Start Date"` guard.
    if (dateStr < o.start_date) return null;

    if (o.freezed && o.freeze_end_date && o.freeze_end_date < dateStr) {
      await run('UPDATE standing_order SET freezed = false, freeze_end_date = NULL WHERE no = ?', no);
      o.freezed = false;
      o.freeze_end_date = null;
    }

    if (o.end_date && !o.till_further_notice && o.end_date < dateStr) {
      await run("UPDATE standing_order SET terminated = true, running = false WHERE no = ?", no);
      return { no, action: 'TERMINATED', posted: 0, charged: 0, note: 'Past its end date' };
    }

    let destinationLoan: { status: string; principal_balance: Cents; interest_balance: Cents; penalty_balance: Cents } | undefined;
    if (o.standing_order_class === 'LOAN_REPAYMENT') {
      destinationLoan = await one(
        'SELECT status, principal_balance, interest_balance, penalty_balance FROM loan WHERE id = ?', o.destination_loan_id,
      );
      const owed = destinationLoan ? destinationLoan.principal_balance + destinationLoan.interest_balance + destinationLoan.penalty_balance : 0;
      if (!destinationLoan || destinationLoan.status !== 'DISBURSED' || owed <= 0) {
        await run("UPDATE standing_order SET terminated = true, running = false WHERE no = ?", no);
        return { no, action: 'TERMINATED', posted: 0, charged: 0, note: 'Destination loan is fully repaid or no longer disbursed' };
      }
    }

    if (o.freezed) return null;
    if (o.last_run_date === dateStr) return null;
    if (!isDueToday(o, dateStr)) return null;

    const account = await one<{ balance: Cents; hold_amount: Cents; min_balance: Cents; account_no: string; status: string }>(
      `SELECT sa.balance, sa.hold_amount, sp.min_balance, sa.account_no, sa.status
       FROM savings_account sa JOIN savings_product sp ON sp.id = sa.product_id WHERE sa.id = ?`,
      o.account_id,
    );
    if (!account || account.status !== 'ACTIVE') {
      return { no, action: 'NONE', posted: 0, charged: 0, note: 'Source account is not active' };
    }

    let chargeAmount = 0;
    if (o.transaction_charge_id) {
      const charges = await previewTransactionChargeById(o.transaction_charge_id, 0);
      chargeAmount = charges.reduce((sum, c) => sum + c.amount, 0);
    }
    const available = Math.max(account.balance - account.hold_amount - account.min_balance - chargeAmount, 0);

    let postingAmount = 0;
    if (o.amount_type === 'FIXED') postingAmount = Math.min(o.amount, available);
    else if (o.amount_type === 'SWEEP') postingAmount = available;
    else if (o.amount_type === 'AMOUNT_BASED') {
      postingAmount = (account.balance - account.hold_amount - account.min_balance) >= o.amount_limit ? available : 0;
    }
    if (destinationLoan && o.standing_order_class === 'LOAN_REPAYMENT') {
      postingAmount = Math.min(postingAmount, destinationLoan.principal_balance + destinationLoan.interest_balance + destinationLoan.penalty_balance);
    }
    if (postingAmount <= 0) return null;

    const description = o.posting_description || `Standing Order ${no}`;

    try {
      if (o.standing_order_class === 'INTERNAL') {
        await assertMemberNotDormant(o.member_id, 'a standing order');
        const dest = await one<{ balance: Cents; account_no: string; gl_control_id: number; status: string }>(
          `SELECT sa.balance, sa.account_no, sp.gl_control_id, sa.status
           FROM savings_account sa JOIN savings_product sp ON sp.id = sa.product_id WHERE sa.id = ?`,
          o.destination_account_id,
        );
        if (!dest || dest.status !== 'ACTIVE') {
          return { no, action: 'NONE', posted: 0, charged: 0, note: 'Destination account is not active' };
        }
        const j = await postJournal({
          valueDate: dateStr, module: 'SAVINGS', eventType: 'STANDING_ORDER', description, reference: no,
          memberId: o.member_id, user,
          lines: [
            { account: o.account_gl_control_id, debit: postingAmount, credit: 0 },
            { account: dest.gl_control_id, debit: 0, credit: postingAmount },
          ],
        });
        const newSourceBal = account.balance - postingAmount;
        await run('UPDATE savings_account SET balance = ?, last_activity = ? WHERE id = ?', newSourceBal, dateStr, o.account_id);
        await run(
          `INSERT INTO txn (txn_ref, value_date, created_at, module, txn_type, member_id,
             savings_account_id, amount, running_balance, channel, description, journal_id, created_by)
           VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?)`,
          await nextSequence('TXN'), dateStr, new Date().toISOString(), 'SAVINGS', 'WITHDRAWAL', o.member_id,
          o.account_id, -postingAmount, newSourceBal, 'SYSTEM', description, j.id, user.username,
        );
        const newDestBal = dest.balance + postingAmount;
        await run('UPDATE savings_account SET balance = ?, last_activity = ? WHERE id = ?', newDestBal, dateStr, o.destination_account_id);
        await run(
          `INSERT INTO txn (txn_ref, value_date, created_at, module, txn_type, member_id,
             savings_account_id, amount, running_balance, channel, description, journal_id, created_by)
           VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?)`,
          await nextSequence('TXN'), dateStr, new Date().toISOString(), 'SAVINGS', 'DEPOSIT', o.destination_member_id,
          o.destination_account_id, postingAmount, newDestBal, 'SYSTEM', description, j.id, user.username,
        );
      } else {
        await repay({
          loanId: o.destination_loan_id!, amount: postingAmount, channel: 'SYSTEM', fromSavingsAccountId: o.account_id,
          valueDate: dateStr, description, user, idempotencyKey: `STO-${no}-${dateStr}`,
        });
      }
    } catch (e) {
      if (e instanceof PostingError || e instanceof AppError) {
        return { no, action: 'NONE', posted: 0, charged: 0, note: e.message };
      }
      throw e;
    }

    let charged = 0;
    if (o.transaction_charge_id) {
      const posted = await postTransactionCharges({
        transactionChargeId: o.transaction_charge_id, baseAmount: 0, debitAccountCode: o.account_gl_control_id,
        valueDate: dateStr, module: 'SAVINGS', eventType: 'STANDING_ORDER_CHARGE', memberId: o.member_id,
        description: `Standing order charge — ${no}`, reference: no, user,
      });
      if (posted) {
        charged = posted.charges.reduce((sum, c) => sum + c.amount, 0);
        const acctNow = await one<{ balance: Cents }>('SELECT balance FROM savings_account WHERE id = ?', o.account_id);
        const newBalance = acctNow!.balance - charged;
        await run('UPDATE savings_account SET balance = ?, last_activity = ? WHERE id = ?', newBalance, dateStr, o.account_id);
        await run(
          `INSERT INTO txn (txn_ref, value_date, created_at, module, txn_type, member_id,
             savings_account_id, amount, running_balance, channel, description, journal_id, created_by)
           VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?)`,
          await nextSequence('TXN'), dateStr, new Date().toISOString(), 'SAVINGS', 'FEE', o.member_id,
          o.account_id, -charged, newBalance, 'SYSTEM', `Standing order charge — ${no}`, posted.journal.id, user.username,
        );
      }
    }

    await run('UPDATE standing_order SET last_run_date = ? WHERE no = ?', dateStr, no);
    return { no, action: 'POSTED', posted: postingAmount, charged, note: null };
  });
}

/**
 * Runs every live (Approved, not terminated) standing order for `dateStr` (defaulting to
 * today). Each order is evaluated and posted in its own transaction — one order's failure is
 * recorded and skipped rather than rolling back everyone else already posted in the same run,
 * matching lib/entranceFeeRecovery.ts's own per-item isolation.
 */
export async function runStandingOrders(user: Actor, dateStr: IsoDate = today()): Promise<StandingOrderRunSummary> {
  const orders = await all<{ no: string }>(
    "SELECT no FROM standing_order WHERE running = true AND terminated = false ORDER BY no",
  );
  const results: StandingOrderRunResult[] = [];

  for (const o of orders) {
    try {
      const outcome = await processOne(o.no, dateStr, user);
      if (outcome) results.push(outcome);
    } catch (e) {
      results.push({ no: o.no, action: 'NONE', posted: 0, charged: 0, note: (e as Error).message || 'Run failed' });
    }
  }

  const summary: StandingOrderRunSummary = {
    results,
    posted: results.filter((r) => r.action === 'POSTED').length,
    terminated: results.filter((r) => r.action === 'TERMINATED').length,
    totalPosted: results.reduce((sum, r) => sum + r.posted, 0),
  };
  await audit(user, 'STANDING_ORDER_RUN', 'standing_order', null, {
    posted: summary.posted, terminated: summary.terminated, totalPosted: summary.totalPosted,
  });
  return summary;
}
