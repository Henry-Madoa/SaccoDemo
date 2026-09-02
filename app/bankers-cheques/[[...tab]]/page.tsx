import Link from 'next/link';
import { notFound } from 'next/navigation';
import { requireAction, currentCanAction } from '@/lib/session';
import {
  listBankersCheques, hasAnyBankersCheques, BANKERS_CHEQUE_FILTER_FIELDS, type BankersChequeView2,
} from '@/lib/bankersCheques';
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
import { NewChequeButton, SubmitButton, CancelApprovalButton, PostButton } from '../cheque-actions';

const TABS: TabDefinition[] = [
  { key: 'open', label: 'Open', tone: 'info' },
  { key: 'pending', label: 'Pending Approval', tone: 'warn' },
  { key: 'approved', label: 'Approved', tone: 'accent' },
  { key: 'processed', label: 'Processed', tone: 'ok' },
];

export default async function BankersChequesPage({ params, searchParams }: {
  params: Promise<{ tab?: string[] }>;
  searchParams: Promise<{ q?: string; filters?: string; sort?: string }>;
}) {
  const user = await requireAction('BANKERS_CHEQUES_READ');
  const { tab: segments } = await params;
  const { q = '', filters: filtersRaw, sort: sortRaw } = await searchParams;
  const filters = parseFilters(filtersRaw);
  const sort = parseSort(sortRaw);

  const requested = segments?.[0];
  if (requested && !TABS.some((t) => t.key === requested)) notFound();
  const tab = (requested ?? 'open') as BankersChequeView2;

  const [rows, empty, canCreate, canApprove, canPost, canManageTypes, members, chequeTypes] = await Promise.all([
    listBankersCheques({ view: tab, search: q, filters, sort }),
    hasAnyBankersCheques(tab).then((any) => !any),
    currentCanAction('BANKERS_CHEQUES_CREATE'),
    currentCanAction('BANKERS_CHEQUES_APPROVE'),
    currentCanAction('BANKERS_CHEQUES_POST'),
    currentCanAction('BANKERS_CHEQUES_TYPES_MANAGE'),
    listActiveMembers(),
    listActiveChequeTypes('BANKERS'),
  ]);
  const fields = BANKERS_CHEQUE_FILTER_FIELDS.map((f) => {
    if (f.key === 'member_id') {
      return { ...f, options: members.map((m) => ({ value: m.id, label: `${m.member_no} — ${m.first_name} ${m.last_name}` })) };
    }
    if (f.key === 'cheque_type_id') {
      return { ...f, options: chequeTypes.map((t) => ({ value: t.id, label: `${t.code} — ${t.description}` })) };
    }
    return f;
  });

  return (
    <Page title="Bankers Cheques" crumb="Sell a banker's cheque against a member's deposit account" user={user}>
      <Tabs tabs={TABS} active={tab} hrefFor={(k) => `/bankers-cheques/${k}`} />
      <Toolbar>
        <SearchInput placeholder="Search member, account, payee or cheque no.…" disabled={empty} />
        <DynamicFilterBar fields={fields} disabled={empty} />
        <Spacer />
        <Link href="/bankers-cheques/schedule" className="btn ghost sm">Print schedule</Link>
        {canManageTypes ? <Link href="/admin/pool/fosa/bankers-cheque-types" className="btn ghost sm">Cheque types</Link> : null}
        {canCreate ? <NewChequeButton members={members} chequeTypes={chequeTypes} /> : null}
      </Toolbar>

      <Card>
        {rows.length ? (
          <TableWrap>
            <thead>
              <tr>
                <th><SortLink sortKey="no">No.</SortLink></th>
                <th>Type</th>
                <th><SortLink sortKey="member">Member</SortLink></th>
                <th>Payee</th>
                <th className="num"><SortLink sortKey="amount">Amount</SortLink></th>
                <th className="num"><SortLink sortKey="net_amount">Net</SortLink></th>
                <th><SortLink sortKey="posting_date">Posting date</SortLink></th>
                <th><SortLink sortKey="status">Status</SortLink></th>
                <th className="num" />
              </tr>
            </thead>
            <tbody>
              {rows.map((c) => {
                const isOwn = c.created_by === user.username;
                return (
                  <tr key={c.no}>
                    <td className="mono"><Link href={`/bankers-cheques/view/${c.no}?view=${tab}`}>{c.no}</Link></td>
                    <td className="mono">{c.cheque_type_code}</td>
                    <td><b>{c.member_first_name} {c.member_last_name}</b><div className="tiny mono">{c.account_no}</div></td>
                    <td className="tiny">{c.payee_details || '—'}</td>
                    <td className="num"><Money cents={c.amount} /></td>
                    <td className="num"><Money cents={c.net_amount} /></td>
                    <td>{c.posting_date}</td>
                    <td><Pill status={c.status} /></td>
                    <td className="num">
                      <div className="inline" style={{ justifyContent: 'flex-end' }}>
                        {c.status === 'Open' && canCreate && isOwn ? <SubmitButton no={c.no} /> : null}
                        {c.status === 'Pending Approval' && canCreate && isOwn ? <CancelApprovalButton no={c.no} /> : null}
                        {c.status === 'Approved' && canPost ? <PostButton no={c.no} /> : null}
                      </div>
                    </td>
                  </tr>
                );
              })}
            </tbody>
          </TableWrap>
        ) : (
          <EmptyState icon="🏦" title="No banker's cheques here"
            sub="A banker's cheque is sold against a member's deposit account through maker-checker approval." />
        )}
      </Card>
    </Page>
  );
}
