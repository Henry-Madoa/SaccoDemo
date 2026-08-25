/*
 * Member Exit Module — the maker-checker process that terminates a membership: settle everything
 * the member owns against everything they owe, pay out the difference, and close their accounts.
 * Ported from the AL reference's "Member Withdrawal" table (Tab52204055) narrowed to
 * Document Type = Withdrawal only — the sibling "Refund" variant on the same AL table is a
 * partial-withdrawal-without-exit feature of its own, out of scope here.
 *
 * Same Open -> Pending Approval -> Approved -> Processed shape as every other document in this
 * codebase, plus a populate/refresh line step (AL's "Validate Assets & Liabilities" action).
 * Processing reuses the existing, tested primitives rather than re-deriving them:
 *   - loanService.repay({fromSavingsAccountId}) for loan payoff (interest/principal allocation,
 *     schedule updates, GL posting — all already correct).
 *   - lib/charges.ts's postTransactionCharges() for the exit Charge Code (the generic
 *     self-balancing "AddCharges" primitive Member Charging and Account Activation already use).
 *   - lib/accounting.ts's postJournal() directly for the one thing nothing else already does: an
 *     internal transfer of a balance from one of the member's own accounts into their withdrawable
 *     deposit account, with no teller/cash leg.
 *   - lib/savings.ts's withdraw() for the final teller/bank payout.
 *
 * This schema already tracks a loan's full owed amount (principal_balance + interest_balance +
 * penalty_balance) as ordinary columns, so unlike AL's separate "Accrued Interest" computation, a
 * liability line's amount is simply that already-correct total — Net Amount needs no separate
 * accrued-interest term.
 */
import {
  one, all, run, tx, nextSequence, audit, hasAnyRow,
} from './db.ts';
import { AppError } from './errors.ts';
import { findMatchingWorkflow, findPendingRoutedTask, pickConditionFields, startWorkflow } from './workflow.ts';
import { getOrg } from './org.ts';
import { repay } from './loanService.ts';
import { postTransactionCharges } from './charges.ts';
import { postJournal } from './accounting.ts';
import { CHANNEL_GL } from './savings.ts';
import { today } from './format.ts';
import type {
  Actor, EligibleExitMemberRow, MemberExit, MemberExitLineWithDetails, MemberExitWithDetails,
} from './types.ts';

export type MemberExitView = 'open' | 'pending' | 'approved' | 'processed';

const VIEW_CLAUSE: Record<MemberExitView, string> = {
  open: "e.status = 'Open'",
  pending: "e.status = 'Pending Approval'",
  approved: "e.status = 'Approved'",
  processed: "e.status = 'Processed'",
};

const SELECT_EXIT = `
  SELECT e.*, m.member_no AS member_no, m.first_name AS member_first_name, m.last_name AS member_last_name,
         tc.code AS transaction_charge_code, tc.description AS transaction_charge_description,
         COALESCE((SELECT SUM(amount) FROM member_exit_line WHERE exit_no = e.no AND entry_type = 'ASSET' AND is_share_capital = false), 0) AS total_assets,
         COALESCE((SELECT SUM(amount) FROM member_exit_line WHERE exit_no = e.no AND entry_type = 'LIABILITY'), 0) AS liabilities,
         COALESCE((SELECT SUM(amount) FROM member_exit_line WHERE exit_no = e.no AND entry_type = 'GUARANTEE'), 0) AS guarantees
  FROM member_exit e
  JOIN member m ON m.id = e.member_id
  LEFT JOIN transaction_charge tc ON tc.id = e.transaction_charge_id`;

export interface ListMemberExitOptions {
  view?: MemberExitView;
  search?: string;
}

export const listMemberExits = (
  { view, search = '' }: ListMemberExitOptions = {},
): Promise<MemberExitWithDetails[]> => all<MemberExitWithDetails>(
  `${SELECT_EXIT}
   WHERE (e.no LIKE @like OR m.member_no LIKE @like OR m.first_name LIKE @like OR m.last_name LIKE @like)
     ${view ? `AND ${VIEW_CLAUSE[view]}` : ''}
   ORDER BY e.no DESC`,
  { like: `%${String(search).trim()}%` },
);

export const getMemberExit = (no: string): Promise<MemberExitWithDetails | undefined> =>
  one<MemberExitWithDetails>(`${SELECT_EXIT} WHERE e.no = ?`, no);

export const hasAnyMemberExits = (view?: MemberExitView): Promise<boolean> =>
  hasAnyRow('member_exit e', view ? VIEW_CLAUSE[view] : undefined);

export async function getAdjacentMemberExitNos(
  no: string, view?: MemberExitView,
): Promise<{ prevNo: string | null; nextNo: string | null }> {
  const clause = view ? `AND ${VIEW_CLAUSE[view]}` : '';
  const [prev, next] = await Promise.all([
    one<{ no: string }>(`SELECT e.no FROM member_exit e WHERE e.no < ? ${clause} ORDER BY e.no DESC LIMIT 1`, no),
    one<{ no: string }>(`SELECT e.no FROM member_exit e WHERE e.no > ? ${clause} ORDER BY e.no ASC LIMIT 1`, no),
  ]);
  return { prevNo: prev?.no ?? null, nextNo: next?.no ?? null };
}

/** Members eligible to open a new exit against: ACTIVE, with no other exit document already
 *  open/in-progress. */
export const eligibleMembersForExit = (): Promise<EligibleExitMemberRow[]> => all<EligibleExitMemberRow>(
  `SELECT m.id, m.member_no, m.first_name, m.last_name
   FROM member m
   WHERE m.status = 'ACTIVE'
     AND NOT EXISTS (SELECT 1 FROM member_exit e WHERE e.member_id = m.id AND e.status <> 'Processed')
   ORDER BY m.member_no`,
);

export const listMemberExitLines = (exitNo: string): Promise<MemberExitLineWithDetails[]> => all<MemberExitLineWithDetails>(
  `SELECT l.*, COALESCE(sa.account_no, ln.loan_no) AS account_no
   FROM member_exit_line l
   LEFT JOIN savings_account sa ON sa.id = l.savings_account_id
   LEFT JOIN loan ln ON ln.id = l.loan_id
   WHERE l.exit_no = ? ORDER BY l.id`,
  exitNo,
);

function addDays(isoDate: string, days: number): string {
  const d = new Date(isoDate + 'T00:00:00Z');
  d.setUTCDate(d.getUTCDate() + days);
  return d.toISOString().slice(0, 10);
}

/** The prorated exposure a member's own guarantee commitments still carry — same
 *  LEAST(committed, prorated-by-current-balance) formula lib/guarantors.ts's guaranteeSplit()
 *  uses, summed here rather than split self/non-self since a Member Exit only ever cares about
 *  the total. Always live — never trusted from a snapshot — since it gates both submission and
 *  processing. */
async function memberGuaranteeExposure(memberId: number): Promise<number> {
  const row = await one<{ s: number }>(
    `SELECT COALESCE(SUM(LEAST(lg.amount, (lg.amount::float8 / NULLIF(l.principal, 0)) * (l.principal_balance + l.interest_balance))), 0) s
     FROM loan_guarantor lg JOIN loan l ON l.id = lg.loan_id
     WHERE lg.member_id = ? AND lg.status = 'COMMITTED'`,
    memberId,
  );
  return Math.round(row?.s || 0);
}

/** Wipes and re-populates a document's lines from the member's current live position — used by
 *  both createMemberExit() and refreshMemberExitLines(). Mirrors AL's
 *  PopulateMemberAssetsLiabilities: every non-withdrawable, non-benevolent account balance as an
 *  Asset line (share capital flagged, not excluded), and — unless the exit is for a deceased
 *  member — every outstanding loan as a Liability line and every guarantee this member still
 *  carries for someone else as a Guarantee line. */
async function populateLines(exitNo: string, memberId: number, exitType: string): Promise<void> {
  await run('DELETE FROM member_exit_line WHERE exit_no = ?', exitNo);

  const assets = await all<{ id: number; balance: number; category: string }>(
    `SELECT sa.id, sa.balance, p.category
     FROM savings_account sa JOIN savings_product p ON p.id = sa.product_id
     WHERE sa.member_id = ? AND sa.status = 'ACTIVE'
       AND p.category NOT IN ('WITHDRAWABLE DEPOSIT', 'BENEVOLENT ACCOUNT')
       AND sa.balance <> 0`,
    memberId,
  );
  for (const a of assets) {
    await run(
      `INSERT INTO member_exit_line (exit_no, entry_type, savings_account_id, balance, amount, is_share_capital)
       VALUES (?,'ASSET',?,?,?,?)`,
      exitNo, a.id, a.balance, a.balance, a.category === 'SHARE CAPITAL ACCOUNT',
    );
  }

  if (exitType !== 'DECEASED') {
    const loans = await all<{ id: number; owed: number }>(
      `SELECT id, (principal_balance + interest_balance + penalty_balance) AS owed
       FROM loan WHERE member_id = ? AND status = 'DISBURSED' AND (principal_balance + interest_balance + penalty_balance) <> 0`,
      memberId,
    );
    for (const l of loans) {
      await run(
        `INSERT INTO member_exit_line (exit_no, entry_type, loan_id, balance, amount)
         VALUES (?,'LIABILITY',?,?,?)`,
        exitNo, l.id, l.owed, -l.owed,
      );
    }

    const guarantees = await all<{ loan_id: number; exposure: number }>(
      `SELECT l.id AS loan_id,
              LEAST(lg.amount, (lg.amount::float8 / NULLIF(l.principal, 0)) * (l.principal_balance + l.interest_balance)) AS exposure
       FROM loan_guarantor lg JOIN loan l ON l.id = lg.loan_id
       WHERE lg.member_id = ? AND lg.status = 'COMMITTED' AND (l.principal_balance + l.interest_balance) <> 0`,
      memberId,
    );
    for (const g of guarantees) {
      const exposure = Math.round(g.exposure || 0);
      if (!exposure) continue;
      await run(
        `INSERT INTO member_exit_line (exit_no, entry_type, loan_id, balance, amount)
         VALUES (?,'GUARANTEE',?,?,?)`,
        exitNo, g.loan_id, exposure, -exposure,
      );
    }
  }

  // Net Amount = total assets (excl. share capital) + liabilities — Guarantees deliberately
  // excluded, same as AL's own Net Amount formula (it's purely a submission/processing gate).
  const totals = await one<{ assets: number; liabilities: number }>(
    `SELECT
       COALESCE(SUM(CASE WHEN entry_type = 'ASSET' AND is_share_capital = false THEN amount ELSE 0 END), 0) AS assets,
       COALESCE(SUM(CASE WHEN entry_type = 'LIABILITY' THEN amount ELSE 0 END), 0) AS liabilities
     FROM member_exit_line WHERE exit_no = ?`,
    exitNo,
  );
  await run('UPDATE member_exit SET net_amount = ? WHERE no = ?', (totals?.assets || 0) + (totals?.liabilities || 0), exitNo);
}

export async function createMemberExit(
  memberId: number, exitType: 'GENERAL' | 'RETIREE' | 'DECEASED', user: Actor,
): Promise<{ no: string }> {
  const member = await one<{ status: string }>('SELECT status FROM member WHERE id = ?', memberId);
  if (!member) throw new AppError('Member not found', 'NOT_FOUND');
  if (member.status !== 'ACTIVE') throw new AppError('Only an active member can be exited', 'VALIDATION');
  const live = await one("SELECT 1 FROM member_exit WHERE member_id = ? AND status <> 'Processed'", memberId);
  if (live) throw new AppError('A member exit is already open or in progress for this member', 'VALIDATION');

  const org = await getOrg();
  const exitDate = today();
  const maturityDate = addDays(exitDate, org?.member_exit_notice_days ?? 30);

  const no = await nextSequence('MEMBER_EXIT');
  await tx(async () => {
    await run(
      `INSERT INTO member_exit (no, member_id, exit_type, exit_date, maturity_date, created_at, created_by)
       VALUES (?,?,?,?,?,?,?)`,
      no, memberId, exitType, exitDate, maturityDate, new Date().toISOString(), user.username,
    );
    await populateLines(no, memberId, exitType);
  });
  await audit(user, 'MEMBER_EXIT_CREATE', 'member_exit', no, { memberId, exitType });
  return { no };
}

export async function refreshMemberExitLines(no: string, user: Actor): Promise<void> {
  const req = await one<MemberExit>('SELECT * FROM member_exit WHERE no = ?', no);
  if (!req) throw new AppError('Member exit not found', 'NOT_FOUND');
  if (req.status !== 'Open') throw new AppError('Only an open member exit can be refreshed', 'VALIDATION');
  await populateLines(no, req.member_id, req.exit_type);
  await audit(user, 'MEMBER_EXIT_REFRESH_LINES', 'member_exit', no, {});
}

export interface SaveMemberExitInput {
  exitType?: 'GENERAL' | 'RETIREE' | 'DECEASED';
  payoutMethod?: 'FOSA' | 'BANK_TRANSFER';
  reason?: string | null;
  transactionChargeId?: number | null;
}

export async function saveMemberExit(no: string, input: SaveMemberExitInput, user: Actor): Promise<MemberExitWithDetails> {
  const req = await one<MemberExit>('SELECT * FROM member_exit WHERE no = ?', no);
  if (!req) throw new AppError('Member exit not found', 'NOT_FOUND');
  if (req.status !== 'Open') throw new AppError('Only an open member exit can be edited', 'VALIDATION');

  const cols: Record<string, unknown> = {};
  if (input.exitType !== undefined) cols.exit_type = input.exitType;
  if (input.payoutMethod !== undefined) cols.payout_method = input.payoutMethod;
  if (input.reason !== undefined) cols.reason = input.reason || null;
  if (input.transactionChargeId !== undefined) cols.transaction_charge_id = input.transactionChargeId || null;

  const keys = Object.keys(cols);
  if (keys.length) {
    await run(`UPDATE member_exit SET ${keys.map((c) => `${c}=?`).join(',')} WHERE no=?`, ...keys.map((c) => cols[c]), no);
  }
  await audit(user, 'MEMBER_EXIT_UPDATE', 'member_exit', no, { fields: keys });
  return (await getMemberExit(no))!;
}

/** BR — ported from AL's OnBeforeSendForApproval, re-run (not merely trusted) at both submit and
 *  process time. */
async function assertReadyForApproval(no: string): Promise<void> {
  const req = await one<MemberExitWithDetails>(`${SELECT_EXIT} WHERE e.no = ?`, no);
  if (!req) throw new AppError('Member exit not found', 'NOT_FOUND');
  if (!req.reason || !req.reason.trim()) throw new AppError('A reason is required before this can be sent for approval', 'VALIDATION');

  const exposure = await memberGuaranteeExposure(req.member_id);
  if (exposure !== 0) {
    throw new AppError(
      'This member still guarantees other members’ loans — clear those through Guarantor Change Management before processing their exit',
      'VALIDATION',
    );
  }
  if (req.total_assets + req.liabilities < 0 && req.exit_type !== 'DECEASED') {
    throw new AppError('Liabilities exceed assets — this member exit cannot be processed', 'VALIDATION');
  }
}

export async function submitMemberExit(no: string, user: Actor): Promise<{ autoApproved: boolean }> {
  const req = await one<MemberExit>('SELECT * FROM member_exit WHERE no = ?', no);
  if (!req) throw new AppError('Member exit not found', 'NOT_FOUND');
  if (req.status !== 'Open') throw new AppError('Only an open member exit can be submitted for approval', 'VALIDATION');
  await assertReadyForApproval(no);

  const matched = await findMatchingWorkflow('MEMBER_EXIT', await pickConditionFields('MEMBER_EXIT', req));
  if (!matched) throw new AppError('There is no enabled workflow for this document', 'NO_WORKFLOW');

  await tx(async () => {
    await run("UPDATE member_exit SET status = 'Pending Approval' WHERE no = ?", no);
    await startWorkflow(matched.workflow, matched.steps, {
      documentType: 'MEMBER_EXIT', entityId: no, requestedBy: user.username, amount: 0,
    });
  });

  const after = await one<{ status: string }>('SELECT status FROM member_exit WHERE no = ?', no);
  return { autoApproved: after?.status === 'Approved' };
}

export async function cancelMemberExitApproval(no: string, user: Actor): Promise<void> {
  const req = await one<Pick<MemberExit, 'status' | 'created_by'>>(
    'SELECT status, created_by FROM member_exit WHERE no = ?', no,
  );
  if (!req) throw new AppError('Member exit not found', 'NOT_FOUND');
  if (req.status !== 'Pending Approval') {
    throw new AppError('Only a request pending approval can have its approval request cancelled', 'VALIDATION');
  }
  const routed = await findPendingRoutedTask('MEMBER_EXIT', no);
  const requestedBy = routed?.requested_by ?? req.created_by;
  if (requestedBy !== user.username) {
    throw new AppError('Only the person who submitted this request for approval can cancel it', 'NOT_REQUESTER');
  }
  await run("UPDATE member_exit SET status = 'Open' WHERE no = ?", no);
  await audit(user, 'MEMBER_EXIT_CANCEL_APPROVAL', 'member_exit', no, {});
}

export async function approveMemberExit(no: string, user: Actor): Promise<void> {
  const req = await one<MemberExit>('SELECT * FROM member_exit WHERE no = ?', no);
  if (!req) throw new AppError('Member exit not found', 'NOT_FOUND');
  if (req.status !== 'Pending Approval') throw new AppError('Only a request pending approval can be approved', 'VALIDATION');
  await run("UPDATE member_exit SET status = 'Approved', decision_reason = NULL WHERE no = ?", no);
  await audit(user, 'MEMBER_EXIT_APPROVE', 'member_exit', no, {});
}

export async function rejectMemberExit(no: string, reason: string | null, user: Actor): Promise<void> {
  if (!reason || !reason.trim()) throw new AppError('A reason is required to reject a request', 'VALIDATION');
  const req = await one<MemberExit>('SELECT * FROM member_exit WHERE no = ?', no);
  if (!req) throw new AppError('Member exit not found', 'NOT_FOUND');
  if (req.status !== 'Pending Approval') throw new AppError('Only a request pending approval can be rejected', 'VALIDATION');
  await run("UPDATE member_exit SET status = 'Open', decision_reason = ? WHERE no = ?", reason, no);
  await audit(user, 'MEMBER_EXIT_REJECT', 'member_exit', no, { reason });
}

/** AL's "Re-Open" action — the one document here that lets an already-Approved decision be
 *  pulled back to Open, rather than only a still-Pending one. Gated by the caller on
 *  MEMBER_EXITS_APPROVE, the same permission Process itself requires. */
export async function reopenMemberExit(no: string, user: Actor): Promise<void> {
  const req = await one<MemberExit>('SELECT * FROM member_exit WHERE no = ?', no);
  if (!req) throw new AppError('Member exit not found', 'NOT_FOUND');
  if (req.status !== 'Approved') throw new AppError('Only an approved member exit can be reopened', 'VALIDATION');
  await run("UPDATE member_exit SET status = 'Open' WHERE no = ?", no);
  await audit(user, 'MEMBER_EXIT_REOPEN', 'member_exit', no, {});
}

/** Approved -> settles every line, pays out the difference, closes accounts. Ported from
 *  PostMemberWithdrawal (Cod52204007.MemberManagement.al:1212), inside one tx() so a failure at
 *  any point leaves the document — and every account it touches — untouched. */
export async function processMemberExit(no: string, user: Actor): Promise<{ memberId: number }> {
  return tx(async () => {
    const req = await one<MemberExitWithDetails>(`${SELECT_EXIT} WHERE e.no = ?`, no);
    if (!req) throw new AppError('Member exit not found', 'NOT_FOUND');
    if (req.status !== 'Approved') throw new AppError('Only an approved member exit can be processed', 'VALIDATION');
    if (!req.maturity_date || today() < req.maturity_date) {
      throw new AppError(`You cannot process this before ${req.maturity_date}, its maturity date`, 'NOT_MATURED');
    }

    const exposure = await memberGuaranteeExposure(req.member_id);
    if (exposure !== 0) {
      throw new AppError(
        'This member still guarantees other members’ loans — clear those through Guarantor Change Management first',
        'VALIDATION',
      );
    }
    if (req.total_assets + req.liabilities < 0 && req.exit_type !== 'DECEASED') {
      throw new AppError('Liabilities exceed assets — this member exit cannot be processed', 'VALIDATION');
    }

    const withdrawable = await one<{ id: number; account_no: string; balance: number; gl_control_id: number; min_balance: number }>(
      `SELECT sa.id, sa.account_no, sa.balance, p.gl_control_id, p.min_balance
       FROM savings_account sa JOIN savings_product p ON p.id = sa.product_id
       WHERE sa.member_id = ? AND sa.status = 'ACTIVE' AND p.category = 'WITHDRAWABLE DEPOSIT'
       ORDER BY sa.id LIMIT 1`,
      req.member_id,
    );
    if (!withdrawable) throw new AppError('This member has no active withdrawable deposit account to settle into', 'VALIDATION');

    const vd = today();
    let withdrawableBalance = withdrawable.balance;

    const lines = await all<{
      id: number; entry_type: string; savings_account_id: number | null; loan_id: number | null; balance: number; is_share_capital: boolean;
    }>('SELECT * FROM member_exit_line WHERE exit_no = ?', no);

    // Consolidate every non-share-capital asset into the withdrawable account — an internal
    // transfer, no teller/cash leg, mirroring AL's "Acc. Transfer" postings.
    for (const line of lines) {
      if (line.entry_type !== 'ASSET' || line.is_share_capital || !line.savings_account_id) continue;
      const source = await one<{ id: number; account_no: string; balance: number; gl_control_id: number }>(
        `SELECT sa.id, sa.account_no, sa.balance, p.gl_control_id
         FROM savings_account sa JOIN savings_product p ON p.id = sa.product_id WHERE sa.id = ?`,
        line.savings_account_id,
      );
      if (!source || source.balance <= 0) continue;
      const amount = source.balance;
      const j = await postJournal({
        valueDate: vd, module: 'MEMBER_EXIT', eventType: 'ASSET_TRANSFER',
        description: `Member exit ${no} — transfer from ${source.account_no}`, reference: no,
        memberId: req.member_id, user,
        lines: [
          { account: source.gl_control_id, debit: amount, credit: 0, narration: 'Member exit — asset consolidated' },
          { account: withdrawable.gl_control_id, debit: 0, credit: amount, narration: 'Member exit — asset consolidated' },
        ],
      });
      await run('UPDATE savings_account SET balance = 0, last_activity = ? WHERE id = ?', vd, source.id);
      withdrawableBalance += amount;
      await run(
        `UPDATE savings_account SET balance = ?, last_activity = ? WHERE id = ?`,
        withdrawableBalance, vd, withdrawable.id,
      );
      await run(
        `INSERT INTO txn (txn_ref, value_date, created_at, module, txn_type, member_id, savings_account_id, amount, running_balance, channel, description, journal_id, created_by)
         VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?)`,
        await nextSequence('TXN'), vd, new Date().toISOString(), 'SAVINGS', 'TRANSFER', req.member_id,
        source.id, -amount, 0, 'INTERNAL', `Member exit ${no} — consolidated to ${withdrawable.account_no}`, j.id, user.username,
      );
      await run(
        `INSERT INTO txn (txn_ref, value_date, created_at, module, txn_type, member_id, savings_account_id, amount, running_balance, channel, description, journal_id, created_by)
         VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?)`,
        await nextSequence('TXN'), vd, new Date().toISOString(), 'SAVINGS', 'TRANSFER', req.member_id,
        withdrawable.id, amount, withdrawableBalance, 'INTERNAL', `Member exit ${no} — from ${source.account_no}`, j.id, user.username,
      );
    }

    // Pay off every outstanding loan from the now-consolidated withdrawable account, reusing the
    // existing repayment engine wholesale. Note: repay()'s own available-funds check still
    // subtracts the withdrawable product's min_balance/hold_amount, which AL's exit posting never
    // respects (the account is being wound down entirely, not left open) — a nonzero floor on a
    // real withdrawable-deposit product could in theory surface as a spurious INSUFFICIENT_FUNDS
    // here even though total assets cover total liabilities in aggregate. Left as-is rather than
    // bypassing repay()'s public checks: a clean rollback with a clear error beats duplicating its
    // interest/principal allocation logic for what should be a zero-min-balance product in practice.
    for (const line of lines) {
      if (line.entry_type !== 'LIABILITY' || !line.loan_id) continue;
      const loanRow = await one<{ owed: number; status: string }>(
        'SELECT (principal_balance + interest_balance + penalty_balance) AS owed, status FROM loan WHERE id = ?',
        line.loan_id,
      );
      if (!loanRow || loanRow.status !== 'DISBURSED' || loanRow.owed <= 0) continue;
      await repay({
        loanId: line.loan_id, amount: loanRow.owed, valueDate: vd,
        description: `Member exit ${no}`, fromSavingsAccountId: withdrawable.id, user,
      });
      withdrawableBalance -= loanRow.owed;
    }

    // The exit charge, if configured — the same generic self-balancing primitive Member Charging
    // and Account Activation's reactivation fee already use.
    if (req.transaction_charge_id) {
      const posted = await postTransactionCharges({
        transactionChargeId: req.transaction_charge_id,
        baseAmount: Math.max(0, req.total_assets + req.liabilities),
        debitAccountCode: withdrawable.gl_control_id, valueDate: vd, module: 'MEMBER_EXIT', eventType: 'EXIT_CHARGE',
        memberId: req.member_id, description: `Member exit ${no} charge`, reference: no, user,
        idempotencyKey: `MEMBER_EXIT_CHARGE-${no}`,
      });
      if (posted) {
        const total = posted.charges.reduce((sum, c) => sum + c.amount, 0);
        withdrawableBalance -= total;
        await run('UPDATE savings_account SET balance = ?, last_activity = ? WHERE id = ?', withdrawableBalance, vd, withdrawable.id);
        await run(
          `INSERT INTO txn (txn_ref, value_date, created_at, module, txn_type, member_id, savings_account_id, amount, running_balance, channel, description, journal_id, created_by)
           VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?)`,
          await nextSequence('TXN'), vd, new Date().toISOString(), 'SAVINGS', 'FEE', req.member_id,
          withdrawable.id, -total, withdrawableBalance, 'TELLER', `Member exit ${no} charge`, posted.journal.id, user.username,
        );
      }
    }

    // Whatever remains gets paid out to the member. Posted directly (not via lib/savings.ts's
    // withdraw()) because that enforces the product's ordinary min_balance floor — irrelevant
    // here, since the account is being emptied and closed outright, not left open. No product
    // withdrawal_fee applies either; the exit's own Charge Code above is the only fee this
    // module charges, matching AL.
    if (withdrawableBalance > 0) {
      const channel = req.payout_method === 'BANK_TRANSFER' ? 'BANK' : 'TELLER';
      const j = await postJournal({
        valueDate: vd, module: 'MEMBER_EXIT', eventType: 'FINAL_PAYOUT',
        description: `Member exit ${no} — final payout`, reference: no, memberId: req.member_id, user,
        lines: [
          { account: withdrawable.gl_control_id, debit: withdrawableBalance, credit: 0, narration: 'Member exit final payout' },
          { account: CHANNEL_GL[channel], debit: 0, credit: withdrawableBalance, narration: 'Member exit final payout' },
        ],
      });
      await run('UPDATE savings_account SET balance = 0, last_activity = ? WHERE id = ?', vd, withdrawable.id);
      await run(
        `INSERT INTO txn (txn_ref, value_date, created_at, module, txn_type, member_id, savings_account_id, amount, running_balance, channel, description, journal_id, created_by)
         VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?)`,
        await nextSequence('TXN'), vd, new Date().toISOString(), 'SAVINGS', 'WITHDRAWAL', req.member_id,
        withdrawable.id, -withdrawableBalance, 0, channel, `Member exit ${no} — final payout`, j.id, user.username,
      );
      withdrawableBalance = 0;
    }

    // Close every other active account except Share Capital and Benevolent (left untouched,
    // matching AL) — and, unlike AL (which never explicitly closes it either), close the
    // withdrawable account too now that it's been paid out to zero.
    await run(
      `UPDATE savings_account SET status = 'CLOSED'
       WHERE member_id = ? AND status = 'ACTIVE' AND id <> ?
         AND product_id NOT IN (SELECT id FROM savings_product WHERE category IN ('SHARE CAPITAL ACCOUNT', 'BENEVOLENT ACCOUNT'))`,
      req.member_id, withdrawable.id,
    );
    await run("UPDATE savings_account SET status = 'CLOSED' WHERE id = ?", withdrawable.id);

    await run("UPDATE member SET status = 'WITHDRAWN' WHERE id = ?", req.member_id);

    await run(
      "UPDATE member_exit SET status = 'Processed', processed_at = ?, processed_by = ? WHERE no = ?",
      new Date().toISOString(), user.username, no,
    );
    await audit(user, 'MEMBER_EXIT_PROCESS', 'member_exit', no, {});
    return { memberId: req.member_id };
  });
}
