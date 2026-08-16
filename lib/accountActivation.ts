/*
 * Account Activation — a maker-checker request to reactivate a savings account that is
 * currently INACTIVE (put there by lib/accountDeactivation.ts, or any other route that ever
 * lands an account in that status). Same Open -> Pending Approval -> Approved -> Processed
 * shape as lib/accountDeactivation.ts: the request only actually reactivates the account
 * (flips it back to ACTIVE) once processAccountActivationRequest() runs on an Approved request.
 * Once ACTIVE again, lib/savings.ts's deposit() and withdraw() both accept postings against it.
 */
import {
  one, all, run, tx, nextSequence, hasAnyRow,
} from './db.ts';
import { AppError } from './errors.ts';
import { diffFields, logTableChange } from './changeLog.ts';
import { findMatchingWorkflow, findPendingRoutedTask, pickConditionFields, startWorkflow } from './workflow.ts';
import { postTransactionCharges, previewTransactionChargeById } from './charges.ts';
import { buildFilterClause, type FilterCondition, type FilterFieldDef } from './listFilters.ts';
import { buildOrderClause, type SortState } from './listSort.ts';
import type {
  Actor, AccountActivationRequest, AccountActivationRequestWithDimensions, SavingsAccountForDebit,
  SavingsAccountWithProduct,
} from './types.ts';

const today = () => new Date().toISOString().slice(0, 10);

/** The four nav sub-views — "processed" means the account has actually been reactivated. */
export type AccountActivationView = 'open' | 'pending' | 'approved' | 'processed';

const VIEW_CLAUSE: Record<AccountActivationView, string> = {
  open: "a.status = 'Open'",
  pending: "a.status = 'Pending Approval'",
  approved: "a.status = 'Approved'",
  processed: "a.status = 'Processed'",
};

const SELECT_REQUEST = `
  SELECT a.*, sa.account_no AS account_no, sa.status AS account_status, sa.balance AS account_balance,
         m.id AS member_id, m.member_no AS member_no, m.first_name AS member_first_name, m.last_name AS member_last_name,
         p.code AS savings_product_code, p.name AS savings_product_name,
         tc.code AS transaction_charge_code, tc.description AS transaction_charge_description,
         da.account_no AS debit_account_no, da.balance AS debit_account_balance,
         da.hold_amount AS debit_account_hold_amount, dp.min_balance AS debit_account_min_balance
  FROM account_activation_request a
  JOIN savings_account sa ON sa.id = a.account_id
  JOIN member m ON m.id = sa.member_id
  JOIN savings_product p ON p.id = sa.product_id
  LEFT JOIN transaction_charge tc ON tc.id = a.transaction_charge_id
  LEFT JOIN savings_account da ON da.id = a.debit_account_id
  LEFT JOIN savings_product dp ON dp.id = da.product_id`;

/** Account Activation list's dynamic-filter registry — the view tabs (which remain the
 *  primary Open/Pending/Approved/Processed navigation, so `status` is deliberately left out
 *  here) plus every meaningful column on the request itself. member_id ships without `options`
 *  — the page fills it in from listActiveMembers(), which it already fetches. */
export const ACCOUNT_ACTIVATION_FILTER_FIELDS: FilterFieldDef[] = [
  { key: 'no', label: 'Request No.', type: 'text', column: 'a.no' },
  { key: 'member_id', label: 'Member', type: 'select', column: 'm.id' },
  { key: 'reason', label: 'Reason', type: 'text', column: 'a.reason' },
  { key: 'decision_reason', label: 'Decision Reason', type: 'text', column: 'a.decision_reason' },
  { key: 'created_by', label: 'Created By', type: 'text', column: 'a.created_by' },
  { key: 'created_at', label: 'Created', type: 'date', column: 'a.created_at', datetime: true },
  { key: 'processed_by', label: 'Processed By', type: 'text', column: 'a.processed_by' },
  { key: 'processed_at', label: 'Processed', type: 'date', column: 'a.processed_at', datetime: true },
];

/** Account Activation list's sortable columns — every column shown in the table. */
const ACCOUNT_ACTIVATION_SORT_COLUMNS: Record<string, string> = {
  no: 'a.no',
  account_no: 'sa.account_no',
  member: 'm.first_name',
  status: 'a.status',
};

export interface ListAccountActivationOptions {
  view?: AccountActivationView;
  search?: string;
  filters?: FilterCondition[];
  sort?: SortState | null;
}

export const listAccountActivationRequests = (
  { view, search = '', filters = [], sort = null }: ListAccountActivationOptions = {},
): Promise<AccountActivationRequestWithDimensions[]> => {
  const { clause, params } = buildFilterClause(ACCOUNT_ACTIVATION_FILTER_FIELDS, filters);
  const orderBy = buildOrderClause(ACCOUNT_ACTIVATION_SORT_COLUMNS, sort, 'a.no DESC');
  return all<AccountActivationRequestWithDimensions>(
    `${SELECT_REQUEST}
     WHERE (m.first_name LIKE @like OR m.last_name LIKE @like OR m.member_no LIKE @like
        OR sa.account_no LIKE @like OR a.no LIKE @like)
       ${view ? `AND ${VIEW_CLAUSE[view]}` : ''}
       ${clause}
     ${orderBy}`,
    { like: `%${String(search).trim()}%`, ...params },
  );
};

/** Adds the charge's currently-computed amount to a fetched request — computed live off the
 *  charge configuration rather than stored, so it always reflects the current tariff (and the
 *  debit account's balance can be compared against a figure that's actually still true) instead
 *  of a snapshot that could silently drift from what submitting/processing would enforce. */
async function withChargeAmount(
  req: AccountActivationRequestWithDimensions,
): Promise<AccountActivationRequestWithDimensions> {
  if (!req.transaction_charge_id) return { ...req, charge_amount: null };
  const charges = await previewTransactionChargeById(req.transaction_charge_id, 0);
  return { ...req, charge_amount: charges.reduce((sum, c) => sum + c.amount, 0) };
}

export async function getAccountActivationRequest(no: string): Promise<AccountActivationRequestWithDimensions | undefined> {
  const req = await one<AccountActivationRequestWithDimensions>(`${SELECT_REQUEST} WHERE a.no = ?`, no);
  return req ? withChargeAmount(req) : undefined;
}

/** Whether the current view tab has any requests at all, ignoring search and dynamic filters —
 *  lets the page grey out its filter controls only when there's truly nothing to filter. */
export const hasAnyAccountActivationRequests = (view?: AccountActivationView): Promise<boolean> =>
  hasAnyRow('account_activation_request a', view ? VIEW_CLAUSE[view] : undefined);

/** The request immediately before/after this one by number — for the card's
 *  Business-Central-style Previous/Next navigation. Scoped to the same `view` tab the record
 *  was opened from (when given), so paging never steps outside the list the user came from. */
export async function getAdjacentAccountActivationNos(
  no: string, view?: AccountActivationView,
): Promise<{ prevNo: string | null; nextNo: string | null }> {
  const clause = view ? `AND ${VIEW_CLAUSE[view]}` : '';
  const [prev, next] = await Promise.all([
    one<{ no: string }>(`SELECT a.no FROM account_activation_request a WHERE a.no < ? ${clause} ORDER BY a.no DESC LIMIT 1`, no),
    one<{ no: string }>(`SELECT a.no FROM account_activation_request a WHERE a.no > ? ${clause} ORDER BY a.no ASC LIMIT 1`, no),
  ]);
  return { prevNo: prev?.no ?? null, nextNo: next?.no ?? null };
}

/** Every INACTIVE account this member holds — the only accounts this module could ever have
 *  anything to do with — minus any that already have a not-yet-Processed activation request in
 *  flight (no piling up a second request behind the first). */
export async function eligibleAccountsForMember(memberId: number): Promise<SavingsAccountWithProduct[]> {
  const accounts = await all<SavingsAccountWithProduct>(
    `SELECT sa.*, p.name AS product_name, p.code AS product_code, p.category, p.min_balance, p.allow_withdrawal
     FROM savings_account sa JOIN savings_product p ON p.id = sa.product_id
     WHERE sa.member_id = ? AND sa.status = 'INACTIVE' ORDER BY sa.account_no`,
    memberId,
  );
  if (!accounts.length) return [];

  const accountIds = accounts.map((a) => a.id);
  const inFlight = new Set(
    (await all<{ account_id: number }>(
      `SELECT account_id FROM account_activation_request
       WHERE account_id IN (${accountIds.map(() => '?').join(',')}) AND status != 'Processed'`,
      ...accountIds,
    )).map((r) => r.account_id),
  );

  return accounts.filter((a) => !inFlight.has(a.id));
}

/** Every withdrawable-product savings account this member holds, any status — the picklist for
 *  where a reactivation fee gets debited from. Status is deliberately not restricted to ACTIVE:
 *  the account being reactivated is itself a valid choice, its balance permitting (by the time
 *  the charge actually posts, processAccountActivationRequest() has already flipped it to
 *  ACTIVE). The product must still permit a withdrawal, same rule lib/savings.ts's withdraw()
 *  itself enforces — a charge is a debit like any other. */
export const debitableAccountsForMember = (memberId: number): Promise<SavingsAccountForDebit[]> =>
  all<SavingsAccountForDebit>(
    `SELECT sa.id, sa.account_no, sa.status, sa.balance, sa.hold_amount, p.name AS product_name,
            p.min_balance, p.gl_control_id
     FROM savings_account sa JOIN savings_product p ON p.id = sa.product_id
     WHERE sa.member_id = ? AND p.allow_withdrawal = 1 ORDER BY sa.account_no`,
    memberId,
  );

/** Validates an account is actually eligible for a fresh activation request — the same rules
 *  eligibleAccountsForMember() filters by, checked here too since a request is staged against
 *  one specific account rather than picked off that list. */
async function assertEligible(accountId: number, excludeRequestNo?: string): Promise<SavingsAccountWithProduct> {
  const account = await one<SavingsAccountWithProduct>(
    `SELECT sa.*, p.name AS product_name, p.code AS product_code, p.category, p.min_balance, p.allow_withdrawal
     FROM savings_account sa JOIN savings_product p ON p.id = sa.product_id WHERE sa.id = ?`,
    accountId,
  );
  if (!account) throw new AppError('Savings account not found', 'NOT_FOUND');
  if (account.status !== 'INACTIVE') {
    throw new AppError(`Only an inactive account can be activated (currently ${account.status})`, 'VALIDATION');
  }

  const dupRequest = await one(
    `SELECT 1 FROM account_activation_request
     WHERE account_id = ? AND status != 'Processed' ${excludeRequestNo ? 'AND no != ?' : ''}`,
    ...(excludeRequestNo ? [accountId, excludeRequestNo] : [accountId]),
  );
  if (dupRequest) {
    throw new AppError('An activation request is already in progress for this account', 'VALIDATION');
  }

  return account;
}

/** Checked at every gate a charged request passes through — creation, submit-for-approval and
 *  processing — since either the configured tariff or the debit account's own balance can move
 *  between those moments, and each one has to still hold true right before it lets the request
 *  through. No-ops when no charge code is selected, so a free (unconfigured) activation is
 *  never blocked by this. */
async function assertChargeAffordable(
  transactionChargeId: number | null, debitAccountId: number | null,
): Promise<void> {
  if (!transactionChargeId) return;
  if (!debitAccountId) {
    throw new AppError('A debit account is required when a charge code is selected', 'VALIDATION');
  }
  const acct = await one<{ account_no: string; balance: number; hold_amount: number; min_balance: number; allow_withdrawal: number }>(
    `SELECT sa.account_no, sa.balance, sa.hold_amount, p.min_balance, p.allow_withdrawal
     FROM savings_account sa JOIN savings_product p ON p.id = sa.product_id WHERE sa.id = ?`,
    debitAccountId,
  );
  if (!acct) throw new AppError('Debit account not found', 'NOT_FOUND');
  if (!acct.allow_withdrawal) {
    throw new AppError(`${acct.account_no}'s product does not permit a withdrawal, so it cannot fund this charge`, 'VALIDATION');
  }

  const charges = await previewTransactionChargeById(transactionChargeId, 0);
  const total = charges.reduce((sum, c) => sum + c.amount, 0);
  const available = acct.balance - acct.hold_amount - acct.min_balance;
  if (total > available) {
    throw new AppError(
      `The reactivation charge of ${(total / 100).toFixed(2)} exceeds ${acct.account_no}'s available balance of ${(available / 100).toFixed(2)}`,
      'INSUFFICIENT_FUNDS',
    );
  }
}

export interface CreateAccountActivationInput {
  accountId: number;
  reason: string;
  /** The Charge Code to apply (a transaction_charge configured for ACCOUNT_ACTIVATION) and
   *  which of the member's accounts it's debited from — both optional; leaving them unset
   *  keeps activation free, same as before this existed. */
  transactionChargeId?: number | null;
  debitAccountId?: number | null;
}

export async function createAccountActivationRequest(
  { accountId, reason, transactionChargeId = null, debitAccountId = null }: CreateAccountActivationInput,
  user: Actor,
): Promise<{ no: string }> {
  if (!reason || !reason.trim()) throw new AppError('A reason is required to request activation', 'VALIDATION');
  await assertEligible(accountId);
  await assertChargeAffordable(transactionChargeId, debitAccountId);

  const no = await nextSequence('ACCOUNT_ACTIVATION');
  await run(
    `INSERT INTO account_activation_request
       (no, account_id, reason, transaction_charge_id, debit_account_id, created_at, created_by)
     VALUES (?,?,?,?,?,?,?)`,
    no, accountId, reason.trim(), transactionChargeId, debitAccountId, new Date().toISOString(), user.username,
  );
  await logTableChange(
    'account_activation_request', no, 'Insertion',
    [
      { field: 'account_id', oldValue: null, newValue: accountId },
      { field: 'reason', oldValue: null, newValue: reason.trim() },
      { field: 'transaction_charge_id', oldValue: null, newValue: transactionChargeId },
      { field: 'debit_account_id', oldValue: null, newValue: debitAccountId },
    ],
    user,
  );
  return { no };
}

export interface UpdateAccountActivationInput {
  reason: string;
  transactionChargeId?: number | null;
  debitAccountId?: number | null;
}

export async function updateAccountActivationRequest(
  no: string, { reason, transactionChargeId = null, debitAccountId = null }: UpdateAccountActivationInput, user: Actor,
): Promise<AccountActivationRequestWithDimensions> {
  if (!reason || !reason.trim()) throw new AppError('A reason is required', 'VALIDATION');
  const req = await one<AccountActivationRequest>('SELECT * FROM account_activation_request WHERE no = ?', no);
  if (!req) throw new AppError('Account activation request not found', 'NOT_FOUND');
  if (req.status !== 'Open') throw new AppError('Only an open request can be edited', 'VALIDATION');
  await assertChargeAffordable(transactionChargeId, debitAccountId);

  const patch = { reason: reason.trim(), transaction_charge_id: transactionChargeId, debit_account_id: debitAccountId };
  await run(
    'UPDATE account_activation_request SET reason = ?, transaction_charge_id = ?, debit_account_id = ? WHERE no = ?',
    patch.reason, patch.transaction_charge_id, patch.debit_account_id, no,
  );
  const changes = diffFields(req as unknown as Record<string, unknown>, patch);
  await logTableChange('account_activation_request', no, 'Modification', changes, user);
  return (await getAccountActivationRequest(no))!;
}

/** Sends the request into the matched workflow — `autoApproved` tells the caller whether it
 *  came straight back out the other side already Approved (the requester was the resolved
 *  approver at every step; see lib/workflow.ts's requesterClearsLevel()), so the UI can say so
 *  instead of the generic "sent for approval". */
export async function submitAccountActivationRequest(no: string, user: Actor): Promise<{ autoApproved: boolean }> {
  const req = await one<AccountActivationRequest>('SELECT * FROM account_activation_request WHERE no = ?', no);
  if (!req) throw new AppError('Account activation request not found', 'NOT_FOUND');
  if (req.status !== 'Open') {
    throw new AppError('Only an open request can be submitted for approval', 'VALIDATION');
  }
  await assertEligible(req.account_id, no);
  await assertChargeAffordable(req.transaction_charge_id, req.debit_account_id);

  const matched = await findMatchingWorkflow(
    'ACCOUNT_ACTIVATION', await pickConditionFields('ACCOUNT_ACTIVATION', req),
  );
  if (!matched) {
    throw new AppError('There is no enabled workflow for this document', 'NO_WORKFLOW');
  }

  await tx(async () => {
    await run("UPDATE account_activation_request SET status = 'Pending Approval' WHERE no = ?", no);
    await logTableChange(
      'account_activation_request', no, 'Modification',
      [{ field: 'status', oldValue: req.status, newValue: 'Pending Approval' }], user,
    );
    await startWorkflow(matched.workflow, matched.steps, {
      documentType: 'ACCOUNT_ACTIVATION', entityId: no, requestedBy: user.username, amount: 0,
    });
  });

  const after = await one<{ status: string }>('SELECT status FROM account_activation_request WHERE no = ?', no);
  return { autoApproved: after?.status === 'Approved' };
}

/** Pulls a submission back to Open — same rules as accountDeactivation.ts's cancelAccountDeactivationApproval(). */
export async function cancelAccountActivationApproval(no: string, user: Actor): Promise<void> {
  const req = await one<Pick<AccountActivationRequest, 'status' | 'created_by'>>(
    'SELECT status, created_by FROM account_activation_request WHERE no = ?', no,
  );
  if (!req) throw new AppError('Account activation request not found', 'NOT_FOUND');
  if (req.status !== 'Pending Approval') {
    throw new AppError('Only a request pending approval can have its approval request cancelled', 'VALIDATION');
  }
  const routed = await findPendingRoutedTask('ACCOUNT_ACTIVATION', no);
  const requestedBy = routed?.requested_by ?? req.created_by;
  if (requestedBy !== user.username) {
    throw new AppError('Only the person who submitted this request for approval can cancel it', 'NOT_REQUESTER');
  }
  await run("UPDATE account_activation_request SET status = 'Open' WHERE no = ?", no);
  await logTableChange(
    'account_activation_request', no, 'Modification',
    [{ field: 'status', oldValue: req.status, newValue: 'Open' }], user,
  );
}

export async function approveAccountActivationRequest(no: string, user: Actor): Promise<void> {
  const req = await one<AccountActivationRequest>('SELECT * FROM account_activation_request WHERE no = ?', no);
  if (!req) throw new AppError('Account activation request not found', 'NOT_FOUND');
  if (req.status !== 'Pending Approval') {
    throw new AppError('Only a request pending approval can be approved', 'VALIDATION');
  }
  await run("UPDATE account_activation_request SET status = 'Approved', decision_reason = NULL WHERE no = ?", no);
  const changes = diffFields(
    req as unknown as Record<string, unknown>, { status: 'Approved', decision_reason: null },
  );
  await logTableChange('account_activation_request', no, 'Modification', changes, user);
}

/** Rejection sends the request back to Open, not a terminal state — the requester can amend
 *  and resubmit it, the same shape lib/accountDeactivation.ts's rejectAccountDeactivationRequest() uses. */
export async function rejectAccountActivationRequest(no: string, reason: string | null, user: Actor): Promise<void> {
  if (!reason || !reason.trim()) throw new AppError('A reason is required to reject a request', 'VALIDATION');
  const req = await one<AccountActivationRequest>('SELECT * FROM account_activation_request WHERE no = ?', no);
  if (!req) throw new AppError('Account activation request not found', 'NOT_FOUND');
  if (req.status !== 'Pending Approval') {
    throw new AppError('Only a request pending approval can be rejected', 'VALIDATION');
  }
  await run("UPDATE account_activation_request SET status = 'Open', decision_reason = ? WHERE no = ?", reason || null, no);
  const changes = diffFields(
    req as unknown as Record<string, unknown>, { status: 'Open', decision_reason: reason || null },
  );
  await logTableChange('account_activation_request', no, 'Modification', changes, user);
}

/** Approved -> flips the target account back to ACTIVE; lib/savings.ts's deposit()/withdraw()
 *  accept postings against it again from that point on. Re-checks the account is still INACTIVE
 *  in case something else changed it after approval. If a Transaction Charge is configured for
 *  ACCOUNT_ACTIVATION (Admin Centre → Charges), the reactivation fee it resolves to is posted
 *  and deducted from the account being reactivated — silently skipped when none is configured,
 *  so activation stays free by default. */
export async function processAccountActivationRequest(no: string, user: Actor): Promise<{ accountId: number }> {
  return tx(async () => {
    const req = await one<AccountActivationRequest>('SELECT * FROM account_activation_request WHERE no = ?', no);
    if (!req) throw new AppError('Account activation request not found', 'NOT_FOUND');
    if (req.status !== 'Approved') {
      throw new AppError('Only an approved request can be processed', 'VALIDATION');
    }
    const account = await one<{ status: string; member_id: number }>(
      'SELECT status, member_id FROM savings_account WHERE id = ?', req.account_id,
    );
    if (!account) throw new AppError('Savings account not found', 'NOT_FOUND');
    if (account.status !== 'INACTIVE') {
      throw new AppError(`Account is no longer inactive (currently ${account.status}) — cannot activate`, 'VALIDATION');
    }
    // Final gate: the tariff or the debit account's own balance may have moved since this
    // request was created or submitted, so both are re-checked right before anything posts.
    await assertChargeAffordable(req.transaction_charge_id, req.debit_account_id);

    await run("UPDATE savings_account SET status = 'ACTIVE' WHERE id = ?", req.account_id);

    // Set below when the reactivation fee posts — carried out to the request's own journal_id
    // column (mirrors member_charging.journal_id) so Find Entries can trace it back here.
    let feeJournalId: number | null = null;

    if (req.transaction_charge_id && req.debit_account_id) {
      const debitAccount = await one<{ balance: number; account_no: string; gl_control_id: number }>(
        `SELECT sa.balance, sa.account_no, p.gl_control_id
         FROM savings_account sa JOIN savings_product p ON p.id = sa.product_id WHERE sa.id = ?`,
        req.debit_account_id,
      );
      if (!debitAccount) throw new AppError('Debit account not found', 'NOT_FOUND');

      const charged = await postTransactionCharges({
        transactionChargeId: req.transaction_charge_id, baseAmount: 0, debitAccountCode: debitAccount.gl_control_id,
        valueDate: today(), module: 'SAVINGS', eventType: 'ACCOUNT_ACTIVATION',
        memberId: account.member_id, description: `Reactivation fee — ${debitAccount.account_no}`, user,
      });
      if (charged) {
        feeJournalId = charged.journal.id;
        const total = charged.charges.reduce((sum, c) => sum + c.amount, 0);
        const newBalance = debitAccount.balance - total;
        await run(
          'UPDATE savings_account SET balance = ?, last_activity = ? WHERE id = ?',
          newBalance, today(), req.debit_account_id,
        );
        await run(
          `INSERT INTO txn (txn_ref, value_date, created_at, module, txn_type, member_id,
             savings_account_id, amount, running_balance, channel, description, journal_id, created_by)
           VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?)`,
          await nextSequence('TXN'), today(), new Date().toISOString(), 'SAVINGS', 'FEE', account.member_id,
          req.debit_account_id, -total, newBalance, 'SYSTEM', `Reactivation fee — ${debitAccount.account_no}`,
          charged.journal.id, user.username,
        );
      }
    }

    await run(
      `UPDATE account_activation_request
       SET status = 'Processed', processed_at = ?, processed_by = ?, journal_id = ? WHERE no = ?`,
      new Date().toISOString(), user.username, feeJournalId, no,
    );
    const changes = diffFields(req as unknown as Record<string, unknown>, { status: 'Processed' });
    await logTableChange('account_activation_request', no, 'Modification', changes, user);
    return { accountId: req.account_id };
  });
}
