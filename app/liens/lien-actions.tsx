'use client';

import { useEffect, useState } from 'react';
import { FormModal } from '@/components/ui/form-modal';
import { Field } from '@/components/ui/field';
import { MemberSelect } from '@/components/ui/member-select';
import { SearchableSelect } from '@/components/ui/searchable-select';
import { useRunAction } from '@/components/ui/run-action';
import { useFormat } from '@/components/ui/format-provider';
import { today } from '@/lib/format';
import {
  requestLien, saveLien, submitLienRequest, cancelLienApprovalRequest, approveLienRequest,
  rejectLienRequest, reopenLienRequest, processLienRequest, deleteLienRequest, accountsForLien,
} from '@/app/actions/liens';
import { delegateMyTask } from '@/app/actions/workflows';
import type { LienTransactionType, Member, MemberLienView } from '@/lib/types';

type EligibleMember = Pick<Member, 'id' | 'member_no' | 'first_name' | 'last_name'>;
type LienAccount = {
  id: number; account_no: string; product_name: string;
  balance: number; hold_amount: number; min_balance: number; available: number;
};

function LienFields({ members, initial }: { members: EligibleMember[]; initial?: MemberLienView | null }) {
  const { cur } = useFormat();
  const editing = !!initial;
  const [transactionType, setTransactionType] = useState<LienTransactionType>(initial?.transaction_type ?? 'HOLD');
  const [memberId, setMemberId] = useState(String(initial?.member_id ?? ''));
  const [accounts, setAccounts] = useState<LienAccount[]>([]);
  const [savingsAccountId, setSavingsAccountId] = useState(String(initial?.savings_account_id ?? ''));

  useEffect(() => {
    let cancelled = false;
    if (!memberId) { setAccounts([]); return; }
    accountsForLien(Number(memberId)).then((res) => {
      if (!cancelled && res.ok) setAccounts(res.data);
    });
    return () => { cancelled = true; };
  }, [memberId]);

  const acct = accounts.find((a) => String(a.id) === savingsAccountId);
  const isHold = transactionType === 'HOLD';
  // AL limit: HOLD up to the account's available (actual) balance, RELEASE up to what is held.
  const ceiling = acct ? (isHold ? acct.available : acct.hold_amount) : null;

  return (
    <>
      <div className="field">
        <label htmlFor="f_transactionType">Instruction <span className="req">*</span></label>
        <select id="f_transactionType" name="transactionType" value={transactionType}
          onChange={(e) => setTransactionType(e.target.value as LienTransactionType)}>
          <option value="HOLD">Hold — freeze part of the balance</option>
          <option value="RELEASE">Release — lift a previous hold</option>
        </select>
      </div>

      <MemberSelect id="f_memberId" name="memberId" members={members} value={memberId}
        onChange={(id) => { setMemberId(id); setSavingsAccountId(''); }} required disabled={editing} />

      <SearchableSelect id="f_savingsAccountId" name="savingsAccountId" label="Account" required
        items={accounts} getValue={(a) => String(a.id)} getLabel={(a) => `${a.account_no} — ${a.product_name}`}
        value={savingsAccountId} onChange={setSavingsAccountId} disabled={!memberId}
        placeholder={
          !memberId ? 'Pick a member first'
            : accounts.length ? 'Search account…'
              : 'No withdrawable / transfer account for this member'
        }
        emptyText="No matching accounts"
        hint={acct
          ? `Balance ${cur(acct.balance)} · currently held ${cur(acct.hold_amount)} · available ${cur(acct.available)}`
          : undefined} />

      <Field
        key={`amt-${savingsAccountId}-${transactionType}-${ceiling ?? 'x'}`}
        name="amount" label={isHold ? 'Amount to hold' : 'Amount to release'} type="currency" min={0} required
        max={ceiling != null ? (ceiling / 100).toFixed(2) : undefined}
        defaultValue={initial ? initial.amount / 100 : ''}
        hint={ceiling != null
          ? (isHold ? `You can hold up to ${cur(ceiling)}` : `Up to ${cur(ceiling)} is currently held`)
          : undefined} />

      <div className="grid g2">
        <Field name="postingDate" label="Posting date" type="date" required
          defaultValue={initial?.posting_date ?? today()} />
      </div>

      <Field name="narration" label="Narration" type="textarea" required
        defaultValue={initial?.narration ?? ''}
        hint="Why this hold/release is being placed — required before it can be sent for approval" />

      <div className="note">
        No journal is posted. Processing moves the account&apos;s hold amount, which every available-balance
        check in the system already respects.
      </div>
    </>
  );
}

export function NewLienButton({ members }: { members: EligibleMember[] }) {
  const [open, setOpen] = useState(false);
  return (
    <>
      <button type="button" className="btn" onClick={() => setOpen(true)}>New lien</button>
      {open ? (
        <FormModal
          title="New lien / hold" wide
          onClose={() => setOpen(false)}
          onSubmit={requestLien}
          submitLabel="Save"
          successTitle="Lien captured"
          successDetail={(d) => `${d.no} saved — send it for approval when ready`}
        >
          <LienFields members={members} />
        </FormModal>
      ) : null}
    </>
  );
}

export function EditButton({ lien, members, className = 'btn ghost' }: {
  lien: MemberLienView; members: EligibleMember[]; className?: string;
}) {
  const [open, setOpen] = useState(false);
  return (
    <>
      <button type="button" className={className} onClick={() => setOpen(true)}>Edit</button>
      {open ? (
        <FormModal
          title={`Edit ${lien.no}`} wide
          onClose={() => setOpen(false)}
          onSubmit={(values) => saveLien(lien.no, values)}
          submitLabel="Save changes"
          successTitle="Lien updated"
        >
          <LienFields members={members} initial={lien} />
        </FormModal>
      ) : null}
    </>
  );
}

export function SubmitButton({ no, className = 'btn sm ghost' }: { no: string; className?: string }) {
  const { run, busy } = useRunAction();
  return (
    <button type="button" className={className} disabled={busy}
      onClick={() => run(() => submitLienRequest(no), {
        confirm: {
          title: 'Send this lien for approval?',
          message: 'It can no longer be edited while pending. A narration is required.',
          confirmLabel: 'Send for approval',
        },
        successTitle: (d) => (d.autoApproved ? 'Approved — ready to process' : 'Sent for approval'),
      })}>
      {busy ? 'Working…' : 'Send for approval'}
    </button>
  );
}

export function CancelApprovalButton({ no, className = 'btn sm ghost' }: { no: string; className?: string }) {
  const { run, busy } = useRunAction();
  return (
    <button type="button" className={className} disabled={busy}
      onClick={() => run(() => cancelLienApprovalRequest(no), {
        confirm: { title: 'Recall this lien?', message: 'It goes back to Open so you can amend and resubmit it.', confirmLabel: 'Recall' },
        successTitle: 'Recalled — back to Open',
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
        confirm: { title: 'Delegate to your substitute?', message: 'Your configured substitute decides this instead of you.', confirmLabel: 'Delegate' },
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
      onClick={() => run(() => approveLienRequest(no), {
        confirm: { title: 'Approve this lien?', message: 'It becomes ready to process. Nothing changes on the account until it is processed.', confirmLabel: 'Approve' },
        successTitle: 'Approved — ready to process',
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
          title="Reject lien"
          onClose={() => setOpen(false)}
          onSubmit={(values) => rejectLienRequest(no, String(values.reason || ''))}
          submitLabel="Reject" submitClass="btn danger"
          successTitle="Rejected — back to Open" resultStyle="popup"
        >
          <Field name="reason" label="Reason" type="textarea" required />
        </FormModal>
      ) : null}
    </>
  );
}

export function ReopenButton({ no, className = 'btn sm ghost' }: { no: string; className?: string }) {
  const { run, busy } = useRunAction();
  return (
    <button type="button" className={className} disabled={busy}
      onClick={() => run(() => reopenLienRequest(no), {
        confirm: { title: 'Reopen this lien?', message: 'It goes back to Open for amendment. It must be approved again before processing.', confirmLabel: 'Reopen' },
        successTitle: 'Reopened — back to Open',
      })}>
      {busy ? 'Working…' : 'Reopen'}
    </button>
  );
}

export function ProcessButton({ no, type, className = 'btn sm' }: { no: string; type: LienTransactionType; className?: string }) {
  const { run, busy } = useRunAction();
  const { cur } = useFormat();
  const verb = type === 'HOLD' ? 'place this hold' : 'release this hold';
  return (
    <button type="button" className={className} disabled={busy}
      onClick={() => run(() => processLienRequest(no), {
        confirm: { title: `Process — ${verb}?`, message: "The account's hold amount changes immediately. This cannot be undone from here (raise the opposite instruction to reverse it).", confirmLabel: 'Process' },
        successTitle: type === 'HOLD' ? 'Hold placed' : 'Hold released',
        successDetail: (d) => `Held now ${cur(d.heldAfter)} · available ${cur(d.available)}`,
      })}>
      {busy ? 'Working…' : 'Process'}
    </button>
  );
}

export function DeleteButton({ no, className = 'btn sm ghost' }: { no: string; className?: string }) {
  const { run, busy } = useRunAction();
  return (
    <button type="button" className={className} disabled={busy}
      onClick={() => run(() => deleteLienRequest(no), {
        confirm: { title: 'Delete this lien?', message: 'It is removed permanently. Only an open lien can be deleted.', confirmLabel: 'Delete' },
        successTitle: 'Deleted',
      })}>
      {busy ? 'Working…' : 'Delete'}
    </button>
  );
}
