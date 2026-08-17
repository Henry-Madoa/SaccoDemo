import Link from 'next/link';
import { notFound } from 'next/navigation';
import { requireAction, currentCanAction } from '@/lib/session';
import {
  getCollateralApplication, getAdjacentCollateralApplicationNos, type CollateralApplicationView,
} from '@/lib/collateralApplications';
import { listCollateralAttachments } from '@/lib/collateralAttachments';
import { listActiveCounties } from '@/lib/pool';
import { findPendingRoutedTask, isEligibleApprover, listWorkflowTasksForDocument } from '@/lib/workflow';
import { formatDate, formatDateTime } from '@/lib/format';
import { isConfigured } from '@/lib/cloudinary';
import { Page } from '@/components/layout/page';
import {
  Card, CardHead, DefinitionList, EmptyState, Pill, Stat, TableWrap, Toolbar, Spacer,
} from '@/components/ui/primitives';
import { Money } from '@/components/ui/money';
import {
  EditButton, SubmitButton, CancelApprovalButton, DeleteButton, ApproveButton, RejectButton, DelegateButton,
  PostButton,
} from '../../collateral-application-actions';
import { CollateralAttachmentPanel } from './attachment-panel';
import { CardNav } from '@/components/ui/card-nav';
import { DocumentActionsMenu } from '@/components/ui/document-actions';

const VIEWS: CollateralApplicationView[] = ['open', 'pending', 'approved', 'processed'];

export default async function CollateralApplicationDetailPage({ params, searchParams }: {
  params: Promise<{ no: string }>;
  searchParams: Promise<{ view?: string }>;
}) {
  const user = await requireAction('COLLATERAL_APPLICATIONS_READ');
  const { no } = await params;
  const { view: viewRaw } = await searchParams;
  const view = VIEWS.includes(viewRaw as CollateralApplicationView) ? (viewRaw as CollateralApplicationView) : undefined;
  const application = await getCollateralApplication(no);
  if (!application) notFound();

  const [canCreate, canApprove, attachments, counties, tasks, { prevNo, nextNo }] = await Promise.all([
    currentCanAction('COLLATERAL_APPLICATIONS_CREATE'), currentCanAction('COLLATERAL_APPLICATIONS_APPROVE'),
    listCollateralAttachments(no), listActiveCounties(),
    listWorkflowTasksForDocument('COLLATERAL_APPLICATION', no),
    getAdjacentCollateralApplicationNos(no, view),
  ]);

  const isOpen = application.status === 'Open';
  const isOwnRequest = application.created_by === user.username;
  const canEditThis = canCreate && (!canApprove || isOwnRequest);

  const routedTask = application.status === 'Pending Approval'
    ? await findPendingRoutedTask('COLLATERAL_APPLICATION', no)
    : null;
  const canDecideThis = routedTask ? await isEligibleApprover(routedTask, user.id) : canApprove;
  const requestedBy = routedTask?.requested_by ?? application.created_by;
  const canCancelThis = canCreate && requestedBy === user.username;
  const registered = application.status === 'Processed';
  const pendingWith = tasks.find((t) => t.status === 'PENDING')?.pending_with;

  return (
    <>
      <CardNav
        prevHref={prevNo ? `/collateral-applications/view/${prevNo}${view ? `?view=${view}` : ''}` : null}
        nextHref={nextNo ? `/collateral-applications/view/${nextNo}${view ? `?view=${view}` : ''}` : null}
      />
      <Page
        title={`${application.collateral_type_code || application.category} — ${application.member_first_name} ${application.member_last_name}`}
        crumb={`${application.no} · ${application.status} · ${application.member_no}${pendingWith ? ` · pending with ${pendingWith}` : ''}`}
        user={user}
      >
      <Toolbar>
        <Link href="/collateral-applications" className="btn ghost sm">← All collateral applications</Link>
        <Link href={`/members/${application.member_id}`} className="btn ghost sm">View member</Link>
        <Spacer />
        {isOpen && canEditThis ? <EditButton application={application} counties={counties} className="btn ghost" /> : null}
        {isOpen && canEditThis ? <SubmitButton no={application.no} className="btn ghost" /> : null}
        {isOpen && canEditThis ? <DeleteButton no={application.no} className="btn ghost" /> : null}
        {application.status === 'Pending Approval' && canCancelThis ? (
          <CancelApprovalButton no={application.no} className="btn ghost" />
        ) : null}
        {application.status === 'Pending Approval' && canDecideThis ? (
          <>
            {routedTask ? <DelegateButton taskId={routedTask.id} className="btn ghost" /> : null}
            <ApproveButton no={application.no} />
            <RejectButton no={application.no} className="btn ghost" />
          </>
        ) : null}
        {application.status === 'Approved' && canApprove ? <PostButton no={application.no} /> : null}
        <DocumentActionsMenu />
      </Toolbar>

      <div className="grid g4 stack-2">
        <Stat label="Collateral value" value={<Money cents={application.collateral_value} decimals={0} />} />
        <Stat label="LTV multiplier" value={`${application.multiplier}%`} />
        <Stat label="Guarantee (LTV)" value={<Money cents={application.guarantee} decimals={0} />} />
        <Stat label="Status" value={<Pill status={application.status} />} />
      </div>

      <div className="grid split-side-sm">
        <div>
          <Card>
            <CardHead title="Collateral details" />
            <DefinitionList items={[
              ['Application no.', <span className="mono" key="no">{application.no}</span>],
              ['Member', <>{application.member_first_name} {application.member_last_name} <span className="mono">({application.member_no})</span></>],
              ['Category', application.category === 'VEHICLE' ? 'Vehicle' : 'Real Estate'],
              ['Collateral type', application.collateral_type_code || '—'],
              ['Description', application.collateral_description || '—'],
              ['Serial / Reg. no.', <span className="mono" key="serial">{application.serial_reg_no || '—'}</span>],
              ['Multi-linking', application.multi_linking ? <Pill tone="info" key="ml">YES</Pill> : '—'],
              ['County', application.county_name || '—'],
              ['Last valuation date', application.last_valuation_date ? formatDate(application.last_valuation_date) : '—'],
              ['Cheque no.', application.cheque_no || '—'],
            ]} />
          </Card>

          <Card>
            <CardHead title="Owner details" />
            <DefinitionList items={[
              ['Owner name', application.owner_name || '—'],
              ['Owner ID no.', application.owner_id_no || '—'],
              ['Owner phone no.', application.owner_phone_no || '—'],
              ['Joint ownership', application.joint_ownership ? <Pill tone="info" key="jo">YES</Pill> : '—'],
            ]} />
          </Card>

          {application.category === 'VEHICLE' ? (
            <Card>
              <CardHead title="Vehicle details" />
              <DefinitionList items={[
                ['Insurance expiry date', application.insurance_expiry_date ? formatDate(application.insurance_expiry_date) : '—'],
                ['Car track subscription due', application.car_track_due_date ? formatDate(application.car_track_due_date) : '—'],
              ]} />
            </Card>
          ) : null}

          <Card>
            <CardHead title="Document trail" sub="Who requested and registered this application, and when" />
            <DefinitionList items={[
              ['Created by', application.created_by || '—'],
              ['Created on', formatDateTime(application.created_at)],
              ['Registered', registered
                ? <Pill tone="ok" key="reg">YES — in the Collateral Register</Pill>
                : <Pill tone="warn" key="reg">NOT YET</Pill>],
              registered ? ['Registered by', application.processed_by || '—'] : null,
              registered ? ['Registered on', formatDateTime(application.processed_at)] : null,
              registered ? ['View register entry', <Link href={`/collateral-register/view/${application.no}`} key="link">{application.no}</Link>] : null,
              application.decision_reason ? ['Decision reason', application.decision_reason] : null,
            ]} />
          </Card>
        </div>

        <div>
          <Card>
            <CardHead
              title="Approval details"
              sub={`${tasks.length} approval step${tasks.length === 1 ? '' : 's'} routed`}
            />
            {tasks.length ? (
              <TableWrap>
                <thead>
                  <tr><th>Sent by</th><th>Sent date</th><th>Approver</th><th>Approved on</th><th /></tr>
                </thead>
                <tbody>
                  {tasks.flatMap((t) => [
                    ...t.level_decisions.map((ld, i) => (
                      <tr key={`${t.id}-level-${i}`} className="muted">
                        <td>—</td>
                        <td>—</td>
                        <td className="muted-cell">
                          Level {ld.sequence}: {ld.decided_by}
                          {ld.comment ? ` — "${ld.comment}"` : ''}
                        </td>
                        <td>{formatDateTime(ld.decided_at)}</td>
                        <td><Pill tone="ok">CLEARED</Pill></td>
                      </tr>
                    )),
                    <tr key={t.id}>
                      <td>{t.requested_by || '—'}</td>
                      <td>{formatDateTime(t.requested_at)}</td>
                      <td className="muted-cell">{t.decided_by || t.pending_with || '—'}</td>
                      <td>{t.decided_at ? formatDateTime(t.decided_at) : '—'}</td>
                      <td><Pill status={t.status} /></td>
                    </tr>,
                  ])}
                </tbody>
              </TableWrap>
            ) : <EmptyState icon="🕓" title="Not yet sent for approval" />}
          </Card>

          <CollateralAttachmentPanel
            applicationNo={application.no}
            attachments={attachments}
            canManage={isOpen && canEditThis}
            mediaEnabled={isConfigured()}
          />
        </div>
      </div>
      </Page>
    </>
  );
}
