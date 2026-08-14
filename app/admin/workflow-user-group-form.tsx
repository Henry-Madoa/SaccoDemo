'use client';

import { useEffect, useMemo, useState } from 'react';
import { FormModal } from '@/components/ui/form-modal';
import { Field } from '@/components/ui/field';
import { saveWorkflowUserGroup } from '@/app/actions/workflows';
import { PRODUCT_STATUSES } from '@/lib/constants';
import type { UserListRow, WorkflowUserGroupMemberRow, WorkflowUserGroupWithUsage } from '@/lib/types';

const DROPDOWN_LIMIT = 25;

/** One past the highest sequence already in use — where a newly added member naturally slots in. */
const suggestSequence = (members: Map<number, number>): number =>
  members.size ? Math.max(...members.values()) + 1 : 1;

export function WorkflowUserGroupFormButton({ group, members, users, className = 'btn', children }: {
  group?: WorkflowUserGroupWithUsage | null;
  members?: WorkflowUserGroupMemberRow[];
  users: UserListRow[];
  className?: string;
  children: React.ReactNode;
}) {
  const [open, setOpen] = useState(false);
  const g = group ?? null;
  const [selected, setSelected] = useState<Map<number, number>>(() =>
    new Map((members || []).map((m) => [m.user_id, m.sequence])));
  const usersById = useMemo(() => new Map(users.map((u) => [u.id, u])), [users]);

  const [query, setQuery] = useState('');
  const [pickedUserId, setPickedUserId] = useState<number | ''>('');
  const [pickedSequence, setPickedSequence] = useState(() => suggestSequence(selected));

  // Re-suggest the next sequence whenever the member list actually changes (add/remove) —
  // left alone while the admin is just typing a value in, so their override sticks.
  useEffect(() => setPickedSequence(suggestSequence(selected)), [selected]);

  const availableUsers = useMemo(() => {
    const q = query.trim().toLowerCase();
    const pool = users.filter((u) => !selected.has(u.id)
      && (!q || u.full_name.toLowerCase().includes(q) || u.username.toLowerCase().includes(q)));
    return pool.slice().sort((a, b) => a.full_name.localeCompare(b.full_name)).slice(0, DROPDOWN_LIMIT);
  }, [users, query, selected]);
  const truncated = availableUsers.length === DROPDOWN_LIMIT;

  const addMember = () => {
    if (!pickedUserId) return;
    setSelected((cur) => new Map(cur).set(pickedUserId, pickedSequence || 1));
    setQuery('');
    setPickedUserId('');
  };
  const removeMember = (id: number) =>
    setSelected((cur) => {
      const next = new Map(cur);
      next.delete(id);
      return next;
    });
  const setMemberSequence = (id: number, sequence: number) =>
    setSelected((cur) => new Map(cur).set(id, sequence));

  const memberRows = [...selected].map(([user_id, sequence]) => ({ user_id, sequence, user: usersById.get(user_id) }))
    .sort((a, b) => a.sequence - b.sequence || (a.user?.full_name || '').localeCompare(b.user?.full_name || ''));

  return (
    <>
      <button type="button" className={className} onClick={() => setOpen(true)}>{children}</button>
      {open ? (
        <FormModal
          title={g ? `Edit ${g.name}` : 'Add an approval user group'}
          onClose={() => setOpen(false)}
          onSubmit={(values) => saveWorkflowUserGroup(
            g ? g.id : null,
            values,
            [...selected].map(([user_id, sequence]) => ({ user_id, sequence })),
          )}
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
          <div className="card-sub">
            Members sharing the same sequence approve as alternates — any one of them clears that level.
            Lower sequences approve before higher ones.
          </div>

          <input
            type="text"
            placeholder="Search to narrow the dropdown by name or username…"
            value={query}
            onChange={(e) => { setQuery(e.target.value); setPickedUserId(''); }}
            style={{ marginTop: 8 }}
          />
          <div className="inline" style={{ marginTop: 8 }}>
            <select
              value={pickedUserId} aria-label="User to add" style={{ flex: 1 }}
              onChange={(e) => setPickedUserId(e.target.value ? Number(e.target.value) : '')}
            >
              <option value="">Select user…</option>
              {availableUsers.map((u) => (
                <option key={u.id} value={u.id}>{u.full_name} ({u.username})</option>
              ))}
            </select>
            <input
              type="number" min={1} value={pickedSequence} aria-label="Sequence for new member"
              style={{ width: 64 }}
              onChange={(e) => setPickedSequence(Number(e.target.value) || 1)}
            />
            <button type="button" className="btn sm" disabled={!pickedUserId} onClick={addMember}>Add member</button>
          </div>
          {truncated ? (
            <div className="tiny" style={{ marginTop: 4 }}>
              Showing the first {DROPDOWN_LIMIT} matches — search to narrow it down further.
            </div>
          ) : null}

          <table style={{ marginTop: 10 }}>
            <thead>
              <tr><th>Member</th><th style={{ width: 90 }}>Sequence</th><th style={{ width: 40 }} /></tr>
            </thead>
            <tbody>
              {memberRows.map(({ user_id, sequence, user }) => (
                <tr key={user_id}>
                  <td style={{ whiteSpace: 'nowrap' }}>
                    {user ? <>{user.full_name} <span className="tiny">({user.username})</span></> : `User #${user_id}`}
                  </td>
                  <td>
                    <input
                      type="number" min={1} value={sequence} aria-label={`Sequence for ${user?.full_name ?? user_id}`}
                      style={{ width: 64 }}
                      onChange={(e) => setMemberSequence(user_id, Number(e.target.value) || 1)} disabled
                    />
                  </td>
                  <td>
                    <button type="button" className="btn sm ghost" onClick={() => removeMember(user_id)}
                      aria-label="Remove member">×</button>
                  </td>
                </tr>
              ))}
              {!memberRows.length ? (
                <tr><td colSpan={3} className="tiny">No members yet — pick one from the dropdown above.</td></tr>
              ) : null}
            </tbody>
          </table>
        </FormModal>
      ) : null}
    </>
  );
}
