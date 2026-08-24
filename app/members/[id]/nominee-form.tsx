'use client';

import { useState } from 'react';
import { FormModal } from '@/components/ui/form-modal';
import { saveNextOfKin, saveNominees } from '@/app/actions/nominees';
import { lookupMemberByIdentificationNo } from '@/app/actions/members';
import { RELATIONSHIPS } from '@/lib/constants';
import type { MemberNextOfKin, MemberNominee } from '@/lib/types';

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
          onSubmit={() => saveNominees(
            memberId,
            rows.filter((r) => r.name.trim()).map((r) => ({
              name: r.name, relationship: r.relationship || null, phone: r.phone || null,
              identification_no: r.identification_no || null,
              percentage: Number(r.percentage) || 0, is_next_of_kin: r.is_next_of_kin,
            })),
          )}
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

export function NextOfKinFormButton({ memberId, nextOfKin, className = 'btn', children }: {
  memberId: number;
  nextOfKin: MemberNextOfKin[];
  className?: string;
  children: React.ReactNode;
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
          onSubmit={() => saveNextOfKin(
            memberId,
            rows.filter((r) => r.name.trim()).map((r) => ({
              name: r.name, relationship: r.relationship || null, phone: r.phone || null,
              identification_no: r.identification_no || null,
            })),
          )}
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
