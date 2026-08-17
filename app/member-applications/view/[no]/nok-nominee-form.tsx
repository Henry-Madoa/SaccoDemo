'use client';

import { useState } from 'react';
import { FormModal } from '@/components/ui/form-modal';
import { Card, CardHead, EmptyState, Pill, TableWrap } from '@/components/ui/primitives';
import { saveApplicationNextOfKin, saveApplicationNominees } from '@/app/actions/applicationNominees';
import { RELATIONSHIPS } from '@/lib/constants';
import type { MemberApplicationNextOfKin, MemberApplicationNominee } from '@/lib/types';

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

export function ApplicationNomineeFormButton({ applicationNo, nominees, className = 'btn', children, onSaved }: {
  applicationNo: string;
  nominees: MemberApplicationNominee[];
  className?: string;
  children: React.ReactNode;
  /** Called after a successful save, for callers holding their own copy of the list. */
  onSaved?: () => void;
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
          onSubmit={async () => {
            const res = await saveApplicationNominees(
              applicationNo,
              rows.filter((r) => r.name.trim()).map((r) => ({
                name: r.name, relationship: r.relationship || null, phone: r.phone || null,
                percentage: Number(r.percentage) || 0, is_next_of_kin: r.is_next_of_kin,
              })),
            );
            if (res.ok) onSaved?.();
            return res;
          }}
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
                      onChange={(e) => update(i, { name: e.target.value })} required />
                  </td>
                  <td>
                    <select value={row.relationship} aria-label="Relationship" required
                      onChange={(e) => update(i, { relationship: e.target.value })}> 
                      {RELATIONSHIPS.map((r) => (
                        <option key={r} value={r}>{r || '—'}</option>
                      ))}
                    </select>
                  </td>
                  <td>
                    <input type="text" value={row.phone} aria-label="Phone"
                      onChange={(e) => update(i, { phone: e.target.value })} required/>
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

export function ApplicationNextOfKinFormButton({ applicationNo, nextOfKin, className = 'btn', children, onSaved }: {
  applicationNo: string;
  nextOfKin: MemberApplicationNextOfKin[];
  className?: string;
  children: React.ReactNode;
  /** Called after a successful save, for callers holding their own copy of the list. */
  onSaved?: () => void;
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
          onSubmit={async () => {
            const res = await saveApplicationNextOfKin(applicationNo, rows.filter((r) => r.name.trim()));
            if (res.ok) onSaved?.();
            return res;
          }}
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
                      onChange={(e) => update(i, { name: e.target.value })} required/>
                  </td>
                  <td>
                    <select value={row.relationship} aria-label="Relationship" required
                      onChange={(e) => update(i, { relationship: e.target.value })}>
                      {RELATIONSHIPS.map((r) => (
                        <option key={r} value={r}>{r || '—'}</option>
                      ))}
                    </select>
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

/* --------------------------------------------------------------------- summary panels */

/** Card showing the saved next-of-kin list plus a "Manage" button — the Next Of Kin tab's content. */
export function ApplicationNextOfKinPanel({ applicationNo, nextOfKin, canManage, onSaved }: {
  applicationNo: string;
  nextOfKin: MemberApplicationNextOfKin[];
  canManage: boolean;
  onSaved?: () => void;
}) {
  return (
    <Card>
      <CardHead title="Next of kin" sub="A member can have more than one">
        {canManage ? (
          <ApplicationNextOfKinFormButton
            applicationNo={applicationNo} nextOfKin={nextOfKin} className="btn sm ghost" onSaved={onSaved}
          >
            Manage
          </ApplicationNextOfKinFormButton>
        ) : null}
      </CardHead>
      {nextOfKin.length ? (
        <TableWrap>
          <thead>
            <tr><th>Name</th><th>Relationship</th><th>Phone</th></tr>
          </thead>
          <tbody>
            {nextOfKin.map((n) => (
              <tr key={n.id}>
                <td><b>{n.name}</b></td>
                <td>{n.relationship || '—'}</td>
                <td>{n.phone || '—'}</td>
              </tr>
            ))}
          </tbody>
        </TableWrap>
      ) : <EmptyState icon="👪" title="No next of kin on file" />}
    </Card>
  );
}

/** Card showing the saved nominee list plus a "Manage" button — the Nominee tab's content. */
export function ApplicationNomineePanel({ applicationNo, nominees, canManage, onSaved }: {
  applicationNo: string;
  nominees: MemberApplicationNominee[];
  canManage: boolean;
  onSaved?: () => void;
}) {
  return (
    <Card>
      <CardHead title="Nominees & beneficiaries" sub="Shares of benefit on the eventual member account">
        {canManage ? (
          <ApplicationNomineeFormButton
            applicationNo={applicationNo} nominees={nominees} className="btn sm ghost" onSaved={onSaved}
          >
            Manage
          </ApplicationNomineeFormButton>
        ) : null}
      </CardHead>
      {nominees.length ? (
        <TableWrap>
          <thead>
            <tr>
              <th>Name</th><th>Relationship</th><th>Phone</th>
              <th className="num">Share</th><th>Also NOK</th>
            </tr>
          </thead>
          <tbody>
            {nominees.map((n) => (
              <tr key={n.id}>
                <td><b>{n.name}</b></td>
                <td>{n.relationship || '—'}</td>
                <td>{n.phone || '—'}</td>
                <td className="num">{n.percentage}%</td>
                <td>{n.is_next_of_kin ? <Pill tone="info">YES</Pill> : '—'}</td>
              </tr>
            ))}
          </tbody>
        </TableWrap>
      ) : <EmptyState icon="🎗" title="No nominees on file" />}
    </Card>
  );
}
