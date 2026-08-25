'use client';

import { useRef, useState } from 'react';
import { useRouter } from 'next/navigation';
import { Card, CardHead, DefinitionList, Pill } from '@/components/ui/primitives';
import { Field, readForm } from '@/components/ui/field';
import { MemberSelect } from '@/components/ui/member-select';
import { useToast } from '@/components/ui/toast';
import { useBeforeNext, useContinueEditing, useGoNext } from '@/components/ui/client-tabs';
import { saveMemberEditRequest } from '@/app/actions/memberEdits';
import { formatDate } from '@/lib/format';
import {
  MEMBER_TITLES, GENDERS, MARITAL_STATUSES, EMPLOYMENT_STATUSES,
} from '@/lib/constants';
import type {
  County, DimensionValue, Member, MemberCategory, MemberEditRequestWithDimensions, SubCounty,
} from '@/lib/types';

/** Shared edit-toggle plumbing for an inline-editable request card. Registers with the
 *  tab bar so its Next button saves a card mid-edit before advancing, instead of discarding it. */
function useInlineEdit(no: string, startEditing = false) {
  const router = useRouter();
  const toast = useToast();
  const formRef = useRef<HTMLFormElement>(null);
  const continueEditing = useContinueEditing();
  const [editing, setEditing] = useState(startEditing || continueEditing);
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState('');

  const save = async (): Promise<boolean> => {
    const form = formRef.current;
    if (!form || !form.reportValidity()) return false;
    setBusy(true);
    setError('');
    try {
      const values = readForm(form);
      const res = await saveMemberEditRequest(no, values);
      if (!res.ok) { setError(res.error || 'Could not save'); return false; }
      toast('Changes saved', undefined, 'ok');
      setEditing(false);
      router.refresh();
      return true;
    } finally {
      setBusy(false);
    }
  };

  useBeforeNext(editing ? save : null);
  const goNext = useGoNext();

  return { formRef, editing, setEditing, busy, error, setError, save, goNext };
}

function EditActions({ busy, error, onCancel, onSave }: {
  busy: boolean; error: string; onCancel: () => void; onSave: () => void;
}) {
  return (
    <div className="inline" style={{ marginTop: 'var(--sp)' }}>
      {error ? <div className="modal-error">{error}</div> : null}
      <button type="button" className="btn ghost sm" onClick={onCancel} disabled={busy}>Cancel</button>
      <button type="button" className="btn sm" onClick={onSave} disabled={busy}>
        {busy ? 'Saving…' : 'Save'}
      </button>
    </div>
  );
}

export interface GeneralInfoCardProps {
  request: MemberEditRequestWithDimensions;
  memberCategories: MemberCategory[];
  globalDimension1Values: DimensionValue[];
  globalDimension2Values: DimensionValue[];
  caption1: string;
  caption2: string;
  /** Every existing member — this card's own Member picker. Picking a different one re-targets
   *  the whole request onto them: every other tab is re-snapshotted from their current live
   *  data, exactly as if the request had been opened against them to begin with (see
   *  lib/memberEdits.ts's changeMemberEditRequestMember()). This is not renaming the current
   *  member's number — it's "wrong member was picked at capture time, start over on the right
   *  one." */
  members: Pick<Member, 'id' | 'member_no' | 'first_name' | 'last_name'>[];
  canEdit: boolean;
}

export function GeneralInfoCard({
  request: a, memberCategories,
  globalDimension1Values, globalDimension2Values, caption1, caption2, members, canEdit,
}: GeneralInfoCardProps) {
  const { formRef, editing, setEditing, busy, error, goNext } = useInlineEdit(a.no);
  const [memberId, setMemberId] = useState(String(a.member_id));

  return (
    <Card>
      <CardHead title="General information" sub="Workflow status and routing">
        {canEdit && !editing ? (
          // memberId lives in this component's own state rather than inside the conditionally
          // rendered <form> below, so — unlike every other (uncontrolled) field here, which gets
          // a clean slate for free each time the form unmounts/remounts on Cancel — it needs an
          // explicit reset on the way back in, or an abandoned pick would silently still be
          // sitting in state the next time Save actually runs.
          <button type="button" className="btn sm ghost"
            onClick={() => { setMemberId(String(a.member_id)); setEditing(true); }}>Edit</button>
        ) : null}
      </CardHead>

      {!editing ? (
        <DefinitionList items={[
          ['Request no.', <span className="mono" key="no">{a.no}</span>],
          ['Member', <>{a.member_first_name} {a.member_last_name} <span className="mono">({a.member_no})</span></>],
          ['Status', <Pill status={a.status} key="status" />],
          ['Member category', a.member_category_name || '—'],
          ['Join date', formatDate(a.join_date)],
          ['KYC verified', a.kyc_verified
            ? <Pill tone="ok" key="kyc">VERIFIED</Pill>
            : <Pill tone="warn" key="kyc">PENDING</Pill>],
          [caption1, a.global_dimension_1_name || '—'],
          [caption2, a.global_dimension_2_name || '—'],
          a.decision_reason ? ['Decision reason', a.decision_reason] : null,
        ]} />
      ) : (
        <>
          <form ref={formRef} onSubmit={(e) => e.preventDefault()}>
            <div className="grid g3">
              <MemberSelect id="f_member_id" name="member_id" members={members} value={memberId}
                onChange={setMemberId} required />
              <Field name="member_category_id" label="Member category" type="select" defaultValue={a.member_category_id}
                options={[
                  { value: '', label: 'Select category…' },
                  ...memberCategories.map((c) => ({ value: c.id, label: c.description })),
                ]} />
              <Field name="join_date" label="Date joined" type="date" defaultValue={a.join_date} />
              <Field name="global_dimension_1_id" label={caption1} type="select" defaultValue={a.global_dimension_1_id}
                options={[
                  { value: '', label: `Select ${caption1.toLowerCase()}…` },
                  ...globalDimension1Values.map((v) => ({ value: v.id, label: v.name })),
                ]} />
              <Field name="global_dimension_2_id" label={caption2} type="select" defaultValue={a.global_dimension_2_id}
                options={[
                  { value: '', label: `Select ${caption2.toLowerCase()}…` },
                  ...globalDimension2Values.map((v) => ({ value: v.id, label: v.name })),
                ]} />
            </div>
            {memberId !== String(a.member_id) ? (
              <div className="note">
                Saving will replace every tab on this card — name, contact details, employment,
                next of kin, nominees, signatories and KYC documents — with the newly selected
                member&apos;s own current information, discarding whatever was staged for {a.member_first_name} {a.member_last_name}.
              </div>
            ) : null}
            <Field name="kyc_verified" label="KYC documents verified" type="checkbox" defaultValue={a.kyc_verified} />
          </form>
          <EditActions busy={busy} error={error} onCancel={() => setEditing(false)} onSave={goNext} />
        </>
      )}
    </Card>
  );
}

export interface BasicInfoCardProps {
  request: MemberEditRequestWithDimensions;
  canEdit: boolean;
  startEditing?: boolean;
}

export function BasicInfoCard({ request: a, canEdit, startEditing = false }: BasicInfoCardProps) {
  const { formRef, editing, setEditing, busy, error, goNext } = useInlineEdit(a.no, canEdit && startEditing);

  return (
    <Card>
      <CardHead title="Basic information" sub="Personal identity and employment">
        {canEdit && !editing ? (
          <button type="button" className="btn sm ghost" onClick={() => setEditing(true)}>Edit</button>
        ) : null}
      </CardHead>

      {!editing ? (
        <>
          <DefinitionList items={[
            ['Name', [a.title, a.first_name, a.middle_name, a.last_name].filter(Boolean).join(' ')],
            ['Identification No.', <span className="mono" key="nid">{a.identification_no || '—'}</span>],
            ['KRA PIN', <span className="mono" key="pin">{a.kra_pin || '—'}</span>],
            ['Date of birth', formatDate(a.date_of_birth)],
            ['Gender', a.gender || '—'],
            ['Marital status', a.marital_status || '—'],
          ]} />
          <h4 className="section-title">Employment</h4>
          <DefinitionList items={[
            ['Employer', a.employer || '—'],
            ['Employment status', a.employment_status || '—'],
            ['Staff no.', <span className="mono" key="staff">{a.staff_no || '—'}</span>],
          ]} />
        </>
      ) : (
        <>
          <form ref={formRef} onSubmit={(e) => e.preventDefault()}>
            <div className="grid g3">
              <Field name="title" label="Title" type="select" defaultValue={a.title} options={MEMBER_TITLES} />
              <Field name="first_name" label="First name" defaultValue={a.first_name} required />
              <Field name="last_name" label="Last name" defaultValue={a.last_name} required />
              <Field name="middle_name" label="Middle name" defaultValue={a.middle_name} />
              <Field name="identification_no" label="Identification No." defaultValue={a.identification_no} />
              <Field name="kra_pin" label="KRA PIN" defaultValue={a.kra_pin} />
              <Field name="date_of_birth" label="Date of birth" type="date" defaultValue={a.date_of_birth} />
              <Field name="gender" label="Gender" type="select" defaultValue={a.gender} options={GENDERS} />
              <Field name="marital_status" label="Marital status" type="select" defaultValue={a.marital_status}
                options={MARITAL_STATUSES} />
            </div>
            <h4 className="section-title">Employment</h4>
            <div className="grid g3">
              <Field name="employer" label="Employer" defaultValue={a.employer} />
              <Field name="employment_status" label="Employment status" type="select"
                defaultValue={a.employment_status} options={EMPLOYMENT_STATUSES} />
              <Field name="staff_no" label="Staff / payroll no." defaultValue={a.staff_no} />
            </div>
          </form>
          <EditActions busy={busy} error={error} onCancel={() => setEditing(false)} onSave={goNext} />
        </>
      )}
    </Card>
  );
}

export interface GroupInfoCardProps {
  request: MemberEditRequestWithDimensions;
  canEdit: boolean;
  startEditing?: boolean;
}

export function GroupInfoCard({ request: a, canEdit, startEditing = false }: GroupInfoCardProps) {
  const { formRef, editing, setEditing, busy, error, goNext } = useInlineEdit(a.no, canEdit && startEditing);

  return (
    <Card>
      <CardHead title="Group/Corporate information" sub="Entity and contact-person details">
        {canEdit && !editing ? (
          <button type="button" className="btn sm ghost" onClick={() => setEditing(true)}>Edit</button>
        ) : null}
      </CardHead>

      {!editing ? (
        <DefinitionList items={[
          ['Group / entity name', a.group_name || '—'],
          ['Registration no.', <span className="mono" key="rn">{a.registration_no || '—'}</span>],
          ['Registration date', formatDate(a.registration_date)],
          ['Number of members', a.member_count ?? '—'],
        ]} />
      ) : (
        <>
          <form ref={formRef} onSubmit={(e) => e.preventDefault()}>
            <div className="grid g3">
              <Field name="group_name" label="Group / entity name" defaultValue={a.group_name} />
              <Field name="registration_no" label="Registration no." defaultValue={a.registration_no} />
              <Field name="registration_date" label="Registration date" type="date" defaultValue={a.registration_date} />
              <Field name="member_count" label="Number of members" type="number" defaultValue={a.member_count} />
            </div>
          </form>
          <EditActions busy={busy} error={error} onCancel={() => setEditing(false)} onSave={goNext} />
        </>
      )}
    </Card>
  );
}

export interface ContactInfoCardProps {
  request: MemberEditRequestWithDimensions;
  counties: County[];
  subCounties: SubCounty[];
  isIndividual: boolean;
  canEdit: boolean;
  startEditing?: boolean;
}

export function ContactInfoCard({
  request: a, counties, subCounties, isIndividual, canEdit, startEditing = false,
}: ContactInfoCardProps) {
  const { formRef, editing, setEditing, busy, error, goNext } = useInlineEdit(a.no, canEdit && startEditing);
  const [countyId, setCountyId] = useState<number | ''>(a.county_id ?? '');

  return (
    <Card>
      <CardHead title="Contact &amp; addresses" sub="How to reach the member">
        {canEdit && !editing ? (
          <button type="button" className="btn sm ghost" onClick={() => setEditing(true)}>Edit</button>
        ) : null}
      </CardHead>

      {!editing ? (
        <DefinitionList items={[
          !isIndividual ? ['Contact person', a.contact_person_name || '—'] : null,
          !isIndividual ? ['Contact phone', a.contact_person_phone || '—'] : null,
          !isIndividual ? ['Contact email', a.contact_person_email || '—'] : null,
          ['Phone', a.phone || '—'],
          ['Email', a.email || '—'],
          isIndividual ? ['Postal address', a.postal_address || '—'] : null,
          ['Physical address', a.physical_address || '—'],
          ['County', a.county_name || '—'],
          ['Sub-county', a.sub_county_name || '—'],
        ]} />
      ) : (
        <>
          <form ref={formRef} onSubmit={(e) => e.preventDefault()}>
            <div className="grid g3">
              {!isIndividual ? (
                <>
                  <Field name="contact_person_name" label="Contact person" defaultValue={a.contact_person_name} />
                  <Field name="contact_person_phone" label="Contact phone" defaultValue={a.contact_person_phone} />
                  <Field name="contact_person_email" label="Contact email" type="email"
                    defaultValue={a.contact_person_email} />
                </>
              ) : null}
              <Field name="phone" label="Phone" defaultValue={a.phone} required />
              <Field name="email" label="Email" type="email" defaultValue={a.email} />
              {isIndividual ? (
                <Field name="postal_address" label="Postal address" defaultValue={a.postal_address} />
              ) : null}
              <Field name="physical_address" label="Physical address" defaultValue={a.physical_address} />
              <Field name="county_id" label="County" type="select" defaultValue={a.county_id}
                options={[{ value: '', label: 'Select county…' }, ...counties.map((c) => ({ value: c.id, label: c.name }))]}
                onChange={(e) => setCountyId(e.target.value ? Number(e.target.value) : '')} />
              <Field key={countyId} name="sub_county_id" label="Sub-county" type="select" defaultValue={a.sub_county_id}
                options={[
                  { value: '', label: countyId ? 'Select sub-county…' : 'Select a county first' },
                  ...subCounties.filter((s) => s.county_id === countyId).map((s) => ({ value: s.id, label: s.name })),
                ]} />
            </div>
          </form>
          <EditActions busy={busy} error={error} onCancel={() => setEditing(false)} onSave={goNext} />
        </>
      )}
    </Card>
  );
}
