import { Card, CardHead, DefinitionList, EmptyState, Pill, TableWrap } from '@/components/ui/primitives';
import { formatDateTime } from '@/lib/format';
import type { AuditEntry, MemberApplicationWithDimensions } from '@/lib/types';

export function AuditTrail({ application, trail }: {
  application: MemberApplicationWithDimensions;
  trail: AuditEntry[];
}) {
  const processed = trail.find((e) => e.action === 'MEMBER_APPLICATION_PROCESS');

  return (
    <>
      <Card>
        <CardHead title="Document trail" sub="Who created and processed this application, and when" />
        <DefinitionList items={[
          ['Created by', application.created_by || '—'],
          ['Created at', formatDateTime(application.created_at)],
          ['Status', <Pill status={application.status} key="status" />],
          ['Processed', application.member_id
            ? <Pill tone="ok" key="processed">YES — {application.member_no}</Pill>
            : <Pill tone="warn" key="processed">NOT YET</Pill>],
          processed ? ['Processed by', processed.username || '—'] : null,
          processed ? ['Processed at', formatDateTime(processed.at)] : null,
          application.decision_reason ? ['Decision reason', application.decision_reason] : null,
        ]} />
      </Card>

      <Card>
        <CardHead title="Audit log" sub={`${trail.length} event${trail.length === 1 ? '' : 's'} recorded`} />
        {trail.length ? (
          <TableWrap>
            <thead>
              <tr><th>Action</th><th>At</th><th>By</th><th>Detail</th></tr>
            </thead>
            <tbody>
              {trail.map((e) => (
                <tr key={e.id}>
                  <td><Pill status={e.action} /></td>
                  <td>{formatDateTime(e.at)}</td>
                  <td className="muted-cell">{e.username || '—'}</td>
                  <td className="tiny mono">{e.detail || '—'}</td>
                </tr>
              ))}
            </tbody>
          </TableWrap>
        ) : <EmptyState icon="🕓" title="No audit events yet" />}
      </Card>
    </>
  );
}
