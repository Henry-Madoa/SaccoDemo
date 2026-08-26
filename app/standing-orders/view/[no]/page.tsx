import Link from 'next/link';
import { notFound } from 'next/navigation';
import { requireAction, currentCanAction } from '@/lib/session';
import {
  getStandingOrder, getAdjacentStandingOrderNos, listStandingOrderHistory, type StandingOrderView,
} from '@/lib/standingOrders';
import { findPendingRoutedTask, isEligibleApprover, listWorkflowTasksForDocument } from '@/lib/workflow';
import { listActiveMembers } from '@/lib/members';
import { formatDateTime } from '@/lib/format';
import { STANDING_ORDER_CLASSES, STANDING_ORDER_AMOUNT_TYPES, STANDING_ORDER_RUN_TYPES } from '@/lib/constants';
import { Page } from '@/components/layout/page';
import {
  DefinitionList, EmptyState, Pill, TableWrap, Toolbar, Spacer,
} from '@/components/ui/primitives';
import { CollapsibleCard } from '@/components/ui/collapsible-card';
import { Money } from '@/components/ui/money';
import { DocumentActionsMenu } from '@/components/ui/document-actions';
import { CardNav } from '@/components/ui/card-nav';
import {
  EditButton, SubmitButton, CancelApprovalButton, ApproveButton, RejectButton, DelegateButton,
  TerminateButton, FreezeButton, UnfreezeButton,
} from '../../standing-order-actions';

const STANDING_ORDER_VIEWS: StandingOrderView[] = ['open', 'pending', 'live', 'terminated'];

const label = (list: { value: string; label: string }[], value: string) => list.find((x) => x.value === value)?.label ?? value;

export default async function StandingOrderDetailPage({ params, searchParams }: {
  params: Promise<{ no: string }>;
  searchParams: Promise<{ view?: string }>;
}) {
  const user = await requireAction('STANDING_ORDERS_READ');
  const { no } = await params;
  const { view: viewRaw } = await searchParams;
  const view = STANDING_ORDER_VIEWS.includes(viewRaw as StandingOrderView) ? (viewRaw as StandingOrderView) : undefined;
  const order = await getStandingOrder(no);
  if (!order) notFound();

  const [canCreate, canApprove, tasks, { prevNo, nextNo }, history] = await Promise.all([
    currentCanAction('STANDING_ORDERS_CREATE'), currentCanAction('STANDING_ORDERS_APPROVE'),
    listWorkflowTasksForDocument('STANDING_ORDER', no),
    getAdjacentStandingOrderNos(no, view),
    order.status === 'Approved' ? listStandingOrderHistory(no) : Promise.resolve([]),
  ]);

  const isOpen = order.status === 'Open';
  const isOwnRequest = order.created_by === user.username;
  const canEditThis = canCreate && (!canApprove || isOwnRequest);

  const routedTask = order.status === 'Pending Approval'
    ? await findPendingRoutedTask('STANDING_ORDER', no)
    : null;
  const canDecideThis = routedTask ? await isEligibleApprover(routedTask, user.id) : canApprove;
  const requestedBy = routedTask?.requested_by ?? order.created_by;
  const canCancelThis = canCreate && requestedBy === user.username;
  const live = order.status === 'Approved' && order.running && !order.terminated;
  const pendingWith = tasks.find((t) => t.status === 'PENDING')?.pending_with;

  const canEditFields = isOpen && canEditThis;
  const editMembers = canEditFields ? await listActiveMembers() : [];

  return (
    <>
      <CardNav
        prevHref={prevNo ? `/standing-orders/view/${prevNo}${view ? `?view=${view}` : ''}` : null}
        nextHref={nextNo ? `/standing-orders/view/${nextNo}${view ? `?view=${view}` : ''}` : null}
      />
      <Page
        title={`${order.no} — ${order.member_first_name} ${order.member_last_name}`}
        crumb={`${order.status}${order.terminated ? ' · Terminated' : order.freezed ? ' · Frozen' : ''} · ${order.member_no}${pendingWith ? ` · pending with ${pendingWith}` : ''}`}
        user={user}
      >
      <Toolbar>
        <Link href="/standing-orders" className="btn ghost sm">← All standing orders</Link>
        <Link href={`/members/${order.member_id}`} className="btn ghost sm">View member</Link>
        <Spacer />
        {canEditFields ? <EditButton order={order} members={editMembers} className="btn ghost" /> : null}
        {canEditFields ? <SubmitButton no={order.no} className="btn ghost" /> : null}
        {order.status === 'Pending Approval' && canCancelThis ? (
          <CancelApprovalButton no={order.no} className="btn ghost" />
        ) : null}
        {order.status === 'Pending Approval' && canDecideThis ? (
          <>
            {routedTask ? <DelegateButton taskId={routedTask.id} className="btn ghost" /> : null}
            <ApproveButton no={order.no} />
            <RejectButton no={order.no} className="btn ghost" />
          </>
        ) : null}
        {live && canApprove ? (
          <>
            {order.freezed ? <UnfreezeButton no={order.no} className="btn ghost" /> : <FreezeButton no={order.no} className="btn ghost" />}
            <TerminateButton no={order.no} className="btn danger" />
          </>
        ) : null}
        <DocumentActionsMenu />
      </Toolbar>

      <div className="grid g2">
        <CollapsibleCard title="Order details" sub="What this order does">
          <DefinitionList items={[
            ['Order no.', <span className="mono" key="no">{order.no}</span>],
            ['Member', <>{order.member_first_name} {order.member_last_name} <span className="mono">({order.member_no})</span></>],
            ['Source account', <><span className="mono">{order.account_no}</span> — available {' '}
              <Money cents={Math.max(order.account_balance - order.account_hold_amount - order.account_min_balance, 0)} /></>],
            ['Type', label(STANDING_ORDER_CLASSES, order.standing_order_class)],
            order.standing_order_class === 'INTERNAL'
              ? ['Destination', <>{order.destination_first_name} {order.destination_last_name} <span className="mono">({order.destination_member_no})</span> — {order.destination_account_no}</>]
              : order.standing_order_class === 'EXTERNAL'
                ? ['Pay through', <span className="mono" key="bank">{order.destination_bank_account_code} — {order.destination_bank_account_name}</span>]
                : ['Loan to repay', <span className="mono" key="loan">{order.destination_loan_no}</span>],
            ['Posting description', order.posting_description || '—'],
            ['Amount type', label(STANDING_ORDER_AMOUNT_TYPES, order.amount_type)],
            order.amount_type === 'FIXED' ? ['Amount', <Money cents={order.amount} key="amount" />] : null,
            order.amount_type === 'AMOUNT_BASED' ? ['Amount limit', <Money cents={order.amount_limit} key="limit" />] : null,
            order.amount_type === 'FIXED' ? ['Run', label(STANDING_ORDER_RUN_TYPES, order.run_type)] : null,
            order.amount_type === 'FIXED' && order.run_type === 'SPECIFIC_DAY' ? ['Day of month', String(order.run_from_day ?? '—')] : null,
            ['Start date', order.start_date],
            ['End date', order.till_further_notice ? 'Till further notice' : (order.end_date ?? '—')],
            order.transaction_charge_id ? ['Charge code', `${order.transaction_charge_code} — ${order.transaction_charge_description}`] : null,
            ['Last run', order.last_run_date ?? 'Never'],
            order.freezed ? ['Frozen until', order.freeze_end_date ?? '—'] : null,
            ['Status', <Pill status={order.status} key="status" />],
            order.decision_reason ? ['Decision reason', order.decision_reason] : null,
          ]} />
        </CollapsibleCard>

        <CollapsibleCard title="Document trail" sub="Who requested this order, and when">
          <DefinitionList items={[
            ['Created by', order.created_by || '—'],
            ['Created on', formatDateTime(order.created_at)],
            ['Live', live
              ? <Pill tone="ok" key="live">YES — running on its own schedule</Pill>
              : <Pill tone={order.terminated ? '' : 'warn'} key="live">{order.terminated ? 'TERMINATED' : 'NOT YET'}</Pill>],
          ]} />
        </CollapsibleCard>
      </div>

      {order.status === 'Approved' ? (
        <CollapsibleCard title="Run history" sub={`${history.length} posting${history.length === 1 ? '' : 's'} so far`}>
          {history.length ? (
            <TableWrap>
              <thead><tr><th>Date</th><th>Journal</th><th>Description</th><th className="num">Amount</th></tr></thead>
              <tbody>
                {history.map((h) => (
                  <tr key={h.journal_no}>
                    <td>{h.value_date}</td>
                    <td className="mono">{h.journal_no}</td>
                    <td>{h.description || '—'}</td>
                    <td className="num"><Money cents={h.amount} /></td>
                  </tr>
                ))}
              </tbody>
            </TableWrap>
          ) : <EmptyState icon="🕓" title="Nothing has posted yet" />}
        </CollapsibleCard>
      ) : null}

      <CollapsibleCard
        title="Approval details"
        sub={`${tasks.length} approval step${tasks.length === 1 ? '' : 's'} routed`}
      >
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
      </CollapsibleCard>
      </Page>
    </>
  );
}
