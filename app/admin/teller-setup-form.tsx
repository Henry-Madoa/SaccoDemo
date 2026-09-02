'use client';

import { useState } from 'react';
import { FormModal } from '@/components/ui/form-modal';
import { Field } from '@/components/ui/field';
import { useRunAction } from '@/components/ui/run-action';
import { saveTellerSetup, removeTellerSetup } from '@/app/actions/tellerSetup';
import type { TellerSetupWithAccount } from '@/lib/types';

type UserOption = { value: string; label: string };
type AccountOption = { value: number; label: string; type: string };

export function TellerSetupFormButton({
  userOptions, accountOptions, row, className = 'btn', children,
}: {
  userOptions: UserOption[];
  accountOptions: AccountOption[];
  row?: TellerSetupWithAccount | null;
  className?: string;
  children: React.ReactNode;
}) {
  const [open, setOpen] = useState(false);
  const [setupType, setSetupType] = useState<'TELLER' | 'TREASURY'>(row?.setup_type ?? 'TELLER');
  const wantType = setupType === 'TELLER' ? 'TILL' : 'TREASURY';
  const accounts = accountOptions.filter((a) => a.type === wantType);

  return (
    <>
      <button type="button" className={className} onClick={() => setOpen(true)}>{children}</button>
      {open ? (
        <FormModal
          title={row ? `Edit teller setup — ${row.user_username}` : 'Add teller setup'}
          onClose={() => setOpen(false)}
          onSubmit={saveTellerSetup}
          submitLabel="Save"
          successTitle="Teller setup saved"
        >
          <Field name="userUsername" label="User" type="select" required
            defaultValue={row?.user_username ?? ''} options={[{ value: '', label: 'Select a user…' }, ...userOptions]} />
          <div className="field">
            <label htmlFor="f_setupType">Setup type <span className="req">*</span></label>
            <select id="f_setupType" name="setupType" value={setupType}
              onChange={(e) => setSetupType(e.target.value as 'TELLER' | 'TREASURY')}>
              <option value="TELLER">Teller (till)</option>
              <option value="TREASURY">Treasury (vault)</option>
            </select>
          </div>
          <Field name="bankAccountId" label={`Cash account (${wantType})`} type="select" required
            defaultValue={row?.bank_account_id ?? ''}
            options={[{ value: '', label: `Select a ${wantType} account…` }, ...accounts.map((a) => ({ value: a.value, label: a.label }))]} />
          <div className="grid g2">
            <Field name="minCapacity" label="Minimum capacity" type="currency" min={0}
              defaultValue={row ? row.min_capacity / 100 : 0}
              hint="A movement may not take this account below this" />
            <Field name="maxCapacity" label="Maximum capacity" type="currency" min={0}
              defaultValue={row ? row.max_capacity / 100 : 0}
              hint="A movement may not take this account above this (0 = no ceiling)" />
          </div>
          {setupType === 'TELLER' ? (
            <Field name="approvalLimit" label="Approval limit" type="currency" min={0}
              defaultValue={row ? row.approval_limit / 100 : 0}
              hint="A deposit/withdrawal above this must be approved before it can be posted" />
          ) : null}
        </FormModal>
      ) : null}
    </>
  );
}

export function DeleteTellerSetupButton({ id, className = 'btn sm ghost' }: { id: number; className?: string }) {
  const { run, busy } = useRunAction();
  return (
    <button type="button" className={className} disabled={busy}
      onClick={() => run(() => removeTellerSetup(id), {
        confirm: { title: 'Delete this teller setup?', message: 'The user will no longer be able to operate that cash account.', confirmLabel: 'Delete' },
        successTitle: 'Teller setup deleted',
      })}>
      {busy ? 'Working…' : 'Delete'}
    </button>
  );
}
