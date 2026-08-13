import type { Permission } from './types.ts';

export interface NavItem {
  path: string;
  label: string;
  icon: string;
  perms: Permission[];
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
      { path: '/dashboard', label: 'Dashboard', icon: '▤', perms: ['REPORT:VIEW'] },
      { path: '/approvals', label: 'Approvals', icon: '✔', perms: ['LOAN:READ', 'MEMBER:READ', 'GL:READ'], badge: 'pendingApprovals' },
      { path: '/member-applications', label: 'Member Application', icon: '📝', perms: ['MEMBER:READ'] },
      {  path: '/members', label: 'Members', icon: '👥', perms: ['MEMBER:READ'] },
      { path: '/savings', label: 'Savings & FOSA', icon: '💰', perms: ['SAVINGS:READ'] },
      { path: '/loans', label: 'Loans', icon: '📄', perms: ['LOAN:READ'] },
       ],
  },
  {
    group: 'Finance',
    items: [
      { path: '/accounting', label: 'General Ledger', icon: '⚖', perms: ['GL:READ'] },
      { path: '/reports', label: 'Reports', icon: '📊', perms: ['REPORT:VIEW'] },
    ],
  },
  {
    group: 'Administration',
    items: [
      {
        path: '/admin', label: 'Admin Centre', icon: '⚙',
        perms: ['ADMIN:ORG_MANAGE', 'ADMIN:THEME_MANAGE', 'ADMIN:USER_MANAGE', 'ADMIN:PRODUCT_MANAGE',
          'ADMIN:AUDIT_VIEW', 'ADMIN:COA_MANAGE', 'ADMIN:ROLE_MANAGE', 'ADMIN:POOL_MANAGE', 'ADMIN:WORKFLOW_MANAGE'],
      },
    ],
  },
];
