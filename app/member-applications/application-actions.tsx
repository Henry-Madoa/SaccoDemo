'use client';

import { useState } from 'react';
import { useRouter } from 'next/navigation';
import { FormModal } from '@/components/ui/form-modal';
import { Field } from '@/components/ui/field';
import { useResultDialog } from '@/components/ui/result-dialog';
import { useConfirm } from '@/components/ui/confirm-dialog';
import { useRunAction } from '@/components/ui/run-action';
import {
  submitApplication, cancelApprovalRequest, approveApplication, rejectApplication, processApplication,
} from '@/app/actions/memberApplications';
import { delegateMyTask } from '@/app/actions/workflows';

export function SubmitButton({ no, className = 'btn sm ghost' }: { no: string; className?: string }) {
  const { run, busy } = useRunAction();
  return (
    <button type="button" className={className} disabled={busy}
      onClick={() => run(() => submitApplication(no), {
        confirm: {
          title: 'Send this application for approval?',
          message: 'It will be routed to the configured approver(s) and can no longer be edited while pending.',
          confirmLabel: 'Send for approval',
        },
        successTitle: (d) => (d.autoApproved ? 'Application approved' : 'Sent for approval'),
        successDetail: (d) => (d.autoApproved
          ? 'You are the assigned approver, so this was approved automatically.' : undefined),
      })}>
      {busy ? 'Working…' : 'Send for approval'}
    </button>
  );
}

/** Pulls a submission back to Open — only valid before any approver has acted on it. */
export function CancelApprovalButton({ no, className = 'btn sm ghost' }: { no: string; className?: string }) {
  const { run, busy } = useRunAction();
  return (
    <button type="button" className={className} disabled={busy}
      onClick={() => run(() => cancelApprovalRequest(no), {
        confirm: {
          title: 'Cancel this approval request?',
          message: 'The application goes back to Open so you can amend and resubmit it.',
          confirmLabel: 'Cancel approval request',
        },
        successTitle: 'Approval request cancelled — back to Open',
      })}>
      {busy ? 'Working…' : 'Cancel approval request'}
    </button>
  );
}

/** Hands the pending task off to my configured substitute. */
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
      onClick={() => run(() => approveApplication(no), {
        confirm: { title: 'Approve this application?', confirmLabel: 'Approve' },
        successTitle: 'Application approved',
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
          title="Reject application"
          onClose={() => setOpen(false)}
          onSubmit={(values) => rejectApplication(no, String(values.reason || ''))}
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
  const showResult = useResultDialog();
  const confirm = useConfirm();
  const router = useRouter();
  const [busy, setBusy] = useState(false);

  const process = async () => {
    const ok = await confirm({
      title: 'Create this member?',
      message: 'This registers a real member record from the approved application. This cannot be undone from here.',
      confirmLabel: 'Create member',
    });
    if (!ok) return;
    setBusy(true);
    try {
      const res = await processApplication(no);
      if (!res.ok) { showResult('Could not create member', res.error, 'err'); return; }
      showResult('Member created', undefined, 'ok');
      router.push(`/members/${res.data.memberId}`);
    } finally {
      setBusy(false);
    }
  };

  return (
    <button type="button" className={className} disabled={busy} onClick={process}>
      {busy ? 'Working…' : 'Create member'}
    </button>
  );
}
