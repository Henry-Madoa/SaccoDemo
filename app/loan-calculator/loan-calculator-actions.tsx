'use client';

import { useEffect, useState } from 'react';
import { useRouter } from 'next/navigation';
import { FormModal } from '@/components/ui/form-modal';
import { MoneyInput } from '@/components/ui/field';
import { MemberSelect } from '@/components/ui/member-select';
import { SearchableSelect } from '@/components/ui/searchable-select';
import { Card, CardHead, TableWrap } from '@/components/ui/primitives';
import { Money } from '@/components/ui/money';
import { useRunAction } from '@/components/ui/run-action';
import { useFormat } from '@/components/ui/format-provider';
import {
  saveLoanCalculation, deleteLoanCalculation, convertLoanCalculation, previewLoanCalculation,
} from '@/app/actions/loanCalculator';
import { LOAN_CALCULATOR_RATE_TYPE_FOR_METHOD, LOAN_CALCULATOR_RATE_TYPES } from '@/lib/constants';
import { addMonths } from '@/lib/loans';
import { today } from '@/lib/format';
import type { LoanCalculatorPreview } from '@/lib/loanCalculator';
import type { LoanCalculatorRateType, LoanProductWithCharges, Member } from '@/lib/types';

export function DeleteButton({ calcNo, className = 'btn sm ghost' }: { calcNo: string; className?: string }) {
  const { run, busy } = useRunAction();
  return (
    <button type="button" className={className} disabled={busy}
      onClick={() => run(() => deleteLoanCalculation(calcNo), {
        confirm: {
          title: 'Delete this calculation?',
          message: 'This cannot be undone.',
          confirmLabel: 'Delete',
        },
        successTitle: 'Deleted',
      })}>
      {busy ? 'Working…' : 'Delete'}
    </button>
  );
}

/** Converts an Open calculation into a real loan application (Loans page, status Open) — a
 *  one-way move, so this is gated behind a confirmation the same way PostButton's document
 *  posting is elsewhere in the app. */
export function ConvertButton({ calcNo, className = 'btn sm' }: { calcNo: string; className?: string }) {
  const { run, busy } = useRunAction();
  return (
    <button type="button" className={className} disabled={busy}
      onClick={() => run(() => convertLoanCalculation(calcNo), {
        confirm: {
          title: 'Convert to loan application?',
          message: 'This creates a new loan application for the member using this calculation\'s product, principal and term. The calculation becomes read-only once converted, and cannot be undone.',
          confirmLabel: 'Convert',
        },
        successTitle: (d) => `Converted to ${d.loanNo}`,
        successDetail: 'Open the new loan application to submit it for approval.',
      })}>
      {busy ? 'Working…' : 'Convert to loan'}
    </button>
  );
}

interface NewCalculationFormProps {
  members: Pick<Member, 'id' | 'member_no' | 'first_name' | 'last_name'>[];
  products: LoanProductWithCharges[];
  presetMemberId?: number | null;
  onClose: () => void;
}

function NewCalculationForm({ members, products, presetMemberId, onClose }: NewCalculationFormProps) {
  const { cur } = useFormat();
  const [memberId, setMemberId] = useState(String(presetMemberId ?? ''));
  const [productId, setProductId] = useState('');
  const [principal, setPrincipal] = useState('');
  const [termMonths, setTermMonths] = useState('');
  const [rateType, setRateType] = useState<LoanCalculatorRateType>('AMORTISED');
  const [repaymentStartDate, setRepaymentStartDate] = useState(addMonths(today(), 1));
  const [preview, setPreview] = useState<LoanCalculatorPreview | null>(null);
  const [previewError, setPreviewError] = useState('');

  const product = products.find((p) => String(p.id) === productId);

  // The Rate Type defaults from the chosen product's own Interest Method (Table 52204036's
  // "Rate Type" := SaccoProduct."Interest Repayment Method") but stays user-editable, since
  // comparing all three amortisation styles against the same principal is the point of this tool.
  useEffect(() => {
    if (product) setRateType(LOAN_CALCULATOR_RATE_TYPE_FOR_METHOD[product.interest_method]);
  }, [product]);

  useEffect(() => {
    let cancelled = false;
    const principalCents = Math.round(Number(principal || 0) * 100);
    const months = Number(termMonths || 0);
    if (!memberId || !productId || !(principalCents > 0) || !(months > 0) || !repaymentStartDate) {
      setPreview(null); setPreviewError('');
      return;
    }
    previewLoanCalculation(Number(memberId), Number(productId), principalCents, months, rateType, repaymentStartDate).then((res) => {
      if (cancelled) return;
      if (res.ok) { setPreview(res.data); setPreviewError(''); }
      else { setPreview(null); setPreviewError(res.error); }
    });
    return () => { cancelled = true; };
  }, [memberId, productId, principal, termMonths, rateType, repaymentStartDate]);

  return (
    <FormModal
      wide
      title="New loan calculation"
      onClose={onClose}
      onSubmit={saveLoanCalculation}
      submitLabel="Save calculation"
      successTitle="Calculation saved"
      successDetail={(d) => `${d.calcNo} saved`}
    >
      <div className="grid g2">
        <MemberSelect id="f_memberId" name="memberId" members={members} value={memberId}
          onChange={setMemberId} required />

        <SearchableSelect id="f_productId" name="productId" label="Loan product" required
          items={products} getValue={(p) => String(p.id)}
          getLabel={(p) => `${p.name} (${p.interest_rate}% ${p.interest_method.toLowerCase()})`}
          value={productId} onChange={setProductId}
          placeholder="Search loan product…" emptyText="No matching products" />

        <div className="field">
          <label htmlFor="f_principal">Principal amount <span className="req">*</span></label>
          <MoneyInput id="f_principal" name="principal" required disabled={!product}
            value={principal} onChange={setPrincipal} />
          <div className="hint">
            {product
              ? `${product.name} range: ${(product.min_amount / 100).toLocaleString()} – ${(product.max_amount / 100).toLocaleString()}`
              : 'Choose a loan product above first'}
          </div>
        </div>

        <div className="field">
          <label htmlFor="f_termMonths">Installments (months) <span className="req">*</span></label>
          <input id="f_termMonths" name="termMonths" type="number" required
            value={termMonths} disabled={!product} onChange={(e) => setTermMonths(e.target.value)} />
          <div className="hint">{product ? `Up to ${product.max_term_months} months` : ' '}</div>
        </div>

        <div className="field">
          <label htmlFor="f_rateType">Rate type <span className="req">*</span></label>
          <select id="f_rateType" name="rateType" required value={rateType}
            onChange={(e) => setRateType(e.target.value as LoanCalculatorRateType)}>
            {LOAN_CALCULATOR_RATE_TYPES.map((r) => <option key={r.value} value={r.value}>{r.label}</option>)}
          </select>
        </div>

        <div className="field">
          <label htmlFor="f_repaymentStartDate">Repayment start date <span className="req">*</span></label>
          <input id="f_repaymentStartDate" name="repaymentStartDate" type="date" required
            value={repaymentStartDate} onChange={(e) => setRepaymentStartDate(e.target.value)} />
        </div>
      </div>

      {previewError ? <div className="note neg" style={{ marginTop: 8 }}>{previewError}</div> : null}

      {preview ? (
        <>
          <Card className="inset">
            <CardHead title="Deposit appraisal" sub="Computed live from the member's loanable deposits and current exposure" />
            <div className="grid g4 stack-2">
              <div className="stat"><div className="label">Current deposits</div><div className="value">{cur(preview.currentDeposits)}</div></div>
              <div className="stat"><div className="label">Loan deposit multiplier</div><div className="value">{cur(preview.depositMultiplierAmount)}</div></div>
              <div className="stat"><div className="label">Outstanding loans</div><div className="value">{cur(preview.outstandingLoans)}</div></div>
              <div className="stat">
                <div className="label">Deposit appraisal</div>
                <div className={`value ${preview.depositAppraisal < 0 ? 'neg' : ''}`}>{cur(preview.depositAppraisal)}</div>
              </div>
            </div>
          </Card>

          <Card className="inset">
            <CardHead
              title="Projected schedule"
              sub={<>Interest rate {preview.interestRate}% · First installment <Money cents={preview.installment} /> · Total interest <Money cents={preview.totalInterest} /></>}
            />
            <div style={{ maxHeight: 260, overflowY: 'auto' }}>
              <TableWrap>
                <thead>
                  <tr><th>#</th><th>Due date</th><th className="num">Opening balance</th><th className="num">Principal</th><th className="num">Interest</th><th className="num">Installment</th></tr>
                </thead>
                <tbody>
                  {preview.rows.map((r) => (
                    <tr key={r.installment_no}>
                      <td>{r.installment_no}</td>
                      <td>{r.due_date}</td>
                      <td className="num"><Money cents={r.opening_balance} /></td>
                      <td className="num"><Money cents={r.principal_due} /></td>
                      <td className="num"><Money cents={r.interest_due} /></td>
                      <td className="num"><Money cents={r.principal_due + r.interest_due} /></td>
                    </tr>
                  ))}
                </tbody>
              </TableWrap>
            </div>
          </Card>
        </>
      ) : null}
    </FormModal>
  );
}

/** Opens the New Calculation form, optionally preset from `?new=<memberId>`. */
export function NewCalculationButton({ members, products, presetMemberId }: {
  members: NewCalculationFormProps['members'];
  products: LoanProductWithCharges[];
  presetMemberId?: number | null;
}) {
  const router = useRouter();
  const [open, setOpen] = useState(Boolean(presetMemberId));

  const close = () => {
    setOpen(false);
    if (presetMemberId) router.replace('/loan-calculator');
  };

  return (
    <>
      <button type="button" className="btn" onClick={() => setOpen(true)}>New calculation</button>
      {open ? (
        <NewCalculationForm members={members} products={products} presetMemberId={presetMemberId} onClose={close} />
      ) : null}
    </>
  );
}
