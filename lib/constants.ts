/*
 * Domain vocabulary shared by server and client code.
 *
 * These lists populate <select> options, so client components import them. They
 * must therefore stay free of any database import: pulling a constant out of
 * lib/members.ts or lib/savings.ts dragged the database client into the browser
 * bundle, and webpack failed the build on its `require('fs')`.
 */
import type { Channel, GlAccountType, InterestMethod, LoanStatus, MemberStatus, SavingsCategory, UserStatus } from './types.ts';

export const MEMBER_STATUSES: MemberStatus[] =
  ['ACTIVE', 'DORMANT', 'APPLICATION', 'SUSPENDED', 'EXITED'];

export const MEMBER_TITLES = ['', 'Mr.', 'Ms.', 'Mrs.', 'Dr.', 'Prof.'];
export const GENDERS = ['', 'MALE', 'FEMALE'];
export const MARITAL_STATUSES = ['', 'SINGLE', 'MARRIED', 'DIVORCED', 'WIDOWED'];
export const EMPLOYMENT_STATUSES = ['', 'PERMANENT', 'CONTRACT', 'SELF_EMPLOYED', 'RETIRED'];

export const DEPOSIT_CHANNELS: Channel[] = ['TELLER', 'MPESA', 'BANK', 'CHECKOFF'];
export const WITHDRAWAL_CHANNELS: Channel[] = ['TELLER', 'MPESA', 'BANK'];
export const DISBURSE_CHANNELS: Channel[] = ['BANK', 'MPESA', 'TELLER'];
export const REPAY_CHANNELS: Channel[] = ['TELLER', 'CHECKOFF', 'MPESA', 'BANK'];

export const SAVINGS_CATEGORIES: SavingsCategory[] = ['SHARE', 'SAVINGS', 'DEPOSIT', 'FIXED'];
export const PRODUCT_STATUSES = ['ACTIVE', 'INACTIVE'];

export const LOAN_STATUSES: LoanStatus[] = ['PENDING', 'APPROVED', 'DISBURSED', 'CLOSED', 'REJECTED'];
export const INTEREST_METHODS: InterestMethod[] = ['REDUCING', 'FLAT'];

export const GL_ACCOUNT_TYPES: GlAccountType[] =
  ['ASSET', 'LIABILITY', 'EQUITY', 'INCOME', 'EXPENSE'];

/** Account types whose balance increases on the debit side. */
export const NATURAL_DEBIT_TYPES: GlAccountType[] = ['ASSET', 'EXPENSE'];

export const USER_STATUSES: UserStatus[] = ['ACTIVE', 'SUSPENDED', 'DISABLED'];
export const BRANCH_STATUSES = ['ACTIVE', 'CLOSED'];

export const SOCIETY_TYPES = [
  'Deposit Taking SACCO',
  'Non-Deposit Taking SACCO',
  'Investment Co-operative',
  'Housing Co-operative',
];

/** Suggested document labels; the field is free text so a society can use its own. */
export const ATTACHMENT_CATEGORIES = [
  'KYC document', 'National ID', 'Payslip', 'Bank statement',
  'Loan application', 'Security / collateral', 'Correspondence', 'Other',
];

export const MONTH_NAMES = [
  'January', 'February', 'March', 'April', 'May', 'June',
  'July', 'August', 'September', 'October', 'November', 'December',
];
