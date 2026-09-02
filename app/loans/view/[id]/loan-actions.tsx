'use client';

import { useEffect, useState } from 'react';
import { useRouter } from 'next/navigation';
import { FormModal } from '@/components/ui/form-modal';
import { Field } from '@/components/ui/field';
import { MemberSelect } from '@/components/ui/member-select';
import { SearchableSelect } from '@/components/ui/searchable-select';
import { DefinitionList } from '@/components/ui/primitives';
import { useFormat } from '@/components/ui/format-provider';
import { useResultDialog } from '@/components/ui/result-dialog';
import { useConfirm } from '@/components/ui/confirm-dialog';
import { useRunAction } from '@/components/ui/run-action';
import { decideLoan, disburseLoan, repayLoan, runLoanAppraisal, submitLoan } from '@/app/actions/loans';
import { delegateMyTask } from '@/app/actions/workflows';
import {
  attachCollateralToLoanRequest, detachCollateralFromLoanRequest, availableCollateralForMember,
} from '@/app/actions/loanCollateral';
import {
  attachFdToLoanRequest, detachFdFromLoanRequest, availableFdForMember,
} from '@/app/actions/loanFdSecurity';
import {
  availableGuarantorsForLoan, commitGuarantorToLoanRequest, releaseGuarantorFromLoanRequest,
} from '@/app/actions/loanGuarantors';
import { PAY_MODES } from '@/lib/constants';
import { today, toUnits } from '@/lib/format';
import type {
  AvailableCollateralRow, AvailableFdRow, BankAccount, GuarantorCandidate, LoanFull, PayMode, SavingsAccountWithProduct,
} from '@/lib/types';

/** Sends a captured (OPEN) loan for approval — only once the loan has been *fully* appraised
 *  (the latest run came back ELIGIBLE, not just any appraisal on file); the server enforces this
 *  too (loanService.submit()), this is just the friendlier front end for it. */
export function SubmitButton({ loanId, appraisalDecision, className = 'btn' }: {
  loanId: number; appraisalDecision: 'ELIGIBLE' | 'REFERRED' | null; className?: string;
}) {
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

  if (appraisalDecision !== 'ELIGIBLE') {
    const label = appraisalDecision === 'REFERRED'
      ? 'Referred — resolve and re-run appraisal before sending for approval'
      : 'Run appraisal before sending for approval';
    return (
      <span className="hint" title="This loan must come back fully eligible before it can be sent for approval.">
        {label}
      </span>
    );
  }

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
              ? 'Approving commits the society to disburse this facility.'
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

/** Cheque No./Date (Pay Mode = Cheque) or a Reference No. (Pay Mode = M-Pesa/Bank/EFT) — the
 *  same per-Pay-Mode extras both DisburseButton and RepayButton need once a Bank/Cashbook
 *  account is in the picture at all. */
function PayModeExtraFields({ payMode }: { payMode: PayMode | '' }) {
  if (payMode === 'CHEQUE') {
    return (
      <>
        <Field name="chequeNo" label="Cheque No." required />
        <Field name="chequeDate" label="Cheque date" type="date" required />
      </>
    );
  }
  if (payMode === 'MPESA' || payMode === 'BANK' || payMode === 'EFT') {
    return <Field name="referenceNo" label="Reference No." required />;
  }
  return null;
}

export function DisburseButton({ loan, bankAccounts }: { loan: LoanFull; bankAccounts: BankAccount[] }) {
  const [open, setOpen] = useState(false);
  const [payMode, setPayMode] = useState<PayMode | ''>('');
  const [bankAccountId, setBankAccountId] = useState('');
  const { cur } = useFormat();
  // A member-savings-account target is decided when the loan itself was applied for/edited —
  // no Payment Channel is offered here at all in that case, since no bank/cashbook is touched.
  const isPayout = !loan.disburse_to_account_id;

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
          {isPayout ? (
            <>
              <SearchableSelect name="bankAccountId" label="Bank/Cashbook account" required
                items={bankAccounts} getValue={(b) => String(b.id)} getLabel={(b) => `${b.code} — ${b.name}`}
                value={bankAccountId} onChange={setBankAccountId}
                placeholder="Search bank/cashbook account…" emptyText="No matching accounts" />
              <Field name="payMode" label="Pay mode" type="select" required
                options={[{ value: '', label: 'Select…' }, ...PAY_MODES]}
                onChange={(e) => setPayMode(e.target.value as PayMode)} />
              <PayModeExtraFields payMode={payMode} />
            </>
          ) : null}
        </FormModal>
      ) : null}
    </>
  );
}

export function RepayButton({ loan, accounts, bankAccounts }: {
  loan: LoanFull;
  accounts: SavingsAccountWithProduct[];
  bankAccounts: BankAccount[];
}) {
  const [open, setOpen] = useState(false);
  const { cur } = useFormat();
  const owed = loan.principal_balance + loan.interest_balance + loan.penalty_balance;
  const [fromSavingsAccountId, setFromSavingsAccountId] = useState('');
  const [payMode, setPayMode] = useState<PayMode | ''>('');
  const [repayBankAccountId, setRepayBankAccountId] = useState('');
  // Debiting a member's own account never touches a bank/cashbook — Payment Channel/Pay Mode
  // only apply to an actual external (cash/bank/mpesa/cheque) receipt.
  const isExternal = !fromSavingsAccountId;

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
          <Field name="amount" label="Amount received" type="currency" required
            defaultValue={toUnits(loan.installment)} />
          <SearchableSelect name="fromSavingsAccountId" label="Debit a member account instead"
            items={accounts} getValue={(a) => String(a.id)}
            getLabel={(a) => `${a.account_no} — ${a.product_name} (${cur(a.balance)})`}
            value={fromSavingsAccountId} onChange={setFromSavingsAccountId}
            placeholder="No — cash / external receipt" emptyText="No matching accounts" />
          {isExternal ? (
            <>
              <SearchableSelect name="bankAccountId" label="Bank/Cashbook account" required
                items={bankAccounts} getValue={(b) => String(b.id)} getLabel={(b) => `${b.code} — ${b.name}`}
                value={repayBankAccountId} onChange={setRepayBankAccountId}
                placeholder="Search bank/cashbook account…" emptyText="No matching accounts" />
              <Field name="payMode" label="Pay mode" type="select" required
                options={[{ value: '', label: 'Select…' }, ...PAY_MODES]}
                onChange={(e) => setPayMode(e.target.value as PayMode)} />
              <PayModeExtraFields payMode={payMode} />
            </>
          ) : null}
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
              <SearchableSelect name="collateralNo" label="Collateral" required
                items={available} getValue={(c) => c.no}
                getLabel={(c) => `${c.no} — ${c.collateral_description || c.serial_reg_no || 'Untitled'} (cover left ${cur(c.collateral_balance)})`}
                value={collateralNo} onChange={setCollateralNo}
                placeholder="Search collateral…" emptyText="No matching collateral" />
              <Field name="guaranteeSh" label="Cover to draw from this item" type="currency" required
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

/** Re-runs and files a fresh credit appraisal against this loan — offered while it is still
 *  OPEN/PENDING APPROVAL/APPROVED (the same window saveAppraisal() itself enforces server-side),
 *  so an officer can revalidate eligibility right up to the point of disbursement. */
export function RunAppraisalButton({ loanId, className = 'btn ghost' }: { loanId: number; className?: string }) {
  const { run, busy } = useRunAction();
  return (
    <button type="button" className={className} disabled={busy}
      onClick={() => run(() => runLoanAppraisal(loanId), {
        successTitle: (a) => `Appraisal filed — ${a.decision === 'ELIGIBLE' ? 'eligible' : 'referred'} (${a.score}/100)`,
      })}>
      {busy ? 'Appraising…' : 'Run appraisal'}
    </button>
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

/** Pledges a member's Fixed Deposit as security for this loan — the FD-as-collateral sibling of
 *  AttachCollateralButton above, only while the loan is still OPEN. */
export function AttachFdSecurityButton({ loanId, memberId, className = 'btn sm ghost' }: {
  loanId: number; memberId: number; className?: string;
}) {
  const [open, setOpen] = useState(false);
  const [available, setAvailable] = useState<AvailableFdRow[]>([]);
  const [fdNo, setFdNo] = useState('');
  const { cur } = useFormat();

  useEffect(() => {
    if (!open) return;
    let cancelled = false;
    availableFdForMember(memberId).then((res) => {
      if (cancelled || !res.ok) return;
      setAvailable(res.data);
    });
    return () => { cancelled = true; };
  }, [open, memberId]);

  const chosen = available.find((f) => f.no === fdNo);

  return (
    <>
      <button type="button" className={className} onClick={() => setOpen(true)}>Attach FD security</button>
      {open ? (
        <FormModal
          title="Attach fixed deposit security"
          onClose={() => setOpen(false)}
          onSubmit={(values) => attachFdToLoanRequest(loanId, String(values.fdNo), String(values.guaranteeSh))}
          submitLabel="Attach"
          successTitle="Fixed deposit attached"
        >
          {available.length ? (
            <>
              <SearchableSelect name="fdNo" label="Fixed deposit" required
                items={available} getValue={(f) => f.no}
                getLabel={(f) => `${f.no} — ${f.fd_type_description} (cover left ${cur(f.available)})`}
                value={fdNo} onChange={setFdNo}
                placeholder="Search fixed deposit…" emptyText="No matching fixed deposits" />
              <Field name="guaranteeSh" label="Cover to draw from this fixed deposit" type="currency" required
                defaultValue={chosen ? toUnits(chosen.available) : ''}
                hint={chosen ? `Up to ${cur(chosen.available)} still available` : undefined} />
            </>
          ) : (
            <p>This member has no approved or active fixed deposit with cover left to pledge.</p>
          )}
        </FormModal>
      ) : null}
    </>
  );
}

export function DetachFdSecurityButton({ loanId, fdNo, className = 'btn sm ghost' }: {
  loanId: number; fdNo: string; className?: string;
}) {
  const { run, busy } = useRunAction();
  return (
    <button type="button" className={className} disabled={busy}
      onClick={() => run(() => detachFdFromLoanRequest(loanId, fdNo), {
        confirm: { title: 'Detach this fixed deposit security?', confirmLabel: 'Detach' },
        successTitle: 'Fixed deposit security detached',
      })}>
      {busy ? 'Working…' : 'Detach'}
    </button>
  );
}

/** Commits a member's guarantee to this loan — only while it is still OPEN, the same point
 *  loan_guarantor rows are fixed. Moved onto the card itself (out of the Edit form) so it works
 *  the same way as AttachCollateralButton above. */
export function AddGuarantorButton({ loanId, memberId, existingMemberIds, className = 'btn sm ghost' }: {
  loanId: number; memberId: number; existingMemberIds: number[]; className?: string;
}) {
  const [open, setOpen] = useState(false);
  const [available, setAvailable] = useState<GuarantorCandidate[]>([]);
  const [guarantorId, setGuarantorId] = useState('');
  const { cur } = useFormat();

  useEffect(() => {
    if (!open) return;
    let cancelled = false;
    availableGuarantorsForLoan(memberId, existingMemberIds).then((res) => {
      if (cancelled || !res.ok) return;
      setAvailable(res.data);
      setGuarantorId('');
    });
    return () => { cancelled = true; };
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [open, memberId]);

  const chosen = available.find((m) => String(m.id) === guarantorId);

  return (
    <>
      <button type="button" className={className} onClick={() => setOpen(true)}>Add guarantor</button>
      {open ? (
        <FormModal
          title="Add guarantor"
          onClose={() => setOpen(false)}
          onSubmit={(values) => commitGuarantorToLoanRequest(loanId, Number(values.guarantorId), String(values.amountSh))}
          submitLabel="Commit"
          successTitle="Guarantor committed"
        >
          {available.length ? (
            <>
              <MemberSelect id="f_guarantorId" name="guarantorId" label="Guarantor" members={available}
                value={guarantorId} onChange={setGuarantorId} required />
              <Field name="amountSh" label="Amount guaranteed" type="currency" required
                defaultValue={chosen ? toUnits(chosen.availableGuarantee) : ''}
                hint={chosen ? `Up to ${cur(chosen.availableGuarantee)} available to guarantee` : 'Pick a member above first'} />
            </>
          ) : (
            <p>No other eligible members are available to guarantee this loan.</p>
          )}
        </FormModal>
      ) : null}
    </>
  );
}

export function ReleaseGuarantorButton({ loanId, memberId, className = 'btn sm ghost' }: {
  loanId: number; memberId: number; className?: string;
}) {
  const { run, busy } = useRunAction();
  return (
    <button type="button" className={className} disabled={busy}
      onClick={() => run(() => releaseGuarantorFromLoanRequest(loanId, memberId), {
        confirm: { title: 'Release this guarantor?', confirmLabel: 'Release' },
        successTitle: 'Guarantor released',
      })}>
      {busy ? 'Working…' : 'Release'}
    </button>
  );
}
