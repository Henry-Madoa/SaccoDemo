import Link from 'next/link';
import { notFound } from 'next/navigation';
import { requireAction, currentCanAction } from '@/lib/session';
import {
  listCollateralReleases, hasAnyCollateralReleases, COLLATERAL_RELEASE_FILTER_FIELDS, type CollateralReleaseView,
} from '@/lib/collateralReleases';
import { listCollateralRegister } from '@/lib/collateralRegister';
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
  NewCollateralReleaseButton, SubmitButton, CancelApprovalButton, PostButton,
} from '../collateral-release-actions';

const TABS: TabDefinition[] = [
  { key: 'open', label: 'Open', tone: 'info' },
  { key: 'pending', label: 'Pending Approval', tone: 'warn' },
  { key: 'approved', label: 'Approved', tone: 'ok' },
  { key: 'processed', label: 'Released', tone: 'accent' },
];

export default async function CollateralReleasesPage({ params, searchParams }: {
  params: Promise<{ tab?: string[] }>;
  searchParams: Promise<{ q?: string; filters?: string; sort?: string; new?: string }>;
}) {
  const user = await requireAction('COLLATERAL_RELEASES_READ');
  const { tab: segments } = await params;
  const { q = '', filters: filtersRaw, sort: sortRaw, new: presetCollateral } = await searchParams;
  const filters = parseFilters(filtersRaw);
  const sort = parseSort(sortRaw);

  const requested = segments?.[0];
  if (requested && !TABS.some((t) => t.key === requested)) notFound();
  const tab = (requested ?? 'open') as CollateralReleaseView;

  const [releases, empty, canCreate, canApprove, members, register] = await Promise.all([
    listCollateralReleases({ view: tab, search: q, filters, sort }),
    hasAnyCollateralReleases(tab).then((any) => !any),
    currentCanAction('COLLATERAL_RELEASES_CREATE'), currentCanAction('COLLATERAL_RELEASES_APPROVE'),
    listActiveMembers(), listCollateralRegister(),
  ]);
  const fields = COLLATERAL_RELEASE_FILTER_FIELDS.map((f) => (
    f.key === 'member_id' ? { ...f, options: members.map((m) => ({ value: m.id, label: `${m.member_no} — ${m.first_name} ${m.last_name}` })) } : f
  ));
  const eligibleCollateral = register.filter((r) => r.status !== 'COLLECTED');

  return (
    <Page title="Collateral Releases" crumb="Handing pledged assets back once every loan they secured is cleared" user={user}>
      <Tabs tabs={TABS} active={tab} hrefFor={(k) => `/collateral-releases/${k}`} />
      <Toolbar>
        <SearchInput placeholder="Search member name, no., collateral no. or release no.…" disabled={empty} />
        <DynamicFilterBar fields={fields} disabled={empty} />
        <Spacer />
        <ExportButton href="/api/export/collateral-releases" params={{ q, view: tab, filters: filtersRaw, sort: sortRaw }} disabled={!releases.length} />
        {canCreate ? (
          <NewCollateralReleaseButton collateral={eligibleCollateral} presetCollateralNo={presetCollateral ?? null} />
        ) : null}
      </Toolbar>

      <Card>
        {releases.length ? (
          <TableWrap>
            <thead>
              <tr>
                <th><SortLink sortKey="no">No.</SortLink></th>
                <th>Collateral</th>
                <th><SortLink sortKey="member">Member</SortLink></th>
                <th>Collected by</th>
                <th><SortLink sortKey="status">Status</SortLink></th><th className="num" />
              </tr>
            </thead>
            <tbody>
              {releases.map((r) => {
                const isOwnRequest = r.created_by === user.username;
                const canEditThis = canCreate && (!canApprove || isOwnRequest);
                return (
                <tr key={r.no}>
                  <td className="mono"><Link href={`/collateral-releases/view/${r.no}?view=${tab}`}>{r.no}</Link></td>
                  <td>
                    <Link href={`/collateral-register/view/${r.collateral_no}`} className="mono">{r.collateral_no}</Link>
                    <div className="tiny">{r.collateral_description || r.collateral_serial_reg_no || ''}</div>
                  </td>
                  <td>
                    <b>{r.member_first_name} {r.member_last_name}</b>
                    <div className="tiny mono">{r.member_no}</div>
                  </td>
                  <td>{r.collected_by || '—'}</td>
                  <td><Pill status={r.status} /></td>
                  <td className="num">
                    <div className="inline" style={{ justifyContent: 'flex-end' }}>
                      {r.status === 'Open' && canEditThis ? <SubmitButton no={r.no} /> : null}
                      {r.status === 'Pending Approval' && canCreate && isOwnRequest ? (
                        <CancelApprovalButton no={r.no} />
                      ) : null}
                      {r.status === 'Approved' && canApprove ? <PostButton no={r.no} /> : null}
                    </div>
                  </td>
                </tr>
                );
              })}
            </tbody>
          </TableWrap>
        ) : <EmptyState icon="🔓" title="No collateral releases here" sub="Try a different tab or clear the search" />}
      </Card>
    </Page>
  );
}
