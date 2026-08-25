'use client';

import { useState } from 'react';
import { FormModal } from '@/components/ui/form-modal';
import { Field } from '@/components/ui/field';
import { createSalaryAppraisalParameter, updateSalaryAppraisalParameter } from '@/app/actions/salaryAppraisal';
import { PRODUCT_STATUSES, SALARY_APPRAISAL_LINE_TYPES, SALARY_APPRAISAL_SPECIAL_TYPES } from '@/lib/constants';
import type { SalaryAppraisalParameter } from '@/lib/types';

export function SalaryAppraisalParameterFormButton({ parameter, className = 'btn', children }: {
  parameter?: SalaryAppraisalParameter | null;
  className?: string;
  children: React.ReactNode;
}) {
  const [open, setOpen] = useState(false);
  const p = parameter ?? null;

  return (
    <>
      <button type="button" className={className} onClick={() => setOpen(true)}>{children}</button>
      {open ? (
        <FormModal
          title={p ? `Edit ${p.code}` : 'Add a salary appraisal parameter'}
          onClose={() => setOpen(false)}
          onSubmit={(values) => (p ? updateSalaryAppraisalParameter(p.id, values) : createSalaryAppraisalParameter(values))}
          submitLabel={p ? 'Save changes' : 'Create'}
          successTitle={p ? 'Parameter updated' : 'Parameter created'}
        >
          <Field name="code" label="Code" required placeholder="e.g. BASIC" defaultValue={p?.code} disabled={!!p} uppercase />
          <Field name="name" label="Name" required placeholder="e.g. Basic Salary" defaultValue={p?.name} />
          <Field name="type" label="Type" type="select" required options={SALARY_APPRAISAL_LINE_TYPES}
            defaultValue={p?.type ?? 'EARNING'} />
          <Field name="special_type" label="Special type" type="select" options={SALARY_APPRAISAL_SPECIAL_TYPES}
            defaultValue={p?.special_type ?? 'NONE'}
            hint="Only one Earning line should be flagged Basic Salary — it drives the loan card's 1/3 affordability cap" />
          {p ? (
            <Field name="status" label="Status" type="select" options={PRODUCT_STATUSES} defaultValue={p.status} />
          ) : null}
        </FormModal>
      ) : null}
    </>
  );
}
