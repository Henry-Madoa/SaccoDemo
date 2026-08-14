import { one, all, run, tx, nextSequence, audit } from './db.ts';
import { AppError } from './errors.ts';
import {
  MEMBER_FIELDS, getMember, updateMember, type MemberField, type MemberInput,
} from './members.ts';
import { findMatchingWorkflow, findPendingRoutedTask, pickConditionFields, startWorkflow } from './workflow.ts';
import type {
  Actor, AuditEntry, MemberEditFieldDiff, MemberEditRequest, MemberEditRequestWithDimensions,
  MemberWithDimensions,
} from './types.ts';

/** Every member field this workflow may change — every MEMBER_FIELDS entry except the
 *  member's own lifecycle `status`, which stays out of this flow. */
const EDIT_FIELDS = MEMBER_FIELDS.filter((f) => f !== 'status') as Exclude<MemberField, 'status'>[];

export type MemberEditField = (typeof EDIT_FIELDS)[number];
export type MemberEditInput = Partial<Record<MemberEditField, string | number | null>>;

/** The four nav sub-views — "processed" means the change has actually landed on the member. */
export type MemberEditView = 'open' | 'pending' | 'approved' | 'processed';

const VIEW_CLAUSE: Record<MemberEditView, string> = {
  open: "e.status = 'Open'",
  pending: "e.status = 'Pending Approval'",
  approved: "e.status = 'Approved'",
  processed: "e.status = 'Committed'",
};

/** Human labels for the diff summary — the same strings info-cards.tsx already writes by hand. */
const FIELD_LABELS: Record<MemberEditField, string> = {
  member_type: 'Member type', member_category_id: 'Member category', title: 'Title',
  first_name: 'First name', middle_name: 'Middle name', last_name: 'Last name',
  national_id: 'National ID', kra_pin: 'KRA PIN', date_of_birth: 'Date of birth',
  gender: 'Gender', marital_status: 'Marital status', phone: 'Phone', email: 'Email',
  postal_address: 'Postal address', physical_address: 'Physical address',
  county_id: 'County', sub_county_id: 'Sub-county', employer: 'Employer',
  employment_status: 'Employment status', staff_no: 'Staff no.', gross_income: 'Gross income',
  other_deductions: 'Other deductions', kyc_verified: 'KYC verified', join_date: 'Date joined',
  photo: 'Photo', front_id_image: 'Front ID image', back_id_image: 'Back ID image',
  signature_image: 'Signature', fingerprint1_image: 'Fingerprint 1', fingerprint2_image: 'Fingerprint 2',
  notes: 'Notes', group_name: 'Group / entity name', registration_no: 'Registration no.',
  registration_date: 'Registration date', contact_person_name: 'Contact person',
  contact_person_phone: 'Contact phone', contact_person_email: 'Contact email',
  member_count: 'Number of members',
  global_dimension_1_id: 'Global dimension 1', global_dimension_2_id: 'Global dimension 2',
};

const SELECT_EDIT_REQUEST = `
  SELECT e.*, m.member_no AS member_no, m.first_name AS member_first_name, m.last_name AS member_last_name,
         c.name AS county_name, sc.name AS sub_county_name,
         mc.description AS member_category_name, mc.category_type AS member_category_type,
         gd1.code AS global_dimension_1_code, gd1.name AS global_dimension_1_name,
         gd2.code AS global_dimension_2_code, gd2.name AS global_dimension_2_name
  FROM member_edit_request e
  JOIN member m ON m.id = e.member_id
  LEFT JOIN county c ON c.id = e.county_id
  LEFT JOIN sub_county sc ON sc.id = e.sub_county_id
  LEFT JOIN member_category mc ON mc.id = e.member_category_id
  LEFT JOIN global_dimension_1_value gd1 ON gd1.id = e.global_dimension_1_id
  LEFT JOIN global_dimension_2_value gd2 ON gd2.id = e.global_dimension_2_id`;

export interface ListEditRequestsOptions {
  view?: MemberEditView;
  search?: string;
}

export const listMemberEditRequests = (
  { view, search = '' }: ListEditRequestsOptions = {},
): Promise<MemberEditRequestWithDimensions[]> =>
  all<MemberEditRequestWithDimensions>(
    `${SELECT_EDIT_REQUEST}
     WHERE (m.first_name LIKE @like OR m.last_name LIKE @like OR m.member_no LIKE @like OR e.no LIKE @like)
       ${view ? `AND ${VIEW_CLAUSE[view]}` : ''}
     ORDER BY e.no DESC`,
    { like: `%${String(search).trim()}%` },
  );

export const getMemberEditRequest = (no: string): Promise<MemberEditRequestWithDimensions | undefined> =>
  one<MemberEditRequestWithDimensions>(`${SELECT_EDIT_REQUEST} WHERE e.no = ?`, no);

/** The member's own currently in-flight (not yet Rejected/Committed) edit request, if any —
 *  used to gate a second request and to link the member page at whatever's already open. */
export const getOpenMemberEditRequest = (memberId: number): Promise<MemberEditRequest | undefined> =>
  one<MemberEditRequest>(
    "SELECT * FROM member_edit_request WHERE member_id = ? AND status NOT IN ('Rejected','Committed') ORDER BY no DESC",
    memberId,
  );

/** Every audit_log entry recorded against this edit request, newest first. */
export const listEditAuditTrail = (no: string): Promise<AuditEntry[]> =>
  all<AuditEntry>(
    "SELECT * FROM audit_log WHERE entity = 'member_edit_request' AND entity_id = ? ORDER BY id DESC", no,
  );

/** Snapshots the member's current values into a fresh, editable request — unlike a member
 *  application's blank slate, an edit needs a full copy so the inline-edit cards have
 *  something to show, and so the eventual diff has a real "before" to compare against. */
export async function createMemberEditRequest(memberId: number, user: Actor): Promise<{ no: string }> {
  const member = await getMember(memberId);
  if (!member) throw new AppError('Member not found', 'NOT_FOUND');

  const inFlight = await getOpenMemberEditRequest(memberId);
  if (inFlight) {
    throw new AppError(
      `${member.member_no} already has an edit request in flight (${inFlight.no}) — finish or cancel it first`,
      'DUPLICATE_REQUEST',
    );
  }

  const no = await nextSequence('MEMBER_EDIT');
  const values = EDIT_FIELDS.map((f) => (member as unknown as Record<string, string | number | null>)[f]);
  await run(
    `INSERT INTO member_edit_request (no, member_id, created_at, created_by, ${EDIT_FIELDS.join(',')})
     VALUES (?,?,?,?${EDIT_FIELDS.map(() => ',?').join('')})`,
    no, memberId, new Date().toISOString(), user.username, ...values,
  );
  await audit(user, 'MEMBER_EDIT_CREATE', 'member_edit_request', no, { memberId });
  return { no };
}

export async function updateMemberEditRequest(
  no: string, body: MemberEditInput, user: Actor,
): Promise<MemberEditRequestWithDimensions> {
  const req = await one<MemberEditRequest>('SELECT status FROM member_edit_request WHERE no = ?', no);
  if (!req) throw new AppError('Edit request not found', 'NOT_FOUND');
  if (req.status !== 'Open') throw new AppError('Only an open edit request can be edited', 'VALIDATION');

  const cols = EDIT_FIELDS.filter((f) => body[f] !== undefined);
  if (cols.length) {
    await run(
      `UPDATE member_edit_request SET ${cols.map((c) => `${c}=?`).join(',')} WHERE no=?`,
      ...cols.map((c) => body[c]!), no,
    );
  }
  await audit(user, 'MEMBER_EDIT_UPDATE', 'member_edit_request', no, { fields: cols });
  return (await getMemberEditRequest(no))!;
}

export async function submitMemberEditRequest(no: string, user: Actor): Promise<void> {
  const req = await one<MemberEditRequest>('SELECT * FROM member_edit_request WHERE no = ?', no);
  if (!req) throw new AppError('Edit request not found', 'NOT_FOUND');
  if (req.status !== 'Open') {
    throw new AppError('Only an open edit request can be submitted for approval', 'VALIDATION');
  }

  const matched = await findMatchingWorkflow('MEMBER_EDIT', await pickConditionFields('MEMBER_EDIT', req));
  if (!matched) {
    throw new AppError('There is no enabled workflow for this document', 'NO_WORKFLOW');
  }

  await tx(async () => {
    await run("UPDATE member_edit_request SET status = 'Pending Approval' WHERE no = ?", no);
    await audit(user, 'MEMBER_EDIT_SUBMIT', 'member_edit_request', no, {});
    await startWorkflow(matched.workflow, matched.steps, {
      documentType: 'MEMBER_EDIT', entityId: no, requestedBy: user.username, amount: req.gross_income,
    });
  });
}

/** Pulls a submission back to Open — same rules as cancelApplicationApproval(). */
export async function cancelEditApproval(no: string, user: Actor): Promise<void> {
  const req = await one<Pick<MemberEditRequest, 'status' | 'created_by'>>(
    'SELECT status, created_by FROM member_edit_request WHERE no = ?', no,
  );
  if (!req) throw new AppError('Edit request not found', 'NOT_FOUND');
  if (req.status !== 'Pending Approval') {
    throw new AppError('Only a request pending approval can have its approval request cancelled', 'VALIDATION');
  }
  const routed = await findPendingRoutedTask('MEMBER_EDIT', no);
  const requestedBy = routed?.requested_by ?? req.created_by;
  if (requestedBy !== user.username) {
    throw new AppError('Only the person who submitted this request for approval can cancel it', 'NOT_REQUESTER');
  }
  await run("UPDATE member_edit_request SET status = 'Open' WHERE no = ?", no);
  await audit(user, 'MEMBER_EDIT_CANCEL_APPROVAL', 'member_edit_request', no, {});
}

export async function approveMemberEdit(no: string, user: Actor): Promise<void> {
  const req = await one<MemberEditRequest>('SELECT status FROM member_edit_request WHERE no = ?', no);
  if (!req) throw new AppError('Edit request not found', 'NOT_FOUND');
  if (req.status !== 'Pending Approval') {
    throw new AppError('Only a request pending approval can be approved', 'VALIDATION');
  }
  await run("UPDATE member_edit_request SET status = 'Approved', decision_reason = NULL WHERE no = ?", no);
  await audit(user, 'MEMBER_EDIT_APPROVE', 'member_edit_request', no, {});
}

export async function rejectMemberEdit(no: string, reason: string | null, user: Actor): Promise<void> {
  const req = await one<MemberEditRequest>('SELECT status FROM member_edit_request WHERE no = ?', no);
  if (!req) throw new AppError('Edit request not found', 'NOT_FOUND');
  if (req.status !== 'Pending Approval') {
    throw new AppError('Only a request pending approval can be rejected', 'VALIDATION');
  }
  await run("UPDATE member_edit_request SET status = 'Rejected', decision_reason = ? WHERE no = ?", reason || null, no);
  await audit(user, 'MEMBER_EDIT_REJECT', 'member_edit_request', no, { reason });
}

/** Approved -> applies onto the live member via members.updateMember(), then marks Committed. */
export async function processMemberEdit(no: string, user: Actor): Promise<{ memberId: number }> {
  return tx(async () => {
    const req = await one<MemberEditRequest>('SELECT * FROM member_edit_request WHERE no = ?', no);
    if (!req) throw new AppError('Edit request not found', 'NOT_FOUND');
    if (req.status !== 'Approved') {
      throw new AppError('Only an approved request can be applied to the member', 'VALIDATION');
    }

    const body: MemberInput = {};
    for (const f of EDIT_FIELDS) body[f] = (req as unknown as Record<string, string | number | null>)[f];
    await updateMember(req.member_id, body, user);
    await run("UPDATE member_edit_request SET status = 'Committed' WHERE no = ?", no);

    await audit(user, 'MEMBER_EDIT_PROCESS', 'member_edit_request', no, { memberId: req.member_id });
    return { memberId: req.member_id };
  });
}

/** Foreign-key fields shown by their resolved name rather than the raw id — the change is
 *  still detected off the id (two different ids could share display text), only the
 *  rendered from/to swaps to the human-readable column. */
const DISPLAY_FIELD: Partial<Record<MemberEditField, { current: string; requested: string }>> = {
  member_category_id: { current: 'member_category_name', requested: 'member_category_name' },
  county_id: { current: 'county_name', requested: 'county_name' },
  sub_county_id: { current: 'sub_county_name', requested: 'sub_county_name' },
  global_dimension_1_id: { current: 'global_dimension_1_name', requested: 'global_dimension_1_name' },
  global_dimension_2_id: { current: 'global_dimension_2_name', requested: 'global_dimension_2_name' },
};

/** Image fields hold an opaque Cloudinary public_id — not worth showing raw, just whether
 *  one is present. */
const IMAGE_FIELDS = new Set<MemberEditField>([
  'photo', 'front_id_image', 'back_id_image', 'signature_image', 'fingerprint1_image', 'fingerprint2_image',
]);

/** Every EDIT_FIELDS entry whose requested value differs from the member's current value —
 *  the "What's changing" summary on the request's view page. */
export function diffMemberEditFields(
  current: MemberWithDimensions, requested: MemberEditRequestWithDimensions,
): MemberEditFieldDiff[] {
  const c = current as unknown as Record<string, string | number | null>;
  const r = requested as unknown as Record<string, string | number | null>;
  const diffs: MemberEditFieldDiff[] = [];
  for (const f of EDIT_FIELDS) {
    const rawFrom = c[f] ?? null;
    const rawTo = r[f] ?? null;
    if (String(rawFrom ?? '') === String(rawTo ?? '')) continue;

    if (IMAGE_FIELDS.has(f)) {
      diffs.push({
        field: f, label: FIELD_LABELS[f],
        from: rawFrom ? 'On file' : 'None', to: rawTo ? 'On file' : 'None',
      });
      continue;
    }
    const display = DISPLAY_FIELD[f];
    diffs.push({
      field: f, label: FIELD_LABELS[f],
      from: display ? (c[display.current] ?? null) : rawFrom,
      to: display ? (r[display.requested] ?? null) : rawTo,
    });
  }
  return diffs;
}
