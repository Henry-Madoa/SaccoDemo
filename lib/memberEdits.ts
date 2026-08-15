import { one, all, run, tx, nextSequence } from './db.ts';
import { AppError } from './errors.ts';
import {
  MEMBER_FIELDS, getMember, updateMember, type MemberField, type MemberInput,
} from './members.ts';
import { listNextOfKin, listNominees, replaceNextOfKin, replaceNominees } from './nominees.ts';
import { listSignatories, replaceSignatories } from './signatories.ts';
import { listEditNextOfKin, listEditNominees, replaceEditNextOfKin, replaceEditNominees } from './editNominees.ts';
import { listEditSignatories, replaceEditSignatories } from './editSignatories.ts';
import { applyEditAttachments, cloneMemberAttachmentsToEdit } from './editAttachments.ts';
import { diffFields, logTableChange } from './changeLog.ts';
import { findMatchingWorkflow, findPendingRoutedTask, pickConditionFields, startWorkflow } from './workflow.ts';
import { buildFilterClause, type FilterCondition, type FilterFieldDef } from './listFilters.ts';
import { buildOrderClause, type SortState } from './listSort.ts';
import {
  MEMBER_TYPES, MEMBER_TITLES, GENDERS, MARITAL_STATUSES, EMPLOYMENT_STATUSES,
} from './constants.ts';
import type {
  Actor, MemberEditFieldDiff, MemberEditRequest, MemberEditRequestWithDimensions,
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
  processed: "e.status = 'Processed'",
};

/** Human labels for the diff summary — the same strings info-cards.tsx already writes by hand. */
const FIELD_LABELS: Record<MemberEditField, string> = {
  member_type: 'Member type', member_category_id: 'Member category', title: 'Title',
  first_name: 'First name', middle_name: 'Middle name', last_name: 'Last name',
  national_id: 'Identification No.', kra_pin: 'KRA PIN', date_of_birth: 'Date of birth',
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

/** Member Edits list's dynamic-filter registry — every meaningful column, same treatment as
 *  Member Applications: the view tabs stay as the primary navigation (so `status` is left
 *  out), image/attachment fields are excluded, and DB-driven fields ship without `options` —
 *  the page fills them in from lookups it already fetches. */
export const EDIT_FILTER_FIELDS: FilterFieldDef[] = [
  { key: 'no', label: 'Request No.', type: 'text', column: 'e.no' },
  { key: 'member_type', label: 'Member Type', type: 'select', column: 'e.member_type', options: MEMBER_TYPES.map((t) => ({ value: t, label: t })) },
  { key: 'member_category_id', label: 'Member Category', type: 'select', column: 'e.member_category_id' },
  { key: 'title', label: 'Title', type: 'select', column: 'e.title', options: MEMBER_TITLES.filter(Boolean).map((t) => ({ value: t, label: t })) },
  { key: 'first_name', label: 'First Name', type: 'text', column: 'e.first_name' },
  { key: 'middle_name', label: 'Middle Name', type: 'text', column: 'e.middle_name' },
  { key: 'last_name', label: 'Last Name', type: 'text', column: 'e.last_name' },
  { key: 'national_id', label: 'Identification No.', type: 'text', column: 'e.national_id' },
  { key: 'kra_pin', label: 'KRA PIN', type: 'text', column: 'e.kra_pin' },
  { key: 'date_of_birth', label: 'Date of Birth', type: 'date', column: 'e.date_of_birth' },
  { key: 'gender', label: 'Gender', type: 'select', column: 'e.gender', options: GENDERS.filter(Boolean).map((g) => ({ value: g, label: g })) },
  { key: 'marital_status', label: 'Marital Status', type: 'select', column: 'e.marital_status', options: MARITAL_STATUSES.filter(Boolean).map((s) => ({ value: s, label: s })) },
  { key: 'phone', label: 'Phone', type: 'text', column: 'e.phone' },
  { key: 'email', label: 'Email', type: 'text', column: 'e.email' },
  { key: 'postal_address', label: 'Postal Address', type: 'text', column: 'e.postal_address' },
  { key: 'physical_address', label: 'Physical Address', type: 'text', column: 'e.physical_address' },
  { key: 'county_id', label: 'County', type: 'select', column: 'e.county_id' },
  { key: 'sub_county_id', label: 'Sub-county', type: 'select', column: 'e.sub_county_id' },
  { key: 'employer', label: 'Employer', type: 'text', column: 'e.employer' },
  { key: 'employment_status', label: 'Employment Status', type: 'select', column: 'e.employment_status', options: EMPLOYMENT_STATUSES.filter(Boolean).map((s) => ({ value: s, label: s })) },
  { key: 'staff_no', label: 'Staff No.', type: 'text', column: 'e.staff_no' },
  { key: 'gross_income', label: 'Gross Income', type: 'number', column: 'e.gross_income' },
  { key: 'other_deductions', label: 'Other Deductions', type: 'number', column: 'e.other_deductions' },
  { key: 'kyc_verified', label: 'KYC Verified', type: 'select', column: 'e.kyc_verified', options: [{ value: 1, label: 'Yes' }, { value: 0, label: 'No' }] },
  { key: 'join_date', label: 'Join Date', type: 'date', column: 'e.join_date' },
  { key: 'notes', label: 'Notes', type: 'text', column: 'e.notes' },
  { key: 'group_name', label: 'Group / Entity Name', type: 'text', column: 'e.group_name' },
  { key: 'registration_no', label: 'Registration No.', type: 'text', column: 'e.registration_no' },
  { key: 'registration_date', label: 'Registration Date', type: 'date', column: 'e.registration_date' },
  { key: 'contact_person_name', label: 'Contact Person', type: 'text', column: 'e.contact_person_name' },
  { key: 'contact_person_phone', label: 'Contact Phone', type: 'text', column: 'e.contact_person_phone' },
  { key: 'contact_person_email', label: 'Contact Email', type: 'text', column: 'e.contact_person_email' },
  { key: 'member_count', label: 'Number of Members', type: 'number', column: 'e.member_count' },
  { key: 'global_dimension_1_id', label: 'Global Dimension 1', type: 'select', column: 'e.global_dimension_1_id' },
  { key: 'global_dimension_2_id', label: 'Global Dimension 2', type: 'select', column: 'e.global_dimension_2_id' },
  { key: 'decision_reason', label: 'Decision Reason', type: 'text', column: 'e.decision_reason' },
  { key: 'created_by', label: 'Created By', type: 'text', column: 'e.created_by' },
  { key: 'created_at', label: 'Created', type: 'date', column: 'e.created_at', datetime: true },
  { key: 'processed_by', label: 'Processed By', type: 'text', column: 'e.processed_by' },
  { key: 'processed_at', label: 'Processed', type: 'date', column: 'e.processed_at', datetime: true },
];

/** Member Edits list's sortable columns — every column shown in the table. */
const EDIT_SORT_COLUMNS: Record<string, string> = {
  no: 'e.no',
  member: 'm.first_name',
  member_no: 'm.member_no',
  status: 'e.status',
};

export interface ListEditRequestsOptions {
  view?: MemberEditView;
  search?: string;
  filters?: FilterCondition[];
  sort?: SortState | null;
}

export const listMemberEditRequests = (
  { view, search = '', filters = [], sort = null }: ListEditRequestsOptions = {},
): Promise<MemberEditRequestWithDimensions[]> => {
  const { clause, params } = buildFilterClause(EDIT_FILTER_FIELDS, filters);
  const orderBy = buildOrderClause(EDIT_SORT_COLUMNS, sort, 'e.no DESC');
  return all<MemberEditRequestWithDimensions>(
    `${SELECT_EDIT_REQUEST}
     WHERE (m.first_name LIKE @like OR m.last_name LIKE @like OR m.member_no LIKE @like OR e.no LIKE @like)
       ${view ? `AND ${VIEW_CLAUSE[view]}` : ''}
       ${clause}
     ${orderBy}`,
    { like: `%${String(search).trim()}%`, ...params },
  );
};

export const getMemberEditRequest = (no: string): Promise<MemberEditRequestWithDimensions | undefined> =>
  one<MemberEditRequestWithDimensions>(`${SELECT_EDIT_REQUEST} WHERE e.no = ?`, no);

/** The edit request immediately before/after this one by number — for the card's
 *  Business-Central-style Previous/Next navigation. Scoped to the same `view` tab the record
 *  was opened from (when given), so paging never steps outside the list the user came from. */
export async function getAdjacentEditRequestNos(
  no: string, view?: MemberEditView,
): Promise<{ prevNo: string | null; nextNo: string | null }> {
  const clause = view ? `AND ${VIEW_CLAUSE[view]}` : '';
  const [prev, next] = await Promise.all([
    one<{ no: string }>(`SELECT e.no FROM member_edit_request e WHERE e.no < ? ${clause} ORDER BY e.no DESC LIMIT 1`, no),
    one<{ no: string }>(`SELECT e.no FROM member_edit_request e WHERE e.no > ? ${clause} ORDER BY e.no ASC LIMIT 1`, no),
  ]);
  return { prevNo: prev?.no ?? null, nextNo: next?.no ?? null };
}

/** The member's own currently in-flight (not yet Processed) edit request, if any — used to
 *  gate a second request and to link the member page at whatever's already open. A rejection
 *  sends the request back to Open rather than a terminal status, so Processed is the only
 *  state that closes it out. */
export const getOpenMemberEditRequest = (memberId: number): Promise<MemberEditRequest | undefined> =>
  one<MemberEditRequest>(
    "SELECT * FROM member_edit_request WHERE member_id = ? AND status != 'Processed' ORDER BY no DESC",
    memberId,
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

  await tx(async () => {
    await run(
      `INSERT INTO member_edit_request (no, member_id, created_at, created_by, ${EDIT_FIELDS.join(',')})
       VALUES (?,?,?,?${EDIT_FIELDS.map(() => ',?').join('')})`,
      no, memberId, new Date().toISOString(), user.username, ...values,
    );

    // Same rationale as the flat fields above: the KYC/Nominee/Next-of-kin/Signatory
    // tabs need a starting point to show and edit, not a blank slate.
    const [nok, nominees, signatories] = await Promise.all([
      listNextOfKin(memberId), listNominees(memberId), listSignatories(memberId),
    ]);
    await replaceEditNextOfKin(no, nok);
    await replaceEditNominees(no, nominees);
    await replaceEditSignatories(no, signatories);
    await cloneMemberAttachmentsToEdit(memberId, no);

    const changes = [
      { field: 'member_id', oldValue: null, newValue: memberId },
      ...EDIT_FIELDS.map((f, i) => ({ field: f, oldValue: null, newValue: values[i] })),
    ];
    await logTableChange('member_edit_request', no, 'Insertion', changes, user);
  });
  return { no };
}

export async function updateMemberEditRequest(
  no: string, body: MemberEditInput, user: Actor,
): Promise<MemberEditRequestWithDimensions> {
  const req = await one<MemberEditRequest>('SELECT * FROM member_edit_request WHERE no = ?', no);
  if (!req) throw new AppError('Edit request not found', 'NOT_FOUND');
  if (req.status !== 'Open') throw new AppError('Only an open edit request can be edited', 'VALIDATION');

  const cols = EDIT_FIELDS.filter((f) => body[f] !== undefined);
  if (cols.length) {
    await run(
      `UPDATE member_edit_request SET ${cols.map((c) => `${c}=?`).join(',')} WHERE no=?`,
      ...cols.map((c) => body[c]!), no,
    );
    const changes = diffFields(
      req as unknown as Record<string, unknown>, Object.fromEntries(cols.map((c) => [c, body[c]])),
    );
    await logTableChange('member_edit_request', no, 'Modification', changes, user);
  }
  return (await getMemberEditRequest(no))!;
}

/** Sends the request into the matched workflow — `autoApproved` tells the caller whether it
 *  came straight back out the other side already Approved (the requester was the resolved
 *  approver at every step; see lib/workflow.ts's requesterClearsLevel()), so the UI can say so
 *  instead of the generic "sent for approval". */
export async function submitMemberEditRequest(no: string, user: Actor): Promise<{ autoApproved: boolean }> {
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
    await logTableChange(
      'member_edit_request', no, 'Modification',
      [{ field: 'status', oldValue: req.status, newValue: 'Pending Approval' }], user,
    );
    await startWorkflow(matched.workflow, matched.steps, {
      documentType: 'MEMBER_EDIT', entityId: no, requestedBy: user.username, amount: req.gross_income,
    });
  });

  const after = await one<{ status: string }>('SELECT status FROM member_edit_request WHERE no = ?', no);
  return { autoApproved: after?.status === 'Approved' };
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
  await logTableChange(
    'member_edit_request', no, 'Modification', [{ field: 'status', oldValue: req.status, newValue: 'Open' }], user,
  );
}

export async function approveMemberEdit(no: string, user: Actor): Promise<void> {
  const req = await one<MemberEditRequest>('SELECT * FROM member_edit_request WHERE no = ?', no);
  if (!req) throw new AppError('Edit request not found', 'NOT_FOUND');
  if (req.status !== 'Pending Approval') {
    throw new AppError('Only a request pending approval can be approved', 'VALIDATION');
  }
  await run("UPDATE member_edit_request SET status = 'Approved', decision_reason = NULL WHERE no = ?", no);
  const changes = diffFields(
    req as unknown as Record<string, unknown>, { status: 'Approved', decision_reason: null },
  );
  await logTableChange('member_edit_request', no, 'Modification', changes, user);
}

/** Rejection sends the request back to Open, not a terminal state — the requester can amend
 *  and resubmit it, the same shape lib/loanService.ts's approve(approve: false) already uses.
 *  decision_reason carries the rejection comment along, so it's visible on the reopened
 *  request until the next decision overwrites or clears it. */
export async function rejectMemberEdit(no: string, reason: string | null, user: Actor): Promise<void> {
  if (!reason || !reason.trim()) throw new AppError('A reason is required to reject a request', 'VALIDATION');
  const req = await one<MemberEditRequest>('SELECT * FROM member_edit_request WHERE no = ?', no);
  if (!req) throw new AppError('Edit request not found', 'NOT_FOUND');
  if (req.status !== 'Pending Approval') {
    throw new AppError('Only a request pending approval can be rejected', 'VALIDATION');
  }
  await run("UPDATE member_edit_request SET status = 'Open', decision_reason = ? WHERE no = ?", reason || null, no);
  const changes = diffFields(
    req as unknown as Record<string, unknown>, { status: 'Open', decision_reason: reason || null },
  );
  await logTableChange('member_edit_request', no, 'Modification', changes, user);
}

/** Approved -> applies onto the live member via members.updateMember(), then marks Processed. */
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

    const [nok, nominees, signatories] = await Promise.all([
      listEditNextOfKin(no), listEditNominees(no), listEditSignatories(no),
    ]);
    await replaceNextOfKin(req.member_id, nok, user);
    await replaceNominees(req.member_id, nominees, user);
    await replaceSignatories(req.member_id, signatories, user);
    await applyEditAttachments(no, req.member_id, user);

    await run(
      "UPDATE member_edit_request SET status = 'Processed', processed_at = ?, processed_by = ? WHERE no = ?",
      new Date().toISOString(), user.username, no,
    );

    const changes = diffFields(req as unknown as Record<string, unknown>, { status: 'Processed' });
    await logTableChange('member_edit_request', no, 'Modification', changes, user);
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
