/*
 * Fixed Deposit Types — setup: the catalogue of term-deposit products, each with its own interest
 * rate bounds, calc method (Flat vs Reducing Balance — see lib/fixedDeposits.ts's schedule
 * generation), the savings_product new FD accounts open under, and the GL accounts interest
 * accrual/withholding tax post to. Mirrors lib/collateralTypes.ts's shape.
 */
import { one, all, run, audit } from './db.ts';
import { AppError } from './errors.ts';
import type { Actor, MemberFixedDepositType, MemberFixedDepositTypeWithUsage } from './types.ts';

const FIELDS = [
  'code', 'description', 'min_interest_rate', 'max_interest_rate', 'interest_calc_type',
  'linked_product_id', 'interest_expense_gl_id', 'interest_payable_gl_id',
  'withholding_tax_rate', 'withholding_tax_gl_id', 'status',
] as const satisfies readonly (keyof MemberFixedDepositType)[];

export type MemberFixedDepositTypeInput = Partial<Record<(typeof FIELDS)[number], string | number | null>>;

export const listFixedDepositTypes = (): Promise<MemberFixedDepositTypeWithUsage[]> =>
  all<MemberFixedDepositTypeWithUsage>(
    `SELECT t.*, p.name AS linked_product_name, COUNT(d.no) AS fixed_deposits
     FROM member_fixed_deposit_type t
     JOIN savings_product p ON p.id = t.linked_product_id
     LEFT JOIN member_fixed_deposit d ON d.fd_type_id = t.id
     GROUP BY t.id, p.name ORDER BY t.code`,
  );

export const listActiveFixedDepositTypes = (): Promise<MemberFixedDepositType[]> =>
  all<MemberFixedDepositType>("SELECT * FROM member_fixed_deposit_type WHERE status = 'ACTIVE' ORDER BY code");

export const getFixedDepositType = (id: number): Promise<MemberFixedDepositType | undefined> =>
  one<MemberFixedDepositType>('SELECT * FROM member_fixed_deposit_type WHERE id = ?', id);

function validate(body: MemberFixedDepositTypeInput): void {
  const min = body.min_interest_rate;
  const max = body.max_interest_rate;
  if (min !== undefined && min !== null && max !== undefined && max !== null && Number(min) > Number(max)) {
    throw new AppError('Minimum interest rate cannot exceed the maximum', 'VALIDATION');
  }
  const wht = body.withholding_tax_rate;
  if (wht !== undefined && wht !== null && Number(wht) > 0 && !body.withholding_tax_gl_id) {
    throw new AppError('A withholding tax GL account is required when the withholding tax rate is above zero', 'VALIDATION');
  }
}

export async function createFixedDepositType(body: MemberFixedDepositTypeInput, user: Actor): Promise<{ id: number }> {
  if (!body.code || !body.description || !body.linked_product_id || !body.interest_expense_gl_id || !body.interest_payable_gl_id) {
    throw new AppError('Code, description, linked product and both interest GL accounts are required', 'VALIDATION');
  }
  validate(body);
  const cols = FIELDS.filter((f) => body[f] !== undefined);
  const info = await run(
    `INSERT INTO member_fixed_deposit_type (${cols.join(',')}) VALUES (${cols.map(() => '?').join(',')})`,
    ...cols.map((c) => body[c]!),
  );
  await audit(user, 'FIXED_DEPOSIT_TYPE_CREATE', 'member_fixed_deposit_type', info.lastInsertRowid, { code: body.code });
  return { id: Number(info.lastInsertRowid) };
}

export async function updateFixedDepositType(
  id: number, body: MemberFixedDepositTypeInput, user: Actor,
): Promise<MemberFixedDepositType> {
  const existing = await getFixedDepositType(id);
  if (!existing) throw new AppError('Fixed deposit type not found', 'NOT_FOUND');
  validate({ ...existing, ...body });
  const cols = FIELDS.filter((f) => body[f] !== undefined && f !== 'code');
  if (cols.length) {
    await run(
      `UPDATE member_fixed_deposit_type SET ${cols.map((c) => `${c}=?`).join(',')} WHERE id=?`,
      ...cols.map((c) => body[c]!), id,
    );
  }
  await audit(user, 'FIXED_DEPOSIT_TYPE_UPDATE', 'member_fixed_deposit_type', id, { fields: cols });
  return (await getFixedDepositType(id))!;
}
