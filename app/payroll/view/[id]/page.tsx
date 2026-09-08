import Link from 'next/link';
import { notFound } from 'next/navigation';
import { requireAction, currentCanAction } from '@/lib/session';
import { getEmployee, getCurrentContract } from '@/lib/employees';
import { getOpenPayrollPeriod, listEmployeeTransactions, listPeriodLines } from '@/lib/payroll';
import { listTransactionCodes } from '@/lib/payrollSetup';
import { Page } from '@/components/layout/page';
import { Card, CardHead, DefinitionList, EmptyState, Pill, TableWrap, Toolbar, Spacer } from '@/components/ui/primitives';
import { CollapsibleCard } from '@/components/ui/collapsible-card';
import { Money } from '@/components/ui/money';
import { RunForEmployeeButton, AddTransactionButton, StopTransactionButton, RemoveTransactionButton } from '../../payroll-actions';

export default async function EmployeePayrollPage({ params }: { params: Promise<{ id: string }> }) {
  const user = await requireAction('PAYROLL_READ');
  const { id: idParam } = await params;
  const employeeId = Number(idParam);

  const emp = await getEmployee(employeeId);
  if (!emp) notFound();

  const [contract, period, canRun, canManage, codes] = await Promise.all([
    getCurrentContract(employeeId), getOpenPayrollPeriod(),
    currentCanAction('PAYROLL_PERIODS_RUN'), currentCanAction('PAYROLL_MANAGE_TRANSACTIONS'),
    listTransactionCodes(),
  ]);
  const transactions = period ? await listEmployeeTransactions(employeeId, period.id) : [];
  const periodLines = period ? await listPeriodLines(period.id, employeeId) : [];

  return (
    <Page title={`${emp.first_name} ${emp.last_name} — Payroll`} crumb={`${emp.employee_no}${period ? ` · ${period.period_name}` : ' · No open period'}`} user={user}>
      <Toolbar>
        <Link href="/payroll" className="btn ghost sm">← All employees</Link>
        <Link href={`/employees/view/${employeeId}`} className="btn ghost sm">View employee</Link>
        {period ? <Link href={`/payroll/view/${employeeId}/payslip?period=${period.id}`} className="btn ghost sm">View payslip</Link> : null}
        <Link href={`/payroll/view/${employeeId}/p9`} className="btn ghost sm">P9 (annual)</Link>
        <Spacer />
        {period && canRun ? <RunForEmployeeButton periodId={period.id} employeeId={employeeId} /> : null}
      </Toolbar>

      <CollapsibleCard title="Salary" sub="From the employee's current contract">
        <DefinitionList items={[
          ['Basic pay', contract ? <Money cents={contract.salary_cents} key="s" /> : '—'],
          ['Job title', contract?.job_title || '—'],
          ['Contract start', contract?.start_date || '—'],
        ]} />
      </CollapsibleCard>

      {!period ? (
        <Card><EmptyState icon="💰" title="No open payroll period" sub={<>Start one under <Link href="/payroll/periods">Payroll Periods</Link>.</>} /></Card>
      ) : (
        <>
          <Card>
            <CardHead title="Earnings & deductions" sub={`Recurring and one-off lines for ${period.period_name}`}>
              {canManage && period.status === 'OPEN' ? <AddTransactionButton employeeId={employeeId} periodId={period.id} codes={codes} /> : null}
            </CardHead>
            {transactions.length ? (
              <TableWrap>
                <thead><tr><th>Code</th><th>Type</th><th className="num">Amount</th><th className="num">Balance</th><th>Stopped</th><th className="num" /></tr></thead>
                <tbody>
                  {transactions.map((t) => (
                    <tr key={t.id}>
                      <td>{t.transaction_code_name}</td>
                      <td>{t.transaction_type.replace('_', ' ')}</td>
                      <td className="num"><Money cents={t.amount_cents} /></td>
                      <td className="num">{t.balance_cents != null ? <Money cents={t.balance_cents} /> : '—'}</td>
                      <td>{t.stopped ? <Pill tone="warn">Stopped</Pill> : '—'}</td>
                      <td className="num">
                        {canManage && period.status === 'OPEN' ? <>
                          <StopTransactionButton id={t.id} stopped={t.stopped} />{' '}
                          <RemoveTransactionButton id={t.id} />
                        </> : null}
                      </td>
                    </tr>
                  ))}
                </tbody>
              </TableWrap>
            ) : <EmptyState icon="🧾" title="No recurring lines yet" />}
          </Card>

          <Card>
            <CardHead title="Computed payslip" sub={periodLines.length ? 'From the last Process run' : 'Not yet processed'} />
            {periodLines.length ? (
              <TableWrap>
                <thead><tr><th>Section</th><th>Code</th><th className="num">Amount</th><th>Dr/Cr</th></tr></thead>
                <tbody>
                  {periodLines.map((l) => (
                    <tr key={l.id}>
                      <td>{l.section}</td>
                      <td>{l.transaction_code_name}</td>
                      <td className="num"><Money cents={l.amount_cents} /></td>
                      <td>{l.is_debit ? 'Debit' : 'Credit'}</td>
                    </tr>
                  ))}
                </tbody>
              </TableWrap>
            ) : <EmptyState icon="🧮" title="Not processed for this period yet" />}
          </Card>
        </>
      )}
    </Page>
  );
}
