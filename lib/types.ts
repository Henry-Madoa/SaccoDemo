/**
 * Domain types.
 *
 * These mirror the PostgreSQL schema in prisma/schema.prisma one-for-one. Flag
 * columns are `0 | 1` integers rather than `boolean`, so that
 * `if (product.allow_withdrawal)` visibly tests a number.
 *
 * Every monetary field is an INTEGER count of minor units (cents). The `Cents`
 * alias exists to make that visible at each use site.
 */

export type Cents = number;
export type IsoDate = string;      // YYYY-MM-DD
export type IsoDateTime = string;  // ISO-8601 UTC
export type Flag = 0 | 1;

/* ------------------------------------------------------------ organisation */

export interface Organisation {
  id: 1;
  name: string;
  short_name: string | null;
  motto: string | null;
  registration_no: string | null;
  sasra_licence_no: string | null;
  kra_pin: string | null;
  society_type: string | null;
  physical_address: string | null;
  postal_address: string | null;
  city: string | null;
  county: string | null;
  country: string | null;
  phone_primary: string | null;
  phone_secondary: string | null;
  email: string | null;
  website: string | null;
  paybill_no: string | null;
  bank_name: string | null;
  bank_account_no: string | null;
  logo: string | null;
  currency_code: string;
  currency_symbol: string;
  locale: string;
  timezone: string;
  date_format: string;
  fy_start_month: number;
  fy_start_day: number;
  statement_footer: string | null;
  updated_at: IsoDateTime | null;
  updated_by: string | null;
}

/** The branding and money-formatting subset every page needs. */
export type OrgBrand = Pick<
  Organisation,
  'name' | 'short_name' | 'motto' | 'logo' | 'currency_code' | 'currency_symbol'
  | 'locale' | 'timezone' | 'website' | 'phone_primary' | 'email' | 'sasra_licence_no'
>;

export type ThemeTokens = Record<string, string>;

export interface Theme {
  preset: string;
  tokens: ThemeTokens;
  updated_at?: IsoDateTime | null;
  updated_by?: string | null;
}

export interface ThemePreset {
  key: string;
  label: string;
  tokens: ThemeTokens;
}

export type TokenType = 'color' | 'text' | 'select';

export interface TokenDefinition {
  key: string;
  label: string;
  type: TokenType;
  help?: string;
  options?: string[];
}

export interface TokenGroup {
  group: string;
  items: TokenDefinition[];
}

/* -------------------------------------------------------------------- RBAC */

export type PermissionResource = 'MEMBER' | 'SAVINGS' | 'LOAN' | 'GL' | 'REPORT' | 'ADMIN';

/** e.g. `LOAN:APPROVE`. Wildcards (`*`, `LOAN:*`) are valid stored values too. */
export type Permission = string;

export interface Branch {
  id: number;
  code: string;
  name: string;
  town: string | null;
  phone: string | null;
  is_head_office: Flag;
  status: 'ACTIVE' | 'CLOSED';
  created_at: IsoDateTime | null;
}

export interface Role {
  id: number;
  name: string;
  description: string | null;
  is_system: Flag;
  permissions: string; // JSON array as stored
}

/** A role row with `permissions` parsed and its user count rolled up. */
export interface RoleWithUsage extends Omit<Role, 'permissions'> {
  permissions: Permission[];
  userCount: number;
}

export type UserStatus = 'ACTIVE' | 'SUSPENDED' | 'DISABLED';

export interface AppUser {
  id: number;
  username: string;
  full_name: string;
  email: string | null;
  phone: string | null;
  password_hash: string;
  role_id: number;
  branch_id: number | null;
  status: UserStatus;
  last_login_at: IsoDateTime | null;
  created_at: IsoDateTime | null;
}

/**
 * The signed-in user, as returned by userFromToken().
 * `password_hash` is deleted before the record leaves the auth layer, which is
 * why it is omitted here rather than marked optional.
 */
export interface SessionUser extends Omit<AppUser, 'password_hash'> {
  role_name: string;
  branch_name: string | null;
  permissionList: Permission[];
}

/** Anything that can be recorded as the actor on an audit entry. */
export interface Actor {
  id: number;
  username: string;
}

export interface UserListRow {
  id: number;
  username: string;
  full_name: string;
  email: string | null;
  phone: string | null;
  status: UserStatus;
  last_login_at: IsoDateTime | null;
  created_at: IsoDateTime | null;
  role_name: string;
  role_id: number;
  branch_name: string | null;
  branch_id: number | null;
}

export interface AuditEntry {
  id: number;
  at: IsoDateTime;
  user_id: number | null;
  username: string | null;
  action: string;
  entity: string | null;
  entity_id: string | null;
  detail: string | null;
  ip: string | null;
}

/* ----------------------------------------------------------------- members */

export type MemberStatus = 'APPLICATION' | 'ACTIVE' | 'DORMANT' | 'SUSPENDED' | 'EXITED';

export interface Member {
  id: number;
  member_no: string;
  member_type: 'INDIVIDUAL' | 'CORPORATE' | 'GROUP';
  title: string | null;
  first_name: string;
  middle_name: string | null;
  last_name: string;
  national_id: string | null;
  kra_pin: string | null;
  date_of_birth: IsoDate | null;
  gender: string | null;
  marital_status: string | null;
  phone: string | null;
  email: string | null;
  postal_address: string | null;
  physical_address: string | null;
  county: string | null;
  employer: string | null;
  employment_status: string | null;
  staff_no: string | null;
  gross_income: Cents;
  other_deductions: Cents;
  nok_name: string | null;
  nok_relationship: string | null;
  nok_phone: string | null;
  branch_id: number | null;
  status: MemberStatus;
  kyc_verified: Flag;
  join_date: IsoDate | null;
  photo: string | null;
  front_id_image: string | null;
  back_id_image: string | null;
  signature_image: string | null;
  fingerprint1_image: string | null;
  fingerprint2_image: string | null;
  notes: string | null;
  created_at: IsoDateTime | null;
  created_by: string | null;
}

export interface MemberWithBranch extends Member {
  branch_name: string | null;
}

export interface MemberListRow extends MemberWithBranch {
  total_savings: Cents;
  loan_balance: Cents;
  /** Window-function total — the same on every row of the page. */
  total_count: number;
}

export interface MemberDetail {
  member: MemberWithBranch;
  accounts: SavingsAccountWithProduct[];
  loans: LoanWithProductName[];
  guaranteeing: GuarantorshipRow[];
  transactions: Txn[];
  appraisal: { deposits: Cents; exposure: Cents };
}

/* -------------------------------------------------------- chart of accounts */

export type GlAccountType = 'ASSET' | 'LIABILITY' | 'EQUITY' | 'INCOME' | 'EXPENSE';

export interface GlAccount {
  id: number;
  code: string;
  name: string;
  type: GlAccountType;
  parent_code: string | null;
  is_postable: Flag;
  balance: Cents;
  status: 'ACTIVE' | 'INACTIVE';
}

export interface TrialBalanceRow {
  id: number;
  code: string;
  name: string;
  type: GlAccountType;
  debit: Cents;
  credit: Cents;
  /** Signed balance in the natural direction of the account type. */
  net: Cents;
  debit_balance: Cents;
  credit_balance: Cents;
}

/* ---------------------------------------------------------------- journals */

export interface Journal {
  id: number;
  journal_no: string;
  value_date: IsoDate;
  posted_at: IsoDateTime;
  source_module: string;
  event_type: string;
  description: string | null;
  reference: string | null;
  member_id: number | null;
  amount: Cents;
  posted_by: string | null;
  reverses_id: number | null;
  reversed_by_id: number | null;
  idempotency_key: string | null;
}

export interface JournalListRow extends Journal {
  member_no: string | null;
  first_name: string | null;
  last_name: string | null;
}

export interface JournalLine {
  id: number;
  journal_id: number;
  line_no: number;
  gl_account_id: number;
  debit: Cents;
  credit: Cents;
  narration: string | null;
}

export interface JournalLineWithAccount extends JournalLine {
  code: string;
  name: string;
  type: GlAccountType;
}

/** A journal line as supplied to postJournal, before it is resolved and stored. */
export interface JournalLineInput {
  /** GL account id (number) or account code (string). */
  account: number | string;
  debit?: Cents;
  credit?: Cents;
  narration?: string | null;
}

export interface PostJournalOptions {
  valueDate: IsoDate;
  module: string;
  eventType: string;
  description?: string | null;
  reference?: string | null;
  memberId?: number | null;
  lines: JournalLineInput[];
  user?: Actor | null;
  idempotencyKey?: string | null;
}

export interface PostedJournal {
  id: number;
  journal_no: string;
  amount: Cents;
  /** Set when an idempotency key matched an existing journal. */
  duplicate?: boolean;
}

export interface LedgerLine extends JournalLine {
  journal_no: string;
  value_date: IsoDate;
  description: string | null;
  source_module: string;
}

export interface AccountingPeriod {
  id: number;
  code: string; // YYYY-MM
  start_date: IsoDate;
  end_date: IsoDate;
  status: 'OPEN' | 'CLOSED';
}

/* ----------------------------------------------------------------- savings */

export type SavingsCategory = 'SHARE' | 'SAVINGS' | 'DEPOSIT' | 'FIXED';
export type SavingsAccountStatus = 'ACTIVE' | 'DORMANT' | 'FROZEN' | 'CLOSED';
export type Channel = 'TELLER' | 'MPESA' | 'BANK' | 'CHECKOFF' | 'SYSTEM';

export interface SavingsProduct {
  id: number;
  code: string;
  name: string;
  category: SavingsCategory;
  min_balance: Cents;
  min_opening: Cents;
  interest_rate: number;
  allow_withdrawal: Flag;
  withdrawal_fee: Cents;
  is_loanable_base: Flag;
  withdrawal_notice_days: number;
  gl_control_id: number | null;
  gl_interest_exp_id: number | null;
  gl_fee_income_id: number | null;
  status: 'ACTIVE' | 'INACTIVE';
}

export interface SavingsProductWithUsage extends SavingsProduct {
  gl_control_code: string | null;
  gl_control_name: string | null;
  accounts: number;
  portfolio: Cents;
}

export interface SavingsAccount {
  id: number;
  account_no: string;
  member_id: number;
  product_id: number;
  balance: Cents;
  hold_amount: Cents;
  status: SavingsAccountStatus;
  opened_date: IsoDate | null;
  last_activity: IsoDate | null;
  version: number;
}

export interface SavingsAccountWithProduct extends SavingsAccount {
  product_name: string;
  product_code: string;
  category: SavingsCategory;
  min_balance: Cents;
  allow_withdrawal: Flag;
}

/** The joined shape getAccount() returns — product GL mappings and member name. */
export interface SavingsAccountFull extends SavingsAccountWithProduct {
  withdrawal_fee: Cents;
  gl_control_id: number;
  gl_fee_income_id: number;
  is_loanable_base: Flag;
  member_no: string;
  first_name: string;
  last_name: string;
}

export interface SavingsAccountListRow extends SavingsAccountWithProduct {
  member_no: string;
  first_name: string;
  last_name: string;
}

export interface Statement {
  account: SavingsAccountFull;
  opening: Cents;
  lines: Txn[];
}

/* ------------------------------------------------------------------- loans */

export type LoanStatus = 'PENDING' | 'APPROVED' | 'REJECTED' | 'DISBURSED' | 'CLOSED' | 'WRITTEN_OFF';
export type InterestMethod = 'REDUCING' | 'FLAT';
export type Classification = 'PERFORMING' | 'WATCH' | 'SUBSTANDARD' | 'DOUBTFUL' | 'LOSS';

export interface LoanProduct {
  id: number;
  code: string;
  name: string;
  interest_rate: number;
  interest_method: InterestMethod;
  max_term_months: number;
  min_amount: Cents;
  max_amount: Cents;
  deposit_multiplier: number;
  min_membership_months: number;
  processing_fee_pct: number;
  insurance_pct: number;
  penalty_rate: number;
  guarantors_required: number;
  max_dsr_pct: number;
  gl_receivable_id: number | null;
  gl_interest_income_id: number | null;
  gl_fee_income_id: number | null;
  gl_penalty_income_id: number | null;
  status: 'ACTIVE' | 'INACTIVE';
}

export interface LoanProductWithUsage extends LoanProduct {
  active_loans: number;
  portfolio: Cents;
}

export interface Loan {
  id: number;
  loan_no: string;
  member_id: number;
  product_id: number;
  principal: Cents;
  interest_rate: number;
  interest_method: InterestMethod;
  term_months: number;
  purpose: string | null;
  status: LoanStatus;
  applied_date: IsoDate | null;
  approved_date: IsoDate | null;
  approved_by: string | null;
  rejected_reason: string | null;
  disbursed_date: IsoDate | null;
  first_due_date: IsoDate | null;
  installment: Cents;
  total_interest: Cents;
  fees_charged: Cents;
  principal_balance: Cents;
  interest_balance: Cents;
  penalty_balance: Cents;
  principal_paid: Cents;
  interest_paid: Cents;
  arrears_amount: Cents;
  days_in_arrears: number;
  classification: Classification;
  disburse_to_account_id: number | null;
  created_by: string | null;
  version: number;
}

export interface LoanWithProductName extends Loan {
  product_name: string;
}

/** The joined shape getLoan() returns — product GL mappings and member details. */
export interface LoanFull extends LoanWithProductName {
  product_code: string;
  gl_receivable_id: number;
  gl_interest_income_id: number;
  gl_fee_income_id: number;
  gl_penalty_income_id: number;
  member_no: string;
  first_name: string;
  last_name: string;
  gross_income: Cents;
  other_deductions: Cents;
}

export interface LoanListRow extends LoanWithProductName {
  product_code: string;
  member_no: string;
  first_name: string;
  last_name: string;
}

export interface LoanScheduleRow {
  id: number;
  loan_id: number;
  installment_no: number;
  due_date: IsoDate;
  opening_balance: Cents;
  principal_due: Cents;
  interest_due: Cents;
  principal_paid: Cents;
  interest_paid: Cents;
  status: 'DUE' | 'PARTIAL' | 'PAID';
}

/** A schedule row as built by buildSchedule(), before it is persisted. */
export type ScheduleDraftRow = Pick<
  LoanScheduleRow, 'installment_no' | 'due_date' | 'opening_balance' | 'principal_due' | 'interest_due'
>;

export interface Schedule {
  rows: ScheduleDraftRow[];
  totalPrincipal: Cents;
  totalInterest: Cents;
  installment: Cents;
}

export interface RepaymentAllocation {
  allocations: { installment_no: number; interest: Cents; principal: Cents }[];
  interest: Cents;
  principal: Cents;
  /** Anything left once every scheduled instalment is settled. */
  unallocated: Cents;
}

export interface LoanGuarantor {
  id: number;
  loan_id: number;
  member_id: number;
  amount: Cents;
  status: string;
}

export interface GuarantorRow extends LoanGuarantor {
  member_no: string;
  first_name: string;
  last_name: string;
}

export interface GuarantorshipRow extends LoanGuarantor {
  loan_no: string;
  loan_status: LoanStatus;
  principal_balance: Cents;
  member_no: string;
  first_name: string;
  last_name: string;
}

export interface LoanDetail {
  loan: LoanFull;
  schedule: LoanScheduleRow[];
  guarantors: GuarantorRow[];
  transactions: Txn[];
}

export interface AppraisalFactor {
  code: string;
  label: string;
  pass: boolean;
  detail: string;
}

export interface Appraisal {
  decision: 'ELIGIBLE' | 'REFERRED';
  score: number;
  factors: AppraisalFactor[];
  installment: Cents;
  deposits: Cents;
  exposure: Cents;
  maxByMultiplier: Cents;
  dsr: number;
  monthlyObligations: Cents;
}

/* ------------------------------------------------------------ transactions */

export type TxnType =
  | 'DEPOSIT' | 'WITHDRAWAL' | 'DISBURSEMENT' | 'REPAYMENT' | 'FEE' | 'INTEREST' | 'REVERSAL';

export interface Txn {
  id: number;
  txn_ref: string;
  value_date: IsoDate;
  created_at: IsoDateTime;
  module: 'SAVINGS' | 'LOAN' | 'CASH';
  txn_type: TxnType;
  member_id: number | null;
  savings_account_id: number | null;
  loan_id: number | null;
  amount: Cents;
  running_balance: Cents | null;
  channel: Channel;
  description: string | null;
  journal_id: number | null;
  created_by: string | null;
  status: 'POSTED' | 'REVERSED';
  reversal_of: number | null;
}

export interface TxnWithMember extends Txn {
  member_no: string | null;
  first_name: string | null;
  last_name: string | null;
}

/* --------------------------------------------------------------- workflow */

export interface ApprovalTask {
  id: number;
  entity: string;
  entity_id: number;
  action: string;
  amount: Cents;
  maker: string;
  maker_at: IsoDateTime;
  checker: string | null;
  checker_at: IsoDateTime | null;
  decision: 'PENDING' | 'APPROVED' | 'REJECTED';
  reason: string | null;
  payload: string | null;
}

export interface ApprovalTaskRow extends ApprovalTask {
  loan_no: string | null;
  principal: Cents | null;
  term_months: number | null;
  loan_status: LoanStatus | null;
  member_no: string | null;
  first_name: string | null;
  last_name: string | null;
}

/* ---------------------------------------------------------------- reports */

export interface DashboardData {
  members: { total: number; active: number; dormant: number };
  loans: {
    total: number; pending: number; approved: number; active: number;
    portfolio: Cents; arrears: Cents;
  };
  deposits: { category: SavingsCategory; name: string; total: Cents; accounts: number }[];
  totalDeposits: Cents;
  shareCapital: Cents;
  cash: Cents;
  loanPortfolio: Cents;
  income: Cents;
  expense: Cents;
  surplus: Cents;
  par: { classification: Classification; loans: number; balance: Cents }[];
  monthly: { month: string; deposits: Cents; withdrawals: Cents; disbursements: Cents }[];
  pendingApprovals: number;
  recentTxns: TxnWithMember[];
}

export interface ReportLine {
  code: string;
  name: string;
  amount: Cents;
}

export interface BalanceSheet {
  assets: ReportLine[];
  liabilities: ReportLine[];
  equity: ReportLine[];
  surplus: Cents;
  totals: { assets: Cents; liabilities: Cents; equity: Cents; equityAndLiabilities: Cents };
  balanced: boolean;
}

export interface IncomeStatement {
  income: ReportLine[];
  expense: ReportLine[];
  totalIncome: Cents;
  totalExpense: Cents;
  surplus: Cents;
  from?: string;
  to?: string;
}

export interface ParRow {
  classification: Classification;
  loans: number;
  balance: Cents;
  arrears: Cents;
  provision_rate: number;
  provision: Cents;
}

export interface PortfolioAtRisk {
  rows: ParRow[];
  total: Cents;
  atRisk: Cents;
  parPct: number;
  totalProvision: Cents;
}

/* ------------------------------------------------------------------- media */

/** The trustworthy metadata for an asset, read back from Cloudinary. */
export interface CloudinaryAsset {
  public_id: string;
  url: string;
  format: string | null;
  bytes: number;
  resource_type: string;
  width: number | null;
  height: number | null;
}

/** One-shot credentials the browser uses to post a file straight to Cloudinary. */
export interface UploadSignature {
  cloudName: string;
  apiKey: string;
  timestamp: number;
  folder: string;
  signature: string;
  resourceType: 'image' | 'auto';
  accepted: string[];
  maxBytes: number;
}

/** What the browser reports back after a direct upload, before verification. */
export interface UploadedFile {
  publicId: string;
  originalFilename: string;
  /** Cloudinary's own read of the resource type; a hint only, verified server-side. */
  resourceType?: string;
}

export type AttachmentEntity = 'member' | 'loan';

export interface Attachment {
  id: number;
  entity: AttachmentEntity;
  entity_id: number;
  /** Cloudinary public_id — the handle used to transform and to delete. */
  public_id: string;
  url: string;
  filename: string;
  /** 'image' or 'raw', as Cloudinary classified it. */
  resource_type: string;
  format: string | null;
  bytes: number;
  category: string | null;
  uploaded_at: IsoDateTime;
  uploaded_by: string;
}

/* ----------------------------------------------------------- action results */

export type ActionSuccess<T> = { ok: true; data: T };
export type ActionFailure = { ok: false; error: string; code: string };

/**
 * What every Server Action returns. Business failures come back as data because
 * an uncaught throw is replaced by an opaque digest in production.
 */
export type ActionResult<T = unknown> = ActionSuccess<T> | ActionFailure;

/** A form read into a plain object by readForm(). */
export type FormValues = Record<string, string | number>;
