import Link from 'next/link';
import { requireAction, currentCanAction } from '@/lib/session';
import { listMembers, MEMBER_FILTER_FIELDS } from '@/lib/members';
import { listActiveMemberCategories, listActiveCounties, listActiveSubCounties, listActiveDimensionValues } from '@/lib/pool';
import { getDimensionCaptions } from '@/lib/org';
import { parseFilters } from '@/lib/listFilters';
import { parseSort } from '@/lib/listSort';
import { Page } from '@/components/layout/page';
import { Card, CardHead, EmptyState, Pill, TableWrap, Toolbar, Spacer } from '@/components/ui/primitives';
import { SearchInput } from '@/components/ui/filters';
import { DynamicFilterBar } from '@/components/ui/dynamic-filter';
import { SortLink } from '@/components/ui/sort-link';
import { Money } from '@/components/ui/money';
import { ExportButton } from '@/components/ui/export-button';

export default async function MembersPage({ searchParams }: {
  searchParams: Promise<{ q?: string; filters?: string; sort?: string }>;
}) {
  const user = await requireAction('MEMBERS_READ');
  const { q = '', filters: filtersRaw, sort: sortRaw } = await searchParams;
  const filters = parseFilters(filtersRaw);
  const sort = parseSort(sortRaw);
  const [{ rows, total }, canCreate, { caption1, caption2 }, categories, counties, subCounties, gd1Values, gd2Values] =
    await Promise.all([
      listMembers({ search: q, filters, sort }),
      currentCanAction('MEMBER_APPLICATIONS_CREATE'),
      getDimensionCaptions(),
      listActiveMemberCategories(),
      listActiveCounties(),
      listActiveSubCounties(),
      listActiveDimensionValues(1),
      listActiveDimensionValues(2),
    ]);
  const fields = MEMBER_FILTER_FIELDS.map((f) => (
    f.key === 'member_category_id' ? { ...f, options: categories.map((c) => ({ value: c.id, label: c.description })) }
      : f.key === 'county_id' ? { ...f, options: counties.map((c) => ({ value: c.id, label: c.name })) }
        : f.key === 'sub_county_id' ? { ...f, options: subCounties.map((c) => ({ value: c.id, label: c.name })) }
          : f.key === 'global_dimension_1_id' ? { ...f, label: caption1, options: gd1Values.map((d) => ({ value: d.id, label: `${d.code} — ${d.name}` })) }
            : f.key === 'global_dimension_2_id' ? { ...f, label: caption2, options: gd2Values.map((d) => ({ value: d.id, label: `${d.code} — ${d.name}` })) }
              : f
  ));

  return (
    <Page title="Members" crumb="Registry, KYC and member 360" user={user}>
      <Toolbar>
        <SearchInput placeholder="Search name, member number, ID or phone…" />
        <DynamicFilterBar fields={fields} />
        <Spacer />
        <ExportButton href="/api/export/members" params={{ q, filters: filtersRaw, sort: sortRaw }} />
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
                  <th><SortLink sortKey="national_id">Identification No.</SortLink></th>
                  <th><SortLink sortKey="phone">Phone</SortLink></th>
                  <th><SortLink sortKey="gd1">{caption1}</SortLink></th>
                  <th><SortLink sortKey="gd2">{caption2}</SortLink></th>
                  <th className="num"><SortLink sortKey="total_savings">Savings</SortLink></th>
                  <th className="num"><SortLink sortKey="loan_balance">Loan balance</SortLink></th>
                  <th><SortLink sortKey="status">Status</SortLink></th>
                </tr>
              </thead>
              <tbody>
                {rows.map((m) => (
                  <tr key={m.id}>
                    <td className="mono">
                      <Link href={`/members/${m.id}`}>{m.member_no}</Link>
                    </td>
                    <td>
                      <b>{m.first_name} {m.last_name}</b>
                      {m.kyc_verified ? null : <> <Pill tone="warn">KYC</Pill></>}
                    </td>
                    <td className="mono">{m.national_id || '—'}</td>
                    <td>{m.phone || '—'}</td>
                    <td>{m.global_dimension_1_name || '—'}</td>
                    <td>{m.global_dimension_2_name || '—'}</td>
                    <td className="num"><Money cents={m.total_savings} decimals={0} /></td>
                    <td className="num">
                      {m.loan_balance ? <Money cents={m.loan_balance} decimals={0} /> : '—'}
                    </td>
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
