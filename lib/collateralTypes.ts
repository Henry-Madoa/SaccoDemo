/*
 * Collateral Types — setup: the catalogue of acceptable collateral types, each with its own
 * loan-to-value multiplier (a percentage, e.g. 70 = 70%) applied to a pledged asset's market
 * value to derive its realisable security value ("Guarantee"). Mirrors lib/admin.ts's loan
 * product CRUD shape.
 */
import { one, all, run, audit } from './db.ts';
import { AppError } from './errors.ts';
import type { Actor, CollateralType, CollateralTypeWithUsage } from './types.ts';

const FIELDS = ['code', 'description', 'category', 'value_multiplier', 'status'] as const satisfies
  readonly (keyof CollateralType)[];

export type CollateralTypeInput = Partial<Record<(typeof FIELDS)[number], string | number | null>>;

export const listCollateralTypes = (): Promise<CollateralTypeWithUsage[]> =>
  all<CollateralTypeWithUsage>(
    `SELECT t.*, COUNT(a.no) AS applications
     FROM collateral_type t LEFT JOIN collateral_application a ON a.collateral_type_id = t.id
     GROUP BY t.id ORDER BY t.category, t.code`,
  );

export const listActiveCollateralTypes = (category?: string): Promise<CollateralType[]> =>
  all<CollateralType>(
    `SELECT * FROM collateral_type WHERE status = 'ACTIVE' ${category ? 'AND category = ?' : ''} ORDER BY code`,
    ...(category ? [category] : []),
  );

export const getCollateralType = (id: number): Promise<CollateralType | undefined> =>
  one<CollateralType>('SELECT * FROM collateral_type WHERE id = ?', id);

/** A type cannot be activated without a sane multiplier — BR-08, extended with the range
 *  check DEF-08 flags as a gap in the source (a multiplier of 7000 would yield 70x cover). */
function validate(body: CollateralTypeInput): void {
  const multiplier = body.value_multiplier;
  if (body.status === 'ACTIVE' && (multiplier === undefined || multiplier === null || Number(multiplier) <= 0)) {
    throw new AppError('An active collateral type must have a value multiplier greater than zero', 'VALIDATION');
  }
  if (multiplier !== undefined && multiplier !== null && (Number(multiplier) <= 0 || Number(multiplier) > 100)) {
    throw new AppError('Value multiplier must be greater than 0 and no more than 100%', 'VALIDATION');
  }
}

export async function createCollateralType(body: CollateralTypeInput, user: Actor): Promise<{ id: number }> {
  if (!body.code || !body.description || !body.category) {
    throw new AppError('Code, description and category are required', 'VALIDATION');
  }
  validate(body);
  const cols = FIELDS.filter((f) => body[f] !== undefined);
  const info = await run(
    `INSERT INTO collateral_type (${cols.join(',')}) VALUES (${cols.map(() => '?').join(',')})`,
    ...cols.map((c) => body[c]!),
  );
  await audit(user, 'COLLATERAL_TYPE_CREATE', 'collateral_type', info.lastInsertRowid, { code: body.code });
  return { id: Number(info.lastInsertRowid) };
}

export async function updateCollateralType(
  id: number, body: CollateralTypeInput, user: Actor,
): Promise<CollateralType> {
  const existing = await getCollateralType(id);
  if (!existing) throw new AppError('Collateral type not found', 'NOT_FOUND');
  validate({ ...existing, ...body });
  const cols = FIELDS.filter((f) => body[f] !== undefined && f !== 'code');
  if (cols.length) {
    await run(
      `UPDATE collateral_type SET ${cols.map((c) => `${c}=?`).join(',')} WHERE id=?`,
      ...cols.map((c) => body[c]!), id,
    );
  }
  await audit(user, 'COLLATERAL_TYPE_UPDATE', 'collateral_type', id, { fields: cols });
  return (await getCollateralType(id))!;
}
