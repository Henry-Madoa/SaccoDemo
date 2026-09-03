import Link from 'next/link';
import { currentCanAction } from '@/lib/session';
import { getOrgBrand } from '@/lib/org';
import { getCreditRoleCenter } from '@/lib/roleCenters';
import { formatDate, today } from '@/lib/format';
import { Page } from '@/components/layout/page';
import { Card, CardHead, EmptyState, Pill, TableWrap } from '@/components/ui/primitives';
import { Money } from '@/components/ui/money';
import { KpiTile, LockedCard } from './shared';
import { MonthTrend, MixDonut, MagnitudeBars } from '../role-center-charts';
import type { SessionUser } from '@/lib/types';

export async function CreditRoleCentre({ user }: { user: SessionUser }) {
  const canLoans = await currentCanAction('LOAN_READ');
  const [org, d] = await Promise.all([getOrgBrand(), getCreditRoleCenter()]);
  const months = d.flows.map((f) => f.month);

  if (!canLoans) {
    return (
      <Page title="Credit Role Centre" crumb={`${org!.name}`} user={user}>
        <LockedCard title="Loan portfolio" />
      </Page>
    );
  }

  return (
    <Page title="Credit Role Centre" crumb={`${org!.name} · as at ${formatDate(today())}`} user={user}>
      <div className="grid g4 stack-2">
        <KpiTile label="Gross loan portfolio" value={<Money cents={d.kpi.portfolio} short />}
          foot={`${d.kpi.activeLoans} loans running`}
          spark={d.flows.map((f) => f.disbursements)} />
        <KpiTile label="Portfolio at risk" value={`${d.kpi.parPct}%`}
          foot={<><Money cents={d.kpi.arrears} decimals={0} /> in arrears</>} sparkColor="var(--danger)" />
        <KpiTile accent={false} label="Disbursed this month" value={<Money cents={d.kpi.disbursedThisMonth} short />} />
        <KpiTile accent={false} label="Awaiting approval" value={d.kpi.pendingApprovals}
          foot={d.kpi.pendingApprovals ? <Link href="/approvals">Open queue</Link> : 'Queue clear'} />
      </div>

      <div className="grid split-wide">
        <Card>
          <CardHead title="Disbursements vs repayments" sub="Loan money out and loan money in, per month" />
          <MonthTrend months={months} series={[
            { name: 'Disbursements', values: d.flows.map((f) => f.disbursements) },
            { name: 'Repayments', values: d.flows.map((f) => f.repayments) },
          ]} />
        </Card>
        <Card>
          <CardHead title="Portfolio by product">
            <Link href="/loans" className="btn sm ghost">Loans</Link>
          </CardHead>
          {d.byProduct.length ? (
            <MixDonut centerLabel="portfolio" total={d.kpi.portfolio}
              rows={d.byProduct.map((p) => ({ name: p.name, amount: p.balance }))} />
          ) : <EmptyState icon="📄" title="No live loans" />}
        </Card>
      </div>

      <div className="grid split-narrow">
        <Card>
          <CardHead title="Risk classification & provisioning" sub="Shaped after the SASRA Form 4 return" />
          <TableWrap>
            <thead>
              <tr><th>Classification</th><th className="num">Loans</th><th className="num">Balance</th><th className="num">Provision</th></tr>
            </thead>
            <tbody>
              {d.par.rows.map((r) => (
                <tr key={r.classification}>
                  <td><Pill status={r.classification} /></td>
                  <td className="num">{r.loans}</td>
                  <td className="num"><Money cents={r.balance} decimals={0} /></td>
                  <td className="num"><Money cents={r.provision} decimals={0} /></td>
                </tr>
              ))}
            </tbody>
          </TableWrap>
        </Card>
        <Card>
          <CardHead title="Sectorial lending" sub="Disbursed portfolio by economic sector" />
          {d.sectors.length ? (
            <MagnitudeBars rows={d.sectors.map((s) => ({ label: s.name, value: s.balance, note: `${s.loans} loans` }))} />
          ) : <EmptyState icon="🌾" title="No sector classification yet" />}
        </Card>
      </div>

      {d.topArrears.length ? (
        <Card>
          <CardHead title="Largest arrears" sub="Disbursed loans with the most overdue" />
          <TableWrap>
            <thead><tr><th>Loan</th><th>Member</th><th>Classification</th><th className="num">Arrears</th></tr></thead>
            <tbody>
              {d.topArrears.map((r) => (
                <tr key={r.loan_no}>
                  <td className="mono">{r.loan_no}</td>
                  <td>{r.member}</td>
                  <td><Pill status={r.classification} /></td>
                  <td className="num"><Money cents={r.arrears} decimals={0} /></td>
                </tr>
              ))}
            </tbody>
          </TableWrap>
        </Card>
      ) : null}
    </Page>
  );
}
