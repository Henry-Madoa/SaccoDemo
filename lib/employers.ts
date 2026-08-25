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
import type { Actor, Employer, EmployerWithCounts } from './types.ts';

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
