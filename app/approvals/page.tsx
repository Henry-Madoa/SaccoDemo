import Link from 'next/link';
import { requirePerm } from '@/lib/session';
import { listApprovalTasks } from '@/lib/reports';
import { formatDateTime } from '@/lib/format';
import { Page } from '@/components/layout/page';
import { Card, CardHead, EmptyState, Pill, Stat, TableWrap } from '@/components/ui/primitives';
import { Money } from '@/components/ui/money';
import type { ApprovalTaskRow } from '@/lib/types';

function TaskTable({ rows, showDecision }: { rows: ApprovalTaskRow[]; showDecision: boolean }) {
  return (
    <TableWrap>
      <thead>
        <tr>
          <th>Loan no.</th><th>Member</th><th className="num">Amount</th>
          <th>Captured by</th><th>Captured</th>
          {showDecision
            ? <><th>Decision</th><th>Checker</th><th>Reason</th></>
            : <th />}
        </tr>
      </thead>
      <tbody>
        {rows.map((r) => (
          <tr key={r.id}>
            <td className="mono"><Link href={`/loans/${r.entity_id}`}>{r.loan_no || '—'}</Link></td>
            <td>{r.first_name || ''} {r.last_name || ''}</td>
            <td className="num"><Money cents={r.amount} decimals={0} /></td>
            <td>{r.maker}</td>
            <td>{formatDateTime(r.maker_at)}</td>
            {showDecision ? (
              <>
                <td><Pill status={r.decision} /></td>
                <td>{r.checker || '—'}</td>
                <td className="muted-cell">{r.reason || ''}</td>
              </>
            ) : (
              <td className="num">
                <Link className="btn sm ghost" href={`/loans/${r.entity_id}`}>Review</Link>
              </td>
            )}
          </tr>
        ))}
      </tbody>
    </TableWrap>
  );
}

export default async function ApprovalsPage() {
  const user = await requirePerm('LOAN:READ');
  const rows = await listApprovalTasks();
  const pending = rows.filter((r) => r.decision === 'PENDING');
  const decided = rows.filter((r) => r.decision !== 'PENDING');

  return (
    <Page
      title="Approvals"
      crumb="Maker-checker queue — an approver may not clear their own work"
      user={user}
    >
      <div className="grid g3 stack-2">
        <Stat label="Awaiting decision" value={pending.length} />
        <Stat label="Value pending"
          value={<Money cents={pending.reduce((a, r) => a + r.amount, 0)} decimals={0} />} />
        <Stat label="Decided" value={decided.length} />
      </div>

      <Card>
        <CardHead title="Pending approvals" sub="Segregation of duties is enforced server-side" />
        {pending.length
          ? <TaskTable rows={pending} showDecision={false} />
          : <EmptyState icon="✔" title="The queue is clear" />}
      </Card>

      <Card>
        <CardHead title="Decision history" sub="Rejected items stay traceable and can be resubmitted" />
        {decided.length
          ? <TaskTable rows={decided} showDecision />
          : <EmptyState icon="🗂" title="Nothing decided yet" />}
      </Card>
    </Page>
  );
}
