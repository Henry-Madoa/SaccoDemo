'use client';

import { useRef, useState } from 'react';
import { useRouter } from 'next/navigation';
import { Modal } from '@/components/ui/modal';
import { Field, readForm } from '@/components/ui/field';
import { startBankReconciliation } from '@/app/actions/gl';
import { today } from '@/lib/format';
import type { BankAccountListRow } from '@/lib/types';

/** Opens the reconciliation worksheet on success rather than just refreshing the list —
 *  FormModal has no redirect hook, and this is the only screen in the app that needs one. */
export function StartReconciliationButton({ bankAccount, className = 'btn ghost sm', children = 'Reconcile' }: {
  bankAccount: BankAccountListRow;
  className?: string;
  children?: React.ReactNode;
}) {
  const [open, setOpen] = useState(false);
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState('');
  const formRef = useRef<HTMLFormElement>(null);
  const router = useRouter();

  const submit = async () => {
    const form = formRef.current;
    if (!form || !form.reportValidity()) return;
    setBusy(true);
    setError('');
    try {
      const res = await startBankReconciliation(bankAccount.id, readForm(form));
      if (!res.ok) { setError(res.error); return; }
      setOpen(false);
      router.push(`/accounting/bank-reconciliation/${res.data.id}`);
    } finally {
      setBusy(false);
    }
  };

  return (
    <>
      <button type="button" className={className} onClick={() => setOpen(true)}>{children}</button>
      {open ? (
        <Modal
          title={`Reconcile ${bankAccount.code} — ${bankAccount.name}`}
          onClose={() => setOpen(false)}
          footer={
            <>
              {error ? <div className="modal-error">{error}</div> : null}
              <button type="button" className="btn ghost" onClick={() => setOpen(false)} disabled={busy}>Cancel</button>
              <button type="button" className="btn" onClick={submit} disabled={busy}>
                {busy ? 'Working…' : 'Start reconciliation'}
              </button>
            </>
          }
        >
          <form ref={formRef}>
            <Field name="statementDate" label="Statement date" type="date" required defaultValue={today()} />
            <Field name="statementBalance" label="Statement balance" type="number" step="0.01" required />
          </form>
        </Modal>
      ) : null}
    </>
  );
}
