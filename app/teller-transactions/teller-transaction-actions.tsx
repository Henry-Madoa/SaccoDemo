'use client';

import { useEffect, useState } from 'react';
import { FormModal } from '@/components/ui/form-modal';
import { Field } from '@/components/ui/field';
import { MemberSelect } from '@/components/ui/member-select';
import { SearchableSelect } from '@/components/ui/searchable-select';
import { useRunAction } from '@/components/ui/run-action';
import { useFormat } from '@/components/ui/format-provider';
import {
  requestTellerTransaction, saveTellerTransaction, submitTellerTransactionRequest,
  cancelTellerTransactionApprovalRequest, approveTellerTransactionRequest, rejectTellerTransactionRequest,
  postTellerTransactionRequest, deleteTellerTransactionRequest, resendTellerSlip, accountsForTellerTransaction,
} from '@/app/actions/tellerTransactions';
import { delegateMyTask } from '@/app/actions/workflows';
import type { Member, SavingsAccountForDebit, TellerTransactionType, TellerTransactionView } from '@/lib/types';

type EligibleMember = Pick<Member, 'id' | 'member_no' | 'first_name' | 'last_name'>;

function TxnFields({ members, initial }: { members: EligibleMember[]; initial?: TellerTransactionView | null }) {
  const { cur } = useFormat();
  const editing = !!initial;
  const [transactionType, setTransactionType] = useState<TellerTransactionType>(initial?.transaction_type ?? 'CASH_DEPOSIT');
  const [memberId, setMemberId] = useState(String(initial?.member_id ?? ''));
  const [accounts, setAccounts] = useState<SavingsAccountForDebit[]>([]);
  const [savingsAccountId, setSavingsAccountId] = useState(String(initial?.savings_account_id ?? ''));

  useEffect(() => {
    let cancelled = false;
    if (!memberId) { setAccounts([]); return; }
    accountsForTellerTransaction(Number(memberId)).then((res) => {
      if (!cancelled && res.ok) setAccounts(res.data);
    });
    return () => { cancelled = true; };
  }, [memberId]);

  const acct = accounts.find((a) => String(a.id) === savingsAccountId);
  const available = acct ? Math.max(acct.balance - acct.hold_amount - acct.min_balance, 0) : null;
  const isDeposit = transactionType === 'CASH_DEPOSIT';

  return (
    <>
      <div className="field">
        <label htmlFor="f_transactionType">Transaction <span className="req">*</span></label>
        {editing ? (
          <>
            {/* A disabled <select> is omitted from FormData, so carry the locked value in a
                hidden input the server still receives. */}
            <input type="hidden" name="transactionType" value={transactionType} />
            <input type="text" value={isDeposit ? 'Cash Deposit' : 'Cash Withdrawal'} disabled readOnly />
          </>
        ) : (
          <select id="f_transactionType" name="transactionType" value={transactionType}
            onChange={(e) => setTransactionType(e.target.value as TellerTransactionType)}>
            <option value="CASH_DEPOSIT">Cash Deposit</option>
            <option value="CASH_WITHDRAWAL">Cash Withdrawal</option>
          </select>
        )}
      </div>

      <MemberSelect id="f_memberId" name="memberId" members={members} value={memberId}
        onChange={(id) => { setMemberId(id); setSavingsAccountId(''); }} required disabled={editing} />

      <SearchableSelect id="f_savingsAccountId" name="savingsAccountId" label="Account" required
        items={accounts} getValue={(a) => String(a.id)} getLabel={(a) => `${a.account_no} — ${a.product_name}`}
        value={savingsAccountId} onChange={setSavingsAccountId}
        placeholder={accounts.length ? 'Search account…' : 'No withdrawable account for this member'}
        emptyText="No matching accounts"
        hint={acct ? `Balance ${cur(acct.balance)} · available ${cur(available ?? 0)}` : undefined} />

      <Field name="amount" label="Amount" type="currency" min={0} required
        defaultValue={initial ? initial.amount / 100 : ''} />

      {isDeposit ? (
        <Field name="sourceOfFunds" label="Source of funds" required
          defaultValue={initial?.source_of_funds ?? ''} placeholder="e.g. Salary, business takings" />
      ) : null}

      <div className="grid g2">
        <Field name="transactedByName" label="Transacted by (name)"
          defaultValue={initial?.transacted_by_name ?? ''} placeholder="Person at the counter" />
        <Field name="transactedByIdNo" label="ID number"
          defaultValue={initial?.transacted_by_id_no ?? ''} />
      </div>

      <div className="note">
        Within your approval limit this posts immediately and emails the member a slip; above it,
        it is sent for approval first.
      </div>
    </>
  );
}

export function NewTellerTransactionButton({ members }: { members: EligibleMember[] }) {
  const [open, setOpen] = useState(false);
  return (
    <>
      <button type="button" className="btn" onClick={() => setOpen(true)}>New transaction</button>
      {open ? (
        <FormModal
          title="New teller transaction" wide
          onClose={() => setOpen(false)}
          onSubmit={requestTellerTransaction}
          submitLabel="Save &amp; post"
          successTitle="Transaction processed"
          successDetail={(d) => (d.posted
            ? `${d.no} posted — ${d.journalNo}${d.emailed ? ' · slip emailed to member' : ''}`
            : d.approvalRequired ? `${d.no} — above your approval limit, sent for approval` : `${d.no} captured`)}
          resultStyle="popup"
        >
          <TxnFields members={members} />
        </FormModal>
      ) : null}
    </>
  );
}

export function EditButton({ doc, members, className = 'btn ghost' }: {
  doc: TellerTransactionView; members: EligibleMember[]; className?: string;
}) {
  const [open, setOpen] = useState(false);
  return (
    <>
      <button type="button" className={className} onClick={() => setOpen(true)}>Edit</button>
      {open ? (
        <FormModal
          title={`Edit ${doc.no}`} wide
          onClose={() => setOpen(false)}
          onSubmit={(values) => saveTellerTransaction(doc.no, values)}
          submitLabel="Save changes"
          successTitle="Transaction updated"
        >
          <TxnFields members={members} initial={doc} />
        </FormModal>
      ) : null}
    </>
  );
}

export function SubmitButton({ no, className = 'btn sm ghost' }: { no: string; className?: string }) {
  const { run, busy } = useRunAction();
  return (
    <button type="button" className={className} disabled={busy}
      onClick={() => run(() => submitTellerTransactionRequest(no), {
        confirm: { title: 'Send for approval?', message: 'This transaction is above your approval limit. It can no longer be edited while pending.', confirmLabel: 'Send for approval' },
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
      onClick={() => run(() => cancelTellerTransactionApprovalRequest(no), {
        confirm: { title: 'Recall this transaction?', message: 'It goes back to Open so you can amend and resubmit it.', confirmLabel: 'Recall' },
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
      onClick={() => run(() => approveTellerTransactionRequest(no), {
        confirm: { title: 'Approve this transaction?', message: 'It becomes ready for the teller to post. No money moves until it is posted.', confirmLabel: 'Approve' },
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
          title="Reject transaction"
          onClose={() => setOpen(false)}
          onSubmit={(values) => rejectTellerTransactionRequest(no, String(values.reason || ''))}
          submitLabel="Reject" submitClass="btn danger"
          successTitle="Rejected — back to Open" resultStyle="popup"
        >
          <Field name="reason" label="Reason" type="textarea" required />
        </FormModal>
      ) : null}
    </>
  );
}

export function PostButton({ no, className = 'btn sm' }: { no: string; className?: string }) {
  const { run, busy } = useRunAction();
  const { cur } = useFormat();
  return (
    <button type="button" className={className} disabled={busy}
      onClick={() => run(() => postTellerTransactionRequest(no), {
        confirm: { title: 'Post this transaction?', message: 'The money moves immediately and the member is emailed a slip. This cannot be undone from here.', confirmLabel: 'Post' },
        successTitle: 'Posted',
        successDetail: (d) => `${d.journalNo} · new balance ${cur(d.balance)}${d.emailed ? ' · slip emailed' : ''}`,
      })}>
      {busy ? 'Working…' : 'Post'}
    </button>
  );
}

export function DeleteButton({ no, className = 'btn sm ghost' }: { no: string; className?: string }) {
  const { run, busy } = useRunAction();
  return (
    <button type="button" className={className} disabled={busy}
      onClick={() => run(() => deleteTellerTransactionRequest(no), {
        confirm: { title: 'Delete this transaction?', message: 'It is removed permanently. Only an open transaction can be deleted.', confirmLabel: 'Delete' },
        successTitle: 'Deleted',
      })}>
      {busy ? 'Working…' : 'Delete'}
    </button>
  );
}

export function ResendSlipButton({ no, className = 'btn sm ghost' }: { no: string; className?: string }) {
  const { run, busy } = useRunAction();
  return (
    <button type="button" className={className} disabled={busy}
      onClick={() => run(() => resendTellerSlip(no), {
        successTitle: (d) => (d.emailed ? 'Slip emailed to member' : 'No email address on file for this member'),
      })}>
      {busy ? 'Working…' : 'Email slip to member'}
    </button>
  );
}
