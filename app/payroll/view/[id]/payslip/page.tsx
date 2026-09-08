import Link from 'next/link';
import { notFound } from 'next/navigation';
import { requireAction } from '@/lib/session';
import { getPayslip, listPayrollPeriods } from '@/lib/payroll';
import { getOrgBrand } from '@/lib/org';
import { Page } from '@/components/layout/page';
import { Card, CardHead, DefinitionList, EmptyState, TableWrap, Toolbar, Spacer } from '@/components/ui/primitives';
import { Money } from '@/components/ui/money';

const SECTION_LABELS: Record<string, string> = {
  BASIC: 'Basic Pay', ALLOWANCE: 'Allowances', STATUTORY: 'Statutory Deductions',
  DEDUCTION: 'Other Deductions', EMPLOYER: 'Employer Contributions', NET: 'Net Pay',
};

export default async function PayslipPage({ params, searchParams }: {
  params: Promise<{ id: string }>;
  searchParams: Promise<{ period?: string }>;
}) {
  const user = await requireAction('PAYROLL_READ');
  const { id: idParam } = await params;
  const { period: periodParam } = await searchParams;
  const employeeId = Number(idParam);

  const periods = await listPayrollPeriods();
  if (!periods.length) {
    return (
      <Page title="Payslip" crumb="No payroll periods yet" user={user}>
        <Card><EmptyState icon="🧾" title="No payroll periods yet" /></Card>
      </Page>
    );
  }
  const periodId = periodParam ? Number(periodParam) : periods.find((p) => p.status === 'OPEN')?.id ?? periods[0].id;

  const [slip, org] = await Promise.all([getPayslip(periodId, employeeId), getOrgBrand()]);
  if (!slip) notFound();

  const bySection = new Map<string, typeof slip.lines>();
  for (const l of slip.lines) {
    if (!bySection.has(l.section)) bySection.set(l.section, []);
    bySection.get(l.section)!.push(l);
  }
  const sectionOrder = ['BASIC', 'ALLOWANCE', 'STATUTORY', 'DEDUCTION', 'EMPLOYER', 'NET'];

  return (
    <Page title={`Payslip — ${slip.employee.first_name} ${slip.employee.last_name}`} crumb={`${org!.name} · ${slip.period.period_name}`} user={user}>
      <Toolbar>
        <Link href={`/payroll/view/${employeeId}`} className="btn ghost sm">← Back</Link>
        <Spacer />
        <div className="inline">
          {periods.map((p) => (
            <Link key={p.id} href={`/payroll/view/${employeeId}/payslip?period=${p.id}`}
              className={`btn sm ${p.id === periodId ? '' : 'ghost'}`}>
              {p.period_name}
            </Link>
          ))}
        </div>
      </Toolbar>

      <Card>
        <CardHead title={`${slip.employee.first_name} ${slip.employee.last_name}`} sub={slip.employee.job_title || undefined} />
        <DefinitionList items={[
          ['Employee No.', slip.employee.employee_no],
          ['Period', `${slip.period.period_name} (${slip.period.start_date} to ${slip.period.end_date})`],
        ]} />
      </Card>

      {!slip.lines.length ? (
        <Card><EmptyState icon="🧾" title="Not processed for this period" /></Card>
      ) : (
        <>
          {sectionOrder.filter((s) => bySection.has(s)).map((section) => (
            <Card key={section}>
              <CardHead title={SECTION_LABELS[section] || section} />
              <TableWrap>
                <tbody>
                  {bySection.get(section)!.map((l, i) => (
                    <tr key={i}>
                      <td>{l.name}</td>
                      <td className="num"><Money cents={l.amountCents} /></td>
                    </tr>
                  ))}
                </tbody>
              </TableWrap>
            </Card>
          ))}
          {slip.p9 ? (
            <Card>
              <CardHead title="Summary" />
              <TableWrap>
                <tbody>
                  <tr><td>Gross pay</td><td className="num"><Money cents={slip.p9.gross_pay_cents} /></td></tr>
                  <tr><td>Taxable pay</td><td className="num"><Money cents={slip.p9.taxable_pay_cents} /></td></tr>
                  <tr><td>PAYE</td><td className="num"><Money cents={slip.p9.paye_cents} /></td></tr>
                  <tr><td>NSSF</td><td className="num"><Money cents={slip.p9.nssf_cents} /></td></tr>
                  <tr><td>SHIF</td><td className="num"><Money cents={slip.p9.shif_cents} /></td></tr>
                  <tr><td>Housing Levy</td><td className="num"><Money cents={slip.p9.housing_levy_cents} /></td></tr>
                  <tr><td>Other deductions</td><td className="num"><Money cents={slip.p9.deductions_cents} /></td></tr>
                  <tr><td><b>Net pay</b></td><td className="num"><b><Money cents={slip.p9.net_pay_cents} /></b></td></tr>
                </tbody>
              </TableWrap>
            </Card>
          ) : null}
        </>
      )}
    </Page>
  );
}
