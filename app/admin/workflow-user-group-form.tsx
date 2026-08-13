'use client';

import { useState } from 'react';
import { FormModal } from '@/components/ui/form-modal';
import { Field } from '@/components/ui/field';
import { saveWorkflowUserGroup } from '@/app/actions/workflows';
import { PRODUCT_STATUSES } from '@/lib/constants';
import type { UserListRow, WorkflowUserGroupWithUsage } from '@/lib/types';

export function WorkflowUserGroupFormButton({ group, memberUserIds, users, className = 'btn', children }: {
  group?: WorkflowUserGroupWithUsage | null;
  memberUserIds?: number[];
  users: UserListRow[];
  className?: string;
  children: React.ReactNode;
}) {
  const [open, setOpen] = useState(false);
  const g = group ?? null;
  const [selected, setSelected] = useState<Set<number>>(() => new Set(memberUserIds || []));

  const toggle = (id: number) =>
    setSelected((cur) => {
      const next = new Set(cur);
      if (next.has(id)) next.delete(id); else next.add(id);
      return next;
    });

  return (
    <>
      <button type="button" className={className} onClick={() => setOpen(true)}>{children}</button>
      {open ? (
        <FormModal
          title={g ? `Edit ${g.name}` : 'Add an approval user group'}
          onClose={() => setOpen(false)}
          onSubmit={(values) => saveWorkflowUserGroup(g ? g.id : null, values, [...selected])}
          submitLabel="Save group"
          successTitle="Group saved"
        >
          <div className="grid g2">
            <Field name="name" label="Group name" defaultValue={g?.name} required maxLength={60} />
            {g ? (
              <Field name="status" label="Status" type="select" defaultValue={g.status} options={PRODUCT_STATUSES} />
            ) : null}
          </div>

          <h4 className="section-title">Members</h4>
          <div style={{ maxHeight: 260, overflowY: 'auto', border: '1px solid var(--border)', borderRadius: 'var(--radius-sm)' }}>
            {users.map((u) => (
              <label key={u.id} className="checkline" style={{ padding: '6px 10px' }}>
                <input type="checkbox" checked={selected.has(u.id)} onChange={() => toggle(u.id)} />
                {u.full_name} <span className="tiny">({u.username})</span>
              </label>
            ))}
          </div>
        </FormModal>
      ) : null}
    </>
  );
}
