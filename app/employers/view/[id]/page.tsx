import Link from 'next/link';
import { notFound } from 'next/navigation';
import { requireAction } from '@/lib/session';
import { getEmployer, getEmployerStats, listEmployerMembers } from '@/lib/employers';
import { Page } from '@/components/layout/page';
import {
  Card, CardHead, DefinitionList, EmptyState, Pill, Stat, TableWrap, Toolbar,
} from '@/components/ui/primitives';
import { Money } from '@/components/ui/money';

export default async function EmployerViewPage({ params }: { params: Promise<{ id: string }> }) {
  const user = await requireAction('EMPLOYERS_MANAGE');
  const { id } = await params;
  const employer = await getEmployer(Number(id));
  if (!employer) notFound();

  const [stats, members] = await Promise.all([
    getEmployerStats(employer.id),
    listEmployerMembers(employer.id),
  ]);

  const totalAssets = stats.total_deposits + stats.total_shares + stats.total_fixed_deposits;

  return (
    <Page title={employer.name} crumb={`Employer ${employer.code} · ${employer.status}`} user={user}>
      <Toolbar>
        <Link href="/admin/pool/hr-payroll/employers" className="btn ghost sm">← All employers</Link>
        <Link href="/checkoff-batches" className="btn ghost sm">Checkoff & Salary batches</Link>
      </Toolbar>

      <div className="grid g4 stack-2">
        <Stat label="Members" value={String(stats.member_count)}
          foot={`${stats.active_member_count} active · ${stats.withdrawn_member_count} withdrawn`} />
        <Stat label="Assets — member deposits" value={<Money cents={totalAssets} decimals={0} />}
          foot={<>savings <Money cents={stats.total_deposits} decimals={0} /> · shares{' '}
            <Money cents={stats.total_shares} decimals={0} /> · fixed deposits{' '}
            <Money cents={stats.total_fixed_deposits} decimals={0} /></>} />
        <Stat label="Liabilities — outstanding loans" value={<Money cents={stats.outstanding_loan_balance} decimals={0} />}
          foot={`${stats.disbursed_loan_count} disbursed loan${stats.disbursed_loan_count === 1 ? '' : 's'}`} />
        <Stat label="Checkoff & Salary processed" value={<Money cents={stats.total_remitted} decimals={0} />}
          foot={`${stats.checkoff_batch_count} batch${stats.checkoff_batch_count === 1 ? '' : 'es'} processed`} />
      </div>

      <div className="grid split-side-sm">
        <div>
          <Card>
            <CardHead title="Employer details" />
            <DefinitionList items={[
              ['Code', <span className="mono" key="code">{employer.code}</span>],
              ['Name', employer.name],
              ['Phone', employer.phone || '—'],
              ['Email', employer.email || '—'],
              ['Payroll No. mandatory', employer.payroll_no_mandatory ? 'Yes' : 'No'],
              ['Status', <Pill status={employer.status} key="status" />],
            ]} />
          </Card>

          <Card>
            <CardHead title="Membership by status" />
            {stats.member_status_breakdown.length ? (
              <TableWrap>
                <thead><tr><th>Status</th><th className="num">Members</th></tr></thead>
                <tbody>
                  {stats.member_status_breakdown.map((s) => (
                    <tr key={s.status}>
                      <td><Pill status={s.status} /></td>
                      <td className="num">{s.count}</td>
                    </tr>
                  ))}
                </tbody>
              </TableWrap>
            ) : <EmptyState icon="👥" title="No members linked yet" />}
          </Card>
        </div>

        <div>
          <Card>
            <CardHead title="Members" sub="Linked via the member's Employment card" />
            {members.length ? (
              <TableWrap>
                <thead>
                  <tr>
                    <th>Member</th><th>Status</th><th className="num">Deposits</th><th className="num">Loans outstanding</th>
                  </tr>
                </thead>
                <tbody>
                  {members.map((m) => (
                    <tr key={m.id}>
                      <td>
                        <Link href={`/members/${m.id}`}>{m.first_name} {m.last_name}</Link>
                        <div className="tiny mono">{m.member_no}</div>
                      </td>
                      <td><Pill status={m.status} /></td>
                      <td className="num"><Money cents={m.deposits} decimals={0} /></td>
                      <td className="num"><Money cents={m.outstanding_loans} decimals={0} /></td>
                    </tr>
                  ))}
                </tbody>
              </TableWrap>
            ) : <EmptyState icon="👥" title="No members linked to this employer yet" />}
          </Card>
        </div>
      </div>
    </Page>
  );
}
