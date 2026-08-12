'use client';

import { useState, type ReactNode } from 'react';
import { FormModal } from '@/components/ui/form-modal';
import { Field } from '@/components/ui/field';
import { saveSavingsProduct, saveLoanProduct } from '@/app/actions/admin';
import { SAVINGS_CATEGORIES, PRODUCT_STATUSES, INTEREST_METHODS } from '@/lib/constants';
import { toUnits } from '@/lib/format';
import type { GlAccount, LoanProductWithUsage, SavingsProductWithUsage } from '@/lib/types';

/** GL accounts as <select> options — every product must map to a postable account. */
const accountOptions = (accounts: GlAccount[]) =>
  accounts.map((a) => ({ value: a.id, label: `${a.code} — ${a.name}` }));

export function SavingsProductButton({ product, accounts, className = 'btn', children }: {
  product?: SavingsProductWithUsage | null;
  accounts: GlAccount[];
  className?: string;
  children: ReactNode;
}) {
  const [open, setOpen] = useState(false);
  const p = product ?? null;

  return (
    <>
      <button type="button" className={className} onClick={() => setOpen(true)}>{children}</button>
      {open ? (
        <FormModal
          wide
          title={p ? `Edit ${p.name}` : 'New savings product'}
          onClose={() => setOpen(false)}
          onSubmit={(values) => saveSavingsProduct(p ? p.id : null, values)}
          submitLabel="Save product"
          successTitle="Product saved"
        >
          <div className="grid g3">
            <Field name="code" label="Product code" defaultValue={p?.code} required disabled={!!p} />
            <Field name="name" label="Product name" defaultValue={p?.name} required />
            <Field name="category" label="Category" type="select"
              defaultValue={p?.category} options={SAVINGS_CATEGORIES} />
            <Field name="interest_rate" label="Interest rate (% p.a.)" type="number" step="0.01"
              defaultValue={p ? p.interest_rate : 0} />
            <Field name="min_opening_sh" label="Minimum opening deposit" type="number" step="0.01"
              defaultValue={p ? toUnits(p.min_opening) : 0} />
            <Field name="min_balance_sh" label="Minimum balance" type="number" step="0.01"
              defaultValue={p ? toUnits(p.min_balance) : 0} />
            <Field name="withdrawal_fee_sh" label="Withdrawal charge" type="number" step="0.01"
              defaultValue={p ? toUnits(p.withdrawal_fee) : 0} />
            <Field name="withdrawal_notice_days" label="Notice period (days)" type="number"
              defaultValue={p ? p.withdrawal_notice_days : 0} />
            <Field name="status" label="Status" type="select"
              defaultValue={p?.status} options={PRODUCT_STATUSES} />
          </div>
          <Field name="allow_withdrawal" label="Withdrawals permitted" type="checkbox"
            defaultValue={p ? p.allow_withdrawal : 1} />
          <Field name="is_loanable_base" label="Counts toward the loan deposit multiplier" type="checkbox"
            defaultValue={p ? p.is_loanable_base : 0} />
          <div className="grid g3">
            <Field name="gl_control_id" label="GL control account" type="select" required
              defaultValue={p?.gl_control_id} options={accountOptions(accounts)} />
            <Field name="gl_interest_exp_id" label="Interest expense account" type="select"
              defaultValue={p?.gl_interest_exp_id} options={accountOptions(accounts)} />
            <Field name="gl_fee_income_id" label="Fee income account" type="select"
              defaultValue={p?.gl_fee_income_id} options={accountOptions(accounts)} />
          </div>
        </FormModal>
      ) : null}
    </>
  );
}

export function LoanProductButton({ product, accounts, className = 'btn', children }: {
  product?: LoanProductWithUsage | null;
  accounts: GlAccount[];
  className?: string;
  children: ReactNode;
}) {
  const [open, setOpen] = useState(false);
  const p = product ?? null;

  return (
    <>
      <button type="button" className={className} onClick={() => setOpen(true)}>{children}</button>
      {open ? (
        <FormModal
          wide
          title={p ? `Edit ${p.name}` : 'New loan product'}
          onClose={() => setOpen(false)}
          onSubmit={(values) => saveLoanProduct(p ? p.id : null, values)}
          submitLabel="Save product"
          successTitle="Product saved"
        >
          <div className="grid g3">
            <Field name="code" label="Product code" defaultValue={p?.code} required disabled={!!p} />
            <Field name="name" label="Product name" defaultValue={p?.name} required />
            <Field name="status" label="Status" type="select"
              defaultValue={p?.status} options={PRODUCT_STATUSES} />
            <Field name="interest_rate" label="Interest rate (% p.a.)" type="number" step="0.01"
              defaultValue={p ? p.interest_rate : 12} />
            <Field name="interest_method" label="Interest method" type="select"
              defaultValue={p?.interest_method} options={INTEREST_METHODS} />
            <Field name="max_term_months" label="Maximum term (months)" type="number"
              defaultValue={p ? p.max_term_months : 48} />
            <Field name="min_amount_sh" label="Minimum amount" type="number" step="0.01"
              defaultValue={p ? toUnits(p.min_amount) : 0} />
            <Field name="max_amount_sh" label="Maximum amount" type="number" step="0.01"
              defaultValue={p ? toUnits(p.max_amount) : 0} />
            <Field name="deposit_multiplier" label="Deposit multiplier" type="number" step="0.1"
              defaultValue={p ? p.deposit_multiplier : 3} />
            <Field name="min_membership_months" label="Minimum membership (months)" type="number"
              defaultValue={p ? p.min_membership_months : 6} />
            <Field name="processing_fee_pct" label="Processing fee (%)" type="number" step="0.01"
              defaultValue={p ? p.processing_fee_pct : 1} />
            <Field name="insurance_pct" label="Insurance (%)" type="number" step="0.01"
              defaultValue={p ? p.insurance_pct : 0.5} />
            <Field name="penalty_rate" label="Penalty rate (% per month)" type="number" step="0.01"
              defaultValue={p ? p.penalty_rate : 1} />
            <Field name="guarantors_required" label="Guarantors required" type="number"
              defaultValue={p ? p.guarantors_required : 2} />
            <Field name="max_dsr_pct" label="Maximum deduction ratio (%)" type="number" step="0.1"
              defaultValue={p ? p.max_dsr_pct : 66.7} />
          </div>
          <div className="grid g2">
            <Field name="gl_receivable_id" label="Loan receivable account" type="select" required
              defaultValue={p?.gl_receivable_id} options={accountOptions(accounts)} />
            <Field name="gl_interest_income_id" label="Interest income account" type="select"
              defaultValue={p?.gl_interest_income_id} options={accountOptions(accounts)} />
            <Field name="gl_fee_income_id" label="Fee income account" type="select"
              defaultValue={p?.gl_fee_income_id} options={accountOptions(accounts)} />
            <Field name="gl_penalty_income_id" label="Penalty income account" type="select"
              defaultValue={p?.gl_penalty_income_id} options={accountOptions(accounts)} />
          </div>
        </FormModal>
      ) : null}
    </>
  );
}
