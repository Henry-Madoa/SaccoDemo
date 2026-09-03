'use client';

import { useState, type ReactNode } from 'react';
import { FormModal } from '@/components/ui/form-modal';
import { Field } from '@/components/ui/field';
import { today } from '@/lib/format';
import { createReceiptRequest, updateReceiptRequest, type ReceiptLineDraft } from '@/app/actions/cashMgmt';
import type { ReceiptDetail } from '@/lib/types';

const LINE_TYPES = ['G/L Account', 'Customer', 'Vendor', 'Bank Account'];
type Opt = { code: string; name: string };

export interface ReceiptFormProps {
  banks: { id: number; code: string; name: string; currency_code: string }[];
  accounts: Opt[];
  customers: { no: string; name: string }[];
  vendors: { no: string; name: string }[];
  currencies: { code: string }[];
  payMethods: { code: string }[];
}

const emptyLine = (): ReceiptLineDraft => ({ lineType: 'G/L Account', accountNo: '', description: '', amount: '', appliesToDocNo: '' });

function Body({ p, initial, lines, setLines }: { p: ReceiptFormProps; initial?: ReceiptDetail | null; lines: ReceiptLineDraft[]; setLines: (l: ReceiptLineDraft[]) => void }) {
  const set = (i: number, k: keyof ReceiptLineDraft, v: string) => setLines(lines.map((l, idx) => (idx === i ? { ...l, [k]: v } : l)));
  const picker = (l: ReceiptLineDraft, i: number): ReactNode => {
    const rows = l.lineType === 'Customer' ? p.customers.map((c) => ({ v: c.no, t: `${c.no} — ${c.name}` }))
      : l.lineType === 'Vendor' ? p.vendors.map((c) => ({ v: c.no, t: `${c.no} — ${c.name}` }))
      : l.lineType === 'Bank Account' ? p.banks.map((c) => ({ v: c.code, t: `${c.code} — ${c.name}` }))
      : p.accounts.map((c) => ({ v: c.code, t: `${c.code} — ${c.name}` }));
    return <select value={l.accountNo} onChange={(e) => set(i, 'accountNo', e.target.value)} aria-label="Account"><option value="">…</option>{rows.map((r) => <option key={r.v} value={r.v}>{r.t}</option>)}</select>;
  };
  return (
    <>
      <div className="grid g3">
        <Field name="receiptType" label="Receipt type" type="select" defaultValue={initial?.receipt_type ?? 'G/L Account'} options={LINE_TYPES.map((t) => ({ value: t, label: t }))} />
        <Field name="bankAccountId" label="Bank account (money in)" type="select" required defaultValue={String(initial?.bank_account_id ?? '')}
          options={[{ value: '', label: '…' }, ...p.banks.map((b) => ({ value: String(b.id), label: `${b.code} — ${b.name} (${b.currency_code})` }))]} />
        <Field name="postingDate" label="Posting date" type="date" required defaultValue={initial?.posting_date ?? today()} />
      </div>
      <div className="grid g3">
        <Field name="currencyCode" label="Currency" type="select" defaultValue={initial?.currency_code ?? ''} options={[{ value: '', label: '(bank currency)' }, ...p.currencies.map((c) => ({ value: c.code, label: c.code }))]} />
        <Field name="payModeCode" label="Payment mode" type="select" defaultValue={initial?.pay_mode_code ?? ''} options={[{ value: '', label: '(none)' }, ...p.payMethods.map((m) => ({ value: m.code, label: m.code }))]} />
        <Field name="externalDocumentNo" label="Cheque / M-Pesa ref." defaultValue={initial?.external_document_no ?? ''} />
      </div>
      <div className="grid g2">
        <Field name="manualReceiptNo" label="Manual receipt no." defaultValue={initial?.manual_receipt_no ?? ''} placeholder="Optional" />
        <Field name="description" label="Received from / narration" required defaultValue={initial?.description ?? ''} />
      </div>
      <div className="hint" style={{ marginTop: 8 }}>Lines</div>
      <table>
        <thead><tr><th style={{ width: 110 }}>Type</th><th>Account</th><th>Description</th><th style={{ width: 130 }}>Amount</th><th>Applies to</th><th style={{ width: 32 }} /></tr></thead>
        <tbody>
          {lines.map((l, i) => (
            <tr key={i}>
              <td><select value={l.lineType} onChange={(e) => set(i, 'lineType', e.target.value)} aria-label="Line type">{LINE_TYPES.map((t) => <option key={t} value={t}>{t}</option>)}</select></td>
              <td>{picker(l, i)}</td>
              <td><input value={l.description} onChange={(e) => set(i, 'description', e.target.value)} aria-label="Description" /></td>
              <td><input type="number" step="0.01" min={0} value={l.amount} onChange={(e) => set(i, 'amount', e.target.value)} aria-label="Amount" /></td>
              <td><input value={l.appliesToDocNo} onChange={(e) => set(i, 'appliesToDocNo', e.target.value)} aria-label="Applies to doc" placeholder="Open invoice no." disabled={l.lineType !== 'Customer' && l.lineType !== 'Vendor'} /></td>
              <td><button type="button" className="btn sm ghost" onClick={() => setLines(lines.filter((_, idx) => idx !== i))} aria-label="Remove">×</button></td>
            </tr>
          ))}
        </tbody>
      </table>
      <button type="button" className="btn ghost sm" style={{ marginTop: 8 }} onClick={() => setLines([...lines, emptyLine()])}>Add line</button>
    </>
  );
}

export function NewReceiptButton(p: ReceiptFormProps) {
  const [open, setOpen] = useState(false);
  const [lines, setLines] = useState<ReceiptLineDraft[]>([emptyLine()]);
  return (
    <>
      <button type="button" className="btn" onClick={() => { setLines([emptyLine()]); setOpen(true); }}>New receipt</button>
      {open ? (
        <FormModal title="New receipt" wide onClose={() => setOpen(false)} onSubmit={(v) => createReceiptRequest(v, lines)}
          submitLabel="Create" successTitle="Receipt created" successDetail={(d) => `${d.no} created — submit it for approval`}>
          <Body p={p} lines={lines} setLines={setLines} />
        </FormModal>
      ) : null}
    </>
  );
}

export function EditReceiptButton({ receipt, className = 'btn sm ghost', p }: { receipt: ReceiptDetail; className?: string; p: ReceiptFormProps }) {
  const [open, setOpen] = useState(false);
  const [lines, setLines] = useState<ReceiptLineDraft[]>(() => receipt.lines.length
    ? receipt.lines.map((l) => ({ lineType: l.line_type, accountNo: l.account_no ?? '', description: l.description ?? '', amount: String(l.amount / 100), appliesToDocNo: l.applies_to_doc_no ?? '' }))
    : [emptyLine()]);
  return (
    <>
      <button type="button" className={className} onClick={() => setOpen(true)}>Edit</button>
      {open ? (
        <FormModal title={`Edit ${receipt.no}`} wide onClose={() => setOpen(false)} onSubmit={(v) => updateReceiptRequest(receipt.no, v, lines)}
          submitLabel="Save changes" successTitle="Receipt updated">
          <Body p={p} initial={receipt} lines={lines} setLines={setLines} />
        </FormModal>
      ) : null}
    </>
  );
}
