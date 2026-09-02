import Link from 'next/link';
import { notFound } from 'next/navigation';
import { requireAction, currentCanAction } from '@/lib/session';
import {
  listInterAccountTransfers, hasAnyInterAccountTransfers, TRANSFER_FILTER_FIELDS, type TransferView,
} from '@/lib/interAccountTransfer';
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
import { NewTransferButton, SubmitButton, CancelApprovalButton, PostButton } from '../transfer-actions';

const TABS: TabDefinition[] = [
  { key: 'open', label: 'Open', tone: 'info' },
  { key: 'pending', label: 'Pending Approval', tone: 'warn' },
  { key: 'approved', label: 'Approved', tone: 'accent' },
  { key: 'processed', label: 'Processed', tone: 'ok' },
];

export default async function InterAccountTransfersPage({ params, searchParams }: {
  params: Promise<{ tab?: string[] }>;
  searchParams: Promise<{ q?: string; filters?: string; sort?: string }>;
}) {
  const user = await requireAction('INTER_ACCOUNT_TRANSFERS_READ');
  const { tab: segments } = await params;
  const { q = '', filters: filtersRaw, sort: sortRaw } = await searchParams;
  const filters = parseFilters(filtersRaw);
  const sort = parseSort(sortRaw);

  const requested = segments?.[0];
  if (requested && !TABS.some((t) => t.key === requested)) notFound();
  const tab = (requested ?? 'open') as TransferView;

  const [rows, empty, canCreate, canApprove, canPost, canCrossMember, members] = await Promise.all([
    listInterAccountTransfers({ view: tab, search: q, filters, sort }),
    hasAnyInterAccountTransfers(tab).then((any) => !any),
    currentCanAction('INTER_ACCOUNT_TRANSFERS_CREATE'),
    currentCanAction('INTER_ACCOUNT_TRANSFERS_APPROVE'),
    currentCanAction('INTER_ACCOUNT_TRANSFERS_POST'),
    currentCanAction('INTER_ACCOUNT_TRANSFERS_CROSS_MEMBER'),
    listActiveMembers(),
  ]);
  const fields = TRANSFER_FILTER_FIELDS.map((f) => (
    f.key === 'source_member_id' || f.key === 'destination_member_id'
      ? { ...f, options: members.map((m) => ({ value: m.id, label: `${m.member_no} — ${m.first_name} ${m.last_name}` })) }
      : f
  ));

  return (
    <Page title="Inter Account Transfers" crumb="Move cash between member deposit accounts" user={user}>
      <Tabs tabs={TABS} active={tab} hrefFor={(k) => `/inter-account-transfers/${k}`} />
      <Toolbar>
        <SearchInput placeholder="Search member, account or transfer no.…" disabled={empty} />
        <DynamicFilterBar fields={fields} disabled={empty} />
        <Spacer />
        {canCreate ? <NewTransferButton members={members} canCrossMember={canCrossMember} /> : null}
      </Toolbar>

      <Card>
        {rows.length ? (
          <TableWrap>
            <thead>
              <tr>
                <th><SortLink sortKey="no">No.</SortLink></th>
                <th><SortLink sortKey="source">From</SortLink></th>
                <th><SortLink sortKey="destination">To</SortLink></th>
                <th className="num"><SortLink sortKey="amount">Amount</SortLink></th>
                <th><SortLink sortKey="posting_date">Posting date</SortLink></th>
                <th><SortLink sortKey="status">Status</SortLink></th>
                <th className="num" />
              </tr>
            </thead>
            <tbody>
              {rows.map((t) => {
                const isOwn = t.created_by === user.username;
                return (
                  <tr key={t.no}>
                    <td className="mono"><Link href={`/inter-account-transfers/view/${t.no}?view=${tab}`}>{t.no}</Link></td>
                    <td>
                      <b>{t.source_first_name} {t.source_last_name}</b>
                      <div className="tiny mono">{t.source_account_no}</div>
                    </td>
                    <td>
                      <b>{t.destination_first_name} {t.destination_last_name}</b>
                      <div className="tiny mono">{t.destination_account_no}</div>
                    </td>
                    <td className="num"><Money cents={t.amount} /></td>
                    <td>{t.posting_date}</td>
                    <td><Pill status={t.status} /></td>
                    <td className="num">
                      <div className="inline" style={{ justifyContent: 'flex-end' }}>
                        {t.status === 'Open' && canCreate && isOwn ? <SubmitButton no={t.no} /> : null}
                        {t.status === 'Pending Approval' && canCreate && isOwn ? <CancelApprovalButton no={t.no} /> : null}
                        {t.status === 'Approved' && canPost ? <PostButton no={t.no} /> : null}
                      </div>
                    </td>
                  </tr>
                );
              })}
            </tbody>
          </TableWrap>
        ) : (
          <EmptyState icon="🔁" title="No transfers here"
            sub="An inter-account transfer moves cash from one member deposit account to another, through maker-checker approval." />
        )}
      </Card>
    </Page>
  );
}
