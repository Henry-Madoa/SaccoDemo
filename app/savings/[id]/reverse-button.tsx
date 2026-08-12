'use client';

import { useState } from 'react';
import { FormModal } from '@/components/ui/form-modal';
import { Field } from '@/components/ui/field';
import { reverseTransaction } from '@/app/actions/savings';

export function ReverseButton({ accountId, txnId }: { accountId: number; txnId: number }) {
  const [open, setOpen] = useState(false);

  return (
    <>
      <button type="button" className="btn sm ghost" onClick={() => setOpen(true)}>Reverse</button>
      {open ? (
        <FormModal
          title="Reverse transaction"
          onClose={() => setOpen(false)}
          onSubmit={(values) => reverseTransaction(accountId, { ...values, txnId })}
          submitLabel="Post reversal"
          submitClass="btn danger"
          successTitle="Reversed"
          successDetail={(r) => `Journal ${r.journal_no}`}
        >
          <p>
            The original transaction is never altered. A compensating journal is posted and both
            entries remain visible in the audit trail.
          </p>
          <Field name="reason" label="Reason for reversal" required
            placeholder="e.g. Posted to the wrong account" />
        </FormModal>
      ) : null}
    </>
  );
}
