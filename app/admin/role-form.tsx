'use client';

import { useState } from 'react';
import { FormModal } from '@/components/ui/form-modal';
import { Field } from '@/components/ui/field';
import { Card } from '@/components/ui/primitives';
import { saveRole } from '@/app/actions/admin';
import { humanise } from '@/lib/format';
import type { Permission, PermissionResource, RoleWithUsage } from '@/lib/types';

export function RoleFormButton({ role, catalogue, className = 'btn', children }: {
  role?: RoleWithUsage | null;
  catalogue: Record<PermissionResource, string[]>;
  className?: string;
  children: React.ReactNode;
}) {
  const [open, setOpen] = useState(false);
  const r = role ?? null;

  // A role holding '*' has every permission; show the boxes ticked accordingly.
  const initial = new Set<Permission>(
    r
      ? (r.permissions.includes('*')
        ? Object.entries(catalogue).flatMap(([res, acts]) => acts.map((a) => `${res}:${a}`))
        : r.permissions)
      : [],
  );
  const [selected, setSelected] = useState<Set<Permission>>(initial);

  const toggle = (key: Permission, on: boolean) =>
    setSelected((cur) => {
      const next = new Set(cur);
      if (on) next.add(key); else next.delete(key);
      return next;
    });

  return (
    <>
      <button type="button" className={className} onClick={() => setOpen(true)}>{children}</button>
      {open ? (
        <FormModal
          wide
          title={r ? `Edit role — ${r.name}` : 'Create a role'}
          onClose={() => setOpen(false)}
          onSubmit={(values) => saveRole(r ? r.id : null, values, [...selected])}
          submitLabel={r ? 'Save role' : 'Create role'}
          successTitle={r ? 'Role updated' : 'Role created'}
        >
          <Field name="name" label="Role name" defaultValue={r?.name} required />
          <Field name="description" label="Description" defaultValue={r?.description} />

          <h4 className="section-title">Permissions</h4>
          <div className="grid g2">
            {Object.entries(catalogue).map(([resource, actions]) => (
              <Card key={resource} className="inset">
                <b style={{ fontSize: 12 }}>{resource}</b>
                <div style={{ marginTop: 8 }}>
                  {actions.map((action) => {
                    const key = `${resource}:${action}`;
                    return (
                      <div className="checkline" key={key}>
                        <input type="checkbox" id={`p_${key}`} checked={selected.has(key)}
                          onChange={(e) => toggle(key, e.target.checked)} />
                        <label htmlFor={`p_${key}`} style={{ fontWeight: 400 }}>
                          {humanise(action).toLowerCase()}
                        </label>
                      </div>
                    );
                  })}
                </div>
              </Card>
            ))}
          </div>
        </FormModal>
      ) : null}
    </>
  );
}
