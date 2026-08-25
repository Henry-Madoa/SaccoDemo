/*
 * Checkoff and Salary Processing — the employer master. Ported from the AL reference's
 * "Employers" table (Tab52204126), narrowed to what actually routes a checkoff/salary batch:
 * name/contact, whether a payroll number is mandatory for its members, and status. AL's own
 * per-employer member-status flowfields, blocked flag and Customer-account settlement fields
 * belong to the wider 59-file module this port scopes down — see lib/checkoffBatches.ts's own
 * header comment for the full list of what's excluded and why.
 */
import { one, all, run, audit } from './db.ts';
import { AppError } from './errors.ts';
import type { Actor, Cents, Employer, EmployerStats, EmployerWithCounts } from './types.ts';

const FIELDS = ['code', 'name', 'phone', 'email', 'payroll_no_mandatory', 'status'] as const satisfies
  readonly (keyof Employer)[];

export type EmployerInput = Partial<Record<(typeof FIELDS)[number], string | number | boolean | null>>;

export const listEmployers = (): Promise<EmployerWithCounts[]> =>
  all<EmployerWithCounts>(
    `SELECT e.*, COUNT(m.id) AS member_count
     FROM employer e LEFT JOIN member m ON m.employer_id = e.id
     GROUP BY e.id ORDER BY e.name`,
  );

export const listActiveEmployers = (): Promise<Employer[]> =>
  all<Employer>("SELECT * FROM employer WHERE status = 'ACTIVE' ORDER BY name");

export const getEmployer = (id: number): Promise<Employer | undefined> =>
  one<Employer>('SELECT * FROM employer WHERE id = ?', id);

export async function createEmployer(body: EmployerInput, user: Actor): Promise<{ id: number }> {
  if (!body.code || !body.name) throw new AppError('Code and name are required', 'VALIDATION');
  if (await one('SELECT 1 FROM employer WHERE code = ?', body.code)) {
    throw new AppError('Employer code already exists', 'DUPLICATE');
  }
  const cols = FIELDS.filter((f) => body[f] !== undefined);
  const info = await run(
    `INSERT INTO employer (${cols.join(',')}) VALUES (${cols.map(() => '?').join(',')})`,
    ...cols.map((c) => body[c]!),
  );
  await audit(user, 'EMPLOYER_CREATE', 'employer', info.lastInsertRowid, { code: body.code });
  return { id: Number(info.lastInsertRowid) };
}

export async function updateEmployer(id: number, body: EmployerInput, user: Actor): Promise<Employer> {
  const existing = await getEmployer(id);
  if (!existing) throw new AppError('Employer not found', 'NOT_FOUND');
  const cols = FIELDS.filter((f) => body[f] !== undefined && f !== 'code');
  if (cols.length) {
    await run(
      `UPDATE employer SET ${cols.map((c) => `${c}=?`).join(',')} WHERE id=?`,
      ...cols.map((c) => body[c]!), id,
    );
  }
  await audit(user, 'EMPLOYER_UPDATE', 'employer', id, { fields: cols });
  return (await getEmployer(id))!;
}

/**
 * Aggregate financial/member-position stats for the Employer View card: how many of this
 * employer's members are Active/Withdrawn/etc, what they collectively hold in savings & shares
 * (assets) versus owe on disbursed loans (liabilities), their Fixed Deposit holdings, and how
 * much Checkoff & Salary Processing has moved for this employer to date.
 */
export async function getEmployerStats(employerId: number): Promise<EmployerStats> {
  const [statusBreakdown, deposits, fd, loans, checkoff] = await Promise.all([
    all<{ status: string; count: number }>(
      'SELECT status, COUNT(*) AS count FROM member WHERE employer_id = ? GROUP BY status', employerId,
    ),
    one<{ total_deposits: number; total_shares: number }>(
      `SELECT
         COALESCE(SUM(CASE WHEN p.category <> 'SHARE CAPITAL ACCOUNT' THEN sa.balance ELSE 0 END), 0) AS total_deposits,
         COALESCE(SUM(CASE WHEN p.category = 'SHARE CAPITAL ACCOUNT' THEN sa.balance ELSE 0 END), 0) AS total_shares
       FROM savings_account sa
       JOIN member m ON m.id = sa.member_id
       JOIN savings_product p ON p.id = sa.product_id
       WHERE m.employer_id = ? AND sa.status = 'ACTIVE' AND p.category <> 'FIXED DEPOSIT ACCOUNT'`,
      employerId,
    ),
    one<{ total: number }>(
      `SELECT COALESCE(SUM(d.amount), 0) AS total
       FROM member_fixed_deposit d JOIN member m ON m.id = d.member_id
       WHERE m.employer_id = ? AND d.status = 'Active'`,
      employerId,
    ),
    one<{ count: number; balance: number }>(
      `SELECT COUNT(*) AS count, COALESCE(SUM(l.principal_balance + l.interest_balance + l.penalty_balance), 0) AS balance
       FROM loan l JOIN member m ON m.id = l.member_id
       WHERE m.employer_id = ? AND l.status = 'DISBURSED'`,
      employerId,
    ),
    one<{ count: number; total: number }>(
      `SELECT COUNT(DISTINCT b.no) AS count, COALESCE(SUM(l.remitted_amount), 0) AS total
       FROM checkoff_batch b JOIN checkoff_batch_line l ON l.batch_no = b.no
       WHERE b.employer_id = ? AND b.status = 'Processed'`,
      employerId,
    ),
  ]);

  const activeCount = statusBreakdown.find((s) => s.status === 'ACTIVE')?.count ?? 0;
  const withdrawnCount = statusBreakdown.find((s) => s.status === 'WITHDRAWN')?.count ?? 0;

  return {
    member_count: statusBreakdown.reduce((sum, s) => sum + s.count, 0),
    active_member_count: activeCount,
    withdrawn_member_count: withdrawnCount,
    member_status_breakdown: statusBreakdown,
    total_deposits: deposits?.total_deposits ?? 0,
    total_shares: deposits?.total_shares ?? 0,
    total_fixed_deposits: fd?.total ?? 0,
    disbursed_loan_count: loans?.count ?? 0,
    outstanding_loan_balance: loans?.balance ?? 0,
    checkoff_batch_count: checkoff?.count ?? 0,
    total_remitted: checkoff?.total ?? 0,
  };
}

export interface EmployerMemberRow {
  id: number;
  member_no: string;
  first_name: string;
  last_name: string;
  status: string;
  deposits: Cents;
  outstanding_loans: Cents;
}

/** The members linked to this employer, with a per-member deposits/loans snapshot — the
 *  Employer View card's drill-down list. */
export const listEmployerMembers = (employerId: number): Promise<EmployerMemberRow[]> => all<EmployerMemberRow>(
  `SELECT m.id, m.member_no, m.first_name, m.last_name, m.status,
          COALESCE(sa.deposits, 0) AS deposits, COALESCE(ln.outstanding, 0) AS outstanding_loans
   FROM member m
   LEFT JOIN (
     SELECT sa.member_id, SUM(sa.balance) AS deposits
     FROM savings_account sa JOIN savings_product p ON p.id = sa.product_id
     WHERE sa.status = 'ACTIVE' AND p.category <> 'FIXED DEPOSIT ACCOUNT'
     GROUP BY sa.member_id
   ) sa ON sa.member_id = m.id
   LEFT JOIN (
     SELECT member_id, SUM(principal_balance + interest_balance + penalty_balance) AS outstanding
     FROM loan WHERE status = 'DISBURSED'
     GROUP BY member_id
   ) ln ON ln.member_id = m.id
   WHERE m.employer_id = ?
   ORDER BY m.member_no`,
  employerId,
);

/** Direct, ungated assignment of which Employer a member is linked to — payroll-routing metadata
 *  for checkoff/salary batches, not the kind of KYC fact the Member Edit maker-checker flow
 *  (lib/memberEdits.ts) exists to protect, so it bypasses that workflow entirely. Pass `null` to
 *  unlink. */
export async function setMemberEmployer(memberId: number, employerId: number | null, user: Actor): Promise<void> {
  const member = await one<{ id: number }>('SELECT id FROM member WHERE id = ?', memberId);
  if (!member) throw new AppError('Member not found', 'NOT_FOUND');
  if (employerId != null && !(await one('SELECT 1 FROM employer WHERE id = ?', employerId))) {
    throw new AppError('Employer not found', 'NOT_FOUND');
  }
  await run('UPDATE member SET employer_id = ? WHERE id = ?', employerId, memberId);
  await audit(user, 'MEMBER_SET_EMPLOYER', 'member', memberId, { employerId });
}
