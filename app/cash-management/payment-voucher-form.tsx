'use client';

import { useState, type ReactNode } from 'react';
import { FormModal } from '@/components/ui/form-modal';
import { Field } from '@/components/ui/field';
import { today } from '@/lib/format';
import { createPvRequest, updatePvRequest, type PvLineDraft } from '@/app/actions/cashMgmt';
import type { PaymentVoucherDetail } from '@/lib/types';

const LINE_TYPES = ['Vendor', 'G/L Account', 'Customer', 'Bank Account'];
type Opt = { code: string; name: string };

export interface PvFormProps {
  banks: { id: number; code: string; name: string; currency_code: string }[];
  accounts: Opt[];
  customers: { no: string; name: string }[];
  vendors: { no: string; name: string }[];
  currencies: { code: string }[];
  payMethods: { code: string }[];
  vatCodes: { code: string; description: string }[];
  whtCodes: { code: string; description: string }[];
  externalBanks: { code: string; name: string }[];
}

const emptyLine = (): PvLineDraft => ({ lineType: 'Vendor', accountNo: '', description: '', amount: '', appliesToDocNo: '', vatProdPostingGroupCode: '', whtCodeOne: '', whtCodeTwo: '' });

function Body({ p, initial, lines, setLines }: { p: PvFormProps; initial?: PaymentVoucherDetail | null; lines: PvLineDraft[]; setLines: (l: PvLineDraft[]) => void }) {
  const set = (i: number, k: keyof PvLineDraft, v: string) => setLines(lines.map((l, idx) => (idx === i ? { ...l, [k]: v } : l)));
  const picker = (l: PvLineDraft, i: number): ReactNode => {
    const rows = l.lineType === 'Customer' ? p.customers.map((c) => ({ v: c.no, t: `${c.no} — ${c.name}` }))
      : l.lineType === 'Vendor' ? p.vendors.map((c) => ({ v: c.no, t: `${c.no} — ${c.name}` }))
      : l.lineType === 'Bank Account' ? p.banks.map((c) => ({ v: c.code, t: `${c.code} — ${c.name}` }))
      : p.accounts.map((c) => ({ v: c.code, t: `${c.code} — ${c.name}` }));
    return <select value={l.accountNo} onChange={(e) => set(i, 'accountNo', e.target.value)} aria-label="Account"><option value="">…</option>{rows.map((r) => <option key={r.v} value={r.v}>{r.t}</option>)}</select>;
  };
  return (
    <>
      <div className="grid g3">
        <Field name="payingBankAccountId" label="Paying bank" type="select" required defaultValue={String(initial?.paying_bank_account_id ?? '')}
          options={[{ value: '', label: '…' }, ...p.banks.map((b) => ({ value: String(b.id), label: `${b.code} — ${b.name} (${b.currency_code})` }))]} />
        <Field name="date" label="Voucher date" type="date" required defaultValue={initial?.date ?? today()} />
        <Field name="pvType" label="Category" defaultValue={initial?.pv_type ?? ''} placeholder="e.g. Supplier Payment" />
      </div>
      <div className="grid g3">
        <Field name="currencyCode" label="Currency" type="select" defaultValue={initial?.currency_code ?? ''} options={[{ value: '', label: '(bank currency)' }, ...p.currencies.map((c) => ({ value: c.code, label: c.code }))]} />
        <Field name="payModeCode" label="Payment mode" type="select" defaultValue={initial?.pay_mode_code ?? ''} options={[{ value: '', label: '(none)' }, ...p.payMethods.map((m) => ({ value: m.code, label: m.code }))]} />
        <Field name="chequeNo" label="Cheque no." defaultValue={initial?.cheque_no ?? ''} />
      </div>
      <div className="grid g3">
        <Field name="chequeDate" label="Cheque date" type="date" defaultValue={initial?.cheque_date ?? ''} />
        <Field name="payeeName" label="Payee name" defaultValue={initial?.payee_name ?? ''} />
        <Field name="payeeAccountNo" label="Payee account no." defaultValue={initial?.payee_account_no ?? ''} />
      </div>
      <div className="grid g2">
        <Field name="payeeExternalBankCode" label="Payee bank" type="select" defaultValue={initial?.payee_external_bank_code ?? ''} options={[{ value: '', label: '(none)' }, ...p.externalBanks.map((b) => ({ value: b.code, label: b.name }))]} />
        <Field name="description" label="Narration" required defaultValue={initial?.description ?? ''} />
      </div>
      <div className="hint" style={{ marginTop: 8 }}>Lines — enter the gross (VAT-inclusive) amount; WHT is withheld from the payee</div>
      <table>
        <thead><tr><th style={{ width: 100 }}>Type</th><th>Account</th><th style={{ width: 120 }}>Gross amt</th><th>Applies to</th><th style={{ width: 90 }}>VAT</th><th style={{ width: 100 }}>WHT 1</th><th style={{ width: 100 }}>WHT 2</th><th style={{ width: 32 }} /></tr></thead>
        <tbody>
          {lines.map((l, i) => (
            <tr key={i}>
              <td><select value={l.lineType} onChange={(e) => set(i, 'lineType', e.target.value)} aria-label="Line type">{LINE_TYPES.map((t) => <option key={t} value={t}>{t}</option>)}</select></td>
              <td>{picker(l, i)}</td>
              <td><input type="number" step="0.01" min={0} value={l.amount} onChange={(e) => set(i, 'amount', e.target.value)} aria-label="Amount" /></td>
              <td><input value={l.appliesToDocNo} onChange={(e) => set(i, 'appliesToDocNo', e.target.value)} aria-label="Applies to" placeholder="Invoice no." disabled={l.lineType !== 'Vendor'} /></td>
              <td><select value={l.vatProdPostingGroupCode} onChange={(e) => set(i, 'vatProdPostingGroupCode', e.target.value)} aria-label="VAT code" disabled={!!l.appliesToDocNo}><option value="">—</option>{p.vatCodes.map((c) => <option key={c.code} value={c.code}>{c.code}</option>)}</select></td>
              <td><select value={l.whtCodeOne} onChange={(e) => set(i, 'whtCodeOne', e.target.value)} aria-label="WHT one"><option value="">—</option>{p.whtCodes.map((c) => <option key={c.code} value={c.code}>{c.code}</option>)}</select></td>
              <td><select value={l.whtCodeTwo} onChange={(e) => set(i, 'whtCodeTwo', e.target.value)} aria-label="WHT two"><option value="">—</option>{p.whtCodes.map((c) => <option key={c.code} value={c.code}>{c.code}</option>)}</select></td>
              <td><button type="button" className="btn sm ghost" onClick={() => setLines(lines.filter((_, idx) => idx !== i))} aria-label="Remove">×</button></td>
            </tr>
          ))}
        </tbody>
      </table>
      <button type="button" className="btn ghost sm" style={{ marginTop: 8 }} onClick={() => setLines([...lines, emptyLine()])}>Add line</button>
    </>
  );
}

export function NewPvButton(p: PvFormProps) {
  const [open, setOpen] = useState(false);
  const [lines, setLines] = useState<PvLineDraft[]>([emptyLine()]);
  return (
    <>
      <button type="button" className="btn" onClick={() => { setLines([emptyLine()]); setOpen(true); }}>New payment voucher</button>
      {open ? (
        <FormModal title="New payment voucher" wide onClose={() => setOpen(false)} onSubmit={(v) => createPvRequest(v, lines)}
          submitLabel="Create" successTitle="Payment voucher created" successDetail={(d) => `${d.no} created — submit it for approval`}>
          <Body p={p} lines={lines} setLines={setLines} />
        </FormModal>
      ) : null}
    </>
  );
}

export function EditPvButton({ pv, className = 'btn sm ghost', p }: { pv: PaymentVoucherDetail; className?: string; p: PvFormProps }) {
  const [open, setOpen] = useState(false);
  const [lines, setLines] = useState<PvLineDraft[]>(() => pv.lines.length
    ? pv.lines.map((l) => ({ lineType: l.line_type, accountNo: l.account_no ?? '', description: l.description ?? '', amount: String(l.amount / 100), appliesToDocNo: l.applies_to_doc_no ?? '', vatProdPostingGroupCode: l.vat_prod_posting_group_code ?? '', whtCodeOne: l.wht_code_one ?? '', whtCodeTwo: l.wht_code_two ?? '' }))
    : [emptyLine()]);
  return (
    <>
      <button type="button" className={className} onClick={() => setOpen(true)}>Edit</button>
      {open ? (
        <FormModal title={`Edit ${pv.no}`} wide onClose={() => setOpen(false)} onSubmit={(v) => updatePvRequest(pv.no, v, lines)}
          submitLabel="Save changes" successTitle="Payment voucher updated">
          <Body p={p} initial={pv} lines={lines} setLines={setLines} />
        </FormModal>
      ) : null}
    </>
  );
}
