/*
 * Bankers Cheque — AL Tab52204123 / Pag52204057-58 / Cod52204019.PostBankersCheque /
 * Rep52204097 "Bankers Cheque Schedule".
 *
 * A maker-checker sale of a banker's cheque against a member's deposit account. On posting the
 * member's account is debited `amount` and the cheque type's clearing G/L account is credited
 * `amount`; the cheque type's clearing charge is also deducted from the member's account.
 * `net_amount` (= amount + charge) must not overdraw the account's available balance.
 *
 * Lifecycle: Open -> Pending Approval -> Approved -> Processed, plus Reopen (Approved & not
 * posted -> Open) — the same shape as lib/liens.ts / lib/interAccountTransfer.ts.
 */
import {
  one, all, run, tx, nextSequence, audit, hasAnyRow,
} from './db.ts';
import { AppError } from './errors.ts';
import { postJournal } from './accounting.ts';
import { getJournal, type JournalDetail } from './gl.ts';
import { getTransactionCharge, calculateTransactionCharges, postTransactionCharges } from './charges.ts';
import { getChequeType } from './chequeTypes.ts';
import { resolvePostingDate } from './postingDates.ts';
import { assertMemberNotDormant } from './memberDormancy.ts';
import { findMatchingWorkflow, findPendingRoutedTask, pickConditionFields, startWorkflow } from './workflow.ts';
import { buildFilterClause, type FilterCondition, type FilterFieldDef } from './listFilters.ts';
import { buildOrderClause, type SortState } from './listSort.ts';
import type {
  Actor, Cents, IsoDate, BankersCheque, BankersChequeView, BankersChequeScheduleRow,
} from './types.ts';

export type BankersChequeView2 = 'open' | 'pending' | 'approved' | 'processed';

const VIEW_CLAUSE: Record<BankersChequeView2, string> = {
  open: "b.status = 'Open'",
  pending: "b.status = 'Pending Approval'",
  approved: "b.status = 'Approved'",
  processed: "b.status = 'Processed'",
};

const SELECT_ROW = `
  SELECT b.*,
         ct.code AS cheque_type_code,
         m.member_no, m.first_name AS member_first_name, m.last_name AS member_last_name,
         sa.account_no, sp.name AS account_product_name, sa.balance AS account_balance,
         sa.hold_amount AS account_hold_amount, sp.min_balance AS account_min_balance,
         GREATEST(sa.balance - sa.hold_amount - sp.min_balance, 0) AS account_available,
         g.code AS clearing_gl_account_code,
         tc.code AS transaction_charge_code,
         j.journal_no AS journal_no
  FROM bankers_cheque b
  JOIN cheque_type ct ON ct.id = b.cheque_type_id
  JOIN member m ON m.id = b.member_id
  JOIN savings_account sa ON sa.id = b.savings_account_id
  JOIN savings_product sp ON sp.id = sa.product_id
  JOIN gl_account g ON g.id = ct.clearing_gl_account_id
  LEFT JOIN transaction_charge tc ON tc.id = b.transaction_charge_id
  LEFT JOIN journal j ON j.id = b.journal_id`;

export const BANKERS_CHEQUE_FILTER_FIELDS: FilterFieldDef[] = [
  { key: 'no', label: 'No.', type: 'text', column: 'b.no' },
  { key: 'cheque_type_id', label: 'Cheque Type', type: 'select', column: 'b.cheque_type_id' },
  { key: 'member_id', label: 'Member', type: 'select', column: 'b.member_id' },
  { key: 'cheque_no', label: 'Cheque No.', type: 'text', column: 'b.cheque_no' },
  { key: 'posting_date', label: 'Posting Date', type: 'date', column: 'b.posting_date' },
  { key: 'created_by', label: 'Created By', type: 'text', column: 'b.created_by' },
  { key: 'created_at', label: 'Created', type: 'date', column: 'b.created_at', datetime: true },
];

const SORT_COLUMNS: Record<string, string> = {
  no: 'b.no',
  member: 'm.first_name',
  amount: 'b.amount',
  net_amount: 'b.net_amount',
  status: 'b.status',
  posting_date: 'b.posting_date',
  created_at: 'b.created_at',
};

export interface ListBankersChequesOptions {
  view?: BankersChequeView2;
  search?: string;
  filters?: FilterCondition[];
  sort?: SortState | null;
}

export const listBankersCheques = (
  { view, search = '', filters = [], sort = null }: ListBankersChequesOptions = {},
): Promise<BankersChequeView[]> => {
  const { clause, params } = buildFilterClause(BANKERS_CHEQUE_FILTER_FIELDS, filters);
  const orderBy = buildOrderClause(SORT_COLUMNS, sort, 'b.no DESC');
  return all<BankersChequeView>(
    `${SELECT_ROW}
     WHERE (b.no LIKE @like OR b.cheque_no LIKE @like OR m.member_no LIKE @like
        OR m.first_name LIKE @like OR m.last_name LIKE @like OR sa.account_no LIKE @like OR b.payee_details LIKE @like)
       ${view ? `AND ${VIEW_CLAUSE[view]}` : ''}
       ${clause}
     ${orderBy}`,
    { like: `%${String(search).trim()}%`, ...params },
  );
};

export const getBankersCheque = (no: string): Promise<BankersChequeView | undefined> =>
  one<BankersChequeView>(`${SELECT_ROW} WHERE b.no = ?`, no);

export const hasAnyBankersCheques = (view?: BankersChequeView2): Promise<boolean> =>
  hasAnyRow('bankers_cheque b', view ? VIEW_CLAUSE[view] : undefined);

export async function getAdjacentBankersChequeNos(
  no: string, view?: BankersChequeView2,
): Promise<{ prevNo: string | null; nextNo: string | null }> {
  const clause = view ? `AND ${VIEW_CLAUSE[view]}` : '';
  const [prev, next] = await Promise.all([
    one<{ no: string }>(`SELECT b.no FROM bankers_cheque b WHERE b.no < ? ${clause} ORDER BY b.no DESC LIMIT 1`, no),
    one<{ no: string }>(`SELECT b.no FROM bankers_cheque b WHERE b.no > ? ${clause} ORDER BY b.no ASC LIMIT 1`, no),
  ]);
  return { prevNo: prev?.no ?? null, nextNo: next?.no ?? null };
}

/* -------------------------------------------------------------- account picker */

export interface BankersChequeAccount {
  id: number; account_no: string; product_name: string;
  balance: Cents; hold_amount: Cents; min_balance: Cents; available: Cents;
}

/** AL Tab52204123's "Account Type" lookup — the member's active accounts on a product that
 *  permits funds transfer (`allow_transfer`). These are the accounts a banker's cheque draws on. */
export const bankersChequeAccountsForMember = (memberId: number): Promise<BankersChequeAccount[]> =>
  all<BankersChequeAccount>(
    `SELECT sa.id, sa.account_no, sp.name AS product_name, sa.balance, sa.hold_amount, sp.min_balance,
            GREATEST(sa.balance - sa.hold_amount - sp.min_balance, 0) AS available
     FROM savings_account sa JOIN savings_product sp ON sp.id = sa.product_id
     WHERE sa.member_id = ? AND sa.status = 'ACTIVE' AND sp.allow_transfer = 1
     ORDER BY sa.account_no`,
    memberId,
  );

/* ------------------------------------------------------------------- charge */

/** The clearing charge configured on a cheque type, and a helper to compute it for an amount. */
async function resolveChequeCharge(chequeTypeId: number): Promise<{ id: number | null; amount: (base: Cents) => Cents }> {
  const type = await getChequeType(chequeTypeId);
  if (!type?.clearing_charge_id) return { id: null, amount: () => 0 };
  const detail = await getTransactionCharge(type.clearing_charge_id);
  if (!detail) return { id: null, amount: () => 0 };
  return {
    id: detail.id,
    amount: (base: Cents) => calculateTransactionCharges(detail, base).reduce((s, c) => s + c.amount, 0),
  };
}

/** Inquiry-only — the clearing charge a cheque of `amount` on `chequeTypeId` would attract. */
export async function previewBankersChequeCharge(chequeTypeId: number, amount: Cents): Promise<Cents> {
  if (!chequeTypeId || !(amount > 0)) return 0;
  const charge = await resolveChequeCharge(chequeTypeId);
  return charge.amount(amount);
}

/* ------------------------------------------------------------ create / edit */

export interface BankersChequeInput {
  chequeTypeId: number;
  memberId: number;
  savingsAccountId: number;
  payeeDetails?: string | null;
  chequeNo?: string | null;
  amount: Cents;
  postingDate: IsoDate;
}

interface AccountFigures {
  member_id: number;
  status: string;
  allow_transfer: number;
  balance: Cents;
  hold_amount: Cents;
  min_balance: Cents;
  gl_control_id: number;
}

async function accountFigures(savingsAccountId: number): Promise<AccountFigures> {
  const acct = await one<AccountFigures>(
    `SELECT sa.member_id, sa.status, sp.allow_transfer, sa.balance, sa.hold_amount, sp.min_balance, sp.gl_control_id
     FROM savings_account sa JOIN savings_product sp ON sp.id = sa.product_id WHERE sa.id = ?`,
    savingsAccountId,
  );
  if (!acct) throw new AppError('Savings account not found', 'NOT_FOUND');
  return acct;
}

const available = (acct: AccountFigures): Cents =>
  Math.max(acct.balance - acct.hold_amount - acct.min_balance, 0);

function assertMandatory(input: BankersChequeInput): void {
  if (!input.chequeTypeId) throw new AppError('A cheque type is required', 'VALIDATION');
  if (!input.memberId) throw new AppError('A member is required', 'VALIDATION');
  if (!input.savingsAccountId) throw new AppError('An account is required', 'VALIDATION');
  if (!input.postingDate) throw new AppError('A posting date is required', 'VALIDATION');
}

/** Shared by create, update, submit and the final pre-post re-check — re-priced against live
 *  figures each time. Returns the charge snapshot to persist. */
async function assertSellable(
  input: Pick<BankersChequeInput, 'chequeTypeId' | 'memberId' | 'savingsAccountId' | 'amount'>,
): Promise<{ chargeId: number | null; chargeAmount: Cents; netAmount: Cents; maxAmount: Cents; description: string; bookBalance: Cents }> {
  if (!(input.amount > 0)) throw new AppError('Amount must be greater than zero', 'VALIDATION');

  const type = await getChequeType(input.chequeTypeId);
  if (!type) throw new AppError('Cheque type not found', 'NOT_FOUND');
  if (type.status !== 'ACTIVE') throw new AppError('That cheque type is not active', 'VALIDATION');
  if (type.maximum_amount > 0 && input.amount > type.maximum_amount) {
    throw new AppError(`This cheque type caps a banker's cheque at ${(type.maximum_amount / 100).toFixed(2)}`, 'AMOUNT_EXCEEDS_MAX');
  }

  const acct = await accountFigures(input.savingsAccountId);
  if (acct.member_id !== input.memberId) throw new AppError('That account does not belong to this member', 'VALIDATION');
  if (acct.status !== 'ACTIVE') throw new AppError(`The account is ${acct.status} — no cheque can be sold against it`, 'VALIDATION');
  if (!acct.allow_transfer) throw new AppError('This account is not enabled for cash transfer / cheque payment', 'VALIDATION');

  const charge = await resolveChequeCharge(input.chequeTypeId);
  const chargeAmount = charge.amount(input.amount);
  const netAmount = input.amount + chargeAmount;
  const avail = available(acct);
  if (netAmount > avail) {
    throw new AppError(
      `The account only has ${(avail / 100).toFixed(2)} available (cheque + ${(chargeAmount / 100).toFixed(2)} charge = ${(netAmount / 100).toFixed(2)})`,
      'AMOUNT_EXCEEDS_AVAILABLE',
    );
  }
  return {
    chargeId: charge.id, chargeAmount, netAmount,
    maxAmount: type.maximum_amount, description: type.description, bookBalance: acct.balance,
  };
}

export async function createBankersCheque(input: BankersChequeInput, user: Actor): Promise<{ no: string }> {
  assertMandatory(input);
  const s = await assertSellable(input);

  const no = await nextSequence('BANKERS_CHEQUE');
  await run(
    `INSERT INTO bankers_cheque
       (no, cheque_type_id, description, max_amount, member_id, savings_account_id, payee_details, cheque_no,
        book_balance, amount, transaction_charge_id, charge_amount, net_amount, posting_date, created_at, created_by)
     VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)`,
    no, input.chequeTypeId, s.description, Math.round(s.maxAmount), input.memberId, input.savingsAccountId,
    input.payeeDetails?.trim() || null, input.chequeNo?.trim() || null, Math.round(s.bookBalance),
    Math.round(input.amount), s.chargeId, Math.round(s.chargeAmount), Math.round(s.netAmount),
    input.postingDate, new Date().toISOString(), user.username,
  );
  await audit(user, 'BANKERS_CHEQUE_CREATE', 'bankers_cheque', no, { amount: input.amount });
  return { no };
}

export async function updateBankersCheque(no: string, input: BankersChequeInput, user: Actor): Promise<BankersChequeView> {
  const before = await one<BankersCheque>('SELECT * FROM bankers_cheque WHERE no = ?', no);
  if (!before) throw new AppError('Banker’s cheque not found', 'NOT_FOUND');
  if (before.status !== 'Open') throw new AppError('Only an open banker’s cheque can be edited', 'VALIDATION');
  if (before.created_by !== user.username) throw new AppError('Only the person who created this can edit it', 'NOT_CREATOR');
  assertMandatory(input);
  const s = await assertSellable(input);

  await run(
    `UPDATE bankers_cheque
     SET cheque_type_id = ?, description = ?, max_amount = ?, member_id = ?, savings_account_id = ?,
         payee_details = ?, cheque_no = ?, book_balance = ?, amount = ?, transaction_charge_id = ?,
         charge_amount = ?, net_amount = ?, posting_date = ?
     WHERE no = ?`,
    input.chequeTypeId, s.description, Math.round(s.maxAmount), input.memberId, input.savingsAccountId,
    input.payeeDetails?.trim() || null, input.chequeNo?.trim() || null, Math.round(s.bookBalance),
    Math.round(input.amount), s.chargeId, Math.round(s.chargeAmount), Math.round(s.netAmount),
    input.postingDate, no,
  );
  await audit(user, 'BANKERS_CHEQUE_UPDATE', 'bankers_cheque', no, {});
  return (await getBankersCheque(no))!;
}

export async function deleteBankersCheque(no: string, user: Actor): Promise<void> {
  const before = await one<Pick<BankersCheque, 'status' | 'created_by'>>(
    'SELECT status, created_by FROM bankers_cheque WHERE no = ?', no,
  );
  if (!before) throw new AppError('Banker’s cheque not found', 'NOT_FOUND');
  if (before.status !== 'Open') throw new AppError('Only an open banker’s cheque can be deleted', 'VALIDATION');
  if (before.created_by !== user.username) throw new AppError('Only the person who created this can delete it', 'NOT_CREATOR');
  await run('DELETE FROM bankers_cheque WHERE no = ?', no);
  await audit(user, 'BANKERS_CHEQUE_DELETE', 'bankers_cheque', no, {});
}

/* -------------------------------------------------------------- maker-checker */

export async function submitBankersCheque(no: string, user: Actor): Promise<{ autoApproved: boolean }> {
  const req = await one<BankersCheque>('SELECT * FROM bankers_cheque WHERE no = ?', no);
  if (!req) throw new AppError('Banker’s cheque not found', 'NOT_FOUND');
  if (req.status !== 'Open') throw new AppError('Only an open banker’s cheque can be submitted for approval', 'VALIDATION');
  if (!req.payee_details || !req.payee_details.trim()) throw new AppError('Payee details are required before sending for approval', 'VALIDATION');
  await assertSellable({ chequeTypeId: req.cheque_type_id, memberId: req.member_id, savingsAccountId: req.savings_account_id, amount: req.amount });

  const matched = await findMatchingWorkflow('BANKERS_CHEQUE', await pickConditionFields('BANKERS_CHEQUE', req));
  if (!matched) throw new AppError('There is no enabled workflow for this document', 'NO_WORKFLOW');

  await tx(async () => {
    await run("UPDATE bankers_cheque SET status = 'Pending Approval' WHERE no = ?", no);
    await startWorkflow(matched.workflow, matched.steps, {
      documentType: 'BANKERS_CHEQUE', entityId: no, requestedBy: user.username, amount: Number(req.amount),
    });
  });

  const after = await one<{ status: string }>('SELECT status FROM bankers_cheque WHERE no = ?', no);
  return { autoApproved: after?.status === 'Approved' };
}

export async function cancelBankersChequeApproval(no: string, user: Actor): Promise<void> {
  const req = await one<Pick<BankersCheque, 'status' | 'created_by'>>('SELECT status, created_by FROM bankers_cheque WHERE no = ?', no);
  if (!req) throw new AppError('Banker’s cheque not found', 'NOT_FOUND');
  if (req.status !== 'Pending Approval') throw new AppError('Only a banker’s cheque pending approval can be recalled', 'VALIDATION');
  const routed = await findPendingRoutedTask('BANKERS_CHEQUE', no);
  const requestedBy = routed?.requested_by ?? req.created_by;
  if (requestedBy !== user.username) throw new AppError('Only the person who submitted this can recall it', 'NOT_REQUESTER');
  await run("UPDATE bankers_cheque SET status = 'Open' WHERE no = ?", no);
  await audit(user, 'BANKERS_CHEQUE_CANCEL_APPROVAL', 'bankers_cheque', no, {});
}

export async function approveBankersCheque(no: string, user: Actor): Promise<void> {
  const req = await one<BankersCheque>('SELECT * FROM bankers_cheque WHERE no = ?', no);
  if (!req) throw new AppError('Banker’s cheque not found', 'NOT_FOUND');
  if (req.status !== 'Pending Approval') throw new AppError('Only a banker’s cheque pending approval can be approved', 'VALIDATION');
  await run("UPDATE bankers_cheque SET status = 'Approved', decision_reason = NULL WHERE no = ?", no);
  await audit(user, 'BANKERS_CHEQUE_APPROVE', 'bankers_cheque', no, {});
}

export async function rejectBankersCheque(no: string, reason: string | null, user: Actor): Promise<void> {
  if (!reason || !reason.trim()) throw new AppError('A reason is required to reject a banker’s cheque', 'VALIDATION');
  const req = await one<BankersCheque>('SELECT * FROM bankers_cheque WHERE no = ?', no);
  if (!req) throw new AppError('Banker’s cheque not found', 'NOT_FOUND');
  if (req.status !== 'Pending Approval') throw new AppError('Only a banker’s cheque pending approval can be rejected', 'VALIDATION');
  await run("UPDATE bankers_cheque SET status = 'Open', decision_reason = ? WHERE no = ?", reason, no);
  await audit(user, 'BANKERS_CHEQUE_REJECT', 'bankers_cheque', no, { reason });
}

/** An Approved, not-yet-posted cheque back to Open for amendment (AL's "Re&open"). */
export async function reopenBankersCheque(no: string, user: Actor): Promise<void> {
  const req = await one<BankersCheque>('SELECT * FROM bankers_cheque WHERE no = ?', no);
  if (!req) throw new AppError('Banker’s cheque not found', 'NOT_FOUND');
  if (req.status !== 'Approved' || req.posted) {
    throw new AppError('Only an approved banker’s cheque that has not been posted can be reopened', 'VALIDATION');
  }
  await run("UPDATE bankers_cheque SET status = 'Open' WHERE no = ?", no);
  await audit(user, 'BANKERS_CHEQUE_REOPEN', 'bankers_cheque', no, {});
}

/* ------------------------------------------------------------------- posting */

export async function postBankersCheque(
  no: string, user: Actor,
): Promise<{ journalNo: string; balance: Cents; charged: Cents }> {
  return tx(async () => {
    const req = await one<BankersCheque>('SELECT * FROM bankers_cheque WHERE no = ?', no);
    if (!req) throw new AppError('Banker’s cheque not found', 'NOT_FOUND');
    if (req.posted) throw new AppError('This banker’s cheque has already been posted', 'VALIDATION');
    if (req.status !== 'Approved') throw new AppError('Only an approved banker’s cheque can be posted', 'VALIDATION');
    if (!req.payee_details || !req.payee_details.trim()) throw new AppError('Payee details are required', 'VALIDATION');
    await assertMemberNotDormant(req.member_id, 'a banker’s cheque');
    const s = await assertSellable({ chequeTypeId: req.cheque_type_id, memberId: req.member_id, savingsAccountId: req.savings_account_id, amount: req.amount });

    const type = await getChequeType(req.cheque_type_id);
    if (!type) throw new AppError('Cheque type not found', 'NOT_FOUND');

    const acct = await one<{ balance: Cents; gl_control_id: number }>(
      `SELECT sa.balance, sp.gl_control_id
       FROM savings_account sa JOIN savings_product sp ON sp.id = sa.product_id WHERE sa.id = ?`,
      req.savings_account_id,
    );
    if (!acct) throw new AppError('Savings account not found', 'NOT_FOUND');

    const amount = Number(req.amount);
    const vd = await resolvePostingDate(user);
    const memberName = await one<{ full: string }>(
      "SELECT first_name || ' ' || last_name AS full FROM member WHERE id = ?", req.member_id,
    );
    const narration = `Banker's cheque ${req.no}${req.cheque_no ? ` (${req.cheque_no})` : ''} — ${req.payee_details}`.slice(0, 250);

    // Main journal: debit the member's deposit control, credit the cheque type's clearing account.
    const j = await postJournal({
      valueDate: vd, module: 'SAVINGS', eventType: 'BANKERS_CHEQUE',
      description: narration, reference: no, memberId: req.member_id, user,
      idempotencyKey: `BANKERS_CHEQUE-${no}`,
      lines: [
        { account: acct.gl_control_id, debit: amount, credit: 0, narration },
        { account: type.clearing_gl_account_id, debit: 0, credit: amount, narration },
      ],
    });

    let balance = acct.balance - amount;
    await run('UPDATE savings_account SET balance = ?, last_activity = ?, version = version + 1 WHERE id = ?', balance, vd, req.savings_account_id);
    await run(
      `INSERT INTO txn (txn_ref, value_date, created_at, module, txn_type, member_id, savings_account_id,
         amount, running_balance, channel, description, journal_id, created_by)
       VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?)`,
      await nextSequence('TXN'), vd, new Date().toISOString(), 'SAVINGS', 'WITHDRAWAL', req.member_id,
      req.savings_account_id, -amount, balance, 'BANKERS_CHEQUE',
      `Banker's cheque ${no} — ${memberName?.full ?? ''}`.trim(), j.id, user.username,
    );

    // Clearing charge — debited from the member's account (AL AddCharges against "Account Type").
    let charged = 0;
    if (s.chargeId && s.chargeAmount > 0) {
      const posted = await postTransactionCharges({
        transactionChargeId: s.chargeId, baseAmount: amount, debitAccountCode: acct.gl_control_id,
        valueDate: vd, module: 'SAVINGS', eventType: 'BANKERS_CHEQUE_CHARGE', memberId: req.member_id,
        description: `Banker's cheque charge — ${no}`, reference: no, user,
        idempotencyKey: `BANKERS_CHEQUE-CHG-${no}`,
      });
      if (posted) {
        charged = posted.charges.reduce((sum, c) => sum + c.amount, 0);
        balance -= charged;
        await run('UPDATE savings_account SET balance = ?, last_activity = ? WHERE id = ?', balance, vd, req.savings_account_id);
        await run(
          `INSERT INTO txn (txn_ref, value_date, created_at, module, txn_type, member_id, savings_account_id,
             amount, running_balance, channel, description, journal_id, created_by)
           VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?)`,
          await nextSequence('TXN'), vd, new Date().toISOString(), 'SAVINGS', 'FEE', req.member_id,
          req.savings_account_id, -charged, balance, 'BANKERS_CHEQUE',
          `Banker's cheque charge — ${no}`, posted.journal.id, user.username,
        );
      }
    }

    await run(
      `UPDATE bankers_cheque SET status = 'Processed', posted = true, charge_amount = ?, net_amount = ?,
         journal_id = ?, posted_at = ?, posted_by = ? WHERE no = ?`,
      charged, amount + charged, j.id, new Date().toISOString(), user.username, no,
    );
    await audit(user, 'BANKERS_CHEQUE_POST', 'bankers_cheque', no, { journalNo: j.journal_no, amount, charged });
    return { journalNo: j.journal_no, balance, charged };
  });
}

export const listBankersChequeHistory = (
  no: string,
): Promise<{ journal_no: string; value_date: IsoDate; description: string | null; amount: Cents }[]> =>
  all(
    'SELECT journal_no, value_date, description, amount FROM journal WHERE reference = ? ORDER BY value_date DESC, id DESC',
    no,
  );

export async function getBankersChequeJournal(no: string): Promise<JournalDetail | null> {
  const row = await one<{ journal_id: number | null }>('SELECT journal_id FROM bankers_cheque WHERE no = ?', no);
  if (!row?.journal_id) return null;
  return getJournal(row.journal_id);
}

/* --------------------------------------------------- Rep52204097 schedule */

export interface BankersChequeScheduleOptions {
  from?: IsoDate;
  to?: IsoDate;
  no?: string;
}

/** AL Rep52204097 "Bankers Cheque Schedule" dataset — posted cheques only, filtered by posting
 *  date range and/or document No. */
export async function bankersChequeSchedule(
  { from, to, no }: BankersChequeScheduleOptions = {},
): Promise<BankersChequeScheduleRow[]> {
  const conds: string[] = ["b.status = 'Processed'", 'b.posted = true'];
  const params: Record<string, unknown> = {};
  if (from) { conds.push('b.posting_date >= @from'); params.from = from; }
  if (to) { conds.push('b.posting_date <= @to'); params.to = to; }
  if (no) { conds.push('b.no LIKE @no'); params.no = `%${no}%`; }
  return all<BankersChequeScheduleRow>(
    `SELECT b.no, b.posting_date, b.cheque_no,
            (m.first_name || ' ' || m.last_name) AS account_name, sa.account_no,
            b.payee_details, b.amount, b.charge_amount, b.net_amount
     FROM bankers_cheque b
     JOIN member m ON m.id = b.member_id
     JOIN savings_account sa ON sa.id = b.savings_account_id
     WHERE ${conds.join(' AND ')}
     ORDER BY b.posting_date, b.no`,
    params,
  );
}
