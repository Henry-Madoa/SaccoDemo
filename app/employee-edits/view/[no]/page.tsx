import Link from 'next/link';
import { notFound } from 'next/navigation';
import { requireAction, currentCanAction } from '@/lib/session';
import {
  getEmployeeEditRequest, listEditNextOfKin, listEditBeneficiaries, listEditDependants,
  listEditEmergencyContacts, listEditProfessionalBodies, listEditWorkHistory, listEditBankAccounts,
} from '@/lib/employeeEdits';
import { listJobGrades } from '@/lib/hrSetup';
import { listCounties, listSubCounties, listDimensionValues } from '@/lib/pool';
import { getDimensionCaptions } from '@/lib/org';
import { findPendingRoutedTask, isEligibleApprover, listWorkflowTasksForDocument } from '@/lib/workflow';
import { formatDateTime } from '@/lib/format';
import { Page } from '@/components/layout/page';
import { DefinitionList, EmptyState, Pill, TableWrap, Toolbar, Spacer } from '@/components/ui/primitives';
import { CollapsibleCard } from '@/components/ui/collapsible-card';
import { DocumentActionsMenu } from '@/components/ui/document-actions';
import {
  SubmitEditButton, CancelEditApprovalButton, ApproveEditButton, RejectEditButton,
  DelegateEditButton, ApplyEditButton, type EditLookups,
} from '../../edit-actions';
import { EditBioDataCard, EditEmploymentBankingCard } from '../../edit-info-cards';
import {
  EditNextOfKinPanel, EditBeneficiariesPanel, EditDependantsPanel, EditEmergencyContactsPanel,
  EditProfessionalBodiesPanel, EditWorkHistoryPanel, EditBankAccountsPanel,
} from '../../edit-sub-entity-panels';

export default async function EmployeeEditDetailPage({ params, searchParams }: {
  params: Promise<{ no: string }>;
  searchParams: Promise<{ edit?: string }>;
}) {
  const user = await requireAction('EMPLOYEE_EDITS_READ');
  const { no } = await params;
  const { edit } = await searchParams;
  const startEditing = edit === '1';

  const req = await getEmployeeEditRequest(no);
  if (!req) notFound();

  const [
    canUpdate, canApprove, tasks, gd1Values, gd2Values, { caption1, caption2 }, jobGrades, counties, subCounties,
    nextOfKin, beneficiaries, dependants, emergencyContacts, professionalBodies, workHistory, bankAccounts,
  ] = await Promise.all([
    currentCanAction('EMPLOYEE_EDITS_UPDATE'),
    currentCanAction('EMPLOYEE_EDITS_APPROVE'),
    listWorkflowTasksForDocument('EMPLOYEE_EDIT', no),
    listDimensionValues(1), listDimensionValues(2), getDimensionCaptions(),
    listJobGrades(), listCounties(), listSubCounties(),
    listEditNextOfKin(no), listEditBeneficiaries(no), listEditDependants(no), listEditEmergencyContacts(no),
    listEditProfessionalBodies(no), listEditWorkHistory(no), listEditBankAccounts(no),
  ]);
  const lookups: EditLookups = {
    globalDimension1Values: gd1Values, globalDimension2Values: gd2Values, caption1, caption2,
    jobGrades, counties, subCounties,
  };

  const isOwn = req.created_by === user.username;
  const isOpen = req.status === 'Open';
  const canManage = isOpen && canUpdate && isOwn;

  const routedTask = req.status === 'Pending Approval' ? await findPendingRoutedTask('EMPLOYEE_EDIT', no) : null;
  const canDecideThis = routedTask ? await isEligibleApprover(routedTask, user.id) : canApprove;
  const requestedBy = routedTask?.requested_by ?? req.created_by;
  const canCancelThis = canUpdate && requestedBy === user.username;
  const pendingWith = tasks.find((t) => t.status === 'PENDING')?.pending_with;

  return (
    <Page
      title={`${req.no} — ${req.employee_first_name} ${req.employee_last_name}`}
      crumb={`${req.status}${pendingWith ? ` · pending with ${pendingWith}` : ''}`}
      user={user}
    >
      <Toolbar>
        <Link href="/employee-edits" className="btn ghost sm">← All edit requests</Link>
        <Link href={`/employees/view/${req.employee_id}`} className="btn ghost sm">View employee</Link>
        <Spacer />
        {isOpen && canUpdate && isOwn ? <SubmitEditButton no={req.no} className="btn ghost" /> : null}
        {req.status === 'Pending Approval' && canCancelThis ? <CancelEditApprovalButton no={req.no} className="btn ghost" /> : null}
        {req.status === 'Pending Approval' && canDecideThis ? (
          <>
            {routedTask ? <DelegateEditButton taskId={routedTask.id} className="btn ghost" /> : null}
            <ApproveEditButton no={req.no} />
            <RejectEditButton no={req.no} className="btn ghost" />
          </>
        ) : null}
        {req.status === 'Approved' && canApprove ? <ApplyEditButton no={req.no} /> : null}
        <DocumentActionsMenu />
      </Toolbar>

      <CollapsibleCard title="Status">
        <DefinitionList items={[
          ['Status', <Pill status={req.status} key="st" />],
          req.decision_reason ? ['Decision reason', req.decision_reason] : null,
        ]} />
      </CollapsibleCard>

      <EditBioDataCard request={req} lookups={lookups} canEdit={canManage} startEditing={startEditing} />
      <EditEmploymentBankingCard request={req} lookups={lookups} canEdit={canManage} />

      <div className="grid g2">
        <EditNextOfKinPanel editNo={no} rows={nextOfKin} canManage={canManage} />
        <EditBeneficiariesPanel editNo={no} rows={beneficiaries} canManage={canManage} />
      </div>
      <div className="grid g2">
        <EditDependantsPanel editNo={no} rows={dependants} canManage={canManage} />
        <EditEmergencyContactsPanel editNo={no} rows={emergencyContacts} canManage={canManage} />
      </div>
      <div className="grid g2">
        <EditProfessionalBodiesPanel editNo={no} rows={professionalBodies} canManage={canManage} />
        <EditWorkHistoryPanel editNo={no} rows={workHistory} canManage={canManage} />
      </div>
      <EditBankAccountsPanel editNo={no} rows={bankAccounts} canManage={canManage} />

      <CollapsibleCard title="Document trail">
        <DefinitionList items={[
          ['Created by', req.created_by || '—'],
          ['Created on', formatDateTime(req.created_at)],
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
  );
}
