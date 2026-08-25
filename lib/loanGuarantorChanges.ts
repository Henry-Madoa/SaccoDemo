/*
 * Guarantor Change Management — a maker-checker request to release and/or substitute one or more
 * guarantors on an already-disbursed loan. Ported from the AL reference's "Loan Security Mgmt."
 * card (Pag52204104 + Tab52204085/58/59), narrowed to Security Type = Guarantor only — collateral
 * already has its own release lifecycle via lib/collateralReleases.ts, and this schema has no row
 * to represent a self-guarantee substitution (see addReplacement() below), unlike AL's Det. Lines.
 *
 * Same Open -> Pending Approval -> Approved -> Processed shape as collateral releases, but with an
 * extra line/replacement level: one line per guarantor COMMITTED to the loan when the document was
 * opened (or last refreshed), each either marked for outright release or covered by one or more
 * replacement guarantors. Amounts are re-validated against live guarantee capacity at submit and
 * at process time — never trusted from what was typed — the same BR-10 pattern
 * lib/collateralReleases.ts already uses for its own linked-balance check.
 */
import {
  one, all, run, tx, nextSequence, audit, hasAnyRow,
} from './db.ts';
import { AppError } from './errors.ts';
import { findMatchingWorkflow, findPendingRoutedTask, pickConditionFields, startWorkflow } from './workflow.ts';
import { guarantorCapacity } from './guarantors.ts';
import { buildFilterClause, type FilterCondition, type FilterFieldDef } from './listFilters.ts';
import { buildOrderClause, type SortState } from './listSort.ts';
import type {
  Actor, ChangeableLoanRow, LoanGuarantorChange, LoanGuarantorChangeLineWithDetails,
  LoanGuarantorChangeWithDetails,
} from './types.ts';

export type GuarantorChangeView = 'open' | 'pending' | 'approved' | 'processed';

const VIEW_CLAUSE: Record<GuarantorChangeView, string> = {
  open: "c.status = 'Open'",
  pending: "c.status = 'Pending Approval'",
  approved: "c.status = 'Approved'",
  processed: "c.status = 'Processed'",
};

const SELECT_CHANGE = `
  SELECT c.*, l.loan_no AS loan_no,
         m.member_no AS member_no, m.first_name AS member_first_name, m.last_name AS member_last_name,
         (l.principal_balance + l.interest_balance + l.penalty_balance) AS loan_outstanding_balance
  FROM loan_guarantor_change c
  JOIN loan l ON l.id = c.loan_id
  JOIN member m ON m.id = c.member_id`;

export const GUARANTOR_CHANGE_FILTER_FIELDS: FilterFieldDef[] = [
  { key: 'no', label: 'No.', type: 'text', column: 'c.no' },
  { key: 'loan_id', label: 'Loan', type: 'select', column: 'c.loan_id' },
  { key: 'member_id', label: 'Member', type: 'select', column: 'c.member_id' },
  { key: 'created_by', label: 'Created By', type: 'text', column: 'c.created_by' },
  { key: 'created_at', label: 'Created', type: 'date', column: 'c.created_at', datetime: true },
];

const SORT_COLUMNS: Record<string, string> = {
  no: 'c.no',
  loan_no: 'l.loan_no',
  member: 'm.first_name',
  member_no: 'm.member_no',
  status: 'c.status',
};

export interface ListGuarantorChangeOptions {
  view?: GuarantorChangeView;
  search?: string;
  filters?: FilterCondition[];
  sort?: SortState | null;
}

export const listGuarantorChanges = (
  { view, search = '', filters = [], sort = null }: ListGuarantorChangeOptions = {},
): Promise<LoanGuarantorChangeWithDetails[]> => {
  const { clause, params } = buildFilterClause(GUARANTOR_CHANGE_FILTER_FIELDS, filters);
  const orderBy = buildOrderClause(SORT_COLUMNS, sort, 'c.no DESC');
  return all<LoanGuarantorChangeWithDetails>(
    `${SELECT_CHANGE}
     WHERE (c.no LIKE @like OR l.loan_no LIKE @like OR m.member_no LIKE @like
            OR m.first_name LIKE @like OR m.last_name LIKE @like)
       ${view ? `AND ${VIEW_CLAUSE[view]}` : ''}
       ${clause}
     ${orderBy}`,
    { like: `%${String(search).trim()}%`, ...params },
  );
};

export const getGuarantorChange = (no: string): Promise<LoanGuarantorChangeWithDetails | undefined> =>
  one<LoanGuarantorChangeWithDetails>(`${SELECT_CHANGE} WHERE c.no = ?`, no);

export const hasAnyGuarantorChanges = (view?: GuarantorChangeView): Promise<boolean> =>
  hasAnyRow('loan_guarantor_change c', view ? VIEW_CLAUSE[view] : undefined);

export async function getAdjacentGuarantorChangeNos(
  no: string, view?: GuarantorChangeView,
): Promise<{ prevNo: string | null; nextNo: string | null }> {
  const clause = view ? `AND ${VIEW_CLAUSE[view]}` : '';
  const [prev, next] = await Promise.all([
    one<{ no: string }>(`SELECT c.no FROM loan_guarantor_change c WHERE c.no < ? ${clause} ORDER BY c.no DESC LIMIT 1`, no),
    one<{ no: string }>(`SELECT c.no FROM loan_guarantor_change c WHERE c.no > ? ${clause} ORDER BY c.no ASC LIMIT 1`, no),
  ]);
  return { prevNo: prev?.no ?? null, nextNo: next?.no ?? null };
}

/** Loans eligible to start a new guarantor change against: DISBURSED, still owing a balance, with
 *  at least one COMMITTED guarantor, and no other change document already open/in-progress
 *  against it (same "one live document at a time" rule as createCollateralRelease()). */
export const listChangeableLoans = (): Promise<ChangeableLoanRow[]> => all<ChangeableLoanRow>(
  `SELECT l.id, l.loan_no, l.member_id, m.member_no, m.first_name, m.last_name,
          (l.principal_balance + l.interest_balance + l.penalty_balance) AS outstanding_balance,
          (SELECT COUNT(*) FROM loan_guarantor g WHERE g.loan_id = l.id AND g.status = 'COMMITTED') AS guarantor_count
   FROM loan l JOIN member m ON m.id = l.member_id
   WHERE l.status = 'DISBURSED'
     AND (l.principal_balance + l.interest_balance + l.penalty_balance) > 0
     AND EXISTS (SELECT 1 FROM loan_guarantor g WHERE g.loan_id = l.id AND g.status = 'COMMITTED')
     AND NOT EXISTS (SELECT 1 FROM loan_guarantor_change c WHERE c.loan_id = l.id AND c.status <> 'Processed')
   ORDER BY l.loan_no`,
);

/** The lines (+ their replacements) for one document, each carrying the guarantor/replacement
 *  members' display names. */
export const listGuarantorChangeLines = (changeNo: string): Promise<LoanGuarantorChangeLineWithDetails[]> =>
  all<Omit<LoanGuarantorChangeLineWithDetails, 'replacements'>>(
    `SELECT ln.*, gm.member_no AS guarantor_member_no, gm.first_name AS guarantor_first_name, gm.last_name AS guarantor_last_name
     FROM loan_guarantor_change_line ln JOIN member gm ON gm.id = ln.guarantor_member_id
     WHERE ln.change_no = ? ORDER BY ln.id`,
    changeNo,
  ).then(async (lines) => {
    const replacements = await all<LoanGuarantorChangeLineWithDetails['replacements'][number]>(
      `SELECT r.*, rm.member_no AS replacement_member_no, rm.first_name AS replacement_first_name, rm.last_name AS replacement_last_name
       FROM loan_guarantor_change_replacement r JOIN member rm ON rm.id = r.replacement_member_id
       WHERE r.line_id IN (SELECT id FROM loan_guarantor_change_line WHERE change_no = ?)
       ORDER BY r.id`,
      changeNo,
    );
    return lines.map((ln) => ({ ...ln, replacements: replacements.filter((r) => r.line_id === ln.id) }));
  });

/** Per-guarantor prorated exposure on one specific loan — same LEAST(committed, prorated-by-
 *  current-balance) formula lib/guarantors.ts's guaranteeSplit() uses across every loan a member
 *  guarantees, scoped here to the single loan a change document is being opened/refreshed against. */
async function populateLines(changeNo: string, loanId: number): Promise<void> {
  const guarantors = await all<{ member_id: number; amount: number; outstanding: number }>(
    `SELECT g.member_id, g.amount,
            LEAST(g.amount, (g.amount::float8 / NULLIF(l.principal, 0)) * (l.principal_balance + l.interest_balance)) AS outstanding
     FROM loan_guarantor g JOIN loan l ON l.id = g.loan_id
     WHERE g.loan_id = ? AND g.status = 'COMMITTED'`,
    loanId,
  );
  for (const g of guarantors) {
    await run(
      `INSERT INTO loan_guarantor_change_line (change_no, guarantor_member_id, initial_guaranteed, outstanding_guaranteed)
       VALUES (?,?,?,?)`,
      changeNo, g.member_id, Math.round(g.amount), Math.max(0, Math.round(g.outstanding || 0)),
    );
  }
}

/** Whether this loan already has a guarantor change document that isn't yet Processed — the
 *  loan page's "Change guarantors" link is only offered when this is false, same "one live
 *  document at a time" rule assertChangeableLoan() enforces on create. */
export const hasLiveGuarantorChange = (loanId: number): Promise<boolean> =>
  one("SELECT 1 FROM loan_guarantor_change WHERE loan_id = ? AND status <> 'Processed'", loanId).then((r) => !!r);

async function assertChangeableLoan(loanId: number): Promise<{ memberId: number }> {
  const loan = await one<{ member_id: number; status: string; balance: number }>(
    `SELECT member_id, status, (principal_balance + interest_balance + penalty_balance) AS balance FROM loan WHERE id = ?`,
    loanId,
  );
  if (!loan) throw new AppError('Loan not found', 'NOT_FOUND');
  if (loan.status !== 'DISBURSED') throw new AppError('Guarantors can only be changed on a disbursed loan', 'VALIDATION');
  if (loan.balance <= 0) throw new AppError('This loan has no outstanding balance left to secure', 'VALIDATION');
  const hasGuarantor = await one("SELECT 1 FROM loan_guarantor WHERE loan_id = ? AND status = 'COMMITTED'", loanId);
  if (!hasGuarantor) throw new AppError('This loan has no committed guarantors to change', 'VALIDATION');
  const live = await one("SELECT 1 FROM loan_guarantor_change WHERE loan_id = ? AND status <> 'Processed'", loanId);
  if (live) throw new AppError('A guarantor change is already open or in progress for this loan', 'VALIDATION');
  return { memberId: loan.member_id };
}

export async function createGuarantorChange(loanId: number, user: Actor): Promise<{ no: string }> {
  const { memberId } = await assertChangeableLoan(loanId);
  const no = await nextSequence('GUARANTOR_CHANGE');
  await tx(async () => {
    await run(
      `INSERT INTO loan_guarantor_change (no, loan_id, member_id, created_at, created_by)
       VALUES (?,?,?,?,?)`,
      no, loanId, memberId, new Date().toISOString(), user.username,
    );
    await populateLines(no, loanId);
  });
  await audit(user, 'GUARANTOR_CHANGE_CREATE', 'loan_guarantor_change', no, { loanId });
  return { no };
}

/** Re-syncs an Open document's lines against the loan's current live COMMITTED guarantors —
 *  wipes existing lines (and, via FK cascade at the app layer below, their replacements) and
 *  re-populates from scratch. Parity with AL's manual "Populate Guarantor Lines" action, useful
 *  if the document has sat open a while. */
export async function refreshGuarantorChangeLines(no: string, user: Actor): Promise<void> {
  const req = await one<LoanGuarantorChange>('SELECT * FROM loan_guarantor_change WHERE no = ?', no);
  if (!req) throw new AppError('Guarantor change not found', 'NOT_FOUND');
  if (req.status !== 'Open') throw new AppError('Only an open guarantor change can be refreshed', 'VALIDATION');
  await tx(async () => {
    await run(
      'DELETE FROM loan_guarantor_change_replacement WHERE line_id IN (SELECT id FROM loan_guarantor_change_line WHERE change_no = ?)',
      no,
    );
    await run('DELETE FROM loan_guarantor_change_line WHERE change_no = ?', no);
    await populateLines(no, req.loan_id);
  });
  await audit(user, 'GUARANTOR_CHANGE_REFRESH_LINES', 'loan_guarantor_change', no, {});
}

async function assertOpenLine(no: string, lineId: number): Promise<{ line: { id: number; release: boolean } }> {
  const req = await one<LoanGuarantorChange>('SELECT * FROM loan_guarantor_change WHERE no = ?', no);
  if (!req) throw new AppError('Guarantor change not found', 'NOT_FOUND');
  if (req.status !== 'Open') throw new AppError('Only an open guarantor change can be edited', 'VALIDATION');
  const line = await one<{ id: number; release: boolean }>(
    'SELECT id, release FROM loan_guarantor_change_line WHERE id = ? AND change_no = ?', lineId, no,
  );
  if (!line) throw new AppError('Line not found', 'NOT_FOUND');
  return { line };
}

/** Toggles a line's Release flag — Release and replacements are mutually exclusive at process
 *  time (mirroring AL's `if Release … else if Substitution …`), so turning Release on clears
 *  whatever replacements were already staged on that line. */
export async function setLineRelease(no: string, lineId: number, release: boolean, user: Actor): Promise<void> {
  await assertOpenLine(no, lineId);
  await tx(async () => {
    await run('UPDATE loan_guarantor_change_line SET release = ? WHERE id = ?', release, lineId);
    if (release) await run('DELETE FROM loan_guarantor_change_replacement WHERE line_id = ?', lineId);
  });
  await audit(user, 'GUARANTOR_CHANGE_SET_RELEASE', 'loan_guarantor_change', no, { lineId, release });
}

/** Adds a replacement guarantor to cover (part of) a line's outstanding amount. Never the loan's
 *  own borrower — this schema has no loan_guarantor row for self-guarantee (commitGuarantor()
 *  forbids it too; self-guarantee capacity is purely computed from deposits, see
 *  lib/guarantors.ts's selfGuaranteeCapacity), so there is nothing to write for a self-substitution
 *  the way AL's Det. Lines allow. Validated against the replacement's own live capacity — the
 *  exact same guarantorCapacity() check commitGuarantor() itself uses — and capped so a line's
 *  replacements never sum past what it's actually releasing (tighter than AL, which only checked
 *  the replacement member's own capacity in isolation). */
export async function addReplacement(
  no: string, lineId: number, replacementMemberId: number, amountSh: number, user: Actor,
): Promise<void> {
  const { line } = await assertOpenLine(no, lineId);
  if (line.release) throw new AppError('This line is marked for release — clear that first to add a replacement instead', 'VALIDATION');

  const req = await one<{ member_id: number }>('SELECT member_id FROM loan_guarantor_change WHERE no = ?', no);
  if (replacementMemberId === req!.member_id) {
    throw new AppError('The loan’s own borrower cannot be added as a replacement guarantor', 'VALIDATION');
  }

  const amt = Math.round(amountSh);
  if (amt <= 0) throw new AppError('Replacement amount must be greater than zero', 'INVALID_AMOUNT');

  const lineRow = await one<{ outstanding_guaranteed: number }>(
    'SELECT outstanding_guaranteed FROM loan_guarantor_change_line WHERE id = ?', lineId,
  );
  const alreadyAllocated = (await one<{ s: number }>(
    'SELECT COALESCE(SUM(amount),0) s FROM loan_guarantor_change_replacement WHERE line_id = ?', lineId,
  ))!.s;
  const remaining = lineRow!.outstanding_guaranteed - alreadyAllocated;
  if (amt > remaining) {
    throw new AppError(
      `This line has only ${(remaining / 100).toLocaleString()} left unallocated`, 'VALIDATION',
    );
  }

  const capacity = await guarantorCapacity(replacementMemberId);
  if (amt > capacity.available) {
    throw new AppError(
      `This member can only guarantee up to ${(capacity.available / 100).toLocaleString()}`, 'OVER_CAPACITY',
    );
  }

  await run(
    'INSERT INTO loan_guarantor_change_replacement (line_id, replacement_member_id, amount) VALUES (?,?,?)',
    lineId, replacementMemberId, amt,
  );
  await audit(user, 'GUARANTOR_CHANGE_ADD_REPLACEMENT', 'loan_guarantor_change', no, { lineId, replacementMemberId, amount: amt });
}

export async function removeReplacement(no: string, replacementId: number, user: Actor): Promise<void> {
  const req = await one<LoanGuarantorChange>('SELECT * FROM loan_guarantor_change WHERE no = ?', no);
  if (!req) throw new AppError('Guarantor change not found', 'NOT_FOUND');
  if (req.status !== 'Open') throw new AppError('Only an open guarantor change can be edited', 'VALIDATION');
  const replacement = await one(
    `SELECT r.id FROM loan_guarantor_change_replacement r
     JOIN loan_guarantor_change_line ln ON ln.id = r.line_id
     WHERE r.id = ? AND ln.change_no = ?`,
    replacementId, no,
  );
  if (!replacement) throw new AppError('Replacement not found', 'NOT_FOUND');
  await run('DELETE FROM loan_guarantor_change_replacement WHERE id = ?', replacementId);
  await audit(user, 'GUARANTOR_CHANGE_REMOVE_REPLACEMENT', 'loan_guarantor_change', no, { replacementId });
}

/** BR — at least one line must actually be changed (released or given a replacement), otherwise
 *  the document would process into a no-op. Fixes the AL source's own gap: its list/card actions
 *  let a submit-with-nothing-checked request go all the way to Process, which then silently did
 *  nothing. */
async function assertReadyForApproval(no: string): Promise<void> {
  const changed = await one(
    `SELECT 1 FROM loan_guarantor_change_line ln
     WHERE ln.change_no = ? AND (ln.release = true OR EXISTS (
       SELECT 1 FROM loan_guarantor_change_replacement r WHERE r.line_id = ln.id
     ))`,
    no,
  );
  if (!changed) {
    throw new AppError('Release at least one guarantor, or add a replacement, before sending this for approval', 'VALIDATION');
  }
}

export async function submitGuarantorChange(no: string, user: Actor): Promise<{ autoApproved: boolean }> {
  const req = await one<LoanGuarantorChange>('SELECT * FROM loan_guarantor_change WHERE no = ?', no);
  if (!req) throw new AppError('Guarantor change not found', 'NOT_FOUND');
  if (req.status !== 'Open') throw new AppError('Only an open guarantor change can be submitted for approval', 'VALIDATION');
  await assertReadyForApproval(no);

  const matched = await findMatchingWorkflow('GUARANTOR_CHANGE', await pickConditionFields('GUARANTOR_CHANGE', req));
  if (!matched) throw new AppError('There is no enabled workflow for this document', 'NO_WORKFLOW');

  await tx(async () => {
    await run("UPDATE loan_guarantor_change SET status = 'Pending Approval' WHERE no = ?", no);
    await startWorkflow(matched.workflow, matched.steps, {
      documentType: 'GUARANTOR_CHANGE', entityId: no, requestedBy: user.username, amount: 0,
    });
  });

  const after = await one<{ status: string }>('SELECT status FROM loan_guarantor_change WHERE no = ?', no);
  return { autoApproved: after?.status === 'Approved' };
}

export async function cancelGuarantorChangeApproval(no: string, user: Actor): Promise<void> {
  const req = await one<Pick<LoanGuarantorChange, 'status' | 'created_by'>>(
    'SELECT status, created_by FROM loan_guarantor_change WHERE no = ?', no,
  );
  if (!req) throw new AppError('Guarantor change not found', 'NOT_FOUND');
  if (req.status !== 'Pending Approval') {
    throw new AppError('Only a request pending approval can have its approval request cancelled', 'VALIDATION');
  }
  const routed = await findPendingRoutedTask('GUARANTOR_CHANGE', no);
  const requestedBy = routed?.requested_by ?? req.created_by;
  if (requestedBy !== user.username) {
    throw new AppError('Only the person who submitted this request for approval can cancel it', 'NOT_REQUESTER');
  }
  await run("UPDATE loan_guarantor_change SET status = 'Open' WHERE no = ?", no);
  await audit(user, 'GUARANTOR_CHANGE_CANCEL_APPROVAL', 'loan_guarantor_change', no, {});
}

export async function approveGuarantorChange(no: string, user: Actor): Promise<void> {
  const req = await one<LoanGuarantorChange>('SELECT * FROM loan_guarantor_change WHERE no = ?', no);
  if (!req) throw new AppError('Guarantor change not found', 'NOT_FOUND');
  if (req.status !== 'Pending Approval') throw new AppError('Only a request pending approval can be approved', 'VALIDATION');
  await run("UPDATE loan_guarantor_change SET status = 'Approved', decision_reason = NULL WHERE no = ?", no);
  await audit(user, 'GUARANTOR_CHANGE_APPROVE', 'loan_guarantor_change', no, {});
}

export async function rejectGuarantorChange(no: string, reason: string | null, user: Actor): Promise<void> {
  if (!reason || !reason.trim()) throw new AppError('A reason is required to reject a request', 'VALIDATION');
  const req = await one<LoanGuarantorChange>('SELECT * FROM loan_guarantor_change WHERE no = ?', no);
  if (!req) throw new AppError('Guarantor change not found', 'NOT_FOUND');
  if (req.status !== 'Pending Approval') throw new AppError('Only a request pending approval can be rejected', 'VALIDATION');
  await run("UPDATE loan_guarantor_change SET status = 'Open', decision_reason = ? WHERE no = ?", reason, no);
  await audit(user, 'GUARANTOR_CHANGE_REJECT', 'loan_guarantor_change', no, { reason });
}

/**
 * Approved -> applies every line onto loan_guarantor, ported from ProcessGuarantorSubstitution
 * (Cod52204008.LoansManagement.al:4883). Per line:
 *   - release: the original guarantor's row moves to 'RELEASED'.
 *   - otherwise, for each replacement: the original guarantor's row moves to 'SUBSTITUTED', and
 *     the replacement's own row is inserted or, if they already guarantee this same loan through
 *     another line, incremented (mirrors AL's LoanGuarantee[3]/[4] "increment if exists, insert if
 *     not"). Capacity is re-checked live here too — never trusted from submit time.
 * A line with neither flag is left untouched.
 */
export async function processGuarantorChange(no: string, user: Actor): Promise<{ loanId: number }> {
  return tx(async () => {
    const req = await one<LoanGuarantorChange>('SELECT * FROM loan_guarantor_change WHERE no = ?', no);
    if (!req) throw new AppError('Guarantor change not found', 'NOT_FOUND');
    if (req.status !== 'Approved') throw new AppError('Only an approved guarantor change can be processed', 'VALIDATION');

    const lines = await all<{ id: number; guarantor_member_id: number; release: boolean }>(
      'SELECT id, guarantor_member_id, release FROM loan_guarantor_change_line WHERE change_no = ?', no,
    );

    for (const line of lines) {
      if (line.release) {
        await run(
          "UPDATE loan_guarantor SET status = 'RELEASED' WHERE loan_id = ? AND member_id = ? AND status = 'COMMITTED'",
          req.loan_id, line.guarantor_member_id,
        );
        continue;
      }

      const replacements = await all<{ replacement_member_id: number; amount: number }>(
        'SELECT replacement_member_id, amount FROM loan_guarantor_change_replacement WHERE line_id = ?', line.id,
      );
      if (!replacements.length) continue;

      await run(
        "UPDATE loan_guarantor SET status = 'SUBSTITUTED' WHERE loan_id = ? AND member_id = ? AND status = 'COMMITTED'",
        req.loan_id, line.guarantor_member_id,
      );

      for (const r of replacements) {
        const capacity = await guarantorCapacity(r.replacement_member_id);
        if (r.amount > capacity.available) {
          throw new AppError(
            `Replacement guarantor capacity has changed and can no longer cover ${(r.amount / 100).toLocaleString()}`,
            'OVER_CAPACITY',
          );
        }
        await run(
          `INSERT INTO loan_guarantor (loan_id, member_id, amount, status) VALUES (?,?,?,'COMMITTED')
           ON CONFLICT (loan_id, member_id) DO UPDATE SET amount = loan_guarantor.amount + EXCLUDED.amount, status = 'COMMITTED'`,
          req.loan_id, r.replacement_member_id, r.amount,
        );
      }
    }

    await run(
      "UPDATE loan_guarantor_change SET status = 'Processed', processed_at = ?, processed_by = ? WHERE no = ?",
      new Date().toISOString(), user.username, no,
    );
    await audit(user, 'GUARANTOR_CHANGE_PROCESS', 'loan_guarantor_change', no, {});
    return { loanId: req.loan_id };
  });
}
