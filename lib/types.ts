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
  bank_branch: string | null;
  /** The name the account is held in — printed above the number on an invoice. */
  bank_account_name: string | null;
  bank_account_no: string | null;
  /** General Ledger Setup: receipts at or above this need approval; below it the creator may
   *  post their own. See lib/receipts.ts postReceipt(). */
  receipt_approval_limit: Cents;
  /** AL General Ledger Setup "Petty Cash Limit" — above it, raise an imprest instead. */
  petty_cash_limit: Cents;
  /** AL "Max No Outstanding Imprests" an employee may hold unsurrendered. */
  max_outstanding_imprests: number;
  /** The employee subledger control account every imprest, refund and claim posts through. */
  imprest_control_account_id: number | null;
  /** Date formula from issue to the surrender due date. */
  imprest_surrender_period: string;
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
  /** Multiplies a member's own deposits to determine how much of OTHER members' loans they
   *  qualify to guarantee — see lib/guarantors.ts's guarantorCapacity(). Defaults to 1. */
  guarantor_multiplier: number;
  /** Separate multiplier for how much of a member's OWN loan their own deposits can secure —
   *  see lib/guarantors.ts's selfGuaranteeCapacity(). Defaults to 1. */
  self_guarantor_multiplier: number;
  /** AL's "Withdrawal Period" — days after a Member Exit is opened before its maturity date,
   *  see lib/memberExits.ts's createMemberExit(). Defaults to 30. */
  member_exit_notice_days: number;
  /** AL's "Update Member Status" report (Rep 52204078) "Dormancy Period", narrowed here to the
   *  member's own Non-Withdrawable Deposit account: no money in it for this many days flips
   *  Active -> Dormant. See lib/memberStatusUpdate.ts. Defaults to 90. */
  dormancy_days: number;
  /** The Transaction Charge auto-applied when a Member Exit is marked Instant Withdrawal. */
  instant_withdrawal_charge_id: number | null;
  /** AL General Ledger Setup "Inter Acc Transfer Charges" — the Transaction Charge auto-applied to
   *  every inter-account transfer, deducted from the source account. See lib/interAccountTransfer.ts. */
  inter_account_transfer_charge_id: number | null;
  /** BC's General Ledger Setup "Allow Posting From"/"Allow Posting To" — see
   *  lib/postingDates.ts. Null = unrestricted. */
  allow_posting_from: IsoDate | null;
  allow_posting_to: IsoDate | null;
  /** AL General Ledger Setup "Validate Cash Denomination" — when true a cash document's
   *  denomination breakdown must total exactly its amount. See lib/denominations.ts. */
  validate_cash_denomination: boolean;
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

/** A per-user permission override line — same shape as PermissionSetLine, keyed to a user. When
 *  present it replaces the role's line for that one object. See lib/userPermissions.ts. */
export interface UserPermissionLine {
  id: number;
  user_id: number;
  object_type: 'TABLE' | 'PAGE';
  object_name: string;
  read_perm: Flag;
  insert_perm: Flag;
  modify_perm: Flag;
  delete_perm: Flag;
  execute_perm: Flag;
  created_at: IsoDateTime | null;
  created_by: string | null;
}

export interface PermissionRightSet {
  read: boolean;
  insert: boolean;
  modify: boolean;
  delete: boolean;
  execute: boolean;
}

/** One object's row in the per-user permission editor: the rights granted by the user's assigned
 *  Permission Sets (primary role ∪ additional sets), the effective rights after any per-user
 *  override, and whether they differ. */
export interface UserPermissionMatrixRow {
  objectType: 'TABLE' | 'PAGE';
  objectName: string;
  label: string;
  /** Granted by the union of the user's assigned Permission Sets, before overrides. */
  granted: PermissionRightSet;
  effective: PermissionRightSet;
  overridden: boolean;
}

export interface UserPermissionMatrix {
  userId: number;
  userName: string;
  role: { id: number; name: string; is_system: Flag };
  /** Names of every Permission Set feeding the granted baseline — the primary role first. */
  grantedSetNames: string[];
  isSystem: boolean;
  rows: UserPermissionMatrixRow[];
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
  /** BC's "Work Date" (My Settings) — this user's own suggested default date, in place of the
   *  real system date, for new documents. Null = use today(). See lib/postingDates.ts. */
  work_date: IsoDate | null;
  /** The Role Centre landing page this user currently sees. Points at one of their assigned
   *  Profiles; null falls back to the default (Super) profile. Grants no permissions. */
  active_profile_id: number | null;
}

/** Business Central's "Profile" — a landing-page selector. Decides which Role Centre (tailored
 *  home dashboard) a user sees; carries no permissions (fully independent of the Permission Set
 *  system). See lib/profiles.ts. */
export interface Profile {
  id: number;
  code: string;
  name: string;
  description: string;
  /** The Role Centre this profile lands on — one of SUPER | CRM | CREDIT | FOSA | FINANCE_MANAGER
   *  | ACCOUNTANT for the seeded profiles. */
  role_centre: string;
  icon: string;
  sort: number;
  is_default: Flag;
  is_system: Flag;
  created_at: IsoDateTime | null;
  created_by: string | null;
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
  /** Every Profile an admin has assigned to this user (system-admin users get all of them). */
  profiles: Profile[];
  /** The Profile whose Role Centre `/dashboard` renders — resolved from `active_profile_id`,
   *  falling back to the default profile, then the first assigned, then a Super stand-in. Never
   *  null. */
  activeProfile: Profile;
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
  /** Codes of the Role Centre Profiles assigned to this user (for the admin list). */
  profile_codes: string[];
  /** Names of the additional Permission Sets granted on top of the primary role. */
  extra_permission_set_names: string[];
  /** How many per-user permission overrides this user carries (0 = plain role). */
  override_count: number;
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
  identification_no: string | null;
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
  /** The formal Employer master record this member is linked to, for checkoff/salary batch
   *  routing — separate from the free-text `employer` column above. See lib/employers.ts. */
  employer_id: number | null;
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
  /** The linked Employer master record's name (employer_id), for checkoff/salary batch routing —
   *  separate from the free-text `employer` column. */
  employer_ref_name: string | null;
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
  identification_no: string | null;
}

/* ------------------------------------------------------- account instructions */

/** AL "Account Instruction Type" (Enum52204019). */
export type AccountInstructionType = 'PREDEFINED' | 'USER_DEFINED';

/** AL "Account Instructions" (Tab52204129) — the admin-defined list of standard operating
 *  instructions a member can pick from at registration. */
export interface AccountInstruction {
  id: number;
  code: string;
  description: string;
  active: Flag;
  sort: number;
}

/** AL "Member Account Instructions" (Tab52204009) — one instruction line against a member,
 *  a member application, or a member edit request (`owner_no` is whichever key applies). */
export interface AccountInstructionLine {
  id: number;
  line_no: number;
  instruction_type: AccountInstructionType;
  instruction: string;
}
export interface MemberAccountInstruction extends AccountInstructionLine { member_id: number }
export interface MemberApplicationAccountInstruction extends AccountInstructionLine { application_no: string }
export interface MemberEditAccountInstruction extends AccountInstructionLine { edit_no: string }

export interface MemberNominee {
  id: number;
  member_id: number;
  name: string;
  relationship: string | null;
  phone: string | null;
  identification_no: string | null;
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
  identification_no: string | null;
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
  identification_no: string | null;
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

/** AL's "Pay From Account Type" (Tab52204084) — CASH is paid at the till (no savings account
 *  touched, payment_reference is the receipt/reference for it); MEMBER_ACCOUNT is deducted from
 *  one of the member's own accounts (debit_account_id). See lib/memberActivation.ts. */
export type PayFromAccountType = 'CASH' | 'MEMBER_ACCOUNT';

export interface MemberActivationRequest {
  no: string;
  member_id: number;
  reason: string | null;
  pay_from_account_type: PayFromAccountType;
  payment_reference: string | null;
  transaction_charge_id: number | null;
  debit_account_id: number | null;
  status: DocumentStatus;
  decision_reason: string | null;
  created_at: IsoDateTime | null;
  created_by: string | null;
  processed_at: IsoDateTime | null;
  processed_by: string | null;
  journal_id: number | null;
}

export interface MemberActivationRequestWithDimensions extends MemberActivationRequest {
  member_no: string;
  member_first_name: string;
  member_last_name: string;
  member_status: MemberStatus;
  transaction_charge_code: string | null;
  transaction_charge_description: string | null;
  debit_account_no: string | null;
  debit_account_balance: Cents | null;
  debit_account_hold_amount: Cents | null;
  debit_account_min_balance: Cents | null;
  /** Computed live off the charge configuration (not stored) — see
   *  lib/memberActivation.ts's withChargeAmount(). Null when no charge is selected. */
  charge_amount: Cents | null;
}

export interface MemberReadmissionRequest {
  no: string;
  member_id: number;
  reason: string | null;
  pay_from_account_type: PayFromAccountType;
  payment_reference: string | null;
  transaction_charge_id: number | null;
  debit_account_id: number | null;
  status: DocumentStatus;
  decision_reason: string | null;
  created_at: IsoDateTime | null;
  created_by: string | null;
  processed_at: IsoDateTime | null;
  processed_by: string | null;
  journal_id: number | null;
}

export interface MemberReadmissionRequestWithDimensions extends MemberReadmissionRequest {
  member_no: string;
  member_first_name: string;
  member_last_name: string;
  member_status: MemberStatus;
  transaction_charge_code: string | null;
  transaction_charge_description: string | null;
  debit_account_no: string | null;
  debit_account_balance: Cents | null;
  debit_account_hold_amount: Cents | null;
  debit_account_min_balance: Cents | null;
  /** Computed live off the charge configuration (not stored) — see
   *  lib/memberReadmission.ts's withChargeAmount(). Null when no charge is selected. */
  charge_amount: Cents | null;
}

/** See lib/standingOrders.ts's file header for what AL's fuller STO Types enum collapses into. */
export type StandingOrderClass = 'INTERNAL' | 'EXTERNAL' | 'LOAN';
export type StandingOrderAmountType = 'FIXED' | 'SWEEP' | 'AMOUNT_BASED';
/** Meaningful only for amount_type = FIXED — see the standing_order model's own doc comment. */
export type StandingOrderRunType = 'SPECIFIC_DAY' | 'END_MONTH' | 'DAILY';

export interface StandingOrder {
  no: string;
  member_id: number;
  account_id: number;
  standing_order_class: StandingOrderClass;
  amount_type: StandingOrderAmountType;
  amount: Cents;
  amount_limit: Cents;
  destination_member_id: number | null;
  destination_account_id: number | null;
  /** EXTERNAL only — the SACCO's own Bank/Cashbook account the payout is made through. */
  destination_bank_account_id: number | null;
  destination_loan_id: number | null;
  posting_description: string | null;
  run_type: StandingOrderRunType;
  run_from_day: number | null;
  start_date: IsoDate;
  till_further_notice: boolean;
  period_months: number | null;
  end_date: IsoDate | null;
  transaction_charge_id: number | null;
  /** Excludes this order from runStandingOrders()'s own daily sweep — it only ever recovers
   *  through Checkoff & Salary Processing's Calculate step, matched by standing_order_class. */
  salary_based: boolean;
  status: DocumentStatus;
  decision_reason: string | null;
  running: boolean;
  terminated: boolean;
  freezed: boolean;
  freeze_end_date: IsoDate | null;
  last_run_date: IsoDate | null;
  created_at: IsoDateTime | null;
  created_by: string | null;
}

export interface StandingOrderWithDimensions extends StandingOrder {
  member_no: string;
  member_first_name: string;
  member_last_name: string;
  account_no: string;
  account_balance: Cents;
  account_hold_amount: Cents;
  account_min_balance: Cents;
  destination_member_no: string | null;
  destination_first_name: string | null;
  destination_last_name: string | null;
  destination_account_no: string | null;
  destination_bank_account_code: string | null;
  destination_bank_account_name: string | null;
  destination_loan_no: string | null;
  transaction_charge_code: string | null;
  transaction_charge_description: string | null;
}

/** One standing_order's outcome from a single lib/standingOrders.ts run — 'NONE' covers every
 *  reason nothing happened (not due yet, frozen, no available balance, below the Amount Based
 *  threshold, the member is Dormant, ...), carried in `note` rather than its own action code, the
 *  same shallow shape lib/entranceFeeRecovery.ts's own result type uses. */
export type StandingOrderRunAction = 'NONE' | 'POSTED' | 'TERMINATED';

export interface StandingOrderRunResult {
  no: string;
  action: StandingOrderRunAction;
  posted: Cents;
  charged: Cents;
  note: string | null;
}

export interface StandingOrderRunSummary {
  results: StandingOrderRunResult[];
  posted: number;
  terminated: number;
  totalPosted: Cents;
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

/* ------------------------------------------------------- FOSA tellering */

/** bank_account.account_type — see lib/cashManagement.ts. */
export type BankAccountType = 'MAIN' | 'TREASURY' | 'TILL' | 'PETTY_CASH' | 'OTHER';

/** AL "FOSA Transaction Types" (the five treasury/till cash movements). */
export type FosaDocumentType =
  | 'RECEIVE_FROM_BANK' | 'TREASURY_REQUEST' | 'INTER_TILL' | 'TREASURY_RETURN' | 'SEND_TO_BANK';

export type TellerTransactionType = 'CASH_DEPOSIT' | 'CASH_WITHDRAWAL';

export type DenominationDocumentKind = 'FOSA' | 'TELLER';

export interface Denomination {
  id: number;
  code: string;
  description: string;
  value: Cents;
  active: boolean;
  sort_order: number;
}

/** One denomination row for a specific document, joined to its master for description/value. */
export interface DenominationLine {
  denomination_id: number;
  code: string;
  description: string;
  value: Cents;
  quantity: number;
  total: Cents;
}

export interface TellerSetup {
  id: number;
  user_username: string;
  setup_type: 'TELLER' | 'TREASURY';
  bank_account_id: number;
  max_capacity: Cents;
  min_capacity: Cents;
  approval_limit: Cents;
  created_at: IsoDateTime | null;
  created_by: string | null;
}

export interface TellerSetupWithAccount extends TellerSetup {
  bank_account_code: string;
  bank_account_name: string;
  bank_account_type: BankAccountType;
}

export interface FosaTransaction {
  no: string;
  document_type: FosaDocumentType;
  source_bank_account_id: number;
  destination_bank_account_id: number;
  amount: Cents;
  status: DocumentStatus;
  decision_reason: string | null;
  posted: boolean;
  journal_id: number | null;
  global_dimension_1_id: number | null;
  global_dimension_2_id: number | null;
  created_at: IsoDateTime | null;
  created_by: string | null;
  posted_at: IsoDateTime | null;
  posted_by: string | null;
}

export interface FosaTransactionView extends FosaTransaction {
  source_code: string;
  source_name: string;
  source_account_type: BankAccountType;
  source_balance: Cents;
  destination_code: string;
  destination_name: string;
  destination_account_type: BankAccountType;
  destination_balance: Cents;
  journal_no: string | null;
  /** Sum of this document's denomination breakdown — see lib/denominations.ts. */
  denomination_total: Cents;
}

export interface TellerTransaction {
  no: string;
  transaction_type: TellerTransactionType;
  member_id: number;
  savings_account_id: number;
  till_bank_account_id: number;
  teller_username: string;
  amount: Cents;
  source_of_funds: string | null;
  transacted_by_name: string | null;
  transacted_by_id_no: string | null;
  transaction_charge_id: number | null;
  charge_amount: Cents;
  available_balance: Cents;
  book_balance: Cents;
  approval_required: boolean;
  status: DocumentStatus;
  decision_reason: string | null;
  posted: boolean;
  journal_id: number | null;
  slip_emailed_at: IsoDateTime | null;
  global_dimension_1_id: number | null;
  global_dimension_2_id: number | null;
  created_at: IsoDateTime | null;
  created_by: string | null;
  posted_at: IsoDateTime | null;
  posted_by: string | null;
}

export interface TellerTransactionView extends TellerTransaction {
  member_no: string;
  member_first_name: string;
  member_last_name: string;
  member_email: string | null;
  member_identification_no: string | null;
  /** Cloudinary public ids for the teller to authenticate the person at the counter. */
  member_photo: string | null;
  member_signature_image: string | null;
  account_no: string;
  account_product_name: string;
  account_balance: Cents;
  account_hold_amount: Cents;
  account_min_balance: Cents;
  account_gl_control_id: number;
  till_code: string;
  till_name: string;
  transaction_charge_code: string | null;
  transaction_charge_description: string | null;
  journal_no: string | null;
  denomination_total: Cents;
}

/* ------------------------------------------------------- Liens / holds */

/** AL "Lien" transaction type — HOLD places a hold on part of a deposit balance, RELEASE lifts
 *  a previous hold. */
export type LienTransactionType = 'HOLD' | 'RELEASE';

export interface MemberLien {
  no: string;
  member_id: number;
  savings_account_id: number;
  transaction_type: LienTransactionType;
  amount: Cents;
  narration: string | null;
  posting_date: IsoDate;
  status: DocumentStatus;
  decision_reason: string | null;
  processed: boolean;
  global_dimension_1_id: number | null;
  global_dimension_2_id: number | null;
  created_at: IsoDateTime | null;
  created_by: string | null;
  processed_at: IsoDateTime | null;
  processed_by: string | null;
}

export interface MemberLienView extends MemberLien {
  member_no: string;
  member_first_name: string;
  member_last_name: string;
  account_no: string;
  account_product_name: string;
  account_balance: Cents;
  account_hold_amount: Cents;
  account_min_balance: Cents;
  /** balance - hold_amount - min_balance, clamped to >= 0 (AL's "ActualBalance" — the most that
   *  can still be held). */
  account_available: Cents;
}

/** AL Tab52204093 "Amount Type" — PARTIAL keeps the source above its product minimum balance;
 *  FULL may drain the source to zero. */
export type InterAccountTransferAmountType = 'PARTIAL' | 'FULL';

/** AL "Inter Account Transfer" (Tab52204093) — a maker-checker cash move between two member
 *  deposit accounts. Only `savings_product.allow_transfer` products can be the source. */
export interface InterAccountTransfer {
  no: string;
  source_member_id: number;
  source_account_id: number;
  destination_member_id: number;
  destination_account_id: number;
  amount_type: InterAccountTransferAmountType;
  amount: Cents;
  transaction_charge_id: number | null;
  charge_amount: Cents;
  narration: string | null;
  posting_date: IsoDate;
  status: DocumentStatus;
  decision_reason: string | null;
  posted: boolean;
  journal_id: number | null;
  global_dimension_1_id: number | null;
  global_dimension_2_id: number | null;
  created_at: IsoDateTime | null;
  created_by: string | null;
  posted_at: IsoDateTime | null;
  posted_by: string | null;
}

export interface InterAccountTransferView extends InterAccountTransfer {
  source_member_no: string;
  source_first_name: string;
  source_last_name: string;
  destination_member_no: string;
  destination_first_name: string;
  destination_last_name: string;
  source_account_no: string;
  source_product_name: string;
  source_balance: Cents;
  source_hold_amount: Cents;
  source_min_balance: Cents;
  destination_account_no: string;
  destination_product_name: string;
  destination_balance: Cents;
  transaction_charge_code: string | null;
  journal_no: string | null;
  /** For PARTIAL: balance - hold - min_balance; for FULL: balance - hold. Clamped >= 0. */
  source_available: Cents;
}

/* --------------------------------------------------------- share trading */

export type ShareWindowStatus = 'New' | 'Published' | 'Retired';
export type ShareOnNoBid = 'Extend' | 'Reverse';
export type ShareFloatType = 'Partial' | 'Full';
export type ShareProceedsType = 'FOSA Account' | 'NWD Account';
export type ShareTradeSource = 'Walking' | 'App' | 'USSD' | 'Portal';
export type ShareFloatingOutcome = 'Transferred' | 'Taken Down' | 'Reversed';

/** AL Tab52204133 "Share Trading Setup" — the trading window a floating is sold in. */
export interface ShareTradingWindow {
  no: string;
  description: string;
  start_date: IsoDate;
  end_date: IsoDate;
  /** Par value per share — the ceiling on any bid. */
  base_price: Cents;
  /** The floor on a seller's minimum acceptable price. */
  reserve_price: Cents;
  transaction_charge_id: number | null;
  clearing_account_id: number;
  holding_account_id: number;
  share_life: string | null;
  tolerance_period: string | null;
  on_no_bid: ShareOnNoBid;
  minimum_shares_to_float: number;
  published: boolean;
  status: ShareWindowStatus;
  created_at: IsoDateTime | null;
  created_by: string | null;
}

export interface ShareTradingWindowView extends ShareTradingWindow {
  transaction_charge_code: string | null;
  clearing_account_code: string;
  clearing_account_name: string;
  holding_account_code: string;
  holding_account_name: string;
  /** FlowFields "Shares On Market" / "Total Value On Market": published, not yet archived. */
  shares_on_market: number;
  value_on_market: Cents;
  floatings: number;
}

/** AL Tab52204134 "Share Floating" — a member's offer to sell share capital. */
export interface ShareFloating {
  no: string;
  window_no: string;
  member_id: number;
  share_account_id: number;
  float_type: ShareFloatType;
  par_value: Cents;
  reserve_price: Cents;
  share_life: string | null;
  tolerance_period: string | null;
  on_no_bid: ShareOnNoBid;
  total_shares: number;
  shares_to_float: number;
  minimum_acceptable_price: Cents;
  floated_value: Cents;
  charge_amount: Cents;
  proceeds_type: ShareProceedsType;
  proceeds_account_id: number | null;
  payment_method_code: string | null;
  external_reference_no: string | null;
  payment_date: IsoDate | null;
  source: ShareTradeSource;
  narration: string | null;
  status: DocumentStatus;
  decision_reason: string | null;
  published: boolean;
  published_on: IsoDate | null;
  expiry_date: IsoDate | null;
  awarded: boolean;
  purchase_date: IsoDate | null;
  payment_due_date: IsoDate | null;
  archived: boolean;
  outcome: ShareFloatingOutcome | null;
  publish_journal_id: number | null;
  purchase_journal_id: number | null;
  transfer_journal_id: number | null;
  takedown_journal_id: number | null;
  global_dimension_1_id: number | null;
  global_dimension_2_id: number | null;
  created_at: IsoDateTime | null;
  created_by: string | null;
  transferred_at: IsoDateTime | null;
  transferred_by: string | null;
}

/**
 * Where a floating stands on the market — AL keeps this as three flags beside the document
 * status; one word is easier to filter and print.
 *   Draft      Open / Pending / Approved, not yet published
 *   On Market  published, taking bids
 *   Awarded    a bid has been posted as the purchase; waiting for payment and transfer
 *   Closed     archived — Transferred, Taken Down or Reversed
 */
export type ShareFloatingStage = 'Draft' | 'On Market' | 'Awarded' | 'Closed';

export interface ShareFloatingView extends ShareFloating {
  member_no: string;
  first_name: string;
  last_name: string;
  member_phone: string | null;
  member_email: string | null;
  share_account_no: string;
  share_product_name: string;
  share_balance: Cents;
  proceeds_account_no: string | null;
  proceeds_product_name: string | null;
  window_description: string;
  window_status: ShareWindowStatus;
  transaction_charge_code: string | null;
  stage: ShareFloatingStage;
  bids: number;
  /** FlowField "Maximum Bid Price". */
  maximum_bid_price: Cents;
  /** FlowField "Payment Amount": the awarded bid's total. */
  payment_amount: Cents;
  /** FlowField "Allocated Amount": what the buyer has allocated towards it so far. */
  allocated_amount: Cents;
  publish_journal_no: string | null;
  purchase_journal_no: string | null;
  transfer_journal_no: string | null;
  takedown_journal_no: string | null;
}

/** AL Tab52204135 "Share Trading Lines" — one member's bid. */
export interface ShareBid {
  id: number;
  floating_no: string;
  member_id: number;
  share_account_id: number;
  bid_price: Cents;
  bid_date: IsoDateTime;
  shares: number;
  charges: Cents;
  total_amount: Cents;
  awarded: boolean;
  bought: boolean;
  source: ShareTradeSource;
  created_by: string | null;
}

export interface ShareBidView extends ShareBid {
  member_no: string;
  first_name: string;
  last_name: string;
  member_phone: string | null;
  member_email: string | null;
  share_account_no: string;
  share_balance: Cents;
}

/** AL Tab52204136 "Share Transfer Receipt" — the buyer's payment allocations. */
export interface ShareTransferReceipt {
  id: number;
  floating_no: string;
  savings_account_id: number;
  allocated_amount: Cents;
  description: string | null;
  created_at: IsoDateTime | null;
  created_by: string | null;
}

export interface ShareTransferReceiptView extends ShareTransferReceipt {
  account_no: string;
  product_name: string;
  balance: Cents;
  available: Cents;
}

export interface ShareFloatingDetail extends ShareFloatingView {
  bids: number;
  bid_lines: ShareBidView[];
  receipts: ShareTransferReceiptView[];
}

/* ------------------------------------------------------ imprest / petty cash */

export type EmployeeLedgerEntryType =
  | 'IMPREST_ISSUE' | 'IMPREST_SURRENDER' | 'IMPREST_REFUND' | 'CLAIM_PAID' | 'PAYROLL_RECOVERY'
  | 'PAYROLL_CLAIM' | 'RECEIPT' | 'PAYMENT' | 'STAFF_CLAIM';

/** The employee subledger — positive means the employee owes the SACCO. */
export interface EmployeeLedgerEntry {
  id: number;
  employee_id: number;
  entry_type: EmployeeLedgerEntryType;
  document_no: string;
  posting_date: IsoDate;
  amount: Cents;
  description: string | null;
  journal_id: number | null;
  created_at: IsoDateTime | null;
  created_by: string | null;
}

export interface EmployeeLedgerEntryView extends EmployeeLedgerEntry {
  employee_no: string;
  first_name: string;
  last_name: string;
  journal_no: string | null;
  running_balance: Cents;
}

export interface ImprestPurpose { code: string; description: string; status: 'ACTIVE' | 'INACTIVE' }

export type ImprestRequestFor = 'Self' | 'Other';
export type ImprestSurrenderStatus = 'Open' | 'Pending Approval' | 'Approved' | 'Closed';
export type ImprestSettlement = 'Receive Now' | 'Deduct from Payroll' | 'Pay Now' | 'Pay from Payroll';

/**
 * Where an imprest stands — the AL keeps Posted / Surrendered / Transfered To Payroll as flags
 * beside two status fields; one word for the list.
 *   Request     the request itself: Open, pending, approved, not yet issued
 *   Issued      money paid out; the employee is in the field, surrender not yet submitted
 *   Surrender   the surrender is in: pending approval, or approved and waiting to be posted
 *   Closed      surrendered and posted (or recovered in full through payroll)
 */
export type ImprestStage = 'Request' | 'Issued' | 'Surrender' | 'Closed';

/** AL Tab52203447 "Request Header" (Imprest / Surrender). */
export interface ImprestRequest {
  no: string;
  employee_id: number;
  request_date: IsoDate;
  purpose_code: string | null;
  purpose: string;
  description: string | null;
  request_for: ImprestRequestFor;
  departure_location: string | null;
  departure_date: IsoDate | null;
  return_date: IsoDate | null;
  total_days: number;
  justification: string | null;
  phone_no: string | null;
  currency_code: string;
  paying_bank_account_id: number | null;
  pay_mode_code: string | null;
  payment_tx_no: string | null;
  cheque_date: IsoDate | null;
  due_date: IsoDate | null;
  status: DocumentStatus;
  decision_reason: string | null;
  posted: boolean;
  posted_at: IsoDateTime | null;
  posted_by: string | null;
  posted_journal_id: number | null;
  pv_no: string | null;
  surrender_status: ImprestSurrenderStatus;
  surrender_date: IsoDate | null;
  surrender_decision_reason: string | null;
  surrendered: boolean;
  surrender_posted_at: IsoDateTime | null;
  surrender_posted_by: string | null;
  surrender_journal_id: number | null;
  settlement: ImprestSettlement | null;
  receiving_bank_account_id: number | null;
  receipt_mode_code: string | null;
  receipt_tx_no: string | null;
  claim_paying_bank_account_id: number | null;
  claim_pay_mode_code: string | null;
  claim_payment_tx_no: string | null;
  transfer_to_payroll: boolean;
  transferred_to_payroll: boolean;
  payroll_transaction_id: number | null;
  payroll_transferred_at: IsoDateTime | null;
  payroll_transferred_by: string | null;
  global_dimension_1_id: number | null;
  global_dimension_2_id: number | null;
  created_at: IsoDateTime | null;
  created_by: string | null;
}

export interface ImprestRequestView extends ImprestRequest {
  employee_no: string;
  first_name: string;
  last_name: string;
  employee_phone: string | null;
  employee_email: string | null;
  job_title: string | null;
  purpose_description: string | null;
  paying_bank_code: string | null;
  paying_bank_name: string | null;
  receiving_bank_code: string | null;
  claim_bank_code: string | null;
  stage: ImprestStage;
  /** FlowFields: Sum of Request Amount / Actual Spent; Net = requested − spent. */
  request_amount: Cents;
  surrender_amount: Cents;
  net_refund: Cents;
  /** The employee's whole subledger balance, not just this imprest. */
  employee_balance: Cents;
  overdue_days: number;
  posted_journal_no: string | null;
  surrender_journal_no: string | null;
  lines: number;
}

/** AL Tab52203449 "Request Lines". */
export interface ImprestRequestLine {
  id: number;
  request_no: string;
  line_no: number;
  gl_account_id: number;
  narration: string | null;
  quantity: number;
  unit_cost: Cents;
  request_amount: Cents;
  actual_spent: Cents;
  surrender_note: string | null;
}

export interface ImprestRequestLineView extends ImprestRequestLine {
  gl_account_code: string;
  gl_account_name: string;
  /** actual − requested: positive is a claim, negative a refund. */
  difference: Cents;
}

export interface ImprestRequestDetail extends ImprestRequestView {
  line_items: ImprestRequestLineView[];
}

/** AL Tab52203444 "Petty Cash Header". */
export interface PettyCash {
  no: string;
  employee_id: number;
  request_date: IsoDate;
  posting_date: IsoDate | null;
  paying_bank_account_id: number | null;
  payment_to: string | null;
  on_behalf_of: string | null;
  payment_narration: string;
  pay_mode_code: string | null;
  payment_tx_no: string | null;
  cheque_date: IsoDate | null;
  currency_code: string;
  status: DocumentStatus;
  decision_reason: string | null;
  posted: boolean;
  posted_at: IsoDateTime | null;
  posted_by: string | null;
  journal_id: number | null;
  paid: boolean;
  paid_at: IsoDateTime | null;
  paid_by: string | null;
  global_dimension_1_id: number | null;
  global_dimension_2_id: number | null;
  created_at: IsoDateTime | null;
  created_by: string | null;
}

export interface PettyCashView extends PettyCash {
  employee_no: string;
  first_name: string;
  last_name: string;
  job_title: string | null;
  paying_bank_code: string | null;
  paying_bank_name: string | null;
  total_amount: Cents;
  journal_no: string | null;
  lines: number;
}

export interface PettyCashLine {
  id: number;
  petty_cash_no: string;
  line_no: number;
  gl_account_id: number;
  description: string | null;
  amount: Cents;
}

export interface PettyCashLineView extends PettyCashLine {
  gl_account_code: string;
  gl_account_name: string;
}

export interface PettyCashDetail extends PettyCashView {
  line_items: PettyCashLineView[];
}

export type StaffClaimSettlement = 'Pay Now' | 'Pay from Payroll';

/** AL Tab52203447 "Request Header" with Request Type Staff Claim. */
export interface StaffClaim {
  no: string;
  employee_id: number;
  claim_date: IsoDate;
  description: string;
  justification: string | null;
  currency_code: string;
  settlement: StaffClaimSettlement;
  paying_bank_account_id: number | null;
  pay_mode_code: string | null;
  payment_tx_no: string | null;
  status: DocumentStatus;
  decision_reason: string | null;
  posted: boolean;
  posted_at: IsoDateTime | null;
  posted_by: string | null;
  journal_id: number | null;
  payment_stopped: boolean;
  stopped_at: IsoDateTime | null;
  stopped_by: string | null;
  stop_reason: string | null;
  transferred_to_payroll: boolean;
  payroll_transaction_id: number | null;
  global_dimension_1_id: number | null;
  global_dimension_2_id: number | null;
  created_at: IsoDateTime | null;
  created_by: string | null;
}

export interface StaffClaimView extends StaffClaim {
  employee_no: string;
  first_name: string;
  last_name: string;
  job_title: string | null;
  paying_bank_code: string | null;
  paying_bank_name: string | null;
  total_amount: Cents;
  journal_no: string | null;
  lines: number;
}

export interface StaffClaimLine {
  id: number;
  claim_no: string;
  line_no: number;
  gl_account_id: number;
  narration: string | null;
  expense_date: IsoDate | null;
  receipt_ref: string | null;
  quantity: number;
  unit_cost: Cents;
  amount: Cents;
}

export interface StaffClaimLineView extends StaffClaimLine {
  gl_account_code: string;
  gl_account_name: string;
}

export interface StaffClaimDetail extends StaffClaimView {
  line_items: StaffClaimLineView[];
}

/* ------------------------------------------------------- requisitions */

export type RequisitionType = 'Store Requisition' | 'Purchase Requisition';
export type RequisitionLineType = 'Item' | 'G/L Account' | 'Fixed Asset';
/** Enum52203430 "Procurement Methods". */
export type ProcurementMethod = 'RFQ' | 'RFP' | 'Direct Procurement' | 'Restricted Tendering' | 'Open Tendering' | 'Low Value Procurement';
/** Pag52203556 Requisitions Review — what procurement does with an approved purchase requisition line. */
export type RequisitionDecision = '' | 'RFQ' | 'Order' | 'Append to Order';
/** AL "PR Closed By". */
export type RequisitionCloseReason = 'Purchase Order' | 'Direct Receipt of Goods/Services' | 'Rejection';
/** Open | Pending Approval | Approved, plus Received once the store requester confirms receipt. */
export type RequisitionStatus = DocumentStatus | 'Received';

/** AL Tab52203515 "Requisition Header". */
export interface Requisition {
  no: string;
  requisition_type: RequisitionType;
  employee_id: number;
  title: string;
  description: string | null;
  requisition_date: IsoDate;
  needed_by_date: IsoDate | null;
  expiration_date: IsoDate | null;
  requested_delivery_date: IsoDate | null;
  currency_code: string;
  location_id: number | null;
  procurement_method: ProcurementMethod | null;
  supplier_id: number | null;
  status: RequisitionStatus;
  decision_reason: string | null;
  issued: boolean;
  issued_at: IsoDateTime | null;
  issued_by: string | null;
  received: boolean;
  received_at: IsoDateTime | null;
  received_by: string | null;
  pr_closed: boolean;
  pr_closed_by: RequisitionCloseReason | null;
  pr_closed_at: IsoDateTime | null;
  pr_closed_by_user: string | null;
  pr_close_reason: string | null;
  po_generated_directly: boolean;
  po_generated_by: string | null;
  po_generated_at: IsoDateTime | null;
  po_number: string | null;
  global_dimension_1_id: number | null;
  global_dimension_2_id: number | null;
  created_at: IsoDateTime | null;
  created_by: string | null;
}

export interface RequisitionView extends Requisition {
  employee_no: string;
  first_name: string;
  last_name: string;
  job_title: string | null;
  location_code: string | null;
  location_name: string | null;
  supplier_no: string | null;
  supplier_name: string | null;
  /** AL flowfields "Quantity Requested" / Amount, plus the issue and processing progress. */
  total_quantity: number;
  total_quantity_approved: number;
  total_quantity_issued: number;
  total_amount: Cents;
  lines: number;
  lines_processed: number;
}

/** AL Tab52203516 "Requisition Lines". */
export interface RequisitionLine {
  id: number;
  requisition_no: string;
  line_no: number;
  type: RequisitionLineType;
  no: string;
  description: string;
  item_id: number | null;
  gl_account_id: number | null;
  unit_of_measure_id: number | null;
  quantity: number;
  quantity_approved: number;
  unit_price: Cents;
  amount: Cents;
  location_id: number | null;
  quantity_to_issue: number;
  quantity_issued: number;
  issued_at: IsoDateTime | null;
  issued_by: string | null;
  decision: RequisitionDecision;
  target_no: string | null;
  processed: boolean;
  order_no: string | null;
}

export interface RequisitionLineView extends RequisitionLine {
  unit_of_measure_code: string | null;
  location_code: string | null;
  /** AL "Quantity in Store" — on hand at the line's location, in the line's unit. */
  quantity_in_store: number;
  /** For Append to Order / RFQ / Order — the vendor or order the target resolves to. */
  target_name: string | null;
}

export interface RequisitionDetail extends RequisitionView {
  line_items: RequisitionLineView[];
  /** Purchase documents raised from this requisition (purchase_header.requisition_no). */
  documents: { no: string; document_type: PurchaseDocumentType; vendor_no: string; vendor_name: string; status: string; amount: Cents }[];
  /** Store issues posted from this requisition (item_journal_line.requisition_line_id). */
  issues: { no: string; line_no: number; item_no: string; description: string; quantity: number; posting_date: IsoDate; posted_by: string | null; location_code: string }[];
}

/* ------------------------------------------------------- bankers cheque */

export type ChequeTypeKind = 'BANKERS' | 'EXTERNAL';

/** AL "Cheque Types" (Tab52204122). BANKERS backs lib/bankersCheques.ts; EXTERNAL backs
 *  lib/chequeDeposits.ts (clearing / bouncing / express charges + maturity period). */
export interface ChequeType {
  id: number;
  code: string;
  type: ChequeTypeKind;
  description: string;
  maximum_amount: Cents;
  clearing_gl_account_id: number;
  clearing_charge_id: number | null;
  bouncing_charge_id: number | null;
  express_charge_id: number | null;
  in_house: boolean;
  maturity_days: number;
  status: 'ACTIVE' | 'INACTIVE';
  created_at: IsoDateTime | null;
  created_by: string | null;
}

export interface ChequeTypeWithDetail extends ChequeType {
  clearing_gl_account_code: string;
  clearing_gl_account_name: string;
  clearing_charge_code: string | null;
  bouncing_charge_code: string | null;
  express_charge_code: string | null;
  cheques_issued: number;
}

/* -------------------------------------------------------- cheque deposit */

export type ChequeDepositStatus = DocumentStatus | 'Cleared' | 'Bounced';

/** AL "Cheque Deposits" (Tab52204124), Deposit document type. */
export interface ChequeDeposit {
  no: string;
  cheque_type_id: number;
  description: string | null;
  member_id: number;
  savings_account_id: number;
  cheque_no: string | null;
  cheque_date: IsoDate | null;
  deposit_date: IsoDate;
  maturity_date: IsoDate;
  in_house: boolean;
  amount: Cents;
  express_cheque: boolean;
  drawer_account_name: string | null;
  drawer_bank: string | null;
  drawer_branch: string | null;
  drawer_account_no: string | null;
  clearing_gl_account_id: number;
  clearing_charge_id: number | null;
  bouncing_charge_id: number | null;
  express_charge_id: number | null;
  charge_amount: Cents;
  express_hold_amount: Cents;
  status: ChequeDepositStatus;
  decision_reason: string | null;
  cleared_by: string | null;
  clearance_date: IsoDate | null;
  journal_id: number | null;
  global_dimension_1_id: number | null;
  global_dimension_2_id: number | null;
  created_at: IsoDateTime | null;
  created_by: string | null;
}

export interface ChequeDepositView extends ChequeDeposit {
  cheque_type_code: string;
  member_no: string;
  member_first_name: string;
  member_last_name: string;
  account_no: string;
  account_product_name: string;
  account_balance: Cents;
  clearing_gl_account_code: string;
  clearing_charge_code: string | null;
  journal_no: string | null;
  /** True once the deposit is Approved and on/after its maturity date (ready for normal clearing). */
  matured: boolean;
  /** Sum of this deposit's cheque instructions. */
  instructions_total: Cents;
}

export type ChequeInstructionTarget = 'ACCOUNT' | 'LOAN';

/** AL "Cheque Instructions" (Tab52204087) — one distribution line on a cheque deposit. */
export interface ChequeInstruction {
  id: number;
  cheque_deposit_no: string;
  line_no: number;
  target_type: ChequeInstructionTarget;
  savings_account_id: number | null;
  loan_id: number | null;
  amount: Cents;
  created_at: IsoDateTime | null;
  created_by: string | null;
}

export interface ChequeInstructionView extends ChequeInstruction {
  /** Display name of the target — the account (no. + product) or the loan (no. + product). */
  target_label: string;
  /** Live balance of the target — the account balance, or the loan's outstanding balance. */
  target_balance: Cents;
}

/** AL "Bankers Cheque" (Tab52204123) — a maker-checker sale of a banker's cheque against a
 *  member's deposit account. */
export interface BankersCheque {
  no: string;
  cheque_type_id: number;
  description: string | null;
  max_amount: Cents;
  member_id: number;
  savings_account_id: number;
  payee_details: string | null;
  cheque_no: string | null;
  book_balance: Cents;
  amount: Cents;
  transaction_charge_id: number | null;
  charge_amount: Cents;
  net_amount: Cents;
  posting_date: IsoDate;
  status: DocumentStatus;
  decision_reason: string | null;
  posted: boolean;
  journal_id: number | null;
  global_dimension_1_id: number | null;
  global_dimension_2_id: number | null;
  created_at: IsoDateTime | null;
  created_by: string | null;
  posted_at: IsoDateTime | null;
  posted_by: string | null;
}

export interface BankersChequeView extends BankersCheque {
  cheque_type_code: string;
  member_no: string;
  member_first_name: string;
  member_last_name: string;
  account_no: string;
  account_product_name: string;
  account_balance: Cents;
  account_hold_amount: Cents;
  account_min_balance: Cents;
  /** balance - hold_amount - min_balance, clamped >= 0 (AL's available-balance check). */
  account_available: Cents;
  clearing_gl_account_code: string;
  transaction_charge_code: string | null;
  journal_no: string | null;
}

/** One line of the AL Rep52204097 "Bankers Cheque Schedule" — posted cheques only. */
export interface BankersChequeScheduleRow {
  no: string;
  posting_date: IsoDate;
  cheque_no: string | null;
  account_name: string;
  account_no: string;
  payee_details: string | null;
  amount: Cents;
  charge_amount: Cents;
  net_amount: Cents;
}

/** The rendered slip view-model — AL Rep52204068 / Rep52204069 dataset. */
export interface TellerSlip {
  doc: TellerTransactionView;
  org: Organisation;
  amountWords: string;
  bookBalanceBefore: Cents;
  bookBalanceAfter: Cents;
  availableAfter: Cents;
}

export interface MemberApplicationNextOfKin {
  id: number;
  application_no: string;
  name: string;
  relationship: string | null;
  phone: string | null;
  identification_no: string | null;
}

export interface MemberApplicationNominee {
  id: number;
  application_no: string;
  name: string;
  relationship: string | null;
  phone: string | null;
  identification_no: string | null;
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
  identification_no: string | null;
}

export interface MemberEditNominee {
  id: number;
  edit_no: string;
  name: string;
  relationship: string | null;
  phone: string | null;
  identification_no: string | null;
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
  /** Depth in the Begin-Total / End-Total bracketing, written by Indent Chart of Accounts
   *  (lib/gl.ts's indentChartOfAccounts()). 0 until the chart has been indented. */
  indentation: number;
  balance: Cents;
  status: 'ACTIVE' | 'INACTIVE';
  /** Blocks this account from a manual G/L journal line — see lib/gl.ts's createJournal(). */
  no_direct_posting: Flag;
  vat_bus_posting_group_code: string | null;
  vat_prod_posting_group_code: string | null;
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

/* ------------------------------------------- financial reports (account schedules) */

export type ColumnLayoutType =
  | 'NET_CHANGE' | 'BALANCE_AT_DATE' | 'BEGINNING_BALANCE' | 'YEAR_TO_DATE' | 'ENTIRE_FISCAL_YEAR' | 'FORMULA';
export type FinReportAmountType = 'NET_AMOUNT' | 'DEBIT_AMOUNT' | 'CREDIT_AMOUNT';
export type ColumnShowType = 'ALWAYS' | 'NEVER' | 'WHEN_POSITIVE' | 'WHEN_NEGATIVE';
export type RoundingFactor = 'NONE' | '1' | '1000' | '1000000';
export type AccScheduleTotalingType = 'POSTING_ACCOUNTS' | 'TOTAL_ACCOUNTS' | 'FORMULA' | 'SET_BASE_FOR_PERCENT';
export type AccScheduleRowType = 'NET_CHANGE' | 'BALANCE_AT_DATE' | 'BEGINNING_BALANCE';
export type AccScheduleShowType = 'YES' | 'NO' | 'IF_ANY_NOT_ZERO' | 'IF_ALL_ZERO';

/** Business Central Table 334 "Column Layout Name". */
export interface ColumnLayoutName {
  id: number;
  name: string;
  description: string;
  created_at: string | null;
  created_by: string | null;
}

/** Business Central Table 333 "Column Layout". */
export interface ColumnLayout {
  id: number;
  column_layout_name_id: number;
  line_no: number;
  column_no: string;
  column_header: string;
  column_type: ColumnLayoutType;
  ledger_entry_type: string;
  amount_type: FinReportAmountType;
  formula: string;
  comparison_date_formula: string;
  show: ColumnShowType;
  rounding_factor: RoundingFactor;
  created_at: string | null;
  created_by: string | null;
}

/** Business Central Table 85 "Acc. Schedule Name" — a Financial Report Row Definition. */
export interface AccScheduleName {
  id: number;
  name: string;
  description: string;
  default_column_layout_name: string | null;
  created_at: string | null;
  created_by: string | null;
}

/** Business Central Table 86 "Acc. Schedule Line". */
export interface AccScheduleLine {
  id: number;
  acc_schedule_name_id: number;
  line_no: number;
  row_no: string;
  description: string;
  totaling_type: AccScheduleTotalingType;
  totaling: string;
  amount_type: FinReportAmountType;
  row_type: AccScheduleRowType;
  show: AccScheduleShowType;
  bold: Flag;
  italic: Flag;
  underline: Flag;
  double_underline: Flag;
  show_opposite_sign: Flag;
  new_page: Flag;
  indentation: number;
  dimension_1_totaling: string;
  dimension_2_totaling: string;
  created_at: string | null;
  created_by: string | null;
}

/** Business Central Table 133 "Financial Report" — a Row Definition paired with a Column Layout. */
export interface FinancialReport {
  id: number;
  name: string;
  description: string;
  row_group: string;
  column_group: string;
  created_at: string | null;
  created_by: string | null;
}

export interface FinReportColumn {
  columnNo: string;
  header: string;
  isFormula: boolean;
  /** Windows shown in the sub-heading, e.g. "01 Jan 2026 – 31 Dec 2026". */
  windowLabel: string;
}

export interface FinReportCell {
  /** null when the column's Show rule blanks it. */
  value: number | null;
  /** A percentage/ratio row is rendered as a plain number, an account row as money. */
  isRatio: boolean;
}

export interface FinReportRow {
  rowNo: string;
  description: string;
  indentation: number;
  bold: boolean;
  italic: boolean;
  underline: boolean;
  doubleUnderline: boolean;
  newPage: boolean;
  isRatio: boolean;
  /** True for a caption line (no totaling, not a formula) — values are blank. */
  isCaption: boolean;
  hidden: boolean;
  /** Account filter behind an account row, for the Trial Balance drill-down link. */
  totaling: string;
  cells: FinReportCell[];
}

export interface FinancialReportResult {
  reportName: string;
  reportDescription: string;
  rowGroup: string;
  columnGroup: string;
  from: string | null;
  to: string;
  columns: FinReportColumn[];
  rows: FinReportRow[];
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
  | 'Standing Order' | 'Benevolent Fund' | 'Statement Charge' | 'Member Reactivation';

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
  recoveries: TransactionRecovery[];
}

export type TransactionRecoveryType = 'LOAN' | 'STANDING_ORDER' | 'INTERNAL_DEPOSIT';
/** LOAN: recover from the member's own recovery_mode='CHECKOFF' disbursed loans.
 *  INTERNAL_DEPOSIT: recover into one of the member's own savings accounts. Unused (null) for
 *  STANDING_ORDER — a standing order's own Amount Type (Fixed/Sweep) already decides how much
 *  it recovers. */
export type TransactionRecoveryDeductionType = 'INSTALLMENT' | 'ARREARS' | 'BALANCE' | 'FULL_REMAINING' | 'BOOST_TO_MINIMUM';

/** One priority-ordered recovery rule attached to an 'End Month Salary' Transaction Charge —
 *  Business Central's "Transaction Recoveries". See lib/checkoffBatches.ts's
 *  calculateCheckoffRecoveries(). */
export interface TransactionRecovery {
  id: number;
  transaction_charge_id: number;
  recovery_type: TransactionRecoveryType;
  deduction_type: TransactionRecoveryDeductionType | null;
  savings_product_id: number | null;
  /** STANDING_ORDER only — matches a member's own salary_based, running standing order(s)
   *  directly by class; null matches any class. Several rows, each pinned to a different class,
   *  is how "priority per class" is achieved. */
  standing_order_class: StandingOrderClass | null;
  priority: number;
  description: string | null;
  status: 'ACTIVE' | 'INACTIVE';
}

export interface TransactionRecoveryWithDetail extends TransactionRecovery {
  savings_product_code: string | null;
  savings_product_name: string | null;
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

/* ------------------------------------------------------ loan product charges */

/** The generic shape calculateChargeFromScheme() (lib/loans.ts) matches a base amount against —
 *  structurally satisfied by both TransactionCalcScheme and LoanProductChargeScheme below, so
 *  the one banded-rate engine serves Transaction Charges and Loan Product Charges alike. */
export interface ChargeSchemeBand {
  lower_limit: Cents;
  upper_limit: Cents | null;
  rate_type: ChargeRateType;
  flat_amount: Cents;
  percentage_rate: number;
  upper_charge_limit: Cents;
  lower_charge_limit: Cents;
}

/** A Loan Product Charge line's Calculation Method: a flat Percentage of the loan principal, or
 *  Calculate from Scheme — an amount-banded tariff table (loan_product_charge_scheme). Distinct
 *  from ChargeCalculationType (SCHEME | PERCENT_OF_CHARGE): a loan product charge's base is
 *  always the principal, so there is no Percentage-of-Charge chaining to express here. */
export type LoanChargeCalculationType = 'PERCENTAGE' | 'SCHEME';

/** One charge a loan product levies — the raw loan_product_charge row. */
export interface LoanProductCharge {
  id: number;
  product_id: number;
  charge_id: number;
  gl_account_id: number;
  calculation_type: LoanChargeCalculationType;
  percentage_rate: number;
  /** Scales the resolved amount by termMonths/12 — for a charge priced as an annual rate but
   *  billed once at disbursement rather than levied in full regardless of term. */
  prorate: boolean;
  priority: number;
  status: 'ACTIVE' | 'INACTIVE';
}

/** One amount-band rate rule for a Loan Product Charge line — the loan_product_charge_scheme twin
 *  of TransactionCalcScheme, banded against the loan principal. */
export interface LoanProductChargeScheme extends ChargeSchemeBand {
  id: number;
  loan_product_charge_id: number;
}

/** A Loan Product Charge line joined with its charge code/name, revenue account and scheme
 *  bands — for admin display/editing, and (being a structural superset) the input the
 *  calculation engine reads directly. */
export interface LoanProductChargeDetail extends LoanProductCharge {
  charge_code: string;
  charge_description: string;
  gl_account_code: string;
  gl_account_name: string;
  scheme: LoanProductChargeScheme[];
}

/** One resolved Loan Product Charge amount, ready to post at disbursement or to show as a
 *  fee preview on the application form. */
export interface CalculatedLoanCharge {
  chargeId: number;
  chargeCode: string;
  chargeDescription: string;
  glAccountId: number;
  glAccountCode: string;
  amount: Cents;
  prorated: boolean;
}

/** A loan product with its own Loan Product Charges lines attached — what the New Application
 *  form needs to preview charges client-side (lib/loans.ts's calculateLoanProductCharges) without a
 *  server round trip for every keystroke. */
export interface LoanProductWithCharges extends LoanProduct {
  charges: LoanProductChargeDetail[];
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
  currency_code: string;
  currency_factor: number;
  /** BC closing date ("C31/12/2025"): posted by Close Income Statement — see lib/accounting.ts. */
  closing_entry: number;
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
  debit_lcy: Cents;
  credit_lcy: Cents;
  currency_code: string;
  currency_factor: number;
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

/** A journal line as supplied to postJournal, before it is resolved and stored. Amounts are in
 *  the journal's transaction currency (`currencyCode`); postJournal derives the LCY amounts. */
export interface JournalLineInput {
  /** GL account id (number) or account code (string). */
  account: number | string;
  debit?: Cents;
  credit?: Cents;
  narration?: string | null;
  /** Explicit per-line override — falls back to the header default (see PostJournalOptions) when omitted. */
  globalDimension1Id?: number | null;
  globalDimension2Id?: number | null;
  /** For a line hitting a bank control account — stamped onto its bank_account_ledger_entry. */
  bankDocumentType?: string | null;
  bankDocumentNo?: string | null;
  bankExternalDocumentNo?: string | null;
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
  /** Transaction currency. Omitted → the base currency (KES); line amounts are then LCY. */
  currencyCode?: string | null;
  /** LCY per 1 unit of `currencyCode`. Omitted → resolved from currency_exchange_rate at valueDate. */
  currencyFactor?: number | null;
  /** Business Central's closing date: the journal is dated `valueDate` (a fiscal year's last day)
   *  but sits after it — outside a "..valueDate" filter, inside "..the day after". Only Close
   *  Income Statement sets it; a closed accounting period does not block it, since it changes no
   *  period's result. */
  closingEntry?: boolean;
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
  closing_entry: number;
  description: string | null;
  source_module: string;
  global_dimension_1_code: string | null;
  global_dimension_2_code: string | null;
}

export interface AccountingPeriod {
  id: number;
  code: string; // YYYY-MM
  start_date: IsoDate;
  end_date: IsoDate;
  /** Whether postings are accepted — BC's Allow Posting gate, independent of the fiscal close. */
  status: 'OPEN' | 'CLOSED';
  /** BC "New Fiscal Year": this period starts a fiscal year. */
  new_fiscal_year: number;
  /** BC "Closed": set by Close Year on every period of the year; never cleared. */
  fiscally_closed: number;
  /** BC "Date Locked": set alongside fiscally_closed. */
  date_locked: number;
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
  /** FOSA tellering role — see lib/cashManagement.ts. */
  account_type: BankAccountType;
  currency_code: string;
  balance_lcy: Cents;
  bank_acc_posting_group_code: string | null;
  bank_branch_no: string | null;
  bank_sort_code: string | null;
  external_bank_code: string | null;
  iban: string | null;
  swift_code: string | null;
  min_balance: Cents;
  last_statement_no: number;
  balance_last_statement: Cents;
  blocked: Flag;
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
  amount_lcy: Cents;
  currency_code: string;
  currency_factor: number;
  document_type: string;
  document_no: string | null;
  external_document_no: string | null;
  open: Flag;
  statement_no: string | null;
  statement_line_no: number | null;
  reversed: Flag;
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
  statement_no: string | null;
  statement_date: IsoDate;
  statement_balance: Cents;
  balance_last_statement: Cents;
  status: 'OPEN' | 'POSTED';
  posted: boolean;
  posted_by: string | null;
  posted_at: IsoDateTime | null;
  journal_id: number | null;
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

/** How a manual external loan disbursement/repayment was actually paid — alongside, not
 *  instead of, which bank_account (Payment Channel) received or paid it out. See
 *  lib/loanService.ts's disburse()/repay(). */
export type PayMode = 'CASH' | 'MPESA' | 'BANK' | 'EFT' | 'CHEQUE';

export interface SavingsProduct {
  id: number;
  code: string;
  name: string;
  category: SavingsCategory;
  min_balance: Cents;
  min_opening: Cents;
  interest_rate: number;
  allow_withdrawal: Flag;
  /** AL "Cash Transfer Allowed" — whether an account on this product may be the source of an
   *  inter-account transfer. See lib/interAccountTransfer.ts. */
  allow_transfer: Flag;
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

/* ---------------------------------------------------------- entrance fee recovery */

/** One Not Paid Up member's registration-fee recovery position — lib/entranceFeeRecovery.ts's
 *  listEntranceFeeRecoveryCandidates(), also the shape a run's per-member outcome is reported
 *  in. `posting_amount` is what a run would (or did) sweep this time: the lesser of what's
 *  still outstanding and what the deposit account can actually spare right now. */
export interface EntranceFeeRecoveryCandidate {
  member_id: number;
  member_no: string;
  first_name: string;
  last_name: string;
  category_code: string;
  registration_fee: Cents;
  paid_registration: Cents;
  outstanding: Cents;
  deposit_account_id: number | null;
  deposit_account_no: string | null;
  available_balance: Cents;
  posting_amount: Cents;
}

export interface EntranceFeeRecoveryResult {
  member_id: number;
  member_no: string;
  posted: Cents;
  activated: boolean;
  skipped_reason: string | null;
}

export interface EntranceFeeRecoveryRunSummary {
  results: EntranceFeeRecoveryResult[];
  totalPosted: Cents;
  membersRecovered: number;
  membersActivated: number;
}

/* ------------------------------------------------------------ member status update */

/** What a Member Status Update run would do (or did) to one Active/Dormant member — driven by
 *  their own Non-Withdrawable Deposit account, see lib/memberStatusUpdate.ts. */
export type MemberStatusUpdateAction =
  | 'NONE' | 'MARK_DORMANT' | 'REACTIVATE' | 'REACTIVATION_BLOCKED';

export interface MemberStatusUpdateCandidate {
  member_id: number;
  member_no: string;
  first_name: string;
  last_name: string;
  status: MemberStatus;
  deposit_account_id: number | null;
  deposit_account_no: string | null;
  balance: Cents;
  /** Days since the deposit account last moved — null when it has never had any activity at
   *  all (opened but never funded), which is treated as immediately dormancy-eligible. */
  days_since_activity: number | null;
  /** The Member Reactivation charge's current amount, previewed live — null when the member
   *  isn't Dormant (nothing to reactivate) or no such charge is configured (reactivation is
   *  free). */
  reactivation_charge: Cents | null;
  action: MemberStatusUpdateAction;
}

export interface MemberStatusUpdateResult {
  member_id: number;
  member_no: string;
  action: MemberStatusUpdateAction;
  charged: Cents;
  note: string | null;
}

export interface MemberStatusUpdateRunSummary {
  results: MemberStatusUpdateResult[];
  markedDormant: number;
  reactivated: number;
  totalCharged: Cents;
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
  penalty_rate: number;
  guarantors_required: number;
  max_dsr_pct: number;
  /** When set, appraise()'s AFFORDABILITY factor is checked against actually-processed payroll
   *  (Checkoff & Salary Processing's SALARY-type batches) instead of the manual Earnings and
   *  Deductions card — the member's real net pay history, not a typed-in mimic of their payslip.
   *  A loan card only ever shows one or the other: the Earnings and Deductions section for a
   *  product that is NOT salary_based, or a read-only Processed Salary summary for one that is. */
  salary_based: Flag;
  /** Months of processed SALARY-type checkoff batches required before a salary_based product's
   *  AFFORDABILITY can be assessed at all — AL's "Min. Salary Count". Ignored when salary_based
   *  is off. */
  min_salary_count: number;
  /** How a salary_based product reduces a member's processed salary history to the single base
   *  figure max_dsr_pct is checked against — AL's "Salary Appraisal Type". Ignored when
   *  salary_based is off. */
  salary_appraisal_type: 'AVERAGE_NET' | 'LOWEST_NET';
  /** Day-of-month a disbursement/application must fall before to get the first instalment due
   *  at the end of that same calendar month — on or after it, the first instalment is pushed a
   *  further month out (see lib/loans.ts's repaymentStartDate). 0 means no cutoff — always the
   *  same-month end. */
  repayment_cutoff_date: number;
  gl_receivable_id: number | null;
  gl_interest_income_id: number | null;
  gl_penalty_income_id: number | null;
  status: 'ACTIVE' | 'INACTIVE';
}

export interface LoanProductWithUsage extends LoanProduct {
  active_loans: number;
  portfolio: Cents;
}

/* ------------------------------------------------- salary appraisal parameters */

export type SalaryAppraisalLineType = 'EARNING' | 'DEDUCTION';
export type SalaryAppraisalSpecialType = 'NONE' | 'BASIC_SALARY';

/** One predefined payslip line item (Admin Centre → Sacco Products → Salary Appraisal
 *  Parameters) a "salary based" loan product's Salary Appraisal section is seeded from. */
export interface SalaryAppraisalParameter {
  id: number;
  code: string;
  name: string;
  type: SalaryAppraisalLineType;
  special_type: SalaryAppraisalSpecialType;
  sort_order: number;
  status: 'ACTIVE' | 'INACTIVE';
}

/** One salary-appraisal line on a loan — a snapshot of a SalaryAppraisalParameter's code/name/
 *  type at seed time, plus the amount typed in to mimic the member's payslip. `editable` is
 *  false for the auto-derived rows representing the member's other disbursed loans. */
export interface LoanSalaryAppraisalLine {
  id: number;
  loan_id: number;
  parameter_id: number | null;
  code: string;
  name: string;
  type: SalaryAppraisalLineType;
  special_type: SalaryAppraisalSpecialType | 'LOAN_DEDUCTION';
  amount: Cents;
  editable: boolean;
}

/** computeSalaryTotals()'s result — the live summary strip on the loan card's Salary Appraisal
 *  section, and the itemised inputs appraise() swaps in for a salary-based product. */
export interface SalaryAppraisalTotals {
  gross: Cents;
  totalDeductions: Cents;
  basicSalary: Cents;
  oneThirdCap: Cents;
  headroom: Cents;
}

/** AL's Recovery Mode, narrowed to the three channels this port actually implements — see
 *  Loan.recovery_mode's own doc comment for what each one wires up to. */
export type LoanRecoveryMode = 'DIRECT' | 'CHECKOFF' | 'STANDING_ORDER';

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
  /** SASRA Sectorial Lending classification (see lib/economicSectors.ts). */
  sector_code: string | null;
  sub_sector_code: string | null;
  sub_subsector_code: string | null;
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
  /** AL's Recovery Mode. A CHECKOFF loan is picked up by lib/checkoffBatches.ts's batch lines;
   *  a STANDING_ORDER loan gets its own recurring standing_order row (destination_loan_id) the
   *  moment it's disbursed — see lib/loanService.ts's disburse() and
   *  lib/standingOrders.ts's createRecoveryStandingOrderForLoan() — instead of relying on
   *  counter/own-initiative repayment either way. */
  recovery_mode: LoanRecoveryMode;
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
  gl_penalty_income_id: number;
  salary_based: Flag;
  min_salary_count: number;
  salary_appraisal_type: 'AVERAGE_NET' | 'LOWEST_NET';
  member_no: string;
  first_name: string;
  last_name: string;
  sector_name: string | null;
  sub_sector_name: string | null;
  sub_subsector_name: string | null;
}

/* -------------------------------------------------------- economic sectors */

/** AL Tab52204077 "Economic Sectors". */
export interface EconomicSector {
  code: string;
  name: string;
  created_at: IsoDateTime | null;
  created_by: string | null;
}
export interface EconomicSubsector {
  id: number;
  sector_code: string;
  code: string;
  name: string;
}
export interface EconomicSubsubsector {
  id: number;
  sector_code: string;
  subsector_code: string;
  code: string;
  description: string;
}

export interface EconomicSectorTree extends EconomicSector {
  subsectors: (EconomicSubsector & { subsubsectors: EconomicSubsubsector[] })[];
  loans: number;
}

/** One line of the SASRA Sectorial Lending Return (AL Rep52204034). */
export interface SectorialLendingRow {
  sector_code: string | null;
  sector_name: string;
  sub_sector_code: string | null;
  sub_sector_name: string;
  sub_subsector_code: string | null;
  sub_subsector_name: string;
  /** Loans currently DISBURSED classified here. */
  loans: number;
  /** Principal advanced in the period (new lending). */
  disbursed: Cents;
  /** Principal recovered in the period. */
  repaid: Cents;
  /** disbursed − repaid — AL's "Net Change-Principal". */
  net_change: Cents;
  /** Current outstanding principal balance. */
  outstanding: Cents;
}

/* --------------------------------------------------------------- No. Series */

export interface NoSeries {
  code: string;
  description: string;
  default_nos: number;
  manual_nos: number;
  date_order: number;
}

export interface NoSeriesLine {
  id: number;
  series_code: string;
  line_no: number;
  starting_date: string | null;
  starting_no: string;
  ending_no: string | null;
  last_no_used: string | null;
  last_date_used: string | null;
  warning_no: string | null;
  increment_by_no: number;
  open: number;
  allow_gaps: number;
}

export interface NoSeriesWithLines extends NoSeries {
  lines: NoSeriesLine[];
}

export interface NoSeriesListRow extends NoSeries {
  line_count: number;
  /** The current (latest) line's key figures, rolled up for the list. */
  starting_no: string | null;
  ending_no: string | null;
  last_no_used: string | null;
  last_date_used: string | null;
  increment_by_no: number | null;
  starting_date: string | null;
  /** How many documents point at this series. */
  used_by: number;
  /** What GetNextNo would hand out today (null if the series can't currently issue). */
  next_no: string | null;
}

export interface DocumentNoSeriesRow {
  document_code: string;
  label: string;
  category: string;
  sort: number;
  series_code: string | null;
  series_description: string | null;
  last_no_used: string | null;
  next_no: string | null;
  manual_nos: number;
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

/** Table 52204036's "Rate Type" — distinct from a disbursed loan's InterestMethod (REDUCING/FLAT
 *  above): a what-if Loan Calculator run lets an officer compare all three amortisation styles
 *  against the same principal, independent of whichever method the loan product itself uses.
 *  STRAIGHT_LINE and AMORTISED share buildSchedule()'s FLAT/REDUCING math; REDUCING_BALANCE
 *  (constant principal, interest on the declining balance) has no level installment and is
 *  computed separately — see lib/loanCalculator.ts. */
export type LoanCalculatorRateType = 'STRAIGHT_LINE' | 'REDUCING_BALANCE' | 'AMORTISED';

/** A calculation stays Open until converted to a real loan application — a one-way move (see
 *  lib/loanCalculator.ts's convertLoanCalculatorToLoan()), after which it becomes read-only. */
export type LoanCalculatorStatus = 'Open' | 'Converted';

export interface LoanCalculator {
  id: number;
  calc_no: string;
  member_id: number;
  product_id: number;
  principal: Cents;
  interest_rate: number;
  rate_type: LoanCalculatorRateType;
  term_months: number;
  repayment_start_date: IsoDate;
  current_deposits: Cents;
  deposit_multiplier_amount: Cents;
  outstanding_loans: Cents;
  deposit_appraisal: Cents;
  installment: Cents;
  total_interest: Cents;
  status: LoanCalculatorStatus;
  converted_loan_id: number | null;
  converted_at: IsoDateTime | null;
  converted_by: string | null;
  created_at: IsoDateTime | null;
  created_by: string | null;
}

export interface LoanCalculatorListRow extends LoanCalculator {
  member_no: string;
  first_name: string;
  last_name: string;
  product_name: string;
  product_code: string;
  converted_loan_no: string | null;
}

export interface LoanCalculatorLine {
  id: number;
  calculator_id: number;
  installment_no: number;
  due_date: IsoDate;
  opening_balance: Cents;
  principal_due: Cents;
  interest_due: Cents;
  installment_amount: Cents;
  closing_balance: Cents;
}

export interface LoanCalculatorDetail {
  calculator: LoanCalculatorListRow;
  lines: LoanCalculatorLine[];
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

/** One candidate in the "Add guarantor" picker — an active member plus how much of OTHER
 *  members' loans they currently qualify to guarantee (lib/guarantors.ts's guarantorCapacity). */
export interface GuarantorCandidate {
  id: number;
  member_no: string;
  first_name: string;
  last_name: string;
  availableGuarantee: Cents;
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
  collateral: LoanCollateralRow[];
  transactions: TxnWithDocument[];
  appraisals: LoanAppraisalRow[];
}

/* ------------------------------------------------------------ collateral module */

export type CollateralCategory = 'VEHICLE' | 'REAL_ESTATE';

/** Setup: the acceptable collateral types, each with its own loan-to-value multiplier
 *  (a percentage, e.g. 70 = 70%) applied to a pledged asset's market value. */
export interface CollateralType {
  id: number;
  code: string;
  description: string;
  category: CollateralCategory;
  value_multiplier: number;
  status: 'ACTIVE' | 'INACTIVE';
}

export interface CollateralTypeWithUsage extends CollateralType {
  applications: number;
}

/** The maker-checker request to pledge one asset — same Open -> Pending Approval ->
 *  Approved -> Processed shape as AccountOpeningRequest. Processing writes the accepted
 *  asset into collateral_register under the same `no` (see lib/collateralApplications.ts). */
export interface CollateralApplication {
  no: string;
  member_id: number;
  category: CollateralCategory;
  collateral_type_id: number | null;
  collateral_description: string | null;
  multiplier: number;
  collateral_value: Cents;
  guarantee: Cents;
  serial_reg_no: string | null;
  multi_linking: Flag;
  county_id: number | null;
  last_valuation_date: IsoDate | null;
  joint_ownership: Flag;
  owner_name: string | null;
  owner_id_no: string | null;
  owner_phone_no: string | null;
  insurance_expiry_date: IsoDate | null;
  car_track_due_date: IsoDate | null;
  cheque_no: string | null;
  status: DocumentStatus;
  decision_reason: string | null;
  processed_at: IsoDateTime | null;
  processed_by: string | null;
  created_at: IsoDateTime | null;
  created_by: string | null;
}

export interface CollateralApplicationWithDetails extends CollateralApplication {
  member_no: string;
  member_first_name: string;
  member_last_name: string;
  collateral_type_code: string | null;
  county_name: string | null;
}

export interface CollateralApplicationAttachment {
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

export type CollateralStatus = 'AVAILABLE' | 'LINKED_TO_LOAN' | 'COLLECTED';

/** The register of accepted collateral — shares its primary key with CollateralApplication.
 *  `status`, `linked_loan_balance` and `collateral_balance` are computed at query time (see
 *  lib/collateralRegister.ts), never stored, so an invalid combination can't be persisted. */
export interface CollateralRegisterRow {
  no: string;
  member_id: number;
  category: CollateralCategory;
  collateral_type_id: number | null;
  collateral_description: string | null;
  collateral_value: Cents;
  guarantee: Cents;
  serial_reg_no: string | null;
  posting_date: IsoDate | null;
  county_id: number | null;
  owner_name: string | null;
  owner_id_no: string | null;
  owner_phone_no: string | null;
  insurance_expiry_date: IsoDate | null;
  car_track_due_date: IsoDate | null;
  collected_at: IsoDate | null;
  created_at: IsoDateTime | null;
  member_no: string;
  member_first_name: string;
  member_last_name: string;
  collateral_type_code: string | null;
  county_name: string | null;
  /** Sum of MIN(security guarantee, loan balance) over every live loan this item secures. */
  linked_loan_balance: Cents;
  /** guarantee - linked_loan_balance — the unused cover still available to lend against. */
  collateral_balance: Cents;
  status: CollateralStatus;
}

/** A maker-checker request to hand a pledged asset back — same Open -> Pending Approval ->
 *  Approved -> Processed shape. Processing stamps collateral_register.collected_at (see
 *  lib/collateralReleases.ts's postCollateralRelease()). */
export interface CollateralRelease {
  no: string;
  collateral_no: string;
  member_id: number;
  collection_date: IsoDate | null;
  collected_by: string | null;
  collected_by_id_no: string | null;
  nationality: 'LOCAL' | 'DIASPORA';
  domicile_country: string | null;
  comments: string | null;
  remarks: string | null;
  status: DocumentStatus;
  decision_reason: string | null;
  processed_at: IsoDateTime | null;
  processed_by: string | null;
  created_at: IsoDateTime | null;
  created_by: string | null;
}

export interface CollateralReleaseWithDetails extends CollateralRelease {
  member_no: string;
  member_first_name: string;
  member_last_name: string;
  collateral_description: string | null;
  collateral_serial_reg_no: string | null;
  /** Live figure at read time — how much loan balance this item still secures, the same
   *  computation collateral_register's status derivation uses. Must be 0 before this release
   *  can post (BR-10), re-checked at both submit and post time, not merely displayed. */
  linked_loan_balance: Cents;
}

/** The join between a loan and the collateral register item(s) securing it — "Loan Securities"
 *  narrowed to Security Type = Collateral (loan_guarantor already covers guarantor security). */
export interface LoanCollateral {
  id: number;
  loan_id: number;
  collateral_no: string;
  guarantee: Cents;
  status: 'ACTIVE' | 'SUBSTITUTED';
  created_at: IsoDateTime | null;
  created_by: string | null;
}

export interface LoanCollateralRow extends LoanCollateral {
  collateral_description: string | null;
  serial_reg_no: string | null;
  collateral_value: Cents;
}

/** One collateral register item a loan officer could still pledge against a loan — narrowed
 *  to the same member, not yet collected, with cover left over. */
export interface AvailableCollateralRow {
  no: string;
  collateral_description: string | null;
  serial_reg_no: string | null;
  guarantee: Cents;
  collateral_balance: Cents;
}

/** A maker-checker request to release and/or substitute one or more guarantors on an
 *  already-disbursed loan — the guarantor-only slice of the AL reference's "Loan Security Mgmt."
 *  card (Tab52204085), narrowed the same way collateral_release narrowed its own AL card to a
 *  single security type. See lib/loanGuarantorChanges.ts's processGuarantorChange(). */
export interface LoanGuarantorChange {
  no: string;
  loan_id: number;
  member_id: number;
  status: DocumentStatus;
  decision_reason: string | null;
  processed_at: IsoDateTime | null;
  processed_by: string | null;
  created_at: IsoDateTime | null;
  created_by: string | null;
}

export interface LoanGuarantorChangeWithDetails extends LoanGuarantorChange {
  loan_no: string;
  member_no: string;
  member_first_name: string;
  member_last_name: string;
  /** Live outstanding balance on the loan itself — for context only, not re-validated against. */
  loan_outstanding_balance: Cents;
}

/** One currently-COMMITTED guarantor snapshotted onto the document when it was populated or
 *  last refreshed. */
export interface LoanGuarantorChangeLine {
  id: number;
  change_no: string;
  guarantor_member_id: number;
  initial_guaranteed: Cents;
  outstanding_guaranteed: Cents;
  release: boolean;
}

export interface LoanGuarantorChangeLineWithDetails extends LoanGuarantorChangeLine {
  guarantor_member_no: string;
  guarantor_first_name: string;
  guarantor_last_name: string;
  replacements: LoanGuarantorChangeReplacementWithDetails[];
}

export type ReplacementType = 'GUARANTOR' | 'COLLATERAL' | 'FIXED_DEPOSIT';

export interface LoanGuarantorChangeReplacement {
  id: number;
  line_id: number;
  replacement_type: ReplacementType;
  replacement_member_id: number | null;
  replacement_collateral_no: string | null;
  replacement_fd_no: string | null;
  amount: Cents;
}

export interface LoanGuarantorChangeReplacementWithDetails extends LoanGuarantorChangeReplacement {
  replacement_member_no: string | null;
  replacement_first_name: string | null;
  replacement_last_name: string | null;
  replacement_collateral_description: string | null;
  replacement_serial_reg_no: string | null;
  replacement_fd_type_description: string | null;
}

/** A loan eligible to open a new guarantor change document against — DISBURSED, still owing a
 *  balance, with at least one COMMITTED guarantor and no other live (non-Processed) change
 *  already open for it. The picker behind "New guarantor change". */
export interface ChangeableLoanRow {
  id: number;
  loan_no: string;
  member_id: number;
  member_no: string;
  first_name: string;
  last_name: string;
  outstanding_balance: Cents;
  guarantor_count: number;
}

/** A maker-checker request to terminate a membership — settle everything the member owns
 *  against everything they owe, pay out the difference, and close their accounts. The
 *  guarantor-only-scoped sibling of Guarantor Change Management is what clears the Guarantees
 *  gate below before this can be submitted. See lib/memberExits.ts's processMemberExit(). */
export interface MemberExit {
  no: string;
  member_id: number;
  exit_type: 'GENERAL' | 'RETIREE' | 'DECEASED';
  payout_method: 'FOSA' | 'BANK_TRANSFER';
  reason: string | null;
  transaction_charge_id: number | null;
  /** AL's "Instant" field — auto-populates transaction_charge_id from
   *  organisation.instant_withdrawal_charge_id and lets processing skip the maturity wait. */
  is_instant: boolean;
  exit_date: IsoDate | null;
  maturity_date: IsoDate | null;
  net_amount: Cents;
  /** The exit charge actually posted at processing time — 0 until processed. */
  charge_amount: Cents;
  status: DocumentStatus;
  decision_reason: string | null;
  processed_at: IsoDateTime | null;
  processed_by: string | null;
  created_at: IsoDateTime | null;
  created_by: string | null;
}

export interface MemberExitWithDetails extends MemberExit {
  member_no: string;
  member_first_name: string;
  member_last_name: string;
  transaction_charge_code: string | null;
  transaction_charge_description: string | null;
  /** Live-computed from the lines (excludes share capital) — mirrors AL's Total Assets flowfield. */
  total_assets: Cents;
  /** Live-computed from the lines (already negative). */
  liabilities: Cents;
  /** Live-computed from the lines (already negative) — must net to 0 before this can be
   *  submitted for approval; see assertReadyForApproval() in lib/memberExits.ts. */
  guarantees: Cents;
}

/** One asset/liability/guarantee line snapshotted when the exit was opened or last refreshed. */
export interface MemberExitLine {
  id: number;
  exit_no: string;
  entry_type: 'ASSET' | 'LIABILITY' | 'GUARANTEE';
  savings_account_id: number | null;
  loan_id: number | null;
  account_name: string | null;
  balance: Cents;
  amount: Cents;
  is_share_capital: boolean;
}

export interface MemberExitLineWithDetails extends MemberExitLine {
  /** The savings account's own number (ASSET lines) or the loan's own number (LIABILITY/
   *  GUARANTEE lines) — whichever of savings_account_id/loan_id is set. */
  account_no: string | null;
}

/** A member eligible to open a new exit against — ACTIVE, with no other exit document already
 *  open/in-progress. The picker behind "New member exit". */
export interface EligibleExitMemberRow {
  id: number;
  member_no: string;
  first_name: string;
  last_name: string;
}

/** Checkoff and Salary Processing's employer master — AL's "Employers" (Tab52204126) narrowed to
 *  what routes a batch: name/contact, whether a payroll number is mandatory, and status. See
 *  lib/employers.ts and lib/checkoffBatches.ts. */
export interface Employer {
  id: number;
  code: string;
  name: string;
  phone: string | null;
  email: string | null;
  payroll_no_mandatory: boolean;
  status: 'ACTIVE' | 'INACTIVE';
}

export interface EmployerWithCounts extends Employer {
  member_count: number;
}

/** Aggregate financial/member-position stats for one employer's linked members — the Employer
 *  View card. See lib/employers.ts's getEmployerStats(). */
export interface EmployerStats {
  member_count: number;
  active_member_count: number;
  withdrawn_member_count: number;
  member_status_breakdown: { status: string; count: number }[];
  total_deposits: Cents;
  total_shares: Cents;
  total_fixed_deposits: Cents;
  disbursed_loan_count: number;
  outstanding_loan_balance: Cents;
  checkoff_batch_count: number;
  total_remitted: Cents;
}

/** A maker-checker batch document scoped to one employer/period. See
 *  lib/checkoffBatches.ts's processCheckoffBatch(). */
/** Which column of an uploaded CSV identifies each row's member, and how it's resolved — ported
 *  from the AL reference's "CheckOff Search Type" enum (Enum52204034), dropping its "Old FOSA
 *  Number" value. See lib/checkoffBatches.ts's applyCheckoffCsvUpload(). */
export type CheckoffSearchType = 'MEMBER_NO' | 'ID_NUMBER' | 'PAYROLL_NO' | 'FOSA_NUMBER';

export interface CheckoffBatch {
  no: string;
  batch_type: 'CHECKOFF' | 'SALARY';
  employer_id: number;
  period: IsoDate;
  posting_date: IsoDate | null;
  description: string | null;
  search_type: CheckoffSearchType;
  status: DocumentStatus;
  decision_reason: string | null;
  /** SALARY only — the 'End Month Salary' Transaction Charge Calculate applies. */
  transaction_charge_id: number | null;
  processed_at: IsoDateTime | null;
  processed_by: string | null;
  created_at: IsoDateTime | null;
  created_by: string | null;
}

export interface CheckoffBatchWithDetails extends CheckoffBatch {
  employer_code: string;
  employer_name: string;
  transaction_charge_code: string | null;
  /** Live-computed from the lines. */
  total_expected: Cents;
  total_remitted: Cents;
  total_variance: Cents;
  total_uploaded: Cents;
  unmatched_count: number;
  line_count: number;
  calculated: boolean;
}

/** One member's line within a checkoff/salary batch. */
export interface CheckoffBatchLine {
  id: number;
  batch_no: string;
  member_id: number;
  payroll_no: string | null;
  expected_amount: Cents;
  remitted_amount: Cents;
  variance: Cents;
  uploaded_amount: Cents;
  uploaded_name: string | null;
  matched: boolean;
}

export interface CheckoffBatchLineWithDetails extends CheckoffBatchLine {
  member_no: string;
  member_first_name: string;
  member_last_name: string;
}

export type CheckoffCalculationEntryType =
  'CHARGE' | 'LOAN_RECOVERY' | 'STANDING_ORDER' | 'INTERNAL_DEPOSIT' | 'NET_AMOUNT';

/** One line of a Calculate run's breakdown for one checkoff_batch_line. See
 *  lib/checkoffBatches.ts's calculateCheckoffRecoveries()/processCheckoffBatch(). */
export interface CheckoffCalculation {
  id: number;
  batch_no: string;
  line_id: number;
  entry_type: CheckoffCalculationEntryType;
  description: string;
  loan_id: number | null;
  savings_account_id: number | null;
  gl_account_id: number | null;
  /** STANDING_ORDER only. */
  standing_order_no: string | null;
  amount: Cents;
}

/** Admin-managed master data for a term-deposit product — interest rate bounds, calc method, the
 *  savings_product new FD accounts open under, and the GL accounts accrual/withholding tax post
 *  to. See lib/fixedDepositTypes.ts. */
export interface MemberFixedDepositType {
  id: number;
  code: string;
  description: string;
  min_interest_rate: number;
  max_interest_rate: number;
  interest_calc_type: 'FLAT' | 'REDUCING';
  linked_product_id: number;
  interest_expense_gl_id: number;
  interest_payable_gl_id: number;
  withholding_tax_rate: number;
  withholding_tax_gl_id: number | null;
  status: 'ACTIVE' | 'INACTIVE';
}

export interface MemberFixedDepositTypeWithUsage extends MemberFixedDepositType {
  linked_product_name: string;
  fixed_deposits: number;
}

/** The maker-checker document for a member's term deposit. `status` carries its own richer
 *  post-approval lifecycle (ACTIVE -> MATURED/TERMINATED) rather than the shared DocumentStatus —
 *  same reason Loan has its own status enum too. See lib/fixedDeposits.ts. */
export interface MemberFixedDeposit {
  no: string;
  member_id: number;
  fd_type_id: number;
  rate: number;
  maturity_instructions: 'ROLLOVER_PRINCIPAL' | 'ROLLOVER_NET' | 'LIQUIDATE';
  amount: Cents;
  source_account_id: number;
  fd_account_id: number | null;
  start_date: IsoDate;
  term_months: number;
  end_date: IsoDate;
  status: 'Open' | 'Pending Approval' | 'Approved' | 'Active' | 'Matured' | 'Terminated';
  decision_reason: string | null;
  rolled_from_no: string | null;
  rolled_to_no: string | null;
  created_at: IsoDateTime | null;
  created_by: string | null;
  activated_at: IsoDateTime | null;
  activated_by: string | null;
  processed_at: IsoDateTime | null;
  processed_by: string | null;
}

export interface MemberFixedDepositWithDetails extends MemberFixedDeposit {
  member_no: string;
  member_first_name: string;
  member_last_name: string;
  fd_type_code: string;
  fd_type_description: string;
  source_account_no: string;
  fd_account_no: string | null;
  /** Live balance of the FD's own dedicated account — 0 until activated. */
  running_balance: Cents;
  /** Live-computed from the schedule. */
  total_interest_payable: Cents;
  total_interest_accrued: Cents;
  total_interest_balance: Cents;
  /** Live-computed from active loan_fd_lien rows against disbursed loans with a balance —
   *  must be 0 before Mature/Terminate, mirrors AL's OnBeforeLiquidate check. */
  linked_loan_balance: Cents;
}

/** One monthly interest accrual line. See lib/fixedDeposits.ts's accrueFixedDepositInterest(). */
export interface MemberFixedDepositSchedule {
  id: number;
  fd_no: string;
  posting_date: IsoDate;
  description: string | null;
  amount: Cents;
  transferred: boolean;
}

/** A Fixed Deposit pledged as security for a loan — the FD-as-collateral sibling of
 *  LoanCollateral. See lib/loanFdSecurity.ts. */
export interface LoanFdLien {
  id: number;
  loan_id: number;
  fd_no: string;
  guarantee: Cents;
  status: 'ACTIVE' | 'RELEASED';
  created_at: IsoDateTime | null;
  created_by: string | null;
}

export interface LoanFdLienRow extends LoanFdLien {
  member_no: string;
  member_first_name: string;
  member_last_name: string;
  fd_amount: Cents;
}

/** One Fixed Deposit a loan officer could still pledge against a loan — narrowed to the same
 *  member, approved-or-active, with cover left over. */
export interface AvailableFdRow {
  no: string;
  fd_type_description: string;
  amount: Cents;
  available: Cents;
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

/** One factor row of a persisted loan_appraisal — the DB-shaped twin of AppraisalFactor. */
export interface LoanAppraisalFactorRow {
  code: string;
  label: string;
  pass: boolean;
  detail: string | null;
}

/** A saved, dated appraisal run against a loan — Appraisal's persisted counterpart. Unlike the
 *  ephemeral Appraisal returned while a loan is still being drafted (no loan_id exists yet),
 *  this is written once the loan is on file and never edited — only ever superseded by a later
 *  run, so the loan's decision history stays intact (section 5's "dated immutable result"). */
export interface LoanAppraisalRow {
  id: number;
  loan_id: number;
  decision: 'ELIGIBLE' | 'REFERRED';
  score: number;
  installment: Cents;
  deposits: Cents;
  exposure: Cents;
  max_by_multiplier: Cents;
  dsr: number;
  monthly_obligations: Cents;
  appraised_by: string | null;
  appraised_at: IsoDateTime | null;
  factors: LoanAppraisalFactorRow[];
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
  /** The specific Bank/Cashbook account a loan disbursement/repayment moved through — only set
   *  for a manual external payout/receipt; null when funded from/to a member's own savings
   *  account (no bank account touched). */
  bank_account_id: number | null;
  pay_mode: PayMode | null;
  /** Pay Mode = CHEQUE only. */
  cheque_no: string | null;
  /** Pay Mode = CHEQUE only. */
  cheque_date: IsoDate | null;
  /** Pay Mode = MPESA | BANK | EFT only. */
  reference_no: string | null;
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
  global_dimension_1_code: string | null;
  global_dimension_2_code: string | null;
  bank_account_code: string | null;
  bank_account_name: string | null;
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
  | 'ACCOUNT_ACTIVATION' | 'MEMBER_ACTIVATION' | 'MEMBER_READMISSION' | 'COLLATERAL_APPLICATION' | 'COLLATERAL_RELEASE'
  | 'GUARANTOR_CHANGE' | 'MEMBER_EXIT' | 'CHECKOFF_BATCH' | 'FIXED_DEPOSIT' | 'STANDING_ORDER'
  | 'FOSA_TRANSACTION' | 'TELLER_TRANSACTION' | 'MEMBER_LIEN' | 'INTER_ACCOUNT_TRANSFER' | 'BANKERS_CHEQUE'
  | 'CHEQUE_DEPOSIT' | 'ITEM_JOURNAL' | 'FA_JOURNAL' | 'DIVIDEND' | 'SHARE_FLOATING'
  | 'IMPREST_REQUEST' | 'IMPREST_SURRENDER' | 'PETTY_CASH' | 'STAFF_CLAIM'
  | 'STORE_REQUISITION' | 'PURCHASE_REQUISITION'
  | 'SALES_DOCUMENT' | 'REMINDER'
  | 'PURCHASE_DOCUMENT'
  | 'RECEIPT' | 'PAYMENT_VOUCHER'
  | 'EMPLOYEE_ONBOARDING' | 'EMPLOYEE_EDIT' | 'EMPLOYEE_CONTRACT_CHANGE' | 'EMPLOYEE_EXIT'
  | 'LEAVE_APPLICATION' | 'LEAVE_ADJUSTMENT' | 'LEAVE_RECALL' | 'LEAVE_PLAN' | 'PAYROLL_PERIOD'
  | 'COMPANY_JOB';
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
  /** This user's own Allow Posting From/To override — null falls back to the organisation's. */
  allow_posting_from: IsoDate | null;
  allow_posting_to: IsoDate | null;
  /** Time-of-day refinement on the two boundary dates only — see the schema's own doc comment. */
  allow_posting_from_time: string | null;
  allow_posting_to_time: string | null;
  /** AL User Setup "Employee No." — the employee this login is; Self Service hangs off it. */
  employee_id: number | null;
}

/** One row of the Approval User Setup grid — the user plus their configured setup, if any. */
export interface ApprovalUserSetupRow {
  user_id: number;
  username: string;
  full_name: string;
  /** The user's scanned signature — a Cloudinary public_id, or null when none is on file. */
  signature_image: string | null;
  approver_id: number | null;
  approver_name: string | null;
  substitute_id: number | null;
  substitute_name: string | null;
  employee_id: number | null;
  employee_no: string | null;
  employee_name: string | null;
  is_approval_administrator: Flag;
  can_reverse_journal: Flag;
  allow_posting_from: IsoDate | null;
  allow_posting_to: IsoDate | null;
  allow_posting_from_time: string | null;
  allow_posting_to_time: string | null;
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

/* --------------------------------------------------------------- job queue */

/** Which background task a Job Queue Entry runs — see lib/jobQueue.ts's JOB_HANDLERS. Currently
 *  only Entrance Fee Recovery is implemented; the type is a plain string union (not yet backed
 *  by a DB enum) so a future job type is one JOB_HANDLERS entry away, no migration required. */
export type JobQueueType = 'ENTRANCE_FEE_RECOVERY' | 'MEMBER_STATUS_UPDATE' | 'STANDING_ORDER_RUN';

export type JobQueueStatus = 'READY' | 'ON HOLD';
export type JobQueueRunStatus = 'SUCCESS' | 'ERROR';

export interface JobQueueEntry {
  id: number;
  code: string;
  description: string;
  job_type: JobQueueType;
  run_every_minutes: number;
  earliest_start_date: IsoDate | null;
  status: JobQueueStatus;
  next_run_at: IsoDateTime | null;
  last_run_at: IsoDateTime | null;
  last_run_status: JobQueueRunStatus | null;
  last_run_message: string | null;
  created_at: IsoDateTime | null;
  created_by: string | null;
  updated_at: IsoDateTime | null;
  updated_by: string | null;
}

/* ------------------------------------------------------------------ inventory */

/** Business Central Table 14, trimmed. Every stock movement happens at one of these. */
export interface Location {
  id: number;
  code: string;
  name: string;
  address: string | null;
  status: 'ACTIVE' | 'INACTIVE';
  created_at: IsoDateTime | null;
  created_by: string | null;
}

/** Business Central Table 204. */
export interface UnitOfMeasure {
  id: number;
  code: string;
  description: string;
  symbol: string | null;
  created_at: IsoDateTime | null;
  created_by: string | null;
}

/** Business Central's Inventory Posting Group — the ledger side of an Item's ledger-subledger
 *  mapping: which G/L account carries this item family's stock value. */
export interface InventoryPostingGroup {
  id: number;
  code: string;
  description: string;
  inventory_gl_account_id: number;
  created_at: IsoDateTime | null;
  created_by: string | null;
}

export interface InventoryPostingGroupView extends InventoryPostingGroup {
  inventory_gl_account_code: string;
  inventory_gl_account_name: string;
  /** Items currently referencing this group — guards deletion. */
  items_using: number;
}

/** Business Central's Gen. Prod. Posting Group — the subledger side of an Item's ledger-subledger
 *  mapping: which P&L account a Positive/Negative Adjmt. offsets against. */
export interface ProductPostingGroup {
  id: number;
  code: string;
  description: string;
  adjustment_gl_account_id: number;
  created_at: IsoDateTime | null;
  created_by: string | null;
}

export interface ProductPostingGroupView extends ProductPostingGroup {
  adjustment_gl_account_code: string;
  adjustment_gl_account_name: string;
  items_using: number;
}

/** Business Central's own five Costing Methods. */
export type ItemCostingMethod = 'FIFO' | 'LIFO' | 'Average' | 'Standard' | 'Specific';

/** The two simplest Business Central Reordering Policies — see calculateReplenishment() in
 *  lib/itemJournal.ts. */
export type ItemReorderingPolicy = 'Fixed Reorder Qty.' | 'Maximum Qty.';

/** Business Central Table 27 "Item", trimmed — see prisma/schema.prisma's model comment for
 *  exactly what was left out and why. */
export interface Item {
  id: number;
  no: string;
  description: string;
  description_2: string | null;
  base_unit_of_measure_id: number;
  purch_unit_of_measure_id: number | null;
  sales_unit_of_measure_id: number | null;
  inventory_posting_group_id: number;
  product_posting_group_id: number;
  costing_method: ItemCostingMethod;
  unit_cost: Cents;
  unit_price: Cents;
  /** Maintained roll-up of this item's stockkeeping_unit rows, across every location. */
  inventory: number;
  reordering_policy: ItemReorderingPolicy;
  reorder_point: number;
  reorder_quantity: number;
  maximum_inventory: number;
  status: 'ACTIVE' | 'BLOCKED';
  created_at: IsoDateTime | null;
  created_by: string | null;
}

export interface ItemListRow extends Item {
  base_unit_of_measure_code: string;
  purch_unit_of_measure_code: string | null;
  sales_unit_of_measure_code: string | null;
  inventory_posting_group_code: string;
  product_posting_group_code: string;
  below_reorder_point: boolean;
}

/** Business Central Table 5404. `qty_per_unit_of_measure` always converts to the item's own
 *  Base UoM — never UoM-to-UoM. See lib/unitOfMeasureConversion.ts. */
export interface ItemUnitOfMeasure {
  id: number;
  item_id: number;
  unit_of_measure_id: number;
  qty_per_unit_of_measure: number;
}

export interface ItemUnitOfMeasureView extends ItemUnitOfMeasure {
  unit_of_measure_code: string;
  unit_of_measure_description: string;
}

/** Business Central Table 5700 "Stockkeeping Unit" — one item's qty-on-hand at one location,
 *  with an optional per-location override of the item's own reordering defaults. */
export interface StockkeepingUnit {
  id: number;
  item_id: number;
  location_id: number;
  reordering_policy: ItemReorderingPolicy | null;
  reorder_point: number | null;
  reorder_quantity: number | null;
  maximum_inventory: number | null;
  inventory: number;
}

export interface StockByLocationRow extends StockkeepingUnit {
  location_code: string;
  location_name: string;
  /** This row's own override where set, else the item's own default. */
  effective_reordering_policy: ItemReorderingPolicy;
  effective_reorder_point: number;
  effective_reorder_quantity: number;
  effective_maximum_inventory: number;
}

/** One row of the "Item Quantities per Location" report — every item+location combination that
 *  has ever had a movement, with its current qty-on-hand and cost value. */
export interface ItemQuantityByLocationRow {
  item_id: number;
  item_no: string;
  item_description: string;
  base_unit_of_measure_code: string;
  location_id: number;
  location_code: string;
  location_name: string;
  inventory: number;
  unit_cost: Cents;
  /** inventory * unit_cost, at the item's current (not historical per-lot) unit cost. */
  value: Cents;
  below_reorder_point: boolean;
}

/** Business Central's own two entry types this module posts — see prisma/schema.prisma. */
export type ItemJournalEntryType = 'Positive Adjmt.' | 'Negative Adjmt.';

/** Business Central Table 83 "Item Journal Line", scoped to Positive/Negative Adjmt. only.
 *  Lifecycle Open -> Pending Approval -> Approved -> Processed, same shape as BankersCheque. */
export interface ItemJournalLine {
  id: number;
  no: string;
  posting_date: IsoDate;
  entry_type: ItemJournalEntryType;
  item_id: number;
  location_id: number;
  description: string | null;
  unit_of_measure_id: number;
  qty_per_unit_of_measure: number;
  quantity: number;
  base_quantity: number;
  applies_to_entry_id: number | null;
  unit_cost: Cents;
  amount: Cents;
  status: DocumentStatus;
  decision_reason: string | null;
  posted: boolean;
  journal_id: number | null;
  /** The store requisition line this Negative Adjmt. issued, if any. */
  requisition_line_id: number | null;
  global_dimension_1_id: number | null;
  global_dimension_2_id: number | null;
  created_at: IsoDateTime | null;
  created_by: string | null;
  posted_at: IsoDateTime | null;
  posted_by: string | null;
}

export interface ItemJournalLineView extends ItemJournalLine {
  item_no: string;
  item_description: string;
  item_costing_method: ItemCostingMethod;
  location_code: string;
  unit_of_measure_code: string;
  journal_no: string | null;
  /** Open quantity (in the item's Base UoM) at this item+location — what a Negative Adjmt. may
   *  not exceed. */
  available_quantity: number;
}

/** Business Central Table 32 "Item Ledger Entry" — the posted, immutable stock movement. An
 *  inbound (Positive Adjmt.) entry is a costed lot; `remaining_quantity`/`open` track how much of
 *  it is still unconsumed by an outbound application. */
export interface ItemLedgerEntry {
  id: number;
  item_id: number;
  location_id: number;
  posting_date: IsoDate;
  entry_type: ItemJournalEntryType;
  document_no: string;
  quantity: number;
  remaining_quantity: number;
  open: boolean;
  unit_cost: Cents;
  amount: Cents;
  item_journal_line_id: number;
  created_at: IsoDateTime | null;
}

export interface ItemLedgerEntryView extends ItemLedgerEntry {
  item_no: string;
  item_description: string;
  location_code: string;
}

/** Business Central Table 339 "Item Application Entry" — which inbound lot an outbound entry
 *  consumed, and how much of it. Written for FIFO/LIFO/Average/Specific; Standard writes none. */
export interface ItemApplicationEntry {
  id: number;
  outbound_entry_id: number;
  inbound_entry_id: number;
  quantity: number;
  posting_date: IsoDate;
  created_at: IsoDateTime | null;
}

export interface ItemApplicationEntryView extends ItemApplicationEntry {
  inbound_document_no: string;
  inbound_unit_cost: Cents;
}

/** One row of calculateReplenishment()'s computed report — an item+location at or below its
 *  Reorder Point, with the quantity its Reordering Policy suggests raising. Nothing persists
 *  until "Create adjustment" turns it into a real Item Journal Line. */
export interface ReplenishmentSuggestion {
  item_id: number;
  item_no: string;
  item_description: string;
  location_id: number;
  location_code: string;
  reordering_policy: ItemReorderingPolicy;
  inventory: number;
  reorder_point: number;
  reorder_quantity: number;
  maximum_inventory: number;
  suggested_quantity: number;
}
/* ============================================================================================
 * Fixed Assets — Business Central FA subledger (Tables 5600/5601/5603/5606/5611/5612/5616/5628/
 * 5629/5643). See lib/fixedAssets.ts, lib/faJournal.ts, lib/fixedAssetDepreciation.ts.
 * ========================================================================================== */

export type FaDepreciationMethod = 'Straight-Line' | 'Declining-Balance 1' | 'DB1/SL' | 'Manual';
export type FaPostingType =
  | 'Acquisition Cost' | 'Depreciation' | 'Write-Down' | 'Appreciation' | 'Disposal' | 'Maintenance';
export type FaJournalStatus = 'Open' | 'Pending Approval' | 'Approved' | 'Processed';
export type FaJournalSource = 'MANUAL' | 'CALCULATE_DEPRECIATION';
export type FaDisposalCalcMethod = 'Net' | 'Gross';

export interface FaClass {
  id: number;
  code: string;
  description: string;
  status: 'ACTIVE' | 'INACTIVE';
  created_at: IsoDateTime | null;
  created_by: string | null;
}

export interface FaSubclass {
  id: number;
  code: string;
  description: string;
  fa_class_code: string | null;
  status: 'ACTIVE' | 'INACTIVE';
  created_at: IsoDateTime | null;
  created_by: string | null;
}

export interface FaLocation {
  id: number;
  code: string;
  description: string;
  status: 'ACTIVE' | 'INACTIVE';
  created_at: IsoDateTime | null;
  created_by: string | null;
}

export interface Maintenance {
  id: number;
  code: string;
  description: string;
  status: 'ACTIVE' | 'INACTIVE';
  created_at: IsoDateTime | null;
  created_by: string | null;
}

/** Business Central Table 5611 "Depreciation Book". This port always integrates to the G/L. */
export interface DepreciationBook {
  id: number;
  code: string;
  description: string;
  g_l_integration: Flag;
  default_final_rounding_amount: Cents;
  use_rounding_in_periodic_depr: Flag;
  created_at: IsoDateTime | null;
  created_by: string | null;
}

/** Business Central Table 5606 "FA Posting Group" — the eight G/L accounts every FA posting
 *  resolves its debit and credit from. */
export interface FaPostingGroup {
  id: number;
  code: string;
  description: string;
  acquisition_cost_account_id: number;
  accum_depreciation_account_id: number;
  depreciation_expense_account_id: number;
  write_down_expense_account_id: number;
  appreciation_account_id: number;
  maintenance_expense_account_id: number;
  gains_acc_on_disposal_id: number;
  losses_acc_on_disposal_id: number;
  created_at: IsoDateTime | null;
  created_by: string | null;
}

export interface FaPostingGroupView extends FaPostingGroup {
  acquisition_cost_account_code: string;
  accum_depreciation_account_code: string;
  depreciation_expense_account_code: string;
  write_down_expense_account_code: string;
  appreciation_account_code: string;
  maintenance_expense_account_code: string;
  gains_acc_on_disposal_code: string;
  losses_acc_on_disposal_code: string;
  assets_using: number;
}

/** Business Central Table 5603 "FA Setup" — singleton. */
export interface FaSetup {
  id: number;
  default_depreciation_book_code: string | null;
  default_fa_posting_group_code: string | null;
  allow_fa_posting_from: IsoDate | null;
  allow_fa_posting_to: IsoDate | null;
  updated_at: IsoDateTime | null;
  updated_by: string | null;
}

/** Business Central Table 5600 "Fixed Asset". */
export interface FixedAsset {
  id: number;
  no: string;
  description: string;
  description_2: string | null;
  fa_class_code: string | null;
  fa_subclass_code: string | null;
  fa_location_code: string | null;
  responsible_employee: string | null;
  serial_no: string | null;
  vendor_name: string | null;
  asset_tag: string | null;
  global_dimension_1_id: number | null;
  global_dimension_2_id: number | null;
  blocked: Flag;
  inactive: Flag;
  acquisition_date: IsoDate | null;
  disposal_date: IsoDate | null;
  created_at: IsoDateTime | null;
  created_by: string | null;
}

export interface FixedAssetListRow extends FixedAsset {
  fa_class_description: string | null;
  fa_subclass_description: string | null;
  fa_location_description: string | null;
  /** Roll-ups for the default depreciation book, when the asset has a book row. */
  depreciation_book_code: string | null;
  depreciation_method: FaDepreciationMethod | null;
  acquisition_cost: Cents;
  accumulated_depreciation: Cents;
  book_value: Cents;
  disposed: boolean;
}

/** Business Central Table 5612 "FA Depreciation Book" — one row per asset + book. */
export interface FaDepreciationBook {
  id: number;
  fixed_asset_id: number;
  depreciation_book_code: string;
  fa_posting_group_code: string;
  depreciation_method: FaDepreciationMethod;
  depreciation_starting_date: IsoDate | null;
  depreciation_ending_date: IsoDate | null;
  no_of_depreciation_years: number | null;
  straight_line_pct: number;
  declining_balance_pct: number;
  fixed_depr_amount: Cents;
  salvage_value: Cents;
  last_depreciation_date: IsoDate | null;
  disposal_calculation_method: FaDisposalCalcMethod;
  acquisition_cost: Cents;
  accumulated_depreciation: Cents;
  write_down_amount: Cents;
  appreciation_amount: Cents;
  book_value: Cents;
  proceeds_on_disposal: Cents;
  gain_loss_on_disposal: Cents;
  maintenance_total: Cents;
  disposed: Flag;
}

export interface FaDepreciationBookView extends FaDepreciationBook {
  fixed_asset_no: string;
  fixed_asset_description: string;
  fa_posting_group_description: string;
}

/** The FA Journal — a maker-checker document, same lifecycle shape as ItemJournalLine. */
export interface FaJournalLine {
  id: number;
  no: string;
  posting_date: IsoDate;
  document_no: string | null;
  fixed_asset_id: number;
  depreciation_book_code: string;
  fa_posting_type: FaPostingType;
  amount: Cents;
  balancing_gl_account_id: number | null;
  maintenance_code: string | null;
  depr_until_fa_posting_date: Flag;
  no_of_depreciation_days: number | null;
  description: string | null;
  source: FaJournalSource;
  status: FaJournalStatus;
  decision_reason: string | null;
  posted: boolean;
  journal_id: number | null;
  created_at: IsoDateTime | null;
  created_by: string | null;
  posted_at: IsoDateTime | null;
  posted_by: string | null;
}

export interface FaJournalLineView extends FaJournalLine {
  fixed_asset_no: string;
  fixed_asset_description: string;
  balancing_gl_account_code: string | null;
  balancing_gl_account_name: string | null;
  journal_no: string | null;
  book_value: Cents;
  disposed: boolean;
}

/** Business Central Table 5601 "FA Ledger Entry" — the posted, immutable FA movement. */
export interface FaLedgerEntry {
  id: number;
  fixed_asset_id: number;
  depreciation_book_code: string;
  fa_posting_date: IsoDate;
  fa_posting_type: FaPostingType;
  document_no: string;
  description: string | null;
  amount: Cents;
  no_of_depreciation_days: number | null;
  journal_id: number | null;
  fa_journal_line_id: number | null;
  part_of_book_value: Flag;
  maintenance_code: string | null;
  reversed: Flag;
  created_at: IsoDateTime | null;
}

export interface FaLedgerEntryView extends FaLedgerEntry {
  fixed_asset_no: string;
  fixed_asset_description: string;
}

/** One line of calculateDepreciation()'s batch summary. */
export interface FaDepreciationSuggestion {
  fixed_asset_id: number;
  fixed_asset_no: string;
  fixed_asset_description: string;
  amount: Cents;
  days: number;
  new_book_value: Cents;
  no: string;
}

/** One row of the FA Book Value report — computed live from fa_ledger_entry. */
export interface FaBookValueRow {
  fixed_asset_id: number;
  fixed_asset_no: string;
  fixed_asset_description: string;
  fa_class_code: string | null;
  acquisition_cost: Cents;
  depreciation: Cents;
  write_down: Cents;
  appreciation: Cents;
  book_value: Cents;
  disposed: boolean;
}

export interface FaBookValueReport {
  book_code: string;
  as_of: IsoDate;
  rows: FaBookValueRow[];
  totals: {
    acquisition_cost: Cents;
    depreciation: Cents;
    write_down: Cents;
    appreciation: Cents;
    book_value: Cents;
  };
}
/* ============================================================================================
 * Receivables — Business Central Sales & Receivables (Tables 3/5/18/21/36/37/92/110-115/289/
 * 293-296/302-305/311/379). See lib/customers.ts, lib/salesDocuments.ts, lib/custLedger.ts,
 * lib/cashReceipts.ts, lib/reminders.ts, lib/receivablesReports.ts.
 * ========================================================================================== */

export type CustomerBlocked = '' | 'Ship' | 'Invoice' | 'All';
export type PaymentMethodBalAccountType = 'None' | 'G/L Account' | 'Bank Account';
export type SalesDocumentType = 'Quote' | 'Order' | 'Invoice' | 'Credit Memo';
export type SalesLineType = 'Comment' | 'G/L Account' | 'Item' | 'Fixed Asset';
export type SalesDocumentStatus = 'Open' | 'Pending Approval' | 'Released';
export type PostedSalesDocumentType = 'Shipment' | 'Invoice' | 'Credit Memo';
export type CustLedgerDocumentType =
  | 'Invoice' | 'Payment' | 'Credit Memo' | 'Reminder' | 'Finance Charge Memo' | 'Refund';
export type DetailedCustLedgerEntryType =
  | 'Initial Entry' | 'Application' | 'Payment Discount' | 'Correction' | 'Unapplied'
  | 'Realized Gain' | 'Realized Loss' | 'Unrealized Gain' | 'Unrealized Loss';
export type ReminderDocumentType = 'Reminder' | 'Finance Charge Memo';
export type ReminderStatus = 'Open' | 'Issued';
export type ReminderLineType = '' | 'Reminder Line' | 'G/L Account' | 'Line Fee';
export type CreditWarnings = 'Both' | 'Credit Limit' | 'Overdue Balance' | 'No Warning';
export type FinChargeInterestMethod = 'Average Daily Balance' | 'Balance Due';

export interface CustomerPostingGroup {
  id: number;
  code: string;
  description: string;
  receivables_account_id: number;
  service_charge_account_id: number;
  additional_fee_account_id: number;
  payment_disc_debit_account_id: number;
  payment_disc_credit_account_id: number;
  invoice_rounding_account_id: number;
  created_at: IsoDateTime | null;
  created_by: string | null;
}

export interface CustomerPostingGroupView extends CustomerPostingGroup {
  receivables_account_code: string;
  service_charge_account_code: string;
  additional_fee_account_code: string;
  payment_disc_debit_account_code: string;
  payment_disc_credit_account_code: string;
  invoice_rounding_account_code: string;
  customers_using: number;
}

export interface PaymentTerms {
  id: number;
  code: string;
  description: string;
  due_date_calculation: string;
  discount_date_calculation: string;
  discount_pct: number;
  calc_pmt_disc_on_credit_memos: Flag;
  status: 'ACTIVE' | 'INACTIVE';
  created_at: IsoDateTime | null;
  created_by: string | null;
}

export interface PaymentMethod {
  id: number;
  code: string;
  description: string;
  bal_account_type: PaymentMethodBalAccountType;
  bal_account_no: string | null;
  status: 'ACTIVE' | 'INACTIVE';
  created_at: IsoDateTime | null;
  created_by: string | null;
}

export interface ReminderTerms {
  id: number;
  code: string;
  description: string;
  max_no_of_reminders: number;
  post_interest: Flag;
  post_additional_fee: Flag;
  min_amount: Cents;
  dont_remind_on_hold: Flag;
  status: 'ACTIVE' | 'INACTIVE';
  created_at: IsoDateTime | null;
  created_by: string | null;
}

export interface ReminderLevel {
  id: number;
  reminder_terms_code: string;
  level_no: number;
  grace_period: string;
  due_date_calculation: string;
  calculate_interest: Flag;
  additional_fee: Cents;
  add_fee_per_line: Cents;
  begin_text: string | null;
  end_text: string | null;
}

export interface FinanceChargeTerms {
  id: number;
  code: string;
  description: string;
  interest_rate: number;
  min_amount: Cents;
  additional_fee: Cents;
  grace_period: string;
  due_date_calculation: string;
  interest_period_days: number;
  interest_calculation_method: FinChargeInterestMethod;
  post_interest: Flag;
  post_additional_fee: Flag;
  line_description: string;
  begin_text: string | null;
  end_text: string | null;
  status: 'ACTIVE' | 'INACTIVE';
  created_at: IsoDateTime | null;
  created_by: string | null;
}

export interface SalesReceivablesSetup {
  id: number;
  default_customer_posting_group_code: string | null;
  default_payment_terms_code: string | null;
  default_reminder_terms_code: string | null;
  default_fin_charge_terms_code: string | null;
  stockout_warning: Flag;
  credit_warnings: CreditWarnings;
  invoice_rounding: Flag;
  invoice_rounding_precision: Cents;
  allow_receivables_posting_from: IsoDate | null;
  allow_receivables_posting_to: IsoDate | null;
  updated_at: IsoDateTime | null;
  updated_by: string | null;
}

/** Business Central Table 18 "Customer". */
export interface Customer {
  id: number;
  no: string;
  name: string;
  name_2: string | null;
  address: string | null;
  address_2: string | null;
  city: string | null;
  post_code: string | null;
  country: string | null;
  contact: string | null;
  phone: string | null;
  email: string | null;
  customer_posting_group_code: string | null;
  payment_terms_code: string | null;
  payment_method_code: string | null;
  reminder_terms_code: string | null;
  fin_charge_terms_code: string | null;
  salesperson: string | null;
  currency_code: string | null;
  credit_limit: Cents;
  blocked: CustomerBlocked;
  global_dimension_1_id: number | null;
  global_dimension_2_id: number | null;
  balance: Cents;
  last_statement_no: number;
  created_at: IsoDateTime | null;
  created_by: string | null;
}

export interface CustomerListRow extends Customer {
  customer_posting_group_description: string | null;
  payment_terms_description: string | null;
  balance_due: Cents;
  credit_limit_exceeded: boolean;
}

export interface CustomerStatistics {
  balance: Cents;
  balance_due: Cents;
  outstanding_orders: Cents;
  overdue_entries: number;
  ledger_entry_count: number;
  credit_limit: Cents;
}

/** Business Central Table 36 "Sales Header". */
export interface SalesHeader {
  id: number;
  document_type: SalesDocumentType;
  no: string;
  customer_id: number;
  sell_to_name: string | null;
  sell_to_address: string | null;
  sell_to_city: string | null;
  sell_to_contact: string | null;
  posting_date: IsoDate;
  document_date: IsoDate;
  due_date: IsoDate | null;
  payment_terms_code: string | null;
  payment_method_code: string | null;
  customer_posting_group_code: string | null;
  your_reference: string | null;
  /** The posted invoice a corrective Credit Memo is raised against (BC Applies-to Doc. No.). */
  applies_to_doc_no: string | null;
  salesperson: string | null;
  currency_code: string;
  currency_factor: number;
  global_dimension_1_id: number | null;
  global_dimension_2_id: number | null;
  status: SalesDocumentStatus;
  amount: Cents;
  decision_reason: string | null;
  created_at: IsoDateTime | null;
  created_by: string | null;
}

export interface SalesHeaderView extends SalesHeader {
  customer_no: string;
  customer_name: string;
  customer_blocked: CustomerBlocked;
}

/** Business Central Table 37 "Sales Line". */
export interface SalesLine {
  id: number;
  sales_header_id: number;
  line_no: number;
  type: SalesLineType;
  no: string | null;
  description: string | null;
  quantity: number;
  unit_price: Cents;
  line_discount_pct: number;
  line_discount_amount: Cents;
  line_amount: Cents;
  qty_to_ship: number;
  qty_shipped: number;
  qty_to_invoice: number;
  qty_invoiced: number;
  location_code: string | null;
  fa_depreciation_book_code: string | null;
  depr_until_date: IsoDate | null;
  global_dimension_1_id: number | null;
  global_dimension_2_id: number | null;
}

export interface SalesDocumentDetail extends SalesHeaderView {
  lines: SalesLine[];
  outstanding_amount: Cents;
  shipped_not_invoiced: Cents;
}

export interface PostedSalesDocument {
  id: number;
  document_type: PostedSalesDocumentType;
  no: string;
  customer_id: number;
  sell_to_name: string | null;
  sell_to_address: string | null;
  sell_to_city: string | null;
  sell_to_contact: string | null;
  posting_date: IsoDate;
  document_date: IsoDate;
  due_date: IsoDate | null;
  order_no: string | null;
  /** The open document this was posted from — what its approval trail is recorded against. */
  source_no: string | null;
  payment_terms_code: string | null;
  your_reference: string | null;
  /** The invoice a posted Credit Memo corrected. */
  applies_to_doc_no: string | null;
  currency_code: string;
  currency_factor: number;
  amount: Cents;
  cust_ledger_entry_id: number | null;
  journal_id: number | null;
  created_at: IsoDateTime | null;
  created_by: string | null;
}

export interface PostedSalesDocumentView extends PostedSalesDocument {
  customer_no: string;
  customer_name: string;
}

export interface PostedSalesLine {
  id: number;
  posted_sales_document_id: number;
  line_no: number;
  type: SalesLineType;
  no: string | null;
  description: string | null;
  quantity: number;
  unit_price: Cents;
  line_discount_amount: Cents;
  line_amount: Cents;
  cogs_amount: Cents;
  item_ledger_entry_id: number | null;
  fa_ledger_entry_id: number | null;
}

/** Business Central Table 21 "Cust. Ledger Entry". */
export interface CustLedgerEntry {
  id: number;
  customer_id: number;
  posting_date: IsoDate;
  document_type: CustLedgerDocumentType;
  document_no: string;
  description: string | null;
  amount: Cents;
  remaining_amount: Cents;
  original_amount: Cents;
  amount_lcy: Cents;
  remaining_amount_lcy: Cents;
  original_amount_lcy: Cents;
  currency_code: string;
  currency_factor: number;
  due_date: IsoDate | null;
  pmt_discount_date: IsoDate | null;
  original_pmt_disc_possible: Cents;
  open: Flag;
  positive: Flag;
  closed_by_entry_no: number | null;
  closed_at_date: IsoDate | null;
  reminder_level: number;
  calculate_interest: Flag;
  source_type: string | null;
  source_id: number | null;
  journal_id: number | null;
  created_at: IsoDateTime | null;
}

export interface CustLedgerEntryView extends CustLedgerEntry {
  customer_no: string;
  customer_name: string;
}

export interface DetailedCustLedgerEntry {
  id: number;
  cust_ledger_entry_id: number;
  entry_type: DetailedCustLedgerEntryType;
  posting_date: IsoDate;
  document_type: string | null;
  document_no: string | null;
  amount: Cents;
  amount_lcy: Cents;
  applied_cust_ledger_entry_id: number | null;
  journal_id: number | null;
  unapplied: Flag;
  unapplied_by_entry_id: number | null;
  created_at: IsoDateTime | null;
}

export interface ReminderHeader {
  id: number;
  document_type: ReminderDocumentType;
  no: string;
  customer_id: number;
  posting_date: IsoDate;
  document_date: IsoDate;
  due_date: IsoDate | null;
  reminder_terms_code: string | null;
  fin_charge_terms_code: string | null;
  reminder_level: number;
  customer_posting_group_code: string | null;
  use_header_level: Flag;
  status: ReminderStatus;
  remaining_amount: Cents;
  interest_amount: Cents;
  additional_fee: Cents;
  total_amount: Cents;
  decision_reason: string | null;
  journal_id: number | null;
  cust_ledger_entry_id: number | null;
  issued_at: IsoDateTime | null;
  issued_by: string | null;
  created_at: IsoDateTime | null;
  created_by: string | null;
}

export interface ReminderHeaderView extends ReminderHeader {
  customer_no: string;
  customer_name: string;
}

export interface ReminderLine {
  id: number;
  reminder_header_id: number;
  line_no: number;
  type: ReminderLineType;
  cust_ledger_entry_id: number | null;
  entry_document_type: string | null;
  entry_document_no: string | null;
  due_date: IsoDate | null;
  original_amount: Cents;
  remaining_amount: Cents;
  no: string | null;
  amount: Cents;
  description: string | null;
  line_type: '' | 'Not Due' | 'On Hold';
}

export interface ReminderDetail extends ReminderHeaderView {
  lines: ReminderLine[];
}

/** One row of the Aged Accounts Receivable report (BC Report 120). */
export interface AgedReceivableRow {
  customer_id: number;
  customer_no: string;
  customer_name: string;
  balance: Cents;
  not_due: Cents;
  bucket_1: Cents;
  bucket_2: Cents;
  bucket_3: Cents;
  bucket_over: Cents;
}

export interface AgedReceivableReport {
  as_of: IsoDate;
  aging_by: 'Due Date' | 'Posting Date';
  period_length: string;
  bucket_labels: [string, string, string, string, string];
  rows: AgedReceivableRow[];
  totals: Omit<AgedReceivableRow, 'customer_id' | 'customer_no' | 'customer_name'>;
}

/** One row of the Customer Statement (BC Report 116). */
export interface CustomerStatementLine {
  posting_date: IsoDate;
  document_type: CustLedgerDocumentType;
  document_no: string;
  description: string | null;
  due_date: IsoDate | null;
  amount: Cents;
  remaining_amount: Cents;
  running_balance: Cents;
}

export interface CustomerStatementReport {
  customer_no: string;
  customer_name: string;
  from: IsoDate;
  to: IsoDate;
  opening_balance: Cents;
  closing_balance: Cents;
  lines: CustomerStatementLine[];
}

/* ============================================================================================
 * Payables — Business Central Purchases & Payables (Tables 23/25/38/39/93/120/122/124/312/380).
 * The mirror image of Receivables. See lib/vendors.ts, lib/purchaseDocuments.ts,
 * lib/vendLedger.ts, lib/paymentJournal.ts, lib/payablesReports.ts.
 * ========================================================================================== */

export type VendorBlocked = '' | 'Payment' | 'Invoice' | 'All';
export type PurchaseDocumentType = 'Quote' | 'Order' | 'Invoice' | 'Credit Memo';
export type PurchaseLineType = 'Comment' | 'G/L Account' | 'Item' | 'Fixed Asset';
export type PurchaseDocumentStatus = 'Open' | 'Pending Approval' | 'Released';
export type PostedPurchaseDocumentType = 'Receipt' | 'Invoice' | 'Credit Memo';
export type VendorLedgerDocumentType =
  | 'Invoice' | 'Payment' | 'Credit Memo' | 'Finance Charge Memo' | 'Refund';
export type DetailedVendorLedgerEntryType =
  | 'Initial Entry' | 'Application' | 'Payment Discount' | 'Correction' | 'Unapplied'
  | 'Realized Gain' | 'Realized Loss' | 'Unrealized Gain' | 'Unrealized Loss';
export interface VendorPostingGroup {
  id: number;
  code: string;
  description: string;
  payables_account_id: number;
  service_charge_account_id: number;
  payment_disc_debit_account_id: number;
  payment_disc_credit_account_id: number;
  invoice_rounding_account_id: number;
  created_at: IsoDateTime | null;
  created_by: string | null;
}

export interface VendorPostingGroupView extends VendorPostingGroup {
  payables_account_code: string;
  service_charge_account_code: string;
  payment_disc_debit_account_code: string;
  payment_disc_credit_account_code: string;
  invoice_rounding_account_code: string;
  vendors_using: number;
}

export interface PurchasesPayablesSetup {
  id: number;
  default_vendor_posting_group_code: string | null;
  default_payment_terms_code: string | null;
  default_vat_bus_posting_group_code: string | null;
  prices_incl_vat: Flag;
  receipt_on_invoice: Flag;
  exact_cost_reversing_mandatory: Flag;
  allow_payables_posting_from: IsoDate | null;
  allow_payables_posting_to: IsoDate | null;
  updated_at: IsoDateTime | null;
  updated_by: string | null;
}

/** Business Central Table 23 "Vendor". */
export interface Vendor {
  id: number;
  no: string;
  name: string;
  name_2: string | null;
  address: string | null;
  address_2: string | null;
  city: string | null;
  post_code: string | null;
  country: string | null;
  contact: string | null;
  phone: string | null;
  email: string | null;
  vendor_posting_group_code: string | null;
  vat_bus_posting_group_code: string | null;
  pin_no: string | null;
  wht_exempt: Flag;
  payment_terms_code: string | null;
  payment_method_code: string | null;
  purchaser: string | null;
  currency_code: string | null;
  credit_limit: Cents;
  blocked: VendorBlocked;
  our_account_no: string | null;
  global_dimension_1_id: number | null;
  global_dimension_2_id: number | null;
  balance: Cents;
  last_statement_no: number;
  created_at: IsoDateTime | null;
  created_by: string | null;
}

export interface VendorListRow extends Vendor {
  vendor_posting_group_description: string | null;
  payment_terms_description: string | null;
  balance_due: Cents;
}

export interface VendorStatistics {
  balance: Cents;
  balance_due: Cents;
  outstanding_orders: Cents;
  overdue_entries: number;
  ledger_entry_count: number;
  credit_limit: Cents;
}

/** Business Central Table 38 "Purchase Header". */
export interface PurchaseHeader {
  id: number;
  document_type: PurchaseDocumentType;
  no: string;
  vendor_id: number;
  buy_from_name: string | null;
  buy_from_address: string | null;
  buy_from_city: string | null;
  buy_from_contact: string | null;
  posting_date: IsoDate;
  document_date: IsoDate;
  due_date: IsoDate | null;
  payment_terms_code: string | null;
  payment_method_code: string | null;
  vendor_posting_group_code: string | null;
  vat_bus_posting_group_code: string | null;
  vendor_invoice_no: string | null;
  /** BC "Applies-to Doc. No." — the posted invoice a credit memo settles when it posts. */
  applies_to_doc_no: string | null;
  purchaser: string | null;
  currency_code: string;
  currency_factor: number;
  global_dimension_1_id: number | null;
  global_dimension_2_id: number | null;
  status: PurchaseDocumentStatus;
  amount: Cents;
  amount_incl_vat: Cents;
  decision_reason: string | null;
  /** AL "Requisition No" — the purchase requisition this was raised from. */
  requisition_no: string | null;
  created_at: IsoDateTime | null;
  created_by: string | null;
}

export interface PurchaseHeaderView extends PurchaseHeader {
  vendor_no: string;
  vendor_name: string;
  vendor_blocked: VendorBlocked;
}

/** Business Central Table 39 "Purchase Line". */
export interface PurchaseLine {
  id: number;
  purchase_header_id: number;
  line_no: number;
  type: PurchaseLineType;
  no: string | null;
  description: string | null;
  quantity: number;
  direct_unit_cost: Cents;
  line_discount_pct: number;
  line_discount_amount: Cents;
  line_amount: Cents;
  vat_prod_posting_group_code: string | null;
  vat_pct: number;
  vat_base_amount: Cents;
  vat_amount: Cents;
  amount_incl_vat: Cents;
  qty_to_receive: number;
  qty_received: number;
  qty_to_invoice: number;
  qty_invoiced: number;
  location_code: string | null;
  fa_depreciation_book_code: string | null;
  global_dimension_1_id: number | null;
  global_dimension_2_id: number | null;
}

export interface PurchaseDocumentDetail extends PurchaseHeaderView {
  lines: PurchaseLine[];
  outstanding_amount: Cents;
  received_not_invoiced: Cents;
}

export interface PostedPurchaseDocument {
  id: number;
  document_type: PostedPurchaseDocumentType;
  no: string;
  vendor_id: number;
  buy_from_name: string | null;
  buy_from_address: string | null;
  buy_from_city: string | null;
  buy_from_contact: string | null;
  posting_date: IsoDate;
  document_date: IsoDate;
  due_date: IsoDate | null;
  order_no: string | null;
  /** The open document this was posted from — what its approval trail is recorded against. */
  source_no: string | null;
  vendor_invoice_no: string | null;
  applies_to_doc_no: string | null;
  payment_terms_code: string | null;
  vat_bus_posting_group_code: string | null;
  currency_code: string;
  currency_factor: number;
  amount: Cents;
  amount_incl_vat: Cents;
  vendor_ledger_entry_id: number | null;
  journal_id: number | null;
  created_at: IsoDateTime | null;
  created_by: string | null;
}

export interface PostedPurchaseDocumentView extends PostedPurchaseDocument {
  vendor_no: string;
  vendor_name: string;
}

export interface PostedPurchaseLine {
  id: number;
  posted_purchase_document_id: number;
  line_no: number;
  type: PurchaseLineType;
  no: string | null;
  description: string | null;
  quantity: number;
  direct_unit_cost: Cents;
  line_discount_amount: Cents;
  line_amount: Cents;
  vat_prod_posting_group_code: string | null;
  vat_pct: number;
  vat_base_amount: Cents;
  vat_amount: Cents;
  amount_incl_vat: Cents;
  item_ledger_entry_id: number | null;
  fa_ledger_entry_id: number | null;
}

/** Business Central Table 25 "Vendor Ledger Entry". */
export interface VendorLedgerEntry {
  id: number;
  vendor_id: number;
  posting_date: IsoDate;
  document_type: VendorLedgerDocumentType;
  document_no: string;
  vendor_invoice_no: string | null;
  description: string | null;
  amount: Cents;
  remaining_amount: Cents;
  original_amount: Cents;
  amount_lcy: Cents;
  remaining_amount_lcy: Cents;
  original_amount_lcy: Cents;
  currency_code: string;
  currency_factor: number;
  due_date: IsoDate | null;
  pmt_discount_date: IsoDate | null;
  original_pmt_disc_possible: Cents;
  open: Flag;
  positive: Flag;
  closed_by_entry_no: number | null;
  closed_at_date: IsoDate | null;
  on_hold: string | null;
  source_type: string | null;
  source_id: number | null;
  journal_id: number | null;
  created_at: IsoDateTime | null;
}

export interface VendorLedgerEntryView extends VendorLedgerEntry {
  vendor_no: string;
  vendor_name: string;
}

export interface DetailedVendorLedgerEntry {
  id: number;
  vendor_ledger_entry_id: number;
  entry_type: DetailedVendorLedgerEntryType;
  posting_date: IsoDate;
  document_type: string | null;
  document_no: string | null;
  amount: Cents;
  amount_lcy: Cents;
  applied_vendor_ledger_entry_id: number | null;
  journal_id: number | null;
  unapplied: Flag;
  unapplied_by_entry_id: number | null;
  created_at: IsoDateTime | null;
}

/** One row of the Aged Accounts Payable report (BC Report 322). */
export interface AgedPayableRow {
  vendor_id: number;
  vendor_no: string;
  vendor_name: string;
  balance: Cents;
  not_due: Cents;
  bucket_1: Cents;
  bucket_2: Cents;
  bucket_3: Cents;
  bucket_over: Cents;
}

export interface AgedPayableReport {
  as_of: IsoDate;
  aging_by: 'Due Date' | 'Posting Date';
  period_length: string;
  bucket_labels: [string, string, string, string, string];
  rows: AgedPayableRow[];
  totals: Omit<AgedPayableRow, 'vendor_id' | 'vendor_no' | 'vendor_name'>;
}

export interface VendorStatementLine {
  posting_date: IsoDate;
  document_type: VendorLedgerDocumentType;
  document_no: string;
  description: string | null;
  due_date: IsoDate | null;
  amount: Cents;
  remaining_amount: Cents;
  running_balance: Cents;
}

export interface VendorStatementReport {
  vendor_no: string;
  vendor_name: string;
  from: IsoDate;
  to: IsoDate;
  opening_balance: Cents;
  closing_balance: Cents;
  lines: VendorStatementLine[];
}

/* ============================================================================================
 * Cash Management (Business Central) + multi-currency. See lib/bankMgmt.ts, lib/cashMgmtSetup.ts,
 * lib/receipts.ts, lib/paymentVouchers.ts.
 * ========================================================================================== */

/**
 * AL's Receipt Type (Enum-Ext52204000 adds Member). It is set on the header and fixes what every
 * line may be posted to — a Receipt Type of G/L Account takes G/L lines and nothing else.
 */
export type ReceiptLineType = 'Member' | 'Employee' | 'Customer' | 'Vendor' | 'G/L Account' | 'Bank Account';
export type ReceiptStatus = 'Open' | 'Pending Approval' | 'Approved';
export type PaymentVoucherLineType = 'Member' | 'Employee' | 'G/L Account' | 'Vendor' | 'Customer' | 'Bank Account';

/**
 * AL's Payment Type (Enum-Ext52204001 adds the SACCO ones). It is set on the header and fixes
 * what every line may pay — the AL relates Payment Voucher Lines."Account No" to a different
 * table per Payment Type, so a Supplier Payment pays vendors and nothing else.
 *
 * The AL's Employee Payment and EFT Loan Payment are deliberately absent: this system has no
 * employee subledger to post against, and a loan is disbursed through lib/loanService.ts's
 * disburse(), so a second path to the same money would be a way to pay it twice.
 */
export type PaymentVoucherType =
  | 'Member Payment' | 'RTGS/SWIFT' | 'Supplier Payment' | 'Customer Refund' | 'Bank Transfer'
  | 'Direct Expensing' | 'Payroll Settlement' | 'Remittance' | 'Employee Payment';
export type BankLedgerDocumentType =
  '' | 'Payment' | 'Refund' | 'Receipt' | 'Transfer' | 'Reconciliation';
export type BankRecLineType = 'Bank Account Ledger Entry' | 'G/L Adjustment';

export interface Currency {
  id: number;
  code: string;
  description: string;
  symbol: string | null;
  iso_numeric_code: string | null;
  is_base: Flag;
  amount_rounding_precision: Cents;
  invoice_rounding_precision: Cents;
  realized_gains_account_id: number | null;
  realized_losses_account_id: number | null;
  unrealized_gains_account_id: number | null;
  unrealized_losses_account_id: number | null;
  residual_gains_account_id: number | null;
  residual_losses_account_id: number | null;
  blocked: Flag;
  created_at: IsoDateTime | null;
  created_by: string | null;
}

export interface CurrencyView extends Currency {
  realized_gains_account_code: string | null;
  realized_losses_account_code: string | null;
  latest_rate: number | null;
  rate_count: number;
}

export interface CurrencyExchangeRate {
  id: number;
  currency_code: string;
  starting_date: IsoDate;
  exchange_rate_amount: number;
  relational_exch_rate_amount: number;
  created_at: IsoDateTime | null;
  created_by: string | null;
}

export interface BankAccPostingGroup {
  id: number;
  code: string;
  description: string;
  gl_account_id: number;
  created_at: IsoDateTime | null;
  created_by: string | null;
}

export interface BankAccPostingGroupView extends BankAccPostingGroup {
  gl_account_code: string;
  gl_account_name: string;
  accounts_using: number;
}

export interface ExternalBank {
  id: number;
  code: string;
  name: string;
  created_at: IsoDateTime | null;
  created_by: string | null;
}

export interface ExternalBankBranch {
  id: number;
  bank_code: string;
  branch_code: string;
  branch_name: string;
}

export interface CashManagementSetup {
  id: number;
  receipt_approval_limit: Cents;
  pv_approval_limit: Cents;
  default_vat_bus_posting_group_code: string | null;
  bank_charges_account_id: number | null;
  bank_interest_income_account_id: number | null;
  default_receipt_bank_account_id: number | null;
  allow_cm_posting_from: IsoDate | null;
  allow_cm_posting_to: IsoDate | null;
  /** AL General Ledger Setup "Loan Repayment Charge" — applied to a Member receipt line that
   *  repays a loan, and taken off before the rest reaches the loan. */
  loan_repayment_charge_id: number | null;
  /** Which savings product receives the remainder when a member pays more than their loan owes.
   *  Null means the receipt refuses the overpayment instead. */
  unallocated_product_id: number | null;
  updated_at: IsoDateTime | null;
  updated_by: string | null;
}

export interface BankRecLine {
  id: number;
  bank_reconciliation_id: number;
  line_no: number;
  type: BankRecLineType;
  transaction_date: IsoDate | null;
  document_no: string | null;
  description: string | null;
  statement_amount: Cents;
  applied_amount: Cents;
  bank_account_ledger_entry_id: number | null;
  gl_account_id: number | null;
  applied: Flag;
}

export interface BankRecLineView extends BankRecLine {
  entry_amount: Cents | null;
  entry_open: Flag | null;
  gl_account_code: string | null;
}

export interface BankReconciliationDetail {
  reconciliation: BankReconciliation;
  bankAccount: BankAccount;
  lines: BankRecLineView[];
  unmatchedEntries: BankAccountLedgerEntryWithJournal[];
  appliedTotal: Cents;
  adjustmentTotal: Cents;
  totalBalance: Cents;
  difference: Cents;
}

/* --------------------------------------------------------------------- Receipt */

export interface ReceiptHeader {
  id: number;
  no: string;
  receipt_type: ReceiptLineType;
  posting_date: IsoDate;
  bank_account_id: number;
  bank_account_name: string | null;
  pay_mode_code: string | null;
  external_document_no: string | null;
  manual_receipt_no: string | null;
  description: string | null;
  currency_code: string;
  currency_factor: number;
  global_dimension_1_id: number | null;
  global_dimension_2_id: number | null;
  amount: Cents;
  approval_limit: Cents;
  status: ReceiptStatus;
  posted: boolean;
  decision_reason: string | null;
  journal_id: number | null;
  created_at: IsoDateTime | null;
  created_by: string | null;
  posted_at: IsoDateTime | null;
  posted_by: string | null;
  /** Receipt Type = Member only. */
  member_id: number | null;
  member_no: string | null;
  member_name: string | null;
  employee_id: number | null;
  /** AL "Received Amount" — what the teller counted, checked against the sum of the lines. */
  received_amount: Cents;
}

export interface ReceiptHeaderView extends ReceiptHeader {
  employee_no: string | null;
  employee_name: string | null;
  bank_account_code: string;
  line_count: number;
  journal_no: string | null;
}

export interface ReceiptLine {
  id: number;
  receipt_header_id: number;
  line_no: number;
  line_type: ReceiptLineType;
  account_no: string | null;
  account_name: string | null;
  description: string | null;
  amount: Cents;
  applies_to_doc_no: string | null;
  global_dimension_1_id: number | null;
  global_dimension_2_id: number | null;
  /* Receipt Type = Member only — see lib/receipts.ts. */
  member_id: number | null;
  savings_account_id: number | null;
  loan_id: number | null;
  product_category: SavingsCategory | null;
  /** The loan balances as quoted when the line was captured — printed on the receipt. */
  penalty_balance: Cents;
  accrued_interest: Cents;
  interest_balance: Cents;
  principal_balance: Cents;
  loan_balance: Cents;
  charge_id: number | null;
  charge_amount: Cents;
}

/** One of a member's own accounts, as offered on a Member receipt line. */
export interface MemberReceiptAccount {
  id: number;
  account_no: string;
  product_name: string;
  category: SavingsCategory;
  balance: Cents;
  /** True when the account is on a LOAN ACCOUNT product, so the line needs a Loan No. */
  is_loan_account: boolean;
}

/** A loan the member can repay through a receipt, with the balances the teller quotes. */
export interface MemberReceiptLoan {
  id: number;
  loan_no: string;
  product_name: string;
  savings_account_id: number | null;
  penalty_balance: Cents;
  accrued_interest: Cents;
  interest_balance: Cents;
  principal_balance: Cents;
  loan_balance: Cents;
}

export interface ReceiptDetail extends ReceiptHeaderView {
  lines: ReceiptLine[];
}

export interface PostedReceipt {
  id: number;
  no: string;
  receipt_no: string;
  receipt_type: ReceiptLineType;
  bank_account_id: number;
  bank_account_name: string | null;
  pay_mode_code: string | null;
  external_document_no: string | null;
  manual_receipt_no: string | null;
  description: string | null;
  currency_code: string;
  currency_factor: number;
  posting_date: IsoDate;
  amount: Cents;
  journal_id: number | null;
  created_at: IsoDateTime | null;
  created_by: string | null;
  /* Receipt Type = Member only. */
  member_id: number | null;
  member_no: string | null;
  member_name: string | null;
  employee_id: number | null;
}

export interface PostedReceiptLine {
  id: number;
  posted_receipt_id: number;
  line_no: number;
  line_type: ReceiptLineType;
  account_no: string | null;
  account_name: string | null;
  description: string | null;
  amount: Cents;
  applies_to_doc_no: string | null;
  /* Receipt Type = Member only — the snapshot the printed receipt shows. */
  member_id: number | null;
  savings_account_id: number | null;
  loan_id: number | null;
  product_category: SavingsCategory | null;
  penalty_balance: Cents;
  accrued_interest: Cents;
  interest_balance: Cents;
  principal_balance: Cents;
  loan_balance: Cents;
  charge_amount: Cents;
}

/* --------------------------------------------------------------- Payment Voucher */

export interface PaymentVoucherHeader {
  id: number;
  no: string;
  date: IsoDate;
  pv_type: PaymentVoucherType | null;
  pay_mode_code: string | null;
  cheque_no: string | null;
  cheque_date: IsoDate | null;
  cheque_received_by: string | null;
  paying_bank_account_id: number;
  currency_code: string;
  currency_factor: number;
  description: string | null;
  payee_name: string | null;
  payee_external_bank_code: string | null;
  payee_bank_branch_code: string | null;
  payee_account_no: string | null;
  global_dimension_1_id: number | null;
  global_dimension_2_id: number | null;
  total_amount: Cents;
  approval_limit: Cents;
  status: ReceiptStatus;
  posted: boolean;
  decision_reason: string | null;
  prepared_by: string | null;
  journal_id: number | null;
  created_at: IsoDateTime | null;
  created_by: string | null;
  posted_at: IsoDateTime | null;
  posted_by: string | null;
  /** Payment Type = Member Payment / RTGS-SWIFT only. */
  member_id: number | null;
  member_no: string | null;
  member_name: string | null;
  employee_id: number | null;
}

/** One of a member's own accounts, as offered on a member payment line. */
export interface MemberPaymentAccount {
  id: number;
  account_no: string;
  product_name: string;
  category: SavingsCategory;
  balance: Cents;
  /** AL's Available Balance: balance less holds less the product's minimum balance, floored at 0. */
  available_balance: Cents;
}

export interface PaymentVoucherHeaderView extends PaymentVoucherHeader {
  paying_bank_account_code: string;
  employee_no: string | null;
  employee_name: string | null;
  line_count: number;
  journal_no: string | null;
}

export interface PaymentVoucherLine {
  id: number;
  payment_voucher_header_id: number;
  line_no: number;
  line_type: PaymentVoucherLineType;
  account_no: string | null;
  account_name: string | null;
  description: string | null;
  amount: Cents;
  applies_to_doc_no: string | null;
  vat_prod_posting_group_code: string | null;
  wht_code_one: string | null;
  wht_code_two: string | null;
  vat_amount: Cents;
  wht_amount_one: Cents;
  wht_amount_two: Cents;
  wht_base: Cents;
  net_amount: Cents;
  purchase_invoice_amount: Cents;
  global_dimension_1_id: number | null;
  global_dimension_2_id: number | null;
  /* Payment Type = Member Payment / RTGS-SWIFT only. */
  member_id: number | null;
  savings_account_id: number | null;
  available_balance: Cents;
}

export interface PaymentVoucherDetail extends PaymentVoucherHeaderView {
  lines: PaymentVoucherLine[];
}

export interface PostedPaymentVoucher {
  id: number;
  no: string;
  pv_no: string;
  date: IsoDate;
  pay_mode_code: string | null;
  cheque_no: string | null;
  cheque_date: IsoDate | null;
  cheque_received_by: string | null;
  paying_bank_account_id: number;
  currency_code: string;
  currency_factor: number;
  description: string | null;
  payee_name: string | null;
  payee_external_bank_code: string | null;
  payee_bank_branch_code: string | null;
  payee_account_no: string | null;
  posting_date: IsoDate;
  total_amount: Cents;
  journal_id: number | null;
  prepared_by: string | null;
  approved_by: string | null;
  created_at: IsoDateTime | null;
  created_by: string | null;
  /** The Payment Type the voucher was raised under — the printout varies by it. */
  pv_type: PaymentVoucherType | null;
  member_id: number | null;
  member_no: string | null;
  member_name: string | null;
  employee_id: number | null;
}

export interface PostedPaymentVoucherLine {
  id: number;
  posted_payment_voucher_id: number;
  line_no: number;
  line_type: PaymentVoucherLineType;
  account_no: string | null;
  account_name: string | null;
  description: string | null;
  amount: Cents;
  applies_to_doc_no: string | null;
  vat_prod_posting_group_code: string | null;
  wht_code_one: string | null;
  wht_code_two: string | null;
  vat_amount: Cents;
  wht_amount_one: Cents;
  wht_amount_two: Cents;
  wht_base: Cents;
  net_amount: Cents;
  /* Payment Type = Member Payment / RTGS-SWIFT only. */
  member_id: number | null;
  savings_account_id: number | null;
  available_balance: Cents;
}

/* ----------------------------------------------------------------- print slips */

/** A resolved signature for a printout — see lib/userSignatures.ts. */
export interface SignatureBlock {
  username: string;
  full_name: string | null;
  src: string | null;
}

/* --------------------------------------------------------------- VAT + Withholding Tax */

export type TaxType = 'VAT' | 'WHT';
export type VatCalculationType = 'Normal' | 'Zero VAT' | 'Exempt';

export interface VatBusinessPostingGroup {
  id: number;
  code: string;
  description: string;
  created_at: IsoDateTime | null;
  created_by: string | null;
}

export interface VatProductPostingGroup {
  id: number;
  code: string;
  description: string;
  tax_type: TaxType;
  created_at: IsoDateTime | null;
  created_by: string | null;
}

export interface VatPostingSetup {
  id: number;
  vat_bus_posting_group_code: string;
  vat_prod_posting_group_code: string;
  tax_type: TaxType;
  vat_pct: number;
  vat_calculation_type: VatCalculationType;
  tax_account_id: number | null;
  wht_base: 'Net' | 'Gross';
  blocked: Flag;
  created_at: IsoDateTime | null;
  created_by: string | null;
}

export interface VatPostingSetupView extends VatPostingSetup {
  tax_account_code: string | null;
  tax_account_name: string | null;
  vat_prod_description: string | null;
}

export interface VatEntry {
  id: number;
  posting_date: IsoDate;
  document_type: string;
  document_no: string;
  type: 'Purchase' | 'Settlement';
  tax_type: TaxType;
  vat_bus_posting_group_code: string | null;
  vat_prod_posting_group_code: string | null;
  vat_pct: number;
  base: Cents;
  amount: Cents;
  base_fcy: Cents;
  amount_fcy: Cents;
  currency_code: string;
  currency_factor: number;
  bill_to_pay_to_no: string | null;
  vendor_pin: string | null;
  wht_certificate_no: string | null;
  journal_id: number | null;
  source_type: string | null;
  source_id: number | null;
  closed: Flag;
  created_at: IsoDateTime | null;
}

export interface WhtCertificate {
  id: number;
  no: string;
  vendor_id: number;
  vendor_name: string | null;
  vendor_pin: string | null;
  payment_voucher_no: string;
  certificate_date: IsoDate;
  gross_amount: Cents;
  total_wht: Cents;
  remitted: Flag;
  remittance_ref: string | null;
  created_at: IsoDateTime | null;
  created_by: string | null;
}

export interface WhtCertificateLine {
  id: number;
  wht_certificate_id: number;
  line_no: number;
  wht_code: string;
  description: string | null;
  rate: number;
  base: Cents;
  wht_amount: Cents;
  vat_entry_id: number | null;
}

export interface WhtCertificateView extends WhtCertificate {
  vendor_no: string;
}

export interface WhtCertificateDetail extends WhtCertificateView {
  lines: WhtCertificateLine[];
}

/** The one place the AL "Payment Voucher Lines".Amount arithmetic lives. */
export interface LineTaxResult {
  vatBase: Cents;
  vatAmount: Cents;
  netOfVat: Cents;
  whtBase: Cents;
  whtOne: Cents;
  whtTwo: Cents;
  netPaid: Cents;
}

export interface WhtCertificateSlipLine {
  wht_code: string;
  description: string;
  rate: number;
  base: Cents;
  wht_amount: Cents;
}

export interface WhtCertificateSlip {
  org_name: string;
  org_address: string;
  org_pin: string | null;
  certificate_no: string;
  certificate_date: IsoDate;
  vendor_name: string;
  vendor_pin: string | null;
  payment_voucher_no: string;
  gross_amount: Cents;
  total_wht: Cents;
  total_wht_words: string;
  lines: WhtCertificateSlipLine[];
  /** The issuing officer's signature on file, resolved at print time (lib/userSignatures.ts). */
  issued_by_signature: SignatureBlock | null;
}

export interface VatInputListingRow {
  vat_prod_posting_group_code: string;
  description: string | null;
  vat_pct: number;
  base: Cents;
  amount: Cents;
  entry_count: number;
}

export interface WhtAnalysisRow {
  bill_to_pay_to_no: string | null;
  vendor_name: string | null;
  vendor_pin: string | null;
  wht_code: string | null;
  rate: number;
  base: Cents;
  amount: Cents;
  entry_count: number;
}

/* ================================================================================================
 * HR & Payroll — Employee Management (ported from "Sacco ERP" AL, object range 52203xxx).
 * ================================================================================================ */

/** Collapses AL's two overlapping status fields into one lifecycle. */
/** AL Payroll Salary Card "Payment Mode". */
export type PaymentMode = 'Bank Transfer' | 'Cheque' | 'Cash' | 'FOSA';
export const PAYMENT_MODES: PaymentMode[] = ['Bank Transfer', 'Cheque', 'Cash', 'FOSA'];

export type EmployeeStatus =
  | 'NEW' | 'PENDING_APPROVAL' | 'ACTIVE' | 'ON_LEAVE' | 'PENDING_FINAL_PAYMENT' | 'INACTIVE' | 'TERMINATED';

/** AL Tab52203636 "Salary Scale Pointers" — a notch on a job grade's salary scale. */
export interface HrSalaryScale {
  id: number; job_grade_id: number; code: string; name: string | null; basic_pay_cents: Cents;
  sequence: number; status: 'ACTIVE' | 'INACTIVE'; created_at: IsoDateTime | null; created_by: string | null;
}
/** AL Tab52203627 "Income/Deduction Configuration" — one earning / deduction a notch confers. */
export interface HrSalaryScaleBenefit {
  id: number; salary_scale_id: number; transaction_code_id: number; amount_cents: Cents; notes: string | null;
}
export interface HrSalaryScaleBenefitView extends HrSalaryScaleBenefit {
  transaction_code: string; transaction_name: string; transaction_type: PayrollTransactionType;
}
export interface HrSalaryScaleView extends HrSalaryScale {
  job_grade_code: string; job_grade_name: string;
  employee_count: number;
  benefits: HrSalaryScaleBenefitView[];
}

export interface HrJobGrade {
  id: number; code: string; name: string;
  notice_period_days: number; probation_notice_period_days: number;
  leave_allowance_amount: Cents; training_allowance_amount: Cents; overtime_allowance_amount: Cents;
  status: string; created_at: IsoDateTime | null; created_by: string | null;
}

export interface HrEmploymentContractType {
  id: number; code: string; name: string; default_notice_period_days: number; status: string;
  created_at: IsoDateTime | null; created_by: string | null;
}

export interface HrTerminationReason {
  id: number; code: string; description: string; pay_gratuity: boolean; status: string;
  created_at: IsoDateTime | null; created_by: string | null;
}

export interface HrClearanceSection {
  id: number; code: string; name: string; owner_email: string | null; sort_order: number; status: string;
  created_at: IsoDateTime | null; created_by: string | null;
}

export interface Employee {
  id: number;
  employee_no: string;
  first_name: string;
  middle_name: string | null;
  last_name: string;
  gender: string | null;
  date_of_birth: IsoDate | null;
  national_id: string | null;
  kra_pin: string | null;
  nssf_no: string | null;
  shif_no: string | null;
  marital_status: string | null;
  phone: string | null;
  alt_phone: string | null;
  email: string | null;
  physical_address: string | null;
  county_id: number | null;
  sub_county_id: number | null;
  job_title: string | null;
  job_grade_id: number | null;
  /** AL Employee."Job Code" — the Company Job (position) held; drives the organogram. */
  company_job_id: number | null;
  contract_type_id: number | null;
  nature_of_employment: 'PERMANENT' | 'CONTRACT' | 'BOARD' | 'SECONDED';
  employee_type: 'STAFF' | 'DRIVER' | 'INTERN' | 'NYSC';
  employment_date: IsoDate;
  probation_period_months: number;
  probation_end_date: IsoDate | null;
  probation_status: 'ON_PROBATION' | 'CONFIRMED' | 'EXTENDED' | 'TERMINATED';
  confirmed_date: IsoDate | null;
  manager_id: number | null;
  overview_manager_id: number | null;
  bank_code: string | null;
  bank_branch: string | null;
  bank_account_no: string | null;
  posting_group_id: number | null;
  global_dimension_1_id: number | null;
  global_dimension_2_id: number | null;
  member_id: number | null;
  salary_scale_id: number | null;
  basic_pay_cents: Cents;
  /** AL Tab52203623 "Payroll Salary Card" — how the employee is paid (basic pay is the contract's). */
  payment_mode: PaymentMode;
  payroll_currency_code: string | null;
  pays_nssf: boolean;
  pays_shif: boolean;
  pays_paye: boolean;
  payslip_message: string | null;
  suspend_pay: boolean;
  suspension_date: IsoDate | null;
  suspension_reasons: string | null;
  stop_relief: boolean;
  insurance_certificate: boolean;
  /** Passport photo / specimen signature — Cloudinary public_ids, or null. */
  photo_image: string | null;
  signature_image: string | null;
  photo_url: string | null;
  disabled: boolean;
  disability_notes: string | null;
  status: EmployeeStatus;
  decision_reason: string | null;
  termination_reason_id: number | null;
  termination_date: IsoDate | null;
  notes: string | null;
  created_at: IsoDateTime | null;
  created_by: string | null;
}

export interface EmployeeView extends Employee {
  job_grade_name: string | null;
  company_job_code: string | null; company_job_name: string | null;
  posting_group_code: string | null;
  posting_group_name: string | null;
  member_no: string | null;
  member_name: string | null;
  contract_type_name: string | null;
  manager_first_name: string | null;
  manager_last_name: string | null;
  county_name: string | null;
  sub_county_name: string | null;
  global_dimension_1_code: string | null;
  global_dimension_1_name: string | null;
  global_dimension_2_code: string | null;
  global_dimension_2_name: string | null;
}

export interface EmployeeNextOfKin {
  id: number; employee_id: number; full_name: string; relationship: string | null;
  id_no: string | null; phone: string | null; email: string | null;
}

export interface EmployeeBeneficiary {
  id: number; employee_id: number; full_name: string; id_no: string | null; date_of_birth: IsoDate | null;
  relationship: string | null; gender: string | null; phone: string | null; email: string | null;
  percentage: number; is_minor: boolean;
}

export interface EmployeeDependant {
  id: number; employee_id: number; full_name: string; id_or_birth_cert_no: string | null;
  date_of_birth: IsoDate | null; relationship: string | null; gender: string | null;
  is_student: boolean; status: string;
}

export interface EmployeeEmergencyContact {
  id: number; employee_id: number; full_name: string; relationship: string | null;
  phone: string | null; alt_phone: string | null; email: string | null;
}

export interface EmployeeProfessionalBody {
  id: number; employee_id: number; body_name: string; membership_no: string | null;
  from_date: IsoDate | null; to_date: IsoDate | null;
}

export interface EmployeeWorkHistory {
  id: number; employee_id: number; institution: string; position_held: string | null;
  from_date: IsoDate | null; to_date: IsoDate | null; reason_for_leaving: string | null;
}

export interface EmployeeBankAccount {
  id: number; employee_id: number; bank_code: string | null; branch: string | null;
  account_no: string; percentage: number;
}

export interface EmployeeContract {
  id: number; employee_id: number; contract_type_id: number | null;
  start_date: IsoDate; end_date: IsoDate | null; job_title: string | null; grade_id: number | null;
  salary_cents: Cents; notice_period_days: number | null; is_current: boolean; status: string;
  created_at: IsoDateTime | null; created_by: string | null;
}

/** Mirrors member_edit_request: one edit request per employee, carrying the proposed bio-data
 *  field values, plus a replace-all shadow table per sub-entity list (see lib/employeeEdits.ts). */
export interface EmployeeEditRequest {
  no: string;
  employee_id: number;
  first_name: string | null;
  middle_name: string | null;
  last_name: string | null;
  gender: string | null;
  date_of_birth: IsoDate | null;
  national_id: string | null;
  kra_pin: string | null;
  nssf_no: string | null;
  shif_no: string | null;
  marital_status: string | null;
  phone: string | null;
  alt_phone: string | null;
  email: string | null;
  physical_address: string | null;
  county_id: number | null;
  sub_county_id: number | null;
  job_title: string | null;
  job_grade_id: number | null;
  /** AL Employee."Job Code" — the Company Job (position) held; drives the organogram. */
  company_job_id: number | null;
  bank_code: string | null;
  bank_branch: string | null;
  bank_account_no: string | null;
  global_dimension_1_id: number | null;
  global_dimension_2_id: number | null;
  /** SACCO Member No. (AL Employee."Member No.") — proposed with the Payroll Salary Card. */
  member_id: number | null;
  posting_group_id: number | null;
  /** AL "J-G Steps" — the salary-scale notch within the job grade; null = off-scale. */
  salary_scale_id: number | null;
  /** Payroll Salary Card "Basic Pay" — kept in step with the current contract's salary. */
  basic_pay_cents: Cents;
  /** AL Tab52203623 "Payroll Salary Card" — how the employee is paid (basic pay is the contract's). */
  payment_mode: PaymentMode;
  payroll_currency_code: string | null;
  pays_nssf: boolean;
  pays_shif: boolean;
  pays_paye: boolean;
  payslip_message: string | null;
  suspend_pay: boolean;
  suspension_date: IsoDate | null;
  suspension_reasons: string | null;
  stop_relief: boolean;
  insurance_certificate: boolean;
  /** Proposed passport photo / specimen signature (Cloudinary public_ids), applied with the rest. */
  photo_image: string | null;
  signature_image: string | null;
  status: DocumentStatus;
  decision_reason: string | null;
  created_at: IsoDateTime | null;
  created_by: string | null;
}

export interface EmployeeEditRequestView extends EmployeeEditRequest {
  company_job_code: string | null; company_job_name: string | null;
  employee_no: string; employee_first_name: string; employee_last_name: string;
  job_grade_name: string | null; county_name: string | null; sub_county_name: string | null;
  posting_group_code: string | null; posting_group_name: string | null;
  member_no: string | null; member_name: string | null;
  global_dimension_1_code: string | null; global_dimension_1_name: string | null;
  global_dimension_2_code: string | null; global_dimension_2_name: string | null;
}

export type EmployeeEditNextOfKin = Omit<EmployeeNextOfKin, 'employee_id'> & { edit_no: string };
export type EmployeeEditBeneficiary = Omit<EmployeeBeneficiary, 'employee_id'> & { edit_no: string };
export type EmployeeEditDependant = Omit<EmployeeDependant, 'employee_id' | 'status'> & { edit_no: string };
export type EmployeeEditEmergencyContact = Omit<EmployeeEmergencyContact, 'employee_id'> & { edit_no: string };
export type EmployeeEditProfessionalBody = Omit<EmployeeProfessionalBody, 'employee_id'> & { edit_no: string };
export type EmployeeEditWorkHistory = Omit<EmployeeWorkHistory, 'employee_id'> & { edit_no: string };
export type EmployeeEditBankAccount = Omit<EmployeeBankAccount, 'employee_id'> & { edit_no: string };

export type EmployeeContractChangeNature = 'NEW_CONTRACT' | 'RENEWAL' | 'SALARY_INCREMENT';

export interface EmployeeContractChange {
  no: string;
  employee_id: number;
  nature: EmployeeContractChangeNature;
  contract_type_id: number | null;
  proposed_start_date: IsoDate | null;
  proposed_end_date: IsoDate | null;
  proposed_salary_cents: Cents | null;
  proposed_grade_id: number | null;
  reason: string | null;
  status: DocumentStatus;
  decision_reason: string | null;
  created_at: IsoDateTime | null;
  created_by: string | null;
}

export interface EmployeeContractChangeView extends EmployeeContractChange {
  employee_no: string; employee_first_name: string; employee_last_name: string;
}

export type EmployeeExitDueType = 'LEAVE_ENCASHMENT' | 'NOTICE_PENALTY' | 'NOTICE_INCOME' | 'GRATUITY' | 'UNCLEARED_ITEMS';

export interface EmployeeExit {
  no: string;
  employee_id: number;
  termination_reason_id: number | null;
  date_of_notice: IsoDate | null;
  date_of_exit: IsoDate | null;
  notice_period_days: number | null;
  notice_fully_served: boolean | null;
  reasons_for_not_serving_notice: string | null;
  can_be_reemployed: boolean | null;
  cleared: boolean;
  status: DocumentStatus;
  decision_reason: string | null;
  created_at: IsoDateTime | null;
  created_by: string | null;
}

export interface EmployeeExitView extends EmployeeExit {
  employee_no: string; employee_first_name: string; employee_last_name: string;
}

export interface EmployeeExitFinalDueLine {
  id: number; exit_no: string; due_type: EmployeeExitDueType; description: string | null; amount_cents: Cents;
}

export interface EmployeeExitClearanceLine {
  id: number; exit_no: string; section_id: number; cleared: boolean;
  cleared_by: string | null; cleared_at: IsoDateTime | null; remarks: string | null;
}

export interface EmployeeExitClearanceLineView extends EmployeeExitClearanceLine {
  section_code: string; section_name: string; owner_email: string | null;
}

/* ================================================================================================
 * HR & Payroll — Leave Management (ported from "Sacco ERP" AL, object range 52203xxx).
 * ================================================================================================ */

export type LeaveGender = 'ANY' | 'MALE' | 'FEMALE';
export type LeaveBalanceTreatment = 'IGNORE' | 'CARRY_FORWARD' | 'CONVERT_CASH';

export interface HrLeaveType {
  id: number; code: string; name: string;
  standard_days: number; accrues: boolean; days_to_accrue: number; unlimited_days: boolean;
  gender: LeaveGender; balance_treatment: LeaveBalanceTreatment; max_carry_forward_days: number;
  inclusive_of_saturday: boolean; inclusive_of_sunday: boolean; inclusive_of_holidays: boolean;
  fixed_days: boolean; is_annual: boolean; max_applicable_days: number | null;
  check_balance: boolean; is_sick_leave: boolean; requires_admin_approval: boolean;
  leave_balance_notification_threshold: number | null; disabled: boolean; status: string;
  created_at: IsoDateTime | null; created_by: string | null;
}

export interface HrLeaveCalendar {
  id: number; code: string; start_date: IsoDate; end_date: IsoDate;
  is_current: boolean; closed: boolean; closed_at: IsoDateTime | null; closed_by: string | null;
  created_at: IsoDateTime | null; created_by: string | null;
}

export interface HrHoliday { id: number; date: IsoDate; reason: string; recurring: boolean }

export interface HrLeaveDaysToAccrue {
  id: number; leave_type_id: number; job_grade_id: number; days_to_accrue: number; leave_day_worth_cents: Cents;
}

export type LeaveLedgerEntryType = 'POSITIVE' | 'NEGATIVE' | 'REIMBURSEMENT' | 'OPENING_BALANCE' | 'ACCRUED';

export interface HrLeaveLedgerEntry {
  id: number; employee_id: number; leave_type_id: number; leave_calendar_id: number;
  quantity: number; entry_type: LeaveLedgerEntryType; posting_date: IsoDate;
  document_no: string | null; source_type: string | null; source_id: string | null;
  closed: boolean; description: string | null; created_at: IsoDateTime | null; created_by: string | null;
}

export type LeaveApplicationNature = 'APPLICATION' | 'REIMBURSEMENT';

export interface HrLeaveApplication {
  no: string; employee_id: number; leave_type_id: number; nature: LeaveApplicationNature;
  leave_calendar_id: number; start_date: IsoDate; end_date: IsoDate;
  days_applied: number; weekend_days: number; holiday_days: number; total_days: number;
  reliever_id: number | null; status: DocumentStatus; decision_reason: string | null;
  leave_allowance_payable: boolean; posted: boolean; posting_date: IsoDate | null;
  days_dropped: number | null; days_to_reimburse: number | null; justification: string | null;
  created_at: IsoDateTime | null; created_by: string | null;
}

export interface HrLeaveApplicationView extends HrLeaveApplication {
  employee_no: string; employee_first_name: string; employee_last_name: string;
  leave_type_name: string; reliever_first_name: string | null; reliever_last_name: string | null;
  balance: number;
}

export interface HrLeaveAdjustment {
  no: string; leave_type_id: number; type: 'POSITIVE' | 'NEGATIVE'; description: string | null;
  days: number; status: DocumentStatus; decision_reason: string | null;
  created_at: IsoDateTime | null; created_by: string | null;
}

export interface HrLeaveAdjustmentView extends HrLeaveAdjustment { leave_type_name: string; line_count: number }

export interface HrLeaveAdjustmentLine {
  id: number; adjustment_no: string; employee_id: number; days: number;
}
export interface HrLeaveAdjustmentLineView extends HrLeaveAdjustmentLine {
  employee_no: string; employee_first_name: string; employee_last_name: string;
}

export interface HrLeaveRecall {
  no: string; employee_id: number; application_no: string; days_to_recall: number;
  status: DocumentStatus; decision_reason: string | null;
  created_at: IsoDateTime | null; created_by: string | null;
}
export interface HrLeaveRecallView extends HrLeaveRecall {
  employee_no: string; employee_first_name: string; employee_last_name: string;
  application_start_date: IsoDate; application_end_date: IsoDate; application_days_applied: number;
}

export interface HrLeavePlan {
  no: string; employee_id: number; leave_calendar_id: number;
  status: DocumentStatus; decision_reason: string | null;
  created_at: IsoDateTime | null; created_by: string | null;
}
export interface HrLeavePlanView extends HrLeavePlan {
  employee_no: string; employee_first_name: string; employee_last_name: string;
}
export interface HrLeavePlanLine { id: number; plan_no: string; start_date: IsoDate; end_date: IsoDate; days: number }

/* ================================================================================================
 * HR & Payroll — Payroll (ported from "Sacco ERP" AL, object range 52203xxx). Posts real
 * double-entry journals on period close via the existing postJournal() engine.
 * ================================================================================================ */

export interface HrPayrollSetup {
  id: 1;
  personal_relief_cents: Cents; insurance_relief_pct: number; max_relief_cents: Cents;
  /** Owner-occupier interest cap per month — P9 column F (KES 30,000 from 27 Dec 2024). */
  mortgage_relief_cents: Cents; shif_pct: number; shif_based_on: 'GROSS' | 'BASIC' | 'TAXABLE';
  nssf_employer_factor: number; housing_levy_enabled: boolean; housing_levy_pct: number;
  housing_levy_based_on: 'GROSS' | 'BASIC' | 'TAXABLE'; minimum_relief_threshold_cents: Cents;
  secondary_tax_pct: number; monthly_working_days: number;
  /** P9 column E3 — the fixed monthly cap on the defined-contribution deduction. */
  pension_deduction_cap_cents: Cents;
  /** P9 column J — cap on the post-retirement medical fund deduction. */
  prmf_cap_cents: Cents;
  /** Whether SHIF (col. I) and the Affordable Housing Levy (col. H) are deducted before tax. */
  shif_deductible: boolean; housing_levy_deductible: boolean;
  updated_at: IsoDateTime | null; updated_by: string | null;
}

export interface PayrollPostingGroup {
  id: number; code: string; name: string;
  salary_expense_account_id: number; paye_payable_account_id: number; net_pay_payable_account_id: number;
  nssf_employee_payable_account_id: number; nssf_employer_expense_account_id: number; nssf_employer_payable_account_id: number;
  shif_payable_account_id: number;
  housing_levy_employee_payable_account_id: number; housing_levy_employer_expense_account_id: number;
  housing_levy_employer_payable_account_id: number;
  created_at: IsoDateTime | null; created_by: string | null;
}

export interface PayrollPayeBand { id: number; sort_order: number; upper_bound_cents: Cents | null; rate_pct: number }
export interface PayrollNssfTier {
  id: number; tier_no: number; lower_limit_cents: Cents; upper_limit_cents: Cents; employee_rate_pct: number; employer_rate_pct: number;
}

export type PayrollTransactionType = 'INCOME' | 'DEDUCTION' | 'COMPANY_DEDUCTION';
export type PayrollBalanceType = 'NONE' | 'INCREASING' | 'REDUCING';
export type PayrollSpecialType =
  | 'NONE' | 'BASIC_SALARY' | 'HOUSE_ALLOWANCE' | 'TRANSPORT_ALLOWANCE' | 'OVERTIME' | 'ACTING_ALLOWANCE'
  | 'LEAVE_ALLOWANCE' | 'GRATUITY' | 'PENSION' | 'MORTGAGE' | 'INSURANCE' | 'LOAN' | 'SALARY_ARREARS' | 'DIRECTORS_FEE'
  /** Taxable but not paid in cash — P9 columns B and C; kept off the journal and the net pay. */
  | 'NON_CASH_BENEFIT' | 'VALUE_OF_QUARTERS'
  /** Post-retirement medical fund — an allowable deduction, P9 column J. */
  | 'PRMF';

export type PayrollAmountPreference = 'FORMULA' | 'HIGHER' | 'LOWER';

export interface PayrollTransactionCode {
  id: number; code: string; name: string; type: PayrollTransactionType; taxable: boolean;
  /** AL "Is Formula" / Formula: the amount is computed from the employee's period transactions,
   *  e.g. `[BPAY]*0.15`; "Amount Preference" picks between it and the line's own amount. */
  is_formula: boolean; formula: string | null; amount_preference: PayrollAmountPreference;
  /** Employer-side contribution on a deduction (AL "Include Employer Deduction"): a multiple of
   *  the employee's amount (2 = the employer pays double), or a formula that overrides it. */
  employer_factor: number; employer_formula: string | null;
  fixed_amount_cents: Cents; upper_limit_cents: Cents | null;
  balance_type: PayrollBalanceType; special_type: PayrollSpecialType;
  gl_account_id: number | null; employer_gl_account_id: number | null; for_every_employee: boolean;
  status: string; created_at: IsoDateTime | null; created_by: string | null;
}

export type PayrollPeriodStatus = 'OPEN' | 'PENDING_APPROVAL' | 'APPROVED' | 'CLOSED';

export interface PayrollPeriod {
  id: number; period_name: string; start_date: IsoDate; end_date: IsoDate; status: PayrollPeriodStatus;
  decision_reason: string | null; closed_at: IsoDateTime | null; closed_by: string | null;
  created_at: IsoDateTime | null; created_by: string | null;
}

export interface EmployeePayrollTransaction {
  id: number; employee_id: number; transaction_code_id: number; payroll_period_id: number;
  amount_cents: Cents; original_amount_cents: Cents | null; balance_cents: Cents | null;
  no_of_periods: number | null; executed_periods: number; stopped: boolean; temporary: boolean;
  notes: string | null;
  /** AL "Loan Number" — set on rows the run pulled from the Credit module. */
  loan_id: number | null;
  /** The window the line is in force (either side open when null). */
  start_date: IsoDate | null; end_date: IsoDate | null;
  /** The salary-scale notch that conferred this line, when it did. */
  salary_scale_id: number | null;
  created_at: IsoDateTime | null; created_by: string | null;
}
export interface EmployeePayrollTransactionView extends EmployeePayrollTransaction {
  transaction_code_name: string; transaction_type: PayrollTransactionType;
}

/** AL Tab52203619 "Payroll Period Transaction" — one computed line of an employee's payroll for
 *  a period. Basic pay, the tax workings, statutories and net pay carry the run's own codes and
 *  no transaction_code_id; only Earnings & Deductions lines point at a code. */
export interface PayrollPeriodTransaction {
  id: number; payroll_period_id: number; employee_id: number;
  transaction_code: string; transaction_code_id: number | null; transaction_name: string;
  transaction_type: 'INCOME' | 'DEDUCTION' | 'COMPANY_DEDUCTION' | 'MEMO' | 'NET';
  group_text: string; group_order: number; sub_group_order: number; payslip_order: number;
  amount_cents: Cents; balance_cents: Cents | null; original_amount_cents: Cents | null; no_of_units: number | null;
  gl_account_id: number | null; post_as: 'DEBIT' | 'CREDIT' | null; post_to_journal: boolean;
  journal_account_type: 'GL' | 'SAVINGS' | 'CREDIT' | 'EMPLOYEE'; company_deduction: boolean;
  member_id: number | null; loan_id: number | null; imprest_no: string | null;
  posting_group_id: number | null; payment_mode: string | null; salary_scale_id: number | null;
  global_dimension_1_id: number | null; global_dimension_2_id: number | null;
  staff_name: string | null; bank_code: string | null; bank_branch: string | null; bank_account_no: string | null;
  created_at: IsoDateTime | null;
}
export interface PayrollPeriodTransactionView extends PayrollPeriodTransaction {
  employee_no: string; employee_first_name: string; employee_last_name: string;
}

export interface PayrollP9Line {
  id: number; employee_id: number; payroll_period_id: number;
  basic_pay_cents: Cents; gross_pay_cents: Cents; taxable_pay_cents: Cents; tax_charged_cents: Cents;
  insurance_relief_cents: Cents; personal_relief_cents: Cents; paye_cents: Cents; nssf_cents: Cents;
  shif_cents: Cents; housing_levy_cents: Cents; deductions_cents: Cents; net_pay_cents: Cents;
  /** P9 columns B, C, the staff pension inside E2, E (lowest of E1/E2/E3), F and J. */
  benefits_cents: Cents; quarters_cents: Cents; pension_cents: Cents; defined_contribution_cents: Cents;
  owner_occupier_interest_cents: Cents; prmf_cents: Cents;
  created_at: IsoDateTime | null;
}

/* ------------------------------------------------------------------------ Dividends */

export type DividendBook = 'BOSA' | 'FOSA';
export type DividendPostingType = 'Provisioning' | 'Payout';
export type DividendComputationType = 'Automatic' | 'Manual Upload';
/**
 * How a savings product earns its dividend. The AL calls this the Proration Type, and it belongs
 * to the product, not the document — one declaration can carry both models at once.
 *
 *   'Pro Rated'        AL's BOSA model, for Non-Withdrawable Deposits and Share Capital: the
 *                      opening stake earns the full year, each later month earns on its own
 *                      increase weighted by the months remaining.
 *   'Minimum Balance'  AL's FOSA model, the bank passbook rule, for withdrawable accounts:
 *                      each month earns on the lowest balance the account held that month.
 *   'Straight Line'    A flat rate on the closing balance, with no monthly working.
 */
export type DividendRateType = 'Pro Rated' | 'Minimum Balance' | 'Straight Line';
export type DividendPostTo = 'Savings' | 'Same Account' | 'Accrue';
export type DividendStatus = 'Open' | 'Pending Approval' | 'Approved';
/** AL enum 52204027 "Dividend Recovery Types". */
export type DividendRecoveryEntryType =
  | 'CHARGES' | 'INTEREST_PAID' | 'PRINCIPAL_PAID' | 'INTEREST_ARREARS' | 'PRINCIPAL_ARREARS'
  | 'BOOST' | 'PREFERENTIAL_BOOST'
  /* Not in the AL enum: this system's loans carry a penalty balance of their own, and a
     recovery has to say which part of the debt it cleared. */
  | 'PENALTY';

/** AL Table 52204068 "Dividend Header". */
export interface Dividend {
  id: number;
  no: string;
  document_type: DividendBook;
  description: string;
  posting_description: string | null;
  dividend_year: number;
  start_date: IsoDate;
  end_date: IsoDate;
  posting_date: IsoDate;
  posting_type: DividendPostingType;
  computation_type: DividendComputationType;
  transaction_charge_id: number | null;
  expense_account_id: number | null;
  payable_account_id: number | null;
  recover_loans: Flag;
  boost_to_minimum: Flag;
  maximum_boost_amount: Cents;
  preferential_boost: Flag;
  global_dimension_1_id: number | null;
  global_dimension_2_id: number | null;
  status: DividendStatus;
  decision_reason: string | null;
  calculated_at: IsoDateTime | null;
  posted: Flag;
  posted_at: IsoDateTime | null;
  posted_by: string | null;
  journal_id: number | null;
  created_at: IsoDateTime | null;
  created_by: string | null;
}

export interface DividendListRow extends Dividend {
  line_count: number;
  total_earned: Cents;
  total_recoveries: Cents;
  total_net: Cents;
  journal_no: string | null;
}

/** AL Table 52204070 "Dividend Calculation Params". */
export interface DividendParam {
  id: number;
  dividend_id: number;
  product_id: number;
  posting_description: string;
  rate: number;
  rate_type: DividendRateType;
  post_to: DividendPostTo;
  is_share_capital: Flag;
  minimum_balance: Cents;
  qualified_minimum_balance: Cents;
  maximum_boost_amount: Cents;
}

export interface DividendParamView extends DividendParam {
  product_code: string;
  product_name: string;
  calculated_amount: Cents;
  account_balances: Cents;
}

/** AL Table 52204069 "Dividend Lines". */
export interface DividendLine {
  id: number;
  dividend_id: number;
  member_id: number;
  member_no: string;
  member_name: string;
  product_id: number;
  savings_account_id: number;
  account_no: string;
  destination_account_id: number | null;
  posting_description: string | null;
  account_balance: Cents;
  amount_earned: Cents;
  total_recoveries: Cents;
  net_amount: Cents;
  preferential_boost: Flag;
  preferential_boost_pct: number;
  deceased: Flag;
  blocked_account: Flag;
  phone_no: string | null;
  posted: Flag;
}

export interface DividendLineView extends DividendLine {
  product_code: string;
  product_name: string;
  destination_account_no: string | null;
}

/** AL Table 52204073 "Dividend Det. Entries" — the monthly working behind a line. */
export interface DividendDetEntry {
  id: number;
  dividend_id: number;
  dividend_line_id: number;
  member_id: number;
  savings_account_id: number;
  month_no: number;
  year: number;
  month_code: string;
  description: string | null;
  posting_type: DividendRateType;
  rate: number;
  ratio: number;
  min_balance: Cents;
  previous_month_balance: Cents;
  current_month_balance: Cents;
  net_change: Cents;
  minimum_running_balance: Cents;
  amount: Cents;
}

/** AL Table 52204067 "Dividend Recoveries". */
export interface DividendRecovery {
  id: number;
  dividend_id: number;
  dividend_line_id: number;
  member_id: number;
  entry_type: DividendRecoveryEntryType;
  recovery_code: string | null;
  description: string;
  loan_id: number | null;
  target_account_id: number | null;
  charge_id: number | null;
  amount: Cents;
  priority: number;
  posted: Flag;
}

export interface DividendRecoveryView extends DividendRecovery {
  loan_no: string | null;
  target_account_no: string | null;
}

/** AL Table 52204072 "Dividend Withdrawn Members". */
export interface DividendWithdrawnMember {
  id: number;
  dividend_id: number;
  member_id: number;
  member_no: string;
  member_name: string;
  exit_no: string | null;
  maturity_date: IsoDate | null;
}

export interface DividendDetail extends DividendListRow {
  params: DividendParamView[];
  withdrawn: DividendWithdrawnMember[];
}

/* ------------------------------------------------------------------ Company Organogram */

export type CompanyJobStatus = 'Open' | 'Pending Approval' | 'Approved' | 'Retired';
export const JOB_QUALIFICATION_TYPES = ['ACADEMIC', 'PROFESSIONAL', 'EXPERIENCE', 'SKILL', 'MEMBERSHIP', 'OTHER'] as const;
export type JobQualificationType = (typeof JOB_QUALIFICATION_TYPES)[number];
export const JOB_QUALIFICATION_PRIORITIES = ['MANDATORY', 'DESIRABLE', 'ADDED_ADVANTAGE'] as const;
export type JobQualificationPriority = (typeof JOB_QUALIFICATION_PRIORITIES)[number];
export const JOB_COMPETENCY_LEVELS = ['BASIC', 'INTERMEDIATE', 'ADVANCED', 'EXPERT'] as const;
export type JobCompetencyLevel = (typeof JOB_COMPETENCY_LEVELS)[number];
/** AL "Primary / 2nd / 3rd Skills Category". */
export const JOB_SKILLS_CATEGORIES = ['Auditors', 'Consultants', 'Training', 'Certification', 'Administration', 'Marketing', 'Management', 'Business Development', 'Finance', 'ICT', 'Credit', 'Operations', 'Other'] as const;

/** AL Tab52203769 "Company Jobs" — a position in the establishment. */
export interface HrCompanyJob {
  id: number; job_id: string; name: string; objective: string | null;
  reports_to_job_id: number | null; job_grade_id: number | null;
  global_dimension_1_id: number | null; global_dimension_2_id: number | null;
  no_of_posts: number; is_management: boolean; profession: string | null;
  skills_category: string | null; skills_category_2: string | null; skills_category_3: string | null;
  status: CompanyJobStatus; decision_reason: string | null;
  created_at: IsoDateTime | null; created_by: string | null; approved_at: IsoDateTime | null; approved_by: string | null;
}
export interface HrCompanyJobView extends HrCompanyJob {
  reports_to_job_code: string | null; reports_to_job_name: string | null;
  job_grade_code: string | null; job_grade_name: string | null;
  global_dimension_1_name: string | null; global_dimension_2_name: string | null;
  /** AL "Occupied Position" (active employees on the job) and "Vacant Positions" (posts − occupied). */
  occupied: number; vacant: number;
}
export interface HrCompanyJobResponsibility { id: number; job_id: number; line_no: number; description: string }
export interface HrCompanyJobRequirement { id: number; job_id: number; line_no: number; description: string }
export interface HrCompanyJobQualification {
  id: number; job_id: number; qualification_type: JobQualificationType; qualification: string; description: string | null;
  priority: JobQualificationPriority; competency_level: JobCompetencyLevel | null;
}
/** An employee placed on a job, as the organogram shows them. */
export interface CompanyJobHolder {
  id: number; employee_no: string; first_name: string; last_name: string; status: string; photo_image: string | null;
  employment_date: IsoDate | null; manager_id: number | null;
}

/* ------------------------------------------------------------ integration (web services) */

/** Business Central "Web Service" (Tab2000000076): an object published under a Service Name. */
export type WebServiceObjectType = 'PAGE' | 'QUERY' | 'CODEUNIT';
export interface WebService {
  id: number;
  object_type: WebServiceObjectType;
  object_id: number;
  object_name: string;
  service_name: string;
  published: boolean;
  description: string | null;
  created_at: IsoDateTime | null;
  created_by: string | null;
}
/** A user's Web Service Access Key (BC User Card) — hashed at rest, shown once when generated. */
export interface WebServiceAccessKey {
  id: number;
  user_id: number;
  key_hash: string;
  key_hint: string;
  expires_at: IsoDateTime | null;
  created_at: IsoDateTime;
  created_by: string | null;
  last_used_at: IsoDateTime | null;
  revoked_at: IsoDateTime | null;
}
export interface WebServiceAccessKeyView extends WebServiceAccessKey {
  username: string; full_name: string; user_status: string;
}
export interface WebServiceLogEntry {
  id: number;
  at: IsoDateTime;
  protocol: 'ODATA' | 'SOAP';
  method: string;
  service_name: string | null;
  operation: string | null;
  path: string;
  username: string | null;
  status: number;
  duration_ms: number;
  ip: string | null;
  error: string | null;
}
