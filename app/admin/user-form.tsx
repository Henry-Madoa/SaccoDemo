'use client';

import { useState } from 'react';
import { FormModal } from '@/components/ui/form-modal';
import { Field } from '@/components/ui/field';
import { SearchableSelect } from '@/components/ui/searchable-select';
import { saveUser } from '@/app/actions/admin';
import { USER_STATUSES } from '@/lib/constants';
import { PASSWORD_RULES } from '@/lib/password';
import type { RoleWithUsage, UserListRow } from '@/lib/types';

export function UserFormButton({ user, roles, className = 'btn', children }: {
  user?: UserListRow | null;
  roles: RoleWithUsage[];
  className?: string;
  children: React.ReactNode;
}) {
  const [open, setOpen] = useState(false);
  const u = user ?? null;
  const [username, setUsername] = useState(u?.username ?? '');
  const [password, setPassword] = useState('');
  const [roleId, setRoleId] = useState(String(u?.role_id ?? ''));

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
            <Field name="username" label="Username" defaultValue={u?.username} required disabled={!!u}
              onChange={(e) => setUsername(e.target.value)} />
            <Field name="email" label="Email" type="email" defaultValue={u?.email} />
            <Field name="phone" label="Phone" defaultValue={u?.phone} />
            <SearchableSelect name="role_id" label="Role" required
              items={roles} getValue={(r) => String(r.id)} getLabel={(r) => r.name}
              value={roleId} onChange={setRoleId} placeholder="Search role…" emptyText="No matching roles" />
            <Field name="password" type="password" required={!u}
              label={u ? 'Reset password (leave blank to keep)' : 'Password'}
              onChange={(e) => setPassword(e.target.value)} />
            {u ? (
              <Field name="status" label="Status" type="select"
                defaultValue={u.status} options={USER_STATUSES} />
            ) : null}
            {!u || password ? (
              <div className="field" style={{ gridColumn: '1 / -1' }}>
                <label>Password requirements</label>
                <ul className="pw-checklist">
                  {PASSWORD_RULES.map((rule) => {
                    const pass = rule.test(password, { username });
                    return (
                      <li key={rule.id}>
                        <span className={pass ? 'factor-ok' : 'factor-no'}>{pass ? '✔' : '✖'}</span> {rule.label}
                      </li>
                    );
                  })}
                </ul>
              </div>
            ) : null}
          </div>
        </FormModal>
      ) : null}
    </>
  );
}
