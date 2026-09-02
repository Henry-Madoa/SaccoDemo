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
  requestChequeDeposit, saveChequeDeposit, submitChequeDepositRequest, cancelChequeDepositApprovalRequest,
  approveChequeDepositRequest, rejectChequeDepositRequest, reopenChequeDepositRequest, deleteChequeDepositRequest,
  clearChequeDepositRequest, expressClearChequeDepositRequest, releaseChequeDepositHoldRequest,
  bounceChequeDepositRequest, accountsForChequeDeposit, previewChequeDeposit,
} from '@/app/actions/chequeDeposits';
import { delegateMyTask } from '@/app/actions/workflows';
import type { ChequeDepositView, ChequeType, Member } from '@/lib/types';

type EligibleMember = Pick<Member, 'id' | 'member_no' | 'first_name' | 'last_name'>;
type ChequeTypeOpt = Pick<ChequeType, 'id' | 'code' | 'description' | 'maximum_amount' | 'in_house' | 'maturity_days' | 'express_charge_id'>;
type DepositAccount = { id: number; account_no: string; product_name: string; balance: number };

function DepositFields({ members, chequeTypes, initial }: {
  members: EligibleMember[]; chequeTypes: ChequeTypeOpt[]; initial?: ChequeDepositView | null;
}) {
  const { cur } = useFormat();
  const editing = !!initial;
  const [chequeTypeId, setChequeTypeId] = useState(String(initial?.cheque_type_id ?? (chequeTypes[0]?.id ?? '')));
  const [memberId, setMemberId] = useState(String(initial?.member_id ?? ''));
  const [accounts, setAccounts] = useState<DepositAccount[]>([]);
  const [savingsAccountId, setSavingsAccountId] = useState(String(initial?.savings_account_id ?? ''));
  const [amount, setAmount] = useState(initial ? toTwoDp(String(initial.amount / 100)) : '');
  const [depositDate, setDepositDate] = useState(initial?.deposit_date ?? today());
  const [express, setExpress] = useState(!!initial?.express_cheque);
  const [preview, setPreview] = useState<{ clearing: number; express: number; bouncing: number; maturityDate: string | null; maxAmount: number; hasExpress: boolean } | null>(null);

  useEffect(() => {
    let cancelled = false;
    if (!memberId) { setAccounts([]); return; }
    accountsForChequeDeposit(Number(memberId)).then((res) => {
      if (!cancelled && res.ok) setAccounts(res.data);
    });
    return () => { cancelled = true; };
  }, [memberId]);

  useEffect(() => {
    let cancelled = false;
    if (!chequeTypeId) { setPreview(null); return; }
    const timer = setTimeout(() => {
      previewChequeDeposit(Number(chequeTypeId), Number(amount) || 0, depositDate).then((res) => {
        if (cancelled || !res.ok) return;
        setPreview({ ...res.data.charges, maturityDate: res.data.maturityDate, maxAmount: res.data.maxAmount, hasExpress: res.data.hasExpress });
      });
    }, 350);
    return () => { cancelled = true; clearTimeout(timer); };
  }, [chequeTypeId, amount, depositDate]);

  const type = chequeTypes.find((t) => String(t.id) === chequeTypeId);
  const acct = accounts.find((a) => String(a.id) === savingsAccountId);
  const hasExpress = preview?.hasExpress ?? !!type?.express_charge_id;

  return (
    <>
      {chequeTypes.length ? (
        <div className="field">
          <label htmlFor="f_chequeTypeId">Cheque type <span className="req">*</span></label>
          <select id="f_chequeTypeId" name="chequeTypeId" value={chequeTypeId}
            onChange={(e) => setChequeTypeId(e.target.value)} disabled={editing}>
            {chequeTypes.map((t) => (
              <option key={t.id} value={t.id}>{t.code} — {t.description}</option>
            ))}
          </select>
          <div className="hint">
            {type?.in_house ? 'In-house — clears on the deposit date. ' : `Maturity period: ${type?.maturity_days ?? 0} day(s). `}
            {preview?.maturityDate ? `Matures ${preview.maturityDate}.` : ''}
          </div>
        </div>
      ) : (
        <div className="note">No external cheque types are configured. Add one under “Cheque types” first.</div>
      )}

      <MemberSelect id="f_memberId" name="memberId" members={members} value={memberId}
        onChange={(id) => { setMemberId(id); setSavingsAccountId(''); }} required disabled={editing} />

      <SearchableSelect id="f_savingsAccountId" name="savingsAccountId" label="Deposit into account" required
        items={accounts} getValue={(a) => String(a.id)} getLabel={(a) => `${a.account_no} — ${a.product_name}`}
        value={savingsAccountId} onChange={setSavingsAccountId} disabled={!memberId}
        placeholder={
          !memberId ? 'Pick a member first'
            : accounts.length ? 'Search account…'
              : 'This member has no active deposit account'
        }
        emptyText="No matching accounts"
        hint={acct ? `Current balance ${cur(acct.balance)}` : undefined} />

      <div className="grid g2">
        <Field name="chequeNo" label="Cheque no." defaultValue={initial?.cheque_no ?? ''} required />
        <Field name="chequeDate" label="Cheque date" type="date" defaultValue={initial?.cheque_date ?? today()} required />
      </div>

      <div className="grid g2">
        <div className="field">
          <label htmlFor="f_depositDate">Deposit date <span className="req">*</span></label>
          <input id="f_depositDate" name="depositDate" type="date" value={depositDate} min={today()}
            onChange={(e) => setDepositDate(e.target.value)} required />
        </div>
        <div className="field">
          <label htmlFor="f_amount">Amount <span className="req">*</span></label>
          <MoneyInput id="f_amount" value={amount} onChange={setAmount} required min={0}
            max={preview && preview.maxAmount > 0 ? (preview.maxAmount / 100).toFixed(2) : undefined} />
          <input type="hidden" name="amount" value={amount} />
          <div className="hint">
            {preview
              ? `Clearing charge ${cur(preview.clearing)}${hasExpress ? ` · express ${cur(preview.express)}` : ''} · bounce ${cur(preview.bouncing)}`
              : 'Charges apply on clearing'}
          </div>
        </div>
      </div>

      <Field name="expressCheque"
        label="Express cheque — release the funds before maturity for the express charge, with a hold on the account until the maturity date"
        type="checkbox" defaultValue={express ? 1 : 0}
        onChange={(e) => setExpress((e.target as HTMLInputElement).checked)} />
      {express && !hasExpress ? (
        <div className="note">This cheque type isn’t configured for express clearing, so it can only clear on its maturity date.</div>
      ) : null}

      <div className="grid g2">
        <Field name="drawerAccountName" label="Drawer account name" defaultValue={initial?.drawer_account_name ?? ''}
          placeholder="Name on the cheque" />
        <Field name="drawerBank" label="Drawer bank" defaultValue={initial?.drawer_bank ?? ''} />
      </div>
      <div className="grid g2">
        <Field name="drawerBranch" label="Drawer branch" defaultValue={initial?.drawer_branch ?? ''} />
        <Field name="drawerAccountNo" label="Drawer account no." defaultValue={initial?.drawer_account_no ?? ''} />
      </div>

      <div className="note">
        On clearing, the amount is credited to the member’s account (debiting Cheques in Clearing) and
        the clearing charge is deducted. Funds are not available until the cheque clears on its maturity date.
      </div>
    </>
  );
}

export function NewDepositButton({ members, chequeTypes }: { members: EligibleMember[]; chequeTypes: ChequeTypeOpt[] }) {
  const [open, setOpen] = useState(false);
  return (
    <>
      <button type="button" className="btn" onClick={() => setOpen(true)}>New cheque deposit</button>
      {open ? (
        <FormModal
          title="New cheque deposit" wide
          onClose={() => setOpen(false)}
          onSubmit={requestChequeDeposit}
          submitLabel="Save"
          successTitle="Cheque deposit captured"
          successDetail={(d) => `${d.no} — matures ${d.maturityDate}`}
        >
          <DepositFields members={members} chequeTypes={chequeTypes} />
        </FormModal>
      ) : null}
    </>
  );
}

export function EditButton({ deposit, members, chequeTypes, className = 'btn ghost' }: {
  deposit: ChequeDepositView; members: EligibleMember[]; chequeTypes: ChequeTypeOpt[]; className?: string;
}) {
  const [open, setOpen] = useState(false);
  return (
    <>
      <button type="button" className={className} onClick={() => setOpen(true)}>Edit</button>
      {open ? (
        <FormModal
          title={`Edit ${deposit.no}`} wide
          onClose={() => setOpen(false)}
          onSubmit={(values) => saveChequeDeposit(deposit.no, values)}
          submitLabel="Save changes"
          successTitle="Cheque deposit updated"
        >
          <DepositFields members={members} chequeTypes={chequeTypes} initial={deposit} />
        </FormModal>
      ) : null}
    </>
  );
}

export function SubmitButton({ no, className = 'btn sm ghost' }: { no: string; className?: string }) {
  const { run, busy } = useRunAction();
  return (
    <button type="button" className={className} disabled={busy}
      onClick={() => run(() => submitChequeDepositRequest(no), {
        confirm: { title: 'Send this cheque deposit for approval?', message: 'It can no longer be edited while pending.', confirmLabel: 'Send for approval' },
        successTitle: (d) => (d.autoApproved ? 'Approved — awaiting clearance' : 'Sent for approval'),
      })}>
      {busy ? 'Working…' : 'Send for approval'}
    </button>
  );
}

export function CancelApprovalButton({ no, className = 'btn sm ghost' }: { no: string; className?: string }) {
  const { run, busy } = useRunAction();
  return (
    <button type="button" className={className} disabled={busy}
      onClick={() => run(() => cancelChequeDepositApprovalRequest(no), {
        confirm: { title: 'Recall this cheque deposit?', message: 'It goes back to Open so you can amend and resubmit it.', confirmLabel: 'Recall' },
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
      onClick={() => run(() => approveChequeDepositRequest(no), {
        confirm: { title: 'Approve this cheque deposit?', message: 'It is banked and held until its maturity date. Nothing is credited yet.', confirmLabel: 'Approve' },
        successTitle: 'Approved — awaiting clearance',
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
          title="Reject cheque deposit"
          onClose={() => setOpen(false)}
          onSubmit={(values) => rejectChequeDepositRequest(no, String(values.reason || ''))}
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
      onClick={() => run(() => reopenChequeDepositRequest(no), {
        confirm: { title: 'Reopen this cheque deposit?', message: 'It goes back to Open for amendment. It must be approved again.', confirmLabel: 'Reopen' },
        successTitle: 'Reopened — back to Open',
      })}>
      {busy ? 'Working…' : 'Reopen'}
    </button>
  );
}

export function ClearButton({ no, className = 'btn sm' }: { no: string; className?: string }) {
  const { run, busy } = useRunAction();
  const { cur } = useFormat();
  return (
    <button type="button" className={className} disabled={busy}
      onClick={() => run(() => clearChequeDepositRequest(no), {
        confirm: { title: 'Clear this cheque?', message: 'The amount is credited to the member’s account and the clearing charge is deducted.', confirmLabel: 'Clear' },
        successTitle: 'Cheque cleared',
        successDetail: (d) => `Account balance ${cur(d.balance)}${d.charged ? ` · charge ${cur(d.charged)}` : ''}`,
      })}>
      {busy ? 'Working…' : 'Clear'}
    </button>
  );
}

export function ExpressClearButton({ no, className = 'btn sm ghost' }: { no: string; className?: string }) {
  const { run, busy } = useRunAction();
  const { cur } = useFormat();
  return (
    <button type="button" className={className} disabled={busy}
      onClick={() => run(() => expressClearChequeDepositRequest(no), {
        confirm: {
          title: 'Express-clear this cheque?',
          message: 'The funds are credited now and the express charge is deducted, but a hold is placed on the account until the maturity date.',
          confirmLabel: 'Express clear',
        },
        successTitle: 'Express-cleared',
        successDetail: (d) => `Credited ${cur(d.balance)} · held ${cur(d.held)} · charge ${cur(d.charged)}`,
      })}>
      {busy ? 'Working…' : 'Express clear'}
    </button>
  );
}

export function ReleaseHoldButton({ no, className = 'btn sm' }: { no: string; className?: string }) {
  const { run, busy } = useRunAction();
  const { cur } = useFormat();
  return (
    <button type="button" className={className} disabled={busy}
      onClick={() => run(() => releaseChequeDepositHoldRequest(no), {
        confirm: { title: 'Release the express hold?', message: 'The cheque has matured — lift the hold so the member can use the funds.', confirmLabel: 'Release hold' },
        successTitle: 'Hold released',
        successDetail: (d) => `Released ${cur(d.held)}`,
      })}>
      {busy ? 'Working…' : 'Release hold'}
    </button>
  );
}

export function BounceButton({ no, className = 'btn sm ghost' }: { no: string; className?: string }) {
  const [open, setOpen] = useState(false);
  return (
    <>
      <button type="button" className={className} onClick={() => setOpen(true)}>Bounce</button>
      {open ? (
        <FormModal
          title="Bounce cheque deposit"
          onClose={() => setOpen(false)}
          onSubmit={(values) => bounceChequeDepositRequest(no, String(values.reason || ''))}
          submitLabel="Mark bounced" submitClass="btn danger"
          successTitle="Cheque bounced" resultStyle="popup"
          successDetail={(d) => `${d.reversed ? 'Early credit reversed. ' : ''}${d.charged ? 'Bouncing charge applied.' : 'No bouncing charge configured.'}`}
        >
          <Field name="reason" label="Reason" type="textarea" required
            hint="Why the bank returned the cheque (e.g. insufficient funds, stale, signature)" />
        </FormModal>
      ) : null}
    </>
  );
}

export function DeleteButton({ no, className = 'btn sm ghost' }: { no: string; className?: string }) {
  const { run, busy } = useRunAction();
  return (
    <button type="button" className={className} disabled={busy}
      onClick={() => run(() => deleteChequeDepositRequest(no), {
        confirm: { title: 'Delete this cheque deposit?', message: 'It is removed permanently. Only an open cheque deposit can be deleted.', confirmLabel: 'Delete' },
        successTitle: 'Deleted',
      })}>
      {busy ? 'Working…' : 'Delete'}
    </button>
  );
}
