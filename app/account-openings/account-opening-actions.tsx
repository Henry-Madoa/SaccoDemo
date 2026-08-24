'use client';

import { useEffect, useState } from 'react';
import { useRouter } from 'next/navigation';
import { FormModal } from '@/components/ui/form-modal';
import { Field } from '@/components/ui/field';
import { MemberSelect } from '@/components/ui/member-select';
import { useFormat } from '@/components/ui/format-provider';
import { useResultDialog } from '@/components/ui/result-dialog';
import { useConfirm } from '@/components/ui/confirm-dialog';
import { useRunAction } from '@/components/ui/run-action';
import {
  requestAccountOpening, saveAccountOpeningRequest, submitAccountOpening,
  cancelAccountOpeningApprovalRequest, approveAccountOpening, rejectAccountOpening,
  processAccountOpening, eligibleProductsForMember,
} from '@/app/actions/accountOpening';
import { delegateMyTask } from '@/app/actions/workflows';
import { JuniorPhotoPanel } from './view/[no]/junior-photo-panel';
import type { AccountOpeningRequestWithDimensions, Member, SavingsProduct } from '@/lib/types';

export function SubmitButton({ no, className = 'btn sm ghost' }: { no: string; className?: string }) {
  const { run, busy } = useRunAction();
  return (
    <button type="button" className={className} disabled={busy}
      onClick={() => run(() => submitAccountOpening(no), {
        confirm: {
          title: 'Send this request for approval?',
          message: 'It will be routed to the configured approver(s) and can no longer be edited while pending.',
          confirmLabel: 'Send for approval',
        },
        successTitle: (d) => (d.autoApproved ? 'Request approved' : 'Sent for approval'),
        successDetail: (d) => (d.autoApproved
          ? 'You are the assigned approver, so this was approved automatically.' : undefined),
      })}>
      {busy ? 'Working…' : 'Send for approval'}
    </button>
  );
}

/** Pulls a submission back to Open — only valid before any approver has acted on it. */
export function CancelApprovalButton({ no, className = 'btn sm ghost' }: { no: string; className?: string }) {
  const { run, busy } = useRunAction();
  return (
    <button type="button" className={className} disabled={busy}
      onClick={() => run(() => cancelAccountOpeningApprovalRequest(no), {
        confirm: {
          title: 'Cancel this approval request?',
          message: 'The request goes back to Open so you can amend and resubmit it.',
          confirmLabel: 'Cancel approval request',
        },
        successTitle: 'Approval request cancelled — back to Open',
      })}>
      {busy ? 'Working…' : 'Cancel approval request'}
    </button>
  );
}

/** Hands the pending task off to my configured substitute. */
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
      onClick={() => run(() => approveAccountOpening(no), {
        confirm: { title: 'Approve this request?', confirmLabel: 'Approve' },
        successTitle: 'Request approved',
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
          title="Reject account opening request"
          onClose={() => setOpen(false)}
          onSubmit={(values) => rejectAccountOpening(no, String(values.reason || ''))}
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

/** Business-details block, shown whenever the selected product is flagged is_business_account. */
function BusinessFields({ defaults }: {
  defaults?: Pick<AccountOpeningRequestWithDimensions, 'business_name' | 'business_location' | 'business_paybill_till_no' | 'business_phone_no'>;
}) {
  return (
    <div className="grid g2">
      <Field name="businessName" label="Business Name" defaultValue={defaults?.business_name ?? ''} required />
      <Field name="businessLocation" label="Business Location" defaultValue={defaults?.business_location ?? ''}required />
      <Field name="businessPaybillTillNo" label="Paybill / Till No." defaultValue={defaults?.business_paybill_till_no ?? ''} />
      <Field name="businessPhoneNo" label="Business Phone No." defaultValue={defaults?.business_phone_no ?? ''} required />
    </div>
  );
}

/** Junior-details text fields, shown whenever the selected product's category is JUNIOR
 *  ACCOUNT. The profile picture is a separate immediate-effect upload (see JuniorPhotoPanel),
 *  not one of this form's fields — EditButton renders it alongside, below. */
function JuniorFields({ defaults }: {
  defaults?: Pick<AccountOpeningRequestWithDimensions, 'junior_name' | 'junior_birth_cert_no' | 'junior_date_of_birth'>;
}) {
  return (
    <div className="grid g2">
      <Field name="juniorName" label="Junior's Name" defaultValue={defaults?.junior_name ?? ''} required />
      <Field name="juniorBirthCertNo" label="Birth Notification / Certificate No." required uppercase maxLength={20}
        defaultValue={defaults?.junior_birth_cert_no ?? ''}
        hint="Uniquely identifies this Junior Account — must not already be in use" />
      <Field name="juniorDateOfBirth" label="Date of Birth" type="date" defaultValue={defaults?.junior_date_of_birth ?? ''} required/>
    </div>
  );
}

/** Edits the member/product/notes/business/junior details of a still-Open request. Also carries
 *  the Junior Profile Picture upload, so a Junior account's details can be finished in one place
 *  rather than needing the detail page as well. */
export function EditButton({ request, members, className = 'btn sm ghost', juniorPhotoSrc = null, mediaEnabled = false }: {
  request: AccountOpeningRequestWithDimensions;
  members: Pick<Member, 'id' | 'member_no' | 'first_name' | 'last_name'>[];
  className?: string;
  juniorPhotoSrc?: string | null;
  mediaEnabled?: boolean;
}) {
  const [open, setOpen] = useState(false);
  const [memberId, setMemberId] = useState(String(request.member_id));
  const [products, setProducts] = useState<SavingsProduct[]>([]);
  const [productId, setProductId] = useState(String(request.savings_product_id));

  useEffect(() => {
    if (!open || !memberId) return;
    let cancelled = false;
    eligibleProductsForMember(Number(memberId)).then((res) => {
      if (!cancelled && res.ok) setProducts(res.data);
    });
    return () => { cancelled = true; };
  }, [open, memberId]);

  // The currently-saved product is always offered too, even though eligibleProductsForMember()
  // (correctly) excludes it once it's picked — otherwise re-opening this form with the request's
  // own member and product would show an empty selection. Only meaningful while the member
  // hasn't changed — a different member's eligible list stands on its own.
  const candidates = memberId === String(request.member_id)
    ? [
        {
          id: request.savings_product_id, code: request.savings_product_code, name: request.savings_product_name,
          category: request.savings_product_category, is_business_account: request.savings_product_is_business_account,
        },
        ...products.filter((p) => p.id !== request.savings_product_id),
      ]
    : products;
  const product = candidates.find((p) => String(p.id) === productId);

  return (
    <>
      <button type="button" className={className} onClick={() => setOpen(true)}>Edit</button>
      {open ? (
        <FormModal
          title={`Edit ${request.no}`}
          onClose={() => setOpen(false)}
          onSubmit={(values) => saveAccountOpeningRequest(request.no, values)}
          submitLabel="Save changes"
          successTitle="Request updated"
        >
          <MemberSelect id="f_memberId" name="memberId" members={members} value={memberId}
            onChange={(id) => { setMemberId(id); setProductId(''); }} required />

          <div className="field">
            <label htmlFor="f_productId">Product <span className="req">*</span></label>
            <select id="f_productId" name="productId" required value={productId}
              onChange={(e) => setProductId(e.target.value)}>
              {candidates.length ? null : <option value="">No eligible products for this member</option>}
              {candidates.map((p) => (
                <option key={p.id} value={p.id}>{p.name} ({p.code})</option>
              ))}
            </select>
          </div>
          <Field name="notes" label="Notes" type="textarea" defaultValue={request.notes ?? ''} />

          {product?.is_business_account ? <BusinessFields defaults={request} /> : null}
          {product?.category === 'JUNIOR ACCOUNT' ? (
            <>
              <JuniorFields defaults={request} />
              <div className="field">
                <label>Junior Profile Picture</label>
                <JuniorPhotoPanel
                  requestNo={request.no}
                  name={request.junior_name || `${request.member_first_name} ${request.member_last_name}`}
                  photoSrc={juniorPhotoSrc}
                  canEdit
                  mediaEnabled={mediaEnabled}
                />
              </div>
            </>
          ) : null}
        </FormModal>
      ) : null}
    </>
  );
}

export function ProcessButton({ no, className = 'btn sm' }: { no: string; className?: string }) {
  const showResult = useResultDialog();
  const confirm = useConfirm();
  const router = useRouter();
  const [busy, setBusy] = useState(false);

  const process = async () => {
    const ok = await confirm({
      title: 'Open this account?',
      message: 'This opens a real, zero-balance savings account for the member. It cannot be undone from here.',
      confirmLabel: 'Open account',
    });
    if (!ok) return;
    setBusy(true);
    try {
      const res = await processAccountOpening(no);
      if (!res.ok) { showResult('Could not open the account', res.error, 'err'); return; }
      showResult('Account opened', undefined, 'ok');
      router.push(`/savings/${res.data.accountId}`);
    } finally {
      setBusy(false);
    }
  };

  return (
    <button type="button" className={className} disabled={busy} onClick={process}>
      {busy ? 'Working…' : 'Open account'}
    </button>
  );
}

interface NewRequestFormProps {
  members: Pick<Member, 'id' | 'member_no' | 'first_name' | 'last_name'>[];
  presetMemberId?: number | null;
  onClose: () => void;
}

function NewRequestForm({ members, presetMemberId, onClose }: NewRequestFormProps) {
  const [memberId, setMemberId] = useState(String(presetMemberId ?? ''));
  const [products, setProducts] = useState<SavingsProduct[]>([]);
  const [productId, setProductId] = useState('');
  const { cur } = useFormat();

  // The eligible product list depends on the member's category (its default accounts are
  // excluded), so it's fetched per-member rather than shipped for everyone up front.
  useEffect(() => {
    let cancelled = false;
    if (!memberId) { setProducts([]); return; }
    eligibleProductsForMember(Number(memberId)).then((res) => {
      if (cancelled) return;
      const list = res.ok ? res.data : [];
      setProducts(list);
      setProductId(String(list[0]?.id ?? ''));
    });
    return () => { cancelled = true; };
  }, [memberId]);

  const product = products.find((p) => String(p.id) === productId);

  return (
    <FormModal
      title="New account opening request"
      onClose={onClose}
      onSubmit={requestAccountOpening}
      submitLabel="Save request"
      successTitle="Request captured"
      successDetail={(d) => `${d.no} saved — send it for approval when you're ready`}
    >
      <MemberSelect id="f_memberId" name="memberId" members={members} value={memberId}
        onChange={setMemberId} required />

      <div className="field">
        <label htmlFor="f_productId">Product <span className="req">*</span></label>
        <select id="f_productId" name="productId" required value={productId}
          onChange={(e) => setProductId(e.target.value)}>
          {products.length ? null : <option value="">No eligible products for this member</option>}
          {products.map((p) => (
            <option key={p.id} value={p.id}>{p.name} ({p.code})</option>
          ))}
        </select>
      </div>

      <Field name="notes" label="Notes" type="textarea" />

      {product?.is_business_account ? <BusinessFields /> : null}
      {product?.category === 'JUNIOR ACCOUNT' ? <JuniorFields /> : null}

      {product ? (
        <div className="note">
          Opened at a zero balance — minimum opening {cur(product.min_opening)} · minimum balance{' '}
          {cur(product.min_balance)} · {product.allow_withdrawal ? 'withdrawals permitted' : 'no withdrawals'} ·{' '}
          interest {product.interest_rate}% p.a. Fund the account afterwards from Savings &amp; FOSA.
        </div>
      ) : null}
    </FormModal>
  );
}

/** Opens the New Request form, optionally preset from `?new=<memberId>` (same pattern as
 *  loans' NewApplicationButton). */
export function NewAccountOpeningButton({ members, presetMemberId }: {
  members: NewRequestFormProps['members'];
  presetMemberId?: number | null;
}) {
  const router = useRouter();
  const [open, setOpen] = useState(Boolean(presetMemberId));

  const close = () => {
    setOpen(false);
    // Drop ?new= so a refresh does not reopen the modal.
    if (presetMemberId) router.replace('/account-openings');
  };

  return (
    <>
      <button type="button" className="btn" onClick={() => setOpen(true)}>New account opening request</button>
      {open ? <NewRequestForm members={members} presetMemberId={presetMemberId} onClose={close} /> : null}
    </>
  );
}
