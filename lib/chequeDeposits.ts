/*
 * Cheque Deposit — AL Tab52204124 "Cheque Deposits" (Deposit document type) / Pag52204061-62 /
 * Cod52204019.PostCheque / Rep52204082 "Cheque Deposit Slip".
 *
 * A member banks a third-party cheque. It is captured (Open), approved, then held until its
 * maturity date. On maturity it is Cleared — funds are credited to the member's account
 * (DR "Cheques in Clearing" / CR member deposit control) and the clearing charge is deducted —
 * or Bounced (bouncing charge only; the member never received the funds). Express clearing
 * credits the funds BEFORE maturity for an express charge and places a hold on the account
 * (AL's "Uncleared Funds" effect) until the real maturity date, when the hold is released.
 *
 * Not ported: Cheque "Instructions" (pre-splitting cleared funds to other accounts / loan
 * repayment) and the "Clearance" document type.
 */
import {
  one, all, run, tx, nextSequence, audit, hasAnyRow,
} from './db.ts';
import { AppError } from './errors.ts';
import { postJournal } from './accounting.ts';
import { getJournal, type JournalDetail } from './gl.ts';
import { getTransactionCharge, calculateTransactionCharges, postTransactionCharges } from './charges.ts';
import { getChequeType } from './chequeTypes.ts';
import { repay } from './loanService.ts';
import { resolvePostingDate } from './postingDates.ts';
import { assertMemberNotDormant } from './memberDormancy.ts';
import { today } from './format.ts';
import { findMatchingWorkflow, findPendingRoutedTask, pickConditionFields, startWorkflow } from './workflow.ts';
import { buildFilterClause, type FilterCondition, type FilterFieldDef } from './listFilters.ts';
import { buildOrderClause, type SortState } from './listSort.ts';
import type {
  Actor, Cents, IsoDate, ChequeDeposit, ChequeDepositView, ChequeInstructionView,
} from './types.ts';

/* ----------------------------------------------------- maturity date (AL Tab52204124 field 13) */

const addDays = (iso: IsoDate, n: number): IsoDate => {
  const d = new Date(iso + 'T00:00:00Z');
  d.setUTCDate(d.getUTCDate() + n);
  return d.toISOString().slice(0, 10);
};
const weekday = (iso: IsoDate): number => new Date(iso + 'T00:00:00Z').getUTCDay(); // 0 Sun .. 6 Sat

/**
 * Faithful port of AL Tab52204124's Maturity Date OnValidate:
 *   naive        = deposit_date + maturity_days   (CalcDate("<n>D", …))
 *   weekends     = # of Sat/Sun in [deposit_date, naive] inclusive
 *   holidays     = # of non-working-day-table dates in [deposit_date, deposit_date + maturity_days + weekends]
 *                  (this app has no such table, so holidays = 0; pass `holidayDates` to plug one in)
 *   maturity     = deposit_date + (weekends + maturity_days + holidays)
 *   then if maturity lands on Sunday +1 day, on Saturday +2 days
 * An in-house cheque clears on the deposit date itself.
 */
export function computeMaturityDate(
  depositDate: IsoDate, maturityDays: number, inHouse: boolean, holidayDates: ReadonlySet<string> = new Set(),
): IsoDate {
  if (inHouse || maturityDays <= 0) return depositDate;

  const naive = addDays(depositDate, maturityDays);
  let weekends = 0;
  for (let d = depositDate; d <= naive; d = addDays(d, 1)) {
    const wd = weekday(d);
    if (wd === 0 || wd === 6) weekends += 1;
  }

  let holidays = 0;
  const windowEnd = addDays(depositDate, maturityDays + weekends);
  for (let d = depositDate; d <= windowEnd; d = addDays(d, 1)) {
    if (holidayDates.has(d)) holidays += 1;
  }

  let maturity = addDays(depositDate, weekends + maturityDays + holidays);
  const wd = weekday(maturity);
  if (wd === 0) maturity = addDays(maturity, 1);
  else if (wd === 6) maturity = addDays(maturity, 2);
  return maturity;
}

/* ---------------------------------------------------------------------------- list / view */

export type ChequeDepositTab = 'open' | 'pending' | 'approved' | 'cleared' | 'bounced';

const VIEW_CLAUSE: Record<ChequeDepositTab, string> = {
  open: "d.status = 'Open'",
  pending: "d.status = 'Pending Approval'",
  approved: "d.status = 'Approved'",
  cleared: "d.status = 'Cleared'",
  bounced: "d.status = 'Bounced'",
};

const SELECT_ROW = `
  SELECT d.*,
         ct.code AS cheque_type_code,
         m.member_no, m.first_name AS member_first_name, m.last_name AS member_last_name,
         sa.account_no, sp.name AS account_product_name, sa.balance AS account_balance,
         g.code AS clearing_gl_account_code,
         cc.code AS clearing_charge_code,
         j.journal_no AS journal_no,
         COALESCE((SELECT SUM(ci.amount) FROM cheque_instruction ci WHERE ci.cheque_deposit_no = d.no), 0) AS instructions_total
  FROM cheque_deposit d
  JOIN cheque_type ct ON ct.id = d.cheque_type_id
  JOIN member m ON m.id = d.member_id
  JOIN savings_account sa ON sa.id = d.savings_account_id
  JOIN savings_product sp ON sp.id = sa.product_id
  JOIN gl_account g ON g.id = d.clearing_gl_account_id
  LEFT JOIN transaction_charge cc ON cc.id = d.clearing_charge_id
  LEFT JOIN journal j ON j.id = d.journal_id`;

export const CHEQUE_DEPOSIT_FILTER_FIELDS: FilterFieldDef[] = [
  { key: 'no', label: 'No.', type: 'text', column: 'd.no' },
  { key: 'cheque_type_id', label: 'Cheque Type', type: 'select', column: 'd.cheque_type_id' },
  { key: 'member_id', label: 'Member', type: 'select', column: 'd.member_id' },
  { key: 'cheque_no', label: 'Cheque No.', type: 'text', column: 'd.cheque_no' },
  { key: 'deposit_date', label: 'Deposit Date', type: 'date', column: 'd.deposit_date' },
  { key: 'maturity_date', label: 'Maturity Date', type: 'date', column: 'd.maturity_date' },
  { key: 'created_by', label: 'Created By', type: 'text', column: 'd.created_by' },
];

const SORT_COLUMNS: Record<string, string> = {
  no: 'd.no',
  member: 'm.first_name',
  amount: 'd.amount',
  status: 'd.status',
  deposit_date: 'd.deposit_date',
  maturity_date: 'd.maturity_date',
  created_at: 'd.created_at',
};

export interface ListChequeDepositsOptions {
  view?: ChequeDepositTab;
  search?: string;
  filters?: FilterCondition[];
  sort?: SortState | null;
}

type ChequeDepositRow = Omit<ChequeDepositView, 'matured'>;
const withMatured = (r: ChequeDepositRow): ChequeDepositView => ({
  ...r, matured: r.status === 'Approved' && r.maturity_date <= today(),
});

export async function listChequeDeposits(
  { view, search = '', filters = [], sort = null }: ListChequeDepositsOptions = {},
): Promise<ChequeDepositView[]> {
  const { clause, params } = buildFilterClause(CHEQUE_DEPOSIT_FILTER_FIELDS, filters);
  const orderBy = buildOrderClause(SORT_COLUMNS, sort, 'd.no DESC');
  const rows = await all<ChequeDepositRow>(
    `${SELECT_ROW}
     WHERE (d.no LIKE @like OR d.cheque_no LIKE @like OR m.member_no LIKE @like
        OR m.first_name LIKE @like OR m.last_name LIKE @like OR sa.account_no LIKE @like OR d.drawer_bank LIKE @like)
       ${view ? `AND ${VIEW_CLAUSE[view]}` : ''}
       ${clause}
     ${orderBy}`,
    { like: `%${String(search).trim()}%`, ...params },
  );
  return rows.map(withMatured);
}

export async function getChequeDeposit(no: string): Promise<ChequeDepositView | undefined> {
  const row = await one<ChequeDepositRow>(`${SELECT_ROW} WHERE d.no = ?`, no);
  return row ? withMatured(row) : undefined;
}

export const hasAnyChequeDeposits = (view?: ChequeDepositTab): Promise<boolean> =>
  hasAnyRow('cheque_deposit d', view ? VIEW_CLAUSE[view] : undefined);

export async function getAdjacentChequeDepositNos(
  no: string, view?: ChequeDepositTab,
): Promise<{ prevNo: string | null; nextNo: string | null }> {
  const clause = view ? `AND ${VIEW_CLAUSE[view]}` : '';
  const [prev, next] = await Promise.all([
    one<{ no: string }>(`SELECT d.no FROM cheque_deposit d WHERE d.no < ? ${clause} ORDER BY d.no DESC LIMIT 1`, no),
    one<{ no: string }>(`SELECT d.no FROM cheque_deposit d WHERE d.no > ? ${clause} ORDER BY d.no ASC LIMIT 1`, no),
  ]);
  return { prevNo: prev?.no ?? null, nextNo: next?.no ?? null };
}

/* -------------------------------------------------------------- account picker */

export interface ChequeDepositAccount {
  id: number; account_no: string; product_name: string; balance: Cents;
}

/** The member's active deposit accounts a cheque can be banked into (AL auto-targets the
 *  Withdrawable Deposit account; here any withdrawal-enabled product). */
export const chequeDepositAccountsForMember = (memberId: number): Promise<ChequeDepositAccount[]> =>
  all<ChequeDepositAccount>(
    `SELECT sa.id, sa.account_no, sp.name AS product_name, sa.balance
     FROM savings_account sa JOIN savings_product sp ON sp.id = sa.product_id
     WHERE sa.member_id = ? AND sa.status = 'ACTIVE' AND sp.allow_withdrawal = 1
     ORDER BY sa.account_no`,
    memberId,
  );

/* ----------------------------------------------------------- cheque instructions */

export interface ChequeInstructionTargetOption {
  target_type: 'ACCOUNT' | 'LOAN';
  id: number;
  label: string;
  balance: Cents;
}

/** AL Tab52204087's Account No. lookup — the depositing member's OWN savings accounts (other
 *  than the deposit account itself) and their OWN disbursed loans. No cross-member targets. */
export async function instructionTargetsForMember(
  memberId: number, excludeAccountId?: number,
): Promise<ChequeInstructionTargetOption[]> {
  const [accts, loans] = await Promise.all([
    all<{ id: number; account_no: string; product_name: string; balance: Cents }>(
      `SELECT sa.id, sa.account_no, sp.name AS product_name, sa.balance
       FROM savings_account sa JOIN savings_product sp ON sp.id = sa.product_id
       WHERE sa.member_id = ? AND sa.status = 'ACTIVE' AND sa.id <> ?
       ORDER BY sa.account_no`,
      memberId, excludeAccountId ?? 0,
    ),
    all<{ id: number; loan_no: string; product_name: string; bal: Cents }>(
      `SELECT l.id, l.loan_no, lp.name AS product_name,
              (l.principal_balance + l.interest_balance + l.penalty_balance) AS bal
       FROM loan l JOIN loan_product lp ON lp.id = l.product_id
       WHERE l.member_id = ? AND l.status = 'DISBURSED'
         AND (l.principal_balance + l.interest_balance + l.penalty_balance) > 0
       ORDER BY l.loan_no`,
      memberId,
    ),
  ]);
  return [
    ...accts.map((a) => ({ target_type: 'ACCOUNT' as const, id: a.id, label: `${a.account_no} — ${a.product_name}`, balance: a.balance })),
    ...loans.map((l) => ({ target_type: 'LOAN' as const, id: l.id, label: `${l.loan_no} — ${l.product_name}`, balance: l.bal })),
  ];
}

const INSTRUCTION_SELECT = `
  SELECT ci.*,
         CASE WHEN ci.target_type = 'LOAN'
              THEN (SELECT l.loan_no || ' — ' || lp.name FROM loan l JOIN loan_product lp ON lp.id = l.product_id WHERE l.id = ci.loan_id)
              ELSE (SELECT sa.account_no || ' — ' || sp.name FROM savings_account sa JOIN savings_product sp ON sp.id = sa.product_id WHERE sa.id = ci.savings_account_id)
         END AS target_label,
         CASE WHEN ci.target_type = 'LOAN'
              THEN (SELECT l.principal_balance + l.interest_balance + l.penalty_balance FROM loan l WHERE l.id = ci.loan_id)
              ELSE (SELECT sa.balance FROM savings_account sa WHERE sa.id = ci.savings_account_id)
         END AS target_balance
  FROM cheque_instruction ci`;

export const listChequeInstructions = (no: string): Promise<ChequeInstructionView[]> =>
  all<ChequeInstructionView>(`${INSTRUCTION_SELECT} WHERE ci.cheque_deposit_no = ? ORDER BY ci.line_no, ci.id`, no);

async function assertOpenDeposit(no: string, user: Actor): Promise<ChequeDeposit> {
  const dep = await one<ChequeDeposit>('SELECT * FROM cheque_deposit WHERE no = ?', no);
  if (!dep) throw new AppError('Cheque deposit not found', 'NOT_FOUND');
  if (dep.status !== 'Open') throw new AppError('Instructions can only be changed while the deposit is Open', 'VALIDATION');
  if (dep.created_by !== user.username) throw new AppError('Only the person who created this deposit can change its instructions', 'NOT_CREATOR');
  return dep;
}

/** The most that may be distributed by instructions — the cheque amount less the clearing
 *  charge (AL OnBeforeSendForApproval's `Amount - "Total Clearing Charges"`). */
export async function instructableAmount(dep: Pick<ChequeDeposit, 'amount' | 'clearing_charge_id'>): Promise<Cents> {
  const charge = await chargeAmount(dep.clearing_charge_id, Number(dep.amount));
  return Math.max(Number(dep.amount) - charge, 0);
}

export interface ChequeInstructionInput {
  targetType: 'ACCOUNT' | 'LOAN';
  targetId: number;
  amount: Cents;
}

export async function addChequeInstruction(no: string, input: ChequeInstructionInput, user: Actor): Promise<{ id: number }> {
  const dep = await assertOpenDeposit(no, user);
  if (!(input.amount > 0)) throw new AppError('Amount must be greater than zero', 'VALIDATION');
  if (!input.targetId) throw new AppError('A target account or loan is required', 'VALIDATION');

  if (input.targetType === 'ACCOUNT') {
    if (input.targetId === dep.savings_account_id) throw new AppError('The deposit account cannot also be an instruction target', 'VALIDATION');
    const acct = await one<{ member_id: number; status: string }>('SELECT member_id, status FROM savings_account WHERE id = ?', input.targetId);
    if (!acct || acct.member_id !== dep.member_id) throw new AppError('That account does not belong to this member', 'VALIDATION');
    if (acct.status !== 'ACTIVE') throw new AppError('That account is not active', 'VALIDATION');
  } else {
    const loan = await one<{ member_id: number; status: string }>('SELECT member_id, status FROM loan WHERE id = ?', input.targetId);
    if (!loan || loan.member_id !== dep.member_id) throw new AppError('That loan does not belong to this member', 'VALIDATION');
    if (loan.status !== 'DISBURSED') throw new AppError('That loan is not open for repayment', 'VALIDATION');
  }

  const existing = await one<{ total: Cents }>(
    "SELECT COALESCE(SUM(amount),0) AS total FROM cheque_instruction WHERE cheque_deposit_no = ?", no,
  );
  const cap = await instructableAmount(dep);
  if ((existing?.total ?? 0) + input.amount > cap) {
    throw new AppError(`Instructions cannot exceed ${(cap / 100).toFixed(2)} (cheque amount less the clearing charge)`, 'VALIDATION');
  }

  const next = await one<{ n: number }>("SELECT COALESCE(MAX(line_no),0) + 1 AS n FROM cheque_instruction WHERE cheque_deposit_no = ?", no);
  const info = await run(
    `INSERT INTO cheque_instruction (cheque_deposit_no, line_no, target_type, savings_account_id, loan_id, amount, created_at, created_by)
     VALUES (?,?,?,?,?,?,?,?)`,
    no, next?.n ?? 1, input.targetType,
    input.targetType === 'ACCOUNT' ? input.targetId : null,
    input.targetType === 'LOAN' ? input.targetId : null,
    Math.round(input.amount), new Date().toISOString(), user.username,
  );
  await audit(user, 'CHEQUE_INSTRUCTION_ADD', 'cheque_instruction', info.lastInsertRowid, { no, ...input });
  return { id: Number(info.lastInsertRowid) };
}

export async function deleteChequeInstruction(no: string, id: number, user: Actor): Promise<void> {
  await assertOpenDeposit(no, user);
  const line = await one<{ id: number }>('SELECT id FROM cheque_instruction WHERE id = ? AND cheque_deposit_no = ?', id, no);
  if (!line) throw new AppError('Instruction line not found', 'NOT_FOUND');
  await run('DELETE FROM cheque_instruction WHERE id = ?', id);
  await audit(user, 'CHEQUE_INSTRUCTION_DELETE', 'cheque_instruction', id, { no });
}

/* ------------------------------------------------------------------- charge helpers */

async function chargeAmount(chargeId: number | null | undefined, base: Cents): Promise<Cents> {
  if (!chargeId) return 0;
  const detail = await getTransactionCharge(chargeId);
  if (!detail) return 0;
  return calculateTransactionCharges(detail, base).reduce((s, c) => s + c.amount, 0);
}

export interface ChequeDepositChargePreview {
  clearing: Cents;
  express: Cents;
  bouncing: Cents;
}

export async function previewChequeDepositCharges(chequeTypeId: number, amount: Cents): Promise<ChequeDepositChargePreview> {
  const type = chequeTypeId ? await getChequeType(chequeTypeId) : null;
  if (!type || !(amount > 0)) return { clearing: 0, express: 0, bouncing: 0 };
  const [clearing, express, bouncing] = await Promise.all([
    chargeAmount(type.clearing_charge_id, amount),
    chargeAmount(type.express_charge_id, amount),
    chargeAmount(type.bouncing_charge_id, amount),
  ]);
  return { clearing, express, bouncing };
}

/* ------------------------------------------------------------ create / edit */

export interface ChequeDepositInput {
  chequeTypeId: number;
  memberId: number;
  savingsAccountId: number;
  chequeNo?: string | null;
  chequeDate?: IsoDate | null;
  depositDate: IsoDate;
  amount: Cents;
  expressCheque: boolean;
  drawerAccountName?: string | null;
  drawerBank?: string | null;
  drawerBranch?: string | null;
  drawerAccountNo?: string | null;
}

async function accountOwner(savingsAccountId: number): Promise<{ member_id: number; status: string; gl_control_id: number; balance: Cents; hold_amount: Cents }> {
  const acct = await one<{ member_id: number; status: string; gl_control_id: number; balance: Cents; hold_amount: Cents }>(
    `SELECT sa.member_id, sa.status, sp.gl_control_id, sa.balance, sa.hold_amount
     FROM savings_account sa JOIN savings_product sp ON sp.id = sa.product_id WHERE sa.id = ?`,
    savingsAccountId,
  );
  if (!acct) throw new AppError('Savings account not found', 'NOT_FOUND');
  return acct;
}

async function assertValid(input: ChequeDepositInput): Promise<{
  description: string; inHouse: boolean; maturityDate: IsoDate;
  clearingGlAccountId: number; clearingChargeId: number | null; bouncingChargeId: number | null; expressChargeId: number | null;
}> {
  if (!input.chequeTypeId) throw new AppError('A cheque type is required', 'VALIDATION');
  if (!input.memberId) throw new AppError('A member is required', 'VALIDATION');
  if (!input.savingsAccountId) throw new AppError('An account is required', 'VALIDATION');
  if (!input.depositDate) throw new AppError('A deposit date is required', 'VALIDATION');
  if (!input.chequeNo?.trim()) throw new AppError('The cheque number is required', 'VALIDATION');
  if (!input.chequeDate) throw new AppError('The cheque date is required', 'VALIDATION');
  if (!(input.amount > 0)) throw new AppError('Amount must be greater than zero', 'VALIDATION');
  // AL: "You cannot back date a Cheque"
  if (input.depositDate < today()) throw new AppError('The deposit date cannot be in the past', 'VALIDATION');

  const type = await getChequeType(input.chequeTypeId);
  if (!type) throw new AppError('Cheque type not found', 'NOT_FOUND');
  if (type.type !== 'EXTERNAL') throw new AppError('That cheque type cannot be used for a cheque deposit', 'VALIDATION');
  if (type.status !== 'ACTIVE') throw new AppError('That cheque type is not active', 'VALIDATION');
  if (type.maximum_amount > 0 && input.amount > type.maximum_amount) {
    throw new AppError(`This cheque type caps a deposit at ${(type.maximum_amount / 100).toFixed(2)}`, 'AMOUNT_EXCEEDS_MAX');
  }
  if (input.expressCheque && !type.express_charge_id) {
    throw new AppError('This cheque type has no express clearing charge configured', 'VALIDATION');
  }

  const acct = await accountOwner(input.savingsAccountId);
  if (acct.member_id !== input.memberId) throw new AppError('That account does not belong to this member', 'VALIDATION');
  if (acct.status !== 'ACTIVE') throw new AppError(`The account is ${acct.status} — a cheque cannot be banked into it`, 'VALIDATION');

  return {
    description: type.description,
    inHouse: type.in_house,
    maturityDate: computeMaturityDate(input.depositDate, type.maturity_days, type.in_house),
    clearingGlAccountId: type.clearing_gl_account_id,
    clearingChargeId: type.clearing_charge_id,
    bouncingChargeId: type.bouncing_charge_id,
    expressChargeId: type.express_charge_id,
  };
}

export async function createChequeDeposit(input: ChequeDepositInput, user: Actor): Promise<{ no: string; maturityDate: IsoDate }> {
  const s = await assertValid(input);
  const no = await nextSequence('CHEQUE_DEPOSIT');
  await run(
    `INSERT INTO cheque_deposit
       (no, cheque_type_id, description, member_id, savings_account_id, cheque_no, cheque_date, deposit_date,
        maturity_date, in_house, amount, express_cheque, drawer_account_name, drawer_bank, drawer_branch,
        drawer_account_no, clearing_gl_account_id, clearing_charge_id, bouncing_charge_id, express_charge_id,
        created_at, created_by)
     VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)`,
    no, input.chequeTypeId, s.description, input.memberId, input.savingsAccountId,
    input.chequeNo?.trim() || null, input.chequeDate, input.depositDate, s.maturityDate, s.inHouse,
    Math.round(input.amount), input.expressCheque, input.drawerAccountName?.trim() || null,
    input.drawerBank?.trim() || null, input.drawerBranch?.trim() || null, input.drawerAccountNo?.trim() || null,
    s.clearingGlAccountId, s.clearingChargeId, s.bouncingChargeId, s.expressChargeId,
    new Date().toISOString(), user.username,
  );
  await audit(user, 'CHEQUE_DEPOSIT_CREATE', 'cheque_deposit', no, { amount: input.amount, maturityDate: s.maturityDate });
  return { no, maturityDate: s.maturityDate };
}

export async function updateChequeDeposit(no: string, input: ChequeDepositInput, user: Actor): Promise<ChequeDepositView> {
  const before = await one<ChequeDeposit>('SELECT * FROM cheque_deposit WHERE no = ?', no);
  if (!before) throw new AppError('Cheque deposit not found', 'NOT_FOUND');
  if (before.status !== 'Open') throw new AppError('Only an open cheque deposit can be edited', 'VALIDATION');
  if (before.created_by !== user.username) throw new AppError('Only the person who created this can edit it', 'NOT_CREATOR');
  const s = await assertValid(input);
  await run(
    `UPDATE cheque_deposit
     SET cheque_type_id = ?, description = ?, member_id = ?, savings_account_id = ?, cheque_no = ?, cheque_date = ?,
         deposit_date = ?, maturity_date = ?, in_house = ?, amount = ?, express_cheque = ?, drawer_account_name = ?,
         drawer_bank = ?, drawer_branch = ?, drawer_account_no = ?, clearing_gl_account_id = ?, clearing_charge_id = ?,
         bouncing_charge_id = ?, express_charge_id = ?
     WHERE no = ?`,
    input.chequeTypeId, s.description, input.memberId, input.savingsAccountId, input.chequeNo?.trim() || null,
    input.chequeDate, input.depositDate, s.maturityDate, s.inHouse, Math.round(input.amount), input.expressCheque,
    input.drawerAccountName?.trim() || null, input.drawerBank?.trim() || null, input.drawerBranch?.trim() || null,
    input.drawerAccountNo?.trim() || null, s.clearingGlAccountId, s.clearingChargeId, s.bouncingChargeId, s.expressChargeId,
    no,
  );
  // Changing the amount or the deposit account can invalidate existing instructions — clear them.
  if (Number(before.amount) !== Math.round(input.amount) || before.savings_account_id !== input.savingsAccountId) {
    await run('DELETE FROM cheque_instruction WHERE cheque_deposit_no = ?', no);
  }
  await audit(user, 'CHEQUE_DEPOSIT_UPDATE', 'cheque_deposit', no, {});
  return (await getChequeDeposit(no))!;
}

export async function deleteChequeDeposit(no: string, user: Actor): Promise<void> {
  const before = await one<Pick<ChequeDeposit, 'status' | 'created_by'>>(
    'SELECT status, created_by FROM cheque_deposit WHERE no = ?', no,
  );
  if (!before) throw new AppError('Cheque deposit not found', 'NOT_FOUND');
  if (before.status !== 'Open') throw new AppError('Only an open cheque deposit can be deleted', 'VALIDATION');
  if (before.created_by !== user.username) throw new AppError('Only the person who created this can delete it', 'NOT_CREATOR');
  await run('DELETE FROM cheque_deposit WHERE no = ?', no);
  await audit(user, 'CHEQUE_DEPOSIT_DELETE', 'cheque_deposit', no, {});
}

/* -------------------------------------------------------------- maker-checker */

export async function submitChequeDeposit(no: string, user: Actor): Promise<{ autoApproved: boolean }> {
  const req = await one<ChequeDeposit>('SELECT * FROM cheque_deposit WHERE no = ?', no);
  if (!req) throw new AppError('Cheque deposit not found', 'NOT_FOUND');
  if (req.status !== 'Open') throw new AppError('Only an open cheque deposit can be submitted for approval', 'VALIDATION');
  await assertInstructionsWithinCap(req);

  const matched = await findMatchingWorkflow('CHEQUE_DEPOSIT', await pickConditionFields('CHEQUE_DEPOSIT', req));
  if (!matched) throw new AppError('There is no enabled workflow for this document', 'NO_WORKFLOW');

  await tx(async () => {
    await run("UPDATE cheque_deposit SET status = 'Pending Approval' WHERE no = ?", no);
    await startWorkflow(matched.workflow, matched.steps, {
      documentType: 'CHEQUE_DEPOSIT', entityId: no, requestedBy: user.username, amount: Number(req.amount),
    });
  });

  const after = await one<{ status: string }>('SELECT status FROM cheque_deposit WHERE no = ?', no);
  return { autoApproved: after?.status === 'Approved' };
}

export async function cancelChequeDepositApproval(no: string, user: Actor): Promise<void> {
  const req = await one<Pick<ChequeDeposit, 'status' | 'created_by'>>('SELECT status, created_by FROM cheque_deposit WHERE no = ?', no);
  if (!req) throw new AppError('Cheque deposit not found', 'NOT_FOUND');
  if (req.status !== 'Pending Approval') throw new AppError('Only a cheque deposit pending approval can be recalled', 'VALIDATION');
  const routed = await findPendingRoutedTask('CHEQUE_DEPOSIT', no);
  const requestedBy = routed?.requested_by ?? req.created_by;
  if (requestedBy !== user.username) throw new AppError('Only the person who submitted this can recall it', 'NOT_REQUESTER');
  await run("UPDATE cheque_deposit SET status = 'Open' WHERE no = ?", no);
  await audit(user, 'CHEQUE_DEPOSIT_CANCEL_APPROVAL', 'cheque_deposit', no, {});
}

export async function approveChequeDeposit(no: string, user: Actor): Promise<void> {
  const req = await one<ChequeDeposit>('SELECT * FROM cheque_deposit WHERE no = ?', no);
  if (!req) throw new AppError('Cheque deposit not found', 'NOT_FOUND');
  if (req.status !== 'Pending Approval') throw new AppError('Only a cheque deposit pending approval can be approved', 'VALIDATION');
  await run("UPDATE cheque_deposit SET status = 'Approved', decision_reason = NULL WHERE no = ?", no);
  await audit(user, 'CHEQUE_DEPOSIT_APPROVE', 'cheque_deposit', no, {});
}

export async function rejectChequeDeposit(no: string, reason: string | null, user: Actor): Promise<void> {
  if (!reason || !reason.trim()) throw new AppError('A reason is required to reject a cheque deposit', 'VALIDATION');
  const req = await one<ChequeDeposit>('SELECT * FROM cheque_deposit WHERE no = ?', no);
  if (!req) throw new AppError('Cheque deposit not found', 'NOT_FOUND');
  if (req.status !== 'Pending Approval') throw new AppError('Only a cheque deposit pending approval can be rejected', 'VALIDATION');
  await run("UPDATE cheque_deposit SET status = 'Open', decision_reason = ? WHERE no = ?", reason, no);
  await audit(user, 'CHEQUE_DEPOSIT_REJECT', 'cheque_deposit', no, { reason });
}

/** An Approved (not yet cleared) cheque deposit back to Open for amendment (AL's "Re&open"). */
export async function reopenChequeDeposit(no: string, user: Actor): Promise<void> {
  const req = await one<ChequeDeposit>('SELECT * FROM cheque_deposit WHERE no = ?', no);
  if (!req) throw new AppError('Cheque deposit not found', 'NOT_FOUND');
  if (req.status !== 'Approved') throw new AppError('Only an approved cheque deposit can be reopened', 'VALIDATION');
  await run("UPDATE cheque_deposit SET status = 'Open' WHERE no = ?", no);
  await audit(user, 'CHEQUE_DEPOSIT_REOPEN', 'cheque_deposit', no, {});
}

/* ------------------------------------------------------------------- clearing / bouncing */

async function assertInstructionsWithinCap(dep: ChequeDeposit): Promise<void> {
  const row = await one<{ total: Cents }>(
    "SELECT COALESCE(SUM(amount),0) AS total FROM cheque_instruction WHERE cheque_deposit_no = ?", dep.no,
  );
  const total = Number(row?.total ?? 0);
  if (total <= 0) return;
  const cap = await instructableAmount(dep);
  if (total > cap) {
    throw new AppError(
      `The instructions total ${(total / 100).toFixed(2)} but only ${(cap / 100).toFixed(2)} is available (cheque amount less the clearing charge)`,
      'VALIDATION',
    );
  }
}

/**
 * Execute the deposit's cheque instructions against the now-confirmed funds in the deposit
 * account: an ACCOUNT line moves its amount to another of the member's accounts; a LOAN line
 * repays that loan (capped at its balance — any excess simply stays in the deposit account,
 * matching AL's own "Refund Any Amount excess" line).
 */
async function processInstructions(req: ChequeDeposit, user: Actor, vd: IsoDate): Promise<{ toAccounts: Cents; toLoans: Cents }> {
  const lines = await all<{ id: number; target_type: string; savings_account_id: number | null; loan_id: number | null; amount: Cents }>(
    'SELECT id, target_type, savings_account_id, loan_id, amount FROM cheque_instruction WHERE cheque_deposit_no = ? ORDER BY line_no, id',
    req.no,
  );
  if (!lines.length) return { toAccounts: 0, toLoans: 0 };

  const src = await one<{ gl_control_id: number }>(
    'SELECT sp.gl_control_id FROM savings_account sa JOIN savings_product sp ON sp.id = sa.product_id WHERE sa.id = ?',
    req.savings_account_id,
  );
  if (!src) throw new AppError('Deposit account not found', 'NOT_FOUND');

  let toAccounts = 0;
  let toLoans = 0;
  for (const line of lines) {
    const amt = Number(line.amount);
    if (line.target_type === 'ACCOUNT') {
      const dst = await one<{ balance: Cents; gl_control_id: number; account_no: string }>(
        `SELECT sa.balance, sp.gl_control_id, sa.account_no
         FROM savings_account sa JOIN savings_product sp ON sp.id = sa.product_id WHERE sa.id = ?`,
        line.savings_account_id,
      );
      const srcBal = await one<{ balance: Cents; account_no: string }>('SELECT balance, account_no FROM savings_account WHERE id = ?', req.savings_account_id);
      if (!dst || !srcBal) throw new AppError('Instruction target account not found', 'NOT_FOUND');
      const narration = `Cheque deposit ${req.no} instruction — ${srcBal.account_no} → ${dst.account_no}`;
      const j = await postJournal({
        valueDate: vd, module: 'SAVINGS', eventType: 'CHEQUE_DEPOSIT_INSTRUCTION',
        description: narration, reference: req.no, memberId: req.member_id, user,
        idempotencyKey: `CHEQUE_DEPOSIT-INSTR-${line.id}`,
        lines: [
          { account: src.gl_control_id, debit: amt, credit: 0, narration },
          { account: dst.gl_control_id, debit: 0, credit: amt, narration },
        ],
      });
      const newSrc = Number(srcBal.balance) - amt;
      await run('UPDATE savings_account SET balance = ?, last_activity = ?, version = version + 1 WHERE id = ?', newSrc, vd, req.savings_account_id);
      await run(
        `INSERT INTO txn (txn_ref, value_date, created_at, module, txn_type, member_id, savings_account_id,
           amount, running_balance, channel, description, journal_id, created_by)
         VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?)`,
        await nextSequence('TXN'), vd, new Date().toISOString(), 'SAVINGS', 'WITHDRAWAL', req.member_id,
        req.savings_account_id, -amt, newSrc, 'CHEQUE', narration, j.id, user.username,
      );
      const newDst = Number(dst.balance) + amt;
      await run('UPDATE savings_account SET balance = ?, last_activity = ?, version = version + 1 WHERE id = ?', newDst, vd, line.savings_account_id);
      await run(
        `INSERT INTO txn (txn_ref, value_date, created_at, module, txn_type, member_id, savings_account_id,
           amount, running_balance, channel, description, journal_id, created_by)
         VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?)`,
        await nextSequence('TXN'), vd, new Date().toISOString(), 'SAVINGS', 'DEPOSIT', req.member_id,
        line.savings_account_id, amt, newDst, 'CHEQUE', narration, j.id, user.username,
      );
      toAccounts += amt;
    } else {
      const loan = await one<{ principal_balance: Cents; interest_balance: Cents; penalty_balance: Cents; status: string }>(
        'SELECT principal_balance, interest_balance, penalty_balance, status FROM loan WHERE id = ?', line.loan_id,
      );
      if (!loan) throw new AppError('Instruction target loan not found', 'NOT_FOUND');
      const owed = Number(loan.principal_balance) + Number(loan.interest_balance) + Number(loan.penalty_balance);
      const pay = Math.min(amt, Math.max(owed, 0));
      if (loan.status === 'DISBURSED' && pay > 0) {
        await repay({
          loanId: line.loan_id!, amount: pay, channel: 'SYSTEM', fromSavingsAccountId: req.savings_account_id,
          valueDate: vd, description: `Cheque deposit ${req.no} instruction`, user,
          idempotencyKey: `CHEQUE_DEPOSIT-INSTR-${line.id}`,
        });
        toLoans += pay;
      }
      // Any excess (amt - pay) simply remains in the deposit account.
    }
  }
  return { toAccounts, toLoans };
}

/** Credit the member and deduct the given charge; shared by normal and express clearing. */
async function creditCleared(
  req: ChequeDeposit, chargeId: number | null, chargeEvent: string, user: Actor,
): Promise<{ journalNo: string; balance: Cents; charged: Cents }> {
  const type = await getChequeType(req.cheque_type_id);
  if (!type) throw new AppError('Cheque type not found', 'NOT_FOUND');
  const acct = await accountOwner(req.savings_account_id);
  const amount = Number(req.amount);
  const vd = await resolvePostingDate(user);
  const narration = `Cheque deposit ${req.no}${req.cheque_no ? ` (${req.cheque_no})` : ''} cleared`;

  const j = await postJournal({
    valueDate: vd, module: 'SAVINGS', eventType: 'CHEQUE_DEPOSIT',
    description: narration, reference: req.no, memberId: req.member_id, user,
    idempotencyKey: `CHEQUE_DEPOSIT-${req.no}`,
    lines: [
      { account: req.clearing_gl_account_id, debit: amount, credit: 0, narration },
      { account: acct.gl_control_id, debit: 0, credit: amount, narration },
    ],
  });

  let balance = acct.balance + amount;
  await run('UPDATE savings_account SET balance = ?, last_activity = ?, version = version + 1 WHERE id = ?', balance, vd, req.savings_account_id);
  await run(
    `INSERT INTO txn (txn_ref, value_date, created_at, module, txn_type, member_id, savings_account_id,
       amount, running_balance, channel, description, journal_id, created_by)
     VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?)`,
    await nextSequence('TXN'), vd, new Date().toISOString(), 'SAVINGS', 'DEPOSIT', req.member_id,
    req.savings_account_id, amount, balance, 'CHEQUE', narration, j.id, user.username,
  );

  let charged = 0;
  if (chargeId) {
    const posted = await postTransactionCharges({
      transactionChargeId: chargeId, baseAmount: amount, debitAccountCode: acct.gl_control_id,
      valueDate: vd, module: 'SAVINGS', eventType: chargeEvent, memberId: req.member_id,
      description: `Cheque deposit charge — ${req.no}`, reference: req.no, user,
      idempotencyKey: `CHEQUE_DEPOSIT-CHG-${req.no}`,
    });
    if (posted) {
      charged = posted.charges.reduce((sum, c) => sum + c.amount, 0);
      balance -= charged;
      await run('UPDATE savings_account SET balance = ?, last_activity = ? WHERE id = ?', balance, vd, req.savings_account_id);
      await run(
        `INSERT INTO txn (txn_ref, value_date, created_at, module, txn_type, member_id, savings_account_id,
           amount, running_balance, channel, description, journal_id, created_by)
         VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?)`,
        await nextSequence('TXN'), vd, new Date().toISOString(), 'SAVINGS', 'FEE', req.member_id,
        req.savings_account_id, -charged, balance, 'CHEQUE', `Cheque deposit charge — ${req.no}`, posted.journal.id, user.username,
      );
    }
  }

  await run(
    `UPDATE cheque_deposit SET status = 'Cleared', charge_amount = ?, journal_id = ?, cleared_by = ?, clearance_date = ?
     WHERE no = ?`,
    charged, j.id, user.username, vd, req.no,
  );
  return { journalNo: j.journal_no, balance, charged };
}

/** Normal clearing on/after the maturity date. */
export async function clearChequeDeposit(no: string, user: Actor): Promise<{ journalNo: string; balance: Cents; charged: Cents }> {
  return tx(async () => {
    const req = await one<ChequeDeposit>('SELECT * FROM cheque_deposit WHERE no = ?', no);
    if (!req) throw new AppError('Cheque deposit not found', 'NOT_FOUND');
    if (req.status !== 'Approved') throw new AppError('Only an approved cheque deposit can be cleared', 'VALIDATION');
    if (req.maturity_date > today()) {
      throw new AppError(
        `This cheque matures on ${req.maturity_date} — use express clearing to release the funds early`, 'NOT_MATURED',
      );
    }
    await assertMemberNotDormant(req.member_id, 'a cheque deposit');
    await assertInstructionsWithinCap(req);
    const res = await creditCleared(req, req.clearing_charge_id, 'CHEQUE_DEPOSIT_CLEAR_CHARGE', user);
    const vd = await resolvePostingDate(user);
    const distributed = await processInstructions(req, user, vd);
    await audit(user, 'CHEQUE_DEPOSIT_CLEAR', 'cheque_deposit', no, {
      journalNo: res.journalNo, amount: Number(req.amount), ...distributed,
    });
    return res;
  });
}

/** Express clearing before maturity — credits the funds now, charges the express fee, and holds
 *  the amount on the account until the real maturity date (AL's "Uncleared Funds" effect). */
export async function expressClearChequeDeposit(no: string, user: Actor): Promise<{ journalNo: string; balance: Cents; charged: Cents; held: Cents }> {
  return tx(async () => {
    const req = await one<ChequeDeposit>('SELECT * FROM cheque_deposit WHERE no = ?', no);
    if (!req) throw new AppError('Cheque deposit not found', 'NOT_FOUND');
    if (req.status !== 'Approved') throw new AppError('Only an approved cheque deposit can be express-cleared', 'VALIDATION');
    if (!req.express_cheque) throw new AppError('This cheque was not marked for express clearing', 'VALIDATION');
    if (!req.express_charge_id) throw new AppError('This cheque type has no express clearing charge configured', 'VALIDATION');
    if (req.maturity_date <= today()) throw new AppError('This cheque has already matured — clear it normally', 'VALIDATION');
    await assertMemberNotDormant(req.member_id, 'a cheque deposit');

    const res = await creditCleared(req, req.express_charge_id, 'CHEQUE_DEPOSIT_EXPRESS_CHARGE', user);

    // Hold the (uncleared) amount so the member cannot spend it before the real maturity date.
    const amount = Number(req.amount);
    const acct = await one<{ hold_amount: Cents }>('SELECT hold_amount FROM savings_account WHERE id = ?', req.savings_account_id);
    await run(
      'UPDATE savings_account SET hold_amount = ?, version = version + 1 WHERE id = ?',
      (acct?.hold_amount ?? 0) + amount, req.savings_account_id,
    );
    await run('UPDATE cheque_deposit SET express_hold_amount = ? WHERE no = ?', amount, no);
    await audit(user, 'CHEQUE_DEPOSIT_EXPRESS_CLEAR', 'cheque_deposit', no, { journalNo: res.journalNo, held: amount });
    return { ...res, held: amount };
  });
}

/** After the real maturity date, lift the hold an express clearance placed on the account. */
export async function releaseChequeDepositHold(no: string, user: Actor): Promise<{ held: Cents }> {
  return tx(async () => {
    const req = await one<ChequeDeposit>('SELECT * FROM cheque_deposit WHERE no = ?', no);
    if (!req) throw new AppError('Cheque deposit not found', 'NOT_FOUND');
    if (req.status !== 'Cleared' || Number(req.express_hold_amount) <= 0) {
      throw new AppError('This cheque deposit has no express hold to release', 'VALIDATION');
    }
    if (req.maturity_date > today()) {
      throw new AppError(`The hold can only be released on/after the maturity date (${req.maturity_date})`, 'NOT_MATURED');
    }
    const held = Number(req.express_hold_amount);
    const acct = await one<{ hold_amount: Cents }>('SELECT hold_amount FROM savings_account WHERE id = ?', req.savings_account_id);
    await run(
      'UPDATE savings_account SET hold_amount = ?, version = version + 1 WHERE id = ?',
      Math.max((acct?.hold_amount ?? 0) - held, 0), req.savings_account_id,
    );
    await run('UPDATE cheque_deposit SET express_hold_amount = 0 WHERE no = ?', no);
    // The funds are now confirmed — run the member's instructions against them.
    const vd = await resolvePostingDate(user);
    const distributed = await processInstructions(req, user, vd);
    await audit(user, 'CHEQUE_DEPOSIT_RELEASE_HOLD', 'cheque_deposit', no, { released: held, ...distributed });
    return { held };
  });
}

/** The bank returned the cheque unpaid. From Approved: a bouncing charge only (the member never
 *  received the funds). From an express-cleared cheque: also reverse the early credit and release
 *  the hold. A fully-cleared (non-express) cheque cannot be bounced here — raise a reversal. */
export async function bounceChequeDeposit(no: string, reason: string | null, user: Actor): Promise<{ charged: Cents; reversed: boolean }> {
  return tx(async () => {
    const req = await one<ChequeDeposit>('SELECT * FROM cheque_deposit WHERE no = ?', no);
    if (!req) throw new AppError('Cheque deposit not found', 'NOT_FOUND');
    const expressHeld = Number(req.express_hold_amount);
    const fromExpress = req.status === 'Cleared' && expressHeld > 0;
    if (req.status !== 'Approved' && !fromExpress) {
      throw new AppError('Only an approved or express-cleared cheque deposit can be bounced', 'VALIDATION');
    }
    await assertMemberNotDormant(req.member_id, 'a cheque deposit');

    const acct = await accountOwner(req.savings_account_id);
    const amount = Number(req.amount);
    const vd = await resolvePostingDate(user);
    let balance = acct.balance;
    let reversed = false;

    if (fromExpress) {
      // Reverse the early credit and lift the hold.
      const narration = `Cheque deposit ${req.no}${req.cheque_no ? ` (${req.cheque_no})` : ''} bounced — reversing express credit`;
      const j = await postJournal({
        valueDate: vd, module: 'SAVINGS', eventType: 'CHEQUE_DEPOSIT_BOUNCE',
        description: narration, reference: req.no, memberId: req.member_id, user,
        idempotencyKey: `CHEQUE_DEPOSIT-BNC-${req.no}`,
        lines: [
          { account: acct.gl_control_id, debit: amount, credit: 0, narration },
          { account: req.clearing_gl_account_id, debit: 0, credit: amount, narration },
        ],
      });
      balance -= amount;
      await run('UPDATE savings_account SET balance = ?, hold_amount = ?, last_activity = ?, version = version + 1 WHERE id = ?',
        balance, Math.max(acct.hold_amount - expressHeld, 0), vd, req.savings_account_id);
      await run(
        `INSERT INTO txn (txn_ref, value_date, created_at, module, txn_type, member_id, savings_account_id,
           amount, running_balance, channel, description, journal_id, created_by)
         VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?)`,
        await nextSequence('TXN'), vd, new Date().toISOString(), 'SAVINGS', 'WITHDRAWAL', req.member_id,
        req.savings_account_id, -amount, balance, 'CHEQUE', narration, j.id, user.username,
      );
      reversed = true;
    }

    let charged = 0;
    if (req.bouncing_charge_id) {
      const posted = await postTransactionCharges({
        transactionChargeId: req.bouncing_charge_id, baseAmount: amount, debitAccountCode: acct.gl_control_id,
        valueDate: vd, module: 'SAVINGS', eventType: 'CHEQUE_DEPOSIT_BOUNCE_CHARGE', memberId: req.member_id,
        description: `Cheque deposit bouncing charge — ${req.no}`, reference: req.no, user,
        idempotencyKey: `CHEQUE_DEPOSIT-BNCCHG-${req.no}`,
      });
      if (posted) {
        charged = posted.charges.reduce((sum, c) => sum + c.amount, 0);
        const now = await one<{ balance: Cents }>('SELECT balance FROM savings_account WHERE id = ?', req.savings_account_id);
        const nb = (now?.balance ?? balance) - charged;
        await run('UPDATE savings_account SET balance = ?, last_activity = ? WHERE id = ?', nb, vd, req.savings_account_id);
        await run(
          `INSERT INTO txn (txn_ref, value_date, created_at, module, txn_type, member_id, savings_account_id,
             amount, running_balance, channel, description, journal_id, created_by)
           VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?)`,
          await nextSequence('TXN'), vd, new Date().toISOString(), 'SAVINGS', 'FEE', req.member_id,
          req.savings_account_id, -charged, nb, 'CHEQUE', `Cheque deposit bouncing charge — ${req.no}`, posted.journal.id, user.username,
        );
      }
    }

    await run(
      `UPDATE cheque_deposit SET status = 'Bounced', decision_reason = ?, express_hold_amount = 0,
         charge_amount = charge_amount + ?, cleared_by = ?, clearance_date = ? WHERE no = ?`,
      reason?.trim() || null, charged, user.username, vd, no,
    );
    await audit(user, 'CHEQUE_DEPOSIT_BOUNCE', 'cheque_deposit', no, { charged, reversed, reason });
    return { charged, reversed };
  });
}

export const listChequeDepositHistory = (
  no: string,
): Promise<{ journal_no: string; value_date: IsoDate; description: string | null; amount: Cents }[]> =>
  all(
    'SELECT journal_no, value_date, description, amount FROM journal WHERE reference = ? ORDER BY value_date DESC, id DESC',
    no,
  );

export async function getChequeDepositJournal(no: string): Promise<JournalDetail | null> {
  const row = await one<{ journal_id: number | null }>('SELECT journal_id FROM cheque_deposit WHERE no = ?', no);
  if (!row?.journal_id) return null;
  return getJournal(row.journal_id);
}
