'use client';

import { useState } from 'react';
import { FormModal } from '@/components/ui/form-modal';
import { Field } from '@/components/ui/field';
import { useRunAction } from '@/components/ui/run-action';
import {
  makeOrderRequest, submitPurchaseDocumentRequest, cancelPurchaseDocumentApprovalRequest, approvePurchaseDocumentRequest,
  rejectPurchaseDocumentRequest, reopenPurchaseDocumentRequest, postPurchaseDocumentRequest, deletePurchaseDocumentRequest,
  submitPaymentJournalRequest, cancelPaymentJournalApprovalRequest, approvePaymentJournalRequest, rejectPaymentJournalRequest,
  reopenPaymentJournalRequest, postPaymentJournalRequest, deletePaymentJournalRequest,
} from '@/app/actions/payables';

function A({ label, busyLabel, onClick, className = 'btn sm ghost' }: { label: string; busyLabel?: string; onClick: () => void; className?: string }) {
  const { busy } = useRunAction();
  return <button type="button" className={className} disabled={busy} onClick={onClick}>{busy ? busyLabel ?? 'Working…' : label}</button>;
}

/* ------------------------------------------------------------- purchase documents */

export function MakeOrderButton({ no }: { no: string }) {
  const { run } = useRunAction();
  return <A label="Make order" onClick={() => run(() => makeOrderRequest(no), {
    confirm: { title: 'Convert this quote to an order?', message: 'The quote is replaced by a new purchase order.', confirmLabel: 'Make order' },
    successTitle: (d) => `Order ${d.no} created`,
  })} className="btn sm" />;
}

export function SubmitDocButton({ no, kind }: { no: string; kind: 'purchase' | 'payment' }) {
  const { run } = useRunAction();
  const fn = kind === 'purchase' ? submitPurchaseDocumentRequest : submitPaymentJournalRequest;
  return <A label="Send for approval" onClick={() => run(() => fn(no), {
    confirm: { title: 'Send for approval?', message: 'It can no longer be edited while pending.', confirmLabel: 'Send' },
    successTitle: (d) => (d.autoApproved ? (kind === 'purchase' ? 'Released — ready to post' : 'Approved — ready to post') : 'Sent for approval'),
  })} />;
}

export function CancelApprovalButton({ no, kind }: { no: string; kind: 'purchase' | 'payment' }) {
  const { run } = useRunAction();
  const fn = kind === 'purchase' ? cancelPurchaseDocumentApprovalRequest : cancelPaymentJournalApprovalRequest;
  return <A label="Cancel approval" onClick={() => run(() => fn(no), {
    confirm: { title: 'Recall this document?', message: 'It goes back to Open.', confirmLabel: 'Recall' }, successTitle: 'Recalled — back to Open',
  })} />;
}

export function ApproveDocButton({ no, kind }: { no: string; kind: 'purchase' | 'payment' }) {
  const { run } = useRunAction();
  const fn = kind === 'purchase' ? approvePurchaseDocumentRequest : approvePaymentJournalRequest;
  return <A label={kind === 'purchase' ? 'Release' : 'Approve'} className="btn sm" onClick={() => run(() => fn(no), {
    confirm: { title: kind === 'purchase' ? 'Release this document?' : 'Approve this payment journal?', message: 'Nothing moves until it is posted.', confirmLabel: 'OK' },
    successTitle: kind === 'purchase' ? 'Released — ready to post' : 'Approved — ready to post',
  })} />;
}

export function RejectDocButton({ no, kind }: { no: string; kind: 'purchase' | 'payment' }) {
  const [open, setOpen] = useState(false);
  const fn = kind === 'purchase' ? rejectPurchaseDocumentRequest : rejectPaymentJournalRequest;
  return (
    <>
      <button type="button" className="btn sm ghost" onClick={() => setOpen(true)}>Reject</button>
      {open ? (
        <FormModal title="Reject" onClose={() => setOpen(false)} onSubmit={(v) => fn(no, String(v.reason || ''))}
          submitLabel="Reject" submitClass="btn danger" successTitle="Rejected — back to Open" resultStyle="popup">
          <Field name="reason" label="Reason" type="textarea" required />
        </FormModal>
      ) : null}
    </>
  );
}

export function ReopenDocButton({ no, kind }: { no: string; kind: 'purchase' | 'payment' }) {
  const { run } = useRunAction();
  const fn = kind === 'purchase' ? reopenPurchaseDocumentRequest : reopenPaymentJournalRequest;
  return <A label="Reopen" onClick={() => run(() => fn(no), {
    confirm: { title: 'Reopen this document?', message: 'It goes back to Open for amendment.', confirmLabel: 'Reopen' }, successTitle: 'Reopened',
  })} />;
}

export function DeleteDocButton({ no, kind }: { no: string; kind: 'purchase' | 'payment' }) {
  const { run } = useRunAction();
  const fn = kind === 'purchase' ? deletePurchaseDocumentRequest : deletePaymentJournalRequest;
  return <A label="Delete" onClick={() => run(() => fn(no), {
    confirm: { title: 'Delete this document?', message: 'It is removed permanently.', confirmLabel: 'Delete' }, successTitle: 'Deleted',
  })} />;
}

export function PostPurchaseDocButton({ no, isOrder }: { no: string; isOrder: boolean }) {
  const [open, setOpen] = useState(false);
  const { run } = useRunAction();
  const post = (receive: boolean, invoice: boolean) => run(() => postPurchaseDocumentRequest(no, receive, invoice), {
    successTitle: 'Purchase document posted',
    successDetail: (d) => [d.receiptNo && `Receipt ${d.receiptNo}`, d.invoiceNo && `Invoice ${d.invoiceNo}`, d.journalNo && `Journal ${d.journalNo}`].filter(Boolean).join(' · ') || 'Posted',
  });
  if (!isOrder) {
    return <A label="Post" className="btn sm" onClick={() => run(() => postPurchaseDocumentRequest(no, false, true), {
      confirm: { title: 'Post this document?', message: 'The vendor ledger and the G/L move immediately.', confirmLabel: 'Post' },
      successTitle: 'Posted',
      successDetail: (d) => (d.invoiceNo ? `Invoice ${d.invoiceNo}` : d.journalNo ? `Journal ${d.journalNo}` : 'Posted'),
    })} />;
  }
  return (
    <>
      <button type="button" className="btn sm" onClick={() => setOpen(true)}>Post…</button>
      {open ? (
        <FormModal title={`Post order ${no}`} onClose={() => setOpen(false)} onSubmit={async () => ({ ok: true, data: {} })} submitLabel="Close" resultStyle="popup">
          <div className="inline" style={{ gap: 8, flexWrap: 'wrap' }}>
            <button type="button" className="btn" onClick={() => { post(true, true); setOpen(false); }}>Receive and Invoice</button>
            <button type="button" className="btn ghost" onClick={() => { post(true, false); setOpen(false); }}>Receive only</button>
            <button type="button" className="btn ghost" onClick={() => { post(false, true); setOpen(false); }}>Invoice only</button>
          </div>
          <div className="hint">Only the Qty. to Receive / Qty. to Invoice on each line is posted — partial posting is supported.</div>
        </FormModal>
      ) : null}
    </>
  );
}

export function PostPaymentJournalButton({ no }: { no: string }) {
  const { run } = useRunAction();
  return <A label="Post" className="btn sm" onClick={() => run(() => postPaymentJournalRequest(no), {
    confirm: { title: 'Post this payment journal?', message: 'The bank, the vendor ledger and the G/L move immediately.', confirmLabel: 'Post' },
    successTitle: (d) => `Posted — ${d.applied} invoice(s) settled`,
    successDetail: (d) => (d.journalNo ? `Journal ${d.journalNo}` : undefined),
  })} />;
}
