/*
 * Inter Account Transfer — AL Tab52204093 / Pag52204163-4 / Cod52204019.PostInterAccountTransfer.
 *
 * A maker-checker instruction to move cash from one member deposit account to another: the same
 * member's other account, or — when the creator holds INTER_ACCOUNT_TRANSFERS_CROSS_MEMBER — a
 * different member's account. Only products flagged `savings_product.allow_transfer` (AL's Vendor
 * "Cash Transfer Allowed") may be the SOURCE of a transfer.
 *
 * Lifecycle: Open -> Pending Approval -> Approved -> Processed, plus Reopen (Approved & not posted
 * -> Open) — the same shape as lib/liens.ts / lib/tellerTransactions.ts.
 *
 * Posting (Cod52204019.PostInterAccountTransfer):
 *   - debit  the source account's deposit control G/L, credit the destination's — `amount`
 *   - move both savings balances and write a `txn` row for each (WITHDRAWAL / DEPOSIT)
 *   - deduct a configurable transfer charge (organisation.inter_account_transfer_charge_id, else
 *     the one Transaction Charge configured for type 'Acc. Transfer') from the SOURCE account
 *
 * Amount Type (AL Tab52204093 field 14):
 *   - PARTIAL: amount + charge <= balance - hold_amount - min_balance
 *   - FULL:    amount + charge <= balance - hold_amount   (may drain the source to its floor)
 */
import {
  one, all, run, tx, nextSequence, audit, hasAnyRow,
} from './db.ts';
import { AppError } from './errors.ts';
import { postJournal } from './accounting.ts';
import { getJournal, type JournalDetail } from './gl.ts';
import { getOrg } from './org.ts';
import {
  getTransactionCharge, getTransactionChargeByType, calculateTransactionCharges, postTransactionCharges,
} from './charges.ts';
import { resolvePostingDate } from './postingDates.ts';
import { assertMemberNotDormant } from './memberDormancy.ts';
import { findMatchingWorkflow, findPendingRoutedTask, pickConditionFields, startWorkflow } from './workflow.ts';
import { buildFilterClause, type FilterCondition, type FilterFieldDef } from './listFilters.ts';
import { buildOrderClause, type SortState } from './listSort.ts';
import type {
  Actor, Cents, IsoDate, InterAccountTransfer, InterAccountTransferAmountType, InterAccountTransferView,
} from './types.ts';

export type TransferView = 'open' | 'pending' | 'approved' | 'processed';

const VIEW_CLAUSE: Record<TransferView, string> = {
  open: "t.status = 'Open'",
  pending: "t.status = 'Pending Approval'",
  approved: "t.status = 'Approved'",
  processed: "t.status = 'Processed'",
};

/** balance - hold - min_balance for PARTIAL; balance - hold for FULL. Clamped >= 0. */
const availableExpr = (amountType: string) =>
  amountType === 'FULL'
    ? 'GREATEST(sa.balance - sa.hold_amount, 0)'
    : 'GREATEST(sa.balance - sa.hold_amount - sp.min_balance, 0)';

const SELECT_ROW = `
  SELECT t.*,
         sm.member_no AS source_member_no, sm.first_name AS source_first_name, sm.last_name AS source_last_name,
         dm.member_no AS destination_member_no, dm.first_name AS destination_first_name, dm.last_name AS destination_last_name,
         ssa.account_no AS source_account_no, ssp.name AS source_product_name,
         ssa.balance AS source_balance, ssa.hold_amount AS source_hold_amount, ssp.min_balance AS source_min_balance,
         dsa.account_no AS destination_account_no, dsp.name AS destination_product_name,
         dsa.balance AS destination_balance,
         tc.code AS transaction_charge_code,
         j.journal_no AS journal_no,
         GREATEST(ssa.balance - ssa.hold_amount - CASE WHEN t.amount_type = 'FULL' THEN 0 ELSE ssp.min_balance END, 0) AS source_available
  FROM inter_account_transfer t
  JOIN member sm ON sm.id = t.source_member_id
  JOIN member dm ON dm.id = t.destination_member_id
  JOIN savings_account ssa ON ssa.id = t.source_account_id
  JOIN savings_product ssp ON ssp.id = ssa.product_id
  JOIN savings_account dsa ON dsa.id = t.destination_account_id
  JOIN savings_product dsp ON dsp.id = dsa.product_id
  LEFT JOIN transaction_charge tc ON tc.id = t.transaction_charge_id
  LEFT JOIN journal j ON j.id = t.journal_id`;

export const TRANSFER_FILTER_FIELDS: FilterFieldDef[] = [
  { key: 'no', label: 'No.', type: 'text', column: 't.no' },
  { key: 'source_member_id', label: 'Source Member', type: 'select', column: 't.source_member_id' },
  { key: 'destination_member_id', label: 'Destination Member', type: 'select', column: 't.destination_member_id' },
  {
    key: 'amount_type', label: 'Amount Type', type: 'select', column: 't.amount_type',
    options: [{ value: 'PARTIAL', label: 'Partial' }, { value: 'FULL', label: 'Full' }],
  },
  { key: 'posting_date', label: 'Posting Date', type: 'date', column: 't.posting_date' },
  { key: 'created_by', label: 'Created By', type: 'text', column: 't.created_by' },
  { key: 'created_at', label: 'Created', type: 'date', column: 't.created_at', datetime: true },
];

const SORT_COLUMNS: Record<string, string> = {
  no: 't.no',
  source: 'sm.first_name',
  destination: 'dm.first_name',
  amount: 't.amount',
  status: 't.status',
  posting_date: 't.posting_date',
  created_at: 't.created_at',
};

export interface ListTransfersOptions {
  view?: TransferView;
  search?: string;
  filters?: FilterCondition[];
  sort?: SortState | null;
}

export const listInterAccountTransfers = (
  { view, search = '', filters = [], sort = null }: ListTransfersOptions = {},
): Promise<InterAccountTransferView[]> => {
  const { clause, params } = buildFilterClause(TRANSFER_FILTER_FIELDS, filters);
  const orderBy = buildOrderClause(SORT_COLUMNS, sort, 't.no DESC');
  return all<InterAccountTransferView>(
    `${SELECT_ROW}
     WHERE (t.no LIKE @like OR sm.member_no LIKE @like OR sm.first_name LIKE @like OR sm.last_name LIKE @like
        OR dm.member_no LIKE @like OR dm.first_name LIKE @like OR dm.last_name LIKE @like
        OR ssa.account_no LIKE @like OR dsa.account_no LIKE @like)
       ${view ? `AND ${VIEW_CLAUSE[view]}` : ''}
       ${clause}
     ${orderBy}`,
    { like: `%${String(search).trim()}%`, ...params },
  );
};

export const getInterAccountTransfer = (no: string): Promise<InterAccountTransferView | undefined> =>
  one<InterAccountTransferView>(`${SELECT_ROW} WHERE t.no = ?`, no);

export const hasAnyInterAccountTransfers = (view?: TransferView): Promise<boolean> =>
  hasAnyRow('inter_account_transfer t', view ? VIEW_CLAUSE[view] : undefined);

export async function getAdjacentTransferNos(
  no: string, view?: TransferView,
): Promise<{ prevNo: string | null; nextNo: string | null }> {
  const clause = view ? `AND ${VIEW_CLAUSE[view]}` : '';
  const [prev, next] = await Promise.all([
    one<{ no: string }>(`SELECT t.no FROM inter_account_transfer t WHERE t.no < ? ${clause} ORDER BY t.no DESC LIMIT 1`, no),
    one<{ no: string }>(`SELECT t.no FROM inter_account_transfer t WHERE t.no > ? ${clause} ORDER BY t.no ASC LIMIT 1`, no),
  ]);
  return { prevNo: prev?.no ?? null, nextNo: next?.no ?? null };
}

/* -------------------------------------------------------------- account pickers */

export interface TransferAccount {
  id: number; account_no: string; product_name: string;
  balance: Cents; hold_amount: Cents; min_balance: Cents;
}

/** AL Tab52204093's "Transfer From" lookup — the member's active accounts on a product that
 *  permits funds transfer (`allow_transfer`). This is the only accounts a transfer can debit. */
export const transferSourceAccountsForMember = (memberId: number): Promise<TransferAccount[]> =>
  all<TransferAccount>(
    `SELECT sa.id, sa.account_no, sp.name AS product_name, sa.balance, sa.hold_amount, sp.min_balance
     FROM savings_account sa JOIN savings_product sp ON sp.id = sa.product_id
     WHERE sa.member_id = ? AND sa.status = 'ACTIVE' AND sp.allow_transfer = 1
     ORDER BY sa.account_no`,
    memberId,
  );

/** AL Tab52204093's "Destination Account" lookup — every active account the destination member
 *  holds (a transfer can credit any deposit/share account), excluding the source account itself. */
export const transferDestinationAccountsForMember = (
  memberId: number, excludeAccountId?: number,
): Promise<TransferAccount[]> =>
  all<TransferAccount>(
    `SELECT sa.id, sa.account_no, sp.name AS product_name, sa.balance, sa.hold_amount, sp.min_balance
     FROM savings_account sa JOIN savings_product sp ON sp.id = sa.product_id
     WHERE sa.member_id = ? AND sa.status = 'ACTIVE' AND sa.id <> ?
     ORDER BY sa.account_no`,
    memberId, excludeAccountId ?? 0,
  );

/* ------------------------------------------------------------------- charge */

/** The Transaction Charge that applies to inter-account transfers — the one configured in Admin
 *  Setup (organisation.inter_account_transfer_charge_id), else the single ACTIVE charge for type
 *  'Acc. Transfer', else none. */
async function resolveTransferCharge(): Promise<{ id: number | null; amount: (base: Cents) => Promise<Cents> }> {
  const org = await getOrg();
  const detail = org?.inter_account_transfer_charge_id
    ? await getTransactionCharge(org.inter_account_transfer_charge_id)
    : await getTransactionChargeByType('Acc. Transfer');
  if (!detail) return { id: null, amount: async () => 0 };
  return {
    id: detail.id,
    amount: async (base: Cents) => calculateTransactionCharges(detail, base).reduce((s, c) => s + c.amount, 0),
  };
}

/** Inquiry-only — the fee a transfer of `amount` would attract. */
export async function previewInterAccountTransferCharge(amount: Cents): Promise<Cents> {
  if (!(amount > 0)) return 0;
  const charge = await resolveTransferCharge();
  return charge.amount(amount);
}

/* ------------------------------------------------------------ create / edit */

export interface TransferInput {
  sourceMemberId: number;
  sourceAccountId: number;
  destinationMemberId: number;
  destinationAccountId: number;
  amountType: InterAccountTransferAmountType;
  amount: Cents;
  postingDate: IsoDate;
  narration?: string | null;
}

interface AccountFigures {
  member_id: number;
  status: string;
  allow_transfer: number;
  balance: Cents;
  hold_amount: Cents;
  min_balance: Cents;
}

async function accountFigures(savingsAccountId: number): Promise<AccountFigures> {
  const acct = await one<AccountFigures>(
    `SELECT sa.member_id, sa.status, sp.allow_transfer, sa.balance, sa.hold_amount, sp.min_balance
     FROM savings_account sa JOIN savings_product sp ON sp.id = sa.product_id WHERE sa.id = ?`,
    savingsAccountId,
  );
  if (!acct) throw new AppError('Savings account not found', 'NOT_FOUND');
  return acct;
}

const sourceAvailable = (acct: AccountFigures, amountType: string): Cents =>
  Math.max(acct.balance - acct.hold_amount - (amountType === 'FULL' ? 0 : acct.min_balance), 0);

function assertMandatory(input: TransferInput): void {
  if (!input.sourceMemberId) throw new AppError('A source member is required', 'VALIDATION');
  if (!input.sourceAccountId) throw new AppError('A source account is required', 'VALIDATION');
  if (!input.destinationMemberId) throw new AppError('A destination member is required', 'VALIDATION');
  if (!input.destinationAccountId) throw new AppError('A destination account is required', 'VALIDATION');
  if (input.sourceAccountId === input.destinationAccountId) {
    throw new AppError('The source and destination account cannot be the same', 'VALIDATION');
  }
  if (!['PARTIAL', 'FULL'].includes(input.amountType)) throw new AppError('Invalid amount type', 'VALIDATION');
  if (!input.postingDate) throw new AppError('A posting date is required', 'VALIDATION');
}

/** Shared by create, update, submit and the final pre-post re-check — figures move between each
 *  moment, so eligibility and the limit are always re-evaluated against live data. */
async function assertTransferable(
  input: Pick<TransferInput, 'sourceMemberId' | 'sourceAccountId' | 'destinationMemberId' | 'destinationAccountId' | 'amountType' | 'amount'>,
): Promise<{ chargeAmount: Cents; chargeId: number | null }> {
  if (!(input.amount > 0)) throw new AppError('Amount must be greater than zero', 'VALIDATION');

  const source = await accountFigures(input.sourceAccountId);
  if (source.member_id !== input.sourceMemberId) throw new AppError('The source account does not belong to the source member', 'VALIDATION');
  if (source.status !== 'ACTIVE') throw new AppError(`The source account is ${source.status} — no transfer can be made`, 'VALIDATION');
  if (!source.allow_transfer) throw new AppError('This account is not enabled for cash transfer', 'VALIDATION');

  const dest = await accountFigures(input.destinationAccountId);
  if (dest.member_id !== input.destinationMemberId) throw new AppError('The destination account does not belong to the destination member', 'VALIDATION');
  if (dest.status !== 'ACTIVE') throw new AppError(`The destination account is ${dest.status} — it cannot receive a transfer`, 'VALIDATION');

  const charge = await resolveTransferCharge();
  const chargeAmount = await charge.amount(input.amount);
  const available = sourceAvailable(source, input.amountType);
  if (input.amount + chargeAmount > available) {
    throw new AppError(
      `The source account only has ${(available / 100).toFixed(2)} available (transfer + ${(chargeAmount / 100).toFixed(2)} charge)`,
      'AMOUNT_EXCEEDS_AVAILABLE',
    );
  }
  return { chargeAmount, chargeId: charge.id };
}

export async function createInterAccountTransfer(input: TransferInput, user: Actor): Promise<{ no: string }> {
  assertMandatory(input);
  const { chargeAmount, chargeId } = await assertTransferable(input);

  const no = await nextSequence('INTER_ACCOUNT_TRANSFER');
  await run(
    `INSERT INTO inter_account_transfer
       (no, source_member_id, source_account_id, destination_member_id, destination_account_id,
        amount_type, amount, transaction_charge_id, charge_amount, narration, posting_date, created_at, created_by)
     VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?)`,
    no, input.sourceMemberId, input.sourceAccountId, input.destinationMemberId, input.destinationAccountId,
    input.amountType, Math.round(input.amount), chargeId, Math.round(chargeAmount),
    input.narration?.trim() || null, input.postingDate, new Date().toISOString(), user.username,
  );
  await audit(user, 'INTER_ACCOUNT_TRANSFER_CREATE', 'inter_account_transfer', no, { amount: input.amount });
  return { no };
}

export async function updateInterAccountTransfer(no: string, input: TransferInput, user: Actor): Promise<InterAccountTransferView> {
  const before = await one<InterAccountTransfer>('SELECT * FROM inter_account_transfer WHERE no = ?', no);
  if (!before) throw new AppError('Transfer not found', 'NOT_FOUND');
  if (before.status !== 'Open') throw new AppError('Only an open transfer can be edited', 'VALIDATION');
  if (before.created_by !== user.username) throw new AppError('Only the person who created this transfer can edit it', 'NOT_CREATOR');
  assertMandatory(input);
  const { chargeAmount, chargeId } = await assertTransferable(input);

  await run(
    `UPDATE inter_account_transfer
     SET source_member_id = ?, source_account_id = ?, destination_member_id = ?, destination_account_id = ?,
         amount_type = ?, amount = ?, transaction_charge_id = ?, charge_amount = ?, narration = ?, posting_date = ?
     WHERE no = ?`,
    input.sourceMemberId, input.sourceAccountId, input.destinationMemberId, input.destinationAccountId,
    input.amountType, Math.round(input.amount), chargeId, Math.round(chargeAmount),
    input.narration?.trim() || null, input.postingDate, no,
  );
  await audit(user, 'INTER_ACCOUNT_TRANSFER_UPDATE', 'inter_account_transfer', no, {});
  return (await getInterAccountTransfer(no))!;
}

export async function deleteInterAccountTransfer(no: string, user: Actor): Promise<void> {
  const before = await one<Pick<InterAccountTransfer, 'status' | 'created_by'>>(
    'SELECT status, created_by FROM inter_account_transfer WHERE no = ?', no,
  );
  if (!before) throw new AppError('Transfer not found', 'NOT_FOUND');
  if (before.status !== 'Open') throw new AppError('Only an open transfer can be deleted', 'VALIDATION');
  if (before.created_by !== user.username) throw new AppError('Only the person who created this transfer can delete it', 'NOT_CREATOR');
  await run('DELETE FROM inter_account_transfer WHERE no = ?', no);
  await audit(user, 'INTER_ACCOUNT_TRANSFER_DELETE', 'inter_account_transfer', no, {});
}

/* -------------------------------------------------------------- maker-checker */

export async function submitInterAccountTransfer(no: string, user: Actor): Promise<{ autoApproved: boolean }> {
  const req = await one<InterAccountTransfer>('SELECT * FROM inter_account_transfer WHERE no = ?', no);
  if (!req) throw new AppError('Transfer not found', 'NOT_FOUND');
  if (req.status !== 'Open') throw new AppError('Only an open transfer can be submitted for approval', 'VALIDATION');
  await assertTransferable({
    sourceMemberId: req.source_member_id, sourceAccountId: req.source_account_id,
    destinationMemberId: req.destination_member_id, destinationAccountId: req.destination_account_id,
    amountType: req.amount_type, amount: req.amount,
  });

  const matched = await findMatchingWorkflow('INTER_ACCOUNT_TRANSFER', await pickConditionFields('INTER_ACCOUNT_TRANSFER', req));
  if (!matched) throw new AppError('There is no enabled workflow for this document', 'NO_WORKFLOW');

  await tx(async () => {
    await run("UPDATE inter_account_transfer SET status = 'Pending Approval' WHERE no = ?", no);
    await startWorkflow(matched.workflow, matched.steps, {
      documentType: 'INTER_ACCOUNT_TRANSFER', entityId: no, requestedBy: user.username, amount: Number(req.amount),
    });
  });

  const after = await one<{ status: string }>('SELECT status FROM inter_account_transfer WHERE no = ?', no);
  return { autoApproved: after?.status === 'Approved' };
}

export async function cancelInterAccountTransferApproval(no: string, user: Actor): Promise<void> {
  const req = await one<Pick<InterAccountTransfer, 'status' | 'created_by'>>(
    'SELECT status, created_by FROM inter_account_transfer WHERE no = ?', no,
  );
  if (!req) throw new AppError('Transfer not found', 'NOT_FOUND');
  if (req.status !== 'Pending Approval') throw new AppError('Only a transfer pending approval can be recalled', 'VALIDATION');
  const routed = await findPendingRoutedTask('INTER_ACCOUNT_TRANSFER', no);
  const requestedBy = routed?.requested_by ?? req.created_by;
  if (requestedBy !== user.username) throw new AppError('Only the person who submitted this transfer can recall it', 'NOT_REQUESTER');
  await run("UPDATE inter_account_transfer SET status = 'Open' WHERE no = ?", no);
  await audit(user, 'INTER_ACCOUNT_TRANSFER_CANCEL_APPROVAL', 'inter_account_transfer', no, {});
}

export async function approveInterAccountTransfer(no: string, user: Actor): Promise<void> {
  const req = await one<InterAccountTransfer>('SELECT * FROM inter_account_transfer WHERE no = ?', no);
  if (!req) throw new AppError('Transfer not found', 'NOT_FOUND');
  if (req.status !== 'Pending Approval') throw new AppError('Only a transfer pending approval can be approved', 'VALIDATION');
  await run("UPDATE inter_account_transfer SET status = 'Approved', decision_reason = NULL WHERE no = ?", no);
  await audit(user, 'INTER_ACCOUNT_TRANSFER_APPROVE', 'inter_account_transfer', no, {});
}

export async function rejectInterAccountTransfer(no: string, reason: string | null, user: Actor): Promise<void> {
  if (!reason || !reason.trim()) throw new AppError('A reason is required to reject a transfer', 'VALIDATION');
  const req = await one<InterAccountTransfer>('SELECT * FROM inter_account_transfer WHERE no = ?', no);
  if (!req) throw new AppError('Transfer not found', 'NOT_FOUND');
  if (req.status !== 'Pending Approval') throw new AppError('Only a transfer pending approval can be rejected', 'VALIDATION');
  await run("UPDATE inter_account_transfer SET status = 'Open', decision_reason = ? WHERE no = ?", reason, no);
  await audit(user, 'INTER_ACCOUNT_TRANSFER_REJECT', 'inter_account_transfer', no, { reason });
}

/** An Approved, not-yet-posted transfer back to Open for amendment (AL's "Re&open"). */
export async function reopenInterAccountTransfer(no: string, user: Actor): Promise<void> {
  const req = await one<InterAccountTransfer>('SELECT * FROM inter_account_transfer WHERE no = ?', no);
  if (!req) throw new AppError('Transfer not found', 'NOT_FOUND');
  if (req.status !== 'Approved' || req.posted) {
    throw new AppError('Only an approved transfer that has not been posted can be reopened', 'VALIDATION');
  }
  await run("UPDATE inter_account_transfer SET status = 'Open' WHERE no = ?", no);
  await audit(user, 'INTER_ACCOUNT_TRANSFER_REOPEN', 'inter_account_transfer', no, {});
}

/* ------------------------------------------------------------------- posting */

export async function postInterAccountTransfer(
  no: string, user: Actor,
): Promise<{ journalNo: string; sourceBalance: Cents; destinationBalance: Cents; charged: Cents }> {
  return tx(async () => {
    const req = await one<InterAccountTransfer>('SELECT * FROM inter_account_transfer WHERE no = ?', no);
    if (!req) throw new AppError('Transfer not found', 'NOT_FOUND');
    if (req.posted) throw new AppError('This transfer has already been posted', 'VALIDATION');
    if (req.status !== 'Approved') throw new AppError('Only an approved transfer can be posted', 'VALIDATION');
    await assertMemberNotDormant(req.source_member_id, 'an inter-account transfer');
    const { chargeAmount, chargeId } = await assertTransferable({
      sourceMemberId: req.source_member_id, sourceAccountId: req.source_account_id,
      destinationMemberId: req.destination_member_id, destinationAccountId: req.destination_account_id,
      amountType: req.amount_type, amount: req.amount,
    });

    const source = await one<{ balance: Cents; account_no: string; gl_control_id: number }>(
      `SELECT sa.balance, sa.account_no, sp.gl_control_id
       FROM savings_account sa JOIN savings_product sp ON sp.id = sa.product_id WHERE sa.id = ?`,
      req.source_account_id,
    );
    const dest = await one<{ balance: Cents; account_no: string; gl_control_id: number }>(
      `SELECT sa.balance, sa.account_no, sp.gl_control_id
       FROM savings_account sa JOIN savings_product sp ON sp.id = sa.product_id WHERE sa.id = ?`,
      req.destination_account_id,
    );
    if (!source || !dest) throw new AppError('Savings account not found', 'NOT_FOUND');

    const amount = Number(req.amount);
    const vd = await resolvePostingDate(user);
    const names = await one<{ src: string; dst: string }>(
      `SELECT (SELECT first_name || ' ' || last_name FROM member WHERE id = ?) AS src,
              (SELECT first_name || ' ' || last_name FROM member WHERE id = ?) AS dst`,
      req.source_member_id, req.destination_member_id,
    );
    const narration = `Inter-account transfer ${req.no}: ${source.account_no} (${names?.src ?? ''}) → ${dest.account_no} (${names?.dst ?? ''})`;

    // Main journal: debit the source deposit control, credit the destination's.
    const j = await postJournal({
      valueDate: vd, module: 'SAVINGS', eventType: 'ACCOUNT_TRANSFER',
      description: narration, reference: no, memberId: req.source_member_id, user,
      idempotencyKey: `INTER_ACCOUNT_TRANSFER-${no}`,
      lines: [
        { account: source.gl_control_id, debit: amount, credit: 0, narration },
        { account: dest.gl_control_id, debit: 0, credit: amount, narration },
      ],
    });

    const newSourceBal = source.balance - amount;
    await run('UPDATE savings_account SET balance = ?, last_activity = ?, version = version + 1 WHERE id = ?', newSourceBal, vd, req.source_account_id);
    await run(
      `INSERT INTO txn (txn_ref, value_date, created_at, module, txn_type, member_id, savings_account_id,
         amount, running_balance, channel, description, journal_id, created_by)
       VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?)`,
      await nextSequence('TXN'), vd, new Date().toISOString(), 'SAVINGS', 'WITHDRAWAL', req.source_member_id,
      req.source_account_id, -amount, newSourceBal, 'TRANSFER', narration, j.id, user.username,
    );

    const newDestBal = dest.balance + amount;
    await run('UPDATE savings_account SET balance = ?, last_activity = ?, version = version + 1 WHERE id = ?', newDestBal, vd, req.destination_account_id);
    await run(
      `INSERT INTO txn (txn_ref, value_date, created_at, module, txn_type, member_id, savings_account_id,
         amount, running_balance, channel, description, journal_id, created_by)
       VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?)`,
      await nextSequence('TXN'), vd, new Date().toISOString(), 'SAVINGS', 'DEPOSIT', req.destination_member_id,
      req.destination_account_id, amount, newDestBal, 'TRANSFER', narration, j.id, user.username,
    );

    // Transfer charge — debited from the source account (AL AddCharges against "Transfer From").
    let charged = 0;
    let sourceBalance = newSourceBal;
    if (chargeId && chargeAmount > 0) {
      const posted = await postTransactionCharges({
        transactionChargeId: chargeId, baseAmount: amount, debitAccountCode: source.gl_control_id,
        valueDate: vd, module: 'SAVINGS', eventType: 'ACCOUNT_TRANSFER_CHARGE', memberId: req.source_member_id,
        description: `Inter-account transfer charge — ${no}`, reference: no, user,
        idempotencyKey: `INTER_ACCOUNT_TRANSFER-CHG-${no}`,
      });
      if (posted) {
        charged = posted.charges.reduce((sum, c) => sum + c.amount, 0);
        sourceBalance -= charged;
        await run('UPDATE savings_account SET balance = ?, last_activity = ? WHERE id = ?', sourceBalance, vd, req.source_account_id);
        await run(
          `INSERT INTO txn (txn_ref, value_date, created_at, module, txn_type, member_id, savings_account_id,
             amount, running_balance, channel, description, journal_id, created_by)
           VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?)`,
          await nextSequence('TXN'), vd, new Date().toISOString(), 'SAVINGS', 'FEE', req.source_member_id,
          req.source_account_id, -charged, sourceBalance, 'TRANSFER',
          `Inter-account transfer charge — ${no}`, posted.journal.id, user.username,
        );
      }
    }

    await run(
      `UPDATE inter_account_transfer SET status = 'Processed', posted = true, charge_amount = ?, journal_id = ?,
         posted_at = ?, posted_by = ? WHERE no = ?`,
      charged, j.id, new Date().toISOString(), user.username, no,
    );
    await audit(user, 'INTER_ACCOUNT_TRANSFER_POST', 'inter_account_transfer', no, {
      journalNo: j.journal_no, amount, charged,
    });
    return { journalNo: j.journal_no, sourceBalance, destinationBalance: newDestBal, charged };
  });
}

export const listInterAccountTransferHistory = (
  no: string,
): Promise<{ journal_no: string; value_date: IsoDate; description: string | null; amount: Cents }[]> =>
  all(
    'SELECT journal_no, value_date, description, amount FROM journal WHERE reference = ? ORDER BY value_date DESC, id DESC',
    no,
  );

export async function getInterAccountTransferJournal(no: string): Promise<JournalDetail | null> {
  const row = await one<{ journal_id: number | null }>('SELECT journal_id FROM inter_account_transfer WHERE no = ?', no);
  if (!row?.journal_id) return null;
  return getJournal(row.journal_id);
}
