export interface NavItem {
  path: string;
  label: string;
  icon: string;
  /** Visible once the user can execute any one of these pages. */
  page: string | string[];
  badge?: 'pendingApprovals';
}

/** A collapsible sub-menu inside a group — one level of nesting only. */
export interface NavSubMenu {
  submenu: string;
  icon: string;
  items: NavItem[];
}

export type NavEntry = NavItem | NavSubMenu;

export const isSubMenu = (e: NavEntry): e is NavSubMenu => 'submenu' in e;

export interface NavGroup {
  group: string;
  items: NavEntry[];
}

/*
 * Navigation definition, kept out of the sidebar's 'use client' module: a value
 * exported from a client module reaches a Server Component as a client-reference
 * proxy, not the array itself, so the layout could not filter it.
 */
export const NAV: NavGroup[] = [
  {
    group: 'Operations',
    items: [
      { path: '/dashboard', label: 'Dashboard', icon: '▤', page: 'DASHBOARD' },
      { path: '/approvals', label: 'Approvals', icon: '✔', page: 'APPROVALS', badge: 'pendingApprovals' },
       ],
  },
  {
    group: 'Client Relationship MGMT',
    items: [
      { path: '/member-applications', label: 'Member Application', icon: '📝', page: 'MEMBER_APPLICATIONS' },
      { path: '/members', label: 'Members', icon: '👥', page: 'MEMBERS' },
      { path: '/member-edits', label: 'Member Editing', icon: '✏', page: 'MEMBER_EDITS' },
      { path: '/account-openings', label: 'Account Opening', icon: '🏦', page: 'ACCOUNT_OPENING' },
      { path: '/account-deactivations', label: 'Account Deactivation', icon: '🚫', page: 'ACCOUNT_DEACTIVATION' },
      { path: '/account-activations', label: 'Account Activation', icon: '✅', page: 'ACCOUNT_ACTIVATION' },
      { path: '/member-chargings', label: 'Member Charging', icon: '🧾', page: 'MEMBER_CHARGING' },
      { path: '/member-exits', label: 'Member Exit', icon: '🚪', page: 'MEMBER_EXITS' },
      { path: '/member-activations', label: 'Member Activation', icon: '🔓', page: 'MEMBER_ACTIVATIONS' },
      { path: '/member-readmissions', label: 'Member Re-admission', icon: '↩', page: 'MEMBER_READMISSIONS' },
      {
        submenu: 'Periodic Activities', icon: '🕰',
        items: [
          { path: '/entrance-fee-recovery', label: 'Entrance Fee Recovery', icon: '🎟', page: 'ENTRANCE_FEE_RECOVERY' },
          { path: '/member-status-update', label: 'Member Status Update', icon: '🕰', page: 'MEMBER_STATUS_UPDATE' },
        ],
      },
      {
        submenu: 'Reports', icon: '📊',
        items: [
          { path: '/member-statements', label: 'Member Statement', icon: '🧾', page: 'MEMBER_STATEMENTS' },
        ],
      },
      ],
  },
  {
    group:'Credit',
    items:[
      { path: '/collateral-applications', label: 'Collateral Applications', icon: '🏠', page: 'COLLATERAL_APPLICATIONS' },
      { path: '/collateral-register', label: 'Collateral Register', icon: '🗂', page: 'COLLATERAL_REGISTER' },
      { path: '/collateral-releases', label: 'Collateral Releases', icon: '🔓', page: 'COLLATERAL_RELEASES' },
      { path: '/loan-calculator', label: 'Loan Calculator', icon: '🧮', page: 'LOAN_CALCULATOR' },
      { path: '/loans', label: 'Loans', icon: '📄', page: 'LOANS' },
      { path: '/guarantor-changes', label: 'Guarantor Changes', icon: '🔁', page: 'GUARANTOR_CHANGES' },
      { path: '/checkoff-batches', label: 'Checkoff & Salary', icon: '💼', page: 'CHECKOFF_BATCHES' },
      {
        submenu: 'Reports', icon: '📊',
        items: [
          { path: '/loan-documents', label: 'Loan Documents', icon: '🖨', page: 'LOANS' },
          { path: '/sectorial-lending', label: 'Sectorial Lending Return', icon: '🌾', page: 'LOANS' },
        ],
      },
      ],
  },
   {
    group:'FOSA',
    items:[
      { path: '/teller-transactions', label: 'Cash Deposits & Withdrawals', icon: '💵', page: 'TELLER_TRANSACTIONS' },
      { path: '/cash-management', label: 'Cash Management', icon: '🏧', page: 'CASH_MANAGEMENT' },
      { path: '/liens', label: 'Liens & Holds', icon: '🔒', page: 'LIENS' },
      { path: '/inter-account-transfers', label: 'Inter Account Transfers', icon: '🔁', page: 'INTER_ACCOUNT_TRANSFERS' },
      { path: '/bankers-cheques', label: 'Bankers Cheques', icon: '🏦', page: 'BANKERS_CHEQUES' },
      { path: '/cheque-deposits', label: 'Cheque Deposits', icon: '🧾', page: 'CHEQUE_DEPOSITS' },
      { path: '/fixed-deposits', label: 'Fixed Deposits', icon: '🏛', page: 'FIXED_DEPOSITS' },
      { path: '/standing-orders', label: 'Standing Orders', icon: '🔄', page: 'STANDING_ORDERS' },
      {
        submenu: 'Reports', icon: '📊',
        items: [
          { path: '/savings', label: 'Member Accounts List', icon: '📄', page: 'SAVINGS' },
        ],
      },
    ],
  },
  {
    group: 'Finance',
    items: [
      { path: '/accounting', label: 'General Ledger', icon: '⚖', page: 'GL' },
      {
        submenu: 'Reports', icon: '📊',
        items: [
          { path: '/reports', label: 'Financial Reports',  icon: '📄', page: 'REPORTS' },
        ],
      },
    ],
  },
  {
    group: 'Administration',
    items: [
      {
        path: '/admin', label: 'Admin Centre', icon: '⚙',
        page: [
          'ADMIN_COMPANY', 'ADMIN_APPEARANCE', 'ADMIN_USERS', 'ADMIN_WORKFLOWS_SETUP', 'ADMIN_ROLES',
          'ADMIN_PRODUCTS_SAVINGS', 'ADMIN_PRODUCTS_LOANS', 'ADMIN_PRODUCTS_COLLATERAL', 'ADMIN_POOL_SECTORS',
          'ADMIN_CHARGES_MASTER', 'ADMIN_CHARGES_TRANSACTION',
          'ADMIN_POOL_CATEGORIES', 'ADMIN_POOL_COUNTIES',
          'ADMIN_POOL_DIMENSIONS', 'ADMIN_POOL_DENOMINATIONS', 'ADMIN_TELLER_SETUP',
          'ADMIN_WORKFLOWS_DEFINITIONS', 'ADMIN_WORKFLOWS_GROUPS', 'ADMIN_WORKFLOWS_TABLES',
          'ADMIN_AUDIT', 'ADMIN_CHANGELOG', 'ADMIN_DATA', 'ADMIN_JOB_QUEUE',
        ],
      },
    ],
  },
];
