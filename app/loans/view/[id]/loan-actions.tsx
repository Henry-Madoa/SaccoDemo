'use client';

import { useEffect, useState } from 'react';
import { useRouter } from 'next/navigation';
import { FormModal } from '@/components/ui/form-modal';
import { Field } from '@/components/ui/field';
import { DefinitionList } from '@/components/ui/primitives';
import { useFormat } from '@/components/ui/format-provider';
import { useResultDialog } from '@/components/ui/result-dialog';
import { useConfirm } from '@/components/ui/confirm-dialog';
import { useRunAction } from '@/components/ui/run-action';
import { decideLoan, disburseLoan, repayLoan, submitLoan } from '@/app/actions/loans';
import { delegateMyTask } from '@/app/actions/workflows';
import {
  attachCollateralToLoanRequest, detachCollateralFromLoanRequest, availableCollateralForMember,
} from '@/app/actions/loanCollateral';
import { DISBURSE_CHANNELS, REPAY_CHANNELS } from '@/lib/constants';
import { today, toUnits } from '@/lib/format';
import type { AvailableCollateralRow, LoanFull, SavingsAccountWithProduct } from '@/lib/types';

/** Sends a captured (OPEN) loan for approval. */
export function SubmitButton({ loanId, className = 'btn' }: { loanId: number; className?: string }) {
  const router = useRouter();
  const showResult = useResultDialog();
  const confirm = useConfirm();
  const [busy, setBusy] = useState(false);

  const submit = async () => {
    const ok = await confirm({
      title: 'Send this loan for approval?',
      message: 'It will be routed to the configured approver(s) and can no longer be edited while pending.',
      confirmLabel: 'Send for approval',
    });
    if (!ok) return;
    setBusy(true);
    try {
      const res = await submitLoan(loanId);
      if (!res.ok) { showResult('Could not submit', res.error, 'err'); return; }
      if (res.data.status === 'APPROVED') {
        showResult('Loan approved', 'You are the assigned approver, so this was approved automatically.', 'ok');
      } else {
        showResult('Sent for approval', undefined, 'ok');
      }
      router.refresh();
    } finally {
      setBusy(false);
    }
  };

  return (
    <button type="button" className={className} disabled={busy} onClick={submit}>
      {busy ? 'Working…' : 'Send for approval'}
    </button>
  );
}

/** Approve / reject / delegate, with the maker-checker rule enforced server-side. */
export function DecideButtons({ loan, routedTaskId }: { loan: LoanFull; routedTaskId: number | null }) {
  const [decision, setDecision] = useState<'approve' | 'reject' | null>(null);
  const { cur } = useFormat();
  const router = useRouter();
  const showResult = useResultDialog();
  const confirm = useConfirm();
  const [delegating, setDelegating] = useState(false);
  const approving = decision === 'approve';

  const delegate = async () => {
    if (!routedTaskId) return;
    const ok = await confirm({
      title: 'Delegate to your substitute?',
      message: 'Your configured substitute will be asked to decide this instead of you.',
      confirmLabel: 'Delegate',
    });
    if (!ok) return;
    setDelegating(true);
    try {
      const res = await delegateMyTask(routedTaskId);
      if (!res.ok) { showResult('Could not delegate', res.error, 'err'); return; }
      showResult('Delegated to your substitute', undefined, 'ok');
      router.refresh();
    } finally {
      setDelegating(false);
    }
  };

  return (
    <>
      {routedTaskId ? (
        <button type="button" className="btn ghost" disabled={delegating} onClick={delegate}>
          {delegating ? 'Working…' : 'Delegate'}
        </button>
      ) : null}
      <button type="button" className="btn ghost" onClick={() => setDecision('reject')}>Reject</button>
      <button type="button" className="btn" onClick={() => setDecision('approve')}>Approve</button>

      {decision ? (
        <FormModal
          title={`${approving ? 'Approve' : 'Reject'} ${loan.loan_no}`}
          onClose={() => setDecision(null)}
          onSubmit={(values) => decideLoan(loan.id, approving, String(values.reason || '').trim())}
          submitLabel={approving ? 'Approve loan' : 'Reject application'}
          submitClass={approving ? 'btn' : 'btn danger'}
          successTitle={approving ? 'Loan approved' : 'Application rejected'}
          successDetail={loan.loan_no}
          resultStyle="popup"
        >
          <p>
            {approving
              ? 'Approving commits the society to disburse this facility. The approver may not be the officer who captured it.'
              : 'The application stays on file and can be resubmitted under a new workflow instance.'}
          </p>
          <div className="card inset">
            <DefinitionList items={[
              ['Member', `${loan.first_name} ${loan.last_name}`],
              ['Amount', <b key="amt">{cur(loan.principal)}</b>],
              ['Term', `${loan.term_months} months`],
              ['Captured by', loan.created_by || '—'],
            ]} />
          </div>
          <Field name="reason" label={approving ? 'Approval note' : 'Reason for rejection'} required={!approving} />
        </FormModal>
      ) : null}
    </>
  );
}

export function DisburseButton({ loan }: { loan: LoanFull }) {
  const [open, setOpen] = useState(false);
  const { cur } = useFormat();

  return (
    <>
      <button type="button" className="btn" onClick={() => setOpen(true)}>Disburse</button>
      {open ? (
        <FormModal
          title={`Disburse ${loan.loan_no}`}
          onClose={() => setOpen(false)}
          onSubmit={(values) => disburseLoan(loan.id, values)}
          submitLabel="Disburse"
          successTitle="Disbursed"
          successDetail={`${loan.loan_no} · ${cur(loan.principal)}`}
          resultStyle="popup"
        >
          <p>
            On disbursement the amortisation schedule is generated, the loan receivable is debited
            and charges are recovered — all in one balanced journal.
          </p>
          <Field name="valueDate" label="Value date" type="date" defaultValue={today()} required />
          <Field name="channel" label="Payment channel" type="select" options={DISBURSE_CHANNELS} />
        </FormModal>
      ) : null}
    </>
  );
}

export function RepayButton({ loan, accounts }: {
  loan: LoanFull;
  accounts: SavingsAccountWithProduct[];
}) {
  const [open, setOpen] = useState(false);
  const { cur } = useFormat();
  const owed = loan.principal_balance + loan.interest_balance + loan.penalty_balance;

  return (
    <>
      <button type="button" className="btn" onClick={() => setOpen(true)}>Post repayment</button>
      {open ? (
        <FormModal
          title={`Repayment — ${loan.loan_no}`}
          onClose={() => setOpen(false)}
          onSubmit={(values) => repayLoan(loan.id, values)}
          submitLabel="Post repayment"
          successTitle={undefined}
        >
          <div className="card inset">
            <DefinitionList items={[
              ['Outstanding', <b key="owed">{cur(owed)}</b>],
              ['Monthly instalment', cur(loan.installment)],
              ['Allocation order', 'Penalties → interest → principal, oldest instalment first'],
            ]} />
          </div>
          <Field name="amount" label="Amount received" type="number" step="0.01" required
            defaultValue={toUnits(loan.installment)} />
          <Field name="channel" label="Channel" type="select" options={REPAY_CHANNELS} />
          <Field name="fromSavingsAccountId" label="Debit a member account instead" type="select"
            options={[
              { value: '', label: 'No — cash / external receipt' },
              ...accounts.map((a) => ({
                value: a.id,
                label: `${a.account_no} — ${a.product_name} (${cur(a.balance)})`,
              })),
            ]} />
          <Field name="valueDate" label="Value date" type="date" defaultValue={today()} />
          <Field name="description" label="Narration" defaultValue="Loan repayment" />
        </FormModal>
      ) : null}
    </>
  );
}

/** Pledges an accepted collateral register item as security for this loan — only while the
 *  loan is still OPEN, the same point loan_guarantor rows are fixed. */
export function AttachCollateralButton({ loanId, memberId, className = 'btn sm ghost' }: {
  loanId: number; memberId: number; className?: string;
}) {
  const [open, setOpen] = useState(false);
  const [available, setAvailable] = useState<AvailableCollateralRow[]>([]);
  const [collateralNo, setCollateralNo] = useState('');
  const { cur } = useFormat();

  useEffect(() => {
    if (!open) return;
    let cancelled = false;
    availableCollateralForMember(memberId).then((res) => {
      if (cancelled || !res.ok) return;
      setAvailable(res.data);
      setCollateralNo(res.data[0]?.no ?? '');
    });
    return () => { cancelled = true; };
  }, [open, memberId]);

  const chosen = available.find((c) => c.no === collateralNo);

  return (
    <>
      <button type="button" className={className} onClick={() => setOpen(true)}>Attach collateral</button>
      {open ? (
        <FormModal
          title="Attach collateral"
          onClose={() => setOpen(false)}
          onSubmit={(values) => attachCollateralToLoanRequest(loanId, String(values.collateralNo), String(values.guaranteeSh))}
          submitLabel="Attach"
          successTitle="Collateral attached"
        >
          {available.length ? (
            <>
              <div className="field">
                <label htmlFor="f_collateralNo">Collateral <span className="req">*</span></label>
                <select id="f_collateralNo" name="collateralNo" required value={collateralNo}
                  onChange={(e) => setCollateralNo(e.target.value)}>
                  {available.map((c) => (
                    <option key={c.no} value={c.no}>
                      {c.no} — {c.collateral_description || c.serial_reg_no || 'Untitled'} (cover left {cur(c.collateral_balance)})
                    </option>
                  ))}
                </select>
              </div>
              <Field name="guaranteeSh" label="Cover to draw from this item" type="number" step="0.01" required
                defaultValue={chosen ? toUnits(chosen.collateral_balance) : ''}
                hint={chosen ? `Up to ${cur(chosen.collateral_balance)} still available` : undefined} />
            </>
          ) : (
            <p>This member has no registered collateral with cover left to pledge.</p>
          )}
        </FormModal>
      ) : null}
    </>
  );
}

export function DetachCollateralButton({ loanId, collateralNo, className = 'btn sm ghost' }: {
  loanId: number; collateralNo: string; className?: string;
}) {
  const { run, busy } = useRunAction();
  return (
    <button type="button" className={className} disabled={busy}
      onClick={() => run(() => detachCollateralFromLoanRequest(loanId, collateralNo), {
        confirm: { title: 'Detach this collateral?', confirmLabel: 'Detach' },
        successTitle: 'Collateral detached',
      })}>
      {busy ? 'Working…' : 'Detach'}
    </button>
  );
}
