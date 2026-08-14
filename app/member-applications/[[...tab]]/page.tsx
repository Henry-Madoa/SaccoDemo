import Link from 'next/link';
import { notFound } from 'next/navigation';
import { requirePerm, currentCan } from '@/lib/session';
import { listMemberApplications, type MemberApplicationView } from '@/lib/memberApplications';
import { Page } from '@/components/layout/page';
import {
  Card, EmptyState, Pill, TableWrap, Tabs, Toolbar, Spacer, type TabDefinition,
} from '@/components/ui/primitives';
import { SearchInput } from '@/components/ui/filters';
import {
  SubmitButton, CancelApprovalButton, ApproveButton, RejectButton, ProcessButton,
} from '../application-actions';

const TABS: TabDefinition[] = [
  { key: 'open', label: 'Open' },
  { key: 'pending', label: 'Pending Approval' },
  { key: 'approved', label: 'Approved' },
  { key: 'processed', label: 'Processed' },
];

export default async function MemberApplicationsPage({ params, searchParams }: {
  params: Promise<{ tab?: string[] }>;
  searchParams: Promise<{ q?: string }>;
}) {
  const user = await requirePerm('MEMBER:READ');
  const { tab: segments } = await params;
  const { q = '' } = await searchParams;

  const requested = segments?.[0];
  if (requested && !TABS.some((t) => t.key === requested)) notFound();
  const tab = (requested ?? 'open') as MemberApplicationView;

  const [applications, canCreate, canApprove] = await Promise.all([
    listMemberApplications({ view: tab, search: q }),
    currentCan('MEMBER:CREATE'), currentCan('MEMBER:APPROVE'),
  ]);

  return (
    <Page title="Member Applications" crumb="Staged memberships, from capture through to approval" user={user}>
      <Tabs tabs={TABS} active={tab} hrefFor={(k) => `/member-applications/${k}`} />
      <Toolbar>
        <SearchInput placeholder="Search name, national ID or application no.…" />
        <Spacer />
        {canCreate ? <Link href="/member-applications/new" className="btn">New application</Link> : null}
      </Toolbar>

      <Card>
        {applications.length ? (
          <TableWrap>
            <thead>
              <tr>
                <th>No.</th><th>Name</th><th>Identification No.</th><th>Phone</th>
                <th>Status</th><th className="num" />
              </tr>
            </thead>
            <tbody>
              {applications.map((a) => {
                const isOwnApplication = a.created_by === user.username;
                const canEditThis = canCreate && (!canApprove || isOwnApplication);
                return (
                <tr key={a.no}>
                  <td className="mono"><Link href={`/member-applications/view/${a.no}`}>{a.no}</Link></td>
                  <td><b>{a.first_name} {a.last_name}</b></td>
                  <td className="mono">{a.national_id || '—'}</td>
                  <td>{a.phone || '—'}</td>
                  <td><Pill status={a.status} /></td>
                  <td className="num">
                    <div className="inline" style={{ justifyContent: 'flex-end' }}>
                      {a.status === 'Open' && canEditThis ? <SubmitButton no={a.no} /> : null}
                      {a.status === 'Pending Approval' && canCreate && isOwnApplication ? (
                        <CancelApprovalButton no={a.no} />
                      ) : null}
                      {a.status === 'Pending Approval' && canApprove ? (
                        <>
                          <ApproveButton no={a.no} />
                          <RejectButton no={a.no} />
                        </>
                      ) : null}
                      {a.status === 'Approved' && canApprove ? <ProcessButton no={a.no} /> : null}
                      {a.member_id ? (
                        <Link href={`/members/${a.member_id}`} className="btn sm ghost">View member</Link>
                      ) : null}
                    </div>
                  </td>

                </tr>
                );
              })}
            </tbody>
          </TableWrap>
        ) : <EmptyState icon="📝" title="No applications here" sub="Try a different tab or clear the search" />}
      </Card>
    </Page>
  );
}
