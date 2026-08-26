'use client';

import { useEffect, useState } from 'react';
import { useRouter } from 'next/navigation';
import { FormModal } from '@/components/ui/form-modal';
import { Field } from '@/components/ui/field';
import { MemberSelect } from '@/components/ui/member-select';
import { SearchableSelect } from '@/components/ui/searchable-select';
import { useResultDialog } from '@/components/ui/result-dialog';
import { useConfirm } from '@/components/ui/confirm-dialog';
import { useRunAction } from '@/components/ui/run-action';
import {
  createCollateralApplicationRequest, saveCollateralApplication, deleteCollateralApplicationRequest,
  submitCollateralApplicationRequest, cancelCollateralApplicationApprovalRequest,
  approveCollateralApplicationRequest, rejectCollateralApplicationRequest, postCollateralApplicationRequest,
  eligibleCollateralTypesForCategory,
} from '@/app/actions/collateralApplications';
import { delegateMyTask } from '@/app/actions/workflows';
import { COLLATERAL_CATEGORIES } from '@/lib/constants';
import { toUnits } from '@/lib/format';
import type {
  CollateralApplicationWithDetails, CollateralType, Member,
} from '@/lib/types';

type MemberOption = Pick<Member, 'id' | 'member_no' | 'first_name' | 'last_name'>;
type CountyOption = { id: number; name: string };

export function SubmitButton({ no, className = 'btn sm ghost' }: { no: string; className?: string }) {
  const { run, busy } = useRunAction();
  return (
    <button type="button" className={className} disabled={busy}
      onClick={() => run(() => submitCollateralApplicationRequest(no), {
        confirm: {
          title: 'Send this application for approval?',
          message: 'It will be routed to the configured approver(s) and can no longer be edited while pending.',
          confirmLabel: 'Send for approval',
        },
        successTitle: (d) => (d.autoApproved ? 'Application approved' : 'Sent for approval'),
        successDetail: (d) => (d.autoApproved
          ? 'You are the assigned approver, so this was approved automatically.' : undefined),
      })}>
      {busy ? 'Working…' : 'Send for approval'}
    </button>
  );
}

export function CancelApprovalButton({ no, className = 'btn sm ghost' }: { no: string; className?: string }) {
  const { run, busy } = useRunAction();
  return (
    <button type="button" className={className} disabled={busy}
      onClick={() => run(() => cancelCollateralApplicationApprovalRequest(no), {
        confirm: {
          title: 'Cancel this approval request?',
          message: 'The application goes back to Open so you can amend and resubmit it.',
          confirmLabel: 'Cancel approval request',
        },
        successTitle: 'Approval request cancelled — back to Open',
      })}>
      {busy ? 'Working…' : 'Cancel approval request'}
    </button>
  );
}

export function DelegateButton({ taskId, className = 'btn sm ghost' }: { taskId: number; className?: string }) {
  const { run, busy } = useRunAction();
  return (
    <button type="button" className={className} disabled={busy}
      onClick={() => run(() => delegateMyTask(taskId), {
        confirm: {
          title: 'Delegate to your substitute?',
          message: 'Your configured substitute will be asked to decide this instead of you.',
          confirmLabel: 'Delegate',
        },
        successTitle: 'Delegated to your substitute',
      })}>
      {busy ? 'Working…' : 'Delegate'}
    </button>
  );
}

export function ApproveButton({ no, className = 'btn sm' }: { no: string; className?: string }) {
  const { run, busy } = useRunAction();
  return (
    <button type="button" className={className} disabled={busy}
      onClick={() => run(() => approveCollateralApplicationRequest(no), {
        confirm: { title: 'Approve this application?', confirmLabel: 'Approve' },
        successTitle: 'Application approved',
      })}>
      {busy ? 'Working…' : 'Approve'}
    </button>
  );
}

export function RejectButton({ no, className = 'btn sm ghost' }: { no: string; className?: string }) {
  const [open, setOpen] = useState(false);
  return (
    <>
      <button type="button" className={className} onClick={() => setOpen(true)}>Reject</button>
      {open ? (
        <FormModal
          title="Reject collateral application"
          onClose={() => setOpen(false)}
          onSubmit={(values) => rejectCollateralApplicationRequest(no, String(values.reason || ''))}
          submitLabel="Reject"
          submitClass="btn danger"
          successTitle="Rejected — back to Open for changes"
          resultStyle="popup"
        >
          <Field name="reason" label="Reason" type="textarea" required />
        </FormModal>
      ) : null}
    </>
  );
}

export function DeleteButton({ no, className = 'btn sm ghost' }: { no: string; className?: string }) {
  const { run, busy } = useRunAction();
  return (
    <button type="button" className={className} disabled={busy}
      onClick={() => run(() => deleteCollateralApplicationRequest(no), {
        confirm: {
          title: 'Delete this application?',
          message: 'This cannot be undone.',
          confirmLabel: 'Delete',
        },
        successTitle: 'Application deleted',
      })}>
      {busy ? 'Working…' : 'Delete'}
    </button>
  );
}

export function PostButton({ no, className = 'btn sm' }: { no: string; className?: string }) {
  const showResult = useResultDialog();
  const confirm = useConfirm();
  const router = useRouter();
  const [busy, setBusy] = useState(false);

  const post = async () => {
    const ok = await confirm({
      title: 'Register this collateral?',
      message: 'This accepts the pledged asset into the Collateral Register. It cannot be undone from here.',
      confirmLabel: 'Register collateral',
    });
    if (!ok) return;
    setBusy(true);
    try {
      const res = await postCollateralApplicationRequest(no);
      if (!res.ok) { showResult('Could not register collateral', res.error, 'err'); return; }
      showResult('Collateral registered', undefined, 'ok');
      router.push(`/collateral-register/view/${res.data.registerNo}`);
    } finally {
      setBusy(false);
    }
  };

  return (
    <button type="button" className={className} disabled={busy} onClick={post}>
      {busy ? 'Working…' : 'Register collateral'}
    </button>
  );
}

/** Fields shared by the New and Edit forms — category drives the collateral type lookup, and
 *  vehicle-only fields appear once a Vehicle type is chosen (BR-03 / the source specification's
 *  CarDetails group). */
function CollateralFields({ defaults, category, setCategory, counties }: {
  defaults?: Partial<CollateralApplicationWithDetails>;
  category: string;
  setCategory: (v: string) => void;
  counties: CountyOption[];
}) {
  const [types, setTypes] = useState<CollateralType[]>([]);
  const [collateralTypeId, setCollateralTypeId] = useState(String(defaults?.collateral_type_id ?? ''));
  const [countyId, setCountyId] = useState(String(defaults?.county_id ?? ''));

  useEffect(() => {
    if (!category) { setTypes([]); return; }
    let cancelled = false;
    eligibleCollateralTypesForCategory(category).then((res) => {
      if (!cancelled && res.ok) setTypes(res.data);
    });
    return () => { cancelled = true; };
  }, [category]);

  const candidateTypes = defaults?.collateral_type_id
    ? [
        { id: defaults.collateral_type_id, code: defaults.collateral_type_code || '' } as CollateralType,
        ...types.filter((t) => t.id !== defaults.collateral_type_id),
      ]
    : types;

  return (
    <>
      <div className="grid g2">
        <div className="field">
          <label htmlFor="f_category">Category <span className="req">*</span></label>
          <select id="f_category" name="category" required value={category}
            onChange={(e) => { setCategory(e.target.value); setCollateralTypeId(''); }}>
            {COLLATERAL_CATEGORIES.map((c) => <option key={c.value} value={c.value}>{c.label}</option>)}
          </select>
        </div>
        <SearchableSelect id="f_collateralTypeId" name="collateralTypeId" label="Collateral Type" required
          items={candidateTypes} getValue={(t) => String(t.id)} getLabel={(t) => t.code}
          value={collateralTypeId} onChange={setCollateralTypeId}
          placeholder="Search collateral type…" emptyText="No matching types" />
        <Field name="collateralValueSh" label="Collateral value (market/appraised)" type="number" step="0.01" required
          defaultValue={defaults?.collateral_value !== undefined ? toUnits(defaults.collateral_value) : ''} />
        <Field name="serialRegNo" label="Serial / Registration No." required
          defaultValue={defaults?.serial_reg_no ?? ''}
          hint="Vehicle registration or title deed number — must be unique unless multi-linked" />
        <SearchableSelect name="countyId" label="County"
          items={counties} getValue={(c) => String(c.id)} getLabel={(c) => c.name}
          value={countyId} onChange={setCountyId} placeholder="Search county…" emptyText="No matching counties" />
        <Field name="ownerName" label="Owner name" defaultValue={defaults?.owner_name ?? ''}
          hint="May differ from the member — see Joint Ownership" />
        <Field name="ownerIdNo" label="Owner ID no." defaultValue={defaults?.owner_id_no ?? ''} />
        <Field name="ownerPhoneNo" label="Owner phone no." defaultValue={defaults?.owner_phone_no ?? ''} />
        <Field name="lastValuationDate" label="Last valuation date" type="date"
          defaultValue={defaults?.last_valuation_date ?? ''} />
        <Field name="chequeNo" label="Cheque no." defaultValue={defaults?.cheque_no ?? ''} />
      </div>
      {category === 'VEHICLE' ? (
        <div className="grid g2">
          <Field name="insuranceExpiryDate" label="Insurance expiry date" type="date"
            defaultValue={defaults?.insurance_expiry_date ?? ''} />
          <Field name="carTrackDueDate" label="Car track subscription due" type="date"
            defaultValue={defaults?.car_track_due_date ?? ''} />
        </div>
      ) : null}
      <div className="grid g2">
        <Field name="jointOwnership" label="Joint ownership" type="checkbox" defaultValue={defaults?.joint_ownership ?? 0} />
        <Field name="multiLinking" label="Multi-linking — allow this asset to secure more than one loan"
          type="checkbox" defaultValue={defaults?.multi_linking ?? 0} />
      </div>
      {types.length === 0 && category ? (
        <div className="note">
          No active collateral types for {COLLATERAL_CATEGORIES.find((c) => c.value === category)?.label} yet —
          add one in Admin Centre → Sacco Products → Collateral Types.
        </div>
      ) : null}
      <div className="hint">Guarantee (realisable security value) is computed automatically from the type&apos;s LTV multiplier.</div>
    </>
  );
}

interface NewRequestFormProps {
  members: MemberOption[];
  counties: CountyOption[];
  presetMemberId?: number | null;
  onClose: () => void;
}

function NewRequestForm({ members, counties, presetMemberId, onClose }: NewRequestFormProps) {
  const [memberId, setMemberId] = useState(String(presetMemberId ?? ''));
  const [category, setCategory] = useState('VEHICLE');

  return (
    <FormModal
      wide
      title="New collateral application"
      onClose={onClose}
      onSubmit={createCollateralApplicationRequest}
      submitLabel="Save application"
      successTitle="Application captured"
      successDetail={(d) => `${d.no} saved — send it for approval when you're ready`}
    >
      <MemberSelect id="f_memberId" name="memberId" members={members} value={memberId}
        onChange={setMemberId} required />
      <CollateralFields category={category} setCategory={setCategory} counties={counties} />
    </FormModal>
  );
}

export function NewCollateralApplicationButton({ members, counties, presetMemberId }: {
  members: MemberOption[];
  counties: CountyOption[];
  presetMemberId?: number | null;
}) {
  const router = useRouter();
  const [open, setOpen] = useState(Boolean(presetMemberId));

  const close = () => {
    setOpen(false);
    if (presetMemberId) router.replace('/collateral-applications');
  };

  return (
    <>
      <button type="button" className="btn" onClick={() => setOpen(true)}>New collateral application</button>
      {open ? (
        <NewRequestForm members={members} counties={counties} presetMemberId={presetMemberId} onClose={close} />
      ) : null}
    </>
  );
}

export function EditButton({ application, members, counties, className = 'btn sm ghost' }: {
  application: CollateralApplicationWithDetails;
  members: MemberOption[];
  counties: CountyOption[];
  className?: string;
}) {
  const [open, setOpen] = useState(false);
  const [memberId, setMemberId] = useState(String(application.member_id));
  const [category, setCategory] = useState<string>(application.category);

  return (
    <>
      <button type="button" className={className} onClick={() => setOpen(true)}>Edit</button>
      {open ? (
        <FormModal
          wide
          title={`Edit ${application.no}`}
          onClose={() => setOpen(false)}
          onSubmit={(values) => saveCollateralApplication(application.no, values)}
          submitLabel="Save changes"
          successTitle="Application updated"
        >
          <MemberSelect id="f_memberId" name="memberId" members={members} value={memberId}
            onChange={setMemberId} required />
          <CollateralFields defaults={application} category={category} setCategory={setCategory} counties={counties} />
        </FormModal>
      ) : null}
    </>
  );
}
