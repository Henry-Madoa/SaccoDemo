'use client';

import { useRef, useState } from 'react';
import { useRouter } from 'next/navigation';
import { DefinitionList } from '@/components/ui/primitives';
import { CollapsibleCard } from '@/components/ui/collapsible-card';
import { Field, readForm } from '@/components/ui/field';
import { SearchableSelect } from '@/components/ui/searchable-select';
import { useToast } from '@/components/ui/toast';
import { updateEmployeeEditRequestAction } from '@/app/actions/employeeEdits';
import { GENDERS, MARITAL_STATUSES } from '@/lib/constants';
import type { EditLookups } from './edit-actions';
import type { EmployeeEditRequestView } from '@/lib/types';

/** Mirrors app/member-edits/view/[no]/info-cards.tsx's inline-editable card pattern: an Edit
 *  button swaps the card's read-only view for its own <form>; Save posts just that section's
 *  fields (lib/employeeEdits.ts's updateEmployeeEditRequest() only touches fields it's given). */
function useInlineEdit(no: string, startEditing = false) {
  const router = useRouter();
  const toast = useToast();
  const formRef = useRef<HTMLFormElement>(null);
  const [editing, setEditing] = useState(startEditing);
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState('');

  const save = async () => {
    const form = formRef.current;
    if (!form || !form.reportValidity()) return;
    setBusy(true);
    setError('');
    try {
      const values = readForm(form);
      const res = await updateEmployeeEditRequestAction(no, values);
      if (!res.ok) { setError(res.error || 'Could not save'); return; }
      toast('Changes saved', undefined, 'ok');
      setEditing(false);
      router.refresh();
    } finally {
      setBusy(false);
    }
  };

  return { formRef, editing, setEditing, busy, error, save };
}

function EditActions({ busy, error, onCancel, onSave }: { busy: boolean; error: string; onCancel: () => void; onSave: () => void }) {
  return (
    <div className="inline" style={{ marginTop: 'var(--sp)' }}>
      {error ? <div className="modal-error">{error}</div> : null}
      <button type="button" className="btn ghost sm" onClick={onCancel} disabled={busy}>Cancel</button>
      <button type="button" className="btn sm" onClick={onSave} disabled={busy}>{busy ? 'Saving…' : 'Save'}</button>
    </div>
  );
}

export function EditBioDataCard({ request: r, lookups, canEdit, startEditing = false }: {
  request: EmployeeEditRequestView; lookups: EditLookups; canEdit: boolean; startEditing?: boolean;
}) {
  const { formRef, editing, setEditing, busy, error, save } = useInlineEdit(r.no, canEdit && startEditing);
  const [countyId, setCountyId] = useState(String(r.county_id ?? ''));
  const [subCountyId, setSubCountyId] = useState(String(r.sub_county_id ?? ''));
  const subCounties = lookups.subCounties.filter((s) => String(s.county_id) === countyId);

  return (
    <CollapsibleCard title="Proposed bio-data" sub="Values that will replace the live employee record on Apply"
      actions={canEdit && !editing ? (
        <button type="button" className="btn sm ghost"
          onClick={() => { setCountyId(String(r.county_id ?? '')); setSubCountyId(String(r.sub_county_id ?? '')); setEditing(true); }}>
          Edit
        </button>
      ) : null}
    >
      {!editing ? (
        <div className="grid g2">
          <DefinitionList items={[
            ['First name', r.first_name || '—'],
            ['Middle name', r.middle_name || '—'],
            ['Last name', r.last_name || '—'],
            ['Gender', r.gender || '—'],
            ['Date of birth', r.date_of_birth || '—'],
            ['Marital status', r.marital_status || '—'],
            ['National ID', r.national_id || '—'],
            ['KRA PIN', r.kra_pin || '—'],
            ['NSSF No.', r.nssf_no || '—'],
            ['SHIF No.', r.shif_no || '—'],
          ]} />
          <DefinitionList items={[
            ['Phone', r.phone || '—'],
            ['Alt. phone', r.alt_phone || '—'],
            ['Email', r.email || '—'],
            ['Physical address', r.physical_address || '—'],
            ['County', r.county_name || '—'],
            ['Sub-county', r.sub_county_name || '—'],
          ]} />
        </div>
      ) : (
        <>
          <form ref={formRef} onSubmit={(ev) => ev.preventDefault()}>
            <div className="grid g3">
              <Field name="first_name" label="First name" required defaultValue={r.first_name ?? ''} />
              <Field name="middle_name" label="Middle name" defaultValue={r.middle_name ?? ''} />
              <Field name="last_name" label="Last name" required defaultValue={r.last_name ?? ''} />
            </div>
            <div className="grid g3">
              <Field name="gender" label="Gender" type="select" options={GENDERS} defaultValue={r.gender ?? ''} />
              <Field name="date_of_birth" label="Date of birth" type="date" defaultValue={r.date_of_birth ?? ''} />
              <Field name="marital_status" label="Marital status" type="select" options={MARITAL_STATUSES} defaultValue={r.marital_status ?? ''} />
            </div>
            <div className="grid g3">
              <Field name="national_id" label="National ID" defaultValue={r.national_id ?? ''} />
              <Field name="kra_pin" label="KRA PIN" defaultValue={r.kra_pin ?? ''} />
              <Field name="nssf_no" label="NSSF No." defaultValue={r.nssf_no ?? ''} />
            </div>
            <div className="grid g2">
              <Field name="shif_no" label="SHIF No." defaultValue={r.shif_no ?? ''} />
              <Field name="phone" label="Phone" defaultValue={r.phone ?? ''} />
            </div>
            <div className="grid g2">
              <Field name="alt_phone" label="Alternative phone" defaultValue={r.alt_phone ?? ''} />
              <Field name="email" label="Email" defaultValue={r.email ?? ''} />
            </div>
            <Field name="physical_address" label="Physical address" defaultValue={r.physical_address ?? ''} />
            <div className="grid g2">
              <SearchableSelect id="f_county_id" name="county_id" label="County"
                items={lookups.counties} getValue={(c) => String(c.id)} getLabel={(c) => c.name}
                value={countyId} onChange={(v) => { setCountyId(v); setSubCountyId(''); }} placeholder="Search county…" />
              <SearchableSelect id="f_sub_county_id" name="sub_county_id" label="Sub-county"
                items={subCounties} getValue={(s) => String(s.id)} getLabel={(s) => s.name}
                value={subCountyId} onChange={setSubCountyId} disabled={!countyId}
                placeholder={countyId ? 'Search sub-county…' : 'Pick a county first'} />
            </div>
          </form>
          <EditActions busy={busy} error={error} onCancel={() => setEditing(false)} onSave={save} />
        </>
      )}
    </CollapsibleCard>
  );
}

export function EditEmploymentBankingCard({ request: r, lookups, canEdit }: {
  request: EmployeeEditRequestView; lookups: EditLookups; canEdit: boolean;
}) {
  const { formRef, editing, setEditing, busy, error, save } = useInlineEdit(r.no);
  const [dim1Id, setDim1Id] = useState(String(r.global_dimension_1_id ?? ''));
  const [dim2Id, setDim2Id] = useState(String(r.global_dimension_2_id ?? ''));
  const [jobGradeId, setJobGradeId] = useState(String(r.job_grade_id ?? ''));

  return (
    <CollapsibleCard title="Proposed employment &amp; banking" sub="Dimensions, job title, grade and bank details"
      actions={canEdit && !editing ? (
        <button type="button" className="btn sm ghost"
          onClick={() => {
            setDim1Id(String(r.global_dimension_1_id ?? '')); setDim2Id(String(r.global_dimension_2_id ?? ''));
            setJobGradeId(String(r.job_grade_id ?? '')); setEditing(true);
          }}>
          Edit
        </button>
      ) : null}
    >
      {!editing ? (
        <DefinitionList items={[
          [lookups.caption1, r.global_dimension_1_name || '—'],
          [lookups.caption2, r.global_dimension_2_name || '—'],
          ['Job title', r.job_title || '—'],
          ['Job grade', r.job_grade_name || '—'],
          ['Bank code', r.bank_code || '—'],
          ['Branch', r.bank_branch || '—'],
          ['Account number', r.bank_account_no || '—'],
        ]} />
      ) : (
        <>
          <form ref={formRef} onSubmit={(ev) => ev.preventDefault()}>
            <div className="grid g2">
              <SearchableSelect id="f_gd1" name="global_dimension_1_id" label={lookups.caption1}
                items={lookups.globalDimension1Values} getValue={(d) => String(d.id)} getLabel={(d) => `${d.code} — ${d.name}`}
                value={dim1Id} onChange={setDim1Id} placeholder={`Search ${lookups.caption1.toLowerCase()}…`} emptyText="No matches" />
              <SearchableSelect id="f_gd2" name="global_dimension_2_id" label={lookups.caption2}
                items={lookups.globalDimension2Values} getValue={(d) => String(d.id)} getLabel={(d) => `${d.code} — ${d.name}`}
                value={dim2Id} onChange={setDim2Id} placeholder={`Search ${lookups.caption2.toLowerCase()}…`} emptyText="No matches" />
            </div>
            <div className="grid g2">
              <Field name="job_title" label="Job title" defaultValue={r.job_title ?? ''} />
              <SearchableSelect id="f_job_grade_id" name="job_grade_id" label="Job grade"
                items={lookups.jobGrades} getValue={(g) => String(g.id)} getLabel={(g) => `${g.code} — ${g.name}`}
                value={jobGradeId} onChange={setJobGradeId} placeholder="Search job grade…" />
            </div>
            <div className="note" style={{ marginTop: 4, marginBottom: 4 }}>Banking</div>
            <div className="grid g3">
              <Field name="bank_code" label="Bank code" defaultValue={r.bank_code ?? ''} />
              <Field name="bank_branch" label="Branch" defaultValue={r.bank_branch ?? ''} />
              <Field name="bank_account_no" label="Account number" defaultValue={r.bank_account_no ?? ''} />
            </div>
          </form>
          <EditActions busy={busy} error={error} onCancel={() => setEditing(false)} onSave={save} />
        </>
      )}
    </CollapsibleCard>
  );
}
