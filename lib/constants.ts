/*
 * Domain vocabulary shared by server and client code.
 *
 * These lists populate <select> options, so client components import them. They
 * must therefore stay free of any database import: pulling a constant out of
 * lib/members.ts or lib/savings.ts dragged the database client into the browser
 * bundle, and webpack failed the build on its `require('fs')`.
 */
import type {
  Channel, ChargeCalculationType, ChargeRateType, ChargeTransactionType, CollateralCategory, DocumentStatus,
  GlAccountStructureType, GlAccountType, InterestMethod, LoanCalculatorRateType, LoanChargeCalculationType,
  LoanStatus, MemberCategoryType, MemberStatus, SalaryAppraisalLineType, SalaryAppraisalSpecialType,
  SavingsAccountStatus, SavingsCategory, UserStatus,
} from './types.ts';

export const MEMBER_STATUSES: MemberStatus[] =
  [ 'NOT PAID UP','ACTIVE','INACTIVE','DORMANT','WITHDRAWN','DECEASED'];

export const MEMBER_TYPES = ['INDIVIDUAL', 'CORPORATE', 'GROUP'];
export const MEMBER_TITLES = ['', 'Mr.', 'Ms.', 'Mrs.', 'Dr.', 'Prof.'];
export const GENDERS = ['', 'MALE', 'FEMALE'];
export const MARITAL_STATUSES = ['', 'SINGLE', 'MARRIED', 'DIVORCED', 'WIDOWED'];
export const EMPLOYMENT_STATUSES = ['', 'PERMANENT', 'CONTRACT', 'SELF_EMPLOYED', 'RETIRED'];

/** Relationship options for next-of-kin and nominee records. */
export const RELATIONSHIPS = [
  '', 'Spouse', 'Son', 'Daughter', 'Father', 'Mother', 'Brother', 'Sister', 'Nephew', 'Niece','Guardian', 'Other',
];

/** Designation options for a non-individual member's signatories. */
export const SIGNATORY_DESIGNATIONS = [
  '', 'Chairman', 'Vice Chairman', 'Treasurer', 'Vice Treasurer', 'Secretary', 'Vice Secretary', 'Member', 'Other',
];

export const DEPOSIT_CHANNELS: Channel[] = ['TELLER', 'MPESA', 'BANK', 'CHECKOFF'];
export const WITHDRAWAL_CHANNELS: Channel[] = ['TELLER', 'MPESA', 'BANK'];
export const DISBURSE_CHANNELS: Channel[] = ['BANK', 'MPESA', 'TELLER'];
export const REPAY_CHANNELS: Channel[] = ['TELLER', 'CHECKOFF', 'MPESA', 'BANK'];

export const SAVINGS_CATEGORIES: SavingsCategory[] = ['WITHDRAWABLE DEPOSIT', 'NON WITHDRAWABLE DEPOSIT', 'JUNIOR ACCOUNT', 'SHARE CAPITAL ACCOUNT', 'FIXED DEPOSIT ACCOUNT', 'LOAN ACCOUNT', 'INVESTMENTS ACCOUNT', 'HOLDING ACCOUNT', 'HOLIDAY ACCOUNT', 'SHARE TRADING ACCOUNT', 'BENEVOLENT ACCOUNT', 'SCHOOL FEE ACCOUNT'];
export const PRODUCT_STATUSES = ['ACTIVE', 'INACTIVE'];
export const SAVINGS_ACCOUNT_STATUSES: SavingsAccountStatus[] = ['ACTIVE', 'DORMANT', 'FROZEN', 'CLOSED', 'INACTIVE'];

export const MEMBER_CATEGORY_TYPES: { value: MemberCategoryType; label: string }[] = [
  { value: 'INDIVIDUAL', label: 'Individual' },
  { value: 'GROUP', label: 'Group' },
  { value: 'INSTITUTION', label: 'Institution' },
  { value: 'MICRO_FINANCE', label: 'Micro-finance group' },
  { value: 'GROUP_MEMBER', label: 'Group member' },
  { value: 'JOINT_ACCOUNT', label: 'Joint account' },
];
export const MEMBER_CATEGORY_STATUSES = ['ACTIVE', 'INACTIVE'];

export const LOAN_STATUSES: LoanStatus[] = ['OPEN','PENDING APPROVAL', 'APPROVED', 'DISBURSED', 'CLOSED', 'ARCHIVED','WRITTEN OFF',];
export const INTEREST_METHODS: InterestMethod[] = ['REDUCING', 'FLAT'];

/** Salary Appraisal Parameters' own Type/Special type option lists (Admin Centre → Sacco
 *  Products → Salary Appraisal Parameters). Special type is only meaningful on an Earning
 *  line — it flags the one line the one-third affordability cap is computed against. */
export const SALARY_APPRAISAL_LINE_TYPES: { value: SalaryAppraisalLineType; label: string }[] = [
  { value: 'EARNING', label: 'Earning' },
  { value: 'DEDUCTION', label: 'Deduction' },
];
export const SALARY_APPRAISAL_SPECIAL_TYPES: { value: SalaryAppraisalSpecialType; label: string }[] = [
  { value: 'NONE', label: 'None' },
  { value: 'BASIC_SALARY', label: 'Basic Salary (drives the 1/3 cap)' },
];

/** Loan Calculator's Rate Type options (Table 52204036) — see LoanCalculatorRateType. */
export const LOAN_CALCULATOR_RATE_TYPES: { value: LoanCalculatorRateType; label: string }[] = [
  { value: 'AMORTISED', label: 'Amortised (level installment)' },
  { value: 'REDUCING_BALANCE', label: 'Reducing Balance (constant principal)' },
  { value: 'STRAIGHT_LINE', label: 'Straight Line (flat interest)' },
];

/** Loan Calculator's default Rate Type per product Interest Method — mirrors Table 52204036's
 *  "Rate Type" := SaccoProduct."Interest Repayment Method" default, mapped onto the calculator's
 *  three-way vocabulary (REDUCING here means "level installment", i.e. AMORTISED). */
export const LOAN_CALCULATOR_RATE_TYPE_FOR_METHOD: Record<InterestMethod, LoanCalculatorRateType> = {
  REDUCING: 'AMORTISED',
  FLAT: 'STRAIGHT_LINE',
};

export const GL_ACCOUNT_TYPES: GlAccountType[] =
  ['ASSET', 'LIABILITY', 'EQUITY', 'INCOME', 'EXPENSE'];

/** Account types whose balance increases on the debit side. */
export const NATURAL_DEBIT_TYPES: GlAccountType[] = ['ASSET', 'EXPENSE'];

/** Business Central's G/L "Account Type" — the account's structural role in the chart,
 *  as opposed to `type` (ASSET/LIABILITY/…) above, which is its financial-statement
 *  category. Only POSTING accounts ever carry ledger entries or a balance of their own;
 *  TOTAL and END_TOTAL roll one up from the Totaling range of accounts they name. */
export const GL_ACCOUNT_STRUCTURE_TYPES: { value: GlAccountStructureType; label: string }[] = [
  { value: 'POSTING', label: 'Posting' },
  { value: 'HEADING', label: 'Heading' },
  { value: 'TOTAL', label: 'Total' },
  { value: 'BEGIN_TOTAL', label: 'Begin-Total' },
  { value: 'END_TOTAL', label: 'End-Total' },
];

export const USER_STATUSES: UserStatus[] = ['ACTIVE', 'SUSPENDED', 'DISABLED'];

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

/** The full "Document Status" vocabulary — a member application only drives itself through some of these. */
export const DOCUMENT_STATUSES: DocumentStatus[] = [
  'Open', 'Pending Approval', 'Approved', 'Processed'
];

/** Every SACCO transaction category a Transaction Charge can be configured for — see
 *  lib/types.ts's ChargeTransactionType for provenance (Table 52204021's Posting Transaction
 *  Type). */
export const CHARGE_TRANSACTION_TYPES: { value: ChargeTransactionType; label: string }[] = [
  { value: 'General', label: 'General' },
  { value: 'Cash Deposit', label: 'Cash Deposit' },
  { value: 'Cash Withdrawal', label: 'Cash Withdrawal' },
  { value: 'ATM', label: 'ATM' },
  { value: 'Loan Disbursal', label: 'Loan Disbursal' },
  { value: 'Interest Due', label: 'Interest Due' },
  { value: 'Interest Paid', label: 'Interest Paid' },
  { value: 'Principal Paid', label: 'Principal Paid' },
  { value: 'Acc. Transfer', label: 'Acc. Transfer' },
  { value: 'Cheque Deposit', label: 'Cheque Deposit' },
  { value: 'Bankers Cheque', label: 'Bankers Cheque' },
  { value: 'Fixed Deposit', label: 'Fixed Deposit' },
  { value: 'End Month Salary', label: 'End Month Salary' },
  { value: 'Checkoff Pay', label: 'Checkoff Pay' },
  { value: 'Teller-Treasury', label: 'Teller-Treasury' },
  { value: 'Disb. Rec', label: 'Disb. Rec' },
  { value: 'Penalty Due', label: 'Penalty Due' },
  { value: 'Penalty Paid', label: 'Penalty Paid' },
  { value: 'Divinded Processing', label: 'Divinded Processing' },
  { value: 'Charge', label: 'Charge' },
  { value: 'Registration Fee', label: 'Registration Fee' },
  { value: 'Standing Order', label: 'Standing Order' },
  { value: 'Benevolent Fund', label: 'Benevolent Fund' },
  { value: 'Statement Charge', label: 'Statement Charge' },
];

export const CHARGE_CALCULATION_TYPES: { value: ChargeCalculationType; label: string }[] = [
  { value: 'SCHEME', label: 'Calculation Scheme' },
  { value: 'PERCENT_OF_CHARGE', label: 'Percentage of Charge' },
];

export const CHARGE_RATE_TYPES: { value: ChargeRateType; label: string }[] = [
  { value: 'FLAT', label: 'Flat Rate' },
  { value: 'PERCENTAGE', label: 'Percentage' },
];

/** Loan Product Charges' own Calculation Method — a flat Percentage of the loan principal, or
 *  Calculate from Scheme (an amount-banded tariff table). Distinct from the generic
 *  CHARGE_CALCULATION_TYPES above: a loan product charge's base is always the principal, so
 *  there's no Percentage-of-Charge chaining to offer here. */
export const LOAN_CHARGE_CALCULATION_TYPES: { value: LoanChargeCalculationType; label: string }[] = [
  { value: 'PERCENTAGE', label: 'Percentage' },
  { value: 'SCHEME', label: 'Calculate from Scheme' },
];

/** Collateral module — collateral_type.category / collateral_application.category. */
export const COLLATERAL_CATEGORIES: { value: CollateralCategory; label: string }[] = [
  { value: 'VEHICLE', label: 'Vehicle' },
  { value: 'REAL_ESTATE', label: 'Real Estate' },
];

/** Suggested labels for a collateral application's attachments — the field is free text. */
export const COLLATERAL_ATTACHMENT_CATEGORIES = [
  'Collateral Photo', 'Title Deed', 'Logbook', 'Valuation Report', 'Insurance Certificate', 'Other',
];

export const NATIONALITIES: { value: 'LOCAL' | 'DIASPORA'; label: string }[] = [
  { value: 'LOCAL', label: 'Local' },
  { value: 'DIASPORA', label: 'Diaspora' },
];

export const EXIT_TYPES: { value: 'GENERAL' | 'RETIREE' | 'DECEASED'; label: string }[] = [
  { value: 'GENERAL', label: 'General' },
  { value: 'RETIREE', label: 'Retiree' },
  { value: 'DECEASED', label: 'Deceased' },
];

export const PAYOUT_METHODS: { value: 'FOSA' | 'BANK_TRANSFER'; label: string }[] = [
  { value: 'FOSA', label: 'FOSA withdrawal' },
  { value: 'BANK_TRANSFER', label: 'Bank transfer' },
];

export const BATCH_TYPES: { value: 'CHECKOFF' | 'SALARY'; label: string }[] = [
  { value: 'CHECKOFF', label: 'Checkoff (loan recovery)' },
  { value: 'SALARY', label: 'Salary (FOSA credit)' },
];

export const RECOVERY_MODES: { value: 'DIRECT' | 'CHECKOFF'; label: string }[] = [
  { value: 'DIRECT', label: 'Direct — member repays over the counter' },
  { value: 'CHECKOFF', label: 'Checkoff — recovered via employer payroll deduction' },
];

export const MONTH_NAMES = [
  'January', 'February', 'March', 'April', 'May', 'June',
  'July', 'August', 'September', 'October', 'November', 'December',
];
