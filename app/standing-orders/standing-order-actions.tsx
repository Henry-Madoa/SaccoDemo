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
  requestStandingOrder, saveStandingOrder, submitStandingOrderRequest, cancelStandingOrderApprovalRequest,
  approveStandingOrderRequest, rejectStandingOrderRequest, terminateStandingOrderRequest,
  freezeStandingOrderRequest, unfreezeStandingOrderRequest, runStandingOrdersNow,
  accountsForStandingOrderSource, accountsForStandingOrderDestination, loansForStandingOrderDestination,
  bankAccountsForStandingOrderDestination, standingOrderChargeCodes, previewStandingOrderChargeAmount,
} from '@/app/actions/standingOrders';
import { delegateMyTask } from '@/app/actions/workflows';
import { STANDING_ORDER_CLASSES, STANDING_ORDER_AMOUNT_TYPES, STANDING_ORDER_RUN_TYPES } from '@/lib/constants';
import { Money } from '@/components/ui/money';
import { useFormat } from '@/components/ui/format-provider';
import type {
  Member, StandingOrderAmountType, StandingOrderClass, StandingOrderRunType, StandingOrderWithDimensions,
  TransactionCharge,
} from '@/lib/types';

export function SubmitButton({ no, className = 'btn sm ghost' }: { no: string; className?: string }) {
  const { run, busy } = useRunAction();
  return (
    <button type="button" className={className} disabled={busy}
      onClick={() => run(() => submitStandingOrderRequest(no), {
        confirm: {
          title: 'Send this standing order for approval?',
          message: 'It will be routed to the configured approver(s) and can no longer be edited while pending.',
          confirmLabel: 'Send for approval',
        },
        successTitle: (d) => (d.autoApproved ? 'Approved — now live' : 'Sent for approval'),
        successDetail: (d) => (d.autoApproved
          ? 'You are the assigned approver, so this was approved automatically and is already running.' : undefined),
      })}>
      {busy ? 'Working…' : 'Send for approval'}
    </button>
  );
}

export function CancelApprovalButton({ no, className = 'btn sm ghost' }: { no: string; className?: string }) {
  const { run, busy } = useRunAction();
  return (
    <button type="button" className={className} disabled={busy}
      onClick={() => run(() => cancelStandingOrderApprovalRequest(no), {
        confirm: {
          title: 'Cancel this approval request?',
          message: 'The order goes back to Open so you can amend and resubmit it.',
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
      onClick={() => run(() => approveStandingOrderRequest(no), {
        confirm: {
          title: 'Approve this standing order?',
          message: 'It goes live immediately — the next scheduled run (or a manual Run now) will start moving money.',
          confirmLabel: 'Approve',
        },
        successTitle: 'Standing order approved — now live',
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
          title="Reject standing order"
          onClose={() => setOpen(false)}
          onSubmit={(values) => rejectStandingOrderRequest(no, String(values.reason || ''))}
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

export function TerminateButton({ no, className = 'btn sm ghost' }: { no: string; className?: string }) {
  const { run, busy } = useRunAction();
  return (
    <button type="button" className={className} disabled={busy}
      onClick={() => run(() => terminateStandingOrderRequest(no), {
        confirm: {
          title: 'Terminate this standing order?',
          message: 'It stops for good — this cannot be undone from here. Set up a new standing order if it needs to resume.',
          confirmLabel: 'Terminate',
        },
        successTitle: 'Standing order terminated',
      })}>
      {busy ? 'Working…' : 'Terminate'}
    </button>
  );
}

export function FreezeButton({ no, className = 'btn sm ghost' }: { no: string; className?: string }) {
  const [open, setOpen] = useState(false);
  return (
    <>
      <button type="button" className={className} onClick={() => setOpen(true)}>Freeze</button>
      {open ? (
        <FormModal
          title="Freeze standing order"
          onClose={() => setOpen(false)}
          onSubmit={(values) => freezeStandingOrderRequest(no, String(values.freezeEndDate || ''))}
          submitLabel="Freeze"
          successTitle="Standing order frozen"
          successDetail={() => 'It resumes automatically once the freeze end date passes.'}
        >
          <Field name="freezeEndDate" label="Freeze until" type="date" required />
        </FormModal>
      ) : null}
    </>
  );
}

export function UnfreezeButton({ no, className = 'btn sm ghost' }: { no: string; className?: string }) {
  const { run, busy } = useRunAction();
  return (
    <button type="button" className={className} disabled={busy}
      onClick={() => run(() => unfreezeStandingOrderRequest(no), { successTitle: 'Standing order unfrozen' })}>
      {busy ? 'Working…' : 'Unfreeze'}
    </button>
  );
}

/** Runs every live, due standing order now — the same runner a Job Queue Entry calls unattended
 *  (Admin Centre → System Automation), just triggered here by a signed-in officer. */
export function RunNowButton({ disabled }: { disabled?: boolean }) {
  const { run, busy } = useRunAction();
  const { cur } = useFormat();
  return (
    <button type="button" className="btn" disabled={disabled || busy}
      onClick={() => run(() => runStandingOrdersNow(), {
        confirm: {
          title: 'Run standing orders now?',
          message: 'Every live standing order that is due today will post immediately. This cannot be undone.',
          confirmLabel: 'Run now',
        },
        successTitle: (d) => (d.posted || d.terminated ? `${d.posted} posted, ${d.terminated} auto-terminated` : 'Nothing was due'),
        successDetail: (d) => (d.totalPosted ? `${cur(d.totalPosted)} moved in total` : undefined),
      })}>
      {busy ? 'Working…' : 'Run now'}
    </button>
  );
}

type EligibleMember = Pick<Member, 'id' | 'member_no' | 'first_name' | 'last_name'>;
type SourceAccount = { id: number; account_no: string; product_name: string; balance: number; hold_amount: number; min_balance: number };
type DestAccount = { id: number; account_no: string; product_name: string };
type DestBankAccount = { id: number; code: string; name: string };
type DestLoan = { id: number; loan_no: string; outstanding_balance: number };

/**
 * The full body of the New/Edit form — member/source account, class-dependent destination,
 * amount-type-dependent amount fields, schedule, and the optional Charge Code, with a live fee
 * preview. Shared by both forms since every field but the member itself stays editable while
 * Open.
 */
function StandingOrderFields({
  members, memberId, setMemberId, initial,
}: {
  members: EligibleMember[];
  memberId: string;
  setMemberId: (v: string) => void;
  initial?: StandingOrderWithDimensions | null;
}) {
  const { cur } = useFormat();
  const [sourceAccounts, setSourceAccounts] = useState<SourceAccount[]>([]);
  const [accountId, setAccountId] = useState(String(initial?.account_id ?? ''));

  const [standingOrderClass, setStandingOrderClass] = useState<StandingOrderClass>(initial?.standing_order_class ?? 'INTERNAL');
  const [destinationMemberId, setDestinationMemberId] = useState(String(initial?.destination_member_id ?? ''));
  const [destAccounts, setDestAccounts] = useState<DestAccount[]>([]);
  const [destinationAccountId, setDestinationAccountId] = useState(String(initial?.destination_account_id ?? ''));
  const [destBankAccounts, setDestBankAccounts] = useState<DestBankAccount[]>([]);
  const [destinationBankAccountId, setDestinationBankAccountId] = useState(String(initial?.destination_bank_account_id ?? ''));
  const [destLoans, setDestLoans] = useState<DestLoan[]>([]);
  const [destinationLoanId, setDestinationLoanId] = useState(String(initial?.destination_loan_id ?? ''));

  const [amountType, setAmountType] = useState<StandingOrderAmountType>(initial?.amount_type ?? 'FIXED');
  const [runType, setRunType] = useState<StandingOrderRunType>(initial?.run_type ?? 'SPECIFIC_DAY');
  const [tillFurtherNotice, setTillFurtherNotice] = useState(!!initial?.till_further_notice);
  const [salaryBased, setSalaryBased] = useState(!!initial?.salary_based);

  const [chargeCodes, setChargeCodes] = useState<TransactionCharge[]>([]);
  const [chargeId, setChargeId] = useState(String(initial?.transaction_charge_id ?? ''));
  const [feeAmount, setFeeAmount] = useState<number | null>(null);

  useEffect(() => {
    let cancelled = false;
    if (!memberId) { setSourceAccounts([]); return; }
    accountsForStandingOrderSource(Number(memberId)).then((res) => {
      if (!cancelled) setSourceAccounts(res.ok ? res.data : []);
    });
    return () => { cancelled = true; };
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [memberId]);

  useEffect(() => {
    let cancelled = false;
    if (standingOrderClass !== 'INTERNAL' || !destinationMemberId) { setDestAccounts([]); return; }
    accountsForStandingOrderDestination(Number(destinationMemberId)).then((res) => {
      if (!cancelled && res.ok) setDestAccounts(res.data);
    });
    return () => { cancelled = true; };
  }, [standingOrderClass, destinationMemberId]);

  useEffect(() => {
    let cancelled = false;
    if (standingOrderClass !== 'LOAN' || !memberId) { setDestLoans([]); return; }
    loansForStandingOrderDestination(Number(memberId)).then((res) => {
      if (!cancelled && res.ok) setDestLoans(res.data);
    });
    return () => { cancelled = true; };
  }, [standingOrderClass, memberId]);

  useEffect(() => {
    if (standingOrderClass !== 'EXTERNAL') { setDestBankAccounts([]); return; }
    bankAccountsForStandingOrderDestination().then((res) => { if (res.ok) setDestBankAccounts(res.data); });
  }, [standingOrderClass]);

  useEffect(() => {
    standingOrderChargeCodes().then((res) => { if (res.ok) setChargeCodes(res.data); });
  }, []);

  useEffect(() => {
    let cancelled = false;
    if (!chargeId) { setFeeAmount(null); return; }
    previewStandingOrderChargeAmount(Number(chargeId)).then((res) => {
      if (!cancelled && res.ok) setFeeAmount(res.data.reduce((sum, c) => sum + c.amount, 0));
    });
    return () => { cancelled = true; };
  }, [chargeId]);

  const sourceAccount = sourceAccounts.find((a) => String(a.id) === accountId);
  const available = sourceAccount ? sourceAccount.balance - sourceAccount.hold_amount - sourceAccount.min_balance : null;

  return (
    <>
      <MemberSelect id="f_memberId" name="memberId" members={members} value={memberId}
        onChange={(id) => { setMemberId(id); setAccountId(''); }} required disabled={!!initial} />

      <SearchableSelect id="f_accountId" name="accountId" label="Source account" required
        items={sourceAccounts} getValue={(a) => String(a.id)} getLabel={(a) => `${a.account_no} — ${a.product_name}`}
        value={accountId} onChange={setAccountId}
        placeholder={sourceAccounts.length ? 'Search account…' : 'No eligible account for this member'}
        emptyText="No matching accounts"
        hint={sourceAccount ? `Available balance: ${cur(Math.max(available ?? 0, 0))}` : undefined} />

      <div className="field" style={{ marginTop: 'calc(var(--sp)*1.5)' }}>
        <label htmlFor="f_standingOrderClass">What should this do <span className="req">*</span></label>
        <select id="f_standingOrderClass" name="standingOrderClass" required value={standingOrderClass}
          onChange={(e) => setStandingOrderClass(e.target.value as StandingOrderClass)}>
          {STANDING_ORDER_CLASSES.map((c) => <option key={c.value} value={c.value}>{c.label}</option>)}
        </select>
      </div>

      {standingOrderClass === 'INTERNAL' ? (
        <div className="grid g2" style={{ marginTop: 'calc(var(--sp)*1.5)' }}>
          <MemberSelect id="f_destinationMemberId" name="destinationMemberId" label="Destination member" members={members}
            value={destinationMemberId} onChange={(id) => { setDestinationMemberId(id); setDestinationAccountId(''); }} required />
          <SearchableSelect id="f_destinationAccountId" name="destinationAccountId" label="Destination account" required
            disabled={!destinationMemberId} items={destAccounts} getValue={(a) => String(a.id)}
            getLabel={(a) => `${a.account_no} — ${a.product_name}`}
            value={destinationAccountId} onChange={setDestinationAccountId}
            placeholder="Search account…" emptyText="No matching accounts" />
        </div>
      ) : standingOrderClass === 'EXTERNAL' ? (
        <SearchableSelect id="f_destinationBankAccountId" name="destinationBankAccountId"
          label="Pay through (Bank/Cashbook)" required
          items={destBankAccounts} getValue={(a) => String(a.id)} getLabel={(a) => `${a.code} — ${a.name}`}
          value={destinationBankAccountId} onChange={setDestinationBankAccountId}
          placeholder="Search bank/cashbook account…" emptyText="No matching accounts"
          hint="The posting description below carries the payment reference — this port has no separate EFT recipient fields."
          style={{ marginTop: 'calc(var(--sp)*1.5)' }} />
      ) : (
        <SearchableSelect id="f_destinationLoanId" name="destinationLoanId" label="Loan to repay" required
          disabled={!memberId} items={destLoans} getValue={(l) => String(l.id)}
          getLabel={(l) => `${l.loan_no} — outstanding ${cur(l.outstanding_balance)}`}
          value={destinationLoanId} onChange={setDestinationLoanId}
          placeholder={destLoans.length ? 'Search loan…' : 'No disbursed loan for this member'}
          emptyText="No matching loans" style={{ marginTop: 'calc(var(--sp)*1.5)' }} />
      )}

      <Field name="postingDescription" label="Posting description" required defaultValue={initial?.posting_description ?? ''} />

      <div className="field" style={{ marginTop: 'calc(var(--sp)*1.5)' }}>
        <label htmlFor="f_amountType">Amount type <span className="req">*</span></label>
        <select id="f_amountType" name="amountType" required value={amountType}
          onChange={(e) => setAmountType(e.target.value as StandingOrderAmountType)}>
          {STANDING_ORDER_AMOUNT_TYPES.map((t) => <option key={t.value} value={t.value}>{t.label}</option>)}
        </select>
      </div>

      {amountType === 'FIXED' ? (
        <Field name="amount" label="Amount" type="number" step="0.01" required
          defaultValue={initial ? initial.amount / 100 : ''} />
      ) : null}
      {amountType === 'AMOUNT_BASED' ? (
        <Field name="amountLimit" label="Amount limit" type="number" step="0.01" required
          defaultValue={initial ? initial.amount_limit / 100 : ''}
          hint="Once the source account's available balance reaches this, the whole balance sweeps" />
      ) : null}

      <div style={{ marginTop: 'calc(var(--sp)*1.5)' }}>
        <Field name="salaryBased" label="Salary based" type="checkbox" defaultValue={salaryBased ? 1 : 0}
          hint="Recovered only through Checkoff & Salary Processing's Calculate step, matched by class — never by the ordinary daily run."
          onChange={(e) => setSalaryBased((e.target as HTMLInputElement).checked)} />
      </div>

      {amountType === 'FIXED' && !salaryBased ? (
        <div className="grid g2" style={{ marginTop: 'calc(var(--sp)*1.5)' }}>
          <div className="field">
            <label htmlFor="f_runType">Run</label>
            <select id="f_runType" name="runType" value={runType} onChange={(e) => setRunType(e.target.value as StandingOrderRunType)}>
              {STANDING_ORDER_RUN_TYPES.map((t) => <option key={t.value} value={t.value}>{t.label}</option>)}
            </select>
          </div>
          {runType === 'SPECIFIC_DAY' ? (
            <Field name="runFromDay" label="Day of month" type="number" min={1} required
              defaultValue={initial?.run_from_day ?? 1} />
          ) : null}
        </div>
      ) : null}

      <div className="grid g2" style={{ marginTop: 'calc(var(--sp)*1.5)' }}>
        <Field name="startDate" label="Start date" type="date" required defaultValue={initial?.start_date ?? ''} />
        <Field name="tillFurtherNotice" label="Till further notice" type="checkbox"
          defaultValue={tillFurtherNotice ? 1 : 0}
          onChange={(e) => setTillFurtherNotice((e.target as HTMLInputElement).checked)} />
      </div>
      {!tillFurtherNotice ? (
        <Field name="periodMonths" label="Period (months)" type="number" min={1} required
          defaultValue={initial?.period_months ?? ''} />
      ) : null}

      <div className="grid g2" style={{ marginTop: 'calc(var(--sp)*1.5)' }}>
        <SearchableSelect id="f_transactionChargeId" name="transactionChargeId" label="Charge code"
          items={chargeCodes} getValue={(c) => String(c.id)} getLabel={(c) => `${c.code} — ${c.description}`}
          value={chargeId} onChange={setChargeId} placeholder="No charge" emptyText="No matching charges" />
        {chargeId ? (
          <div className="note" style={{ alignSelf: 'end', paddingBottom: 8 }}>
            Charge amount: <b>{feeAmount != null ? cur(feeAmount) : '…'}</b> (deducted from the source account on top of each posting)
          </div>
        ) : null}
      </div>
    </>
  );
}

function NewRequestForm({ members, onClose }: { members: EligibleMember[]; onClose: () => void }) {
  const [memberId, setMemberId] = useState('');
  return (
    <FormModal
      title="New standing order" wide
      onClose={onClose}
      onSubmit={requestStandingOrder}
      submitLabel="Save order"
      successTitle="Standing order captured"
      successDetail={(d) => `${d.no} saved — send it for approval when you're ready`}
    >
      <StandingOrderFields members={members} memberId={memberId} setMemberId={setMemberId} />
    </FormModal>
  );
}

export function EditButton({ order, members, className = 'btn sm ghost' }: {
  order: StandingOrderWithDimensions;
  members: EligibleMember[];
  className?: string;
}) {
  const [open, setOpen] = useState(false);
  const [memberId, setMemberId] = useState(String(order.member_id));
  return (
    <>
      <button type="button" className={className} onClick={() => setOpen(true)}>Edit</button>
      {open ? (
        <FormModal
          title={`Edit ${order.no}`} wide
          onClose={() => setOpen(false)}
          onSubmit={(values) => saveStandingOrder(order.no, values)}
          submitLabel="Save changes"
          successTitle="Standing order updated"
        >
          <StandingOrderFields members={members} memberId={memberId} setMemberId={setMemberId} initial={order} />
        </FormModal>
      ) : null}
    </>
  );
}

export function NewStandingOrderButton({ members }: { members: EligibleMember[] }) {
  const [open, setOpen] = useState(false);
  return (
    <>
      <button type="button" className="btn" onClick={() => setOpen(true)}>New standing order</button>
      {open ? <NewRequestForm members={members} onClose={() => setOpen(false)} /> : null}
    </>
  );
}
