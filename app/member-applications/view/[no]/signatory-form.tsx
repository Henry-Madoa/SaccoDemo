'use client';

import { useState } from 'react';
import { FormModal } from '@/components/ui/form-modal';
import { Card, CardHead, EmptyState, TableWrap } from '@/components/ui/primitives';
import { saveApplicationSignatories } from '@/app/actions/applicationSignatories';
import { SIGNATORY_DESIGNATIONS } from '@/lib/constants';
import { formatDate } from '@/lib/format';
import type { MemberApplicationSignatory } from '@/lib/types';

interface SignatoryRow {
  identification_no: string;
  name: string;
  designation: string;
  date_of_birth: string;
  email: string;
  phone: string;
}

const emptySignatoryRow = (): SignatoryRow =>
  ({ identification_no: '', name: '', designation: '', date_of_birth: '', email: '', phone: '' });

export function ApplicationSignatoryFormButton({ applicationNo, signatories, className = 'btn', children, onSaved }: {
  applicationNo: string;
  signatories: MemberApplicationSignatory[];
  className?: string;
  children: React.ReactNode;
  /** Called after a successful save, for callers holding their own copy of the list. */
  onSaved?: () => void;
}) {
  const [open, setOpen] = useState(false);
  const [rows, setRows] = useState<SignatoryRow[]>(() =>
    signatories.map((s) => ({
      identification_no: s.identification_no || '', name: s.name, designation: s.designation || '',
      date_of_birth: s.date_of_birth || '', email: s.email || '', phone: s.phone || '',
    })));

  const update = (i: number, patch: Partial<SignatoryRow>) =>
    setRows((cur) => cur.map((r, k) => (k === i ? { ...r, ...patch } : r)));
  const remove = (i: number) => setRows((cur) => cur.filter((_, k) => k !== i));

  return (
    <>
      <button type="button" className={className} onClick={() => setOpen(true)}>{children}</button>
      {open ? (
        <FormModal
          wide
          title="Signatories"
          onClose={() => setOpen(false)}
          onSubmit={async () => {
            const res = await saveApplicationSignatories(
              applicationNo,
              rows.filter((r) => r.name.trim()).map((r) => ({
                identification_no: r.identification_no || null, name: r.name,
                designation: r.designation || null, date_of_birth: r.date_of_birth || null,
                email: r.email || null, phone: r.phone || null,
              })),
            );
            if (res.ok) onSaved?.();
            return res;
          }}
          submitLabel="Save signatories"
          successTitle="Signatories saved"
        >
          <table>
            <thead>
              <tr>
                <th>Identification No</th><th>Name</th><th>Designation</th>
                <th>Date of birth</th><th>Email</th><th>Phone</th><th style={{ width: 40 }} />
              </tr>
            </thead>
            <tbody>
              {rows.map((row, i) => (
                <tr key={i}>
                  <td>
                    <input type="text" value={row.identification_no} aria-label="Identification No" required
                      onChange={(e) => update(i, { identification_no: e.target.value })} />
                  </td>
                  <td>
                    <input type="text" value={row.name} aria-label="Name" required
                      onChange={(e) => update(i, { name: e.target.value })} />
                  </td>
                  <td>
                    <select value={row.designation} aria-label="Designation" required
                      onChange={(e) => update(i, { designation: e.target.value })}>
                      {SIGNATORY_DESIGNATIONS.map((d) => (
                        <option key={d} value={d}>{d || '—'}</option>
                      ))}
                    </select>
                  </td>
                  <td>
                    <input type="date" value={row.date_of_birth} aria-label="Date of birth" required
                      onChange={(e) => update(i, { date_of_birth: e.target.value })} />
                  </td>
                  <td>
                    <input type="email" value={row.email} aria-label="Email"
                      onChange={(e) => update(i, { email: e.target.value })} />
                  </td>
                  <td>
                    <input type="text" value={row.phone} aria-label="Phone" required
                      onChange={(e) => update(i, { phone: e.target.value })} />
                  </td>
                  <td>
                    <button type="button" className="btn sm ghost" onClick={() => remove(i)}
                      aria-label="Remove row">×</button>
                  </td>
                </tr>
              ))}
              {!rows.length ? (
                <tr><td colSpan={7} className="tiny">No signatories yet.</td></tr>
              ) : null}
            </tbody>
          </table>
          <div className="inline" style={{ marginTop: 10 }}>
            <button type="button" className="btn ghost sm" onClick={() => setRows((cur) => [...cur, emptySignatoryRow()])}>
              Add signatory
            </button>
          </div>
        </FormModal>
      ) : null}
    </>
  );
}

/** Card showing the saved signatory list plus a "Manage" button — the Signatories tab's content. */
export function ApplicationSignatoryPanel({ applicationNo, signatories, canManage, onSaved }: {
  applicationNo: string;
  signatories: MemberApplicationSignatory[];
  canManage: boolean;
  onSaved?: () => void;
}) {
  return (
    <Card>
      <CardHead title="Signatories" sub="Office bearers authorised to act on the eventual member account">
        {canManage ? (
          <ApplicationSignatoryFormButton
            applicationNo={applicationNo} signatories={signatories} className="btn sm ghost" onSaved={onSaved}
          >
            Manage
          </ApplicationSignatoryFormButton>
        ) : null}
      </CardHead>
      {signatories.length ? (
        <TableWrap>
          <thead>
            <tr>
              <th>Identification No</th><th>Name</th><th>Designation</th>
              <th>Date of birth</th><th>Email</th><th>Phone</th>
            </tr>
          </thead>
          <tbody>
            {signatories.map((s) => (
              <tr key={s.id}>
                <td className="mono">{s.identification_no || '—'}</td>
                <td><b>{s.name}</b></td>
                <td>{s.designation || '—'}</td>
                <td>{formatDate(s.date_of_birth)}</td>
                <td>{s.email || '—'}</td>
                <td>{s.phone || '—'}</td>
              </tr>
            ))}
          </tbody>
        </TableWrap>
      ) : <EmptyState icon="✍" title="No signatories on file" />}
    </Card>
  );
}
