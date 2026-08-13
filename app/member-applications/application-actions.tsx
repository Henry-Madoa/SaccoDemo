'use client';

import { useState } from 'react';
import { useRouter } from 'next/navigation';
import { FormModal } from '@/components/ui/form-modal';
import { Field } from '@/components/ui/field';
import { useToast } from '@/components/ui/toast';
import {
  submitApplication, cancelApprovalRequest, approveApplication, rejectApplication, processApplication,
} from '@/app/actions/memberApplications';

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
      onClick={() => run(() => submitApplication(no), 'Sent for approval')}>
      {busy ? 'Working…' : 'Send for approval'}
    </button>
  );
}

/** Pulls a submission back to Open — only valid before any approver has acted on it. */
export function CancelApprovalButton({ no, className = 'btn sm ghost' }: { no: string; className?: string }) {
  const { run, busy } = useRunAction();
  return (
    <button type="button" className={className} disabled={busy}
      onClick={() => run(() => cancelApprovalRequest(no), 'Approval request cancelled — back to Open')}>
      {busy ? 'Working…' : 'Cancel approval request'}
    </button>
  );
}

export function ApproveButton({ no, className = 'btn sm' }: { no: string; className?: string }) {
  const { run, busy } = useRunAction();
  return (
    <button type="button" className={className} disabled={busy}
      onClick={() => run(() => approveApplication(no), 'Application approved')}>
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
          successTitle="Application rejected"
        >
          <Field name="reason" label="Reason" type="textarea" required />
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
      const res = await processApplication(no);
      if (!res.ok) { toast('Could not create member', res.error, 'err'); return; }
      toast('Member created', undefined, 'ok');
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
