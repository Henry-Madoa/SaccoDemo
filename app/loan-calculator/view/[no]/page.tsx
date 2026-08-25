import Link from 'next/link';
import { notFound } from 'next/navigation';
import { requireAction, currentCanAction } from '@/lib/session';
import { getLoanCalculator, getAdjacentLoanCalculatorNos, type LoanCalculatorView } from '@/lib/loanCalculator';
import { formatDate, formatDateTime, humanise } from '@/lib/format';
import { Page } from '@/components/layout/page';
import {
  Card, CardHead, DefinitionList, Pill, Stat, TableWrap, Toolbar, Spacer,
} from '@/components/ui/primitives';
import { Money } from '@/components/ui/money';
import { CardNav } from '@/components/ui/card-nav';
import { DeleteButton, ConvertButton } from '../../loan-calculator-actions';

const LOAN_CALCULATOR_VIEWS: LoanCalculatorView[] = ['open', 'converted'];

export default async function LoanCalculatorDetailPage({ params, searchParams }: {
  params: Promise<{ no: string }>;
  searchParams: Promise<{ view?: string }>;
}) {
  const user = await requireAction('LOAN_CALCULATOR_READ');
  const { no } = await params;
  const { view: viewRaw } = await searchParams;
  const view = LOAN_CALCULATOR_VIEWS.includes(viewRaw as LoanCalculatorView) ? (viewRaw as LoanCalculatorView) : undefined;
  const detail = await getLoanCalculator(no);
  if (!detail) notFound();
  const { calculator, lines } = detail;

  const [canDelete, canConvert, { prevNo, nextNo }] = await Promise.all([
    currentCanAction('LOAN_CALCULATOR_DELETE'),
    currentCanAction('LOAN_CALCULATOR_CONVERT'),
    getAdjacentLoanCalculatorNos(no, view),
  ]);
  const isOwn = calculator.created_by === user.username;
  const isOpen = calculator.status === 'Open';
  const totalPrincipal = lines.reduce((s, l) => s + l.principal_due, 0);

  return (
    <>
      <CardNav
        prevHref={prevNo ? `/loan-calculator/view/${prevNo}${view ? `?view=${view}` : ''}` : null}
        nextHref={nextNo ? `/loan-calculator/view/${nextNo}${view ? `?view=${view}` : ''}` : null}
      />
      <Page
        title={`${calculator.product_name} — ${calculator.first_name} ${calculator.last_name}`}
        crumb={`${calculator.calc_no} · ${humanise(calculator.rate_type)} · ${calculator.member_no}`}
        user={user}
      >
        <Toolbar>
          <Link href="/loan-calculator" className="btn ghost sm">← All calculations</Link>
          {calculator.converted_loan_id ? (
            <Link href={`/loans/view/${calculator.converted_loan_id}`} className="btn ghost sm">View loan application</Link>
          ) : null}
          <Link href={`/members/${calculator.member_id}`} className="btn ghost sm">View member</Link>
          <Spacer />
          {isOpen && canConvert ? <ConvertButton calcNo={calculator.calc_no} /> : null}
          {isOpen && canDelete && isOwn ? <DeleteButton calcNo={calculator.calc_no} className="btn ghost" /> : null}
        </Toolbar>

        <div className="grid g4 stack-2">
          <Stat label="Principal" value={<Money cents={calculator.principal} decimals={0} />} />
          <Stat label="First installment" value={<Money cents={calculator.installment} decimals={0} />} />
          <Stat label="Total interest" value={<Money cents={calculator.total_interest} decimals={0} />} />
          <Stat label="Status" value={<Pill status={calculator.status} tone={isOpen ? 'info' : 'ok'} />} />
        </div>

        <div className="grid split-side-sm">
          <div>
            <Card>
              <CardHead title="Calculation details" />
              <DefinitionList items={[
                ['No.', <span className="mono" key="no">{calculator.calc_no}</span>],
                ['Member', <>{calculator.first_name} {calculator.last_name} <span className="mono">({calculator.member_no})</span></>],
                ['Loan product', calculator.product_name],
                ['Principal amount', <Money cents={calculator.principal} key="principal" />],
                ['Interest rate', `${calculator.interest_rate}%`],
                ['Rate type', humanise(calculator.rate_type)],
                ['Installments (months)', calculator.term_months],
                ['Repayment start date', formatDate(calculator.repayment_start_date)],
              ]} />
            </Card>

            <Card>
              <CardHead title="Deposit appraisal" sub="Snapshot at the time this calculation was run" />
              <DefinitionList items={[
                ['Current deposits', <Money cents={calculator.current_deposits} key="deposits" />],
                ['Loan deposit multiplier', <Money cents={calculator.deposit_multiplier_amount} key="multiplier" />],
                ['Outstanding loans', <Money cents={calculator.outstanding_loans} key="outstanding" />],
                ['Deposit appraisal', (
                  <span className={calculator.deposit_appraisal < 0 ? 'neg' : ''} key="appraisal">
                    <Money cents={calculator.deposit_appraisal} />
                  </span>
                )],
              ]} />
            </Card>

            {!isOpen ? (
              <Card>
                <CardHead title="Converted to loan application" />
                <DefinitionList items={[
                  ['Loan no.', calculator.converted_loan_no
                    ? <Link href={`/loans/view/${calculator.converted_loan_id}`} className="mono" key="loan-no">{calculator.converted_loan_no}</Link>
                    : '—'],
                  ['Converted by', calculator.converted_by || '—'],
                  ['Converted on', formatDateTime(calculator.converted_at)],
                ]} />
              </Card>
            ) : null}

            <Card>
              <CardHead title="Created" />
              <DefinitionList items={[
                ['Created by', calculator.created_by || '—'],
                ['Created on', formatDateTime(calculator.created_at)],
              ]} />
            </Card>
          </div>

          <div>
            <Card>
              <CardHead
                title="Projected schedule"
                sub={`${lines.length} installment${lines.length === 1 ? '' : 's'} · principal sums to ${(totalPrincipal / 100).toLocaleString()}`}
              />
              <TableWrap>
                <thead>
                  <tr>
                    <th>#</th><th>Due date</th><th className="num">Opening balance</th>
                    <th className="num">Principal</th><th className="num">Interest</th>
                    <th className="num">Installment</th><th className="num">Closing balance</th>
                  </tr>
                </thead>
                <tbody>
                  {lines.map((l) => (
                    <tr key={l.installment_no}>
                      <td>{l.installment_no}</td>
                      <td>{formatDate(l.due_date)}</td>
                      <td className="num"><Money cents={l.opening_balance} /></td>
                      <td className="num"><Money cents={l.principal_due} /></td>
                      <td className="num"><Money cents={l.interest_due} /></td>
                      <td className="num"><Money cents={l.installment_amount} /></td>
                      <td className="num"><Money cents={l.closing_balance} /></td>
                    </tr>
                  ))}
                </tbody>
              </TableWrap>
            </Card>
          </div>
        </div>
      </Page>
    </>
  );
}
