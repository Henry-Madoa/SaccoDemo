'use client';

import { useRunAction } from '@/components/ui/run-action';
import { runEntranceFeeRecoveryNow } from '@/app/actions/entranceFeeRecovery';
import { useFormat } from '@/components/ui/format-provider';

/** Runs recovery across every Not Paid Up member with an outstanding fee — the same runner a
 *  Job Queue Entry calls unattended (Admin Centre → System Automation), just triggered here by a
 *  signed-in officer instead. */
export function RunRecoveryButton({ disabled }: { disabled?: boolean }) {
  const { run, busy } = useRunAction();
  const { cur } = useFormat();

  return (
    <button type="button" className="btn" disabled={disabled || busy}
      onClick={() => run(() => runEntranceFeeRecoveryNow(), {
        confirm: {
          title: 'Run Entrance Fee Recovery?',
          message: 'Every eligible Not Paid Up member will have whatever their deposit account can spare swept toward their registration fee. This cannot be undone.',
          confirmLabel: 'Run recovery',
        },
        successTitle: (d) => {
          const failures = d.results.filter((r) => r.skipped_reason?.startsWith('Posting failed'));
          if (failures.length) return `${failures.length} member(s) could not be posted`;
          return d.membersRecovered ? `${d.membersRecovered} member(s) recovered` : 'Nothing to recover';
        },
        successDetail: (d) => {
          const failures = d.results.filter((r) => r.skipped_reason?.startsWith('Posting failed'));
          if (failures.length) {
            const rest = failures.length > 1 ? `\n(+${failures.length - 1} more)` : '';
            return `${failures[0].member_no} — ${failures[0].skipped_reason}${rest}`;
          }
          return d.membersRecovered
            ? `${cur(d.totalPosted)} posted · ${d.membersActivated} member(s) activated`
            : 'No eligible member currently has both an outstanding fee and an available balance';
        },
      })}>
      {busy ? 'Working…' : 'Run recovery'}
    </button>
  );
}
