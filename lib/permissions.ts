/*
 * Business Central-style Permission Sets.
 *
 * A role's access is a set of lines, each granting rights on one Object:
 * a database Table (Read/Insert/Modify/Delete) or an application Page (an
 * Execute right — can this screen be reached at all). Business verbs like
 * "disburse a loan" aren't single-table CRUD (disburseLoan() posts a journal,
 * rewrites the repayment schedule, and moves two balances in one
 * transaction) so a literal 1:1 swap of "permission string" for "table
 * right" can't express them. ACTIONS below is the bridge: one named grant of
 * (owning page, table rights[]) per business operation, built directly from
 * an inventory of what each of the app's server actions actually reads and
 * writes. A call site asks for one action (`requireAction('LOAN_DISBURSE')`)
 * and both the page Execute right and every table right it lists are
 * checked together — but the *admin-configurable unit*, in the Permission
 * Set editor, is genuinely the table and the page, not this registry.
 */
import { all } from './db.ts';
import type { SessionUser } from './types.ts';

export type ObjectType = 'TABLE' | 'PAGE';
export type Right = 'read' | 'insert' | 'modify' | 'delete';

const humanize = (identifier: string): string => identifier
  .replace(/_/g, ' ')
  .replace(/\b\w/g, (c) => c.toUpperCase());

/** Tables that must never appear in the Permission Set line dropdown: pure
 *  auth/session plumbing, and the permission engine's own storage (granting
 *  raw RIMD on permission_set_line would be a privilege-escalation hole). */
const EXCLUDED_TABLES = new Set(['session', 'permission_set_line']);

/** The live set of tables a Permission Set line may target — same
 *  information_schema introspection as lib/configPackages.ts's
 *  listConfigPackageTables(), so a new Prisma model appears here with no
 *  catalogue edit. */
export async function listPermissionTables(): Promise<{ name: string; label: string }[]> {
  const rows = await all<{ table_name: string }>(
    "SELECT table_name FROM information_schema.tables WHERE table_schema = 'public' AND table_type = 'BASE TABLE' ORDER BY table_name",
  );
  return rows
    .filter((r) => !EXCLUDED_TABLES.has(r.table_name) && !r.table_name.startsWith('_'))
    .map((r) => ({ name: r.table_name, label: humanize(r.table_name) }));
}

/** Pages are compiled routes, not database rows, so — unlike tables — this
 *  catalogue is maintained by hand: the BC equivalent of compiled Page
 *  objects. `/approvals` previously had no permission gate at all; giving it
 *  its own page closes that gap. */
export const PAGES: { code: string; label: string; route: string }[] = [
  { code: 'DASHBOARD', label: 'Dashboard', route: '/dashboard' },
  { code: 'APPROVALS', label: 'Approvals', route: '/approvals' },
  { code: 'SAVINGS', label: 'Savings & FOSA', route: '/savings' },
  { code: 'LOANS', label: 'Loans', route: '/loans' },
  { code: 'LOAN_CALCULATOR', label: 'Loan Calculator', route: '/loan-calculator' },
  { code: 'MEMBER_APPLICATIONS', label: 'Member Application', route: '/member-applications' },
  { code: 'MEMBERS', label: 'Members', route: '/members' },
  { code: 'MEMBER_STATEMENTS', label: 'Member Statement', route: '/member-statements' },
  { code: 'MEMBER_EDITS', label: 'Member Editing', route: '/member-edits' },
  { code: 'MEMBER_EXITS', label: 'Member Exit', route: '/member-exits' },
  { code: 'CHECKOFF_BATCHES', label: 'Checkoff & Salary Processing', route: '/checkoff-batches' },
  { code: 'FIXED_DEPOSITS', label: 'Fixed Deposits', route: '/fixed-deposits' },
  { code: 'ACCOUNT_OPENING', label: 'Account Opening', route: '/account-openings' },
  { code: 'ACCOUNT_DEACTIVATION', label: 'Account Deactivation', route: '/account-deactivations' },
  { code: 'ACCOUNT_ACTIVATION', label: 'Account Activation', route: '/account-activations' },
  { code: 'MEMBER_ACTIVATIONS', label: 'Member Activation', route: '/member-activations' },
  { code: 'STANDING_ORDERS', label: 'Standing Orders', route: '/standing-orders' },
  { code: 'MEMBER_CHARGING', label: 'Member Charging', route: '/member-chargings' },
  { code: 'ENTRANCE_FEE_RECOVERY', label: 'Entrance Fee Recovery', route: '/entrance-fee-recovery' },
  { code: 'MEMBER_STATUS_UPDATE', label: 'Member Status Update', route: '/member-status-update' },
  { code: 'COLLATERAL_APPLICATIONS', label: 'Collateral Applications', route: '/collateral-applications' },
  { code: 'COLLATERAL_REGISTER', label: 'Collateral Register', route: '/collateral-register' },
  { code: 'COLLATERAL_RELEASES', label: 'Collateral Releases', route: '/collateral-releases' },
  { code: 'GUARANTOR_CHANGES', label: 'Guarantor Changes', route: '/guarantor-changes' },
  { code: 'GL', label: 'General Ledger', route: '/accounting' },
  { code: 'REPORTS', label: 'Reports', route: '/reports' },
  { code: 'ADMIN_COMPANY', label: 'Company Information', route: '/admin/company' },
  { code: 'ADMIN_APPEARANCE', label: 'Appearance & Theme', route: '/admin/appearance' },
  { code: 'ADMIN_PRODUCTS_SAVINGS', label: 'Savings Products', route: '/admin/products/savings' },
  { code: 'ADMIN_PRODUCTS_LOANS', label: 'Loan Products', route: '/admin/products/loans' },
  { code: 'ADMIN_PRODUCTS_COLLATERAL', label: 'Collateral Types', route: '/admin/products/collateral' },
  { code: 'ADMIN_PRODUCTS_SALARY_PARAMS', label: 'Salary Appraisal Parameters', route: '/admin/products/salary' },
  { code: 'ADMIN_PRODUCTS_EMPLOYERS', label: 'Employers', route: '/admin/products/employers' },
  { code: 'ADMIN_PRODUCTS_FD', label: 'Fixed Deposit Types', route: '/admin/products/fixed-deposit-types' },
  { code: 'ADMIN_CHARGES_MASTER', label: 'Charge Codes', route: '/admin/charges/master' },
  { code: 'ADMIN_CHARGES_TRANSACTION', label: 'Transaction Charges', route: '/admin/charges/transaction' },
  { code: 'ADMIN_POOL_CATEGORIES', label: 'Member Categories', route: '/admin/pool/categories' },
  { code: 'ADMIN_POOL_COUNTIES', label: 'Counties', route: '/admin/pool/counties' },
  { code: 'ADMIN_POOL_DIMENSIONS', label: 'Dimensions', route: '/admin/pool/dimensions' },
  { code: 'ADMIN_WORKFLOWS_DEFINITIONS', label: 'Workflows', route: '/admin/workflows/definitions' },
  { code: 'ADMIN_WORKFLOWS_GROUPS', label: 'Approval User Groups', route: '/admin/workflows/groups' },
  { code: 'ADMIN_WORKFLOWS_TABLES', label: 'Table Relations', route: '/admin/workflows/tables' },
  { code: 'ADMIN_USERS', label: 'Users', route: '/admin/security/users' },
  { code: 'ADMIN_WORKFLOWS_SETUP', label: 'User Setup', route: '/admin/security/setup' },
  { code: 'ADMIN_ROLES', label: 'Permission Sets', route: '/admin/security/roles' },
  { code: 'ADMIN_AUDIT', label: 'Audit Trail', route: '/admin/security/audit' },
  { code: 'ADMIN_CHANGELOG', label: 'Change Log Management', route: '/admin/security/changelog' },
  { code: 'ADMIN_DATA', label: 'Data Management', route: '/admin/data' },
  { code: 'ADMIN_JOB_QUEUE', label: 'System Automation', route: '/admin/automation' },
];

export interface ActionGrant {
  page: string;
  tables: [table: string, right: Right][];
}

/**
 * One entry per surviving business operation from the old resource:action
 * catalogue. Where a single old permission string served more than one
 * physically distinct screen (MEMBER:READ gated Members, Member Application
 * *and* Member Editing alike), it is split per page here — otherwise a
 * role granted access to one of those screens would silently reach all
 * three, which defeats the point of per-page Execute rights.
 *
 * Two known bugs in the old catalogue are fixed as a side effect, not
 * carried forward: `ADMIN:CHANGE_LOG_MANAGE` was checked at 4 call sites but
 * never actually granted by any literal permission (only by the `*`
 * wildcard) — ADMIN_CHANGE_LOG_MANAGE below is real. `LOAN:WRITE_OFF` and
 * `REPORT:EXPORT` were declared and seeded but never checked anywhere —
 * dropped, nothing maps to them.
 */
export const ACTIONS = {
  // Members
  MEMBERS_READ: { page: 'MEMBERS', tables: [['member', 'read']] },
  MEMBERS_UPDATE: {
    page: 'MEMBERS',
    tables: [
      ['member', 'modify'], ['attachment', 'insert'], ['attachment', 'delete'],
      ['member_next_of_kin', 'insert'], ['member_next_of_kin', 'delete'],
      ['member_nominee', 'insert'], ['member_nominee', 'delete'],
    ],
  },
  // Member Statement — read-only, multi-filter statement of account and loan activity, drawn
  // straight from the member/savings/loan tables plus the shared txn ledger they already grant
  // MEMBERS_READ/SAVINGS_READ/LOAN_READ on individually; this action bundles read of all four
  // behind the statement's own page so a role can be given the printout without also being
  // given the underlying Members/Savings/Loans screens.
  MEMBER_STATEMENTS_READ: {
    page: 'MEMBER_STATEMENTS',
    tables: [['member', 'read'], ['savings_account', 'read'], ['loan', 'read'], ['txn', 'read']],
  },
  // Member Application
  MEMBER_APPLICATIONS_READ: { page: 'MEMBER_APPLICATIONS', tables: [['member_application', 'read']] },
  MEMBER_APPLICATIONS_CREATE: {
    page: 'MEMBER_APPLICATIONS',
    tables: [['member_application', 'insert'], ['member_application', 'modify'], ['workflow_task', 'insert'], ['workflow_task', 'modify']],
  },
  MEMBER_APPLICATIONS_UPDATE: {
    page: 'MEMBER_APPLICATIONS',
    tables: [
      ['member_application', 'modify'],
      ['member_application_next_of_kin', 'insert'], ['member_application_next_of_kin', 'delete'],
      ['member_application_nominee', 'insert'], ['member_application_nominee', 'delete'],
      ['member_application_signatory', 'insert'], ['member_application_signatory', 'delete'],
      ['member_application_attachment', 'insert'], ['member_application_attachment', 'delete'],
    ],
  },
  MEMBER_APPLICATIONS_APPROVE: {
    page: 'MEMBER_APPLICATIONS',
    tables: [
      ['member_application', 'modify'], ['member', 'insert'], ['member_next_of_kin', 'insert'],
      ['member_nominee', 'insert'], ['member_signatory', 'insert'], ['attachment', 'insert'],
    ],
  },
  // Member Editing
  MEMBER_EDITS_READ: { page: 'MEMBER_EDITS', tables: [['member_edit_request', 'read']] },
  MEMBER_EDITS_UPDATE: {
    page: 'MEMBER_EDITS',
    tables: [
      ['member_edit_request', 'insert'], ['member_edit_request', 'modify'],
      ['member_edit_next_of_kin', 'insert'], ['member_edit_next_of_kin', 'delete'],
      ['member_edit_nominee', 'insert'], ['member_edit_nominee', 'delete'],
      ['member_edit_signatory', 'insert'], ['member_edit_signatory', 'delete'],
      ['member_edit_attachment', 'insert'], ['member_edit_attachment', 'delete'],
    ],
  },
  MEMBER_EDITS_APPROVE: { page: 'MEMBER_EDITS', tables: [['member_edit_request', 'modify'], ['member', 'modify']] },

  // Member Exit — terminates a membership: settles every asset/liability/guarantee, pays out the
  // difference and closes the member's accounts (see lib/memberExits.ts's processMemberExit()).
  // APPROVE actually moves money — journal/loan/savings/member rights, same shape LOAN_DISBURSE
  // and COLLATERAL_RELEASES_APPROVE already carry for their own posting steps.
  MEMBER_EXITS_READ: { page: 'MEMBER_EXITS', tables: [['member_exit', 'read']] },
  MEMBER_EXITS_CREATE: {
    page: 'MEMBER_EXITS',
    tables: [
      ['member_exit', 'insert'], ['member_exit', 'modify'], ['member_exit_line', 'insert'], ['member_exit_line', 'delete'],
      ['workflow_task', 'insert'], ['workflow_task', 'modify'],
    ],
  },
  MEMBER_EXITS_APPROVE: {
    page: 'MEMBER_EXITS',
    tables: [
      ['member_exit', 'modify'], ['member', 'modify'], ['savings_account', 'modify'],
      ['loan', 'modify'], ['loan_schedule', 'modify'], ['journal', 'insert'], ['journal_line', 'insert'], ['txn', 'insert'],
    ],
  },

  // Checkoff and Salary Processing — an employer-scoped batch that reconciles what was actually
  // remitted against expected loan-installment recoveries (CHECKOFF) or simply credits salary
  // (SALARY). APPROVE actually moves money — journal/loan/savings rights, same shape
  // MEMBER_EXITS_APPROVE above already carries for its own posting step.
  CHECKOFF_BATCHES_READ: { page: 'CHECKOFF_BATCHES', tables: [['checkoff_batch', 'read']] },
  CHECKOFF_BATCHES_CREATE: {
    page: 'CHECKOFF_BATCHES',
    tables: [
      ['checkoff_batch', 'insert'], ['checkoff_batch', 'modify'], ['checkoff_batch_line', 'insert'], ['checkoff_batch_line', 'modify'],
      ['checkoff_calculation', 'insert'], ['checkoff_calculation', 'delete'],
      ['workflow_task', 'insert'], ['workflow_task', 'modify'],
    ],
  },
  CHECKOFF_BATCHES_APPROVE: {
    page: 'CHECKOFF_BATCHES',
    tables: [
      ['checkoff_batch', 'modify'], ['loan', 'modify'], ['loan_schedule', 'modify'], ['savings_account', 'modify'],
      ['journal', 'insert'], ['journal_line', 'insert'], ['txn', 'insert'],
    ],
  },

  // Member Fixed Deposit — a term deposit funded from and paid back to a member's own savings.
  // APPROVE also carries the full lifecycle beyond the maker-checker decision itself (activate,
  // accrue interest, mature, terminate) since every one of those steps moves real money —
  // journal/savings_account/schedule rights, same shape MEMBER_EXITS_APPROVE carries above.
  FIXED_DEPOSITS_READ: { page: 'FIXED_DEPOSITS', tables: [['member_fixed_deposit', 'read']] },
  FIXED_DEPOSITS_CREATE: {
    page: 'FIXED_DEPOSITS',
    tables: [
      ['member_fixed_deposit', 'insert'], ['member_fixed_deposit', 'modify'],
      ['workflow_task', 'insert'], ['workflow_task', 'modify'],
    ],
  },
  FIXED_DEPOSITS_APPROVE: {
    page: 'FIXED_DEPOSITS',
    tables: [
      ['member_fixed_deposit', 'modify'], ['member_fixed_deposit_schedule', 'insert'], ['member_fixed_deposit_schedule', 'modify'],
      ['savings_account', 'insert'], ['savings_account', 'modify'],
      ['journal', 'insert'], ['journal_line', 'insert'], ['txn', 'insert'],
    ],
  },

  // Account Opening — additional savings accounts, not a member category's default account
  // (those are provisioned automatically; see pool.getDefaultAccountsBacklog()). Always opens
  // at a zero balance — no deposit, so no journal/txn rights are needed; funding the account
  // afterwards is a separate SAVINGS_DEPOSIT grant.
  ACCOUNT_OPENING_READ: { page: 'ACCOUNT_OPENING', tables: [['account_opening_request', 'read']] },
  ACCOUNT_OPENING_CREATE: {
    page: 'ACCOUNT_OPENING',
    tables: [['account_opening_request', 'insert'], ['account_opening_request', 'modify'], ['workflow_task', 'insert'], ['workflow_task', 'modify']],
  },
  ACCOUNT_OPENING_APPROVE: {
    page: 'ACCOUNT_OPENING',
    tables: [['account_opening_request', 'modify'], ['savings_account', 'insert']],
  },

  // Account Deactivation — deactivates an existing non-default savings account (the member's
  // category default accounts are excluded; see lib/accountDeactivation.ts's
  // eligibleAccountsForMember()). Processing only flips the account's status to INACTIVE, no
  // balance movement, so no journal/txn rights are needed.
  ACCOUNT_DEACTIVATION_READ: { page: 'ACCOUNT_DEACTIVATION', tables: [['account_deactivation_request', 'read']] },
  ACCOUNT_DEACTIVATION_CREATE: {
    page: 'ACCOUNT_DEACTIVATION',
    tables: [['account_deactivation_request', 'insert'], ['account_deactivation_request', 'modify'], ['workflow_task', 'insert'], ['workflow_task', 'modify']],
  },
  ACCOUNT_DEACTIVATION_APPROVE: {
    page: 'ACCOUNT_DEACTIVATION',
    tables: [['account_deactivation_request', 'modify'], ['savings_account', 'modify']],
  },

  // Account Activation — reactivates an INACTIVE savings account (only ever an account this
  // module itself, or a prior manual freeze, put in that state; see
  // lib/accountActivation.ts's eligibleAccountsForMember()). Processing flips the account's
  // status back to ACTIVE and, when a reactivation fee is configured (Admin Centre → Charges),
  // posts and debits it — hence the journal/txn rights alongside savings_account.
  ACCOUNT_ACTIVATION_READ: { page: 'ACCOUNT_ACTIVATION', tables: [['account_activation_request', 'read']] },
  ACCOUNT_ACTIVATION_CREATE: {
    page: 'ACCOUNT_ACTIVATION',
    tables: [['account_activation_request', 'insert'], ['account_activation_request', 'modify'], ['workflow_task', 'insert'], ['workflow_task', 'modify']],
  },
  ACCOUNT_ACTIVATION_APPROVE: {
    page: 'ACCOUNT_ACTIVATION',
    tables: [
      ['account_activation_request', 'modify'], ['savings_account', 'modify'],
      ['journal', 'insert'], ['journal_line', 'insert'], ['txn', 'insert'],
    ],
  },

  // Member Activation — reactivates a Dormant member (see lib/memberActivation.ts): flips their
  // status back to Active, reactivates every one of their own INACTIVE accounts, and — when a
  // reactivation fee is configured — posts it either to the teller cash account or debited from
  // one of their own accounts. Same shape as ACCOUNT_ACTIVATION above, one level up (member
  // rather than a single account).
  MEMBER_ACTIVATIONS_READ: { page: 'MEMBER_ACTIVATIONS', tables: [['member_activation_request', 'read']] },
  MEMBER_ACTIVATIONS_CREATE: {
    page: 'MEMBER_ACTIVATIONS',
    tables: [['member_activation_request', 'insert'], ['member_activation_request', 'modify'], ['workflow_task', 'insert'], ['workflow_task', 'modify']],
  },
  MEMBER_ACTIVATIONS_APPROVE: {
    page: 'MEMBER_ACTIVATIONS',
    tables: [
      ['member_activation_request', 'modify'], ['member', 'modify'], ['savings_account', 'modify'],
      ['journal', 'insert'], ['journal_line', 'insert'], ['txn', 'insert'],
    ],
  },

  // Standing Order — a recurring instruction (transfer or loan repayment) that runs itself once
  // Approved (see lib/standingOrders.ts). APPROVE also covers Terminate/Freeze/Unfreeze — the
  // same ongoing-lifecycle tier as approval, not a separate maker-checker step — since none of
  // them move money themselves (only the automated/manual run does, gated by its own _RUN
  // action). No money moves at approval time either, hence no ledger table rights here.
  STANDING_ORDERS_READ: { page: 'STANDING_ORDERS', tables: [['standing_order', 'read']] },
  STANDING_ORDERS_CREATE: {
    page: 'STANDING_ORDERS',
    tables: [['standing_order', 'insert'], ['standing_order', 'modify'], ['workflow_task', 'insert'], ['workflow_task', 'modify']],
  },
  STANDING_ORDERS_APPROVE: { page: 'STANDING_ORDERS', tables: [['standing_order', 'modify']] },
  STANDING_ORDERS_RUN: {
    page: 'STANDING_ORDERS',
    tables: [
      ['standing_order', 'modify'], ['savings_account', 'modify'], ['loan', 'modify'], ['loan_schedule', 'modify'],
      ['journal', 'insert'], ['journal_line', 'insert'], ['txn', 'insert'],
    ],
  },

  // Member Charging — an ad-hoc charge posted straight against a member's own withdrawable
  // deposit account (see lib/memberCharging.ts). No approval workflow: whoever creates the
  // document also posts it, so — unlike Account Opening/Deactivation/Activation above — there
  // is no separate _APPROVE action, just _CREATE (draft it) and _POST (post it); a role that
  // should let its holder do the whole thing end to end (the norm here) is simply granted both.
  MEMBER_CHARGING_READ: { page: 'MEMBER_CHARGING', tables: [['member_charging', 'read']] },
  MEMBER_CHARGING_CREATE: {
    page: 'MEMBER_CHARGING',
    tables: [['member_charging', 'insert'], ['member_charging', 'modify'], ['member_charging', 'delete']],
  },
  MEMBER_CHARGING_POST: {
    page: 'MEMBER_CHARGING',
    tables: [
      ['member_charging', 'modify'], ['savings_account', 'modify'],
      ['journal', 'insert'], ['journal_line', 'insert'], ['txn', 'insert'],
    ],
  },

  // Entrance Fee Recovery — batch sweep that recovers a Not Paid Up member's outstanding
  // registration fee (Admin Centre → Member Categories' own Registration Fee/Account) from
  // their Non-Withdrawable Deposit account, capped by what's actually available; once the fee
  // is fully recovered the member flips from Not Paid Up to Active. Ported from the source
  // documentation's "Entrance Fee Recovery" report (Rep 52204049). No maker-checker document —
  // whoever can run it also posts it, the same shape MEMBER_CHARGING above uses.
  ENTRANCE_FEE_RECOVERY_READ: {
    page: 'ENTRANCE_FEE_RECOVERY',
    tables: [['member', 'read'], ['member_category', 'read'], ['savings_account', 'read']],
  },
  ENTRANCE_FEE_RECOVERY_RUN: {
    page: 'ENTRANCE_FEE_RECOVERY',
    tables: [
      ['member', 'modify'], ['savings_account', 'modify'],
      ['journal', 'insert'], ['journal_line', 'insert'], ['txn', 'insert'],
    ],
  },

  // Member Status Update — the Active <-> Dormant sweep and its reactivation charge (see
  // lib/memberStatusUpdate.ts). Same shape as ENTRANCE_FEE_RECOVERY above.
  MEMBER_STATUS_UPDATE_READ: {
    page: 'MEMBER_STATUS_UPDATE',
    tables: [['member', 'read'], ['savings_account', 'read']],
  },
  MEMBER_STATUS_UPDATE_RUN: {
    page: 'MEMBER_STATUS_UPDATE',
    tables: [
      ['member', 'modify'], ['savings_account', 'modify'],
      ['journal', 'insert'], ['journal_line', 'insert'], ['txn', 'insert'],
    ],
  },

  // Savings & FOSA
  SAVINGS_READ: { page: 'SAVINGS', tables: [['savings_account', 'read']] },
  SAVINGS_DEPOSIT: { page: 'SAVINGS', tables: [['journal', 'insert'], ['journal_line', 'insert'], ['savings_account', 'modify'], ['txn', 'insert']] },
  SAVINGS_WITHDRAW: { page: 'SAVINGS', tables: [['journal', 'insert'], ['journal_line', 'insert'], ['savings_account', 'modify'], ['txn', 'insert']] },
  SAVINGS_REVERSE: { page: 'SAVINGS', tables: [['journal', 'insert'], ['savings_account', 'modify'], ['txn', 'insert'], ['txn', 'modify']] },

  // Loans
  LOAN_READ: { page: 'LOANS', tables: [['loan', 'read']] },
  LOAN_CREATE: {
    page: 'LOANS',
    tables: [
      ['loan', 'insert'], ['loan_guarantor', 'insert'], ['loan_guarantor', 'delete'],
      ['loan_collateral', 'insert'], ['loan_collateral', 'delete'],
      ['loan_appraisal', 'insert'], ['loan_appraisal_factor', 'insert'],
      ['workflow_task', 'insert'], ['attachment', 'insert'], ['attachment', 'delete'],
    ],
  },
  LOAN_APPROVE: { page: 'LOANS', tables: [['loan', 'modify']] },
  LOAN_DISBURSE: {
    page: 'LOANS',
    tables: [
      ['journal', 'insert'], ['journal_line', 'insert'], ['loan_schedule', 'insert'], ['loan_schedule', 'delete'],
      ['loan', 'modify'], ['savings_account', 'modify'], ['txn', 'insert'],
      // recovery_mode = STANDING_ORDER auto-creates and activates its own recovery standing
      // order right here — see lib/standingOrders.ts's createRecoveryStandingOrderForLoan().
      ['standing_order', 'insert'], ['standing_order', 'modify'],
    ],
  },
  LOAN_REPAY: {
    page: 'LOANS',
    tables: [['journal', 'insert'], ['journal_line', 'insert'], ['loan_schedule', 'modify'], ['loan', 'modify'], ['savings_account', 'modify'], ['txn', 'insert']],
  },

  // Loan Calculator — a what-if repayment quote against a member/product/principal/term, saved
  // as its own immutable record (like loan_appraisal) rather than a real application. No
  // approval workflow and no posting: creating a run and reading it back is the whole lifecycle,
  // plus letting its own creator delete a run they no longer need.
  LOAN_CALCULATOR_READ: { page: 'LOAN_CALCULATOR', tables: [['loan_calculator', 'read']] },
  LOAN_CALCULATOR_CREATE: { page: 'LOAN_CALCULATOR', tables: [['loan_calculator', 'insert']] },
  LOAN_CALCULATOR_DELETE: { page: 'LOAN_CALCULATOR', tables: [['loan_calculator', 'delete']] },
  // Converts an Open calculation into a real loan application via lib/loanService.ts's own
  // apply() — grants exactly what that call writes (a new loan row, no guarantors from here)
  // plus modify on loan_calculator itself, to flip it to Converted and link the new loan.
  LOAN_CALCULATOR_CONVERT: { page: 'LOAN_CALCULATOR', tables: [['loan_calculator', 'modify'], ['loan', 'insert']] },

  // Collateral — a member pledges a titled asset (vehicle, land, building) as security,
  // alongside or instead of guarantors — see loan_collateral, the join a loan officer uses
  // to attach an accepted register item as a loan's security (granted through LOAN_CREATE
  // above, not here). Applications and Releases are maker-checker documents through the
  // shared workflow engine, same shape as Account Opening; the Register is the read-only
  // accepted-asset ledger, written only by processing an application or a release, so it
  // carries no _CREATE/_APPROVE action of its own.
  COLLATERAL_APPLICATIONS_READ: { page: 'COLLATERAL_APPLICATIONS', tables: [['collateral_application', 'read']] },
  COLLATERAL_APPLICATIONS_CREATE: {
    page: 'COLLATERAL_APPLICATIONS',
    tables: [
      ['collateral_application', 'insert'], ['collateral_application', 'modify'],
      ['collateral_application_attachment', 'insert'], ['collateral_application_attachment', 'delete'],
      ['workflow_task', 'insert'], ['workflow_task', 'modify'],
    ],
  },
  COLLATERAL_APPLICATIONS_APPROVE: {
    page: 'COLLATERAL_APPLICATIONS',
    tables: [['collateral_application', 'modify'], ['collateral_register', 'insert'], ['collateral_register', 'modify']],
  },
  COLLATERAL_REGISTER_READ: { page: 'COLLATERAL_REGISTER', tables: [['collateral_register', 'read']] },
  COLLATERAL_RELEASES_READ: { page: 'COLLATERAL_RELEASES', tables: [['collateral_release', 'read']] },
  COLLATERAL_RELEASES_CREATE: {
    page: 'COLLATERAL_RELEASES',
    tables: [['collateral_release', 'insert'], ['collateral_release', 'modify'], ['workflow_task', 'insert'], ['workflow_task', 'modify']],
  },
  COLLATERAL_RELEASES_APPROVE: {
    page: 'COLLATERAL_RELEASES',
    tables: [['collateral_release', 'modify'], ['collateral_register', 'modify']],
  },

  // Guarantor Change Management — releases and/or substitutes guarantors on an already-disbursed
  // loan (loan_guarantor is otherwise frozen once DISBURSED — see commitGuarantor/releaseGuarantor
  // in lib/loanService.ts, which only work while a loan is still OPEN). Same maker-checker shape
  // as Collateral Releases above.
  GUARANTOR_CHANGES_READ: { page: 'GUARANTOR_CHANGES', tables: [['loan_guarantor_change', 'read']] },
  GUARANTOR_CHANGES_CREATE: {
    page: 'GUARANTOR_CHANGES',
    tables: [
      ['loan_guarantor_change', 'insert'], ['loan_guarantor_change', 'modify'],
      ['workflow_task', 'insert'], ['workflow_task', 'modify'],
    ],
  },
  GUARANTOR_CHANGES_APPROVE: {
    page: 'GUARANTOR_CHANGES',
    tables: [['loan_guarantor_change', 'modify'], ['loan_guarantor', 'modify'], ['loan_guarantor', 'insert']],
  },

  // General Ledger
  GL_READ: { page: 'GL', tables: [['journal', 'read'], ['journal_line', 'read'], ['gl_account', 'read']] },
  GL_JOURNAL_CREATE: { page: 'GL', tables: [['journal', 'insert'], ['journal_line', 'insert'], ['workflow_task', 'insert']] },
  GL_JOURNAL_APPROVE: { page: 'GL', tables: [['journal', 'insert'], ['journal_line', 'insert']] },
  GL_JOURNAL_REVERSE: { page: 'GL', tables: [['journal', 'insert'], ['journal', 'modify'], ['journal_line', 'insert']] },
  GL_PERIOD_CLOSE: { page: 'GL', tables: [['accounting_period', 'modify']] },
  GL_ACCOUNT_MANAGE: { page: 'GL', tables: [['gl_account', 'insert'], ['gl_account', 'modify'], ['change_log_entry', 'insert']] },
  GL_BANK_RECONCILE: {
    page: 'GL',
    tables: [['bank_reconciliation', 'insert'], ['bank_reconciliation', 'modify'], ['bank_account_ledger_entry', 'modify']],
  },

  // Reporting — pure aggregation, execute-only (see file header).
  DASHBOARD_VIEW: { page: 'DASHBOARD', tables: [] },
  REPORTS_VIEW: { page: 'REPORTS', tables: [] },
  APPROVALS_VIEW: { page: 'APPROVALS', tables: [] },

  // Admin Centre
  ADMIN_ORG_MANAGE: { page: 'ADMIN_COMPANY', tables: [['organisation', 'modify']] },
  ADMIN_THEME_MANAGE: { page: 'ADMIN_APPEARANCE', tables: [['theme', 'modify']] },
  ADMIN_USER_MANAGE: { page: 'ADMIN_USERS', tables: [['app_user', 'insert'], ['app_user', 'modify']] },
  ADMIN_ROLE_MANAGE: { page: 'ADMIN_ROLES', tables: [['role', 'insert'], ['role', 'modify']] },
  ADMIN_PRODUCTS_SAVINGS_MANAGE: { page: 'ADMIN_PRODUCTS_SAVINGS', tables: [['savings_product', 'insert'], ['savings_product', 'modify']] },
  ADMIN_PRODUCTS_LOANS_MANAGE: {
    page: 'ADMIN_PRODUCTS_LOANS',
    tables: [
      ['loan_product', 'insert'], ['loan_product', 'modify'],
      ['loan_product_charge', 'insert'], ['loan_product_charge', 'modify'], ['loan_product_charge', 'delete'],
      ['loan_product_charge_scheme', 'insert'], ['loan_product_charge_scheme', 'modify'], ['loan_product_charge_scheme', 'delete'],
    ],
  },
  ADMIN_PRODUCTS_COLLATERAL_MANAGE: { page: 'ADMIN_PRODUCTS_COLLATERAL', tables: [['collateral_type', 'insert'], ['collateral_type', 'modify']] },
  ADMIN_PRODUCTS_SALARY_PARAMS_MANAGE: {
    page: 'ADMIN_PRODUCTS_SALARY_PARAMS',
    tables: [['salary_appraisal_parameter', 'insert'], ['salary_appraisal_parameter', 'modify']],
  },
  EMPLOYERS_MANAGE: { page: 'ADMIN_PRODUCTS_EMPLOYERS', tables: [['employer', 'insert'], ['employer', 'modify']] },
  ADMIN_PRODUCTS_FD_MANAGE: { page: 'ADMIN_PRODUCTS_FD', tables: [['member_fixed_deposit_type', 'insert'], ['member_fixed_deposit_type', 'modify']] },
  ADMIN_CHARGES_MASTER_MANAGE: { page: 'ADMIN_CHARGES_MASTER', tables: [['charge', 'insert'], ['charge', 'modify']] },
  ADMIN_CHARGES_TRANSACTION_MANAGE: {
    page: 'ADMIN_CHARGES_TRANSACTION',
    tables: [
      ['transaction_charge', 'insert'], ['transaction_charge', 'modify'],
      ['transaction_charge_setup', 'insert'], ['transaction_charge_setup', 'modify'], ['transaction_charge_setup', 'delete'],
      ['transaction_calc_scheme', 'insert'], ['transaction_calc_scheme', 'modify'], ['transaction_calc_scheme', 'delete'],
      ['transaction_recovery', 'insert'], ['transaction_recovery', 'delete'],
    ],
  },
  ADMIN_POOL_CATEGORIES_MANAGE: {
    page: 'ADMIN_POOL_CATEGORIES',
    tables: [['member_category', 'insert'], ['member_category', 'modify'], ['member_category_default_account', 'insert'], ['member_category_default_account', 'delete']],
  },
  ADMIN_POOL_COUNTIES_MANAGE: { page: 'ADMIN_POOL_COUNTIES', tables: [['county', 'insert'], ['county', 'modify'], ['sub_county', 'insert'], ['sub_county', 'delete']] },
  ADMIN_POOL_DIMENSIONS_MANAGE: {
    page: 'ADMIN_POOL_DIMENSIONS',
    tables: [['global_dimension_1_value', 'insert'], ['global_dimension_1_value', 'modify'], ['global_dimension_2_value', 'insert'], ['global_dimension_2_value', 'modify'], ['organisation', 'modify']],
  },
  ADMIN_WORKFLOWS_DEFINITIONS_MANAGE: {
    page: 'ADMIN_WORKFLOWS_DEFINITIONS',
    tables: [['workflow', 'insert'], ['workflow', 'modify'], ['workflow_condition', 'insert'], ['workflow_condition', 'delete'], ['workflow_step', 'insert'], ['workflow_step', 'delete']],
  },
  ADMIN_WORKFLOWS_GROUPS_MANAGE: {
    page: 'ADMIN_WORKFLOWS_GROUPS',
    tables: [['workflow_user_group', 'insert'], ['workflow_user_group', 'modify'], ['workflow_user_group_member', 'insert'], ['workflow_user_group_member', 'delete']],
  },
  ADMIN_WORKFLOWS_SETUP_MANAGE: { page: 'ADMIN_WORKFLOWS_SETUP', tables: [['approval_user_setup', 'insert'], ['approval_user_setup', 'modify']] },
  ADMIN_WORKFLOWS_TABLES_MANAGE: {
    page: 'ADMIN_WORKFLOWS_TABLES',
    tables: [['workflow_table_relation', 'insert'], ['workflow_table_relation_field', 'insert'], ['workflow_table_relation_field', 'delete']],
  },
  ADMIN_CONFIG_PACKAGE_MANAGE: {
    page: 'ADMIN_DATA',
    tables: [['config_package', 'insert'], ['config_package', 'modify'], ['config_package', 'delete'], ['config_package_field', 'insert'], ['config_package_field', 'delete']],
  },
  ADMIN_CHANGE_LOG_MANAGE: {
    page: 'ADMIN_CHANGELOG',
    tables: [['change_log_setup', 'insert'], ['change_log_setup', 'modify'], ['change_log_setup', 'delete'], ['change_log_entry', 'read']],
  },
  ADMIN_AUDIT_VIEW: { page: 'ADMIN_AUDIT', tables: [['audit_log', 'read']] },

  // System Automation (Job Queue) — mirrors Business Central's Job Queue Entry: the admin sets
  // up recurring background tasks (currently just Entrance Fee Recovery — see lib/jobQueue.ts's
  // JOB_HANDLERS) that the in-process scheduler (instrumentation.ts) polls and runs unattended.
  // One grant covers the whole screen, including manually running an entry on demand — same
  // shape ACCOUNT_ACTIVATION_APPROVE bundles its own posting rights under a single action.
  ADMIN_JOB_QUEUE_MANAGE: {
    page: 'ADMIN_JOB_QUEUE',
    tables: [
      ['job_queue_entry', 'insert'], ['job_queue_entry', 'modify'], ['job_queue_entry', 'delete'],
      ['member', 'modify'], ['savings_account', 'modify'],
      ['journal', 'insert'], ['journal_line', 'insert'], ['txn', 'insert'],
    ],
  },
} as const satisfies Record<string, ActionGrant>;

export type ActionKey = keyof typeof ACTIONS;

/* --------------------------------------------------------------- checks */

export function canTable(user: SessionUser | null | undefined, table: string, right: Right): boolean {
  if (!user) return false;
  if (user.is_system) return true;
  return !!user.permissionSet.tables[table]?.[right];
}

export function canPage(user: SessionUser | null | undefined, page: string): boolean {
  if (!user) return false;
  if (user.is_system) return true;
  return !!user.permissionSet.pages[page];
}

export function canAction(user: SessionUser | null | undefined, key: ActionKey): boolean {
  if (!user) return false;
  if (user.is_system) return true;
  const grant = ACTIONS[key];
  return canPage(user, grant.page) && grant.tables.every(([t, r]) => canTable(user, t, r));
}

/* ----------------------------------------------------------------- seed */

/** Seed-only: resolves a role's list of ACTIONS keys into the deduplicated
 *  {role_id, object_type, object_name, rights} rows an admin clicking
 *  through the Permission Set editor would have produced by hand. */
export function expandActionsToLines(
  roleId: number, actionKeys: ActionKey[],
): { role_id: number; object_type: ObjectType; object_name: string; read: boolean; insert: boolean; modify: boolean; delete: boolean; execute: boolean }[] {
  const pages = new Map<string, boolean>();
  const tables = new Map<string, { read: boolean; insert: boolean; modify: boolean; delete: boolean }>();

  for (const key of actionKeys) {
    const grant = ACTIONS[key];
    pages.set(grant.page, true);
    for (const [table, right] of grant.tables) {
      const row = tables.get(table) ?? { read: false, insert: false, modify: false, delete: false };
      row[right] = true;
      tables.set(table, row);
    }
  }

  return [
    ...[...pages.keys()].map((page) => ({
      role_id: roleId, object_type: 'PAGE' as const, object_name: page,
      read: false, insert: false, modify: false, delete: false, execute: true,
    })),
    ...[...tables.entries()].map(([table, rights]) => ({
      role_id: roleId, object_type: 'TABLE' as const, object_name: table,
      ...rights, execute: false,
    })),
  ];
}
