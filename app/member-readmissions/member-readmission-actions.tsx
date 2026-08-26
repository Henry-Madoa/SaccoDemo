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
  requestMemberReadmission, saveMemberReadmissionRequest, submitMemberReadmission,
  cancelMemberReadmissionApprovalRequest, approveMemberReadmission, rejectMemberReadmission,
  processMemberReadmission, eligibleMembersForReadmissionRequest, accountsForReadmissionDebit,
} from '@/app/actions/memberReadmission';
import { listMemberReadmissionChargeCodes, previewMemberReadmissionChargeAmount } from '@/app/actions/charges';
import { delegateMyTask } from '@/app/actions/workflows';
import { Money } from '@/components/ui/money';
import { useFormat } from '@/components/ui/format-provider';
import type {
  MemberReadmissionRequestWithDimensions, PayFromAccountType, SavingsAccountForDebit, TransactionCharge,
} from '@/lib/types';

type EligibleMember = { id: number; member_no: string; first_name: string; last_name: string };

export function SubmitButton({ no, className = 'btn sm ghost' }: { no: string; className?: string }) {
  const { run, busy } = useRunAction();
  return (
    <button type="button" className={className} disabled={busy}
      onClick={() => run(() => submitMemberReadmission(no), {
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

export function CancelApprovalButton({ no, className = 'btn sm ghost' }: { no: string; className?: string }) {
  const { run, busy } = useRunAction();
  return (
    <button type="button" className={className} disabled={busy}
      onClick={() => run(() => cancelMemberReadmissionApprovalRequest(no), {
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
      onClick={() => run(() => approveMemberReadmission(no), {
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
          title="Reject member re-admission request"
          onClose={() => setOpen(false)}
          onSubmit={(values) => rejectMemberReadmission(no, String(values.reason || ''))}
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
 *  lib/memberReadmission.ts's withChargeAmount()) — the fee this specific request's chosen
 *  Charge Code resolves to right now. */
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
      title: 'Re-admit this member?',
      message: feeAmount
        ? `A re-admission charge of ${cur(feeAmount)} will be recovered. The member becomes Active and their default savings accounts are re-provisioned immediately.`
        : 'The member becomes Active and their default savings accounts are re-provisioned immediately.',
      confirmLabel: 'Re-admit member',
    });
    if (!ok) return;
    setBusy(true);
    try {
      const res = await processMemberReadmission(no);
      if (!res.ok) { showResult('Could not re-admit the member', res.error, 'err'); return; }
      showResult('Member re-admitted', undefined, 'ok');
      router.push(`/members/${res.data.memberId}`);
    } finally {
      setBusy(false);
    }
  };

  return (
    <button type="button" className={className} disabled={busy} onClick={process}>
      {busy ? 'Working…' : 'Re-admit member'}
    </button>
  );
}

const PAY_FROM_OPTIONS: { value: PayFromAccountType; label: string }[] = [
  { value: 'MEMBER_ACCOUNT', label: "Member's own account" },
  { value: 'CASH', label: 'Cash at the till' },
];

/**
 * The Charge Code + Pay From Account Type pair, with a live fee/available-balance preview —
 * shared by the New Request form and the Edit button for an Open request. Paying by CASH swaps
 * the Debit Account picker for a Payment Reference field.
 */
function ChargeFields({
  memberId, chargeId, setChargeId, payFromAccountType, setPayFromAccountType,
  debitAccountId, setDebitAccountId,
}: {
  memberId: string;
  chargeId: string;
  setChargeId: (v: string) => void;
  payFromAccountType: PayFromAccountType;
  setPayFromAccountType: (v: PayFromAccountType) => void;
  debitAccountId: string;
  setDebitAccountId: (v: string) => void;
}) {
  const { cur } = useFormat();
  const [chargeCodes, setChargeCodes] = useState<TransactionCharge[]>([]);
  const [debitAccounts, setDebitAccounts] = useState<SavingsAccountForDebit[]>([]);
  const [feeAmount, setFeeAmount] = useState<number | null>(null);

  useEffect(() => {
    listMemberReadmissionChargeCodes().then((res) => {
      if (res.ok) setChargeCodes(res.data);
    });
  }, []);

  useEffect(() => {
    let cancelled = false;
    if (!memberId || payFromAccountType !== 'MEMBER_ACCOUNT') { setDebitAccounts([]); return; }
    accountsForReadmissionDebit(Number(memberId)).then((res) => {
      if (!cancelled && res.ok) setDebitAccounts(res.data);
    });
    return () => { cancelled = true; };
  }, [memberId, payFromAccountType]);

  useEffect(() => {
    let cancelled = false;
    if (!chargeId) { setFeeAmount(null); return; }
    previewMemberReadmissionChargeAmount(Number(chargeId)).then((res) => {
      if (!cancelled && res.ok) setFeeAmount(res.data.reduce((sum, c) => sum + c.amount, 0));
    });
    return () => { cancelled = true; };
  }, [chargeId]);

  const debitAccount = debitAccounts.find((a) => String(a.id) === debitAccountId);
  const available = debitAccount ? debitAccount.balance - debitAccount.hold_amount - debitAccount.min_balance : null;
  const insufficient = payFromAccountType === 'MEMBER_ACCOUNT' && !!chargeId && feeAmount != null && available != null && feeAmount > available;

  return (
    <>
      <div className="grid g2" style={{ marginTop: 'calc(var(--sp)*1.5)' }}>
        <SearchableSelect id="f_transactionChargeId" name="transactionChargeId" label="Re-admission charge"
          items={chargeCodes} getValue={(c) => String(c.id)} getLabel={(c) => `${c.code} — ${c.description}`}
          value={chargeId} onChange={setChargeId} placeholder="No charge" emptyText="No matching charges" />
        <div className="field">
          <label htmlFor="f_payFromAccountType">Pay from</label>
          <select id="f_payFromAccountType" name="payFromAccountType" value={payFromAccountType}
            disabled={!chargeId}
            onChange={(e) => setPayFromAccountType(e.target.value as PayFromAccountType)}>
            {PAY_FROM_OPTIONS.map((o) => <option key={o.value} value={o.value}>{o.label}</option>)}
          </select>
        </div>
      </div>

      {chargeId && payFromAccountType === 'MEMBER_ACCOUNT' ? (
        <SearchableSelect id="f_debitAccountId" name="debitAccountId" label="Debit account" required
          items={debitAccounts} getValue={(a) => String(a.id)} getLabel={(a) => `${a.account_no} — ${a.product_name}`}
          value={debitAccountId} onChange={setDebitAccountId}
          placeholder="Search account…" emptyText="No matching accounts"
          style={{ marginTop: 'calc(var(--sp)*1.5)' }} />
      ) : null}

      {chargeId && payFromAccountType === 'CASH' ? (
        <Field name="paymentReference" label="Payment reference" required
          hint="Till slip / receipt number for the cash received" />
      ) : null}

      {chargeId ? (
        <div className="note" style={{ marginTop: 8 }}>
          Charge amount: <b className={insufficient ? 'neg' : undefined}>{feeAmount != null ? cur(feeAmount) : '…'}</b>
          {payFromAccountType === 'MEMBER_ACCOUNT' && debitAccount ? (
            <> · {debitAccount.account_no} available balance: <b>{cur(Math.max(available ?? 0, 0))}</b></>
          ) : null}
          {insufficient ? (
            <div className="neg">
              The charge exceeds the selected account's available balance — pick a different account,
              pay by cash instead, or reduce the charge before this can be sent for approval.
            </div>
          ) : null}
        </div>
      ) : null}
    </>
  );
}

interface NewRequestFormProps {
  presetMemberId?: number | null;
  onClose: () => void;
}

function NewRequestForm({ presetMemberId, onClose }: NewRequestFormProps) {
  const [members, setMembers] = useState<EligibleMember[]>([]);
  const [memberId, setMemberId] = useState(String(presetMemberId ?? ''));
  const [chargeId, setChargeId] = useState('');
  const [payFromAccountType, setPayFromAccountType] = useState<PayFromAccountType>('MEMBER_ACCOUNT');
  const [debitAccountId, setDebitAccountId] = useState('');

  useEffect(() => {
    eligibleMembersForReadmissionRequest().then((res) => {
      if (res.ok) setMembers(res.data);
    });
  }, []);

  return (
    <FormModal
      title="New member re-admission request"
      onClose={onClose}
      onSubmit={requestMemberReadmission}
      submitLabel="Save request"
      successTitle="Request captured"
      successDetail={(d) => `${d.no} saved — send it for approval when you're ready`}
    >
      <MemberSelect id="f_memberId" name="memberId" members={members} value={memberId}
        onChange={(id) => { setMemberId(id); setDebitAccountId(''); }} required
        placeholder={members.length ? 'Search member no. or name…' : 'No Withdrawn members available'} />

      <Field name="reason" label="Reason" type="textarea" required />

      <ChargeFields
        memberId={memberId} chargeId={chargeId} setChargeId={setChargeId}
        payFromAccountType={payFromAccountType} setPayFromAccountType={setPayFromAccountType}
        debitAccountId={debitAccountId} setDebitAccountId={setDebitAccountId}
      />
    </FormModal>
  );
}

/** Lets an Open request's Charge, Pay From choice and Reason all be changed before it's sent for
 *  approval. The member itself is fixed once a request exists — same "the anchor doesn't change
 *  on edit" shape as most of this app's other maker-checker documents. */
export function EditButton({ request, className = 'btn sm ghost' }: {
  request: MemberReadmissionRequestWithDimensions;
  className?: string;
}) {
  const [open, setOpen] = useState(false);
  const [chargeId, setChargeId] = useState(String(request.transaction_charge_id ?? ''));
  const [payFromAccountType, setPayFromAccountType] = useState<PayFromAccountType>(request.pay_from_account_type);
  const [debitAccountId, setDebitAccountId] = useState(String(request.debit_account_id ?? ''));

  return (
    <>
      <button type="button" className={className} onClick={() => setOpen(true)}>Edit</button>
      {open ? (
        <FormModal
          title={`Edit ${request.no}`}
          onClose={() => setOpen(false)}
          onSubmit={(values) => saveMemberReadmissionRequest(request.no, { ...values, memberId: request.member_id })}
          submitLabel="Save changes"
          successTitle="Request updated"
        >
          <div className="note">
            Member: <b>{request.member_first_name} {request.member_last_name}</b> <span className="mono">({request.member_no})</span>
          </div>

          <Field name="reason" label="Reason" type="textarea" required defaultValue={request.reason ?? ''} />
          <ChargeFields
            memberId={String(request.member_id)} chargeId={chargeId} setChargeId={setChargeId}
            payFromAccountType={payFromAccountType} setPayFromAccountType={setPayFromAccountType}
            debitAccountId={debitAccountId} setDebitAccountId={setDebitAccountId}
          />
        </FormModal>
      ) : null}
    </>
  );
}

/** Opens the New Request form, optionally preset from `?new=<memberId>` (same pattern as
 *  Member Activation's own NewMemberActivationButton). */
export function NewMemberReadmissionButton({ presetMemberId }: { presetMemberId?: number | null }) {
  const router = useRouter();
  const [open, setOpen] = useState(Boolean(presetMemberId));

  const close = () => {
    setOpen(false);
    if (presetMemberId) router.replace('/member-readmissions');
  };

  return (
    <>
      <button type="button" className="btn" onClick={() => setOpen(true)}>New re-admission request</button>
      {open ? <NewRequestForm presetMemberId={presetMemberId} onClose={close} /> : null}
    </>
  );
}
