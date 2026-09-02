'use client';

import { useEffect, useState } from 'react';
import { FormModal } from '@/components/ui/form-modal';
import { Field, MoneyInput, toTwoDp } from '@/components/ui/field';
import { MemberSelect } from '@/components/ui/member-select';
import { SearchableSelect } from '@/components/ui/searchable-select';
import { useRunAction } from '@/components/ui/run-action';
import { useFormat } from '@/components/ui/format-provider';
import { today } from '@/lib/format';
import {
  requestInterAccountTransfer, saveInterAccountTransfer, submitInterAccountTransferRequest,
  cancelInterAccountTransferApprovalRequest, approveInterAccountTransferRequest, rejectInterAccountTransferRequest,
  reopenInterAccountTransferRequest, postInterAccountTransferRequest, deleteInterAccountTransferRequest,
  sourceAccountsForTransfer, destinationAccountsForTransfer, previewTransferCharge,
} from '@/app/actions/interAccountTransfer';
import { delegateMyTask } from '@/app/actions/workflows';
import type { InterAccountTransferAmountType, InterAccountTransferView, Member } from '@/lib/types';

type EligibleMember = Pick<Member, 'id' | 'member_no' | 'first_name' | 'last_name'>;
type TransferAccount = {
  id: number; account_no: string; product_name: string;
  balance: number; hold_amount: number; min_balance: number;
};

function TransferFields({ members, canCrossMember, initial }: {
  members: EligibleMember[]; canCrossMember: boolean; initial?: InterAccountTransferView | null;
}) {
  const { cur } = useFormat();
  const editing = !!initial;
  const [amountType, setAmountType] = useState<InterAccountTransferAmountType>(initial?.amount_type ?? 'PARTIAL');
  // On Edit, seed each picker with the account already on the transfer so its label shows
  // immediately — the effects below then load the full list of selectable accounts.
  const initialSourceAccount: TransferAccount[] = initial?.source_account_id ? [{
    id: initial.source_account_id, account_no: initial.source_account_no, product_name: initial.source_product_name,
    balance: initial.source_balance, hold_amount: initial.source_hold_amount, min_balance: initial.source_min_balance,
  }] : [];
  const initialDestAccount: TransferAccount[] = initial?.destination_account_id ? [{
    id: initial.destination_account_id, account_no: initial.destination_account_no, product_name: initial.destination_product_name,
    balance: initial.destination_balance, hold_amount: 0, min_balance: 0,
  }] : [];

  const [sourceMemberId, setSourceMemberId] = useState(String(initial?.source_member_id ?? ''));
  const [sourceAccounts, setSourceAccounts] = useState<TransferAccount[]>(initialSourceAccount);
  const [sourceAccountId, setSourceAccountId] = useState(String(initial?.source_account_id ?? ''));
  const [destMemberId, setDestMemberId] = useState(String(initial?.destination_member_id ?? initial?.source_member_id ?? ''));
  const [destAccounts, setDestAccounts] = useState<TransferAccount[]>(initialDestAccount);
  const [destAccountId, setDestAccountId] = useState(String(initial?.destination_account_id ?? ''));
  const [charge, setCharge] = useState<number | null>(initial ? initial.charge_amount : null);
  const [amount, setAmount] = useState(initial ? toTwoDp(String(initial.amount / 100)) : '');

  // Source member -> the accounts it can transfer FROM (allow_transfer products only).
  useEffect(() => {
    let cancelled = false;
    if (!sourceMemberId) { setSourceAccounts([]); return; }
    sourceAccountsForTransfer(Number(sourceMemberId)).then((res) => {
      if (!cancelled && res.ok) setSourceAccounts(res.data);
    });
    return () => { cancelled = true; };
  }, [sourceMemberId]);

  // Destination member (defaults to the source member — AL's own OnValidate of "Member No") +
  // source account -> the accounts it can transfer TO (any active account of that member, minus
  // the source account itself).
  useEffect(() => {
    let cancelled = false;
    if (!destMemberId) { setDestAccounts([]); return; }
    destinationAccountsForTransfer(Number(destMemberId), sourceAccountId ? Number(sourceAccountId) : undefined).then((res) => {
      if (!cancelled && res.ok) setDestAccounts(res.data);
    });
    return () => { cancelled = true; };
  }, [destMemberId, sourceAccountId]);

  // GetChargesAmount(Inter Acc Transfer Charge, Amount) — refreshed (debounced) as the amount changes.
  useEffect(() => {
    let cancelled = false;
    const n = Number(amount);
    if (!n || n <= 0) { setCharge(null); return; }
    const timer = setTimeout(() => {
      previewTransferCharge(n).then((res) => {
        if (!cancelled && res.ok) setCharge(res.data);
      });
    }, 400);
    return () => { cancelled = true; clearTimeout(timer); };
  }, [amount]);

  const src = sourceAccounts.find((a) => String(a.id) === sourceAccountId);
  const available = src
    ? Math.max(src.balance - src.hold_amount - (amountType === 'FULL' ? 0 : src.min_balance), 0)
    : null;
  const ceiling = available != null ? Math.max(available - (charge ?? 0), 0) : null;

  return (
    <>
      <div className="field">
        <label htmlFor="f_amountType">Amount type <span className="req">*</span></label>
        <select id="f_amountType" name="amountType" value={amountType}
          onChange={(e) => setAmountType(e.target.value as InterAccountTransferAmountType)}>
          <option value="PARTIAL">Partial — keep the source above its minimum balance</option>
          <option value="FULL">Full — may draw the source down to zero</option>
        </select>
      </div>

      <div className="grid g2">
        <MemberSelect id="f_sourceMemberId" name="sourceMemberId" label="Source member" members={members}
          value={sourceMemberId}
          onChange={(id) => {
            setSourceMemberId(id);
            setSourceAccountId('');
            setDestAccountId('');
            setDestMemberId(id);
          }}
          required disabled={editing} />

        <SearchableSelect id="f_sourceAccountId" name="sourceAccountId" label="Source account" required
          items={sourceAccounts} getValue={(a) => String(a.id)}
          getLabel={(a) => `${a.account_no} — ${a.product_name}`}
          value={sourceAccountId} onChange={(v) => { setSourceAccountId(v); setDestAccountId(''); }}
          disabled={!sourceMemberId}
          placeholder={
            !sourceMemberId ? 'Pick a source member first'
              : sourceAccounts.length ? 'Search account…'
                : 'This member has no transfer-enabled account'
          }
          emptyText="No matching accounts"
          hint={src
            ? `Balance ${cur(src.balance)} · held ${cur(src.hold_amount)} · available ${cur(available ?? 0)}`
            : undefined} />
      </div>

      <div className="grid g2">
        <MemberSelect id="f_destinationMemberId" name="destinationMemberId" label="Destination member"
          members={members} value={destMemberId}
          onChange={(id) => { setDestMemberId(id); setDestAccountId(''); }}
          required disabled={editing || !canCrossMember} />

        <SearchableSelect id="f_destinationAccountId" name="destinationAccountId" label="Destination account" required
          items={destAccounts} getValue={(a) => String(a.id)}
          getLabel={(a) => `${a.account_no} — ${a.product_name}`}
          value={destAccountId} onChange={setDestAccountId}
          disabled={!destMemberId}
          placeholder={
            !destMemberId ? 'Pick a destination member first'
              : destAccounts.length ? 'Search account…'
                : 'No other active account for this member'
          }
          emptyText="No matching accounts" />
      </div>

      {!canCrossMember ? (
        <div className="note">You can transfer only between one member’s own accounts.</div>
      ) : null}

      <div className="field">
        <label htmlFor="f_amount">Amount to transfer <span className="req">*</span></label>
        <MoneyInput id="f_amount" value={amount} onChange={setAmount} required min={0}
          max={ceiling != null ? (ceiling / 100).toFixed(2) : undefined} />
        <input type="hidden" name="amount" value={amount} />
        <div className="hint">
          {charge != null
            ? `Transfer charge ${cur(charge)}${ceiling != null ? ` · you can send up to ${cur(ceiling)}` : ''}`
            : (ceiling != null ? `You can send up to ${cur(ceiling)}` : 'Charge is applied on posting')}
        </div>
      </div>

      <div className="grid g2">
        <Field name="postingDate" label="Posting date" type="date" required
          defaultValue={initial?.posting_date ?? today()} />
      </div>

      <Field name="narration" label="Narration" type="textarea"
        defaultValue={initial?.narration ?? ''}
        hint="Optional — why this transfer is being made" />

      <div className="note">
        On posting this withdraws from the source account, deposits to the destination account and
        deducts the transfer charge from the source.
      </div>
    </>
  );
}

export function NewTransferButton({ members, canCrossMember }: { members: EligibleMember[]; canCrossMember: boolean }) {
  const [open, setOpen] = useState(false);
  return (
    <>
      <button type="button" className="btn" onClick={() => setOpen(true)}>New transfer</button>
      {open ? (
        <FormModal
          title="New inter-account transfer" wide
          onClose={() => setOpen(false)}
          onSubmit={requestInterAccountTransfer}
          submitLabel="Save"
          successTitle="Transfer captured"
          successDetail={(d) => `${d.no} saved — send it for approval when ready`}
        >
          <TransferFields members={members} canCrossMember={canCrossMember} />
        </FormModal>
      ) : null}
    </>
  );
}

export function EditButton({ transfer, members, canCrossMember, className = 'btn ghost' }: {
  transfer: InterAccountTransferView; members: EligibleMember[]; canCrossMember: boolean; className?: string;
}) {
  const [open, setOpen] = useState(false);
  return (
    <>
      <button type="button" className={className} onClick={() => setOpen(true)}>Edit</button>
      {open ? (
        <FormModal
          title={`Edit ${transfer.no}`} wide
          onClose={() => setOpen(false)}
          onSubmit={(values) => saveInterAccountTransfer(transfer.no, values)}
          submitLabel="Save changes"
          successTitle="Transfer updated"
        >
          <TransferFields members={members} canCrossMember={canCrossMember} initial={transfer} />
        </FormModal>
      ) : null}
    </>
  );
}

export function SubmitButton({ no, className = 'btn sm ghost' }: { no: string; className?: string }) {
  const { run, busy } = useRunAction();
  return (
    <button type="button" className={className} disabled={busy}
      onClick={() => run(() => submitInterAccountTransferRequest(no), {
        confirm: {
          title: 'Send this transfer for approval?',
          message: 'It can no longer be edited while pending.',
          confirmLabel: 'Send for approval',
        },
        successTitle: (d) => (d.autoApproved ? 'Approved — ready to post' : 'Sent for approval'),
      })}>
      {busy ? 'Working…' : 'Send for approval'}
    </button>
  );
}

export function CancelApprovalButton({ no, className = 'btn sm ghost' }: { no: string; className?: string }) {
  const { run, busy } = useRunAction();
  return (
    <button type="button" className={className} disabled={busy}
      onClick={() => run(() => cancelInterAccountTransferApprovalRequest(no), {
        confirm: { title: 'Recall this transfer?', message: 'It goes back to Open so you can amend and resubmit it.', confirmLabel: 'Recall' },
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
      onClick={() => run(() => approveInterAccountTransferRequest(no), {
        confirm: { title: 'Approve this transfer?', message: 'It becomes ready to post. Nothing moves until it is posted.', confirmLabel: 'Approve' },
        successTitle: 'Approved — ready to post',
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
          title="Reject transfer"
          onClose={() => setOpen(false)}
          onSubmit={(values) => rejectInterAccountTransferRequest(no, String(values.reason || ''))}
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
      onClick={() => run(() => reopenInterAccountTransferRequest(no), {
        confirm: { title: 'Reopen this transfer?', message: 'It goes back to Open for amendment. It must be approved again before posting.', confirmLabel: 'Reopen' },
        successTitle: 'Reopened — back to Open',
      })}>
      {busy ? 'Working…' : 'Reopen'}
    </button>
  );
}

export function PostButton({ no, className = 'btn sm' }: { no: string; className?: string }) {
  const { run, busy } = useRunAction();
  const { cur } = useFormat();
  return (
    <button type="button" className={className} disabled={busy}
      onClick={() => run(() => postInterAccountTransferRequest(no), {
        confirm: {
          title: 'Post this transfer?',
          message: 'Cash moves immediately from the source account to the destination account and the charge is deducted. This cannot be undone from here.',
          confirmLabel: 'Post',
        },
        successTitle: 'Transfer posted',
        successDetail: (d) => `Source balance ${cur(d.sourceBalance)} · destination ${cur(d.destinationBalance)}`,
      })}>
      {busy ? 'Working…' : 'Post'}
    </button>
  );
}

export function DeleteButton({ no, className = 'btn sm ghost' }: { no: string; className?: string }) {
  const { run, busy } = useRunAction();
  return (
    <button type="button" className={className} disabled={busy}
      onClick={() => run(() => deleteInterAccountTransferRequest(no), {
        confirm: { title: 'Delete this transfer?', message: 'It is removed permanently. Only an open transfer can be deleted.', confirmLabel: 'Delete' },
        successTitle: 'Deleted',
      })}>
      {busy ? 'Working…' : 'Delete'}
    </button>
  );
}
