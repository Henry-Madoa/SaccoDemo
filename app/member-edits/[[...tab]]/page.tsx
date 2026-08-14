import Link from 'next/link';
import { notFound } from 'next/navigation';
import { requirePerm, currentCan } from '@/lib/session';
import { listMemberEditRequests, type MemberEditView } from '@/lib/memberEdits';
import { Page } from '@/components/layout/page';
import {
  Card, EmptyState, Pill, TableWrap, Tabs, Toolbar, Spacer, type TabDefinition,
} from '@/components/ui/primitives';
import { SearchInput } from '@/components/ui/filters';
import {
  SubmitButton, CancelApprovalButton, ApproveButton, RejectButton, ProcessButton,
} from '../edit-actions';

const TABS: TabDefinition[] = [
  { key: 'open', label: 'Open' },
  { key: 'pending', label: 'Pending Approval' },
  { key: 'approved', label: 'Approved' },
  { key: 'processed', label: 'Processed' },
];

export default async function MemberEditsPage({ params, searchParams }: {
  params: Promise<{ tab?: string[] }>;
  searchParams: Promise<{ q?: string }>;
}) {
  const user = await requirePerm('MEMBER:READ');
  const { tab: segments } = await params;
  const { q = '' } = await searchParams;

  const requested = segments?.[0];
  if (requested && !TABS.some((t) => t.key === requested)) notFound();
  const tab = (requested ?? 'open') as MemberEditView;

  const [requests, canUpdate, canApprove] = await Promise.all([
    listMemberEditRequests({ view: tab, search: q }),
    currentCan('MEMBER:UPDATE'), currentCan('MEMBER:APPROVE'),
  ]);

  return (
    <Page title="Member Edits" crumb="Staged changes to existing members, from capture through to approval" user={user}>
      <Tabs tabs={TABS} active={tab} hrefFor={(k) => `/member-edits/${k}`} />
      <Toolbar>
        <SearchInput placeholder="Search member name, no. or request no.…" />
        <Spacer />
      </Toolbar>

      <Card>
        {requests.length ? (
          <TableWrap>
            <thead>
              <tr>
                <th>No.</th><th>Member</th><th>Member no.</th>
                <th>Status</th><th className="num" />
              </tr>
            </thead>
            <tbody>
              {requests.map((r) => {
                const isOwnRequest = r.created_by === user.username;
                const canEditThis = canUpdate && (!canApprove || isOwnRequest);
                return (
                <tr key={r.no}>
                  <td className="mono"><Link href={`/member-edits/view/${r.no}`}>{r.no}</Link></td>
                  <td><b>{r.member_first_name} {r.member_last_name}</b></td>
                  <td className="mono">{r.member_no}</td>
                  <td><Pill status={r.status} /></td>
                  <td className="num">
                    <div className="inline" style={{ justifyContent: 'flex-end' }}>
                      {r.status === 'Open' && canEditThis ? <SubmitButton no={r.no} /> : null}
                      {r.status === 'Pending Approval' && canUpdate && isOwnRequest ? (
                        <CancelApprovalButton no={r.no} />
                      ) : null}
                      {r.status === 'Pending Approval' && canApprove ? (
                        <>
                          <ApproveButton no={r.no} />
                          <RejectButton no={r.no} />
                        </>
                      ) : null}
                      {r.status === 'Approved' && canApprove ? <ProcessButton no={r.no} /> : null}
                      <Link href={`/members/${r.member_id}`} className="btn sm ghost">View member</Link>
                    </div>
                  </td>
                </tr>
                );
              })}
            </tbody>
          </TableWrap>
        ) : <EmptyState icon="✏️" title="No edit requests here" sub="Try a different tab or clear the search" />}
      </Card>
    </Page>
  );
}
