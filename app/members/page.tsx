import Link from 'next/link';
import { requireAction, currentCanAction } from '@/lib/session';
import {
  listMembers, hasAnyMembers, MEMBER_FILTER_FIELDS, MEMBER_STATUSES,
} from '@/lib/members';
import { listActiveMemberCategories, listActiveCounties, listActiveSubCounties, listActiveDimensionValues } from '@/lib/pool';
import { getDimensionCaptions } from '@/lib/org';
import { parseFilters } from '@/lib/listFilters';
import { parseSort } from '@/lib/listSort';
import { Page } from '@/components/layout/page';
import {
  Card, CardHead, EmptyState, Pill, TableWrap, Tabs, Toolbar, Spacer, type TabDefinition,
} from '@/components/ui/primitives';
import { SearchInput } from '@/components/ui/filters';
import { DynamicFilterBar } from '@/components/ui/dynamic-filter';
import { SortLink } from '@/components/ui/sort-link';
import { Money } from '@/components/ui/money';
import { formatDate } from '@/lib/format';
import { ExportButton } from '@/components/ui/export-button';
import type { MemberStatus } from '@/lib/types';

/** The list's Status navigation — a tab per member status, themed off the org's active Theme &
 *  Appearance tokens (see Tabs' `tone`). Query-param based (`?status=...`), not a path segment,
 *  since /members/[id] already owns single-segment routes under /members. Withdrawn and Deceased
 *  intentionally share the "bad" tone — both are terminal exits — while "All" stays untoned like
 *  the rest of the app's neutral/closed convention (lib/format.ts's statusTone()). */
const STATUS_TABS: (TabDefinition & { status: MemberStatus | null })[] = [
  { key: 'all', label: 'All', status: null },
  { key: 'active', label: 'Active', status: 'ACTIVE', tone: 'ok' },
  { key: 'not-paid-up', label: 'Not Paid Up', status: 'NOT PAID UP', tone: 'warn' },
  { key: 'dormant', label: 'Dormant', status: 'DORMANT', tone: 'info' },
  { key: 'inactive', label: 'Inactive', status: 'INACTIVE', tone: 'accent' },
  { key: 'withdrawn', label: 'Withdrawn', status: 'WITHDRAWN', tone: 'bad' },
  { key: 'deceased', label: 'Deceased', status: 'DECEASED', tone: 'bad' },
];

export default async function MembersPage({ searchParams }: {
  searchParams: Promise<{ q?: string; filters?: string; sort?: string; status?: string }>;
}) {
  const user = await requireAction('MEMBERS_READ');
  const { q = '', filters: filtersRaw, sort: sortRaw, status: statusRaw } = await searchParams;
  const activeStatus = MEMBER_STATUSES.includes(statusRaw as MemberStatus) ? (statusRaw as MemberStatus) : null;
  const activeTab = STATUS_TABS.find((t) => t.status === activeStatus)?.key ?? 'all';
  const filters = parseFilters(filtersRaw);
  const effectiveFilters = activeStatus ? [...filters, { field: 'status', operator: '=' as const, value: activeStatus }] : filters;
  const sort = parseSort(sortRaw);
  const [{ rows, total }, empty, canCreate, { caption1, caption2 }, categories, counties, subCounties, gd1Values, gd2Values] =
    await Promise.all([
      listMembers({ search: q, filters: effectiveFilters, sort }),
      hasAnyMembers(activeStatus).then((any) => !any),
      currentCanAction('MEMBER_APPLICATIONS_CREATE'),
      getDimensionCaptions(),
      listActiveMemberCategories(),
      listActiveCounties(),
      listActiveSubCounties(),
      listActiveDimensionValues(1),
      listActiveDimensionValues(2),
    ]);
  // The Status tabs above are now the primary way to narrow by status, so it's dropped from the
  // dynamic filter bar (mirroring member-applications' TABS/APPLICATION_FILTER_FIELDS split) —
  // it stays in MEMBER_FILTER_FIELDS itself since buildFilterClause still needs it to resolve
  // the synthetic condition a tab adds above.
  const fields = MEMBER_FILTER_FIELDS.filter((f) => f.key !== 'status').map((f) => (
    f.key === 'member_category_id' ? { ...f, options: categories.map((c) => ({ value: c.id, label: c.description })) }
      : f.key === 'county_id' ? { ...f, options: counties.map((c) => ({ value: c.id, label: c.name })) }
        : f.key === 'sub_county_id' ? { ...f, options: subCounties.map((c) => ({ value: c.id, label: c.name })) }
          : f.key === 'global_dimension_1_id' ? { ...f, label: caption1, options: gd1Values.map((d) => ({ value: d.id, label: `${d.code} — ${d.name}` })) }
            : f.key === 'global_dimension_2_id' ? { ...f, label: caption2, options: gd2Values.map((d) => ({ value: d.id, label: `${d.code} — ${d.name}` })) }
              : f
  ));

  return (
    <Page title="Members" crumb="Registry, KYC and member 360" user={user}>
      <Tabs
        tabs={STATUS_TABS} active={activeTab}
        hrefFor={(k) => {
          const t = STATUS_TABS.find((s) => s.key === k);
          return t?.status ? `/members?status=${encodeURIComponent(t.status)}` : '/members';
        }}
      />
      <Toolbar>
        <SearchInput placeholder="Search name, member number, ID or phone…" disabled={empty} />
        <DynamicFilterBar fields={fields} disabled={empty} />
        <Spacer />
        <ExportButton href="/api/export/members" params={{ q, filters: filtersRaw, sort: sortRaw }} disabled={!rows.length} />
        {canCreate ? (
          <Link href="/member-applications/new" className="btn">New member application</Link>
        ) : null}
      </Toolbar>

      <Card>
        {rows.length ? (
          <>
            <CardHead
              title={`${total.toLocaleString()} member${total === 1 ? '' : 's'}`}
              sub="Click a row to open the member 360 view"
            />
            <TableWrap>
              <thead>
                <tr>
                  <th><SortLink sortKey="member_no">Member no.</SortLink></th>
                  <th><SortLink sortKey="name">Name</SortLink></th>
                  <th><SortLink sortKey="identification_no">Identification No.</SortLink></th>
                  <th><SortLink sortKey="phone">Phone</SortLink></th>
                  <th><SortLink sortKey="gd1">{caption1}</SortLink></th>
                  <th><SortLink sortKey="gd2">{caption2}</SortLink></th>
                  <th className="num"><SortLink sortKey="total_savings">Savings</SortLink></th>
                  <th className="num"><SortLink sortKey="loan_balance">Loan balance</SortLink></th>
                  <th><SortLink sortKey="created_at">Date of Registration</SortLink></th>
                  <th><SortLink sortKey="status">Status</SortLink></th>
                </tr>
              </thead>
              <tbody>
                {rows.map((m) => (
                  <tr key={m.id}>
                    <td className="mono">
                      <Link href={`/members/${m.id}${activeStatus ? `?status=${encodeURIComponent(activeStatus)}` : ''}`}>{m.member_no}</Link>
                    </td>
                    <td>
                      <b>{m.first_name} {m.last_name}</b>
                      {m.kyc_verified ? null : <> <Pill tone="warn">KYC</Pill></>}
                    </td>
                    <td className="mono">{m.identification_no || '—'}</td>
                    <td>{m.phone || '—'}</td>
                    <td>{m.global_dimension_1_name || '—'}</td>
                    <td>{m.global_dimension_2_name || '—'}</td>
                    <td className="num"><Money cents={m.total_savings} decimals={0} /></td>
                    <td className="num">
                      {m.loan_balance ? <Money cents={m.loan_balance} decimals={0} /> : '—'}
                    </td>
                    <td>{formatDate(m.created_at)}</td>
                    <td><Pill status={m.status} /></td>
                  </tr>
                ))}
              </tbody>
            </TableWrap>
          </>
        ) : (
          <EmptyState icon="👥" title="No members match" sub="Try a different search or clear the filters" />
        )}
      </Card>
    </Page>
  );
}
