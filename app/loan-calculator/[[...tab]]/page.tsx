import Link from 'next/link';
import { notFound } from 'next/navigation';
import { requireAction, currentCanAction } from '@/lib/session';
import {
  listLoanCalculators, hasAnyLoanCalculators, LOAN_CALCULATOR_FILTER_FIELDS, type LoanCalculatorView,
} from '@/lib/loanCalculator';
import { listActiveLoanProductsWithCharges } from '@/lib/admin';
import { listActiveMembers } from '@/lib/members';
import { LOAN_CALCULATOR_RATE_TYPES } from '@/lib/constants';
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
import { humanise } from '@/lib/format';
import { NewCalculationButton, ConvertButton, DeleteButton } from '../loan-calculator-actions';

const TABS: TabDefinition[] = [
  { key: 'open', label: 'Open', tone: 'info' },
  { key: 'converted', label: 'Converted to Loan Application', tone: 'ok' },
];

export default async function LoanCalculatorPage({ params, searchParams }: {
  params: Promise<{ tab?: string[] }>;
  searchParams: Promise<{ q?: string; filters?: string; sort?: string; new?: string }>;
}) {
  const user = await requireAction('LOAN_CALCULATOR_READ');
  const { tab: segments } = await params;
  const { q = '', filters: filtersRaw, sort: sortRaw, new: presetMember } = await searchParams;
  const filters = parseFilters(filtersRaw);
  const sort = parseSort(sortRaw);

  const requested = segments?.[0];
  if (requested && !TABS.some((t) => t.key === requested)) notFound();
  const tab = (requested ?? 'open') as LoanCalculatorView;

  const [rows, empty, canCreate, canConvert, canDelete, members, products] = await Promise.all([
    listLoanCalculators({ view: tab, search: q, filters, sort }),
    hasAnyLoanCalculators(tab).then((any) => !any),
    currentCanAction('LOAN_CALCULATOR_CREATE'),
    currentCanAction('LOAN_CALCULATOR_CONVERT'),
    currentCanAction('LOAN_CALCULATOR_DELETE'),
    listActiveMembers(),
    listActiveLoanProductsWithCharges(),
  ]);
  const fields = LOAN_CALCULATOR_FILTER_FIELDS.map((f) => (
    f.key === 'product_id' ? { ...f, options: products.map((p) => ({ value: p.id, label: p.name })) }
      : f.key === 'rate_type' ? { ...f, options: LOAN_CALCULATOR_RATE_TYPES }
        : f
  ));

  return (
    <Page title="Loan Calculator" crumb="What-if repayment quotes — compare terms and rate types before a member applies" user={user}>
      <Tabs tabs={TABS} active={tab} hrefFor={(k) => `/loan-calculator/${k}`} />
      <Toolbar>
        <SearchInput placeholder="Search calculation no., member name or number…" disabled={empty} />
        <DynamicFilterBar fields={fields} disabled={empty} />
        <Spacer />
        {canCreate ? (
          <NewCalculationButton members={members} products={products} presetMemberId={presetMember ? Number(presetMember) : null} />
        ) : null}
      </Toolbar>

      <Card>
        {rows.length ? (
          <TableWrap>
            <thead>
              <tr>
                <th><SortLink sortKey="calc_no">No.</SortLink></th>
                <th><SortLink sortKey="member">Member</SortLink></th>
                <th><SortLink sortKey="product_name">Product</SortLink></th>
                <th className="num"><SortLink sortKey="principal">Principal</SortLink></th>
                <th><SortLink sortKey="rate_type">Rate type</SortLink></th>
                <th className="num"><SortLink sortKey="term_months">Months</SortLink></th>
                <th className="num"><SortLink sortKey="installment">Installment</SortLink></th>
                {tab === 'open' ? <th className="num">Deposit appraisal</th> : <th>Loan application</th>}
                <th className="num" />
              </tr>
            </thead>
            <tbody>
              {rows.map((r) => {
                const isOwn = r.created_by === user.username;
                return (
                <tr key={r.calc_no}>
                  <td className="mono"><Link href={`/loan-calculator/view/${r.calc_no}?view=${tab}`}>{r.calc_no}</Link></td>
                  <td>
                    {r.first_name} {r.last_name}
                    <div className="tiny mono">{r.member_no}</div>
                  </td>
                  <td>{r.product_name}</td>
                  <td className="num"><Money cents={r.principal} decimals={0} /></td>
                  <td>{humanise(r.rate_type)}</td>
                  <td className="num">{r.term_months}</td>
                  <td className="num"><Money cents={r.installment} decimals={0} /></td>
                  {tab === 'open' ? (
                    <td className={`num ${r.deposit_appraisal < 0 ? 'neg' : ''}`}><Money cents={r.deposit_appraisal} decimals={0} /></td>
                  ) : (
                    <td>
                      {r.converted_loan_no ? <Link href={`/loans/view/${r.converted_loan_id}`} className="mono">{r.converted_loan_no}</Link> : '—'}
                      <div className="tiny">{r.converted_by || '—'}</div>
                    </td>
                  )}
                  <td className="num">
                    <div className="inline" style={{ justifyContent: 'flex-end' }}>
                      {tab === 'open' && canConvert ? <ConvertButton calcNo={r.calc_no} className="btn sm" /> : null}
                      {tab === 'open' && canDelete && isOwn ? <DeleteButton calcNo={r.calc_no} /> : null}
                      {tab === 'converted' ? <Pill status="Converted" tone="ok" /> : null}
                    </div>
                  </td>
                </tr>
                );
              })}
            </tbody>
          </TableWrap>
        ) : <EmptyState icon="🧮" title="No loan calculations here" sub="Try a different tab, or run a what-if quote for a member before they apply" />}
      </Card>
    </Page>
  );
}
