/*
 * Collateral Release — a maker-checker request to hand a pledged asset back once every loan it
 * secured has been cleared. Same Open -> Pending Approval -> Approved -> Processed shape as
 * lib/collateralApplications.ts; processing stamps collateral_register.collected_at.
 *
 * BR-10's substantive safeguard — collateral cannot be released while it still secures an
 * outstanding loan balance — is enforced in the service layer at both submit and post time
 * (DEF-16/DEF-20 in the source specification: the AL implementation checked this from only one
 * of its two entry points, and never re-checked it at posting, relying entirely on a page
 * action's Visible expression). Here there is exactly one submit path and one post path, and
 * both re-fetch the live figure rather than trusting anything already on the document.
 */
import {
  one, all, run, tx, nextSequence, audit, hasAnyRow,
} from './db.ts';
import { AppError } from './errors.ts';
import { findMatchingWorkflow, findPendingRoutedTask, pickConditionFields, startWorkflow } from './workflow.ts';
import { getCollateralLinkedBalance } from './collateralRegister.ts';
import { buildFilterClause, type FilterCondition, type FilterFieldDef } from './listFilters.ts';
import { buildOrderClause, type SortState } from './listSort.ts';
import type { Actor, CollateralRelease, CollateralReleaseWithDetails } from './types.ts';

export type CollateralReleaseView = 'open' | 'pending' | 'approved' | 'processed';

const VIEW_CLAUSE: Record<CollateralReleaseView, string> = {
  open: "l.status = 'Open'",
  pending: "l.status = 'Pending Approval'",
  approved: "l.status = 'Approved'",
  processed: "l.status = 'Processed'",
};

const SELECT_RELEASE = `
  SELECT l.*, m.member_no AS member_no, m.first_name AS member_first_name, m.last_name AS member_last_name,
         r.collateral_description AS collateral_description, r.serial_reg_no AS collateral_serial_reg_no,
         COALESCE(x.linked_loan_balance, 0) AS linked_loan_balance
  FROM collateral_release l
  JOIN member m ON m.id = l.member_id
  JOIN collateral_register r ON r.no = l.collateral_no
  LEFT JOIN (
    SELECT lc.collateral_no, SUM(LEAST(lc.guarantee, ln.principal_balance + ln.interest_balance + ln.penalty_balance)) AS linked_loan_balance
    FROM loan_collateral lc JOIN loan ln ON ln.id = lc.loan_id
    WHERE lc.status = 'ACTIVE' AND ln.status = 'DISBURSED'
      AND (ln.principal_balance + ln.interest_balance + ln.penalty_balance) > 0
    GROUP BY lc.collateral_no
  ) x ON x.collateral_no = l.collateral_no`;

export const COLLATERAL_RELEASE_FILTER_FIELDS: FilterFieldDef[] = [
  { key: 'no', label: 'No.', type: 'text', column: 'l.no' },
  { key: 'collateral_no', label: 'Collateral No.', type: 'text', column: 'l.collateral_no' },
  { key: 'member_id', label: 'Member', type: 'select', column: 'l.member_id' },
  { key: 'collected_by', label: 'Collected By', type: 'text', column: 'l.collected_by' },
  { key: 'collection_date', label: 'Collection Date', type: 'date', column: 'l.collection_date' },
  { key: 'nationality', label: 'Nationality', type: 'select', column: 'l.nationality', options: [{ value: 'LOCAL', label: 'Local' }, { value: 'DIASPORA', label: 'Diaspora' }] },
  { key: 'created_by', label: 'Created By', type: 'text', column: 'l.created_by' },
  { key: 'created_at', label: 'Created', type: 'date', column: 'l.created_at', datetime: true },
];

const SORT_COLUMNS: Record<string, string> = {
  no: 'l.no',
  collateral_no: 'l.collateral_no',
  member: 'm.first_name',
  member_no: 'm.member_no',
  status: 'l.status',
};

export interface ListCollateralReleaseOptions {
  view?: CollateralReleaseView;
  search?: string;
  filters?: FilterCondition[];
  sort?: SortState | null;
}

export const listCollateralReleases = (
  { view, search = '', filters = [], sort = null }: ListCollateralReleaseOptions = {},
): Promise<CollateralReleaseWithDetails[]> => {
  const { clause, params } = buildFilterClause(COLLATERAL_RELEASE_FILTER_FIELDS, filters);
  const orderBy = buildOrderClause(SORT_COLUMNS, sort, 'l.no DESC');
  return all<CollateralReleaseWithDetails>(
    `${SELECT_RELEASE}
     WHERE (l.no LIKE @like OR l.collateral_no LIKE @like OR m.member_no LIKE @like
            OR m.first_name LIKE @like OR m.last_name LIKE @like)
       ${view ? `AND ${VIEW_CLAUSE[view]}` : ''}
       ${clause}
     ${orderBy}`,
    { like: `%${String(search).trim()}%`, ...params },
  );
};

export const getCollateralRelease = (no: string): Promise<CollateralReleaseWithDetails | undefined> =>
  one<CollateralReleaseWithDetails>(`${SELECT_RELEASE} WHERE l.no = ?`, no);

export const hasAnyCollateralReleases = (view?: CollateralReleaseView): Promise<boolean> =>
  hasAnyRow('collateral_release l', view ? VIEW_CLAUSE[view] : undefined);

export async function getAdjacentCollateralReleaseNos(
  no: string, view?: CollateralReleaseView,
): Promise<{ prevNo: string | null; nextNo: string | null }> {
  const clause = view ? `AND ${VIEW_CLAUSE[view]}` : '';
  const [prev, next] = await Promise.all([
    one<{ no: string }>(`SELECT l.no FROM collateral_release l WHERE l.no < ? ${clause} ORDER BY l.no DESC LIMIT 1`, no),
    one<{ no: string }>(`SELECT l.no FROM collateral_release l WHERE l.no > ? ${clause} ORDER BY l.no ASC LIMIT 1`, no),
  ]);
  return { prevNo: prev?.no ?? null, nextNo: next?.no ?? null };
}

export interface CreateCollateralReleaseInput {
  collateralNo: string;
  collectionDate?: string | null;
  collectedBy?: string | null;
  collectedByIdNo?: string | null;
  nationality?: string;
  domicileCountry?: string | null;
  comments?: string | null;
  remarks?: string | null;
}

export async function createCollateralRelease(
  input: CreateCollateralReleaseInput, user: Actor,
): Promise<{ no: string }> {
  const register = await one<{ no: string; member_id: number; collected_at: string | null }>(
    'SELECT no, member_id, collected_at FROM collateral_register WHERE no = ?', input.collateralNo,
  );
  if (!register) throw new AppError('Collateral register item not found', 'NOT_FOUND');
  if (register.collected_at) throw new AppError('This collateral item has already been collected', 'VALIDATION');

  // DEF-12 (source specification): nothing stops more than one release document targeting the
  // same item, or a release against an already-collected one. The collected_at check above
  // covers the second half; this covers the first — only one *live* release may exist at a time.
  const live = await one(
    "SELECT 1 FROM collateral_release WHERE collateral_no = ? AND status <> 'Processed'", input.collateralNo,
  );
  if (live) throw new AppError('A release request is already open or in progress for this collateral item', 'VALIDATION');

  if (input.nationality === 'DIASPORA' && !input.domicileCountry?.trim()) {
    throw new AppError('Domicile country is required for a diaspora collector', 'VALIDATION');
  }

  const no = await nextSequence('COLLATERAL_RELEASE');
  await run(
    `INSERT INTO collateral_release
       (no, collateral_no, member_id, collection_date, collected_by, collected_by_id_no,
        nationality, domicile_country, comments, remarks, created_at, created_by)
     VALUES (?,?,?,?,?,?,?,?,?,?,?,?)`,
    no, input.collateralNo, register.member_id, input.collectionDate || null, input.collectedBy || null,
    input.collectedByIdNo || null, input.nationality || 'LOCAL', input.domicileCountry || null,
    input.comments || null, input.remarks || null, new Date().toISOString(), user.username,
  );
  await audit(user, 'COLLATERAL_RELEASE_CREATE', 'collateral_release', no, { collateralNo: input.collateralNo });
  return { no };
}

export interface UpdateCollateralReleaseInput extends Partial<CreateCollateralReleaseInput> {}

export async function updateCollateralRelease(
  no: string, body: UpdateCollateralReleaseInput, user: Actor,
): Promise<CollateralReleaseWithDetails> {
  const req = await one<CollateralRelease>('SELECT * FROM collateral_release WHERE no = ?', no);
  if (!req) throw new AppError('Collateral release not found', 'NOT_FOUND');
  if (req.status !== 'Open') throw new AppError('Only an open release can be edited', 'VALIDATION');

  const nationality = body.nationality !== undefined ? body.nationality : req.nationality;
  const domicileCountry = body.domicileCountry !== undefined ? body.domicileCountry : req.domicile_country;
  if (nationality === 'DIASPORA' && !domicileCountry?.trim()) {
    throw new AppError('Domicile country is required for a diaspora collector', 'VALIDATION');
  }

  const cols: Record<string, unknown> = {};
  // A changed collateral item (whether re-targeting the same member's other pledge, or a
  // different member's entirely) is re-validated exactly as a fresh release would be — still
  // uncollected, and not already claimed by another live release (excluding this one) — and
  // member_id is re-derived from the newly chosen item's own register row, the same way it was
  // set at creation, so the two never disagree about whose asset this is.
  if (body.collateralNo !== undefined && body.collateralNo !== req.collateral_no) {
    const register = await one<{ no: string; member_id: number; collected_at: string | null }>(
      'SELECT no, member_id, collected_at FROM collateral_register WHERE no = ?', body.collateralNo,
    );
    if (!register) throw new AppError('Collateral register item not found', 'NOT_FOUND');
    if (register.collected_at) throw new AppError('This collateral item has already been collected', 'VALIDATION');
    const live = await one(
      "SELECT 1 FROM collateral_release WHERE collateral_no = ? AND status <> 'Processed' AND no <> ?",
      body.collateralNo, no,
    );
    if (live) throw new AppError('A release request is already open or in progress for this collateral item', 'VALIDATION');
    cols.collateral_no = body.collateralNo;
    cols.member_id = register.member_id;
  }
  if (body.collectionDate !== undefined) cols.collection_date = body.collectionDate || null;
  if (body.collectedBy !== undefined) cols.collected_by = body.collectedBy || null;
  if (body.collectedByIdNo !== undefined) cols.collected_by_id_no = body.collectedByIdNo || null;
  if (body.nationality !== undefined) cols.nationality = body.nationality;
  if (body.domicileCountry !== undefined) cols.domicile_country = body.domicileCountry || null;
  if (body.comments !== undefined) cols.comments = body.comments || null;
  if (body.remarks !== undefined) cols.remarks = body.remarks || null;

  const keys = Object.keys(cols);
  if (keys.length) {
    await run(`UPDATE collateral_release SET ${keys.map((c) => `${c}=?`).join(',')} WHERE no=?`, ...keys.map((c) => cols[c]), no);
  }
  await audit(user, 'COLLATERAL_RELEASE_UPDATE', 'collateral_release', no, { fields: keys });
  return (await getCollateralRelease(no))!;
}

export async function deleteCollateralRelease(no: string, user: Actor): Promise<void> {
  const req = await one<CollateralRelease>('SELECT * FROM collateral_release WHERE no = ?', no);
  if (!req) throw new AppError('Collateral release not found', 'NOT_FOUND');
  if (req.status !== 'Open') throw new AppError('Only an open release can be deleted', 'VALIDATION');
  await run('DELETE FROM collateral_release WHERE no = ?', no);
  await audit(user, 'COLLATERAL_RELEASE_DELETE', 'collateral_release', no, {});
}

/** BR-10 — the substantive completeness check, enforced from the single submit path (fixing
 *  DEF-16, where the source specification's list-page entry point omitted it entirely). */
async function assertReadyForApproval(req: CollateralRelease): Promise<void> {
  const missing: string[] = [];
  if (!req.collected_by || !req.collected_by.trim()) missing.push('Collected By');
  if (!req.collection_date) missing.push('Collection Date');
  if (missing.length) {
    throw new AppError(`Complete the following before sending for approval: ${missing.join(', ')}`, 'VALIDATION');
  }
  const balance = await getCollateralLinkedBalance(req.collateral_no);
  if (balance > 0) {
    throw new AppError(
      `Collateral ${req.collateral_no} still secures ${(balance / 100).toLocaleString()} of outstanding loan balance and cannot be released`,
      'VALIDATION',
    );
  }
}

export async function submitCollateralRelease(no: string, user: Actor): Promise<{ autoApproved: boolean }> {
  const req = await one<CollateralRelease>('SELECT * FROM collateral_release WHERE no = ?', no);
  if (!req) throw new AppError('Collateral release not found', 'NOT_FOUND');
  if (req.status !== 'Open') throw new AppError('Only an open release can be submitted for approval', 'VALIDATION');
  await assertReadyForApproval(req);

  const matched = await findMatchingWorkflow(
    'COLLATERAL_RELEASE', await pickConditionFields('COLLATERAL_RELEASE', req),
  );
  if (!matched) throw new AppError('There is no enabled workflow for this document', 'NO_WORKFLOW');

  await tx(async () => {
    await run("UPDATE collateral_release SET status = 'Pending Approval' WHERE no = ?", no);
    await startWorkflow(matched.workflow, matched.steps, {
      documentType: 'COLLATERAL_RELEASE', entityId: no, requestedBy: user.username, amount: 0,
    });
  });

  const after = await one<{ status: string }>('SELECT status FROM collateral_release WHERE no = ?', no);
  return { autoApproved: after?.status === 'Approved' };
}

export async function cancelCollateralReleaseApproval(no: string, user: Actor): Promise<void> {
  const req = await one<Pick<CollateralRelease, 'status' | 'created_by'>>(
    'SELECT status, created_by FROM collateral_release WHERE no = ?', no,
  );
  if (!req) throw new AppError('Collateral release not found', 'NOT_FOUND');
  if (req.status !== 'Pending Approval') {
    throw new AppError('Only a request pending approval can have its approval request cancelled', 'VALIDATION');
  }
  const routed = await findPendingRoutedTask('COLLATERAL_RELEASE', no);
  const requestedBy = routed?.requested_by ?? req.created_by;
  if (requestedBy !== user.username) {
    throw new AppError('Only the person who submitted this request for approval can cancel it', 'NOT_REQUESTER');
  }
  await run("UPDATE collateral_release SET status = 'Open' WHERE no = ?", no);
  await audit(user, 'COLLATERAL_RELEASE_CANCEL_APPROVAL', 'collateral_release', no, {});
}

export async function approveCollateralRelease(no: string, user: Actor): Promise<void> {
  const req = await one<CollateralRelease>('SELECT * FROM collateral_release WHERE no = ?', no);
  if (!req) throw new AppError('Collateral release not found', 'NOT_FOUND');
  if (req.status !== 'Pending Approval') throw new AppError('Only a request pending approval can be approved', 'VALIDATION');
  await run("UPDATE collateral_release SET status = 'Approved', decision_reason = NULL WHERE no = ?", no);
  await audit(user, 'COLLATERAL_RELEASE_APPROVE', 'collateral_release', no, {});
}

export async function rejectCollateralRelease(no: string, reason: string | null, user: Actor): Promise<void> {
  if (!reason || !reason.trim()) throw new AppError('A reason is required to reject a request', 'VALIDATION');
  const req = await one<CollateralRelease>('SELECT * FROM collateral_release WHERE no = ?', no);
  if (!req) throw new AppError('Collateral release not found', 'NOT_FOUND');
  if (req.status !== 'Pending Approval') throw new AppError('Only a request pending approval can be rejected', 'VALIDATION');
  await run("UPDATE collateral_release SET status = 'Open', decision_reason = ? WHERE no = ?", reason, no);
  await audit(user, 'COLLATERAL_RELEASE_REJECT', 'collateral_release', no, { reason });
}

/**
 * Approved -> stamps the register item as collected. Re-validates BR-10 here too (DEF-20: the
 * source specification's posting routine performed no re-validation at all, relying entirely on
 * a page action's Visible expression — an HTTP endpoint has no such gate). Fails loudly if the
 * register row is somehow already collected (DEF-21: the source silently did nothing) rather
 * than leaving the release stranded with no explanation.
 */
export async function postCollateralRelease(no: string, user: Actor): Promise<{ collateralNo: string }> {
  return tx(async () => {
    const req = await one<CollateralRelease>('SELECT * FROM collateral_release WHERE no = ?', no);
    if (!req) throw new AppError('Collateral release not found', 'NOT_FOUND');
    if (req.status !== 'Approved') throw new AppError('Only an approved release can be posted', 'VALIDATION');

    const balance = await getCollateralLinkedBalance(req.collateral_no);
    if (balance > 0) {
      throw new AppError(
        `Collateral ${req.collateral_no} still secures ${(balance / 100).toLocaleString()} of outstanding loan balance`,
        'VALIDATION',
      );
    }

    const updated = await run(
      "UPDATE collateral_register SET collected_at = ? WHERE no = ? AND collected_at IS NULL",
      new Date().toISOString().slice(0, 10), req.collateral_no,
    );
    if (!updated.changes) {
      throw new AppError(`Collateral register item ${req.collateral_no} was not found or is already collected`, 'NOT_FOUND');
    }

    await run(
      "UPDATE collateral_release SET status = 'Processed', processed_at = ?, processed_by = ? WHERE no = ?",
      new Date().toISOString(), user.username, no,
    );
    await audit(user, 'COLLATERAL_RELEASE_POST', 'collateral_release', no, {});
    return { collateralNo: req.collateral_no };
  });
}
