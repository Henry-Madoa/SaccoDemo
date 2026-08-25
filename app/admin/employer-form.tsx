'use client';

import { useState } from 'react';
import { FormModal } from '@/components/ui/form-modal';
import { Field } from '@/components/ui/field';
import { createEmployerRequest, updateEmployerRequest } from '@/app/actions/employers';
import { PRODUCT_STATUSES } from '@/lib/constants';
import type { Employer } from '@/lib/types';

export function EmployerFormButton({ employer, className = 'btn', children }: {
  employer?: Employer | null;
  className?: string;
  children: React.ReactNode;
}) {
  const [open, setOpen] = useState(false);
  const e = employer ?? null;

  return (
    <>
      <button type="button" className={className} onClick={() => setOpen(true)}>{children}</button>
      {open ? (
        <FormModal
          title={e ? `Edit ${e.code}` : 'Add an employer'}
          onClose={() => setOpen(false)}
          onSubmit={(values) => (e ? updateEmployerRequest(e.id, values) : createEmployerRequest(values))}
          submitLabel={e ? 'Save changes' : 'Create'}
          successTitle={e ? 'Employer updated' : 'Employer created'}
        >
          <Field name="code" label="Code" required placeholder="e.g. GOK" defaultValue={e?.code} disabled={!!e} uppercase />
          <Field name="name" label="Name" required placeholder="e.g. Government of Kenya" defaultValue={e?.name} />
          <div className="grid g2">
            <Field name="phone" label="Phone" defaultValue={e?.phone ?? ''} />
            <Field name="email" label="Email" defaultValue={e?.email ?? ''} />
          </div>
          <Field name="payroll_no_mandatory" label="Payroll number mandatory for members" type="checkbox"
            defaultValue={e?.payroll_no_mandatory ? '1' : ''} />
          {e ? (
            <Field name="status" label="Status" type="select" options={PRODUCT_STATUSES} defaultValue={e.status} />
          ) : null}
        </FormModal>
      ) : null}
    </>
  );
}
