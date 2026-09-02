'use client';

import { useEffect, useState } from 'react';
import Link from 'next/link';
import { usePathname } from 'next/navigation';
import { initials } from '@/lib/format';
import { NAV } from '@/lib/nav';
import { useNav } from './nav-context';
import type { OrgBrand, SessionUser } from '@/lib/types';

const COLLAPSED_GROUPS_KEY = 'nav-collapsed-groups';

export interface SidebarProps {
  org: OrgBrand;
  user: SessionUser;
  /** Nav paths this user may see — resolved on the server so the permission
   *  list never reaches the browser. */
  allowedPaths: string[];
  badges?: Partial<Record<'pendingApprovals', number>>;
}

export function Sidebar({ org, user, allowedPaths, badges = {} }: SidebarProps) {
  const pathname = usePathname();
  const { open, close, hideDesktop } = useNav();
  const name = org.short_name || org.name || 'SACCO';

  // The header button hides the permanent column on desktop; on the mobile
  // drawer it simply closes it (the hamburger in the top bar reopens either).
  const hide = () => {
    if (typeof window !== 'undefined' && window.matchMedia('(min-width: 901px)').matches) hideDesktop();
    else close();
  };

  const [collapsed, setCollapsed] = useState<Set<string>>(new Set());

  // Server render can't know a returning user's preference — it always starts
  // fully expanded, then this reconciles from localStorage right after mount.
  useEffect(() => {
    try {
      const saved = localStorage.getItem(COLLAPSED_GROUPS_KEY);
      if (saved) setCollapsed(new Set(JSON.parse(saved)));
    } catch { /* ignore malformed/unavailable storage */ }
  }, []);

  const toggleGroup = (group: string) => {
    setCollapsed((prev) => {
      const next = new Set(prev);
      if (next.has(group)) next.delete(group); else next.add(group);
      localStorage.setItem(COLLAPSED_GROUPS_KEY, JSON.stringify([...next]));
      return next;
    });
  };

  return (
    <>
      {/* Backdrop only exists while the drawer is open, so it cannot swallow
          clicks on the desktop layout. */}
      {open ? <div className="nav-backdrop" onClick={close} aria-hidden="true" /> : null}

      <aside id="app-sidebar" className={`sidebar ${open ? 'open' : ''}`}>
        <div className="sidebar-head">
          <Link href="/dashboard" className="sidebar-brand" onClick={close}>
            {org.logo ? <img src={org.logo} alt="" /> : <div className="mark">{initials(name)}</div>}
            <div>
              <div className="name">{name}</div>
              <div className="sub">Core Banking System</div>
            </div>
          </Link>
          <button type="button" className="sidebar-collapse" onClick={hide}
            aria-label="Hide sidebar" title="Hide sidebar">
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" aria-hidden="true">
              <path d="M13 6l-6 6 6 6M19 6l-6 6 6 6" stroke="currentColor" strokeWidth="2"
                strokeLinecap="round" strokeLinejoin="round" />
            </svg>
          </button>
        </div>

        <nav className="nav">
          {NAV.map((group) => {
            const items = group.items.filter((i) => allowedPaths.includes(i.path));
            if (!items.length) return null;
            const isCollapsed = collapsed.has(group.group);
            const bodyId = `nav-group-${group.group.replace(/\s+/g, '-').toLowerCase()}`;
            return (
              <div key={group.group}>
                <button type="button" className="nav-group" aria-expanded={!isCollapsed} aria-controls={bodyId}
                  onClick={() => toggleGroup(group.group)}>
                  {group.group}
                </button>
                <div id={bodyId} className={`nav-group-body ${isCollapsed ? 'collapsed' : ''}`}>
                  <div className="nav-group-body-inner">
                    {items.map((item) => {
                      const active = pathname === item.path || pathname.startsWith(`${item.path}/`);
                      const badge = item.badge ? badges[item.badge] : 0;
                      return (
                        <Link key={item.path} href={item.path} className={active ? 'active' : ''}
                          aria-current={active ? 'page' : undefined}>
                          <span className="ico" aria-hidden="true">{item.icon}</span>
                          {item.label}
                          {badge ? <span className="badge">{badge}</span> : null}
                        </Link>
                      );
                    })}
                  </div>
                </div>
              </div>
            );
          })}
        </nav>

        <div className="sidebar-foot">
          Signed in as {user.username}<br />{user.role_name}
        </div>
      </aside>
    </>
  );
}
