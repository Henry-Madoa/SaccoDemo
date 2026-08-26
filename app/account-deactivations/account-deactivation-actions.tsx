'use client';

import { useEffect, useState } from 'react';
import { useRouter } from 'next/navigation';
import { FormModal } from '@/components/ui/form-modal';
import { Field } from '@/components/ui/field';
import { MemberSelect } from '@/components/ui/member-select';
import { SearchableSelect } from '@/components/ui/searchable-select';
import { useResultDialog } from '@/components/ui/result-dialog';
import { useConfirm } from '@/components/ui/confirm-dialog';
import { useRunAction } from '@/components/ui/run-action';
import {
  requestAccountDeactivation, saveAccountDeactivationRequest, submitAccountDeactivation,
  cancelAccountDeactivationApprovalRequest, approveAccountDeactivation, rejectAccountDeactivation,
  processAccountDeactivation, eligibleAccountsForDeactivation,
} from '@/app/actions/accountDeactivation';
import { delegateMyTask } from '@/app/actions/workflows';
import { Money } from '@/components/ui/money';
import type { AccountDeactivationRequestWithDimensions, Member, SavingsAccountWithProduct } from '@/lib/types';

export function SubmitButton({ no, className = 'btn sm ghost' }: { no: string; className?: string }) {
  const { run, busy } = useRunAction();
  return (
    <button type="button" className={className} disabled={busy}
      onClick={() => run(() => submitAccountDeactivation(no), {
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
      onClick={() => run(() => cancelAccountDeactivationApprovalRequest(no), {
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
      onClick={() => run(() => approveAccountDeactivation(no), {
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
          title="Reject account deactivation request"
          onClose={() => setOpen(false)}
          onSubmit={(values) => rejectAccountDeactivation(no, String(values.reason || ''))}
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
      title: 'Deactivate this account?',
      message: 'The account will stop accepting deposits and withdrawals immediately. This cannot be undone from here.',
      confirmLabel: 'Deactivate account',
      danger: true,
    });
    if (!ok) return;
    setBusy(true);
    try {
      const res = await processAccountDeactivation(no);
      if (!res.ok) { showResult('Could not deactivate the account', res.error, 'err'); return; }
      showResult('Account deactivated', undefined, 'ok');
      router.push(`/savings/${res.data.accountId}`);
    } finally {
      setBusy(false);
    }
  };

  return (
    <button type="button" className={className} disabled={busy} onClick={process}>
      {busy ? 'Working…' : 'Deactivate account'}
    </button>
  );
}

/** Lets an Open request's Member, Account and Reason all be changed before it's sent for
 *  approval — the account is the request's real anchor (member is only ever derived from
 *  whichever account is chosen), so changing the member re-fetches that member's own eligible
 *  ACTIVE (non-default) accounts exactly as the New Request form does. */
export function EditButton({ request, members, className = 'btn sm ghost' }: {
  request: AccountDeactivationRequestWithDimensions;
  members: Pick<Member, 'id' | 'member_no' | 'first_name' | 'last_name'>[];
  className?: string;
}) {
  const [open, setOpen] = useState(false);
  const [memberId, setMemberId] = useState(String(request.member_id));
  const [accounts, setAccounts] = useState<SavingsAccountWithProduct[]>([]);
  const [accountId, setAccountId] = useState(String(request.account_id));

  // Re-fetches whenever the member changes (including the initial fetch for the request's own
  // member) — excludeRequestNo keeps the account already attached to this request in the list,
  // which the generic "not already in flight" filter would otherwise hide from itself.
  useEffect(() => {
    if (!open) return;
    let cancelled = false;
    if (!memberId) { setAccounts([]); return; }
    eligibleAccountsForDeactivation(Number(memberId), request.no).then((res) => {
      if (cancelled) return;
      const list = res.ok ? res.data : [];
      setAccounts(list);
      if (!list.some((a) => String(a.id) === accountId)) setAccountId('');
    });
    return () => { cancelled = true; };
    // Only memberId should re-trigger this — accountId is read, not depended on.
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [open, memberId, request.no]);

  const account = accounts.find((a) => String(a.id) === accountId);

  return (
    <>
      <button type="button" className={className} onClick={() => setOpen(true)}>Edit</button>
      {open ? (
        <FormModal
          title={`Edit ${request.no}`}
          onClose={() => setOpen(false)}
          onSubmit={(values) => saveAccountDeactivationRequest(request.no, values)}
          submitLabel="Save changes"
          successTitle="Request updated"
        >
          <MemberSelect id="f_memberId" name="memberId" members={members} value={memberId}
            onChange={setMemberId} required />

          <SearchableSelect id="f_accountId" name="accountId" label="Account" required
            items={accounts} getValue={(a) => String(a.id)} getLabel={(a) => `${a.account_no} — ${a.product_name}`}
            value={accountId} onChange={setAccountId}
            placeholder={accounts.length ? 'Search account…' : 'No eligible accounts for this member'}
            emptyText="No matching accounts" />

          <Field name="reason" label="Reason" type="textarea" required defaultValue={request.reason ?? ''} />

          {account ? (
            <div className="note">
              Current balance <Money cents={account.balance} /> — deactivating flips the account to
              INACTIVE once processed, and it will no longer accept deposits or withdrawals.
            </div>
          ) : null}
        </FormModal>
      ) : null}
    </>
  );
}

interface NewRequestFormProps {
  members: Pick<Member, 'id' | 'member_no' | 'first_name' | 'last_name'>[];
  presetMemberId?: number | null;
  onClose: () => void;
}

function NewRequestForm({ members, presetMemberId, onClose }: NewRequestFormProps) {
  const [memberId, setMemberId] = useState(String(presetMemberId ?? ''));
  const [accounts, setAccounts] = useState<SavingsAccountWithProduct[]>([]);
  const [accountId, setAccountId] = useState('');

  // The eligible account list depends on the member (excludes their category's default
  // accounts and anything already mid-deactivation), so it's fetched per-member.
  useEffect(() => {
    let cancelled = false;
    if (!memberId) { setAccounts([]); return; }
    eligibleAccountsForDeactivation(Number(memberId)).then((res) => {
      if (cancelled) return;
      setAccounts(res.ok ? res.data : []);
    });
    return () => { cancelled = true; };
  }, [memberId]);

  const account = accounts.find((a) => String(a.id) === accountId);

  return (
    <FormModal
      title="New account deactivation request"
      onClose={onClose}
      onSubmit={requestAccountDeactivation}
      submitLabel="Save request"
      successTitle="Request captured"
      successDetail={(d) => `${d.no} saved — send it for approval when you're ready`}
    >
      <MemberSelect id="f_memberId" name="memberId" members={members} value={memberId}
        onChange={(id) => { setMemberId(id); setAccountId(''); }} required />

      <SearchableSelect id="f_accountId" name="accountId" label="Account" required
        items={accounts} getValue={(a) => String(a.id)} getLabel={(a) => `${a.account_no} — ${a.product_name}`}
        value={accountId} onChange={setAccountId}
        placeholder={accounts.length ? 'Search account…' : 'No eligible accounts for this member'}
        emptyText="No matching accounts" />

      <Field name="reason" label="Reason" type="textarea" required />

      {account ? (
        <div className="note">
          Current balance <Money cents={account.balance} /> — deactivating flips the account to
          INACTIVE once processed, and it will no longer accept deposits or withdrawals.
        </div>
      ) : null}
    </FormModal>
  );
}

/** Opens the New Request form, optionally preset from `?new=<memberId>` (same pattern as
 *  Account Opening's NewAccountOpeningButton). */
export function NewAccountDeactivationButton({ members, presetMemberId }: {
  members: NewRequestFormProps['members'];
  presetMemberId?: number | null;
}) {
  const router = useRouter();
  const [open, setOpen] = useState(Boolean(presetMemberId));

  const close = () => {
    setOpen(false);
    // Drop ?new= so a refresh does not reopen the modal.
    if (presetMemberId) router.replace('/account-deactivations');
  };

  return (
    <>
      <button type="button" className="btn" onClick={() => setOpen(true)}>New deactivation request</button>
      {open ? <NewRequestForm members={members} presetMemberId={presetMemberId} onClose={close} /> : null}
    </>
  );
}
