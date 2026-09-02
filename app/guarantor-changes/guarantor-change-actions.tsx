'use client';

import { useEffect, useState } from 'react';
import { useRouter } from 'next/navigation';
import { FormModal } from '@/components/ui/form-modal';
import { Modal } from '@/components/ui/modal';
import { Field, MoneyInput } from '@/components/ui/field';
import { MemberSelect } from '@/components/ui/member-select';
import { SearchableSelect } from '@/components/ui/searchable-select';
import { TableWrap } from '@/components/ui/primitives';
import { Money } from '@/components/ui/money';
import { useFormat } from '@/components/ui/format-provider';
import { useResultDialog } from '@/components/ui/result-dialog';
import { useConfirm } from '@/components/ui/confirm-dialog';
import { useRunAction } from '@/components/ui/run-action';
import {
  requestGuarantorChange, refreshGuarantorChangeLinesRequest, setLineReleaseRequest,
  addReplacementRequest, removeReplacementRequest, availableReplacementsForChange,
  availableCollateralForGuarantorChange, availableFdForGuarantorChange,
  submitGuarantorChangeRequest, cancelGuarantorChangeApprovalRequest,
  approveGuarantorChangeRequest, rejectGuarantorChangeRequest, processGuarantorChangeRequest,
} from '@/app/actions/loanGuarantorChanges';
import { delegateMyTask } from '@/app/actions/workflows';
import { REPLACEMENT_TYPES } from '@/lib/constants';
import type {
  AvailableCollateralRow, AvailableFdRow, ChangeableLoanRow, GuarantorCandidate,
  LoanGuarantorChangeLineWithDetails, ReplacementType,
} from '@/lib/types';

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

/** A replacement row's display label + sub-line, per its type. */
function replacementLabel(r: LoanGuarantorChangeLineWithDetails['replacements'][number]): { title: string; sub: string | null } {
  if (r.replacement_type === 'COLLATERAL') {
    return { title: r.replacement_collateral_description || r.replacement_collateral_no || '—', sub: r.replacement_collateral_no };
  }
  if (r.replacement_type === 'FIXED_DEPOSIT') {
    return { title: r.replacement_fd_type_description || r.replacement_fd_no || '—', sub: r.replacement_fd_no };
  }
  return { title: `${r.replacement_first_name} ${r.replacement_last_name}`, sub: r.replacement_member_no };
}

/** Manages one line's replacements — list with remove, plus a compact add form. Which security
 *  type a replacement can be — Member/Guarantor, Fixed Deposit, or Collateral (AL's Det. Lines
 *  Security Type) — is chosen first and drives which picker (and which candidate list) shows
 *  below it. Every candidate list is scoped to the loan's own borrower (for Collateral/Fixed
 *  Deposit) exactly as lib/loanGuarantorChanges.ts's addReplacement() itself re-validates —
 *  fetched lazily once opened, all three at once so switching the type never re-fetches. */
export function ReplacementsModal({ no, line, disabled }: {
  no: string; line: LoanGuarantorChangeLineWithDetails; disabled: boolean;
}) {
  const [open, setOpen] = useState(false);
  const [type, setType] = useState<ReplacementType>('GUARANTOR');
  const [memberCandidates, setMemberCandidates] = useState<GuarantorCandidate[]>([]);
  const [collateralCandidates, setCollateralCandidates] = useState<AvailableCollateralRow[]>([]);
  const [fdCandidates, setFdCandidates] = useState<AvailableFdRow[]>([]);
  const [code, setCode] = useState('');
  const [amountSh, setAmountSh] = useState('');
  const [busy, setBusy] = useState(false);
  const router = useRouter();
  const showResult = useResultDialog();
  const confirm = useConfirm();
  const { cur } = useFormat();

  useEffect(() => {
    if (!open) return;
    let cancelled = false;
    Promise.all([
      availableReplacementsForChange(no),
      availableCollateralForGuarantorChange(no),
      availableFdForGuarantorChange(no),
    ]).then(([members, collateral, fd]) => {
      if (cancelled) return;
      if (members.ok) setMemberCandidates(members.data);
      if (collateral.ok) setCollateralCandidates(collateral.data);
      if (fd.ok) setFdCandidates(fd.data);
    });
    return () => { cancelled = true; };
  }, [open, no]);

  const allocated = line.replacements.reduce((s, r) => s + r.amount, 0);
  const remaining = line.outstanding_guaranteed - allocated;

  const chosenMember = memberCandidates.find((c) => String(c.id) === code);
  const chosenCollateral = collateralCandidates.find((c) => c.no === code);
  const chosenFd = fdCandidates.find((c) => c.no === code);
  const availableOnChosen = type === 'GUARANTOR' ? chosenMember?.availableGuarantee
    : type === 'COLLATERAL' ? chosenCollateral?.collateral_balance
      : chosenFd?.available;

  const changeType = (t: ReplacementType) => { setType(t); setCode(''); };

  const add = async () => {
    if (!code || !amountSh) { showResult('Incomplete', 'Choose one and an amount first', 'err'); return; }
    setBusy(true);
    try {
      const res = await addReplacementRequest(no, line.id, type, code, amountSh);
      if (!res.ok) { showResult('Could not add replacement', res.error, 'err'); return; }
      setCode('');
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
              <thead><tr><th>Type</th><th>Security</th><th className="num">Amount</th><th className="num" /></tr></thead>
              <tbody>
                {line.replacements.map((r) => {
                  const { title, sub } = replacementLabel(r);
                  return (
                    <tr key={r.id}>
                      <td>{REPLACEMENT_TYPES.find((t) => t.value === r.replacement_type)?.label ?? r.replacement_type}</td>
                      <td>{title}{sub ? <div className="tiny mono">{sub}</div> : null}</td>
                      <td className="num"><Money cents={r.amount} decimals={0} /></td>
                      <td className="num">
                        {!disabled ? (
                          <button type="button" className="btn sm ghost" disabled={busy} onClick={() => remove(r.id)}>
                            Remove
                          </button>
                        ) : null}
                      </td>
                    </tr>
                  );
                })}
              </tbody>
            </TableWrap>
          ) : <p className="tiny">No replacements added yet.</p>}

          {!disabled ? (
            <>
              <div className="field" style={{ marginTop: 10 }}>
                <label htmlFor={`f_replacementType_${line.id}`}>Replacement type</label>
                <select id={`f_replacementType_${line.id}`} value={type}
                  onChange={(e) => changeType(e.target.value as ReplacementType)}>
                  {REPLACEMENT_TYPES.map((t) => <option key={t.value} value={t.value}>{t.label}</option>)}
                </select>
              </div>
              <div className="grid g3" style={{ alignItems: 'start' }}>
                {type === 'GUARANTOR' ? (
                  <MemberSelect id={`f_replacement_${line.id}`} name="replacementMemberId" label="Member"
                    members={memberCandidates} value={code} onChange={setCode} />
                ) : type === 'COLLATERAL' ? (
                  <div>
                    <SearchableSelect id={`f_replacementCollateral_${line.id}`} name="replacementCollateralNo" label="Collateral"
                      items={collateralCandidates} getValue={(c) => c.no}
                      getLabel={(c) => `${c.no} — ${c.collateral_description || c.serial_reg_no || 'Untitled'} (cover left ${cur(c.collateral_balance)})`}
                      value={code} onChange={setCode} placeholder="Search collateral…" emptyText="No matching collateral" />
                    {!collateralCandidates.length ? <div className="hint">The borrower has no registered collateral with cover left.</div> : null}
                  </div>
                ) : (
                  <div>
                    <SearchableSelect id={`f_replacementFd_${line.id}`} name="replacementFdNo" label="Fixed deposit"
                      items={fdCandidates} getValue={(f) => f.no}
                      getLabel={(f) => `${f.no} — ${f.fd_type_description} (cover left ${cur(f.available)})`}
                      value={code} onChange={setCode} placeholder="Search fixed deposit…" emptyText="No matching fixed deposits" />
                    {!fdCandidates.length ? <div className="hint">The borrower has no approved or active fixed deposit with cover left.</div> : null}
                  </div>
                )}
                <div className="field">
                  <label htmlFor={`f_replacementAmount_${line.id}`}>Amount</label>
                  <MoneyInput id={`f_replacementAmount_${line.id}`} value={amountSh} onChange={setAmountSh} />
                  <div className="hint">
                    {availableOnChosen != null ? `Up to ${cur(availableOnChosen)} available` : `${cur(Math.max(0, remaining))} left unallocated on this line`}
                  </div>
                </div>
                <div className="field">
                  <label>&nbsp;</label>
                  <button type="button" className="btn sm" disabled={busy} onClick={add}>
                    {busy ? 'Working…' : 'Add'}
                  </button>
                </div>
              </div>
            </>
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
  const [loanId, setLoanId] = useState(presetLoanId ?? '');
  return (
    <FormModal
      title="New guarantor change"
      onClose={onClose}
      onSubmit={(values) => requestGuarantorChange(Number(values.loanId))}
      submitLabel="Open document"
      successTitle="Guarantor change opened"
      successDetail={(d) => `${d.no} saved — release or substitute guarantors, then send it for approval`}
    >
      <SearchableSelect id="f_loanId" name="loanId" label="Loan" required
        items={loans} getValue={(l) => String(l.id)}
        getLabel={(l) => `${l.loan_no} — ${l.member_no} ${l.first_name} ${l.last_name} (${l.guarantor_count} guarantor${l.guarantor_count === 1 ? '' : 's'}, outstanding ${cur(l.outstanding_balance)})`}
        value={loanId} onChange={setLoanId} placeholder="Search loan…" emptyText="No matching loans" />
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
