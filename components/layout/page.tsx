import type { ReactNode } from 'react';
import { initials } from '@/lib/format';
import { SignOutButton } from './sign-out-button';
import { NavToggle } from './nav-toggle';
import type { SessionUser } from '@/lib/types';

export interface PageProps {
  title: ReactNode;
  crumb?: ReactNode;
  user: SessionUser;
  children: ReactNode;
}

/**
 * The top bar plus the content well.
 *
 * Every route renders its own <Page>, which is what lets the heading carry
 * route-specific detail (a member's name, a loan number) without the shell
 * having to know about routes — the old app poked at #page-title imperatively.
 */
export function Page({ title, crumb, user, children }: PageProps) {
  return (
    <>
      <header className="topbar">
        <NavToggle />
        <div className="titles">
          <h1>{title}</h1>
          {crumb ? <div className="crumb">{crumb}</div> : null}
        </div>
        <div className="spacer" />
        <div className="usermenu">
          {/* Name and role are the first thing to go when width runs out —
              the avatar still identifies who is signed in. */}
          <div className="whoami">
            <div className="who">{user.full_name}</div>
            <div className="role">{user.role_name}</div>
          </div>
          <div className="avatar" title={`${user.full_name} — ${user.role_name}`}>
            {initials(user.full_name)}
          </div>
          <SignOutButton />
        </div>
      </header>
      <main className="content">{children}</main>
    </>
  );
}
