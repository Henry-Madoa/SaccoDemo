'use client';

import { ActionButton } from '@/components/ui/action-button';
import { runAging } from '@/app/actions/loans';
import { formatDate } from '@/lib/format';

export function AgingButton() {
  return (
    <ActionButton
      className="btn ghost"
      action={runAging}
      success="Ageing complete"
      successDetail={(r) => `${r.loansProcessed} loans reclassified as at ${formatDate(r.asOf)}`}
    >
      Run arrears ageing
    </ActionButton>
  );
}
