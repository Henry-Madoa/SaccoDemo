'use client';

import { useState } from 'react';
import { FormModal } from '@/components/ui/form-modal';
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
          <div className="field">
            <label htmlFor="f_employerId">Employer</label>
            <select id="f_employerId" name="employerId" defaultValue={currentEmployerId ? String(currentEmployerId) : ''}>
              <option value="">— None —</option>
              {employers.map((e) => <option key={e.id} value={e.id}>{e.code} — {e.name}</option>)}
            </select>
          </div>
        </FormModal>
      ) : null}
    </>
  );
}
