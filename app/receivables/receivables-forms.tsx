'use client';

import { useState, type ReactNode } from 'react';
import { FormModal } from '@/components/ui/form-modal';
import { Field } from '@/components/ui/field';
import { GlAccountSelect } from '@/components/ui/gl-account-select';
import {
  createCpgRequest, updateCpgRequest,
  createPaymentTermsRequest, updatePaymentTermsRequest,
  createPaymentMethodRequest, updatePaymentMethodRequest,
  createFinanceChargeTermsRequest, updateFinanceChargeTermsRequest,
  createReminderTermsRequest, updateReminderTermsRequest,
  requestCustomer, saveCustomer, saveSalesReceivablesSetupRequest,
} from '@/app/actions/receivables';
import type {
  CustomerListRow, CustomerPostingGroup, CustomerPostingGroupView, FinanceChargeTerms, GlAccount,
  PaymentMethod, PaymentTerms, ReminderLevel, ReminderTerms, SalesReceivablesSetup,
} from '@/lib/types';

const STATUSES = [{ value: 'ACTIVE', label: 'Active' }, { value: 'INACTIVE', label: 'Inactive' }];
const BLOCKED = [
  { value: '', label: '(not blocked)' }, { value: 'Ship', label: 'Ship' },
  { value: 'Invoice', label: 'Invoice' }, { value: 'All', label: 'All' },
];

/* ------------------------------------------------------------------- Customer */

export function CustomerFormButton({ customer, postingGroups, paymentTerms, paymentMethods, reminderTerms, finChargeTerms, className = 'btn', children }: {
  customer?: CustomerListRow | null;
  postingGroups: CustomerPostingGroupView[]; paymentTerms: PaymentTerms[]; paymentMethods: PaymentMethod[];
  reminderTerms: ReminderTerms[]; finChargeTerms: FinanceChargeTerms[];
  className?: string; children: ReactNode;
}) {
  const [open, setOpen] = useState(false);
  const c = customer ?? null;
  const opts = (rows: { code: string; description: string }[], none = '(none)') =>
    [{ value: '', label: none }, ...rows.map((r) => ({ value: r.code, label: `${r.code} — ${r.description}` }))];
  return (
    <>
      <button type="button" className={className} onClick={() => setOpen(true)}>{children}</button>
      {open ? (
        <FormModal
          title={c ? `Edit ${c.no}` : 'New customer'} wide
          onClose={() => setOpen(false)}
          onSubmit={(v) => (c ? saveCustomer(c.no, v) : requestCustomer(v))}
          submitLabel={c ? 'Save changes' : 'Create'}
          successTitle={c ? 'Customer updated' : 'Customer created'}
        >
          <div className="grid g2">
            <Field name="name" label="Name" required defaultValue={c?.name} />
            <Field name="name2" label="Name 2" defaultValue={c?.name_2 ?? ''} placeholder="Optional" />
          </div>
          <div className="grid g2">
            <Field name="address" label="Address" defaultValue={c?.address ?? ''} />
            <Field name="city" label="City" defaultValue={c?.city ?? ''} />
          </div>
          <div className="grid g3">
            <Field name="contact" label="Contact" defaultValue={c?.contact ?? ''} />
            <Field name="phone" label="Phone" defaultValue={c?.phone ?? ''} />
            <Field name="email" label="Email" type="email" defaultValue={c?.email ?? ''} />
          </div>
          <div className="grid g2">
            <Field name="customerPostingGroupCode" label="Customer posting group" type="select" defaultValue={c?.customer_posting_group_code ?? ''} options={opts(postingGroups)} />
            <Field name="paymentTermsCode" label="Payment terms" type="select" defaultValue={c?.payment_terms_code ?? ''} options={opts(paymentTerms)} />
          </div>
          <div className="grid g2">
            <Field name="paymentMethodCode" label="Payment method" type="select" defaultValue={c?.payment_method_code ?? ''} options={opts(paymentMethods)} />
            <Field name="salesperson" label="Salesperson" defaultValue={c?.salesperson ?? ''} placeholder="Optional" />
          </div>
          <div className="grid g2">
            <Field name="reminderTermsCode" label="Reminder terms" type="select" defaultValue={c?.reminder_terms_code ?? ''} options={opts(reminderTerms)} />
            <Field name="finChargeTermsCode" label="Fin. charge terms" type="select" defaultValue={c?.fin_charge_terms_code ?? ''} options={opts(finChargeTerms)} />
          </div>
          <div className="grid g2">
            <Field name="creditLimit" label="Credit limit" type="currency" defaultValue={c ? String(c.credit_limit / 100) : '0'} />
            <Field name="blocked" label="Blocked" type="select" defaultValue={c?.blocked ?? ''} options={BLOCKED} />
          </div>
        </FormModal>
      ) : null}
    </>
  );
}

/* ----------------------------------------------------- Customer Posting Group */

const CPG_ACCOUNTS: { name: string; label: string }[] = [
  { name: 'receivables_account_id', label: 'Receivables Account' },
  { name: 'service_charge_account_id', label: 'Service Charge (interest) Account' },
  { name: 'additional_fee_account_id', label: 'Additional Fee Account' },
  { name: 'payment_disc_debit_account_id', label: 'Payment Disc. Debit Account' },
  { name: 'payment_disc_credit_account_id', label: 'Payment Disc. Credit Account' },
  { name: 'invoice_rounding_account_id', label: 'Invoice Rounding Account' },
];

export function CustomerPostingGroupFormButton({ row, accounts, className = 'btn', children }: {
  row?: CustomerPostingGroupView | null; accounts: GlAccount[]; className?: string; children: ReactNode;
}) {
  const [open, setOpen] = useState(false);
  const r = row ?? null;
  const [ids, setIds] = useState<Record<string, string>>(() =>
    Object.fromEntries(CPG_ACCOUNTS.map((a) => [a.name, r ? String((r as unknown as Record<string, number>)[a.name] ?? '') : ''])));
  return (
    <>
      <button type="button" className={className} onClick={() => {
        setIds(Object.fromEntries(CPG_ACCOUNTS.map((a) => [a.name, r ? String((r as unknown as Record<string, number>)[a.name] ?? '') : ''])));
        setOpen(true);
      }}>{children}</button>
      {open ? (
        <FormModal
          title={r ? `Edit ${r.code}` : 'New customer posting group'} wide
          onClose={() => setOpen(false)}
          onSubmit={(v) => (r ? updateCpgRequest(r.id, v) : createCpgRequest(v))}
          submitLabel={r ? 'Save changes' : 'Create'}
          successTitle={r ? 'Posting group updated' : 'Posting group created'}
        >
          <div className="grid g2">
            <Field name="code" label="Code" required uppercase defaultValue={r?.code} disabled={!!r} placeholder="e.g. TRADE" />
            <Field name="description" label="Description" required defaultValue={r?.description} />
          </div>
          {CPG_ACCOUNTS.map((a) => (
            <GlAccountSelect key={a.name} name={a.name} label={a.label} required accounts={accounts}
              value={ids[a.name] ?? ''} onChange={(val) => setIds((p) => ({ ...p, [a.name]: val }))} />
          ))}
        </FormModal>
      ) : null}
    </>
  );
}

/* ------------------------------------------------------------ Payment Terms */

export function PaymentTermsFormButton({ row, className = 'btn', children }: { row?: PaymentTerms | null; className?: string; children: ReactNode }) {
  const [open, setOpen] = useState(false);
  const r = row ?? null;
  return (
    <>
      <button type="button" className={className} onClick={() => setOpen(true)}>{children}</button>
      {open ? (
        <FormModal
          title={r ? `Edit ${r.code}` : 'New payment terms'}
          onClose={() => setOpen(false)}
          onSubmit={(v) => (r ? updatePaymentTermsRequest(r.id, v) : createPaymentTermsRequest(v))}
          submitLabel={r ? 'Save changes' : 'Create'} successTitle={r ? 'Payment terms updated' : 'Payment terms created'}
        >
          <div className="grid g2">
            <Field name="code" label="Code" required uppercase defaultValue={r?.code} disabled={!!r} placeholder="e.g. 30 DAYS" />
            <Field name="description" label="Description" required defaultValue={r?.description} />
          </div>
          <div className="grid g3">
            <Field name="due_date_calculation" label="Due Date Calculation" defaultValue={r?.due_date_calculation ?? ''} placeholder="e.g. 30D, CM, CM+10D" hint="Business Central date formula" />
            <Field name="discount_date_calculation" label="Discount Date Calculation" defaultValue={r?.discount_date_calculation ?? ''} placeholder="e.g. 8D" />
            <Field name="discount_pct" label="Discount %" type="number" step="0.01" min={0} max={100} defaultValue={r?.discount_pct ?? 0} />
          </div>
          {r ? <Field name="status" label="Status" type="select" options={STATUSES} defaultValue={r.status} /> : null}
        </FormModal>
      ) : null}
    </>
  );
}

/* ---------------------------------------------------------- Payment Method */

export function PaymentMethodFormButton({ row, banks, className = 'btn', children }: {
  row?: PaymentMethod | null; banks: { code: string; name: string }[]; className?: string; children: ReactNode;
}) {
  const [open, setOpen] = useState(false);
  const r = row ?? null;
  const [balType, setBalType] = useState(r?.bal_account_type ?? 'None');
  return (
    <>
      <button type="button" className={className} onClick={() => setOpen(true)}>{children}</button>
      {open ? (
        <FormModal
          title={r ? `Edit ${r.code}` : 'New payment method'}
          onClose={() => setOpen(false)}
          onSubmit={(v) => (r ? updatePaymentMethodRequest(r.id, v) : createPaymentMethodRequest(v))}
          submitLabel={r ? 'Save changes' : 'Create'} successTitle={r ? 'Payment method updated' : 'Payment method created'}
        >
          <div className="grid g2">
            <Field name="code" label="Code" required uppercase defaultValue={r?.code} disabled={!!r} placeholder="e.g. MPESA" />
            <Field name="description" label="Description" required defaultValue={r?.description} />
          </div>
          <div className="grid g2">
            <Field name="bal_account_type" label="Bal. Account Type" type="select" defaultValue={balType}
              options={[{ value: 'None', label: 'None' }, { value: 'Bank Account', label: 'Bank Account' }, { value: 'G/L Account', label: 'G/L Account' }]}
              onChange={(e) => setBalType(e.target.value as never)} />
            {balType === 'Bank Account'
              ? <Field name="bal_account_no" label="Bank Account" type="select" defaultValue={r?.bal_account_no ?? ''}
                options={[{ value: '', label: '(none)' }, ...banks.map((b) => ({ value: b.code, label: `${b.code} — ${b.name}` }))]} />
              : <Field name="bal_account_no" label="Bal. Account No." defaultValue={r?.bal_account_no ?? ''} placeholder={balType === 'None' ? 'n/a' : 'G/L code'} />}
          </div>
          {r ? <Field name="status" label="Status" type="select" options={STATUSES} defaultValue={r.status} /> : null}
        </FormModal>
      ) : null}
    </>
  );
}

/* -------------------------------------------------------- Finance Charge Terms */

export function FinanceChargeTermsFormButton({ row, className = 'btn', children }: { row?: FinanceChargeTerms | null; className?: string; children: ReactNode }) {
  const [open, setOpen] = useState(false);
  const r = row ?? null;
  return (
    <>
      <button type="button" className={className} onClick={() => setOpen(true)}>{children}</button>
      {open ? (
        <FormModal
          title={r ? `Edit ${r.code}` : 'New finance charge terms'} wide
          onClose={() => setOpen(false)}
          onSubmit={(v) => (r ? updateFinanceChargeTermsRequest(r.id, v) : createFinanceChargeTermsRequest(v))}
          submitLabel={r ? 'Save changes' : 'Create'} successTitle={r ? 'Finance charge terms updated' : 'Finance charge terms created'}
        >
          <div className="grid g2">
            <Field name="code" label="Code" required uppercase defaultValue={r?.code} disabled={!!r} placeholder="e.g. 1.5%" />
            <Field name="description" label="Description" required defaultValue={r?.description} />
          </div>
          <div className="grid g3">
            <Field name="interest_rate" label="Interest Rate % p.a." type="number" step="0.01" min={0} defaultValue={r?.interest_rate ?? 0} />
            <Field name="interest_period_days" label="Interest Period (days)" type="number" step="1" min={1} defaultValue={r?.interest_period_days ?? 360} />
            <Field name="interest_calculation_method" label="Calculation Method" type="select" defaultValue={r?.interest_calculation_method ?? 'Balance Due'}
              options={[{ value: 'Balance Due', label: 'Balance Due' }, { value: 'Average Daily Balance', label: 'Average Daily Balance' }]} />
          </div>
          <div className="grid g3">
            <Field name="min_amount" label="Minimum Amount" type="currency" defaultValue={r ? String(r.min_amount / 100) : '0'} />
            <Field name="additional_fee" label="Additional Fee" type="currency" defaultValue={r ? String(r.additional_fee / 100) : '0'} />
            <Field name="line_description" label="Line Description" defaultValue={r?.line_description ?? 'Finance Charge'} />
          </div>
          <div className="grid g2">
            <Field name="grace_period" label="Grace Period" defaultValue={r?.grace_period ?? '0D'} placeholder="e.g. 0D" />
            <Field name="due_date_calculation" label="Due Date Calculation" defaultValue={r?.due_date_calculation ?? '14D'} placeholder="e.g. 14D" />
          </div>
          <div className="grid g2">
            <Field name="post_interest" label="Post Interest" type="checkbox" defaultValue={r ? (r.post_interest ? 'on' : '') : 'on'} />
            <Field name="post_additional_fee" label="Post Additional Fee" type="checkbox" defaultValue={r ? (r.post_additional_fee ? 'on' : '') : ''} />
          </div>
          {r ? <Field name="status" label="Status" type="select" options={STATUSES} defaultValue={r.status} /> : null}
        </FormModal>
      ) : null}
    </>
  );
}

/* --------------------------------------------------------- Reminder Terms + Levels */

const emptyLevel = () => ({ grace_period: '7D', due_date_calculation: '7D', calculate_interest: '', additional_fee: '', add_fee_per_line: '', begin_text: '', end_text: '' });

export function ReminderTermsFormButton({ row, initialLevels, className = 'btn', children }: {
  row?: ReminderTerms | null; initialLevels?: ReminderLevel[]; className?: string; children: ReactNode;
}) {
  const [open, setOpen] = useState(false);
  const r = row ?? null;
  const [levels, setLevels] = useState<Record<string, string>[]>(() =>
    (initialLevels ?? []).length
      ? initialLevels!.map((l) => ({
        grace_period: l.grace_period, due_date_calculation: l.due_date_calculation,
        calculate_interest: l.calculate_interest ? 'on' : '', additional_fee: String(l.additional_fee / 100),
        add_fee_per_line: String(l.add_fee_per_line / 100), begin_text: l.begin_text ?? '', end_text: l.end_text ?? '',
      }))
      : [emptyLevel()]);
  const setLevel = (i: number, k: string, v: string) => setLevels((p) => p.map((l, idx) => (idx === i ? { ...l, [k]: v } : l)));

  return (
    <>
      <button type="button" className={className} onClick={() => setOpen(true)}>{children}</button>
      {open ? (
        <FormModal
          title={r ? `Edit ${r.code}` : 'New reminder terms'} wide
          onClose={() => setOpen(false)}
          onSubmit={(v) => (r
            ? updateReminderTermsRequest(r.id, v, levels)
            : createReminderTermsRequest(v, levels))}
          submitLabel={r ? 'Save changes' : 'Create'} successTitle={r ? 'Reminder terms updated' : 'Reminder terms created'}
        >
          <div className="grid g2">
            <Field name="code" label="Code" required uppercase defaultValue={r?.code} disabled={!!r} placeholder="e.g. DOMESTIC" />
            <Field name="description" label="Description" required defaultValue={r?.description} />
          </div>
          <div className="grid g3">
            <Field name="max_no_of_reminders" label="Max No. of Reminders" type="number" step="1" min={1} defaultValue={r?.max_no_of_reminders ?? 3} />
            <Field name="min_amount" label="Minimum Amount" type="currency" defaultValue={r ? String(r.min_amount / 100) : '0'} />
            <Field name="dont_remind_on_hold" label="Don't Remind On Hold" type="checkbox" defaultValue={r ? (r.dont_remind_on_hold ? 'on' : '') : 'on'} />
          </div>
          <div className="grid g2">
            <Field name="post_interest" label="Post Interest" type="checkbox" defaultValue={r ? (r.post_interest ? 'on' : '') : 'on'} />
            <Field name="post_additional_fee" label="Post Additional Fee" type="checkbox" defaultValue={r ? (r.post_additional_fee ? 'on' : '') : 'on'} />
          </div>
          {r ? <Field name="status" label="Status" type="select" options={STATUSES} defaultValue={r.status} /> : null}

          <div className="hint" style={{ marginTop: 'calc(var(--sp)*1)' }}>Reminder levels (numbered automatically in order):</div>
          {levels.map((l, i) => (
            <fieldset key={i} style={{ border: '1px solid var(--line)', borderRadius: 8, padding: 'var(--sp)', marginBottom: 8 }}>
              <legend className="tiny muted-cell">Level {i + 1}</legend>
              <div className="grid g3">
                <label className="tiny">Grace period<input value={l.grace_period} onChange={(e) => setLevel(i, 'grace_period', e.target.value)} placeholder="7D" /></label>
                <label className="tiny">Due date calc.<input value={l.due_date_calculation} onChange={(e) => setLevel(i, 'due_date_calculation', e.target.value)} placeholder="7D" /></label>
                <label className="tiny">Calculate interest <input type="checkbox" checked={l.calculate_interest === 'on'} onChange={(e) => setLevel(i, 'calculate_interest', e.target.checked ? 'on' : '')} /></label>
              </div>
              <div className="grid g2">
                <label className="tiny">Additional fee<input type="number" step="0.01" value={l.additional_fee} onChange={(e) => setLevel(i, 'additional_fee', e.target.value)} /></label>
                <label className="tiny">Add. fee per line<input type="number" step="0.01" value={l.add_fee_per_line} onChange={(e) => setLevel(i, 'add_fee_per_line', e.target.value)} /></label>
              </div>
              <label className="tiny">Beginning text<textarea rows={2} value={l.begin_text} onChange={(e) => setLevel(i, 'begin_text', e.target.value)} /></label>
              <label className="tiny">Ending text<textarea rows={2} value={l.end_text} onChange={(e) => setLevel(i, 'end_text', e.target.value)} /></label>
              <button type="button" className="btn sm ghost" onClick={() => setLevels((p) => p.filter((_, idx) => idx !== i))}>Remove level</button>
            </fieldset>
          ))}
          <button type="button" className="btn ghost sm" onClick={() => setLevels((p) => [...p, emptyLevel()])}>Add level</button>
        </FormModal>
      ) : null}
    </>
  );
}

/* --------------------------------------------------- Sales & Receivables Setup */

export function SalesReceivablesSetupButton({ setup, postingGroups, paymentTerms, reminderTerms, finChargeTerms, className = 'btn', children }: {
  setup: SalesReceivablesSetup; postingGroups: CustomerPostingGroup[]; paymentTerms: PaymentTerms[];
  reminderTerms: ReminderTerms[]; finChargeTerms: FinanceChargeTerms[]; className?: string; children: ReactNode;
}) {
  const [open, setOpen] = useState(false);
  const opts = (rows: { code: string; description: string }[]) => [{ value: '', label: '(none)' }, ...rows.map((r) => ({ value: r.code, label: `${r.code} — ${r.description}` }))];
  return (
    <>
      <button type="button" className={className} onClick={() => setOpen(true)}>{children}</button>
      {open ? (
        <FormModal title="Sales & Receivables Setup" onClose={() => setOpen(false)} onSubmit={saveSalesReceivablesSetupRequest} submitLabel="Save" successTitle="Setup saved">
          <div className="grid g2">
            <Field name="default_customer_posting_group_code" label="Default customer posting group" type="select" defaultValue={setup.default_customer_posting_group_code ?? ''} options={opts(postingGroups)} />
            <Field name="default_payment_terms_code" label="Default payment terms" type="select" defaultValue={setup.default_payment_terms_code ?? ''} options={opts(paymentTerms)} />
          </div>
          <div className="grid g2">
            <Field name="default_reminder_terms_code" label="Default reminder terms" type="select" defaultValue={setup.default_reminder_terms_code ?? ''} options={opts(reminderTerms)} />
            <Field name="default_fin_charge_terms_code" label="Default fin. charge terms" type="select" defaultValue={setup.default_fin_charge_terms_code ?? ''} options={opts(finChargeTerms)} />
          </div>
          <div className="grid g2">
            <Field name="credit_warnings" label="Credit Warnings" type="select" defaultValue={setup.credit_warnings}
              options={['Both', 'Credit Limit', 'Overdue Balance', 'No Warning'].map((v) => ({ value: v, label: v }))} />
            <Field name="stockout_warning" label="Stockout Warning" type="checkbox" defaultValue={setup.stockout_warning ? 'on' : ''} />
          </div>
          <div className="grid g2">
            <Field name="allow_receivables_posting_from" label="Allow Posting From" type="date" defaultValue={setup.allow_receivables_posting_from ?? ''} />
            <Field name="allow_receivables_posting_to" label="Allow Posting To" type="date" defaultValue={setup.allow_receivables_posting_to ?? ''} />
          </div>
        </FormModal>
      ) : null}
    </>
  );
}
