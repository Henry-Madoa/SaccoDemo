import Link from 'next/link';
import { notFound } from 'next/navigation';
import { requireAction, currentCanAction } from '@/lib/session';
import {
  getInterAccountTransfer, getAdjacentTransferNos, listInterAccountTransferHistory, type TransferView,
} from '@/lib/interAccountTransfer';
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
  ReopenButton, PostButton, DeleteButton,
} from '../../transfer-actions';

const VIEWS: TransferView[] = ['open', 'pending', 'approved', 'processed'];

export default async function TransferDetailPage({ params, searchParams }: {
  params: Promise<{ no: string }>;
  searchParams: Promise<{ view?: string }>;
}) {
  const user = await requireAction('INTER_ACCOUNT_TRANSFERS_READ');
  const { no } = await params;
  const { view: viewRaw } = await searchParams;
  const view = VIEWS.includes(viewRaw as TransferView) ? (viewRaw as TransferView) : undefined;

  const transfer = await getInterAccountTransfer(no);
  if (!transfer) notFound();

  const [canCreate, canApprove, canPost, canCrossMember, tasks, { prevNo, nextNo }, history] = await Promise.all([
    currentCanAction('INTER_ACCOUNT_TRANSFERS_CREATE'),
    currentCanAction('INTER_ACCOUNT_TRANSFERS_APPROVE'),
    currentCanAction('INTER_ACCOUNT_TRANSFERS_POST'),
    currentCanAction('INTER_ACCOUNT_TRANSFERS_CROSS_MEMBER'),
    listWorkflowTasksForDocument('INTER_ACCOUNT_TRANSFER', no),
    getAdjacentTransferNos(no, view),
    listInterAccountTransferHistory(no),
  ]);

  const isOwn = transfer.created_by === user.username;
  const isOpen = transfer.status === 'Open';
  const editMembers = isOpen && canCreate && isOwn ? await listActiveMembers() : [];

  const routedTask = transfer.status === 'Pending Approval' ? await findPendingRoutedTask('INTER_ACCOUNT_TRANSFER', no) : null;
  const canDecideThis = routedTask ? await isEligibleApprover(routedTask, user.id) : canApprove;
  const requestedBy = routedTask?.requested_by ?? transfer.created_by;
  const canCancelThis = canCreate && requestedBy === user.username;
  const pendingWith = tasks.find((t) => t.status === 'PENDING')?.pending_with;
  const q = view ? `?view=${view}` : '';

  return (
    <>
      <CardNav
        prevHref={prevNo ? `/inter-account-transfers/view/${prevNo}${q}` : null}
        nextHref={nextNo ? `/inter-account-transfers/view/${nextNo}${q}` : null}
      />
      <Page
        title={`${transfer.no} — Transfer`}
        crumb={`${transfer.status} · ${transfer.source_first_name} ${transfer.source_last_name} → ${transfer.destination_first_name} ${transfer.destination_last_name}${pendingWith ? ` · pending with ${pendingWith}` : ''}`}
        user={user}
      >
        <Toolbar>
          <Link href="/inter-account-transfers" className="btn ghost sm">← All transfers</Link>
          <Link href={`/members/${transfer.source_member_id}`} className="btn ghost sm">Source member</Link>
          <Spacer />
          {isOpen && canCreate && isOwn ? <EditButton transfer={transfer} members={editMembers} canCrossMember={canCrossMember} className="btn ghost" /> : null}
          {isOpen && canCreate && isOwn ? <DeleteButton no={transfer.no} className="btn ghost" /> : null}
          {isOpen && canCreate && isOwn ? <SubmitButton no={transfer.no} className="btn ghost" /> : null}
          {transfer.status === 'Pending Approval' && canCancelThis ? <CancelApprovalButton no={transfer.no} className="btn ghost" /> : null}
          {transfer.status === 'Pending Approval' && canDecideThis ? (
            <>
              {routedTask ? <DelegateButton taskId={routedTask.id} className="btn ghost" /> : null}
              <ApproveButton no={transfer.no} />
              <RejectButton no={transfer.no} className="btn ghost" />
            </>
          ) : null}
          {transfer.status === 'Approved' && !transfer.posted && canApprove ? <ReopenButton no={transfer.no} className="btn ghost" /> : null}
          {transfer.status === 'Approved' && canPost ? <PostButton no={transfer.no} /> : null}
          <DocumentActionsMenu />
        </Toolbar>

        <CollapsibleCard title="Transfer details" sub="Cash moved from the source account to the destination account">
          <div className="grid g2">
            <DefinitionList items={[
              ['Transfer no.', <span className="mono" key="no">{transfer.no}</span>],
              ['Amount type', transfer.amount_type === 'FULL' ? 'Full' : 'Partial'],
              ['Amount', <Money cents={transfer.amount} key="a" />],
              ['Transfer charge', <Money cents={transfer.charge_amount} key="c" />],
              ['Posting date', transfer.posting_date],
              ['Narration', transfer.narration || '—'],
              ['Status', <Pill status={transfer.status} key="st" />],
              transfer.decision_reason ? ['Decision reason', transfer.decision_reason] : null,
            ]} />
            <DefinitionList items={[
              ['From member', <>{transfer.source_first_name} {transfer.source_last_name} <span className="mono">({transfer.source_member_no})</span></>],
              ['From account', <><span className="mono">{transfer.source_account_no}</span> — {transfer.source_product_name}</>],
              ['Source available', <Money cents={transfer.source_available} key="sa" />],
              ['To member', <>{transfer.destination_first_name} {transfer.destination_last_name} <span className="mono">({transfer.destination_member_no})</span></>],
              ['To account', <><span className="mono">{transfer.destination_account_no}</span> — {transfer.destination_product_name}</>],
              transfer.journal_no ? ['Journal', <span className="mono" key="j">{transfer.journal_no}</span>] : null,
            ]} />
          </div>
        </CollapsibleCard>

        <CollapsibleCard title="Document trail" sub="Who raised this, and when">
          <DefinitionList items={[
            ['Created by', transfer.created_by || '—'],
            ['Created on', formatDateTime(transfer.created_at)],
            ['Posted by', transfer.posted_by || '—'],
            ['Posted on', formatDateTime(transfer.posted_at)],
          ]} />
        </CollapsibleCard>

        <CollapsibleCard title="Journal postings" sub={`${history.length} G/L journal${history.length === 1 ? '' : 's'} for ${transfer.no}`}>
          {history.length ? (
            <TableWrap>
              <thead><tr><th>Journal</th><th>Value date</th><th>Description</th><th className="num">Amount</th></tr></thead>
              <tbody>
                {history.map((h) => (
                  <tr key={h.journal_no}>
                    <td className="mono">{h.journal_no}</td>
                    <td>{h.value_date}</td>
                    <td>{h.description || '—'}</td>
                    <td className="num"><Money cents={h.amount} /></td>
                  </tr>
                ))}
              </tbody>
            </TableWrap>
          ) : <EmptyState icon="🧾" title="Not yet posted" />}
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
