import Link from 'next/link';
import { notFound } from 'next/navigation';
import { requireAction, currentCanAction } from '@/lib/session';
import {
  getLien, getAdjacentLienNos, listAccountLienHistory, type LienView,
} from '@/lib/liens';
import { listActiveMembers } from '@/lib/members';
import { findPendingRoutedTask, isEligibleApprover, listWorkflowTasksForDocument } from '@/lib/workflow';
import { formatDateTime } from '@/lib/format';
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
  ReopenButton, ProcessButton, DeleteButton,
} from '../../lien-actions';

const VIEWS: LienView[] = ['open', 'pending', 'approved', 'processed'];

export default async function LienDetailPage({ params, searchParams }: {
  params: Promise<{ no: string }>;
  searchParams: Promise<{ view?: string }>;
}) {
  const user = await requireAction('LIENS_READ');
  const { no } = await params;
  const { view: viewRaw } = await searchParams;
  const view = VIEWS.includes(viewRaw as LienView) ? (viewRaw as LienView) : undefined;

  const lien = await getLien(no);
  if (!lien) notFound();
  const isHold = lien.transaction_type === 'HOLD';

  const [canCreate, canApprove, canProcess, tasks, { prevNo, nextNo }, accountHistory] = await Promise.all([
    currentCanAction('LIENS_CREATE'),
    currentCanAction('LIENS_APPROVE'),
    currentCanAction('LIENS_POST'),
    listWorkflowTasksForDocument('MEMBER_LIEN', no),
    getAdjacentLienNos(no, view),
    listAccountLienHistory(lien.savings_account_id),
  ]);

  const isOwn = lien.created_by === user.username;
  const isOpen = lien.status === 'Open';
  const editMembers = isOpen && canCreate && isOwn ? await listActiveMembers() : [];

  const routedTask = lien.status === 'Pending Approval' ? await findPendingRoutedTask('MEMBER_LIEN', no) : null;
  const canDecideThis = routedTask ? await isEligibleApprover(routedTask, user.id) : canApprove;
  const requestedBy = routedTask?.requested_by ?? lien.created_by;
  const canCancelThis = canCreate && requestedBy === user.username;
  const pendingWith = tasks.find((t) => t.status === 'PENDING')?.pending_with;
  const q = view ? `?view=${view}` : '';

  return (
    <>
      <CardNav
        prevHref={prevNo ? `/liens/view/${prevNo}${q}` : null}
        nextHref={nextNo ? `/liens/view/${nextNo}${q}` : null}
      />
      <Page
        title={`${lien.no} — ${isHold ? 'Hold' : 'Release'}`}
        crumb={`${lien.status} · ${lien.member_first_name} ${lien.member_last_name} (${lien.member_no})${pendingWith ? ` · pending with ${pendingWith}` : ''}`}
        user={user}
      >
        <Toolbar>
          <Link href="/liens" className="btn ghost sm">← All liens</Link>
          <Link href={`/members/${lien.member_id}`} className="btn ghost sm">View member</Link>
          <Spacer />
          {isOpen && canCreate && isOwn ? <EditButton lien={lien} members={editMembers} className="btn ghost" /> : null}
          {isOpen && canCreate && isOwn ? <DeleteButton no={lien.no} className="btn ghost" /> : null}
          {isOpen && canCreate && isOwn ? <SubmitButton no={lien.no} className="btn ghost" /> : null}
          {lien.status === 'Pending Approval' && canCancelThis ? <CancelApprovalButton no={lien.no} className="btn ghost" /> : null}
          {lien.status === 'Pending Approval' && canDecideThis ? (
            <>
              {routedTask ? <DelegateButton taskId={routedTask.id} className="btn ghost" /> : null}
              <ApproveButton no={lien.no} />
              <RejectButton no={lien.no} className="btn ghost" />
            </>
          ) : null}
          {lien.status === 'Approved' && !lien.processed && canApprove ? <ReopenButton no={lien.no} className="btn ghost" /> : null}
          {lien.status === 'Approved' && canProcess ? <ProcessButton no={lien.no} type={lien.transaction_type} /> : null}
          <DocumentActionsMenu />
        </Toolbar>

        <CollapsibleCard title="Lien details" sub={isHold ? 'Freezes part of the deposit balance' : 'Lifts a previous hold'}>
          <div className="grid g2">
            <DefinitionList items={[
              ['Lien no.', <span className="mono" key="no">{lien.no}</span>],
              ['Instruction', <Pill tone={isHold ? 'warn' : 'ok'} key="t">{isHold ? 'Hold' : 'Release'}</Pill>],
              ['Member', <>{lien.member_first_name} {lien.member_last_name} <span className="mono">({lien.member_no})</span></>],
              ['Account', <><span className="mono">{lien.account_no}</span> — {lien.account_product_name}</>],
              ['Amount', <Money cents={lien.amount} key="a" />],
              ['Posting date', lien.posting_date],
              ['Narration', lien.narration || '—'],
            ]} />
            <DefinitionList items={[
              ['Account balance', <Money cents={lien.account_balance} key="b" />],
              ['Currently held', <Money cents={lien.account_hold_amount} key="h" />],
              ['Available', <Money cents={lien.account_available} key="av" />],
              ['Status', <Pill status={lien.status} key="st" />],
              lien.decision_reason ? ['Decision reason', lien.decision_reason] : null,
              lien.processed ? ['Processed', <Pill tone="ok" key="p">YES</Pill>] : null,
            ]} />
          </div>
        </CollapsibleCard>

        <CollapsibleCard title="Document trail" sub="Who raised this, and when">
          <DefinitionList items={[
            ['Created by', lien.created_by || '—'],
            ['Created on', formatDateTime(lien.created_at)],
            ['Processed by', lien.processed_by || '—'],
            ['Processed on', formatDateTime(lien.processed_at)],
          ]} />
        </CollapsibleCard>

        <CollapsibleCard title="Account hold history" sub={`${accountHistory.length} processed lien${accountHistory.length === 1 ? '' : 's'} on ${lien.account_no}`}>
          {accountHistory.length ? (
            <TableWrap>
              <thead><tr><th>No.</th><th>Type</th><th className="num">Amount</th><th>Narration</th><th>Processed</th></tr></thead>
              <tbody>
                {accountHistory.map((h) => (
                  <tr key={h.no}>
                    <td className="mono"><Link href={`/liens/view/${h.no}`}>{h.no}</Link></td>
                    <td>{h.transaction_type === 'HOLD' ? 'Hold' : 'Release'}</td>
                    <td className="num"><Money cents={h.amount} /></td>
                    <td>{h.narration || '—'}</td>
                    <td>{formatDateTime(h.processed_at)}</td>
                  </tr>
                ))}
              </tbody>
            </TableWrap>
          ) : <EmptyState icon="🕓" title="No holds have been processed on this account yet" />}
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
