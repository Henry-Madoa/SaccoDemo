import Link from 'next/link';
import { notFound } from 'next/navigation';
import { requireAction, currentCanAction } from '@/lib/session';
import {
  listGuarantorChanges, hasAnyGuarantorChanges, listChangeableLoans, GUARANTOR_CHANGE_FILTER_FIELDS,
  type GuarantorChangeView,
} from '@/lib/loanGuarantorChanges';
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
  NewGuarantorChangeButton, SubmitButton, CancelApprovalButton, ProcessButton,
} from '../guarantor-change-actions';

const TABS: TabDefinition[] = [
  { key: 'open', label: 'Open', tone: 'info' },
  { key: 'pending', label: 'Pending Approval', tone: 'warn' },
  { key: 'approved', label: 'Approved', tone: 'ok' },
  { key: 'processed', label: 'Processed', tone: 'accent' },
];

export default async function GuarantorChangesPage({ params, searchParams }: {
  params: Promise<{ tab?: string[] }>;
  searchParams: Promise<{ q?: string; filters?: string; sort?: string; new?: string }>;
}) {
  const user = await requireAction('GUARANTOR_CHANGES_READ');
  const { tab: segments } = await params;
  const { q = '', filters: filtersRaw, sort: sortRaw, new: presetLoanId } = await searchParams;
  const filters = parseFilters(filtersRaw);
  const sort = parseSort(sortRaw);

  const requested = segments?.[0];
  if (requested && !TABS.some((t) => t.key === requested)) notFound();
  const tab = (requested ?? 'open') as GuarantorChangeView;

  const [changes, empty, canCreate, canApprove, loans] = await Promise.all([
    listGuarantorChanges({ view: tab, search: q, filters, sort }),
    hasAnyGuarantorChanges(tab).then((any) => !any),
    currentCanAction('GUARANTOR_CHANGES_CREATE'), currentCanAction('GUARANTOR_CHANGES_APPROVE'),
    listChangeableLoans(),
  ]);

  return (
    <Page title="Guarantor Changes" crumb="Releasing or substituting guarantors on already-disbursed loans" user={user}>
      <Tabs tabs={TABS} active={tab} hrefFor={(k) => `/guarantor-changes/${k}`} />
      <Toolbar>
        <SearchInput placeholder="Search member name, no., loan no. or document no.…" disabled={empty} />
        <DynamicFilterBar fields={GUARANTOR_CHANGE_FILTER_FIELDS} disabled={empty} />
        <Spacer />
        <ExportButton href="/api/export/guarantor-changes" params={{ q, view: tab, filters: filtersRaw, sort: sortRaw }} disabled={!changes.length} />
        {canCreate ? <NewGuarantorChangeButton loans={loans} presetLoanId={presetLoanId ?? null} /> : null}
      </Toolbar>

      <Card>
        {changes.length ? (
          <TableWrap>
            <thead>
              <tr>
                <th><SortLink sortKey="no">No.</SortLink></th>
                <th><SortLink sortKey="loan_no">Loan</SortLink></th>
                <th><SortLink sortKey="member">Member</SortLink></th>
                <th><SortLink sortKey="status">Status</SortLink></th><th className="num" />
              </tr>
            </thead>
            <tbody>
              {changes.map((c) => {
                const isOwnRequest = c.created_by === user.username;
                const canEditThis = canCreate && (!canApprove || isOwnRequest);
                return (
                <tr key={c.no}>
                  <td className="mono"><Link href={`/guarantor-changes/view/${c.no}?view=${tab}`}>{c.no}</Link></td>
                  <td>
                    <Link href={`/loans/view/${c.loan_id}`} className="mono">{c.loan_no}</Link>
                  </td>
                  <td>
                    <b>{c.member_first_name} {c.member_last_name}</b>
                    <div className="tiny mono">{c.member_no}</div>
                  </td>
                  <td><Pill status={c.status} /></td>
                  <td className="num">
                    <div className="inline" style={{ justifyContent: 'flex-end' }}>
                      {c.status === 'Open' && canEditThis ? <SubmitButton no={c.no} /> : null}
                      {c.status === 'Pending Approval' && canCreate && isOwnRequest ? (
                        <CancelApprovalButton no={c.no} />
                      ) : null}
                      {c.status === 'Approved' && canApprove ? <ProcessButton no={c.no} /> : null}
                    </div>
                  </td>
                </tr>
                );
              })}
            </tbody>
          </TableWrap>
        ) : <EmptyState icon="🔁" title="No guarantor changes here" sub="Try a different tab or clear the search" />}
      </Card>
    </Page>
  );
}
