/*
 * Member Fixed Deposit Module — a term deposit that draws down part of a member's own savings,
 * earns interest monthly, and pays out (with an optional roll-over) at maturity. Ported from the
 * AL reference's Tab52204017/18/19 "Member Fixed Deposit*" tables and Cod52204010.FixedDepositMgt.
 *
 * Same Open -> Pending Approval -> Approved maker-checker shape as every other document here, but
 * `status` then carries its own richer post-approval lifecycle (Active -> Matured/Terminated)
 * rather than the shared 4-state DocumentStatus — same reason `loan.status` isn't that enum
 * either.
 *
 * Design choices worth flagging:
 *  - Each FD gets its OWN dedicated savings_account (not a single control account shared across
 *    all of a member's FDs the way AL's CreateFDAccount does, which then needs ledger-entry-level
 *    filtering by "Source Code" to tell one FD's balance from another's). Opened directly here
 *    (not via lib/savings.ts's openAccount()), which enforces "one account per product per
 *    member" — a rule that makes sense for a member opening their own FOSA/BOSA account, but not
 *    for a system-created per-instrument ledger account where a member can hold several FDs of
 *    the same type at once.
 *  - Interest accrual (accrueFixedDepositInterest) only ever posts a GL journal — it never
 *    touches the FD's own account balance, matching AL's PostFDAccrual. The FD's own account
 *    holds exactly `amount` from activation until maturity/termination.
 *  - Roll-over transfers the real balance into the successor FD directly and brings it up
 *    immediately Active — AL's own CopyFixedDeposit resets the new FD to Open needing a second
 *    manual approval + Activate cycle that would draw a second time from the member's regular
 *    savings, and its actual balance-transfer postings are commented out in the reference source.
 *    That's incomplete in the reference app; this port fixes it.
 */
import {
  one, all, run, tx, nextSequence, audit, hasAnyRow,
} from './db.ts';
import { AppError } from './errors.ts';
import { findMatchingWorkflow, findPendingRoutedTask, pickConditionFields, startWorkflow } from './workflow.ts';
import * as savings from './savings.ts';
import { postJournal } from './accounting.ts';
import { addMonths } from './loans.ts';
import { getFdLinkedBalance } from './loanFdSecurity.ts';
import { today } from './format.ts';
import { resolvePostingDate } from './postingDates.ts';
import type {
  Actor, IsoDate, MemberFixedDeposit, MemberFixedDepositSchedule, MemberFixedDepositType, MemberFixedDepositWithDetails,
} from './types.ts';

export type FixedDepositView = 'open' | 'pending' | 'approved' | 'active' | 'matured' | 'terminated';

const VIEW_CLAUSE: Record<FixedDepositView, string> = {
  open: "d.status = 'Open'",
  pending: "d.status = 'Pending Approval'",
  approved: "d.status = 'Approved'",
  active: "d.status = 'Active'",
  matured: "d.status = 'Matured'",
  terminated: "d.status = 'Terminated'",
};

const SELECT_FD = `
  SELECT d.*, m.member_no AS member_no, m.first_name AS member_first_name, m.last_name AS member_last_name,
         t.code AS fd_type_code, t.description AS fd_type_description,
         sa.account_no AS source_account_no, fa.account_no AS fd_account_no,
         COALESCE(fa.balance, 0) AS running_balance,
         COALESCE((SELECT SUM(amount) FROM member_fixed_deposit_schedule WHERE fd_no = d.no), 0) AS total_interest_payable,
         COALESCE((SELECT SUM(amount) FROM member_fixed_deposit_schedule WHERE fd_no = d.no AND transferred = true), 0) AS total_interest_accrued,
         COALESCE((SELECT SUM(amount) FROM member_fixed_deposit_schedule WHERE fd_no = d.no AND transferred = false), 0) AS total_interest_balance,
         COALESCE((SELECT SUM(LEAST(lfl.guarantee, l.principal_balance + l.interest_balance + l.penalty_balance))
                    FROM loan_fd_lien lfl JOIN loan l ON l.id = lfl.loan_id
                    WHERE lfl.fd_no = d.no AND lfl.status = 'ACTIVE' AND l.status = 'DISBURSED'
                      AND (l.principal_balance + l.interest_balance + l.penalty_balance) > 0), 0) AS linked_loan_balance
  FROM member_fixed_deposit d
  JOIN member m ON m.id = d.member_id
  JOIN member_fixed_deposit_type t ON t.id = d.fd_type_id
  JOIN savings_account sa ON sa.id = d.source_account_id
  LEFT JOIN savings_account fa ON fa.id = d.fd_account_id`;

export interface ListFixedDepositOptions {
  view?: FixedDepositView;
  search?: string;
}

export const listFixedDeposits = (
  { view, search = '' }: ListFixedDepositOptions = {},
): Promise<MemberFixedDepositWithDetails[]> => all<MemberFixedDepositWithDetails>(
  `${SELECT_FD}
   WHERE (d.no LIKE @like OR m.member_no LIKE @like OR m.first_name LIKE @like OR m.last_name LIKE @like)
     ${view ? `AND ${VIEW_CLAUSE[view]}` : ''}
   ORDER BY d.no DESC`,
  { like: `%${String(search).trim()}%` },
);

export const getFixedDeposit = (no: string): Promise<MemberFixedDepositWithDetails | undefined> =>
  one<MemberFixedDepositWithDetails>(`${SELECT_FD} WHERE d.no = ?`, no);

export const hasAnyFixedDeposits = (view?: FixedDepositView): Promise<boolean> =>
  hasAnyRow('member_fixed_deposit d', view ? VIEW_CLAUSE[view] : undefined);

export async function getAdjacentFixedDepositNos(
  no: string, view?: FixedDepositView,
): Promise<{ prevNo: string | null; nextNo: string | null }> {
  const clause = view ? `AND ${VIEW_CLAUSE[view]}` : '';
  const [prev, next] = await Promise.all([
    one<{ no: string }>(`SELECT d.no FROM member_fixed_deposit d WHERE d.no < ? ${clause} ORDER BY d.no DESC LIMIT 1`, no),
    one<{ no: string }>(`SELECT d.no FROM member_fixed_deposit d WHERE d.no > ? ${clause} ORDER BY d.no ASC LIMIT 1`, no),
  ]);
  return { prevNo: prev?.no ?? null, nextNo: next?.no ?? null };
}

export const listFixedDepositSchedule = (fdNo: string): Promise<MemberFixedDepositSchedule[]> =>
  all<MemberFixedDepositSchedule>('SELECT * FROM member_fixed_deposit_schedule WHERE fd_no = ? ORDER BY posting_date', fdNo);

async function withdrawableAccount(memberId: number): Promise<{ id: number; account_no: string; balance: number } | undefined> {
  return one<{ id: number; account_no: string; balance: number }>(
    `SELECT sa.id, sa.account_no, sa.balance
     FROM savings_account sa JOIN savings_product p ON p.id = sa.product_id
     WHERE sa.member_id = ? AND sa.status = 'ACTIVE' AND p.category = 'WITHDRAWABLE DEPOSIT'
     ORDER BY sa.id LIMIT 1`,
    memberId,
  );
}

/** Ported verbatim from Cod52204010.CreateFixedDepositSchedule: one monthly line from
 *  `startDate` to `endDate`, Interest = rate * principal * 0.01 / 12, with the principal
 *  compounding each period only under REDUCING. */
async function populateSchedule(
  fdNo: string, rate: number, amount: number, startDate: string, endDate: string, calcType: string,
): Promise<void> {
  await run('DELETE FROM member_fixed_deposit_schedule WHERE fd_no = ?', fdNo);
  let principal = amount;
  let d = startDate;
  do {
    const interest = Math.round((rate * principal * 0.01) / 12);
    if (calcType === 'REDUCING') principal += interest;
    await run(
      `INSERT INTO member_fixed_deposit_schedule (fd_no, posting_date, description, amount)
       VALUES (?,?,?,?)`,
      fdNo, d, `Accrued interest for ${d}`, interest,
    );
    d = addMonths(d, 1);
  } while (d < endDate);
}

async function openFdAccount(memberId: number, productId: number): Promise<number> {
  const accountNo = await nextSequence('SAVINGS_ACCOUNT');
  const info = await run(
    `INSERT INTO savings_account (account_no, member_id, product_id, balance, status, opened_date, last_activity)
     VALUES (?,?,?,0,'ACTIVE',?,?)`,
    accountNo, memberId, productId, today(), today(),
  );
  return Number(info.lastInsertRowid);
}

async function closeAccount(accountId: number, valueDate: IsoDate): Promise<void> {
  await run("UPDATE savings_account SET status = 'CLOSED', last_activity = ? WHERE id = ?", valueDate, accountId);
}

async function insertTxn(
  memberId: number, accountId: number, amount: number, runningBalance: number, txnType: string, description: string,
  journalId: number, user: Actor, valueDate: IsoDate,
): Promise<void> {
  await run(
    `INSERT INTO txn (txn_ref, value_date, created_at, module, txn_type, member_id, savings_account_id, amount, running_balance, channel, description, journal_id, created_by)
     VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?)`,
    await nextSequence('TXN'), valueDate, new Date().toISOString(), 'SAVINGS', txnType, memberId,
    accountId, amount, runningBalance, 'INTERNAL', description, journalId, user.username,
  );
}

export interface CreateFixedDepositInput {
  memberId: number;
  fdTypeId: number;
  rate: number;
  amount: number;
  maturityInstructions: 'ROLLOVER_PRINCIPAL' | 'ROLLOVER_NET' | 'LIQUIDATE';
  startDate: string;
  termMonths: number;
}

export async function createFixedDeposit(input: CreateFixedDepositInput, user: Actor): Promise<{ no: string }> {
  const member = await one<{ status: string }>('SELECT status FROM member WHERE id = ?', input.memberId);
  if (!member) throw new AppError('Member not found', 'NOT_FOUND');
  if (member.status !== 'ACTIVE') throw new AppError('Only an active member can open a fixed deposit', 'VALIDATION');

  const fdType = await one<MemberFixedDepositType>('SELECT * FROM member_fixed_deposit_type WHERE id = ?', input.fdTypeId);
  if (!fdType) throw new AppError('Fixed deposit type not found', 'NOT_FOUND');
  if (fdType.status !== 'ACTIVE') throw new AppError('This fixed deposit type is not active', 'VALIDATION');

  const rate = Number(input.rate);
  if (rate > fdType.max_interest_rate) {
    throw new AppError(`You cannot exceed the maximum interest rate of ${fdType.max_interest_rate}`, 'VALIDATION');
  }
  if (rate < fdType.min_interest_rate) {
    throw new AppError(`You cannot go below the minimum interest rate of ${fdType.min_interest_rate}`, 'VALIDATION');
  }

  const amount = Math.round(input.amount);
  if (amount <= 0) throw new AppError('Amount must be greater than zero', 'VALIDATION');
  const termMonths = Math.round(input.termMonths);
  if (termMonths <= 0) throw new AppError('Term must be at least one month', 'VALIDATION');

  const source = await withdrawableAccount(input.memberId);
  if (!source) throw new AppError('This member has no active withdrawable deposit account to fund this from', 'VALIDATION');
  if (source.balance < amount) {
    throw new AppError(`You can only fix up to ${(source.balance / 100).toLocaleString()}`, 'VALIDATION');
  }

  const startDate = input.startDate || today();
  const endDate = addMonths(startDate, termMonths);

  const no = await nextSequence('FIXED_DEPOSIT');
  await run(
    `INSERT INTO member_fixed_deposit
       (no, member_id, fd_type_id, rate, maturity_instructions, amount, source_account_id,
        start_date, term_months, end_date, created_at, created_by)
     VALUES (?,?,?,?,?,?,?,?,?,?,?,?)`,
    no, input.memberId, input.fdTypeId, rate, input.maturityInstructions, amount, source.id,
    startDate, termMonths, endDate, new Date().toISOString(), user.username,
  );
  await audit(user, 'FIXED_DEPOSIT_CREATE', 'member_fixed_deposit', no, { memberId: input.memberId, amount });
  return { no };
}

export async function submitFixedDeposit(no: string, user: Actor): Promise<{ autoApproved: boolean }> {
  const req = await one<MemberFixedDeposit>('SELECT * FROM member_fixed_deposit WHERE no = ?', no);
  if (!req) throw new AppError('Fixed deposit not found', 'NOT_FOUND');
  if (req.status !== 'Open') throw new AppError('Only an open fixed deposit can be submitted for approval', 'VALIDATION');

  const source = await one<{ balance: number }>('SELECT balance FROM savings_account WHERE id = ?', req.source_account_id);
  if (!source || source.balance < req.amount) {
    throw new AppError(`You can only fix up to ${((source?.balance ?? 0) / 100).toLocaleString()}`, 'VALIDATION');
  }

  const matched = await findMatchingWorkflow('FIXED_DEPOSIT', await pickConditionFields('FIXED_DEPOSIT', req));
  if (!matched) throw new AppError('There is no enabled workflow for this document', 'NO_WORKFLOW');

  await tx(async () => {
    await run("UPDATE member_fixed_deposit SET status = 'Pending Approval' WHERE no = ?", no);
    await startWorkflow(matched.workflow, matched.steps, {
      documentType: 'FIXED_DEPOSIT', entityId: no, requestedBy: user.username, amount: req.amount,
    });
  });

  const after = await one<{ status: string }>('SELECT status FROM member_fixed_deposit WHERE no = ?', no);
  return { autoApproved: after?.status === 'Approved' };
}

export async function cancelFixedDepositApproval(no: string, user: Actor): Promise<void> {
  const req = await one<Pick<MemberFixedDeposit, 'status' | 'created_by'>>(
    'SELECT status, created_by FROM member_fixed_deposit WHERE no = ?', no,
  );
  if (!req) throw new AppError('Fixed deposit not found', 'NOT_FOUND');
  if (req.status !== 'Pending Approval') {
    throw new AppError('Only a request pending approval can have its approval request cancelled', 'VALIDATION');
  }
  const routed = await findPendingRoutedTask('FIXED_DEPOSIT', no);
  const requestedBy = routed?.requested_by ?? req.created_by;
  if (requestedBy !== user.username) {
    throw new AppError('Only the person who submitted this request for approval can cancel it', 'NOT_REQUESTER');
  }
  await run("UPDATE member_fixed_deposit SET status = 'Open' WHERE no = ?", no);
  await audit(user, 'FIXED_DEPOSIT_CANCEL_APPROVAL', 'member_fixed_deposit', no, {});
}

export async function approveFixedDeposit(no: string, user: Actor): Promise<void> {
  const req = await one<MemberFixedDeposit>('SELECT * FROM member_fixed_deposit WHERE no = ?', no);
  if (!req) throw new AppError('Fixed deposit not found', 'NOT_FOUND');
  if (req.status !== 'Pending Approval') throw new AppError('Only a request pending approval can be approved', 'VALIDATION');
  await run("UPDATE member_fixed_deposit SET status = 'Approved', decision_reason = NULL WHERE no = ?", no);
  await audit(user, 'FIXED_DEPOSIT_APPROVE', 'member_fixed_deposit', no, {});
}

export async function rejectFixedDeposit(no: string, reason: string | null, user: Actor): Promise<void> {
  if (!reason || !reason.trim()) throw new AppError('A reason is required to reject a request', 'VALIDATION');
  const req = await one<MemberFixedDeposit>('SELECT * FROM member_fixed_deposit WHERE no = ?', no);
  if (!req) throw new AppError('Fixed deposit not found', 'NOT_FOUND');
  if (req.status !== 'Pending Approval') throw new AppError('Only a request pending approval can be rejected', 'VALIDATION');
  await run("UPDATE member_fixed_deposit SET status = 'Open', decision_reason = ? WHERE no = ?", reason, no);
  await audit(user, 'FIXED_DEPOSIT_REJECT', 'member_fixed_deposit', no, { reason });
}

/** Approved -> Active: draws the principal from the source account, opens the FD's own dedicated
 *  account and funds it, then generates the interest schedule. Combines AL's separate Activate +
 *  Generate Schedule actions into one step. */
export async function activateFixedDeposit(no: string, user: Actor): Promise<void> {
  return tx(async () => {
    const req = await one<MemberFixedDeposit>('SELECT * FROM member_fixed_deposit WHERE no = ?', no);
    if (!req) throw new AppError('Fixed deposit not found', 'NOT_FOUND');
    if (req.status !== 'Approved') throw new AppError('Only an approved fixed deposit can be activated', 'VALIDATION');

    const fdType = await one<MemberFixedDepositType>('SELECT * FROM member_fixed_deposit_type WHERE id = ?', req.fd_type_id);
    if (!fdType) throw new AppError('Fixed deposit type not found', 'NOT_FOUND');

    const vd = await resolvePostingDate(user);
    await savings.withdraw({
      accountId: req.source_account_id, amount: req.amount, channel: 'SYSTEM',
      valueDate: vd, description: `Fixed deposit ${no} activation`, user,
    });
    const fdAccountId = await openFdAccount(req.member_id, fdType.linked_product_id);
    await savings.deposit({
      accountId: fdAccountId, amount: req.amount, channel: 'SYSTEM',
      valueDate: vd, description: `Fixed deposit ${no} activation`, user,
    });
    await populateSchedule(no, req.rate, req.amount, req.start_date, req.end_date, fdType.interest_calc_type);

    await run(
      "UPDATE member_fixed_deposit SET status = 'Active', fd_account_id = ?, activated_at = ?, activated_by = ? WHERE no = ?",
      fdAccountId, new Date().toISOString(), user.username, no,
    );
    await audit(user, 'FIXED_DEPOSIT_ACTIVATE', 'member_fixed_deposit', no, { fdAccountId });
  });
}

/** Posts the GL accrual for every schedule row due and not yet transferred — pure GL, never
 *  touches the FD's own account balance. Ported from PostFDAccrual. */
export async function accrueFixedDepositInterest(no: string, user: Actor): Promise<{ postedLines: number }> {
  return tx(async () => {
    const req = await one<MemberFixedDeposit>('SELECT * FROM member_fixed_deposit WHERE no = ?', no);
    if (!req) throw new AppError('Fixed deposit not found', 'NOT_FOUND');
    if (req.status !== 'Active') throw new AppError('Only an active fixed deposit can accrue interest', 'VALIDATION');

    const fdType = await one<MemberFixedDepositType>('SELECT * FROM member_fixed_deposit_type WHERE id = ?', req.fd_type_id);
    if (!fdType) throw new AppError('Fixed deposit type not found', 'NOT_FOUND');

    const due = await all<MemberFixedDepositSchedule>(
      "SELECT * FROM member_fixed_deposit_schedule WHERE fd_no = ? AND transferred = false AND posting_date <= ? ORDER BY posting_date",
      no, today(),
    );
    if (!due.length) return { postedLines: 0 };

    const total = due.reduce((s, r) => s + r.amount, 0);
    if (total > 0) {
      await postJournal({
        valueDate: await resolvePostingDate(user), module: 'FIXED_DEPOSIT', eventType: 'INTEREST_ACCRUAL',
        description: `Fixed deposit ${no} — interest accrual`, reference: no, memberId: req.member_id, user,
        lines: [
          { account: fdType.interest_expense_gl_id, debit: total, credit: 0, narration: 'Fixed deposit interest accrual' },
          { account: fdType.interest_payable_gl_id, debit: 0, credit: total, narration: 'Fixed deposit interest accrual' },
        ],
      });
    }
    await run(
      `UPDATE member_fixed_deposit_schedule SET transferred = true WHERE id = ANY(?)`,
      due.map((r) => r.id),
    );
    await audit(user, 'FIXED_DEPOSIT_ACCRUE', 'member_fixed_deposit', no, { total, lines: due.length });
    return { postedLines: due.length };
  });
}

async function assertNoLiveLien(fdNo: string): Promise<void> {
  const balance = await getFdLinkedBalance(fdNo);
  if (balance > 0) {
    throw new AppError('This fixed deposit still secures a disbursed loan — release that security first', 'VALIDATION');
  }
}

/** Approved by the type's withholding_tax_rate, credits net interest into the FD's own account,
 *  then settles the principal per maturity_instructions. Ported from MatureFixedDeposit — see the
 *  module doc comment above for the deliberate roll-over correction versus the AL source. */
export async function matureFixedDeposit(no: string, user: Actor): Promise<void> {
  return tx(async () => {
    const req = await one<MemberFixedDeposit>('SELECT * FROM member_fixed_deposit WHERE no = ?', no);
    if (!req) throw new AppError('Fixed deposit not found', 'NOT_FOUND');
    if (req.status !== 'Active') throw new AppError('Only an active fixed deposit can be matured', 'VALIDATION');
    if (today() < req.end_date) {
      throw new AppError(`You cannot mature this fixed deposit before its due date of ${req.end_date}`, 'VALIDATION');
    }
    await assertNoLiveLien(no);

    const fdType = await one<MemberFixedDepositType>('SELECT * FROM member_fixed_deposit_type WHERE id = ?', req.fd_type_id);
    if (!fdType) throw new AppError('Fixed deposit type not found', 'NOT_FOUND');
    const fdAccount = await one<{ id: number; balance: number; gl_control_id: number }>(
      `SELECT sa.id, sa.balance, p.gl_control_id FROM savings_account sa JOIN savings_product p ON p.id = sa.product_id WHERE sa.id = ?`,
      req.fd_account_id!,
    );
    if (!fdAccount) throw new AppError('This fixed deposit has no funded account to mature', 'VALIDATION');
    const source = await one<{ id: number; balance: number; gl_control_id: number }>(
      `SELECT sa.id, sa.balance, p.gl_control_id FROM savings_account sa JOIN savings_product p ON p.id = sa.product_id WHERE sa.id = ?`,
      req.source_account_id,
    );
    if (!source) throw new AppError('Source account not found', 'NOT_FOUND');

    const scheduleTotal = await one<{ total: number }>(
      'SELECT COALESCE(SUM(amount), 0) AS total FROM member_fixed_deposit_schedule WHERE fd_no = ?', no,
    );
    const totalInterest = scheduleTotal?.total ?? 0;
    const wht = fdType.withholding_tax_rate > 0 ? Math.round((totalInterest * fdType.withholding_tax_rate) / 100) : 0;
    const netInterest = totalInterest - wht;
    const vd = await resolvePostingDate(user);

    let fdBalance = fdAccount.balance;
    if (totalInterest > 0) {
      const j = await postJournal({
        valueDate: vd, module: 'FIXED_DEPOSIT', eventType: 'INTEREST_MATURITY',
        description: `Fixed deposit ${no} — interest at maturity`, reference: no, memberId: req.member_id, user,
        lines: [
          { account: fdType.interest_payable_gl_id, debit: totalInterest, credit: 0, narration: 'Fixed deposit interest at maturity' },
          { account: fdAccount.gl_control_id, debit: 0, credit: netInterest, narration: 'Fixed deposit interest at maturity' },
          ...(wht > 0 ? [{ account: fdType.withholding_tax_gl_id!, debit: 0, credit: wht, narration: 'Withholding tax on fixed deposit interest' }] : []),
        ],
      });
      fdBalance += netInterest;
      await run('UPDATE savings_account SET balance = ?, last_activity = ? WHERE id = ?', fdBalance, vd, fdAccount.id);
      await insertTxn(req.member_id, fdAccount.id, netInterest, fdBalance, 'INTEREST', `Fixed deposit ${no} — interest at maturity`, j.id, user, vd);
    }

    if (req.maturity_instructions === 'LIQUIDATE') {
      const j = await postJournal({
        valueDate: vd, module: 'FIXED_DEPOSIT', eventType: 'FINAL_PAYOUT',
        description: `Fixed deposit ${no} — maturity payout`, reference: no, memberId: req.member_id, user,
        lines: [
          { account: fdAccount.gl_control_id, debit: fdBalance, credit: 0, narration: 'Fixed deposit maturity payout' },
          { account: source.gl_control_id, debit: 0, credit: fdBalance, narration: 'Fixed deposit maturity payout' },
        ],
      });
      await run('UPDATE savings_account SET balance = 0, last_activity = ? WHERE id = ?', vd, fdAccount.id);
      await insertTxn(req.member_id, fdAccount.id, -fdBalance, 0, 'TRANSFER', `Fixed deposit ${no} — maturity payout`, j.id, user, vd);
      const newSourceBalance = source.balance + fdBalance;
      await run('UPDATE savings_account SET balance = ?, last_activity = ? WHERE id = ?', newSourceBalance, vd, source.id);
      await insertTxn(req.member_id, source.id, fdBalance, newSourceBalance, 'TRANSFER', `Fixed deposit ${no} — maturity payout`, j.id, user, vd);
      await closeAccount(fdAccount.id, vd);
      await run("UPDATE member_fixed_deposit SET status = 'Matured', processed_at = ?, processed_by = ? WHERE no = ?", new Date().toISOString(), user.username, no);
    } else {
      const payout = req.maturity_instructions === 'ROLLOVER_PRINCIPAL' ? netInterest : 0;
      const newAmount = req.maturity_instructions === 'ROLLOVER_PRINCIPAL' ? req.amount : req.amount + netInterest;

      if (payout > 0) {
        const j = await postJournal({
          valueDate: vd, module: 'FIXED_DEPOSIT', eventType: 'INTEREST_PAYOUT',
          description: `Fixed deposit ${no} — interest payout on roll-over`, reference: no, memberId: req.member_id, user,
          lines: [
            { account: fdAccount.gl_control_id, debit: payout, credit: 0, narration: 'Fixed deposit roll-over interest payout' },
            { account: source.gl_control_id, debit: 0, credit: payout, narration: 'Fixed deposit roll-over interest payout' },
          ],
        });
        fdBalance -= payout;
        await run('UPDATE savings_account SET balance = ?, last_activity = ? WHERE id = ?', fdBalance, vd, fdAccount.id);
        await insertTxn(req.member_id, fdAccount.id, -payout, fdBalance, 'TRANSFER', `Fixed deposit ${no} — roll-over interest payout`, j.id, user, vd);
        const newSourceBalance = source.balance + payout;
        await run('UPDATE savings_account SET balance = ?, last_activity = ? WHERE id = ?', newSourceBalance, vd, source.id);
        await insertTxn(req.member_id, source.id, payout, newSourceBalance, 'TRANSFER', `Fixed deposit ${no} — roll-over interest payout`, j.id, user, vd);
      }

      const newNo = await nextSequence('FIXED_DEPOSIT');
      const newStartDate = req.end_date;
      const newEndDate = addMonths(newStartDate, req.term_months);
      const newFdAccountId = await openFdAccount(req.member_id, fdType.linked_product_id);

      // Both the old and new FD accounts sit under the same fixed-deposit product, so this
      // transfer nets to zero on the control account itself — a pure sub-ledger reallocation,
      // still posted as a real (self-balancing) journal for the audit trail.
      const j2 = await postJournal({
        valueDate: vd, module: 'FIXED_DEPOSIT', eventType: 'ROLLOVER_TRANSFER',
        description: `Fixed deposit ${no} — roll over to ${newNo}`, reference: no, memberId: req.member_id, user,
        lines: [
          { account: fdAccount.gl_control_id, debit: fdBalance, credit: 0, narration: 'Fixed deposit roll-over transfer' },
          { account: fdAccount.gl_control_id, debit: 0, credit: fdBalance, narration: 'Fixed deposit roll-over transfer' },
        ],
      });
      await run('UPDATE savings_account SET balance = 0, last_activity = ? WHERE id = ?', vd, fdAccount.id);
      await insertTxn(req.member_id, fdAccount.id, -fdBalance, 0, 'TRANSFER', `Fixed deposit ${no} — roll over to ${newNo}`, j2.id, user, vd);
      await run('UPDATE savings_account SET balance = ?, last_activity = ? WHERE id = ?', fdBalance, vd, newFdAccountId);
      await insertTxn(req.member_id, newFdAccountId, fdBalance, fdBalance, 'TRANSFER', `Fixed deposit ${no} — roll over from ${no}`, j2.id, user, vd);
      await closeAccount(fdAccount.id, vd);

      await run(
        `INSERT INTO member_fixed_deposit
           (no, member_id, fd_type_id, rate, maturity_instructions, amount, source_account_id, fd_account_id,
            start_date, term_months, end_date, status, created_at, created_by, activated_at, activated_by, rolled_from_no)
         VALUES (?,?,?,?,?,?,?,?,?,?,?,'Active',?,?,?,?,?)`,
        newNo, req.member_id, req.fd_type_id, req.rate, req.maturity_instructions, newAmount, req.source_account_id, newFdAccountId,
        newStartDate, req.term_months, newEndDate, new Date().toISOString(), user.username, new Date().toISOString(), user.username, no,
      );
      await populateSchedule(newNo, req.rate, newAmount, newStartDate, newEndDate, fdType.interest_calc_type);

      await run(
        "UPDATE member_fixed_deposit SET status = 'Matured', processed_at = ?, processed_by = ?, rolled_to_no = ? WHERE no = ?",
        new Date().toISOString(), user.username, newNo, no,
      );
    }

    await audit(user, 'FIXED_DEPOSIT_MATURE', 'member_fixed_deposit', no, { maturityInstructions: req.maturity_instructions });
  });
}

/** Early termination while Active — no interest is paid, only the principal (the FD account's
 *  balance is always exactly `amount` until maturity, since accrual never touches it). Ported
 *  from CancelFixedDeposit. */
export async function terminateFixedDeposit(no: string, user: Actor): Promise<void> {
  return tx(async () => {
    const req = await one<MemberFixedDeposit>('SELECT * FROM member_fixed_deposit WHERE no = ?', no);
    if (!req) throw new AppError('Fixed deposit not found', 'NOT_FOUND');
    if (req.status !== 'Active') throw new AppError('Only an active fixed deposit can be terminated', 'VALIDATION');
    await assertNoLiveLien(no);

    const fdAccount = await one<{ id: number; balance: number; gl_control_id: number }>(
      `SELECT sa.id, sa.balance, p.gl_control_id FROM savings_account sa JOIN savings_product p ON p.id = sa.product_id WHERE sa.id = ?`,
      req.fd_account_id!,
    );
    if (!fdAccount) throw new AppError('This fixed deposit has no funded account to terminate', 'VALIDATION');
    const source = await one<{ id: number; balance: number; gl_control_id: number }>(
      `SELECT sa.id, sa.balance, p.gl_control_id FROM savings_account sa JOIN savings_product p ON p.id = sa.product_id WHERE sa.id = ?`,
      req.source_account_id,
    );
    if (!source) throw new AppError('Source account not found', 'NOT_FOUND');

    const vd = await resolvePostingDate(user);
    const j = await postJournal({
      valueDate: vd, module: 'FIXED_DEPOSIT', eventType: 'TERMINATION',
      description: `Fixed deposit ${no} — early termination`, reference: no, memberId: req.member_id, user,
      lines: [
        { account: fdAccount.gl_control_id, debit: fdAccount.balance, credit: 0, narration: 'Fixed deposit early termination' },
        { account: source.gl_control_id, debit: 0, credit: fdAccount.balance, narration: 'Fixed deposit early termination' },
      ],
    });
    await run('UPDATE savings_account SET balance = 0, last_activity = ? WHERE id = ?', vd, fdAccount.id);
    await insertTxn(req.member_id, fdAccount.id, -fdAccount.balance, 0, 'TRANSFER', `Fixed deposit ${no} — early termination`, j.id, user, vd);
    const newSourceBalance = source.balance + fdAccount.balance;
    await run('UPDATE savings_account SET balance = ?, last_activity = ? WHERE id = ?', newSourceBalance, vd, source.id);
    await insertTxn(req.member_id, source.id, fdAccount.balance, newSourceBalance, 'TRANSFER', `Fixed deposit ${no} — early termination`, j.id, user, vd);
    await closeAccount(fdAccount.id, vd);

    await run("UPDATE member_fixed_deposit SET status = 'Terminated', processed_at = ?, processed_by = ? WHERE no = ?", new Date().toISOString(), user.username, no);
    await audit(user, 'FIXED_DEPOSIT_TERMINATE', 'member_fixed_deposit', no, {});
  });
}
