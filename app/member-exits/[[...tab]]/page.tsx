import Link from 'next/link';
import { notFound } from 'next/navigation';
import { requireAction, currentCanAction } from '@/lib/session';
import {
  listMemberExits, hasAnyMemberExits, eligibleMembersForExit, listMembersInExitHistory,
  MEMBER_EXIT_FILTER_FIELDS, type MemberExitView,
} from '@/lib/memberExits';
import { parseFilters } from '@/lib/listFilters';
import { parseSort } from '@/lib/listSort';
import { Page } from '@/components/layout/page';
import {
  Card, EmptyState, Pill, TableWrap, Tabs, Toolbar, Spacer, type TabDefinition,
} from '@/components/ui/primitives';
import { SearchInput } from '@/components/ui/filters';
import { DynamicFilterBar } from '@/components/ui/dynamic-filter';
import { SortLink } from '@/components/ui/sort-link';
import { Money } from '@/components/ui/money';
import { ExportButton } from '@/components/ui/export-button';
import { humanise } from '@/lib/format';
import {
  NewMemberExitButton, SubmitButton, CancelApprovalButton, ReopenButton, ProcessButton,
} from '../member-exit-actions';

const TABS: TabDefinition[] = [
  { key: 'open', label: 'Open', tone: 'info' },
  { key: 'pending', label: 'Pending Approval', tone: 'warn' },
  { key: 'approved', label: 'Approved', tone: 'ok' },
  { key: 'processed', label: 'Processed', tone: 'accent' },
];

export default async function MemberExitsPage({ params, searchParams }: {
  params: Promise<{ tab?: string[] }>;
  searchParams: Promise<{ q?: string; filters?: string; sort?: string; new?: string }>;
}) {
  const user = await requireAction('MEMBER_EXITS_READ');
  const { tab: segments } = await params;
  const { q = '', filters: filtersRaw, sort: sortRaw, new: presetMemberId } = await searchParams;
  const filters = parseFilters(filtersRaw);
  const sort = parseSort(sortRaw);

  const requested = segments?.[0];
  if (requested && !TABS.some((t) => t.key === requested)) notFound();
  const tab = (requested ?? 'open') as MemberExitView;

  const [exits, empty, canCreate, canApprove, members, filterMembers] = await Promise.all([
    listMemberExits({ view: tab, search: q, filters, sort }),
    hasAnyMemberExits(tab).then((any) => !any),
    currentCanAction('MEMBER_EXITS_CREATE'), currentCanAction('MEMBER_EXITS_APPROVE'),
    eligibleMembersForExit(),
    listMembersInExitHistory(),
  ]);
  const fields = MEMBER_EXIT_FILTER_FIELDS.map((f) => (
    f.key === 'member_id' ? { ...f, options: filterMembers.map((m) => ({ value: m.id, label: `${m.member_no} — ${m.first_name} ${m.last_name}` })) }
      : f
  ));

  return (
    <Page title="Member Exit" crumb="Terminating a membership — settle assets and liabilities, pay out the balance, close the accounts" user={user}>
      <Tabs tabs={TABS} active={tab} hrefFor={(k) => `/member-exits/${k}`} />
      <Toolbar>
        <SearchInput placeholder="Search member name, no. or document no.…" disabled={empty} />
        <DynamicFilterBar fields={fields} disabled={empty} />
        <Spacer />
        <ExportButton href="/api/export/member-exits" params={{ q, view: tab, filters: filtersRaw, sort: sortRaw }} disabled={!exits.length} />
        {canCreate ? <NewMemberExitButton members={members} presetMemberId={presetMemberId ?? null} /> : null}
      </Toolbar>

      <Card>
        {exits.length ? (
          <TableWrap>
            <thead>
              <tr>
                <th><SortLink sortKey="no">No.</SortLink></th>
                <th><SortLink sortKey="member">Member</SortLink></th>
                <th><SortLink sortKey="exit_type">Exit type</SortLink></th>
                <th className="num"><SortLink sortKey="net_amount">Net amount</SortLink></th>
                <th><SortLink sortKey="status">Status</SortLink></th><th className="num" />
              </tr>
            </thead>
            <tbody>
              {exits.map((e) => {
                const isOwnRequest = e.created_by === user.username;
                const canEditThis = canCreate && (!canApprove || isOwnRequest);
                return (
                <tr key={e.no}>
                  <td className="mono"><Link href={`/member-exits/view/${e.no}?view=${tab}`}>{e.no}</Link></td>
                  <td>
                    <b>{e.member_first_name} {e.member_last_name}</b>
                    <div className="tiny mono">{e.member_no}</div>
                  </td>
                  <td>{humanise(e.exit_type)}</td>
                  <td className="num"><Money cents={e.net_amount} decimals={0} /></td>
                  <td><Pill status={e.status} /></td>
                  <td className="num">
                    <div className="inline" style={{ justifyContent: 'flex-end' }}>
                      {e.status === 'Open' && canEditThis ? <SubmitButton no={e.no} /> : null}
                      {e.status === 'Pending Approval' && canCreate && isOwnRequest ? (
                        <CancelApprovalButton no={e.no} />
                      ) : null}
                      {e.status === 'Approved' && canApprove ? (
                        <>
                          <ReopenButton no={e.no} />
                          <ProcessButton no={e.no} />
                        </>
                      ) : null}
                    </div>
                  </td>
                </tr>
                );
              })}
            </tbody>
          </TableWrap>
        ) : <EmptyState icon="🚪" title="No member exits here" sub="Try a different tab or clear the search" />}
      </Card>
    </Page>
  );
}
