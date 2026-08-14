import type { ReactNode } from 'react';
import { getOrgBrand } from '@/lib/org';
import { requireUser } from '@/lib/session';
import { canPage } from '@/lib/permissions';
import { pendingApprovalCount } from '@/lib/reports';
import { NAV } from '@/lib/nav';
import { Sidebar } from '@/components/layout/sidebar';
import { NavProvider } from '@/components/layout/nav-context';

export async function AppShell({ children }: { children: ReactNode }) {
  const user = await requireUser();
  const org = (await getOrgBrand())!;

  // Resolve navigation visibility here so the browser only ever learns which
  // links to draw, not the permission list that produced them.
  const allowedPaths = NAV.flatMap((g) => g.items)
    .filter((i) => (Array.isArray(i.page) ? i.page : [i.page]).some((p) => canPage(user, p)))
    .map((i) => i.path);

  const badges = canPage(user, 'APPROVALS') ? { pendingApprovals: await pendingApprovalCount() } : {};

  return (
    <NavProvider>
      <div className="shell">
        <Sidebar org={org} user={user} allowedPaths={allowedPaths} badges={badges} />
        <div className="main">{children}</div>
      </div>
    </NavProvider>
  );
}
