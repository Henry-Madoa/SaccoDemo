'use client';

import { useState } from 'react';
import { FormModal } from '@/components/ui/form-modal';
import { Field } from '@/components/ui/field';
import { useRunAction } from '@/components/ui/run-action';
import {
  makeOrderRequest, submitSalesDocumentRequest, cancelSalesDocumentApprovalRequest, approveSalesDocumentRequest,
  rejectSalesDocumentRequest, reopenSalesDocumentRequest, postSalesDocumentRequest, deleteSalesDocumentRequest,
  submitCashReceiptRequest, cancelCashReceiptApprovalRequest, approveCashReceiptRequest, rejectCashReceiptRequest,
  reopenCashReceiptRequest, postCashReceiptRequest, deleteCashReceiptRequest,
  issueReminderRequest, deleteReminderRequest,
} from '@/app/actions/receivables';

function A({ label, busyLabel, onClick, className = 'btn sm ghost' }: { label: string; busyLabel?: string; onClick: () => void; className?: string }) {
  const { busy } = useRunAction();
  return <button type="button" className={className} disabled={busy} onClick={onClick}>{busy ? busyLabel ?? 'Working…' : label}</button>;
}

/* ------------------------------------------------------------- sales documents */

export function MakeOrderButton({ no }: { no: string }) {
  const { run } = useRunAction();
  return <A label="Make order" onClick={() => run(() => makeOrderRequest(no), {
    confirm: { title: 'Convert this quote to an order?', message: 'The quote is replaced by a new sales order.', confirmLabel: 'Make order' },
    successTitle: (d) => `Order ${d.no} created`,
  })} className="btn sm" />;
}

export function SubmitDocButton({ no, kind }: { no: string; kind: 'sales' | 'cash' }) {
  const { run } = useRunAction();
  const fn = kind === 'sales' ? submitSalesDocumentRequest : submitCashReceiptRequest;
  return <A label="Send for approval" onClick={() => run(() => fn(no), {
    confirm: { title: 'Send for approval?', message: 'It can no longer be edited while pending.', confirmLabel: 'Send' },
    successTitle: (d) => (d.autoApproved ? (kind === 'sales' ? 'Released — ready to post' : 'Approved — ready to post') : 'Sent for approval'),
  })} />;
}

export function CancelApprovalButton({ no, kind }: { no: string; kind: 'sales' | 'cash' }) {
  const { run } = useRunAction();
  const fn = kind === 'sales' ? cancelSalesDocumentApprovalRequest : cancelCashReceiptApprovalRequest;
  return <A label="Cancel approval" onClick={() => run(() => fn(no), {
    confirm: { title: 'Recall this document?', message: 'It goes back to Open.', confirmLabel: 'Recall' }, successTitle: 'Recalled — back to Open',
  })} />;
}

export function ApproveDocButton({ no, kind }: { no: string; kind: 'sales' | 'cash' }) {
  const { run } = useRunAction();
  const fn = kind === 'sales' ? approveSalesDocumentRequest : approveCashReceiptRequest;
  return <A label={kind === 'sales' ? 'Release' : 'Approve'} className="btn sm" onClick={() => run(() => fn(no), {
    confirm: { title: kind === 'sales' ? 'Release this document?' : 'Approve this cash receipt?', message: 'Nothing moves until it is posted.', confirmLabel: 'OK' },
    successTitle: kind === 'sales' ? 'Released — ready to post' : 'Approved — ready to post',
  })} />;
}

export function RejectDocButton({ no, kind }: { no: string; kind: 'sales' | 'cash' }) {
  const [open, setOpen] = useState(false);
  const fn = kind === 'sales' ? rejectSalesDocumentRequest : rejectCashReceiptRequest;
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

export function ReopenDocButton({ no, kind }: { no: string; kind: 'sales' | 'cash' }) {
  const { run } = useRunAction();
  const fn = kind === 'sales' ? reopenSalesDocumentRequest : reopenCashReceiptRequest;
  return <A label="Reopen" onClick={() => run(() => fn(no), {
    confirm: { title: 'Reopen this document?', message: 'It goes back to Open for amendment.', confirmLabel: 'Reopen' }, successTitle: 'Reopened',
  })} />;
}

export function DeleteDocButton({ no, kind }: { no: string; kind: 'sales' | 'cash' | 'reminder' }) {
  const { run } = useRunAction();
  const fn = kind === 'sales' ? deleteSalesDocumentRequest : kind === 'cash' ? deleteCashReceiptRequest : deleteReminderRequest;
  return <A label="Delete" onClick={() => run(() => fn(no), {
    confirm: { title: 'Delete this document?', message: 'It is removed permanently.', confirmLabel: 'Delete' }, successTitle: 'Deleted',
  })} />;
}

export function PostSalesDocButton({ no, isOrder }: { no: string; isOrder: boolean }) {
  const [open, setOpen] = useState(false);
  const { run } = useRunAction();
  const post = (ship: boolean, invoice: boolean) => run(() => postSalesDocumentRequest(no, ship, invoice), {
    successTitle: 'Sales document posted',
    successDetail: (d) => [d.shipmentNo && `Shipment ${d.shipmentNo}`, d.invoiceNo && `Invoice ${d.invoiceNo}`, d.journalNo && `Journal ${d.journalNo}`].filter(Boolean).join(' · ') || 'Posted',
  });
  if (!isOrder) {
    return <A label="Post" className="btn sm" onClick={() => run(() => postSalesDocumentRequest(no, false, true), {
      confirm: { title: 'Post this document?', message: 'The customer ledger and the G/L move immediately.', confirmLabel: 'Post' },
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
            <button type="button" className="btn" onClick={() => { post(true, true); setOpen(false); }}>Ship and Invoice</button>
            <button type="button" className="btn ghost" onClick={() => { post(true, false); setOpen(false); }}>Ship only</button>
            <button type="button" className="btn ghost" onClick={() => { post(false, true); setOpen(false); }}>Invoice only</button>
          </div>
          <div className="hint">Only the Qty. to Ship / Qty. to Invoice on each line is posted — partial posting is supported.</div>
        </FormModal>
      ) : null}
    </>
  );
}

export function PostCashReceiptButton({ no }: { no: string }) {
  const { run } = useRunAction();
  return <A label="Post" className="btn sm" onClick={() => run(() => postCashReceiptRequest(no), {
    confirm: { title: 'Post this cash receipt?', message: 'The bank, the customer ledger and the G/L move immediately.', confirmLabel: 'Post' },
    successTitle: (d) => `Posted — ${d.applied} invoice(s) settled`,
    successDetail: (d) => (d.journalNo ? `Journal ${d.journalNo}` : undefined),
  })} />;
}

export function IssueReminderButton({ no }: { no: string }) {
  const { run } = useRunAction();
  return <A label="Issue" className="btn sm" onClick={() => run(() => issueReminderRequest(no), {
    confirm: { title: 'Issue this reminder?', message: 'Any interest and fee is posted to the customer ledger and the G/L.', confirmLabel: 'Issue' },
    successTitle: 'Issued',
    successDetail: (d) => (d.journalNo ? `Journal ${d.journalNo}` : 'Issued (no charge posted)'),
  })} />;
}
