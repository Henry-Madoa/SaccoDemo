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
 *     from. Instead, a CSV upload (applyCheckoffCsvUpload(), ApplyEmployerUpload's own role
 *     narrowed to apply straight onto this batch's lines rather than a separate staging table)
 *     or a manual entry (recordRemittedAmount()) records what was actually remitted, and
 *     Calculate (calculateCheckoffRecoveries()) then runs the batch's attached Transaction
 *     Charge and Transaction Recoveries waterfall (lib/charges.ts, lib/types.ts's
 *     TransactionRecovery) against it — CalculateRecoveries narrowed to the two recovery types
 *     this port can act on without further master data (see TransactionRecoveryType).
 *   - Deliberately excluded: Standing Order as a Transaction Recovery type (this app's own
 *     Standing Order module already recovers on its own independent daily schedule — see
 *     lib/standingOrders.ts), Member Subscriptions/block-amount recovery, the ongoing Employer
 *     Payroll Details staging table (a CSV upload is applied directly instead), Checkoff
 *     Variations, Checkoff Advice, and the various analysis reports.
 *
 * Processing reuses the engines every other module here already trusts — no new GL mechanics:
 *   - loanService.repay({channel: 'CHECKOFF'}) for loan recoveries.
 *   - lib/savings.ts's deposit({channel: 'CHECKOFF'}) for salary credits and internal-deposit
 *     recoveries.
 *   - lib/charges.ts's postTransactionCharges() for a SALARY batch's charge components.
 * All post through CHANNEL_GL.CHECKOFF -> GL account 1040 "Check-off Receivable Clearing"
 * (already seeded as both a GL account and a bank_account row), which is what let AL's own
 * "Balancing Account" concept on Checkoff Header be dropped entirely — reconciling whatever an
 * employer actually remits into that clearing account is an ordinary bank-reconciliation task
 * this app already has tooling for, entirely separate from this batch.
 */
import {
  one, all, run, tx, nextSequence, audit, hasAnyRow,
} from './db.ts';
import { AppError } from './errors.ts';
import { findMatchingWorkflow, findPendingRoutedTask, pickConditionFields, startWorkflow } from './workflow.ts';
import { repay } from './loanService.ts';
import { deposit, CHANNEL_GL } from './savings.ts';
import { today } from './format.ts';
import { parseCsv } from './csv.ts';
import * as chargesLib from './charges.ts';
import type {
  Actor, Cents, CheckoffBatch, CheckoffBatchLineWithDetails, CheckoffBatchWithDetails, CheckoffSearchType,
  TransactionCharge,
} from './types.ts';

export type CheckoffBatchView = 'open' | 'pending' | 'approved' | 'processed';

const VIEW_CLAUSE: Record<CheckoffBatchView, string> = {
  open: "b.status = 'Open'",
  pending: "b.status = 'Pending Approval'",
  approved: "b.status = 'Approved'",
  processed: "b.status = 'Processed'",
};

const SELECT_BATCH = `
  SELECT b.*, e.code AS employer_code, e.name AS employer_name, tc.code AS transaction_charge_code,
         COALESCE((SELECT SUM(expected_amount) FROM checkoff_batch_line WHERE batch_no = b.no), 0) AS total_expected,
         COALESCE((SELECT SUM(remitted_amount) FROM checkoff_batch_line WHERE batch_no = b.no), 0) AS total_remitted,
         COALESCE((SELECT SUM(variance) FROM checkoff_batch_line WHERE batch_no = b.no), 0) AS total_variance,
         COALESCE((SELECT SUM(uploaded_amount) FROM checkoff_batch_line WHERE batch_no = b.no), 0) AS total_uploaded,
         COALESCE((SELECT COUNT(*) FROM checkoff_batch_line WHERE batch_no = b.no AND NOT matched), 0) AS unmatched_count,
         COALESCE((SELECT COUNT(*) FROM checkoff_batch_line WHERE batch_no = b.no), 0) AS line_count,
         EXISTS(SELECT 1 FROM checkoff_calculation WHERE batch_no = b.no) AS calculated
  FROM checkoff_batch b
  JOIN employer e ON e.id = b.employer_id
  LEFT JOIN transaction_charge tc ON tc.id = b.transaction_charge_id`;

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
  // Calculate's own rows reference a line id, so they must go before the lines they reference do.
  await run('DELETE FROM checkoff_calculation WHERE batch_no = ?', batchNo);
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
  transactionChargeId?: number | null, searchType: CheckoffSearchType = 'PAYROLL_NO',
): Promise<{ no: string }> {
  if (!(await one('SELECT 1 FROM employer WHERE id = ?', employerId))) {
    throw new AppError('Employer not found', 'NOT_FOUND');
  }
  await assertNoLiveBatch(employerId, batchType, period);
  const chargeId = batchType === 'SALARY' ? transactionChargeId || null : null;

  const no = await nextSequence('CHECKOFF_BATCH');
  await tx(async () => {
    await run(
      `INSERT INTO checkoff_batch
         (no, batch_type, employer_id, period, posting_date, search_type, transaction_charge_id, created_at, created_by)
       VALUES (?,?,?,?,?,?,?,?,?)`,
      no, batchType, employerId, period, today(), searchType, chargeId, new Date().toISOString(), user.username,
    );
    await populateLines(no, employerId, batchType);
  });
  await audit(user, 'CHECKOFF_BATCH_CREATE', 'checkoff_batch', no, { employerId, batchType, period, chargeId, searchType });
  return { no };
}

export interface UpdateCheckoffBatchInput {
  employerId: number;
  period: string;
  postingDate?: string | null;
  description?: string | null;
  searchType?: CheckoffSearchType;
  /** SALARY only — silently ignored for a CHECKOFF batch, same as createCheckoffBatch(). */
  transactionChargeId?: number | null;
}

/**
 * Edits the batch's own header while it's still Open — ported from the AL reference's own
 * Checkoff/Salary card, where the whole "General" field group (Employer Code, Document/Posting
 * Date, Posting Description, Charge Code, ...) is `Editable = Status = Open` and locked the
 * moment it leaves Open. Changing the Employer or Period re-populates the line set from scratch
 * (populateLines() already wipes any stale Calculate output along with the old lines) since
 * those two fields are what the whole member/expected-amount population is keyed on; changing
 * just the Charge Code only needs its own stale Calculate output cleared, not a full repopulate.
 */
export async function updateCheckoffBatch(no: string, input: UpdateCheckoffBatchInput, user: Actor): Promise<void> {
  const req = await one<CheckoffBatch>('SELECT * FROM checkoff_batch WHERE no = ?', no);
  if (!req) throw new AppError('Checkoff batch not found', 'NOT_FOUND');
  if (req.status !== 'Open') throw new AppError('Only an open batch can be edited', 'VALIDATION');
  if (!input.employerId || !(await one('SELECT 1 FROM employer WHERE id = ?', input.employerId))) {
    throw new AppError('Employer not found', 'NOT_FOUND');
  }
  if (!input.period) throw new AppError('Period is required', 'VALIDATION');

  const employerOrPeriodChanged = input.employerId !== req.employer_id || input.period !== req.period;
  if (employerOrPeriodChanged) {
    await assertNoLiveBatch(input.employerId, req.batch_type, input.period, no);
  }
  const chargeId = req.batch_type === 'SALARY' ? (input.transactionChargeId ?? null) : null;
  const searchType = input.searchType || req.search_type;

  await tx(async () => {
    await run(
      `UPDATE checkoff_batch
       SET employer_id = ?, period = ?, posting_date = ?, description = ?, search_type = ?, transaction_charge_id = ?
       WHERE no = ?`,
      input.employerId, input.period, input.postingDate || null, input.description || null, searchType, chargeId, no,
    );
    if (employerOrPeriodChanged) {
      await populateLines(no, input.employerId, req.batch_type);
    } else if (chargeId !== req.transaction_charge_id) {
      await run('DELETE FROM checkoff_calculation WHERE batch_no = ?', no);
    }
  });
  await audit(user, 'CHECKOFF_BATCH_UPDATE', 'checkoff_batch', no, {
    employerId: input.employerId, period: input.period, employerOrPeriodChanged, chargeId, searchType,
  });
}

/** The Charge Code picklist for a Salary Processing batch — every enabled Transaction Charge
 *  configured for 'End Month Salary'. */
export const listSalaryChargeCodes = (): Promise<TransactionCharge[]> =>
  chargesLib.listTransactionChargesByType('End Month Salary');

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
  await tx(async () => {
    await run('UPDATE checkoff_batch_line SET remitted_amount = ?, variance = ? WHERE id = ?', amount, variance, lineId);
    // A hand-edit after Calculate invalidates that line's own breakdown — it was computed
    // against the amount just replaced. Cleared rather than left stale so
    // assertReadyForApproval()'s "must have been Calculated" gate catches it again.
    await run('DELETE FROM checkoff_calculation WHERE line_id = ?', lineId);
  });
  await audit(user, 'CHECKOFF_BATCH_RECORD_REMITTED', 'checkoff_batch', no, { lineId, amount });
}

/** Which CSV header names identify the "who" column, per Search Type — ported from the AL
 *  reference's "CheckOff Search Type" enum (Enum52204034). */
const CSV_ID_HEADERS: Record<CheckoffSearchType, string[]> = {
  MEMBER_NO: ['member no', 'member no.', 'member number'],
  ID_NUMBER: ['id number', 'id no', 'id no.', 'identification no', 'identification no.', 'national id'],
  PAYROLL_NO: ['payroll no', 'payroll no.', 'staff no', 'staff no.', 'employee no', 'payroll number', 'staff number'],
  FOSA_NUMBER: ['fosa no', 'fosa no.', 'fosa number', 'account no', 'account no.', 'account number'],
};
const CSV_ID_LABEL: Record<CheckoffSearchType, string> = {
  MEMBER_NO: 'Member No.', ID_NUMBER: 'ID Number', PAYROLL_NO: 'Payroll No./Staff No.', FOSA_NUMBER: 'FOSA No./Account No.',
};
const CSV_NAME_HEADERS = ['name', 'employee name', 'member name'];
const CSV_AMOUNT_HEADERS = ['amount', 'remitted amount', 'salary', 'net pay'];

function findCsvColumn(header: string[], candidates: string[]): number {
  const lower = header.map((h) => h.trim().toLowerCase());
  for (const c of candidates) {
    const idx = lower.indexOf(c);
    if (idx !== -1) return idx;
  }
  return -1;
}

/**
 * Resolves one uploaded row's raw identifier to a member id, per the batch's own Search Type —
 * ported from GetMemberNo (Cod52204013.CheckoffManagement.al), dropping its "Old FOSA Number"
 * case and its 'SUSP:'-prefixed suspense fallback (this port has no suspense account/table to
 * post an unresolved row to; applyCheckoffCsvUpload() reports it back as an unmatched row
 * instead). FOSA Number resolves against savings_account.account_no directly, the same way AL's
 * own Vendor.Get(CheckNo) resolves against a Vendor's own No. with no product-type filter.
 */
async function resolveMemberIdBySearchType(
  searchType: CheckoffSearchType, checkNo: string, employerId: number,
): Promise<number | null> {
  switch (searchType) {
    case 'MEMBER_NO': {
      const m = await one<{ id: number }>('SELECT id FROM member WHERE LOWER(member_no) = LOWER(?)', checkNo);
      return m?.id ?? null;
    }
    case 'ID_NUMBER': {
      const m = await one<{ id: number }>('SELECT id FROM member WHERE LOWER(identification_no) = LOWER(?)', checkNo);
      return m?.id ?? null;
    }
    case 'FOSA_NUMBER': {
      const a = await one<{ member_id: number }>('SELECT member_id FROM savings_account WHERE LOWER(account_no) = LOWER(?)', checkNo);
      return a?.member_id ?? null;
    }
    case 'PAYROLL_NO':
    default: {
      const m = await one<{ id: number }>(
        'SELECT id FROM member WHERE LOWER(staff_no) = LOWER(?) AND employer_id = ?', checkNo, employerId,
      );
      return m?.id ?? null;
    }
  }
}

export interface CheckoffCsvUploadResult {
  matchedCount: number;
  unmatchedRows: string[];
  totalUploaded: Cents;
}

/**
 * Ported from ApplyEmployerUpload (Cod52204013.CheckoffManagement.al), narrowed since this port
 * has no separate Employer Payroll Details staging table: applies a CSV (an identifier column —
 * shape driven by the batch's own Search Type — plus Name and Amount) straight onto the batch's
 * own lines. Each row's identifier is resolved to a member id per Search Type
 * (resolveMemberIdBySearchType(), GetMemberNo()'s own dispatch), then matched against this
 * batch's own line set. A matched row also overwrites that line's remitted_amount, so it's ready
 * to Validate/Calculate/submit without a separate manual entry pass — the officer only needs to
 * hand-edit a line afterward to correct or override what the file said. Unmatched rows (no
 * member resolves, or the resolved member isn't a line of this batch) are reported back rather
 * than silently dropped, mirroring AL's own Suspense Account fallback in spirit without needing
 * a dedicated suspense posting of its own.
 */
export async function applyCheckoffCsvUpload(no: string, csvText: string, user: Actor): Promise<CheckoffCsvUploadResult> {
  const req = await one<CheckoffBatch>('SELECT * FROM checkoff_batch WHERE no = ?', no);
  if (!req) throw new AppError('Checkoff batch not found', 'NOT_FOUND');
  if (req.status !== 'Open') throw new AppError('Only an open batch can be updated from a CSV upload', 'VALIDATION');

  const rows = parseCsv(csvText);
  if (rows.length < 2) throw new AppError('The CSV file has no data rows', 'VALIDATION');
  const [header, ...dataRows] = rows;
  const idCol = findCsvColumn(header, CSV_ID_HEADERS[req.search_type]);
  const nameCol = findCsvColumn(header, CSV_NAME_HEADERS);
  const amountCol = findCsvColumn(header, CSV_AMOUNT_HEADERS);
  if (idCol === -1 || amountCol === -1) {
    throw new AppError(`The CSV must have a ${CSV_ID_LABEL[req.search_type]} column and an Amount column`, 'VALIDATION');
  }

  const lines = await all<{ id: number; member_id: number; expected_amount: number }>(
    'SELECT id, member_id, expected_amount FROM checkoff_batch_line WHERE batch_no = ?', no,
  );
  const lineByMemberId = new Map(lines.map((l) => [l.member_id, l]));

  let matchedCount = 0;
  let totalUploaded = 0;
  const unmatchedRows: string[] = [];

  await tx(async () => {
    await run(
      "UPDATE checkoff_batch_line SET uploaded_amount = 0, uploaded_name = NULL, matched = false WHERE batch_no = ?", no,
    );
    // An upload replaces remitted_amount for every matched line, invalidating any prior
    // Calculate breakdown for this batch — same reasoning as recordRemittedAmount()'s own clear.
    await run('DELETE FROM checkoff_calculation WHERE batch_no = ?', no);
    for (const row of dataRows) {
      if (!row.some((c) => c.trim())) continue;
      const checkNo = (row[idCol] || '').trim();
      const name = nameCol !== -1 ? (row[nameCol] || '').trim() : '';
      const amount = Math.max(0, Math.round(Number(String(row[amountCol] || '0').replace(/,/g, '')) * 100)) || 0;
      if (!checkNo) continue;

      const memberId = await resolveMemberIdBySearchType(req.search_type, checkNo, req.employer_id);
      const line = memberId != null ? lineByMemberId.get(memberId) : undefined;
      if (!line) {
        unmatchedRows.push(`${checkNo}${name ? ` (${name})` : ''}`);
        continue;
      }
      const variance = req.batch_type === 'CHECKOFF' ? amount - line.expected_amount : 0;
      await run(
        `UPDATE checkoff_batch_line
         SET uploaded_amount = ?, uploaded_name = ?, matched = true, remitted_amount = ?, variance = ?
         WHERE id = ?`,
        amount, name || null, amount, variance, line.id,
      );
      matchedCount += 1;
      totalUploaded += amount;
    }
  });

  await audit(user, 'CHECKOFF_BATCH_CSV_UPLOAD', 'checkoff_batch', no, {
    matchedCount, unmatchedCount: unmatchedRows.length, totalUploaded, searchType: req.search_type,
  });
  return { matchedCount, unmatchedRows, totalUploaded };
}

export interface CheckoffValidationResult {
  totalRemitted: Cents;
  totalUploaded: Cents;
  tallyVariance: Cents;
  unmatchedCount: number;
  mismatchedLines: { lineId: number; memberName: string; remitted: Cents; uploaded: Cents }[];
}

/**
 * Ported from ValidateUpload (Cod52204013.CheckoffManagement.al): a non-blocking tally of what
 * the CSV upload carried against what the card currently shows (an officer may have hand-edited
 * a line's remitted amount after uploading), surfaced for review before Calculate/submission
 * rather than enforced as a hard gate — the same posture AL's own ValidateUpload takes.
 */
export async function validateCheckoffBatch(no: string, user: Actor): Promise<CheckoffValidationResult> {
  const req = await getCheckoffBatch(no);
  if (!req) throw new AppError('Checkoff batch not found', 'NOT_FOUND');
  const lines = await listCheckoffBatchLines(no);
  const mismatched = lines.filter((l) => l.uploaded_amount > 0 && l.uploaded_amount !== l.remitted_amount);

  const result: CheckoffValidationResult = {
    totalRemitted: req.total_remitted,
    totalUploaded: req.total_uploaded,
    tallyVariance: req.total_remitted - req.total_uploaded,
    unmatchedCount: req.unmatched_count,
    mismatchedLines: mismatched.map((l) => ({
      lineId: l.id, memberName: `${l.member_first_name} ${l.member_last_name}`,
      remitted: l.remitted_amount, uploaded: l.uploaded_amount,
    })),
  };
  await audit(user, 'CHECKOFF_BATCH_VALIDATE', 'checkoff_batch', no, {
    tallyVariance: result.tallyVariance, unmatchedCount: result.unmatchedCount, mismatchedCount: mismatched.length,
  });
  return result;
}

/**
 * SALARY only — ported from CalculateRecoveries (Cod52204013.CheckoffManagement.al): applies the
 * batch's attached Transaction Charge components to each line's remitted amount, then its
 * Transaction Recoveries by ascending Priority (Loan first-come-first-served by lowest balance,
 * Internal Deposit against the configured savings product), writing every step to
 * checkoff_calculation for review before Send for approval. Whatever is left after every
 * recovery is exhausted is recorded as a NET_AMOUNT row — what processCheckoffBatch() deposits
 * to the member's own withdrawable account. Re-running Calculate wipes and rebuilds this batch's
 * rows from scratch, so it's always safe to re-run after editing a line.
 */
export async function calculateCheckoffRecoveries(no: string, user: Actor): Promise<{ linesCalculated: number }> {
  const req = await one<CheckoffBatch>('SELECT * FROM checkoff_batch WHERE no = ?', no);
  if (!req) throw new AppError('Checkoff batch not found', 'NOT_FOUND');
  if (req.status !== 'Open') throw new AppError('Only an open batch can be calculated', 'VALIDATION');
  if (req.batch_type !== 'SALARY') throw new AppError('Calculate only applies to Salary Processing batches', 'VALIDATION');
  if (!req.transaction_charge_id) throw new AppError('Attach a Charge Code to this batch before calculating', 'VALIDATION');

  const detail = await chargesLib.getTransactionCharge(req.transaction_charge_id);
  if (!detail) throw new AppError('Charge Code not found', 'NOT_FOUND');
  const activeRecoveries = detail.recoveries.filter((r) => r.status === 'ACTIVE').sort((a, b) => a.priority - b.priority);

  const lines = await all<{ id: number; member_id: number; remitted_amount: number }>(
    'SELECT id, member_id, remitted_amount FROM checkoff_batch_line WHERE batch_no = ?', no,
  );

  let linesCalculated = 0;
  await tx(async () => {
    await run('DELETE FROM checkoff_calculation WHERE batch_no = ?', no);

    for (const line of lines) {
      if (line.remitted_amount <= 0) continue;
      let remaining = line.remitted_amount;

      const charges = chargesLib.calculateTransactionCharges(detail, line.remitted_amount);
      for (const c of charges) {
        const amt = Math.min(remaining, c.amount);
        if (amt <= 0) continue;
        await run(
          `INSERT INTO checkoff_calculation (batch_no, line_id, entry_type, description, gl_account_id, amount)
           VALUES (?,?,?,?,?,?)`,
          no, line.id, 'CHARGE', c.chargeCode, c.glAccountId, amt,
        );
        remaining -= amt;
      }

      for (const rec of activeRecoveries) {
        if (remaining <= 0) break;

        if (rec.recovery_type === 'LOAN') {
          const loans = await all<{ id: number; owed: number; installment: number; arrears_amount: number }>(
            `SELECT id, (principal_balance + interest_balance + penalty_balance) AS owed, installment, arrears_amount
             FROM loan WHERE member_id = ? AND status = 'DISBURSED' AND recovery_mode = 'CHECKOFF'
               AND (principal_balance + interest_balance + penalty_balance) > 0
             ORDER BY owed ASC`,
            line.member_id,
          );
          for (const loanRow of loans) {
            if (remaining <= 0) break;
            const target = rec.deduction_type === 'ARREARS' ? Math.min(loanRow.arrears_amount, loanRow.owed)
              : rec.deduction_type === 'BALANCE' ? loanRow.owed
                : Math.min(loanRow.installment, loanRow.owed);
            const amt = Math.min(remaining, target);
            if (amt <= 0) continue;
            await run(
              `INSERT INTO checkoff_calculation (batch_no, line_id, entry_type, description, loan_id, amount)
               VALUES (?,?,?,?,?,?)`,
              no, line.id, 'LOAN_RECOVERY', rec.description || 'Loan recovery', loanRow.id, amt,
            );
            remaining -= amt;
          }
        } else {
          const account = await one<{ id: number; balance: number; min_balance: number }>(
            `SELECT sa.id, sa.balance, p.min_balance FROM savings_account sa JOIN savings_product p ON p.id = sa.product_id
             WHERE sa.member_id = ? AND sa.product_id = ? AND sa.status = 'ACTIVE' ORDER BY sa.id LIMIT 1`,
            line.member_id, rec.savings_product_id,
          );
          if (!account) continue;
          const target = rec.deduction_type === 'BOOST_TO_MINIMUM'
            ? Math.max(0, account.min_balance - account.balance)
            : remaining;
          const amt = Math.min(remaining, target);
          if (amt <= 0) continue;
          await run(
            `INSERT INTO checkoff_calculation (batch_no, line_id, entry_type, description, savings_account_id, amount)
             VALUES (?,?,?,?,?,?)`,
            no, line.id, 'INTERNAL_DEPOSIT', rec.description || 'Internal deposit', account.id, amt,
          );
          remaining -= amt;
        }
      }

      if (remaining > 0) {
        await run(
          `INSERT INTO checkoff_calculation (batch_no, line_id, entry_type, description, amount) VALUES (?,?,?,?,?)`,
          no, line.id, 'NET_AMOUNT', 'Net amount to savings', remaining,
        );
      }
      linesCalculated += 1;
    }
  });

  await audit(user, 'CHECKOFF_BATCH_CALCULATE', 'checkoff_batch', no, { linesCalculated });
  return { linesCalculated };
}

export interface CheckoffCalculationWithDetail {
  id: number;
  batch_no: string;
  line_id: number;
  entry_type: string;
  description: string;
  loan_id: number | null;
  loan_no: string | null;
  savings_account_id: number | null;
  savings_account_no: string | null;
  gl_account_id: number | null;
  gl_account_code: string | null;
  amount: Cents;
}

/** Calculate's breakdown for a batch — the source both processCheckoffBatch() posts from and
 *  the view page shows as a "here's what will post" review before Send for approval. */
export const listCheckoffCalculations = (no: string): Promise<CheckoffCalculationWithDetail[]> =>
  all<CheckoffCalculationWithDetail>(
    `SELECT c.*, l.loan_no, sa.account_no AS savings_account_no, g.code AS gl_account_code
     FROM checkoff_calculation c
     LEFT JOIN loan l ON l.id = c.loan_id
     LEFT JOIN savings_account sa ON sa.id = c.savings_account_id
     LEFT JOIN gl_account g ON g.id = c.gl_account_id
     WHERE c.batch_no = ? ORDER BY c.line_id, c.id`,
    no,
  );

/** At least one line must actually carry a remitted amount, otherwise the batch would process
 *  into a no-op — the same "something must actually be changed" gate every other module here
 *  checks before submission (not AL's stricter "every kobo must reconcile exactly", which would
 *  block a batch where a genuinely absent member simply remitted nothing that period). A SALARY
 *  batch with a Charge Code attached must also have been Calculated, so what's approved is
 *  exactly what processCheckoffBatch() will post rather than a stale or never-run breakdown. */
async function assertReadyForApproval(no: string, req: CheckoffBatch): Promise<void> {
  const hasRemittance = await one(
    "SELECT 1 FROM checkoff_batch_line WHERE batch_no = ? AND remitted_amount > 0", no,
  );
  if (!hasRemittance) {
    throw new AppError('Record at least one member’s remitted amount before sending this for approval', 'VALIDATION');
  }
  if (req.batch_type === 'SALARY' && req.transaction_charge_id) {
    const calculated = await one('SELECT 1 FROM checkoff_calculation WHERE batch_no = ?', no);
    if (!calculated) {
      throw new AppError('Run Calculate before sending this batch for approval', 'VALIDATION');
    }
  }
}

export async function submitCheckoffBatch(no: string, user: Actor): Promise<{ autoApproved: boolean }> {
  const req = await one<CheckoffBatch>('SELECT * FROM checkoff_batch WHERE no = ?', no);
  if (!req) throw new AppError('Checkoff batch not found', 'NOT_FOUND');
  if (req.status !== 'Open') throw new AppError('Only an open batch can be submitted for approval', 'VALIDATION');
  await assertReadyForApproval(no, req);

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

/** Every SALARY line's own withdrawable deposit account — the fallback deposit target both the
 *  no-Calculate path and a Calculate NET_AMOUNT row post the leftover amount to. */
async function memberWithdrawableAccountId(memberId: number): Promise<number | undefined> {
  const account = await one<{ id: number }>(
    `SELECT sa.id FROM savings_account sa JOIN savings_product p ON p.id = sa.product_id
     WHERE sa.member_id = ? AND sa.status = 'ACTIVE' AND p.category = 'WITHDRAWABLE DEPOSIT'
     ORDER BY sa.id LIMIT 1`,
    memberId,
  );
  return account?.id;
}

/**
 * Approved -> posts every line with a remitted amount, ported from PostCheckoff/ApplyEmployerUpload
 * (Cod52204013.CheckoffManagement.al):
 *   - CHECKOFF: pay down the member's own recovery_mode='CHECKOFF' disbursed loans (lowest
 *     balance first) with loanService.repay({channel: 'CHECKOFF'}) until the line's remitted
 *     amount is exhausted. Whatever's left over once every such loan is cleared is left unposted
 *     rather than silently absorbed — surfaced back to the caller as `unallocated` per line.
 *   - SALARY, Calculate never run for this line (no checkoff_calculation rows — a batch with no
 *     Charge Code attached, per assertReadyForApproval()'s gate): the whole remitted amount goes
 *     straight to the member's withdrawable deposit account, same as before Calculate existed.
 *   - SALARY, Calculate has run: posts exactly what Calculate found, rather than recomputing —
 *     the batch's Transaction Charge components (via postTransactionCharges(), deterministic
 *     against the same remitted amount and charge config Calculate used), each stored
 *     LOAN_RECOVERY row (loanService.repay()), each stored INTERNAL_DEPOSIT row
 *     (savings.deposit() into that recovery's configured product account), and the stored
 *     NET_AMOUNT row (savings.deposit() into the member's own withdrawable account).
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
        continue;
      }

      const calcRows = await all<{
        id: number; entry_type: string; loan_id: number | null; savings_account_id: number | null; amount: number;
      }>(
        'SELECT id, entry_type, loan_id, savings_account_id, amount FROM checkoff_calculation WHERE line_id = ? ORDER BY id',
        line.id,
      );

      if (!calcRows.length) {
        const accountId = await memberWithdrawableAccountId(line.member_id);
        if (!accountId) continue;
        await deposit({
          accountId, amount: line.remitted_amount, channel: 'CHECKOFF', valueDate: vd,
          description: `Salary processing ${no}`, user,
        });
        continue;
      }

      if (req.transaction_charge_id && calcRows.some((c) => c.entry_type === 'CHARGE')) {
        await chargesLib.postTransactionCharges({
          transactionChargeId: req.transaction_charge_id, baseAmount: line.remitted_amount,
          debitAccountCode: CHANNEL_GL.CHECKOFF, valueDate: vd, module: 'CHECKOFF',
          eventType: 'End Month Salary', memberId: line.member_id,
          description: `Salary processing ${no}`, reference: no, user,
        });
      }
      for (const calc of calcRows) {
        if (calc.entry_type === 'LOAN_RECOVERY' && calc.loan_id) {
          await repay({
            loanId: calc.loan_id, amount: calc.amount, channel: 'CHECKOFF', valueDate: vd,
            description: `Checkoff ${no}`, user,
          });
        } else if (calc.entry_type === 'INTERNAL_DEPOSIT' && calc.savings_account_id) {
          await deposit({
            accountId: calc.savings_account_id, amount: calc.amount, channel: 'CHECKOFF', valueDate: vd,
            description: `Salary processing ${no}`, user,
          });
        } else if (calc.entry_type === 'NET_AMOUNT') {
          const accountId = await memberWithdrawableAccountId(line.member_id);
          if (accountId) {
            await deposit({
              accountId, amount: calc.amount, channel: 'CHECKOFF', valueDate: vd,
              description: `Salary processing ${no}`, user,
            });
          }
        }
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
