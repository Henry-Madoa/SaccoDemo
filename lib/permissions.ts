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
  { code: 'MEMBER_APPLICATIONS', label: 'Member Application', route: '/member-applications' },
  { code: 'MEMBERS', label: 'Members', route: '/members' },
  { code: 'MEMBER_EDITS', label: 'Member Editing', route: '/member-edits' },
  { code: 'ACCOUNT_OPENING', label: 'Account Opening', route: '/account-openings' },
  { code: 'ACCOUNT_DEACTIVATION', label: 'Account Deactivation', route: '/account-deactivations' },
  { code: 'ACCOUNT_ACTIVATION', label: 'Account Activation', route: '/account-activations' },
  { code: 'MEMBER_CHARGING', label: 'Member Charging', route: '/member-chargings' },
  { code: 'GL', label: 'General Ledger', route: '/accounting' },
  { code: 'REPORTS', label: 'Reports', route: '/reports' },
  { code: 'ADMIN_COMPANY', label: 'Company Information', route: '/admin/company' },
  { code: 'ADMIN_APPEARANCE', label: 'Appearance & Theme', route: '/admin/appearance' },
  { code: 'ADMIN_PRODUCTS_SAVINGS', label: 'Savings Products', route: '/admin/products/savings' },
  { code: 'ADMIN_PRODUCTS_LOANS', label: 'Loan Products', route: '/admin/products/loans' },
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

  // Savings & FOSA
  SAVINGS_READ: { page: 'SAVINGS', tables: [['savings_account', 'read']] },
  SAVINGS_DEPOSIT: { page: 'SAVINGS', tables: [['journal', 'insert'], ['journal_line', 'insert'], ['savings_account', 'modify'], ['txn', 'insert']] },
  SAVINGS_WITHDRAW: { page: 'SAVINGS', tables: [['journal', 'insert'], ['journal_line', 'insert'], ['savings_account', 'modify'], ['txn', 'insert']] },
  SAVINGS_REVERSE: { page: 'SAVINGS', tables: [['journal', 'insert'], ['savings_account', 'modify'], ['txn', 'insert'], ['txn', 'modify']] },

  // Loans
  LOAN_READ: { page: 'LOANS', tables: [['loan', 'read']] },
  LOAN_CREATE: { page: 'LOANS', tables: [['loan', 'insert'], ['loan_guarantor', 'insert'], ['workflow_task', 'insert'], ['attachment', 'insert'], ['attachment', 'delete']] },
  LOAN_APPROVE: { page: 'LOANS', tables: [['loan', 'modify']] },
  LOAN_DISBURSE: {
    page: 'LOANS',
    tables: [['journal', 'insert'], ['journal_line', 'insert'], ['loan_schedule', 'insert'], ['loan_schedule', 'delete'], ['loan', 'modify'], ['savings_account', 'modify'], ['txn', 'insert']],
  },
  LOAN_REPAY: {
    page: 'LOANS',
    tables: [['journal', 'insert'], ['journal_line', 'insert'], ['loan_schedule', 'modify'], ['loan', 'modify'], ['savings_account', 'modify'], ['txn', 'insert']],
  },

  // General Ledger
  GL_READ: { page: 'GL', tables: [['journal', 'read'], ['journal_line', 'read'], ['gl_account', 'read']] },
  GL_JOURNAL_CREATE: { page: 'GL', tables: [['journal', 'insert'], ['journal_line', 'insert'], ['workflow_task', 'insert']] },
  GL_JOURNAL_APPROVE: { page: 'GL', tables: [['journal', 'insert'], ['journal_line', 'insert']] },
  GL_JOURNAL_REVERSE: { page: 'GL', tables: [['journal', 'insert'], ['journal', 'modify'], ['journal_line', 'insert']] },
  GL_PERIOD_CLOSE: { page: 'GL', tables: [['accounting_period', 'modify']] },
  GL_ACCOUNT_MANAGE: { page: 'GL', tables: [['gl_account', 'insert'], ['gl_account', 'modify'], ['change_log_entry', 'insert']] },

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
  ADMIN_PRODUCTS_LOANS_MANAGE: { page: 'ADMIN_PRODUCTS_LOANS', tables: [['loan_product', 'insert'], ['loan_product', 'modify']] },
  ADMIN_CHARGES_MASTER_MANAGE: { page: 'ADMIN_CHARGES_MASTER', tables: [['charge', 'insert'], ['charge', 'modify']] },
  ADMIN_CHARGES_TRANSACTION_MANAGE: {
    page: 'ADMIN_CHARGES_TRANSACTION',
    tables: [
      ['transaction_charge', 'insert'], ['transaction_charge', 'modify'],
      ['transaction_charge_setup', 'insert'], ['transaction_charge_setup', 'modify'], ['transaction_charge_setup', 'delete'],
      ['transaction_calc_scheme', 'insert'], ['transaction_calc_scheme', 'modify'], ['transaction_calc_scheme', 'delete'],
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
