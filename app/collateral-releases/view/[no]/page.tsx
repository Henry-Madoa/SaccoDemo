import Link from 'next/link';
import { notFound } from 'next/navigation';
import { requireAction, currentCanAction } from '@/lib/session';
import {
  getCollateralRelease, getAdjacentCollateralReleaseNos, type CollateralReleaseView,
} from '@/lib/collateralReleases';
import { listCollateralRegister } from '@/lib/collateralRegister';
import { findPendingRoutedTask, isEligibleApprover, listWorkflowTasksForDocument } from '@/lib/workflow';
import { formatDate, formatDateTime } from '@/lib/format';
import { Page } from '@/components/layout/page';
import {
  Card, CardHead, DefinitionList, EmptyState, Pill, Stat, TableWrap, Toolbar, Spacer,
} from '@/components/ui/primitives';
import { Money } from '@/components/ui/money';
import {
  EditButton, SubmitButton, CancelApprovalButton, DeleteButton, ApproveButton, RejectButton, DelegateButton,
  PostButton,
} from '../../collateral-release-actions';
import { CardNav } from '@/components/ui/card-nav';
import { DocumentActionsMenu } from '@/components/ui/document-actions';

const VIEWS: CollateralReleaseView[] = ['open', 'pending', 'approved', 'processed'];

export default async function CollateralReleaseDetailPage({ params, searchParams }: {
  params: Promise<{ no: string }>;
  searchParams: Promise<{ view?: string }>;
}) {
  const user = await requireAction('COLLATERAL_RELEASES_READ');
  const { no } = await params;
  const { view: viewRaw } = await searchParams;
  const view = VIEWS.includes(viewRaw as CollateralReleaseView) ? (viewRaw as CollateralReleaseView) : undefined;
  const release = await getCollateralRelease(no);
  if (!release) notFound();

  const [canCreate, canApprove, tasks, { prevNo, nextNo }] = await Promise.all([
    currentCanAction('COLLATERAL_RELEASES_CREATE'), currentCanAction('COLLATERAL_RELEASES_APPROVE'),
    listWorkflowTasksForDocument('COLLATERAL_RELEASE', no),
    getAdjacentCollateralReleaseNos(no, view),
  ]);

  const isOpen = release.status === 'Open';
  const isOwnRequest = release.created_by === user.username;
  const canEditThis = canCreate && (!canApprove || isOwnRequest);

  const routedTask = release.status === 'Pending Approval'
    ? await findPendingRoutedTask('COLLATERAL_RELEASE', no)
    : null;
  const canDecideThis = routedTask ? await isEligibleApprover(routedTask, user.id) : canApprove;
  const requestedBy = routedTask?.requested_by ?? release.created_by;
  const canCancelThis = canCreate && requestedBy === user.username;
  const processed = release.status === 'Processed';
  const pendingWith = tasks.find((t) => t.status === 'PENDING')?.pending_with;

  const canEditFields = isOpen && canEditThis;
  const editCollateral = canEditFields
    ? (await listCollateralRegister()).filter((r) => r.status !== 'COLLECTED')
    : [];

  return (
    <>
      <CardNav
        prevHref={prevNo ? `/collateral-releases/view/${prevNo}${view ? `?view=${view}` : ''}` : null}
        nextHref={nextNo ? `/collateral-releases/view/${nextNo}${view ? `?view=${view}` : ''}` : null}
      />
      <Page
        title={`Release of ${release.collateral_no}`}
        crumb={`${release.no} · ${release.status} · ${release.member_no}${pendingWith ? ` · pending with ${pendingWith}` : ''}`}
        user={user}
      >
      <Toolbar>
        <Link href="/collateral-releases" className="btn ghost sm">← All collateral releases</Link>
        <Link href={`/collateral-register/view/${release.collateral_no}`} className="btn ghost sm">View collateral</Link>
        <Link href={`/members/${release.member_id}`} className="btn ghost sm">View member</Link>
        <Spacer />
        {canEditFields ? <EditButton release={release} collateral={editCollateral} className="btn ghost" /> : null}
        {canEditFields ? <SubmitButton no={release.no} className="btn ghost" /> : null}
        {canEditFields ? <DeleteButton no={release.no} className="btn ghost" /> : null}
        {release.status === 'Pending Approval' && canCancelThis ? (
          <CancelApprovalButton no={release.no} className="btn ghost" />
        ) : null}
        {release.status === 'Pending Approval' && canDecideThis ? (
          <>
            {routedTask ? <DelegateButton taskId={routedTask.id} className="btn ghost" /> : null}
            <ApproveButton no={release.no} />
            <RejectButton no={release.no} className="btn ghost" />
          </>
        ) : null}
        {release.status === 'Approved' && canApprove ? <PostButton no={release.no} /> : null}
        <DocumentActionsMenu />
      </Toolbar>

      <div className="grid g4 stack-2">
        <Stat label="Collateral" value={release.collateral_description || release.collateral_serial_reg_no || release.collateral_no} />
        <Stat label="Linked loan balance"
          value={<Money cents={release.linked_loan_balance} decimals={0} />}
          foot={release.linked_loan_balance > 0 ? 'Must reach zero before this can be released' : 'Clear to release'} />
        <Stat label="Status" value={<Pill status={release.status} />} />
        <Stat label="Nationality" value={release.nationality === 'DIASPORA' ? `Diaspora (${release.domicile_country || '—'})` : 'Local'} />
      </div>

      <div className="grid split-side-sm">
        <div>
          <Card>
            <CardHead title="Release details" />
            <DefinitionList items={[
              ['Release no.', <span className="mono" key="no">{release.no}</span>],
              ['Collateral', <Link href={`/collateral-register/view/${release.collateral_no}`} key="col">{release.collateral_no}</Link>],
              ['Member', <>{release.member_first_name} {release.member_last_name} <span className="mono">({release.member_no})</span></>],
              ['Collection date', release.collection_date ? formatDate(release.collection_date) : '—'],
              ['Collected by', release.collected_by || '—'],
              ["Collector's ID no.", release.collected_by_id_no || '—'],
              ['Comments', release.comments || '—'],
              ['Remarks', release.remarks || '—'],
              release.decision_reason ? ['Decision reason', release.decision_reason] : null,
            ]} />
          </Card>

          <Card>
            <CardHead title="Document trail" sub="Who requested and processed this release, and when" />
            <DefinitionList items={[
              ['Created by', release.created_by || '—'],
              ['Created on', formatDateTime(release.created_at)],
              ['Processed', processed
                ? <Pill tone="ok" key="processed">YES — collateral collected</Pill>
                : <Pill tone="warn" key="processed">NOT YET</Pill>],
              processed ? ['Processed by', release.processed_by || '—'] : null,
              processed ? ['Processed on', formatDateTime(release.processed_at)] : null,
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
        </div>
      </div>
      </Page>
    </>
  );
}
