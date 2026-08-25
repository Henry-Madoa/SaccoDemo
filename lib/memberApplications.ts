import {
  one, all, run, tx, nextSequence, hasAnyRow,
} from './db.ts';
import { AppError } from './errors.ts';
import { createMember, type MemberInput } from './members.ts';
import { listApplicationNextOfKin, listApplicationNominees } from './applicationNominees.ts';
import { listApplicationSignatories } from './applicationSignatories.ts';
import { diffFields, logTableChange } from './changeLog.ts';
import { findMatchingWorkflow, findPendingRoutedTask, pickConditionFields, startWorkflow } from './workflow.ts';
import { getMemberCategoryDefaultAccounts } from './pool.ts';
import { openAccount } from './savings.ts';
import { buildFilterClause, type FilterCondition, type FilterFieldDef } from './listFilters.ts';
import { buildOrderClause, type SortState } from './listSort.ts';
import {
  MEMBER_TYPES, MEMBER_TITLES, GENDERS, MARITAL_STATUSES, EMPLOYMENT_STATUSES,
} from './constants.ts';
import type {
  Actor, MemberApplication, MemberApplicationAttachment, MemberApplicationWithDimensions,
} from './types.ts';

const APPLICATION_FIELDS = [
  'member_type', 'member_category_id', 'title', 'first_name', 'middle_name', 'last_name', 'identification_no', 'kra_pin',
  'date_of_birth', 'gender', 'marital_status', 'phone', 'email', 'postal_address', 'physical_address',
  'county_id', 'sub_county_id', 'employer', 'employment_status', 'staff_no',
  'kyc_verified', 'join_date',
  'notes', 'photo', 'front_id_image', 'back_id_image', 'signature_image',
  'fingerprint1_image', 'fingerprint2_image',
  'group_name', 'registration_no', 'registration_date',
  'contact_person_name', 'contact_person_phone', 'contact_person_email', 'member_count',
  'global_dimension_1_id', 'global_dimension_2_id',
] as const satisfies readonly (keyof MemberApplication)[];

export type MemberApplicationField = (typeof APPLICATION_FIELDS)[number];
export type MemberApplicationInput = Partial<Record<MemberApplicationField, string | number | null>>;

/** The four nav sub-views — "processed" means a member has actually been created, not a specific status string. */
export type MemberApplicationView = 'open' | 'pending' | 'approved' | 'processed';

const VIEW_CLAUSE: Record<MemberApplicationView, string> = {
  open: "a.status = 'Open'",
  pending: "a.status = 'Pending Approval'",
  approved: "a.status = 'Approved'",
  processed: 'a.member_id IS NOT NULL',
};

const SELECT_APPLICATION = `
  SELECT a.*, c.name AS county_name, sc.name AS sub_county_name,
         mc.description AS member_category_name, mc.category_type AS member_category_type,
         m.member_no AS member_no,
         gd1.code AS global_dimension_1_code, gd1.name AS global_dimension_1_name,
         gd2.code AS global_dimension_2_code, gd2.name AS global_dimension_2_name
  FROM member_application a
  LEFT JOIN county c ON c.id = a.county_id
  LEFT JOIN sub_county sc ON sc.id = a.sub_county_id
  LEFT JOIN member_category mc ON mc.id = a.member_category_id
  LEFT JOIN member m ON m.id = a.member_id
  LEFT JOIN global_dimension_1_value gd1 ON gd1.id = a.global_dimension_1_id
  LEFT JOIN global_dimension_2_value gd2 ON gd2.id = a.global_dimension_2_id`;

/** Member Applications list's dynamic-filter registry — every meaningful column, sitting
 *  alongside the view tabs (which remain the primary Open/Pending/Approved/Processed
 *  navigation, so `status` is deliberately left out here). Image/attachment fields (photo,
 *  front/back id, signature, fingerprints) are excluded — nothing to filter on. DB-driven
 *  fields (member_category_id, county_id, sub_county_id, both dimensions) ship without
 *  `options`; the page fills them in from lookups it already fetches. */
export const APPLICATION_FILTER_FIELDS: FilterFieldDef[] = [
  { key: 'no', label: 'Application No.', type: 'text', column: 'a.no' },
  { key: 'member_type', label: 'Member Type', type: 'select', column: 'a.member_type', options: MEMBER_TYPES.map((t) => ({ value: t, label: t })) },
  { key: 'member_category_id', label: 'Member Category', type: 'select', column: 'a.member_category_id' },
  { key: 'title', label: 'Title', type: 'select', column: 'a.title', options: MEMBER_TITLES.filter(Boolean).map((t) => ({ value: t, label: t })) },
  { key: 'first_name', label: 'First Name', type: 'text', column: 'a.first_name' },
  { key: 'middle_name', label: 'Middle Name', type: 'text', column: 'a.middle_name' },
  { key: 'last_name', label: 'Last Name', type: 'text', column: 'a.last_name' },
  { key: 'identification_no', label: 'Identification No.', type: 'text', column: 'a.identification_no' },
  { key: 'kra_pin', label: 'KRA PIN', type: 'text', column: 'a.kra_pin' },
  { key: 'date_of_birth', label: 'Date of Birth', type: 'date', column: 'a.date_of_birth' },
  { key: 'gender', label: 'Gender', type: 'select', column: 'a.gender', options: GENDERS.filter(Boolean).map((g) => ({ value: g, label: g })) },
  { key: 'marital_status', label: 'Marital Status', type: 'select', column: 'a.marital_status', options: MARITAL_STATUSES.filter(Boolean).map((s) => ({ value: s, label: s })) },
  { key: 'phone', label: 'Phone', type: 'text', column: 'a.phone' },
  { key: 'email', label: 'Email', type: 'text', column: 'a.email' },
  { key: 'postal_address', label: 'Postal Address', type: 'text', column: 'a.postal_address' },
  { key: 'physical_address', label: 'Physical Address', type: 'text', column: 'a.physical_address' },
  { key: 'county_id', label: 'County', type: 'select', column: 'a.county_id' },
  { key: 'sub_county_id', label: 'Sub-county', type: 'select', column: 'a.sub_county_id' },
  { key: 'employer', label: 'Employer', type: 'text', column: 'a.employer' },
  { key: 'employment_status', label: 'Employment Status', type: 'select', column: 'a.employment_status', options: EMPLOYMENT_STATUSES.filter(Boolean).map((s) => ({ value: s, label: s })) },
  { key: 'staff_no', label: 'Staff No.', type: 'text', column: 'a.staff_no' },
  { key: 'kyc_verified', label: 'KYC Verified', type: 'select', column: 'a.kyc_verified', options: [{ value: 1, label: 'Yes' }, { value: 0, label: 'No' }] },
  { key: 'join_date', label: 'Join Date', type: 'date', column: 'a.join_date' },
  { key: 'notes', label: 'Notes', type: 'text', column: 'a.notes' },
  { key: 'group_name', label: 'Group / Entity Name', type: 'text', column: 'a.group_name' },
  { key: 'registration_no', label: 'Registration No.', type: 'text', column: 'a.registration_no' },
  { key: 'registration_date', label: 'Registration Date', type: 'date', column: 'a.registration_date' },
  { key: 'contact_person_name', label: 'Contact Person', type: 'text', column: 'a.contact_person_name' },
  { key: 'contact_person_phone', label: 'Contact Phone', type: 'text', column: 'a.contact_person_phone' },
  { key: 'contact_person_email', label: 'Contact Email', type: 'text', column: 'a.contact_person_email' },
  { key: 'member_count', label: 'Number of Members', type: 'number', column: 'a.member_count' },
  { key: 'global_dimension_1_id', label: 'Global Dimension 1', type: 'select', column: 'a.global_dimension_1_id' },
  { key: 'global_dimension_2_id', label: 'Global Dimension 2', type: 'select', column: 'a.global_dimension_2_id' },
  { key: 'decision_reason', label: 'Decision Reason', type: 'text', column: 'a.decision_reason' },
  { key: 'created_by', label: 'Created By', type: 'text', column: 'a.created_by' },
  { key: 'created_at', label: 'Created', type: 'date', column: 'a.created_at', datetime: true },
  { key: 'processed_by', label: 'Processed By', type: 'text', column: 'a.processed_by' },
  { key: 'processed_at', label: 'Processed', type: 'date', column: 'a.processed_at', datetime: true },
];

/** Member Applications list's sortable columns — every column shown in the table. */
const APPLICATION_SORT_COLUMNS: Record<string, string> = {
  no: 'a.no',
  name: 'a.first_name',
  identification_no: 'a.identification_no',
  phone: 'a.phone',
  status: 'a.status',
};

export interface ListApplicationsOptions {
  view?: MemberApplicationView;
  search?: string;
  filters?: FilterCondition[];
  sort?: SortState | null;
}

export const listMemberApplications = (
  { view, search = '', filters = [], sort = null }: ListApplicationsOptions = {},
): Promise<MemberApplicationWithDimensions[]> => {
  const { clause, params } = buildFilterClause(APPLICATION_FILTER_FIELDS, filters);
  const orderBy = buildOrderClause(APPLICATION_SORT_COLUMNS, sort, 'a.no DESC');
  return all<MemberApplicationWithDimensions>(
    `${SELECT_APPLICATION}
     WHERE (a.first_name LIKE @like OR a.last_name LIKE @like OR a.identification_no LIKE @like OR a.no LIKE @like)
       ${view ? `AND ${VIEW_CLAUSE[view]}` : ''}
       ${clause}
     ${orderBy}`,
    { like: `%${String(search).trim()}%`, ...params },
  );
};

export const getMemberApplication = (no: string): Promise<MemberApplicationWithDimensions | undefined> =>
  one<MemberApplicationWithDimensions>(`${SELECT_APPLICATION} WHERE a.no = ?`, no);

/** Whether the current view tab has any applications at all, ignoring search and dynamic
 *  filters — lets the page grey out its filter controls only when there's truly nothing to
 *  filter. */
export const hasAnyMemberApplications = (view?: MemberApplicationView): Promise<boolean> =>
  hasAnyRow('member_application a', view ? VIEW_CLAUSE[view] : undefined);

/** The application immediately before/after this one by number — for the card's
 *  Business-Central-style Previous/Next navigation. Scoped to the same `view` tab the record
 *  was opened from (when given), so paging never steps outside the list the user came from. */
export async function getAdjacentApplicationNos(
  no: string, view?: MemberApplicationView,
): Promise<{ prevNo: string | null; nextNo: string | null }> {
  const clause = view ? `AND ${VIEW_CLAUSE[view]}` : '';
  const [prev, next] = await Promise.all([
    one<{ no: string }>(`SELECT a.no FROM member_application a WHERE a.no < ? ${clause} ORDER BY a.no DESC LIMIT 1`, no),
    one<{ no: string }>(`SELECT a.no FROM member_application a WHERE a.no > ? ${clause} ORDER BY a.no ASC LIMIT 1`, no),
  ]);
  return { prevNo: prev?.no ?? null, nextNo: next?.no ?? null };
}

export async function createMemberApplication(
  body: MemberApplicationInput, user: Actor,
): Promise<{ no: string }> {
  const no = await nextSequence('MEMBER_APPLICATION');
  const cols = APPLICATION_FIELDS.filter((f) => body[f] !== undefined);
  await run(
    `INSERT INTO member_application (no, created_at, created_by${cols.length ? ',' + cols.join(',') : ''})
     VALUES (?,?,?${cols.map(() => ',?').join('')})`,
    no, new Date().toISOString(), user.username, ...cols.map((c) => body[c]!),
  );
  await logTableChange(
    'member_application', no, 'Insertion', cols.map((c) => ({ field: c, oldValue: null, newValue: body[c] })), user,
  );
  return { no };
}

export async function updateMemberApplication(
  no: string, body: MemberApplicationInput, user: Actor,
): Promise<MemberApplicationWithDimensions> {
  const app = await one<MemberApplication>('SELECT * FROM member_application WHERE no = ?', no);
  if (!app) throw new AppError('Application not found', 'NOT_FOUND');
  if (app.status !== 'Open') throw new AppError('Only an open application can be edited', 'VALIDATION');

  const cols = APPLICATION_FIELDS.filter((f) => body[f] !== undefined);
  if (cols.length) {
    await run(
      `UPDATE member_application SET ${cols.map((c) => `${c}=?`).join(',')} WHERE no=?`,
      ...cols.map((c) => body[c]!), no,
    );
    const changes = diffFields(
      app as unknown as Record<string, unknown>, Object.fromEntries(cols.map((c) => [c, body[c]])),
    );
    await logTableChange('member_application', no, 'Modification', changes, user);
  }
  return (await getMemberApplication(no))!;
}

/** Sends the application into the matched workflow — `autoApproved` tells the caller whether
 *  it came straight back out the other side already Approved (the requester was the resolved
 *  approver at every step; see lib/workflow.ts's requesterClearsLevel()), so the UI can say so
 *  instead of the generic "sent for approval". */
export async function submitMemberApplication(no: string, user: Actor): Promise<{ autoApproved: boolean }> {
  const app = await one<MemberApplication>('SELECT * FROM member_application WHERE no = ?', no);
  if (!app) throw new AppError('Application not found', 'NOT_FOUND');
  if (app.status !== 'Open') {
    throw new AppError('Only an open application can be submitted for approval', 'VALIDATION');
  }

  // Validation: ensure required related records exist before submitting
  // - INDIVIDUAL categories require at least one Next of Kin and one Nominee
  // - Non-individual categories require at least one Signatory
  // If member_category_id is not set, treat as INDIVIDUAL (legacy behaviour elsewhere).
  const categoryRow = app.member_category_id
    ? await one<{ category_type: string }>('SELECT category_type FROM member_category WHERE id = ?', app.member_category_id)
    : null;
  const categoryType = categoryRow?.category_type ?? 'INDIVIDUAL';
  if (categoryType === 'INDIVIDUAL') {
    const [nextOfKin, nominees] = await Promise.all([
      listApplicationNextOfKin(no),
      listApplicationNominees(no),
    ]);
    if (!nextOfKin || nextOfKin.length === 0) {
      throw new AppError('Individual applications must include at least one Next of Kin', 'VALIDATION');
    }
    if (!nominees || nominees.length === 0) {
      throw new AppError('Individual applications must include at least one Nominee', 'VALIDATION');
    }
  } else {
    const signatories = await listApplicationSignatories(no);
    if (!signatories || signatories.length === 0) {
      throw new AppError('Non-individual applications must include at least one Signatory', 'VALIDATION');
    }
  }

  // Submitting always requires routing through an admin-defined, enabled workflow —
  // there's no falling back to a flat permission check for a fresh submission.
  const matched = await findMatchingWorkflow(
    'MEMBER_APPLICATION', await pickConditionFields('MEMBER_APPLICATION', app),
  );
  if (!matched) {
    throw new AppError('There is no enabled workflow for this document', 'NO_WORKFLOW');
  }

  await tx(async () => {
    await run("UPDATE member_application SET status = 'Pending Approval' WHERE no = ?", no);
    await logTableChange(
      'member_application', no, 'Modification',
      [{ field: 'status', oldValue: app.status, newValue: 'Pending Approval' }], user,
    );
    await startWorkflow(matched.workflow, matched.steps, {
      documentType: 'MEMBER_APPLICATION', entityId: no, requestedBy: user.username, amount: 0,
    });
  });

  const after = await one<{ status: string }>('SELECT status FROM member_application WHERE no = ?', no);
  return { autoApproved: after?.status === 'Approved' };
}

/**
 * Pulls a submission back to Open.
 *
 * Only valid while still "Pending Approval" — the single-step approve action
 * moves an application straight to "Approved", so being in "Pending Approval"
 * already means no approver has acted on it yet. Only whoever actually sent it
 * for approval may cancel the request — not just anyone who can create applications.
 */
export async function cancelApplicationApproval(no: string, user: Actor): Promise<void> {
  const app = await one<Pick<MemberApplication, 'status' | 'created_by'>>(
    'SELECT status, created_by FROM member_application WHERE no = ?', no,
  );
  if (!app) throw new AppError('Application not found', 'NOT_FOUND');
  if (app.status !== 'Pending Approval') {
    throw new AppError('Only an application pending approval can have its approval request cancelled', 'VALIDATION');
  }
  const routed = await findPendingRoutedTask('MEMBER_APPLICATION', no);
  const requestedBy = routed?.requested_by ?? app.created_by;
  if (requestedBy !== user.username) {
    throw new AppError('Only the person who submitted this application for approval can cancel the request', 'NOT_REQUESTER');
  }
  await run("UPDATE member_application SET status = 'Open' WHERE no = ?", no);
  await logTableChange(
    'member_application', no, 'Modification', [{ field: 'status', oldValue: app.status, newValue: 'Open' }], user,
  );
}

export async function approveMemberApplication(no: string, user: Actor): Promise<void> {
  const app = await one<MemberApplication>('SELECT * FROM member_application WHERE no = ?', no);
  if (!app) throw new AppError('Application not found', 'NOT_FOUND');
  if (app.status !== 'Pending Approval') {
    throw new AppError('Only an application pending approval can be approved', 'VALIDATION');
  }
  await run("UPDATE member_application SET status = 'Approved', decision_reason = NULL WHERE no = ?", no);
  const changes = diffFields(
    app as unknown as Record<string, unknown>, { status: 'Approved', decision_reason: null },
  );
  await logTableChange('member_application', no, 'Modification', changes, user);
}

/** Rejection sends the application back to Open, not a terminal state — the applicant can
 *  amend and resubmit it, the same shape lib/loanService.ts's approve(approve: false) already
 *  uses. decision_reason carries the rejection comment along, so it's visible on the
 *  reopened application until the next decision overwrites or clears it. */
export async function rejectMemberApplication(no: string, reason: string | null, user: Actor): Promise<void> {
  if (!reason || !reason.trim()) throw new AppError('A reason is required to reject an application', 'VALIDATION');
  const app = await one<MemberApplication>('SELECT * FROM member_application WHERE no = ?', no);
  if (!app) throw new AppError('Application not found', 'NOT_FOUND');
  if (app.status !== 'Pending Approval') {
    throw new AppError('Only an application pending approval can be rejected', 'VALIDATION');
  }
  await run("UPDATE member_application SET status = 'Open', decision_reason = ? WHERE no = ?", reason || null, no);
  const changes = diffFields(
    app as unknown as Record<string, unknown>, { status: 'Open', decision_reason: reason || null },
  );
  await logTableChange('member_application', no, 'Modification', changes, user);
}

/** Approved -> a real member.createMember() call, linked back onto the application as "Processed". */
export async function createMemberFromApplication(no: string, user: Actor): Promise<{ memberId: number }> {
  return tx(async () => {
    const app = await one<MemberApplication>('SELECT * FROM member_application WHERE no = ?', no);
    if (!app) throw new AppError('Application not found', 'NOT_FOUND');
    if (app.status !== 'Approved') {
      throw new AppError('Only an approved application can be turned into a member', 'VALIDATION');
    }

    const body: MemberInput = {
      member_type: app.member_type, member_category_id: app.member_category_id, title: app.title,
      first_name: app.first_name, middle_name: app.middle_name, last_name: app.last_name,
      identification_no: app.identification_no, kra_pin: app.kra_pin, date_of_birth: app.date_of_birth,
      gender: app.gender, marital_status: app.marital_status, phone: app.phone, email: app.email,
      postal_address: app.postal_address, physical_address: app.physical_address,
      county_id: app.county_id, sub_county_id: app.sub_county_id, employer: app.employer,
      employment_status: app.employment_status, staff_no: app.staff_no, status: 'NOT PAID UP',
      kyc_verified: app.kyc_verified, join_date: app.join_date, notes: app.notes, photo: app.photo,
      front_id_image: app.front_id_image, back_id_image: app.back_id_image,
      signature_image: app.signature_image, fingerprint1_image: app.fingerprint1_image,
      fingerprint2_image: app.fingerprint2_image,
      group_name: app.group_name, registration_no: app.registration_no, registration_date: app.registration_date,
      contact_person_name: app.contact_person_name, contact_person_phone: app.contact_person_phone,
      contact_person_email: app.contact_person_email, member_count: app.member_count,
      global_dimension_1_id: app.global_dimension_1_id, global_dimension_2_id: app.global_dimension_2_id,
    };
    const member = await createMember(body, user);
    await run(
      `UPDATE member_application
       SET member_id = ?, status = 'Processed', processed_at = ?, processed_by = ? WHERE no = ?`,
      member.id, new Date().toISOString(), user.username, no,
    );

    // Open the savings accounts the member's category defaults to (e.g. a mandatory shares account).
    if (app.member_category_id) {
      const defaultAccounts = await getMemberCategoryDefaultAccounts(app.member_category_id);
      for (const d of defaultAccounts) {
        await openAccount({ memberId: member.id, productId: d.savings_product_id, user, enforceMinOpening: false });
      }
    }

    // Raw rows — not the re-signed ones listApplicationAttachments() returns for display,
    // since a signed (expiring) url must never be the one persisted to storage.
    const [nextOfKin, nominees, signatories, attachments] = await Promise.all([
      listApplicationNextOfKin(no), listApplicationNominees(no), listApplicationSignatories(no),
      all<MemberApplicationAttachment>('SELECT * FROM member_application_attachment WHERE application_no = ?', no),
    ]);
    for (const n of nextOfKin) {
      await run(
        'INSERT INTO member_next_of_kin (member_id, name, relationship, phone) VALUES (?,?,?,?)',
        member.id, n.name, n.relationship, n.phone,
      );
    }
    for (const n of nominees) {
      await run(
        `INSERT INTO member_nominee (member_id, name, relationship, phone, percentage, is_next_of_kin)
         VALUES (?,?,?,?,?,?)`,
        member.id, n.name, n.relationship, n.phone, n.percentage, n.is_next_of_kin,
      );
    }
    for (const s of signatories) {
      await run(
        `INSERT INTO member_signatory (member_id, identification_no, name, designation, date_of_birth, email, phone)
         VALUES (?,?,?,?,?,?,?)`,
        member.id, s.identification_no, s.name, s.designation, s.date_of_birth, s.email, s.phone,
      );
    }
    for (const a of attachments) {
      await run(
        `INSERT INTO attachment (entity, entity_id, public_id, url, filename, resource_type,
           format, bytes, category, uploaded_at, uploaded_by)
         VALUES ('member',?,?,?,?,?,?,?,?,?,?)`,
        member.id, a.public_id, a.url, a.filename, a.resource_type, a.format, a.bytes, a.category,
        a.uploaded_at, a.uploaded_by,
      );
    }

    const changes = diffFields(
      app as unknown as Record<string, unknown>, { member_id: member.id, status: 'Processed' },
    );
    await logTableChange('member_application', no, 'Modification', changes, user);
    return { memberId: member.id };
  });
}
