import { CollapsibleCard } from '@/components/ui/collapsible-card';
import { EmptyState, TableWrap } from '@/components/ui/primitives';
import type { MemberEditFieldDiff } from '@/lib/types';

const fmt = (v: string | number | null) => (v === null || v === '' ? '—' : String(v));

/** What an approver actually needs to decide on — every field this request would change,
 *  current vs. requested, without having to read two full cards side by side. */
export function ChangesSummary({ diffs }: { diffs: MemberEditFieldDiff[] }) {
  return (
    <CollapsibleCard title="What's changing" sub={`${diffs.length} field${diffs.length === 1 ? '' : 's'} would change`}>
      {diffs.length ? (
        <TableWrap>
          <thead>
            <tr><th>Field</th><th>Current</th><th>Requested</th></tr>
          </thead>
          <tbody>
            {diffs.map((d) => (
              <tr key={d.field}>
                <td><b>{d.label}</b></td>
                <td className="muted-cell">{fmt(d.from)}</td>
                <td>{fmt(d.to)}</td>
              </tr>
            ))}
          </tbody>
        </TableWrap>
      ) : <EmptyState icon="✓" title="No changes yet" sub="Edit the cards below to stage a change" />}
    </CollapsibleCard>
  );
}
