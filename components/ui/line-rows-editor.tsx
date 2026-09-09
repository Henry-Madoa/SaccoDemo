'use client';

import { useState } from 'react';
import { FormModal } from './form-modal';
import { EMAIL_PATTERN, EMAIL_TITLE, PHONE_PATTERN, PHONE_TITLE } from '@/lib/validate';
import { EmptyState, TableWrap } from './primitives';
import { CollapsibleCard } from './collapsible-card';
import type { ActionResult } from '@/lib/types';

/*
 * A generic "manage a repeating list of rows in a modal" editor — the pattern
 * app/member-edits/view/[no]/nok-nominee-form.tsx hand-wrote once for Next of Kin and once for
 * Nominees. Employee Management needs the same shape seven times over (next of kin,
 * beneficiaries, dependants, emergency contacts, professional bodies, work history, bank
 * accounts), each in two contexts (the live employee, and an Employee Editing request) — enough
 * repetition that a shared component earns its place instead of fourteen hand-copies.
 */

export type LineColumn<R> = {
  key: keyof R & string;
  label: string;
  type?: 'text' | 'select' | 'checkbox' | 'number' | 'date' | 'phone' | 'email';
  options?: readonly (string | { value: string | number; label: string })[];
  width?: number | string;
  /** Read-only rendering for the summary panel — defaults to the raw value. */
  render?: (row: R) => React.ReactNode;
};

export function LineRowsFormButton<R extends Record<string, any>>({
  title, wide = true, rows: initialRows, columns, emptyRow, onSave,
  submitLabel = 'Save', successTitle = 'Saved', className = 'btn', children, onSaved,
}: {
  title: string; wide?: boolean; rows: R[]; columns: LineColumn<R>[]; emptyRow: () => R;
  onSave: (rows: R[]) => Promise<ActionResult<unknown>>;
  submitLabel?: string; successTitle?: string; className?: string; children: React.ReactNode;
  onSaved?: () => void;
}) {
  const [open, setOpen] = useState(false);
  const [rows, setRows] = useState<R[]>(() => initialRows.map((r) => ({ ...r })));

  const update = (i: number, key: string, value: unknown) =>
    setRows((cur) => cur.map((r, k) => (k === i ? { ...r, [key]: value } : r)));
  const remove = (i: number) => setRows((cur) => cur.filter((_, k) => k !== i));

  return (
    <>
      <button type="button" className={className} onClick={() => setOpen(true)}>{children}</button>
      {open ? (
        <FormModal
          wide={wide} title={title} onClose={() => setOpen(false)}
          onSubmit={async () => {
            const res = await onSave(rows);
            if (res.ok) onSaved?.();
            return res;
          }}
          submitLabel={submitLabel} successTitle={successTitle}
        >
          <table>
            <thead>
              <tr>
                {columns.map((c) => <th key={c.key} style={c.width ? { width: c.width } : undefined}>{c.label}</th>)}
                <th style={{ width: 40 }} />
              </tr>
            </thead>
            <tbody>
              {rows.map((row, i) => (
                <tr key={i}>
                  {columns.map((c) => {
                    const value = row[c.key];
                    if (c.type === 'checkbox') {
                      return (
                        <td key={c.key} style={{ textAlign: 'center' }}>
                          <input type="checkbox" checked={!!value} aria-label={c.label}
                            onChange={(e) => update(i, c.key, e.target.checked)} />
                        </td>
                      );
                    }
                    if (c.type === 'select') {
                      return (
                        <td key={c.key}>
                          <select value={(value as string) ?? ''} aria-label={c.label}
                            onChange={(e) => update(i, c.key, e.target.value)}>
                            {(c.options || []).map((o) => {
                              const v = typeof o === 'object' ? o.value : o;
                              const t = typeof o === 'object' ? o.label : o;
                              return <option key={String(v)} value={v}>{t || '—'}</option>;
                            })}
                          </select>
                        </td>
                      );
                    }
                    return (
                      <td key={c.key}>
                        <input
                          type={c.type === 'number' ? 'number' : c.type === 'date' ? 'date'
                            : c.type === 'phone' ? 'tel' : c.type === 'email' ? 'email' : 'text'}
                          inputMode={c.type === 'phone' ? 'tel' : undefined}
                          pattern={c.type === 'phone' ? PHONE_PATTERN : c.type === 'email' ? EMAIL_PATTERN : undefined}
                          title={c.type === 'phone' ? PHONE_TITLE : c.type === 'email' ? EMAIL_TITLE : undefined}
                          value={(value as string | number) ?? ''} aria-label={c.label}
                          onChange={(e) => update(
                            i, c.key, c.type === 'number' ? (e.target.value === '' ? '' : Number(e.target.value)) : e.target.value,
                          )}
                        />
                      </td>
                    );
                  })}
                  <td><button type="button" className="btn sm ghost" onClick={() => remove(i)} aria-label="Remove row">×</button></td>
                </tr>
              ))}
              {!rows.length ? <tr><td colSpan={columns.length + 1} className="tiny">No rows yet.</td></tr> : null}
            </tbody>
          </table>
          <div className="inline" style={{ marginTop: 10 }}>
            <button type="button" className="btn ghost sm" onClick={() => setRows((cur) => [...cur, emptyRow()])}>Add row</button>
          </div>
        </FormModal>
      ) : null}
    </>
  );
}

/** The saved-rows summary card, with an optional "Manage" button in its header. */
export function LineRowsPanel<R extends Record<string, any>>({
  title, sub, rows, columns, icon = '📋', manageButton,
}: {
  title: string; sub?: string; rows: R[]; columns: LineColumn<R>[]; icon?: string; manageButton?: React.ReactNode;
}) {
  return (
    <CollapsibleCard title={title} sub={sub} actions={manageButton}>
      {rows.length ? (
        <TableWrap>
          <thead><tr>{columns.map((c) => <th key={c.key}>{c.label}</th>)}</tr></thead>
          <tbody>
            {rows.map((row, i) => (
              <tr key={i}>
                {columns.map((c) => (
                  <td key={c.key}>{c.render ? c.render(row) : (String(row[c.key] ?? '') || '—')}</td>
                ))}
              </tr>
            ))}
          </tbody>
        </TableWrap>
      ) : <EmptyState icon={icon} title={`No ${title.toLowerCase()} on file`} />}
    </CollapsibleCard>
  );
}
