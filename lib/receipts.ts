/*
 * Receipt — a maker-checker cash-in document (AL Tab52203423/424, Cod52203434.PostReceipt, and
 * the Nation CBS member extension: Enum-Ext52204000, Tab-Ext52204014/15, Cod52204021).
 *
 * The SACCO records money received (by cash, cheque or M-Pesa) into a bank account. The header's
 * Receipt Type fixes what every line may be posted to — a G/L Account receipt takes G/L lines and
 * nothing else — exactly as the AL relates Receipt Lines."Account No" to a different table per
 * Receipt Type.
 *
 * Posting is one journal (Dr the bank account, Cr each line's account), plus whatever a line's own
 * subledger needs: Customer lines write + apply a Payment; Vendor lines a Refund; G/L and Bank
 * lines credit the account directly; Member lines either credit one of the member's savings
 * accounts or repay one of their loans through lib/loanService.ts's repay(), which posts its own
 * journal and so is left out of the receipt's.
 *
 * Lifecycle: Open → Pending Approval → Approved → Posted. A receipt whose amount is below the
 * Receipt Approval Limit (Cash Management Setup) can be posted directly by its creator without a
 * workflow (BC's `Amount < Approval Limit` path); at/above the limit it must be approved.
 */
import { one, all, run, tx, nextSequence, audit, hasAnyRow } from './db.ts';
import { AppError } from './errors.ts';
import { postJournal } from './accounting.ts';
import { sendMail } from './mailer.ts';
import { sendSms } from './sms.ts';
import { formatDate, formatMoney } from './format.ts';
import { repay } from './loanService.ts';
import { postTransactionCharges, previewTransactionChargeById } from './charges.ts';
import { getEffectivePostingRange } from './postingDates.ts';
import { resolveDocCurrency } from './currency.ts';
import { getCashManagementSetup } from './cashMgmtSetup.ts';
import { createCustLedgerEntry, applyCustomerEntries, recomputeCustomerBalance } from './custLedger.ts';
import { createVendorLedgerEntry, applyVendorEntries, recomputeVendorBalance } from './vendLedger.ts';
import { findMatchingWorkflow, findPendingRoutedTask, pickConditionFields, startWorkflow } from './workflow.ts';
import { buildFilterClause, type FilterCondition, type FilterFieldDef } from './listFilters.ts';
import { buildOrderClause, type SortState } from './listSort.ts';
import type {
  Actor, Cents, IsoDate, Member, MemberReceiptAccount, MemberReceiptLoan, ReceiptDetail, ReceiptHeader,
  ReceiptHeaderView, ReceiptLine, ReceiptLineType,
} from './types.ts';

export type ReceiptView = 'open' | 'pending' | 'approved' | 'posted';

const VIEW_CLAUSE: Record<ReceiptView, string> = {
  open: "rh.status = 'Open'",
  pending: "rh.status = 'Pending Approval'",
  approved: "rh.status = 'Approved'",
  posted: 'rh.posted = true',
};

/** AL's Receipt Type, which a receipt's lines all inherit — see resolveLine(). */
const RECEIPT_TYPES: ReceiptLineType[] = ['Member', 'Employee', 'Customer', 'Vendor', 'G/L Account', 'Bank Account'];

const SELECT_ROW = `
  SELECT rh.*, ba.code AS bank_account_code,
         (SELECT COUNT(*) FROM receipt_line l WHERE l.receipt_header_id = rh.id) AS line_count,
         j.journal_no AS journal_no,
         e.employee_no, TRIM(COALESCE(e.first_name, '') || ' ' || COALESCE(e.last_name, '')) AS employee_name
  FROM receipt_header rh
  JOIN bank_account ba ON ba.id = rh.bank_account_id
  LEFT JOIN journal j ON j.id = rh.journal_id
  LEFT JOIN employee e ON e.id = rh.employee_id`;

export const RECEIPT_FILTER_FIELDS: FilterFieldDef[] = [
  { key: 'no', label: 'No.', type: 'text', column: 'rh.no' },
  { key: 'receipt_type', label: 'Type', type: 'select', column: 'rh.receipt_type',
    options: RECEIPT_TYPES.map((v) => ({ value: v, label: v })) },
  { key: 'bank_account_id', label: 'Bank Account', type: 'select', column: 'rh.bank_account_id' },
  { key: 'created_by', label: 'Created By', type: 'text', column: 'rh.created_by' },
];

const SORT_COLUMNS: Record<string, string> = {
  no: 'rh.no', amount: 'rh.amount', status: 'rh.status', created_at: 'rh.created_at',
};

export interface ListReceiptsOptions {
  view?: ReceiptView; search?: string; filters?: FilterCondition[]; sort?: SortState | null;
}

export const listReceipts = (
  { view, search = '', filters = [], sort = null }: ListReceiptsOptions = {},
): Promise<ReceiptHeaderView[]> => {
  const { clause, params } = buildFilterClause(RECEIPT_FILTER_FIELDS, filters);
  const orderBy = buildOrderClause(SORT_COLUMNS, sort, 'rh.no DESC');
  return all<ReceiptHeaderView>(
    `${SELECT_ROW}
     WHERE (rh.no LIKE @like OR rh.description LIKE @like OR rh.external_document_no LIKE @like)
       ${view ? `AND ${VIEW_CLAUSE[view]}` : ''}
       ${clause}
     ${orderBy}`,
    { like: `%${String(search).trim()}%`, ...params },
  );
};

export async function getReceipt(no: string): Promise<ReceiptDetail | undefined> {
  const header = await one<ReceiptHeaderView>(`${SELECT_ROW} WHERE rh.no = ?`, no);
  if (!header) return undefined;
  const lines = await all<ReceiptLine>('SELECT * FROM receipt_line WHERE receipt_header_id = ? ORDER BY line_no', header.id);
  return { ...header, lines };
}

export const hasAnyReceipts = (view?: ReceiptView): Promise<boolean> =>
  hasAnyRow('receipt_header rh', view ? VIEW_CLAUSE[view] : undefined);

/* --------------------------------------------------------------- member lookups */

/**
 * The accounts a Member receipt line may credit — AL's `Vendor where("Account Type" = Sacco|Loan,
 * "Member No." = field("Member No."), "Product Posting Type" <> "Fixed Deposit Account")`.
 *
 * A fixed deposit is excluded because it is funded once, at placement, through its own document;
 * a closed account because nothing can be paid into it. The AL's Loan half of that filter has no
 * equivalent here — this system keeps a loan as its own record rather than mirroring it as an
 * account on a "Loan Account" product, so memberReceiptLoans() offers those separately.
 */
export const memberReceiptAccounts = (memberId: number): Promise<MemberReceiptAccount[]> =>
  all<MemberReceiptAccount>(
    `SELECT sa.id, sa.account_no, sp.name AS product_name, sp.category, sa.balance,
            (sp.category = 'LOAN ACCOUNT') AS is_loan_account
     FROM savings_account sa JOIN savings_product sp ON sp.id = sa.product_id
     WHERE sa.member_id = ? AND sa.status <> 'CLOSED' AND sp.category <> 'FIXED DEPOSIT ACCOUNT'
     ORDER BY sp.category, sa.account_no`,
    memberId,
  );

/**
 * The loans a Member receipt line may repay — AL's `Loans where("Member No." = field, "Loan
 * Balance" > 0, "Loan Account" = field("Account No"))`, with the balances the teller quotes.
 *
 * Accrued interest is AL's GetProratedInterest(): interest that has run since the last accrual but
 * is not yet on the ledger. This system accrues on a schedule rather than pro-rating on demand, so
 * it reports the interest already accrued and outstanding, which is the figure the member owes.
 */
export const memberReceiptLoans = (memberId: number): Promise<MemberReceiptLoan[]> =>
  all<MemberReceiptLoan>(
    `SELECT l.id, l.loan_no, lp.name AS product_name, l.disburse_to_account_id AS savings_account_id,
            l.penalty_balance, l.interest_balance AS accrued_interest, l.interest_balance,
            l.principal_balance,
            (l.principal_balance + l.interest_balance + l.penalty_balance) AS loan_balance
     FROM loan l JOIN loan_product lp ON lp.id = l.product_id
     WHERE l.member_id = ? AND l.status = 'DISBURSED'
       AND (l.principal_balance + l.interest_balance + l.penalty_balance) > 0
     ORDER BY l.days_in_arrears DESC, l.loan_no`,
    memberId,
  );

/**
 * Who may be receipted — AL's `Members where(Status = filter(Active | Dormant | "Not Paid Up"))`.
 * Wider than lib/members.ts's listActiveMembers(), deliberately: paying money in is exactly how a
 * dormant member becomes active again, so refusing them here would trap them.
 */
export const listReceiptMembers = (): Promise<Pick<Member, 'id' | 'member_no' | 'first_name' | 'last_name'>[]> =>
  all<Pick<Member, 'id' | 'member_no' | 'first_name' | 'last_name'>>(
    `SELECT id, member_no, first_name, last_name FROM member
     WHERE status IN ('ACTIVE', 'DORMANT', 'NOT PAID UP') ORDER BY member_no`,
  );

/** The member's own summary, for the header's Member No. lookup. */
export const receiptMemberName = async (memberId: number): Promise<{ member_no: string; name: string } | undefined> =>
  one<{ member_no: string; name: string }>(
    `SELECT member_no,
            TRIM(COALESCE(first_name,'') || ' ' || COALESCE(middle_name,'') || ' ' || COALESCE(last_name,'')) AS name
     FROM member WHERE id = ?`,
    memberId,
  );

/* -------------------------------------------------------------------- create / edit */

export interface ReceiptLineInput {
  /** Ignored on input: a line always takes the header's Receipt Type. Kept so an existing caller
   *  that still sends it is not broken. */
  lineType?: ReceiptLineType;
  accountNo: string;
  description?: string | null;
  amount: Cents;
  appliesToDocNo?: string | null;
  /** Receipt Type = Member only, and exactly one of the two: the member account this line is
   *  deposited into, or the loan it repays. */
  savingsAccountId?: number | null;
  loanId?: number | null;
  /** Whose account or loan this line is for. Defaults to the header's member; set it to take
   *  money for somebody else on the same receipt (a parent paying a child's loan, a group
   *  collection). The header's member stays the document's member of record. */
  memberId?: number | null;
}
export interface ReceiptInput {
  receiptType: ReceiptLineType;
  bankAccountId: number;
  postingDate: IsoDate;
  payModeCode?: string | null;
  externalDocumentNo?: string | null;
  manualReceiptNo?: string | null;
  description: string;
  currencyCode?: string | null;
  /** Receipt Type = Member only. */
  memberId?: number | null;
  /** Receipt Type = Employee only. */
  employeeId?: number | null;
  receivedAmount?: Cents;
  lines: ReceiptLineInput[];
}

async function loadBank(id: number): Promise<{ id: number; code: string; name: string; gl_account_id: number; currency_code: string; status: string }> {
  const ba = await one<{ id: number; code: string; name: string; gl_account_id: number; currency_code: string; status: string }>(
    'SELECT id, code, name, gl_account_id, currency_code, status FROM bank_account WHERE id = ?', id,
  );
  if (!ba) throw new AppError('Bank account not found', 'NOT_FOUND');
  if (ba.status !== 'ACTIVE') throw new AppError('That bank account is not active', 'VALIDATION');
  return ba;
}

/** Everything a resolved line contributes beyond what the user typed. */
interface ResolvedLine {
  accountName: string;
  memberId: number | null;
  savingsAccountId: number | null;
  loanId: number | null;
  productCategory: string | null;
  penaltyBalance: Cents;
  accruedInterest: Cents;
  interestBalance: Cents;
  principalBalance: Cents;
  loanBalance: Cents;
  chargeId: number | null;
  chargeAmount: Cents;
}

const BLANK_RESOLVED: Omit<ResolvedLine, 'accountName'> = {
  memberId: null, savingsAccountId: null, loanId: null, productCategory: null,
  penaltyBalance: 0, accruedInterest: 0, interestBalance: 0, principalBalance: 0, loanBalance: 0,
  chargeId: null, chargeAmount: 0,
};

/**
 * Validates one line against the header's Receipt Type and fills in everything derived.
 *
 * The type is the header's, never the line's own — AL relates Receipt Lines."Account No" to a
 * different table per `"Receipt Type"`, which is the header's field, so a G/L Account receipt can
 * only ever hold G/L lines.
 */
async function resolveLine(
  input: ReceiptLineInput, lineType: ReceiptLineType, currencyCode: string,
  header: { memberId: number | null; employeeId?: number | null; postingDate: IsoDate },
): Promise<ResolvedLine> {
  if (!(input.amount > 0)) throw new AppError('Every line needs an amount greater than zero', 'VALIDATION');

  // Money in from a member of staff: the line's account is the header's employee, and an
  // Applies-to Doc. No. may name the imprest it settles.
  if (lineType === 'Employee') {
    if (!header.employeeId) throw new AppError('Pick the employee this receipt is from', 'VALIDATION');
    const e = await one<{ id: number; employee_no: string; first_name: string; last_name: string }>('SELECT id, employee_no, first_name, last_name FROM employee WHERE id = ?', header.employeeId);
    if (!e) throw new AppError('Employee not found', 'NOT_FOUND');
    const ref = input.appliesToDocNo?.trim();
    if (ref) {
      const imp = await one<{ employee_id: number }>('SELECT employee_id FROM imprest_request WHERE no = ?', ref);
      if (!imp) throw new AppError(`Imprest request ${ref} not found`, 'NOT_FOUND');
      if (imp.employee_id !== e.id) throw new AppError(`Imprest ${ref} does not belong to ${e.employee_no}`, 'VALIDATION');
    }
    return { ...BLANK_RESOLVED, accountName: `${e.first_name} ${e.last_name}` };
  }

  if (lineType === 'Member') {
    if (!header.memberId) throw new AppError('Pick the member this receipt is for', 'VALIDATION');
    if (!input.savingsAccountId && !input.loanId) {
      throw new AppError('Every line needs a member account or a loan to pay into', 'VALIDATION');
    }
    if (input.savingsAccountId && input.loanId) {
      throw new AppError('A line pays into an account or off a loan, not both', 'VALIDATION');
    }
    // The line's own member, defaulting to the header's — one receipt can take money for several
    // members, while the header's member remains who the receipt is issued to.
    const lineMemberId = Number(input.memberId ?? header.memberId);

    // A loan repayment. The AL reaches the loan through a Vendor record on a "Loan Account"
    // product; here a loan is its own record and is picked directly, which is the same choice the
    // teller makes and one fewer thing to keep in step.
    if (input.loanId) {
      const loan = await one<{
        id: number; loan_no: string; member_id: number; status: string; product_name: string;
        penalty_balance: Cents; interest_balance: Cents; principal_balance: Cents;
      }>(
        `SELECT l.id, l.loan_no, l.member_id, l.status, lp.name AS product_name,
                l.penalty_balance, l.interest_balance, l.principal_balance
         FROM loan l JOIN loan_product lp ON lp.id = l.product_id WHERE l.id = ?`,
        input.loanId,
      );
      if (!loan) throw new AppError('Loan not found', 'NOT_FOUND');
      if (Number(loan.member_id) !== lineMemberId) {
        throw new AppError(`Loan ${loan.loan_no} does not belong to the member on this line`, 'VALIDATION');
      }
      if (loan.status !== 'DISBURSED') throw new AppError(`Loan ${loan.loan_no} is ${loan.status} — nothing to repay`, 'VALIDATION');

      const owed = Number(loan.principal_balance) + Number(loan.interest_balance) + Number(loan.penalty_balance);
      const setup = await getCashManagementSetup();
      // AL: the repayment charge comes off the line first, and only what is left reaches the loan —
      // so the member is never told they cleared more than they did.
      const charge = setup.loan_repayment_charge_id
        ? (await previewTransactionChargeById(setup.loan_repayment_charge_id, input.amount))
          .reduce((sum, c) => sum + c.amount, 0)
        : 0;
      if (charge >= input.amount) {
        throw new AppError(`The repayment charge (${charge / 100}) leaves nothing for loan ${loan.loan_no}`, 'VALIDATION');
      }
      if (input.amount - charge > owed && !setup.unallocated_product_id) {
        throw new AppError(
          `${(input.amount - charge) / 100} exceeds what loan ${loan.loan_no} still owes (${owed / 100}). `
          + 'Reduce the line, or set an Unallocated Product on Cash Management Setup to hold the balance.',
          'VALIDATION',
        );
      }
      return {
        ...BLANK_RESOLVED,
        accountName: `${loan.loan_no} — ${loan.product_name}`,
        memberId: lineMemberId,
        loanId: loan.id,
        // AL's Product Posting Type for a loan line.
        productCategory: 'LOAN ACCOUNT',
        penaltyBalance: Number(loan.penalty_balance),
        accruedInterest: Number(loan.interest_balance),
        interestBalance: Number(loan.interest_balance),
        principalBalance: Number(loan.principal_balance),
        loanBalance: owed,
        chargeId: setup.loan_repayment_charge_id,
        chargeAmount: charge,
      };
    }

    // A deposit into one of the member's own accounts.
    const acc = await one<{
      id: number; account_no: string; member_id: number; status: string; category: string; product_name: string;
    }>(
      `SELECT sa.id, sa.account_no, sa.member_id, sa.status, sp.category, sp.name AS product_name
       FROM savings_account sa JOIN savings_product sp ON sp.id = sa.product_id WHERE sa.id = ?`,
      input.savingsAccountId,
    );
    if (!acc) throw new AppError('Member account not found', 'NOT_FOUND');
    if (Number(acc.member_id) !== lineMemberId) {
      throw new AppError(`Account ${acc.account_no} does not belong to the member on this line`, 'VALIDATION');
    }
    if (acc.status === 'CLOSED') throw new AppError(`Account ${acc.account_no} is closed`, 'VALIDATION');
    if (acc.status === 'FROZEN') throw new AppError(`Account ${acc.account_no} is frozen`, 'VALIDATION');
    if (acc.category === 'FIXED DEPOSIT ACCOUNT') {
      throw new AppError('A fixed deposit is funded through its own document, not a receipt', 'VALIDATION');
    }
    return {
      ...BLANK_RESOLVED,
      accountName: `${acc.account_no} — ${acc.product_name}`,
      memberId: lineMemberId,
      savingsAccountId: acc.id,
      productCategory: acc.category,
    };
  }

  if (!input.accountNo?.trim()) throw new AppError(`A ${lineType} is required on every line`, 'VALIDATION');
  const no = input.accountNo.trim();
  if (lineType === 'Customer') {
    const c = await one<{ name: string; blocked: string; currency_code: string | null }>('SELECT name, blocked, currency_code FROM customer WHERE no = ?', no);
    if (!c) throw new AppError(`Customer ${no} not found`, 'NOT_FOUND');
    if (c.blocked === 'All') throw new AppError(`Customer ${no} is blocked`, 'VALIDATION');
    return { ...BLANK_RESOLVED, accountName: c.name };
  }
  if (lineType === 'Vendor') {
    const v = await one<{ name: string; blocked: string }>('SELECT name, blocked FROM vendor WHERE no = ?', no);
    if (!v) throw new AppError(`Vendor ${no} not found`, 'NOT_FOUND');
    return { ...BLANK_RESOLVED, accountName: v.name };
  }
  if (lineType === 'Bank Account') {
    const b = await one<{ name: string; currency_code: string }>('SELECT name, currency_code FROM bank_account WHERE code = ?', no);
    if (!b) throw new AppError(`Bank account ${no} not found`, 'NOT_FOUND');
    if (b.currency_code !== currencyCode) throw new AppError('An inter-bank line must be in the same currency as the receipt', 'VALIDATION');
    return { ...BLANK_RESOLVED, accountName: b.name };
  }
  const acc = await one<{ name: string; is_postable: number; status: string; no_direct_posting: number }>(
    'SELECT name, is_postable, status, no_direct_posting FROM gl_account WHERE code = ?', no,
  );
  if (!acc || !acc.is_postable || acc.status !== 'ACTIVE') throw new AppError(`G/L account ${no} is not an active posting account`, 'VALIDATION');
  if (acc.no_direct_posting) throw new AppError(`G/L account ${no} is a subledger control account`, 'VALIDATION');
  return { ...BLANK_RESOLVED, accountName: acc.name };
}
/**
 * The Payment Method a cash document was settled by — a real relation to the Setup Pool table,
 * not free text, so a code that was renamed or blocked cannot quietly stay on new documents.
 * Blank is allowed: not every receipt or voucher records how the money moved.
 */
async function assertPaymentMethod(code: string | null | undefined): Promise<string | null> {
  const value = code?.trim();
  if (!value) return null;
  const m = await one<{ code: string; status: string }>(
    'SELECT code, status FROM payment_method WHERE code = ?', value,
  );
  if (!m) throw new AppError(`Payment method ${value} is not defined`, 'NOT_FOUND');
  if (m.status !== 'ACTIVE') throw new AppError(`Payment method ${value} is not active`, 'VALIDATION');
  return m.code;
}

export async function createReceipt(input: ReceiptInput, user: Actor): Promise<{ no: string }> {
  if (!input.postingDate) throw new AppError('A posting date is required', 'VALIDATION');
  if (!input.description?.trim()) throw new AppError('A description (received from) is required', 'VALIDATION');
  if (!RECEIPT_TYPES.includes(input.receiptType)) throw new AppError('Invalid receipt type', 'VALIDATION');
  const member = await resolveHeaderMember(input);
  const employeeId = await resolveHeaderEmployee(input);
  const payMode = await assertPaymentMethod(input.payModeCode);
  const bank = await loadBank(input.bankAccountId);
  const cur = await resolveDocCurrency(input.currencyCode ?? bank.currency_code, input.postingDate);
  if (cur.code !== bank.currency_code) throw new AppError(`The receipt is in ${cur.code} but bank account ${bank.code} is a ${bank.currency_code} account`, 'VALIDATION');
  // The approval threshold is General Ledger Setup's, stamped onto the header so a limit changed
  // later cannot retrospectively change what an existing receipt needed.
  const org = await one<{ receipt_approval_limit: Cents }>(
    'SELECT receipt_approval_limit FROM organisation LIMIT 1',
  );
  const no = await nextSequence('RECEIPT');
  return tx(async () => {
    const info = await run(
      `INSERT INTO receipt_header
         (no, receipt_type, posting_date, bank_account_id, bank_account_name, pay_mode_code, external_document_no, manual_receipt_no,
          description, currency_code, currency_factor, approval_limit, member_id, member_no, member_name, received_amount,
          employee_id, created_at, created_by)
       VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)`,
      no, input.receiptType, input.postingDate, bank.id, bank.name, payMode, input.externalDocumentNo?.trim() || null,
      input.manualReceiptNo?.trim() || null, input.description.trim(), cur.code, cur.factor,
      org?.receipt_approval_limit ?? 0, member?.id ?? null, member?.member_no ?? null, member?.name ?? null,
      Math.round(input.receivedAmount ?? 0), employeeId, new Date().toISOString(), user.username,
    );
    await replaceLines(Number(info.lastInsertRowid), input, cur.code);
    await audit(user, 'RECEIPT_CREATE', 'receipt_header', no, { lineCount: input.lines.length, type: input.receiptType });
    return { no };
  });
}

export async function updateReceipt(no: string, input: ReceiptInput, user: Actor): Promise<void> {
  const before = await one<ReceiptHeader>('SELECT * FROM receipt_header WHERE no = ?', no);
  if (!before) throw new AppError('Receipt not found', 'NOT_FOUND');
  if (before.status !== 'Open') throw new AppError('Only an open receipt can be edited', 'VALIDATION');
  if (before.created_by !== user.username) throw new AppError('Only the person who created this can edit it', 'NOT_CREATOR');
  if (!RECEIPT_TYPES.includes(input.receiptType)) throw new AppError('Invalid receipt type', 'VALIDATION');
  const member = await resolveHeaderMember(input);
  const employeeId = await resolveHeaderEmployee(input);
  const payMode = await assertPaymentMethod(input.payModeCode);
  const bank = await loadBank(input.bankAccountId);
  const cur = await resolveDocCurrency(input.currencyCode ?? before.currency_code, input.postingDate);
  if (cur.code !== bank.currency_code) throw new AppError('The receipt currency must match the bank account currency', 'VALIDATION');
  await tx(async () => {
    await run(
      `UPDATE receipt_header SET receipt_type = ?, posting_date = ?, bank_account_id = ?, bank_account_name = ?, pay_mode_code = ?,
         external_document_no = ?, manual_receipt_no = ?, description = ?, currency_code = ?, currency_factor = ?,
         member_id = ?, member_no = ?, member_name = ?, received_amount = ?, employee_id = ? WHERE id = ?`,
      input.receiptType, input.postingDate, bank.id, bank.name, payMode, input.externalDocumentNo?.trim() || null,
      input.manualReceiptNo?.trim() || null, input.description.trim(), cur.code, cur.factor,
      member?.id ?? null, member?.member_no ?? null, member?.name ?? null, Math.round(input.receivedAmount ?? 0), employeeId, before.id,
    );
    await replaceLines(before.id, input, cur.code);
  });
  await audit(user, 'RECEIPT_UPDATE', 'receipt_header', no, {});
}

/** The employee an Employee receipt is from; cleared whenever the type is anything else. */
async function resolveHeaderEmployee(input: ReceiptInput): Promise<number | null> {
  if (input.receiptType !== 'Employee') return null;
  if (!input.employeeId) throw new AppError('Pick the employee this receipt is from', 'VALIDATION');
  const e = await one<{ id: number }>('SELECT id FROM employee WHERE id = ?', input.employeeId);
  if (!e) throw new AppError('Employee not found', 'NOT_FOUND');
  return e.id;
}

/** AL Tab-Ext52204014's Member No. OnValidate — the name follows the number. */
async function resolveHeaderMember(
  input: ReceiptInput,
): Promise<{ id: number; member_no: string; name: string } | null> {
  if (input.receiptType !== 'Member') return null;
  if (!input.memberId) throw new AppError('Pick the member this receipt is for', 'VALIDATION');
  const m = await one<{ id: number; member_no: string; name: string; status: string }>(
    `SELECT id, member_no, status,
            TRIM(COALESCE(first_name,'') || ' ' || COALESCE(middle_name,'') || ' ' || COALESCE(last_name,'')) AS name
     FROM member WHERE id = ?`,
    input.memberId,
  );
  if (!m) throw new AppError('Member not found', 'NOT_FOUND');
  // AL: `TableRelation = Members where(Status = filter(Active | Dormant | "Not Paid Up"))`.
  if (!['ACTIVE', 'DORMANT', 'NOT PAID UP'].includes(m.status)) {
    throw new AppError(`Member ${m.member_no} is ${m.status} and cannot be receipted`, 'VALIDATION');
  }
  return { id: m.id, member_no: m.member_no, name: m.name.split(' ').filter(Boolean).join(' ') };
}

async function replaceLines(headerId: number, input: ReceiptInput, currencyCode: string): Promise<void> {
  await run('DELETE FROM receipt_line WHERE receipt_header_id = ?', headerId);
  const lineType = input.receiptType;
  const isMember = lineType === 'Member';
  let lineNo = 10000;
  let total = 0;
  for (const l of input.lines) {
    const isEmployee = lineType === 'Employee';
    const hasAccount = isMember ? !!(l.savingsAccountId || l.loanId) : isEmployee ? !!input.employeeId : !!l.accountNo?.trim();
    // A blank row the user never filled in is dropped; one carrying money but no account is
    // refused, so a line can never be silently lost between the form and the document.
    if (!hasAccount && !(l.amount > 0)) continue;
    if (!hasAccount) {
      throw new AppError(
        isMember
          ? 'A line has an amount but no member account or loan to pay it into'
          : `A line has an amount but no ${lineType} — this receipt posts to ${lineType} only`,
        'VALIDATION',
      );
    }
    if (!(l.amount > 0)) continue;
    const r = await resolveLine(l, lineType, currencyCode, {
      memberId: input.memberId ?? null, employeeId: input.employeeId ?? null, postingDate: input.postingDate,
    });
    const employeeNo = isEmployee ? (await one<{ employee_no: string }>('SELECT employee_no FROM employee WHERE id = ?', input.employeeId))?.employee_no ?? null : null;
    // AL Tab-Ext52204015: a line always carries a description, defaulted from the header —
    // 'Member Receipt' on a member receipt, the header's own narration otherwise. The form asks
    // for one; this is the backstop, so a posted line can never print blank.
    const description = l.description?.trim()
      || (isMember ? 'Member Receipt' : input.description.trim());
    if (!description) throw new AppError('Every receipt line needs a description', 'VALIDATION');
    total += Math.round(l.amount);
    await run(
      `INSERT INTO receipt_line
         (receipt_header_id, line_no, line_type, account_no, account_name, description, amount, applies_to_doc_no,
          member_id, savings_account_id, loan_id, product_category, penalty_balance, accrued_interest,
          interest_balance, principal_balance, loan_balance, charge_id, charge_amount)
       VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)`,
      headerId, lineNo, lineType, employeeNo ?? (l.accountNo?.trim() || null), r.accountName, description,
      Math.round(l.amount), l.appliesToDocNo?.trim() || null,
      r.memberId, r.savingsAccountId, r.loanId, r.productCategory, r.penaltyBalance, r.accruedInterest,
      r.interestBalance, r.principalBalance, r.loanBalance, r.chargeId, r.chargeAmount,
    );
    lineNo += 10000;
  }
  await run('UPDATE receipt_header SET amount = ? WHERE id = ?', total, headerId);
}

export async function deleteReceipt(no: string, user: Actor): Promise<void> {
  const before = await one<Pick<ReceiptHeader, 'status' | 'created_by'>>('SELECT status, created_by FROM receipt_header WHERE no = ?', no);
  if (!before) throw new AppError('Receipt not found', 'NOT_FOUND');
  if (before.status !== 'Open') throw new AppError('Only an open receipt can be deleted', 'VALIDATION');
  if (before.created_by !== user.username) throw new AppError('Only the person who created this can delete it', 'NOT_CREATOR');
  await run('DELETE FROM receipt_header WHERE no = ?', no);
  await audit(user, 'RECEIPT_DELETE', 'receipt_header', no, {});
}

/* --------------------------------------------------------------- maker-checker */

/**
 * AL Tab-Ext52204014's OnBeforeSendForApproval: the lines must add up to what was received.
 *
 * This is the control total for the whole document — it matters most on a member receipt, where
 * the lines may be spread across several members' accounts and loans and a miskeyed one would
 * otherwise be invisible. A Received Amount of zero means it was never captured, which is still
 * allowed on the types that have no cash drawer behind them.
 */
function assertReceivedAmountAgrees(header: ReceiptHeader): void {
  if (header.receipt_type === 'Member' && !header.received_amount) {
    throw new AppError('Enter the amount received from the member', 'VALIDATION');
  }
  if (header.received_amount && header.received_amount !== header.amount) {
    throw new AppError(
      `The lines total ${header.amount / 100} but ${header.received_amount / 100} was received — `
      + 'they must agree before this receipt can go any further.',
      'VALIDATION',
    );
  }
}

export async function submitReceipt(no: string, user: Actor): Promise<{ autoApproved: boolean }> {
  const req = await one<ReceiptHeader>('SELECT * FROM receipt_header WHERE no = ?', no);
  if (!req) throw new AppError('Receipt not found', 'NOT_FOUND');
  if (req.status !== 'Open') throw new AppError('Only an open receipt can be submitted', 'VALIDATION');
  if (req.amount <= 0) throw new AppError('Add at least one receipt line before submitting', 'VALIDATION');
  assertReceivedAmountAgrees(req);
  const matched = await findMatchingWorkflow('RECEIPT', await pickConditionFields('RECEIPT', req));
  if (!matched) throw new AppError('There is no enabled workflow for this document', 'NO_WORKFLOW');
  await tx(async () => {
    await run("UPDATE receipt_header SET status = 'Pending Approval' WHERE no = ?", no);
    await startWorkflow(matched.workflow, matched.steps, {
      documentType: 'RECEIPT', entityId: no, requestedBy: user.username, amount: Number(req.amount),
    });
  });
  const after = await one<{ status: string }>('SELECT status FROM receipt_header WHERE no = ?', no);
  return { autoApproved: after?.status === 'Approved' };
}

export async function cancelReceiptApproval(no: string, user: Actor): Promise<void> {
  const req = await one<Pick<ReceiptHeader, 'status' | 'created_by'>>('SELECT status, created_by FROM receipt_header WHERE no = ?', no);
  if (!req) throw new AppError('Receipt not found', 'NOT_FOUND');
  if (req.status !== 'Pending Approval') throw new AppError('Only a receipt pending approval can be recalled', 'VALIDATION');
  const routed = await findPendingRoutedTask('RECEIPT', no);
  if ((routed?.requested_by ?? req.created_by) !== user.username) throw new AppError('Only the person who submitted this can recall it', 'NOT_REQUESTER');
  await run("UPDATE receipt_header SET status = 'Open' WHERE no = ?", no);
  await audit(user, 'RECEIPT_CANCEL_APPROVAL', 'receipt_header', no, {});
}

export async function approveReceipt(no: string, user: Actor): Promise<void> {
  const req = await one<ReceiptHeader>('SELECT * FROM receipt_header WHERE no = ?', no);
  if (!req) throw new AppError('Receipt not found', 'NOT_FOUND');
  if (req.status !== 'Pending Approval') throw new AppError('Only a receipt pending approval can be approved', 'VALIDATION');
  await run("UPDATE receipt_header SET status = 'Approved', decision_reason = NULL WHERE no = ?", no);
  await audit(user, 'RECEIPT_APPROVE', 'receipt_header', no, {});
}

export async function rejectReceipt(no: string, reason: string | null, user: Actor): Promise<void> {
  if (!reason?.trim()) throw new AppError('A reason is required to reject a receipt', 'VALIDATION');
  const req = await one<ReceiptHeader>('SELECT * FROM receipt_header WHERE no = ?', no);
  if (!req) throw new AppError('Receipt not found', 'NOT_FOUND');
  if (req.status !== 'Pending Approval') throw new AppError('Only a receipt pending approval can be rejected', 'VALIDATION');
  await run("UPDATE receipt_header SET status = 'Open', decision_reason = ? WHERE no = ?", reason, no);
  await audit(user, 'RECEIPT_REJECT', 'receipt_header', no, { reason });
}

export async function reopenReceipt(no: string, user: Actor): Promise<void> {
  const req = await one<ReceiptHeader>('SELECT * FROM receipt_header WHERE no = ?', no);
  if (!req) throw new AppError('Receipt not found', 'NOT_FOUND');
  if (req.status !== 'Approved' || req.posted) throw new AppError('Only an approved, unposted receipt can be reopened', 'VALIDATION');
  await run("UPDATE receipt_header SET status = 'Open' WHERE no = ?", no);
  await audit(user, 'RECEIPT_REOPEN', 'receipt_header', no, {});
}

/** A member account credit queued while the receipt's journal is being assembled — written once
 *  the journal exists, so every ledger entry points at it. */
interface MemberCredit {
  accountId: number;
  memberId: number;
  amount: Cents;
  narration: string;
}

/**
 * A Member receipt line that repays a loan — AL PostReceipt's Member branch.
 *
 * The AL hand-allocates penalty → interest → principal and writes the journal lines itself. Here
 * the repayment goes through lib/loanService.ts's repay() instead, funded straight from the bank
 * account the receipt was taken into: that is the one engine that owns the loan schedule, arrears
 * and interest/principal allocation, and it allocates penalty-first exactly as the AL does. It
 * posts its own journal, so a loan line is deliberately kept out of the receipt's own journal
 * rather than debiting the bank twice for the same money.
 *
 * Returns whatever is left after the charge and the loan are satisfied, for the caller to park.
 */
async function postMemberLoanLine(
  header: ReceiptHeader, line: ReceiptLine, bankGlAccountId: number, vd: IsoDate, user: Actor,
): Promise<{ repaid: Cents; charged: Cents; unallocated: Cents }> {
  const setup = await getCashManagementSetup();
  const loan = await one<{ id: number; loan_no: string; status: string; owed: Cents }>(
    `SELECT id, loan_no, status, (principal_balance + interest_balance + penalty_balance) AS owed
     FROM loan WHERE id = ?`, line.loan_id!,
  );
  if (!loan) throw new AppError('Loan not found', 'NOT_FOUND');
  if (loan.status !== 'DISBURSED') throw new AppError(`Loan ${loan.loan_no} is ${loan.status} — nothing to repay`, 'VALIDATION');

  // Recomputed from the live setup rather than trusting the snapshot taken when the line was
  // captured, so the G/L split always matches how the Transaction Charge is configured now.
  let charged = 0;
  if (setup.loan_repayment_charge_id) {
    const posted = await postTransactionCharges({
      transactionChargeId: setup.loan_repayment_charge_id, baseAmount: line.amount,
      debitAccountCode: bankGlAccountId, valueDate: vd, module: 'CASH_MGMT',
      eventType: 'LOAN_REPAYMENT_CHARGE', memberId: line.member_id,
      description: `Receipt ${header.no} — loan repayment charge`, reference: header.no, user,
      idempotencyKey: `RECEIPT-CHG-${header.no}-${line.id}`,
    });
    if (posted) charged = posted.charges.reduce((sum, c) => sum + c.amount, 0);
  }

  const available = line.amount - charged;
  const repaid = Math.min(available, Number(loan.owed));
  if (repaid > 0) {
    await repay({
      loanId: loan.id, amount: repaid, valueDate: vd, channel: 'SYSTEM',
      bankAccountId: header.bank_account_id,
      description: `Receipt ${header.no} — ${loan.loan_no}`,
      idempotencyKey: `RECEIPT-REP-${header.no}-${line.id}`, user,
    });
  }
  return { repaid, charged, unallocated: available - repaid };
}

/**
 * Where a loan overpayment goes — AL parks it in another of the member's accounts rather than
 * refusing the money. Which account is a policy choice, so it is configured (Cash Management
 * Setup → Unallocated Product) instead of being hard-wired to AL's School Fee Account.
 */
async function unallocatedAccountFor(memberId: number, productId: number | null): Promise<number> {
  if (!productId) {
    throw new AppError(
      'This line pays more than the loan owes. Reduce it, or set an Unallocated Product on Cash '
      + 'Management Setup for the balance to be held in.',
      'VALIDATION',
    );
  }
  const holding = await one<{ id: number }>(
    `SELECT id FROM savings_account
     WHERE member_id = ? AND product_id = ? AND status <> 'CLOSED' ORDER BY id LIMIT 1`,
    memberId, productId,
  );
  if (!holding) {
    throw new AppError(
      'This line pays more than the loan owes, and the member has no account on the Unallocated '
      + 'Product to hold the balance. Reduce the line, or open one for them.',
      'VALIDATION',
    );
  }
  return holding.id;
}

/**
 * Credits one of the member's accounts and writes the ledger entry behind it.
 *
 * Posted directly rather than through lib/savings.ts's deposit(), because that raises its own
 * journal against a channel G/L account while a receipt has already decided which bank account the
 * money went into — the receipt's own journal carries the matching credit to the product's control
 * account. A credit also wakes a dormant account, exactly as a counter deposit does.
 */
async function writeMemberCredit(
  header: ReceiptHeader, credit: MemberCredit, vd: IsoDate, journalId: number, user: Actor,
): Promise<void> {
  const acct = await one<{ balance: Cents }>('SELECT balance FROM savings_account WHERE id = ?', credit.accountId);
  const next = Number(acct?.balance ?? 0) + credit.amount;
  await run(
    `UPDATE savings_account SET balance = ?, last_activity = ?, version = version + 1,
       status = CASE WHEN status = 'DORMANT' THEN 'ACTIVE' ELSE status END WHERE id = ?`,
    next, vd, credit.accountId,
  );
  await run(
    `INSERT INTO txn (txn_ref, value_date, created_at, module, txn_type, member_id, savings_account_id,
       amount, running_balance, channel, description, journal_id, bank_account_id, created_by)
     VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?)`,
    await nextSequence('TXN'), vd, new Date().toISOString(), 'SAVINGS', 'DEPOSIT', credit.memberId,
    credit.accountId, credit.amount, next, 'TELLER', credit.narration.slice(0, 250), journalId,
    header.bank_account_id, user.username,
  );
}

/** The deposit control account a member credit lands on. */
const controlAccountFor = async (accountId: number): Promise<number> => {
  const row = await one<{ gl_control_id: number }>(
    `SELECT sp.gl_control_id FROM savings_account sa JOIN savings_product sp ON sp.id = sa.product_id
     WHERE sa.id = ?`, accountId,
  );
  if (!row?.gl_control_id) throw new AppError('That savings product has no G/L control account', 'VALIDATION');
  return Number(row.gl_control_id);
};

/* ----------------------------------------------------------- member notification */

/**
 * Tells the member their receipt has posted, by e-mail and SMS — AL's own
 * `CommunicationMgmt` / `NotificationsMgt.SendSms` after posting.
 *
 * It goes to the member on the **header**, not to each line's member: a line may be for somebody
 * else's account (a parent paying a child's loan), but the receipt is issued to one person, and
 * that is who holds it and who is told about it.
 *
 * Never throws. The money has already moved and the document is already posted by the time this
 * runs; a gateway that is down must not undo any of that.
 */
async function notifyMemberOfReceipt(header: ReceiptHeader, lines: ReceiptLine[]): Promise<void> {
  try {
    if (header.receipt_type !== 'Member' || !header.member_id) return;
    const member = await one<{ first_name: string; phone: string | null; email: string | null }>(
      'SELECT first_name, phone, email FROM member WHERE id = ?', header.member_id,
    );
    if (!member) return;
    const org = await one<{ name: string }>('SELECT name FROM organisation LIMIT 1');
    const sacco = org?.name ?? 'your SACCO';
    const total = formatMoney(header.amount, { symbol: header.currency_code });

    const detail = lines.map((l) => `${l.description || l.account_name}: `
      + formatMoney(l.amount, { symbol: header.currency_code }));

    if (member.phone) {
      await sendSms({
        to: member.phone,
        source: 'RECEIPT',
        message: `Dear ${member.first_name}, we have received ${total} on receipt ${header.no}`
          + ` dated ${formatDate(header.posting_date)}. ${detail.slice(0, 2).join('; ')}.`
          + ` Thank you — ${sacco}.`,
      });
    }
    if (member.email) {
      await sendMail({
        to: member.email,
        subject: `Receipt ${header.no} — ${total} received`,
        html: `<p>Dear ${member.first_name},</p>`
          + `<p>We have received <b>${total}</b> on receipt <b>${header.no}</b> dated`
          + ` ${formatDate(header.posting_date)}.</p>`
          + `<ul>${detail.map((d) => `<li>${d}</li>`).join('')}</ul>`
          + `<p>Thank you,<br/>${sacco}</p>`,
      });
    }
  } catch (err) {
    console.error('[receipt] member notification failed', err);
  }
}

/* ------------------------------------------------------------------- posting */

export async function postReceipt(no: string, user: Actor): Promise<{ postedReceiptNo: string; journalNo: string | null }> {
  const result = await tx(async () => {
    const header = await one<ReceiptHeader>('SELECT * FROM receipt_header WHERE no = ?', no);
    if (!header) throw new AppError('Receipt not found', 'NOT_FOUND');
    if (header.posted) throw new AppError('This receipt has already been posted', 'VALIDATION');
    // A receipt at/above the approval limit must be Approved; below it the creator can post directly.
    if (header.amount >= header.approval_limit && header.status !== 'Approved') {
      throw new AppError('This receipt is at or above the approval limit and must be approved before posting', 'VALIDATION');
    }
    if (header.amount < header.approval_limit && header.status === 'Open' && header.created_by !== user.username) {
      throw new AppError('Only the person who created this receipt can post it directly', 'NOT_CREATOR');
    }
    if (!['Open', 'Approved'].includes(header.status)) throw new AppError('This receipt cannot be posted', 'VALIDATION');
    assertReceivedAmountAgrees(header);

    const vd = header.posting_date;
    const setup = await getCashManagementSetup();
    if (setup.allow_cm_posting_from && vd < setup.allow_cm_posting_from) throw new AppError(`Cash Management posting is not allowed before ${setup.allow_cm_posting_from}`, 'VALIDATION');
    if (setup.allow_cm_posting_to && vd > setup.allow_cm_posting_to) throw new AppError(`Cash Management posting is not allowed after ${setup.allow_cm_posting_to}`, 'VALIDATION');
    const range = await getEffectivePostingRange(user.id);
    if (range.from && vd < range.from) throw new AppError(`Posting date ${vd} is before your earliest allowed date (${range.from})`, 'VALIDATION');
    if (range.to && vd > range.to) throw new AppError(`Posting date ${vd} is after your latest allowed date (${range.to})`, 'VALIDATION');

    const bank = await loadBank(header.bank_account_id);
    const lines = await all<ReceiptLine>('SELECT * FROM receipt_line WHERE receipt_header_id = ? ORDER BY line_no', header.id);
    if (!lines.length) throw new AppError('This receipt has no lines', 'VALIDATION');
    /** Employee lines — written to the employee subledger once the journal exists. */
    const employeeReceipts: { amount: Cents; appliesTo: string | null; narration: string }[] = [];

    const glLines: { account: number; debit: Cents; credit: Cents; narration: string; bankDocumentType?: string; bankDocumentNo?: string; bankExternalDocumentNo?: string | null }[] = [];
    const memberCredits: MemberCredit[] = [];
    const touchedCustomers = new Set<number>();
    const touchedVendors = new Set<number>();
    let loanRepaid = 0;
    let loanCharged = 0;

    for (const line of lines) {
      const narration = `Receipt ${no} — ${line.description || line.account_name || line.account_no}`.slice(0, 250);
      if (line.line_type === 'Member') {
        if (line.loan_id) {
          // repay() and the repayment charge each post their own journal against the bank, so this
          // line contributes nothing to the receipt's journal except any unallocated remainder.
          const res = await postMemberLoanLine(header, line, bank.gl_account_id, vd, user);
          loanRepaid += res.repaid;
          loanCharged += res.charged;
          if (res.unallocated > 0) {
            const setup = await getCashManagementSetup();
            const accountId = await unallocatedAccountFor(line.member_id!, setup.unallocated_product_id);
            glLines.push({ account: await controlAccountFor(accountId), debit: 0, credit: res.unallocated, narration: `${narration} (unallocated)` });
            memberCredits.push({
              accountId, memberId: line.member_id!, amount: res.unallocated,
              narration: `Receipt ${no} — unallocated after loan repayment`,
            });
          }
        } else {
          glLines.push({ account: await controlAccountFor(line.savings_account_id!), debit: 0, credit: line.amount, narration });
          memberCredits.push({ accountId: line.savings_account_id!, memberId: line.member_id!, amount: line.amount, narration });
        }
      } else if (line.line_type === 'Employee') {
        // Settles what the employee owes on the subledger — the control account is credited.
        if (!header.employee_id) throw new AppError('This receipt has no employee', 'VALIDATION');
        const imprest = await import('./imprest.ts');
        glLines.push({ account: await imprest.imprestControlAccountId(), debit: 0, credit: line.amount, narration });
        employeeReceipts.push({ amount: line.amount, appliesTo: line.applies_to_doc_no, narration });
      } else if (line.line_type === 'G/L Account') {
        const acc = await one<{ id: number }>('SELECT id FROM gl_account WHERE code = ?', line.account_no!);
        glLines.push({ account: acc!.id, debit: 0, credit: line.amount, narration });
      } else if (line.line_type === 'Bank Account') {
        const b = await one<{ gl_account_id: number }>('SELECT gl_account_id FROM bank_account WHERE code = ?', line.account_no!);
        glLines.push({ account: b!.gl_account_id, debit: 0, credit: line.amount, narration, bankDocumentType: 'Transfer', bankDocumentNo: no });
      } else if (line.line_type === 'Customer') {
        const c = await one<{ id: number; customer_posting_group_code: string | null }>('SELECT id, customer_posting_group_code FROM customer WHERE no = ?', line.account_no!);
        if (!c?.customer_posting_group_code) throw new AppError(`Customer ${line.account_no} has no Customer Posting Group`, 'VALIDATION');
        const pg = await one<{ receivables_account_id: number }>('SELECT receivables_account_id FROM customer_posting_group WHERE code = ?', c.customer_posting_group_code);
        glLines.push({ account: pg!.receivables_account_id, debit: 0, credit: line.amount, narration });
        const pay = await createCustLedgerEntry({
          customerId: c.id, postingDate: vd, documentType: 'Payment', documentNo: no,
          description: narration, amount: -line.amount, currencyCode: header.currency_code, currencyFactor: header.currency_factor,
          sourceType: 'Receipt', sourceId: header.id,
        });
        const target: number[] = [];
        if (line.applies_to_doc_no) {
          const t = await one<{ id: number }>("SELECT id FROM cust_ledger_entry WHERE customer_id = ? AND document_no = ? AND open = 1 AND positive = 1 ORDER BY id LIMIT 1", c.id, line.applies_to_doc_no);
          if (t) target.push(t.id);
        }
        await applyCustomerEntries({ applyingEntryId: pay, appliedTo: target.length ? target : 'auto', postingDate: vd }, user);
        touchedCustomers.add(c.id);
      } else {
        const v = await one<{ id: number; vendor_posting_group_code: string | null }>('SELECT id, vendor_posting_group_code FROM vendor WHERE no = ?', line.account_no!);
        if (!v?.vendor_posting_group_code) throw new AppError(`Vendor ${line.account_no} has no Vendor Posting Group`, 'VALIDATION');
        const pg = await one<{ payables_account_id: number }>('SELECT payables_account_id FROM vendor_posting_group WHERE code = ?', v.vendor_posting_group_code);
        glLines.push({ account: pg!.payables_account_id, debit: 0, credit: line.amount, narration });
        const ref = await createVendorLedgerEntry({
          vendorId: v.id, postingDate: vd, documentType: 'Refund', documentNo: no, description: narration,
          amount: -line.amount, currencyCode: header.currency_code, currencyFactor: header.currency_factor, sourceType: 'Receipt', sourceId: header.id,
        });
        const target: number[] = [];
        if (line.applies_to_doc_no) {
          const t = await one<{ id: number }>("SELECT id FROM vendor_ledger_entry WHERE vendor_id = ? AND document_no = ? AND open = 1 AND positive = 1 ORDER BY id LIMIT 1", v.id, line.applies_to_doc_no);
          if (t) target.push(t.id);
        }
        await applyVendorEntries({ applyingEntryId: ref, appliedTo: target.length ? target : 'auto', postingDate: vd }, user);
        touchedVendors.add(v.id);
      }
    }

    // The bank is debited with what this journal actually credits — which is the whole receipt
    // except the loan lines, whose own journals have already debited it for their share.
    const journalAmount = glLines.reduce((sum, l) => sum + l.credit, 0);
    if (employeeReceipts.length && !(journalAmount > 0)) throw new AppError('Nothing to post', 'VALIDATION');
    let j: { id: number; journal_no: string } | null = null;
    if (journalAmount > 0) {
      j = await postJournal({
        valueDate: vd, module: 'CASH_MGMT', eventType: 'RECEIPT',
        description: `Receipt ${no} — ${header.description}`.slice(0, 250), reference: no, user,
        memberId: header.member_id, idempotencyKey: `RECEIPT-${no}`,
        currencyCode: header.currency_code, currencyFactor: header.currency_factor,
        lines: [
          {
            account: bank.gl_account_id, debit: journalAmount, credit: 0,
            narration: `Receipt ${no} — ${header.description}`.slice(0, 250),
            bankDocumentType: 'Receipt', bankDocumentNo: no, bankExternalDocumentNo: header.external_document_no,
          },
          ...glLines.map((l) => ({
            account: l.account, debit: l.debit, credit: l.credit, narration: l.narration,
            bankDocumentType: l.bankDocumentType, bankDocumentNo: l.bankDocumentNo, bankExternalDocumentNo: l.bankExternalDocumentNo,
          })),
        ],
      });
      for (const credit of memberCredits) await writeMemberCredit(header, credit, vd, j.id, user);
      await run("UPDATE cust_ledger_entry SET journal_id = ? WHERE source_type = 'Receipt' AND source_id = ? AND journal_id IS NULL", j.id, header.id);
      await run("UPDATE vendor_ledger_entry SET journal_id = ? WHERE source_type = 'Receipt' AND source_id = ? AND journal_id IS NULL", j.id, header.id);
    }
    for (const c of touchedCustomers) await recomputeCustomerBalance(c);
    for (const v of touchedVendors) await recomputeVendorBalance(v);

    const postedNo = await nextSequence('POSTED_RECEIPT');
    const info = await run(
      `INSERT INTO posted_receipt
         (no, receipt_no, receipt_type, bank_account_id, bank_account_name, pay_mode_code, external_document_no,
          manual_receipt_no, description, currency_code, currency_factor, posting_date, amount, journal_id,
          member_id, member_no, member_name, employee_id, created_at, created_by)
       VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)`,
      postedNo, no, header.receipt_type, bank.id, header.bank_account_name, header.pay_mode_code, header.external_document_no,
      header.manual_receipt_no, header.description, header.currency_code, header.currency_factor, vd, header.amount, j?.id ?? null,
      header.member_id, header.member_no, header.member_name, header.employee_id, new Date().toISOString(), user.username,
    );
    if (employeeReceipts.length && j) {
      const imprest = await import('./imprest.ts');
      for (const r of employeeReceipts) {
        await imprest.writeEmployeeLedgerEntry({
          employeeId: header.employee_id!, entryType: r.appliesTo ? 'IMPREST_REFUND' : 'RECEIPT', documentNo: r.appliesTo ?? no,
          postingDate: vd, amount: -r.amount, description: r.narration, journalId: j.id, user,
        });
      }
    }
    const prId = Number(info.lastInsertRowid);
    let ln = 10000;
    for (const line of lines) {
      await run(
        `INSERT INTO posted_receipt_line
           (posted_receipt_id, line_no, line_type, account_no, account_name, description, amount, applies_to_doc_no,
            member_id, savings_account_id, loan_id, product_category, penalty_balance, accrued_interest,
            interest_balance, principal_balance, loan_balance, charge_amount)
         VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)`,
        prId, ln, line.line_type, line.account_no, line.account_name, line.description, line.amount, line.applies_to_doc_no,
        line.member_id, line.savings_account_id, line.loan_id, line.product_category, line.penalty_balance,
        line.accrued_interest, line.interest_balance, line.principal_balance, line.loan_balance, line.charge_amount,
      );
      ln += 10000;
    }

    await run("UPDATE receipt_header SET posted = true, journal_id = ?, posted_at = ?, posted_by = ? WHERE no = ?", j?.id ?? null, new Date().toISOString(), user.username, no);
    await audit(user, 'RECEIPT_POST', 'receipt_header', no, { postedNo, journalNo: j?.journal_no ?? null, loanRepaid, loanCharged });
    return { postedReceiptNo: postedNo, journalNo: j?.journal_no ?? null, header, lines };
  });

  // Outside the transaction: an SMS gateway that hangs must not hold a database connection, and
  // a receipt that posted stays posted whether or not the message got through.
  await notifyMemberOfReceipt(result.header, result.lines);
  return { postedReceiptNo: result.postedReceiptNo, journalNo: result.journalNo };
}
