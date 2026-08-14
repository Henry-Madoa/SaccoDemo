import Link from 'next/link';
import { requirePerm, currentCan } from '@/lib/session';
import { listMembers, MEMBER_STATUSES } from '@/lib/members';
import { getDimensionCaptions } from '@/lib/org';
import { Page } from '@/components/layout/page';
import { Card, CardHead, EmptyState, Pill, TableWrap, Toolbar, Spacer } from '@/components/ui/primitives';
import { SearchInput, SelectFilter } from '@/components/ui/filters';
import { Money } from '@/components/ui/money';

export default async function MembersPage({ searchParams }: {
  searchParams: Promise<{ q?: string; status?: string }>;
}) {
  const user = await requirePerm('MEMBER:READ');
  const { q = '', status = '' } = await searchParams;
  const [{ rows, total }, canCreate, { caption1, caption2 }] = await Promise.all([
    listMembers({ search: q, status }),
    currentCan('MEMBER:CREATE'),
    getDimensionCaptions(),
  ]);

  return (
    <Page title="Members" crumb="Registry, KYC and member 360" user={user}>
      <Toolbar>
        <SearchInput placeholder="Search name, member number, ID or phone…" />
        <SelectFilter paramName="status" options={MEMBER_STATUSES} allLabel="All statuses" />
        <Spacer />
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
                  <th>Member no.</th><th>Name</th><th>Identification No.</th><th>Phone</th>
                  <th>{caption1}</th><th>{caption2}</th>
                  <th className="num">Savings</th><th className="num">Loan balance</th><th>Status</th>
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
