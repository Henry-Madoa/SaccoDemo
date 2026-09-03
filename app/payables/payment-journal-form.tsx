'use client';

import { useState } from 'react';
import { useRouter } from 'next/navigation';
import { FormModal } from '@/components/ui/form-modal';
import { Field } from '@/components/ui/field';
import { useResultDialog } from '@/components/ui/result-dialog';
import { today } from '@/lib/format';
import {
  requestPaymentJournal, savePaymentJournal, suggestVendorPaymentsRequest, type PaymentJournalLineDraft,
} from '@/app/actions/payables';
import type { PaymentJournalDetail } from '@/lib/types';

type Vend = { id: number; no: string; name: string };
const emptyLine = (): PaymentJournalLineDraft => ({ vendorId: '', amount: '', paymentMethodCode: '', appliesToDocNo: '', externalDocumentNo: '', description: '' });

function Fields({ banks, vendors, paymentMethods, initial, lines, setLines }: {
  banks: { id: number; code: string; name: string }[]; vendors: Vend[]; paymentMethods: { code: string }[];
  initial?: PaymentJournalDetail | null; lines: PaymentJournalLineDraft[]; setLines: (l: PaymentJournalLineDraft[]) => void;
}) {
  const set = (i: number, k: keyof PaymentJournalLineDraft, v: string) => setLines(lines.map((l, idx) => (idx === i ? { ...l, [k]: v } : l)));
  return (
    <>
      <div className="grid g3">
        <Field name="postingDate" label="Posting date" type="date" required defaultValue={initial?.posting_date ?? today()} />
        <Field name="documentDate" label="Document date" type="date" defaultValue={initial?.document_date ?? today()} />
        <Field name="bankAccountId" label="Bank account" type="select" required defaultValue={String(initial?.bank_account_id ?? banks[0]?.id ?? '')}
          options={banks.map((b) => ({ value: b.id, label: `${b.code} — ${b.name}` }))} />
      </div>
      <Field name="description" label="Description" defaultValue={initial?.description ?? ''} placeholder="Optional" />

      <div className="hint" style={{ marginTop: 'calc(var(--sp)*1)' }}>Payment lines</div>
      <table>
        <thead><tr><th>Vendor</th><th style={{ width: 120 }}>Amount</th><th style={{ width: 90 }}>Method</th><th style={{ width: 120 }}>Applies to Inv.</th><th style={{ width: 40 }} /></tr></thead>
        <tbody>
          {lines.map((l, i) => (
            <tr key={i}>
              <td>
                <select value={l.vendorId} onChange={(e) => set(i, 'vendorId', e.target.value)} aria-label="Vendor">
                  <option value="">…</option>{vendors.map((c) => <option key={c.id} value={c.id}>{c.no} — {c.name}</option>)}
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

export function NewPaymentJournalButton({ banks, vendors, paymentMethods }: {
  banks: { id: number; code: string; name: string }[]; vendors: Vend[]; paymentMethods: { code: string }[];
}) {
  const [open, setOpen] = useState(false);
  const [lines, setLines] = useState<PaymentJournalLineDraft[]>([emptyLine()]);
  return (
    <>
      <button type="button" className="btn" onClick={() => { setLines([emptyLine()]); setOpen(true); }}>New payment journal</button>
      {open ? (
        <FormModal title="New payment journal" wide onClose={() => setOpen(false)} onSubmit={(v) => requestPaymentJournal(v, lines)}
          submitLabel="Create" successTitle="Payment journal created" successDetail={(d) => `${d.no} — submit it for approval`}>
          <Fields banks={banks} vendors={vendors} paymentMethods={paymentMethods} lines={lines} setLines={setLines} />
        </FormModal>
      ) : null}
    </>
  );
}

export function EditPaymentJournalButton({ journal, banks, vendors, paymentMethods, className = 'btn ghost sm' }: {
  journal: PaymentJournalDetail; banks: { id: number; code: string; name: string }[]; vendors: Vend[]; paymentMethods: { code: string }[]; className?: string;
}) {
  const [open, setOpen] = useState(false);
  const [lines, setLines] = useState<PaymentJournalLineDraft[]>(() =>
    journal.lines.length ? journal.lines.map((l) => ({
      vendorId: String(l.vendor_id), amount: String(l.amount / 100), paymentMethodCode: l.payment_method_code ?? '',
      appliesToDocNo: l.applies_to_doc_no ?? '', externalDocumentNo: l.external_document_no ?? '', description: l.description ?? '',
    })) : [emptyLine()]);
  return (
    <>
      <button type="button" className={className} onClick={() => setOpen(true)}>Edit</button>
      {open ? (
        <FormModal title={`Edit ${journal.no}`} wide onClose={() => setOpen(false)} onSubmit={(v) => savePaymentJournal(journal.no, v, lines)}
          submitLabel="Save changes" successTitle="Payment journal updated">
          <Fields banks={banks} vendors={vendors} paymentMethods={paymentMethods} initial={journal} lines={lines} setLines={setLines} />
        </FormModal>
      ) : null}
    </>
  );
}

/* --------------------------------------------- Suggest Vendor Payments (BC Report 393) */

export function SuggestVendorPaymentsPanel({ banks, vendors }: {
  banks: { id: number; code: string; name: string }[]; vendors: Vend[];
}) {
  const router = useRouter();
  const showResult = useResultDialog();
  const [lastDate, setLastDate] = useState(today());
  const [bankId, setBankId] = useState(String(banks[0]?.id ?? ''));
  const [vendorId, setVendorId] = useState('');
  const [findDiscounts, setFindDiscounts] = useState(true);
  const [busy, setBusy] = useState(false);

  const run = async () => {
    setBusy(true);
    try {
      const res = await suggestVendorPaymentsRequest({
        lastPaymentDate: lastDate, findPaymentDiscounts: findDiscounts ? 'on' : '',
        bankAccountId: bankId, onlyVendorId: vendorId,
      });
      if (!res.ok) { showResult('Could not suggest payments', res.error, 'err'); return; }
      showResult(`Payment journal ${res.data.no} created`, `${res.data.lineCount} line(s) — review, submit and post`, 'ok');
      router.refresh();
    } finally { setBusy(false); }
  };

  return (
    <div className="grid g3" style={{ alignItems: 'end' }}>
      <Field name="lastPaymentDate" label="Last payment date" type="date" defaultValue={lastDate} onChange={(e) => setLastDate(e.target.value)} />
      <Field name="bankAccountId" label="Bank account" type="select" defaultValue={bankId} onChange={(e) => setBankId(e.target.value)}
        options={banks.map((b) => ({ value: b.id, label: `${b.code} — ${b.name}` }))} />
      <Field name="onlyVendorId" label="Vendor" type="select" defaultValue={vendorId} onChange={(e) => setVendorId(e.target.value)}
        options={[{ value: '', label: 'All vendors' }, ...vendors.map((v) => ({ value: v.id, label: `${v.no} — ${v.name}` }))]} />
      <label className="tiny">Find payment discounts <input type="checkbox" checked={findDiscounts} onChange={(e) => setFindDiscounts(e.target.checked)} /></label>
      <button type="button" className="btn" disabled={busy || !bankId} onClick={run}>{busy ? 'Working…' : 'Suggest vendor payments'}</button>
    </div>
  );
}
