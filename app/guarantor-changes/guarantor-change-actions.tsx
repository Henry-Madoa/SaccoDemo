'use client';

import { useEffect, useState } from 'react';
import { useRouter } from 'next/navigation';
import { FormModal } from '@/components/ui/form-modal';
import { Modal } from '@/components/ui/modal';
import { Field } from '@/components/ui/field';
import { MemberSelect } from '@/components/ui/member-select';
import { TableWrap } from '@/components/ui/primitives';
import { Money } from '@/components/ui/money';
import { useFormat } from '@/components/ui/format-provider';
import { useResultDialog } from '@/components/ui/result-dialog';
import { useConfirm } from '@/components/ui/confirm-dialog';
import { useRunAction } from '@/components/ui/run-action';
import {
  requestGuarantorChange, refreshGuarantorChangeLinesRequest, setLineReleaseRequest,
  addReplacementRequest, removeReplacementRequest, availableReplacementsForChange,
  submitGuarantorChangeRequest, cancelGuarantorChangeApprovalRequest,
  approveGuarantorChangeRequest, rejectGuarantorChangeRequest, processGuarantorChangeRequest,
} from '@/app/actions/loanGuarantorChanges';
import { delegateMyTask } from '@/app/actions/workflows';
import type { ChangeableLoanRow, GuarantorCandidate, LoanGuarantorChangeLineWithDetails } from '@/lib/types';

export function SubmitButton({ no, className = 'btn sm ghost' }: { no: string; className?: string }) {
  const { run, busy } = useRunAction();
  return (
    <button type="button" className={className} disabled={busy}
      onClick={() => run(() => submitGuarantorChangeRequest(no), {
        confirm: {
          title: 'Send this guarantor change for approval?',
          message: 'It will be routed to the configured approver(s) and can no longer be edited while pending.',
          confirmLabel: 'Send for approval',
        },
        successTitle: (d) => (d.autoApproved ? 'Approved' : 'Sent for approval'),
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
      onClick={() => run(() => cancelGuarantorChangeApprovalRequest(no), {
        confirm: {
          title: 'Cancel this approval request?',
          message: 'The document goes back to Open so you can amend and resubmit it.',
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
      onClick={() => run(() => approveGuarantorChangeRequest(no), {
        confirm: { title: 'Approve this guarantor change?', confirmLabel: 'Approve' },
        successTitle: 'Guarantor change approved',
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
          title="Reject guarantor change"
          onClose={() => setOpen(false)}
          onSubmit={(values) => rejectGuarantorChangeRequest(no, String(values.reason || ''))}
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

export function ProcessButton({ no, className = 'btn sm' }: { no: string; className?: string }) {
  const { run, busy } = useRunAction();
  return (
    <button type="button" className={className} disabled={busy}
      onClick={() => run(() => processGuarantorChangeRequest(no), {
        confirm: {
          title: 'Process this guarantor change?',
          message: 'Released guarantors drop off the loan and replacements take their place. This cannot be undone from here.',
          confirmLabel: 'Process',
        },
        successTitle: 'Guarantor change processed',
      })}>
      {busy ? 'Working…' : 'Process'}
    </button>
  );
}

export function RefreshLinesButton({ no, className = 'btn sm ghost' }: { no: string; className?: string }) {
  const { run, busy } = useRunAction();
  return (
    <button type="button" className={className} disabled={busy}
      onClick={() => run(() => refreshGuarantorChangeLinesRequest(no), {
        confirm: {
          title: 'Refresh lines from the loan?',
          message: 'Re-syncs from the loan’s currently committed guarantors. Any release flags or replacements staged here are discarded.',
          confirmLabel: 'Refresh lines',
        },
        successTitle: 'Lines refreshed',
      })}>
      {busy ? 'Working…' : 'Refresh lines'}
    </button>
  );
}

/** Per-line release toggle — mutually exclusive with replacements (checking Release clears
 *  whatever's staged, enforced server-side in lib/loanGuarantorChanges.ts's setLineRelease()). */
export function ReleaseToggle({ no, lineId, release, hasReplacements }: {
  no: string; lineId: number; release: boolean; hasReplacements: boolean;
}) {
  const router = useRouter();
  const showResult = useResultDialog();
  const confirm = useConfirm();
  const [busy, setBusy] = useState(false);

  const toggle = async () => {
    const next = !release;
    if (next && hasReplacements) {
      const ok = await confirm({
        title: 'Release this guarantor?',
        message: 'This line already has replacements staged — they will be removed.',
        confirmLabel: 'Release and clear replacements',
      });
      if (!ok) return;
    }
    setBusy(true);
    try {
      const res = await setLineReleaseRequest(no, lineId, next);
      if (!res.ok) { showResult('Could not update line', res.error, 'err'); return; }
      router.refresh();
    } finally {
      setBusy(false);
    }
  };

  return (
    <label className="inline" style={{ gap: 6, cursor: busy ? 'default' : 'pointer' }}>
      <input type="checkbox" checked={release} disabled={busy} onChange={toggle} />
      Release
    </label>
  );
}

/** Manages one line's replacement guarantors — list with remove, plus a compact add form.
 *  Candidates (and their live capacity) are fetched lazily once opened. */
export function ReplacementsModal({ no, line, disabled }: {
  no: string; line: LoanGuarantorChangeLineWithDetails; disabled: boolean;
}) {
  const [open, setOpen] = useState(false);
  const [candidates, setCandidates] = useState<GuarantorCandidate[]>([]);
  const [memberId, setMemberId] = useState('');
  const [amountSh, setAmountSh] = useState('');
  const [busy, setBusy] = useState(false);
  const router = useRouter();
  const showResult = useResultDialog();
  const confirm = useConfirm();
  const { cur } = useFormat();

  useEffect(() => {
    if (!open) return;
    let cancelled = false;
    availableReplacementsForChange(no).then((res) => {
      if (!cancelled && res.ok) setCandidates(res.data);
    });
    return () => { cancelled = true; };
  }, [open, no]);

  const allocated = line.replacements.reduce((s, r) => s + r.amount, 0);
  const remaining = line.outstanding_guaranteed - allocated;
  const chosen = candidates.find((c) => String(c.id) === memberId);

  const add = async () => {
    if (!memberId || !amountSh) { showResult('Incomplete', 'Choose a member and an amount first', 'err'); return; }
    setBusy(true);
    try {
      const res = await addReplacementRequest(no, line.id, Number(memberId), amountSh);
      if (!res.ok) { showResult('Could not add replacement', res.error, 'err'); return; }
      setMemberId('');
      setAmountSh('');
      router.refresh();
    } finally {
      setBusy(false);
    }
  };

  const remove = async (replacementId: number) => {
    const ok = await confirm({ title: 'Remove this replacement?', confirmLabel: 'Remove' });
    if (!ok) return;
    setBusy(true);
    try {
      const res = await removeReplacementRequest(no, replacementId);
      if (!res.ok) { showResult('Could not remove replacement', res.error, 'err'); return; }
      router.refresh();
    } finally {
      setBusy(false);
    }
  };

  return (
    <>
      <button type="button" className="btn sm ghost" disabled={disabled && !line.replacements.length} onClick={() => setOpen(true)}>
        {line.replacements.length ? `Replacements (${line.replacements.length})` : 'Add replacement'}
      </button>
      {open ? (
        <Modal title={`Replacements for ${line.guarantor_first_name} ${line.guarantor_last_name}`} onClose={() => setOpen(false)}>
          {line.replacements.length ? (
            <TableWrap>
              <thead><tr><th>Member</th><th className="num">Amount</th><th className="num" /></tr></thead>
              <tbody>
                {line.replacements.map((r) => (
                  <tr key={r.id}>
                    <td>{r.replacement_first_name} {r.replacement_last_name}
                      <div className="tiny mono">{r.replacement_member_no}</div>
                    </td>
                    <td className="num"><Money cents={r.amount} decimals={0} /></td>
                    <td className="num">
                      {!disabled ? (
                        <button type="button" className="btn sm ghost" disabled={busy} onClick={() => remove(r.id)}>
                          Remove
                        </button>
                      ) : null}
                    </td>
                  </tr>
                ))}
              </tbody>
            </TableWrap>
          ) : <p className="tiny">No replacements added yet.</p>}

          {!disabled ? (
            <div className="grid g3" style={{ marginTop: 10, alignItems: 'end' }}>
              <MemberSelect id={`f_replacement_${line.id}`} name="replacementMemberId" label="Add replacement"
                members={candidates} value={memberId} onChange={setMemberId} />
              <div className="field">
                <label htmlFor={`f_replacementAmount_${line.id}`}>Amount</label>
                <input id={`f_replacementAmount_${line.id}`} type="number" step="0.01" value={amountSh}
                  onChange={(e) => setAmountSh(e.target.value)} />
                <div className="hint">
                  {chosen ? `Up to ${cur(chosen.availableGuarantee)} available` : `${cur(Math.max(0, remaining))} left unallocated on this line`}
                </div>
              </div>
              <button type="button" className="btn sm" disabled={busy} onClick={add}>
                {busy ? 'Working…' : 'Add'}
              </button>
            </div>
          ) : null}
        </Modal>
      ) : null}
    </>
  );
}

function NewChangeForm({ loans, presetLoanId, onClose }: {
  loans: ChangeableLoanRow[]; presetLoanId?: string | null; onClose: () => void;
}) {
  const { cur } = useFormat();
  return (
    <FormModal
      title="New guarantor change"
      onClose={onClose}
      onSubmit={(values) => requestGuarantorChange(Number(values.loanId))}
      submitLabel="Open document"
      successTitle="Guarantor change opened"
      successDetail={(d) => `${d.no} saved — release or substitute guarantors, then send it for approval`}
    >
      <div className="field">
        <label htmlFor="f_loanId">Loan <span className="req">*</span></label>
        <select id="f_loanId" name="loanId" required defaultValue={presetLoanId ?? String(loans[0]?.id ?? '')}>
          {loans.map((l) => (
            <option key={l.id} value={l.id}>
              {l.loan_no} — {l.member_no} {l.first_name} {l.last_name}
              {' '}({l.guarantor_count} guarantor{l.guarantor_count === 1 ? '' : 's'}, outstanding {cur(l.outstanding_balance)})
            </option>
          ))}
        </select>
      </div>
    </FormModal>
  );
}

export function NewGuarantorChangeButton({ loans, presetLoanId }: {
  loans: ChangeableLoanRow[]; presetLoanId?: string | null;
}) {
  const router = useRouter();
  const [open, setOpen] = useState(Boolean(presetLoanId));

  const close = () => {
    setOpen(false);
    if (presetLoanId) router.replace('/guarantor-changes');
  };

  return (
    <>
      <button type="button" className="btn" disabled={!loans.length} onClick={() => setOpen(true)}>
        New guarantor change
      </button>
      {open ? <NewChangeForm loans={loans} presetLoanId={presetLoanId} onClose={close} /> : null}
    </>
  );
}
