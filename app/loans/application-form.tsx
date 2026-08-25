'use client';

import { useEffect, useState } from 'react';
import { useRouter } from 'next/navigation';
import { FormModal } from '@/components/ui/form-modal';
import { Field, readForm } from '@/components/ui/field';
import { MemberSelect } from '@/components/ui/member-select';
import { useToast } from '@/components/ui/toast';
import { Card, CardHead, TableWrap } from '@/components/ui/primitives';
import { Money } from '@/components/ui/money';
import { AppraisalCard } from '@/components/loans/appraisal-card';
import { appraiseLoan, applyForLoan, memberDisbursementAccounts, updateLoanApplication } from '@/app/actions/loans';
import { calculateLoanProductCharges } from '@/lib/loans';
import { RECOVERY_MODES } from '@/lib/constants';
import { toCents, toUnits } from '@/lib/format';
import type {
  Appraisal, Cents, LoanProductWithCharges, Member, SavingsAccountWithProduct,
} from '@/lib/types';

export interface ApplicationFormProps {
  members: Pick<Member, 'id' | 'member_no' | 'first_name' | 'last_name'>[];
  products: LoanProductWithCharges[];
  presetMemberId?: number | null;
  onClose: () => void;
}

/** The loan fields Edit needs pre-filled — a subset of LoanFull, so callers don't have to
 *  assemble a bespoke shape just to open the same form pre-populated. */
export interface EditableLoan {
  id: number;
  loan_no: string;
  member_id: number;
  product_id: number;
  principal: Cents;
  term_months: number;
  purpose: string | null;
  disburse_to_account_id: number | null;
  recovery_mode?: 'DIRECT' | 'CHECKOFF';
}

interface LoanFormProps {
  members: Pick<Member, 'id' | 'member_no' | 'first_name' | 'last_name'>[];
  products: LoanProductWithCharges[];
  presetMemberId?: number | null;
  /** Present only for Edit — prefills every field and switches the form to updateLoanApplication. */
  loan?: EditableLoan | null;
  onClose: () => void;
}

function LoanForm({ members, products, presetMemberId, loan, onClose }: LoanFormProps) {
  const toast = useToast();
  const [memberId, setMemberId] = useState(String(loan?.member_id ?? presetMemberId ?? ''));
  const [productId, setProductId] = useState(loan ? String(loan.product_id) : '');
  const [principal, setPrincipal] = useState(loan ? toUnits(loan.principal) : '');
  const [termMonths, setTermMonths] = useState(loan ? String(loan.term_months) : '24');
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

  // Section 3's pricing rule: the product must be picked before an amount means anything (its
  // min/max range and charge % gate everything downstream), so the amount field stays disabled
  // until then — and clearing the product back out clears whatever was typed against it.
  const product = products.find((p) => String(p.id) === productId);
  useEffect(() => {
    if (!product) setPrincipal('');
  }, [product]);

  // Live charge preview — section 3's "the proposed system must show the formula result and
  // every charge line before submission" — the Loan Product Charges computation module
  // (lib/loans.ts's calculateLoanProductCharges), itemised, computed the instant an amount is
  // typed against the chosen product.
  const principalCents = toCents(principal);
  const charges = product && principalCents > 0
    ? calculateLoanProductCharges(product.charges, principalCents, Number(termMonths) || 0)
    : [];
  const chargesTotal = charges.reduce((s, c) => s + c.amount, 0);

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
      title={loan ? `Edit ${loan.loan_no}` : 'New loan application'}
      onClose={onClose}
      onSubmit={loan ? (values) => updateLoanApplication(loan.id, values) : applyForLoan}
      submitLabel={loan ? 'Save changes' : 'Save application'}
      successTitle={loan ? 'Application updated' : 'Application captured'}
      successDetail={(l) => (loan ? `${l.loan_no} updated` : `${l.loan_no} saved — send it for approval when you're ready`)}
      extraFooter={
        <button type="button" className="btn ghost" disabled={checking}
          onClick={(e) => runAppraisal(e.currentTarget.closest('.modal')?.querySelector('form') ?? null)}>
          {checking ? 'Appraising…' : 'Run appraisal'}
        </button>
      }
    >
      <div className="grid g2">
        <MemberSelect id="f_memberId" name="memberId" members={members} value={memberId}
          onChange={setMemberId} required />

        <div className="field">
          <label htmlFor="f_productId">Loan product <span className="req">*</span></label>
          <select id="f_productId" name="productId" required value={productId}
            onChange={(e) => setProductId(e.target.value)}>
            <option value="">— Select a product first —</option>
            {products.map((p) => (
              <option key={p.id} value={p.id}>{p.name} ({p.interest_rate}% {p.interest_method.toLowerCase()})</option>
            ))}
          </select>
        </div>

        <div className="field">
          <label htmlFor="f_principal">Amount applied for <span className="req">*</span></label>
          <input id="f_principal" name="principal" type="number" step="0.01" required
            value={principal} disabled={!product}
            onChange={(e) => setPrincipal(e.target.value)} />
          <div className="hint">
            {product
              ? `${product.name} range: ${(product.min_amount / 100).toLocaleString()} – ${(product.max_amount / 100).toLocaleString()}`
              : 'Choose a loan product above to enter an amount'}
          </div>
        </div>

        <div className="field">
          <label htmlFor="f_termMonths">Repayment period (months) <span className="req">*</span></label>
          <input id="f_termMonths" name="termMonths" type="number" required
            value={termMonths} onChange={(e) => setTermMonths(e.target.value)} />
        </div>
        <Field name="purpose" label="Purpose" placeholder="e.g. Business expansion" defaultValue={loan?.purpose ?? ''} />
        {/* Keyed on the loaded account count: accounts arrive async (fetched once memberId is
            known), and an uncontrolled select only applies defaultValue at mount — remounting
            once real options exist is what lets Edit's saved disbursement account come back
            pre-selected instead of silently falling back to "Pay out through the bank". */}
        <Field key={accounts.length} name="disburseToAccountId" label="Disburse to" type="select"
          defaultValue={loan?.disburse_to_account_id ?? ''}
          options={[
            { value: '', label: 'Pay out through the bank' },
            ...accounts.map((a) => ({ value: a.id, label: `${a.account_no} — ${a.product_name}` })),
          ]} />
        <Field name="recoveryMode" label="Recovery mode" type="select" options={RECOVERY_MODES}
          defaultValue={loan?.recovery_mode ?? 'DIRECT'}
          hint="Checkoff is recovered via Checkoff & Salary Processing batches instead of counter repayment" />
      </div>

      {charges.length ? (
        <Card className="inset">
          <CardHead title="Loan charges" sub="Computed automatically from the product's charge parameters" />
          <TableWrap>
            <thead><tr><th>Charge</th><th className="num">Amount</th></tr></thead>
            <tbody>
              {charges.map((c) => (
                <tr key={c.chargeId}>
                  <td>{c.chargeDescription || c.chargeCode}{c.prorated ? ' (prorated)' : ''}</td>
                  <td className="num"><Money cents={c.amount} /></td>
                </tr>
              ))}
            </tbody>
            <tfoot>
              <tr>
                <td>Total charges</td>
                <td className="num"><b><Money cents={chargesTotal} /></b></td>
              </tr>
              <tr>
                <td>Net amount payable</td>
                <td className="num"><b><Money cents={principalCents - chargesTotal} /></b></td>
              </tr>
            </tfoot>
          </TableWrap>
        </Card>
      ) : null}

      {appraisal ? <AppraisalCard appraisal={appraisal} /> : null}
    </FormModal>
  );
}

/** Opens the application form, optionally preset from `?new=<memberId>`. */
export function NewApplicationButton({ members, products, presetMemberId }: {
  members: ApplicationFormProps['members'];
  products: LoanProductWithCharges[];
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
        <LoanForm members={members} products={products}
          presetMemberId={presetMemberId} onClose={close} />
      ) : null}
    </>
  );
}

/** Opens the same form pre-filled against an existing loan — only meaningful while it's still
 *  OPEN (the same window loan-actions.tsx's SubmitButton offers Send for approval), since once
 *  submitted the terms are what the workflow was routed against. */
export function EditLoanButton({ members, products, loan, className = 'btn ghost' }: {
  members: ApplicationFormProps['members'];
  products: LoanProductWithCharges[];
  loan: EditableLoan;
  className?: string;
}) {
  const [open, setOpen] = useState(false);

  return (
    <>
      <button type="button" className={className} onClick={() => setOpen(true)}>Edit</button>
      {open ? (
        <LoanForm members={members} products={products} loan={loan} onClose={() => setOpen(false)} />
      ) : null}
    </>
  );
}
