'use client';

import { Fragment, useState, type ReactNode } from 'react';
import { FormModal } from '@/components/ui/form-modal';
import { Field } from '@/components/ui/field';
import {
  TariffMatrix, emptyBand, bandFromScheme, bandToDraft, schemeSummary, type SchemeBandRow,
} from '@/components/admin/tariff-matrix';
import { saveSavingsProduct, saveLoanProduct } from '@/app/actions/admin';
import type { LoanProductChargeDraft } from '@/lib/loanProductCharges';
import {
  SAVINGS_CATEGORIES, PRODUCT_STATUSES, INTEREST_METHODS, LOAN_CHARGE_CALCULATION_TYPES, SALARY_APPRAISAL_TYPES,
} from '@/lib/constants';
import { toUnits } from '@/lib/format';
import type {
  Charge, GlAccount, LoanChargeCalculationType, LoanProductChargeDetail, LoanProductWithUsage,
  SavingsProductWithUsage,
} from '@/lib/types';

/** GL accounts as <select> options — every product must map to a postable account. */
const accountOptions = (accounts: GlAccount[]) =>
  accounts.map((a) => ({ value: a.id, label: `${a.code} — ${a.name}` }));

/** One Loan Product Charges row — a Charge Code, a Revenue account, a Calculation Method
 *  (Percentage or Calculate from Scheme), whether it prorates by term, and posting priority. */
interface LoanChargeRow {
  charge_id: number | '';
  gl_account_id: number | '';
  calculation_type: LoanChargeCalculationType;
  percentage_rate_sh: string;
  prorate: boolean;
  priority: number;
  status: 'ACTIVE' | 'INACTIVE';
  scheme: SchemeBandRow[];
}

const emptyChargeRow = (priority: number): LoanChargeRow => ({
  charge_id: '', gl_account_id: '', calculation_type: 'PERCENTAGE', percentage_rate_sh: '0',
  prorate: false, priority, status: 'ACTIVE', scheme: [emptyBand()],
});

export function SavingsProductButton({ product, accounts, className = 'btn', children }: {
  product?: SavingsProductWithUsage | null;
  accounts: GlAccount[];
  className?: string;
  children: ReactNode;
}) {
  const [open, setOpen] = useState(false);
  const p = product ?? null;

  return (
    <>
      <button type="button" className={className} onClick={() => setOpen(true)}>{children}</button>
      {open ? (
        <FormModal
          wide
          title={p ? `Edit ${p.name}` : 'New savings product'}
          onClose={() => setOpen(false)}
          onSubmit={(values) => saveSavingsProduct(p ? p.id : null, values)}
          submitLabel="Save product"
          successTitle="Product saved"
        >
          <div className="grid g3">
            <Field name="code" label="Product code" defaultValue={p?.code} required disabled={!!p} />
            <Field name="name" label="Product name" defaultValue={p?.name} required />
            <Field name="category" label="Category" type="select"
              defaultValue={p?.category} options={SAVINGS_CATEGORIES} />
            <Field name="interest_rate" label="Interest rate (% p.a.)" type="number" step="0.01"
              defaultValue={p ? p.interest_rate : 0} />
            <Field name="min_opening_sh" label="Minimum opening deposit" type="number" step="0.01"
              defaultValue={p ? toUnits(p.min_opening) : 0} />
            <Field name="min_balance_sh" label="Minimum balance" type="number" step="0.01"
              defaultValue={p ? toUnits(p.min_balance) : 0} />
            <Field name="withdrawal_fee_sh" label="Withdrawal charge" type="number" step="0.01"
              defaultValue={p ? toUnits(p.withdrawal_fee) : 0} />
            <Field name="withdrawal_notice_days" label="Notice period (days)" type="number"
              defaultValue={p ? p.withdrawal_notice_days : 0} />
            <Field name="status" label="Status" type="select"
              defaultValue={p?.status} options={PRODUCT_STATUSES} />
          </div>
          <Field name="allow_withdrawal" label="Withdrawals permitted" type="checkbox"
            defaultValue={p ? p.allow_withdrawal : 1} />
          <Field name="is_loanable_base" label="Counts toward the loan deposit multiplier" type="checkbox"
            defaultValue={p ? p.is_loanable_base : 0} />
          <Field name="is_business_account" label="Business account — collects business details when opened" type="checkbox"
            defaultValue={p ? p.is_business_account : 0} />
          <div className="grid g3">
            <Field name="gl_control_id" label="GL control account" type="select" required
              defaultValue={p?.gl_control_id} options={accountOptions(accounts)} />
            <Field name="gl_interest_exp_id" label="Interest expense account" type="select"
              defaultValue={p?.gl_interest_exp_id} options={accountOptions(accounts)} />
            <Field name="gl_fee_income_id" label="Fee income account" type="select"
              defaultValue={p?.gl_fee_income_id} options={accountOptions(accounts)} />
          </div>
        </FormModal>
      ) : null}
    </>
  );
}

export function LoanProductButton({ product, chargeLines, charges, accounts, className = 'btn', children }: {
  product?: LoanProductWithUsage | null;
  /** This product's own Loan Product Charges lines, if any — omitted for a brand-new product. */
  chargeLines?: LoanProductChargeDetail[];
  /** The reusable charge codes (Admin Centre → Charges → Charge Codes) each line picks from. */
  charges: Charge[];
  accounts: GlAccount[];
  className?: string;
  children: ReactNode;
}) {
  const [open, setOpen] = useState(false);
  const p = product ?? null;
  const [salaryBased, setSalaryBased] = useState(!!Number(p?.salary_based ?? 0));
  const [chargeRows, setChargeRows] = useState<LoanChargeRow[]>(() => (chargeLines ?? []).map((l) => ({
    charge_id: l.charge_id, gl_account_id: l.gl_account_id, calculation_type: l.calculation_type,
    percentage_rate_sh: String(l.percentage_rate), prorate: l.prorate, priority: l.priority, status: l.status,
    scheme: l.scheme.length ? l.scheme.map(bandFromScheme) : [emptyBand()],
  })));
  // Which charge line's Tariff Matrix is currently expanded — at most one at a time, same as
  // Transaction Charges' own component table.
  const [expandedCharge, setExpandedCharge] = useState<number | null>(null);

  const updateCharge = (i: number, patch: Partial<LoanChargeRow>) =>
    setChargeRows((cur) => cur.map((r, k) => (k === i ? { ...r, ...patch } : r)));
  const removeCharge = (i: number) => {
    setChargeRows((cur) => cur.filter((_, k) => k !== i));
    setExpandedCharge((cur) => (cur === i ? null : cur));
  };
  const updateChargeScheme = (i: number, scheme: SchemeBandRow[]) =>
    setChargeRows((cur) => cur.map((r, k) => (k === i ? { ...r, scheme } : r)));

  const chargeDrafts = (): LoanProductChargeDraft[] => chargeRows.map((r) => ({
    charge_id: Number(r.charge_id) || 0,
    gl_account_id: Number(r.gl_account_id) || 0,
    calculation_type: r.calculation_type,
    percentage_rate: r.calculation_type === 'PERCENTAGE' ? Number(r.percentage_rate_sh) || 0 : 0,
    prorate: r.prorate,
    priority: r.priority,
    status: r.status,
    scheme: r.calculation_type === 'SCHEME' ? r.scheme.map(bandToDraft) : [],
  }));

  return (
    <>
      <button type="button" className={className} onClick={() => setOpen(true)}>{children}</button>
      {open ? (
        <FormModal
          wide
          title={p ? `Edit ${p.name}` : 'New loan product'}
          onClose={() => setOpen(false)}
          onSubmit={(values) => saveLoanProduct(p ? p.id : null, values, chargeDrafts())}
          submitLabel="Save product"
          successTitle="Product saved"
        >
          <div className="grid g3">
            <Field name="code" label="Product code" defaultValue={p?.code} required disabled={!!p} />
            <Field name="name" label="Product name" defaultValue={p?.name} required />
            <Field name="status" label="Status" type="select"
              defaultValue={p?.status} options={PRODUCT_STATUSES} />
            <Field name="interest_rate" label="Interest rate (% p.a.)" type="number" step="0.01"
              defaultValue={p ? p.interest_rate : 12} />
            <Field name="interest_method" label="Interest method" type="select"
              defaultValue={p?.interest_method} options={INTEREST_METHODS} />
            <Field name="max_term_months" label="Maximum term (months)" type="number"
              defaultValue={p ? p.max_term_months : 48} />
            <Field name="min_amount_sh" label="Minimum amount" type="number" step="0.01"
              defaultValue={p ? toUnits(p.min_amount) : 0} />
            <Field name="max_amount_sh" label="Maximum amount" type="number" step="0.01"
              defaultValue={p ? toUnits(p.max_amount) : 0} />
            <Field name="deposit_multiplier" label="Deposit multiplier" type="number" step="0.1"
              defaultValue={p ? p.deposit_multiplier : 3} />
            <Field name="min_membership_months" label="Minimum membership (months)" type="number"
              defaultValue={p ? p.min_membership_months : 6} />
            <Field name="guarantors_required" label="Guarantors required" type="number"
              defaultValue={p ? p.guarantors_required : 2} />
            <Field name="max_dsr_pct" label="Maximum deduction ratio (%)" type="number" step="0.1"
              defaultValue={p ? p.max_dsr_pct : 66.7}
              hint="Checked against processed payroll for a Salary based product, or the Salary Appraisal card for any other" />
            <Field name="penalty_rate" label="Penalty rate (% per month)" type="number" step="0.01"
              defaultValue={p ? p.penalty_rate : 1} />
            <Field name="repayment_cutoff_date" label="Repayment cutoff date (day of month)" type="number" min={0}
              defaultValue={p ? p.repayment_cutoff_date : 0}
              hint="Before this day, the first instalment falls due at month-end; on or after it, a further month out. 0 = no cutoff." />
          </div>
          <Field
            name="salary_based" type="checkbox" defaultValue={p ? p.salary_based : 0}
            onChange={(e) => setSalaryBased((e.target as HTMLInputElement).checked)}
            label="Salary based — affordability is checked against actually-processed payroll (Checkoff & Salary Processing) instead of the manual Salary Appraisal card. Only turn this on for a product whose members are paid through this SACCO's own payroll processing."
          />
          {/* Kept mounted (display:none, not unmounted) while off, so an already-saved value here
              survives toggling Salary based off and back on without this uncontrolled form
              losing it on submit. */}
          <div className="grid g2" style={!salaryBased ? { display: 'none' } : undefined}>
            <Field name="min_salary_count" label="Min. processed salaries required" type="number" min={1}
              defaultValue={p ? p.min_salary_count : 1}
              hint="Months of processed payroll required before affordability can be assessed" />
            <Field name="salary_appraisal_type" label="Salary appraisal method" type="select"
              defaultValue={p?.salary_appraisal_type ?? 'AVERAGE_NET'} options={SALARY_APPRAISAL_TYPES}
              hint="How processed salary history reduces to the one figure checked against the deduction ratio" />
          </div>

          <h4 className="section-title">Loan product charges</h4>
          <div className="card-sub">
            The Loan Products charge computation module — one loan product, many charges. Each
            line draws its Charge Code from the Charges master and posts to its own Revenue
            account. Calculation Method is either a flat Percentage of the amount applied for, or
            Calculate from Scheme — a tariff table banded by principal. Prorate scales the
            resolved amount by the repayment term ÷ 12 months, for a charge priced as an annual
            rate but billed once at disbursement (e.g. insurance) rather than levied in full
            regardless of term. A product with no charges configured here has no disbursement
            charges at all.
          </div>
          <div style={{ overflowX: 'auto', marginTop: 8 }}>
            <table>
              <thead>
                <tr>
                  <th>Charge</th><th>Revenue account</th><th>Calculation method</th><th>Rate / Tariff</th>
                  <th style={{ width: 60 }}>Prorate</th><th style={{ width: 60 }}>Priority</th><th style={{ width: 40 }} />
                </tr>
              </thead>
              <tbody>
                {chargeRows.map((row, i) => (
                  <Fragment key={i}>
                    <tr>
                      <td>
                        <select value={row.charge_id} aria-label="Charge"
                          onChange={(e) => updateCharge(i, { charge_id: e.target.value ? Number(e.target.value) : '' })}>
                          <option value="">Select…</option>
                          {charges.map((c) => <option key={c.id} value={c.id}>{c.code}</option>)}
                        </select>
                      </td>
                      <td>
                        <select value={row.gl_account_id} aria-label="Revenue account"
                          onChange={(e) => updateCharge(i, { gl_account_id: e.target.value ? Number(e.target.value) : '' })}>
                          <option value="">Select…</option>
                          {accounts.map((a) => <option key={a.id} value={a.id}>{a.code} — {a.name}</option>)}
                        </select>
                      </td>
                      <td>
                        <select value={row.calculation_type} aria-label="Calculation method"
                          onChange={(e) => updateCharge(i, { calculation_type: e.target.value as LoanChargeCalculationType })}>
                          {LOAN_CHARGE_CALCULATION_TYPES.map((t) => <option key={t.value} value={t.value}>{t.label}</option>)}
                        </select>
                      </td>
                      <td>
                        {row.calculation_type === 'PERCENTAGE' ? (
                          <>
                            <input type="number" step="0.01" value={row.percentage_rate_sh} aria-label="Percentage rate"
                              style={{ width: 80 }}
                              onChange={(e) => updateCharge(i, { percentage_rate_sh: e.target.value })} />
                            <span className="tiny">%</span>
                          </>
                        ) : (
                          <button type="button" className="btn sm ghost" aria-expanded={expandedCharge === i}
                            onClick={() => setExpandedCharge((cur) => (cur === i ? null : i))}>
                            {expandedCharge === i ? '▾' : '▸'} {schemeSummary(row.scheme)}
                          </button>
                        )}
                      </td>
                      <td style={{ textAlign: 'center' }}>
                        <input type="checkbox" checked={row.prorate} aria-label="Prorate by term"
                          onChange={(e) => updateCharge(i, { prorate: e.target.checked })} />
                      </td>
                      <td>
                        <input type="number" min={1} value={row.priority} aria-label="Priority" style={{ width: 56 }}
                          onChange={(e) => updateCharge(i, { priority: Number(e.target.value) || 1 })} />
                      </td>
                      <td>
                        <button type="button" className="btn sm ghost" onClick={() => removeCharge(i)} aria-label="Remove charge">×</button>
                      </td>
                    </tr>
                    {row.calculation_type === 'SCHEME' && expandedCharge === i ? (
                      <tr key={`${i}-scheme`}>
                        <td colSpan={7} style={{ background: 'var(--surface-2)', padding: '10px 10px 14px 30px' }}>
                          <TariffMatrix bands={row.scheme} baseLabel="the loan principal"
                            onChange={(next) => updateChargeScheme(i, next)} />
                        </td>
                      </tr>
                    ) : null}
                  </Fragment>
                ))}
                {!chargeRows.length ? (
                  <tr>
                    <td colSpan={7} className="tiny">
                      No charges configured — this product has no disbursement charges.
                    </td>
                  </tr>
                ) : null}
              </tbody>
            </table>
          </div>
          <div className="inline" style={{ marginTop: 10 }}>
            <button
              type="button" className="btn ghost sm"
              onClick={() => setChargeRows((cur) => {
                const next = [...cur, emptyChargeRow(cur.length + 1)];
                setExpandedCharge(null);
                return next;
              })}
            >
              Add charge
            </button>
          </div>

          <div className="grid g2" style={{ marginTop: 'calc(var(--sp)*2)' }}>
            <Field name="gl_receivable_id" label="Loan receivable account" type="select" required
              defaultValue={p?.gl_receivable_id} options={accountOptions(accounts)} />
            <Field name="gl_interest_income_id" label="Interest income account" type="select"
              defaultValue={p?.gl_interest_income_id} options={accountOptions(accounts)} />
            <Field name="gl_penalty_income_id" label="Penalty income account" type="select"
              defaultValue={p?.gl_penalty_income_id} options={accountOptions(accounts)} />
          </div>
        </FormModal>
      ) : null}
    </>
  );
}
