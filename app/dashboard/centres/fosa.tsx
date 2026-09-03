import Link from 'next/link';
import { currentCanAction } from '@/lib/session';
import { getOrgBrand } from '@/lib/org';
import { getFosaRoleCenter } from '@/lib/roleCenters';
import { formatDate, today } from '@/lib/format';
import { Page } from '@/components/layout/page';
import { Card, CardHead, EmptyState, TableWrap } from '@/components/ui/primitives';
import { Money } from '@/components/ui/money';
import { KpiTile, LockedCard } from './shared';
import { MonthTrend, MagnitudeBars, StatusDonut } from '../role-center-charts';
import type { SessionUser } from '@/lib/types';

export async function FosaRoleCentre({ user }: { user: SessionUser }) {
  const canSavings = await currentCanAction('SAVINGS_READ');
  const canTeller = await currentCanAction('TELLER_TRANSACTIONS_READ');
  const [org, d] = await Promise.all([getOrgBrand(), getFosaRoleCenter()]);
  const months = d.flows.map((f) => f.month);

  return (
    <Page title="FOSA Role Centre" crumb={`${org!.name} · as at ${formatDate(today())}`} user={user}>
      {canSavings ? (
        <div className="grid g4 stack-2">
          <KpiTile label="FOSA savings held" value={<Money cents={d.kpi.fosaDeposits} short />}
            spark={d.flows.map((f) => f.deposits)} />
          <KpiTile label="Deposits today" value={<Money cents={d.kpi.depositsToday} short />}
            foot={<>Withdrawals <Money cents={d.kpi.withdrawalsToday} decimals={0} /></>} sparkColor="var(--series-3)" />
          <KpiTile accent={false} label="Till & vault cash" value={<Money cents={d.kpi.tillCash} short />} />
          <KpiTile accent={false} label="Cheques in clearing" value={d.kpi.chequesInClearing}
            foot={<Money cents={d.kpi.chequesInClearingValue} decimals={0} />} />
        </div>
      ) : <LockedCard title="FOSA KPIs" />}

      <div className="grid split-wide">
        {canSavings ? (
          <Card>
            <CardHead title="Deposits vs withdrawals" sub="FOSA cash flow per month">
              <Link href="/teller-transactions" className="btn sm ghost">Teller</Link>
            </CardHead>
            <MonthTrend months={months} series={[
              { name: 'Deposits', values: d.flows.map((f) => f.deposits) },
              { name: 'Withdrawals', values: d.flows.map((f) => f.withdrawals) },
            ]} />
          </Card>
        ) : <LockedCard title="Deposits vs withdrawals" />}

        {canTeller || canSavings ? (
          <Card>
            <CardHead title="Cash positions" sub="Balance in each till and the vault" />
            {d.tills.length ? (
              <MagnitudeBars rows={d.tills.map((t) => ({ label: `${t.name}`, value: t.balance, note: t.type }))} />
            ) : <EmptyState icon="🏧" title="No till accounts configured" />}
          </Card>
        ) : <LockedCard title="Cash positions" />}
      </div>

      <div className="grid split-narrow">
        <Card>
          <CardHead title="Cheque deposits by status" />
          {d.chequeStatus.some((c) => c.count) ? (
            <StatusDonut centerLabel="cheques" rows={d.chequeStatus.map((c) => ({ label: c.status, value: c.count }))} />
          ) : <EmptyState icon="🧾" title="No cheque deposits" />}
        </Card>
        <Card>
          <CardHead title="Front-office watchlist" />
          <TableWrap>
            <tbody>
              <tr><td>Active standing orders</td><td className="num">{d.kpi.standingOrders}</td></tr>
              <tr><td>Liens & holds outstanding</td>
                <td className="num">{d.liens.count} · <Money cents={d.liens.amount} decimals={0} /></td></tr>
              <tr><td>Fixed deposits maturing within a month</td>
                <td className="num">{d.maturingFd.count} · <Money cents={d.maturingFd.amount} decimals={0} /></td></tr>
            </tbody>
          </TableWrap>
        </Card>
      </div>
    </Page>
  );
}
