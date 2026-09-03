'use client';

import { useState, type ReactNode } from 'react';
import { FormModal } from '@/components/ui/form-modal';
import { Field } from '@/components/ui/field';
import { SearchableSelect } from '@/components/ui/searchable-select';
import { today } from '@/lib/format';
import { requestSalesDocument, saveSalesDocument, type SalesLineDraft } from '@/app/actions/receivables';
import type { PaymentMethod, PaymentTerms, SalesDocumentDetail, SalesDocumentType } from '@/lib/types';

type EligibleCustomer = { id: number; no: string; name: string; blocked: string; payment_terms_code: string | null };

const LINE_TYPES = ['G/L Account', 'Item', 'Fixed Asset', 'Comment'];
const emptyLine = (): SalesLineDraft => ({
  type: 'G/L Account', no: '', description: '', quantity: '1', unitPrice: '', lineDiscountPct: '',
  locationCode: '', faDepreciationBookCode: '',
});

function DocFields({ documentType, customers, paymentTerms, paymentMethods, accounts, items, fixedAssets, locations, initial, lines, setLines }: {
  documentType: SalesDocumentType;
  customers: EligibleCustomer[]; paymentTerms: PaymentTerms[]; paymentMethods: PaymentMethod[];
  accounts: { code: string; name: string }[]; items: { no: string; description: string }[];
  fixedAssets: { no: string; description: string }[]; locations: { code: string; name: string }[];
  initial?: SalesDocumentDetail | null; lines: SalesLineDraft[]; setLines: (l: SalesLineDraft[]) => void;
}) {
  const editing = !!initial;
  const [customerId, setCustomerId] = useState(String(initial?.customer_id ?? ''));
  const set = (i: number, k: keyof SalesLineDraft, v: string) => setLines(lines.map((l, idx) => (idx === i ? { ...l, [k]: v } : l)));

  return (
    <>
      <input type="hidden" name="documentType" value={documentType} />
      <div className="grid g2">
        <SearchableSelect
          name="customerId" label="Customer" required items={customers} value={customerId} disabled={editing}
          getValue={(c) => String(c.id)} getLabel={(c) => `${c.no} — ${c.name}${c.blocked ? ` (blocked: ${c.blocked})` : ''}`}
          onChange={setCustomerId} placeholder="Search customer…" emptyText="No matching customers"
        />
        <Field name="postingDate" label="Posting date" type="date" required defaultValue={initial?.posting_date ?? today()} />
      </div>
      <div className="grid g3">
        <Field name="documentDate" label="Document date" type="date" defaultValue={initial?.document_date ?? today()} />
        <Field name="paymentTermsCode" label="Payment terms" type="select" defaultValue={initial?.payment_terms_code ?? ''}
          options={[{ value: '', label: '(from customer)' }, ...paymentTerms.map((p) => ({ value: p.code, label: p.code }))]} />
        <Field name="paymentMethodCode" label="Payment method" type="select" defaultValue={initial?.payment_method_code ?? ''}
          options={[{ value: '', label: '(none)' }, ...paymentMethods.map((p) => ({ value: p.code, label: p.code }))]} />
      </div>
      <Field name="yourReference" label="Your reference" defaultValue={initial?.your_reference ?? ''} placeholder="External document no. (optional)" />

      <div className="hint" style={{ marginTop: 'calc(var(--sp)*1)' }}>Lines</div>
      <table>
        <thead>
          <tr><th style={{ width: 110 }}>Type</th><th>No.</th><th>Description</th><th style={{ width: 70 }}>Qty</th><th style={{ width: 110 }}>Unit price</th><th style={{ width: 60 }}>Disc %</th><th style={{ width: 40 }} /></tr>
        </thead>
        <tbody>
          {lines.map((l, i) => (
            <tr key={i}>
              <td>
                <select value={l.type} onChange={(e) => set(i, 'type', e.target.value)} aria-label="Line type">
                  {LINE_TYPES.map((t) => <option key={t} value={t}>{t}</option>)}
                </select>
              </td>
              <td>
                {l.type === 'Comment' ? null
                  : l.type === 'G/L Account'
                    ? <select value={l.no} onChange={(e) => set(i, 'no', e.target.value)} aria-label="Account"><option value="">…</option>{accounts.map((a) => <option key={a.code} value={a.code}>{a.code} — {a.name}</option>)}</select>
                    : l.type === 'Item'
                      ? <select value={l.no} onChange={(e) => set(i, 'no', e.target.value)} aria-label="Item"><option value="">…</option>{items.map((a) => <option key={a.no} value={a.no}>{a.no} — {a.description}</option>)}</select>
                      : <select value={l.no} onChange={(e) => set(i, 'no', e.target.value)} aria-label="Fixed asset"><option value="">…</option>{fixedAssets.map((a) => <option key={a.no} value={a.no}>{a.no} — {a.description}</option>)}</select>}
              </td>
              <td><input value={l.description} onChange={(e) => set(i, 'description', e.target.value)} aria-label="Description" /></td>
              <td><input type="number" step="0.01" min={0} value={l.quantity} onChange={(e) => set(i, 'quantity', e.target.value)} aria-label="Quantity" disabled={l.type === 'Comment' || l.type === 'Fixed Asset'} /></td>
              <td><input type="number" step="0.01" min={0} value={l.unitPrice} onChange={(e) => set(i, 'unitPrice', e.target.value)} aria-label="Unit price" disabled={l.type === 'Comment'} placeholder={l.type === 'Fixed Asset' ? 'proceeds' : ''} /></td>
              <td><input type="number" step="0.01" min={0} max={100} value={l.lineDiscountPct} onChange={(e) => set(i, 'lineDiscountPct', e.target.value)} aria-label="Discount %" disabled={l.type === 'Comment'} /></td>
              <td><button type="button" className="btn sm ghost" onClick={() => setLines(lines.filter((_, idx) => idx !== i))} aria-label="Remove">×</button></td>
            </tr>
          ))}
          {lines.some((l) => l.type === 'Item') ? (
            <tr>
              <td colSpan={7} className="tiny">
                Item lines need a location:{' '}
                {lines.map((l, i) => (l.type === 'Item' ? (
                  <span key={i}>
                    line {i + 1}:{' '}
                    <select value={l.locationCode} onChange={(e) => set(i, 'locationCode', e.target.value)} aria-label="Location">
                      <option value="">…</option>{locations.map((loc) => <option key={loc.code} value={loc.code}>{loc.code}</option>)}
                    </select>{' '}
                  </span>
                ) : null))}
              </td>
            </tr>
          ) : null}
        </tbody>
      </table>
      <button type="button" className="btn ghost sm" style={{ marginTop: 8 }} onClick={() => setLines([...lines, emptyLine()])}>Add line</button>
    </>
  );
}

export function NewSalesDocumentButton({ documentType, ...rest }: {
  documentType: SalesDocumentType;
  customers: EligibleCustomer[]; paymentTerms: PaymentTerms[]; paymentMethods: PaymentMethod[];
  accounts: { code: string; name: string }[]; items: { no: string; description: string }[];
  fixedAssets: { no: string; description: string }[]; locations: { code: string; name: string }[];
}) {
  const [open, setOpen] = useState(false);
  const [lines, setLines] = useState<SalesLineDraft[]>([emptyLine()]);
  return (
    <>
      <button type="button" className="btn" onClick={() => { setLines([emptyLine()]); setOpen(true); }}>New {documentType.toLowerCase()}</button>
      {open ? (
        <FormModal
          title={`New sales ${documentType.toLowerCase()}`} wide
          onClose={() => setOpen(false)}
          onSubmit={(v) => requestSalesDocument(v, lines)}
          submitLabel="Create" successTitle="Sales document created"
          successDetail={(d) => `${d.no} created — submit it for approval`}
        >
          <DocFields documentType={documentType} {...rest} lines={lines} setLines={setLines} />
        </FormModal>
      ) : null}
    </>
  );
}

export function EditSalesDocumentButton({ doc, documentType, className = 'btn ghost sm', ...rest }: {
  doc: SalesDocumentDetail; documentType: SalesDocumentType; className?: string;
  customers: EligibleCustomer[]; paymentTerms: PaymentTerms[]; paymentMethods: PaymentMethod[];
  accounts: { code: string; name: string }[]; items: { no: string; description: string }[];
  fixedAssets: { no: string; description: string }[]; locations: { code: string; name: string }[];
}) {
  const [open, setOpen] = useState(false);
  const [lines, setLines] = useState<SalesLineDraft[]>(() =>
    doc.lines.length
      ? doc.lines.map((l) => ({
        type: l.type, no: l.no ?? '', description: l.description ?? '', quantity: String(l.quantity),
        unitPrice: String(l.unit_price / 100), lineDiscountPct: String(l.line_discount_pct),
        locationCode: l.location_code ?? '', faDepreciationBookCode: l.fa_depreciation_book_code ?? '',
      }))
      : [emptyLine()]);
  return (
    <>
      <button type="button" className={className} onClick={() => setOpen(true)}>Edit</button>
      {open ? (
        <FormModal
          title={`Edit ${doc.no}`} wide
          onClose={() => setOpen(false)}
          onSubmit={(v) => saveSalesDocument(doc.no, v, lines)}
          submitLabel="Save changes" successTitle="Sales document updated"
        >
          <DocFields documentType={documentType} {...rest} initial={doc} lines={lines} setLines={setLines} />
        </FormModal>
      ) : null}
    </>
  );
}
