'use client';

import { useRunAction } from '@/components/ui/run-action';
import { runMemberStatusUpdateNow } from '@/app/actions/memberStatusUpdate';
import { useFormat } from '@/components/ui/format-provider';

/** Runs the update across every Active/Dormant member — the same runner a Job Queue Entry calls
 *  unattended (Admin Centre → System Automation), just triggered here by a signed-in officer. */
export function RunStatusUpdateButton({ disabled }: { disabled?: boolean }) {
  const { run, busy } = useRunAction();
  const { cur } = useFormat();

  return (
    <button type="button" className="btn" disabled={disabled || busy}
      onClick={() => run(() => runMemberStatusUpdateNow(), {
        confirm: {
          title: 'Run Member Status Update?',
          message: 'Members with no money in their Non-Withdrawable Deposit account long enough will be marked Dormant; Dormant members who now have money will be reactivated (recovering the reactivation charge, if one is configured). This cannot be undone.',
          confirmLabel: 'Run update',
        },
        successTitle: (d) => (d.markedDormant || d.reactivated
          ? `${d.markedDormant} marked Dormant, ${d.reactivated} reactivated` : 'No status changes needed'),
        successDetail: (d) => (d.totalCharged ? `${cur(d.totalCharged)} in reactivation charges recovered` : undefined),
      })}>
      {busy ? 'Working…' : 'Run update'}
    </button>
  );
}
