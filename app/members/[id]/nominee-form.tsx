'use client';

import { useState } from 'react';
import { FormModal } from '@/components/ui/form-modal';
import { saveNextOfKin, saveNominees } from '@/app/actions/nominees';
import { RELATIONSHIPS } from '@/lib/constants';
import type { MemberNextOfKin, MemberNominee } from '@/lib/types';

/* --------------------------------------------------------------------- nominees */
interface NomineeRow {
  name: string;
  relationship: string;
  phone: string;
  percentage: number | '';
  is_next_of_kin: boolean;
}

const emptyNomineeRow = (): NomineeRow =>
  ({ name: '', relationship: '', phone: '', percentage: '', is_next_of_kin: false });

export function NomineeFormButton({ memberId, nominees, className = 'btn', children }: {
  memberId: number;
  nominees: MemberNominee[];
  className?: string;
  children: React.ReactNode;
}) {
  const [open, setOpen] = useState(false);
  const [rows, setRows] = useState<NomineeRow[]>(() =>
    (nominees.length ? nominees : []).map((n) => ({
      name: n.name, relationship: n.relationship || '', phone: n.phone || '',
      percentage: n.percentage, is_next_of_kin: !!n.is_next_of_kin,
    })));

  const update = (i: number, patch: Partial<NomineeRow>) =>
    setRows((cur) => cur.map((r, k) => (k === i ? { ...r, ...patch } : r)));
  const remove = (i: number) => setRows((cur) => cur.filter((_, k) => k !== i));

  const total = Math.round(rows.reduce((sum, r) => sum + (Number(r.percentage) || 0), 0) * 100) / 100;
  const balanced = !rows.length || total === 100;

  return (
    <>
      <button type="button" className={className} onClick={() => setOpen(true)}>{children}</button>
      {open ? (
        <FormModal
          wide
          title="Nominees & beneficiaries"
          onClose={() => setOpen(false)}
          onSubmit={() => saveNominees(
            memberId,
            rows.filter((r) => r.name.trim()).map((r) => ({
              name: r.name, relationship: r.relationship || null, phone: r.phone || null,
              percentage: Number(r.percentage) || 0, is_next_of_kin: r.is_next_of_kin,
            })),
          )}
          submitLabel="Save nominees"
          successTitle="Nominees saved"
        >
          <table>
            <thead>
              <tr>
                <th>Name</th><th>Relationship</th><th>Phone</th><th style={{ width: 110 }}>Share %</th>
                <th style={{ width: 100 }}>Also NOK</th><th style={{ width: 40 }} />
              </tr>
            </thead>
            <tbody>
              {rows.map((row, i) => (
                <tr key={i}>
                  <td>
                    <input type="text" value={row.name} aria-label="Name"
                      onChange={(e) => update(i, { name: e.target.value })} />
                  </td>
                  <td>
                    <select value={row.relationship} aria-label="Relationship"
                      onChange={(e) => update(i, { relationship: e.target.value })}>
                      {RELATIONSHIPS.map((r) => (
                        <option key={r} value={r}>{r || '—'}</option>
                      ))}
                    </select>
                  </td>
                  <td>
                    <input type="text" value={row.phone} aria-label="Phone"
                      onChange={(e) => update(i, { phone: e.target.value })} />
                  </td>
                  <td>
                    <input type="number" min={0} max={100} step="0.01" value={row.percentage}
                      aria-label="Percentage share"
                      onChange={(e) => update(i, { percentage: e.target.value === '' ? '' : Number(e.target.value) })} />
                  </td>
                  <td style={{ textAlign: 'center' }}>
                    <input type="checkbox" checked={row.is_next_of_kin} aria-label="Also add as next of kin"
                      onChange={(e) => update(i, { is_next_of_kin: e.target.checked })} />
                  </td>
                  <td>
                    <button type="button" className="btn sm ghost" onClick={() => remove(i)}
                      aria-label="Remove row">×</button>
                  </td>
                </tr>
              ))}
              {!rows.length ? (
                <tr><td colSpan={6} className="tiny">No nominees yet.</td></tr>
              ) : null}
            </tbody>
            {rows.length ? (
              <tfoot>
                <tr>
                  <td colSpan={3} className="tiny">Shares must add up to 100%</td>
                  <td className={balanced ? 'pos' : 'neg'} style={{ fontWeight: 600 }}>{total}%</td>
                  <td colSpan={2} />
                </tr>
              </tfoot>
            ) : null}
          </table>
          <div className="inline" style={{ marginTop: 10 }}>
            <button type="button" className="btn ghost sm" onClick={() => setRows((cur) => [...cur, emptyNomineeRow()])}>
              Add nominee
            </button>
          </div>
        </FormModal>
      ) : null}
    </>
  );
}

/* --------------------------------------------------------------------- next of kin */
interface NokRow {
  name: string;
  relationship: string;
  phone: string;
}

const emptyNokRow = (): NokRow => ({ name: '', relationship: '', phone: '' });

export function NextOfKinFormButton({ memberId, nextOfKin, className = 'btn', children }: {
  memberId: number;
  nextOfKin: MemberNextOfKin[];
  className?: string;
  children: React.ReactNode;
}) {
  const [open, setOpen] = useState(false);
  const [rows, setRows] = useState<NokRow[]>(() =>
    nextOfKin.map((n) => ({ name: n.name, relationship: n.relationship || '', phone: n.phone || '' })));

  const update = (i: number, patch: Partial<NokRow>) =>
    setRows((cur) => cur.map((r, k) => (k === i ? { ...r, ...patch } : r)));
  const remove = (i: number) => setRows((cur) => cur.filter((_, k) => k !== i));

  return (
    <>
      <button type="button" className={className} onClick={() => setOpen(true)}>{children}</button>
      {open ? (
        <FormModal
          wide
          title="Next of kin"
          onClose={() => setOpen(false)}
          onSubmit={() => saveNextOfKin(memberId, rows.filter((r) => r.name.trim()))}
          submitLabel="Save next of kin"
          successTitle="Next of kin saved"
        >
          <table>
            <thead>
              <tr><th>Name</th><th>Relationship</th><th>Phone</th><th style={{ width: 40 }} /></tr>
            </thead>
            <tbody>
              {rows.map((row, i) => (
                <tr key={i}>
                  <td>
                    <input type="text" value={row.name} aria-label="Name"
                      onChange={(e) => update(i, { name: e.target.value })} />
                  </td>
                  <td>
                    <select value={row.relationship} aria-label="Relationship"
                      onChange={(e) => update(i, { relationship: e.target.value })}>
                      {RELATIONSHIPS.map((r) => (
                        <option key={r} value={r}>{r || '—'}</option>
                      ))}
                    </select>
                  </td>
                  <td>
                    <input type="text" value={row.phone} aria-label="Phone"
                      onChange={(e) => update(i, { phone: e.target.value })} />
                  </td>
                  <td>
                    <button type="button" className="btn sm ghost" onClick={() => remove(i)}
                      aria-label="Remove row">×</button>
                  </td>
                </tr>
              ))}
              {!rows.length ? (
                <tr><td colSpan={4} className="tiny">No next of kin on file yet.</td></tr>
              ) : null}
            </tbody>
          </table>
          <div className="inline" style={{ marginTop: 10 }}>
            <button type="button" className="btn ghost sm" onClick={() => setRows((cur) => [...cur, emptyNokRow()])}>
              Add next of kin
            </button>
          </div>
        </FormModal>
      ) : null}
    </>
  );
}
