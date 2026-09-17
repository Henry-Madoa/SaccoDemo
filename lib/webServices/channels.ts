/*
 * Codeunit "Channels Integration" — the procedures a mobile app, USSD gateway, paybill or
 * internet-banking portal calls (ported from Cod52204017 "Channels Integrations"): member and
 * account lookups, balances and mini statements, loan products, qualification and applications,
 * standing orders, and the channel postings themselves (deposits, withdrawals, transfers,
 * repayments, reversals). Everything posts through the same library functions the tellers use,
 * so channel activity carries the same validations, journals and audit trail.
 *
 * Responses are JSON objects; every procedure that can fail throws, and the protocol layer
 * turns that into an OData error or SOAP fault with a proper status. Money is decimal (12.50).
 */
import { one, all, tx } from '../db.ts';
import { AppError } from '../errors.ts';
import { deposit, withdraw, reverseTxn, statement } from '../savings.ts';
import { appraise, apply, saveAppraisal, submit, commitGuarantor, releaseGuarantor, repay } from '../loanService.ts';
import { buildSchedule, calculateLoanProductCharges, addMonths } from '../loans.ts';
import { listLoanProductCharges } from '../loanProductCharges.ts';
import { listTransactionCharges, getTransactionCharge, calculateTransactionCharges } from '../charges.ts';
import { createStandingOrder, submitStandingOrder } from '../standingOrders.ts';
import { buildMemberStatementPrints } from '../memberStatementPrint.ts';
import { renderDocument } from '../documentPrint.ts';
import { imageSrc } from '../cloudinary.ts';
import type { WsCodeunit, WsProcedure, WsType } from './objects.ts';
import type { LoanProduct, Member, SavingsAccount, StandingOrderClass } from '../types.ts';

const P = (name: string, type: WsType, required = true) => ({ name, type, required });
const m = (cents: unknown) => Number(cents ?? 0) / 100;
const cents = (v: unknown) => Math.round(Number(v ?? 0) * 100);
const str = (v: unknown): string | null => (v == null || String(v).trim() === '' ? null : String(v).trim());
const fullName = (r: { first_name?: string | null; middle_name?: string | null; last_name?: string | null }) =>
  [r.first_name, r.middle_name, r.last_name].filter(Boolean).join(' ');

/* ------------------------------------------------------------------------------ lookups */

async function memberByNo(memberNo: unknown): Promise<Member> {
  const r = await one<Member>('SELECT * FROM member WHERE member_no = ?', String(memberNo ?? '').trim());
  if (!r) throw new AppError(`Member ${String(memberNo ?? '')} not found`, 'NOT_FOUND');
  return r;
}
async function memberByAny(identifier: string): Promise<Member | undefined> {
  const id = identifier.trim();
  return one<Member>(
    'SELECT * FROM member WHERE member_no = ? OR identification_no = ? OR phone = ? OR phone = ? ORDER BY id LIMIT 1',
    id, id, id, id.replace(/^\+?254/, '0'),
  );
}
interface AccountRow extends SavingsAccount { member_no: string; first_name: string; middle_name: string | null; last_name: string; member_status: string; product_code: string; product_name: string; category: string; allow_withdrawal: number; withdrawal_fee: number; min_balance: number }
const ACCOUNT_SQL = `SELECT a.*, m.member_no, m.first_name, m.middle_name, m.last_name, m.status AS member_status,
                            p.code AS product_code, p.name AS product_name, p.category, p.allow_withdrawal, p.withdrawal_fee, p.min_balance
                     FROM savings_account a JOIN member m ON m.id = a.member_id JOIN savings_product p ON p.id = a.product_id`;
async function accountByNo(accountNo: unknown): Promise<AccountRow> {
  const r = await one<AccountRow>(`${ACCOUNT_SQL} WHERE a.account_no = ?`, String(accountNo ?? '').trim());
  if (!r) throw new AppError(`Account ${String(accountNo ?? '')} not found`, 'NOT_FOUND');
  return r;
}
const memberAccounts = (memberId: number): Promise<AccountRow[]> =>
  all<AccountRow>(`${ACCOUNT_SQL} WHERE a.member_id = ? AND a.status <> 'CLOSED' ORDER BY p.allow_withdrawal DESC, a.account_no`, memberId);
/** The transacting (FOSA) account: the member's withdrawable deposit account, oldest first. */
const fosaAccount = async (memberId: number): Promise<AccountRow | undefined> =>
  (await memberAccounts(memberId)).find((a) => a.category === 'WITHDRAWABLE DEPOSIT' && a.status === 'ACTIVE')
  ?? (await memberAccounts(memberId)).find((a) => Number(a.allow_withdrawal) === 1 && a.status === 'ACTIVE');

const accountJson = (a: AccountRow) => ({
  accountNo: a.account_no, accountName: `${fullName(a)} — ${a.product_name}`, memberNo: a.member_no, productCode: a.product_code, productName: a.product_name,
  category: a.category, status: a.status, balance: m(a.balance), holdAmount: m(a.hold_amount), availableBalance: m(Number(a.balance) - Number(a.hold_amount) - Number(a.min_balance)),
  minimumBalance: m(a.min_balance), withdrawable: Number(a.allow_withdrawal) === 1, openedDate: a.opened_date,
});

interface LoanRow { id: number; loan_no: string; member_id: number; product_code: string; product_name: string; principal: number; interest_rate: number; term_months: number; status: string; applied_date: string | null; approved_date: string | null; disbursed_date: string | null; installment: number; principal_balance: number; interest_balance: number; penalty_balance: number; arrears_amount: number; days_in_arrears: number; classification: string | null; purpose: string | null; total_interest: number; principal_paid: number; interest_paid: number; first_due_date: string | null }
const LOAN_SQL = 'SELECT l.*, p.code AS product_code, p.name AS product_name FROM loan l JOIN loan_product p ON p.id = l.product_id';
async function loanByNo(loanNo: unknown): Promise<LoanRow> {
  const r = await one<LoanRow>(`${LOAN_SQL} WHERE l.loan_no = ?`, String(loanNo ?? '').trim());
  if (!r) throw new AppError(`Loan ${String(loanNo ?? '')} not found`, 'NOT_FOUND');
  return r;
}
const loanJson = (l: LoanRow) => ({
  loanNo: l.loan_no, productCode: l.product_code, productName: l.product_name, status: l.status, principal: m(l.principal), interestRate: Number(l.interest_rate),
  termMonths: Number(l.term_months), installment: m(l.installment), purpose: l.purpose, appliedDate: l.applied_date, approvedDate: l.approved_date, disbursedDate: l.disbursed_date,
  firstDueDate: l.first_due_date, principalBalance: m(l.principal_balance), interestBalance: m(l.interest_balance), penaltyBalance: m(l.penalty_balance),
  outstandingBalance: m(Number(l.principal_balance) + Number(l.interest_balance) + Number(l.penalty_balance)), principalPaid: m(l.principal_paid), interestPaid: m(l.interest_paid),
  arrearsAmount: m(l.arrears_amount), daysInArrears: Number(l.days_in_arrears), classification: l.classification,
});

async function productByCode(code: unknown): Promise<LoanProduct> {
  const p = await one<LoanProduct>("SELECT * FROM loan_product WHERE code = ? AND status = 'ACTIVE'", String(code ?? '').trim().toUpperCase());
  if (!p) throw new AppError(`Loan product ${String(code ?? '')} not found`, 'NOT_FOUND');
  return p;
}

/** A base64 document the channel can show or forward: the statement/slip HTML. */
const asBase64Document = (html: string, fileName: string) => ({ fileName, contentType: 'text/html; charset=utf-8', base64: Buffer.from(html, 'utf8').toString('base64') });

/** A channel posting must be safe to retry: the same channel reference is answered with the
 *  same result instead of posting twice. */
async function existingByKey(idempotencyKey: string): Promise<{ txn_ref: string; amount: number; running_balance: number } | undefined> {
  return one(`SELECT t.txn_ref, t.amount, t.running_balance FROM journal j JOIN txn t ON t.journal_id = j.id
              WHERE j.idempotency_key = ? AND t.status <> 'REVERSED' ORDER BY t.id DESC LIMIT 1`, idempotencyKey);
}

const CHANNEL_TRANSACTION_TYPES = [
  { code: 'DEPOSIT', description: 'Deposit to a member account (paybill / mobile money in)' },
  { code: 'WITHDRAWAL', description: 'Withdrawal from a member account (mobile money out)' },
  { code: 'LOAN_REPAYMENT', description: 'Repayment of a running loan' },
  { code: 'ACCOUNT_TRANSFER', description: 'Transfer between two member accounts' },
];
const STANDING_ORDER_CLASSES: { code: StandingOrderClass; description: string }[] = [
  { code: 'INTERNAL', description: 'To another member account in the SACCO' },
  { code: 'EXTERNAL', description: 'To an external bank account' },
  { code: 'LOAN', description: 'Loan repayment' },
];

/* ------------------------------------------------------------------------------ procedures */

const procedures: WsProcedure[] = [
  /* ---------------------------------------------------------------- members */
  {
    name: 'GetMemberCategories', caption: 'Membership categories and their registration fees', params: [], returns: 'Json', action: 'MEMBERS_READ',
    run: async () => (await all<{ code: string; description: string; category_type: string; registration_fee: number }>("SELECT code, description, category_type, registration_fee FROM member_category WHERE status = 'ACTIVE' ORDER BY code"))
      .map((c) => ({ code: c.code, description: c.description, categoryType: c.category_type, registrationFee: m(c.registration_fee) })),
  },
  {
    name: 'GetMemberNoFromPhoneNo', caption: 'Member number for a phone number', params: [P('phoneNo', 'Code')], returns: 'Code', action: 'MEMBERS_READ',
    run: async ({ phoneNo }) => { const r = await memberByAny(String(phoneNo)); if (!r) throw new AppError('No member with that phone number', 'NOT_FOUND'); return r.member_no; },
  },
  {
    name: 'GetMemberNoFromIDNo', caption: 'Member number for a national ID number', params: [P('idNo', 'Code')], returns: 'Code', action: 'MEMBERS_READ',
    run: async ({ idNo }) => { const r = await one<Member>('SELECT * FROM member WHERE identification_no = ?', String(idNo).trim()); if (!r) throw new AppError('No member with that ID number', 'NOT_FOUND'); return r.member_no; },
  },
  {
    name: 'CustomerLookup', caption: 'Member and transacting account for a phone number, ID or member number', params: [P('phoneNumber', 'Code'), P('channelReference', 'Code', false)], returns: 'Json', action: 'MEMBERS_READ',
    run: async ({ phoneNumber }) => {
      const r = await memberByAny(String(phoneNumber)); if (!r) throw new AppError('Customer not found', 'NOT_FOUND');
      const fosa = await fosaAccount(r.id);
      return { memberNo: r.member_no, customerName: fullName(r), status: r.status, phone: r.phone, idNo: r.identification_no, fosaAccountNo: fosa?.account_no ?? null, fosaBalance: fosa ? m(fosa.balance) : null };
    },
  },
  {
    name: 'GetMemberProfileByMemberNo', caption: 'Full member profile: bio-data, accounts, loans and next of kin', params: [P('memberNo', 'Code')], returns: 'Json', action: 'MEMBERS_READ',
    run: async ({ memberNo }) => {
      const r = await memberByNo(memberNo);
      const [accounts, loans, kins, category] = await Promise.all([
        memberAccounts(r.id),
        all<LoanRow>(`${LOAN_SQL} WHERE l.member_id = ? AND l.status = 'DISBURSED' ORDER BY l.loan_no`, r.id),
        all<{ name: string; relationship: string | null; phone: string | null }>('SELECT name, relationship, phone FROM member_nominee WHERE member_id = ? AND is_next_of_kin = 1 ORDER BY id', r.id),
        r.member_category_id ? one<{ code: string; description: string }>('SELECT code, description FROM member_category WHERE id = ?', r.member_category_id) : Promise.resolve(undefined),
      ]);
      return {
        memberNo: r.member_no, name: fullName(r), firstName: r.first_name, middleName: r.middle_name, lastName: r.last_name, title: r.title, gender: r.gender, dateOfBirth: r.date_of_birth,
        idNo: r.identification_no, kraPin: r.kra_pin, phone: r.phone, email: r.email, postalAddress: r.postal_address, physicalAddress: r.physical_address,
        employer: r.employer, staffNo: r.staff_no, status: r.status, kycVerified: !!Number(r.kyc_verified), joinDate: r.join_date, memberType: r.member_type,
        category: category ? { code: category.code, description: category.description } : null,
        totalDeposits: m(accounts.reduce((s, a) => s + Number(a.balance), 0)),
        totalLoans: m(loans.reduce((s, l) => s + Number(l.principal_balance) + Number(l.interest_balance) + Number(l.penalty_balance), 0)),
        accounts: accounts.map(accountJson), loans: loans.map(loanJson), nextOfKin: kins,
      };
    },
  },
  {
    name: 'GetMemberNextOfKins', caption: 'Next of kin and nominees on file', params: [P('memberNo', 'Code')], returns: 'Json', action: 'MEMBERS_READ',
    run: async ({ memberNo }) => {
      const r = await memberByNo(memberNo);
      return (await all<{ name: string; relationship: string | null; phone: string | null; identification_no: string | null; percentage: number | null; is_next_of_kin: number }>('SELECT name, relationship, phone, identification_no, percentage, is_next_of_kin FROM member_nominee WHERE member_id = ? ORDER BY is_next_of_kin DESC, id', r.id))
        .map((k) => ({ name: k.name, relationship: k.relationship, phone: k.phone, idNo: k.identification_no, sharePercent: k.percentage == null ? null : Number(k.percentage), isNextOfKin: !!Number(k.is_next_of_kin) }));
    },
  },
  {
    name: 'GetMemberGuarantorInformation', caption: 'Loans this member guarantees, and who guarantees their loans', params: [P('memberNo', 'Code')], returns: 'Json', action: 'LOAN_READ',
    run: async ({ memberNo }) => {
      const r = await memberByNo(memberNo);
      const guaranteeing = await all<{ loan_no: string; borrower_no: string; borrower: string; amount: number; status: string; loan_status: string; outstanding: number }>(
        `SELECT l.loan_no, b.member_no AS borrower_no, b.first_name || ' ' || b.last_name AS borrower, g.amount, g.status, l.status AS loan_status,
                l.principal_balance + l.interest_balance + l.penalty_balance AS outstanding
         FROM loan_guarantor g JOIN loan l ON l.id = g.loan_id JOIN member b ON b.id = l.member_id WHERE g.member_id = ? ORDER BY l.loan_no`, r.id);
      const guarantors = await all<{ loan_no: string; member_no: string; name: string; amount: number; status: string }>(
        `SELECT l.loan_no, gm.member_no, gm.first_name || ' ' || gm.last_name AS name, g.amount, g.status
         FROM loan_guarantor g JOIN loan l ON l.id = g.loan_id JOIN member gm ON gm.id = g.member_id WHERE l.member_id = ? ORDER BY l.loan_no`, r.id);
      return {
        memberNo: r.member_no,
        guaranteeing: guaranteeing.map((g) => ({ loanNo: g.loan_no, borrowerNo: g.borrower_no, borrower: g.borrower, amount: m(g.amount), status: g.status, loanStatus: g.loan_status, outstanding: m(g.outstanding) })),
        totalGuaranteed: m(guaranteeing.filter((g) => g.loan_status === 'DISBURSED').reduce((s, g) => s + Number(g.amount), 0)),
        myGuarantors: guarantors.map((g) => ({ loanNo: g.loan_no, memberNo: g.member_no, name: g.name, amount: m(g.amount), status: g.status })),
      };
    },
  },
  {
    name: 'ExportMemberImages', caption: 'A member image (passport photo, ID front/back or signature) as a URL or base64', params: [P('memberNo', 'Code'), P('imageType', 'Code')], returns: 'Json', action: 'MEMBERS_READ',
    run: async ({ memberNo, imageType }) => {
      const r = await memberByNo(memberNo);
      const col = ({ MEMBERPICTURE: 'photo', PHOTO: 'photo', PASSPORT: 'photo', FRONTID: 'front_id_image', BACKID: 'back_id_image', SIGNATURE: 'signature_image' } as Record<string, keyof Member>)[String(imageType).toUpperCase().replace(/[^A-Z]/g, '')];
      if (!col) throw new AppError('imageType must be MemberPicture, FrontID, BackID or Signature', 'VALIDATION');
      const stored = r[col] as string | null;
      const src = imageSrc(stored);
      if (!src) return { memberNo: r.member_no, imageType, available: false };
      return src.startsWith('data:')
        ? { memberNo: r.member_no, imageType, available: true, contentType: src.slice(5, src.indexOf(';')), base64: src.slice(src.indexOf(',') + 1) }
        : { memberNo: r.member_no, imageType, available: true, url: src };
    },
  },
  {
    name: 'CheckMemberPendingDocument', caption: 'Whether the member has a document of a type awaiting approval', params: [P('memberNo', 'Code'), P('documentType', 'Code')], returns: 'Json', action: 'MEMBERS_READ',
    run: async ({ memberNo, documentType }) => {
      const r = await memberByNo(memberNo);
      const type = String(documentType).toUpperCase().replace(/[^A-Z]/g, '');
      let rows: { no: string; status: string }[];
      switch (type) {
        case 'LOAN': rows = await all("SELECT loan_no AS no, status FROM loan WHERE member_id = ? AND status IN ('OPEN','PENDING','APPROVED')", r.id); break;
        case 'STANDINGORDER': rows = await all("SELECT no, status FROM standing_order WHERE member_id = ? AND status IN ('Open','Pending Approval')", r.id); break;
        case 'CHANGEREQUEST': rows = await all("SELECT no, status FROM member_edit_request WHERE member_id = ? AND status IN ('Open','Pending Approval')", r.id); break;
        case 'GUARANTORSUBSTITUTION': rows = await all("SELECT gc.no, gc.status FROM loan_guarantor_change gc JOIN loan l ON l.id = gc.loan_id WHERE l.member_id = ? AND gc.status IN ('Open','Pending Approval')", r.id); break;
        default: throw new AppError('documentType must be Loan, StandingOrder, ChangeRequest or GuarantorSubstitution', 'VALIDATION');
      }
      return { memberNo: r.member_no, documentType: type, hasPending: rows.length > 0, documents: rows };
    },
  },
  {
    name: 'GetEmployerDetails', caption: 'An employer on the check-off register', params: [P('employerCode', 'Code')], returns: 'Json', action: 'MEMBERS_READ',
    run: async ({ employerCode }) => {
      const e = await one<{ code: string; name: string; phone: string | null; email: string | null; status: string; members: number }>(
        'SELECT e.code, e.name, e.phone, e.email, e.status, (SELECT COUNT(*) FROM member m WHERE m.employer_id = e.id) AS members FROM employer e WHERE e.code = ?', String(employerCode).trim().toUpperCase());
      if (!e) throw new AppError(`Employer ${String(employerCode)} not found`, 'NOT_FOUND');
      return { ...e, members: Number(e.members) };
    },
  },
  {
    name: 'GetEmployerMembers', caption: 'Members attached to an employer', params: [P('employerCode', 'Code')], returns: 'Json', action: 'MEMBERS_READ',
    run: async ({ employerCode }) => (await all<{ member_no: string; name: string; staff_no: string | null; phone: string | null; status: string }>(
      `SELECT m.member_no, m.first_name || ' ' || m.last_name AS name, m.staff_no, m.phone, m.status FROM member m JOIN employer e ON e.id = m.employer_id WHERE e.code = ? ORDER BY m.member_no`, String(employerCode).trim().toUpperCase()))
      .map((r) => ({ memberNo: r.member_no, name: r.name, staffNo: r.staff_no, phone: r.phone, status: r.status })),
  },

  /* ---------------------------------------------------------------- accounts & balances */
  {
    name: 'AccountValidation', caption: 'Whether an account number exists and can transact', params: [P('accountNo', 'Code')], returns: 'Json', action: 'SAVINGS_READ',
    run: async ({ accountNo }) => {
      const a = await one<AccountRow>(`${ACCOUNT_SQL} WHERE a.account_no = ?`, String(accountNo).trim());
      if (!a) return { valid: false, accountNo, message: 'Account not found' };
      return { valid: a.status === 'ACTIVE' && a.member_status === 'ACTIVE', accountNo: a.account_no, accountName: `${fullName(a)} — ${a.product_name}`, memberNo: a.member_no, status: a.status, memberStatus: a.member_status, withdrawable: Number(a.allow_withdrawal) === 1 };
    },
  },
  {
    name: 'CheckFosaAccount', caption: 'Validate a transacting (FOSA) account and return its holder', params: [P('fosaAccountNo', 'Code')], returns: 'Json', action: 'SAVINGS_READ',
    run: async ({ fosaAccountNo }) => {
      const a = await accountByNo(fosaAccountNo);
      if (Number(a.allow_withdrawal) !== 1) throw new AppError(`${a.account_no} is a ${a.category.toLowerCase()} account, not a transacting account`, 'VALIDATION');
      return { ...accountJson(a), memberName: fullName(a), phone: (await memberByNo(a.member_no)).phone };
    },
  },
  {
    name: 'GetMemberFOSAAccount', caption: "The member's transacting (FOSA) account", params: [P('memberNo', 'Code')], returns: 'Json', action: 'SAVINGS_READ',
    run: async ({ memberNo }) => { const r = await memberByNo(memberNo); const a = await fosaAccount(r.id); if (!a) throw new AppError('The member has no transacting account', 'NOT_FOUND'); return accountJson(a); },
  },
  {
    name: 'GetTransactingAccountFromPhoneNo', caption: 'The transacting account for a phone number', params: [P('phoneNo', 'Code')], returns: 'Json', action: 'SAVINGS_READ',
    run: async ({ phoneNo }) => { const r = await memberByAny(String(phoneNo)); if (!r) throw new AppError('No member with that phone number', 'NOT_FOUND'); const a = await fosaAccount(r.id); if (!a) throw new AppError('The member has no transacting account', 'NOT_FOUND'); return accountJson(a); },
  },
  {
    name: 'AccountsLookup', caption: 'Every account (or every loan) of a member, by member no., ID or phone', params: [P('identifier', 'Code'), P('isLoan', 'Boolean', false)], returns: 'Json', action: 'SAVINGS_READ',
    run: async ({ identifier, isLoan }) => {
      const r = await memberByAny(String(identifier)); if (!r) throw new AppError('Member not found', 'NOT_FOUND');
      if (isLoan) return (await all<LoanRow>(`${LOAN_SQL} WHERE l.member_id = ? AND l.status = 'DISBURSED' ORDER BY l.loan_no`, r.id)).map(loanJson);
      return (await memberAccounts(r.id)).map(accountJson);
    },
  },
  {
    name: 'GetMemberAccountDetails', caption: 'Details and balances of one account', params: [P('accountNo', 'Code')], returns: 'Json', action: 'SAVINGS_READ',
    run: async ({ accountNo }) => accountJson(await accountByNo(accountNo)),
  },
  {
    name: 'BalanceInquiry', caption: 'Balance of an account', params: [P('accountNumber', 'Code'), P('channelReference', 'Code', false)], returns: 'Json', action: 'SAVINGS_READ',
    run: async ({ accountNumber }) => { const a = await accountByNo(accountNumber); return { accountNo: a.account_no, accountName: `${fullName(a)} — ${a.product_name}`, balance: m(a.balance), holdAmount: m(a.hold_amount), availableBalance: accountJson(a).availableBalance, currency: 'KES' }; },
  },
  {
    name: 'MemberAccountsBalanceInquiry', caption: 'Balances of every account and running loan of a member', params: [P('memberNo', 'Code')], returns: 'Json', action: 'SAVINGS_READ',
    run: async ({ memberNo }) => {
      const r = await memberByNo(memberNo);
      const [accounts, loans] = await Promise.all([memberAccounts(r.id), all<LoanRow>(`${LOAN_SQL} WHERE l.member_id = ? AND l.status = 'DISBURSED' ORDER BY l.loan_no`, r.id)]);
      return {
        memberNo: r.member_no, name: fullName(r),
        accounts: accounts.map((a) => ({ accountNo: a.account_no, productName: a.product_name, category: a.category, balance: m(a.balance), availableBalance: accountJson(a).availableBalance })),
        loans: loans.map((l) => ({ loanNo: l.loan_no, productName: l.product_name, outstandingBalance: loanJson(l).outstandingBalance, installment: m(l.installment), arrearsAmount: m(l.arrears_amount), daysInArrears: Number(l.days_in_arrears) })),
      };
    },
  },
  {
    name: 'MiniStatement', caption: 'The last N transactions on an account (default 5)', params: [P('accountNumber', 'Code'), P('noOfTransactions', 'Integer', false)], returns: 'Json', action: 'SAVINGS_READ',
    run: async ({ accountNumber, noOfTransactions }) => {
      const a = await accountByNo(accountNumber);
      const n = Math.min(Math.max(Number(noOfTransactions ?? 5) || 5, 1), 50);
      const rows = await all<{ txn_ref: string; value_date: string; txn_type: string; description: string | null; amount: number; running_balance: number; channel: string; reference_no: string | null }>(
        "SELECT txn_ref, value_date, txn_type, description, amount, running_balance, channel, reference_no FROM txn WHERE savings_account_id = ? AND status <> 'REVERSED' ORDER BY id DESC LIMIT ?", a.id, n);
      return { accountNo: a.account_no, balance: m(a.balance), transactions: rows.map((t) => ({ reference: t.txn_ref, date: t.value_date, type: t.txn_type, description: t.description, amount: m(t.amount), balance: m(t.running_balance), channel: t.channel, channelReference: t.reference_no })) };
    },
  },
  {
    name: 'MiniStatementByDate', caption: 'Transactions on an account between two dates', params: [P('accountNumber', 'Code'), P('fromDate', 'Date'), P('toDate', 'Date')], returns: 'Json', action: 'SAVINGS_READ',
    run: async ({ accountNumber, fromDate, toDate }) => {
      const a = await accountByNo(accountNumber);
      const s = await statement(a.id, String(fromDate), String(toDate));
      let running = Number(s.opening);
      return {
        accountNo: a.account_no, fromDate, toDate, openingBalance: m(s.opening),
        transactions: s.lines.map((t) => { running += Number(t.amount); return { reference: t.txn_ref, date: t.value_date, type: t.txn_type, description: t.description, documentNo: t.document_no, amount: m(t.amount), balance: m(running) }; }),
        closingBalance: m(running),
      };
    },
  },
  {
    name: 'GetFullStatement', caption: 'The formatted account statement as a base64 document', params: [P('accountNumber', 'Code'), P('startDate', 'Date', false), P('endDate', 'Date', false)], returns: 'Json', action: 'MEMBER_STATEMENTS_READ',
    run: async ({ accountNumber, startDate, endDate }, ctx) => {
      const a = await accountByNo(accountNumber);
      const docs = await buildMemberStatementPrints({ memberIds: [a.member_id], accountIds: [a.id], from: str(startDate), to: str(endDate), showAccounts: true, showLoans: false }, { username: ctx.user.username, full_name: ctx.user.full_name });
      if (!docs.length) throw new AppError('No statement could be produced', 'NOT_FOUND');
      return asBase64Document(renderDocument(docs[0]), `statement-${a.account_no}.html`);
    },
  },

  /* ---------------------------------------------------------------- loans */
  {
    name: 'GetLoanProducts', caption: 'Active loan products and their terms', params: [], returns: 'Json', action: 'LOAN_READ',
    run: async () => (await all<LoanProduct>("SELECT * FROM loan_product WHERE status = 'ACTIVE' ORDER BY code")).map((p) => ({
      code: p.code, name: p.name, interestRate: Number(p.interest_rate), interestMethod: p.interest_method, maxTermMonths: Number(p.max_term_months),
      minAmount: m(p.min_amount), maxAmount: m(p.max_amount), depositMultiplier: Number(p.deposit_multiplier), guarantorsRequired: Number(p.guarantors_required), minMembershipMonths: Number(p.min_membership_months),
    })),
  },
  {
    name: 'CheckQualifiedLoanAmount', caption: 'How much a member qualifies for on a product', params: [P('customerNo', 'Code'), P('productCode', 'Code'), P('numberOfMonths', 'Integer', false)], returns: 'Json', action: 'LOAN_READ',
    run: async ({ customerNo, productCode, numberOfMonths }) => {
      const r = await memberByNo(customerNo); const p = await productByCode(productCode);
      const months = Math.min(Number(numberOfMonths) || Number(p.max_term_months), Number(p.max_term_months));
      const ap = await appraise({ memberId: r.id, productId: p.id, principal: Number(p.max_amount) || 1, termMonths: months });
      const qualified = Math.max(0, Math.min(Number(p.max_amount) || ap.maxByMultiplier, ap.maxByMultiplier - ap.exposure));
      return {
        memberNo: r.member_no, productCode: p.code, numberOfMonths: months, deposits: m(ap.deposits), existingExposure: m(ap.exposure), maxByMultiplier: m(ap.maxByMultiplier),
        qualifiedLoanAmount: m(qualified), minimumCanApply: m(p.min_amount), maximumCanApply: m(p.max_amount), monthlyObligations: m(ap.monthlyObligations),
      };
    },
  },
  {
    name: 'CalculateRepayment', caption: 'Loan calculator: installment, total interest and schedule for an amount and term', params: [P('productCode', 'Code'), P('amount', 'Decimal'), P('numberOfMonths', 'Integer'), P('startDate', 'Date', false)], returns: 'Json', action: 'LOAN_READ',
    run: async ({ productCode, amount, numberOfMonths, startDate }) => {
      const p = await productByCode(productCode);
      const months = Number(numberOfMonths);
      if (months < 1 || months > Number(p.max_term_months)) throw new AppError(`Term must be between 1 and ${p.max_term_months} months`, 'VALIDATION');
      const firstDue = addMonths(str(startDate) ?? new Date().toISOString().slice(0, 10), 1);
      const s = buildSchedule(cents(amount), Number(p.interest_rate), months, p.interest_method, firstDue);
      const charges = calculateLoanProductCharges(await listLoanProductCharges(p.id), cents(amount), months);
      return {
        productCode: p.code, amount: Number(amount), numberOfMonths: months, interestRate: Number(p.interest_rate), interestMethod: p.interest_method,
        installment: m(s.installment), totalInterest: m(s.totalInterest), totalRepayable: m(s.totalPrincipal + s.totalInterest),
        charges: charges.map((c) => ({ code: c.chargeCode, description: c.chargeDescription, amount: m(c.amount) })), totalCharges: m(charges.reduce((t, c) => t + c.amount, 0)),
        schedule: s.rows.map((row) => ({ installmentNo: row.installment_no, dueDate: row.due_date, principal: m(row.principal_due), interest: m(row.interest_due), total: m(row.principal_due + row.interest_due), balance: m(row.opening_balance - row.principal_due) })),
      };
    },
  },
  {
    name: 'GetLoanCharges', caption: 'Charges that apply to a loan', params: [P('loanNo', 'Code')], returns: 'Json', action: 'LOAN_READ',
    run: async ({ loanNo }) => {
      const l = await loanByNo(loanNo);
      const p = await one<LoanProduct>("SELECT * FROM loan_product WHERE code = ?", l.product_code);
      const charges = calculateLoanProductCharges(await listLoanProductCharges(p!.id), Number(l.principal), Number(l.term_months));
      return { loanNo: l.loan_no, chargesAlreadyDeducted: m((await one<{ f: number }>('SELECT fees_charged AS f FROM loan WHERE id = ?', l.id))?.f), charges: charges.map((c) => ({ code: c.chargeCode, description: c.chargeDescription, amount: m(c.amount) })), total: m(charges.reduce((t, c) => t + c.amount, 0)) };
    },
  },
  {
    name: 'GetMemberLoans', caption: 'Running loans of a member', params: [P('memberNo', 'Code')], returns: 'Json', action: 'LOAN_READ',
    run: async ({ memberNo }) => { const r = await memberByNo(memberNo); return (await all<LoanRow>(`${LOAN_SQL} WHERE l.member_id = ? AND l.status = 'DISBURSED' ORDER BY l.loan_no`, r.id)).map(loanJson); },
  },
  {
    name: 'GetLoanApplications', caption: 'Loan applications of a member still in progress (open, pending or approved)', params: [P('memberNo', 'Code')], returns: 'Json', action: 'LOAN_READ',
    run: async ({ memberNo }) => {
      const r = await memberByNo(memberNo);
      const loans = await all<LoanRow>(`${LOAN_SQL} WHERE l.member_id = ? AND l.status IN ('OPEN','PENDING','APPROVED','REJECTED') ORDER BY l.id DESC`, r.id);
      const out = [];
      for (const l of loans) {
        const guarantors = await all<{ member_no: string; name: string; amount: number; status: string }>("SELECT gm.member_no, gm.first_name || ' ' || gm.last_name AS name, g.amount, g.status FROM loan_guarantor g JOIN member gm ON gm.id = g.member_id WHERE g.loan_id = ?", l.id);
        out.push({ ...loanJson(l), guarantors: guarantors.map((g) => ({ memberNo: g.member_no, name: g.name, amount: m(g.amount), status: g.status })) });
      }
      return out;
    },
  },
  {
    name: 'GetLoanSchedule', caption: 'Repayment schedule of a loan', params: [P('loanNo', 'Code')], returns: 'Json', action: 'LOAN_READ',
    run: async ({ loanNo }) => {
      const l = await loanByNo(loanNo);
      const rows = await all<{ installment_no: number; due_date: string; opening_balance: number; principal_due: number; interest_due: number; principal_paid: number; interest_paid: number; status: string }>('SELECT * FROM loan_schedule WHERE loan_id = ? ORDER BY installment_no', l.id);
      return { loanNo: l.loan_no, installment: m(l.installment), schedule: rows.map((s) => ({ installmentNo: s.installment_no, dueDate: s.due_date, openingBalance: m(s.opening_balance), principalDue: m(s.principal_due), interestDue: m(s.interest_due), totalDue: m(s.principal_due + s.interest_due), principalPaid: m(s.principal_paid), interestPaid: m(s.interest_paid), status: s.status })) };
    },
  },
  {
    name: 'GetLoanStatement', caption: 'Postings on a loan (disbursement, repayments, interest, penalties)', params: [P('loanNo', 'Code'), P('fromDate', 'Date', false), P('toDate', 'Date', false)], returns: 'Json', action: 'LOAN_READ',
    run: async ({ loanNo, fromDate, toDate }) => {
      const l = await loanByNo(loanNo);
      const rows = await all<{ txn_ref: string; value_date: string; txn_type: string; description: string | null; amount: number; running_balance: number; channel: string }>(
        `SELECT txn_ref, value_date, txn_type, description, amount, running_balance, channel FROM txn WHERE loan_id = ? AND status <> 'REVERSED'
         ${str(fromDate) ? 'AND value_date >= ?' : ''} ${str(toDate) ? 'AND value_date <= ?' : ''} ORDER BY id`, l.id, ...[str(fromDate), str(toDate)].filter(Boolean));
      return { ...loanJson(l), transactions: rows.map((t) => ({ reference: t.txn_ref, date: t.value_date, type: t.txn_type, description: t.description, amount: m(t.amount), balance: m(t.running_balance), channel: t.channel })) };
    },
  },
  {
    name: 'MonthlyRepayment', caption: 'Monthly installment of a loan', params: [P('loanNo', 'Code')], returns: 'Decimal', action: 'LOAN_READ',
    run: async ({ loanNo }) => m((await loanByNo(loanNo)).installment),
  },
  {
    name: 'SubmitLoanApplication', caption: 'Capture a loan application from a channel and send it for approval when it is complete',
    params: [P('memberNo', 'Code'), P('productCode', 'Code'), P('appliedAmount', 'Decimal'), P('installments', 'Integer'), P('loanPurpose', 'Text', false), P('sectorCode', 'Code', false), P('guarantors', 'Text', false), P('sourceType', 'Code', false)],
    returns: 'Json', action: 'LOAN_CREATE',
    run: async ({ memberNo, productCode, appliedAmount, installments, loanPurpose, sectorCode, guarantors, sourceType }, ctx) => {
      const r = await memberByNo(memberNo); const p = await productByCode(productCode);
      // "M00012:5000,M00034" — guarantor member numbers with an optional amount each.
      const guarantorList: { memberId: number; amount?: number }[] = [];
      for (const part of String(guarantors ?? '').split(',').map((s) => s.trim()).filter(Boolean)) {
        const [gNo, gAmt] = part.split(':'); const g = await memberByNo(gNo);
        guarantorList.push(gAmt ? { memberId: g.id, amount: cents(gAmt) } : { memberId: g.id });
      }
      const loan = await apply({
        memberId: r.id, productId: p.id, principal: cents(appliedAmount), termMonths: Number(installments),
        purpose: str(loanPurpose) ? `${str(loanPurpose)} [${String(sourceType ?? 'CHANNEL').toUpperCase()}]` : `Applied via ${String(sourceType ?? 'CHANNEL').toUpperCase()}`,
        sectorCode: str(sectorCode), guarantors: guarantorList, user: ctx.actor,
      });
      // The credit appraisal is what an officer runs before sending a loan on; a channel application
      // gets the same one, and only an eligible result is sent for approval.
      let status = loan.status; let submitted = false; let note: string | null = null; let decision: string | null = null;
      try {
        const ap = await saveAppraisal({ loanId: loan.id, user: ctx.actor }); decision = ap.decision;
        const s = await submit({ loanId: loan.id, user: ctx.actor }); status = s.status; submitted = true;
      } catch (e) { note = (e as Error).message; }
      return { loanNo: loan.loan_no, status, appraisal: decision, submitted, note, appliedAmount: Number(appliedAmount), installments: Number(installments) };
    },
  },
  {
    name: 'SubmitGuarantorRequest', caption: 'Add a guarantor to (or remove one from) a loan application', params: [P('loanNo', 'Code'), P('memberNo', 'Code'), P('requestedAmount', 'Decimal'), P('action', 'Code', false)], returns: 'Json', action: 'LOAN_CREATE',
    run: async ({ loanNo, memberNo, requestedAmount, action }, ctx) => {
      const l = await loanByNo(loanNo); const g = await memberByNo(memberNo);
      if (String(action ?? 'New').toUpperCase() === 'REMOVE') { await releaseGuarantor(l.id, g.id, ctx.actor); return { loanNo: l.loan_no, guarantor: g.member_no, action: 'Removed' }; }
      await commitGuarantor({ loanId: l.id, memberId: g.id, amount: cents(requestedAmount) }, ctx.actor);
      return { loanNo: l.loan_no, guarantor: g.member_no, action: 'Added', amount: Number(requestedAmount) };
    },
  },
  {
    name: 'GetEconomicSectors', caption: 'Economic sectors a loan can be classified under', params: [], returns: 'Json', action: 'LOAN_READ',
    run: async () => all<{ code: string; name: string }>('SELECT code, name FROM economic_sector ORDER BY code'),
  },

  /* ---------------------------------------------------------------- charges & configuration */
  {
    name: 'GetChannelTransactionTypes', caption: 'The transaction types ChannelTransactions accepts', params: [], returns: 'Json',
    run: async () => CHANNEL_TRANSACTION_TYPES,
  },
  {
    name: 'GetTransactionChargeCodes', caption: 'Transaction charge codes set up in the SACCO', params: [], returns: 'Json', action: 'SAVINGS_READ',
    run: async () => (await listTransactionCharges()).filter((c) => c.status === 'ACTIVE').map((c) => ({ code: c.code, description: c.description, transactionType: c.transaction_type })),
  },
  {
    name: 'LookUpTransactionCharges', caption: 'The charge a transaction of a given amount attracts', params: [P('chargeCode', 'Code'), P('transactionAmount', 'Decimal')], returns: 'Json', action: 'SAVINGS_READ',
    run: async ({ chargeCode, transactionAmount }) => {
      const c = (await listTransactionCharges()).find((x) => x.code.toUpperCase() === String(chargeCode).trim().toUpperCase());
      if (!c) throw new AppError(`Charge code ${String(chargeCode)} not found`, 'NOT_FOUND');
      const detail = await getTransactionCharge(c.id);
      const lines = detail ? calculateTransactionCharges(detail, cents(transactionAmount)) : [];
      return { chargeCode: c.code, transactionAmount: Number(transactionAmount), charges: lines.map((l) => ({ code: l.chargeCode, description: l.chargeDescription, amount: m(l.amount) })), totalCharge: m(lines.reduce((t, l) => t + l.amount, 0)) };
    },
  },
  {
    name: 'GetStandingOrderTypes', caption: 'Standing order classes', params: [], returns: 'Json',
    run: async () => STANDING_ORDER_CLASSES,
  },

  /* ---------------------------------------------------------------- postings */
  {
    name: 'ChannelTransactions', caption: 'Post a channel transaction: DEPOSIT, WITHDRAWAL or LOAN_REPAYMENT (idempotent by channel reference)',
    params: [P('accountNumber', 'Code'), P('channelReference', 'Code'), P('transactionAmount', 'Decimal'), P('transactionTypeCode', 'Code'), P('phoneNo', 'Text', false), P('customerName', 'Text', false), P('billIdentifier', 'Code', false), P('narration', 'Text', false)],
    returns: 'Json',
    run: async ({ accountNumber, channelReference, transactionAmount, transactionTypeCode, phoneNo, customerName, billIdentifier, narration }, ctx) => {
      const ref = str(channelReference); if (!ref) throw new AppError('channelReference is required', 'VALIDATION');
      const type = String(transactionTypeCode).toUpperCase().replace(/[^A-Z_]/g, '');
      const { canAction } = await import('../permissions.ts');
      const need = type === 'DEPOSIT' ? 'SAVINGS_DEPOSIT' : type === 'WITHDRAWAL' ? 'SAVINGS_WITHDRAW' : type === 'LOAN_REPAYMENT' ? 'LOAN_REPAY' : null;
      if (!need) throw new AppError('transactionTypeCode must be DEPOSIT, WITHDRAWAL or LOAN_REPAYMENT (ACCOUNT_TRANSFER uses InterAccountTransfer)', 'VALIDATION');
      if (!canAction(ctx.user, need)) throw new AppError(`This user lacks the ${need} permission`, 'FORBIDDEN');
      const dup = await existingByKey(`CH-${ref}`);
      if (dup) return { duplicate: true, channelReference: ref, transactionNo: dup.txn_ref, amount: m(Math.abs(dup.amount)), balance: m(dup.running_balance) };
      const who = [str(customerName), str(phoneNo), str(billIdentifier)].filter(Boolean).join(' · ');
      const description = str(narration) ?? `${type.replace('_', ' ')} via channel ${ref}${who ? ` (${who})` : ''}`;
      if (type === 'LOAN_REPAYMENT') {
        const l = await loanByNo(accountNumber);
        const res = await repay({ loanId: l.id, amount: cents(transactionAmount), channel: 'MPESA', description, user: ctx.actor, idempotencyKey: `CH-${ref}` });
        return { duplicate: false, channelReference: ref, loanNo: l.loan_no, journalNo: res.journal_no, principal: m(res.principal), interest: m(res.interest), penalty: m(res.penalty), closed: res.closed };
      }
      const a = await accountByNo(accountNumber);
      const res = type === 'DEPOSIT'
        ? await deposit({ accountId: a.id, amount: cents(transactionAmount), channel: 'MPESA', description, reference: ref, user: ctx.actor, idempotencyKey: `CH-${ref}` })
        : await withdraw({ accountId: a.id, amount: cents(transactionAmount), channel: 'MPESA', description, user: ctx.actor, idempotencyKey: `CH-${ref}` });
      return { duplicate: !!res.duplicate, channelReference: ref, transactionNo: res.txn.txn_ref, accountNo: a.account_no, amount: Number(transactionAmount), charge: m(res.fee ?? 0), balance: m(res.balance) };
    },
  },
  {
    name: 'InterAccountTransfer', caption: 'Move money between two member accounts (idempotent by channel reference)',
    params: [P('debitAccountNumber', 'Code'), P('creditAccountNumber', 'Code'), P('channelReference', 'Code'), P('transactionAmount', 'Decimal'), P('narration', 'Text', false)],
    returns: 'Json', action: 'SAVINGS_WITHDRAW',
    run: async ({ debitAccountNumber, creditAccountNumber, channelReference, transactionAmount, narration }, ctx) => {
      const ref = str(channelReference); if (!ref) throw new AppError('channelReference is required', 'VALIDATION');
      const from = await accountByNo(debitAccountNumber); const to = await accountByNo(creditAccountNumber);
      if (from.id === to.id) throw new AppError('Debit and credit accounts must differ', 'VALIDATION');
      const dup = await existingByKey(`CH-${ref}-OUT`);
      if (dup) return { duplicate: true, channelReference: ref, transactionNo: dup.txn_ref };
      const amount = cents(transactionAmount);
      const text = str(narration) ?? `Transfer ${from.account_no} → ${to.account_no} (${ref})`;
      const result = await tx(async () => {
        const out = await withdraw({ accountId: from.id, amount, channel: 'SYSTEM', description: text, user: ctx.actor, idempotencyKey: `CH-${ref}-OUT` });
        const inn = await deposit({ accountId: to.id, amount, channel: 'SYSTEM', description: text, reference: `${ref}-IN`, user: ctx.actor, idempotencyKey: `CH-${ref}-IN` });
        return { out, inn };
      });
      return { duplicate: false, channelReference: ref, amount: Number(transactionAmount), debit: { accountNo: from.account_no, transactionNo: result.out.txn.txn_ref, balance: m(result.out.balance) }, credit: { accountNo: to.account_no, transactionNo: result.inn.txn.txn_ref, balance: m(result.inn.balance) } };
    },
  },
  {
    name: 'TransactionReversal', caption: 'Reverse a channel transaction by its transaction number or channel reference', params: [P('originalTransactionRef', 'Code'), P('reason', 'Text', false)], returns: 'Json', action: 'SAVINGS_REVERSE',
    run: async ({ originalTransactionRef, reason }, ctx) => {
      const ref = String(originalTransactionRef).trim();
      // By transaction number, or by the channel reference the posting was made under.
      const t = await one<{ id: number; txn_ref: string; status: string; savings_account_id: number | null }>(
        `SELECT t.id, t.txn_ref, t.status, t.savings_account_id FROM txn t LEFT JOIN journal j ON j.id = t.journal_id
         WHERE t.txn_ref = ? OR t.reference_no = ? OR j.idempotency_key IN (?, ?) OR j.reference = ? ORDER BY t.id DESC LIMIT 1`, ref, ref, `CH-${ref}`, `CH-${ref}-OUT`, ref);
      if (!t) throw new AppError(`Transaction ${ref} not found`, 'NOT_FOUND');
      if (!t.savings_account_id) throw new AppError('Only savings account transactions can be reversed here', 'VALIDATION');
      const res = await reverseTxn({ txnId: t.id, reason: str(reason) ?? `Channel reversal of ${ref}`, user: ctx.actor });
      return { reversed: t.txn_ref, journalNo: res.journal_no, balance: m(res.balance) };
    },
  },
  {
    name: 'SubmitStandingOrderRequest', caption: 'Create a standing order and send it for approval',
    params: [P('memberNo', 'Code'), P('sourceAccountNo', 'Code'), P('standingOrderClass', 'Code'), P('amount', 'Decimal'), P('startDate', 'Date'), P('runPeriodMonths', 'Integer', false), P('destinationAccountNo', 'Code', false), P('destinationLoanNo', 'Code', false), P('description', 'Text', false), P('sweep', 'Boolean', false)],
    returns: 'Json', action: 'STANDING_ORDERS_CREATE',
    run: async ({ memberNo, sourceAccountNo, standingOrderClass, amount, startDate, runPeriodMonths, destinationAccountNo, destinationLoanNo, description, sweep }, ctx) => {
      const r = await memberByNo(memberNo); const src = await accountByNo(sourceAccountNo);
      if (src.member_id !== r.id) throw new AppError(`${src.account_no} does not belong to ${r.member_no}`, 'VALIDATION');
      const cls = String(standingOrderClass).toUpperCase() as StandingOrderClass;
      if (!STANDING_ORDER_CLASSES.some((c) => c.code === cls)) throw new AppError('standingOrderClass must be INTERNAL, EXTERNAL or LOAN', 'VALIDATION');
      if (cls === 'EXTERNAL') throw new AppError('External standing orders are set up at the branch — the destination bank must be verified', 'VALIDATION');
      const dest = cls === 'INTERNAL' ? await accountByNo(destinationAccountNo) : null;
      const loan = cls === 'LOAN' ? await loanByNo(destinationLoanNo) : null;
      const months = Number(runPeriodMonths) || null;
      const { no } = await createStandingOrder({
        memberId: r.id, accountId: src.id, standingOrderClass: cls, amountType: sweep ? 'SWEEP' : 'FIXED', amount: cents(amount),
        destinationMemberId: dest ? dest.member_id : null, destinationAccountId: dest?.id ?? null, destinationLoanId: loan?.id ?? null,
        postingDescription: str(description) ?? `Standing order ${cls.toLowerCase()} via channel`, runType: 'SPECIFIC_DAY', runFromDay: Number(String(startDate).slice(8, 10)) || 1,
        startDate: String(startDate), tillFurtherNotice: !months, periodMonths: months,
      }, ctx.actor);
      let status = 'Open'; let note: string | null = null;
      try { const s = await submitStandingOrder(no, ctx.actor); status = s.autoApproved ? 'Approved' : 'Pending Approval'; } catch (e) { note = (e as Error).message; }
      return { standingOrderNo: no, status, note };
    },
  },
];

export const CHANNELS_INTEGRATION: WsCodeunit = {
  kind: 'CODEUNIT', id: 50302, name: 'Channels Integration', caption: 'Channels Integration', procedures,
};

