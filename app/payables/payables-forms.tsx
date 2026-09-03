'use client';

import { useState, type ReactNode } from 'react';
import { FormModal } from '@/components/ui/form-modal';
import { Field } from '@/components/ui/field';
import { GlAccountSelect } from '@/components/ui/gl-account-select';
import {
  createVpgRequest, updateVpgRequest,
  requestVendor, saveVendor, savePurchasesPayablesSetupRequest,
} from '@/app/actions/payables';
import type {
  GlAccount, PaymentMethod, PaymentTerms, PurchasesPayablesSetup, VendorListRow, VendorPostingGroup,
  VendorPostingGroupView,
} from '@/lib/types';

const BLOCKED = [
  { value: '', label: '(not blocked)' }, { value: 'Payment', label: 'Payment' },
  { value: 'Invoice', label: 'Invoice' }, { value: 'All', label: 'All' },
];

/* ------------------------------------------------------------------- Vendor */

export function VendorFormButton({ vendor, postingGroups, paymentTerms, paymentMethods, className = 'btn', children }: {
  vendor?: VendorListRow | null;
  postingGroups: VendorPostingGroupView[]; paymentTerms: PaymentTerms[]; paymentMethods: PaymentMethod[];
  className?: string; children: ReactNode;
}) {
  const [open, setOpen] = useState(false);
  const v = vendor ?? null;
  const opts = (rows: { code: string; description: string }[], none = '(none)') =>
    [{ value: '', label: none }, ...rows.map((r) => ({ value: r.code, label: `${r.code} — ${r.description}` }))];
  return (
    <>
      <button type="button" className={className} onClick={() => setOpen(true)}>{children}</button>
      {open ? (
        <FormModal
          title={v ? `Edit ${v.no}` : 'New vendor'} wide
          onClose={() => setOpen(false)}
          onSubmit={(vals) => (v ? saveVendor(v.no, vals) : requestVendor(vals))}
          submitLabel={v ? 'Save changes' : 'Create'}
          successTitle={v ? 'Vendor updated' : 'Vendor created'}
        >
          <div className="grid g2">
            <Field name="name" label="Name" required defaultValue={v?.name} />
            <Field name="name2" label="Name 2" defaultValue={v?.name_2 ?? ''} placeholder="Optional" />
          </div>
          <div className="grid g2">
            <Field name="address" label="Address" defaultValue={v?.address ?? ''} />
            <Field name="city" label="City" defaultValue={v?.city ?? ''} />
          </div>
          <div className="grid g3">
            <Field name="contact" label="Contact" defaultValue={v?.contact ?? ''} />
            <Field name="phone" label="Phone" defaultValue={v?.phone ?? ''} />
            <Field name="email" label="Email" type="email" defaultValue={v?.email ?? ''} />
          </div>
          <div className="grid g2">
            <Field name="vendorPostingGroupCode" label="Vendor posting group" type="select" defaultValue={v?.vendor_posting_group_code ?? ''} options={opts(postingGroups)} />
            <Field name="paymentTermsCode" label="Payment terms" type="select" defaultValue={v?.payment_terms_code ?? ''} options={opts(paymentTerms)} />
          </div>
          <div className="grid g2">
            <Field name="paymentMethodCode" label="Payment method" type="select" defaultValue={v?.payment_method_code ?? ''} options={opts(paymentMethods)} />
            <Field name="purchaser" label="Purchaser" defaultValue={v?.purchaser ?? ''} placeholder="Optional" />
          </div>
          <div className="grid g3">
            <Field name="ourAccountNo" label="Our Account No." defaultValue={v?.our_account_no ?? ''} placeholder="Our account with the vendor" />
            <Field name="creditLimit" label="Credit limit" type="currency" defaultValue={v ? String(v.credit_limit / 100) : '0'} />
            <Field name="blocked" label="Blocked" type="select" defaultValue={v?.blocked ?? ''} options={BLOCKED} />
          </div>
        </FormModal>
      ) : null}
    </>
  );
}

/* ----------------------------------------------------- Vendor Posting Group */

const VPG_ACCOUNTS: { name: string; label: string }[] = [
  { name: 'payables_account_id', label: 'Payables Account' },
  { name: 'service_charge_account_id', label: 'Service Charge Account' },
  { name: 'payment_disc_debit_account_id', label: 'Payment Disc. Debit Account' },
  { name: 'payment_disc_credit_account_id', label: 'Payment Disc. Credit (Received) Account' },
  { name: 'invoice_rounding_account_id', label: 'Invoice Rounding Account' },
];

export function VendorPostingGroupFormButton({ row, accounts, className = 'btn', children }: {
  row?: VendorPostingGroupView | null; accounts: GlAccount[]; className?: string; children: ReactNode;
}) {
  const [open, setOpen] = useState(false);
  const r = row ?? null;
  const [ids, setIds] = useState<Record<string, string>>(() =>
    Object.fromEntries(VPG_ACCOUNTS.map((a) => [a.name, r ? String((r as unknown as Record<string, number>)[a.name] ?? '') : ''])));
  return (
    <>
      <button type="button" className={className} onClick={() => {
        setIds(Object.fromEntries(VPG_ACCOUNTS.map((a) => [a.name, r ? String((r as unknown as Record<string, number>)[a.name] ?? '') : ''])));
        setOpen(true);
      }}>{children}</button>
      {open ? (
        <FormModal
          title={r ? `Edit ${r.code}` : 'New vendor posting group'} wide
          onClose={() => setOpen(false)}
          onSubmit={(v) => (r ? updateVpgRequest(r.id, v) : createVpgRequest(v))}
          submitLabel={r ? 'Save changes' : 'Create'}
          successTitle={r ? 'Posting group updated' : 'Posting group created'}
        >
          <div className="grid g2">
            <Field name="code" label="Code" required uppercase defaultValue={r?.code} disabled={!!r} placeholder="e.g. TRADE" />
            <Field name="description" label="Description" required defaultValue={r?.description} />
          </div>
          {VPG_ACCOUNTS.map((a) => (
            <GlAccountSelect key={a.name} name={a.name} label={a.label} required accounts={accounts}
              value={ids[a.name] ?? ''} onChange={(val) => setIds((p) => ({ ...p, [a.name]: val }))} />
          ))}
        </FormModal>
      ) : null}
    </>
  );
}

/* --------------------------------------------------- Purchases & Payables Setup */

export function PurchasesPayablesSetupButton({ setup, postingGroups, paymentTerms, className = 'btn', children }: {
  setup: PurchasesPayablesSetup; postingGroups: VendorPostingGroup[]; paymentTerms: PaymentTerms[];
  className?: string; children: ReactNode;
}) {
  const [open, setOpen] = useState(false);
  const opts = (rows: { code: string; description: string }[]) => [{ value: '', label: '(none)' }, ...rows.map((r) => ({ value: r.code, label: `${r.code} — ${r.description}` }))];
  return (
    <>
      <button type="button" className={className} onClick={() => setOpen(true)}>{children}</button>
      {open ? (
        <FormModal title="Purchases & Payables Setup" onClose={() => setOpen(false)} onSubmit={savePurchasesPayablesSetupRequest} submitLabel="Save" successTitle="Setup saved">
          <div className="grid g2">
            <Field name="default_vendor_posting_group_code" label="Default vendor posting group" type="select" defaultValue={setup.default_vendor_posting_group_code ?? ''} options={opts(postingGroups)} />
            <Field name="default_payment_terms_code" label="Default payment terms" type="select" defaultValue={setup.default_payment_terms_code ?? ''} options={opts(paymentTerms)} />
          </div>
          <div className="grid g2">
            <Field name="receipt_on_invoice" label="Receipt on Invoice" type="checkbox" defaultValue={setup.receipt_on_invoice ? 'on' : ''} hint="Auto-receive stock when posting a Purchase Invoice" />
            <Field name="exact_cost_reversing_mandatory" label="Exact Cost Reversing Mandatory" type="checkbox" defaultValue={setup.exact_cost_reversing_mandatory ? 'on' : ''} />
          </div>
          <div className="grid g2">
            <Field name="allow_payables_posting_from" label="Allow Posting From" type="date" defaultValue={setup.allow_payables_posting_from ?? ''} />
            <Field name="allow_payables_posting_to" label="Allow Posting To" type="date" defaultValue={setup.allow_payables_posting_to ?? ''} />
          </div>
        </FormModal>
      ) : null}
    </>
  );
}
