'use client';

import { useState } from 'react';
import { FormModal } from '@/components/ui/form-modal';
import { Field } from '@/components/ui/field';
import { saveUser } from '@/app/actions/admin';
import { USER_STATUSES } from '@/lib/constants';
import type { Branch, RoleWithUsage, UserListRow } from '@/lib/types';

export function UserFormButton({ user, roles, branches, className = 'btn', children }: {
  user?: UserListRow | null;
  roles: RoleWithUsage[];
  branches: Branch[];
  className?: string;
  children: React.ReactNode;
}) {
  const [open, setOpen] = useState(false);
  const u = user ?? null;

  return (
    <>
      <button type="button" className={className} onClick={() => setOpen(true)}>{children}</button>
      {open ? (
        <FormModal
          title={u ? `Edit ${u.full_name}` : 'Add a system user'}
          onClose={() => setOpen(false)}
          onSubmit={(values) => saveUser(u ? u.id : null, values)}
          submitLabel={u ? 'Save' : 'Create user'}
          successTitle={u ? 'User updated' : 'User created'}
        >
          <div className="grid g2">
            <Field name="full_name" label="Full name" defaultValue={u?.full_name} required />
            <Field name="username" label="Username" defaultValue={u?.username} required disabled={!!u} />
            <Field name="email" label="Email" type="email" defaultValue={u?.email} />
            <Field name="phone" label="Phone" defaultValue={u?.phone} />
            <Field name="role_id" label="Role" type="select" required defaultValue={u?.role_id}
              options={roles.map((r) => ({ value: r.id, label: r.name }))} />
            <Field name="branch_id" label="Branch" type="select" defaultValue={u?.branch_id}
              options={branches.map((b) => ({ value: b.id, label: b.name }))} />
            <Field name="password" type="password" required={!u}
              label={u ? 'Reset password (leave blank to keep)' : 'Password'}
              hint="Minimum 8 characters" />
            {u ? (
              <Field name="status" label="Status" type="select"
                defaultValue={u.status} options={USER_STATUSES} />
            ) : null}
          </div>
        </FormModal>
      ) : null}
    </>
  );
}
