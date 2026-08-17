import Link from 'next/link';
import { notFound } from 'next/navigation';
import { requireAction, currentCanAction } from '@/lib/session';
import {
  listCollateralApplications, hasAnyCollateralApplications, COLLATERAL_APPLICATION_FILTER_FIELDS,
  type CollateralApplicationView,
} from '@/lib/collateralApplications';
import { listActiveMembers } from '@/lib/members';
import { listActiveCounties } from '@/lib/pool';
import { listCollateralTypes } from '@/lib/collateralTypes';
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
import { ExportButton } from '@/components/ui/export-button';
import {
  NewCollateralApplicationButton, SubmitButton, CancelApprovalButton, PostButton,
} from '../collateral-application-actions';

const TABS: TabDefinition[] = [
  { key: 'open', label: 'Open', tone: 'info' },
  { key: 'pending', label: 'Pending Approval', tone: 'warn' },
  { key: 'approved', label: 'Approved', tone: 'ok' },
  { key: 'processed', label: 'Registered', tone: 'accent' },
];

export default async function CollateralApplicationsPage({ params, searchParams }: {
  params: Promise<{ tab?: string[] }>;
  searchParams: Promise<{ q?: string; filters?: string; sort?: string; new?: string }>;
}) {
  const user = await requireAction('COLLATERAL_APPLICATIONS_READ');
  const { tab: segments } = await params;
  const { q = '', filters: filtersRaw, sort: sortRaw, new: presetMember } = await searchParams;
  const filters = parseFilters(filtersRaw);
  const sort = parseSort(sortRaw);

  const requested = segments?.[0];
  if (requested && !TABS.some((t) => t.key === requested)) notFound();
  const tab = (requested ?? 'open') as CollateralApplicationView;

  const [applications, empty, canCreate, canApprove, members, counties, types] = await Promise.all([
    listCollateralApplications({ view: tab, search: q, filters, sort }),
    hasAnyCollateralApplications(tab).then((any) => !any),
    currentCanAction('COLLATERAL_APPLICATIONS_CREATE'), currentCanAction('COLLATERAL_APPLICATIONS_APPROVE'),
    listActiveMembers(), listActiveCounties(), listCollateralTypes(),
  ]);
  const fields = COLLATERAL_APPLICATION_FILTER_FIELDS.map((f) => (
    f.key === 'member_id' ? { ...f, options: members.map((m) => ({ value: m.id, label: `${m.member_no} — ${m.first_name} ${m.last_name}` })) }
      : f.key === 'collateral_type_id' ? { ...f, options: types.map((t) => ({ value: t.id, label: t.code })) }
        : f
  ));

  return (
    <Page title="Collateral Applications" crumb="Pledged assets, from request through to registration" user={user}>
      <Tabs tabs={TABS} active={tab} hrefFor={(k) => `/collateral-applications/${k}`} />
      <Toolbar>
        <SearchInput placeholder="Search member name, no., serial no. or application no.…" disabled={empty} />
        <DynamicFilterBar fields={fields} disabled={empty} />
        <Spacer />
        <ExportButton href="/api/export/collateral-applications" params={{ q, view: tab, filters: filtersRaw, sort: sortRaw }} disabled={!applications.length} />
        {canCreate ? (
          <NewCollateralApplicationButton members={members} counties={counties} presetMemberId={presetMember ? Number(presetMember) : null} />
        ) : null}
      </Toolbar>

      <Card>
        {applications.length ? (
          <TableWrap>
            <thead>
              <tr>
                <th><SortLink sortKey="no">No.</SortLink></th>
                <th><SortLink sortKey="member">Member</SortLink></th>
                <th><SortLink sortKey="collateral_type">Type</SortLink></th>
                <th>Serial / Reg. No.</th>
                <th className="num"><SortLink sortKey="collateral_value">Value</SortLink></th>
                <th className="num"><SortLink sortKey="guarantee">Guarantee</SortLink></th>
                <th><SortLink sortKey="status">Status</SortLink></th><th className="num" />
              </tr>
            </thead>
            <tbody>
              {applications.map((a) => {
                const isOwnRequest = a.created_by === user.username;
                const canEditThis = canCreate && (!canApprove || isOwnRequest);
                return (
                <tr key={a.no}>
                  <td className="mono"><Link href={`/collateral-applications/view/${a.no}?view=${tab}`}>{a.no}</Link></td>
                  <td>
                    <b>{a.member_first_name} {a.member_last_name}</b>
                    <div className="tiny mono">{a.member_no}</div>
                  </td>
                  <td>{a.collateral_type_code || '—'}</td>
                  <td className="mono tiny">{a.serial_reg_no || '—'}</td>
                  <td className="num"><Money cents={a.collateral_value} decimals={0} /></td>
                  <td className="num"><Money cents={a.guarantee} decimals={0} /></td>
                  <td><Pill status={a.status} /></td>
                  <td className="num">
                    <div className="inline" style={{ justifyContent: 'flex-end' }}>
                      {a.status === 'Open' && canEditThis ? <SubmitButton no={a.no} /> : null}
                      {a.status === 'Pending Approval' && canCreate && isOwnRequest ? (
                        <CancelApprovalButton no={a.no} />
                      ) : null}
                      {a.status === 'Approved' && canApprove ? <PostButton no={a.no} /> : null}
                      <Link href={`/members/${a.member_id}`} className="btn sm ghost">View member</Link>
                    </div>
                  </td>
                </tr>
                );
              })}
            </tbody>
          </TableWrap>
        ) : <EmptyState icon="🏠" title="No collateral applications here" sub="Try a different tab or clear the search" />}
      </Card>
    </Page>
  );
}
