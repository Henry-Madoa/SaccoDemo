'use client';

import { useEffect, useState } from 'react';
import { useRouter } from 'next/navigation';
import { FormModal } from '@/components/ui/form-modal';
import { Field, readForm } from '@/components/ui/field';
import { Card, CardHead, Pill, TableWrap } from '@/components/ui/primitives';
import { useFormat } from '@/components/ui/format-provider';
import { useToast } from '@/components/ui/toast';
import { appraiseLoan, applyForLoan, memberDisbursementAccounts } from '@/app/actions/loans';
import type { Appraisal, LoanProduct, Member, SavingsAccountWithProduct } from '@/lib/types';

export interface ApplicationFormProps {
  members: Pick<Member, 'id' | 'member_no' | 'first_name' | 'last_name'>[];
  products: LoanProduct[];
  presetMemberId?: number | null;
  onClose: () => void;
}

function ApplicationForm({ members, products, presetMemberId, onClose }: ApplicationFormProps) {
  const toast = useToast();
  const [memberId, setMemberId] = useState(String(presetMemberId ?? members[0]?.id ?? ''));
  const [accounts, setAccounts] = useState<SavingsAccountWithProduct[]>([]);
  const [appraisal, setAppraisal] = useState<Appraisal | null>(null);
  const [checking, setChecking] = useState(false);

  // The disbursement target depends on the member, so it is fetched rather than
  // shipped for all 120 members up front.
  useEffect(() => {
    let cancelled = false;
    if (!memberId) { setAccounts([]); return; }
    setAppraisal(null);
    memberDisbursementAccounts(Number(memberId)).then((res) => {
      if (!cancelled && res.ok) setAccounts(res.data);
    });
    return () => { cancelled = true; };
  }, [memberId]);

  const runAppraisal = async (form: HTMLFormElement | null) => {
    if (!form) return;
    const values = readForm(form);
    if (!values.memberId || !values.productId || !values.principal) {
      toast('Incomplete', 'Choose a member, product and amount first', 'err');
      return;
    }
    setChecking(true);
    try {
      const res = await appraiseLoan(values);
      if (res.ok) setAppraisal(res.data);
      else toast('Could not appraise', res.error, 'err');
    } finally {
      setChecking(false);
    }
  };

  return (
    <FormModal
      wide
      title="New loan application"
      onClose={onClose}
      onSubmit={applyForLoan}
      submitLabel="Save application"
      successTitle="Application captured"
      successDetail={(l) => `${l.loan_no} saved — send it for approval when you're ready`}
      extraFooter={
        <button type="button" className="btn ghost" disabled={checking}
          onClick={(e) => runAppraisal(e.currentTarget.closest('.modal')?.querySelector('form') ?? null)}>
          {checking ? 'Appraising…' : 'Run appraisal'}
        </button>
      }
    >
      <div className="grid g2">
        <div className="field">
          <label htmlFor="f_memberId">Member <span className="req">*</span></label>
          <select id="f_memberId" name="memberId" required value={memberId}
            onChange={(e) => setMemberId(e.target.value)}>
            {members.map((m) => (
              <option key={m.id} value={m.id}>{m.member_no} — {m.first_name} {m.last_name}</option>
            ))}
          </select>
        </div>

        <Field name="productId" label="Loan product" type="select" required
          options={products.map((p) => ({
            value: p.id,
            label: `${p.name} (${p.interest_rate}% ${p.interest_method.toLowerCase()})`,
          }))} />

        <Field name="principal" label="Amount applied for" type="number" step="0.01" required />
        <Field name="termMonths" label="Repayment period (months)" type="number" defaultValue={24} required />
        <Field name="purpose" label="Purpose" placeholder="e.g. Business expansion" />
        <Field name="disburseToAccountId" label="Disburse to" type="select"
          options={[
            { value: '', label: 'Pay out through the bank' },
            ...accounts.map((a) => ({ value: a.id, label: `${a.account_no} — ${a.product_name}` })),
          ]} />
      </div>

      {appraisal ? <AppraisalCard appraisal={appraisal} /> : null}
    </FormModal>
  );
}

function AppraisalCard({ appraisal: a }: { appraisal: Appraisal }) {
  const { cur } = useFormat();
  return (
    <Card className="inset">
      <CardHead
        title={<>Credit appraisal — <Pill status={a.decision} /></>}
        sub={`Policy score ${a.score}/100 · every factor is shown so the decision is explainable`}
      />
      <TableWrap>
        <thead><tr><th /><th>Factor</th><th>Assessment</th></tr></thead>
        <tbody>
          {a.factors.map((f) => (
            <tr key={f.code}>
              <td style={{ width: 26 }}>
                <span className={f.pass ? 'factor-ok' : 'factor-no'}>{f.pass ? '✔' : '✖'}</span>
              </td>
              <td>{f.label}</td>
              <td className="muted-cell">{f.detail}</td>
            </tr>
          ))}
        </tbody>
      </TableWrap>
      <div className="grid g4" style={{ marginTop: 'calc(var(--sp)*2)' }}>
        <div><div className="metric-label">Monthly instalment</div><b>{cur(a.installment)}</b></div>
        <div><div className="metric-label">Deposit ceiling</div><b>{cur(a.maxByMultiplier, { decimals: 0 })}</b></div>
        <div><div className="metric-label">Existing exposure</div><b>{cur(a.exposure, { decimals: 0 })}</b></div>
        <div><div className="metric-label">Deduction ratio</div><b>{a.dsr}%</b></div>
      </div>
    </Card>
  );
}

/** Opens the application form, optionally preset from `?new=<memberId>`. */
export function NewApplicationButton({ members, products, presetMemberId }: {
  members: ApplicationFormProps['members'];
  products: LoanProduct[];
  presetMemberId?: number | null;
}) {
  const router = useRouter();
  const [open, setOpen] = useState(Boolean(presetMemberId));

  const close = () => {
    setOpen(false);
    // Drop ?new= so a refresh does not reopen the modal.
    if (presetMemberId) router.replace('/loans');
  };

  return (
    <>
      <button type="button" className="btn" onClick={() => setOpen(true)}>New application</button>
      {open ? (
        <ApplicationForm members={members} products={products}
          presetMemberId={presetMemberId} onClose={close} />
      ) : null}
    </>
  );
}
