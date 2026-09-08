import Link from 'next/link';
import { notFound } from 'next/navigation';
import { requireAction, currentCanAction } from '@/lib/session';
import {
  getEmployee, getAdjacentEmployeeIds, listActiveEmployees, listNextOfKin, listBeneficiaries, listDependants,
  listEmergencyContacts, listProfessionalBodies, listWorkHistory, listBankAccounts, listContracts,
  type EmployeeListView,
} from '@/lib/employees';
import { listJobGrades, listContractTypes } from '@/lib/hrSetup';
import { listCounties, listSubCounties, listDimensionValues } from '@/lib/pool';
import { getDimensionCaptions } from '@/lib/org';
import { findPendingRoutedTask, isEligibleApprover, listWorkflowTasksForDocument } from '@/lib/workflow';
import { formatDateTime } from '@/lib/format';
import { Page } from '@/components/layout/page';
import { DefinitionList, EmptyState, Pill, TableWrap, Toolbar, Spacer } from '@/components/ui/primitives';
import { CollapsibleCard } from '@/components/ui/collapsible-card';
import { Money } from '@/components/ui/money';
import { DocumentActionsMenu } from '@/components/ui/document-actions';
import { CardNav } from '@/components/ui/card-nav';
import {
  DeleteButton, SubmitButton, CancelApprovalButton, ApproveButton, RejectButton, DelegateButton,
  type EmployeeLookups,
} from '../../employee-actions';
import { BioDataCard, EmploymentCard, BankingCard } from '../../employee-info-cards';
import {
  NextOfKinPanel, BeneficiariesPanel, DependantsPanel, EmergencyContactsPanel,
  ProfessionalBodiesPanel, WorkHistoryPanel, BankAccountsPanel,
} from '../../sub-entity-panels';

const VIEWS: EmployeeListView[] = ['new', 'pending', 'active', 'inactive', 'all'];

export default async function EmployeeDetailPage({ params, searchParams }: {
  params: Promise<{ id: string }>;
  searchParams: Promise<{ view?: string; edit?: string }>;
}) {
  const user = await requireAction('EMPLOYEES_READ');
  const { id: idParam } = await params;
  const id = Number(idParam);
  const { view: viewRaw, edit } = await searchParams;
  const view = VIEWS.includes(viewRaw as EmployeeListView) ? (viewRaw as EmployeeListView) : undefined;
  const startEditing = edit === '1';

  const emp = await getEmployee(id);
  if (!emp) notFound();

  const [
    canCreate, canApprove, tasks, { prevId, nextId }, gd1Values, gd2Values, { caption1, caption2 },
    jobGrades, contractTypes, counties, subCounties,
    managers, nextOfKin, beneficiaries, dependants, emergencyContacts, professionalBodies, workHistory, bankAccounts, contracts,
  ] = await Promise.all([
    currentCanAction('EMPLOYEES_CREATE'),
    currentCanAction('EMPLOYEES_APPROVE'),
    listWorkflowTasksForDocument('EMPLOYEE_ONBOARDING', String(id)),
    getAdjacentEmployeeIds(id, view),
    listDimensionValues(1), listDimensionValues(2), getDimensionCaptions(),
    listJobGrades(), listContractTypes(), listCounties(), listSubCounties(), listActiveEmployees(),
    listNextOfKin(id), listBeneficiaries(id), listDependants(id), listEmergencyContacts(id),
    listProfessionalBodies(id), listWorkHistory(id), listBankAccounts(id), listContracts(id),
  ]);
  const lookups: EmployeeLookups = {
    globalDimension1Values: gd1Values, globalDimension2Values: gd2Values, caption1, caption2,
    jobGrades, contractTypes, counties, subCounties, managers,
  };

  const isOwn = emp.created_by === user.username;
  const isNew = emp.status === 'NEW';
  const canManageSubEntities = isNew && canCreate && isOwn;

  const routedTask = emp.status === 'PENDING_APPROVAL' ? await findPendingRoutedTask('EMPLOYEE_ONBOARDING', String(id)) : null;
  const canDecideThis = routedTask ? await isEligibleApprover(routedTask, user.id) : canApprove;
  const requestedBy = routedTask?.requested_by ?? emp.created_by;
  const canCancelThis = canCreate && requestedBy === user.username;
  const pendingWith = tasks.find((t) => t.status === 'PENDING')?.pending_with;
  const q = view ? `?view=${view}` : '';

  return (
    <>
      <CardNav prevHref={prevId ? `/employees/view/${prevId}${q}` : null} nextHref={nextId ? `/employees/view/${nextId}${q}` : null} />
      <Page
        title={`${emp.first_name} ${emp.last_name} — ${emp.employee_no}`}
        crumb={`${emp.status}${emp.global_dimension_2_name ? ` · ${emp.global_dimension_2_name}` : ''}${pendingWith ? ` · pending with ${pendingWith}` : ''}`}
        user={user}
      >
        <Toolbar>
          <Link href="/employees" className="btn ghost sm">← All employees</Link>
          <Spacer />
          {isNew && canCreate && isOwn ? <DeleteButton id={emp.id} className="btn ghost" /> : null}
          {isNew && canCreate && isOwn ? <SubmitButton id={emp.id} className="btn ghost" /> : null}
          {emp.status === 'PENDING_APPROVAL' && canCancelThis ? <CancelApprovalButton id={emp.id} className="btn ghost" /> : null}
          {emp.status === 'PENDING_APPROVAL' && canDecideThis ? (
            <>
              {routedTask ? <DelegateButton taskId={routedTask.id} className="btn ghost" /> : null}
              <ApproveButton id={emp.id} />
              <RejectButton id={emp.id} className="btn ghost" />
            </>
          ) : null}
          <DocumentActionsMenu />
        </Toolbar>

        <CollapsibleCard title="Status">
          <DefinitionList items={[
            ['Status', <Pill status={emp.status} key="st" />],
            emp.decision_reason ? ['Decision reason', emp.decision_reason] : null,
          ]} />
        </CollapsibleCard>

        <BioDataCard employee={emp} lookups={lookups} canEdit={canManageSubEntities} startEditing={startEditing} />
        <EmploymentCard employee={emp} lookups={lookups} canEdit={canManageSubEntities} />
        <BankingCard employee={emp} canEdit={canManageSubEntities} />

        <CollapsibleCard title="Contract history" sub={`${contracts.length} contract record${contracts.length === 1 ? '' : 's'}`}>
          {contracts.length ? (
            <TableWrap>
              <thead><tr><th>Start</th><th>End</th><th>Job title</th><th className="num">Salary</th><th>Current</th></tr></thead>
              <tbody>
                {contracts.map((c) => (
                  <tr key={c.id}>
                    <td>{c.start_date}</td>
                    <td>{c.end_date || '—'}</td>
                    <td>{c.job_title || '—'}</td>
                    <td className="num"><Money cents={c.salary_cents} /></td>
                    <td>{c.is_current ? <Pill tone="ok">Current</Pill> : '—'}</td>
                  </tr>
                ))}
              </tbody>
            </TableWrap>
          ) : <EmptyState icon="📄" title="No contract recorded yet — opens automatically on approval" />}
        </CollapsibleCard>

        <div className="grid g2">
          <NextOfKinPanel employeeId={id} rows={nextOfKin} canManage={canManageSubEntities} />
          <BeneficiariesPanel employeeId={id} rows={beneficiaries} canManage={canManageSubEntities} />
        </div>
        <div className="grid g2">
          <DependantsPanel employeeId={id} rows={dependants} canManage={canManageSubEntities} />
          <EmergencyContactsPanel employeeId={id} rows={emergencyContacts} canManage={canManageSubEntities} />
        </div>
        <div className="grid g2">
          <ProfessionalBodiesPanel employeeId={id} rows={professionalBodies} canManage={canManageSubEntities} />
          <WorkHistoryPanel employeeId={id} rows={workHistory} canManage={canManageSubEntities} />
        </div>
        <BankAccountsPanel employeeId={id} rows={bankAccounts} canManage={canManageSubEntities} />

        <CollapsibleCard title="Document trail" sub="Who raised this, and when">
          <DefinitionList items={[
            ['Created by', emp.created_by || '—'],
            ['Created on', formatDateTime(emp.created_at)],
          ]} />
        </CollapsibleCard>

        <CollapsibleCard title="Approval details" sub={`${tasks.length} approval step${tasks.length === 1 ? '' : 's'} routed`}>
          {tasks.length ? (
            <TableWrap>
              <thead><tr><th>Sent by</th><th>Sent date</th><th>Approver</th><th>Approved on</th><th /></tr></thead>
              <tbody>
                {tasks.map((t) => (
                  <tr key={t.id}>
                    <td>{t.requested_by || '—'}</td>
                    <td>{formatDateTime(t.requested_at)}</td>
                    <td className="muted-cell">{t.decided_by || t.pending_with || '—'}</td>
                    <td>{t.decided_at ? formatDateTime(t.decided_at) : '—'}</td>
                    <td><Pill status={t.status} /></td>
                  </tr>
                ))}
              </tbody>
            </TableWrap>
          ) : <EmptyState icon="🕓" title="Not yet sent for approval" />}
        </CollapsibleCard>
      </Page>
    </>
  );
}
