import Link from 'next/link';
import { requireAction } from '@/lib/session';
import { getP9Annual } from '@/lib/payroll';
import { getOrgBrand } from '@/lib/org';
import { Page } from '@/components/layout/page';
import { Card, CardHead, DefinitionList, EmptyState, TableWrap, Toolbar, Spacer } from '@/components/ui/primitives';
import { Money } from '@/components/ui/money';

export default async function P9Page({ params, searchParams }: {
  params: Promise<{ id: string }>;
  searchParams: Promise<{ year?: string }>;
}) {
  const user = await requireAction('PAYROLL_READ');
  const { id: idParam } = await params;
  const { year: yearParam } = await searchParams;
  const employeeId = Number(idParam);
  const year = yearParam || String(new Date().getFullYear());

  const [{ employee, rows, totals }, org] = await Promise.all([getP9Annual(employeeId, year), getOrgBrand()]);
  const years = Array.from({ length: 5 }, (_, i) => String(new Date().getFullYear() - i));

  return (
    <Page title={`P9 — ${employee.first_name} ${employee.last_name}`} crumb={`${org!.name} · Tax year ${year}`} user={user}>
      <Toolbar>
        <Link href={`/payroll/view/${employeeId}`} className="btn ghost sm">← Back</Link>
        <Spacer />
        <div className="inline">
          {years.map((y) => (
            <Link key={y} href={`/payroll/view/${employeeId}/p9?year=${y}`} className={`btn sm ${y === year ? '' : 'ghost'}`}>{y}</Link>
          ))}
        </div>
      </Toolbar>

      <Card>
        <CardHead title={`${employee.first_name} ${employee.last_name}`} />
        <DefinitionList items={[
          ['Employee No.', employee.employee_no],
          ['KRA PIN', employee.kra_pin || '—'],
          ['Tax year', year],
        ]} />
      </Card>

      <Card>
        <CardHead title="Monthly breakdown" sub="P9 — Kenyan annual tax deduction card" />
        {rows.length ? (
          <div style={{ overflowX: 'auto' }}>
            <TableWrap>
              <thead>
                <tr>
                  <th>Period</th><th className="num">Gross Pay</th><th className="num">Taxable Pay</th>
                  <th className="num">NSSF</th><th className="num">SHIF</th><th className="num">Personal Relief</th>
                  <th className="num">Insurance Relief</th><th className="num">PAYE</th><th className="num">Net Pay</th>
                </tr>
              </thead>
              <tbody>
                {rows.map((r) => (
                  <tr key={r.periodName}>
                    <td>{r.periodName}</td>
                    <td className="num"><Money cents={r.grossCents} /></td>
                    <td className="num"><Money cents={r.taxableCents} /></td>
                    <td className="num"><Money cents={r.nssfCents} /></td>
                    <td className="num"><Money cents={r.shifCents} /></td>
                    <td className="num"><Money cents={r.personalReliefCents} /></td>
                    <td className="num"><Money cents={r.insuranceReliefCents} /></td>
                    <td className="num"><Money cents={r.payeCents} /></td>
                    <td className="num"><Money cents={r.netCents} /></td>
                  </tr>
                ))}
                <tr>
                  <td><b>Total</b></td>
                  <td className="num"><b><Money cents={totals.grossCents} /></b></td>
                  <td className="num"><b><Money cents={totals.taxableCents} /></b></td>
                  <td className="num"><b><Money cents={totals.nssfCents} /></b></td>
                  <td className="num"><b><Money cents={totals.shifCents} /></b></td>
                  <td className="num"><b><Money cents={totals.personalReliefCents} /></b></td>
                  <td className="num"><b><Money cents={totals.insuranceReliefCents} /></b></td>
                  <td className="num"><b><Money cents={totals.payeCents} /></b></td>
                  <td className="num"><b><Money cents={totals.netCents} /></b></td>
                </tr>
              </tbody>
            </TableWrap>
          </div>
        ) : <EmptyState icon="🧾" title={`No payroll runs found for ${year}`} />}
      </Card>
    </Page>
  );
}
