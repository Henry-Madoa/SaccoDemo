import Link from 'next/link';
import { notFound } from 'next/navigation';
import { requireAction, currentCanAction } from '@/lib/session';
import {
  getAccountActivationRequest, getAdjacentAccountActivationNos, type AccountActivationView,
} from '@/lib/accountActivation';
import { findPendingRoutedTask, isEligibleApprover, listWorkflowTasksForDocument } from '@/lib/workflow';
import { formatDateTime } from '@/lib/format';
import { Page } from '@/components/layout/page';
import {
  Card, CardHead, DefinitionList, EmptyState, Pill, TableWrap, Toolbar, Spacer,
} from '@/components/ui/primitives';
import { Money } from '@/components/ui/money';
import { CardNav } from '@/components/ui/card-nav';
import {
  SubmitButton, CancelApprovalButton, ApproveButton, RejectButton, DelegateButton, ProcessButton,
} from '../../account-activation-actions';

const ACCOUNT_ACTIVATION_VIEWS: AccountActivationView[] = ['open', 'pending', 'approved', 'processed'];

export default async function AccountActivationDetailPage({ params, searchParams }: {
  params: Promise<{ no: string }>;
  searchParams: Promise<{ view?: string }>;
}) {
  const user = await requireAction('ACCOUNT_ACTIVATION_READ');
  const { no } = await params;
  const { view: viewRaw } = await searchParams;
  const view = ACCOUNT_ACTIVATION_VIEWS.includes(viewRaw as AccountActivationView) ? (viewRaw as AccountActivationView) : undefined;
  const request = await getAccountActivationRequest(no);
  if (!request) notFound();

  const [canCreate, canApprove, tasks, { prevNo, nextNo }] = await Promise.all([
    currentCanAction('ACCOUNT_ACTIVATION_CREATE'), currentCanAction('ACCOUNT_ACTIVATION_APPROVE'),
    listWorkflowTasksForDocument('ACCOUNT_ACTIVATION', no),
    getAdjacentAccountActivationNos(no, view),
  ]);

  const isOpen = request.status === 'Open';
  const isOwnRequest = request.created_by === user.username;
  const canEditThis = canCreate && (!canApprove || isOwnRequest);

  // Same shape as Account Deactivation: the routed task's current approver (or their substitute/
  // delegate) decides it; no matching workflow falls back to the coarse
  // ACCOUNT_ACTIVATION_APPROVE permission. Cancelling is only for whoever sent it for approval.
  const routedTask = request.status === 'Pending Approval'
    ? await findPendingRoutedTask('ACCOUNT_ACTIVATION', no)
    : null;
  const canDecideThis = routedTask ? await isEligibleApprover(routedTask, user.id) : canApprove;
  const requestedBy = routedTask?.requested_by ?? request.created_by;
  const canCancelThis = canCreate && requestedBy === user.username;
  const processed = request.status === 'Processed';
  const pendingWith = tasks.find((t) => t.status === 'PENDING')?.pending_with;

  return (
    <>
      <CardNav
        prevHref={prevNo ? `/account-activations/view/${prevNo}${view ? `?view=${view}` : ''}` : null}
        nextHref={nextNo ? `/account-activations/view/${nextNo}${view ? `?view=${view}` : ''}` : null}
      />
      <Page
        title={`${request.account_no} — ${request.member_first_name} ${request.member_last_name}`}
        crumb={`${request.no} · ${request.status} · ${request.member_no}${pendingWith ? ` · pending with ${pendingWith}` : ''}`}
        user={user}
      >
      <Toolbar>
        <Link href="/account-activations" className="btn ghost sm">← All activation requests</Link>
        <Link href={`/savings/${request.account_id}`} className="btn ghost sm">View account</Link>
        <Link href={`/members/${request.member_id}`} className="btn ghost sm">View member</Link>
        <Spacer />
        {isOpen && canEditThis ? <SubmitButton no={request.no} className="btn ghost" /> : null}
        {request.status === 'Pending Approval' && canCancelThis ? (
          <CancelApprovalButton no={request.no} className="btn ghost" />
        ) : null}
        {request.status === 'Pending Approval' && canDecideThis ? (
          <>
            {routedTask ? <DelegateButton taskId={routedTask.id} className="btn ghost" /> : null}
            <ApproveButton no={request.no} />
            <RejectButton no={request.no} className="btn ghost" />
          </>
        ) : null}
        {request.status === 'Approved' && canApprove ? <ProcessButton no={request.no} /> : null}
      </Toolbar>

      <Card>
        <CardHead title="Request details" sub="Status" />
        <DefinitionList items={[
          ['Request no.', <span className="mono" key="no">{request.no}</span>],
          ['Member', <>{request.member_first_name} {request.member_last_name} <span className="mono">({request.member_no})</span></>],
          ['Account', <><span className="mono">{request.account_no}</span> — {request.savings_product_name}</>],
          ['Account status', <Pill status={request.account_status} key="acct-status" />],
          ['Account balance', <Money cents={request.account_balance} key="acct-balance" />],
          ['Reason', request.reason || '—'],
          ['Status', <Pill status={request.status} key="status" />],
          request.decision_reason ? ['Decision reason', request.decision_reason] : null,
        ]} />
      </Card>

      <Card>
        <CardHead title="Document trail" sub="Who requested and processed this request, and when" />
        <DefinitionList items={[
          ['Created by', request.created_by || '—'],
          ['Created on', formatDateTime(request.created_at)],
          ['Processed', processed
            ? <Pill tone="ok" key="processed">YES — account reactivated</Pill>
            : <Pill tone="warn" key="processed">NOT YET</Pill>],
          processed ? ['Processed by', request.processed_by || '—'] : null,
          processed ? ['Processed on', formatDateTime(request.processed_at)] : null,
        ]} />
      </Card>

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
      </Page>
    </>
  );
}
