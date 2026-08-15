'use client';

import { useState } from 'react';
import { useRouter } from 'next/navigation';
import { FormModal } from '@/components/ui/form-modal';
import { Field } from '@/components/ui/field';
import { useResultDialog } from '@/components/ui/result-dialog';
import { useConfirm } from '@/components/ui/confirm-dialog';
import { useRunAction } from '@/components/ui/run-action';
import {
  requestMemberEdit, submitMemberEdit, cancelMemberEditApproval, approveMemberEditRequest,
  rejectMemberEditRequest, processMemberEditRequest,
} from '@/app/actions/memberEdits';
import { delegateMyTask } from '@/app/actions/workflows';
import type { Member } from '@/lib/types';

export function SubmitButton({ no, className = 'btn sm ghost' }: { no: string; className?: string }) {
  const { run, busy } = useRunAction();
  return (
    <button type="button" className={className} disabled={busy}
      onClick={() => run(() => submitMemberEdit(no), {
        confirm: {
          title: 'Send this edit request for approval?',
          message: 'It will be routed to the configured approver(s) and can no longer be edited while pending.',
          confirmLabel: 'Send for approval',
        },
        successTitle: (d) => (d.autoApproved ? 'Edit request approved' : 'Sent for approval'),
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
      onClick={() => run(() => cancelMemberEditApproval(no), {
        confirm: {
          title: 'Cancel this approval request?',
          message: 'The edit request goes back to Open so you can amend and resubmit it.',
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
      onClick={() => run(() => approveMemberEditRequest(no), {
        confirm: { title: 'Approve this edit request?', confirmLabel: 'Approve' },
        successTitle: 'Edit request approved',
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
          title="Reject edit request"
          onClose={() => setOpen(false)}
          onSubmit={(values) => rejectMemberEditRequest(no, String(values.reason || ''))}
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

/** Starts a new edit request by snapshotting an existing member's current values. */
export function NewEditRequestButton({ members }: {
  members: Pick<Member, 'id' | 'member_no' | 'first_name' | 'last_name'>[];
}) {
  const router = useRouter();
  const [open, setOpen] = useState(false);
  return (
    <>
      <button type="button" className="btn" onClick={() => setOpen(true)}>New edit request</button>
      {open ? (
        <FormModal
          title="New member edit request"
          onClose={() => setOpen(false)}
          onSubmit={async (values) => {
            const res = await requestMemberEdit(Number(values.memberId));
            if (res.ok) router.push(`/member-edits/view/${res.data.no}?edit=1`);
            return res;
          }}
          submitLabel="Start request"
          successTitle="Edit request created"
          successDetail={(d) => `${d.no} is open for editing`}
        >
          <Field name="memberId" label="Member" type="select" required
            options={members.map((m) => ({ value: m.id, label: `${m.member_no} — ${m.first_name} ${m.last_name}` }))} />
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
      title: 'Apply these changes?',
      message: 'The approved edits will be written onto the live member record. This cannot be undone from here.',
      confirmLabel: 'Apply changes',
    });
    if (!ok) return;
    setBusy(true);
    try {
      const res = await processMemberEditRequest(no);
      if (!res.ok) { showResult('Could not apply changes', res.error, 'err'); return; }
      showResult('Changes applied to the member', undefined, 'ok');
      router.push(`/members/${res.data.memberId}`);
    } finally {
      setBusy(false);
    }
  };

  return (
    <button type="button" className={className} disabled={busy} onClick={process}>
      {busy ? 'Working…' : 'Apply changes'}
    </button>
  );
}
