'use client';

import { useEffect, useState } from 'react';
import { useRouter } from 'next/navigation';
import { FormModal } from '@/components/ui/form-modal';
import { Field } from '@/components/ui/field';
import { useResultDialog } from '@/components/ui/result-dialog';
import { useConfirm } from '@/components/ui/confirm-dialog';
import { useRunAction } from '@/components/ui/run-action';
import {
  requestMemberCharging, saveMemberCharging, deleteMemberChargingRequest, postMemberChargingRequest,
  accountsForMemberCharging, memberChargingChargeCodes, previewMemberChargingAmount,
} from '@/app/actions/memberCharging';
import { useFormat } from '@/components/ui/format-provider';
import type { CalculatedMemberCharge } from '@/lib/memberCharging';
import type {
  Member, MemberChargingWithDimensions, SavingsAccountForDebit, TransactionCharge,
} from '@/lib/types';

export function DeleteButton({ no, className = 'btn sm ghost' }: { no: string; className?: string }) {
  const { run, busy } = useRunAction();
  return (
    <button type="button" className={className} disabled={busy}
      onClick={() => run(() => deleteMemberChargingRequest(no), {
        confirm: {
          title: 'Delete this document?',
          message: 'This cannot be undone.',
          confirmLabel: 'Delete',
        },
        successTitle: 'Deleted',
      })}>
      {busy ? 'Working…' : 'Delete'}
    </button>
  );
}

/** `amount` comes straight off the document's own `amount_charged` — the fee this specific
 *  document's chosen Charge Code resolves to right now, not a generic preview. */
export function PostButton({ no, amount = null, className = 'btn sm' }: {
  no: string; amount?: number | null; className?: string;
}) {
  const showResult = useResultDialog();
  const confirm = useConfirm();
  const router = useRouter();
  const { cur } = useFormat();
  const [busy, setBusy] = useState(false);

  const post = async () => {
    const ok = await confirm({
      title: 'Post this charge?',
      message: amount
        ? `${cur(amount)} will be debited from the source account immediately. This cannot be undone.`
        : 'This cannot be undone.',
      confirmLabel: 'Post',
    });
    if (!ok) return;
    setBusy(true);
    try {
      const res = await postMemberChargingRequest(no);
      if (!res.ok) { showResult('Could not post this charge', res.error, 'err'); return; }
      showResult('Charge posted', `Journal ${res.data.journalNo} — ${cur(res.data.amount)}`, 'ok');
      router.refresh();
    } finally {
      setBusy(false);
    }
  };

  return (
    <button type="button" className={className} disabled={busy} onClick={post}>
      {busy ? 'Working…' : 'Post'}
    </button>
  );
}

/**
 * Source Account + Charge Code + (conditionally) No Of Pages, with a live fee/available-balance
 * preview — shared by the New Document form and the Edit button for an Open document. Source
 * Account is Table 52204206's "resolved" withdrawable deposit account: since a member can hold
 * more than one, this presents whichever the member has as a picklist (auto-selecting the
 * first) rather than guessing.
 */
function ChargeFields({
  memberId, sourceAccountId, setSourceAccountId, chargeId, setChargeId, noOfPages, setNoOfPages, autoSelectFirst,
}: {
  memberId: string;
  sourceAccountId: string;
  setSourceAccountId: (v: string) => void;
  chargeId: string;
  setChargeId: (v: string) => void;
  noOfPages: string;
  setNoOfPages: (v: string) => void;
  /** New documents default to the first configured Charge Code / withdrawable account so a fee
   *  preview is visible immediately; editing an existing document must never override what was
   *  already (possibly deliberately) chosen. */
  autoSelectFirst?: boolean;
}) {
  const { cur } = useFormat();
  const [chargeCodes, setChargeCodes] = useState<TransactionCharge[]>([]);
  const [sourceAccounts, setSourceAccounts] = useState<SavingsAccountForDebit[]>([]);
  const [calc, setCalc] = useState<CalculatedMemberCharge | null>(null);

  // Charge Codes don't depend on the member — fetched once.
  useEffect(() => {
    memberChargingChargeCodes().then((res) => {
      if (!res.ok) return;
      setChargeCodes(res.data);
      if (autoSelectFirst) setChargeId(chargeId || String(res.data[0]?.id ?? ''));
    });
    // Only ever runs once per mount — chargeId/setChargeId are read at that moment on purpose.
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  // The member's withdrawable accounts — refetched whenever the member changes.
  useEffect(() => {
    let cancelled = false;
    if (!memberId) { setSourceAccounts([]); return; }
    accountsForMemberCharging(Number(memberId)).then((res) => {
      if (cancelled) return;
      const list = res.ok ? res.data : [];
      setSourceAccounts(list);
      if (autoSelectFirst) setSourceAccountId(String(list[0]?.id ?? ''));
    });
    return () => { cancelled = true; };
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [memberId]);

  // GetChargesAmount(Charge Code, No Of Pages) — recalculated on either input changing.
  useEffect(() => {
    let cancelled = false;
    if (!chargeId) { setCalc(null); return; }
    previewMemberChargingAmount(Number(chargeId), noOfPages ? Number(noOfPages) : null).then((res) => {
      if (!cancelled && res.ok) setCalc(res.data);
    });
    return () => { cancelled = true; };
  }, [chargeId, noOfPages]);

  const charge = chargeCodes.find((c) => String(c.id) === chargeId);
  const isStatementCharge = charge?.transaction_type === 'Statement Charge';
  const sourceAccount = sourceAccounts.find((a) => String(a.id) === sourceAccountId);
  const available = sourceAccount ? sourceAccount.balance - sourceAccount.hold_amount - sourceAccount.min_balance : null;
  const feeAmount = calc?.amount ?? null;
  const insufficient = !!chargeId && feeAmount != null && available != null && feeAmount > available;

  return (
    <>
      <div className="field" style={{ marginTop: 'calc(var(--sp)*1.5)' }}>
        <label htmlFor="f_sourceAccountId">Source account <span className="req">*</span></label>
        <select id="f_sourceAccountId" name="sourceAccountId" required value={sourceAccountId}
          disabled={!memberId} onChange={(e) => setSourceAccountId(e.target.value)}>
          {sourceAccounts.length ? null : <option value="">No withdrawable account for this member</option>}
          {sourceAccounts.map((a) => <option key={a.id} value={a.id}>{a.account_no} — {a.product_name}</option>)}
        </select>
      </div>

      <div className="grid g2" style={{ marginTop: 'calc(var(--sp)*1.5)' }}>
        <div className="field">
          <label htmlFor="f_transactionChargeId">Charge code <span className="req">*</span></label>
          <select id="f_transactionChargeId" name="transactionChargeId" required value={chargeId}
            onChange={(e) => setChargeId(e.target.value)}>
            <option value="">Select…</option>
            {chargeCodes.map((c) => <option key={c.id} value={c.id}>{c.code} — {c.description}</option>)}
          </select>
        </div>
        {isStatementCharge ? (
          <div className="field">
            <label htmlFor="f_noOfPages">No. of pages <span className="req">*</span></label>
            <input id="f_noOfPages" name="noOfPages" type="number" min={1} required value={noOfPages}
              onChange={(e) => setNoOfPages(e.target.value)} />
          </div>
        ) : null}
      </div>

      {chargeId ? (
        <div className="note" style={{ marginTop: 8 }}>
          {charge ? <>Posting transaction type: <b>{charge.transaction_type}</b> · </> : null}
          Charge amount: <b className={insufficient ? 'neg' : undefined}>{feeAmount != null ? cur(feeAmount) : '…'}</b>
          {sourceAccount ? (
            <> · {sourceAccount.account_no} available balance: <b>{cur(Math.max(available ?? 0, 0))}</b></>
          ) : null}
          {insufficient ? (
            <div className="neg">The charge exceeds the source account's available balance.</div>
          ) : null}
        </div>
      ) : null}
    </>
  );
}

interface NewDocumentFormProps {
  members: Pick<Member, 'id' | 'member_no' | 'first_name' | 'last_name'>[];
  presetMemberId?: number | null;
  onClose: () => void;
}

function NewDocumentForm({ members, presetMemberId, onClose }: NewDocumentFormProps) {
  const [memberId, setMemberId] = useState(String(presetMemberId ?? members[0]?.id ?? ''));
  const [sourceAccountId, setSourceAccountId] = useState('');
  const [chargeId, setChargeId] = useState('');
  const [noOfPages, setNoOfPages] = useState('');

  return (
    <FormModal
      title="New member charge"
      onClose={onClose}
      onSubmit={requestMemberCharging}
      submitLabel="Save document"
      successTitle="Document captured"
      successDetail={(d) => `${d.no} saved — post it when you're ready`}
    >
      <div className="field">
        <label htmlFor="f_memberId">Member <span className="req">*</span></label>
        <select id="f_memberId" name="memberId" required value={memberId}
          onChange={(e) => { setMemberId(e.target.value); setSourceAccountId(''); }}>
          {members.map((m) => (
            <option key={m.id} value={m.id}>{m.member_no} — {m.first_name} {m.last_name}</option>
          ))}
        </select>
      </div>

      <ChargeFields
        memberId={memberId} sourceAccountId={sourceAccountId} setSourceAccountId={setSourceAccountId}
        chargeId={chargeId} setChargeId={setChargeId} noOfPages={noOfPages} setNoOfPages={setNoOfPages}
        autoSelectFirst
      />

      <Field name="description" label="Description" type="textarea" required />
    </FormModal>
  );
}

/** Lets an Open document's Source Account, Charge Code, No Of Pages and Description be changed
 *  before it's posted — the member is fixed at creation, same as Account Activation's own Edit
 *  button never lets the member change. */
export function EditButton({ request, className = 'btn sm ghost' }: {
  request: MemberChargingWithDimensions;
  className?: string;
}) {
  const [open, setOpen] = useState(false);
  const [sourceAccountId, setSourceAccountId] = useState(String(request.source_account_id));
  const [chargeId, setChargeId] = useState(String(request.transaction_charge_id));
  const [noOfPages, setNoOfPages] = useState(request.no_of_pages != null ? String(request.no_of_pages) : '');

  return (
    <>
      <button type="button" className={className} onClick={() => setOpen(true)}>Edit</button>
      {open ? (
        <FormModal
          title={`Edit ${request.no}`}
          onClose={() => setOpen(false)}
          onSubmit={(values) => saveMemberCharging(request.no, values)}
          submitLabel="Save changes"
          successTitle="Document updated"
        >
          <ChargeFields
            memberId={String(request.member_id)} sourceAccountId={sourceAccountId} setSourceAccountId={setSourceAccountId}
            chargeId={chargeId} setChargeId={setChargeId} noOfPages={noOfPages} setNoOfPages={setNoOfPages}
          />
          <Field name="description" label="Description" type="textarea" required defaultValue={request.description} />
        </FormModal>
      ) : null}
    </>
  );
}

/** Opens the New Document form, optionally preset from `?new=<memberId>` (same pattern as
 *  Account Activation's NewAccountActivationButton). */
export function NewMemberChargingButton({ members, presetMemberId }: {
  members: NewDocumentFormProps['members'];
  presetMemberId?: number | null;
}) {
  const router = useRouter();
  const [open, setOpen] = useState(Boolean(presetMemberId));

  const close = () => {
    setOpen(false);
    if (presetMemberId) router.replace('/member-chargings');
  };

  return (
    <>
      <button type="button" className="btn" onClick={() => setOpen(true)}>New member charge</button>
      {open ? <NewDocumentForm members={members} presetMemberId={presetMemberId} onClose={close} /> : null}
    </>
  );
}
