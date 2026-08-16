'use client';

import { useState } from 'react';
import { FormModal } from '@/components/ui/form-modal';
import { Field } from '@/components/ui/field';
import { saveApprovalUserSetupRow } from '@/app/actions/workflows';
import type { ApprovalUserSetupRow } from '@/lib/types';

export function ApprovalUserSetupFormButton({ row, users, className = 'btn', children }: {
  row: ApprovalUserSetupRow;
  users: ApprovalUserSetupRow[];
  className?: string;
  children: React.ReactNode;
}) {
  const [open, setOpen] = useState(false);
  const others = users.filter((u) => u.user_id !== row.user_id);

  return (
    <>
      <button type="button" className={className} onClick={() => setOpen(true)}>{children}</button>
      {open ? (
        <FormModal
          title={`Approval setup — ${row.full_name}`}
          onClose={() => setOpen(false)}
          onSubmit={(values) => saveApprovalUserSetupRow(row.user_id, values)}
          submitLabel="Save"
          successTitle="Approval setup saved"
        >
          <div className="grid g2">
            <Field name="approver_id" label="Approver" type="select" defaultValue={row.approver_id}
              hint="Resolved for this user's requests when a workflow step is set to &quot;Requester's approver&quot;"
              options={[{ value: '', label: 'None' }, ...others.map((u) => ({ value: u.user_id, label: u.full_name }))]} />
            <Field name="substitute_id" label="Substitute" type="select" defaultValue={row.substitute_id}
              hint="Also eligible to act on anything routed to this user"
              options={[{ value: '', label: 'None' }, ...others.map((u) => ({ value: u.user_id, label: u.full_name }))]} />
          </div>
          <Field name="is_approval_administrator" label="Approval Administrator"
            type="checkbox" defaultValue={row.is_approval_administrator}
            hint="Fallback approver when a &quot;Requester's approver&quot; step can't resolve one" />
          <Field name="can_reverse_journal" label="Can Reverse Journal"
            type="checkbox" defaultValue={row.can_reverse_journal}
            hint="Required to reverse a posted GL journal, on top of the General Ledger role permission" />
        </FormModal>
      ) : null}
    </>
  );
}
