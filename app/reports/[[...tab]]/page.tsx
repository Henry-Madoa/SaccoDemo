import { notFound } from 'next/navigation';
import { requirePerm } from '@/lib/session';
import { getOrgBrand } from '@/lib/org';
import { getBalanceSheet, getIncomeStatement, getPortfolioAtRisk } from '@/lib/reports';
import { formatDate, today, startOfYear } from '@/lib/format';
import { Page } from '@/components/layout/page';
import {
  Card, CardHead, EmptyState, Pill, Stat, TableWrap, Tabs, type TabDefinition,
} from '@/components/ui/primitives';
import { Money } from '@/components/ui/money';
import { PrintButton } from '@/components/ui/print-button';
import { CompositionBars } from '../composition-charts';
import type { ReportLine } from '@/lib/types';

const TABS: TabDefinition[] = [
  { key: 'balance-sheet', label: 'Statement of financial position' },
  { key: 'income', label: 'Statement of comprehensive income' },
  { key: 'par', label: 'Risk classification & provisioning' },
];

export default async function ReportsPage({ params }: { params: Promise<{ tab?: string[] }> }) {
  const user = await requirePerm('REPORT:VIEW');
  const { tab: segments } = await params;
  const tab = segments?.[0] ?? 'balance-sheet';
  if (!TABS.some((t) => t.key === tab)) notFound();

  return (
    <Page
      title="Reports"
      crumb="Management and regulatory reporting from controlled ledger data"
      user={user}
    >
      <Tabs tabs={TABS} active={tab} hrefFor={(k) => `/reports/${k}`} />
      {tab === 'balance-sheet' ? <BalanceSheetTab /> : null}
      {tab === 'income' ? <IncomeTab /> : null}
      {tab === 'par' ? <ParTab /> : null}
    </Page>
  );
}

/** A labelled block of report lines with its own subtotal. */
function Section({ label, lines, total }: { label: string; lines: ReportLine[]; total: number }) {
  return (
    <>
      <tr className="section"><td colSpan={2}><b>{label}</b></td></tr>
      {lines.filter((r) => r.amount !== 0).map((r) => (
        <tr className="indent" key={r.code}>
          <td><span className="mono muted-cell">{r.code}</span> {r.name}</td>
          <td className="num"><Money cents={r.amount} symbol={false} /></td>
        </tr>
      ))}
      <tr className="indent subtotal">
        <td><b>Total {label.toLowerCase()}</b></td>
        <td className="num"><b><Money cents={total} symbol={false} /></b></td>
      </tr>
    </>
  );
}

async function BalanceSheetTab() {
  const [brand, d] = await Promise.all([getOrgBrand(), getBalanceSheet()]);
  const org = brand!;

  return (
    <Card>
      <CardHead
        title="Statement of financial position"
        sub={`${org.name} · as at ${formatDate(today())} · amounts in ${org.currency_code}`}
      >
        <PrintButton className="btn ghost sm" />
      </CardHead>
      <div className="report-body">
        <table>
          <tbody>
            <Section label="Assets" lines={d.assets} total={d.totals.assets} />
            <Section label="Liabilities" lines={d.liabilities} total={d.totals.liabilities} />
            <Section label="Capital and reserves" lines={d.equity} total={d.totals.equity} />
            <tr className="indent">
              <td>Surplus for the period</td>
              <td className="num"><Money cents={d.surplus} symbol={false} /></td>
            </tr>
          </tbody>
          <tfoot>
            <tr>
              <td><b>Total equity and liabilities</b></td>
              <td className="num"><b><Money cents={d.totals.equityAndLiabilities} symbol={false} /></b></td>
            </tr>
          </tfoot>
        </table>
        <div style={{ marginTop: 14 }}>
          <Pill tone={d.balanced ? 'ok' : 'bad'}>
            {d.balanced
              ? 'Assets equal equity and liabilities'
              : <>Out of balance by <Money cents={d.totals.assets - d.totals.equityAndLiabilities} /></>}
          </Pill>
        </div>
      </div>
    </Card>
  );
}

async function IncomeTab() {
  const from = startOfYear();
  const to = today();
  const [brand, d] = await Promise.all([getOrgBrand(), getIncomeStatement(from, to)]);
  const org = brand!;

  return (
    <Card>
      <CardHead
        title="Statement of comprehensive income"
        sub={`${org.name} · ${formatDate(from)} to ${formatDate(to)}`}
      >
        <PrintButton className="btn ghost sm" />
      </CardHead>
      <div className="grid g2">
        <div style={{ maxWidth: 560 }}>
          <table>
            <tbody>
              <Section label="Income" lines={d.income} total={d.totalIncome} />
              <Section label="Expenditure" lines={d.expense} total={d.totalExpense} />
            </tbody>
            <tfoot>
              <tr>
                <td><b>Surplus for the period</b></td>
                <td className="num"><b><Money cents={d.surplus} symbol={false} /></b></td>
              </tr>
            </tfoot>
          </table>
        </div>
        <div>
          <h4 className="metric-label" style={{ marginBottom: 10 }}>Income composition</h4>
          {d.income.some((r) => r.amount > 0)
            ? <CompositionBars lines={d.income} total={d.totalIncome} />
            : <EmptyState icon="📊" title="No income recorded in this period" />}

          <h4 className="metric-label" style={{ margin: '20px 0 10px' }}>Expenditure composition</h4>
          {d.expense.some((r) => r.amount > 0)
            ? <CompositionBars lines={d.expense} total={d.totalExpense} color="var(--series-2)" />
            : <EmptyState icon="📊" title="No expenditure recorded" />}
        </div>
      </div>
    </Card>
  );
}

async function ParTab() {
  const d = await getPortfolioAtRisk();
  const totalLoans = d.rows.reduce((a, r) => a + r.loans, 0);
  const totalArrears = d.rows.reduce((a, r) => a + r.arrears, 0);

  return (
    <>
      <div className="grid g3 stack-2">
        <Stat label="Gross loan portfolio" value={<Money cents={d.total} decimals={0} />} />
        <Stat label="Portfolio at risk" value={`${d.parPct}%`}
          foot={<><Money cents={d.atRisk} decimals={0} /> outside the performing band</>} />
        <Stat label="Indicative provision" value={<Money cents={d.totalProvision} decimals={0} />}
          foot="Applying the configured provisioning rates" />
      </div>

      <Card>
        <CardHead
          title="Risk classification of assets and provisioning"
          sub="Shaped after the SASRA Form 4 return — classification bands and provisioning rates are configurable"
        >
          <PrintButton className="btn ghost sm" />
        </CardHead>
        <TableWrap>
          <thead>
            <tr>
              <th>Classification</th><th className="num">Loans</th>
              <th className="num">Outstanding balance</th><th className="num">Arrears</th>
              <th className="num">Provision rate</th><th className="num">Provision</th>
            </tr>
          </thead>
          <tbody>
            {d.rows.map((r) => (
              <tr key={r.classification}>
                <td><Pill status={r.classification} /></td>
                <td className="num">{r.loans}</td>
                <td className="num"><Money cents={r.balance} symbol={false} /></td>
                <td className="num"><Money cents={r.arrears} symbol={false} /></td>
                <td className="num">{(r.provision_rate * 100).toFixed(0)}%</td>
                <td className="num"><Money cents={r.provision} symbol={false} /></td>
              </tr>
            ))}
          </tbody>
          <tfoot>
            <tr>
              <td>Total</td>
              <td className="num">{totalLoans}</td>
              <td className="num"><Money cents={d.total} symbol={false} /></td>
              <td className="num"><Money cents={totalArrears} symbol={false} /></td>
              <td />
              <td className="num"><Money cents={d.totalProvision} symbol={false} /></td>
            </tr>
          </tfoot>
        </TableWrap>
        <p className="note" style={{ margin: '16px 0 0' }}>
          Classification bands used here: performing 0–30 days, watch 31–180, substandard 181–360,
          doubtful 361–540, loss beyond 540. Confirm the bands, provisioning rates and return format
          against the regulator&apos;s current published requirements before filing.
        </p>
      </Card>
    </>
  );
}
