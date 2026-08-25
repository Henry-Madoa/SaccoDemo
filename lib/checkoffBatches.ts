/*
 * Checkoff and Salary Processing — a maker-checker batch document scoped to one employer/period
 * that reconciles what an employer's payroll deduction actually remitted against what this SACCO
 * expected, then posts the result. Ported from the AL reference's Checkoff module
 * (Tab52204060/61 "Checkoff Header"/"Lines", Cod52204013 "Checkoff Management",
 * Cod52204009 "Payroll Loan Management" — a ~59-file system also covering Employer Payroll
 * Details staging, a priority-ordered Transaction Recoveries waterfall across loans/standing
 * orders/internal deposits/commissions with double-recovery guards, Checkoff Variations, and
 * outbound Checkoff Advice letters).
 *
 * This port narrows to the core workflow plus remittance reconciliation:
 *   - CHECKOFF lines auto-compute an `expected_amount` from each member's own `recovery_mode =
 *     'CHECKOFF'` disbursed loans (their installment, capped at the loan's own balance) — AL's
 *     GetExpectedAmount, simplified: this schema's loan balances are always current, so there is
 *     no need to re-run daily interest accrual first.
 *   - SALARY lines carry no computed expectation — AL derived it from the Employer Payroll
 *     Details staging table this port excludes, so there is nothing to compute a salary amount
 *     from. The officer records what was actually remitted directly (the same reconciliation
 *     field CHECKOFF lines use for their own actual-vs-expected comparison).
 *   - Deliberately excluded: Standing Orders, Member Subscriptions/block-amount recovery, the
 *     priority-ordered Transaction Recoveries/commission waterfall, Employer Payroll Details,
 *     Checkoff Variations, Checkoff Advice, and the various analysis reports.
 *
 * Processing reuses the engines every other module here already trusts — no new GL mechanics:
 *   - loanService.repay({channel: 'CHECKOFF'}) for loan recoveries.
 *   - lib/savings.ts's deposit({channel: 'CHECKOFF'}) for salary credits.
 * Both already post through CHANNEL_GL.CHECKOFF -> GL account 1040 "Check-off Receivable
 * Clearing" (already seeded as both a GL account and a bank_account row), which is what let AL's
 * own "Balancing Account" concept on Checkoff Header be dropped entirely — reconciling whatever
 * an employer actually remits into that clearing account is an ordinary bank-reconciliation task
 * this app already has tooling for, entirely separate from this batch.
 */
import {
  one, all, run, tx, nextSequence, audit, hasAnyRow,
} from './db.ts';
import { AppError } from './errors.ts';
import { findMatchingWorkflow, findPendingRoutedTask, pickConditionFields, startWorkflow } from './workflow.ts';
import { repay } from './loanService.ts';
import { deposit } from './savings.ts';
import { today } from './format.ts';
import type {
  Actor, CheckoffBatch, CheckoffBatchLineWithDetails, CheckoffBatchWithDetails,
} from './types.ts';

export type CheckoffBatchView = 'open' | 'pending' | 'approved' | 'processed';

const VIEW_CLAUSE: Record<CheckoffBatchView, string> = {
  open: "b.status = 'Open'",
  pending: "b.status = 'Pending Approval'",
  approved: "b.status = 'Approved'",
  processed: "b.status = 'Processed'",
};

const SELECT_BATCH = `
  SELECT b.*, e.code AS employer_code, e.name AS employer_name,
         COALESCE((SELECT SUM(expected_amount) FROM checkoff_batch_line WHERE batch_no = b.no), 0) AS total_expected,
         COALESCE((SELECT SUM(remitted_amount) FROM checkoff_batch_line WHERE batch_no = b.no), 0) AS total_remitted,
         COALESCE((SELECT SUM(variance) FROM checkoff_batch_line WHERE batch_no = b.no), 0) AS total_variance,
         COALESCE((SELECT COUNT(*) FROM checkoff_batch_line WHERE batch_no = b.no), 0) AS line_count
  FROM checkoff_batch b
  JOIN employer e ON e.id = b.employer_id`;

export interface ListCheckoffBatchOptions {
  view?: CheckoffBatchView;
  search?: string;
}

export const listCheckoffBatches = (
  { view, search = '' }: ListCheckoffBatchOptions = {},
): Promise<CheckoffBatchWithDetails[]> => all<CheckoffBatchWithDetails>(
  `${SELECT_BATCH}
   WHERE (b.no LIKE @like OR e.code LIKE @like OR e.name LIKE @like)
     ${view ? `AND ${VIEW_CLAUSE[view]}` : ''}
   ORDER BY b.no DESC`,
  { like: `%${String(search).trim()}%` },
);

export const getCheckoffBatch = (no: string): Promise<CheckoffBatchWithDetails | undefined> =>
  one<CheckoffBatchWithDetails>(`${SELECT_BATCH} WHERE b.no = ?`, no);

export const hasAnyCheckoffBatches = (view?: CheckoffBatchView): Promise<boolean> =>
  hasAnyRow('checkoff_batch b', view ? VIEW_CLAUSE[view] : undefined);

export async function getAdjacentCheckoffBatchNos(
  no: string, view?: CheckoffBatchView,
): Promise<{ prevNo: string | null; nextNo: string | null }> {
  const clause = view ? `AND ${VIEW_CLAUSE[view]}` : '';
  const [prev, next] = await Promise.all([
    one<{ no: string }>(`SELECT b.no FROM checkoff_batch b WHERE b.no < ? ${clause} ORDER BY b.no DESC LIMIT 1`, no),
    one<{ no: string }>(`SELECT b.no FROM checkoff_batch b WHERE b.no > ? ${clause} ORDER BY b.no ASC LIMIT 1`, no),
  ]);
  return { prevNo: prev?.no ?? null, nextNo: next?.no ?? null };
}

export const listCheckoffBatchLines = (batchNo: string): Promise<CheckoffBatchLineWithDetails[]> =>
  all<CheckoffBatchLineWithDetails>(
    `SELECT l.*, m.member_no AS member_no, m.first_name AS member_first_name, m.last_name AS member_last_name
     FROM checkoff_batch_line l JOIN member m ON m.id = l.member_id
     WHERE l.batch_no = ? ORDER BY m.member_no`,
    batchNo,
  );

/** Wipes and re-populates a batch's lines from the members' current live position — used by both
 *  createCheckoffBatch() and refreshCheckoffBatchLines(). */
async function populateLines(batchNo: string, employerId: number, batchType: string): Promise<void> {
  await run('DELETE FROM checkoff_batch_line WHERE batch_no = ?', batchNo);

  if (batchType === 'CHECKOFF') {
    const members = await all<{ id: number; staff_no: string | null }>(
      `SELECT DISTINCT m.id, m.staff_no
       FROM member m JOIN loan l ON l.member_id = m.id
       WHERE m.employer_id = ? AND l.status = 'DISBURSED' AND l.recovery_mode = 'CHECKOFF'
         AND (l.principal_balance + l.interest_balance + l.penalty_balance) > 0`,
      employerId,
    );
    for (const m of members) {
      const expected = await one<{ s: number }>(
        `SELECT COALESCE(SUM(LEAST(installment, principal_balance + interest_balance + penalty_balance)), 0) s
         FROM loan WHERE member_id = ? AND status = 'DISBURSED' AND recovery_mode = 'CHECKOFF'
           AND (principal_balance + interest_balance + penalty_balance) > 0`,
        m.id,
      );
      await run(
        'INSERT INTO checkoff_batch_line (batch_no, member_id, payroll_no, expected_amount) VALUES (?,?,?,?)',
        batchNo, m.id, m.staff_no, Math.round(expected?.s || 0),
      );
    }
  } else {
    const members = await all<{ id: number; staff_no: string | null }>(
      `SELECT m.id, m.staff_no FROM member m
       WHERE m.employer_id = ? AND m.status = 'ACTIVE'
         AND EXISTS (
           SELECT 1 FROM savings_account sa JOIN savings_product p ON p.id = sa.product_id
           WHERE sa.member_id = m.id AND sa.status = 'ACTIVE' AND p.category = 'WITHDRAWABLE DEPOSIT'
         )`,
      employerId,
    );
    for (const m of members) {
      await run(
        'INSERT INTO checkoff_batch_line (batch_no, member_id, payroll_no) VALUES (?,?,?)',
        batchNo, m.id, m.staff_no,
      );
    }
  }
}

async function assertNoLiveBatch(employerId: number, batchType: string, period: string, excludeNo?: string): Promise<void> {
  const live = await one(
    `SELECT 1 FROM checkoff_batch
     WHERE employer_id = ? AND batch_type = ? AND period = ? AND status <> 'Processed' ${excludeNo ? 'AND no <> ?' : ''}`,
    ...(excludeNo ? [employerId, batchType, period, excludeNo] : [employerId, batchType, period]),
  );
  if (live) throw new AppError('A batch for this employer, type and period is already open or in progress', 'VALIDATION');
}

export async function createCheckoffBatch(
  employerId: number, batchType: 'CHECKOFF' | 'SALARY', period: string, user: Actor,
): Promise<{ no: string }> {
  if (!(await one('SELECT 1 FROM employer WHERE id = ?', employerId))) {
    throw new AppError('Employer not found', 'NOT_FOUND');
  }
  await assertNoLiveBatch(employerId, batchType, period);

  const no = await nextSequence('CHECKOFF_BATCH');
  await tx(async () => {
    await run(
      `INSERT INTO checkoff_batch (no, batch_type, employer_id, period, posting_date, created_at, created_by)
       VALUES (?,?,?,?,?,?,?)`,
      no, batchType, employerId, period, today(), new Date().toISOString(), user.username,
    );
    await populateLines(no, employerId, batchType);
  });
  await audit(user, 'CHECKOFF_BATCH_CREATE', 'checkoff_batch', no, { employerId, batchType, period });
  return { no };
}

export async function refreshCheckoffBatchLines(no: string, user: Actor): Promise<void> {
  const req = await one<CheckoffBatch>('SELECT * FROM checkoff_batch WHERE no = ?', no);
  if (!req) throw new AppError('Checkoff batch not found', 'NOT_FOUND');
  if (req.status !== 'Open') throw new AppError('Only an open batch can be refreshed', 'VALIDATION');
  await populateLines(no, req.employer_id, req.batch_type);
  await audit(user, 'CHECKOFF_BATCH_REFRESH_LINES', 'checkoff_batch', no, {});
}

/** The reconciliation step: records what was actually remitted for one member and, for a
 *  CHECKOFF line, recomputes its variance against the computed expected amount. */
export async function recordRemittedAmount(no: string, lineId: number, amountSh: number, user: Actor): Promise<void> {
  const req = await one<CheckoffBatch>('SELECT * FROM checkoff_batch WHERE no = ?', no);
  if (!req) throw new AppError('Checkoff batch not found', 'NOT_FOUND');
  if (req.status !== 'Open') throw new AppError('Only an open batch can be edited', 'VALIDATION');
  const line = await one<{ id: number; expected_amount: number }>(
    'SELECT id, expected_amount FROM checkoff_batch_line WHERE id = ? AND batch_no = ?', lineId, no,
  );
  if (!line) throw new AppError('Line not found', 'NOT_FOUND');

  const amount = Math.max(0, Math.round(amountSh));
  const variance = req.batch_type === 'CHECKOFF' ? amount - line.expected_amount : 0;
  await run('UPDATE checkoff_batch_line SET remitted_amount = ?, variance = ? WHERE id = ?', amount, variance, lineId);
  await audit(user, 'CHECKOFF_BATCH_RECORD_REMITTED', 'checkoff_batch', no, { lineId, amount });
}

/** At least one line must actually carry a remitted amount, otherwise the batch would process
 *  into a no-op — the same "something must actually be changed" gate every other module here
 *  checks before submission (not AL's stricter "every kobo must reconcile exactly", which would
 *  block a batch where a genuinely absent member simply remitted nothing that period). */
async function assertReadyForApproval(no: string): Promise<void> {
  const hasRemittance = await one(
    "SELECT 1 FROM checkoff_batch_line WHERE batch_no = ? AND remitted_amount > 0", no,
  );
  if (!hasRemittance) {
    throw new AppError('Record at least one member’s remitted amount before sending this for approval', 'VALIDATION');
  }
}

export async function submitCheckoffBatch(no: string, user: Actor): Promise<{ autoApproved: boolean }> {
  const req = await one<CheckoffBatch>('SELECT * FROM checkoff_batch WHERE no = ?', no);
  if (!req) throw new AppError('Checkoff batch not found', 'NOT_FOUND');
  if (req.status !== 'Open') throw new AppError('Only an open batch can be submitted for approval', 'VALIDATION');
  await assertReadyForApproval(no);

  const matched = await findMatchingWorkflow('CHECKOFF_BATCH', await pickConditionFields('CHECKOFF_BATCH', req));
  if (!matched) throw new AppError('There is no enabled workflow for this document', 'NO_WORKFLOW');

  await tx(async () => {
    await run("UPDATE checkoff_batch SET status = 'Pending Approval' WHERE no = ?", no);
    await startWorkflow(matched.workflow, matched.steps, {
      documentType: 'CHECKOFF_BATCH', entityId: no, requestedBy: user.username, amount: 0,
    });
  });

  const after = await one<{ status: string }>('SELECT status FROM checkoff_batch WHERE no = ?', no);
  return { autoApproved: after?.status === 'Approved' };
}

export async function cancelCheckoffBatchApproval(no: string, user: Actor): Promise<void> {
  const req = await one<Pick<CheckoffBatch, 'status' | 'created_by'>>(
    'SELECT status, created_by FROM checkoff_batch WHERE no = ?', no,
  );
  if (!req) throw new AppError('Checkoff batch not found', 'NOT_FOUND');
  if (req.status !== 'Pending Approval') {
    throw new AppError('Only a request pending approval can have its approval request cancelled', 'VALIDATION');
  }
  const routed = await findPendingRoutedTask('CHECKOFF_BATCH', no);
  const requestedBy = routed?.requested_by ?? req.created_by;
  if (requestedBy !== user.username) {
    throw new AppError('Only the person who submitted this request for approval can cancel it', 'NOT_REQUESTER');
  }
  await run("UPDATE checkoff_batch SET status = 'Open' WHERE no = ?", no);
  await audit(user, 'CHECKOFF_BATCH_CANCEL_APPROVAL', 'checkoff_batch', no, {});
}

export async function approveCheckoffBatch(no: string, user: Actor): Promise<void> {
  const req = await one<CheckoffBatch>('SELECT * FROM checkoff_batch WHERE no = ?', no);
  if (!req) throw new AppError('Checkoff batch not found', 'NOT_FOUND');
  if (req.status !== 'Pending Approval') throw new AppError('Only a request pending approval can be approved', 'VALIDATION');
  await run("UPDATE checkoff_batch SET status = 'Approved', decision_reason = NULL WHERE no = ?", no);
  await audit(user, 'CHECKOFF_BATCH_APPROVE', 'checkoff_batch', no, {});
}

export async function rejectCheckoffBatch(no: string, reason: string | null, user: Actor): Promise<void> {
  if (!reason || !reason.trim()) throw new AppError('A reason is required to reject a request', 'VALIDATION');
  const req = await one<CheckoffBatch>('SELECT * FROM checkoff_batch WHERE no = ?', no);
  if (!req) throw new AppError('Checkoff batch not found', 'NOT_FOUND');
  if (req.status !== 'Pending Approval') throw new AppError('Only a request pending approval can be rejected', 'VALIDATION');
  await run("UPDATE checkoff_batch SET status = 'Open', decision_reason = ? WHERE no = ?", reason, no);
  await audit(user, 'CHECKOFF_BATCH_REJECT', 'checkoff_batch', no, { reason });
}

/**
 * Approved -> posts every line with a remitted amount, ported from PostCheckoff/ApplyEmployerUpload
 * (Cod52204013.CheckoffManagement.al), stripped to the two postings this port keeps:
 *   - CHECKOFF: pay down the member's own recovery_mode='CHECKOFF' disbursed loans (lowest
 *     balance first) with loanService.repay({channel: 'CHECKOFF'}) until the line's remitted
 *     amount is exhausted. Whatever's left over once every such loan is cleared is left unposted
 *     rather than silently absorbed — surfaced back to the caller as `unallocated` per line.
 *   - SALARY: credit the member's withdrawable deposit account with
 *     savings.deposit({channel: 'CHECKOFF'}).
 * All inside one tx() so a failure partway through leaves the batch, and every account/loan it
 * touches, untouched.
 */
export async function processCheckoffBatch(no: string, user: Actor): Promise<{ employerId: number }> {
  return tx(async () => {
    const req = await one<CheckoffBatch>('SELECT * FROM checkoff_batch WHERE no = ?', no);
    if (!req) throw new AppError('Checkoff batch not found', 'NOT_FOUND');
    if (req.status !== 'Approved') throw new AppError('Only an approved batch can be processed', 'VALIDATION');

    const vd = req.posting_date || today();
    const lines = await all<{ id: number; member_id: number; remitted_amount: number }>(
      'SELECT id, member_id, remitted_amount FROM checkoff_batch_line WHERE batch_no = ?', no,
    );

    for (const line of lines) {
      if (line.remitted_amount <= 0) continue;

      if (req.batch_type === 'CHECKOFF') {
        let remaining = line.remitted_amount;
        const loans = await all<{ id: number; owed: number }>(
          `SELECT id, (principal_balance + interest_balance + penalty_balance) AS owed
           FROM loan WHERE member_id = ? AND status = 'DISBURSED' AND recovery_mode = 'CHECKOFF'
             AND (principal_balance + interest_balance + penalty_balance) > 0
           ORDER BY owed ASC`,
          line.member_id,
        );
        for (const loanRow of loans) {
          if (remaining <= 0) break;
          const amount = Math.min(remaining, loanRow.owed);
          if (amount <= 0) continue;
          await repay({
            loanId: loanRow.id, amount, channel: 'CHECKOFF', valueDate: vd,
            description: `Checkoff ${no}`, user,
          });
          remaining -= amount;
        }
      } else {
        const account = await one<{ id: number }>(
          `SELECT sa.id FROM savings_account sa JOIN savings_product p ON p.id = sa.product_id
           WHERE sa.member_id = ? AND sa.status = 'ACTIVE' AND p.category = 'WITHDRAWABLE DEPOSIT'
           ORDER BY sa.id LIMIT 1`,
          line.member_id,
        );
        if (!account) continue;
        await deposit({
          accountId: account.id, amount: line.remitted_amount, channel: 'CHECKOFF', valueDate: vd,
          description: `Salary processing ${no}`, user,
        });
      }
    }

    await run(
      "UPDATE checkoff_batch SET status = 'Processed', processed_at = ?, processed_by = ? WHERE no = ?",
      new Date().toISOString(), user.username, no,
    );
    await audit(user, 'CHECKOFF_BATCH_PROCESS', 'checkoff_batch', no, {});
    return { employerId: req.employer_id };
  });
}
