/*
 * Lien / Hold — AL "Lien" (Tab52204192 / Pages 52204235-6 / Cod52204007.PostAmountHolding).
 * A maker-checker instruction to HOLD part of a member's deposit-account balance (making it
 * unavailable to withdraw, borrow against, sweep or be charged from) or to RELEASE a previous
 * hold. There is NO G/L posting — AL only writes an "Uncleared Funds" memo entry; here,
 * processing moves `savings_account.hold_amount`, which every "available balance" calculation
 * in the app already subtracts (lib/savings.ts, lib/memberCharging.ts, lib/standingOrders.ts,
 * lib/loanService.ts, ...). So a processed HOLD immediately restricts the member's funds and a
 * processed RELEASE frees them, with no ledger movement.
 *
 * Lifecycle: Open -> Pending Approval -> Approved -> Processed, plus a Reopen back to Open
 * while Approved and not yet processed (AL's own "Re&open" action).
 *
 * Amount limits (AL Tab52204192 field 6 OnValidate against GetAccountBalance):
 *   - HOLD    <= the account's ActualBalance (balance - hold_amount - min_balance, clamped >= 0)
 *   - RELEASE <= the amount currently held on the account (hold_amount)
 */
import {
  one, all, run, tx, nextSequence, audit, hasAnyRow,
} from './db.ts';
import { AppError } from './errors.ts';
import { assertMemberNotDormant } from './memberDormancy.ts';
import { findMatchingWorkflow, findPendingRoutedTask, pickConditionFields, startWorkflow } from './workflow.ts';
import { buildFilterClause, type FilterCondition, type FilterFieldDef } from './listFilters.ts';
import { buildOrderClause, type SortState } from './listSort.ts';
import type { Actor, Cents, IsoDate, LienTransactionType, MemberLien, MemberLienView } from './types.ts';

export type LienView = 'open' | 'pending' | 'approved' | 'processed';

const VIEW_CLAUSE: Record<LienView, string> = {
  open: "l.status = 'Open'",
  pending: "l.status = 'Pending Approval'",
  approved: "l.status = 'Approved'",
  processed: "l.status = 'Processed'",
};

/** AL Tab52204192's Account No. TableRelation — the accounts a lien can attach to. In this
 *  system that's any deposit product that permits withdrawal / funds transfer
 *  (`savings_product.allow_withdrawal`), the exact pool every other "pick a deposit account"
 *  list uses (teller transactions, member charging, standing orders). It naturally excludes
 *  Share Capital, Fixed Deposits and non-withdrawable (BOSA) deposits, matching AL — and,
 *  unlike keying off the free-text `category`, it can't be broken by a product left on the
 *  default/blank category. */

const SELECT_ROW = `
  SELECT l.*,
         m.member_no, m.first_name AS member_first_name, m.last_name AS member_last_name,
         sa.account_no, sp.name AS account_product_name, sa.balance AS account_balance,
         sa.hold_amount AS account_hold_amount, sp.min_balance AS account_min_balance,
         GREATEST(sa.balance - sa.hold_amount - sp.min_balance, 0) AS account_available
  FROM member_lien l
  JOIN member m ON m.id = l.member_id
  JOIN savings_account sa ON sa.id = l.savings_account_id
  JOIN savings_product sp ON sp.id = sa.product_id`;

export const LIEN_FILTER_FIELDS: FilterFieldDef[] = [
  { key: 'no', label: 'No.', type: 'text', column: 'l.no' },
  {
    key: 'transaction_type', label: 'Type', type: 'select', column: 'l.transaction_type',
    options: [{ value: 'HOLD', label: 'Hold' }, { value: 'RELEASE', label: 'Release' }],
  },
  { key: 'member_id', label: 'Member', type: 'select', column: 'm.id' },
  { key: 'posting_date', label: 'Posting Date', type: 'date', column: 'l.posting_date' },
  { key: 'created_by', label: 'Created By', type: 'text', column: 'l.created_by' },
  { key: 'created_at', label: 'Created', type: 'date', column: 'l.created_at', datetime: true },
];

const SORT_COLUMNS: Record<string, string> = {
  no: 'l.no',
  member: 'm.first_name',
  amount: 'l.amount',
  status: 'l.status',
  posting_date: 'l.posting_date',
  created_at: 'l.created_at',
};

export interface ListLiensOptions {
  view?: LienView;
  search?: string;
  filters?: FilterCondition[];
  sort?: SortState | null;
}

export const listLiens = (
  { view, search = '', filters = [], sort = null }: ListLiensOptions = {},
): Promise<MemberLienView[]> => {
  const { clause, params } = buildFilterClause(LIEN_FILTER_FIELDS, filters);
  const orderBy = buildOrderClause(SORT_COLUMNS, sort, 'l.no DESC');
  return all<MemberLienView>(
    `${SELECT_ROW}
     WHERE (l.no LIKE @like OR m.member_no LIKE @like OR m.first_name LIKE @like OR m.last_name LIKE @like
        OR sa.account_no LIKE @like)
       ${view ? `AND ${VIEW_CLAUSE[view]}` : ''}
       ${clause}
     ${orderBy}`,
    { like: `%${String(search).trim()}%`, ...params },
  );
};

export const getLien = (no: string): Promise<MemberLienView | undefined> =>
  one<MemberLienView>(`${SELECT_ROW} WHERE l.no = ?`, no);

export const hasAnyLiens = (view?: LienView): Promise<boolean> =>
  hasAnyRow('member_lien l', view ? VIEW_CLAUSE[view] : undefined);

export async function getAdjacentLienNos(
  no: string, view?: LienView,
): Promise<{ prevNo: string | null; nextNo: string | null }> {
  const clause = view ? `AND ${VIEW_CLAUSE[view]}` : '';
  const [prev, next] = await Promise.all([
    one<{ no: string }>(`SELECT l.no FROM member_lien l WHERE l.no < ? ${clause} ORDER BY l.no DESC LIMIT 1`, no),
    one<{ no: string }>(`SELECT l.no FROM member_lien l WHERE l.no > ? ${clause} ORDER BY l.no ASC LIMIT 1`, no),
  ]);
  return { prevNo: prev?.no ?? null, nextNo: next?.no ?? null };
}

/** Every processed lien against an account — its hold/release history (what makes up its
 *  current hold_amount). */
export const listAccountLienHistory = (savingsAccountId: number): Promise<Pick<MemberLien, 'no' | 'transaction_type' | 'amount' | 'narration' | 'processed_at' | 'processed_by'>[]> =>
  all(
    `SELECT no, transaction_type, amount, narration, processed_at, processed_by
     FROM member_lien WHERE savings_account_id = ? AND status = 'Processed'
     ORDER BY processed_at DESC, no DESC`,
    savingsAccountId,
  );

/** The member's deposit accounts a lien can attach to, with the figures the card needs —
 *  every active account on a product that permits withdrawal / funds transfer. */
export const lienableAccountsForMember = (memberId: number): Promise<{
  id: number; account_no: string; product_name: string; balance: Cents; hold_amount: Cents;
  min_balance: Cents; available: Cents;
}[]> =>
  all(
    `SELECT sa.id, sa.account_no, sp.name AS product_name, sa.balance, sa.hold_amount, sp.min_balance,
            GREATEST(sa.balance - sa.hold_amount - sp.min_balance, 0) AS available
     FROM savings_account sa JOIN savings_product sp ON sp.id = sa.product_id
     WHERE sa.member_id = ? AND sa.status = 'ACTIVE' AND sp.allow_withdrawal = 1
     ORDER BY sa.account_no`,
    memberId,
  );

/* ------------------------------------------------------------ create / edit */

export interface LienInput {
  memberId: number;
  savingsAccountId: number;
  transactionType: LienTransactionType;
  amount: Cents;
  postingDate: IsoDate;
  narration?: string | null;
}

interface AccountFigures {
  member_id: number;
  status: string;
  allow_withdrawal: number;
  balance: Cents;
  hold_amount: Cents;
  min_balance: Cents;
}

async function accountFigures(savingsAccountId: number): Promise<AccountFigures> {
  const acct = await one<AccountFigures>(
    `SELECT sa.member_id, sa.status, sp.allow_withdrawal, sa.balance, sa.hold_amount, sp.min_balance
     FROM savings_account sa JOIN savings_product sp ON sp.id = sa.product_id WHERE sa.id = ?`,
    savingsAccountId,
  );
  if (!acct) throw new AppError('Savings account not found', 'NOT_FOUND');
  return acct;
}

/** Shared by create, update and the final pre-process re-check — the balance can move between
 *  any of those moments, so the limit is always re-evaluated against live figures. */
async function assertWithinLimit(
  savingsAccountId: number, memberId: number, transactionType: LienTransactionType, amount: Cents,
): Promise<void> {
  if (!(amount > 0)) throw new AppError('Amount must be greater than zero', 'VALIDATION');
  const acct = await accountFigures(savingsAccountId);
  if (acct.member_id !== memberId) throw new AppError('That account does not belong to this member', 'VALIDATION');
  if (acct.status !== 'ACTIVE') throw new AppError(`The account is ${acct.status} — no lien can be placed`, 'VALIDATION');
  if (!acct.allow_withdrawal) {
    throw new AppError('A lien can only be placed on an account that permits withdrawal / funds transfer', 'VALIDATION');
  }

  if (transactionType === 'HOLD') {
    const available = Math.max(acct.balance - acct.hold_amount - acct.min_balance, 0);
    if (amount > available) {
      throw new AppError(
        `You can only hold up to ${(available / 100).toFixed(2)} on this account`, 'AMOUNT_EXCEEDS_AVAILABLE',
      );
    }
  } else {
    if (amount > acct.hold_amount) {
      throw new AppError(
        `Only ${(acct.hold_amount / 100).toFixed(2)} is currently held on this account — you cannot release more`,
        'AMOUNT_EXCEEDS_HELD',
      );
    }
  }
}

function assertMandatory(input: LienInput): void {
  if (!input.memberId) throw new AppError('Member is required', 'VALIDATION');
  if (!input.savingsAccountId) throw new AppError('An account is required', 'VALIDATION');
  if (!['HOLD', 'RELEASE'].includes(input.transactionType)) throw new AppError('Invalid transaction type', 'VALIDATION');
  if (!input.postingDate) throw new AppError('A posting date is required', 'VALIDATION');
}

export async function createLien(input: LienInput, user: Actor): Promise<{ no: string }> {
  assertMandatory(input);
  await assertWithinLimit(input.savingsAccountId, input.memberId, input.transactionType, input.amount);

  const no = await nextSequence('MEMBER_LIEN');
  await run(
    `INSERT INTO member_lien
       (no, member_id, savings_account_id, transaction_type, amount, narration, posting_date, created_at, created_by)
     VALUES (?,?,?,?,?,?,?,?,?)`,
    no, input.memberId, input.savingsAccountId, input.transactionType, Math.round(input.amount),
    input.narration?.trim() || null, input.postingDate, new Date().toISOString(), user.username,
  );
  await audit(user, 'LIEN_CREATE', 'member_lien', no, { type: input.transactionType, amount: input.amount });
  return { no };
}

export async function updateLien(no: string, input: LienInput, user: Actor): Promise<MemberLienView> {
  const before = await one<MemberLien>('SELECT * FROM member_lien WHERE no = ?', no);
  if (!before) throw new AppError('Lien not found', 'NOT_FOUND');
  if (before.status !== 'Open') throw new AppError('Only an open lien can be edited', 'VALIDATION');
  if (before.created_by !== user.username) throw new AppError('Only the person who created this lien can edit it', 'NOT_CREATOR');
  assertMandatory(input);
  await assertWithinLimit(input.savingsAccountId, input.memberId, input.transactionType, input.amount);

  await run(
    `UPDATE member_lien
     SET member_id = ?, savings_account_id = ?, transaction_type = ?, amount = ?, narration = ?, posting_date = ?
     WHERE no = ?`,
    input.memberId, input.savingsAccountId, input.transactionType, Math.round(input.amount),
    input.narration?.trim() || null, input.postingDate, no,
  );
  await audit(user, 'LIEN_UPDATE', 'member_lien', no, {});
  return (await getLien(no))!;
}

export async function deleteLien(no: string, user: Actor): Promise<void> {
  const before = await one<Pick<MemberLien, 'status' | 'created_by'>>('SELECT status, created_by FROM member_lien WHERE no = ?', no);
  if (!before) throw new AppError('Lien not found', 'NOT_FOUND');
  if (before.status !== 'Open') throw new AppError('Only an open lien can be deleted', 'VALIDATION');
  if (before.created_by !== user.username) throw new AppError('Only the person who created this lien can delete it', 'NOT_CREATOR');
  await run('DELETE FROM member_lien WHERE no = ?', no);
  await audit(user, 'LIEN_DELETE', 'member_lien', no, {});
}

/* -------------------------------------------------------------- maker-checker */

export async function submitLien(no: string, user: Actor): Promise<{ autoApproved: boolean }> {
  const req = await one<MemberLien>('SELECT * FROM member_lien WHERE no = ?', no);
  if (!req) throw new AppError('Lien not found', 'NOT_FOUND');
  if (req.status !== 'Open') throw new AppError('Only an open lien can be submitted for approval', 'VALIDATION');
  if (!req.narration || !req.narration.trim()) throw new AppError('A narration is required before sending for approval', 'VALIDATION');
  await assertWithinLimit(req.savings_account_id, req.member_id, req.transaction_type, req.amount);

  const matched = await findMatchingWorkflow('MEMBER_LIEN', await pickConditionFields('MEMBER_LIEN', req));
  if (!matched) throw new AppError('There is no enabled workflow for this document', 'NO_WORKFLOW');

  await tx(async () => {
    await run("UPDATE member_lien SET status = 'Pending Approval' WHERE no = ?", no);
    await startWorkflow(matched.workflow, matched.steps, {
      documentType: 'MEMBER_LIEN', entityId: no, requestedBy: user.username, amount: Number(req.amount),
    });
  });

  const after = await one<{ status: string }>('SELECT status FROM member_lien WHERE no = ?', no);
  return { autoApproved: after?.status === 'Approved' };
}

export async function cancelLienApproval(no: string, user: Actor): Promise<void> {
  const req = await one<Pick<MemberLien, 'status' | 'created_by'>>('SELECT status, created_by FROM member_lien WHERE no = ?', no);
  if (!req) throw new AppError('Lien not found', 'NOT_FOUND');
  if (req.status !== 'Pending Approval') throw new AppError('Only a lien pending approval can be recalled', 'VALIDATION');
  const routed = await findPendingRoutedTask('MEMBER_LIEN', no);
  const requestedBy = routed?.requested_by ?? req.created_by;
  if (requestedBy !== user.username) throw new AppError('Only the person who submitted this lien can recall it', 'NOT_REQUESTER');
  await run("UPDATE member_lien SET status = 'Open' WHERE no = ?", no);
  await audit(user, 'LIEN_CANCEL_APPROVAL', 'member_lien', no, {});
}

export async function approveLien(no: string, user: Actor): Promise<void> {
  const req = await one<MemberLien>('SELECT * FROM member_lien WHERE no = ?', no);
  if (!req) throw new AppError('Lien not found', 'NOT_FOUND');
  if (req.status !== 'Pending Approval') throw new AppError('Only a lien pending approval can be approved', 'VALIDATION');
  await run("UPDATE member_lien SET status = 'Approved', decision_reason = NULL WHERE no = ?", no);
  await audit(user, 'LIEN_APPROVE', 'member_lien', no, {});
}

export async function rejectLien(no: string, reason: string | null, user: Actor): Promise<void> {
  if (!reason || !reason.trim()) throw new AppError('A reason is required to reject a lien', 'VALIDATION');
  const req = await one<MemberLien>('SELECT * FROM member_lien WHERE no = ?', no);
  if (!req) throw new AppError('Lien not found', 'NOT_FOUND');
  if (req.status !== 'Pending Approval') throw new AppError('Only a lien pending approval can be rejected', 'VALIDATION');
  await run("UPDATE member_lien SET status = 'Open', decision_reason = ? WHERE no = ?", reason, no);
  await audit(user, 'LIEN_REJECT', 'member_lien', no, { reason });
}

/** AL's "Re&open" action — an Approved, not-yet-processed lien back to Open for amendment. */
export async function reopenLien(no: string, user: Actor): Promise<void> {
  const req = await one<MemberLien>('SELECT * FROM member_lien WHERE no = ?', no);
  if (!req) throw new AppError('Lien not found', 'NOT_FOUND');
  if (req.status !== 'Approved' || req.processed) {
    throw new AppError('Only an approved lien that has not been processed can be reopened', 'VALIDATION');
  }
  await run("UPDATE member_lien SET status = 'Open' WHERE no = ?", no);
  await audit(user, 'LIEN_REOPEN', 'member_lien', no, {});
}

/* ------------------------------------------------------------------- process */

/**
 * AL Cod52204007.PostAmountHolding — no G/L, just move the account's hold. A HOLD adds to
 * `savings_account.hold_amount`; a RELEASE subtracts (clamped at zero). Every available-balance
 * calc in the app then reflects it immediately. The limit is re-checked one last time here.
 */
export async function processLien(no: string, user: Actor): Promise<{ heldBefore: Cents; heldAfter: Cents; available: Cents }> {
  return tx(async () => {
    const req = await one<MemberLien>('SELECT * FROM member_lien WHERE no = ?', no);
    if (!req) throw new AppError('Lien not found', 'NOT_FOUND');
    if (req.status !== 'Approved') throw new AppError('Only an approved lien can be processed', 'VALIDATION');
    if (req.processed) throw new AppError('This lien has already been processed', 'VALIDATION');
    if (!req.narration || !req.narration.trim()) throw new AppError('A narration is required', 'VALIDATION');
    await assertMemberNotDormant(req.member_id, 'a lien');
    await assertWithinLimit(req.savings_account_id, req.member_id, req.transaction_type, req.amount);

    const acct = await accountFigures(req.savings_account_id);
    const amount = Number(req.amount);
    const heldAfter = req.transaction_type === 'HOLD'
      ? acct.hold_amount + amount
      : Math.max(acct.hold_amount - amount, 0);

    await run(
      'UPDATE savings_account SET hold_amount = ?, version = version + 1 WHERE id = ?',
      heldAfter, req.savings_account_id,
    );
    await run(
      `UPDATE member_lien SET status = 'Processed', processed = true, processed_at = ?, processed_by = ? WHERE no = ?`,
      new Date().toISOString(), user.username, no,
    );
    await audit(user, 'LIEN_PROCESS', 'member_lien', no, {
      type: req.transaction_type, amount, heldBefore: acct.hold_amount, heldAfter,
    });
    return {
      heldBefore: acct.hold_amount,
      heldAfter,
      available: Math.max(acct.balance - heldAfter - acct.min_balance, 0),
    };
  });
}
