/*
 * Collateral Application — a maker-checker request to pledge one asset (a vehicle, a parcel of
 * land, a building) as loan security. Same Open -> Pending Approval -> Approved -> Processed
 * shape as lib/accountOpening.ts: the request only actually creates the accepted register entry
 * (postCollateralApplication()) once it is Approved.
 *
 * Fixes several defects the source AL specification flags rather than reproducing them:
 *  - BR-04/DEF-14: Guarantee is recomputed by computeGuarantee() every time either
 *    collateral_value or collateral_type_id changes, in the same code path, so it can never go
 *    stale the way a field-level OnValidate trigger allowed.
 *  - BR-06/DEF-15: the duplicate serial/reg-no check excludes the document's own record,
 *    ignores items that have already been collected, and raises when a *live* duplicate is
 *    found — the inverse of the source's inverted condition.
 *  - DEF-01/DEF-02/DEF-03: postCollateralApplication() is a single upsert inside a transaction,
 *    so the register's Serial/Reg No. is always copied, an update never silently discards
 *    changes, and processed_at is always set.
 */
import {
  one, all, run, tx, nextSequence, audit, hasAnyRow,
} from './db.ts';
import { AppError } from './errors.ts';
import { findMatchingWorkflow, findPendingRoutedTask, pickConditionFields, startWorkflow } from './workflow.ts';
import { buildFilterClause, type FilterCondition, type FilterFieldDef } from './listFilters.ts';
import { buildOrderClause, type SortState } from './listSort.ts';
import type {
  Actor, CollateralApplication, CollateralApplicationWithDetails, CollateralType, Member,
} from './types.ts';

const today = (): string => new Date().toISOString().slice(0, 10);

export type CollateralApplicationView = 'open' | 'pending' | 'approved' | 'processed';

const VIEW_CLAUSE: Record<CollateralApplicationView, string> = {
  open: "a.status = 'Open'",
  pending: "a.status = 'Pending Approval'",
  approved: "a.status = 'Approved'",
  processed: "a.status = 'Processed'",
};

const SELECT_APPLICATION = `
  SELECT a.*, m.member_no AS member_no, m.first_name AS member_first_name, m.last_name AS member_last_name,
         t.code AS collateral_type_code, c.name AS county_name
  FROM collateral_application a
  JOIN member m ON m.id = a.member_id
  LEFT JOIN collateral_type t ON t.id = a.collateral_type_id
  LEFT JOIN county c ON c.id = a.county_id`;

export const COLLATERAL_APPLICATION_FILTER_FIELDS: FilterFieldDef[] = [
  { key: 'no', label: 'No.', type: 'text', column: 'a.no' },
  { key: 'member_id', label: 'Member', type: 'select', column: 'a.member_id' },
  { key: 'category', label: 'Category', type: 'select', column: 'a.category' },
  { key: 'collateral_type_id', label: 'Collateral Type', type: 'select', column: 'a.collateral_type_id' },
  { key: 'serial_reg_no', label: 'Serial / Reg. No.', type: 'text', column: 'a.serial_reg_no' },
  { key: 'collateral_value', label: 'Collateral Value', type: 'number', column: 'a.collateral_value' },
  { key: 'guarantee', label: 'Guarantee', type: 'number', column: 'a.guarantee' },
  { key: 'owner_name', label: 'Owner Name', type: 'text', column: 'a.owner_name' },
  { key: 'decision_reason', label: 'Decision Reason', type: 'text', column: 'a.decision_reason' },
  { key: 'created_by', label: 'Created By', type: 'text', column: 'a.created_by' },
  { key: 'created_at', label: 'Created', type: 'date', column: 'a.created_at', datetime: true },
];

const SORT_COLUMNS: Record<string, string> = {
  no: 'a.no',
  member: 'm.first_name',
  member_no: 'm.member_no',
  category: 'a.category',
  collateral_type: 't.code',
  collateral_value: 'a.collateral_value',
  guarantee: 'a.guarantee',
  status: 'a.status',
};

export interface ListCollateralApplicationOptions {
  view?: CollateralApplicationView;
  search?: string;
  filters?: FilterCondition[];
  sort?: SortState | null;
}

export const listCollateralApplications = (
  { view, search = '', filters = [], sort = null }: ListCollateralApplicationOptions = {},
): Promise<CollateralApplicationWithDetails[]> => {
  const { clause, params } = buildFilterClause(COLLATERAL_APPLICATION_FILTER_FIELDS, filters);
  const orderBy = buildOrderClause(SORT_COLUMNS, sort, 'a.no DESC');
  return all<CollateralApplicationWithDetails>(
    `${SELECT_APPLICATION}
     WHERE (a.no LIKE @like OR a.serial_reg_no LIKE @like OR m.member_no LIKE @like
            OR m.first_name LIKE @like OR m.last_name LIKE @like)
       ${view ? `AND ${VIEW_CLAUSE[view]}` : ''}
       ${clause}
     ${orderBy}`,
    { like: `%${String(search).trim()}%`, ...params },
  );
};

export const getCollateralApplication = (no: string): Promise<CollateralApplicationWithDetails | undefined> =>
  one<CollateralApplicationWithDetails>(`${SELECT_APPLICATION} WHERE a.no = ?`, no);

export const hasAnyCollateralApplications = (view?: CollateralApplicationView): Promise<boolean> =>
  hasAnyRow('collateral_application a', view ? VIEW_CLAUSE[view] : undefined);

export async function getAdjacentCollateralApplicationNos(
  no: string, view?: CollateralApplicationView,
): Promise<{ prevNo: string | null; nextNo: string | null }> {
  const clause = view ? `AND ${VIEW_CLAUSE[view]}` : '';
  const [prev, next] = await Promise.all([
    one<{ no: string }>(`SELECT a.no FROM collateral_application a WHERE a.no < ? ${clause} ORDER BY a.no DESC LIMIT 1`, no),
    one<{ no: string }>(`SELECT a.no FROM collateral_application a WHERE a.no > ? ${clause} ORDER BY a.no ASC LIMIT 1`, no),
  ]);
  return { prevNo: prev?.no ?? null, nextNo: next?.no ?? null };
}

/** BR-04: the realisable security value. `multiplier` is a percentage (70 = 70%), not a
 *  fraction — matches the source specification's Guarantee := Value x Multiplier x 0.01. */
export const computeGuarantee = (collateralValue: number, multiplier: number): number =>
  Math.round(collateralValue * multiplier / 100);

/**
 * BR-06, corrected per the source specification's own recommended rebuild (Section 4): the
 * live register — not other in-flight applications — is checked for the same serial/reg no,
 * excluding this document's own record and anything already collected. Raising when a match
 * *is* found is the sensible condition; the source AL raised on the inverse.
 */
async function assertNoDuplicateSerial(
  serialRegNo: string | null | undefined, multiLinking: boolean, excludeNo?: string,
): Promise<void> {
  if (!serialRegNo || !serialRegNo.trim() || multiLinking) return;
  const existing = await one<{ no: string; member_first_name: string; member_last_name: string }>(
    `SELECT r.no, m.first_name AS member_first_name, m.last_name AS member_last_name
     FROM collateral_register r JOIN member m ON m.id = r.member_id
     WHERE r.serial_reg_no = ? AND r.collected_at IS NULL ${excludeNo ? 'AND r.no <> ?' : ''}`,
    ...(excludeNo ? [serialRegNo, excludeNo] : [serialRegNo]),
  );
  if (existing) {
    throw new AppError(
      `Collateral "${serialRegNo}" is already registered under ${existing.no} for ${existing.member_first_name} ${existing.member_last_name}`,
      'DUPLICATE_SERIAL',
    );
  }
}

export interface CreateCollateralApplicationInput {
  memberId: number;
  category: string;
  collateralTypeId: number;
  collateralValue: number;
  serialRegNo?: string | null;
  multiLinking?: boolean;
  countyId?: number | null;
  lastValuationDate?: string | null;
  jointOwnership?: boolean;
  ownerName?: string | null;
  ownerIdNo?: string | null;
  ownerPhoneNo?: string | null;
  insuranceExpiryDate?: string | null;
  carTrackDueDate?: string | null;
  chequeNo?: string | null;
}

/** BR-02/BR-03: snapshots the member and collateral-type detail this document needs onto the
 *  document itself — a later change to either master record must not retroactively change an
 *  existing application. */
async function resolveTypeSnapshot(
  category: string, collateralTypeId: number,
): Promise<{ type: CollateralType; multiplier: number }> {
  const type = await one<CollateralType>('SELECT * FROM collateral_type WHERE id = ?', collateralTypeId);
  if (!type) throw new AppError('Collateral type not found', 'NOT_FOUND');
  if (type.status !== 'ACTIVE') throw new AppError(`Collateral type "${type.code}" is not active`, 'VALIDATION');
  if (type.category !== category) {
    throw new AppError(`Collateral type "${type.code}" does not belong to the ${category} category`, 'VALIDATION');
  }
  return { type, multiplier: type.value_multiplier };
}

export async function createCollateralApplication(
  input: CreateCollateralApplicationInput, user: Actor,
): Promise<{ no: string }> {
  const member = await one<Member>('SELECT * FROM member WHERE id = ?', input.memberId);
  if (!member) throw new AppError('Member not found', 'NOT_FOUND');
  if (member.status === 'WITHDRAWN' || member.status === 'DECEASED') {
    throw new AppError('This member has exited the society', 'VALIDATION');
  }
  const collateralValue = Math.round(input.collateralValue);
  if (collateralValue <= 0) throw new AppError('Collateral value must be greater than zero', 'VALIDATION');
  const { type, multiplier } = await resolveTypeSnapshot(input.category, input.collateralTypeId);
  await assertNoDuplicateSerial(input.serialRegNo, !!input.multiLinking);

  const no = await nextSequence('COLLATERAL_APPLICATION');
  await run(
    `INSERT INTO collateral_application
       (no, member_id, category, collateral_type_id, collateral_description, multiplier,
        collateral_value, guarantee, serial_reg_no, multi_linking, county_id, last_valuation_date,
        joint_ownership, owner_name, owner_id_no, owner_phone_no, insurance_expiry_date,
        car_track_due_date, cheque_no, created_at, created_by)
     VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)`,
    no, input.memberId, input.category, input.collateralTypeId, type.description, multiplier,
    collateralValue, computeGuarantee(collateralValue, multiplier), input.serialRegNo || null,
    input.multiLinking ? 1 : 0, input.countyId || null, input.lastValuationDate || null,
    input.jointOwnership ? 1 : 0, input.ownerName || null, input.ownerIdNo || null, input.ownerPhoneNo || null,
    input.insuranceExpiryDate || null, input.carTrackDueDate || null, input.chequeNo || null,
    new Date().toISOString(), user.username,
  );
  await audit(user, 'COLLATERAL_APPLICATION_CREATE', 'collateral_application', no, { memberId: input.memberId });
  return { no };
}

export interface UpdateCollateralApplicationInput extends Partial<CreateCollateralApplicationInput> {}

export async function updateCollateralApplication(
  no: string, body: UpdateCollateralApplicationInput, user: Actor,
): Promise<CollateralApplicationWithDetails> {
  const req = await one<CollateralApplication>('SELECT * FROM collateral_application WHERE no = ?', no);
  if (!req) throw new AppError('Collateral application not found', 'NOT_FOUND');
  if (req.status !== 'Open') throw new AppError('Only an open application can be edited', 'VALIDATION');

  const category = body.category ?? req.category;
  const collateralTypeId = body.collateralTypeId ?? req.collateral_type_id;
  const collateralValue = body.collateralValue !== undefined ? Math.round(body.collateralValue) : req.collateral_value;
  const multiLinking = body.multiLinking !== undefined ? body.multiLinking : !!req.multi_linking;
  const serialRegNo = body.serialRegNo !== undefined ? body.serialRegNo : req.serial_reg_no;

  const cols: Record<string, unknown> = {};
  if (body.memberId !== undefined) {
    const member = await one<Member>('SELECT * FROM member WHERE id = ?', body.memberId);
    if (!member) throw new AppError('Member not found', 'NOT_FOUND');
    if (member.status === 'WITHDRAWN' || member.status === 'DECEASED') {
      throw new AppError('This member has exited the society', 'VALIDATION');
    }
    cols.member_id = body.memberId;
  }
  if (body.category !== undefined) cols.category = body.category;
  if (body.countyId !== undefined) cols.county_id = body.countyId || null;
  if (body.lastValuationDate !== undefined) cols.last_valuation_date = body.lastValuationDate || null;
  if (body.jointOwnership !== undefined) cols.joint_ownership = body.jointOwnership ? 1 : 0;
  if (body.ownerName !== undefined) cols.owner_name = body.ownerName || null;
  if (body.ownerIdNo !== undefined) cols.owner_id_no = body.ownerIdNo || null;
  if (body.ownerPhoneNo !== undefined) cols.owner_phone_no = body.ownerPhoneNo || null;
  if (body.insuranceExpiryDate !== undefined) cols.insurance_expiry_date = body.insuranceExpiryDate || null;
  if (body.carTrackDueDate !== undefined) cols.car_track_due_date = body.carTrackDueDate || null;
  if (body.chequeNo !== undefined) cols.cheque_no = body.chequeNo || null;
  if (body.multiLinking !== undefined) cols.multi_linking = body.multiLinking ? 1 : 0;
  if (body.serialRegNo !== undefined) cols.serial_reg_no = body.serialRegNo || null;

  // DEF-14 fixed structurally: whenever either input to the guarantee changes — the value or
  // the type — both the snapshot (multiplier/description) and the guarantee itself are
  // recomputed together in this one path, so the figure can never go stale.
  if (body.collateralValue !== undefined) cols.collateral_value = collateralValue;
  if (collateralTypeId !== null && (body.collateralTypeId !== undefined || body.category !== undefined)) {
    const { type, multiplier } = await resolveTypeSnapshot(category, collateralTypeId);
    cols.collateral_type_id = collateralTypeId;
    cols.collateral_description = type.description;
    cols.multiplier = multiplier;
    cols.guarantee = computeGuarantee(collateralValue, multiplier);
  } else if (body.collateralValue !== undefined) {
    cols.guarantee = computeGuarantee(collateralValue, req.multiplier);
  }

  // BR-06: re-run whenever the serial/reg no or the multi-linking bypass changes.
  if (body.serialRegNo !== undefined || body.multiLinking !== undefined) {
    await assertNoDuplicateSerial(serialRegNo, multiLinking, no);
  }

  const keys = Object.keys(cols);
  if (keys.length) {
    await run(`UPDATE collateral_application SET ${keys.map((c) => `${c}=?`).join(',')} WHERE no=?`, ...keys.map((c) => cols[c]), no);
  }
  await audit(user, 'COLLATERAL_APPLICATION_UPDATE', 'collateral_application', no, { fields: keys });
  return (await getCollateralApplication(no))!;
}

export async function deleteCollateralApplication(no: string, user: Actor): Promise<void> {
  const req = await one<CollateralApplication>('SELECT * FROM collateral_application WHERE no = ?', no);
  if (!req) throw new AppError('Collateral application not found', 'NOT_FOUND');
  if (req.status !== 'Open') throw new AppError('Only an open application can be deleted', 'VALIDATION');
  await run('DELETE FROM collateral_application_attachment WHERE application_no = ?', no);
  await run('DELETE FROM collateral_application WHERE no = ?', no);
  await audit(user, 'COLLATERAL_APPLICATION_DELETE', 'collateral_application', no, {});
}

/** BR-07: everything the register posting will need must be in place before this can be sent
 *  for approval. */
function assertReadyForApproval(req: CollateralApplication): void {
  const missing: string[] = [];
  if (!req.collateral_type_id) missing.push('Collateral Type');
  if (!req.serial_reg_no || !req.serial_reg_no.trim()) missing.push('Serial / Reg. No.');
  if (!(req.collateral_value > 0)) missing.push('Collateral Value');
  if (!(req.guarantee > 0)) missing.push('Guarantee');
  if (missing.length) {
    throw new AppError(`Complete the following before sending for approval: ${missing.join(', ')}`, 'VALIDATION');
  }
}

export async function submitCollateralApplication(no: string, user: Actor): Promise<{ autoApproved: boolean }> {
  const req = await one<CollateralApplication>('SELECT * FROM collateral_application WHERE no = ?', no);
  if (!req) throw new AppError('Collateral application not found', 'NOT_FOUND');
  if (req.status !== 'Open') throw new AppError('Only an open application can be submitted for approval', 'VALIDATION');
  assertReadyForApproval(req);
  await assertNoDuplicateSerial(req.serial_reg_no, !!req.multi_linking, no);

  const matched = await findMatchingWorkflow(
    'COLLATERAL_APPLICATION', await pickConditionFields('COLLATERAL_APPLICATION', req),
  );
  if (!matched) throw new AppError('There is no enabled workflow for this document', 'NO_WORKFLOW');

  await tx(async () => {
    await run("UPDATE collateral_application SET status = 'Pending Approval' WHERE no = ?", no);
    await startWorkflow(matched.workflow, matched.steps, {
      documentType: 'COLLATERAL_APPLICATION', entityId: no, requestedBy: user.username, amount: req.guarantee,
    });
  });

  const after = await one<{ status: string }>('SELECT status FROM collateral_application WHERE no = ?', no);
  return { autoApproved: after?.status === 'Approved' };
}

export async function cancelCollateralApplicationApproval(no: string, user: Actor): Promise<void> {
  const req = await one<Pick<CollateralApplication, 'status' | 'created_by'>>(
    'SELECT status, created_by FROM collateral_application WHERE no = ?', no,
  );
  if (!req) throw new AppError('Collateral application not found', 'NOT_FOUND');
  if (req.status !== 'Pending Approval') {
    throw new AppError('Only a request pending approval can have its approval request cancelled', 'VALIDATION');
  }
  const routed = await findPendingRoutedTask('COLLATERAL_APPLICATION', no);
  const requestedBy = routed?.requested_by ?? req.created_by;
  if (requestedBy !== user.username) {
    throw new AppError('Only the person who submitted this request for approval can cancel it', 'NOT_REQUESTER');
  }
  await run("UPDATE collateral_application SET status = 'Open' WHERE no = ?", no);
  await audit(user, 'COLLATERAL_APPLICATION_CANCEL_APPROVAL', 'collateral_application', no, {});
}

export async function approveCollateralApplication(no: string, user: Actor): Promise<void> {
  const req = await one<CollateralApplication>('SELECT * FROM collateral_application WHERE no = ?', no);
  if (!req) throw new AppError('Collateral application not found', 'NOT_FOUND');
  if (req.status !== 'Pending Approval') throw new AppError('Only a request pending approval can be approved', 'VALIDATION');
  await run("UPDATE collateral_application SET status = 'Approved', decision_reason = NULL WHERE no = ?", no);
  await audit(user, 'COLLATERAL_APPLICATION_APPROVE', 'collateral_application', no, {});
}

export async function rejectCollateralApplication(no: string, reason: string | null, user: Actor): Promise<void> {
  if (!reason || !reason.trim()) throw new AppError('A reason is required to reject a request', 'VALIDATION');
  const req = await one<CollateralApplication>('SELECT * FROM collateral_application WHERE no = ?', no);
  if (!req) throw new AppError('Collateral application not found', 'NOT_FOUND');
  if (req.status !== 'Pending Approval') throw new AppError('Only a request pending approval can be rejected', 'VALIDATION');
  await run("UPDATE collateral_application SET status = 'Open', decision_reason = ? WHERE no = ?", reason, no);
  await audit(user, 'COLLATERAL_APPLICATION_REJECT', 'collateral_application', no, { reason });
}

/**
 * BR-14 — Approved -> writes (or, for a re-processed document, re-writes in place) the
 * accepted collateral_register row under the same `no`. A single upsert inside a transaction
 * fixes DEF-01 (Serial/Reg No. is copied), DEF-02 (the update path always persists) and DEF-03
 * (processed_at is always set) all at once, since there is only one code path rather than the
 * source's separate, inconsistent insert/update branches.
 */
export async function postCollateralApplication(no: string, user: Actor): Promise<{ registerNo: string }> {
  return tx(async () => {
    const req = await one<CollateralApplication>('SELECT * FROM collateral_application WHERE no = ?', no);
    if (!req) throw new AppError('Collateral application not found', 'NOT_FOUND');
    if (req.status !== 'Approved') throw new AppError('Only an approved application can be posted to the register', 'VALIDATION');

    const postingDate = today();
    await run(
      `INSERT INTO collateral_register
         (no, member_id, category, collateral_type_id, collateral_description, collateral_value,
          guarantee, serial_reg_no, posting_date, county_id, owner_name, owner_id_no, owner_phone_no,
          insurance_expiry_date, car_track_due_date, created_at)
       VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)
       ON CONFLICT (no) DO UPDATE SET
         member_id = EXCLUDED.member_id, category = EXCLUDED.category,
         collateral_type_id = EXCLUDED.collateral_type_id, collateral_description = EXCLUDED.collateral_description,
         collateral_value = EXCLUDED.collateral_value, guarantee = EXCLUDED.guarantee,
         serial_reg_no = EXCLUDED.serial_reg_no, posting_date = EXCLUDED.posting_date,
         county_id = EXCLUDED.county_id, owner_name = EXCLUDED.owner_name, owner_id_no = EXCLUDED.owner_id_no,
         owner_phone_no = EXCLUDED.owner_phone_no, insurance_expiry_date = EXCLUDED.insurance_expiry_date,
         car_track_due_date = EXCLUDED.car_track_due_date`,
      no, req.member_id, req.category, req.collateral_type_id, req.collateral_description, req.collateral_value,
      req.guarantee, req.serial_reg_no, postingDate, req.county_id, req.owner_name, req.owner_id_no,
      req.owner_phone_no, req.insurance_expiry_date, req.car_track_due_date, new Date().toISOString(),
    );

    await run(
      `UPDATE collateral_application SET status = 'Processed', processed_at = ?, processed_by = ? WHERE no = ?`,
      new Date().toISOString(), user.username, no,
    );
    await audit(user, 'COLLATERAL_APPLICATION_POST', 'collateral_application', no, {});
    return { registerNo: no };
  });
}
