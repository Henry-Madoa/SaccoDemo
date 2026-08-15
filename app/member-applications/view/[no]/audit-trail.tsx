import { Card, CardHead, DefinitionList, EmptyState, Pill, TableWrap } from '@/components/ui/primitives';
import { formatDateTime } from '@/lib/format';
import type { MemberApplicationWithDimensions, WorkflowTaskWithApprover } from '@/lib/types';

/** Approval routing (Sent by / Approver) comes from workflow_task, not this table —
 *  a multi-step workflow produces one task per step, so `tasks` is a full history,
 *  oldest first. A still-PENDING step shows who it's currently sitting with
 *  (`pending_with`) instead of a blank Approver cell, and a group-sequence step's
 *  already-cleared levels (`level_decisions`) each get their own row above it. */
export function AuditTrail({ application, tasks }: {
  application: MemberApplicationWithDimensions;
  tasks: WorkflowTaskWithApprover[];
}) {
  const processed = application.status === 'Processed';

  return (
    <>
      <Card>
        <CardHead title="Document trail" sub="Who created and processed this application, and when" />
        <DefinitionList items={[
          ['Created by', application.created_by || '—'],
          ['Created on', formatDateTime(application.created_at)],
          ['Status', <Pill status={application.status} key="status" />],
          ['Processed', processed
            ? <Pill tone="ok" key="processed">YES — {application.member_no}</Pill>
            : <Pill tone="warn" key="processed">NOT YET</Pill>],
          processed ? ['Processed by', application.processed_by || '—'] : null,
          processed ? ['Processed on', formatDateTime(application.processed_at)] : null,
          application.decision_reason ? ['Decision reason', application.decision_reason] : null,
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
    </>
  );
}
