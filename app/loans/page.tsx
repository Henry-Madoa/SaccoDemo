import Link from 'next/link';
import { requireAction, currentCanAction } from '@/lib/session';
import { listLoans, LOAN_FILTER_FIELDS } from '@/lib/loanService';
import { listActiveLoanProducts } from '@/lib/admin';
import { listActiveMembers } from '@/lib/members';
import { parseFilters } from '@/lib/listFilters';
import { parseSort } from '@/lib/listSort';
import { Page } from '@/components/layout/page';
import { Card, CardHead, EmptyState, Pill, TableWrap, Toolbar, Spacer } from '@/components/ui/primitives';
import { SearchInput } from '@/components/ui/filters';
import { DynamicFilterBar } from '@/components/ui/dynamic-filter';
import { SortLink } from '@/components/ui/sort-link';
import { Money } from '@/components/ui/money';
import { ExportButton } from '@/components/ui/export-button';
import { NewApplicationButton } from './application-form';
import { AgingButton } from './aging-button';

export default async function LoansPage({ searchParams }: {
  searchParams: Promise<{ q?: string; filters?: string; sort?: string; new?: string }>;
}) {
  const user = await requireAction('LOAN_READ');
  const { q = '', filters: filtersRaw, sort: sortRaw, new: presetMember } = await searchParams;
  const filters = parseFilters(filtersRaw);
  const sort = parseSort(sortRaw);
  const [rows, canCreate, members, products] = await Promise.all([
    listLoans({ search: q, filters, sort }),
    currentCanAction('LOAN_CREATE'),
    listActiveMembers(),
    listActiveLoanProducts(),
  ]);
  const fields = LOAN_FILTER_FIELDS.map((f) => (
    f.key === 'product_id' ? { ...f, options: products.map((p) => ({ value: p.id, label: p.name })) } : f
  ));

  const book = rows
    .filter((l) => l.status === 'DISBURSED')
    .reduce((a, l) => a + l.principal_balance, 0);

  return (
    <Page title="Loans" crumb="Origination, appraisal, disbursement and collection" user={user}>
      <Toolbar>
        <SearchInput placeholder="Search loan number, member number or name…" />
        <DynamicFilterBar fields={fields} />
        <Spacer />
        <ExportButton href="/api/export/loans" params={{ q, filters: filtersRaw, sort: sortRaw }} />
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
                    <td className="mono"><Link href={`/loans/${l.id}`}>{l.loan_no}</Link></td>
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
