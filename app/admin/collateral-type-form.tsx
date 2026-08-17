'use client';

import { useState, type ReactNode } from 'react';
import { FormModal } from '@/components/ui/form-modal';
import { Field } from '@/components/ui/field';
import { saveCollateralType } from '@/app/actions/collateralTypes';
import { COLLATERAL_CATEGORIES, PRODUCT_STATUSES } from '@/lib/constants';
import type { CollateralTypeWithUsage } from '@/lib/types';

export function CollateralTypeButton({ collateralType, className = 'btn', children }: {
  collateralType?: CollateralTypeWithUsage | null;
  className?: string;
  children: ReactNode;
}) {
  const [open, setOpen] = useState(false);
  const t = collateralType ?? null;

  return (
    <>
      <button type="button" className={className} onClick={() => setOpen(true)}>{children}</button>
      {open ? (
        <FormModal
          title={t ? `Edit ${t.code}` : 'New collateral type'}
          onClose={() => setOpen(false)}
          onSubmit={(values) => saveCollateralType(t ? t.id : null, values)}
          submitLabel="Save collateral type"
          successTitle="Collateral type saved"
        >
          <div className="grid g2">
            <Field name="code" label="Code" defaultValue={t?.code} required disabled={!!t} />
            <Field name="description" label="Description" defaultValue={t?.description} required />
            <Field name="category" label="Category" type="select" required
              defaultValue={t?.category} options={COLLATERAL_CATEGORIES.map((c) => ({ value: c.value, label: c.label }))} />
            <Field name="value_multiplier" label="Value multiplier — loan-to-value (%)" type="number" step="0.01"
              min={0} defaultValue={t ? t.value_multiplier : 70}
              hint="Applied to the appraised value to derive the realisable security value" />
            <Field name="status" label="Status" type="select" defaultValue={t?.status} options={PRODUCT_STATUSES} />
          </div>
        </FormModal>
      ) : null}
    </>
  );
}
