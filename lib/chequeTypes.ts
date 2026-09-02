/*
 * Cheque Types master — AL Tab52204122 "Cheque Types". Two kinds are ported:
 *   - BANKERS  — a banker's cheque the SACCO sells (lib/bankersCheques.ts)
 *   - EXTERNAL — a third-party cheque a member banks (lib/chequeDeposits.ts), with clearing /
 *                bouncing / express charges and a maturity period.
 */
import { one, all, run, audit } from './db.ts';
import { AppError } from './errors.ts';
import type { Actor, Cents, ChequeType, ChequeTypeKind, ChequeTypeWithDetail } from './types.ts';

const SELECT_DETAIL = `
  SELECT ct.*,
         g.code AS clearing_gl_account_code, g.name AS clearing_gl_account_name,
         cc.code AS clearing_charge_code, bc.code AS bouncing_charge_code, ec.code AS express_charge_code,
         (SELECT COUNT(*) FROM bankers_cheque bk WHERE bk.cheque_type_id = ct.id)
       + (SELECT COUNT(*) FROM cheque_deposit cd WHERE cd.cheque_type_id = ct.id) AS cheques_issued
  FROM cheque_type ct
  JOIN gl_account g ON g.id = ct.clearing_gl_account_id
  LEFT JOIN transaction_charge cc ON cc.id = ct.clearing_charge_id
  LEFT JOIN transaction_charge bc ON bc.id = ct.bouncing_charge_id
  LEFT JOIN transaction_charge ec ON ec.id = ct.express_charge_id`;

export const listChequeTypes = (type?: ChequeTypeKind): Promise<ChequeTypeWithDetail[]> =>
  all<ChequeTypeWithDetail>(
    `${SELECT_DETAIL} ${type ? 'WHERE ct.type = ?' : ''} ORDER BY ct.code`,
    ...(type ? [type] : []),
  );

export const listActiveChequeTypes = (type: ChequeTypeKind): Promise<ChequeType[]> =>
  all<ChequeType>("SELECT * FROM cheque_type WHERE status = 'ACTIVE' AND type = ? ORDER BY code", type);

export const getChequeType = (id: number): Promise<ChequeType | undefined> =>
  one<ChequeType>('SELECT * FROM cheque_type WHERE id = ?', id);

export interface ChequeTypeInput {
  code: string;
  type: ChequeTypeKind;
  description: string;
  maximumAmount: Cents;
  clearingGlAccountId: number;
  clearingChargeId: number | null;
  bouncingChargeId: number | null;
  expressChargeId: number | null;
  inHouse: boolean;
  maturityDays: number;
  status: 'ACTIVE' | 'INACTIVE';
}

function assertInput(input: ChequeTypeInput): void {
  if (!input.code.trim()) throw new AppError('A code is required', 'VALIDATION');
  if (!input.description.trim()) throw new AppError('A description is required', 'VALIDATION');
  if (!['BANKERS', 'EXTERNAL'].includes(input.type)) throw new AppError('Invalid cheque type kind', 'VALIDATION');
  if (!input.clearingGlAccountId) throw new AppError('A clearing G/L account is required', 'VALIDATION');
  if (input.maximumAmount < 0) throw new AppError('The maximum amount cannot be negative', 'VALIDATION');
  if (input.type === 'EXTERNAL' && !input.inHouse && input.maturityDays < 1) {
    throw new AppError('An external cheque type needs a maturity period of at least 1 day', 'VALIDATION');
  }
}

export async function createChequeType(input: ChequeTypeInput, user: Actor): Promise<{ id: number }> {
  assertInput(input);
  const dup = await one<{ id: number }>('SELECT id FROM cheque_type WHERE code = ?', input.code.trim());
  if (dup) throw new AppError('A cheque type with this code already exists', 'DUPLICATE');
  const info = await run(
    `INSERT INTO cheque_type
       (code, type, description, maximum_amount, clearing_gl_account_id, clearing_charge_id, bouncing_charge_id,
        express_charge_id, in_house, maturity_days, status, created_at, created_by)
     VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?)`,
    input.code.trim(), input.type, input.description.trim(), Math.round(input.maximumAmount), input.clearingGlAccountId,
    input.clearingChargeId, input.bouncingChargeId, input.expressChargeId, input.inHouse,
    Math.max(0, Math.round(input.maturityDays)), input.status, new Date().toISOString(), user.username,
  );
  await audit(user, 'CHEQUE_TYPE_CREATE', 'cheque_type', info.lastInsertRowid, { code: input.code, type: input.type });
  return { id: Number(info.lastInsertRowid) };
}

export async function updateChequeType(id: number, input: ChequeTypeInput, user: Actor): Promise<void> {
  assertInput(input);
  const before = await getChequeType(id);
  if (!before) throw new AppError('Cheque type not found', 'NOT_FOUND');
  const dup = await one<{ id: number }>('SELECT id FROM cheque_type WHERE code = ? AND id <> ?', input.code.trim(), id);
  if (dup) throw new AppError('A cheque type with this code already exists', 'DUPLICATE');
  await run(
    `UPDATE cheque_type
     SET code = ?, type = ?, description = ?, maximum_amount = ?, clearing_gl_account_id = ?, clearing_charge_id = ?,
         bouncing_charge_id = ?, express_charge_id = ?, in_house = ?, maturity_days = ?, status = ?
     WHERE id = ?`,
    input.code.trim(), input.type, input.description.trim(), Math.round(input.maximumAmount), input.clearingGlAccountId,
    input.clearingChargeId, input.bouncingChargeId, input.expressChargeId, input.inHouse,
    Math.max(0, Math.round(input.maturityDays)), input.status, id,
  );
  await audit(user, 'CHEQUE_TYPE_UPDATE', 'cheque_type', id, {});
}
