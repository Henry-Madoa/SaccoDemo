import Link from 'next/link';
import { notFound } from 'next/navigation';
import { requireAction, currentCanAction } from '@/lib/session';
import {
  getMemberActivationRequest, getAdjacentMemberActivationNos, getMemberActivationJournal,
  type MemberActivationView,
} from '@/lib/memberActivation';
import { findPendingRoutedTask, isEligibleApprover, listWorkflowTasksForDocument } from '@/lib/workflow';
import { formatDateTime } from '@/lib/format';
import { Page } from '@/components/layout/page';
import {
  Card, CardHead, DefinitionList, EmptyState, Pill, TableWrap, Toolbar, Spacer,
} from '@/components/ui/primitives';
import { Money } from '@/components/ui/money';
import { DocumentActionsMenu } from '@/components/ui/document-actions';
import { CardNav } from '@/components/ui/card-nav';
import {
  EditButton, SubmitButton, CancelApprovalButton, ApproveButton, RejectButton, DelegateButton, ProcessButton,
} from '../../member-activation-actions';

const MEMBER_ACTIVATION_VIEWS: MemberActivationView[] = ['open', 'pending', 'approved', 'processed'];

export default async function MemberActivationDetailPage({ params, searchParams }: {
  params: Promise<{ no: string }>;
  searchParams: Promise<{ view?: string }>;
}) {
  const user = await requireAction('MEMBER_ACTIVATIONS_READ');
  const { no } = await params;
  const { view: viewRaw } = await searchParams;
  const view = MEMBER_ACTIVATION_VIEWS.includes(viewRaw as MemberActivationView) ? (viewRaw as MemberActivationView) : undefined;
  const request = await getMemberActivationRequest(no);
  if (!request) notFound();

  const [canCreate, canApprove, tasks, { prevNo, nextNo }, journal] = await Promise.all([
    currentCanAction('MEMBER_ACTIVATIONS_CREATE'), currentCanAction('MEMBER_ACTIVATIONS_APPROVE'),
    listWorkflowTasksForDocument('MEMBER_ACTIVATION', no),
    getAdjacentMemberActivationNos(no, view),
    request.status === 'Processed' ? getMemberActivationJournal(no) : Promise.resolve(null),
  ]);

  const isOpen = request.status === 'Open';
  const isOwnRequest = request.created_by === user.username;
  const canEditThis = canCreate && (!canApprove || isOwnRequest);

  const routedTask = request.status === 'Pending Approval'
    ? await findPendingRoutedTask('MEMBER_ACTIVATION', no)
    : null;
  const canDecideThis = routedTask ? await isEligibleApprover(routedTask, user.id) : canApprove;
  const requestedBy = routedTask?.requested_by ?? request.created_by;
  const canCancelThis = canCreate && requestedBy === user.username;
  const processed = request.status === 'Processed';
  const pendingWith = tasks.find((t) => t.status === 'PENDING')?.pending_with;

  const canEditFields = isOpen && canEditThis;
  const availableOnDebit = request.debit_account_id != null
    ? Math.max(
      (request.debit_account_balance ?? 0) - (request.debit_account_hold_amount ?? 0) - (request.debit_account_min_balance ?? 0),
      0,
    )
    : null;

  return (
    <>
      <CardNav
        prevHref={prevNo ? `/member-activations/view/${prevNo}${view ? `?view=${view}` : ''}` : null}
        nextHref={nextNo ? `/member-activations/view/${nextNo}${view ? `?view=${view}` : ''}` : null}
      />
      <Page
        title={`${request.member_first_name} ${request.member_last_name} — ${request.member_no}`}
        crumb={`${request.no} · ${request.status} · ${request.member_no}${pendingWith ? ` · pending with ${pendingWith}` : ''}`}
        user={user}
      >
      <Toolbar>
        <Link href="/member-activations" className="btn ghost sm">← All activation requests</Link>
        <Link href={`/members/${request.member_id}`} className="btn ghost sm">View member</Link>
        <Spacer />
        {canEditFields ? <EditButton request={request} className="btn ghost" /> : null}
        {canEditFields ? <SubmitButton no={request.no} className="btn ghost" /> : null}
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
        {request.status === 'Approved' && canApprove ? (
          <ProcessButton no={request.no} feeAmount={request.charge_amount} />
        ) : null}
        <DocumentActionsMenu />
      </Toolbar>

      <Card>
        <CardHead title="Request details" sub="Status" />
        <DefinitionList items={[
          ['Request no.', <span className="mono" key="no">{request.no}</span>],
          ['Member', <>{request.member_first_name} {request.member_last_name} <span className="mono">({request.member_no})</span></>],
          ['Member status', <Pill status={request.member_status} key="member-status" />],
          ['Reason', request.reason || '—'],
          request.transaction_charge_id ? ['Reactivation charge', `${request.transaction_charge_code} — ${request.transaction_charge_description}`] : null,
          request.transaction_charge_id ? ['Charge amount', <Money cents={request.charge_amount ?? 0} key="charge-amount" />] : null,
          request.transaction_charge_id ? ['Pay from', request.pay_from_account_type === 'CASH' ? 'Cash at the till' : "Member's own account"] : null,
          request.pay_from_account_type === 'CASH' && request.payment_reference ? ['Payment reference', request.payment_reference] : null,
          request.debit_account_id ? [
            'Debit account',
            <>
              <span className="mono">{request.debit_account_no}</span>
              {' — available '}
              <Money cents={availableOnDebit ?? 0} />
            </>,
          ] : null,
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
            ? <Pill tone="ok" key="processed">YES — member reactivated</Pill>
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

      {processed ? (
        <Card>
          <CardHead
            title="Related ledger entries"
            sub={journal ? `Journal ${journal.journal.journal_no}` : 'Navigate'}
          />
          {journal ? (
            <TableWrap>
              <thead>
                <tr><th>Account</th><th>Narration</th><th className="num">Debit</th><th className="num">Credit</th></tr>
              </thead>
              <tbody>
                {journal.lines.map((l) => (
                  <tr key={l.id}>
                    <td><span className="mono">{l.code}</span> — {l.name}</td>
                    <td>{l.narration || '—'}</td>
                    <td className="num">{l.debit ? <Money cents={l.debit} /> : '—'}</td>
                    <td className="num">{l.credit ? <Money cents={l.credit} /> : '—'}</td>
                  </tr>
                ))}
              </tbody>
            </TableWrap>
          ) : <EmptyState icon="⚖" title="No reactivation charge was posted" sub="Activation was free — no charge was configured for this request" />}
        </Card>
      ) : null}
      </Page>
    </>
  );
}
