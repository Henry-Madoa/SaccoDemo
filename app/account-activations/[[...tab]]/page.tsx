import Link from 'next/link';
import { notFound } from 'next/navigation';
import { requireAction, currentCanAction } from '@/lib/session';
import {
  listAccountActivationRequests, ACCOUNT_ACTIVATION_FILTER_FIELDS, type AccountActivationView,
} from '@/lib/accountActivation';
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
import {
  NewAccountActivationButton, SubmitButton, CancelApprovalButton, ProcessButton,
} from '../account-activation-actions';

const TABS: TabDefinition[] = [
  { key: 'open', label: 'Open', tone: 'info' },
  { key: 'pending', label: 'Pending Approval', tone: 'warn' },
  { key: 'approved', label: 'Approved', tone: 'ok' },
  { key: 'processed', label: 'Processed', tone: 'accent' },
];

export default async function AccountActivationsPage({ params, searchParams }: {
  params: Promise<{ tab?: string[] }>;
  searchParams: Promise<{ q?: string; filters?: string; sort?: string; new?: string }>;
}) {
  const user = await requireAction('ACCOUNT_ACTIVATION_READ');
  const { tab: segments } = await params;
  const { q = '', filters: filtersRaw, sort: sortRaw, new: presetMember } = await searchParams;
  const filters = parseFilters(filtersRaw);
  const sort = parseSort(sortRaw);

  const requested = segments?.[0];
  if (requested && !TABS.some((t) => t.key === requested)) notFound();
  const tab = (requested ?? 'open') as AccountActivationView;

  const [requests, canCreate, canApprove, members] = await Promise.all([
    listAccountActivationRequests({ view: tab, search: q, filters, sort }),
    currentCanAction('ACCOUNT_ACTIVATION_CREATE'), currentCanAction('ACCOUNT_ACTIVATION_APPROVE'),
    listActiveMembers(),
  ]);
  const fields = ACCOUNT_ACTIVATION_FILTER_FIELDS.map((f) => (
    f.key === 'member_id' ? { ...f, options: members.map((m) => ({ value: m.id, label: `${m.member_no} — ${m.first_name} ${m.last_name}` })) }
      : f
  ));

  return (
    <Page title="Account Activation" crumb="Reactivating inactive savings accounts, from request through to approval" user={user}>
      <Tabs tabs={TABS} active={tab} hrefFor={(k) => `/account-activations/${k}`} />
      <Toolbar>
        <SearchInput placeholder="Search member name, no., account no. or request no.…" />
        <DynamicFilterBar fields={fields} />
        <Spacer />
        <ExportButton href="/api/export/account-activations" params={{ q, view: tab, filters: filtersRaw, sort: sortRaw }} disabled={!requests.length} />
        {canCreate ? (
          <NewAccountActivationButton members={members} presetMemberId={presetMember ? Number(presetMember) : null} />
        ) : null}
      </Toolbar>

      <Card>
        {requests.length ? (
          <TableWrap>
            <thead>
              <tr>
                <th><SortLink sortKey="no">No.</SortLink></th>
                <th><SortLink sortKey="member">Member</SortLink></th>
                <th><SortLink sortKey="account_no">Account</SortLink></th>
                <th><SortLink sortKey="status">Status</SortLink></th><th className="num" />
              </tr>
            </thead>
            <tbody>
              {requests.map((r) => {
                const isOwnRequest = r.created_by === user.username;
                const canEditThis = canCreate && (!canApprove || isOwnRequest);
                return (
                <tr key={r.no}>
                  <td className="mono"><Link href={`/account-activations/view/${r.no}?view=${tab}`}>{r.no}</Link></td>
                  <td>
                    <b>{r.member_first_name} {r.member_last_name}</b>
                    <div className="tiny mono">{r.member_no}</div>
                  </td>
                  <td>
                    <span className="mono">{r.account_no}</span>
                    <div className="tiny muted-cell">{r.savings_product_name}</div>
                  </td>
                  <td><Pill status={r.status} /></td>
                  <td className="num">
                    <div className="inline" style={{ justifyContent: 'flex-end' }}>
                      {r.status === 'Open' && canEditThis ? <SubmitButton no={r.no} /> : null}
                      {r.status === 'Pending Approval' && canCreate && isOwnRequest ? (
                        <CancelApprovalButton no={r.no} />
                      ) : null}
                      {r.status === 'Approved' && canApprove ? <ProcessButton no={r.no} /> : null}
                      <Link href={`/members/${r.member_id}`} className="btn sm ghost">View member</Link>
                    </div>
                  </td>
                </tr>
                );
              })}
            </tbody>
          </TableWrap>
        ) : <EmptyState icon="✅" title="No activation requests here" sub="Try a different tab or clear the search" />}
      </Card>
    </Page>
  );
}
