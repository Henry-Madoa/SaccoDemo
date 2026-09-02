'use client';

import { useState } from 'react';
import { FormModal } from '@/components/ui/form-modal';
import { Field } from '@/components/ui/field';
import { useRunAction } from '@/components/ui/run-action';
import { saveAccountInstructionRequest, deleteAccountInstructionRequest } from '@/app/actions/accountInstructions';
import type { AccountInstruction } from '@/lib/types';

export function AccountInstructionFormButton({ row, className = 'btn', children }: {
  row?: AccountInstruction | null; className?: string; children: React.ReactNode;
}) {
  const [open, setOpen] = useState(false);
  return (
    <>
      <button type="button" className={className} onClick={() => setOpen(true)}>{children}</button>
      {open ? (
        <FormModal
          title={row ? `Account instruction — ${row.code}` : 'New account instruction'}
          onClose={() => setOpen(false)}
          onSubmit={saveAccountInstructionRequest}
          submitLabel="Save"
          successTitle="Account instruction saved"
        >
          {row ? <input type="hidden" name="id" value={row.id} /> : null}
          <Field name="code" label="Code" defaultValue={row?.code} required uppercase
            hint="A short identifier, e.g. NO_THIRD_PARTY" />
          <Field name="description" label="Instruction" defaultValue={row?.description} required
            hint="The wording the member and the teller see" />
          <Field name="sort" type="number" label="Sort order" step="1" defaultValue={String(row?.sort ?? 0)} />
          <Field type="checkbox" name="active" label="Active — offered in the registration dropdown"
            defaultValue={row ? row.active : 1} />
        </FormModal>
      ) : null}
    </>
  );
}

export function DeleteAccountInstructionButton({ id, className = 'btn sm ghost' }: { id: number; className?: string }) {
  const { run, busy } = useRunAction();
  return (
    <button type="button" className={className} disabled={busy}
      onClick={() => run(() => deleteAccountInstructionRequest(id), {
        confirm: {
          title: 'Delete this instruction?',
          message: 'Refused if it is already used — deactivate it instead.',
          confirmLabel: 'Delete',
        },
        successTitle: 'Deleted',
      })}>
      {busy ? 'Working…' : 'Delete'}
    </button>
  );
}
