/*
 * The join between a loan and the collateral register item(s) securing it — "Loan Securities"
 * narrowed to Security Type = Collateral (see prisma/schema.prisma's loan_collateral comment;
 * loan_guarantor already covers guarantor security separately). Attaching and detaching are
 * only allowed while the loan is still OPEN, the same point loan_guarantor rows are fixed —
 * before disbursement, not after.
 */
import { one, all, run, audit } from './db.ts';
import { AppError } from './errors.ts';
import { getCollateralLinkedBalance } from './collateralRegister.ts';
import type { Actor, LoanCollateralRow } from './types.ts';

export const listLoanCollateral = (loanId: number): Promise<LoanCollateralRow[]> => all<LoanCollateralRow>(
  `SELECT lc.*, r.collateral_description, r.serial_reg_no, r.collateral_value
   FROM loan_collateral lc JOIN collateral_register r ON r.no = lc.collateral_no
   WHERE lc.loan_id = ? ORDER BY lc.id`,
  loanId,
);

export interface AttachCollateralInput {
  loanId: number;
  collateralNo: string;
  guarantee: number;
}

/** Pledges a register item as security for a loan, capped to whatever cover it still has left
 *  after every loan currently drawing from it. Only while the loan is OPEN — mirrors the
 *  point guarantors are fixed at application, before approval/disbursement. */
export async function attachCollateralToLoan({ loanId, collateralNo, guarantee }: AttachCollateralInput, user: Actor): Promise<void> {
  const loan = await one<{ id: number; member_id: number; status: string }>(
    'SELECT id, member_id, status FROM loan WHERE id = ?', loanId,
  );
  if (!loan) throw new AppError('Loan not found', 'NOT_FOUND');
  if (loan.status !== 'OPEN') throw new AppError('Collateral can only be attached while the loan is still open', 'VALIDATION');

  const register = await one<{ no: string; member_id: number; guarantee: number; collected_at: string | null }>(
    'SELECT no, member_id, guarantee, collected_at FROM collateral_register WHERE no = ?', collateralNo,
  );
  if (!register) throw new AppError('Collateral register item not found', 'NOT_FOUND');
  if (register.collected_at) throw new AppError('This collateral item has already been collected', 'VALIDATION');
  if (register.member_id !== loan.member_id) {
    throw new AppError('This collateral item is not registered to the same member as the loan', 'VALIDATION');
  }

  const amount = Math.round(guarantee);
  if (amount <= 0) throw new AppError('Guarantee amount must be greater than zero', 'VALIDATION');

  const linked = await getCollateralLinkedBalance(collateralNo);
  const available = register.guarantee - linked;
  if (amount > available) {
    throw new AppError(
      `Only ${(available / 100).toLocaleString()} of cover is still available on this collateral item`, 'VALIDATION',
    );
  }

  await run(
    `INSERT INTO loan_collateral (loan_id, collateral_no, guarantee, created_at, created_by)
     VALUES (?,?,?,?,?)
     ON CONFLICT (loan_id, collateral_no) DO UPDATE SET guarantee = EXCLUDED.guarantee, status = 'ACTIVE'`,
    loanId, collateralNo, amount, new Date().toISOString(), user.username,
  );
  await audit(user, 'LOAN_COLLATERAL_ATTACH', 'loan', loanId, { collateralNo, guarantee: amount });
}

export async function detachCollateralFromLoan(loanId: number, collateralNo: string, user: Actor): Promise<void> {
  const loan = await one<{ status: string }>('SELECT status FROM loan WHERE id = ?', loanId);
  if (!loan) throw new AppError('Loan not found', 'NOT_FOUND');
  if (loan.status !== 'OPEN') throw new AppError('Collateral can only be detached while the loan is still open', 'VALIDATION');

  await run('DELETE FROM loan_collateral WHERE loan_id = ? AND collateral_no = ?', loanId, collateralNo);
  await audit(user, 'LOAN_COLLATERAL_DETACH', 'loan', loanId, { collateralNo });
}
