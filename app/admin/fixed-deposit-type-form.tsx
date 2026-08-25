'use client';

import { useState, type ReactNode } from 'react';
import { FormModal } from '@/components/ui/form-modal';
import { Field } from '@/components/ui/field';
import { saveFixedDepositType } from '@/app/actions/fixedDepositTypes';
import { FD_INTEREST_CALC_TYPES, PRODUCT_STATUSES } from '@/lib/constants';
import type { GlAccount, MemberFixedDepositTypeWithUsage, SavingsProduct } from '@/lib/types';

const accountOptions = (accounts: GlAccount[]) =>
  accounts.map((a) => ({ value: a.id, label: `${a.code} — ${a.name}` }));

export function FixedDepositTypeButton({ fdType, products, accounts, className = 'btn', children }: {
  fdType?: MemberFixedDepositTypeWithUsage | null;
  products: SavingsProduct[];
  accounts: GlAccount[];
  className?: string;
  children: ReactNode;
}) {
  const [open, setOpen] = useState(false);
  const t = fdType ?? null;

  return (
    <>
      <button type="button" className={className} onClick={() => setOpen(true)}>{children}</button>
      {open ? (
        <FormModal
          title={t ? `Edit ${t.code}` : 'New fixed deposit type'}
          onClose={() => setOpen(false)}
          onSubmit={(values) => saveFixedDepositType(t ? t.id : null, values)}
          submitLabel="Save fixed deposit type"
          successTitle="Fixed deposit type saved"
        >
          <div className="grid g2">
            <Field name="code" label="Code" defaultValue={t?.code} required disabled={!!t} />
            <Field name="description" label="Description" defaultValue={t?.description} required />
            <Field name="min_interest_rate" label="Min. interest rate (%)" type="number" step="0.01" min={0}
              defaultValue={t?.min_interest_rate ?? 0} />
            <Field name="max_interest_rate" label="Max. interest rate (%)" type="number" step="0.01" min={0}
              defaultValue={t?.max_interest_rate ?? 0} />
            <Field name="interest_calc_type" label="Interest calc type" type="select" required
              defaultValue={t?.interest_calc_type ?? 'FLAT'} options={FD_INTEREST_CALC_TYPES} />
            <Field name="linked_product_id" label="Linked savings product" type="select" required
              defaultValue={t?.linked_product_id}
              options={products.map((p) => ({ value: p.id, label: p.name }))}
              hint="New fixed deposit accounts open under this product" />
            <Field name="interest_expense_gl_id" label="Interest expense account" type="select" required
              defaultValue={t?.interest_expense_gl_id} options={accountOptions(accounts)}
              hint="Debited monthly on interest accrual" />
            <Field name="interest_payable_gl_id" label="Interest payable account" type="select" required
              defaultValue={t?.interest_payable_gl_id} options={accountOptions(accounts)}
              hint="Credited monthly on accrual, cleared at maturity" />
            <Field name="withholding_tax_rate" label="Withholding tax rate (%)" type="number" step="0.01" min={0}
              defaultValue={t?.withholding_tax_rate ?? 0} />
            <Field name="withholding_tax_gl_id" label="Withholding tax account" type="select"
              defaultValue={t?.withholding_tax_gl_id ?? ''}
              options={[{ value: '', label: '— None —' }, ...accountOptions(accounts)]}
              hint="Required if the withholding tax rate is above zero" />
            <Field name="status" label="Status" type="select" defaultValue={t?.status} options={PRODUCT_STATUSES} />
          </div>
        </FormModal>
      ) : null}
    </>
  );
}
