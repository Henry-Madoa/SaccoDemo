import Link from 'next/link';
import { notFound } from 'next/navigation';
import { requireAction, currentCanAction } from '@/lib/session';
import {
  listMemberChargings, hasAnyMemberChargings, MEMBER_CHARGING_FILTER_FIELDS, type MemberChargingView,
} from '@/lib/memberCharging';
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
import { ExportButton } from '@/components/ui/export-button';
import { Money } from '@/components/ui/money';
import { NewMemberChargingButton, DeleteButton, PostButton } from '../member-charging-actions';

const TABS: TabDefinition[] = [
  { key: 'open', label: 'Open', tone: 'info' },
  { key: 'posted', label: 'Posted', tone: 'ok' },
];

export default async function MemberChargingsPage({ params, searchParams }: {
  params: Promise<{ tab?: string[] }>;
  searchParams: Promise<{ q?: string; filters?: string; sort?: string; new?: string }>;
}) {
  const user = await requireAction('MEMBER_CHARGING_READ');
  const { tab: segments } = await params;
  const { q = '', filters: filtersRaw, sort: sortRaw, new: presetMember } = await searchParams;
  const filters = parseFilters(filtersRaw);
  const sort = parseSort(sortRaw);

  const requested = segments?.[0];
  if (requested && !TABS.some((t) => t.key === requested)) notFound();
  const tab = (requested ?? 'open') as MemberChargingView;

  const [documents, empty, canCreate, canPost, members] = await Promise.all([
    listMemberChargings({ view: tab, search: q, filters, sort }),
    hasAnyMemberChargings(tab).then((any) => !any),
    currentCanAction('MEMBER_CHARGING_CREATE'), currentCanAction('MEMBER_CHARGING_POST'),
    listActiveMembers(),
  ]);
  const fields = MEMBER_CHARGING_FILTER_FIELDS.map((f) => (
    f.key === 'member_id' ? { ...f, options: members.map((m) => ({ value: m.id, label: `${m.member_no} — ${m.first_name} ${m.last_name}` })) }
      : f
  ));

  return (
    <Page title="Member Charging" crumb="Ad-hoc charges posted straight against a member's own withdrawable deposit account" user={user}>
      <Tabs tabs={TABS} active={tab} hrefFor={(k) => `/member-chargings/${k}`} />
      <Toolbar>
        <SearchInput placeholder="Search member name, no., account no. or document no.…" disabled={empty} />
        <DynamicFilterBar fields={fields} disabled={empty} />
        <Spacer />
        <ExportButton href="/api/export/member-chargings" params={{ q, view: tab, filters: filtersRaw, sort: sortRaw }} disabled={!documents.length} />
        {canCreate ? (
          <NewMemberChargingButton members={members} presetMemberId={presetMember ? Number(presetMember) : null} />
        ) : null}
      </Toolbar>

      <Card>
        {documents.length ? (
          <TableWrap>
            <thead>
              <tr>
                <th><SortLink sortKey="no">No.</SortLink></th>
                <th><SortLink sortKey="member">Member</SortLink></th>
                <th><SortLink sortKey="source_account_no">Source account</SortLink></th>
                <th className="num"><SortLink sortKey="amount_charged">Amount</SortLink></th>
                <th><SortLink sortKey="status">Status</SortLink></th><th className="num" />
              </tr>
            </thead>
            <tbody>
              {documents.map((d) => {
                const isOwn = d.created_by === user.username;
                const canEditThis = canCreate && (!canPost || isOwn);
                return (
                <tr key={d.no}>
                  <td className="mono"><Link href={`/member-chargings/view/${d.no}?view=${tab}`}>{d.no}</Link></td>
                  <td>
                    <b>{d.member_first_name} {d.member_last_name}</b>
                    <div className="tiny mono">{d.member_no}</div>
                  </td>
                  <td>
                    <span className="mono">{d.source_account_no}</span>
                    <div className="tiny muted-cell">{d.transaction_charge_code} — {d.transaction_charge_description}</div>
                  </td>
                  <td className="num"><Money cents={d.amount_charged} /></td>
                  <td><Pill status={d.status} /></td>
                  <td className="num">
                    <div className="inline" style={{ justifyContent: 'flex-end' }}>
                      {d.status === 'Open' && canPost ? <PostButton no={d.no} amount={d.amount_charged} /> : null}
                      {d.status === 'Open' && canEditThis ? <DeleteButton no={d.no} /> : null}
                      <Link href={`/members/${d.member_id}`} className="btn sm ghost">View member</Link>
                    </div>
                  </td>
                </tr>
                );
              })}
            </tbody>
          </TableWrap>
        ) : <EmptyState icon="🧾" title="No member charging documents here" sub="Try a different tab or clear the search" />}
      </Card>
    </Page>
  );
}
