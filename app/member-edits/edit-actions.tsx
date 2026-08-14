'use client';

import { useState } from 'react';
import { useRouter } from 'next/navigation';
import { FormModal } from '@/components/ui/form-modal';
import { Field } from '@/components/ui/field';
import { useToast } from '@/components/ui/toast';
import {
  requestMemberEdit, submitMemberEdit, cancelMemberEditApproval, approveMemberEditRequest,
  rejectMemberEditRequest, processMemberEditRequest,
} from '@/app/actions/memberEdits';
import { delegateMyTask } from '@/app/actions/workflows';
import type { Member } from '@/lib/types';

/** Shared shape for the simple one-click workflow actions. */
function useRunAction() {
  const toast = useToast();
  const router = useRouter();
  const [busy, setBusy] = useState(false);

  const run = async (fn: () => Promise<{ ok: boolean; error?: string }>, successTitle: string) => {
    setBusy(true);
    try {
      const res = await fn();
      if (!res.ok) toast('Could not complete', res.error, 'err');
      else {
        toast(successTitle, undefined, 'ok');
        router.refresh();
      }
    } finally {
      setBusy(false);
    }
  };

  return { run, busy };
}

export function SubmitButton({ no, className = 'btn sm ghost' }: { no: string; className?: string }) {
  const { run, busy } = useRunAction();
  return (
    <button type="button" className={className} disabled={busy}
      onClick={() => run(() => submitMemberEdit(no), 'Sent for approval')}>
      {busy ? 'Working…' : 'Send for approval'}
    </button>
  );
}

/** Pulls a submission back to Open — only valid before any approver has acted on it. */
export function CancelApprovalButton({ no, className = 'btn sm ghost' }: { no: string; className?: string }) {
  const { run, busy } = useRunAction();
  return (
    <button type="button" className={className} disabled={busy}
      onClick={() => run(() => cancelMemberEditApproval(no), 'Approval request cancelled — back to Open')}>
      {busy ? 'Working…' : 'Cancel approval request'}
    </button>
  );
}

/** Hands the pending task off to my configured substitute. */
export function DelegateButton({ taskId, className = 'btn sm ghost' }: { taskId: number; className?: string }) {
  const { run, busy } = useRunAction();
  return (
    <button type="button" className={className} disabled={busy}
      onClick={() => run(() => delegateMyTask(taskId), 'Delegated to your substitute')}>
      {busy ? 'Working…' : 'Delegate'}
    </button>
  );
}

export function ApproveButton({ no, className = 'btn sm' }: { no: string; className?: string }) {
  const { run, busy } = useRunAction();
  return (
    <button type="button" className={className} disabled={busy}
      onClick={() => run(() => approveMemberEditRequest(no), 'Edit request approved')}>
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
          successTitle="Edit request rejected"
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
  const toast = useToast();
  const router = useRouter();
  const [busy, setBusy] = useState(false);

  const process = async () => {
    setBusy(true);
    try {
      const res = await processMemberEditRequest(no);
      if (!res.ok) { toast('Could not apply changes', res.error, 'err'); return; }
      toast('Changes applied to the member', undefined, 'ok');
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
