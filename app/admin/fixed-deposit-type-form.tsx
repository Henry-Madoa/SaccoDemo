'use client';

import { useState, type ReactNode } from 'react';
import { FormModal } from '@/components/ui/form-modal';
import { Field } from '@/components/ui/field';
import { GlAccountSelect } from '@/components/ui/gl-account-select';
import { SearchableSelect } from '@/components/ui/searchable-select';
import { saveFixedDepositType } from '@/app/actions/fixedDepositTypes';
import { FD_INTEREST_CALC_TYPES, PRODUCT_STATUSES } from '@/lib/constants';
import type { GlAccount, MemberFixedDepositTypeWithUsage, SavingsProduct } from '@/lib/types';

export function FixedDepositTypeButton({ fdType, products, accounts, className = 'btn', children }: {
  fdType?: MemberFixedDepositTypeWithUsage | null;
  products: SavingsProduct[];
  accounts: GlAccount[];
  className?: string;
  children: ReactNode;
}) {
  const [open, setOpen] = useState(false);
  const t = fdType ?? null;
  const [interestExpenseGlId, setInterestExpenseGlId] = useState(String(t?.interest_expense_gl_id ?? ''));
  const [interestPayableGlId, setInterestPayableGlId] = useState(String(t?.interest_payable_gl_id ?? ''));
  const [withholdingTaxGlId, setWithholdingTaxGlId] = useState(String(t?.withholding_tax_gl_id ?? ''));
  const [linkedProductId, setLinkedProductId] = useState(String(t?.linked_product_id ?? ''));

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
            <SearchableSelect name="linked_product_id" label="Linked savings product" required
              items={products} getValue={(p) => String(p.id)} getLabel={(p) => `${p.code} — ${p.name}`}
              value={linkedProductId} onChange={setLinkedProductId} placeholder="Search product…"
              emptyText="No matching products"
              hint="New fixed deposit accounts open under this product" />
            <GlAccountSelect name="interest_expense_gl_id" label="Interest expense account" required
              accounts={accounts} value={interestExpenseGlId} onChange={setInterestExpenseGlId}
              hint="Debited monthly on interest accrual" />
            <GlAccountSelect name="interest_payable_gl_id" label="Interest payable account" required
              accounts={accounts} value={interestPayableGlId} onChange={setInterestPayableGlId}
              hint="Credited monthly on accrual, cleared at maturity" />
            <Field name="withholding_tax_rate" label="Withholding tax rate (%)" type="number" step="0.01" min={0}
              defaultValue={t?.withholding_tax_rate ?? 0} />
            <GlAccountSelect name="withholding_tax_gl_id" label="Withholding tax account"
              accounts={accounts} value={withholdingTaxGlId} onChange={setWithholdingTaxGlId}
              hint="Required if the withholding tax rate is above zero" />
            <Field name="status" label="Status" type="select" defaultValue={t?.status} options={PRODUCT_STATUSES} />
          </div>
        </FormModal>
      ) : null}
    </>
  );
}
