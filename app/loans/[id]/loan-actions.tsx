'use client';

import { useState } from 'react';
import { FormModal } from '@/components/ui/form-modal';
import { Field } from '@/components/ui/field';
import { DefinitionList } from '@/components/ui/primitives';
import { useFormat } from '@/components/ui/format-provider';
import { decideLoan, disburseLoan, repayLoan } from '@/app/actions/loans';
import { DISBURSE_CHANNELS, REPAY_CHANNELS } from '@/lib/constants';
import { today, toUnits } from '@/lib/format';
import type { LoanFull, SavingsAccountWithProduct } from '@/lib/types';

/** Approve / reject, with the maker-checker rule enforced server-side. */
export function DecideButtons({ loan }: { loan: LoanFull }) {
  const [decision, setDecision] = useState<'approve' | 'reject' | null>(null);
  const { cur } = useFormat();
  const approving = decision === 'approve';

  return (
    <>
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
