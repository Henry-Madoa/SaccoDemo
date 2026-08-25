'use client';

import { useState } from 'react';
import { useRouter } from 'next/navigation';
import { FormModal } from '@/components/ui/form-modal';
import { Field } from '@/components/ui/field';
import { useResultDialog } from '@/components/ui/result-dialog';
import { useRunAction } from '@/components/ui/run-action';
import { useFormat } from '@/components/ui/format-provider';
import {
  requestCheckoffBatch, refreshCheckoffBatchLinesRequest, recordRemittedAmountRequest,
  submitCheckoffBatchRequest, cancelCheckoffBatchApprovalRequest, approveCheckoffBatchRequest,
  rejectCheckoffBatchRequest, processCheckoffBatchRequest,
} from '@/app/actions/checkoffBatches';
import { delegateMyTask } from '@/app/actions/workflows';
import { BATCH_TYPES } from '@/lib/constants';
import { toUnits } from '@/lib/format';
import type { CheckoffBatchLineWithDetails, Employer } from '@/lib/types';

export function SubmitButton({ no, className = 'btn sm ghost' }: { no: string; className?: string }) {
  const { run, busy } = useRunAction();
  return (
    <button type="button" className={className} disabled={busy}
      onClick={() => run(() => submitCheckoffBatchRequest(no), {
        confirm: {
          title: 'Send this batch for approval?',
          message: 'It will be routed to the configured approver(s) and can no longer be edited while pending.',
          confirmLabel: 'Send for approval',
        },
        successTitle: (d) => (d.autoApproved ? 'Approved' : 'Sent for approval'),
        successDetail: (d) => (d.autoApproved
          ? 'You are the assigned approver, so this was approved automatically.' : undefined),
      })}>
      {busy ? 'Working…' : 'Send for approval'}
    </button>
  );
}

export function CancelApprovalButton({ no, className = 'btn sm ghost' }: { no: string; className?: string }) {
  const { run, busy } = useRunAction();
  return (
    <button type="button" className={className} disabled={busy}
      onClick={() => run(() => cancelCheckoffBatchApprovalRequest(no), {
        confirm: {
          title: 'Cancel this approval request?',
          message: 'The batch goes back to Open so you can amend and resubmit it.',
          confirmLabel: 'Cancel approval request',
        },
        successTitle: 'Approval request cancelled — back to Open',
      })}>
      {busy ? 'Working…' : 'Cancel approval request'}
    </button>
  );
}

export function DelegateButton({ taskId, className = 'btn sm ghost' }: { taskId: number; className?: string }) {
  const { run, busy } = useRunAction();
  return (
    <button type="button" className={className} disabled={busy}
      onClick={() => run(() => delegateMyTask(taskId), {
        confirm: {
          title: 'Delegate to your substitute?',
          message: 'Your configured substitute will be asked to decide this instead of you.',
          confirmLabel: 'Delegate',
        },
        successTitle: 'Delegated to your substitute',
      })}>
      {busy ? 'Working…' : 'Delegate'}
    </button>
  );
}

export function ApproveButton({ no, className = 'btn sm' }: { no: string; className?: string }) {
  const { run, busy } = useRunAction();
  return (
    <button type="button" className={className} disabled={busy}
      onClick={() => run(() => approveCheckoffBatchRequest(no), {
        confirm: { title: 'Approve this batch?', confirmLabel: 'Approve' },
        successTitle: 'Batch approved',
      })}>
      {busy ? 'Working…' : 'Approve'}
    </button>
  );
}

export function RejectButton({ no, className = 'btn sm ghost' }: { no: string; className?: string }) {
  const [open, setOpen] = useState(false);
  return (
    <>
      <button type="button" className={className} onClick={() => setOpen(true)}>Reject</button>
      {open ? (
        <FormModal
          title="Reject batch"
          onClose={() => setOpen(false)}
          onSubmit={(values) => rejectCheckoffBatchRequest(no, String(values.reason || ''))}
          submitLabel="Reject"
          submitClass="btn danger"
          successTitle="Rejected — back to Open for changes"
          resultStyle="popup"
        >
          <Field name="reason" label="Reason" type="textarea" required />
        </FormModal>
      ) : null}
    </>
  );
}

export function ProcessButton({ no, className = 'btn sm' }: { no: string; className?: string }) {
  const { run, busy } = useRunAction();
  return (
    <button type="button" className={className} disabled={busy}
      onClick={() => run(() => processCheckoffBatchRequest(no), {
        confirm: {
          title: 'Process this batch?',
          message: 'Loan recoveries are posted (CHECKOFF) or salaries credited (SALARY) for every line with a remitted amount. This cannot be undone from here.',
          confirmLabel: 'Process',
        },
        successTitle: 'Batch processed',
      })}>
      {busy ? 'Working…' : 'Process'}
    </button>
  );
}

export function RefreshLinesButton({ no, className = 'btn sm ghost' }: { no: string; className?: string }) {
  const { run, busy } = useRunAction();
  return (
    <button type="button" className={className} disabled={busy}
      onClick={() => run(() => refreshCheckoffBatchLinesRequest(no), {
        confirm: {
          title: 'Refresh lines from current member data?',
          message: 'Re-syncs the member list and expected amounts. Any remitted amounts already recorded are cleared.',
          confirmLabel: 'Refresh lines',
        },
        successTitle: 'Lines refreshed',
      })}>
      {busy ? 'Working…' : 'Refresh lines'}
    </button>
  );
}

/** The reconciliation input: what was actually remitted for one member, with a live variance
 *  preview against the computed expected amount as it's typed. */
export function RemittedAmountField({ no, line, isCheckoff }: {
  no: string; line: CheckoffBatchLineWithDetails; isCheckoff: boolean;
}) {
  const router = useRouter();
  const showResult = useResultDialog();
  const { cur } = useFormat();
  const [value, setValue] = useState(line.remitted_amount ? toUnits(line.remitted_amount) : '');
  const [busy, setBusy] = useState(false);

  const save = async () => {
    setBusy(true);
    try {
      const res = await recordRemittedAmountRequest(no, line.id, value);
      if (!res.ok) { showResult('Could not save', res.error, 'err'); return; }
      router.refresh();
    } finally {
      setBusy(false);
    }
  };

  const previewVariance = isCheckoff && value !== ''
    ? Math.round(Number(value) * 100) - line.expected_amount
    : null;

  return (
    <div className="inline" style={{ gap: 6 }}>
      <input type="number" step="0.01" min={0} style={{ width: 130, textAlign: 'right' }}
        aria-label={`Remitted amount for ${line.member_first_name} ${line.member_last_name}`}
        value={value} disabled={busy} onChange={(e) => setValue(e.target.value)} onBlur={save} />
      {previewVariance != null && previewVariance !== 0 ? (
        <span className={previewVariance < 0 ? 'neg' : 'tiny'}>
          {previewVariance > 0 ? '+' : ''}{cur(previewVariance)}
        </span>
      ) : null}
    </div>
  );
}

function NewBatchForm({ employers, onClose }: { employers: Employer[]; onClose: () => void }) {
  return (
    <FormModal
      title="New checkoff/salary batch"
      onClose={onClose}
      onSubmit={(values) => {
        const period = String(values.period || '');
        return requestCheckoffBatch(Number(values.employerId), String(values.batchType), period ? `${period}-01` : '');
      }}
      submitLabel="Open batch"
      successTitle="Batch opened"
      successDetail={(d) => `${d.no} saved — record what each member remitted, then send it for approval`}
    >
      <div className="field">
        <label htmlFor="f_employerId">Employer <span className="req">*</span></label>
        <select id="f_employerId" name="employerId" required defaultValue={String(employers[0]?.id ?? '')}>
          {employers.map((e) => <option key={e.id} value={e.id}>{e.code} — {e.name}</option>)}
        </select>
      </div>
      <Field name="batchType" label="Batch type" type="select" required options={BATCH_TYPES} defaultValue="CHECKOFF" />
      <div className="field">
        <label htmlFor="f_period">Period <span className="req">*</span></label>
        <input id="f_period" name="period" type="month" required />
      </div>
    </FormModal>
  );
}

export function NewCheckoffBatchButton({ employers }: { employers: Employer[] }) {
  const [open, setOpen] = useState(false);
  return (
    <>
      <button type="button" className="btn" disabled={!employers.length} onClick={() => setOpen(true)}>
        New batch
      </button>
      {open ? <NewBatchForm employers={employers} onClose={() => setOpen(false)} /> : null}
    </>
  );
}
