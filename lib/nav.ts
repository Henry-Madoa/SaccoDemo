export interface NavItem {
  path: string;
  label: string;
  icon: string;
  /** Visible once the user can execute any one of these pages. */
  page: string | string[];
  badge?: 'pendingApprovals';
}

export interface NavGroup {
  group: string;
  items: NavItem[];
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
      { path: '/savings', label: 'Savings & FOSA', icon: '💰', page: 'SAVINGS' },
      { path: '/loans', label: 'Loans', icon: '📄', page: 'LOANS' },
       ],
  },
  {
    group: 'Client Relationship Mgmt',
    items: [
      { path: '/member-applications', label: 'Member Application', icon: '📝', page: 'MEMBER_APPLICATIONS' },
      { path: '/members', label: 'Members', icon: '👥', page: 'MEMBERS' },
      { path: '/member-edits', label: 'Member Editing', icon: '✏', page: 'MEMBER_EDITS' },
    ],
  },
  {
    group: 'Finance',
    items: [
      { path: '/accounting', label: 'General Ledger', icon: '⚖', page: 'GL' },
      { path: '/reports', label: 'Reports', icon: '📊', page: 'REPORTS' },
    ],
  },
  {
    group: 'Administration',
    items: [
      {
        path: '/admin', label: 'Admin Centre', icon: '⚙',
        page: [
          'ADMIN_COMPANY', 'ADMIN_APPEARANCE', 'ADMIN_USERS', 'ADMIN_ROLES', 'ADMIN_PRODUCTS_SAVINGS',
          'ADMIN_PRODUCTS_LOANS', 'ADMIN_POOL_CATEGORIES', 'ADMIN_POOL_COUNTIES', 'ADMIN_POOL_DIMENSIONS',
          'ADMIN_WORKFLOWS_DEFINITIONS', 'ADMIN_WORKFLOWS_GROUPS', 'ADMIN_WORKFLOWS_SETUP', 'ADMIN_WORKFLOWS_TABLES',
          'ADMIN_AUDIT', 'ADMIN_CHANGELOG', 'ADMIN_DATA',
        ],
      },
    ],
  },
];
