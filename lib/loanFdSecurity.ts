/*
 * The join between a loan and the Fixed Deposit(s) securing it — the FD-as-collateral sibling of
 * lib/loanCollateral.ts (physical collateral_register items) and loan_guarantor (guarantor
 * security). Attaching and detaching are only allowed while the loan is still OPEN, the same
 * point the other two security types are fixed — before disbursement, not after.
 */
import { one, all, run, audit } from './db.ts';
import { AppError } from './errors.ts';
import type { Actor, AvailableFdRow, LoanFdLienRow } from './types.ts';

export const listLoanFdLiens = (loanId: number): Promise<LoanFdLienRow[]> => all<LoanFdLienRow>(
  `SELECT lfl.*, m.member_no, m.first_name AS member_first_name, m.last_name AS member_last_name, d.amount AS fd_amount
   FROM loan_fd_lien lfl
   JOIN member_fixed_deposit d ON d.no = lfl.fd_no
   JOIN member m ON m.id = d.member_id
   WHERE lfl.loan_id = ? ORDER BY lfl.id`,
  loanId,
);

/** The prorated exposure every ACTIVE lien on this FD still carries against a live loan balance —
 *  mirrors lib/collateralRegister.ts's getCollateralLinkedBalance(). Gates Mature/Terminate
 *  (lib/fixedDeposits.ts) as well as how much fresh cover a new lien can still draw. */
export async function getFdLinkedBalance(fdNo: string): Promise<number> {
  const row = await one<{ balance: number }>(
    `SELECT COALESCE(SUM(LEAST(lfl.guarantee, l.principal_balance + l.interest_balance + l.penalty_balance)), 0) AS balance
     FROM loan_fd_lien lfl JOIN loan l ON l.id = lfl.loan_id
     WHERE lfl.fd_no = ? AND lfl.status = 'ACTIVE' AND l.status = 'DISBURSED'
       AND (l.principal_balance + l.interest_balance + l.penalty_balance) > 0`,
    fdNo,
  );
  return row?.balance ?? 0;
}

/** The Fixed Deposits this member could still pledge for a loan — approved or already active,
 *  with cover left over. */
export function listAvailableFdForMember(memberId: number): Promise<AvailableFdRow[]> {
  return all<AvailableFdRow>(
    `SELECT d.no, t.description AS fd_type_description, d.amount,
            d.amount - COALESCE(x.linked_loan_balance, 0) AS available
     FROM member_fixed_deposit d
     JOIN member_fixed_deposit_type t ON t.id = d.fd_type_id
     LEFT JOIN (
       SELECT lfl.fd_no, SUM(LEAST(lfl.guarantee, l.principal_balance + l.interest_balance + l.penalty_balance)) AS linked_loan_balance
       FROM loan_fd_lien lfl JOIN loan l ON l.id = lfl.loan_id
       WHERE lfl.status = 'ACTIVE' AND l.status = 'DISBURSED'
         AND (l.principal_balance + l.interest_balance + l.penalty_balance) > 0
       GROUP BY lfl.fd_no
     ) x ON x.fd_no = d.no
     WHERE d.member_id = ? AND d.status IN ('Approved', 'Active')
       AND d.amount - COALESCE(x.linked_loan_balance, 0) > 0
     ORDER BY d.no`,
    memberId,
  );
}

export interface AttachFdInput {
  loanId: number;
  fdNo: string;
  guarantee: number;
}

/** Pledges a member's Fixed Deposit as security for a loan, capped to whatever cover it still has
 *  left after every loan currently drawing from it. Only while the loan is OPEN. */
export async function attachFdToLoan({ loanId, fdNo, guarantee }: AttachFdInput, user: Actor): Promise<void> {
  const loan = await one<{ id: number; member_id: number; status: string }>(
    'SELECT id, member_id, status FROM loan WHERE id = ?', loanId,
  );
  if (!loan) throw new AppError('Loan not found', 'NOT_FOUND');
  if (loan.status !== 'OPEN') throw new AppError('FD security can only be attached while the loan is still open', 'VALIDATION');

  const fd = await one<{ no: string; member_id: number; amount: number; status: string }>(
    'SELECT no, member_id, amount, status FROM member_fixed_deposit WHERE no = ?', fdNo,
  );
  if (!fd) throw new AppError('Fixed deposit not found', 'NOT_FOUND');
  if (fd.member_id !== loan.member_id) {
    throw new AppError('This fixed deposit does not belong to the same member as the loan', 'VALIDATION');
  }
  if (fd.status !== 'Approved' && fd.status !== 'Active') {
    throw new AppError('Only an approved or active fixed deposit can be pledged as security', 'VALIDATION');
  }

  const amount = Math.round(guarantee);
  if (amount <= 0) throw new AppError('Guarantee amount must be greater than zero', 'VALIDATION');

  const linked = await getFdLinkedBalance(fdNo);
  const available = fd.amount - linked;
  if (amount > available) {
    throw new AppError(
      `Only ${(available / 100).toLocaleString()} of cover is still available on this fixed deposit`, 'VALIDATION',
    );
  }

  await run(
    `INSERT INTO loan_fd_lien (loan_id, fd_no, guarantee, created_at, created_by)
     VALUES (?,?,?,?,?)
     ON CONFLICT (loan_id, fd_no) DO UPDATE SET guarantee = EXCLUDED.guarantee, status = 'ACTIVE'`,
    loanId, fdNo, amount, new Date().toISOString(), user.username,
  );
  await audit(user, 'LOAN_FD_LIEN_ATTACH', 'loan', loanId, { fdNo, guarantee: amount });
}

export async function detachFdFromLoan(loanId: number, fdNo: string, user: Actor): Promise<void> {
  const loan = await one<{ status: string }>('SELECT status FROM loan WHERE id = ?', loanId);
  if (!loan) throw new AppError('Loan not found', 'NOT_FOUND');
  if (loan.status !== 'OPEN') throw new AppError('FD security can only be detached while the loan is still open', 'VALIDATION');

  await run('DELETE FROM loan_fd_lien WHERE loan_id = ? AND fd_no = ?', loanId, fdNo);
  await audit(user, 'LOAN_FD_LIEN_DETACH', 'loan', loanId, { fdNo });
}
