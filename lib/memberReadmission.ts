/*
 * Member Re-admission — a maker-checker request to let a member who previously exited the
 * society (member.status = WITHDRAWN) rejoin. Same Open -> Pending Approval -> Approved ->
 * Processed shape as lib/memberActivation.ts, which this closely mirrors — the difference is
 * scope: this reverses lib/memberExits.ts's processMemberExit(), which fully settled the member
 * (paid off every loan, closed every account except Share Capital/Benevolent, zeroed their
 * balances) rather than just leaving them dormant-but-intact. Re-admission is therefore closer
 * to fresh onboarding (lib/memberApplications.ts's createMemberFromApplication) than to
 * lib/memberActivation.ts's own "reactivate every INACTIVE account" step: it re-provisions the
 * member's Member Category default savings accounts from scratch (reopening a CLOSED one where
 * it still exists, opening a new one otherwise) rather than merely flipping a status.
 *
 * A Deceased member (member.status = DECEASED — see lib/memberExits.ts's exit_type branch) is
 * terminal and never offered here; only WITHDRAWN is eligible, the same "only one specific
 * status is eligible" discipline lib/memberActivation.ts applies to DORMANT.
 *
 * The optional re-admission fee reuses the exact same "Pay From Account Type" choice (cash at
 * the till, or deducted from one of the member's own re-provisioned accounts) as
 * lib/memberActivation.ts's own reactivation fee — any active 'General' Transaction Charge,
 * freely chosen by the maker.
 */
import {
  one, all, run, tx, nextSequence, hasAnyRow,
} from './db.ts';
import { AppError } from './errors.ts';
import { diffFields, logTableChange } from './changeLog.ts';
import { findMatchingWorkflow, findPendingRoutedTask, pickConditionFields, startWorkflow } from './workflow.ts';
import { postTransactionCharges, previewTransactionChargeById } from './charges.ts';
import { openAccount, CHANNEL_GL } from './savings.ts';
import { getMemberCategoryDefaultAccounts } from './pool.ts';
import { resolvePostingDate } from './postingDates.ts';
import { buildFilterClause, type FilterCondition, type FilterFieldDef } from './listFilters.ts';
import { buildOrderClause, type SortState } from './listSort.ts';
import { getJournal, type JournalDetail } from './gl.ts';
import type {
  Actor, MemberReadmissionRequest, MemberReadmissionRequestWithDimensions, PayFromAccountType,
  SavingsAccountForDebit,
} from './types.ts';

export type MemberReadmissionView = 'open' | 'pending' | 'approved' | 'processed';

const VIEW_CLAUSE: Record<MemberReadmissionView, string> = {
  open: "a.status = 'Open'",
  pending: "a.status = 'Pending Approval'",
  approved: "a.status = 'Approved'",
  processed: "a.status = 'Processed'",
};

const SELECT_REQUEST = `
  SELECT a.*, m.member_no AS member_no, m.first_name AS member_first_name, m.last_name AS member_last_name,
         m.status AS member_status,
         tc.code AS transaction_charge_code, tc.description AS transaction_charge_description,
         da.account_no AS debit_account_no, da.balance AS debit_account_balance,
         da.hold_amount AS debit_account_hold_amount, dp.min_balance AS debit_account_min_balance
  FROM member_readmission_request a
  JOIN member m ON m.id = a.member_id
  LEFT JOIN transaction_charge tc ON tc.id = a.transaction_charge_id
  LEFT JOIN savings_account da ON da.id = a.debit_account_id
  LEFT JOIN savings_product dp ON dp.id = da.product_id`;

export const MEMBER_READMISSION_FILTER_FIELDS: FilterFieldDef[] = [
  { key: 'no', label: 'Request No.', type: 'text', column: 'a.no' },
  { key: 'member_id', label: 'Member', type: 'select', column: 'm.id' },
  { key: 'reason', label: 'Reason', type: 'text', column: 'a.reason' },
  { key: 'decision_reason', label: 'Decision Reason', type: 'text', column: 'a.decision_reason' },
  { key: 'created_by', label: 'Created By', type: 'text', column: 'a.created_by' },
  { key: 'created_at', label: 'Created', type: 'date', column: 'a.created_at', datetime: true },
  { key: 'processed_by', label: 'Processed By', type: 'text', column: 'a.processed_by' },
  { key: 'processed_at', label: 'Processed', type: 'date', column: 'a.processed_at', datetime: true },
];

const MEMBER_READMISSION_SORT_COLUMNS: Record<string, string> = {
  no: 'a.no',
  member: 'm.first_name',
  status: 'a.status',
};

export interface ListMemberReadmissionOptions {
  view?: MemberReadmissionView;
  search?: string;
  filters?: FilterCondition[];
  sort?: SortState | null;
}

export const listMemberReadmissionRequests = (
  { view, search = '', filters = [], sort = null }: ListMemberReadmissionOptions = {},
): Promise<MemberReadmissionRequestWithDimensions[]> => {
  const { clause, params } = buildFilterClause(MEMBER_READMISSION_FILTER_FIELDS, filters);
  const orderBy = buildOrderClause(MEMBER_READMISSION_SORT_COLUMNS, sort, 'a.no DESC');
  return all<MemberReadmissionRequestWithDimensions>(
    `${SELECT_REQUEST}
     WHERE (m.first_name LIKE @like OR m.last_name LIKE @like OR m.member_no LIKE @like OR a.no LIKE @like)
       ${view ? `AND ${VIEW_CLAUSE[view]}` : ''}
       ${clause}
     ${orderBy}`,
    { like: `%${String(search).trim()}%`, ...params },
  );
};

/** Adds the charge's currently-computed amount to a fetched request — computed live, same
 *  reasoning as lib/memberActivation.ts's own withChargeAmount(). */
async function withChargeAmount(
  req: MemberReadmissionRequestWithDimensions,
): Promise<MemberReadmissionRequestWithDimensions> {
  if (!req.transaction_charge_id) return { ...req, charge_amount: null };
  const charges = await previewTransactionChargeById(req.transaction_charge_id, 0);
  return { ...req, charge_amount: charges.reduce((sum, c) => sum + c.amount, 0) };
}

export async function getMemberReadmissionRequest(no: string): Promise<MemberReadmissionRequestWithDimensions | undefined> {
  const req = await one<MemberReadmissionRequestWithDimensions>(`${SELECT_REQUEST} WHERE a.no = ?`, no);
  return req ? withChargeAmount(req) : undefined;
}

export const hasAnyMemberReadmissionRequests = (view?: MemberReadmissionView): Promise<boolean> =>
  hasAnyRow('member_readmission_request a', view ? VIEW_CLAUSE[view] : undefined);

export async function getAdjacentMemberReadmissionNos(
  no: string, view?: MemberReadmissionView,
): Promise<{ prevNo: string | null; nextNo: string | null }> {
  const clause = view ? `AND ${VIEW_CLAUSE[view]}` : '';
  const [prev, next] = await Promise.all([
    one<{ no: string }>(`SELECT a.no FROM member_readmission_request a WHERE a.no < ? ${clause} ORDER BY a.no DESC LIMIT 1`, no),
    one<{ no: string }>(`SELECT a.no FROM member_readmission_request a WHERE a.no > ? ${clause} ORDER BY a.no ASC LIMIT 1`, no),
  ]);
  return { prevNo: prev?.no ?? null, nextNo: next?.no ?? null };
}

/** Every Withdrawn member — Deceased is terminal and excluded, the same way
 *  lib/memberActivation.ts's own eligibleMembersForActivation() narrows to Dormant only — minus
 *  anyone who already has a not-yet-Processed re-admission request in flight. */
export const eligibleMembersForReadmission = (): Promise<{ id: number; member_no: string; first_name: string; last_name: string }[]> =>
  all(
    `SELECT m.id, m.member_no, m.first_name, m.last_name
     FROM member m
     WHERE m.status = 'WITHDRAWN'
       AND NOT EXISTS (SELECT 1 FROM member_readmission_request r WHERE r.member_id = m.id AND r.status != 'Processed')
     ORDER BY m.member_no`,
  );

/** Every account this member still holds (Share Capital/Benevolent survive an exit untouched)
 *  whose product permits a withdrawal — the picklist for where a re-admission fee gets debited
 *  from when paying from MEMBER_ACCOUNT. By the time the fee actually posts, processing has
 *  already re-provisioned every category-default account, same reasoning as
 *  lib/memberActivation.ts's own debitableAccountsForMember(). */
export const debitableAccountsForMember = (memberId: number): Promise<SavingsAccountForDebit[]> =>
  all<SavingsAccountForDebit>(
    `SELECT sa.id, sa.account_no, sa.status, sa.balance, sa.hold_amount, p.name AS product_name,
            p.min_balance, p.gl_control_id
     FROM savings_account sa JOIN savings_product p ON p.id = sa.product_id
     WHERE sa.member_id = ? AND p.allow_withdrawal = 1 ORDER BY sa.account_no`,
    memberId,
  );

async function assertEligible(memberId: number, excludeRequestNo?: string): Promise<void> {
  const member = await one<{ status: string }>('SELECT status FROM member WHERE id = ?', memberId);
  if (!member) throw new AppError('Member not found', 'NOT_FOUND');
  if (member.status !== 'WITHDRAWN') {
    throw new AppError(`Only a Withdrawn member can be re-admitted (currently ${member.status})`, 'VALIDATION');
  }
  const dupRequest = await one(
    `SELECT 1 FROM member_readmission_request
     WHERE member_id = ? AND status != 'Processed' ${excludeRequestNo ? 'AND no != ?' : ''}`,
    ...(excludeRequestNo ? [memberId, excludeRequestNo] : [memberId]),
  );
  if (dupRequest) {
    throw new AppError('A re-admission request is already in progress for this member', 'VALIDATION');
  }
}

/** Checked at every gate a charged request passes through, same discipline
 *  lib/memberActivation.ts's assertChargeAffordable() applies. CASH needs nothing checked here
 *  — the till isn't a balance this module tracks — only MEMBER_ACCOUNT actually draws down a
 *  savings account. */
async function assertChargeAffordable(
  transactionChargeId: number | null, payFromAccountType: PayFromAccountType, debitAccountId: number | null,
): Promise<void> {
  if (!transactionChargeId || payFromAccountType === 'CASH') return;
  if (!debitAccountId) {
    throw new AppError('A debit account is required when paying the charge from a member account', 'VALIDATION');
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
      `The re-admission charge of ${(total / 100).toFixed(2)} exceeds ${acct.account_no}'s available balance of ${(available / 100).toFixed(2)}`,
      'INSUFFICIENT_FUNDS',
    );
  }
}

function assertPaymentFields(
  payFromAccountType: PayFromAccountType, paymentReference: string | null, debitAccountId: number | null,
): void {
  if (payFromAccountType === 'CASH' && !paymentReference?.trim()) {
    throw new AppError('A payment reference is required when the member pays in cash', 'VALIDATION');
  }
  if (payFromAccountType === 'MEMBER_ACCOUNT' && !debitAccountId) {
    throw new AppError('A debit account is required when paying from a member account', 'VALIDATION');
  }
}

export interface MemberReadmissionInput {
  memberId: number;
  reason: string;
  payFromAccountType: PayFromAccountType;
  paymentReference?: string | null;
  transactionChargeId?: number | null;
  debitAccountId?: number | null;
}

export async function createMemberReadmissionRequest(
  {
    memberId, reason, payFromAccountType, paymentReference = null, transactionChargeId = null, debitAccountId = null,
  }: MemberReadmissionInput,
  user: Actor,
): Promise<{ no: string }> {
  if (!reason || !reason.trim()) throw new AppError('A reason is required to request re-admission', 'VALIDATION');
  await assertEligible(memberId);
  assertPaymentFields(payFromAccountType, paymentReference, debitAccountId);
  await assertChargeAffordable(transactionChargeId, payFromAccountType, debitAccountId);

  const no = await nextSequence('MEMBER_READMISSION');
  await run(
    `INSERT INTO member_readmission_request
       (no, member_id, reason, pay_from_account_type, payment_reference, transaction_charge_id, debit_account_id,
        created_at, created_by)
     VALUES (?,?,?,?,?,?,?,?,?)`,
    no, memberId, reason.trim(), payFromAccountType, paymentReference?.trim() || null, transactionChargeId,
    payFromAccountType === 'MEMBER_ACCOUNT' ? debitAccountId : null, new Date().toISOString(), user.username,
  );
  await logTableChange(
    'member_readmission_request', no, 'Insertion',
    [
      { field: 'member_id', oldValue: null, newValue: memberId },
      { field: 'reason', oldValue: null, newValue: reason.trim() },
      { field: 'pay_from_account_type', oldValue: null, newValue: payFromAccountType },
      { field: 'payment_reference', oldValue: null, newValue: paymentReference },
      { field: 'transaction_charge_id', oldValue: null, newValue: transactionChargeId },
      { field: 'debit_account_id', oldValue: null, newValue: debitAccountId },
    ],
    user,
  );
  return { no };
}

export async function updateMemberReadmissionRequest(
  no: string, input: MemberReadmissionInput, user: Actor,
): Promise<MemberReadmissionRequestWithDimensions> {
  const {
    memberId, reason, payFromAccountType, paymentReference = null, transactionChargeId = null, debitAccountId = null,
  } = input;
  if (!reason || !reason.trim()) throw new AppError('A reason is required', 'VALIDATION');
  const req = await one<MemberReadmissionRequest>('SELECT * FROM member_readmission_request WHERE no = ?', no);
  if (!req) throw new AppError('Member re-admission request not found', 'NOT_FOUND');
  if (req.status !== 'Open') throw new AppError('Only an open request can be edited', 'VALIDATION');
  if (memberId !== req.member_id) await assertEligible(memberId, no);
  assertPaymentFields(payFromAccountType, paymentReference, debitAccountId);
  await assertChargeAffordable(transactionChargeId, payFromAccountType, debitAccountId);

  const patch = {
    member_id: memberId, reason: reason.trim(), pay_from_account_type: payFromAccountType,
    payment_reference: paymentReference?.trim() || null, transaction_charge_id: transactionChargeId,
    debit_account_id: payFromAccountType === 'MEMBER_ACCOUNT' ? debitAccountId : null,
  };
  await run(
    `UPDATE member_readmission_request
     SET member_id = ?, reason = ?, pay_from_account_type = ?, payment_reference = ?,
         transaction_charge_id = ?, debit_account_id = ?
     WHERE no = ?`,
    patch.member_id, patch.reason, patch.pay_from_account_type, patch.payment_reference,
    patch.transaction_charge_id, patch.debit_account_id, no,
  );
  const changes = diffFields(req as unknown as Record<string, unknown>, patch);
  await logTableChange('member_readmission_request', no, 'Modification', changes, user);
  return (await getMemberReadmissionRequest(no))!;
}

export async function submitMemberReadmissionRequest(no: string, user: Actor): Promise<{ autoApproved: boolean }> {
  const req = await one<MemberReadmissionRequest>('SELECT * FROM member_readmission_request WHERE no = ?', no);
  if (!req) throw new AppError('Member re-admission request not found', 'NOT_FOUND');
  if (req.status !== 'Open') throw new AppError('Only an open request can be submitted for approval', 'VALIDATION');
  await assertEligible(req.member_id, no);
  await assertChargeAffordable(req.transaction_charge_id, req.pay_from_account_type, req.debit_account_id);

  const matched = await findMatchingWorkflow('MEMBER_READMISSION', await pickConditionFields('MEMBER_READMISSION', req));
  if (!matched) throw new AppError('There is no enabled workflow for this document', 'NO_WORKFLOW');

  await tx(async () => {
    await run("UPDATE member_readmission_request SET status = 'Pending Approval' WHERE no = ?", no);
    await logTableChange(
      'member_readmission_request', no, 'Modification',
      [{ field: 'status', oldValue: req.status, newValue: 'Pending Approval' }], user,
    );
    await startWorkflow(matched.workflow, matched.steps, {
      documentType: 'MEMBER_READMISSION', entityId: no, requestedBy: user.username, amount: 0,
    });
  });

  const after = await one<{ status: string }>('SELECT status FROM member_readmission_request WHERE no = ?', no);
  return { autoApproved: after?.status === 'Approved' };
}

export async function cancelMemberReadmissionApproval(no: string, user: Actor): Promise<void> {
  const req = await one<Pick<MemberReadmissionRequest, 'status' | 'created_by'>>(
    'SELECT status, created_by FROM member_readmission_request WHERE no = ?', no,
  );
  if (!req) throw new AppError('Member re-admission request not found', 'NOT_FOUND');
  if (req.status !== 'Pending Approval') {
    throw new AppError('Only a request pending approval can have its approval request cancelled', 'VALIDATION');
  }
  const routed = await findPendingRoutedTask('MEMBER_READMISSION', no);
  const requestedBy = routed?.requested_by ?? req.created_by;
  if (requestedBy !== user.username) {
    throw new AppError('Only the person who submitted this request for approval can cancel it', 'NOT_REQUESTER');
  }
  await run("UPDATE member_readmission_request SET status = 'Open' WHERE no = ?", no);
  await logTableChange(
    'member_readmission_request', no, 'Modification',
    [{ field: 'status', oldValue: req.status, newValue: 'Open' }], user,
  );
}

export async function approveMemberReadmissionRequest(no: string, user: Actor): Promise<void> {
  const req = await one<MemberReadmissionRequest>('SELECT * FROM member_readmission_request WHERE no = ?', no);
  if (!req) throw new AppError('Member re-admission request not found', 'NOT_FOUND');
  if (req.status !== 'Pending Approval') {
    throw new AppError('Only a request pending approval can be approved', 'VALIDATION');
  }
  await run("UPDATE member_readmission_request SET status = 'Approved', decision_reason = NULL WHERE no = ?", no);
  const changes = diffFields(
    req as unknown as Record<string, unknown>, { status: 'Approved', decision_reason: null },
  );
  await logTableChange('member_readmission_request', no, 'Modification', changes, user);
}

export async function rejectMemberReadmissionRequest(no: string, reason: string | null, user: Actor): Promise<void> {
  if (!reason || !reason.trim()) throw new AppError('A reason is required to reject a request', 'VALIDATION');
  const req = await one<MemberReadmissionRequest>('SELECT * FROM member_readmission_request WHERE no = ?', no);
  if (!req) throw new AppError('Member re-admission request not found', 'NOT_FOUND');
  if (req.status !== 'Pending Approval') {
    throw new AppError('Only a request pending approval can be rejected', 'VALIDATION');
  }
  await run("UPDATE member_readmission_request SET status = 'Open', decision_reason = ? WHERE no = ?", reason || null, no);
  const changes = diffFields(
    req as unknown as Record<string, unknown>, { status: 'Open', decision_reason: reason || null },
  );
  await logTableChange('member_readmission_request', no, 'Modification', changes, user);
}

/**
 * Re-provisions one Member Category default product for a re-admitted member: reopens a
 * still-present CLOSED account for that product (lib/memberExits.ts closed rather than deleted
 * them, so the original account_no and history survive), reactivates a stray INACTIVE one, opens
 * a brand new one if the member never held that product at all, or leaves an already-ACTIVE one
 * untouched (Share Capital/Benevolent survive an exit unclosed — see memberExits.ts — so those
 * simply pass straight through here). Unlike lib/pool.ts's own openDefaultAccountForMember()
 * (built for a category's default set changing under *already-active* members), this must
 * actually resurrect a CLOSED row, not just skip it — a plain openAccount() call would reject a
 * product the member already has *any* row for, closed or not.
 */
async function reprovisionDefaultAccount(memberId: number, productId: number, user: Actor, vd: string): Promise<void> {
  const existing = await one<{ id: number; status: string }>(
    'SELECT id, status FROM savings_account WHERE member_id = ? AND product_id = ?', memberId, productId,
  );
  if (!existing) {
    await openAccount({ memberId, productId, user, enforceMinOpening: false });
    return;
  }
  if (existing.status === 'CLOSED') {
    await run('UPDATE savings_account SET status = ?, last_activity = ? WHERE id = ?', 'ACTIVE', vd, existing.id);
  } else if (existing.status === 'INACTIVE') {
    await run("UPDATE savings_account SET status = 'ACTIVE' WHERE id = ?", existing.id);
  }
}

/**
 * Approved -> flips the member back to Active (before re-provisioning accounts, since
 * lib/savings.ts's openAccount() itself refuses to open anything for a Withdrawn member),
 * re-provisions every one of their Member Category's default savings accounts, and — if a
 * Transaction Charge is configured — posts the re-admission fee either straight to the teller
 * cash account (CASH) or debited from one of the member's own re-provisioned accounts
 * (MEMBER_ACCOUNT), silently skipped when no charge is selected so re-admission stays free by
 * default, same as lib/memberActivation.ts.
 */
export async function processMemberReadmissionRequest(no: string, user: Actor): Promise<{ memberId: number }> {
  return tx(async () => {
    const req = await one<MemberReadmissionRequest>('SELECT * FROM member_readmission_request WHERE no = ?', no);
    if (!req) throw new AppError('Member re-admission request not found', 'NOT_FOUND');
    if (req.status !== 'Approved') throw new AppError('Only an approved request can be processed', 'VALIDATION');

    const member = await one<{ status: string; member_category_id: number | null }>(
      'SELECT status, member_category_id FROM member WHERE id = ?', req.member_id,
    );
    if (!member) throw new AppError('Member not found', 'NOT_FOUND');
    if (member.status !== 'WITHDRAWN') {
      throw new AppError(`Member is no longer Withdrawn (currently ${member.status}) — cannot re-admit`, 'VALIDATION');
    }
    // Final gate: the tariff or the debit account's own balance may have moved since this
    // request was created or submitted, so both are re-checked right before anything posts.
    await assertChargeAffordable(req.transaction_charge_id, req.pay_from_account_type, req.debit_account_id);

    const vd = await resolvePostingDate(user);

    await run("UPDATE member SET status = 'ACTIVE' WHERE id = ?", req.member_id);

    if (member.member_category_id) {
      const defaults = await getMemberCategoryDefaultAccounts(member.member_category_id);
      for (const d of defaults) {
        await reprovisionDefaultAccount(req.member_id, d.savings_product_id, user, vd);
      }
    }

    // Set below when the re-admission fee posts — carried out to the request's own journal_id
    // column (mirrors member_activation_request.journal_id) so Find Entries can trace it back.
    let feeJournalId: number | null = null;

    if (req.transaction_charge_id) {
      const description = `Member re-admission fee — ${no}`;

      if (req.pay_from_account_type === 'CASH') {
        const posted = await postTransactionCharges({
          transactionChargeId: req.transaction_charge_id, baseAmount: 0, debitAccountCode: CHANNEL_GL.TELLER,
          valueDate: vd, module: 'SAVINGS', eventType: 'MEMBER_READMISSION', memberId: req.member_id,
          description, reference: no, user,
        });
        if (posted) feeJournalId = posted.journal.id;
      } else if (req.debit_account_id) {
        const debitAccount = await one<{ balance: number; account_no: string; gl_control_id: number }>(
          `SELECT sa.balance, sa.account_no, p.gl_control_id
           FROM savings_account sa JOIN savings_product p ON p.id = sa.product_id WHERE sa.id = ?`,
          req.debit_account_id,
        );
        if (!debitAccount) throw new AppError('Debit account not found', 'NOT_FOUND');

        const posted = await postTransactionCharges({
          transactionChargeId: req.transaction_charge_id, baseAmount: 0, debitAccountCode: debitAccount.gl_control_id,
          valueDate: vd, module: 'SAVINGS', eventType: 'MEMBER_READMISSION', memberId: req.member_id,
          description, reference: no, user,
        });
        if (posted) {
          feeJournalId = posted.journal.id;
          const total = posted.charges.reduce((sum, c) => sum + c.amount, 0);
          const newBalance = debitAccount.balance - total;
          await run(
            'UPDATE savings_account SET balance = ?, last_activity = ? WHERE id = ?',
            newBalance, vd, req.debit_account_id,
          );
          await run(
            `INSERT INTO txn (txn_ref, value_date, created_at, module, txn_type, member_id,
               savings_account_id, amount, running_balance, channel, description, journal_id, created_by)
             VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?)`,
            await nextSequence('TXN'), vd, new Date().toISOString(), 'SAVINGS', 'FEE', req.member_id,
            req.debit_account_id, -total, newBalance, 'SYSTEM', description, posted.journal.id, user.username,
          );
        }
      }
    }

    await run(
      `UPDATE member_readmission_request
       SET status = 'Processed', processed_at = ?, processed_by = ?, journal_id = ? WHERE no = ?`,
      new Date().toISOString(), user.username, feeJournalId, no,
    );
    const changes = diffFields(req as unknown as Record<string, unknown>, { status: 'Processed' });
    await logTableChange('member_readmission_request', no, 'Modification', changes, user);
    return { memberId: req.member_id };
  });
}

/** The posted re-admission-fee journal, for a processed request. Null when processed with no
 *  charge configured. */
export async function getMemberReadmissionJournal(no: string): Promise<JournalDetail | null> {
  const row = await one<{ journal_id: number | null }>('SELECT journal_id FROM member_readmission_request WHERE no = ?', no);
  if (!row?.journal_id) return null;
  return getJournal(row.journal_id);
}
