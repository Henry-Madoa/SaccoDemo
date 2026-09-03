'use client';

import { useState } from 'react';
import { FormModal } from '@/components/ui/form-modal';
import { Field } from '@/components/ui/field';
import { today } from '@/lib/format';
import { requestCashReceipt, saveCashReceipt, type CashReceiptLineDraft } from '@/app/actions/receivables';
import type { CashReceiptDetail } from '@/lib/types';

type Cust = { id: number; no: string; name: string };
const emptyLine = (): CashReceiptLineDraft => ({ customerId: '', amount: '', paymentMethodCode: '', appliesToDocNo: '', externalDocumentNo: '', description: '' });

function Fields({ banks, customers, paymentMethods, initial, lines, setLines }: {
  banks: { id: number; code: string; name: string }[]; customers: Cust[]; paymentMethods: { code: string }[];
  initial?: CashReceiptDetail | null; lines: CashReceiptLineDraft[]; setLines: (l: CashReceiptLineDraft[]) => void;
}) {
  const set = (i: number, k: keyof CashReceiptLineDraft, v: string) => setLines(lines.map((l, idx) => (idx === i ? { ...l, [k]: v } : l)));
  return (
    <>
      <div className="grid g3">
        <Field name="postingDate" label="Posting date" type="date" required defaultValue={initial?.posting_date ?? today()} />
        <Field name="documentDate" label="Document date" type="date" defaultValue={initial?.document_date ?? today()} />
        <Field name="bankAccountId" label="Bank account" type="select" required defaultValue={String(initial?.bank_account_id ?? banks[0]?.id ?? '')}
          options={banks.map((b) => ({ value: b.id, label: `${b.code} — ${b.name}` }))} />
      </div>
      <Field name="description" label="Description" defaultValue={initial?.description ?? ''} placeholder="Optional" />

      <div className="hint" style={{ marginTop: 'calc(var(--sp)*1)' }}>Receipt lines</div>
      <table>
        <thead><tr><th>Customer</th><th style={{ width: 120 }}>Amount</th><th style={{ width: 90 }}>Method</th><th style={{ width: 120 }}>Applies to Inv.</th><th style={{ width: 40 }} /></tr></thead>
        <tbody>
          {lines.map((l, i) => (
            <tr key={i}>
              <td>
                <select value={l.customerId} onChange={(e) => set(i, 'customerId', e.target.value)} aria-label="Customer">
                  <option value="">…</option>{customers.map((c) => <option key={c.id} value={c.id}>{c.no} — {c.name}</option>)}
                </select>
              </td>
              <td><input type="number" step="0.01" min={0} value={l.amount} onChange={(e) => set(i, 'amount', e.target.value)} aria-label="Amount" /></td>
              <td>
                <select value={l.paymentMethodCode} onChange={(e) => set(i, 'paymentMethodCode', e.target.value)} aria-label="Method">
                  <option value="">…</option>{paymentMethods.map((m) => <option key={m.code} value={m.code}>{m.code}</option>)}
                </select>
              </td>
              <td><input value={l.appliesToDocNo} onChange={(e) => set(i, 'appliesToDocNo', e.target.value)} aria-label="Applies to" placeholder="oldest first" /></td>
              <td><button type="button" className="btn sm ghost" onClick={() => setLines(lines.filter((_, idx) => idx !== i))} aria-label="Remove">×</button></td>
            </tr>
          ))}
        </tbody>
      </table>
      <button type="button" className="btn ghost sm" style={{ marginTop: 8 }} onClick={() => setLines([...lines, emptyLine()])}>Add line</button>
    </>
  );
}

export function NewCashReceiptButton({ banks, customers, paymentMethods }: {
  banks: { id: number; code: string; name: string }[]; customers: Cust[]; paymentMethods: { code: string }[];
}) {
  const [open, setOpen] = useState(false);
  const [lines, setLines] = useState<CashReceiptLineDraft[]>([emptyLine()]);
  return (
    <>
      <button type="button" className="btn" onClick={() => { setLines([emptyLine()]); setOpen(true); }}>New cash receipt</button>
      {open ? (
        <FormModal title="New cash receipt" wide onClose={() => setOpen(false)} onSubmit={(v) => requestCashReceipt(v, lines)}
          submitLabel="Create" successTitle="Cash receipt created" successDetail={(d) => `${d.no} — submit it for approval`}>
          <Fields banks={banks} customers={customers} paymentMethods={paymentMethods} lines={lines} setLines={setLines} />
        </FormModal>
      ) : null}
    </>
  );
}

export function EditCashReceiptButton({ receipt, banks, customers, paymentMethods, className = 'btn ghost sm' }: {
  receipt: CashReceiptDetail; banks: { id: number; code: string; name: string }[]; customers: Cust[]; paymentMethods: { code: string }[]; className?: string;
}) {
  const [open, setOpen] = useState(false);
  const [lines, setLines] = useState<CashReceiptLineDraft[]>(() =>
    receipt.lines.length ? receipt.lines.map((l) => ({
      customerId: String(l.customer_id), amount: String(l.amount / 100), paymentMethodCode: l.payment_method_code ?? '',
      appliesToDocNo: l.applies_to_doc_no ?? '', externalDocumentNo: l.external_document_no ?? '', description: l.description ?? '',
    })) : [emptyLine()]);
  return (
    <>
      <button type="button" className={className} onClick={() => setOpen(true)}>Edit</button>
      {open ? (
        <FormModal title={`Edit ${receipt.no}`} wide onClose={() => setOpen(false)} onSubmit={(v) => saveCashReceipt(receipt.no, v, lines)}
          submitLabel="Save changes" successTitle="Cash receipt updated">
          <Fields banks={banks} customers={customers} paymentMethods={paymentMethods} initial={receipt} lines={lines} setLines={setLines} />
        </FormModal>
      ) : null}
    </>
  );
}
