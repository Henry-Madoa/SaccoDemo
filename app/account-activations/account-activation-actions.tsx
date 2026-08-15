'use client';

import { useEffect, useState } from 'react';
import { useRouter } from 'next/navigation';
import { FormModal } from '@/components/ui/form-modal';
import { Field } from '@/components/ui/field';
import { useResultDialog } from '@/components/ui/result-dialog';
import { useConfirm } from '@/components/ui/confirm-dialog';
import { useRunAction } from '@/components/ui/run-action';
import {
  requestAccountActivation, submitAccountActivation,
  cancelAccountActivationApprovalRequest, approveAccountActivation, rejectAccountActivation,
  processAccountActivation, eligibleAccountsForActivation,
} from '@/app/actions/accountActivation';
import { delegateMyTask } from '@/app/actions/workflows';
import { Money } from '@/components/ui/money';
import type { Member, SavingsAccountWithProduct } from '@/lib/types';

export function SubmitButton({ no, className = 'btn sm ghost' }: { no: string; className?: string }) {
  const { run, busy } = useRunAction();
  return (
    <button type="button" className={className} disabled={busy}
      onClick={() => run(() => submitAccountActivation(no), {
        confirm: {
          title: 'Send this request for approval?',
          message: 'It will be routed to the configured approver(s) and can no longer be edited while pending.',
          confirmLabel: 'Send for approval',
        },
        successTitle: (d) => (d.autoApproved ? 'Request approved' : 'Sent for approval'),
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
      onClick={() => run(() => cancelAccountActivationApprovalRequest(no), {
        confirm: {
          title: 'Cancel this approval request?',
          message: 'The request goes back to Open so you can amend and resubmit it.',
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
      onClick={() => run(() => approveAccountActivation(no), {
        confirm: { title: 'Approve this request?', confirmLabel: 'Approve' },
        successTitle: 'Request approved',
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
          title="Reject account activation request"
          onClose={() => setOpen(false)}
          onSubmit={(values) => rejectAccountActivation(no, String(values.reason || ''))}
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
      title: 'Activate this account?',
      message: 'The account will accept deposits and withdrawals again immediately.',
      confirmLabel: 'Activate account',
    });
    if (!ok) return;
    setBusy(true);
    try {
      const res = await processAccountActivation(no);
      if (!res.ok) { showResult('Could not activate the account', res.error, 'err'); return; }
      showResult('Account activated', undefined, 'ok');
      router.push(`/savings/${res.data.accountId}`);
    } finally {
      setBusy(false);
    }
  };

  return (
    <button type="button" className={className} disabled={busy} onClick={process}>
      {busy ? 'Working…' : 'Activate account'}
    </button>
  );
}

interface NewRequestFormProps {
  members: Pick<Member, 'id' | 'member_no' | 'first_name' | 'last_name'>[];
  presetMemberId?: number | null;
  onClose: () => void;
}

function NewRequestForm({ members, presetMemberId, onClose }: NewRequestFormProps) {
  const [memberId, setMemberId] = useState(String(presetMemberId ?? members[0]?.id ?? ''));
  const [accounts, setAccounts] = useState<SavingsAccountWithProduct[]>([]);
  const [accountId, setAccountId] = useState('');

  // The eligible account list depends on the member (only their INACTIVE accounts, minus
  // anything already mid-activation), so it's fetched per-member.
  useEffect(() => {
    let cancelled = false;
    if (!memberId) { setAccounts([]); return; }
    eligibleAccountsForActivation(Number(memberId)).then((res) => {
      if (cancelled) return;
      const list = res.ok ? res.data : [];
      setAccounts(list);
      setAccountId(String(list[0]?.id ?? ''));
    });
    return () => { cancelled = true; };
  }, [memberId]);

  const account = accounts.find((a) => String(a.id) === accountId);

  return (
    <FormModal
      title="New account activation request"
      onClose={onClose}
      onSubmit={requestAccountActivation}
      submitLabel="Save request"
      successTitle="Request captured"
      successDetail={(d) => `${d.no} saved — send it for approval when you're ready`}
    >
      <div className="field">
        <label htmlFor="f_memberId">Member <span className="req">*</span></label>
        <select id="f_memberId" name="memberId" required value={memberId}
          onChange={(e) => setMemberId(e.target.value)}>
          {members.map((m) => (
            <option key={m.id} value={m.id}>{m.member_no} — {m.first_name} {m.last_name}</option>
          ))}
        </select>
      </div>

      <div className="field">
        <label htmlFor="f_accountId">Account <span className="req">*</span></label>
        <select id="f_accountId" name="accountId" required value={accountId}
          onChange={(e) => setAccountId(e.target.value)}>
          {accounts.length ? null : <option value="">No inactive accounts for this member</option>}
          {accounts.map((a) => (
            <option key={a.id} value={a.id}>{a.account_no} — {a.product_name}</option>
          ))}
        </select>
      </div>

      <Field name="reason" label="Reason" type="textarea" required />

      {account ? (
        <div className="note">
          Current balance <Money cents={account.balance} /> — activating flips the account back
          to ACTIVE once processed, and it will accept deposits and withdrawals again.
        </div>
      ) : null}
    </FormModal>
  );
}

/** Opens the New Request form, optionally preset from `?new=<memberId>` (same pattern as
 *  Account Deactivation's NewAccountDeactivationButton). */
export function NewAccountActivationButton({ members, presetMemberId }: {
  members: NewRequestFormProps['members'];
  presetMemberId?: number | null;
}) {
  const router = useRouter();
  const [open, setOpen] = useState(Boolean(presetMemberId));

  const close = () => {
    setOpen(false);
    // Drop ?new= so a refresh does not reopen the modal.
    if (presetMemberId) router.replace('/account-activations');
  };

  return (
    <>
      <button type="button" className="btn" onClick={() => setOpen(true)}>New activation request</button>
      {open ? <NewRequestForm members={members} presetMemberId={presetMemberId} onClose={close} /> : null}
    </>
  );
}
