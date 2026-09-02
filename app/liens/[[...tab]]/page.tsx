import Link from 'next/link';
import { notFound } from 'next/navigation';
import { requireAction, currentCanAction } from '@/lib/session';
import { listLiens, hasAnyLiens, LIEN_FILTER_FIELDS, type LienView } from '@/lib/liens';
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
import { NewLienButton, SubmitButton, CancelApprovalButton, ProcessButton } from '../lien-actions';

const TABS: TabDefinition[] = [
  { key: 'open', label: 'Open', tone: 'info' },
  { key: 'pending', label: 'Pending Approval', tone: 'warn' },
  { key: 'approved', label: 'Approved', tone: 'accent' },
  { key: 'processed', label: 'Processed', tone: 'ok' },
];

export default async function LiensPage({ params, searchParams }: {
  params: Promise<{ tab?: string[] }>;
  searchParams: Promise<{ q?: string; filters?: string; sort?: string }>;
}) {
  const user = await requireAction('LIENS_READ');
  const { tab: segments } = await params;
  const { q = '', filters: filtersRaw, sort: sortRaw } = await searchParams;
  const filters = parseFilters(filtersRaw);
  const sort = parseSort(sortRaw);

  const requested = segments?.[0];
  if (requested && !TABS.some((t) => t.key === requested)) notFound();
  const tab = (requested ?? 'open') as LienView;

  const [rows, empty, canCreate, canApprove, canProcess, members] = await Promise.all([
    listLiens({ view: tab, search: q, filters, sort }),
    hasAnyLiens(tab).then((any) => !any),
    currentCanAction('LIENS_CREATE'),
    currentCanAction('LIENS_APPROVE'),
    currentCanAction('LIENS_POST'),
    listActiveMembers(),
  ]);
  const fields = LIEN_FILTER_FIELDS.map((f) => (
    f.key === 'member_id'
      ? { ...f, options: members.map((m) => ({ value: m.id, label: `${m.member_no} — ${m.first_name} ${m.last_name}` })) }
      : f
  ));

  return (
    <Page title="Liens & Holds" crumb="Hold or release part of a member's deposit balance" user={user}>
      <Tabs tabs={TABS} active={tab} hrefFor={(k) => `/liens/${k}`} />
      <Toolbar>
        <SearchInput placeholder="Search member, account or lien no.…" disabled={empty} />
        <DynamicFilterBar fields={fields} disabled={empty} />
        <Spacer />
        {canCreate ? <NewLienButton members={members} /> : null}
      </Toolbar>

      <Card>
        {rows.length ? (
          <TableWrap>
            <thead>
              <tr>
                <th><SortLink sortKey="no">No.</SortLink></th>
                <th>Type</th>
                <th><SortLink sortKey="member">Member</SortLink></th>
                <th>Account</th>
                <th className="num"><SortLink sortKey="amount">Amount</SortLink></th>
                <th><SortLink sortKey="posting_date">Posting date</SortLink></th>
                <th><SortLink sortKey="status">Status</SortLink></th>
                <th className="num" />
              </tr>
            </thead>
            <tbody>
              {rows.map((l) => {
                const isOwn = l.created_by === user.username;
                return (
                  <tr key={l.no}>
                    <td className="mono"><Link href={`/liens/view/${l.no}?view=${tab}`}>{l.no}</Link></td>
                    <td>
                      <Pill tone={l.transaction_type === 'HOLD' ? 'warn' : 'ok'}>
                        {l.transaction_type === 'HOLD' ? 'Hold' : 'Release'}
                      </Pill>
                    </td>
                    <td><b>{l.member_first_name} {l.member_last_name}</b><div className="tiny mono">{l.member_no}</div></td>
                    <td className="mono">{l.account_no}<div className="tiny muted-cell">{l.account_product_name}</div></td>
                    <td className="num"><Money cents={l.amount} /></td>
                    <td>{l.posting_date}</td>
                    <td><Pill status={l.status} /></td>
                    <td className="num">
                      <div className="inline" style={{ justifyContent: 'flex-end' }}>
                        {l.status === 'Open' && canCreate && isOwn ? <SubmitButton no={l.no} /> : null}
                        {l.status === 'Pending Approval' && canCreate && isOwn ? <CancelApprovalButton no={l.no} /> : null}
                        {l.status === 'Approved' && canProcess ? <ProcessButton no={l.no} type={l.transaction_type} /> : null}
                      </div>
                    </td>
                  </tr>
                );
              })}
            </tbody>
          </TableWrap>
        ) : (
          <EmptyState icon="🔒" title="No liens here"
            sub="A Hold freezes part of a member's deposit; a Release lifts it. No ledger entry is posted." />
        )}
      </Card>
    </Page>
  );
}
