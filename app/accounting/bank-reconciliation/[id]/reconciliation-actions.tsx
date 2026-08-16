'use client';

import { useState, useTransition } from 'react';
import { useRouter } from 'next/navigation';
import { toggleReconciledEntry, completeBankReconciliation } from '@/app/actions/gl';
import { useToast } from '@/components/ui/toast';
import type { BankAccountLedgerEntryWithJournal } from '@/lib/types';

/** One entry row's checkbox — ticking posts immediately (optimistic) rather than batching, so
 *  a session interrupted partway through still has its ticks saved (see
 *  getBankReconciliationWorksheet's own-session reload behaviour). */
export function ReconcileCheckbox({ entry, reconciliationId, editable }: {
  entry: BankAccountLedgerEntryWithJournal; reconciliationId: number; editable: boolean;
}) {
  const router = useRouter();
  const toast = useToast();
  const [checked, setChecked] = useState(entry.reconciled === 1);
  const [pending, startTransition] = useTransition();

  const toggle = () => {
    const next = !checked;
    setChecked(next);
    startTransition(async () => {
      const res = await toggleReconciledEntry(entry.id, reconciliationId, next);
      if (!res.ok) {
        setChecked(!next);
        toast('Could not update', res.error, 'err');
        return;
      }
      router.refresh();
    });
  };

  return (
    <input type="checkbox" checked={checked} disabled={!editable || pending} onChange={toggle} aria-label="Reconciled" />
  );
}

export function CompleteReconciliationButton({ id, disabled }: { id: number; disabled: boolean }) {
  const router = useRouter();
  const toast = useToast();
  const [busy, setBusy] = useState(false);

  const complete = async () => {
    setBusy(true);
    try {
      const res = await completeBankReconciliation(id);
      if (!res.ok) { toast('Could not complete', res.error, 'err'); return; }
      toast('Reconciliation completed', undefined, 'ok');
      router.refresh();
    } finally {
      setBusy(false);
    }
  };

  return (
    <button type="button" className="btn" onClick={complete} disabled={disabled || busy}>
      {busy ? 'Working…' : 'Complete reconciliation'}
    </button>
  );
}
