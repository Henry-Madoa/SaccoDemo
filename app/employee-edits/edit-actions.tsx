'use client';

import { useState } from 'react';
import { useRouter } from 'next/navigation';
import { FormModal } from '@/components/ui/form-modal';
import { Field } from '@/components/ui/field';
import { SearchableSelect } from '@/components/ui/searchable-select';
import { useRunAction } from '@/components/ui/run-action';
import {
  createEmployeeEditRequestAction, submitEmployeeEditRequestAction,
  cancelEmployeeEditApprovalAction, approveEmployeeEditAction, rejectEmployeeEditAction, processEmployeeEditAction,
} from '@/app/actions/employeeEdits';
import { delegateMyTask } from '@/app/actions/workflows';
import type { County, SubCounty, DimensionValue, EmployeeView, HrJobGrade } from '@/lib/types';

export interface EditLookups {
  globalDimension1Values: DimensionValue[]; globalDimension2Values: DimensionValue[];
  caption1: string; caption2: string;
  jobGrades: HrJobGrade[]; counties: County[]; subCounties: SubCounty[];
}

type EmployeeLite = Pick<EmployeeView, 'id' | 'employee_no' | 'first_name' | 'last_name'>;

/** Starts a new edit request by snapshotting an active employee's current values. */
export function NewEditRequestButton({ employees }: { employees: EmployeeLite[] }) {
  const router = useRouter();
  const [open, setOpen] = useState(false);
  const [employeeId, setEmployeeId] = useState('');
  return (
    <>
      <button type="button" className="btn" onClick={() => setOpen(true)}>New edit request</button>
      {open ? (
        <FormModal
          title="New employee edit request"
          onClose={() => setOpen(false)}
          onSubmit={async () => {
            const res = await createEmployeeEditRequestAction(Number(employeeId));
            if (res.ok) router.push(`/employee-edits/view/${res.data.no}?edit=1`);
            return res;
          }}
          submitLabel="Start request"
          successTitle="Edit request created"
          successDetail={(d) => `${d.no} is open for editing`}
        >
          <SearchableSelect id="f_employeeId" name="employeeId" label="Employee"
            items={employees} getValue={(e) => String(e.id)} getLabel={(e) => `${e.employee_no} — ${e.first_name} ${e.last_name}`}
            value={employeeId} onChange={setEmployeeId} required placeholder="Search employee…" />
        </FormModal>
      ) : null}
    </>
  );
}

export function SubmitEditButton({ no, className = 'btn sm ghost' }: { no: string; className?: string }) {
  const { run, busy } = useRunAction();
  return (
    <button type="button" className={className} disabled={busy}
      onClick={() => run(() => submitEmployeeEditRequestAction(no), {
        confirm: { title: 'Send this edit request for approval?', confirmLabel: 'Send for approval' },
        successTitle: (d) => (d.autoApproved ? 'Approved — ready to apply' : 'Sent for approval'),
      })}>
      {busy ? 'Working…' : 'Send for approval'}
    </button>
  );
}

export function CancelEditApprovalButton({ no, className = 'btn sm ghost' }: { no: string; className?: string }) {
  const { run, busy } = useRunAction();
  return (
    <button type="button" className={className} disabled={busy}
      onClick={() => run(() => cancelEmployeeEditApprovalAction(no), {
        confirm: { title: 'Recall this request?', message: 'It goes back to Open so you can amend and resubmit it.', confirmLabel: 'Recall' },
        successTitle: 'Recalled — back to Open',
      })}>
      {busy ? 'Working…' : 'Cancel approval request'}
    </button>
  );
}

export function DelegateEditButton({ taskId, className = 'btn sm ghost' }: { taskId: number; className?: string }) {
  const { run, busy } = useRunAction();
  return (
    <button type="button" className={className} disabled={busy}
      onClick={() => run(() => delegateMyTask(taskId), {
        confirm: { title: 'Delegate to your substitute?', confirmLabel: 'Delegate' },
        successTitle: 'Delegated to your substitute',
      })}>
      {busy ? 'Working…' : 'Delegate'}
    </button>
  );
}

export function ApproveEditButton({ no, className = 'btn sm' }: { no: string; className?: string }) {
  const { run, busy } = useRunAction();
  return (
    <button type="button" className={className} disabled={busy}
      onClick={() => run(() => approveEmployeeEditAction(no), {
        confirm: { title: 'Approve this edit request?', message: 'Nothing changes on the employee until you Apply it.', confirmLabel: 'Approve' },
        successTitle: 'Approved — ready to apply',
      })}>
      {busy ? 'Working…' : 'Approve'}
    </button>
  );
}

export function RejectEditButton({ no, className = 'btn sm ghost' }: { no: string; className?: string }) {
  const [open, setOpen] = useState(false);
  return (
    <>
      <button type="button" className={className} onClick={() => setOpen(true)}>Reject</button>
      {open ? (
        <FormModal
          title="Reject edit request"
          onClose={() => setOpen(false)}
          onSubmit={(values) => rejectEmployeeEditAction(no, String(values.reason || ''))}
          submitLabel="Reject" submitClass="btn danger"
          successTitle="Rejected — back to Open" resultStyle="popup"
        >
          <Field name="reason" label="Reason" type="textarea" required />
        </FormModal>
      ) : null}
    </>
  );
}

export function ApplyEditButton({ no, className = 'btn sm' }: { no: string; className?: string }) {
  const { run, busy } = useRunAction();
  return (
    <button type="button" className={className} disabled={busy}
      onClick={() => run(() => processEmployeeEditAction(no), {
        confirm: { title: 'Apply this edit to the employee?', message: 'The employee record and every sub-entity list are updated immediately.', confirmLabel: 'Apply' },
        successTitle: 'Applied to the employee',
      })}>
      {busy ? 'Working…' : 'Apply to employee'}
    </button>
  );
}
