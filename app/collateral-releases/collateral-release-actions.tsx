'use client';

import { useState } from 'react';
import { useRouter } from 'next/navigation';
import { FormModal } from '@/components/ui/form-modal';
import { Field } from '@/components/ui/field';
import { useResultDialog } from '@/components/ui/result-dialog';
import { useConfirm } from '@/components/ui/confirm-dialog';
import { useRunAction } from '@/components/ui/run-action';
import {
  requestCollateralRelease, saveCollateralRelease, deleteCollateralReleaseRequest,
  submitCollateralReleaseRequest, cancelCollateralReleaseApprovalRequest, approveCollateralReleaseRequest,
  rejectCollateralReleaseRequest, postCollateralReleaseRequest,
} from '@/app/actions/collateralReleases';
import { delegateMyTask } from '@/app/actions/workflows';
import { NATIONALITIES } from '@/lib/constants';
import type { CollateralRegisterRow, CollateralReleaseWithDetails } from '@/lib/types';

export function SubmitButton({ no, className = 'btn sm ghost' }: { no: string; className?: string }) {
  const { run, busy } = useRunAction();
  return (
    <button type="button" className={className} disabled={busy}
      onClick={() => run(() => submitCollateralReleaseRequest(no), {
        confirm: {
          title: 'Send this release for approval?',
          message: 'It will be routed to the configured approver(s) and can no longer be edited while pending.',
          confirmLabel: 'Send for approval',
        },
        successTitle: (d) => (d.autoApproved ? 'Release approved' : 'Sent for approval'),
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
      onClick={() => run(() => cancelCollateralReleaseApprovalRequest(no), {
        confirm: {
          title: 'Cancel this approval request?',
          message: 'The release goes back to Open so you can amend and resubmit it.',
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
      onClick={() => run(() => approveCollateralReleaseRequest(no), {
        confirm: { title: 'Approve this release?', confirmLabel: 'Approve' },
        successTitle: 'Release approved',
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
          title="Reject collateral release"
          onClose={() => setOpen(false)}
          onSubmit={(values) => rejectCollateralReleaseRequest(no, String(values.reason || ''))}
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
      onClick={() => run(() => deleteCollateralReleaseRequest(no), {
        confirm: { title: 'Delete this release?', message: 'This cannot be undone.', confirmLabel: 'Delete' },
        successTitle: 'Release deleted',
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
      title: 'Release this collateral?',
      message: 'This marks the register item as collected. It cannot be undone from here.',
      confirmLabel: 'Release collateral',
    });
    if (!ok) return;
    setBusy(true);
    try {
      const res = await postCollateralReleaseRequest(no);
      if (!res.ok) { showResult('Could not release collateral', res.error, 'err'); return; }
      showResult('Collateral released', undefined, 'ok');
      router.refresh();
    } finally {
      setBusy(false);
    }
  };

  return (
    <button type="button" className={className} disabled={busy} onClick={post}>
      {busy ? 'Working…' : 'Release collateral'}
    </button>
  );
}

function CollectorFields({ defaults }: { defaults?: Partial<CollateralReleaseWithDetails> }) {
  const [nationality, setNationality] = useState<string>(defaults?.nationality ?? 'LOCAL');
  return (
    <>
      <div className="grid g2">
        <Field name="collectionDate" label="Collection date" type="date" required
          defaultValue={defaults?.collection_date ?? ''} />
        <Field name="collectedBy" label="Collected by" required defaultValue={defaults?.collected_by ?? ''} />
        <Field name="collectedByIdNo" label="Collector's ID no." defaultValue={defaults?.collected_by_id_no ?? ''} />
        <Field name="nationality" label="Nationality" type="select" defaultValue={nationality}
          options={NATIONALITIES} onChange={(e) => setNationality(e.target.value)} />
        {nationality === 'DIASPORA' ? (
          <Field name="domicileCountry" label="Domicile country" required defaultValue={defaults?.domicile_country ?? ''} />
        ) : null}
      </div>
      <Field name="comments" label="Comments" type="textarea" defaultValue={defaults?.comments ?? ''} />
      <Field name="remarks" label="Remarks" type="textarea" defaultValue={defaults?.remarks ?? ''} />
    </>
  );
}

type ReleasableCollateral = Pick<
  CollateralRegisterRow,
  'no' | 'collateral_description' | 'serial_reg_no' | 'status' | 'member_no' | 'member_first_name' | 'member_last_name'
>;

const collateralLabel = (c: ReleasableCollateral): string =>
  `${c.no} — ${c.member_no} ${c.member_first_name} ${c.member_last_name} — `
  + `${c.collateral_description || c.serial_reg_no || 'Untitled'} `
  + `(${c.status === 'LINKED_TO_LOAN' ? 'Linked to loan' : 'Available'})`;

interface NewReleaseFormProps {
  collateral: ReleasableCollateral[];
  presetCollateralNo?: string | null;
  onClose: () => void;
}

function NewReleaseForm({ collateral, presetCollateralNo, onClose }: NewReleaseFormProps) {
  return (
    <FormModal
      wide
      title="New collateral release"
      onClose={onClose}
      onSubmit={requestCollateralRelease}
      submitLabel="Save release"
      successTitle="Release captured"
      successDetail={(d) => `${d.no} saved — send it for approval once the loan balance it secures is cleared`}
    >
      <div className="field">
        <label htmlFor="f_collateralNo">Collateral <span className="req">*</span></label>
        <select id="f_collateralNo" name="collateralNo" required defaultValue={presetCollateralNo ?? collateral[0]?.no ?? ''}>
          {collateral.map((c) => <option key={c.no} value={c.no}>{collateralLabel(c)}</option>)}
        </select>
      </div>
      <CollectorFields />
    </FormModal>
  );
}

export function NewCollateralReleaseButton({ collateral, presetCollateralNo }: {
  collateral: NewReleaseFormProps['collateral'];
  presetCollateralNo?: string | null;
}) {
  const router = useRouter();
  const [open, setOpen] = useState(Boolean(presetCollateralNo));

  const close = () => {
    setOpen(false);
    if (presetCollateralNo) router.replace('/collateral-releases');
  };

  return (
    <>
      <button type="button" className="btn" disabled={!collateral.length} onClick={() => setOpen(true)}>
        New collateral release
      </button>
      {open ? <NewReleaseForm collateral={collateral} presetCollateralNo={presetCollateralNo} onClose={close} /> : null}
    </>
  );
}

/** Lets an Open release's target Collateral item — and, since the member is only ever derived
 *  from whichever item is chosen (see lib/collateralReleases.ts's updateCollateralRelease()), the
 *  member — be changed, alongside the collector details, before it's sent for approval. */
export function EditButton({ release, collateral, className = 'btn sm ghost' }: {
  release: CollateralReleaseWithDetails;
  collateral: ReleasableCollateral[];
  className?: string;
}) {
  const [open, setOpen] = useState(false);
  const [collateralNo, setCollateralNo] = useState(release.collateral_no);

  // The item currently attached to this release is always offered, even if it's since been
  // filtered out of the live `collateral` list for some other reason — otherwise re-opening this
  // form would show an empty/mismatched selection.
  const candidates = collateral.some((c) => c.no === release.collateral_no)
    ? collateral
    : [
        {
          no: release.collateral_no, collateral_description: release.collateral_description,
          serial_reg_no: release.collateral_serial_reg_no, status: 'AVAILABLE' as const,
          member_no: release.member_no, member_first_name: release.member_first_name,
          member_last_name: release.member_last_name,
        },
        ...collateral,
      ];

  return (
    <>
      <button type="button" className={className} onClick={() => setOpen(true)}>Edit</button>
      {open ? (
        <FormModal
          wide
          title={`Edit ${release.no}`}
          onClose={() => setOpen(false)}
          onSubmit={(values) => saveCollateralRelease(release.no, values)}
          submitLabel="Save changes"
          successTitle="Release updated"
        >
          <div className="field">
            <label htmlFor="f_collateralNo">Collateral <span className="req">*</span></label>
            <select id="f_collateralNo" name="collateralNo" required value={collateralNo}
              onChange={(e) => setCollateralNo(e.target.value)}>
              {candidates.map((c) => <option key={c.no} value={c.no}>{collateralLabel(c)}</option>)}
            </select>
          </div>
          <CollectorFields defaults={release} />
        </FormModal>
      ) : null}
    </>
  );
}
