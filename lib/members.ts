import { one, all, run, nextSequence, audit } from './db.ts';
import { AppError } from './errors.ts';
import { loanableDeposits, existingExposure } from './loanService.ts';
import { listNextOfKin, listNominees } from './nominees.ts';
import type {
  Actor, GuarantorshipRow, LoanWithProductName, Member, MemberDetail, MemberListRow,
  MemberWithDimensions, SavingsAccountWithProduct, Txn,
} from './types.ts';

const MEMBER_FIELDS = [
  'member_type', 'member_category_id', 'title', 'first_name', 'middle_name', 'last_name', 'national_id', 'kra_pin',
  'date_of_birth', 'gender', 'marital_status', 'phone', 'email', 'postal_address', 'physical_address',
  'county_id', 'sub_county_id', 'employer', 'employment_status', 'staff_no', 'gross_income', 'other_deductions',
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

export interface ListMembersOptions {
  search?: string;
  status?: string;
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
  { search = '', status = '', limit = 200, offset = 0 }: ListMembersOptions = {},
): Promise<{ rows: MemberListRow[]; total: number }> {
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
            OR m.national_id LIKE @like OR m.phone LIKE @like)
       ${status ? 'AND m.status = @status' : ''}
     ORDER BY m.member_no LIMIT @limit OFFSET @offset`,
    { like: `%${String(search).trim()}%`, status, limit: Math.min(limit, 500), offset },
  );
  return { rows, total: rows.length ? rows[0].total_count : 0 };
}

/** Members eligible to be picked in a loan application. */
export const listActiveMembers = () =>
  all<Pick<Member, 'id' | 'member_no' | 'first_name' | 'last_name'>>(
    "SELECT id, member_no, first_name, last_name FROM member WHERE status = 'ACTIVE' ORDER BY member_no",
  );

export const getMember = (id: number): Promise<MemberWithDimensions | undefined> =>
  one<MemberWithDimensions>(
    `SELECT m.*, c.name AS county_name, sc.name AS sub_county_name,
            mc.description AS member_category_name, mc.category_type AS member_category_type,
            gd1.code AS global_dimension_1_code, gd1.name AS global_dimension_1_name,
            gd2.code AS global_dimension_2_code, gd2.name AS global_dimension_2_name
     FROM member m
     LEFT JOIN county c ON c.id = m.county_id
     LEFT JOIN sub_county sc ON sc.id = m.sub_county_id
     LEFT JOIN member_category mc ON mc.id = m.member_category_id
     LEFT JOIN global_dimension_1_value gd1 ON gd1.id = m.global_dimension_1_id
     LEFT JOIN global_dimension_2_value gd2 ON gd2.id = m.global_dimension_2_id
     WHERE m.id = ?`,
    id,
  );

/** Member 360 — profile, accounts, loans, guarantorships and recent activity. */
export async function getMemberDetail(id: number): Promise<MemberDetail | null> {
  const member = await getMember(id);
  if (!member) return null;

  // Independent reads — one round trip's worth of latency instead of six.
  const [accounts, loans, guaranteeing, transactions, deposits, exposure, nextOfKin, nominees] = await Promise.all([
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
  };
}

export async function createMember(body: MemberInput, user: Actor): Promise<MemberWithDimensions> {
  if (!body.first_name || !body.last_name) {
    throw new AppError('First and last name are required', 'VALIDATION');
  }
  if (body.national_id) {
    const dup = await one<Pick<Member, 'member_no' | 'first_name' | 'last_name'>>(
      'SELECT member_no, first_name, last_name FROM member WHERE national_id = ?', body.national_id,
    );
    if (dup) {
      throw new AppError(
        `National ID already registered to ${dup.member_no} — ${dup.first_name} ${dup.last_name}`,
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
