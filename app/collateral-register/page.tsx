import Link from 'next/link';
import { requireAction } from '@/lib/session';
import {
  listCollateralRegister, hasAnyCollateralRegister, COLLATERAL_REGISTER_FILTER_FIELDS,
} from '@/lib/collateralRegister';
import { listActiveMembers } from '@/lib/members';
import { listCollateralTypes } from '@/lib/collateralTypes';
import { COLLATERAL_CATEGORIES } from '@/lib/constants';
import { parseFilters } from '@/lib/listFilters';
import { parseSort } from '@/lib/listSort';
import { Page } from '@/components/layout/page';
import { Card, EmptyState, Pill, TableWrap, Toolbar, Spacer } from '@/components/ui/primitives';
import { SearchInput } from '@/components/ui/filters';
import { DynamicFilterBar } from '@/components/ui/dynamic-filter';
import { SortLink } from '@/components/ui/sort-link';
import { Money } from '@/components/ui/money';
import { ExportButton } from '@/components/ui/export-button';

export default async function CollateralRegisterPage({ searchParams }: {
  searchParams: Promise<{ q?: string; filters?: string; sort?: string }>;
}) {
  const user = await requireAction('COLLATERAL_REGISTER_READ');
  const { q = '', filters: filtersRaw, sort: sortRaw } = await searchParams;
  const filters = parseFilters(filtersRaw);
  const sort = parseSort(sortRaw);

  const [rows, empty, members, types] = await Promise.all([
    listCollateralRegister({ search: q, filters, sort }),
    hasAnyCollateralRegister().then((any) => !any),
    listActiveMembers(), listCollateralTypes(),
  ]);
  const fields = COLLATERAL_REGISTER_FILTER_FIELDS.map((f) => (
    f.key === 'member_id' ? { ...f, options: members.map((m) => ({ value: m.id, label: `${m.member_no} — ${m.first_name} ${m.last_name}` })) }
      : f.key === 'collateral_type_id' ? { ...f, options: types.map((t) => ({ value: t.id, label: t.code })) }
        : f.key === 'category' ? { ...f, options: COLLATERAL_CATEGORIES.map((c) => ({ value: c.value, label: c.label })) }
          : f
  ));

  const totals = rows.reduce((a, r) => ({
    value: a.value + r.collateral_value, guarantee: a.guarantee + r.guarantee,
    linked: a.linked + r.linked_loan_balance, available: a.available + r.collateral_balance,
  }), { value: 0, guarantee: 0, linked: 0, available: 0 });

  return (
    <Page title="Collateral Register" crumb="The live, read-only ledger of accepted collateral" user={user}>
      <div className="grid g4 stack-2">
        <div className="stat"><div className="label">Registered items</div><div className="value">{rows.length}</div></div>
        <div className="stat"><div className="label">Total guarantee</div><div className="value"><Money cents={totals.guarantee} decimals={0} /></div></div>
        <div className="stat"><div className="label">Consumed by loans</div><div className="value"><Money cents={totals.linked} decimals={0} /></div></div>
        <div className="stat"><div className="label">Available cover</div><div className="value"><Money cents={totals.available} decimals={0} /></div></div>
      </div>

      <Toolbar>
        <SearchInput placeholder="Search member name, no., serial no. or register no.…" disabled={empty} />
        <DynamicFilterBar fields={fields} disabled={empty} />
        <Spacer />
        <ExportButton href="/api/export/collateral-register" params={{ q, filters: filtersRaw, sort: sortRaw }} disabled={!rows.length} />
      </Toolbar>

      <Card>
        {rows.length ? (
          <TableWrap>
            <thead>
              <tr>
                <th><SortLink sortKey="no">No.</SortLink></th>
                <th><SortLink sortKey="member">Member</SortLink></th>
                <th><SortLink sortKey="collateral_type">Type</SortLink></th>
                <th>Serial / Reg. No.</th>
                <th className="num"><SortLink sortKey="collateral_value">Value</SortLink></th>
                <th className="num"><SortLink sortKey="guarantee">Guarantee</SortLink></th>
                <th className="num"><SortLink sortKey="linked_loan_balance">Linked balance</SortLink></th>
                <th className="num"><SortLink sortKey="collateral_balance">Available cover</SortLink></th>
                <th><SortLink sortKey="status">Status</SortLink></th><th className="num" />
              </tr>
            </thead>
            <tbody>
              {rows.map((r) => (
                <tr key={r.no}>
                  <td className="mono"><Link href={`/collateral-register/view/${r.no}`}>{r.no}</Link></td>
                  <td>
                    <b>{r.member_first_name} {r.member_last_name}</b>
                    <div className="tiny mono">{r.member_no}</div>
                  </td>
                  <td>{r.collateral_type_code || '—'}</td>
                  <td className="mono tiny">{r.serial_reg_no || '—'}</td>
                  <td className="num"><Money cents={r.collateral_value} decimals={0} /></td>
                  <td className="num"><Money cents={r.guarantee} decimals={0} /></td>
                  <td className="num"><Money cents={r.linked_loan_balance} decimals={0} /></td>
                  <td className="num"><Money cents={r.collateral_balance} decimals={0} /></td>
                  <td><Pill status={r.status} /></td>
                  <td className="num">
                    <Link href={`/collateral-applications/view/${r.no}`} className="btn sm ghost">View application</Link>
                  </td>
                </tr>
              ))}
            </tbody>
          </TableWrap>
        ) : <EmptyState icon="🗂" title="No collateral registered yet" sub="Registered collateral appears here once an application is posted" />}
      </Card>
    </Page>
  );
}
