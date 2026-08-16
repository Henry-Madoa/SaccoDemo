'use client';

import { useState, type ReactNode } from 'react';
import { FormModal } from '@/components/ui/form-modal';
import { Field } from '@/components/ui/field';
import { createBankAccount, updateBankAccount } from '@/app/actions/gl';
import { PRODUCT_STATUSES } from '@/lib/constants';
import type { BankAccountListRow, GlAccount } from '@/lib/types';

export function BankAccountFormButton({ bankAccount, postableAccounts, className = 'btn', children }: {
  bankAccount?: BankAccountListRow | null;
  postableAccounts: GlAccount[];
  className?: string;
  children: ReactNode;
}) {
  const [open, setOpen] = useState(false);
  const b = bankAccount ?? null;

  return (
    <>
      <button type="button" className={className} onClick={() => setOpen(true)}>{children}</button>
      {open ? (
        <FormModal
          title={b ? `Edit ${b.code} — ${b.name}` : 'Add a bank account'}
          onClose={() => setOpen(false)}
          onSubmit={(values) => (b ? updateBankAccount(b.id, values) : createBankAccount(values))}
          submitLabel={b ? 'Save changes' : 'Create'}
          successTitle={b ? 'Bank account updated' : 'Bank account created'}
        >
          <Field name="code" label="Code" required placeholder="e.g. BANK2" defaultValue={b?.code} disabled={!!b} />
          <Field name="name" label="Name" required defaultValue={b?.name} />
          {b ? (
            <Field name="gl_account_id" label="G/L control account" defaultValue={`${b.gl_account_code} — ${b.gl_account_name}`} disabled />
          ) : (
            <Field
              name="gl_account_id" label="G/L control account" type="select" required
              options={postableAccounts.map((a) => ({ value: a.id, label: `${a.code} — ${a.name}` }))}
              hint="Gets flagged no-direct-posting — only Savings/Loans/Bank Reconciliation can post to it afterwards"
            />
          )}
          <Field name="bank_name" label="Bank name" placeholder="Optional" defaultValue={b?.bank_name ?? ''} />
          <Field name="account_no" label="Account number" placeholder="Optional" defaultValue={b?.account_no ?? ''} />
          {b ? (
            <Field name="status" label="Status" type="select" options={PRODUCT_STATUSES} defaultValue={b.status} />
          ) : null}
        </FormModal>
      ) : null}
    </>
  );
}
