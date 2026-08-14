import Link from 'next/link';
import { requireAction } from '@/lib/session';
import { getOrgBrand } from '@/lib/org';
import { getDashboard } from '@/lib/reports';
import { formatDate, today } from '@/lib/format';
import { Page } from '@/components/layout/page';
import { Card, CardHead, EmptyState, Pill, Stat, TableWrap } from '@/components/ui/primitives';
import { Money, SignedMoney } from '@/components/ui/money';
import { MonthlyVolumesChart, DepositMixChart } from './charts';

export default async function DashboardPage() {
  const user = await requireAction('DASHBOARD_VIEW');
  const [org, d] = await Promise.all([getOrgBrand(), getDashboard()]);

  const accountCount = d.deposits.reduce((a, x) => a + x.accounts, 0);
  const parPct = d.loans.portfolio ? (d.loans.arrears / d.loans.portfolio) * 100 : 0;

  return (
    <Page title="Dashboard" crumb={`${org!.name} · as at ${formatDate(today())}`} user={user}>
      <div className="grid g4 stack-2">
        <Stat label="Total member deposits" value={<Money cents={d.totalDeposits} short />}
          foot={`${accountCount} accounts across ${d.deposits.length} products`} />
        <Stat label="Loan portfolio" value={<Money cents={d.loanPortfolio} short />}
          foot={`${d.loans.active} loans running`} />
        <Stat label="Share capital" value={<Money cents={d.shareCapital} short />}
          foot={`${d.members.active} active members`} />
        <Stat label="Cash & bank" value={<Money cents={d.cash} short />}
          foot="Tellers, bank and mobile money" />
      </div>

      <div className="grid g4 stack-2">
        <Stat accent={false} label="Membership" value={d.members.total.toLocaleString()}
          foot={`${d.members.active} active · ${d.members.dormant} dormant`} />
        <Stat accent={false} label="Portfolio at risk" value={`${parPct.toFixed(2)}%`}
          foot={<><Money cents={d.loans.arrears} decimals={0} /> in arrears</>} />
        <Stat accent={false} label="Surplus to date" value={<Money cents={d.surplus} short />}
          foot={<>Income <Money cents={d.income} short /> · Costs <Money cents={d.expense} short /></>} />
        <Stat accent={false} label="Awaiting approval" value={String(d.pendingApprovals)}
          foot={d.pendingApprovals
            ? <Link href="/approvals">Open the approvals queue</Link>
            : 'Queue is clear'} />
      </div>

      <div className="grid split-wide">
        <Card>
          <CardHead title="Transaction volumes by month"
            sub="Member deposits received, withdrawals paid out and loans disbursed" />
          {d.monthly.length
            ? <MonthlyVolumesChart monthly={d.monthly} />
            : <EmptyState icon="📊" title="No transactions yet" />}
        </Card>

        <Card>
          <CardHead title="Deposits by product" sub="Member funds under management" />
          <DepositMixChart deposits={d.deposits} total={d.totalDeposits} />
        </Card>
      </div>

      <div className="grid split-narrow">
        <Card>
          <CardHead title="Loan book by risk classification" sub="Days in arrears drive the classification" />
          {d.par.length ? (
            <TableWrap>
              <thead>
                <tr><th>Classification</th><th className="num">Loans</th><th className="num">Balance</th></tr>
              </thead>
              <tbody>
                {d.par.map((p) => (
                  <tr key={p.classification}>
                    <td><Pill status={p.classification} /></td>
                    <td className="num">{p.loans}</td>
                    <td className="num"><Money cents={p.balance} decimals={0} /></td>
                  </tr>
                ))}
              </tbody>
            </TableWrap>
          ) : <EmptyState icon="📄" title="No live loans" />}
        </Card>

        <Card>
          <CardHead title="Latest transactions" sub="Most recent postings across all modules" />
          {d.recentTxns.length ? (
            <TableWrap>
              <thead>
                <tr>
                  <th>Reference</th><th>Date</th><th>Member</th><th>Type</th><th className="num">Amount</th>
                </tr>
              </thead>
              <tbody>
                {d.recentTxns.map((t) => (
                  <tr key={t.id}>
                    <td className="mono">{t.txn_ref}</td>
                    <td>{formatDate(t.value_date)}</td>
                    <td>{t.member_no ? `${t.first_name} ${t.last_name}` : '—'}</td>
                    <td><Pill status={t.txn_type} /></td>
                    <td className="num"><SignedMoney cents={t.amount} /></td>
                  </tr>
                ))}
              </tbody>
            </TableWrap>
          ) : <EmptyState icon="🧾" title="Nothing posted yet" />}
        </Card>
      </div>
    </Page>
  );
}
