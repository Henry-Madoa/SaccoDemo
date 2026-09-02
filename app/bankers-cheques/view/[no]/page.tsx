import Link from 'next/link';
import { notFound } from 'next/navigation';
import { requireAction, currentCanAction } from '@/lib/session';
import {
  getBankersCheque, getAdjacentBankersChequeNos, listBankersChequeHistory, type BankersChequeView2,
} from '@/lib/bankersCheques';
import { listActiveChequeTypes } from '@/lib/chequeTypes';
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
} from '../../cheque-actions';

const VIEWS: BankersChequeView2[] = ['open', 'pending', 'approved', 'processed'];

export default async function BankersChequeDetailPage({ params, searchParams }: {
  params: Promise<{ no: string }>;
  searchParams: Promise<{ view?: string }>;
}) {
  const user = await requireAction('BANKERS_CHEQUES_READ');
  const { no } = await params;
  const { view: viewRaw } = await searchParams;
  const view = VIEWS.includes(viewRaw as BankersChequeView2) ? (viewRaw as BankersChequeView2) : undefined;

  const cheque = await getBankersCheque(no);
  if (!cheque) notFound();

  const [canCreate, canApprove, canPost, tasks, { prevNo, nextNo }, history] = await Promise.all([
    currentCanAction('BANKERS_CHEQUES_CREATE'),
    currentCanAction('BANKERS_CHEQUES_APPROVE'),
    currentCanAction('BANKERS_CHEQUES_POST'),
    listWorkflowTasksForDocument('BANKERS_CHEQUE', no),
    getAdjacentBankersChequeNos(no, view),
    listBankersChequeHistory(no),
  ]);

  const isOwn = cheque.created_by === user.username;
  const isOpen = cheque.status === 'Open';
  const [editMembers, editChequeTypes] = isOpen && canCreate && isOwn
    ? await Promise.all([listActiveMembers(), listActiveChequeTypes('BANKERS')])
    : [[], []];

  const routedTask = cheque.status === 'Pending Approval' ? await findPendingRoutedTask('BANKERS_CHEQUE', no) : null;
  const canDecideThis = routedTask ? await isEligibleApprover(routedTask, user.id) : canApprove;
  const requestedBy = routedTask?.requested_by ?? cheque.created_by;
  const canCancelThis = canCreate && requestedBy === user.username;
  const pendingWith = tasks.find((t) => t.status === 'PENDING')?.pending_with;
  const q = view ? `?view=${view}` : '';

  return (
    <>
      <CardNav
        prevHref={prevNo ? `/bankers-cheques/view/${prevNo}${q}` : null}
        nextHref={nextNo ? `/bankers-cheques/view/${nextNo}${q}` : null}
      />
      <Page
        title={`${cheque.no} — Banker's Cheque`}
        crumb={`${cheque.status} · ${cheque.member_first_name} ${cheque.member_last_name} (${cheque.member_no})${pendingWith ? ` · pending with ${pendingWith}` : ''}`}
        user={user}
      >
        <Toolbar>
          <Link href="/bankers-cheques" className="btn ghost sm">← All banker's cheques</Link>
          <Link href={`/members/${cheque.member_id}`} className="btn ghost sm">View member</Link>
          <Spacer />
          {isOpen && canCreate && isOwn ? <EditButton cheque={cheque} members={editMembers} chequeTypes={editChequeTypes} className="btn ghost" /> : null}
          {isOpen && canCreate && isOwn ? <DeleteButton no={cheque.no} className="btn ghost" /> : null}
          {isOpen && canCreate && isOwn ? <SubmitButton no={cheque.no} className="btn ghost" /> : null}
          {cheque.status === 'Pending Approval' && canCancelThis ? <CancelApprovalButton no={cheque.no} className="btn ghost" /> : null}
          {cheque.status === 'Pending Approval' && canDecideThis ? (
            <>
              {routedTask ? <DelegateButton taskId={routedTask.id} className="btn ghost" /> : null}
              <ApproveButton no={cheque.no} />
              <RejectButton no={cheque.no} className="btn ghost" />
            </>
          ) : null}
          {cheque.status === 'Approved' && !cheque.posted && canApprove ? <ReopenButton no={cheque.no} className="btn ghost" /> : null}
          {cheque.status === 'Approved' && canPost ? <PostButton no={cheque.no} /> : null}
          <DocumentActionsMenu />
        </Toolbar>

        <CollapsibleCard title="Banker's cheque details" sub="Sold against the member's deposit account">
          <div className="grid g2">
            <DefinitionList items={[
              ['Cheque no.', <span className="mono" key="no">{cheque.no}</span>],
              ['Type', <><span className="mono">{cheque.cheque_type_code}</span> — {cheque.description}</>],
              ['Physical cheque no.', cheque.cheque_no || '—'],
              ['Member', <>{cheque.member_first_name} {cheque.member_last_name} <span className="mono">({cheque.member_no})</span></>],
              ['Account', <><span className="mono">{cheque.account_no}</span> — {cheque.account_product_name}</>],
              ['Payee details', cheque.payee_details || '—'],
              ['Posting date', cheque.posting_date],
            ]} />
            <DefinitionList items={[
              ['Amount', <Money cents={cheque.amount} key="a" />],
              ['Clearing charge', <Money cents={cheque.charge_amount} key="c" />],
              ['Net amount', <Money cents={cheque.net_amount} key="n" />],
              ['Account balance', <Money cents={cheque.account_balance} key="b" />],
              ['Available', <Money cents={cheque.account_available} key="av" />],
              ['Clearing account', <span className="mono" key="cl">{cheque.clearing_gl_account_code}</span>],
              ['Status', <Pill status={cheque.status} key="st" />],
              cheque.decision_reason ? ['Decision reason', cheque.decision_reason] : null,
              cheque.journal_no ? ['Journal', <span className="mono" key="j">{cheque.journal_no}</span>] : null,
            ]} />
          </div>
        </CollapsibleCard>

        <CollapsibleCard title="Document trail" sub="Who raised this, and when">
          <DefinitionList items={[
            ['Created by', cheque.created_by || '—'],
            ['Created on', formatDateTime(cheque.created_at)],
            ['Posted by', cheque.posted_by || '—'],
            ['Posted on', formatDateTime(cheque.posted_at)],
          ]} />
        </CollapsibleCard>

        <CollapsibleCard title="Journal postings" sub={`${history.length} G/L journal${history.length === 1 ? '' : 's'} for ${cheque.no}`}>
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
