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
  global_dimension_1_caption: string;
  global_dimension_2_caption: string;
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

export interface County {
  id: number;
  name: string;
  status: 'ACTIVE' | 'INACTIVE';
}

export interface CountyWithUsage extends County {
  sub_counties: number;
  members: number;
}

export interface SubCounty {
  id: number;
  county_id: number;
  name: string;
  status: 'ACTIVE' | 'INACTIVE';
}

/** A value on the Global Dimension 1 or 2 pick list — both lists share this shape. */
export interface DimensionValue {
  id: number;
  code: string;
  name: string;
  status: 'ACTIVE' | 'INACTIVE';
}

export interface SubCountyWithUsage extends SubCounty {
  county_name: string;
  members: number;
}

export interface Role {
  id: number;
  name: string;
  description: string | null;
  is_system: Flag;
}

/** One Permission Set line: a grant of rights on one Table or Page object. */
export interface PermissionSetLine {
  id: number;
  role_id: number;
  object_type: 'TABLE' | 'PAGE';
  object_name: string;
  read_perm: Flag;
  insert_perm: Flag;
  modify_perm: Flag;
  delete_perm: Flag;
  execute_perm: Flag;
}

/** A table available in the Permission Set line dropdown — live, not curated. */
export interface PermissionTableOption {
  name: string;
  label: string;
}

/** A role row with its lines and user count rolled up. */
export interface RoleWithUsage extends Role {
  lines: PermissionSetLine[];
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
  status: UserStatus;
  last_login_at: IsoDateTime | null;
  created_at: IsoDateTime | null;
}

/** A role's lines, folded into direct lookups for canTable()/canPage(). */
export interface PermissionSet {
  tables: Record<string, { read: boolean; insert: boolean; modify: boolean; delete: boolean }>;
  pages: Record<string, boolean>;
}

/**
 * The signed-in user, as returned by userFromToken().
 * `password_hash` is deleted before the record leaves the auth layer, which is
 * why it is omitted here rather than marked optional.
 */
export interface SessionUser extends Omit<AppUser, 'password_hash'> {
  role_name: string;
  is_system: Flag;
  permissionSet: PermissionSet;
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

/** Which tables get field-level change tracking — Admin Centre toggles these. */
export interface ChangeLogSetup {
  table_name: string;
  table_caption: string;
  log_insertion: Flag;
  log_modification: Flag;
  log_deletion: Flag;
}

export type ChangeLogType = 'Insertion' | 'Modification' | 'Deletion';

export interface ChangeLogEntry {
  id: number;
  table_name: string;
  table_caption: string;
  record_id: string;
  field_name: string;
  old_value: string | null;
  new_value: string | null;
  type: ChangeLogType;
  changed_at: IsoDateTime;
  user_id: number | null;
  username: string;
}

/* ----------------------------------------------------------------- members */

export type MemberStatus = 'NOT PAID UP'|'ACTIVE'|'INACTIVE'|'DORMANT'|'WITHDRAWN'|'DECEASED' ;

export interface Member {
  id: number;
  member_no: string;
  member_type: 'INDIVIDUAL' | 'CORPORATE' | 'GROUP';
  member_category_id: number | null;
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
  county_id: number | null;
  sub_county_id: number | null;
  employer: string | null;
  employment_status: string | null;
  staff_no: string | null;
  gross_income: Cents;
  other_deductions: Cents;
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
  /** Populated only for non-individual member categories (institution, group, joint account). */
  group_name: string | null;
  registration_no: string | null;
  registration_date: IsoDate | null;
  contact_person_name: string | null;
  contact_person_phone: string | null;
  contact_person_email: string | null;
  member_count: number | null;
  global_dimension_1_id: number | null;
  global_dimension_2_id: number | null;
  created_at: IsoDateTime | null;
  created_by: string | null;
}

export interface MemberWithDimensions extends Member {
  county_name: string | null;
  sub_county_name: string | null;
  member_category_name: string | null;
  member_category_type: MemberCategoryType | null;
  global_dimension_1_code: string | null;
  global_dimension_1_name: string | null;
  global_dimension_2_code: string | null;
  global_dimension_2_name: string | null;
}

export interface MemberListRow extends MemberWithDimensions {
  total_savings: Cents;
  loan_balance: Cents;
  /** Window-function total — the same on every row of the page. */
  total_count: number;
}

export interface MemberNextOfKin {
  id: number;
  member_id: number;
  name: string;
  relationship: string | null;
  phone: string | null;
}

export interface MemberNominee {
  id: number;
  member_id: number;
  name: string;
  relationship: string | null;
  phone: string | null;
  percentage: number;
  is_next_of_kin: Flag;
}

/** An office bearer authorised to act on a non-individual (group/corporate) member's account. */
export interface MemberSignatory {
  id: number;
  member_id: number;
  identification_no: string | null;
  name: string;
  designation: string | null;
  date_of_birth: IsoDate | null;
  email: string | null;
  phone: string | null;
}

export interface MemberDetail {
  member: MemberWithDimensions;
  accounts: SavingsAccountWithProduct[];
  loans: LoanWithProductName[];
  guaranteeing: GuarantorshipRow[];
  transactions: Txn[];
  appraisal: { deposits: Cents; exposure: Cents };
  nextOfKin: MemberNextOfKin[];
  nominees: MemberNominee[];
  signatories: MemberSignatory[];
}

/* ----------------------------------------------------------- member applications */

/**
 * The workflow state of a staging document — shared vocabulary across whatever
 * document types eventually reuse it, so not every value applies to every one.
 * A member application only ever drives itself through a subset of these.
 */
export type DocumentStatus =
  | 'Open' | 'Pending Approval' | 'Approved' | 'Processed';

/** A staged membership, captured with every field member.createMember() will need once approved. */
export interface MemberApplication {
  no: string;
  member_type: 'INDIVIDUAL' | 'CORPORATE' | 'GROUP';
  member_category_id: number | null;
  title: string | null;
  first_name: string | null;
  middle_name: string | null;
  last_name: string | null;
  national_id: string | null;
  kra_pin: string | null;
  date_of_birth: IsoDate | null;
  gender: string | null;
  marital_status: string | null;
  phone: string | null;
  email: string | null;
  postal_address: string | null;
  physical_address: string | null;
  county_id: number | null;
  sub_county_id: number | null;
  employer: string | null;
  employment_status: string | null;
  staff_no: string | null;
  gross_income: Cents;
  other_deductions: Cents;
  kyc_verified: Flag;
  join_date: IsoDate | null;
  photo: string | null;
  front_id_image: string | null;
  back_id_image: string | null;
  signature_image: string | null;
  fingerprint1_image: string | null;
  fingerprint2_image: string | null;
  notes: string | null;
  /** Populated only for non-individual member categories (institution, group, joint account). */
  group_name: string | null;
  registration_no: string | null;
  registration_date: IsoDate | null;
  contact_person_name: string | null;
  contact_person_phone: string | null;
  contact_person_email: string | null;
  member_count: number | null;
  global_dimension_1_id: number | null;
  global_dimension_2_id: number | null;
  /** The approval workflow state. Captioned "Status" in the UI. */
  status: DocumentStatus;
  decision_reason: string | null;
  member_id: number | null;
  created_at: IsoDateTime | null;
  created_by: string | null;
  processed_at: IsoDateTime | null;
  processed_by: string | null;
}

export interface MemberApplicationWithDimensions extends MemberApplication {
  county_name: string | null;
  sub_county_name: string | null;
  member_category_name: string | null;
  /** Drives the Basic-information-vs-Group/Corporate-information tab choice on the application card. */
  member_category_type: MemberCategoryType | null;
  /** Set once processed — the member number the application became. */
  member_no: string | null;
  global_dimension_1_code: string | null;
  global_dimension_1_name: string | null;
  global_dimension_2_code: string | null;
  global_dimension_2_name: string | null;
}

/* ----------------------------------------------------------------- member edits */

/** A staged set of changes to an existing member, carrying a full snapshot of every
 *  editable field (not just the ones actually changed) plus its own approval workflow —
 *  mirrors MemberApplication, except member_id is always set from creation. */
export interface MemberEditRequest {
  no: string;
  member_id: number;
  member_type: 'INDIVIDUAL' | 'CORPORATE' | 'GROUP';
  member_category_id: number | null;
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
  county_id: number | null;
  sub_county_id: number | null;
  employer: string | null;
  employment_status: string | null;
  staff_no: string | null;
  gross_income: Cents;
  other_deductions: Cents;
  kyc_verified: Flag;
  join_date: IsoDate | null;
  photo: string | null;
  front_id_image: string | null;
  back_id_image: string | null;
  signature_image: string | null;
  fingerprint1_image: string | null;
  fingerprint2_image: string | null;
  notes: string | null;
  group_name: string | null;
  registration_no: string | null;
  registration_date: IsoDate | null;
  contact_person_name: string | null;
  contact_person_phone: string | null;
  contact_person_email: string | null;
  member_count: number | null;
  global_dimension_1_id: number | null;
  global_dimension_2_id: number | null;
  /** The approval workflow state. Captioned "Status" in the UI. */
  status: DocumentStatus;
  decision_reason: string | null;
  created_at: IsoDateTime | null;
  created_by: string | null;
  processed_at: IsoDateTime | null;
  processed_by: string | null;
}

export interface MemberEditRequestWithDimensions extends MemberEditRequest {
  county_name: string | null;
  sub_county_name: string | null;
  member_category_name: string | null;
  /** Drives the Basic-information-vs-Group/Corporate-information tab choice on the card. */
  member_category_type: MemberCategoryType | null;
  /** The target member's own number/name — this always exists, unlike an application's. */
  member_no: string;
  member_first_name: string;
  member_last_name: string;
  global_dimension_1_code: string | null;
  global_dimension_1_name: string | null;
  global_dimension_2_code: string | null;
  global_dimension_2_name: string | null;
}

/** One field that differs between an edit request's stored value and the member's
 *  live value — powers the "What's changing" summary on the request's view page. */
export interface MemberEditFieldDiff {
  field: string;
  label: string;
  from: string | number | null;
  to: string | number | null;
}

export interface AccountOpeningRequest {
  no: string;
  member_id: number;
  savings_product_id: number;
  notes: string | null;
  business_name: string | null;
  business_location: string | null;
  business_paybill_till_no: string | null;
  business_phone_no: string | null;
  junior_name: string | null;
  junior_birth_cert_no: string | null;
  junior_date_of_birth: IsoDate | null;
  junior_photo: string | null;
  status: DocumentStatus;
  decision_reason: string | null;
  account_id: number | null;
  created_at: IsoDateTime | null;
  created_by: string | null;
  processed_at: IsoDateTime | null;
  processed_by: string | null;
}

export interface AccountOpeningRequestWithDimensions extends AccountOpeningRequest {
  member_no: string;
  member_first_name: string;
  member_last_name: string;
  savings_product_code: string;
  savings_product_name: string;
  savings_product_category: SavingsCategory;
  savings_product_is_business_account: Flag;
}

/** A maker-checker request to deactivate an existing non-default savings account — the same
 *  Open -> Pending Approval -> Approved -> Processed shape as AccountOpeningRequest. Processing
 *  sets the target account's status to INACTIVE (lib/savings.ts then refuses to post against it). */
export interface AccountDeactivationRequest {
  no: string;
  account_id: number;
  reason: string | null;
  status: DocumentStatus;
  decision_reason: string | null;
  created_at: IsoDateTime | null;
  created_by: string | null;
  processed_at: IsoDateTime | null;
  processed_by: string | null;
}

export interface AccountDeactivationRequestWithDimensions extends AccountDeactivationRequest {
  account_no: string;
  account_status: SavingsAccountStatus;
  account_balance: Cents;
  member_id: number;
  member_no: string;
  member_first_name: string;
  member_last_name: string;
  savings_product_code: string;
  savings_product_name: string;
}

/** A maker-checker request to reactivate an INACTIVE savings account — the mirror image of
 *  AccountDeactivationRequest. Processing sets the target account's status back to ACTIVE. */
export interface AccountActivationRequest {
  no: string;
  account_id: number;
  reason: string | null;
  status: DocumentStatus;
  decision_reason: string | null;
  created_at: IsoDateTime | null;
  created_by: string | null;
  processed_at: IsoDateTime | null;
  processed_by: string | null;
  /** The Charge Code (a transaction_charge configured for ACCOUNT_ACTIVATION) applied to this
   *  request, and which of the member's accounts it's debited from — both null when
   *  activation is free (no charge selected). */
  transaction_charge_id: number | null;
  debit_account_id: number | null;
  /** Set when the optional reactivation fee posts — mirrors member_charging.journal_id, and
   *  is what lets Find Entries trace the fee back to this request. */
  journal_id: number | null;
}

export interface AccountActivationRequestWithDimensions extends AccountActivationRequest {
  account_no: string;
  account_status: SavingsAccountStatus;
  account_balance: Cents;
  member_id: number;
  member_no: string;
  member_first_name: string;
  member_last_name: string;
  savings_product_code: string;
  savings_product_name: string;
  transaction_charge_code: string | null;
  transaction_charge_description: string | null;
  debit_account_no: string | null;
  debit_account_balance: Cents | null;
  debit_account_hold_amount: Cents | null;
  debit_account_min_balance: Cents | null;
  /** Computed live off the charge configuration (not stored) — see
   *  lib/accountActivation.ts's withChargeAmount(). Null when no charge is selected. */
  charge_amount: Cents | null;
}

/** The debit-account picklist row for a charged Account Activation request — every account a
 *  member holds, any status, with just what's needed to preview an available balance and post
 *  a charge against it. */
export interface SavingsAccountForDebit {
  id: number;
  account_no: string;
  status: SavingsAccountStatus;
  balance: Cents;
  hold_amount: Cents;
  product_name: string;
  min_balance: Cents;
  gl_control_id: number;
}

/** An ad-hoc charge posted straight against a member's own withdrawable deposit account —
 *  see lib/memberCharging.ts. No approval workflow: whoever creates it also posts it, so
 *  `status` only ever moves Open -> Posted. `amount_charged` is recalculated from
 *  transaction_charge_id/no_of_pages right up to the moment of posting, never trusted as a
 *  stale snapshot when it matters financially. */
export interface MemberCharging {
  no: string;
  description: string;
  member_id: number;
  source_account_id: number;
  transaction_charge_id: number;
  no_of_pages: number | null;
  amount_charged: Cents;
  status: 'Open' | 'Posted';
  journal_id: number | null;
  created_at: IsoDateTime | null;
  created_by: string | null;
  posted_at: IsoDateTime | null;
  posted_by: string | null;
}

export interface MemberChargingWithDimensions extends MemberCharging {
  member_no: string;
  member_first_name: string;
  member_last_name: string;
  source_account_no: string;
  source_account_balance: Cents;
  source_account_hold_amount: Cents;
  source_account_min_balance: Cents;
  source_account_gl_control_id: number;
  transaction_charge_code: string;
  transaction_charge_description: string;
  /** Derived from the selected Charge Code, not stored — see Table 52204206's "Posting
   *  Transaction Type". */
  posting_transaction_type: ChargeTransactionType;
  journal_no: string | null;
  /** Computed live off the source account's current balance — see
   *  lib/memberCharging.ts's withSourceBalance(). */
  source_balance: Cents;
}

export interface MemberApplicationNextOfKin {
  id: number;
  application_no: string;
  name: string;
  relationship: string | null;
  phone: string | null;
}

export interface MemberApplicationNominee {
  id: number;
  application_no: string;
  name: string;
  relationship: string | null;
  phone: string | null;
  percentage: number;
  is_next_of_kin: Flag;
}

/** An office bearer authorised to act on the eventual non-individual (group/corporate) member's account. */
export interface MemberApplicationSignatory {
  id: number;
  application_no: string;
  identification_no: string | null;
  name: string;
  designation: string | null;
  date_of_birth: IsoDate | null;
  email: string | null;
  phone: string | null;
}

export interface MemberApplicationAttachment {
  id: number;
  application_no: string;
  public_id: string;
  url: string;
  filename: string;
  resource_type: string;
  format: string | null;
  bytes: number;
  category: string | null;
  uploaded_at: IsoDateTime;
  uploaded_by: string;
}

export interface MemberEditNextOfKin {
  id: number;
  edit_no: string;
  name: string;
  relationship: string | null;
  phone: string | null;
}

export interface MemberEditNominee {
  id: number;
  edit_no: string;
  name: string;
  relationship: string | null;
  phone: string | null;
  percentage: number;
  is_next_of_kin: Flag;
}

/** An office bearer authorised to act on the eventual non-individual (group/corporate) member's account. */
export interface MemberEditSignatory {
  id: number;
  edit_no: string;
  identification_no: string | null;
  name: string;
  designation: string | null;
  date_of_birth: IsoDate | null;
  email: string | null;
  phone: string | null;
}

export interface MemberEditAttachment {
  id: number;
  edit_no: string;
  public_id: string;
  url: string;
  filename: string;
  resource_type: string;
  format: string | null;
  bytes: number;
  category: string | null;
  uploaded_at: IsoDateTime;
  uploaded_by: string;
}

/* -------------------------------------------------------- chart of accounts */

export type GlAccountType = 'ASSET' | 'LIABILITY' | 'EQUITY' | 'INCOME' | 'EXPENSE';

/** Business Central's G/L "Account Type" — the account's structural role in the chart
 *  (see lib/constants.ts's GL_ACCOUNT_STRUCTURE_TYPES). */
export type GlAccountStructureType = 'POSTING' | 'HEADING' | 'TOTAL' | 'BEGIN_TOTAL' | 'END_TOTAL';

export interface GlAccount {
  id: number;
  code: string;
  name: string;
  type: GlAccountType;
  parent_code: string | null;
  is_postable: Flag;
  account_type: GlAccountStructureType;
  /** For TOTAL/END_TOTAL only — the code range(s)/list of Posting accounts this row sums,
   *  Business Central style (e.g. "1010..1099|1200"). */
  totaling: string | null;
  balance: Cents;
  status: 'ACTIVE' | 'INACTIVE';
  /** Blocks this account from a manual G/L journal line — see lib/gl.ts's createJournal(). */
  no_direct_posting: Flag;
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

/* ------------------------------------------------------- charge management */

/** Which SACCO transaction category a Transaction Charge attaches to — Table 52204021's
 *  "Posting Transaction Type" (Sacco Transaction Type enum), values kept verbatim from the
 *  source documentation including its own 'Divinded Processing' spelling. Account Activation's
 *  reactivation fee (the one type actually wired to a posting routine so far, via
 *  lib/charges.ts's postTransactionCharges() from lib/accountActivation.ts) reuses 'General'
 *  rather than getting a dedicated value of its own. */
export type ChargeTransactionType =
  | 'General' | 'Cash Deposit' | 'Cash Withdrawal' | 'ATM' | 'Loan Disbursal' | 'Interest Due'
  | 'Interest Paid' | 'Principal Paid' | 'Acc. Transfer' | 'Cheque Deposit' | 'Bankers Cheque'
  | 'Fixed Deposit' | 'End Month Salary' | 'Checkoff Pay' | 'Teller-Treasury' | 'Disb. Rec'
  | 'Penalty Due' | 'Penalty Paid' | 'Divinded Processing' | 'Charge' | 'Registration Fee'
  | 'Standing Order' | 'Benevolent Fund' | 'Statement Charge';

export type ChargeCalculationType = 'SCHEME' | 'PERCENT_OF_CHARGE';
export type ChargeRateType = 'FLAT' | 'PERCENTAGE';

/** Reusable charge code — Business Central's "Charges" master. */
export interface Charge {
  id: number;
  code: string;
  description: string;
  status: 'ACTIVE' | 'INACTIVE';
}

/** One amount-band rate rule for a component — Business Central's "Transaction Calc. Scheme".
 *  upper_limit null means unbounded; the *_charge_limit fields are 0 when not capped. */
export interface TransactionCalcScheme {
  id: number;
  transaction_charge_setup_id: number;
  lower_limit: Cents;
  upper_limit: Cents | null;
  rate_type: ChargeRateType;
  flat_amount: Cents;
  percentage_rate: number;
  upper_charge_limit: Cents;
  lower_charge_limit: Cents;
}

/** One component of a Transaction Charge — Business Central's "Transaction Charges Setup"
 *  line: which charge, where it posts, how it's calculated and in what priority order. */
export interface TransactionChargeSetup {
  id: number;
  transaction_charge_id: number;
  charge_id: number;
  gl_account_id: number;
  calculation_type: ChargeCalculationType;
  source_setup_id: number | null;
  priority: number;
  status: 'ACTIVE' | 'INACTIVE';
}

/** A component row joined with its charge code/name, posting account and (first) scheme
 *  band, for display and for the calculation engine. */
export interface TransactionChargeSetupDetail extends TransactionChargeSetup {
  charge_code: string;
  charge_description: string;
  gl_account_code: string;
  gl_account_name: string;
  scheme: TransactionCalcScheme[];
}

/** The parent charge event for one transaction type — Business Central's "Transaction
 *  Charge". */
export interface TransactionCharge {
  id: number;
  code: string;
  description: string;
  transaction_type: ChargeTransactionType;
  status: 'ACTIVE' | 'INACTIVE';
}

export interface TransactionChargeWithDetail extends TransactionCharge {
  components: TransactionChargeSetupDetail[];
}

/** One resolved charge component amount, ready to post or to show as a fee preview. */
export interface CalculatedCharge {
  setupId: number;
  chargeCode: string;
  chargeDescription: string;
  glAccountId: number;
  glAccountCode: string;
  amount: Cents;
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
  global_dimension_1_id: number | null;
  global_dimension_2_id: number | null;
}

export interface JournalListRow extends Journal {
  member_no: string | null;
  first_name: string | null;
  last_name: string | null;
  global_dimension_1_code: string | null;
  global_dimension_2_code: string | null;
}

export interface JournalLine {
  id: number;
  journal_id: number;
  line_no: number;
  gl_account_id: number;
  debit: Cents;
  credit: Cents;
  narration: string | null;
  global_dimension_1_id: number | null;
  global_dimension_2_id: number | null;
}

export interface JournalLineWithAccount extends JournalLine {
  code: string;
  name: string;
  type: GlAccountType;
  global_dimension_1_code: string | null;
  global_dimension_2_code: string | null;
}

/** A journal line as supplied to postJournal, before it is resolved and stored. */
export interface JournalLineInput {
  /** GL account id (number) or account code (string). */
  account: number | string;
  debit?: Cents;
  credit?: Cents;
  narration?: string | null;
  /** Explicit per-line override — falls back to the header default (see PostJournalOptions) when omitted. */
  globalDimension1Id?: number | null;
  globalDimension2Id?: number | null;
}

export interface PostJournalOptions {
  valueDate: IsoDate;
  module: string;
  eventType: string;
  description?: string | null;
  reference?: string | null;
  memberId?: number | null;
  /** Explicit header default. When omitted and memberId is set, resolved from the member's own dimensions. */
  globalDimension1Id?: number | null;
  globalDimension2Id?: number | null;
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
  reference: string | null;
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

/* ------------------------------------------------- find entries / navigate */

/** One row in a Find Entries / Navigate bucket — every source document type links through
 *  its own posted-document page, so the href is resolved server-side per bucket rather than
 *  the client guessing a route pattern per module. */
export interface JournalRelatedEntry {
  label: string;
  amount: Cents;
  href: string;
}

/** One bucket of the Navigate summary (Business Central's "Navigate" action) — a count plus
 *  the entries themselves, for a document/table related to the journal being inspected. */
export interface JournalRelatedBucket {
  entries: JournalRelatedEntry[];
}

export interface JournalRelatedEntries {
  glLineCount: number;
  vendor: JournalRelatedBucket;   // savings (module SAVINGS) txn rows for this journal
  customer: JournalRelatedBucket; // loan (module LOAN) txn rows for this journal
  memberCharging: JournalRelatedBucket;
  accountActivation: JournalRelatedBucket;
  bank: JournalRelatedBucket;
}

/* ------------------------------------------------------------- bank subledger */

export interface BankAccount {
  id: number;
  code: string;
  name: string;
  gl_account_id: number;
  bank_name: string | null;
  account_no: string | null;
  balance: Cents;
  status: 'ACTIVE' | 'INACTIVE';
}

export interface BankAccountListRow extends BankAccount {
  gl_account_code: string;
  gl_account_name: string;
}

export interface BankAccountLedgerEntry {
  id: number;
  bank_account_id: number;
  journal_id: number;
  journal_line_id: number;
  posting_date: IsoDate;
  description: string | null;
  amount: Cents;
  running_balance: Cents;
  reconciled: Flag;
  bank_reconciliation_id: number | null;
}

export interface BankAccountLedgerEntryWithJournal extends BankAccountLedgerEntry {
  journal_no: string;
  source_module: string;
}

export interface BankReconciliation {
  id: number;
  bank_account_id: number;
  statement_date: IsoDate;
  statement_balance: Cents;
  status: 'OPEN' | 'COMPLETED';
  created_by: string | null;
  created_at: IsoDateTime | null;
  completed_by: string | null;
  completed_at: IsoDateTime | null;
}

export interface BankReconciliationWorksheet {
  reconciliation: BankReconciliation;
  bankAccount: BankAccount;
  entries: BankAccountLedgerEntryWithJournal[];
  clearedTotal: Cents;
  difference: Cents;
}

/** A savings account bucketed by days since its last transaction — the SACCO-realistic
 *  stand-in for Business Central's Vendor Aging Report, which needs invoice due dates that a
 *  member's deposit account has no equivalent of. */
export interface DormancyAgingRow {
  account_id: number;
  account_no: string;
  member_no: string;
  first_name: string;
  last_name: string;
  product_name: string;
  balance: Cents;
  last_txn_date: IsoDate | null;
  days_since_last_txn: number;
  bucket: '0-30' | '31-90' | '91-180' | '180+';
}

/* ----------------------------------------------------------------- savings */

export type SavingsCategory = 'WITHDRAWABLE DEPOSIT' | 'NON WITHDRAWABLE DEPOSIT' | 'JUNIOR ACCOUNT' | 'SHARE CAPITAL ACCOUNT' | 'FIXED DEPOSIT ACCOUNT' | 'LOAN ACCOUNT' | 'INVESTMENTS ACCOUNT' | 'HOLDING ACCOUNT' | 'HOLIDAY ACCOUNT' | 'SHARE TRADING ACCOUNT' | 'BENEVOLENT ACCOUNT' | 'SCHOOL FEE ACCOUNT';
export type SavingsAccountStatus = 'ACTIVE' | 'DORMANT' | 'FROZEN' | 'CLOSED' | 'INACTIVE';
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
  /** Collects business details (name, location, paybill/till, phone) at Account Opening time. */
  is_business_account: Flag;
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

/* ---------------------------------------------------------- member categories */

export type MemberCategoryType =
  | 'INDIVIDUAL' | 'GROUP' |'INSTITUTION' | 'MICRO_FINANCE' | 'GROUP_MEMBER' | 'JOINT_ACCOUNT';

export interface MemberCategory {
  id: number;
  code: string;
  description: string;
  category_type: MemberCategoryType;
  registration_fee: Cents;
  registration_fee_account_id: number | null;
  status: 'ACTIVE' | 'INACTIVE';
}

export interface MemberCategoryWithUsage extends MemberCategory {
  registration_fee_account_code: string | null;
  registration_fee_account_name: string | null;
  default_accounts: number;
  members: number;
}

export interface MemberCategoryDefaultAccount {
  id: number;
  member_category_id: number;
  savings_product_id: number;
  description: string;
}

export interface MemberCategoryDefaultAccountRow extends MemberCategoryDefaultAccount {
  savings_product_code: string;
  savings_product_name: string;
}

/** One (member, default product) pair a category's default-account backfill still needs to
 *  open — computed by pool.getDefaultAccountsBacklog(), then opened one at a time by the
 *  client-driven progress UI (Admin Centre -> Setup Pool -> Member Categories -> Create
 *  Default Accounts), so the browser can show real per-item progress. */
export interface DefaultAccountBacklogItem {
  memberId: number;
  memberNo: string;
  memberName: string;
  productId: number;
  productCode: string;
  productName: string;
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
  business_name: string | null;
  business_location: string | null;
  business_paybill_till_no: string | null;
  business_phone_no: string | null;
  junior_name: string | null;
  junior_birth_cert_no: string | null;
  junior_date_of_birth: IsoDate | null;
  junior_photo: string | null;
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
  is_business_account: Flag;
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
  lines: TxnWithDocument[];
}

/* ------------------------------------------------------------------- loans */

export type LoanStatus = 'OPEN'|'PENDING APPROVAL' | 'APPROVED' | 'DISBURSED' | 'CLOSED' |'ARCHIVED' | 'WRITTEN OFF';
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
  transactions: TxnWithDocument[];
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

/** A txn carrying its posted journal's Document No. (`journal.reference` — the source
 *  document's own number: Member Charging's/Account Activation's `no`, a loan's `loan_no`, ...)
 *  — what a Statement of Account / Loan account activity list shows and searches by, distinct
 *  from `txn_ref`, which is this txn's own internally-generated reference. */
export interface TxnWithDocument extends Txn {
  document_no: string | null;
}

/** A txn row shown as a Vendor (savings) or Customer (loan) Ledger Entry — Business Central
 *  terminology for what this app already tracks as `txn`: a savings account is the "vendor"
 *  side (a liability the SACCO owes the member), a loan is the "customer" side (a receivable
 *  owed to the SACCO). Same underlying data, reused for both list screens. */
export interface SubledgerEntryRow extends TxnWithMember {
  document_no: string;
  document_href: string;
  journal_no: string | null;
}

/* --------------------------------------------------------------- workflow */

export type WorkflowDocumentType =
  | 'MEMBER_APPLICATION' | 'MEMBER_EDIT' | 'LOAN' | 'JOURNAL' | 'ACCOUNT_OPENING' | 'ACCOUNT_DEACTIVATION'
  | 'ACCOUNT_ACTIVATION';
export type WorkflowApproverType = 'USER' | 'DIRECT_APPROVER' | 'USER_GROUP';
export type WorkflowConditionOperator = '=' | '!=' | '>' | '>=' | '<' | '<=' | 'BETWEEN';
export type WorkflowTaskStatus = 'PENDING' | 'APPROVED' | 'REJECTED' | 'CANCELLED';

export interface Workflow {
  id: number;
  name: string;
  /** One of the wired WorkflowDocumentType literals, or (for a workflow defined against any
   *  other real table) that table's own name — see DocumentTypeOption / listDocumentTypeOptions(). */
  document_type: string;
  enabled: Flag;
  created_at: IsoDateTime | null;
  created_by: string | null;
}

/** One selectable document type in a workflow's dropdown — the live, denylist-filtered set of
 *  every real table, not just the fixed handful with a wired submission flow. */
export interface DocumentTypeOption {
  documentType: string;
  table: string;
  label: string;
  /** Whether a submission flow actually calls findMatchingWorkflow() for this document type.
   *  False for any table beyond the wired set: an admin can still configure conditions and
   *  approval steps for it, but it stays inert — no code path creates a task from it — until
   *  real integration code is added, the same way LOAN/JOURNAL/etc. were. */
  wired: boolean;
}

export interface WorkflowCondition {
  id: number;
  workflow_id: number;
  field: string;
  operator: WorkflowConditionOperator;
  value: string;
  value2: string | null;
}

export interface WorkflowStep {
  id: number;
  workflow_id: number;
  step_no: number;
  approver_type: WorkflowApproverType;
  approver_user_id: number | null;
  approver_group_id: number | null;
  notify_email: Flag;
}

/** A workflow with its condition and step child rows, as edited/displayed as one unit. */
export interface WorkflowWithDetail extends Workflow {
  conditions: WorkflowCondition[];
  steps: WorkflowStep[];
}

/** Registers the one DB table backing a document type's workflow conditions — admin-managed
 *  under Admin Centre → Workflow Management → Table Relations. `table_name` is never freely
 *  editable: for a wired document type it always mirrors DOCUMENT_TABLE[document_type]
 *  (lib/workflowConstants.ts) — the only table that type's submission code actually fetches
 *  condition values from — and for any other document type it's forced to match the document
 *  type itself, since that IS the table name there (see DocumentTypeOption). */
export interface WorkflowTableRelation {
  id: number;
  document_type: string;
  table_name: string;
  created_at: IsoDateTime | null;
  created_by: string | null;
}

/** One column of a table relation's table that's enabled as a workflow condition field. */
export interface WorkflowTableRelationField {
  id: number;
  table_relation_id: number;
  field_name: string;
}

export interface WorkflowTableRelationWithFields extends WorkflowTableRelation {
  fields: WorkflowTableRelationField[];
}

/** An admin-defined CSV export/import package (Admin Centre → Data Management) — which table,
 *  and via ConfigPackageField, which of that table's columns are included. */
export interface ConfigPackage {
  id: number;
  code: string;
  name: string;
  table_name: string;
  key_field: string | null;
  created_at: IsoDateTime | null;
  created_by: string | null;
}

export interface ConfigPackageField {
  id: number;
  package_id: number;
  field_name: string;
  column_no: number;
}

export interface ConfigPackageWithFields extends ConfigPackage {
  fields: ConfigPackageField[];
}

/** One selectable table in the package's table dropdown — the live, denylist-filtered set. */
export interface ConfigPackageTableOption {
  table_name: string;
  label: string;
}

/** One selectable column of a package's table — `relation_table` is set when the column is a
 *  foreign key, so export/import can resolve it to/from a human-readable code instead of a raw id.
 *  `required` (NOT NULL, no default) matters for import: a row that doesn't match the package's
 *  key field gets inserted as new, so it must supply every required column or the insert fails —
 *  importConfigPackage() checks this up front instead of surfacing a raw DB constraint error.
 *  `filter_type` drives which operators the export filter builder offers for this column. */
export interface ConfigPackageColumn {
  name: string;
  label: string;
  relation_table: string | null;
  required: boolean;
  filter_type: 'text' | 'number' | 'date' | 'select';
}

export interface ConfigImportRowResult {
  row: number;
  status: 'INSERTED' | 'UPDATED' | 'ERROR';
  message?: string;
}

export interface ConfigImportResult {
  inserted: number;
  updated: number;
  errors: number;
  rows: ConfigImportRowResult[];
}

export interface WorkflowUserGroup {
  id: number;
  name: string;
  status: 'ACTIVE' | 'INACTIVE';
}

export interface WorkflowUserGroupWithUsage extends WorkflowUserGroup {
  members: number;
}

/** One member of an approval user group, with the sequence level they approve at. */
export interface WorkflowUserGroupMemberRow {
  user_id: number;
  sequence: number;
}

export interface ApprovalUserSetup {
  id: number;
  user_id: number;
  approver_id: number | null;
  substitute_id: number | null;
  is_approval_administrator: Flag;
  can_reverse_journal: Flag;
}

/** One row of the Approval User Setup grid — the user plus their configured setup, if any. */
export interface ApprovalUserSetupRow {
  user_id: number;
  username: string;
  full_name: string;
  approver_id: number | null;
  approver_name: string | null;
  substitute_id: number | null;
  substitute_name: string | null;
  is_approval_administrator: Flag;
  can_reverse_journal: Flag;
}

export interface WorkflowTask {
  id: number;
  workflow_id: number | null;
  workflow_step_id: number | null;
  step_no: number;
  document_type: WorkflowDocumentType;
  entity_id: string;
  assigned_to_user_id: number | null;
  assigned_to_group_id: number | null;
  /** The group's currently-pending sequence level; null when assigned to a single user. */
  current_sequence: number | null;
  /** Set when the current approver hands this task to their substitute. */
  delegated_by_user_id: number | null;
  delegated_to_user_id: number | null;
  status: WorkflowTaskStatus;
  requested_by: string;
  requested_at: IsoDateTime;
  decided_by: string | null;
  decided_at: IsoDateTime | null;
  comment: string | null;
  amount: Cents;
  payload: string | null;
}

/** A task row as shown in the "My Approvals" worklist — with display labels resolved. */
export interface WorkflowTaskRow extends WorkflowTask {
  workflow_name: string | null;
  /** A short human label for the document (loan no., application no., journal no.). */
  document_label: string;
  /** Where "Review" / clicking the row should navigate. */
  link: string;
}

/** One group-sequence level a task has already cleared, reconstructed from the system audit
 *  log since the task row itself only ever holds the final decision. */
export interface WorkflowLevelDecision {
  sequence: number;
  decided_by: string;
  decided_at: IsoDateTime;
  comment: string | null;
}

/** A task row as shown on a document's own Approval Details table. */
export interface WorkflowTaskWithApprover extends WorkflowTask {
  /** Who may currently act on this task — a resolved name, or "Group name — member, member".
   *  Only populated while status is PENDING; null once decided. */
  pending_with: string | null;
  /** For a group task with multiple sequence levels, each level already cleared, oldest
   *  first. Empty for a single-approver task, or a group task still on its first level. */
  level_decisions: WorkflowLevelDecision[];
}

export type NotificationType = 'WORKFLOW_PENDING' | 'WORKFLOW_APPROVED' | 'WORKFLOW_REJECTED';

export interface AppNotification {
  id: number;
  user_id: number;
  type: NotificationType;
  title: string;
  body: string | null;
  link: string | null;
  is_read: Flag;
  created_at: IsoDateTime;
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
