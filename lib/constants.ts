/*
 * Domain vocabulary shared by server and client code.
 *
 * These lists populate <select> options, so client components import them. They
 * must therefore stay free of any database import: pulling a constant out of
 * lib/members.ts or lib/savings.ts dragged the database client into the browser
 * bundle, and webpack failed the build on its `require('fs')`.
 */
import type {
  Channel, ChargeCalculationType, ChargeRateType, ChargeTransactionType, CheckoffSearchType, CollateralCategory,
  DocumentStatus, GlAccountStructureType, GlAccountType, InterestMethod, JobQueueStatus, JobQueueType, LoanCalculatorRateType,
  LoanChargeCalculationType, LoanRecoveryMode, LoanStatus, MemberCategoryType, MemberStatus, PayMode, SalaryAppraisalLineType,
  TransactionRecoveryDeductionType, TransactionRecoveryType,
  SalaryAppraisalSpecialType, SavingsAccountStatus, SavingsCategory, StandingOrderAmountType, StandingOrderClass,
  StandingOrderRunType, UserStatus,
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

/** How a manual external loan disbursement/repayment was actually paid — shown alongside the
 *  Bank/Cashbook (Payment Channel) picker, not instead of it. See lib/types.ts's PayMode. */
export const PAY_MODES: { value: PayMode; label: string }[] = [
  { value: 'CASH', label: 'Cash' },
  { value: 'MPESA', label: 'M-Pesa' },
  { value: 'BANK', label: 'Bank Transfer' },
  { value: 'EFT', label: 'EFT' },
  { value: 'CHEQUE', label: 'Cheque' },
];

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

/** System Automation (Job Queue)'s own Job Type/Status option lists (Admin Centre → System
 *  Automation). Job Type is deliberately a short, hand-maintained list — see JobQueueType. */
export const JOB_QUEUE_TYPES: { value: JobQueueType; label: string }[] = [
  { value: 'ENTRANCE_FEE_RECOVERY', label: 'Entrance Fee Recovery' },
  { value: 'MEMBER_STATUS_UPDATE', label: 'Member Status Update' },
  { value: 'STANDING_ORDER_RUN', label: 'Standing Order Run' },
];
export const JOB_QUEUE_STATUSES: JobQueueStatus[] = ['READY', 'ON HOLD'];

/** Standing Order's own option lists (Admin Centre has nothing to configure here — these are
 *  chosen per order on the New/Edit form) — see lib/standingOrders.ts's file header for what
 *  AL's fuller STO Types enum collapses into. */
export const STANDING_ORDER_CLASSES: { value: StandingOrderClass; label: string }[] = [
  { value: 'INTERNAL', label: 'Transfer to an account' },
  { value: 'LOAN_REPAYMENT', label: 'Loan repayment' },
];
export const STANDING_ORDER_AMOUNT_TYPES: { value: StandingOrderAmountType; label: string }[] = [
  { value: 'FIXED', label: 'Fixed amount' },
  { value: 'SWEEP', label: 'Sweep (everything available)' },
  { value: 'AMOUNT_BASED', label: 'Amount based (sweep once a threshold is reached)' },
];
/** Meaningful only when amount_type = FIXED. */
export const STANDING_ORDER_RUN_TYPES: { value: StandingOrderRunType; label: string }[] = [
  { value: 'SPECIFIC_DAY', label: 'A specific day each month' },
  { value: 'END_MONTH', label: 'End of month' },
  { value: 'DAILY', label: 'Daily' },
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
  { value: 'Member Reactivation', label: 'Member Reactivation' },
];

export const CHARGE_CALCULATION_TYPES: { value: ChargeCalculationType; label: string }[] = [
  { value: 'SCHEME', label: 'Calculation Scheme' },
  { value: 'PERCENT_OF_CHARGE', label: 'Percentage of Charge' },
];

export const CHARGE_RATE_TYPES: { value: ChargeRateType; label: string }[] = [
  { value: 'FLAT', label: 'Flat Rate' },
  { value: 'PERCENTAGE', label: 'Percentage' },
];

/** Transaction Recoveries — ported from Tab52204065, narrowed to the two recovery types this
 *  app can act on (see lib/types.ts's TransactionRecoveryType). */
export const TRANSACTION_RECOVERY_TYPES: { value: TransactionRecoveryType; label: string }[] = [
  { value: 'LOAN', label: 'Loan' },
  { value: 'STANDING_ORDER', label: 'Standing Order' },
  { value: 'INTERNAL_DEPOSIT', label: 'Internal Deposit' },
];

export const LOAN_DEDUCTION_TYPES: { value: TransactionRecoveryDeductionType; label: string }[] = [
  { value: 'INSTALLMENT', label: 'Monthly Installment' },
  { value: 'ARREARS', label: 'Arrears Amount' },
  { value: 'BALANCE', label: 'Loan Balance' },
];

export const INTERNAL_DEPOSIT_DEDUCTION_TYPES: { value: TransactionRecoveryDeductionType; label: string }[] = [
  { value: 'FULL_REMAINING', label: 'Full Remaining Amount' },
  { value: 'BOOST_TO_MINIMUM', label: 'Boost to Minimum Balance' },
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

/** Which column of an uploaded CSV identifies each row's member — see lib/types.ts's
 *  CheckoffSearchType. */
export const CHECKOFF_SEARCH_TYPES: { value: CheckoffSearchType; label: string }[] = [
  { value: 'MEMBER_NO', label: 'Member Number' },
  { value: 'ID_NUMBER', label: 'ID Number' },
  { value: 'PAYROLL_NO', label: 'Payroll No.' },
  { value: 'FOSA_NUMBER', label: 'FOSA Number' },
];

export const RECOVERY_MODES: { value: LoanRecoveryMode; label: string }[] = [
  { value: 'DIRECT', label: 'Direct — member repays over the counter' },
  { value: 'CHECKOFF', label: 'Checkoff — recovered via employer payroll deduction' },
  { value: 'STANDING_ORDER', label: 'Standing Order — auto-created and recovered on its own schedule' },
];

export const FD_MATURITY_INSTRUCTIONS: { value: 'ROLLOVER_PRINCIPAL' | 'ROLLOVER_NET' | 'LIQUIDATE'; label: string }[] = [
  { value: 'LIQUIDATE', label: 'Liquidate — pay out principal and interest' },
  { value: 'ROLLOVER_PRINCIPAL', label: 'Roll over principal — reinvest the principal, pay out interest' },
  { value: 'ROLLOVER_NET', label: 'Roll over net — reinvest principal and interest together' },
];

export const FD_INTEREST_CALC_TYPES: { value: 'FLAT' | 'REDUCING'; label: string }[] = [
  { value: 'FLAT', label: 'Flat rate' },
  { value: 'REDUCING', label: 'Reducing balance' },
];

export const SALARY_APPRAISAL_TYPES: { value: 'AVERAGE_NET' | 'LOWEST_NET'; label: string }[] = [
  { value: 'AVERAGE_NET', label: 'Average net salary' },
  { value: 'LOWEST_NET', label: 'Lowest net salary' },
];

export const REPLACEMENT_TYPES: { value: 'GUARANTOR' | 'COLLATERAL' | 'FIXED_DEPOSIT'; label: string }[] = [
  { value: 'GUARANTOR', label: 'Member / Guarantor' },
  { value: 'FIXED_DEPOSIT', label: 'Fixed Deposit' },
  { value: 'COLLATERAL', label: 'Collateral' },
];

export const MONTH_NAMES = [
  'January', 'February', 'March', 'April', 'May', 'June',
  'July', 'August', 'September', 'October', 'November', 'December',
];
