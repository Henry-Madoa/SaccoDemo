/*
 * Teller Transactions — AL Tab52204046 / Cod52204019.PostTellerTransaction. An over-the-counter
 * member cash deposit or withdrawal posted against the teller's own till (Teller Setup). It
 * auto-posts when the amount (plus charge) is within the teller's Approval Limit; otherwise it
 * routes through maker-checker approval first, then the teller posts it.
 *
 * Posting debits/credits the till's cash G/L against the member's withdrawable-deposit control
 * G/L through lib/accounting.ts's postJournal() (which also updates the till's reconciliation
 * subledger), moves the savings balance, records a `txn` row (the same shape lib/savings.ts
 * writes), posts a configurable transaction charge, then emails the member a receipt slip.
 */
import {
  one, all, run, tx, nextSequence, audit, hasAnyRow,
} from './db.ts';
import { AppError } from './errors.ts';
import { postJournal } from './accounting.ts';
import { getJournal, type JournalDetail } from './gl.ts';
import { getTransactionChargeByType, calculateTransactionCharges, postTransactionCharges } from './charges.ts';
import { resolvePostingDate } from './postingDates.ts';
import { assertDenominationsBalance, replaceDenominationLines, clearDenominationLines } from './denominations.ts';
import { requireTellerSetup } from './tellerSetup.ts';
import { findMatchingWorkflow, findPendingRoutedTask, pickConditionFields, startWorkflow } from './workflow.ts';
import { buildFilterClause, type FilterCondition, type FilterFieldDef } from './listFilters.ts';
import { buildOrderClause, type SortState } from './listSort.ts';
import { sendMail } from './mailer.ts';
import { buildTellerSlip, renderSlipHtml, slipSubject } from './tellerSlip.ts';
import type {
  Actor, Cents, SavingsAccountForDebit, TellerTransaction, TellerTransactionType, TellerTransactionView, IsoDate,
} from './types.ts';

export type TellerTxnView = 'open' | 'pending' | 'approved' | 'posted';

const VIEW_CLAUSE: Record<TellerTxnView, string> = {
  open: "tt.status = 'Open'",
  pending: "tt.status = 'Pending Approval'",
  approved: "tt.status = 'Approved'",
  posted: "tt.status = 'Processed'",
};

const DEPOSIT_MEMBER_STATUSES = ['ACTIVE', 'DORMANT'];
const WITHDRAWAL_MEMBER_STATUSES = ['ACTIVE', 'DORMANT', 'WITHDRAWN'];

const SELECT_ROW = `
  SELECT tt.*,
         m.member_no, m.first_name AS member_first_name, m.last_name AS member_last_name, m.email AS member_email,
         m.identification_no AS member_identification_no, m.photo AS member_photo,
         m.signature_image AS member_signature_image,
         sa.account_no, sp.name AS account_product_name, sa.balance AS account_balance,
         sa.hold_amount AS account_hold_amount, sp.min_balance AS account_min_balance,
         sp.gl_control_id AS account_gl_control_id,
         b.code AS till_code, b.name AS till_name,
         tc.code AS transaction_charge_code, tc.description AS transaction_charge_description,
         j.journal_no AS journal_no,
         COALESCE((SELECT SUM(cdl.quantity * d.value) FROM cash_denomination_line cdl
                   JOIN denomination d ON d.id = cdl.denomination_id
                   WHERE cdl.document_kind = 'TELLER' AND cdl.document_no = tt.no), 0) AS denomination_total
  FROM teller_transaction tt
  JOIN member m ON m.id = tt.member_id
  JOIN savings_account sa ON sa.id = tt.savings_account_id
  JOIN savings_product sp ON sp.id = sa.product_id
  JOIN bank_account b ON b.id = tt.till_bank_account_id
  LEFT JOIN transaction_charge tc ON tc.id = tt.transaction_charge_id
  LEFT JOIN journal j ON j.id = tt.journal_id`;

export const TELLER_TRANSACTION_FILTER_FIELDS: FilterFieldDef[] = [
  { key: 'no', label: 'No.', type: 'text', column: 'tt.no' },
  {
    key: 'transaction_type', label: 'Type', type: 'select', column: 'tt.transaction_type',
    options: [{ value: 'CASH_DEPOSIT', label: 'Cash Deposit' }, { value: 'CASH_WITHDRAWAL', label: 'Cash Withdrawal' }],
  },
  { key: 'member_id', label: 'Member', type: 'select', column: 'm.id' },
  { key: 'created_by', label: 'Created By', type: 'text', column: 'tt.created_by' },
  { key: 'created_at', label: 'Created', type: 'date', column: 'tt.created_at', datetime: true },
];

const SORT_COLUMNS: Record<string, string> = {
  no: 'tt.no',
  member: 'm.first_name',
  amount: 'tt.amount',
  status: 'tt.status',
  created_at: 'tt.created_at',
};

export interface ListTellerTransactionsOptions {
  view?: TellerTxnView;
  search?: string;
  filters?: FilterCondition[];
  sort?: SortState | null;
}

export const listTellerTransactions = (
  { view, search = '', filters = [], sort = null }: ListTellerTransactionsOptions = {},
): Promise<TellerTransactionView[]> => {
  const { clause, params } = buildFilterClause(TELLER_TRANSACTION_FILTER_FIELDS, filters);
  const orderBy = buildOrderClause(SORT_COLUMNS, sort, 'tt.no DESC');
  return all<TellerTransactionView>(
    `${SELECT_ROW}
     WHERE (tt.no LIKE @like OR m.member_no LIKE @like OR m.first_name LIKE @like OR m.last_name LIKE @like
        OR sa.account_no LIKE @like)
       ${view ? `AND ${VIEW_CLAUSE[view]}` : ''}
       ${clause}
     ${orderBy}`,
    { like: `%${String(search).trim()}%`, ...params },
  );
};

export const getTellerTransaction = (no: string): Promise<TellerTransactionView | undefined> =>
  one<TellerTransactionView>(`${SELECT_ROW} WHERE tt.no = ?`, no);

export const hasAnyTellerTransactions = (view?: TellerTxnView): Promise<boolean> =>
  hasAnyRow('teller_transaction tt', view ? VIEW_CLAUSE[view] : undefined);

export async function getAdjacentTellerTransactionNos(
  no: string, view?: TellerTxnView,
): Promise<{ prevNo: string | null; nextNo: string | null }> {
  const clause = view ? `AND ${VIEW_CLAUSE[view]}` : '';
  const [prev, next] = await Promise.all([
    one<{ no: string }>(`SELECT tt.no FROM teller_transaction tt WHERE tt.no < ? ${clause} ORDER BY tt.no DESC LIMIT 1`, no),
    one<{ no: string }>(`SELECT tt.no FROM teller_transaction tt WHERE tt.no > ? ${clause} ORDER BY tt.no ASC LIMIT 1`, no),
  ]);
  return { prevNo: prev?.no ?? null, nextNo: next?.no ?? null };
}

/** The member's active accounts a teller may transact against. A withdrawal is limited to
 *  withdrawal-enabled products; a deposit may target any active account (shares, BOSA deposits). */
export const eligibleAccountsForMember = (
  memberId: number, transactionType: TellerTransactionType = 'CASH_WITHDRAWAL',
): Promise<SavingsAccountForDebit[]> =>
  all<SavingsAccountForDebit>(
    `SELECT sa.id, sa.account_no, sa.status, sa.balance, sa.hold_amount, p.name AS product_name,
            p.min_balance, p.gl_control_id
     FROM savings_account sa JOIN savings_product p ON p.id = sa.product_id
     WHERE sa.member_id = ? AND sa.status = 'ACTIVE'
       ${transactionType === 'CASH_DEPOSIT' ? '' : 'AND p.allow_withdrawal = 1'}
     ORDER BY sa.account_no`,
    memberId,
  );

/* ------------------------------------------------------------ resolve + validate */

export interface TellerTransactionInput {
  transactionType: TellerTransactionType;
  memberId: number;
  savingsAccountId: number;
  amount: Cents;
  sourceOfFunds?: string | null;
  transactedByName?: string | null;
  transactedByIdNo?: string | null;
}

interface Resolved {
  chargeId: number | null;
  chargeAmount: Cents;
  availableBalance: Cents;
  bookBalance: Cents;
  approvalRequired: boolean;
  tillBankAccountId: number;
  approvalLimit: Cents;
}

async function resolveAndValidate(input: TellerTransactionInput, user: Actor): Promise<Resolved> {
  if (!(input.amount > 0)) throw new AppError('Amount must be greater than zero', 'VALIDATION');

  const member = await one<{ id: number; status: string }>('SELECT id, status FROM member WHERE id = ?', input.memberId);
  if (!member) throw new AppError('Member not found', 'NOT_FOUND');
  const allowed = input.transactionType === 'CASH_DEPOSIT' ? DEPOSIT_MEMBER_STATUSES : WITHDRAWAL_MEMBER_STATUSES;
  if (!allowed.includes(member.status)) {
    throw new AppError(`A ${member.status.toLowerCase()} member cannot ${input.transactionType === 'CASH_DEPOSIT' ? 'deposit' : 'withdraw'} at the counter`, 'VALIDATION');
  }

  const account = await one<{ member_id: number; status: string; balance: Cents; hold_amount: Cents; min_balance: Cents; allow_withdrawal: number }>(
    `SELECT sa.member_id, sa.status, sa.balance, sa.hold_amount, sp.min_balance, sp.allow_withdrawal
     FROM savings_account sa JOIN savings_product sp ON sp.id = sa.product_id WHERE sa.id = ?`,
    input.savingsAccountId,
  );
  if (!account) throw new AppError('Savings account not found', 'NOT_FOUND');
  if (account.member_id !== input.memberId) throw new AppError('That account does not belong to this member', 'VALIDATION');
  if (account.status !== 'ACTIVE') throw new AppError(`The account is ${account.status} — no counter transaction is possible`, 'VALIDATION');
  if (!account.allow_withdrawal && input.transactionType === 'CASH_WITHDRAWAL') {
    throw new AppError('This product does not permit withdrawals', 'VALIDATION');
  }
  if (input.transactionType === 'CASH_DEPOSIT' && !input.sourceOfFunds?.trim()) {
    throw new AppError('Source of funds is required for a cash deposit', 'VALIDATION');
  }

  const till = await requireTellerSetup(user.username);

  // Charge Code auto-resolved from the transaction type (AL SaccoSetup."Cash * Charges").
  const chargeType = input.transactionType === 'CASH_DEPOSIT' ? 'Cash Deposit' : 'Cash Withdrawal';
  const chargeDetail = await getTransactionChargeByType(chargeType);
  const chargeAmount = chargeDetail
    ? calculateTransactionCharges(chargeDetail, input.amount).reduce((sum, c) => sum + c.amount, 0)
    : 0;

  const bookBalance = account.balance;
  const availableBalance = Math.max(account.balance - account.hold_amount - account.min_balance - chargeAmount, 0);

  if (input.transactionType === 'CASH_WITHDRAWAL') {
    const spendable = account.balance - account.hold_amount - account.min_balance;
    if (input.amount + chargeAmount > spendable) {
      throw new AppError(
        `Insufficient available balance. Available ${(Math.max(spendable, 0) / 100).toFixed(2)}, requested ${((input.amount + chargeAmount) / 100).toFixed(2)} (incl. charge)`,
        'INSUFFICIENT_FUNDS',
      );
    }
  }

  // AL Tab52204046: approval is required once the amount (incl. charge) exceeds the teller's
  // Approval Limit. An Approval Limit of 0 means "everything needs approval".
  const approvalRequired = input.amount + chargeAmount > till.approval_limit;

  return {
    chargeId: chargeDetail ? chargeDetail.id : null,
    chargeAmount,
    availableBalance,
    bookBalance,
    approvalRequired,
    tillBankAccountId: till.bank_account_id,
    approvalLimit: till.approval_limit,
  };
}

/* ------------------------------------------------------------------- create */

export async function createTellerTransaction(
  input: TellerTransactionInput, user: Actor,
): Promise<{ no: string; approvalRequired: boolean }> {
  const r = await resolveAndValidate(input, user);
  const no = await nextSequence('TELLER_TRANSACTION');
  await run(
    `INSERT INTO teller_transaction
       (no, transaction_type, member_id, savings_account_id, till_bank_account_id, teller_username, amount,
        source_of_funds, transacted_by_name, transacted_by_id_no, transaction_charge_id, charge_amount,
        available_balance, book_balance, approval_required, created_at, created_by)
     VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)`,
    no, input.transactionType, input.memberId, input.savingsAccountId, r.tillBankAccountId, user.username,
    Math.round(input.amount), input.sourceOfFunds?.trim() || null, input.transactedByName?.trim() || null,
    input.transactedByIdNo?.trim() || null, r.chargeId, r.chargeAmount, r.availableBalance, r.bookBalance,
    r.approvalRequired, new Date().toISOString(), user.username,
  );
  await audit(user, 'TELLER_TRANSACTION_CREATE', 'teller_transaction', no, { type: input.transactionType });
  return { no, approvalRequired: r.approvalRequired };
}

export async function updateTellerTransaction(
  no: string, input: TellerTransactionInput, user: Actor,
): Promise<TellerTransactionView> {
  const before = await one<TellerTransaction>('SELECT * FROM teller_transaction WHERE no = ?', no);
  if (!before) throw new AppError('Document not found', 'NOT_FOUND');
  if (before.status !== 'Open') throw new AppError('Only an open document can be edited', 'VALIDATION');
  if (before.created_by !== user.username) throw new AppError('Only the person who created this document can edit it', 'NOT_CREATOR');
  const r = await resolveAndValidate(input, user);
  // Switching direction re-runs every rule (charge type, member-status / product checks, sufficient
  // balance, approval limit) via resolveAndValidate, and a fresh denomination count can be captured
  // on the document afterwards — nothing is posted while it is still Open.
  await run(
    `UPDATE teller_transaction
     SET transaction_type = ?, member_id = ?, savings_account_id = ?, amount = ?, source_of_funds = ?,
         transacted_by_name = ?, transacted_by_id_no = ?, transaction_charge_id = ?, charge_amount = ?,
         available_balance = ?, book_balance = ?, approval_required = ?, till_bank_account_id = ?
     WHERE no = ?`,
    input.transactionType, input.memberId, input.savingsAccountId, Math.round(input.amount),
    input.sourceOfFunds?.trim() || null, input.transactedByName?.trim() || null,
    input.transactedByIdNo?.trim() || null, r.chargeId, r.chargeAmount,
    r.availableBalance, r.bookBalance, r.approvalRequired, r.tillBankAccountId, no,
  );
  await audit(user, 'TELLER_TRANSACTION_UPDATE', 'teller_transaction', no, {});
  return (await getTellerTransaction(no))!;
}

export async function setTellerDenominations(
  no: string, lines: { denominationId: number; quantity: number }[], user: Actor,
): Promise<void> {
  const doc = await one<Pick<TellerTransaction, 'status' | 'created_by'>>(
    'SELECT status, created_by FROM teller_transaction WHERE no = ?', no,
  );
  if (!doc) throw new AppError('Document not found', 'NOT_FOUND');
  if (doc.status !== 'Open') throw new AppError('The denomination breakdown can only be changed while the document is open', 'VALIDATION');
  if (doc.created_by !== user.username) throw new AppError('Only the person who created this document can edit it', 'NOT_CREATOR');
  await replaceDenominationLines('TELLER', no, lines);
}

export async function deleteTellerTransaction(no: string, user: Actor): Promise<void> {
  const before = await one<Pick<TellerTransaction, 'status' | 'created_by'>>(
    'SELECT status, created_by FROM teller_transaction WHERE no = ?', no,
  );
  if (!before) throw new AppError('Document not found', 'NOT_FOUND');
  if (before.status !== 'Open') throw new AppError('Only an open document can be deleted', 'VALIDATION');
  if (before.created_by !== user.username) throw new AppError('Only the person who created this document can delete it', 'NOT_CREATOR');
  await clearDenominationLines('TELLER', no);
  await run('DELETE FROM teller_transaction WHERE no = ?', no);
  await audit(user, 'TELLER_TRANSACTION_DELETE', 'teller_transaction', no, {});
}

/* -------------------------------------------------------------- maker-checker */

export async function submitTellerTransaction(no: string, user: Actor): Promise<{ autoApproved: boolean }> {
  const req = await one<TellerTransaction>('SELECT * FROM teller_transaction WHERE no = ?', no);
  if (!req) throw new AppError('Document not found', 'NOT_FOUND');
  if (req.status !== 'Open') throw new AppError('Only an open document can be submitted for approval', 'VALIDATION');
  if (!req.approval_required) throw new AppError('This transaction is within the approval limit — post it directly instead', 'VALIDATION');
  await assertDenominationsBalance('TELLER', no, req.amount);

  const matched = await findMatchingWorkflow('TELLER_TRANSACTION', await pickConditionFields('TELLER_TRANSACTION', req));
  if (!matched) throw new AppError('There is no enabled workflow for this document', 'NO_WORKFLOW');

  await tx(async () => {
    await run("UPDATE teller_transaction SET status = 'Pending Approval' WHERE no = ?", no);
    await startWorkflow(matched.workflow, matched.steps, {
      documentType: 'TELLER_TRANSACTION', entityId: no, requestedBy: user.username, amount: Number(req.amount),
    });
  });

  const after = await one<{ status: string }>('SELECT status FROM teller_transaction WHERE no = ?', no);
  return { autoApproved: after?.status === 'Approved' };
}

export async function cancelTellerTransactionApproval(no: string, user: Actor): Promise<void> {
  const req = await one<Pick<TellerTransaction, 'status' | 'created_by'>>(
    'SELECT status, created_by FROM teller_transaction WHERE no = ?', no,
  );
  if (!req) throw new AppError('Document not found', 'NOT_FOUND');
  if (req.status !== 'Pending Approval') throw new AppError('Only a document pending approval can be recalled', 'VALIDATION');
  const routed = await findPendingRoutedTask('TELLER_TRANSACTION', no);
  const requestedBy = routed?.requested_by ?? req.created_by;
  if (requestedBy !== user.username) throw new AppError('Only the person who submitted this document can recall it', 'NOT_REQUESTER');
  await run("UPDATE teller_transaction SET status = 'Open' WHERE no = ?", no);
  await audit(user, 'TELLER_TRANSACTION_CANCEL_APPROVAL', 'teller_transaction', no, {});
}

export async function approveTellerTransaction(no: string, user: Actor): Promise<void> {
  const req = await one<TellerTransaction>('SELECT * FROM teller_transaction WHERE no = ?', no);
  if (!req) throw new AppError('Document not found', 'NOT_FOUND');
  if (req.status !== 'Pending Approval') throw new AppError('Only a document pending approval can be approved', 'VALIDATION');
  await run("UPDATE teller_transaction SET status = 'Approved', decision_reason = NULL WHERE no = ?", no);
  await audit(user, 'TELLER_TRANSACTION_APPROVE', 'teller_transaction', no, {});
}

export async function rejectTellerTransaction(no: string, reason: string | null, user: Actor): Promise<void> {
  if (!reason || !reason.trim()) throw new AppError('A reason is required to reject a document', 'VALIDATION');
  const req = await one<TellerTransaction>('SELECT * FROM teller_transaction WHERE no = ?', no);
  if (!req) throw new AppError('Document not found', 'NOT_FOUND');
  if (req.status !== 'Pending Approval') throw new AppError('Only a document pending approval can be rejected', 'VALIDATION');
  await run("UPDATE teller_transaction SET status = 'Open', decision_reason = ? WHERE no = ?", reason, no);
  await audit(user, 'TELLER_TRANSACTION_REJECT', 'teller_transaction', no, { reason });
}

/* ------------------------------------------------------------------- posting */

export async function postTellerTransaction(no: string, user: Actor): Promise<{ journalNo: string; balance: Cents; emailed: boolean }> {
  const result = await tx(async () => {
    const req = await one<TellerTransaction>('SELECT * FROM teller_transaction WHERE no = ?', no);
    if (!req) throw new AppError('Document not found', 'NOT_FOUND');
    if (req.posted) throw new AppError('This transaction has already been posted', 'VALIDATION');
    if (req.approval_required) {
      if (req.status !== 'Approved') throw new AppError('This transaction must be approved before it can be posted', 'VALIDATION');
    } else if (req.status !== 'Open') {
      throw new AppError('Only an open transaction can be posted', 'VALIDATION');
    }
    await assertDenominationsBalance('TELLER', no, req.amount);

    const account = await one<{ balance: Cents; account_no: string; gl_control_id: number; status: string; member_id: number }>(
      `SELECT sa.balance, sa.account_no, sp.gl_control_id, sa.status, sa.member_id
       FROM savings_account sa JOIN savings_product sp ON sp.id = sa.product_id WHERE sa.id = ?`,
      req.savings_account_id,
    );
    if (!account) throw new AppError('Savings account not found', 'NOT_FOUND');
    if (account.status !== 'ACTIVE') throw new AppError(`The account is ${account.status} — posting prohibited`, 'VALIDATION');

    const till = await one<{ gl_account_id: number; name: string }>(
      'SELECT gl_account_id, name FROM bank_account WHERE id = ?', req.till_bank_account_id,
    );
    if (!till) throw new AppError('Till account not found', 'NOT_FOUND');

    const amount = Number(req.amount);
    const isDeposit = req.transaction_type === 'CASH_DEPOSIT';
    const vd = await resolvePostingDate(user);
    const memberName = await one<{ full: string }>(
      "SELECT first_name || ' ' || last_name AS full FROM member WHERE id = ?", req.member_id,
    );
    const narration = `${isDeposit ? 'Cash deposit (OTC)' : 'Cash withdrawal (OTC)'} — ${memberName?.full ?? ''} ${req.transacted_by_id_no ?? ''}`.trim();

    // Main journal: deposit -> debit till cash, credit member deposit control; withdrawal -> the reverse.
    const j = await postJournal({
      valueDate: vd, module: 'SAVINGS', eventType: isDeposit ? 'DEPOSIT' : 'WITHDRAWAL',
      description: narration, reference: no, memberId: req.member_id, user,
      idempotencyKey: `TELLER_TRANSACTION-${no}`,
      lines: isDeposit
        ? [
          { account: till.gl_account_id, debit: amount, credit: 0, narration },
          { account: account.gl_control_id, debit: 0, credit: amount, narration },
        ]
        : [
          { account: account.gl_control_id, debit: amount, credit: 0, narration },
          { account: till.gl_account_id, debit: 0, credit: amount, narration },
        ],
    });

    let balance = isDeposit ? account.balance + amount : account.balance - amount;
    await run('UPDATE savings_account SET balance = ?, last_activity = ?, version = version + 1 WHERE id = ?', balance, vd, req.savings_account_id);
    await run(
      `INSERT INTO txn (txn_ref, value_date, created_at, module, txn_type, member_id, savings_account_id,
         amount, running_balance, channel, description, journal_id, created_by)
       VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?)`,
      await nextSequence('TXN'), vd, new Date().toISOString(), 'SAVINGS', isDeposit ? 'DEPOSIT' : 'WITHDRAWAL',
      req.member_id, req.savings_account_id, isDeposit ? amount : -amount, balance, 'TELLER',
      narration, j.id, user.username,
    );

    // Transaction charge — debited from the member's account, credited to each configured income
    // G/L (AL AddCharges with SelfBalancing = true).
    if (req.transaction_charge_id) {
      const posted = await postTransactionCharges({
        transactionChargeId: req.transaction_charge_id, baseAmount: amount, debitAccountCode: account.gl_control_id,
        valueDate: vd, module: 'SAVINGS', eventType: isDeposit ? 'CASH_DEPOSIT_CHARGE' : 'CASH_WITHDRAWAL_CHARGE',
        memberId: req.member_id, description: `Teller ${isDeposit ? 'deposit' : 'withdrawal'} charge — ${no}`,
        reference: no, user, idempotencyKey: `TELLER_TRANSACTION-CHG-${no}`,
      });
      if (posted) {
        const charged = posted.charges.reduce((sum, c) => sum + c.amount, 0);
        balance -= charged;
        await run('UPDATE savings_account SET balance = ?, last_activity = ? WHERE id = ?', balance, vd, req.savings_account_id);
        await run(
          `INSERT INTO txn (txn_ref, value_date, created_at, module, txn_type, member_id, savings_account_id,
             amount, running_balance, channel, description, journal_id, created_by)
           VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?)`,
          await nextSequence('TXN'), vd, new Date().toISOString(), 'SAVINGS', 'FEE', req.member_id,
          req.savings_account_id, -charged, balance, 'TELLER',
          `Teller ${isDeposit ? 'deposit' : 'withdrawal'} charge — ${no}`, posted.journal.id, user.username,
        );
        await run('UPDATE teller_transaction SET charge_amount = ? WHERE no = ?', charged, no);
      }
    }

    await run(
      `UPDATE teller_transaction SET status = 'Processed', posted = true, journal_id = ?, posted_at = ?, posted_by = ?
       WHERE no = ?`,
      j.id, new Date().toISOString(), user.username, no,
    );
    await audit(user, 'TELLER_TRANSACTION_POST', 'teller_transaction', no, { journalNo: j.journal_no });
    return { journalNo: j.journal_no, balance };
  });

  // Email the member their receipt slip — non-blocking, outside the posting transaction.
  const emailed = await emailSlip(no);
  return { ...result, emailed };
}

/** Sends (or re-sends) the deposit/withdrawal slip to the member's email. Safe to call more
 *  than once. Returns whether an address was on file to send to. */
export async function emailSlip(no: string): Promise<boolean> {
  const slip = await buildTellerSlip(no);
  if (!slip) return false;
  if (!slip.doc.member_email) return false;
  await sendMail({
    to: slip.doc.member_email,
    subject: slipSubject(slip.doc),
    html: renderSlipHtml(slip),
  });
  await run('UPDATE teller_transaction SET slip_emailed_at = ? WHERE no = ?', new Date().toISOString(), no);
  return true;
}

export const listTellerTransactionHistory = (no: string): Promise<{ journal_no: string; value_date: IsoDate; description: string | null; amount: Cents }[]> =>
  all(
    'SELECT journal_no, value_date, description, amount FROM journal WHERE reference = ? ORDER BY value_date DESC, id DESC',
    no,
  );

export async function getTellerTransactionJournal(no: string): Promise<JournalDetail | null> {
  const row = await one<{ journal_id: number | null }>('SELECT journal_id FROM teller_transaction WHERE no = ?', no);
  if (!row?.journal_id) return null;
  return getJournal(row.journal_id);
}
