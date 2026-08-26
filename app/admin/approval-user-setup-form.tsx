'use client';

import { useState } from 'react';
import { FormModal } from '@/components/ui/form-modal';
import { Field } from '@/components/ui/field';
import { SearchableSelect } from '@/components/ui/searchable-select';
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
  const [approverId, setApproverId] = useState(String(row.approver_id ?? ''));
  const [substituteId, setSubstituteId] = useState(String(row.substitute_id ?? ''));

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
            <SearchableSelect name="approver_id" label="Approver"
              hint="Resolved for this user's requests when a workflow step is set to &quot;Requester's approver&quot;"
              items={others} getValue={(u) => String(u.user_id)} getLabel={(u) => u.full_name}
              value={approverId} onChange={setApproverId} placeholder="Search user…" emptyText="No matching users" />
            <SearchableSelect name="substitute_id" label="Substitute"
              hint="Also eligible to act on anything routed to this user"
              items={others} getValue={(u) => String(u.user_id)} getLabel={(u) => u.full_name}
              value={substituteId} onChange={setSubstituteId} placeholder="Search user…" emptyText="No matching users" />
          </div>
          <Field name="is_approval_administrator" label="Approval Administrator"
            type="checkbox" defaultValue={row.is_approval_administrator}
            hint="Fallback approver when a &quot;Requester's approver&quot; step can't resolve one" />
          <Field name="can_reverse_journal" label="Can Reverse Journal"
            type="checkbox" defaultValue={row.can_reverse_journal}
            hint="Required to reverse any posted transaction — GL journal, savings, and so on — on top of that module's own reversal permission" />
        </FormModal>
      ) : null}
    </>
  );
}
