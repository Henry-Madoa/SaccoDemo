import Link from 'next/link';
import { notFound } from 'next/navigation';
import { requireAction, currentCanAction } from '@/lib/session';
import {
  listMemberEditRequests, hasAnyMemberEditRequests, EDIT_FILTER_FIELDS, type MemberEditView,
} from '@/lib/memberEdits';
import { listActiveMembers } from '@/lib/members';
import { listActiveMemberCategories, listActiveCounties, listActiveSubCounties, listActiveDimensionValues } from '@/lib/pool';
import { getDimensionCaptions } from '@/lib/org';
import { parseFilters } from '@/lib/listFilters';
import { parseSort } from '@/lib/listSort';
import { Page } from '@/components/layout/page';
import {
  Card, EmptyState, Pill, TableWrap, Tabs, Toolbar, Spacer, type TabDefinition,
} from '@/components/ui/primitives';
import { SearchInput } from '@/components/ui/filters';
import { DynamicFilterBar } from '@/components/ui/dynamic-filter';
import { SortLink } from '@/components/ui/sort-link';
import { ExportButton } from '@/components/ui/export-button';
import {
  NewEditRequestButton, SubmitButton, CancelApprovalButton, ProcessButton,
} from '../edit-actions';

const TABS: TabDefinition[] = [
  { key: 'open', label: 'Open', tone: 'info' },
  { key: 'pending', label: 'Pending Approval', tone: 'warn' },
  { key: 'approved', label: 'Approved', tone: 'ok' },
  { key: 'processed', label: 'Processed', tone: 'accent' },
];

export default async function MemberEditsPage({ params, searchParams }: {
  params: Promise<{ tab?: string[] }>;
  searchParams: Promise<{ q?: string; filters?: string; sort?: string }>;
}) {
  const user = await requireAction('MEMBER_EDITS_READ');
  const { tab: segments } = await params;
  const { q = '', filters: filtersRaw, sort: sortRaw } = await searchParams;
  const filters = parseFilters(filtersRaw);
  const sort = parseSort(sortRaw);

  const requested = segments?.[0];
  if (requested && !TABS.some((t) => t.key === requested)) notFound();
  const tab = (requested ?? 'open') as MemberEditView;

  const [requests, empty, canUpdate, canApprove, members, categories, counties, subCounties, gd1Values, gd2Values, { caption1, caption2 }] =
    await Promise.all([
      listMemberEditRequests({ view: tab, search: q, filters, sort }),
      hasAnyMemberEditRequests(tab).then((any) => !any),
      currentCanAction('MEMBER_EDITS_UPDATE'), currentCanAction('MEMBER_EDITS_APPROVE'),
      listActiveMembers(),
      listActiveMemberCategories(), listActiveCounties(), listActiveSubCounties(),
      listActiveDimensionValues(1), listActiveDimensionValues(2), getDimensionCaptions(),
    ]);
  const fields = EDIT_FILTER_FIELDS.map((f) => (
    f.key === 'member_category_id' ? { ...f, options: categories.map((c) => ({ value: c.id, label: c.description })) }
      : f.key === 'county_id' ? { ...f, options: counties.map((c) => ({ value: c.id, label: c.name })) }
        : f.key === 'sub_county_id' ? { ...f, options: subCounties.map((c) => ({ value: c.id, label: c.name })) }
          : f.key === 'global_dimension_1_id' ? { ...f, label: caption1, options: gd1Values.map((d) => ({ value: d.id, label: `${d.code} — ${d.name}` })) }
            : f.key === 'global_dimension_2_id' ? { ...f, label: caption2, options: gd2Values.map((d) => ({ value: d.id, label: `${d.code} — ${d.name}` })) }
              : f
  ));

  return (
    <Page title="Member Edits" crumb="Staged changes to existing members, from capture through to approval" user={user}>
      <Tabs tabs={TABS} active={tab} hrefFor={(k) => `/member-edits/${k}`} />
      <Toolbar>
        <SearchInput placeholder="Search member name, no. or request no.…" disabled={empty} />
        <DynamicFilterBar fields={fields} disabled={empty} />
        <Spacer />
        <ExportButton href="/api/export/member-edits" params={{ q, view: tab, filters: filtersRaw, sort: sortRaw }} disabled={!requests.length} />
        {canUpdate ? <NewEditRequestButton members={members} /> : null}
      </Toolbar>

      <Card>
        {requests.length ? (
          <TableWrap>
            <thead>
              <tr>
                <th><SortLink sortKey="no">No.</SortLink></th>
                <th><SortLink sortKey="member">Member</SortLink></th>
                <th><SortLink sortKey="member_no">Member no.</SortLink></th>
                <th><SortLink sortKey="status">Status</SortLink></th><th className="num" />
              </tr>
            </thead>
            <tbody>
              {requests.map((r) => {
                const isOwnRequest = r.created_by === user.username;
                const canEditThis = canUpdate && (!canApprove || isOwnRequest);
                return (
                <tr key={r.no}>
                  <td className="mono"><Link href={`/member-edits/view/${r.no}?view=${tab}`}>{r.no}</Link></td>
                  <td><b>{r.member_first_name} {r.member_last_name}</b></td>
                  <td className="mono">{r.member_no}</td>
                  <td><Pill status={r.status} /></td>
                  <td className="num">
                    <div className="inline" style={{ justifyContent: 'flex-end' }}>
                      {r.status === 'Open' && canEditThis ? <SubmitButton no={r.no} /> : null}
                      {r.status === 'Pending Approval' && canUpdate && isOwnRequest ? (
                        <CancelApprovalButton no={r.no} />
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
