'use client';

import { useState } from 'react';
import { FormModal } from '@/components/ui/form-modal';
import { Field } from '@/components/ui/field';
import { useRunAction } from '@/components/ui/run-action';
import {
  createPayrollPeriodRequest, submitPayrollPeriodRequest, cancelPayrollPeriodApprovalRequest,
  approvePayrollPeriodRequest, rejectPayrollPeriodRequest, closePayrollPeriodRequest,
} from '@/app/actions/payroll';

export function NewPeriodButton() {
  const [open, setOpen] = useState(false);
  return (
    <>
      <button type="button" className="btn" onClick={() => setOpen(true)}>New payroll period</button>
      {open ? (
        <FormModal
          title="New payroll period"
          onClose={() => setOpen(false)}
          onSubmit={createPayrollPeriodRequest}
          submitLabel="Create"
          successTitle="Payroll period created"
        >
          <Field name="periodName" label="Period name" required placeholder="e.g. 2026-09" />
          <div className="grid g2">
            <Field name="startDate" label="Start date" type="date" required />
            <Field name="endDate" label="End date" type="date" required />
          </div>
        </FormModal>
      ) : null}
    </>
  );
}

export function SubmitButton({ id, className = 'btn sm ghost' }: { id: number; className?: string }) {
  const { run, busy } = useRunAction();
  return (
    <button type="button" className={className} disabled={busy}
      onClick={() => run(() => submitPayrollPeriodRequest(id), {
        confirm: { title: 'Send this period for approval?', confirmLabel: 'Send for approval' },
        successTitle: (d) => (d.autoApproved ? 'Approved' : 'Sent for approval'),
      })}>
      {busy ? 'Working…' : 'Send for approval'}
    </button>
  );
}

export function CancelApprovalButton({ id, className = 'btn sm ghost' }: { id: number; className?: string }) {
  const { run, busy } = useRunAction();
  return (
    <button type="button" className={className} disabled={busy}
      onClick={() => run(() => cancelPayrollPeriodApprovalRequest(id), {
        confirm: { title: 'Recall this period?', confirmLabel: 'Recall' }, successTitle: 'Recalled — back to Open',
      })}>
      {busy ? 'Working…' : 'Cancel approval request'}
    </button>
  );
}

export { DelegateButton } from '@/components/ui/delegate-button';

export function ApproveButton({ id, className = 'btn sm' }: { id: number; className?: string }) {
  const { run, busy } = useRunAction();
  return (
    <button type="button" className={className} disabled={busy}
      onClick={() => run(() => approvePayrollPeriodRequest(id), {
        confirm: { title: 'Approve this payroll period?', confirmLabel: 'Approve' }, successTitle: 'Approved',
      })}>
      {busy ? 'Working…' : 'Approve'}
    </button>
  );
}

export function RejectButton({ id, className = 'btn sm ghost' }: { id: number; className?: string }) {
  const [open, setOpen] = useState(false);
  return (
    <>
      <button type="button" className={className} onClick={() => setOpen(true)}>Reject</button>
      {open ? (
        <FormModal
          title="Reject payroll period"
          onClose={() => setOpen(false)}
          onSubmit={(values) => rejectPayrollPeriodRequest(id, String(values.reason || ''))}
          submitLabel="Reject" submitClass="btn danger"
          successTitle="Rejected — back to Open" resultStyle="popup"
        >
          <Field name="reason" label="Reason" type="textarea" required />
        </FormModal>
      ) : null}
    </>
  );
}

export function CloseButton({ id, nextPeriodName, className = 'btn' }: { id: number; nextPeriodName: string; className?: string }) {
  const [open, setOpen] = useState(false);
  return (
    <>
      <button type="button" className={className} onClick={() => setOpen(true)}>Close period</button>
      {open ? (
        <FormModal
          title="Close payroll period" wide
          onClose={() => setOpen(false)}
          onSubmit={(values) => closePayrollPeriodRequest(id, values)}
          submitLabel="Close &amp; post"
          successTitle="Period closed"
          successDetail={(d) => `Journal ${d.journalNo} posted`}
        >
          <div className="note" style={{ marginBottom: 10 }}>
            Posts one balanced journal for the whole period and opens the next one. This cannot be undone from here.
          </div>
          <Field name="periodName" label="Next period name" required defaultValue={nextPeriodName} />
          <div className="grid g2">
            <Field name="startDate" label="Next period start date" type="date" required />
            <Field name="endDate" label="Next period end date" type="date" required />
          </div>
        </FormModal>
      ) : null}
    </>
  );
}
