import Link from 'next/link';
import { requirePerm, currentCan } from '@/lib/session';
import { listLoans } from '@/lib/loanService';
import { listActiveLoanProducts } from '@/lib/admin';
import { listActiveMembers } from '@/lib/members';
import { LOAN_STATUSES } from '@/lib/constants';
import { Page } from '@/components/layout/page';
import { Card, CardHead, EmptyState, Pill, TableWrap, Toolbar, Spacer } from '@/components/ui/primitives';
import { SearchInput, SelectFilter } from '@/components/ui/filters';
import { Money } from '@/components/ui/money';
import { NewApplicationButton } from './application-form';
import { AgingButton } from './aging-button';

export default async function LoansPage({ searchParams }: {
  searchParams: Promise<{ q?: string; status?: string; new?: string }>;
}) {
  const user = await requirePerm('LOAN:READ');
  const { q = '', status = '', new: presetMember } = await searchParams;
  const [rows, canCreate, members, products] = await Promise.all([
    listLoans({ search: q, status }),
    currentCan('LOAN:CREATE'),
    listActiveMembers(),
    listActiveLoanProducts(),
  ]);

  const book = rows
    .filter((l) => l.status === 'DISBURSED')
    .reduce((a, l) => a + l.principal_balance, 0);

  return (
    <Page title="Loans" crumb="Origination, appraisal, disbursement and collection" user={user}>
      <Toolbar>
        <SearchInput placeholder="Search loan number, member number or name…" />
        <SelectFilter paramName="status" options={LOAN_STATUSES} allLabel="All statuses" />
        <Spacer />
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
                  <th>Loan no.</th><th>Member</th><th>Product</th>
                  <th className="num">Principal</th><th className="num">Outstanding</th>
                  <th className="num">Instalment</th><th className="num">Arrears</th>
                  <th>Status</th><th>Class</th>
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
