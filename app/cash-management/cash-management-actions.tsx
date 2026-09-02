'use client';

import { useEffect, useState } from 'react';
import { FormModal } from '@/components/ui/form-modal';
import { Field } from '@/components/ui/field';
import { SearchableSelect } from '@/components/ui/searchable-select';
import { useRunAction } from '@/components/ui/run-action';
import { useFormat } from '@/components/ui/format-provider';
import { FOSA_DOC_TYPES, type FosaDocTypeMeta } from '@/lib/constants';
import {
  requestFosaTransaction, saveFosaTransaction, submitFosaTransactionRequest, cancelFosaApprovalRequest,
  approveFosaTransactionRequest, rejectFosaTransactionRequest, postFosaTransactionRequest,
  deleteFosaTransactionRequest, counterpartyAccountsFor, myFosaAutoAccountFor,
} from '@/app/actions/cashManagement';
import { delegateMyTask } from '@/app/actions/workflows';
import type { BankAccountType, FosaDocumentType, FosaTransactionView } from '@/lib/types';

interface Acct {
  id: number; code: string; name: string; account_type: BankAccountType;
  balance: number; min_capacity: number; max_capacity: number;
}
type AutoAcct = Acct & { role: 'SOURCE' | 'DESTINATION' };

/** How much may actually leave a source account (balance, less any minimum float it must keep)
 *  — null when there is no meaningful ceiling (the external Main Bank). */
const sourceCeiling = (a: Acct | null): number | null =>
  a && (a.account_type === 'TILL' || a.account_type === 'TREASURY')
    ? Math.max(a.balance - (a.min_capacity || 0), 0)
    : null;

/** How much a destination account can still take before hitting its maximum capacity — null
 *  when it has no ceiling. */
const destHeadroom = (a: Acct | null): number | null =>
  a && (a.max_capacity || 0) > 0 ? Math.max(a.max_capacity - a.balance, 0) : null;

function FosaFields({ initial }: { initial?: FosaTransactionView | null }) {
  const { cur } = useFormat();
  const editing = !!initial;
  const [documentType, setDocumentType] = useState<FosaDocumentType>(initial?.document_type ?? 'TREASURY_REQUEST');
  const meta: FosaDocTypeMeta = FOSA_DOC_TYPES.find((d) => d.value === documentType)!;
  const [accts, setAccts] = useState<Acct[]>([]);
  const initialCounterparty = initial
    ? (meta.counterparty === 'SOURCE' ? initial.source_bank_account_id : initial.destination_bank_account_id)
    : null;
  const [counterpartyBankAccountId, setCounterparty] = useState(String(initialCounterparty ?? ''));
  // The end of the movement auto-resolved from the user's own Teller Setup (their till / vault)
  // — carries capacity limits so the Amount can be pre-filled and capped against the real
  // ceiling, not just the raw balance.
  const [autoAcct, setAutoAcct] = useState<AutoAcct | null>(null);

  useEffect(() => {
    let cancelled = false;
    counterpartyAccountsFor(documentType, meta.counterpartyType).then((res) => {
      if (!cancelled && res.ok) setAccts(res.data);
    });
    if (!editing) {
      myFosaAutoAccountFor(documentType).then((res) => {
        if (!cancelled && res.ok) setAutoAcct(res.data);
      });
    }
    return () => { cancelled = true; };
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [documentType]);

  const pickedCp = accts.find((a) => String(a.id) === counterpartyBankAccountId) ?? null;
  const isReturn = documentType === 'TREASURY_RETURN' || documentType === 'SEND_TO_BANK';
  // The movement's two ends — one is the picked counterparty, the other the auto-resolved account.
  const srcAcct: Acct | null = meta.counterparty === 'SOURCE' ? pickedCp : autoAcct;
  const dstAcct: Acct | null = meta.counterparty === 'SOURCE' ? autoAcct : pickedCp;

  // The most that can actually move: not more than the source can spare, nor more headroom than
  // the destination has left. Server enforces the same via assertCapacity().
  const ceilings = [sourceCeiling(srcAcct), destHeadroom(dstAcct)].filter((x): x is number => x != null);
  const maxAmount = ceilings.length ? Math.min(...ceilings) : null;

  // Returns are pre-filled with that maximum ("hand back everything you're allowed to").
  const prefill = !editing && isReturn && maxAmount != null && maxAmount > 0 ? maxAmount : null;

  const amountHint = editing
    ? undefined
    : prefill != null
      ? `Suggested: the most you can return (${cur(prefill)})${srcAcct && (srcAcct.min_capacity || 0) > 0 ? ` — keeps ${srcAcct.name}'s ${cur(srcAcct.min_capacity)} minimum float` : ''}. Reduce it for a partial return.`
      : maxAmount != null
        ? `Cannot exceed ${cur(maxAmount)}`
        : undefined;

  return (
    <>
      <div className="field">
        <label htmlFor="f_documentType">Movement <span className="req">*</span></label>
        {editing ? (
          <>
            {/* A disabled <select> is omitted from FormData — carry the locked value along. */}
            <input type="hidden" name="documentType" value={documentType} />
            <input type="text" value={meta.label} disabled readOnly />
          </>
        ) : (
          <select
            id="f_documentType" name="documentType" value={documentType}
            onChange={(e) => { setDocumentType(e.target.value as FosaDocumentType); setCounterparty(''); }}
          >
            {FOSA_DOC_TYPES.map((d) => <option key={d.value} value={d.value}>{d.label}</option>)}
          </select>
        )}
        <div className="hint">{meta.flow}. The other side of this movement is your own {meta.creatorSetup === 'TELLER' ? 'till' : 'treasury account'}.</div>
      </div>

      <SearchableSelect
        id="f_counterpartyBankAccountId" name="counterpartyBankAccountId"
        label={meta.counterparty === 'SOURCE' ? 'Cash comes from' : 'Cash goes to'} required
        items={accts} getValue={(a) => String(a.id)} getLabel={(a) => `${a.code} — ${a.name}`}
        value={counterpartyBankAccountId} onChange={setCounterparty}
        placeholder={accts.length ? 'Search account…' : 'No eligible account'}
        emptyText="No matching accounts"
        hint={(() => {
          const a = accts.find((x) => String(x.id) === counterpartyBankAccountId);
          return a ? `Balance: ${cur(a.balance)}` : undefined;
        })()}
      />

      <Field
        // Re-mounts (picking up the new defaultValue) whenever the pre-filled amount changes,
        // e.g. switching the movement type from a request to a return.
        key={`amount-${editing ? initial!.no : (prefill != null ? `p${prefill}` : 'none')}`}
        name="amount" label="Amount" type="currency" min={0} required
        max={maxAmount != null ? (maxAmount / 100).toFixed(2) : undefined}
        defaultValue={initial ? initial.amount / 100 : (prefill != null ? prefill / 100 : '')}
        hint={amountHint}
      />

      <div className="note">
        After saving, capture the denomination breakdown on the document, then send it for approval.
      </div>
    </>
  );
}

export function NewFosaTransactionButton() {
  const [open, setOpen] = useState(false);
  return (
    <>
      <button type="button" className="btn" onClick={() => setOpen(true)}>New cash movement</button>
      {open ? (
        <FormModal
          title="New cash movement"
          onClose={() => setOpen(false)}
          onSubmit={requestFosaTransaction}
          submitLabel="Save"
          successTitle="Cash movement captured"
          successDetail={(d) => `${d.no} saved — add the denomination breakdown, then send for approval`}
        >
          <FosaFields />
        </FormModal>
      ) : null}
    </>
  );
}

export function EditButton({ doc, className = 'btn ghost' }: { doc: FosaTransactionView; className?: string }) {
  const [open, setOpen] = useState(false);
  return (
    <>
      <button type="button" className={className} onClick={() => setOpen(true)}>Edit</button>
      {open ? (
        <FormModal
          title={`Edit ${doc.no}`}
          onClose={() => setOpen(false)}
          onSubmit={(values) => saveFosaTransaction(doc.no, values)}
          submitLabel="Save changes"
          successTitle="Cash movement updated"
        >
          <FosaFields initial={doc} />
        </FormModal>
      ) : null}
    </>
  );
}

export function SubmitButton({ no, className = 'btn sm ghost' }: { no: string; className?: string }) {
  const { run, busy } = useRunAction();
  return (
    <button type="button" className={className} disabled={busy}
      onClick={() => run(() => submitFosaTransactionRequest(no), {
        confirm: {
          title: 'Send this cash movement for approval?',
          message: 'It can no longer be edited while pending. The denomination breakdown must balance if the company requires it.',
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
      onClick={() => run(() => cancelFosaApprovalRequest(no), {
        confirm: { title: 'Recall this cash movement?', message: 'It goes back to Open so you can amend and resubmit it.', confirmLabel: 'Recall' },
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
      onClick={() => run(() => approveFosaTransactionRequest(no), {
        confirm: { title: 'Approve this cash movement?', message: 'It becomes ready to post. No cash moves until it is posted.', confirmLabel: 'Approve' },
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
          title="Reject cash movement"
          onClose={() => setOpen(false)}
          onSubmit={(values) => rejectFosaTransactionRequest(no, String(values.reason || ''))}
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
      onClick={() => run(() => postFosaTransactionRequest(no), {
        confirm: { title: 'Post this cash movement?', message: 'The cash moves between the two accounts immediately and a journal is posted. This cannot be undone from here.', confirmLabel: 'Post' },
        successTitle: 'Cash movement posted',
        successDetail: (d) => `${d.journalNo} · ${cur(d.amount)} moved`,
      })}>
      {busy ? 'Working…' : 'Post'}
    </button>
  );
}

export function DeleteButton({ no, className = 'btn sm ghost' }: { no: string; className?: string }) {
  const { run, busy } = useRunAction();
  return (
    <button type="button" className={className} disabled={busy}
      onClick={() => run(() => deleteFosaTransactionRequest(no), {
        confirm: { title: 'Delete this cash movement?', message: 'It is removed permanently. Only an open document can be deleted.', confirmLabel: 'Delete' },
        successTitle: 'Deleted',
      })}>
      {busy ? 'Working…' : 'Delete'}
    </button>
  );
}
