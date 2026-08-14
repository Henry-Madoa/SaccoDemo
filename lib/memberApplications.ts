import { one, all, run, tx, nextSequence, audit } from './db.ts';
import { AppError } from './errors.ts';
import { createMember, type MemberInput } from './members.ts';
import { listApplicationNextOfKin, listApplicationNominees } from './applicationNominees.ts';
import { listApplicationSignatories } from './applicationSignatories.ts';
import { findMatchingWorkflow, findPendingRoutedTask, pickConditionFields, startWorkflow } from './workflow.ts';
import { getMemberCategoryDefaultAccounts } from './pool.ts';
import { openAccount } from './savings.ts';
import type {
  Actor, AuditEntry, MemberApplication, MemberApplicationAttachment, MemberApplicationWithDimensions,
} from './types.ts';

const APPLICATION_FIELDS = [
  'member_type', 'member_category_id', 'title', 'first_name', 'middle_name', 'last_name', 'national_id', 'kra_pin',
  'date_of_birth', 'gender', 'marital_status', 'phone', 'email', 'postal_address', 'physical_address',
  'county_id', 'sub_county_id', 'employer', 'employment_status', 'staff_no', 'gross_income', 'other_deductions',
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

export interface ListApplicationsOptions {
  view?: MemberApplicationView;
  search?: string;
}

export const listMemberApplications = (
  { view, search = '' }: ListApplicationsOptions = {},
): Promise<MemberApplicationWithDimensions[]> =>
  all<MemberApplicationWithDimensions>(
    `${SELECT_APPLICATION}
     WHERE (a.first_name LIKE @like OR a.last_name LIKE @like OR a.national_id LIKE @like OR a.no LIKE @like)
       ${view ? `AND ${VIEW_CLAUSE[view]}` : ''}
     ORDER BY a.no DESC`,
    { like: `%${String(search).trim()}%` },
  );

export const getMemberApplication = (no: string): Promise<MemberApplicationWithDimensions | undefined> =>
  one<MemberApplicationWithDimensions>(`${SELECT_APPLICATION} WHERE a.no = ?`, no);

/** Every audit_log entry recorded against this application, newest first. */
export const listApplicationAuditTrail = (no: string): Promise<AuditEntry[]> =>
  all<AuditEntry>(
    "SELECT * FROM audit_log WHERE entity = 'member_application' AND entity_id = ? ORDER BY id DESC", no,
  );

export async function createMemberApplication(
  body: MemberApplicationInput, user: Actor,
): Promise<{ no: string }> {
  if (!body.first_name || !body.last_name) {
    throw new AppError('First and last name are required', 'VALIDATION');
  }
  const no = await nextSequence('MEMBER_APPLICATION');
  const cols = APPLICATION_FIELDS.filter((f) => body[f] !== undefined);
  await run(
    `INSERT INTO member_application (no, created_at, created_by${cols.length ? ',' + cols.join(',') : ''})
     VALUES (?,?,?${cols.map(() => ',?').join('')})`,
    no, new Date().toISOString(), user.username, ...cols.map((c) => body[c]!),
  );
  await audit(user, 'MEMBER_APPLICATION_CREATE', 'member_application', no, {});
  return { no };
}

export async function updateMemberApplication(
  no: string, body: MemberApplicationInput, user: Actor,
): Promise<MemberApplicationWithDimensions> {
  const app = await one<MemberApplication>('SELECT status FROM member_application WHERE no = ?', no);
  if (!app) throw new AppError('Application not found', 'NOT_FOUND');
  if (app.status !== 'Open') throw new AppError('Only an open application can be edited', 'VALIDATION');

  const cols = APPLICATION_FIELDS.filter((f) => body[f] !== undefined);
  if (cols.length) {
    await run(
      `UPDATE member_application SET ${cols.map((c) => `${c}=?`).join(',')} WHERE no=?`,
      ...cols.map((c) => body[c]!), no,
    );
  }
  await audit(user, 'MEMBER_APPLICATION_UPDATE', 'member_application', no, { fields: cols });
  return (await getMemberApplication(no))!;
}

export async function submitMemberApplication(no: string, user: Actor): Promise<void> {
  const app = await one<MemberApplication>('SELECT * FROM member_application WHERE no = ?', no);
  if (!app) throw new AppError('Application not found', 'NOT_FOUND');
  if (app.status !== 'Open') {
    throw new AppError('Only an open application can be submitted for approval', 'VALIDATION');
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
    await audit(user, 'MEMBER_APPLICATION_SUBMIT', 'member_application', no, {});
    await startWorkflow(matched.workflow, matched.steps, {
      documentType: 'MEMBER_APPLICATION', entityId: no, requestedBy: user.username, amount: app.gross_income,
    });
  });
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
  await audit(user, 'MEMBER_APPLICATION_CANCEL_APPROVAL', 'member_application', no, {});
}

export async function approveMemberApplication(no: string, user: Actor): Promise<void> {
  const app = await one<MemberApplication>('SELECT status FROM member_application WHERE no = ?', no);
  if (!app) throw new AppError('Application not found', 'NOT_FOUND');
  if (app.status !== 'Pending Approval') {
    throw new AppError('Only an application pending approval can be approved', 'VALIDATION');
  }
  await run("UPDATE member_application SET status = 'Approved', decision_reason = NULL WHERE no = ?", no);
  await audit(user, 'MEMBER_APPLICATION_APPROVE', 'member_application', no, {});
}

export async function rejectMemberApplication(no: string, reason: string | null, user: Actor): Promise<void> {
  const app = await one<MemberApplication>('SELECT status FROM member_application WHERE no = ?', no);
  if (!app) throw new AppError('Application not found', 'NOT_FOUND');
  if (app.status !== 'Pending Approval') {
    throw new AppError('Only an application pending approval can be rejected', 'VALIDATION');
  }
  await run("UPDATE member_application SET status = 'Rejected', decision_reason = ? WHERE no = ?", reason || null, no);
  await audit(user, 'MEMBER_APPLICATION_REJECT', 'member_application', no, { reason });
}

/** Approved -> a real member.createMember() call, linked back onto the application as "Committed". */
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
      national_id: app.national_id, kra_pin: app.kra_pin, date_of_birth: app.date_of_birth,
      gender: app.gender, marital_status: app.marital_status, phone: app.phone, email: app.email,
      postal_address: app.postal_address, physical_address: app.physical_address,
      county_id: app.county_id, sub_county_id: app.sub_county_id, employer: app.employer,
      employment_status: app.employment_status, staff_no: app.staff_no, gross_income: app.gross_income,
      other_deductions: app.other_deductions, status: 'NOT PAID UP',
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
    await run("UPDATE member_application SET member_id = ?, status = 'Committed' WHERE no = ?", member.id, no);

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

    await audit(user, 'MEMBER_APPLICATION_PROCESS', 'member_application', no, { memberId: member.id });
    return { memberId: member.id };
  });
}
