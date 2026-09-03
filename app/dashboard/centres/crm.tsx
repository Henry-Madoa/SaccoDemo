import Link from 'next/link';
import { currentCanAction } from '@/lib/session';
import { getOrgBrand } from '@/lib/org';
import { getCrmRoleCenter } from '@/lib/roleCenters';
import { formatDate, today } from '@/lib/format';
import { Page } from '@/components/layout/page';
import { Card, CardHead, EmptyState, TableWrap } from '@/components/ui/primitives';
import { Money } from '@/components/ui/money';
import { KpiTile, LockedCard } from './shared';
import { MonthTrend, MagnitudeBars, StatusDonut } from '../role-center-charts';
import type { SessionUser } from '@/lib/types';

export async function CrmRoleCentre({ user }: { user: SessionUser }) {
  const canMembers = await currentCanAction('MEMBERS_READ');
  const canApps = await currentCanAction('MEMBER_APPLICATIONS_READ');
  const [org, d] = await Promise.all([getOrgBrand(), getCrmRoleCenter()]);
  const months = d.membersByMonth.map((m) => m.month);

  return (
    <Page title="Client Relationship Management" crumb={`${org!.name} · as at ${formatDate(today())}`} user={user}>
      {canMembers ? (
        <div className="grid g4 stack-2">
          <KpiTile label="Total members" value={d.members.total.toLocaleString()}
            foot={`${d.members.active} active`}
            spark={d.membersByMonth.map((m) => m.running)} />
          <KpiTile label="Joined this month" value={d.members.joinedThisMonth}
            spark={d.membersByMonth.map((m) => m.joined)} sparkColor="var(--series-3)" />
          <KpiTile accent={false} label="Dormant members" value={d.members.dormant}
            foot={`${d.members.notPaidUp} not paid up`} />
          <KpiTile accent={false} label="Exits vs re-admissions (YTD)"
            value={`${d.churn.exitsYtd} / ${d.churn.readmissionsYtd}`} />
        </div>
      ) : <LockedCard title="Membership KPIs" />}

      <div className="grid split-wide">
        {canMembers ? (
          <Card>
            <CardHead title="Membership growth" sub="New members per month and the running roll" />
            <MonthTrend months={months} money={false} area
              series={[{ name: 'Members', values: d.membersByMonth.map((m) => m.running) }]} />
          </Card>
        ) : <LockedCard title="Membership growth" />}

        {canApps ? (
          <Card>
            <CardHead title="Application pipeline" sub="Member applications by stage">
              <Link href="/member-applications" className="btn sm ghost">Open</Link>
            </CardHead>
            {d.pipeline.some((p) => p.count) ? (
              <MagnitudeBars money={false} rows={d.pipeline.map((p) => ({ label: p.stage, value: p.count }))} />
            ) : <EmptyState icon="📝" title="No applications in progress" />}
          </Card>
        ) : <LockedCard title="Application pipeline" />}
      </div>

      <div className="grid split-narrow">
        {canMembers ? (
          <Card>
            <CardHead title="Members by category" />
            {d.byCategory.length ? (
              <StatusDonut centerLabel="members" rows={d.byCategory.map((c) => ({ label: c.name, value: c.count }))} />
            ) : <EmptyState icon="👥" title="No members yet" />}
          </Card>
        ) : <LockedCard title="Members by category" />}

        {canMembers ? (
          <Card>
            <CardHead title="Dormancy ageing"
              sub="Active accounts by days since their last transaction" />
            <TableWrap>
              <thead><tr><th>Days idle</th><th className="num">Accounts</th><th className="num">Balance held</th></tr></thead>
              <tbody>
                {d.dormancy.map((b) => (
                  <tr key={b.bucket}>
                    <td>{b.bucket}</td>
                    <td className="num">{b.accounts}</td>
                    <td className="num"><Money cents={b.balance} decimals={0} /></td>
                  </tr>
                ))}
              </tbody>
            </TableWrap>
          </Card>
        ) : <LockedCard title="Dormancy ageing" />}
      </div>
    </Page>
  );
}
