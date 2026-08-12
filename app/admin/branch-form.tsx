'use client';

import { useState } from 'react';
import { FormModal } from '@/components/ui/form-modal';
import { Field } from '@/components/ui/field';
import { saveBranch } from '@/app/actions/admin';
import { BRANCH_STATUSES } from '@/lib/constants';
import type { Branch } from '@/lib/types';

export function BranchFormButton({ branch, className = 'btn', children }: {
  branch?: Branch | null;
  className?: string;
  children: React.ReactNode;
}) {
  const [open, setOpen] = useState(false);
  const b = branch ?? null;

  return (
    <>
      <button type="button" className={className} onClick={() => setOpen(true)}>{children}</button>
      {open ? (
        <FormModal
          title={b ? `Edit ${b.name}` : 'Add a branch'}
          onClose={() => setOpen(false)}
          onSubmit={(values) => saveBranch(b ? b.id : null, values)}
          submitLabel="Save"
          successTitle="Branch saved"
          successDetail={(saved) => saved.name}
        >
          <Field name="code" label="Branch code" defaultValue={b?.code} required disabled={!!b} />
          <Field name="name" label="Branch name" defaultValue={b?.name} required />
          <Field name="town" label="Town" defaultValue={b?.town} />
          <Field name="phone" label="Phone" defaultValue={b?.phone} />
          {b ? (
            <Field name="status" label="Status" type="select"
              defaultValue={b.status} options={BRANCH_STATUSES} />
          ) : null}
        </FormModal>
      ) : null}
    </>
  );
}
