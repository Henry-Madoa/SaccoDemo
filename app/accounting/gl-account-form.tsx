'use client';

import { useState } from 'react';
import { FormModal } from '@/components/ui/form-modal';
import { Field } from '@/components/ui/field';
import { createGlAccount } from '@/app/actions/gl';
import { GL_ACCOUNT_TYPES } from '@/lib/constants';

export function AddGlAccountButton() {
  const [open, setOpen] = useState(false);
  return (
    <>
      <button type="button" className="btn" onClick={() => setOpen(true)}>Add account</button>
      {open ? (
        <FormModal
          title="Add a GL account"
          onClose={() => setOpen(false)}
          onSubmit={createGlAccount}
          submitLabel="Create"
          successTitle="Account created"
        >
          <Field name="code" label="Account code" required placeholder="e.g. 4060" />
          <Field name="name" label="Account name" required />
          <Field name="type" label="Type" type="select" required options={GL_ACCOUNT_TYPES} />
          <Field name="parent_code" label="Parent code" placeholder="Optional" />
          <Field name="is_postable" label="Postable (transactions may be posted here)"
            type="checkbox" defaultValue={1} />
        </FormModal>
      ) : null}
    </>
  );
}
