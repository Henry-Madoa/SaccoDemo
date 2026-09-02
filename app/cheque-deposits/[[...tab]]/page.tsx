import Link from 'next/link';
import { notFound } from 'next/navigation';
import { requireAction, currentCanAction } from '@/lib/session';
import {
  listChequeDeposits, hasAnyChequeDeposits, CHEQUE_DEPOSIT_FILTER_FIELDS, type ChequeDepositTab,
} from '@/lib/chequeDeposits';
import { listActiveChequeTypes } from '@/lib/chequeTypes';
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
import {
  NewDepositButton, SubmitButton, CancelApprovalButton, ClearButton, ExpressClearButton, ReleaseHoldButton,
} from '../cheque-deposit-actions';

const TABS: TabDefinition[] = [
  { key: 'open', label: 'Open', tone: 'info' },
  { key: 'pending', label: 'Pending Approval', tone: 'warn' },
  { key: 'approved', label: 'Awaiting Clearance', tone: 'accent' },
  { key: 'cleared', label: 'Cleared', tone: 'ok' },
  { key: 'bounced', label: 'Bounced', tone: 'bad' },
];

export default async function ChequeDepositsPage({ params, searchParams }: {
  params: Promise<{ tab?: string[] }>;
  searchParams: Promise<{ q?: string; filters?: string; sort?: string }>;
}) {
  const user = await requireAction('CHEQUE_DEPOSITS_READ');
  const { tab: segments } = await params;
  const { q = '', filters: filtersRaw, sort: sortRaw } = await searchParams;
  const filters = parseFilters(filtersRaw);
  const sort = parseSort(sortRaw);

  const requested = segments?.[0];
  if (requested && !TABS.some((t) => t.key === requested)) notFound();
  const tab = (requested ?? 'open') as ChequeDepositTab;

  const [rows, empty, canCreate, canClear, canManageTypes, members, chequeTypes] = await Promise.all([
    listChequeDeposits({ view: tab, search: q, filters, sort }),
    hasAnyChequeDeposits(tab).then((any) => !any),
    currentCanAction('CHEQUE_DEPOSITS_CREATE'),
    currentCanAction('CHEQUE_DEPOSITS_CLEAR'),
    currentCanAction('CHEQUE_DEPOSITS_TYPES_MANAGE'),
    listActiveMembers(),
    listActiveChequeTypes('EXTERNAL'),
  ]);
  const fields = CHEQUE_DEPOSIT_FILTER_FIELDS.map((f) => {
    if (f.key === 'member_id') {
      return { ...f, options: members.map((m) => ({ value: m.id, label: `${m.member_no} — ${m.first_name} ${m.last_name}` })) };
    }
    if (f.key === 'cheque_type_id') {
      return { ...f, options: chequeTypes.map((t) => ({ value: t.id, label: `${t.code} — ${t.description}` })) };
    }
    return f;
  });

  return (
    <Page title="Cheque Deposits" crumb="Bank a third-party cheque against a member's account" user={user}>
      <Tabs tabs={TABS} active={tab} hrefFor={(k) => `/cheque-deposits/${k}`} />
      <Toolbar>
        <SearchInput placeholder="Search member, account, cheque no. or bank…" disabled={empty} />
        <DynamicFilterBar fields={fields} disabled={empty} />
        <Spacer />
        {canManageTypes ? <Link href="/admin/pool/fosa/external-cheque-types" className="btn ghost sm">Cheque types</Link> : null}
        {canCreate ? <NewDepositButton members={members} chequeTypes={chequeTypes} /> : null}
      </Toolbar>

      <Card>
        {rows.length ? (
          <TableWrap>
            <thead>
              <tr>
                <th><SortLink sortKey="no">No.</SortLink></th>
                <th>Type</th>
                <th><SortLink sortKey="member">Member</SortLink></th>
                <th>Cheque</th>
                <th className="num"><SortLink sortKey="amount">Amount</SortLink></th>
                <th><SortLink sortKey="deposit_date">Deposited</SortLink></th>
                <th><SortLink sortKey="maturity_date">Matures</SortLink></th>
                <th><SortLink sortKey="status">Status</SortLink></th>
                <th className="num" />
              </tr>
            </thead>
            <tbody>
              {rows.map((d) => {
                const isOwn = d.created_by === user.username;
                return (
                  <tr key={d.no}>
                    <td className="mono"><Link href={`/cheque-deposits/view/${d.no}?view=${tab}`}>{d.no}</Link></td>
                    <td className="mono">{d.cheque_type_code}</td>
                    <td><b>{d.member_first_name} {d.member_last_name}</b><div className="tiny mono">{d.account_no}</div></td>
                    <td className="mono">{d.cheque_no || '—'}<div className="tiny muted-cell">{d.drawer_bank || ''}</div></td>
                    <td className="num"><Money cents={d.amount} /></td>
                    <td>{d.deposit_date}</td>
                    <td>{d.maturity_date}{d.express_cheque ? <span className="tiny muted-cell"> express</span> : null}</td>
                    <td><Pill status={d.status} /></td>
                    <td className="num">
                      <div className="inline" style={{ justifyContent: 'flex-end' }}>
                        {d.status === 'Open' && canCreate && isOwn ? <SubmitButton no={d.no} /> : null}
                        {d.status === 'Pending Approval' && canCreate && isOwn ? <CancelApprovalButton no={d.no} /> : null}
                        {d.status === 'Approved' && canClear && d.matured ? <ClearButton no={d.no} /> : null}
                        {d.status === 'Approved' && canClear && !d.matured && d.express_cheque ? <ExpressClearButton no={d.no} /> : null}
                        {d.status === 'Cleared' && canClear && d.express_hold_amount > 0 && d.matured ? <ReleaseHoldButton no={d.no} /> : null}
                      </div>
                    </td>
                  </tr>
                );
              })}
            </tbody>
          </TableWrap>
        ) : (
          <EmptyState icon="🧾" title="No cheque deposits here"
            sub="A cheque deposit banks a third-party cheque; it clears to the member's account on its maturity date." />
        )}
      </Card>
    </Page>
  );
}
