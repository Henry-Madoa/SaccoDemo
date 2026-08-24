import Link from 'next/link';
import { notFound } from 'next/navigation';
import { requireAction, currentCanAction } from '@/lib/session';
import {
  listLoans, hasAnyLoans, LOAN_FILTER_FIELDS, LOAN_TAB_STATUS,
} from '@/lib/loanService';
import { listActiveLoanProductsWithCharges } from '@/lib/admin';
import { listActiveMembers } from '@/lib/members';
import { parseFilters } from '@/lib/listFilters';
import { parseSort } from '@/lib/listSort';
import { Page } from '@/components/layout/page';
import {
  Card, CardHead, EmptyState, Pill, TableWrap, Tabs, Toolbar, Spacer, type TabDefinition,
} from '@/components/ui/primitives';
import { SearchInput } from '@/components/ui/filters';
import { DynamicFilterBar } from '@/components/ui/dynamic-filter';
import { SortLink } from '@/components/ui/sort-link';
import { Money } from '@/components/ui/money';
import { ExportButton } from '@/components/ui/export-button';
import { NewApplicationButton } from '../application-form';
import { AgingButton } from '../aging-button';

/** The list's Status navigation — a tab per stage of the loan lifecycle (Open, a captured but
 *  unsubmitted draft, through Pending Approval, Approved, Disbursed, to Closed, plus the two
 *  terminal-but-not-Closed outcomes Written Off and Archived), themed off the org's active
 *  Theme & Appearance tokens (see Tabs' `tone`). Path-segment based (/loans/<tab>), matching
 *  Member Applications & Member Edits — the loan detail route lives under /loans/view/<id>
 *  precisely so it doesn't collide with this catch-all. Rejection isn't its own tab: a rejected
 *  loan is sent back to Open for the applicant to amend and resubmit, not archived. "All",
 *  "Closed" and "Archived" stay untoned, matching lib/format.ts's STATUS_TONE and Members' own
 *  Closed tab — the theme only defines 4 status colours plus one accent, spent one-per-tab below;
 *  Written Off reuses 'bad' since STATUS_TONE maps it the same as other write-off-like statuses. */
const TABS: TabDefinition[] = [
  { key: 'all', label: 'All' },
  { key: 'open', label: 'Open', tone: 'info' },
  { key: 'pending', label: 'Pending Approval', tone: 'warn' },
  { key: 'approved', label: 'Approved', tone: 'ok' },
  { key: 'disbursed', label: 'Disbursed', tone: 'accent' },
  { key: 'closed', label: 'Closed' },
  { key: 'written-off', label: 'Written Off', tone: 'bad' },
  { key: 'archived', label: 'Archived' },
];

export default async function LoansPage({ params, searchParams }: {
  params: Promise<{ tab?: string[] }>;
  searchParams: Promise<{ q?: string; filters?: string; sort?: string; new?: string }>;
}) {
  const user = await requireAction('LOAN_READ');
  const { tab: segments } = await params;
  const { q = '', filters: filtersRaw, sort: sortRaw, new: presetMember } = await searchParams;

  const requested = segments?.[0];
  if (requested && !TABS.some((t) => t.key === requested)) notFound();
  const tab = requested ?? 'all';

  const filters = parseFilters(filtersRaw);
  const tabStatus = LOAN_TAB_STATUS[tab];
  const effectiveFilters = tabStatus ? [...filters, { field: 'status', operator: '=' as const, value: tabStatus }] : filters;
  const sort = parseSort(sortRaw);
  const [rows, empty, canCreate, members, products] = await Promise.all([
    listLoans({ search: q, filters: effectiveFilters, sort }),
    hasAnyLoans(tabStatus).then((any) => !any),
    currentCanAction('LOAN_CREATE'),
    listActiveMembers(),
    listActiveLoanProductsWithCharges(),
  ]);
  // The Status tabs above are now the primary way to narrow by status, so it's dropped from the
  // dynamic filter bar — it stays in LOAN_FILTER_FIELDS itself since buildFilterClause still
  // needs it to resolve the synthetic condition a tab adds above.
  const fields = LOAN_FILTER_FIELDS.filter((f) => f.key !== 'status').map((f) => (
    f.key === 'product_id' ? { ...f, options: products.map((p) => ({ value: p.id, label: p.name })) } : f
  ));

  const book = rows
    .filter((l) => l.status === 'DISBURSED')
    .reduce((a, l) => a + l.principal_balance, 0);

  return (
    <Page title="Loans" crumb="Origination, appraisal, disbursement and collection" user={user}>
      <Tabs tabs={TABS} active={tab} hrefFor={(k) => (k === 'all' ? '/loans' : `/loans/${k}`)} />
      <Toolbar>
        <SearchInput placeholder="Search loan number, member number or name…" disabled={empty} />
        <DynamicFilterBar fields={fields} disabled={empty} />
        <Spacer />
        <ExportButton href="/api/export/loans" params={{ q, filters: filtersRaw, sort: sortRaw }} disabled={!rows.length} />
        <AgingButton />
        {canCreate ? (
          <NewApplicationButton
            members={members}
            products={products}
            presetMemberId={presetMember ? Number(presetMember) : null}
          />
        ) : null}
      </Toolbar>

      <Card>
        {rows.length ? (
          <>
            <CardHead
              title={`${rows.length} loan${rows.length === 1 ? '' : 's'}`}
              sub={<>Outstanding principal on the listed running loans: <Money cents={book} /></>}
            />
            <TableWrap>
              <thead>
                <tr>
                  <th><SortLink sortKey="loan_no">Loan no.</SortLink></th>
                  <th><SortLink sortKey="member">Member</SortLink></th>
                  <th><SortLink sortKey="product_name">Product</SortLink></th>
                  <th className="num"><SortLink sortKey="principal">Principal</SortLink></th>
                  <th className="num"><SortLink sortKey="outstanding">Outstanding</SortLink></th>
                  <th className="num"><SortLink sortKey="installment">Instalment</SortLink></th>
                  <th className="num"><SortLink sortKey="arrears_amount">Arrears</SortLink></th>
                  <th><SortLink sortKey="status">Status</SortLink></th>
                  <th><SortLink sortKey="classification">Class</SortLink></th>
                </tr>
              </thead>
              <tbody>
                {rows.map((l) => (
                  <tr key={l.id}>
                    <td className="mono"><Link href={`/loans/view/${l.id}?tab=${tab}`}>{l.loan_no}</Link></td>
                    <td>
                      {l.first_name} {l.last_name}
                      <div className="tiny mono">{l.member_no}</div>
                    </td>
                    <td>{l.product_name}</td>
                    <td className="num"><Money cents={l.principal} decimals={0} /></td>
                    <td className="num">
                      {l.status === 'DISBURSED'
                        ? <Money cents={l.principal_balance + l.interest_balance} decimals={0} />
                        : '—'}
                    </td>
                    <td className="num">
                      {l.installment ? <Money cents={l.installment} decimals={0} /> : '—'}
                    </td>
                    <td className={`num ${l.arrears_amount ? 'neg' : ''}`}>
                      {l.arrears_amount ? <Money cents={l.arrears_amount} decimals={0} /> : '—'}
                    </td>
                    <td><Pill status={l.status} /></td>
                    <td>{l.status === 'DISBURSED' ? <Pill status={l.classification} /> : '—'}</td>
                  </tr>
                ))}
              </tbody>
            </TableWrap>
          </>
        ) : <EmptyState icon="📄" title="No loans match" />}
      </Card>
    </Page>
  );
}
