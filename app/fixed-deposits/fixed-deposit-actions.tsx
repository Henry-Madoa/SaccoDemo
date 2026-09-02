'use client';

import { useEffect, useState } from 'react';
import { FormModal } from '@/components/ui/form-modal';
import { Field } from '@/components/ui/field';
import { MemberSelect } from '@/components/ui/member-select';
import { SearchableSelect } from '@/components/ui/searchable-select';
import { useRunAction } from '@/components/ui/run-action';
import {
  requestFixedDeposit, submitFixedDepositRequest, cancelFixedDepositApprovalRequest,
  approveFixedDepositRequest, rejectFixedDepositRequest, activateFixedDepositRequest,
  accrueFixedDepositInterestRequest, matureFixedDepositRequest, terminateFixedDepositRequest,
} from '@/app/actions/fixedDeposits';
import { activeFixedDepositTypes } from '@/app/actions/fixedDepositTypes';
import { delegateMyTask } from '@/app/actions/workflows';
import { FD_MATURITY_INSTRUCTIONS } from '@/lib/constants';
import type { Member, MemberFixedDepositType } from '@/lib/types';

export function SubmitButton({ no, className = 'btn sm ghost' }: { no: string; className?: string }) {
  const { run, busy } = useRunAction();
  return (
    <button type="button" className={className} disabled={busy}
      onClick={() => run(() => submitFixedDepositRequest(no), {
        confirm: {
          title: 'Send this fixed deposit for approval?',
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
      onClick={() => run(() => cancelFixedDepositApprovalRequest(no), {
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
      onClick={() => run(() => approveFixedDepositRequest(no), {
        confirm: { title: 'Approve this fixed deposit?', confirmLabel: 'Approve' },
        successTitle: 'Fixed deposit approved',
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
          title="Reject fixed deposit"
          onClose={() => setOpen(false)}
          onSubmit={(values) => rejectFixedDepositRequest(no, String(values.reason || ''))}
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

export function ActivateButton({ no, className = 'btn sm' }: { no: string; className?: string }) {
  const { run, busy } = useRunAction();
  return (
    <button type="button" className={className} disabled={busy}
      onClick={() => run(() => activateFixedDepositRequest(no), {
        confirm: {
          title: 'Activate this fixed deposit?',
          message: 'The amount is drawn from the source account into a new dedicated account, and the interest schedule is generated.',
          confirmLabel: 'Activate',
        },
        successTitle: 'Fixed deposit activated',
      })}>
      {busy ? 'Working…' : 'Activate'}
    </button>
  );
}

export function AccrueInterestButton({ no, className = 'btn sm ghost' }: { no: string; className?: string }) {
  const { run, busy } = useRunAction();
  return (
    <button type="button" className={className} disabled={busy}
      onClick={() => run(() => accrueFixedDepositInterestRequest(no), {
        confirm: {
          title: 'Accrue interest?',
          message: 'Posts the GL accrual for every schedule line due and not yet posted.',
          confirmLabel: 'Accrue interest',
        },
        successTitle: (d) => (d.postedLines ? `Accrued ${d.postedLines} line${d.postedLines === 1 ? '' : 's'}` : 'Nothing due yet'),
      })}>
      {busy ? 'Working…' : 'Accrue interest'}
    </button>
  );
}

export function MatureButton({ no, className = 'btn sm' }: { no: string; className?: string }) {
  const { run, busy } = useRunAction();
  return (
    <button type="button" className={className} disabled={busy}
      onClick={() => run(() => matureFixedDepositRequest(no), {
        confirm: {
          title: 'Mature this fixed deposit?',
          message: 'Interest is finalised and the principal is settled per the maturity instructions. This cannot be undone from here.',
          confirmLabel: 'Mature',
        },
        successTitle: 'Fixed deposit matured',
      })}>
      {busy ? 'Working…' : 'Mature'}
    </button>
  );
}

export function TerminateButton({ no, className = 'btn sm ghost' }: { no: string; className?: string }) {
  const { run, busy } = useRunAction();
  return (
    <button type="button" className={className} disabled={busy}
      onClick={() => run(() => terminateFixedDepositRequest(no), {
        confirm: {
          title: 'Terminate this fixed deposit early?',
          message: 'Only the principal is refunded to the source account — no interest is paid. This cannot be undone from here.',
          confirmLabel: 'Terminate',
        },
        successTitle: 'Fixed deposit terminated',
      })}>
      {busy ? 'Working…' : 'Terminate'}
    </button>
  );
}

function NewFixedDepositForm({ members, onClose }: {
  members: Pick<Member, 'id' | 'member_no' | 'first_name' | 'last_name'>[];
  onClose: () => void;
}) {
  const [memberId, setMemberId] = useState('');
  const [types, setTypes] = useState<MemberFixedDepositType[]>([]);
  const [fdTypeId, setFdTypeId] = useState('');
  const [rate, setRate] = useState('');

  useEffect(() => {
    activeFixedDepositTypes().then((res) => { if (res.ok) setTypes(res.data); });
  }, []);

  const fdType = types.find((t) => String(t.id) === fdTypeId);

  return (
    <FormModal
      title="New fixed deposit"
      onClose={onClose}
      onSubmit={requestFixedDeposit}
      submitLabel="Open document"
      successTitle="Fixed deposit opened"
      successDetail={(d) => `${d.no} saved — send it for approval when you're ready`}
    >
      <MemberSelect id="f_memberId" name="memberId" members={members} value={memberId} onChange={setMemberId} required />

      <div className="grid g2">
        <SearchableSelect id="f_fdTypeId" name="fdTypeId" label="Fixed deposit type" required
          items={types} getValue={(t) => String(t.id)} getLabel={(t) => `${t.code} — ${t.description}`}
          value={fdTypeId} onChange={(v) => {
            setFdTypeId(v);
            const t = types.find((x) => String(x.id) === v);
            if (t) setRate(String(t.max_interest_rate));
          }} placeholder="Search fixed deposit type…" emptyText="No matching types" />
        <div className="field">
          <label htmlFor="f_rate">Interest rate (%) <span className="req">*</span></label>
          <input id="f_rate" name="rate" type="number" step="0.01" required value={rate} disabled={!fdType}
            onChange={(e) => setRate(e.target.value)} />
          {fdType ? <div className="hint">Range: {fdType.min_interest_rate}% – {fdType.max_interest_rate}%</div> : null}
        </div>
        <Field name="amount" label="Amount" type="currency" required />
        <Field name="termMonths" label="Term (months)" type="number" required defaultValue={12} />
        <div className="field">
          <label htmlFor="f_startDate">Start date <span className="req">*</span></label>
          <input id="f_startDate" name="startDate" type="date" required defaultValue={new Date().toISOString().slice(0, 10)} />
        </div>
        <Field name="maturityInstructions" label="Maturity instructions" type="select" required
          defaultValue="LIQUIDATE" options={FD_MATURITY_INSTRUCTIONS} />
      </div>
    </FormModal>
  );
}

export function NewFixedDepositButton({ members }: {
  members: Pick<Member, 'id' | 'member_no' | 'first_name' | 'last_name'>[];
}) {
  const [open, setOpen] = useState(false);
  return (
    <>
      <button type="button" className="btn" disabled={!members.length} onClick={() => setOpen(true)}>
        New fixed deposit
      </button>
      {open ? <NewFixedDepositForm members={members} onClose={() => setOpen(false)} /> : null}
    </>
  );
}
