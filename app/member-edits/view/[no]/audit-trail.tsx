import { Card, CardHead, DefinitionList, EmptyState, Pill, TableWrap } from '@/components/ui/primitives';
import { formatDateTime } from '@/lib/format';
import type { AuditEntry, MemberEditRequestWithDimensions } from '@/lib/types';

export function AuditTrail({ request, trail }: {
  request: MemberEditRequestWithDimensions;
  trail: AuditEntry[];
}) {
  const processed = trail.find((e) => e.action === 'MEMBER_EDIT_PROCESS');

  return (
    <>
      <Card>
        <CardHead title="Document trail" sub="Who requested and applied this edit, and when" />
        <DefinitionList items={[
          ['Created by', request.created_by || '—'],
          ['Created at', formatDateTime(request.created_at)],
          ['Status', <Pill status={request.status} key="status" />],
          ['Applied to member', request.status === 'Committed'
            ? <Pill tone="ok" key="processed">YES — {request.member_no}</Pill>
            : <Pill tone="warn" key="processed">NOT YET</Pill>],
          processed ? ['Applied by', processed.username || '—'] : null,
          processed ? ['Applied at', formatDateTime(processed.at)] : null,
          request.decision_reason ? ['Decision reason', request.decision_reason] : null,
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
