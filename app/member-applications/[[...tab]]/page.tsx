import Link from 'next/link';
import { notFound } from 'next/navigation';
import { requireAction, currentCanAction } from '@/lib/session';
import { listMemberApplications, APPLICATION_FILTER_FIELDS, type MemberApplicationView } from '@/lib/memberApplications';
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
  SubmitButton, CancelApprovalButton, ProcessButton,
} from '../application-actions';

const TABS: TabDefinition[] = [
  { key: 'open', label: 'Open', tone: 'info' },
  { key: 'pending', label: 'Pending Approval', tone: 'warn' },
  { key: 'approved', label: 'Approved', tone: 'ok' },
  { key: 'processed', label: 'Processed', tone: 'accent' },
];

export default async function MemberApplicationsPage({ params, searchParams }: {
  params: Promise<{ tab?: string[] }>;
  searchParams: Promise<{ q?: string; filters?: string; sort?: string }>;
}) {
  const user = await requireAction('MEMBER_APPLICATIONS_READ');
  const { tab: segments } = await params;
  const { q = '', filters: filtersRaw, sort: sortRaw } = await searchParams;
  const filters = parseFilters(filtersRaw);
  const sort = parseSort(sortRaw);

  const requested = segments?.[0];
  if (requested && !TABS.some((t) => t.key === requested)) notFound();
  const tab = (requested ?? 'open') as MemberApplicationView;

  const [applications, canCreate, canApprove, categories, counties, subCounties, gd1Values, gd2Values, { caption1, caption2 }] =
    await Promise.all([
      listMemberApplications({ view: tab, search: q, filters, sort }),
      currentCanAction('MEMBER_APPLICATIONS_CREATE'), currentCanAction('MEMBER_APPLICATIONS_APPROVE'),
      listActiveMemberCategories(), listActiveCounties(), listActiveSubCounties(),
      listActiveDimensionValues(1), listActiveDimensionValues(2), getDimensionCaptions(),
    ]);
  const fields = APPLICATION_FILTER_FIELDS.map((f) => (
    f.key === 'member_category_id' ? { ...f, options: categories.map((c) => ({ value: c.id, label: c.description })) }
      : f.key === 'county_id' ? { ...f, options: counties.map((c) => ({ value: c.id, label: c.name })) }
        : f.key === 'sub_county_id' ? { ...f, options: subCounties.map((c) => ({ value: c.id, label: c.name })) }
          : f.key === 'global_dimension_1_id' ? { ...f, label: caption1, options: gd1Values.map((d) => ({ value: d.id, label: `${d.code} — ${d.name}` })) }
            : f.key === 'global_dimension_2_id' ? { ...f, label: caption2, options: gd2Values.map((d) => ({ value: d.id, label: `${d.code} — ${d.name}` })) }
              : f
  ));

  return (
    <Page title="Member Applications" crumb="Staged memberships, from capture through to approval" user={user}>
      <Tabs tabs={TABS} active={tab} hrefFor={(k) => `/member-applications/${k}`} />
      <Toolbar>
        <SearchInput placeholder="Search name, national ID or application no.…" />
        <DynamicFilterBar fields={fields} />
        <Spacer />
        <ExportButton href="/api/export/member-applications" params={{ q, view: tab, filters: filtersRaw, sort: sortRaw }} disabled={!applications.length} />
        {canCreate ? <Link href="/member-applications/new" className="btn">New application</Link> : null}
      </Toolbar>

      <Card>
        {applications.length ? (
          <TableWrap>
            <thead>
              <tr>
                <th><SortLink sortKey="no">No.</SortLink></th>
                <th><SortLink sortKey="name">Name</SortLink></th>
                <th><SortLink sortKey="national_id">Identification No.</SortLink></th>
                <th><SortLink sortKey="phone">Phone</SortLink></th>
                <th><SortLink sortKey="status">Status</SortLink></th><th className="num" />
              </tr>
            </thead>
            <tbody>
              {applications.map((a) => {
                const isOwnApplication = a.created_by === user.username;
                const canEditThis = canCreate && (!canApprove || isOwnApplication);
                return (
                <tr key={a.no}>
                  <td className="mono"><Link href={`/member-applications/view/${a.no}?view=${tab}`}>{a.no}</Link></td>
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
