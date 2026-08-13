import Link from 'next/link';
import { requireUser, currentCan } from '@/lib/session';
import {
  listMyWorkflowTasks, listLegacyPendingTasks, listWorkflowTaskHistory,
} from '@/lib/workflow';
import { formatDateTime } from '@/lib/format';
import { Page } from '@/components/layout/page';
import { Card, CardHead, EmptyState, Pill, Stat, TableWrap } from '@/components/ui/primitives';
import { Money } from '@/components/ui/money';
import { TaskActions } from './task-actions';
import type { WorkflowTaskRow } from '@/lib/types';

function TaskTable({ rows, decideable, showDecision }: {
  rows: WorkflowTaskRow[]; decideable: boolean; showDecision: boolean;
}) {
  return (
    <TableWrap>
      <thead>
        <tr>
          <th>Document</th><th>Workflow</th><th className="num">Amount</th>
          <th>Requested by</th><th>Requested</th>
          {showDecision ? <><th>Decision</th><th>Decided by</th><th>Comment</th></> : <th />}
        </tr>
      </thead>
      <tbody>
        {rows.map((r) => (
          <tr key={r.id}>
            <td><Link href={r.link}>{r.document_label}</Link></td>
            <td>{r.workflow_name || <span className="tiny">No workflow (permission-based)</span>}</td>
            <td className="num"><Money cents={r.amount} decimals={0} /></td>
            <td>{r.requested_by}</td>
            <td>{formatDateTime(r.requested_at)}</td>
            {showDecision ? (
              <>
                <td><Pill status={r.status} /></td>
                <td>{r.decided_by || '—'}</td>
                <td className="muted-cell">{r.comment || ''}</td>
              </>
            ) : (
              <td className="num">
                {decideable ? <TaskActions taskId={r.id} /> : <Link className="btn sm ghost" href={r.link}>Review</Link>}
              </td>
            )}
          </tr>
        ))}
      </tbody>
    </TableWrap>
  );
}

export default async function ApprovalsPage() {
  const user = await requireUser();
  const [myTasks, canLoanApprove, history] = await Promise.all([
    listMyWorkflowTasks(user.id),
    currentCan('LOAN:APPROVE'),
    listWorkflowTaskHistory(),
  ]);
  const legacyLoanTasks = canLoanApprove ? await listLegacyPendingTasks('LOAN') : [];

  const pendingValue = [...myTasks, ...legacyLoanTasks].reduce((a, r) => a + r.amount, 0);

  return (
    <Page
      title="Approvals"
      crumb="Workflow-routed requests and the maker-checker queue"
      user={user}
    >
      <div className="grid g3 stack-2">
        <Stat label="Awaiting your decision" value={myTasks.length + legacyLoanTasks.length} />
        <Stat label="Value pending" value={<Money cents={pendingValue} decimals={0} />} />
        <Stat label="Decided" value={history.length} />
      </div>

      <Card>
        <CardHead title="Assigned to me" sub="Routed by a workflow — only you (or your substitute/group) may decide these" />
        {myTasks.length
          ? <TaskTable rows={myTasks} decideable showDecision={false} />
          : <EmptyState icon="✔" title="Nothing routed to you right now" />}
      </Card>

      {canLoanApprove ? (
        <Card>
          <CardHead title="Loans awaiting decision" sub="No workflow configured for these — anyone with Loan Approve rights may act, from the loan's own page" />
          {legacyLoanTasks.length
            ? <TaskTable rows={legacyLoanTasks} decideable={false} showDecision={false} />
            : <EmptyState icon="✔" title="The queue is clear" />}
        </Card>
      ) : null}

      <Card>
        <CardHead title="Decision history" sub="Rejected items stay traceable and can be resubmitted" />
        {history.length
          ? <TaskTable rows={history} decideable={false} showDecision />
          : <EmptyState icon="🗂" title="Nothing decided yet" />}
      </Card>
    </Page>
  );
}
