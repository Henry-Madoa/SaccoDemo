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
  /** Which Role Centres surface this group in the sidebar (Business Central: the Profile / Role
   *  Center defines the navigation). Omit for a group every Role Centre sees. The SUPER Role
   *  Centre always sees every group. Values are `profile.role_centre` keys —
   *  CRM | CREDIT | FOSA | FINANCE_MANAGER | ACCOUNTANT. */
  centres?: string[];
}

/** Whether `group` shows in the sidebar for a user whose active Role Centre is `roleCentre`. */
export const groupInRoleCentre = (group: NavGroup, roleCentre: string): boolean =>
  roleCentre === 'SUPER' || !group.centres || group.centres.includes(roleCentre);

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
    centres: ['CRM'],
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
    centres: ['CREDIT'],
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
    centres: ['FOSA'],
    items:[
      { path: '/teller-transactions', label: 'Cash Deposits & Withdrawals', icon: '💵', page: 'TELLER_TRANSACTIONS' },
      { path: '/branch-cash', label: 'Branch Cash', icon: '🏧', page: 'CASH_MANAGEMENT' },
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
    centres: ['FINANCE_MANAGER', 'ACCOUNTANT'],
    items: [
      { path: '/accounting', label: 'General Ledger', icon: '⚖', page: 'GL' },
      {
        submenu: 'Receivables', icon: '🧾',
        items: [
          { path: '/receivables', label: 'Customers', icon: '👤', page: 'RECEIVABLES' },
          { path: '/receivables/sales-invoices', label: 'Sales Documents', icon: '📄', page: 'RECEIVABLES' },
          { path: '/receivables/cash-receipts', label: 'Cash Receipts', icon: '💰', page: 'RECEIVABLES' },
          { path: '/receivables/reminders', label: 'Reminders', icon: '⏰', page: 'RECEIVABLES' },
          { path: '/receivables/aged-ar', label: 'Aged Receivables', icon: '📊', page: 'RECEIVABLES' },
        ],
      },
      {
        submenu: 'Payables', icon: '📥',
        items: [
          { path: '/payables', label: 'Vendors', icon: '🏭', page: 'PAYABLES' },
          { path: '/payables/purchase-invoices', label: 'Purchase Documents', icon: '📄', page: 'PAYABLES' },
          { path: '/payables/payment-journal', label: 'Payment Journal', icon: '💸', page: 'PAYABLES' },
          { path: '/payables/aged-ap', label: 'Aged Payables', icon: '📊', page: 'PAYABLES' },
        ],
      },
      {
        submenu: 'Cash Management', icon: '🏦',
        items: [
          { path: '/cash-management', label: 'Bank Accounts', icon: '🏦', page: 'CASH_MGMT' },
          { path: '/cash-management/ledger-entries', label: 'Bank Ledger Entries', icon: '📓', page: 'CASH_MGMT' },
          { path: '/cash-management/reconciliations', label: 'Bank Reconciliation', icon: '✔', page: 'CASH_MGMT' },
          { path: '/cash-management/receipts', label: 'Receipts', icon: '🧾', page: 'CASH_MGMT' },
          { path: '/cash-management/payment-vouchers', label: 'Payment Vouchers', icon: '💸', page: 'CASH_MGMT' },
          { path: '/cash-management/currencies', label: 'Currencies', icon: '💱', page: 'CASH_MGMT' },
          { path: '/cash-management/adjust-exchange-rates', label: 'Adjust Exchange Rates', icon: '📈', page: 'CASH_MGMT' },
        ],
      },
      {
        submenu: 'VAT & WHT', icon: '🧮',
        items: [
          { path: '/finance/vat/input-listing', label: 'VAT Input Listing', icon: '📄', page: 'VAT_REPORTS' },
          { path: '/finance/vat/wht-analysis', label: 'WHT Analysis', icon: '📊', page: 'VAT_REPORTS' },
          { path: '/finance/vat/wht-certificates', label: 'WHT Certificates', icon: '📜', page: 'VAT_REPORTS' },
        ],
      },
      {
        submenu: 'Inventory', icon: '📦',
        items: [
          { path: '/inventory/items', label: 'Items', icon: '📦', page: 'INVENTORY' },
          { path: '/inventory/item-journal', label: 'Item Journal', icon: '📓', page: 'INVENTORY' },
        ],
      },
      {
        submenu: 'Fixed Assets', icon: '🏛',
        items: [
          { path: '/fixed-assets', label: 'Assets', icon: '🏛', page: 'FIXED_ASSETS' },
          { path: '/fixed-assets/journal', label: 'FA Journal', icon: '📓', page: 'FIXED_ASSETS' },
          { path: '/fixed-assets/depreciation', label: 'Calculate Depreciation', icon: '📉', page: 'FIXED_ASSETS' },
          { path: '/fixed-assets/book-value', label: 'Book Value Report', icon: '📊', page: 'FIXED_ASSETS' },
        ],
      },
      {
        submenu: 'Financial Reports', icon: '🧾',
        items: [
          { path: '/finance/financial-reports', label: 'Reports', icon: '📄', page: 'FINANCIAL_REPORTS' },
          { path: '/finance/financial-reports/row-definitions', label: 'Row Definitions', icon: '↔', page: 'FINANCIAL_REPORTS' },
          { path: '/finance/financial-reports/column-layouts', label: 'Column Layouts', icon: '⋮', page: 'FINANCIAL_REPORTS' },
        ],
      },
      {
        submenu: 'Reports', icon: '📊',
        items: [
          { path: '/reports', label: 'Financial Statements',  icon: '📄', page: 'REPORTS' },
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
