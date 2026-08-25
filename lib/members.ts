import {
  one, all, run, nextSequence, audit, hasAnyRow,
} from './db.ts';
import { AppError } from './errors.ts';
import { loanableDeposits, existingExposure } from './loanService.ts';
import { listNextOfKin, listNominees } from './nominees.ts';
import { listSignatories } from './signatories.ts';
import { buildFilterClause, type FilterCondition, type FilterFieldDef } from './listFilters.ts';
import { buildOrderClause, type SortState } from './listSort.ts';
import {
  MEMBER_STATUSES, MEMBER_TYPES, MEMBER_TITLES, GENDERS, MARITAL_STATUSES, EMPLOYMENT_STATUSES,
} from './constants.ts';
import type {
  Actor, GuarantorshipRow, LoanWithProductName, Member, MemberDetail, MemberListRow,
  MemberStatus, MemberWithDimensions, SavingsAccountWithProduct, Txn,
} from './types.ts';

export const MEMBER_FIELDS = [
  'member_type', 'member_category_id', 'title', 'first_name', 'middle_name', 'last_name', 'identification_no', 'kra_pin',
  'date_of_birth', 'gender', 'marital_status', 'phone', 'email', 'postal_address', 'physical_address',
  'county_id', 'sub_county_id', 'employer', 'employment_status', 'staff_no',
  'status', 'kyc_verified', 'join_date',
  'notes', 'photo', 'front_id_image', 'back_id_image', 'signature_image',
  'fingerprint1_image', 'fingerprint2_image',
  'group_name', 'registration_no', 'registration_date',
  'contact_person_name', 'contact_person_phone', 'contact_person_email', 'member_count',
  'global_dimension_1_id', 'global_dimension_2_id',
] as const satisfies readonly (keyof Member)[];

export type MemberField = (typeof MEMBER_FIELDS)[number];
export type MemberInput = Partial<Record<MemberField, string | number | null>>;

export { MEMBER_STATUSES } from './constants.ts';

/** Members list's dynamic-filter registry — every column meaningful to filter on (image/binary
 *  fields like photo/signature/fingerprint images are excluded, since there's nothing to filter).
 *  DB-driven fields (member_category_id, county_id, sub_county_id, both dimensions) ship without
 *  `options` here; the page fills them in from lookups it already fetches. */
export const MEMBER_FILTER_FIELDS: FilterFieldDef[] = [
  { key: 'member_no', label: 'Member No.', type: 'text', column: 'm.member_no' },
  { key: 'member_type', label: 'Member Type', type: 'select', column: 'm.member_type', options: MEMBER_TYPES.map((t) => ({ value: t, label: t })) },
  { key: 'member_category_id', label: 'Member Category', type: 'select', column: 'm.member_category_id' },
  { key: 'title', label: 'Title', type: 'select', column: 'm.title', options: MEMBER_TITLES.filter(Boolean).map((t) => ({ value: t, label: t })) },
  { key: 'first_name', label: 'First Name', type: 'text', column: 'm.first_name' },
  { key: 'middle_name', label: 'Middle Name', type: 'text', column: 'm.middle_name' },
  { key: 'last_name', label: 'Last Name', type: 'text', column: 'm.last_name' },
  { key: 'identification_no', label: 'Identification No.', type: 'text', column: 'm.identification_no' },
  { key: 'kra_pin', label: 'KRA PIN', type: 'text', column: 'm.kra_pin' },
  { key: 'date_of_birth', label: 'Date of Birth', type: 'date', column: 'm.date_of_birth' },
  { key: 'gender', label: 'Gender', type: 'select', column: 'm.gender', options: GENDERS.filter(Boolean).map((g) => ({ value: g, label: g })) },
  { key: 'marital_status', label: 'Marital Status', type: 'select', column: 'm.marital_status', options: MARITAL_STATUSES.filter(Boolean).map((s) => ({ value: s, label: s })) },
  { key: 'phone', label: 'Phone', type: 'text', column: 'm.phone' },
  { key: 'email', label: 'Email', type: 'text', column: 'm.email' },
  { key: 'postal_address', label: 'Postal Address', type: 'text', column: 'm.postal_address' },
  { key: 'physical_address', label: 'Physical Address', type: 'text', column: 'm.physical_address' },
  { key: 'county_id', label: 'County', type: 'select', column: 'm.county_id' },
  { key: 'sub_county_id', label: 'Sub-county', type: 'select', column: 'm.sub_county_id' },
  { key: 'employer', label: 'Employer', type: 'text', column: 'm.employer' },
  { key: 'employment_status', label: 'Employment Status', type: 'select', column: 'm.employment_status', options: EMPLOYMENT_STATUSES.filter(Boolean).map((s) => ({ value: s, label: s })) },
  { key: 'staff_no', label: 'Staff No.', type: 'text', column: 'm.staff_no' },
  { key: 'status', label: 'Status', type: 'select', column: 'm.status', options: MEMBER_STATUSES.map((s) => ({ value: s, label: s })) },
  { key: 'kyc_verified', label: 'KYC Verified', type: 'select', column: 'm.kyc_verified', options: [{ value: 1, label: 'Yes' }, { value: 0, label: 'No' }] },
  { key: 'join_date', label: 'Join Date', type: 'date', column: 'm.join_date' },
  { key: 'notes', label: 'Notes', type: 'text', column: 'm.notes' },
  { key: 'group_name', label: 'Group / Entity Name', type: 'text', column: 'm.group_name' },
  { key: 'registration_no', label: 'Registration No.', type: 'text', column: 'm.registration_no' },
  { key: 'registration_date', label: 'Registration Date', type: 'date', column: 'm.registration_date' },
  { key: 'contact_person_name', label: 'Contact Person', type: 'text', column: 'm.contact_person_name' },
  { key: 'contact_person_phone', label: 'Contact Phone', type: 'text', column: 'm.contact_person_phone' },
  { key: 'contact_person_email', label: 'Contact Email', type: 'text', column: 'm.contact_person_email' },
  { key: 'member_count', label: 'Number of Members', type: 'number', column: 'm.member_count' },
  { key: 'global_dimension_1_id', label: 'Global Dimension 1', type: 'select', column: 'm.global_dimension_1_id' },
  { key: 'global_dimension_2_id', label: 'Global Dimension 2', type: 'select', column: 'm.global_dimension_2_id' },
  { key: 'created_at', label: 'Created', type: 'date', column: 'm.created_at', datetime: true },
  { key: 'created_by', label: 'Created By', type: 'text', column: 'm.created_by' },
];

/** Members list's sortable columns — every column shown in the table. */
const MEMBER_SORT_COLUMNS: Record<string, string> = {
  member_no: 'm.member_no',
  name: 'm.first_name',
  identification_no: 'm.identification_no',
  phone: 'm.phone',
  gd1: 'gd1.name',
  gd2: 'gd2.name',
  total_savings: 'total_savings',
  loan_balance: 'loan_balance',
  created_at: 'm.created_at',
  status: 'm.status',
};

export interface ListMembersOptions {
  search?: string;
  filters?: FilterCondition[];
  sort?: SortState | null;
  limit?: number;
  offset?: number;
}

/**
 * Paged member registry with rolled-up savings and loan balances.
 *
 * The old endpoint ran the same predicate twice — once for the page, once for
 * COUNT(*). A window function returns both in a single scan.
 */
export async function listMembers(
  { search = '', filters = [], sort = null, limit = 200, offset = 0 }: ListMembersOptions = {},
): Promise<{ rows: MemberListRow[]; total: number }> {
  const { clause, params } = buildFilterClause(MEMBER_FILTER_FIELDS, filters);
  const orderBy = buildOrderClause(MEMBER_SORT_COLUMNS, sort, 'm.member_no');
  const rows = await all<MemberListRow>(
    `SELECT m.*, c.name AS county_name, sc.name AS sub_county_name,
            mc.description AS member_category_name,
            gd1.code AS global_dimension_1_code, gd1.name AS global_dimension_1_name,
            gd2.code AS global_dimension_2_code, gd2.name AS global_dimension_2_name,
            (SELECT COALESCE(SUM(sa.balance),0) FROM savings_account sa WHERE sa.member_id = m.id) AS total_savings,
            (SELECT COALESCE(SUM(l.principal_balance + l.interest_balance),0) FROM loan l
              WHERE l.member_id = m.id AND l.status='DISBURSED') AS loan_balance,
            COUNT(*) OVER () AS total_count
     FROM member m
     LEFT JOIN county c ON c.id = m.county_id
     LEFT JOIN sub_county sc ON sc.id = m.sub_county_id
     LEFT JOIN member_category mc ON mc.id = m.member_category_id
     LEFT JOIN global_dimension_1_value gd1 ON gd1.id = m.global_dimension_1_id
     LEFT JOIN global_dimension_2_value gd2 ON gd2.id = m.global_dimension_2_id
     WHERE (m.member_no LIKE @like OR m.first_name LIKE @like OR m.last_name LIKE @like
            OR m.identification_no LIKE @like OR m.phone LIKE @like)
       ${clause}
     ${orderBy} LIMIT @limit OFFSET @offset`,
    { like: `%${String(search).trim()}%`, limit: Math.min(limit, 500), offset, ...params },
  );
  return { rows, total: rows.length ? rows[0].total_count : 0 };
}

/** Whether the current Status tab has any members at all, ignoring search and dynamic
 *  filters — lets the page grey out its filter controls only when there's truly nothing to
 *  filter, as opposed to a search/filter simply matching zero of an otherwise non-empty tab. */
export const hasAnyMembers = (status: MemberStatus | null = null): Promise<boolean> =>
  hasAnyRow('member m', status ? 'm.status = ?' : undefined, ...(status ? [status] : []));

/** Members eligible to be picked in a loan application. */
export const listActiveMembers = () =>
  all<Pick<Member, 'id' | 'member_no' | 'first_name' | 'last_name'>>(
    "SELECT id, member_no, first_name, last_name FROM member WHERE status = 'ACTIVE' ORDER BY member_no",
  );

/** A member's identity by their Identification No. — the Next of Kin / Nominee forms' "this
 *  person is already a member" lookup: entering an ID that matches a live member auto-fills
 *  their name and phone rather than asking the officer to retype what's already on file. */
export const findMemberByIdentificationNo = (
  identificationNo: string,
): Promise<Pick<Member, 'id' | 'member_no' | 'first_name' | 'last_name' | 'phone'> | undefined> =>
  one<Pick<Member, 'id' | 'member_no' | 'first_name' | 'last_name' | 'phone'>>(
    'SELECT id, member_no, first_name, last_name, phone FROM member WHERE identification_no = ?',
    identificationNo,
  );

export const getMember = (id: number): Promise<MemberWithDimensions | undefined> =>
  one<MemberWithDimensions>(
    `SELECT m.*, c.name AS county_name, sc.name AS sub_county_name,
            mc.description AS member_category_name, mc.category_type AS member_category_type,
            gd1.code AS global_dimension_1_code, gd1.name AS global_dimension_1_name,
            gd2.code AS global_dimension_2_code, gd2.name AS global_dimension_2_name,
            emp.name AS employer_ref_name
     FROM member m
     LEFT JOIN county c ON c.id = m.county_id
     LEFT JOIN sub_county sc ON sc.id = m.sub_county_id
     LEFT JOIN member_category mc ON mc.id = m.member_category_id
     LEFT JOIN global_dimension_1_value gd1 ON gd1.id = m.global_dimension_1_id
     LEFT JOIN global_dimension_2_value gd2 ON gd2.id = m.global_dimension_2_id
     LEFT JOIN employer emp ON emp.id = m.employer_id
     WHERE m.id = ?`,
    id,
  );

/** The member immediately before/after this one by member_no — the same order the Members
 *  list defaults to — for the card's Business-Central-style Previous/Next navigation. Either
 *  side is null at the start/end of the list. Scoped to `status` (the Members list's Status
 *  tab) when given, so paging never steps outside the tab the record was opened from. */
export async function getAdjacentMemberIds(
  id: number, status?: MemberStatus,
): Promise<{ prevId: number | null; nextId: number | null }> {
  const current = await one<{ member_no: string }>('SELECT member_no FROM member WHERE id = ?', id);
  if (!current) return { prevId: null, nextId: null };
  const clause = status ? 'AND status = ?' : '';
  const prevArgs = status ? [current.member_no, status] : [current.member_no];
  const nextArgs = status ? [current.member_no, status] : [current.member_no];
  const [prev, next] = await Promise.all([
    one<{ id: number }>(`SELECT id FROM member WHERE member_no < ? ${clause} ORDER BY member_no DESC LIMIT 1`, ...prevArgs),
    one<{ id: number }>(`SELECT id FROM member WHERE member_no > ? ${clause} ORDER BY member_no ASC LIMIT 1`, ...nextArgs),
  ]);
  return { prevId: prev?.id ?? null, nextId: next?.id ?? null };
}

/** Member 360 — profile, accounts, loans, guarantorships and recent activity. */
export async function getMemberDetail(id: number): Promise<MemberDetail | null> {
  const member = await getMember(id);
  if (!member) return null;

  // Independent reads — one round trip's worth of latency instead of six.
  const [
    accounts, loans, guaranteeing, transactions, deposits, exposure, nextOfKin, nominees, signatories,
  ] = await Promise.all([
    all<SavingsAccountWithProduct>(
      `SELECT sa.*, p.name AS product_name, p.code AS product_code, p.category, p.min_balance, p.allow_withdrawal
       FROM savings_account sa JOIN savings_product p ON p.id = sa.product_id
       WHERE sa.member_id = ? ORDER BY p.id`,
      id,
    ),
    all<LoanWithProductName>(
      `SELECT l.*, p.name AS product_name FROM loan l JOIN loan_product p ON p.id = l.product_id
       WHERE l.member_id = ? ORDER BY l.id DESC`,
      id,
    ),
    all<GuarantorshipRow>(
      `SELECT g.*, l.loan_no, l.status AS loan_status, l.principal_balance,
              m.member_no, m.first_name, m.last_name
       FROM loan_guarantor g JOIN loan l ON l.id = g.loan_id JOIN member m ON m.id = l.member_id
       WHERE g.member_id = ?`,
      id,
    ),
    all<Txn>('SELECT * FROM txn WHERE member_id = ? ORDER BY id DESC LIMIT 40', id),
    loanableDeposits(id),
    existingExposure(id),
    listNextOfKin(id),
    listNominees(id),
    listSignatories(id),
  ]);

  return {
    member,
    accounts,
    loans,
    guaranteeing,
    transactions,
    appraisal: { deposits, exposure },
    nextOfKin,
    nominees,
    signatories,
  };
}

export async function createMember(body: MemberInput, user: Actor): Promise<MemberWithDimensions> {
  if (!body.first_name || !body.last_name) {
    throw new AppError('First and last name are required', 'VALIDATION');
  }
  if (body.identification_no) {
    const dup = await one<Pick<Member, 'member_no' | 'first_name' | 'last_name'>>(
      'SELECT member_no, first_name, last_name FROM member WHERE identification_no = ?', body.identification_no,
    );
    if (dup) {
      throw new AppError(
        `Identification No. already registered to ${dup.member_no} — ${dup.first_name} ${dup.last_name}`,
        'DUPLICATE_MEMBER',
      );
    }
  }
  const memberNo = await nextSequence('MEMBER');
  const cols = MEMBER_FIELDS.filter((f) => body[f] !== undefined);
  const info = await run(
    `INSERT INTO member (member_no, created_at, created_by${cols.length ? ',' + cols.join(',') : ''})
     VALUES (?,?,?${cols.map(() => ',?').join('')})`,
    memberNo, new Date().toISOString(), user.username, ...cols.map((c) => body[c]!),
  );

  await audit(user, 'MEMBER_CREATE', 'member', info.lastInsertRowid, { memberNo });
  return (await getMember(Number(info.lastInsertRowid)))!;
}

export async function updateMember(id: number, body: MemberInput, user: Actor): Promise<MemberWithDimensions> {
  const cols = MEMBER_FIELDS.filter((f) => body[f] !== undefined);
  if (cols.length) {
    await run(
      `UPDATE member SET ${cols.map((c) => `${c}=?`).join(',')} WHERE id=?`,
      ...cols.map((c) => body[c]!), id,
    );
  }
  await audit(user, 'MEMBER_UPDATE', 'member', id, { fields: cols });
  return (await getMember(id))!;
}
