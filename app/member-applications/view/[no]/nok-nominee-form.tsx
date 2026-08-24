'use client';

import { useState } from 'react';
import { FormModal } from '@/components/ui/form-modal';
import { Card, CardHead, EmptyState, Pill, TableWrap } from '@/components/ui/primitives';
import { saveApplicationNextOfKin, saveApplicationNominees } from '@/app/actions/applicationNominees';
import { lookupMemberByIdentificationNo } from '@/app/actions/members';
import { RELATIONSHIPS } from '@/lib/constants';
import type { MemberApplicationNextOfKin, MemberApplicationNominee } from '@/lib/types';

/** Looks up whichever member (if any) already carries this Identification No. and, when found,
 *  fills in the row's Name and Phone from that member's own record instead of asking the
 *  officer to retype what's already on file — the "if this nominee/next of kin is an existing
 *  member" auto-populate behaviour, triggered the moment the ID field loses focus. */
async function matchExistingMember(idNo: string): Promise<{ name: string; phone: string; memberNo: string } | null> {
  const trimmed = idNo.trim();
  if (!trimmed) return null;
  const res = await lookupMemberByIdentificationNo(trimmed);
  if (!res.ok || !res.data) return null;
  return { name: `${res.data.first_name} ${res.data.last_name}`, phone: res.data.phone || '', memberNo: res.data.member_no };
}

/* --------------------------------------------------------------------- nominees */
interface NomineeRow {
  name: string;
  relationship: string;
  phone: string;
  identification_no: string;
  percentage: number | '';
  is_next_of_kin: boolean;
  /** Set once the Identification No. matches an existing member — display only, never submitted. */
  matchedMemberNo?: string | null;
}

const emptyNomineeRow = (): NomineeRow => ({
  name: '', relationship: '', phone: '', identification_no: '', percentage: '', is_next_of_kin: false,
  matchedMemberNo: null,
});

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
      identification_no: n.identification_no || '', percentage: n.percentage, is_next_of_kin: !!n.is_next_of_kin,
      matchedMemberNo: null,
    })));

  const update = (i: number, patch: Partial<NomineeRow>) =>
    setRows((cur) => cur.map((r, k) => (k === i ? { ...r, ...patch } : r)));
  const remove = (i: number) => setRows((cur) => cur.filter((_, k) => k !== i));

  const onIdBlur = async (i: number, value: string) => {
    const match = await matchExistingMember(value);
    if (!match) { update(i, { matchedMemberNo: null }); return; }
    update(i, { name: match.name, phone: match.phone, matchedMemberNo: match.memberNo });
  };

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
                identification_no: r.identification_no || null,
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
                <th>Name</th><th>Relationship</th><th>Phone</th><th>Identification No.</th>
                <th style={{ width: 110 }}>Share %</th>
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
                    <input type="text" value={row.identification_no} aria-label="Identification No."
                      onChange={(e) => update(i, { identification_no: e.target.value, matchedMemberNo: null })}
                      onBlur={(e) => onIdBlur(i, e.target.value)} />
                    {row.matchedMemberNo ? (
                      <div className="tiny" style={{ color: 'var(--ok)' }}>Matched member {row.matchedMemberNo}</div>
                    ) : null}
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
                <tr><td colSpan={7} className="tiny">No nominees yet.</td></tr>
              ) : null}
            </tbody>
            {rows.length ? (
              <tfoot>
                <tr>
                  <td colSpan={4} className="tiny">Shares must add up to 100%</td>
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
  identification_no: string;
  matchedMemberNo?: string | null;
}

const emptyNokRow = (): NokRow => ({ name: '', relationship: '', phone: '', identification_no: '', matchedMemberNo: null });

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
    nextOfKin.map((n) => ({
      name: n.name, relationship: n.relationship || '', phone: n.phone || '',
      identification_no: n.identification_no || '', matchedMemberNo: null,
    })));

  const update = (i: number, patch: Partial<NokRow>) =>
    setRows((cur) => cur.map((r, k) => (k === i ? { ...r, ...patch } : r)));
  const remove = (i: number) => setRows((cur) => cur.filter((_, k) => k !== i));

  const onIdBlur = async (i: number, value: string) => {
    const match = await matchExistingMember(value);
    if (!match) { update(i, { matchedMemberNo: null }); return; }
    update(i, { name: match.name, phone: match.phone, matchedMemberNo: match.memberNo });
  };

  return (
    <>
      <button type="button" className={className} onClick={() => setOpen(true)}>{children}</button>
      {open ? (
        <FormModal
          wide
          title="Next of kin"
          onClose={() => setOpen(false)}
          onSubmit={async () => {
            const res = await saveApplicationNextOfKin(
              applicationNo,
              rows.filter((r) => r.name.trim()).map((r) => ({
                name: r.name, relationship: r.relationship || null, phone: r.phone || null,
                identification_no: r.identification_no || null,
              })),
            );
            if (res.ok) onSaved?.();
            return res;
          }}
          submitLabel="Save next of kin"
          successTitle="Next of kin saved"
        >
          <table>
            <thead>
              <tr><th>Name</th><th>Relationship</th><th>Phone</th><th>Identification No.</th><th style={{ width: 40 }} /></tr>
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
                    <input type="text" value={row.identification_no} aria-label="Identification No."
                      onChange={(e) => update(i, { identification_no: e.target.value, matchedMemberNo: null })}
                      onBlur={(e) => onIdBlur(i, e.target.value)} />
                    {row.matchedMemberNo ? (
                      <div className="tiny" style={{ color: 'var(--ok)' }}>Matched member {row.matchedMemberNo}</div>
                    ) : null}
                  </td>
                  <td>
                    <button type="button" className="btn sm ghost" onClick={() => remove(i)}
                      aria-label="Remove row">×</button>
                  </td>
                </tr>
              ))}
              {!rows.length ? (
                <tr><td colSpan={5} className="tiny">No next of kin on file yet.</td></tr>
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
            <tr><th>Name</th><th>Relationship</th><th>Phone</th><th>Identification No.</th></tr>
          </thead>
          <tbody>
            {nextOfKin.map((n) => (
              <tr key={n.id}>
                <td><b>{n.name}</b></td>
                <td>{n.relationship || '—'}</td>
                <td>{n.phone || '—'}</td>
                <td className="mono">{n.identification_no || '—'}</td>
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
              <th>Name</th><th>Relationship</th><th>Phone</th><th>Identification No.</th>
              <th className="num">Share</th><th>Also NOK</th>
            </tr>
          </thead>
          <tbody>
            {nominees.map((n) => (
              <tr key={n.id}>
                <td><b>{n.name}</b></td>
                <td>{n.relationship || '—'}</td>
                <td>{n.phone || '—'}</td>
                <td className="mono">{n.identification_no || '—'}</td>
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
