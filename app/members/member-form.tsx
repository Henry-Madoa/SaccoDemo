'use client';

import { useState, type ReactNode } from 'react';
import { FormModal } from '@/components/ui/form-modal';
import { Field } from '@/components/ui/field';
import { saveMember } from '@/app/actions/members';
import { today, toUnits } from '@/lib/format';
import {
  MEMBER_STATUSES, MEMBER_TITLES, GENDERS, MARITAL_STATUSES, EMPLOYMENT_STATUSES,
} from '@/lib/constants';
import type { Branch, MemberWithBranch } from '@/lib/types';

export interface MemberFormProps {
  member?: MemberWithBranch | null;
  branches: Branch[];
  onClose: () => void;
}

export function MemberForm({ member, branches, onClose }: MemberFormProps) {
  const m = member ?? null;

  return (
    <FormModal
      wide
      title={m ? `Edit ${m.first_name} ${m.last_name}` : 'Register a new member'}
      onClose={onClose}
      onSubmit={(values) => saveMember(m ? m.id : null, values)}
      submitLabel={m ? 'Save changes' : 'Register member'}
      successTitle={m ? 'Member updated' : 'Member registered'}
      successDetail={(saved) => `${saved.member_no} — ${saved.first_name} ${saved.last_name}`}
    >
      <div className="grid g3">
        <Field name="title" label="Title" type="select" defaultValue={m?.title} options={MEMBER_TITLES} />
        <Field name="first_name" label="First name" defaultValue={m?.first_name} required />
        <Field name="last_name" label="Last name" defaultValue={m?.last_name} required />
        <Field name="middle_name" label="Middle name" defaultValue={m?.middle_name} />
        <Field name="national_id" label="National ID" defaultValue={m?.national_id} hint="Checked for duplicates" />
        <Field name="kra_pin" label="KRA PIN" defaultValue={m?.kra_pin} />
        <Field name="date_of_birth" label="Date of birth" type="date" defaultValue={m?.date_of_birth} />
        <Field name="gender" label="Gender" type="select" defaultValue={m?.gender} options={GENDERS} />
        <Field name="marital_status" label="Marital status" type="select" defaultValue={m?.marital_status} options={MARITAL_STATUSES} />
        <Field name="phone" label="Phone" defaultValue={m?.phone} />
        <Field name="email" label="Email" type="email" defaultValue={m?.email} />
        <Field name="county" label="County" defaultValue={m?.county} />
        <Field name="postal_address" label="Postal address" defaultValue={m?.postal_address} />
        <Field name="physical_address" label="Physical address" defaultValue={m?.physical_address} />
        <Field name="branch_id" label="Branch" type="select" defaultValue={m?.branch_id}
          options={branches.map((b) => ({ value: b.id, label: b.name }))} />
      </div>

      <h4 className="section-title">Employment &amp; affordability</h4>
      <div className="grid g3">
        <Field name="employer" label="Employer" defaultValue={m?.employer} />
        <Field name="employment_status" label="Employment status" type="select"
          defaultValue={m?.employment_status} options={EMPLOYMENT_STATUSES} />
        <Field name="staff_no" label="Staff / payroll no." defaultValue={m?.staff_no} />
        <Field name="gross_income_sh" label="Gross monthly income" type="number" step="0.01"
          defaultValue={m?.gross_income ? toUnits(m.gross_income) : ''}
          hint="Used for the deduction-ratio test" />
        <Field name="other_deductions_sh" label="Other monthly deductions" type="number" step="0.01"
          defaultValue={m?.other_deductions ? toUnits(m.other_deductions) : ''} />
        <Field name="status" label="Member status" type="select"
          defaultValue={m?.status || 'ACTIVE'} options={MEMBER_STATUSES} />
      </div>

      <h4 className="section-title">Next of kin</h4>
      <div className="grid g3">
        <Field name="nok_name" label="Full name" defaultValue={m?.nok_name} />
        <Field name="nok_relationship" label="Relationship" defaultValue={m?.nok_relationship} />
        <Field name="nok_phone" label="Phone" defaultValue={m?.nok_phone} />
      </div>

      <Field name="kyc_verified" label="KYC documents verified" type="checkbox" defaultValue={m?.kyc_verified} />
      <Field name="join_date" label="Date joined" type="date" defaultValue={m?.join_date || today()} />
    </FormModal>
  );
}

/** Button that opens the member form. Used by the registry and the 360 view. */
export function MemberFormButton({ member, branches, className = 'btn', children }: {
  member?: MemberWithBranch | null;
  branches: Branch[];
  className?: string;
  children: ReactNode;
}) {
  const [open, setOpen] = useState(false);
  return (
    <>
      <button type="button" className={className} onClick={() => setOpen(true)}>{children}</button>
      {open ? <MemberForm member={member} branches={branches} onClose={() => setOpen(false)} /> : null}
    </>
  );
}
