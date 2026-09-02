import Link from 'next/link';
import { notFound } from 'next/navigation';
import { requireAction, currentCanAction } from '@/lib/session';
import {
  listTellerTransactions, hasAnyTellerTransactions, TELLER_TRANSACTION_FILTER_FIELDS, type TellerTxnView,
} from '@/lib/tellerTransactions';
import { tellerSetupForUser } from '@/lib/tellerSetup';
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
import { NewTellerTransactionButton, SubmitButton, CancelApprovalButton, PostButton } from '../teller-transaction-actions';

const TABS: TabDefinition[] = [
  { key: 'open', label: 'Open', tone: 'info' },
  { key: 'pending', label: 'Pending Approval', tone: 'warn' },
  { key: 'approved', label: 'Approved', tone: 'accent' },
  { key: 'posted', label: 'Posted', tone: 'ok' },
];

export default async function TellerTransactionsPage({ params, searchParams }: {
  params: Promise<{ tab?: string[] }>;
  searchParams: Promise<{ q?: string; filters?: string; sort?: string }>;
}) {
  const user = await requireAction('TELLER_TRANSACTIONS_READ');
  const { tab: segments } = await params;
  const { q = '', filters: filtersRaw, sort: sortRaw } = await searchParams;
  const filters = parseFilters(filtersRaw);
  const sort = parseSort(sortRaw);

  const requested = segments?.[0];
  if (requested && !TABS.some((t) => t.key === requested)) notFound();
  const tab = (requested ?? 'open') as TellerTxnView;

  const [docs, empty, canCreate, canPost, members, till] = await Promise.all([
    listTellerTransactions({ view: tab, search: q, filters, sort }),
    hasAnyTellerTransactions(tab).then((any) => !any),
    currentCanAction('TELLER_TRANSACTIONS_CREATE'),
    currentCanAction('TELLER_TRANSACTIONS_POST'),
    listActiveMembers(),
    tellerSetupForUser(user.username),
  ]);
  const fields = TELLER_TRANSACTION_FILTER_FIELDS.map((f) => (
    f.key === 'member_id'
      ? { ...f, options: members.map((m) => ({ value: m.id, label: `${m.member_no} — ${m.first_name} ${m.last_name}` })) }
      : f
  ));

  return (
    <Page title="Cash Deposits &amp; Withdrawals" crumb="Over-the-counter member cash transactions" user={user}>
      <Tabs tabs={TABS} active={tab} hrefFor={(k) => `/teller-transactions/${k}`} />
      <Toolbar>
        <SearchInput placeholder="Search member, account or document no.…" disabled={empty} />
        <DynamicFilterBar fields={fields} disabled={empty} />
        <Spacer />
        {canCreate && till ? <NewTellerTransactionButton members={members} /> : null}
      </Toolbar>

      {canCreate && !till ? (
        <Card>
          <EmptyState icon="🔒" title="You are not set up as a teller"
            sub="Ask an administrator to add a Teller Setup for your user (Admin Centre → Teller Setup)." />
        </Card>
      ) : null}

      <Card>
        {docs.length ? (
          <TableWrap>
            <thead>
              <tr>
                <th><SortLink sortKey="no">No.</SortLink></th>
                <th>Type</th>
                <th><SortLink sortKey="member">Member</SortLink></th>
                <th>Account</th>
                <th className="num"><SortLink sortKey="amount">Amount</SortLink></th>
                <th><SortLink sortKey="status">Status</SortLink></th>
                <th className="num" />
              </tr>
            </thead>
            <tbody>
              {docs.map((d) => {
                const isOwn = d.created_by === user.username;
                return (
                  <tr key={d.no}>
                    <td className="mono"><Link href={`/teller-transactions/view/${d.no}?view=${tab}`}>{d.no}</Link></td>
                    <td>{d.transaction_type === 'CASH_DEPOSIT' ? 'Deposit' : 'Withdrawal'}</td>
                    <td><b>{d.member_first_name} {d.member_last_name}</b><div className="tiny mono">{d.member_no}</div></td>
                    <td className="mono">{d.account_no}</td>
                    <td className="num"><Money cents={d.amount} /></td>
                    <td>
                      <Pill status={d.status} />
                      {d.status === 'Open' && d.approval_required ? <Pill tone="warn">Needs approval</Pill> : null}
                    </td>
                    <td className="num">
                      <div className="inline" style={{ justifyContent: 'flex-end' }}>
                        {d.status === 'Open' && d.approval_required && canCreate && isOwn ? <SubmitButton no={d.no} /> : null}
                        {d.status === 'Open' && !d.approval_required && canPost ? <PostButton no={d.no} /> : null}
                        {d.status === 'Pending Approval' && canCreate && isOwn ? <CancelApprovalButton no={d.no} /> : null}
                        {d.status === 'Approved' && canPost ? <PostButton no={d.no} /> : null}
                      </div>
                    </td>
                  </tr>
                );
              })}
            </tbody>
          </TableWrap>
        ) : <EmptyState icon="💵" title="No teller transactions here" sub="Try a different tab or clear the search" />}
      </Card>
    </Page>
  );
}
