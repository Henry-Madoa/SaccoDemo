'use client';

import { useState } from 'react';
import { FormModal } from '@/components/ui/form-modal';
import { Field } from '@/components/ui/field';
import { useRunAction } from '@/components/ui/run-action';
import {
  runPayrollForEmployeeRequest, runPayrollForPeriodRequest, addEmployeeTransactionRequest,
  removeEmployeeTransactionRequest, stopEmployeeTransactionRequest,
} from '@/app/actions/payroll';
import type { PayrollTransactionCode } from '@/lib/types';

export function RunForEmployeeButton({ periodId, employeeId, className = 'btn sm' }: { periodId: number; employeeId: number; className?: string }) {
  const { run, busy } = useRunAction();
  return (
    <button type="button" className={className} disabled={busy}
      onClick={() => run(() => runPayrollForEmployeeRequest(periodId, employeeId), {
        confirm: { title: 'Run payroll for this employee?', message: 'Re-computes their payslip lines for the open period. Safe to re-run.', confirmLabel: 'Run' },
        successTitle: 'Payroll computed',
      })}>
      {busy ? 'Working…' : 'Process'}
    </button>
  );
}

export function RunForPeriodButton({ periodId, className = 'btn' }: { periodId: number; className?: string }) {
  const { run, busy } = useRunAction();
  return (
    <button type="button" className={className} disabled={busy}
      onClick={() => run(() => runPayrollForPeriodRequest(periodId), {
        confirm: { title: 'Process payroll for every eligible employee?', message: 'Re-computes payslip lines for every Active/On Leave employee with a posting group set.', confirmLabel: 'Process payroll' },
        successTitle: (d) => `Processed ${d.processed} employee(s)`,
        successDetail: (d) => (d.failed.length ? `${d.failed.length} failed — check each employee's card for details` : undefined),
      })}>
      {busy ? 'Working…' : 'Process payroll'}
    </button>
  );
}

export function AddTransactionButton({ employeeId, periodId, codes, className = 'btn sm' }: {
  employeeId: number; periodId: number; codes: PayrollTransactionCode[]; className?: string;
}) {
  const [open, setOpen] = useState(false);
  return (
    <>
      <button type="button" className={className} onClick={() => setOpen(true)}>Add line</button>
      {open ? (
        <FormModal
          title="Add earnings / deduction line"
          onClose={() => setOpen(false)}
          onSubmit={(values) => addEmployeeTransactionRequest({
            employeeId, periodId, transactionCodeId: Number(values.transactionCodeId),
            amountCents: Math.round(Number(values.amountCents || 0) * 100),
            originalAmountCents: values.originalAmountCents ? Math.round(Number(values.originalAmountCents) * 100) : undefined,
            noOfPeriods: values.noOfPeriods ? Number(values.noOfPeriods) : undefined,
            temporary: !!Number(values.temporary), notes: values.notes ? String(values.notes) : undefined,
          })}
          submitLabel="Add"
          successTitle="Line added"
        >
          <Field name="transactionCodeId" label="Transaction code" type="select" required
            options={codes.map((c) => ({ value: c.id, label: `${c.code} — ${c.name}` }))} />
          <div className="grid g2">
            <Field name="amountCents" label="Amount this period" type="currency" required />
            <Field name="originalAmountCents" label="Original amount (loan principal, if reducing balance)" type="currency" />
          </div>
          <div className="grid g2">
            <Field name="noOfPeriods" label="Runs for N periods (blank = indefinite)" type="number" />
            <Field name="temporary" label="One-off (does not roll forward)" type="checkbox" />
          </div>
          <Field name="notes" label="Notes" />
        </FormModal>
      ) : null}
    </>
  );
}

export function StopTransactionButton({ id, stopped, className = 'btn sm ghost' }: { id: number; stopped: boolean; className?: string }) {
  const { run, busy } = useRunAction();
  return (
    <button type="button" className={className} disabled={busy}
      onClick={() => run(() => stopEmployeeTransactionRequest(id, !stopped), {
        confirm: { title: stopped ? 'Resume this line?' : 'Stop this line?', confirmLabel: stopped ? 'Resume' : 'Stop' },
        successTitle: stopped ? 'Resumed' : 'Stopped',
      })}>
      {busy ? '…' : (stopped ? 'Resume' : 'Stop')}
    </button>
  );
}

export function RemoveTransactionButton({ id, className = 'btn sm ghost' }: { id: number; className?: string }) {
  const { run, busy } = useRunAction();
  return (
    <button type="button" className={className} disabled={busy}
      onClick={() => run(() => removeEmployeeTransactionRequest(id), {
        confirm: { title: 'Remove this line?', message: 'Only while the period is Open.', confirmLabel: 'Remove' },
        successTitle: 'Removed',
      })}>
      {busy ? '…' : 'Remove'}
    </button>
  );
}
