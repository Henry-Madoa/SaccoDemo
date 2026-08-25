'use client';

import { useEffect, useState } from 'react';
import { useRouter } from 'next/navigation';
import { FormModal } from '@/components/ui/form-modal';
import { Field } from '@/components/ui/field';
import { MemberSelect } from '@/components/ui/member-select';
import { useResultDialog } from '@/components/ui/result-dialog';
import { useConfirm } from '@/components/ui/confirm-dialog';
import { useRunAction } from '@/components/ui/run-action';
import { useFormat } from '@/components/ui/format-provider';
import {
  requestMemberExit, refreshMemberExitLinesRequest, saveMemberExitRequest, submitMemberExitRequest,
  cancelMemberExitApprovalRequest, approveMemberExitRequest, rejectMemberExitRequest,
  reopenMemberExitRequest, processMemberExitRequest,
} from '@/app/actions/memberExits';
import { listMemberExitChargeCodes, previewTransactionChargeAmount } from '@/app/actions/charges';
import { delegateMyTask } from '@/app/actions/workflows';
import { EXIT_TYPES, PAYOUT_METHODS } from '@/lib/constants';
import type { EligibleExitMemberRow, MemberExitWithDetails, TransactionCharge } from '@/lib/types';

export function SubmitButton({ no, className = 'btn sm ghost' }: { no: string; className?: string }) {
  const { run, busy } = useRunAction();
  return (
    <button type="button" className={className} disabled={busy}
      onClick={() => run(() => submitMemberExitRequest(no), {
        confirm: {
          title: 'Send this member exit for approval?',
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
      onClick={() => run(() => cancelMemberExitApprovalRequest(no), {
        confirm: {
          title: 'Cancel this approval request?',
          message: 'The document goes back to Open so you can amend and resubmit it.',
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
      onClick={() => run(() => approveMemberExitRequest(no), {
        confirm: { title: 'Approve this member exit?', confirmLabel: 'Approve' },
        successTitle: 'Member exit approved',
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
          title="Reject member exit"
          onClose={() => setOpen(false)}
          onSubmit={(values) => rejectMemberExitRequest(no, String(values.reason || ''))}
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

/** AL's "Re-Open" action — pulls an Approved-but-not-yet-Processed document back to Open, unlike
 *  Cancel Approval Request which only ever applies to a still-Pending one. */
export function ReopenButton({ no, className = 'btn sm ghost' }: { no: string; className?: string }) {
  const { run, busy } = useRunAction();
  return (
    <button type="button" className={className} disabled={busy}
      onClick={() => run(() => reopenMemberExitRequest(no), {
        confirm: {
          title: 'Reopen this member exit?',
          message: 'It goes back to Open for further changes, undoing the approval decision.',
          confirmLabel: 'Reopen',
        },
        successTitle: 'Member exit reopened — back to Open',
      })}>
      {busy ? 'Working…' : 'Reopen'}
    </button>
  );
}

export function ProcessButton({ no, className = 'btn sm' }: { no: string; className?: string }) {
  const { run, busy } = useRunAction();
  return (
    <button type="button" className={className} disabled={busy}
      onClick={() => run(() => processMemberExitRequest(no), {
        confirm: {
          title: 'Process this member exit?',
          message: 'This settles every asset and liability, pays out the balance and closes the member’s accounts. This cannot be undone from here.',
          confirmLabel: 'Process',
        },
        successTitle: 'Member exit processed',
      })}>
      {busy ? 'Working…' : 'Process'}
    </button>
  );
}

export function RefreshLinesButton({ no, className = 'btn sm ghost' }: { no: string; className?: string }) {
  const { run, busy } = useRunAction();
  return (
    <button type="button" className={className} disabled={busy}
      onClick={() => run(() => refreshMemberExitLinesRequest(no), {
        confirm: {
          title: 'Refresh lines from the member’s current position?',
          message: 'Re-syncs the asset, liability and guarantee lines from the member’s live accounts, loans and guarantees.',
          confirmLabel: 'Refresh lines',
        },
        successTitle: 'Lines refreshed',
      })}>
      {busy ? 'Working…' : 'Refresh lines'}
    </button>
  );
}

/** Exit type / payout method / reason / Charge Code — shared by the New form and Edit, with a
 *  live fee preview once a Charge Code is picked, same shape Account Activation's
 *  ChargeDebitFields uses. */
function ExitFields({ exitType, setExitType, defaults }: {
  exitType: string;
  setExitType: (v: string) => void;
  defaults?: Partial<MemberExitWithDetails>;
}) {
  const { cur } = useFormat();
  const [chargeCodes, setChargeCodes] = useState<TransactionCharge[]>([]);
  const [chargeId, setChargeId] = useState(String(defaults?.transaction_charge_id ?? ''));
  const [feeAmount, setFeeAmount] = useState<number | null>(null);

  useEffect(() => {
    listMemberExitChargeCodes().then((res) => { if (res.ok) setChargeCodes(res.data); });
  }, []);

  useEffect(() => {
    let cancelled = false;
    if (!chargeId) { setFeeAmount(null); return; }
    previewTransactionChargeAmount(Number(chargeId), Math.max(0, defaults?.net_amount ?? 0)).then((res) => {
      if (!cancelled && res.ok) setFeeAmount(res.data.reduce((sum, c) => sum + c.amount, 0));
    });
    return () => { cancelled = true; };
  }, [chargeId, defaults?.net_amount]);

  return (
    <>
      <div className="grid g2">
        <div className="field">
          <label htmlFor="f_exitType">Exit type</label>
          <select id="f_exitType" name="exitType" value={exitType} onChange={(e) => setExitType(e.target.value)}>
            {EXIT_TYPES.map((t) => <option key={t.value} value={t.value}>{t.label}</option>)}
          </select>
        </div>
        <div className="field">
          <label htmlFor="f_payoutMethod">Payout method</label>
          <select id="f_payoutMethod" name="payoutMethod" defaultValue={defaults?.payout_method ?? 'FOSA'}>
            {PAYOUT_METHODS.map((p) => <option key={p.value} value={p.value}>{p.label}</option>)}
          </select>
        </div>
      </div>
      <Field name="reason" label="Reason" type="textarea" required defaultValue={defaults?.reason ?? ''} />
      <div className="field">
        <label htmlFor="f_transactionChargeId">Charge code</label>
        <select id="f_transactionChargeId" name="transactionChargeId" value={chargeId}
          onChange={(e) => setChargeId(e.target.value)}>
          <option value="">No charge</option>
          {chargeCodes.map((c) => <option key={c.id} value={c.id}>{c.code} — {c.description}</option>)}
        </select>
      </div>
      {chargeId && feeAmount != null ? (
        <div className="note" style={{ marginTop: 8 }}>Charge amount: <b>{cur(feeAmount)}</b></div>
      ) : null}
    </>
  );
}

function NewExitForm({ members, presetMemberId, onClose }: {
  members: EligibleExitMemberRow[]; presetMemberId?: string | null; onClose: () => void;
}) {
  const [memberId, setMemberId] = useState(presetMemberId ?? '');
  const [exitType, setExitType] = useState('GENERAL');
  return (
    <FormModal
      title="New member exit"
      onClose={onClose}
      onSubmit={(values) => requestMemberExit(Number(values.memberId), exitType)}
      submitLabel="Open document"
      successTitle="Member exit opened"
      successDetail={(d) => `${d.no} saved — review the assets/liabilities, then send it for approval`}
    >
      <MemberSelect id="f_memberId" name="memberId" members={members} value={memberId} onChange={setMemberId} required />
      <div className="field">
        <label htmlFor="f_exitTypeNew">Exit type</label>
        <select id="f_exitTypeNew" value={exitType} onChange={(e) => setExitType(e.target.value)}>
          {EXIT_TYPES.map((t) => <option key={t.value} value={t.value}>{t.label}</option>)}
        </select>
      </div>
    </FormModal>
  );
}

export function NewMemberExitButton({ members, presetMemberId }: {
  members: EligibleExitMemberRow[]; presetMemberId?: string | null;
}) {
  const router = useRouter();
  const [open, setOpen] = useState(Boolean(presetMemberId));

  const close = () => {
    setOpen(false);
    if (presetMemberId) router.replace('/member-exits');
  };

  return (
    <>
      <button type="button" className="btn" disabled={!members.length} onClick={() => setOpen(true)}>
        New member exit
      </button>
      {open ? <NewExitForm members={members} presetMemberId={presetMemberId} onClose={close} /> : null}
    </>
  );
}

export function EditButton({ exit, className = 'btn sm ghost' }: { exit: MemberExitWithDetails; className?: string }) {
  const [open, setOpen] = useState(false);
  const [exitType, setExitType] = useState<string>(exit.exit_type);

  return (
    <>
      <button type="button" className={className} onClick={() => setOpen(true)}>Edit</button>
      {open ? (
        <FormModal
          title={`Edit ${exit.no}`}
          onClose={() => setOpen(false)}
          onSubmit={(values) => saveMemberExitRequest(exit.no, values)}
          submitLabel="Save changes"
          successTitle="Member exit updated"
        >
          <ExitFields exitType={exitType} setExitType={setExitType} defaults={exit} />
        </FormModal>
      ) : null}
    </>
  );
}
