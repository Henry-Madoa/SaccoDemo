'use client';

import { useState } from 'react';
import { FormModal } from '@/components/ui/form-modal';
import { Field } from '@/components/ui/field';
import { useRunAction } from '@/components/ui/run-action';
import { savePostingGroupRequest, deletePostingGroupRequest } from '@/app/actions/payrollSetup';
import type { GlAccount, PayrollPostingGroup } from '@/lib/types';

export function PostingGroupFormButton({ group, accounts, className = 'btn', children }: {
  group?: PayrollPostingGroup | null; accounts: GlAccount[]; className?: string; children: React.ReactNode;
}) {
  const [open, setOpen] = useState(false);
  const g = group ?? null;
  const opts = accounts.map((a) => ({ value: a.id, label: `${a.code} — ${a.name}` }));

  return (
    <>
      <button type="button" className={className} onClick={() => setOpen(true)}>{children}</button>
      {open ? (
        <FormModal
          title={g ? `Edit ${g.name}` : 'Add a payroll posting group'} wide
          onClose={() => setOpen(false)}
          onSubmit={(values) => savePostingGroupRequest({ ...values, id: g?.id ?? '' })}
          submitLabel={g ? 'Save changes' : 'Create'}
          successTitle={g ? 'Posting group updated' : 'Posting group created'}
        >
          <div className="grid g2">
            <Field name="code" label="Code" required defaultValue={g?.code} uppercase />
            <Field name="name" label="Name" required defaultValue={g?.name} />
          </div>
          <div className="grid g2">
            <Field name="salaryExpenseAccountId" label="Salary expense account" type="select" required options={opts} defaultValue={g?.salary_expense_account_id ?? ''} />
            <Field name="netPayPayableAccountId" label="Net pay payable account" type="select" required options={opts} defaultValue={g?.net_pay_payable_account_id ?? ''} />
          </div>
          <Field name="payePayableAccountId" label="PAYE payable account" type="select" required options={opts} defaultValue={g?.paye_payable_account_id ?? ''} />
          <div className="grid g3">
            <Field name="nssfEmployeePayableAccountId" label="NSSF employee payable" type="select" required options={opts} defaultValue={g?.nssf_employee_payable_account_id ?? ''} />
            <Field name="nssfEmployerExpenseAccountId" label="NSSF employer expense" type="select" required options={opts} defaultValue={g?.nssf_employer_expense_account_id ?? ''} />
            <Field name="nssfEmployerPayableAccountId" label="NSSF employer payable" type="select" required options={opts} defaultValue={g?.nssf_employer_payable_account_id ?? ''} />
          </div>
          <Field name="shifPayableAccountId" label="SHIF payable account" type="select" required options={opts} defaultValue={g?.shif_payable_account_id ?? ''} />
          <div className="grid g3">
            <Field name="housingLevyEmployeePayableAccountId" label="Housing Levy employee payable" type="select" required options={opts} defaultValue={g?.housing_levy_employee_payable_account_id ?? ''} />
            <Field name="housingLevyEmployerExpenseAccountId" label="Housing Levy employer expense" type="select" required options={opts} defaultValue={g?.housing_levy_employer_expense_account_id ?? ''} />
            <Field name="housingLevyEmployerPayableAccountId" label="Housing Levy employer payable" type="select" required options={opts} defaultValue={g?.housing_levy_employer_payable_account_id ?? ''} />
          </div>
        </FormModal>
      ) : null}
    </>
  );
}

export function DeletePostingGroupButton({ id, className = 'btn sm ghost' }: { id: number; className?: string }) {
  const { run, busy } = useRunAction();
  return (
    <button type="button" className={className} disabled={busy}
      onClick={() => run(() => deletePostingGroupRequest(id), {
        confirm: { title: 'Delete this posting group?', message: 'Refused if any employee is assigned to it.', confirmLabel: 'Delete' },
        successTitle: 'Deleted',
      })}>
      {busy ? 'Working…' : 'Delete'}
    </button>
  );
}
