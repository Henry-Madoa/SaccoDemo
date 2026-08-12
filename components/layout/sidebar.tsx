'use client';

import Link from 'next/link';
import { usePathname } from 'next/navigation';
import { initials } from '@/lib/format';
import { NAV } from '@/lib/nav';
import { useNav } from './nav-context';
import type { OrgBrand, SessionUser } from '@/lib/types';

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
  const { open, close } = useNav();
  const name = org.short_name || org.name || 'SACCO';

  return (
    <>
      {/* Backdrop only exists while the drawer is open, so it cannot swallow
          clicks on the desktop layout. */}
      {open ? <div className="nav-backdrop" onClick={close} aria-hidden="true" /> : null}

      <aside id="app-sidebar" className={`sidebar ${open ? 'open' : ''}`}>
        <div className="sidebar-head">
          {org.logo ? <img src={org.logo} alt="" /> : <div className="mark">{initials(name)}</div>}
          <div>
            <div className="name">{name}</div>
            <div className="sub">Core Banking System</div>
          </div>
        </div>

        <nav className="nav">
          {NAV.map((group) => {
            const items = group.items.filter((i) => allowedPaths.includes(i.path));
            if (!items.length) return null;
            return (
              <div key={group.group}>
                <div className="nav-group">{group.group}</div>
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
            );
          })}
        </nav>

        <div className="sidebar-foot">
          Signed in as {user.username}<br />{user.branch_name || 'Head Office'}
        </div>
      </aside>
    </>
  );
}
