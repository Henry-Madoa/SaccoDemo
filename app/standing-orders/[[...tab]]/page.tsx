import Link from 'next/link';
import { notFound } from 'next/navigation';
import { requireAction, currentCanAction } from '@/lib/session';
import {
  listStandingOrders, hasAnyStandingOrders, STANDING_ORDER_FILTER_FIELDS, type StandingOrderView,
} from '@/lib/standingOrders';
import { listActiveMembers } from '@/lib/members';
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
import { STANDING_ORDER_CLASSES } from '@/lib/constants';
import {
  NewStandingOrderButton, SubmitButton, CancelApprovalButton, TerminateButton, RunNowButton,
} from '../standing-order-actions';

const TABS: TabDefinition[] = [
  { key: 'open', label: 'Open', tone: 'info' },
  { key: 'pending', label: 'Pending Approval', tone: 'warn' },
  { key: 'live', label: 'Live', tone: 'ok' },
  { key: 'terminated', label: 'Terminated', tone: 'accent' },
];

export default async function StandingOrdersPage({ params, searchParams }: {
  params: Promise<{ tab?: string[] }>;
  searchParams: Promise<{ q?: string; filters?: string; sort?: string }>;
}) {
  const user = await requireAction('STANDING_ORDERS_READ');
  const { tab: segments } = await params;
  const { q = '', filters: filtersRaw, sort: sortRaw } = await searchParams;
  const filters = parseFilters(filtersRaw);
  const sort = parseSort(sortRaw);

  const requested = segments?.[0];
  if (requested && !TABS.some((t) => t.key === requested)) notFound();
  const tab = (requested ?? 'open') as StandingOrderView;

  const [orders, empty, canCreate, canApprove, canRun, members] = await Promise.all([
    listStandingOrders({ view: tab, search: q, filters, sort }),
    hasAnyStandingOrders(tab).then((any) => !any),
    currentCanAction('STANDING_ORDERS_CREATE'), currentCanAction('STANDING_ORDERS_APPROVE'),
    currentCanAction('STANDING_ORDERS_RUN'),
    listActiveMembers(),
  ]);
  const fields = STANDING_ORDER_FILTER_FIELDS.map((f) => (
    f.key === 'member_id' ? { ...f, options: members.map((m) => ({ value: m.id, label: `${m.member_no} — ${m.first_name} ${m.last_name}` })) }
      : f
  ));

  return (
    <Page title="Standing Orders" crumb="Recurring transfers and loan repayments — runs itself once approved" user={user}>
      <Tabs tabs={TABS} active={tab} hrefFor={(k) => `/standing-orders/${k}`} />
      <Toolbar>
        <SearchInput placeholder="Search member name, no. or order no.…" disabled={empty} />
        <DynamicFilterBar fields={fields} disabled={empty} />
        <Spacer />
        {tab === 'live' && canRun ? <RunNowButton disabled={!orders.length} /> : null}
        {canCreate ? <NewStandingOrderButton members={members} /> : null}
      </Toolbar>

      <Card>
        {orders.length ? (
          <TableWrap>
            <thead>
              <tr>
                <th><SortLink sortKey="no">No.</SortLink></th>
                <th><SortLink sortKey="member">Member</SortLink></th>
                <th>Class</th>
                <th>Destination</th>
                <th className="num"><SortLink sortKey="amount">Amount</SortLink></th>
                <th><SortLink sortKey="status">Status</SortLink></th><th className="num" />
              </tr>
            </thead>
            <tbody>
              {orders.map((o) => {
                const isOwnRequest = o.created_by === user.username;
                const canEditThis = canCreate && (!canApprove || isOwnRequest);
                return (
                <tr key={o.no}>
                  <td className="mono"><Link href={`/standing-orders/view/${o.no}?view=${tab}`}>{o.no}</Link></td>
                  <td>
                    <b>{o.member_first_name} {o.member_last_name}</b>
                    <div className="tiny mono">{o.member_no}</div>
                  </td>
                  <td>{STANDING_ORDER_CLASSES.find((c) => c.value === o.standing_order_class)?.label ?? o.standing_order_class}</td>
                  <td>
                    {o.standing_order_class === 'INTERNAL'
                      ? <>{o.destination_account_no}<div className="tiny muted-cell">{o.destination_first_name} {o.destination_last_name}</div></>
                      : <span className="mono">{o.destination_loan_no}</span>}
                  </td>
                  <td className="num">{o.amount_type === 'FIXED' ? <Money cents={o.amount} /> : o.amount_type === 'AMOUNT_BASED' ? <Money cents={o.amount_limit} /> : '—'}</td>
                  <td>
                    <Pill status={o.status} />
                    {o.status === 'Approved' && o.terminated ? <Pill tone="">Terminated</Pill> : null}
                    {o.status === 'Approved' && !o.terminated && o.freezed ? <Pill tone="warn">Frozen</Pill> : null}
                  </td>
                  <td className="num">
                    <div className="inline" style={{ justifyContent: 'flex-end' }}>
                      {o.status === 'Open' && canEditThis ? <SubmitButton no={o.no} /> : null}
                      {o.status === 'Pending Approval' && canCreate && isOwnRequest ? (
                        <CancelApprovalButton no={o.no} />
                      ) : null}
                      {o.status === 'Approved' && !o.terminated && canApprove ? <TerminateButton no={o.no} /> : null}
                      <Link href={`/members/${o.member_id}`} className="btn sm ghost">View member</Link>
                    </div>
                  </td>
                </tr>
                );
              })}
            </tbody>
          </TableWrap>
        ) : <EmptyState icon="🔄" title="No standing orders here" sub="Try a different tab or clear the search" />}
      </Card>
    </Page>
  );
}
