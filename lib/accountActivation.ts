/*
 * Account Activation — a maker-checker request to reactivate a savings account that is
 * currently INACTIVE (put there by lib/accountDeactivation.ts, or any other route that ever
 * lands an account in that status). Same Open -> Pending Approval -> Approved -> Processed
 * shape as lib/accountDeactivation.ts: the request only actually reactivates the account
 * (flips it back to ACTIVE) once processAccountActivationRequest() runs on an Approved request.
 * Once ACTIVE again, lib/savings.ts's deposit() and withdraw() both accept postings against it.
 */
import { one, all, run, tx, nextSequence } from './db.ts';
import { AppError } from './errors.ts';
import { diffFields, logTableChange } from './changeLog.ts';
import { findMatchingWorkflow, findPendingRoutedTask, pickConditionFields, startWorkflow } from './workflow.ts';
import { buildFilterClause, type FilterCondition, type FilterFieldDef } from './listFilters.ts';
import { buildOrderClause, type SortState } from './listSort.ts';
import type {
  Actor, AccountActivationRequest, AccountActivationRequestWithDimensions, SavingsAccountWithProduct,
} from './types.ts';

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
         p.code AS savings_product_code, p.name AS savings_product_name
  FROM account_activation_request a
  JOIN savings_account sa ON sa.id = a.account_id
  JOIN member m ON m.id = sa.member_id
  JOIN savings_product p ON p.id = sa.product_id`;

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

export const getAccountActivationRequest = (no: string): Promise<AccountActivationRequestWithDimensions | undefined> =>
  one<AccountActivationRequestWithDimensions>(`${SELECT_REQUEST} WHERE a.no = ?`, no);

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

export interface CreateAccountActivationInput {
  accountId: number;
  reason: string;
}

export async function createAccountActivationRequest(
  { accountId, reason }: CreateAccountActivationInput, user: Actor,
): Promise<{ no: string }> {
  if (!reason || !reason.trim()) throw new AppError('A reason is required to request activation', 'VALIDATION');
  await assertEligible(accountId);

  const no = await nextSequence('ACCOUNT_ACTIVATION');
  await run(
    `INSERT INTO account_activation_request (no, account_id, reason, created_at, created_by)
     VALUES (?,?,?,?,?)`,
    no, accountId, reason.trim(), new Date().toISOString(), user.username,
  );
  await logTableChange(
    'account_activation_request', no, 'Insertion',
    [
      { field: 'account_id', oldValue: null, newValue: accountId },
      { field: 'reason', oldValue: null, newValue: reason.trim() },
    ],
    user,
  );
  return { no };
}

export async function updateAccountActivationRequest(
  no: string, reason: string, user: Actor,
): Promise<AccountActivationRequestWithDimensions> {
  if (!reason || !reason.trim()) throw new AppError('A reason is required', 'VALIDATION');
  const req = await one<AccountActivationRequest>('SELECT * FROM account_activation_request WHERE no = ?', no);
  if (!req) throw new AppError('Account activation request not found', 'NOT_FOUND');
  if (req.status !== 'Open') throw new AppError('Only an open request can be edited', 'VALIDATION');

  await run('UPDATE account_activation_request SET reason = ? WHERE no = ?', reason.trim(), no);
  const changes = diffFields(req as unknown as Record<string, unknown>, { reason: reason.trim() });
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
 *  in case something else changed it after approval. */
export async function processAccountActivationRequest(no: string, user: Actor): Promise<{ accountId: number }> {
  return tx(async () => {
    const req = await one<AccountActivationRequest>('SELECT * FROM account_activation_request WHERE no = ?', no);
    if (!req) throw new AppError('Account activation request not found', 'NOT_FOUND');
    if (req.status !== 'Approved') {
      throw new AppError('Only an approved request can be processed', 'VALIDATION');
    }
    const account = await one<{ status: string }>('SELECT status FROM savings_account WHERE id = ?', req.account_id);
    if (!account) throw new AppError('Savings account not found', 'NOT_FOUND');
    if (account.status !== 'INACTIVE') {
      throw new AppError(`Account is no longer inactive (currently ${account.status}) — cannot activate`, 'VALIDATION');
    }

    await run("UPDATE savings_account SET status = 'ACTIVE' WHERE id = ?", req.account_id);
    await run(
      `UPDATE account_activation_request
       SET status = 'Processed', processed_at = ?, processed_by = ? WHERE no = ?`,
      new Date().toISOString(), user.username, no,
    );
    const changes = diffFields(req as unknown as Record<string, unknown>, { status: 'Processed' });
    await logTableChange('account_activation_request', no, 'Modification', changes, user);
    return { accountId: req.account_id };
  });
}
