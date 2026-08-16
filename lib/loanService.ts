/*
 * Loan origination, appraisal, approval, disbursement and repayment.
 * Per section 11 of the design: the loan module raises business events and the
 * posting engine writes the money. Loan balances are derived from those events.
 */
import {
  one, all, run, tx, nextSequence, audit, hasAnyRow,
} from './db.ts';
import { postJournal } from './accounting.ts';
import { PostingError } from './errors.ts';
import { buildSchedule, allocateRepayment, addMonths, daysBetween, classify } from './loans.ts';
import { CHANNEL_GL } from './savings.ts';
import { findMatchingWorkflow, startWorkflow } from './workflow.ts';
import { buildFilterClause, type FilterCondition, type FilterFieldDef } from './listFilters.ts';
import { buildOrderClause, type SortState } from './listSort.ts';
import { LOAN_STATUSES, INTEREST_METHODS } from './constants.ts';
import type {
  Actor, Appraisal, AppraisalFactor, Cents, Channel, GuarantorRow, IsoDate, JournalLineInput,
  LoanDetail, LoanFull, LoanListRow, LoanProduct, LoanScheduleRow, Member,
  SavingsAccount, Txn, TxnWithDocument,
} from './types.ts';

const today = (): IsoDate => new Date().toISOString().slice(0, 10);

export function getLoan(id: number): Promise<LoanFull | undefined> {
  return one<LoanFull>(
    `SELECT l.*, p.name AS product_name, p.code AS product_code,
            p.gl_receivable_id, p.gl_interest_income_id, p.gl_fee_income_id, p.gl_penalty_income_id,
            m.member_no, m.first_name, m.last_name, m.gross_income, m.other_deductions
     FROM loan l JOIN loan_product p ON p.id = l.product_id
     JOIN member m ON m.id = l.member_id WHERE l.id = ?`,
    id,
  );
}

/** The Loans list's tab keys, and the status each pins down — "all" contributes no filter.
 *  Shared between the list page's tab links and the detail card's Previous/Next, so paging
 *  through a tab never steps outside the status it was opened from. */
export const LOAN_TAB_STATUS: Record<string, string | undefined> = {
  all: undefined,
  open: 'OPEN',
  pending: 'PENDING APPROVAL',
  approved: 'APPROVED',
  disbursed: 'DISBURSED',
  closed: 'CLOSED',
  'written-off': 'WRITTEN OFF',
  archived: 'ARCHIVED',
};

/** Whether the current Status tab has any loans at all, ignoring search and dynamic filters —
 *  lets the page grey out its filter controls only when there's truly nothing to filter. */
export const hasAnyLoans = (status?: string): Promise<boolean> =>
  hasAnyRow('loan l', status ? 'l.status = ?' : undefined, ...(status ? [status] : []));

/** The loan immediately before/after this one by id — for the card's Business-Central-style
 *  Previous/Next navigation. Scoped to `status` (a LOAN_TAB_STATUS value) when given, so paging
 *  never steps outside the tab the record was opened from. */
export async function getAdjacentLoanIds(
  id: number, status?: string,
): Promise<{ prevId: number | null; nextId: number | null }> {
  const clause = status ? 'AND status = ?' : '';
  const prevArgs = status ? [id, status] : [id];
  const nextArgs = status ? [id, status] : [id];
  const [prev, next] = await Promise.all([
    one<{ id: number }>(`SELECT id FROM loan WHERE id < ? ${clause} ORDER BY id DESC LIMIT 1`, ...prevArgs),
    one<{ id: number }>(`SELECT id FROM loan WHERE id > ? ${clause} ORDER BY id ASC LIMIT 1`, ...nextArgs),
  ]);
  return { prevId: prev?.id ?? null, nextId: next?.id ?? null };
}

/** Loans list's dynamic-filter registry — every meaningful column. product_id ships without
 *  `options` since it's DB-driven; the page fills it in from listActiveLoanProducts(), which
 *  it already fetches. Excludes purely internal columns (id, member_id — redundant with the
 *  free-text search, disburse_to_account_id, version — an optimistic-lock counter). */
export const LOAN_FILTER_FIELDS: FilterFieldDef[] = [
  { key: 'loan_no', label: 'Loan No.', type: 'text', column: 'l.loan_no' },
  { key: 'product_id', label: 'Product', type: 'select', column: 'l.product_id' },
  { key: 'interest_rate', label: 'Interest Rate', type: 'number', column: 'l.interest_rate' },
  { key: 'interest_method', label: 'Interest Method', type: 'select', column: 'l.interest_method', options: INTEREST_METHODS.map((m) => ({ value: m, label: m })) },
  { key: 'term_months', label: 'Term (Months)', type: 'number', column: 'l.term_months' },
  { key: 'purpose', label: 'Purpose', type: 'text', column: 'l.purpose' },
  { key: 'status', label: 'Status', type: 'select', column: 'l.status', options: LOAN_STATUSES.map((s) => ({ value: s, label: s })) },
  { key: 'applied_date', label: 'Applied Date', type: 'date', column: 'l.applied_date' },
  { key: 'approved_date', label: 'Approved Date', type: 'date', column: 'l.approved_date' },
  { key: 'approved_by', label: 'Approved By', type: 'text', column: 'l.approved_by' },
  { key: 'rejected_reason', label: 'Rejected Reason', type: 'text', column: 'l.rejected_reason' },
  { key: 'disbursed_date', label: 'Disbursed Date', type: 'date', column: 'l.disbursed_date' },
  { key: 'first_due_date', label: 'First Due Date', type: 'date', column: 'l.first_due_date' },
  { key: 'principal', label: 'Principal', type: 'number', column: 'l.principal' },
  { key: 'installment', label: 'Instalment', type: 'number', column: 'l.installment' },
  { key: 'total_interest', label: 'Total Interest', type: 'number', column: 'l.total_interest' },
  { key: 'fees_charged', label: 'Fees Charged', type: 'number', column: 'l.fees_charged' },
  { key: 'principal_balance', label: 'Principal Balance', type: 'number', column: 'l.principal_balance' },
  { key: 'interest_balance', label: 'Interest Balance', type: 'number', column: 'l.interest_balance' },
  { key: 'penalty_balance', label: 'Penalty Balance', type: 'number', column: 'l.penalty_balance' },
  { key: 'principal_paid', label: 'Principal Paid', type: 'number', column: 'l.principal_paid' },
  { key: 'interest_paid', label: 'Interest Paid', type: 'number', column: 'l.interest_paid' },
  { key: 'arrears_amount', label: 'Arrears', type: 'number', column: 'l.arrears_amount' },
  { key: 'days_in_arrears', label: 'Days in Arrears', type: 'number', column: 'l.days_in_arrears' },
  {
    key: 'classification', label: 'Classification', type: 'select', column: 'l.classification',
    options: ['PERFORMING', 'WATCH', 'SUBSTANDARD', 'DOUBTFUL', 'LOSS'].map((c) => ({ value: c, label: c })),
  },
  { key: 'created_by', label: 'Created By', type: 'text', column: 'l.created_by' },
];

/** Loans list's sortable columns — every column shown in the table. */
const LOAN_SORT_COLUMNS: Record<string, string> = {
  loan_no: 'l.loan_no',
  member: 'm.first_name',
  product_name: 'p.name',
  principal: 'l.principal',
  outstanding: '(l.principal_balance + l.interest_balance)',
  installment: 'l.installment',
  arrears_amount: 'l.arrears_amount',
  status: 'l.status',
  classification: 'l.classification',
};

/** Loans matching a free-text search, further narrowed by any dynamic filter conditions. */
export function listLoans(
  { search = '', filters = [], sort = null }: { search?: string; filters?: FilterCondition[]; sort?: SortState | null } = {},
): Promise<LoanListRow[]> {
  const { clause, params } = buildFilterClause(LOAN_FILTER_FIELDS, filters);
  const orderBy = buildOrderClause(LOAN_SORT_COLUMNS, sort, 'l.id DESC');
  return all<LoanListRow>(
    `SELECT l.*, p.name AS product_name, p.code AS product_code,
            m.member_no, m.first_name, m.last_name
     FROM loan l JOIN loan_product p ON p.id = l.product_id JOIN member m ON m.id = l.member_id
     WHERE (l.loan_no LIKE @like OR m.member_no LIKE @like OR m.first_name LIKE @like OR m.last_name LIKE @like)
       ${clause}
     ${orderBy} LIMIT 300`,
    { like: `%${String(search).trim()}%`, ...params },
  );
}

export async function getLoanDetail(id: number): Promise<LoanDetail | null> {
  const loan = await getLoan(id);
  if (!loan) return null;
  const [schedule, guarantors, transactions] = await Promise.all([
    all<LoanScheduleRow>('SELECT * FROM loan_schedule WHERE loan_id = ? ORDER BY installment_no', id),
    all<GuarantorRow>(
      `SELECT g.*, m.member_no, m.first_name, m.last_name
       FROM loan_guarantor g JOIN member m ON m.id = g.member_id WHERE g.loan_id = ?`,
      id,
    ),
    all<TxnWithDocument>(
      `SELECT t.*, j.reference AS document_no FROM txn t LEFT JOIN journal j ON j.id = t.journal_id
       WHERE t.loan_id = ? ORDER BY t.id DESC`,
      id,
    ),
  ]);
  return { loan, schedule, guarantors, transactions };
}

/** Deposits that count toward the loan multiplier. */
export async function loanableDeposits(memberId: number): Promise<Cents> {
  return (await one<{ s: Cents }>(
    `SELECT COALESCE(SUM(sa.balance),0) s FROM savings_account sa
     JOIN savings_product p ON p.id = sa.product_id
     WHERE sa.member_id = ? AND p.is_loanable_base = 1 AND sa.status <> 'CLOSED'`,
    memberId,
  ))!.s;
}

export async function existingExposure(memberId: number): Promise<Cents> {
  return (await one<{ s: Cents }>(
    `SELECT COALESCE(SUM(principal_balance + interest_balance + penalty_balance),0) s
     FROM loan WHERE member_id = ? AND status = 'DISBURSED'`,
    memberId,
  ))!.s;
}

async function monthlyObligations(memberId: number): Promise<Cents> {
  return (await one<{ s: Cents }>(
    "SELECT COALESCE(SUM(installment),0) s FROM loan WHERE member_id = ? AND status = 'DISBURSED'",
    memberId,
  ))!.s;
}

export interface AppraiseInput {
  memberId: number;
  productId: number;
  principal: Cents;
  termMonths: number;
}

/** Credit appraisal — returns an explainable decision with individual factor results. */
export async function appraise({ memberId, productId, principal, termMonths }: AppraiseInput): Promise<Appraisal> {
  const [member, product, deposits, exposure, obligations] = await Promise.all([
    one<Member>('SELECT * FROM member WHERE id = ?', memberId),
    one<LoanProduct>('SELECT * FROM loan_product WHERE id = ?', productId),
    loanableDeposits(memberId),
    existingExposure(memberId),
    monthlyObligations(memberId),
  ]);
  if (!member) throw new PostingError('Member not found', 'MEMBER_NOT_FOUND');
  if (!product) throw new PostingError('Loan product not found', 'PRODUCT_NOT_FOUND');

  const maxByMultiplier = Math.round(deposits * product.deposit_multiplier);
  const monthsAsMember = member.join_date
    ? Math.floor(daysBetween(member.join_date, today()) / 30.44)
    : 0;
  const { installment } = buildSchedule(
    Math.max(principal, 1), product.interest_rate, Math.max(termMonths, 1), product.interest_method, today(),
  );
  const totalDeductions = obligations + member.other_deductions + installment;
  const dsr = member.gross_income > 0 ? (totalDeductions / member.gross_income) * 100 : 999;

  const factors: AppraisalFactor[] = [
    { code: 'MEMBER_STATUS', label: 'Member in good standing', pass: member.status === 'ACTIVE',
      detail: `Status is ${member.status}` },
    { code: 'KYC', label: 'KYC verified', pass: !!member.kyc_verified,
      detail: member.kyc_verified ? 'Documents verified' : 'KYC not yet verified' },
    { code: 'MEMBERSHIP_PERIOD', label: `Minimum ${product.min_membership_months} months membership`,
      pass: monthsAsMember >= product.min_membership_months, detail: `${monthsAsMember} months as a member` },
    { code: 'PRODUCT_LIMITS', label: 'Within product amount limits',
      pass: principal >= product.min_amount && principal <= product.max_amount,
      detail: `Product range ${(product.min_amount / 100).toLocaleString()} – ${(product.max_amount / 100).toLocaleString()}` },
    { code: 'TERM', label: `Term within ${product.max_term_months} months`,
      pass: termMonths > 0 && termMonths <= product.max_term_months, detail: `${termMonths} months requested` },
    { code: 'DEPOSIT_MULTIPLIER', label: `Within ${product.deposit_multiplier}× deposits`,
      pass: principal <= maxByMultiplier,
      detail: `Deposits ${(deposits / 100).toLocaleString()} → ceiling ${(maxByMultiplier / 100).toLocaleString()}` },
    { code: 'AFFORDABILITY', label: `Deduction ratio ≤ ${product.max_dsr_pct}%`,
      pass: dsr <= product.max_dsr_pct,
      detail: `Total deductions ${(totalDeductions / 100).toLocaleString()} of income ${(member.gross_income / 100).toLocaleString()} = ${dsr.toFixed(1)}%` },
  ];

  const passed = factors.filter((f) => f.pass).length;
  return {
    decision: factors.every((f) => f.pass) ? 'ELIGIBLE' : 'REFERRED',
    score: Math.round((passed / factors.length) * 100),
    factors,
    installment,
    deposits,
    exposure,
    maxByMultiplier,
    dsr: Number(dsr.toFixed(1)),
    monthlyObligations: obligations,
  };
}

export interface ApplyInput extends AppraiseInput {
  purpose?: string | null;
  guarantors?: { memberId: number; amount?: Cents }[];
  disburseToAccountId?: number | null;
  user: Actor;
}

/** Captures a loan application as a draft (status OPEN) — no workflow is required to exist yet;
 *  that's only checked once the applicant actually submits it (see submit() below), mirroring
 *  memberApplications.ts's createMemberApplication()/submitMemberApplication() split. */
export async function apply({
  memberId, productId, principal, termMonths, purpose,
  guarantors = [], disburseToAccountId = null, user,
}: ApplyInput): Promise<LoanFull> {
  principal = Math.round(principal);
  const product = await one<LoanProduct>('SELECT * FROM loan_product WHERE id = ?', productId);
  if (!product) throw new PostingError('Loan product not found', 'PRODUCT_NOT_FOUND');
  if (principal <= 0) throw new PostingError('Loan amount must be greater than zero', 'INVALID_AMOUNT');
  if (termMonths <= 0 || termMonths > product.max_term_months) {
    throw new PostingError(`Term must be between 1 and ${product.max_term_months} months`, 'INVALID_TERM');
  }

  const id = await tx(async () => {
    const loanNo = await nextSequence('LOAN');
    const info = await run(
      `INSERT INTO loan (loan_no, member_id, product_id, principal, interest_rate, interest_method,
         term_months, purpose, status, applied_date, disburse_to_account_id, created_by)
       VALUES (?,?,?,?,?,?,?,?,'OPEN',?,?,?)`,
      loanNo, memberId, productId, principal, product.interest_rate, product.interest_method,
      termMonths, purpose || null, today(), disburseToAccountId || null, user.username,
    );
    const loanId = Number(info.lastInsertRowid);
    for (const g of guarantors) {
      // A member named twice on one application is a duplicate, not an error.
      await run(
        `INSERT INTO loan_guarantor (loan_id, member_id, amount) VALUES (?,?,?)
         ON CONFLICT (loan_id, member_id) DO NOTHING`,
        loanId, g.memberId, Math.round(g.amount || 0),
      );
    }

    return loanId;
  });

  await audit(user, 'LOAN_APPLY', 'loan', id, { principal, termMonths, productId });
  return (await getLoan(id))!;
}

export interface SubmitInput {
  loanId: number;
  user: Actor;
}

/** Sends a captured (OPEN) loan for approval — always requires routing through an admin-defined,
 *  enabled workflow, with no falling back to a flat permission check. Keys passed here must match
 *  RUNTIME_FIELD_CAP.LOAN (lib/workflowConstants.ts) — that cap is what stops an admin from
 *  enabling a Table Relation field here that would never actually match. */
export async function submit({ loanId, user }: SubmitInput): Promise<LoanFull> {
  const loan = await getLoan(loanId);
  if (!loan) throw new PostingError('Loan not found', 'NOT_FOUND');
  if (loan.status !== 'OPEN') throw new PostingError(`Loan is ${loan.status} and cannot be submitted`, 'BAD_STATUS');

  const matched = await findMatchingWorkflow('LOAN', {
    principal: loan.principal, product_id: loan.product_id, term_months: loan.term_months,
  });
  if (!matched) throw new PostingError('There is no enabled workflow for this document', 'NO_WORKFLOW');

  await tx(async () => {
    await run("UPDATE loan SET status='PENDING APPROVAL' WHERE id=?", loanId);
    await startWorkflow(matched.workflow, matched.steps, {
      documentType: 'LOAN', entityId: String(loanId), requestedBy: user.username, amount: loan.principal,
    });
  });

  await audit(user, 'LOAN_SUBMIT', 'loan', loanId, {});
  return (await getLoan(loanId))!;
}

export interface ApproveInput {
  loanId: number;
  user: Actor;
  approve?: boolean;
  reason?: string | null;
}

/** Maker-checker: the approver may not be the applicant. */
export async function approve(
  { loanId, user, approve: decision = true, reason = null }: ApproveInput,
): Promise<LoanFull> {
  const loan = await getLoan(loanId);
  if (!loan) throw new PostingError('Loan not found', 'NOT_FOUND');
  if (loan.status !== 'PENDING APPROVAL') {
    throw new PostingError(`Loan is ${loan.status} and cannot be appraised`, 'BAD_STATUS');
  }
  if (loan.created_by === user.username) {
    throw new PostingError('Segregation of duties: you cannot approve a loan you captured', 'SOD_VIOLATION');
  }
  if (!decision && (!reason || !reason.trim())) {
    throw new PostingError('A reason is required to reject a loan application', 'VALIDATION');
  }

  await tx(async () => {
    if (!decision) {
      // Rejection sends the loan back to OPEN rather than a terminal state — the applicant
      // can amend and resubmit it, the same shape as a self-service cancel-approval pull-back.
      await run(
        "UPDATE loan SET status='OPEN', rejected_reason=?, approved_by=?, approved_date=? WHERE id=?",
        reason, user.username, today(), loanId,
      );
    } else {
      await run(
        "UPDATE loan SET status='APPROVED', approved_by=?, approved_date=? WHERE id=?",
        user.username, today(), loanId,
      );
    }
  });

  await audit(user, decision ? 'LOAN_APPROVE' : 'LOAN_REJECT', 'loan', loanId, { reason });
  return (await getLoan(loanId))!;
}

export interface DisburseInput {
  loanId: number;
  valueDate?: IsoDate;
  channel?: Channel;
  user: Actor;
}

export async function disburse({ loanId, valueDate, channel = 'BANK', user }: DisburseInput): Promise<LoanFull> {
  const loan = await getLoan(loanId);
  if (!loan) throw new PostingError('Loan not found', 'NOT_FOUND');
  if (loan.status !== 'APPROVED') {
    throw new PostingError(`Loan must be APPROVED before disbursement (currently ${loan.status})`, 'BAD_STATUS');
  }
  const product = (await one<LoanProduct>('SELECT * FROM loan_product WHERE id = ?', loan.product_id))!;
  const vd = valueDate || today();
  const firstDue = addMonths(vd, 1);
  const sched = buildSchedule(loan.principal, loan.interest_rate, loan.term_months, loan.interest_method, firstDue);

  const fees = Math.round((loan.principal * product.processing_fee_pct) / 100)
    + Math.round((loan.principal * product.insurance_pct) / 100);

  const target = loan.disburse_to_account_id
    ? await one<SavingsAccount & { gl_control_id: number }>(
        `SELECT sa.*, p.gl_control_id FROM savings_account sa
         JOIN savings_product p ON p.id = sa.product_id WHERE sa.id = ?`,
        loan.disburse_to_account_id,
      )
    : undefined;

  await tx(async () => {
    const lines: JournalLineInput[] = [
      { account: loan.gl_receivable_id, debit: loan.principal, credit: 0, narration: `Disbursement ${loan.loan_no}` },
    ];
    if (target) {
      lines.push({ account: target.gl_control_id, debit: 0, credit: loan.principal, narration: 'Credit to member account' });
      if (fees > 0) {
        lines.push({ account: target.gl_control_id, debit: fees, credit: 0, narration: 'Loan charges recovered' });
        lines.push({ account: loan.gl_fee_income_id, debit: 0, credit: fees, narration: 'Processing fee & insurance' });
      }
    } else {
      lines.push({ account: CHANNEL_GL[channel] || CHANNEL_GL.BANK, debit: 0, credit: loan.principal - fees, narration: 'Net paid out' });
      if (fees > 0) lines.push({ account: loan.gl_fee_income_id, debit: 0, credit: fees, narration: 'Processing fee & insurance' });
    }

    const j = await postJournal({
      valueDate: vd, module: 'LOAN', eventType: 'DISBURSEMENT',
      description: `Loan disbursement ${loan.loan_no}`, reference: loan.loan_no,
      memberId: loan.member_id, user, lines,
    });

    await run('DELETE FROM loan_schedule WHERE loan_id = ?', loanId);
    const INS_SCHEDULE =
      `INSERT INTO loan_schedule (loan_id, installment_no, due_date, opening_balance, principal_due, interest_due)
       VALUES (?,?,?,?,?,?)`;
    for (const r of sched.rows) {
      await run(INS_SCHEDULE, loanId, r.installment_no, r.due_date, r.opening_balance, r.principal_due, r.interest_due);
    }

    await run(
      `UPDATE loan SET status='DISBURSED', disbursed_date=?, first_due_date=?, installment=?,
        total_interest=?, fees_charged=?, principal_balance=?, interest_balance=?, version = version + 1
       WHERE id = ?`,
      vd, firstDue, sched.installment, sched.totalInterest, fees, loan.principal, sched.totalInterest, loanId,
    );

    if (target) {
      const newBal = target.balance + loan.principal - fees;
      await run(
        'UPDATE savings_account SET balance = ?, last_activity = ?, version = version + 1 WHERE id = ?',
        newBal, vd, target.id,
      );
      await run(
        `INSERT INTO txn (txn_ref, value_date, created_at, module, txn_type, member_id,
           savings_account_id, loan_id, amount, running_balance, channel, description, journal_id, created_by)
         VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?)`,
        await nextSequence('TXN'), vd, new Date().toISOString(), 'SAVINGS', 'DISBURSEMENT', loan.member_id,
        target.id, loanId, loan.principal - fees, newBal, 'SYSTEM',
        `Loan ${loan.loan_no} net of charges`, j.id, user.username,
      );
    }

    await run(
      `INSERT INTO txn (txn_ref, value_date, created_at, module, txn_type, member_id, loan_id,
         amount, running_balance, channel, description, journal_id, created_by)
       VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?)`,
      await nextSequence('TXN'), vd, new Date().toISOString(), 'LOAN', 'DISBURSEMENT', loan.member_id, loanId,
      loan.principal, loan.principal, channel, `Disbursement ${loan.loan_no}`, j.id, user.username,
    );
  });

  await audit(user, 'LOAN_DISBURSE', 'loan', loanId, { amount: loan.principal, fees });
  return (await getLoan(loanId))!;
}

export interface RepayInput {
  loanId: number;
  amount: Cents;
  channel?: Channel;
  valueDate?: IsoDate;
  description?: string;
  fromSavingsAccountId?: number | null;
  user: Actor;
  idempotencyKey?: string | null;
}

export interface RepayResult {
  principal: Cents;
  interest: Cents;
  penalty: Cents;
  closed: boolean;
  journal_no: string;
  loan: LoanFull;
}

export async function repay({
  loanId, amount, channel = 'TELLER', valueDate, description,
  fromSavingsAccountId = null, user, idempotencyKey = null,
}: RepayInput): Promise<RepayResult> {
  amount = Math.round(amount);
  if (!(amount > 0)) throw new PostingError('Repayment must be greater than zero', 'INVALID_AMOUNT');
  const loan = await getLoan(loanId);
  if (!loan) throw new PostingError('Loan not found', 'NOT_FOUND');
  if (loan.status !== 'DISBURSED') throw new PostingError(`Loan is ${loan.status}; no repayment due`, 'BAD_STATUS');

  const totalOwed = loan.principal_balance + loan.interest_balance + loan.penalty_balance;
  if (amount > totalOwed) {
    throw new PostingError(
      `Repayment ${(amount / 100).toFixed(2)} exceeds the outstanding balance ${(totalOwed / 100).toFixed(2)}`,
      'OVERPAYMENT',
    );
  }

  const vd = valueDate || today();
  const schedule = await all<LoanScheduleRow>(
    'SELECT * FROM loan_schedule WHERE loan_id = ? ORDER BY installment_no', loanId,
  );

  let source: (SavingsAccount & { gl_control_id: number; min_balance: Cents }) | undefined;
  if (fromSavingsAccountId) {
    source = await one<SavingsAccount & { gl_control_id: number; min_balance: Cents }>(
      `SELECT sa.*, p.gl_control_id, p.min_balance FROM savings_account sa
       JOIN savings_product p ON p.id = sa.product_id WHERE sa.id = ?`,
      fromSavingsAccountId,
    );
    if (!source) throw new PostingError('Source savings account not found', 'ACCOUNT_NOT_FOUND');
    const available = source.balance - source.hold_amount - source.min_balance;
    if (amount > available) {
      throw new PostingError(
        `Insufficient funds in ${source.account_no}. Available ${(available / 100).toFixed(2)}`, 'INSUFFICIENT_FUNDS',
      );
    }
  }

  const res = await tx(async () => {
    let remaining = amount;
    const penaltyPaid = Math.min(loan.penalty_balance, remaining);
    remaining -= penaltyPaid;
    const alloc = allocateRepayment(schedule, remaining);

    const lines: JournalLineInput[] = [
      source
        ? { account: source.gl_control_id, debit: amount, credit: 0, narration: 'Repayment from member account' }
        : { account: CHANNEL_GL[channel] || CHANNEL_GL.TELLER, debit: amount, credit: 0, narration: 'Loan repayment received' },
    ];
    if (penaltyPaid > 0) lines.push({ account: loan.gl_penalty_income_id, debit: 0, credit: penaltyPaid, narration: 'Penalty recovered' });
    if (alloc.interest > 0) lines.push({ account: loan.gl_interest_income_id, debit: 0, credit: alloc.interest, narration: 'Interest income' });
    if (alloc.principal > 0) lines.push({ account: loan.gl_receivable_id, debit: 0, credit: alloc.principal, narration: 'Principal recovered' });
    if (alloc.unallocated > 0) {
      // Nothing left to apply against — treat as principal prepayment.
      lines.push({ account: loan.gl_receivable_id, debit: 0, credit: alloc.unallocated, narration: 'Principal prepayment' });
    }

    const j = await postJournal({
      valueDate: vd, module: 'LOAN', eventType: 'REPAYMENT',
      description: description || `Repayment ${loan.loan_no}`, reference: loan.loan_no,
      memberId: loan.member_id, user, idempotencyKey, lines,
    });

    const UPD_SCHEDULE =
      `UPDATE loan_schedule SET principal_paid = principal_paid + ?, interest_paid = interest_paid + ?,
        status = CASE WHEN principal_paid + ? >= principal_due AND interest_paid + ? >= interest_due
                      THEN 'PAID' ELSE 'PARTIAL' END
       WHERE loan_id = ? AND installment_no = ?`;
    for (const a of alloc.allocations) {
      await run(UPD_SCHEDULE, a.principal, a.interest, a.principal, a.interest, loanId, a.installment_no);
    }

    const principalApplied = alloc.principal + alloc.unallocated;
    const newPrincipal = loan.principal_balance - principalApplied;
    const newInterest = loan.interest_balance - alloc.interest;
    const newPenalty = loan.penalty_balance - penaltyPaid;
    const closed = newPrincipal <= 0 && newInterest <= 0 && newPenalty <= 0;

    await run(
      `UPDATE loan SET principal_balance=?, interest_balance=?, penalty_balance=?,
        principal_paid = principal_paid + ?, interest_paid = interest_paid + ?,
        status = CASE WHEN ? THEN 'CLOSED' ELSE status END, version = version + 1
       WHERE id = ?`,
      newPrincipal, newInterest, newPenalty, principalApplied, alloc.interest, closed, loanId,
    );

    if (source) {
      const newBal = source.balance - amount;
      await run(
        'UPDATE savings_account SET balance=?, last_activity=?, version=version+1 WHERE id=?',
        newBal, vd, source.id,
      );
      await run(
        `INSERT INTO txn (txn_ref, value_date, created_at, module, txn_type, member_id,
           savings_account_id, loan_id, amount, running_balance, channel, description, journal_id, created_by)
         VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?)`,
        await nextSequence('TXN'), vd, new Date().toISOString(), 'SAVINGS', 'REPAYMENT', loan.member_id,
        source.id, loanId, -amount, newBal, 'SYSTEM', `Loan repayment ${loan.loan_no}`, j.id, user.username,
      );
    }

    await run(
      `INSERT INTO txn (txn_ref, value_date, created_at, module, txn_type, member_id, loan_id,
         amount, running_balance, channel, description, journal_id, created_by)
       VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?)`,
      await nextSequence('TXN'), vd, new Date().toISOString(), 'LOAN', 'REPAYMENT', loan.member_id, loanId,
      -amount, newPrincipal, channel,
      `Repayment: principal ${(principalApplied / 100).toFixed(2)}, interest ${(alloc.interest / 100).toFixed(2)}`,
      j.id, user.username,
    );

    return {
      principal: principalApplied,
      interest: alloc.interest,
      penalty: penaltyPaid,
      closed,
      journal_no: j.journal_no,
    };
  });

  await audit(user, 'LOAN_REPAY', 'loan', loanId, { amount, ...res });
  return { ...res, loan: (await getLoan(loanId))! };
}

/** Recompute arrears and SASRA-style classification for every live loan. */
export async function runArrearsAging(asOf?: IsoDate): Promise<{ asOf: IsoDate; loansProcessed: number }> {
  const d = asOf || today();
  const loans = await all<{ id: number }>("SELECT id FROM loan WHERE status = 'DISBURSED'");
  const OVERDUE_FOR =
    `SELECT COALESCE(SUM((principal_due - principal_paid) + (interest_due - interest_paid)),0) amt,
            MIN(due_date) oldest
     FROM loan_schedule WHERE loan_id = ? AND due_date <= ? AND status <> 'PAID'`;
  const UPD = 'UPDATE loan SET arrears_amount=?, days_in_arrears=?, classification=? WHERE id=?';

  const loansProcessed = await tx(async () => {
    let n = 0;
    for (const l of loans) {
      const overdue = (await one<{ amt: Cents; oldest: IsoDate | null }>(OVERDUE_FOR, l.id, d))!;
      const amt = Math.max(overdue.amt || 0, 0);
      const days = amt > 0 && overdue.oldest ? Math.max(daysBetween(overdue.oldest, d), 0) : 0;
      await run(UPD, amt, days, classify(days), l.id);
      n++;
    }
    return n;
  });

  return { asOf: d, loansProcessed };
}
