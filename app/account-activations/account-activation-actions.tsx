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
  requestAccountActivation, saveAccountActivationRequest, submitAccountActivation,
  cancelAccountActivationApprovalRequest, approveAccountActivation, rejectAccountActivation,
  processAccountActivation, eligibleAccountsForActivation, accountsForActivationDebit,
} from '@/app/actions/accountActivation';
import { listAccountActivationChargeCodes, previewTransactionChargeAmount } from '@/app/actions/charges';
import { delegateMyTask } from '@/app/actions/workflows';
import { Money } from '@/components/ui/money';
import { useFormat } from '@/components/ui/format-provider';
import type {
  AccountActivationRequestWithDimensions, Member, SavingsAccountForDebit, SavingsAccountWithProduct,
  TransactionCharge,
} from '@/lib/types';

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

/** `feeAmount` comes straight off the request's own `charge_amount` (see
 *  lib/accountActivation.ts's withChargeAmount()) — the fee this specific request's chosen
 *  Charge Code resolves to right now, not a generic type-wide preview. */
export function ProcessButton({ no, feeAmount = null, className = 'btn sm' }: {
  no: string; feeAmount?: number | null; className?: string;
}) {
  const showResult = useResultDialog();
  const confirm = useConfirm();
  const router = useRouter();
  const { cur } = useFormat();
  const [busy, setBusy] = useState(false);

  const process = async () => {
    const ok = await confirm({
      title: 'Activate this account?',
      message: feeAmount
        ? `A reactivation fee of ${cur(feeAmount)} will be charged. It will accept deposits and withdrawals again immediately.`
        : 'The account will accept deposits and withdrawals again immediately.',
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

/**
 * The Charge Code + Debit Account pair, with a live fee/available-balance preview — shared by
 * the New Request form and the Edit button for an Open request, since both let the same two
 * fields be set and both need the same "would this even be affordable" feedback.
 */
function ChargeDebitFields({ memberId, chargeId, setChargeId, debitAccountId, setDebitAccountId }: {
  memberId: string;
  chargeId: string;
  setChargeId: (v: string) => void;
  debitAccountId: string;
  setDebitAccountId: (v: string) => void;
}) {
  const { cur } = useFormat();
  const [chargeCodes, setChargeCodes] = useState<TransactionCharge[]>([]);
  const [debitAccounts, setDebitAccounts] = useState<SavingsAccountForDebit[]>([]);
  const [feeAmount, setFeeAmount] = useState<number | null>(null);

  // Charge Codes configured for ACCOUNT_ACTIVATION don't depend on the member — fetched once.
  useEffect(() => {
    listAccountActivationChargeCodes().then((res) => {
      if (res.ok) setChargeCodes(res.data);
    });
  }, []);

  // The debit account picklist is every account the member holds, any status.
  useEffect(() => {
    let cancelled = false;
    if (!memberId) { setDebitAccounts([]); return; }
    accountsForActivationDebit(Number(memberId)).then((res) => {
      if (!cancelled && res.ok) setDebitAccounts(res.data);
    });
    return () => { cancelled = true; };
  }, [memberId]);

  // The fee itself only depends on which Charge Code is picked, not on which account pays it.
  useEffect(() => {
    let cancelled = false;
    if (!chargeId) { setFeeAmount(null); return; }
    previewTransactionChargeAmount(Number(chargeId)).then((res) => {
      if (!cancelled && res.ok) setFeeAmount(res.data.reduce((sum, c) => sum + c.amount, 0));
    });
    return () => { cancelled = true; };
  }, [chargeId]);

  const debitAccount = debitAccounts.find((a) => String(a.id) === debitAccountId);
  const available = debitAccount ? debitAccount.balance - debitAccount.hold_amount - debitAccount.min_balance : null;
  const insufficient = !!chargeId && feeAmount != null && available != null && feeAmount > available;

  return (
    <>
      <div className="grid g2" style={{ marginTop: 'calc(var(--sp)*1.5)' }}>
        <SearchableSelect id="f_transactionChargeId" name="transactionChargeId" label="Charge code"
          items={chargeCodes} getValue={(c) => String(c.id)} getLabel={(c) => `${c.code} — ${c.description}`}
          value={chargeId} onChange={setChargeId} placeholder="No charge" emptyText="No matching charges" />
        <SearchableSelect id="f_debitAccountId" name="debitAccountId"
          label="Debit account" required={!!chargeId} disabled={!chargeId}
          items={debitAccounts} getValue={(a) => String(a.id)} getLabel={(a) => `${a.account_no} — ${a.product_name}`}
          value={debitAccountId} onChange={setDebitAccountId}
          placeholder="Search account…" emptyText="No matching accounts" />
      </div>

      {chargeId ? (
        <div className="note" style={{ marginTop: 8 }}>
          Charge amount: <b className={insufficient ? 'neg' : undefined}>{feeAmount != null ? cur(feeAmount) : '…'}</b>
          {debitAccount ? (
            <> · {debitAccount.account_no} available balance: <b>{cur(Math.max(available ?? 0, 0))}</b></>
          ) : null}
          {insufficient ? (
            <div className="neg">
              The charge exceeds the selected account's available balance — pick a different account
              or reduce the charge before this can be sent for approval.
            </div>
          ) : null}
        </div>
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
  const [chargeId, setChargeId] = useState('');
  const [debitAccountId, setDebitAccountId] = useState('');

  // The eligible account list depends on the member (only their INACTIVE accounts, minus
  // anything already mid-activation), so it's fetched per-member.
  useEffect(() => {
    let cancelled = false;
    if (!memberId) { setAccounts([]); return; }
    eligibleAccountsForActivation(Number(memberId)).then((res) => {
      if (cancelled) return;
      setAccounts(res.ok ? res.data : []);
    });
    setAccountId('');
    setDebitAccountId('');
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
      <MemberSelect id="f_memberId" name="memberId" members={members} value={memberId}
        onChange={setMemberId} required />

      <SearchableSelect id="f_accountId" name="accountId" label="Account" required
        items={accounts} getValue={(a) => String(a.id)} getLabel={(a) => `${a.account_no} — ${a.product_name}`}
        value={accountId} onChange={setAccountId}
        placeholder={accounts.length ? 'Search account…' : 'No inactive accounts for this member'}
        emptyText="No matching accounts" />

      <Field name="reason" label="Reason" type="textarea" required />

      {account ? (
        <div className="note">
          Current balance <Money cents={account.balance} /> — activating flips the account back
          to ACTIVE once processed, and it will accept deposits and withdrawals again.
        </div>
      ) : null}

      <ChargeDebitFields
        memberId={memberId} chargeId={chargeId} setChargeId={setChargeId}
        debitAccountId={debitAccountId} setDebitAccountId={setDebitAccountId}
      />
    </FormModal>
  );
}

/** Lets an Open request's Member, Account, Charge Code, Debit Account and Reason all be changed
 *  before it's sent for approval — the account is the request's real anchor (member is only
 *  ever derived from whichever account is chosen), so changing the member re-fetches that
 *  member's own eligible INACTIVE accounts exactly as the New Request form does. */
export function EditButton({ request, members, className = 'btn sm ghost' }: {
  request: AccountActivationRequestWithDimensions;
  members: Pick<Member, 'id' | 'member_no' | 'first_name' | 'last_name'>[];
  className?: string;
}) {
  const [open, setOpen] = useState(false);
  const [memberId, setMemberId] = useState(String(request.member_id));
  const [accounts, setAccounts] = useState<SavingsAccountWithProduct[]>([]);
  const [accountId, setAccountId] = useState(String(request.account_id));
  const [chargeId, setChargeId] = useState(String(request.transaction_charge_id ?? ''));
  const [debitAccountId, setDebitAccountId] = useState(String(request.debit_account_id ?? ''));

  // Re-fetches whenever the member changes (including the initial fetch for the request's own
  // member) — excludeRequestNo keeps the account already attached to this request in the list,
  // which the generic "not already in flight" filter would otherwise hide from itself.
  useEffect(() => {
    if (!open) return;
    let cancelled = false;
    if (!memberId) { setAccounts([]); return; }
    eligibleAccountsForActivation(Number(memberId), request.no).then((res) => {
      if (cancelled) return;
      const list = res.ok ? res.data : [];
      setAccounts(list);
      // Keep the current account selected if it's still eligible for whichever member is now
      // selected; otherwise clear it rather than guessing a replacement.
      if (!list.some((a) => String(a.id) === accountId)) setAccountId('');
    });
    return () => { cancelled = true; };
    // Only memberId should re-trigger this — accountId is read, not depended on.
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [open, memberId, request.no]);

  return (
    <>
      <button type="button" className={className} onClick={() => setOpen(true)}>Edit</button>
      {open ? (
        <FormModal
          title={`Edit ${request.no}`}
          onClose={() => setOpen(false)}
          onSubmit={(values) => saveAccountActivationRequest(request.no, values)}
          submitLabel="Save changes"
          successTitle="Request updated"
        >
          <MemberSelect id="f_memberId" name="memberId" members={members} value={memberId}
            onChange={(id) => { setMemberId(id); setDebitAccountId(''); }} required />

          <SearchableSelect id="f_accountId" name="accountId" label="Account" required
            items={accounts} getValue={(a) => String(a.id)} getLabel={(a) => `${a.account_no} — ${a.product_name}`}
            value={accountId} onChange={setAccountId}
            placeholder={accounts.length ? 'Search account…' : 'No inactive accounts for this member'}
            emptyText="No matching accounts" />

          <Field name="reason" label="Reason" type="textarea" required defaultValue={request.reason ?? ''} />
          <ChargeDebitFields
            memberId={memberId} chargeId={chargeId} setChargeId={setChargeId}
            debitAccountId={debitAccountId} setDebitAccountId={setDebitAccountId}
          />
        </FormModal>
      ) : null}
    </>
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
