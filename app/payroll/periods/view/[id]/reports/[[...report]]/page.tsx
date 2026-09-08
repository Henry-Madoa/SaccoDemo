import Link from 'next/link';
import { notFound } from 'next/navigation';
import { requireAction } from '@/lib/session';
import {
  getPayrollPeriod, getCompanySummary, getNetPayReport, getNssfReport, getShifReport,
  getPayeReport, getHousingLevyReport, getPayrollRegister, getDeductionsReport,
} from '@/lib/payroll';
import { Page } from '@/components/layout/page';
import { Card, CardHead, EmptyState, TableWrap, Tabs, Toolbar, Spacer, type TabDefinition } from '@/components/ui/primitives';
import { Money } from '@/components/ui/money';
import { ExportButton } from '@/components/ui/export-button';

const TABS: TabDefinition[] = [
  { key: 'summary', label: 'Company Summary' },
  { key: 'register', label: 'Payroll Register' },
  { key: 'net-pay', label: 'Net Pay Report' },
  { key: 'paye', label: 'PAYE' },
  { key: 'nssf', label: 'NSSF' },
  { key: 'shif', label: 'SHIF' },
  { key: 'housing-levy', label: 'Housing Levy' },
  { key: 'deductions', label: 'Deductions' },
];

export default async function PayrollReportsPage({ params }: { params: Promise<{ id: string; report?: string[] }> }) {
  const user = await requireAction('PAYROLL_PERIODS_READ');
  const { id: idParam, report: segments } = await params;
  const periodId = Number(idParam);

  const period = await getPayrollPeriod(periodId);
  if (!period) notFound();

  const requested = segments?.[0];
  if (requested && !TABS.some((t) => t.key === requested)) notFound();
  const tab = requested ?? 'summary';

  return (
    <Page title={`${period.period_name} — Reports`} crumb="Printable payroll reports" user={user}>
      <Toolbar>
        <Link href={`/payroll/periods/view/${periodId}`} className="btn ghost sm">← Back to period</Link>
      </Toolbar>
      <Tabs tabs={TABS} active={tab} hrefFor={(k) => `/payroll/periods/view/${periodId}/reports/${k}`} />

      {tab === 'summary' ? <SummaryReport periodId={periodId} /> : null}
      {tab === 'register' ? <RegisterReport periodId={periodId} /> : null}
      {tab === 'net-pay' ? <NetPayReport periodId={periodId} /> : null}
      {tab === 'paye' ? <StatutoryReport periodId={periodId} title="PAYE Report" load={getPayeReport} exportKind="paye" /> : null}
      {tab === 'nssf' ? <StatutoryReport periodId={periodId} title="NSSF Report" load={getNssfReport} exportKind="nssf" /> : null}
      {tab === 'shif' ? <StatutoryReport periodId={periodId} title="SHIF Report" load={getShifReport} exportKind="shif" /> : null}
      {tab === 'housing-levy' ? <StatutoryReport periodId={periodId} title="Housing Levy Report" load={getHousingLevyReport} exportKind="housing-levy" /> : null}
      {tab === 'deductions' ? <DeductionsReportView periodId={periodId} /> : null}
    </Page>
  );
}

async function RegisterReport({ periodId }: { periodId: number }) {
  const rows = await getPayrollRegister(periodId);
  return (
    <>
      <Toolbar>
        <Spacer />
        <ExportButton href="/api/export/payroll-register" params={{ period: String(periodId) }} disabled={!rows.length}>Export to Excel</ExportButton>
      </Toolbar>
      <Card>
        <CardHead title="Payroll Register" sub="Every figure on each employee's payslip, one row per employee" />
        {rows.length ? (
          <div style={{ overflowX: 'auto' }}>
            <TableWrap>
              <thead>
                <tr>
                  <th>Employee No.</th><th>Name</th><th className="num">Basic</th><th className="num">Allowances</th>
                  <th className="num">Gross</th><th className="num">Taxable</th><th className="num">PAYE</th>
                  <th className="num">NSSF</th><th className="num">SHIF</th><th className="num">Housing Levy</th>
                  <th className="num">Deductions</th><th className="num">Net Pay</th>
                </tr>
              </thead>
              <tbody>
                {rows.map((r) => (
                  <tr key={r.employeeId}>
                    <td className="mono">{r.employeeNo}</td><td>{r.name}</td>
                    <td className="num"><Money cents={r.basicCents} /></td>
                    <td className="num"><Money cents={r.allowancesCents} /></td>
                    <td className="num"><Money cents={r.grossCents} /></td>
                    <td className="num"><Money cents={r.taxableCents} /></td>
                    <td className="num"><Money cents={r.payeCents} /></td>
                    <td className="num"><Money cents={r.nssfCents} /></td>
                    <td className="num"><Money cents={r.shifCents} /></td>
                    <td className="num"><Money cents={r.housingLevyCents} /></td>
                    <td className="num"><Money cents={r.deductionsCents} /></td>
                    <td className="num"><b><Money cents={r.netCents} /></b></td>
                  </tr>
                ))}
              </tbody>
            </TableWrap>
          </div>
        ) : <EmptyState icon="📋" title="Not processed yet" />}
      </Card>
    </>
  );
}

async function DeductionsReportView({ periodId }: { periodId: number }) {
  const rows = await getDeductionsReport(periodId);
  const total = rows.reduce((s, r) => s + r.amountCents, 0);
  return (
    <>
      <Toolbar>
        <Spacer />
        <ExportButton href="/api/export/payroll-deductions" params={{ period: String(periodId) }} disabled={!rows.length}>Export to Excel</ExportButton>
      </Toolbar>
      <Card>
        <CardHead title="Deductions Report" sub={`Non-statutory deductions (loans, welfare, insurance, ...) — total ${(total / 100).toLocaleString()}`} />
        {rows.length ? (
          <TableWrap>
            <thead><tr><th>Employee No.</th><th>Name</th><th>Deduction</th><th className="num">Amount</th></tr></thead>
            <tbody>
              {rows.map((r, i) => (
                <tr key={i}>
                  <td className="mono">{r.employeeNo}</td><td>{r.name}</td><td>{r.codeName}</td>
                  <td className="num"><Money cents={r.amountCents} /></td>
                </tr>
              ))}
            </tbody>
          </TableWrap>
        ) : <EmptyState icon="🧾" title="No deductions this period" />}
      </Card>
    </>
  );
}

async function SummaryReport({ periodId }: { periodId: number }) {
  const s = await getCompanySummary(periodId);
  return (
    <>
      <Toolbar>
        <Spacer />
        <ExportButton href="/api/export/payroll-company-summary" params={{ period: String(periodId) }}>Export to Excel</ExportButton>
      </Toolbar>
      <div className="grid g4 stack-2">
        <Card><CardHead title="Employees" /><div className="num" style={{ fontSize: 24 }}>{s.employeeCount}</div></Card>
        <Card><CardHead title="Gross pay" /><div className="num" style={{ fontSize: 24 }}><Money cents={s.grossPayCents} /></div></Card>
        <Card><CardHead title="Total PAYE" /><div className="num" style={{ fontSize: 24 }}><Money cents={s.payeCents} /></div></Card>
        <Card><CardHead title="Net pay" /><div className="num" style={{ fontSize: 24 }}><Money cents={s.netPayCents} /></div></Card>
      </div>
      <Card>
        <CardHead title="Statutory totals" />
        <TableWrap>
          <tbody>
            <tr><td>Taxable pay</td><td className="num"><Money cents={s.taxablePayCents} /></td></tr>
            <tr><td>PAYE</td><td className="num"><Money cents={s.payeCents} /></td></tr>
            <tr><td>NSSF — employee</td><td className="num"><Money cents={s.nssfEmployeeCents} /></td></tr>
            <tr><td>NSSF — employer</td><td className="num"><Money cents={s.nssfEmployerCents} /></td></tr>
            <tr><td>SHIF</td><td className="num"><Money cents={s.shifCents} /></td></tr>
            <tr><td>Housing Levy — employee</td><td className="num"><Money cents={s.housingLevyEmployeeCents} /></td></tr>
            <tr><td>Housing Levy — employer</td><td className="num"><Money cents={s.housingLevyEmployerCents} /></td></tr>
            <tr><td>Other deductions</td><td className="num"><Money cents={s.deductionsCents} /></td></tr>
            <tr><td><b>Net pay</b></td><td className="num"><b><Money cents={s.netPayCents} /></b></td></tr>
          </tbody>
        </TableWrap>
      </Card>
      <Card>
        <CardHead title="By department" />
        {s.byDepartment.length ? (
          <TableWrap>
            <thead><tr><th>Department</th><th className="num">Employees</th><th className="num">Gross pay</th><th className="num">Net pay</th></tr></thead>
            <tbody>
              {s.byDepartment.map((d) => (
                <tr key={d.name}>
                  <td>{d.name}</td><td className="num">{d.employeeCount}</td>
                  <td className="num"><Money cents={d.grossPayCents} /></td><td className="num"><Money cents={d.netPayCents} /></td>
                </tr>
              ))}
            </tbody>
          </TableWrap>
        ) : <EmptyState icon="🏢" title="No data" />}
      </Card>
    </>
  );
}

async function NetPayReport({ periodId }: { periodId: number }) {
  const rows = await getNetPayReport(periodId);
  const totalNet = rows.reduce((s, r) => s + r.netPayCents, 0);
  return (
    <>
      <Toolbar>
        <Spacer />
        <ExportButton href="/api/export/payroll-net-pay" params={{ period: String(periodId) }} disabled={!rows.length}>Export to Excel</ExportButton>
      </Toolbar>
      <Card>
        <CardHead title="Net Pay Report" sub={`Total net pay: ${(totalNet / 100).toLocaleString()}`} />
        {rows.length ? (
          <TableWrap>
            <thead><tr><th>Employee No.</th><th>Name</th><th className="num">Gross pay</th><th className="num">Deductions</th><th className="num">Net pay</th></tr></thead>
            <tbody>
              {rows.map((r) => (
                <tr key={r.employeeId}>
                  <td className="mono">{r.employeeNo}</td><td>{r.name}</td>
                  <td className="num"><Money cents={r.grossPayCents} /></td>
                  <td className="num"><Money cents={r.totalDeductionsCents} /></td>
                  <td className="num"><Money cents={r.netPayCents} /></td>
                </tr>
              ))}
            </tbody>
          </TableWrap>
        ) : <EmptyState icon="💰" title="Not processed yet" />}
      </Card>
    </>
  );
}

async function StatutoryReport({ periodId, title, load, exportKind }: {
  periodId: number; title: string;
  load: (periodId: number) => Promise<{ employeeId: number; employeeNo: string; name: string; amountCents: number }[]>;
  exportKind: string;
}) {
  const rows = await load(periodId);
  const total = rows.reduce((s, r) => s + r.amountCents, 0);
  return (
    <>
      <Toolbar>
        <Spacer />
        <ExportButton href="/api/export/payroll-statutory" params={{ period: String(periodId), kind: exportKind }} disabled={!rows.length}>
          Export to Excel
        </ExportButton>
      </Toolbar>
      <Card>
        <CardHead title={title} sub={`Total: ${(total / 100).toLocaleString()}`} />
        {rows.length ? (
          <TableWrap>
            <thead><tr><th>Employee No.</th><th>Name</th><th className="num">Amount</th></tr></thead>
            <tbody>
              {rows.map((r) => (
                <tr key={r.employeeId}>
                  <td className="mono">{r.employeeNo}</td><td>{r.name}</td><td className="num"><Money cents={r.amountCents} /></td>
                </tr>
              ))}
            </tbody>
          </TableWrap>
        ) : <EmptyState icon="🧾" title="Not processed yet" />}
      </Card>
    </>
  );
}
