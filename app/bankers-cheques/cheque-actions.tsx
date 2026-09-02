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
  requestBankersCheque, saveBankersCheque, submitBankersChequeRequest, cancelBankersChequeApprovalRequest,
  approveBankersChequeRequest, rejectBankersChequeRequest, reopenBankersChequeRequest, postBankersChequeRequest,
  deleteBankersChequeRequest, accountsForBankersCheque, previewChequeCharge,
} from '@/app/actions/bankersCheques';
import { delegateMyTask } from '@/app/actions/workflows';
import type { BankersChequeView, ChequeType, Member } from '@/lib/types';

type EligibleMember = Pick<Member, 'id' | 'member_no' | 'first_name' | 'last_name'>;
type ChequeAccount = {
  id: number; account_no: string; product_name: string;
  balance: number; hold_amount: number; min_balance: number; available: number;
};

function ChequeFields({ members, chequeTypes, initial }: {
  members: EligibleMember[]; chequeTypes: Pick<ChequeType, 'id' | 'code' | 'description' | 'maximum_amount'>[];
  initial?: BankersChequeView | null;
}) {
  const { cur } = useFormat();
  const editing = !!initial;
  const [chequeTypeId, setChequeTypeId] = useState(String(initial?.cheque_type_id ?? (chequeTypes[0]?.id ?? '')));
  const [memberId, setMemberId] = useState(String(initial?.member_id ?? ''));
  // On Edit, seed the picker with the account already on the cheque so its label shows
  // immediately — the effect then loads the member's full list of eligible accounts.
  const [accounts, setAccounts] = useState<ChequeAccount[]>(
    initial?.savings_account_id ? [{
      id: initial.savings_account_id, account_no: initial.account_no, product_name: initial.account_product_name,
      balance: initial.account_balance, hold_amount: initial.account_hold_amount,
      min_balance: initial.account_min_balance, available: initial.account_available,
    }] : [],
  );
  const [savingsAccountId, setSavingsAccountId] = useState(String(initial?.savings_account_id ?? ''));
  const [amount, setAmount] = useState(initial ? toTwoDp(String(initial.amount / 100)) : '');
  const [charge, setCharge] = useState<number | null>(initial ? initial.charge_amount : null);

  useEffect(() => {
    let cancelled = false;
    if (!memberId) { setAccounts([]); return; }
    accountsForBankersCheque(Number(memberId)).then((res) => {
      if (!cancelled && res.ok) setAccounts(res.data);
    });
    return () => { cancelled = true; };
  }, [memberId]);

  useEffect(() => {
    let cancelled = false;
    const n = Number(amount);
    if (!chequeTypeId || !n || n <= 0) { setCharge(null); return; }
    const timer = setTimeout(() => {
      previewChequeCharge(Number(chequeTypeId), n).then((res) => {
        if (!cancelled && res.ok) setCharge(res.data);
      });
    }, 400);
    return () => { cancelled = true; clearTimeout(timer); };
  }, [amount, chequeTypeId]);

  const type = chequeTypes.find((t) => String(t.id) === chequeTypeId);
  const acct = accounts.find((a) => String(a.id) === savingsAccountId);
  const chargeVal = charge ?? 0;
  // AL: Amount <= Max Amount AND Net Amount (amount + charge) <= account available.
  const ceilingByBalance = acct ? Math.max(acct.available - chargeVal, 0) : null;
  const ceiling = [
    type && type.maximum_amount > 0 ? type.maximum_amount : null,
    ceilingByBalance,
  ].filter((v): v is number => v != null).reduce((m, v) => Math.min(m, v), Infinity);
  const effectiveCeiling = Number.isFinite(ceiling) ? ceiling : null;

  return (
    <>
      {chequeTypes.length ? (
        <div className="field">
          <label htmlFor="f_chequeTypeId">Cheque type <span className="req">*</span></label>
          {editing ? (
            <>
              {/* A disabled <select> is omitted from FormData — carry the locked value along. */}
              <input type="hidden" name="chequeTypeId" value={chequeTypeId} />
              <input type="text" value={type ? `${type.code} — ${type.description}` : ''} disabled readOnly />
            </>
          ) : (
            <select id="f_chequeTypeId" name="chequeTypeId" value={chequeTypeId}
              onChange={(e) => setChequeTypeId(e.target.value)}>
              {chequeTypes.map((t) => (
                <option key={t.id} value={t.id}>{t.code} — {t.description}</option>
              ))}
            </select>
          )}
          {type && type.maximum_amount > 0 ? (
            <div className="hint">Maximum per cheque: {cur(type.maximum_amount)}</div>
          ) : null}
        </div>
      ) : (
        <div className="note">No banker’s cheque types are configured. Add one under “Cheque types” first.</div>
      )}

      <MemberSelect id="f_memberId" name="memberId" members={members} value={memberId}
        onChange={(id) => { setMemberId(id); setSavingsAccountId(''); }} required disabled={editing} />

      <SearchableSelect id="f_savingsAccountId" name="savingsAccountId" label="Account" required
        items={accounts} getValue={(a) => String(a.id)} getLabel={(a) => `${a.account_no} — ${a.product_name}`}
        value={savingsAccountId} onChange={setSavingsAccountId} disabled={!memberId}
        placeholder={
          !memberId ? 'Pick a member first'
            : accounts.length ? 'Search account…'
              : 'This member has no transfer-enabled account'
        }
        emptyText="No matching accounts"
        hint={acct ? `Balance ${cur(acct.balance)} · available ${cur(acct.available)}` : undefined} />

      <Field name="chequeNo" label="Cheque no." defaultValue={initial?.cheque_no ?? ''}
        placeholder="The physical cheque leaf number" />

      <Field name="payeeDetails" label="Payee details" type="textarea"
        defaultValue={initial?.payee_details ?? ''}
        hint="Who the cheque is payable to — required before it can be sent for approval" />

      <div className="field">
        <label htmlFor="f_amount">Amount <span className="req">*</span></label>
        <MoneyInput id="f_amount" value={amount} onChange={setAmount} required min={0}
          max={effectiveCeiling != null ? (effectiveCeiling / 100).toFixed(2) : undefined} />
        <input type="hidden" name="amount" value={amount} />
        <div className="hint">
          {charge != null
            ? `Clearing charge ${cur(charge)} · net ${cur((Number(amount) * 100 || 0) + charge)}${effectiveCeiling != null ? ` · max ${cur(effectiveCeiling)}` : ''}`
            : (effectiveCeiling != null ? `You can issue up to ${cur(effectiveCeiling)}` : 'Charge is applied on posting')}
        </div>
      </div>

      <div className="grid g2">
        <Field name="postingDate" label="Posting date" type="date" required
          defaultValue={initial?.posting_date ?? today()} />
      </div>

      <div className="note">
        On posting this debits the member’s account (cheque amount + clearing charge) and credits the
        cheque type’s clearing account.
      </div>
    </>
  );
}

export function NewChequeButton({ members, chequeTypes }: {
  members: EligibleMember[]; chequeTypes: Pick<ChequeType, 'id' | 'code' | 'description' | 'maximum_amount'>[];
}) {
  const [open, setOpen] = useState(false);
  return (
    <>
      <button type="button" className="btn" onClick={() => setOpen(true)}>New cheque</button>
      {open ? (
        <FormModal
          title="New banker’s cheque" wide
          onClose={() => setOpen(false)}
          onSubmit={requestBankersCheque}
          submitLabel="Save"
          successTitle="Banker’s cheque captured"
          successDetail={(d) => `${d.no} saved — send it for approval when ready`}
        >
          <ChequeFields members={members} chequeTypes={chequeTypes} />
        </FormModal>
      ) : null}
    </>
  );
}

export function EditButton({ cheque, members, chequeTypes, className = 'btn ghost' }: {
  cheque: BankersChequeView;
  members: EligibleMember[];
  chequeTypes: Pick<ChequeType, 'id' | 'code' | 'description' | 'maximum_amount'>[];
  className?: string;
}) {
  const [open, setOpen] = useState(false);
  return (
    <>
      <button type="button" className={className} onClick={() => setOpen(true)}>Edit</button>
      {open ? (
        <FormModal
          title={`Edit ${cheque.no}`} wide
          onClose={() => setOpen(false)}
          onSubmit={(values) => saveBankersCheque(cheque.no, values)}
          submitLabel="Save changes"
          successTitle="Banker’s cheque updated"
        >
          <ChequeFields members={members} chequeTypes={chequeTypes} initial={cheque} />
        </FormModal>
      ) : null}
    </>
  );
}

export function SubmitButton({ no, className = 'btn sm ghost' }: { no: string; className?: string }) {
  const { run, busy } = useRunAction();
  return (
    <button type="button" className={className} disabled={busy}
      onClick={() => run(() => submitBankersChequeRequest(no), {
        confirm: {
          title: 'Send this banker’s cheque for approval?',
          message: 'It can no longer be edited while pending. Payee details are required.',
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
      onClick={() => run(() => cancelBankersChequeApprovalRequest(no), {
        confirm: { title: 'Recall this banker’s cheque?', message: 'It goes back to Open so you can amend and resubmit it.', confirmLabel: 'Recall' },
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
      onClick={() => run(() => approveBankersChequeRequest(no), {
        confirm: { title: 'Approve this banker’s cheque?', message: 'It becomes ready to post. Nothing moves until it is posted.', confirmLabel: 'Approve' },
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
          title="Reject banker’s cheque"
          onClose={() => setOpen(false)}
          onSubmit={(values) => rejectBankersChequeRequest(no, String(values.reason || ''))}
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
      onClick={() => run(() => reopenBankersChequeRequest(no), {
        confirm: { title: 'Reopen this banker’s cheque?', message: 'It goes back to Open for amendment. It must be approved again before posting.', confirmLabel: 'Reopen' },
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
      onClick={() => run(() => postBankersChequeRequest(no), {
        confirm: {
          title: 'Post this banker’s cheque?',
          message: 'The member’s account is debited immediately (cheque amount + clearing charge). This cannot be undone from here.',
          confirmLabel: 'Post',
        },
        successTitle: 'Banker’s cheque posted',
        successDetail: (d) => `Account balance ${cur(d.balance)}${d.charged ? ` · charge ${cur(d.charged)}` : ''}`,
      })}>
      {busy ? 'Working…' : 'Post'}
    </button>
  );
}

export function DeleteButton({ no, className = 'btn sm ghost' }: { no: string; className?: string }) {
  const { run, busy } = useRunAction();
  return (
    <button type="button" className={className} disabled={busy}
      onClick={() => run(() => deleteBankersChequeRequest(no), {
        confirm: { title: 'Delete this banker’s cheque?', message: 'It is removed permanently. Only an open banker’s cheque can be deleted.', confirmLabel: 'Delete' },
        successTitle: 'Deleted',
      })}>
      {busy ? 'Working…' : 'Delete'}
    </button>
  );
}
