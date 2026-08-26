'use client';

import { useState } from 'react';
import { FormModal } from '@/components/ui/form-modal';
import { SearchableSelect } from '@/components/ui/searchable-select';
import { setMemberEmployerRequest } from '@/app/actions/employers';
import type { Employer } from '@/lib/types';

/** Links a member to a formal Employer record for checkoff/salary batch routing
 *  (lib/checkoffBatches.ts) — direct and ungated (no approval workflow), since this is
 *  payroll-routing metadata, not the kind of KYC fact Member Editing exists to protect. */
export function SetEmployerButton({ memberId, currentEmployerId, employers, className = 'btn sm ghost' }: {
  memberId: number;
  currentEmployerId: number | null;
  employers: Employer[];
  className?: string;
}) {
  const [open, setOpen] = useState(false);
  const [employerId, setEmployerId] = useState(currentEmployerId ? String(currentEmployerId) : '');

  return (
    <>
      <button type="button" className={className} onClick={() => setOpen(true)}>
        {currentEmployerId ? 'Change employer' : 'Set employer'}
      </button>
      {open ? (
        <FormModal
          title="Set employer (for checkoff/salary batches)"
          onClose={() => setOpen(false)}
          onSubmit={(values) => setMemberEmployerRequest(
            memberId, values.employerId ? Number(values.employerId) : null,
          )}
          submitLabel="Save"
          successTitle="Employer updated"
        >
          <SearchableSelect name="employerId" label="Employer"
            items={employers} getValue={(e) => String(e.id)} getLabel={(e) => `${e.code} — ${e.name}`}
            value={employerId} onChange={setEmployerId} placeholder="— None —" emptyText="No matching employers" />
        </FormModal>
      ) : null}
    </>
  );
}
