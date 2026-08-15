'use client';

import { useState } from 'react';
import { FormModal } from '@/components/ui/form-modal';
import { Field } from '@/components/ui/field';
import { createCharge, updateCharge } from '@/app/actions/charges';
import { PRODUCT_STATUSES } from '@/lib/constants';
import type { Charge } from '@/lib/types';

export function ChargeFormButton({ charge, className = 'btn', children }: {
  charge?: Charge | null;
  className?: string;
  children: React.ReactNode;
}) {
  const [open, setOpen] = useState(false);
  const c = charge ?? null;

  return (
    <>
      <button type="button" className={className} onClick={() => setOpen(true)}>{children}</button>
      {open ? (
        <FormModal
          title={c ? `Edit ${c.code}` : 'Add a charge'}
          onClose={() => setOpen(false)}
          onSubmit={(values) => (c ? updateCharge(c.id, values) : createCharge(values))}
          submitLabel={c ? 'Save changes' : 'Create'}
          successTitle={c ? 'Charge updated' : 'Charge created'}
        >
          <Field name="code" label="Charge code" required placeholder="e.g. REACTFEE"
            defaultValue={c?.code} disabled={!!c} uppercase />
          <Field name="description" label="Description" required defaultValue={c?.description} />
          {c ? (
            <Field name="status" label="Status" type="select" options={PRODUCT_STATUSES} defaultValue={c.status} />
          ) : null}
        </FormModal>
      ) : null}
    </>
  );
}
