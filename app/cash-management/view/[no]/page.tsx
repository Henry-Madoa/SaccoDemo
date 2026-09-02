import Link from 'next/link';
import { notFound } from 'next/navigation';
import { requireAction, currentCanAction } from '@/lib/session';
import {
  getFosaTransaction, getAdjacentFosaTransactionNos, listFosaTransactionHistory, fosaDocTypeMeta,
  type CashManagementView,
} from '@/lib/cashManagement';
import { getDenominationLines } from '@/lib/denominations';
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
import { DenominationGrid } from '@/components/ui/denomination-grid';
import {
  EditButton, SubmitButton, CancelApprovalButton, ApproveButton, RejectButton, DelegateButton,
  PostButton, DeleteButton,
} from '../../cash-management-actions';

const VIEWS: CashManagementView[] = ['open', 'pending', 'approved', 'posted'];

export default async function CashMovementDetailPage({ params, searchParams }: {
  params: Promise<{ no: string }>;
  searchParams: Promise<{ view?: string }>;
}) {
  const user = await requireAction('CASH_MANAGEMENT_READ');
  const { no } = await params;
  const { view: viewRaw } = await searchParams;
  const view = VIEWS.includes(viewRaw as CashManagementView) ? (viewRaw as CashManagementView) : undefined;

  const doc = await getFosaTransaction(no);
  if (!doc) notFound();
  const meta = fosaDocTypeMeta(doc.document_type);

  const [canCreate, canApprove, canPost, tasks, { prevNo, nextNo }, denomLines, history] = await Promise.all([
    currentCanAction('CASH_MANAGEMENT_CREATE'),
    currentCanAction('CASH_MANAGEMENT_APPROVE'),
    currentCanAction('CASH_MANAGEMENT_POST'),
    listWorkflowTasksForDocument('FOSA_TRANSACTION', no),
    getAdjacentFosaTransactionNos(no, view),
    getDenominationLines('FOSA', no),
    doc.status === 'Processed' ? listFosaTransactionHistory(no) : Promise.resolve([]),
  ]);

  const isOwn = doc.created_by === user.username;
  const isOpen = doc.status === 'Open';

  const routedTask = doc.status === 'Pending Approval' ? await findPendingRoutedTask('FOSA_TRANSACTION', no) : null;
  const canDecideThis = routedTask ? await isEligibleApprover(routedTask, user.id) : canApprove;
  const requestedBy = routedTask?.requested_by ?? doc.created_by;
  const canCancelThis = canCreate && requestedBy === user.username;
  const pendingWith = tasks.find((t) => t.status === 'PENDING')?.pending_with;
  const q = view ? `?view=${view}` : '';

  return (
    <>
      <CardNav
        prevHref={prevNo ? `/cash-management/view/${prevNo}${q}` : null}
        nextHref={nextNo ? `/cash-management/view/${nextNo}${q}` : null}
      />
      <Page
        title={`${doc.no} — ${meta.label}`}
        crumb={`${doc.status} · ${meta.flow}${pendingWith ? ` · pending with ${pendingWith}` : ''}`}
        user={user}
      >
        <Toolbar>
          <Link href="/cash-management" className="btn ghost sm">← All cash movements</Link>
          <Spacer />
          {isOpen && canCreate && isOwn ? <EditButton doc={doc} className="btn ghost" /> : null}
          {isOpen && canCreate && isOwn ? <SubmitButton no={doc.no} className="btn ghost" /> : null}
          {isOpen && canCreate && isOwn ? <DeleteButton no={doc.no} className="btn ghost" /> : null}
          {doc.status === 'Pending Approval' && canCancelThis ? <CancelApprovalButton no={doc.no} className="btn ghost" /> : null}
          {doc.status === 'Pending Approval' && canDecideThis ? (
            <>
              {routedTask ? <DelegateButton taskId={routedTask.id} className="btn ghost" /> : null}
              <ApproveButton no={doc.no} />
              <RejectButton no={doc.no} className="btn ghost" />
            </>
          ) : null}
          {doc.status === 'Approved' && canPost ? <PostButton no={doc.no} /> : null}
          <DocumentActionsMenu />
        </Toolbar>

        <CollapsibleCard title="Movement details" sub={meta.flow}>
          <div className="grid g2">
            <DefinitionList items={[
              ['Document no.', <span className="mono" key="no">{doc.no}</span>],
              ['Movement', meta.label],
              ['From', <><span className="mono">{doc.source_code}</span> — {doc.source_name} ({doc.source_account_type})</>],
              ['To', <><span className="mono">{doc.destination_code}</span> — {doc.destination_name} ({doc.destination_account_type})</>],
              ['Amount', <Money cents={doc.amount} key="amt" />],
            ]} />
            <DefinitionList items={[
              ['From balance', <Money cents={doc.source_balance} key="sb" />],
              ['To balance', <Money cents={doc.destination_balance} key="db" />],
              ['Status', <Pill status={doc.status} key="st" />],
              doc.decision_reason ? ['Decision reason', doc.decision_reason] : null,
              doc.journal_no ? ['Journal', <span className="mono" key="j">{doc.journal_no}</span>] : null,
            ]} />
          </div>
        </CollapsibleCard>

        <CollapsibleCard title="Denomination breakdown" sub="Note & coin count for this movement">
          <DenominationGrid
            kind="FOSA"
            docNo={no}
            lines={denomLines}
            amount={doc.amount}
            editable={isOpen && canCreate && isOwn}
          />
        </CollapsibleCard>

        <CollapsibleCard title="Document trail" sub="Who raised this, and when">
          <DefinitionList items={[
            ['Created by', doc.created_by || '—'],
            ['Created on', formatDateTime(doc.created_at)],
            ['Posted by', doc.posted_by || '—'],
            ['Posted on', formatDateTime(doc.posted_at)],
          ]} />
        </CollapsibleCard>

        {doc.status === 'Processed' ? (
          <CollapsibleCard title="Posted entries" sub={`${history.length} journal${history.length === 1 ? '' : 's'}`}>
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
            ) : <EmptyState icon="🕓" title="Nothing posted yet" />}
          </CollapsibleCard>
        ) : null}

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
