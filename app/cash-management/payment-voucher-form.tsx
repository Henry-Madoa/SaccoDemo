'use client';

import { useEffect, useState, type ReactNode } from 'react';
import { FormModal } from '@/components/ui/form-modal';
import { Field } from '@/components/ui/field';
import { AppliesToPicker } from '@/components/ui/applies-to-picker';
import { MemberSelect } from '@/components/ui/member-select';
import { useFormat } from '@/components/ui/format-provider';
import { today } from '@/lib/format';
import {
  createPvRequest, updatePvRequest, memberPaymentOptions, type PvLineDraft,
} from '@/app/actions/cashMgmt';
import type {
  MemberPaymentAccount, Member, PaymentVoucherDetail, PaymentVoucherType,
} from '@/lib/types';

/**
 * AL Tab-Ext52204018: the Payment Type chosen on the header is what a line's Account No relates
 * to, so it is chosen once and every line follows it. Kept in step with PAYMENT_VOUCHER_TYPES in
 * lib/paymentVouchers.ts, which is the server-side authority.
 */
const PV_TYPES: { value: PaymentVoucherType; label: string; pays: string; help: string }[] = [
  {
    value: 'Member Payment', label: 'Member Payment', pays: 'member account',
    help: 'Pay a member over the counter from one of their own deposit accounts.',
  },
  {
    value: 'RTGS/SWIFT', label: 'RTGS / SWIFT', pays: 'member account',
    help: 'Transfer a member’s funds out by RTGS or SWIFT.',
  },
  {
    value: 'Supplier Payment', label: 'Supplier Payment', pays: 'vendor',
    help: 'Settle a vendor invoice, with VAT and withholding tax where they apply.',
  },
  {
    value: 'Customer Refund', label: 'Customer Refund', pays: 'customer',
    help: 'Refund a customer against their open entries.',
  },
  {
    value: 'Bank Transfer', label: 'Bank Transfer', pays: 'bank account',
    help: 'Move money to another of the SACCO’s bank accounts.',
  },
  {
    value: 'Direct Expensing', label: 'Direct Expensing', pays: 'G/L account',
    help: 'Pay an expense straight to a G/L account, with no vendor behind it.',
  },
  {
    value: 'Payroll Settlement', label: 'Payroll Settlement', pays: 'liability account',
    help: 'Settle a payroll liability — net pay, PAYE, NSSF, SHIF or the housing levy.',
  },
  {
    value: 'Remittance', label: 'Remittance', pays: 'liability account',
    help: 'Remit a statutory or third-party liability the SACCO is holding.',
  },
];

const ruleFor = (t: PaymentVoucherType) => PV_TYPES.find((x) => x.value === t) ?? PV_TYPES[5];
const isMemberType = (t: PaymentVoucherType) => t === 'Member Payment' || t === 'RTGS/SWIFT';
/** Only a supplier payment carries a tax split; nothing else has a VAT or WHT base behind it. */
const hasTax = (t: PaymentVoucherType) => t === 'Supplier Payment' || t === 'Direct Expensing';

type Opt = { code: string; name: string };
type EligibleMember = Pick<Member, 'id' | 'member_no' | 'first_name' | 'last_name'>;

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
  members: EligibleMember[];
}

const emptyLine = (): PvLineDraft => ({
  lineType: '', accountNo: '', description: '', amount: '', appliesToDocNo: '',
  vatProdPostingGroupCode: '', whtCodeOne: '', whtCodeTwo: '', savingsAccountId: '',
});

function Body({ p, initial, lines, setLines }: {
  p: PvFormProps; initial?: PaymentVoucherDetail | null;
  lines: PvLineDraft[]; setLines: (l: PvLineDraft[]) => void;
}) {
  const { cur } = useFormat();
  const [pvType, setPvType] = useState<PaymentVoucherType>(initial?.pv_type ?? 'Supplier Payment');
  const [memberId, setMemberId] = useState(String(initial?.member_id ?? ''));
  const [accounts, setAccounts] = useState<MemberPaymentAccount[]>([]);

  const rule = ruleFor(pvType);
  const member = isMemberType(pvType);
  const taxed = hasTax(pvType);

  // Which of the member's products may be drawn on depends on the Payment Type, so the list is
  // reloaded when either changes — AL filters Member Payment and RTGS/SWIFT differently.
  useEffect(() => {
    let cancelled = false;
    if (!member || !memberId) { setAccounts([]); return; }
    memberPaymentOptions(Number(memberId), pvType).then((res) => {
      if (!cancelled && res.ok) setAccounts(res.data);
    });
    return () => { cancelled = true; };
  }, [member, memberId, pvType]);

  const set = (i: number, k: keyof PvLineDraft, v: string) =>
    setLines(lines.map((l, idx) => (idx === i ? { ...l, [k]: v } : l)));

  const picker = (l: PvLineDraft, i: number): ReactNode => {
    if (member) {
      return (
        <select value={l.savingsAccountId ?? ''} onChange={(e) => set(i, 'savingsAccountId', e.target.value)}
          aria-label="Member account" disabled={!memberId}>
          <option value="">{memberId ? '…' : 'Pick the member first'}</option>
          {accounts.map((a) => (
            <option key={a.id} value={a.id}>{a.account_no} — {a.product_name}</option>
          ))}
        </select>
      );
    }
    const rows = pvType === 'Customer Refund' ? p.customers.map((c) => ({ v: c.no, t: `${c.no} — ${c.name}` }))
      : pvType === 'Supplier Payment' ? p.vendors.map((c) => ({ v: c.no, t: `${c.no} — ${c.name}` }))
        : pvType === 'Bank Transfer' ? p.banks.map((c) => ({ v: c.code, t: `${c.code} — ${c.name}` }))
          : p.accounts.map((c) => ({ v: c.code, t: `${c.code} — ${c.name}` }));
    return (
      <select value={l.accountNo} onChange={(e) => set(i, 'accountNo', e.target.value)} aria-label="Account">
        <option value="">…</option>
        {rows.map((r) => <option key={r.v} value={r.v}>{r.t}</option>)}
      </select>
    );
  };

  return (
    <>
      <div className="grid g3">
        <div className="field">
          <label htmlFor="f_pvType">Payment type <span className="req">*</span></label>
          <select id="f_pvType" name="pvType" value={pvType}
            onChange={(e) => {
              // Changing the type invalidates every account already picked, so the lines reset.
              setPvType(e.target.value as PaymentVoucherType);
              setLines([emptyLine()]);
            }}>
            {PV_TYPES.map((t) => <option key={t.value} value={t.value}>{t.label}</option>)}
          </select>
          <div className="hint">{rule.help}</div>
        </div>
        <Field name="payingBankAccountId" label="Paying bank" type="select" required defaultValue={String(initial?.paying_bank_account_id ?? '')}
          options={[{ value: '', label: '…' }, ...p.banks.map((b) => ({ value: String(b.id), label: `${b.code} — ${b.name} (${b.currency_code})` }))]} />
        <Field name="date" label="Voucher date" type="date" required defaultValue={initial?.date ?? today()} />
      </div>

      {member ? (
        <div className="grid g2">
          <MemberSelect id="f_memberId" name="memberId" label="Member" members={p.members}
            value={memberId} onChange={(id) => { setMemberId(id); setLines([emptyLine()]); }} required />
          <Field name="payeeName" label="Payee name" defaultValue={initial?.payee_name ?? ''}
            hint="Defaults to the member; set it only when someone else collects" />
        </div>
      ) : (
        <input type="hidden" name="memberId" value="" />
      )}

      <div className="grid g3">
        <Field name="currencyCode" label="Currency" type="select" defaultValue={initial?.currency_code ?? ''} options={[{ value: '', label: '(bank currency)' }, ...p.currencies.map((c) => ({ value: c.code, label: c.code }))]} />
        <Field name="payModeCode" label="Payment mode" type="select" defaultValue={initial?.pay_mode_code ?? ''} options={[{ value: '', label: '(none)' }, ...p.payMethods.map((m) => ({ value: m.code, label: m.code }))]} />
        <Field name="chequeNo" label="Cheque / EFT no." defaultValue={initial?.cheque_no ?? ''} />
      </div>
      <div className="grid g3">
        <Field name="chequeDate" label="Cheque date" type="date" defaultValue={initial?.cheque_date ?? ''} />
        {member ? null : <Field name="payeeName" label="Payee name" defaultValue={initial?.payee_name ?? ''} />}
        <Field name="payeeAccountNo" label="Payee account no." defaultValue={initial?.payee_account_no ?? ''} />
      </div>
      <div className="grid g2">
        <Field name="payeeExternalBankCode" label="Payee bank" type="select" defaultValue={initial?.payee_external_bank_code ?? ''} options={[{ value: '', label: '(none)' }, ...p.externalBanks.map((b) => ({ value: b.code, label: b.name }))]} />
        <Field name="description" label="Narration" required defaultValue={initial?.description ?? ''} />
      </div>

      <div className="hint" style={{ marginTop: 8 }}>
        {taxed
          ? 'Lines — enter the gross (VAT-inclusive) amount; WHT is withheld from the payee'
          : `Lines — every line on this voucher pays a ${rule.pays}`}
      </div>
      <table>
        <thead>
          <tr>
            <th>{member ? 'Member account' : rule.pays.replace(/^\w/, (c) => c.toUpperCase())}</th>
            <th>Description</th>
            <th style={{ width: 120 }}>{taxed ? 'Gross amt' : 'Amount'}</th>
            {member ? <th style={{ width: 130 }}>Available</th> : <th>Applies to</th>}
            {taxed ? <th style={{ width: 90 }}>VAT</th> : null}
            {taxed ? <th style={{ width: 100 }}>WHT 1</th> : null}
            {taxed ? <th style={{ width: 100 }}>WHT 2</th> : null}
            <th style={{ width: 32 }} />
          </tr>
        </thead>
        <tbody>
          {lines.map((l, i) => {
            const acc = accounts.find((a) => String(a.id) === l.savingsAccountId);
            const over = acc && Number(l.amount) * 100 > acc.available_balance;
            return (
              <tr key={i}>
                <td>{picker(l, i)}</td>
                <td><input value={l.description} onChange={(e) => set(i, 'description', e.target.value)} aria-label="Description" /></td>
                <td><input type="number" step="0.01" min={0} value={l.amount} onChange={(e) => set(i, 'amount', e.target.value)} aria-label="Amount" /></td>
                {member ? (
                  <td className={over ? 'tiny danger-text' : 'tiny muted-cell'}>
                    {acc ? cur(acc.available_balance) : '—'}
                    {over ? <div>Exceeds available</div> : null}
                  </td>
                ) : (
                  <td>
                    <AppliesToPicker
                      partyType={pvType === 'Supplier Payment' ? 'Vendor' : pvType === 'Customer Refund' ? 'Customer' : null}
                      partyNo={l.accountNo} value={l.appliesToDocNo ?? ''}
                      onChange={(v) => set(i, 'appliesToDocNo', v)}
                      onPickAmount={(amt) => set(i, 'amount', amt)}
                    />
                  </td>
                )}
                {taxed ? (
                  <td><select value={l.vatProdPostingGroupCode} onChange={(e) => set(i, 'vatProdPostingGroupCode', e.target.value)} aria-label="VAT code" disabled={!!l.appliesToDocNo}><option value="">—</option>{p.vatCodes.map((c) => <option key={c.code} value={c.code}>{c.code}</option>)}</select></td>
                ) : null}
                {taxed ? (
                  <td><select value={l.whtCodeOne} onChange={(e) => set(i, 'whtCodeOne', e.target.value)} aria-label="WHT one"><option value="">—</option>{p.whtCodes.map((c) => <option key={c.code} value={c.code}>{c.code}</option>)}</select></td>
                ) : null}
                {taxed ? (
                  <td><select value={l.whtCodeTwo} onChange={(e) => set(i, 'whtCodeTwo', e.target.value)} aria-label="WHT two"><option value="">—</option>{p.whtCodes.map((c) => <option key={c.code} value={c.code}>{c.code}</option>)}</select></td>
                ) : null}
                <td><button type="button" className="btn sm ghost" onClick={() => setLines(lines.filter((_, idx) => idx !== i))} aria-label="Remove">×</button></td>
              </tr>
            );
          })}
        </tbody>
      </table>
      <button type="button" className="btn ghost sm" style={{ marginTop: 8 }} onClick={() => setLines([...lines, emptyLine()])}>Add line</button>
      {member ? (
        <div className="note">
          Available is the account balance less any holds and the product’s minimum balance — the
          most that may be drawn. It is checked again at posting against the live balance.
        </div>
      ) : null}
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
  const [lines, setLines] = useState<PvLineDraft[]>(() => (pv.lines.length
    ? pv.lines.map((l) => ({
      lineType: l.line_type,
      accountNo: l.account_no ?? '',
      description: l.description ?? '',
      amount: String(l.amount / 100),
      appliesToDocNo: l.applies_to_doc_no ?? '',
      vatProdPostingGroupCode: l.vat_prod_posting_group_code ?? '',
      whtCodeOne: l.wht_code_one ?? '',
      whtCodeTwo: l.wht_code_two ?? '',
      savingsAccountId: l.savings_account_id ? String(l.savings_account_id) : '',
    }))
    : [emptyLine()]));
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
