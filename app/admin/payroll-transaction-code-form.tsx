'use client';

import { useState } from 'react';
import { FormModal } from '@/components/ui/form-modal';
import { Field } from '@/components/ui/field';
import { useRunAction } from '@/components/ui/run-action';
import { saveTransactionCodeRequest, deleteTransactionCodeRequest } from '@/app/actions/payrollSetup';
import type { GlAccount, PayrollTransactionCode } from '@/lib/types';

const TYPE_OPTIONS = [
  { value: 'INCOME', label: 'Income' }, { value: 'DEDUCTION', label: 'Deduction' }, { value: 'COMPANY_DEDUCTION', label: 'Company Deduction' },
];
const BALANCE_OPTIONS = [
  { value: 'NONE', label: 'None' }, { value: 'INCREASING', label: 'Increasing' }, { value: 'REDUCING', label: 'Reducing (loan-style)' },
];
const SPECIAL_OPTIONS = [
  { value: 'NONE', label: '—' }, { value: 'BASIC_SALARY', label: 'Basic Salary' }, { value: 'HOUSE_ALLOWANCE', label: 'House Allowance' },
  { value: 'TRANSPORT_ALLOWANCE', label: 'Transport Allowance' }, { value: 'OVERTIME', label: 'Overtime' },
  { value: 'ACTING_ALLOWANCE', label: 'Acting Allowance' }, { value: 'LEAVE_ALLOWANCE', label: 'Leave Allowance' },
  { value: 'GRATUITY', label: 'Gratuity' }, { value: 'PENSION', label: 'Pension (pre-tax)' },
  { value: 'MORTGAGE', label: 'Mortgage (relief)' }, { value: 'INSURANCE', label: 'Insurance (relief)' },
  { value: 'LOAN', label: 'Loan' }, { value: 'SALARY_ARREARS', label: 'Salary Arrears' }, { value: 'DIRECTORS_FEE', label: "Director's Fee" },
];

export function TransactionCodeFormButton({ code, accounts, className = 'btn', children }: {
  code?: PayrollTransactionCode | null; accounts: GlAccount[]; className?: string; children: React.ReactNode;
}) {
  const [open, setOpen] = useState(false);
  const c = code ?? null;
  const opts = [{ value: '', label: '—' }, ...accounts.map((a) => ({ value: a.id, label: `${a.code} — ${a.name}` }))];

  return (
    <>
      <button type="button" className={className} onClick={() => setOpen(true)}>{children}</button>
      {open ? (
        <FormModal
          title={c ? `Edit ${c.name}` : 'Add a payroll transaction code'} wide
          onClose={() => setOpen(false)}
          onSubmit={(values) => saveTransactionCodeRequest({ ...values, id: c?.id ?? '' })}
          submitLabel={c ? 'Save changes' : 'Create'}
          successTitle={c ? 'Transaction code updated' : 'Transaction code created'}
        >
          <div className="grid g2">
            <Field name="code" label="Code" required defaultValue={c?.code} uppercase />
            <Field name="name" label="Name" required defaultValue={c?.name} />
          </div>
          <div className="grid g3">
            <Field name="type" label="Type" type="select" options={TYPE_OPTIONS} defaultValue={c?.type ?? 'INCOME'} />
            <Field name="balanceType" label="Balance behaviour" type="select" options={BALANCE_OPTIONS} defaultValue={c?.balance_type ?? 'NONE'} />
            <Field name="specialType" label="Special type" type="select" options={SPECIAL_OPTIONS} defaultValue={c?.special_type ?? 'NONE'} />
          </div>
          <div className="grid g2">
            <Field name="glAccountId" label="G/L account" type="select" options={opts} defaultValue={c?.gl_account_id ?? ''} />
            <Field name="employerGlAccountId" label="Employer expense account (Company Deduction)" type="select" options={opts} defaultValue={c?.employer_gl_account_id ?? ''} />
          </div>
          <div className="grid g2">
            <Field name="fixedAmountCents" label="Default/fixed amount" type="currency" defaultValue={c ? c.fixed_amount_cents / 100 : 0} />
            <Field name="upperLimitCents" label="Upper limit (optional cap)" type="currency" defaultValue={c?.upper_limit_cents != null ? c.upper_limit_cents / 100 : ''} />
          </div>
          <div className="grid g3">
            <Field name="taxable" label="Taxable" type="checkbox" defaultValue={c?.taxable !== false ? '1' : ''} />
            <Field name="forEveryEmployee" label="Blanket — applies to every employee" type="checkbox" defaultValue={c?.for_every_employee ? '1' : ''} />
            <Field name="isFormula" label="Formula-driven (amount entered manually per employee)" type="checkbox" defaultValue={c?.is_formula ? '1' : ''} />
          </div>
        </FormModal>
      ) : null}
    </>
  );
}

export function DeleteTransactionCodeButton({ id, className = 'btn sm ghost' }: { id: number; className?: string }) {
  const { run, busy } = useRunAction();
  return (
    <button type="button" className={className} disabled={busy}
      onClick={() => run(() => deleteTransactionCodeRequest(id), {
        confirm: { title: 'Delete this transaction code?', message: 'Refused if it has been used on a payroll transaction.', confirmLabel: 'Delete' },
        successTitle: 'Deleted',
      })}>
      {busy ? 'Working…' : 'Delete'}
    </button>
  );
}
