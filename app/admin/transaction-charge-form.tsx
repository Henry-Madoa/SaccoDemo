'use client';

import { Fragment, useEffect, useState } from 'react';
import { FormModal } from '@/components/ui/form-modal';
import { Field } from '@/components/ui/field';
import { saveTransactionCharge } from '@/app/actions/charges';
import { listStandingOrderStoTypes } from '@/app/actions/standingOrders';
import {
  TariffMatrix, emptyBand, bandFromScheme, bandToDraft, schemeSummary, type SchemeBandRow,
} from '@/components/admin/tariff-matrix';
import type { TransactionChargeSetupDraft, TransactionCalcSchemeDraft, TransactionRecoveryDraft } from '@/lib/charges';
import {
  CHARGE_TRANSACTION_TYPES, CHARGE_CALCULATION_TYPES, PRODUCT_STATUSES, STANDING_ORDER_CLASSES,
  TRANSACTION_RECOVERY_TYPES, LOAN_DEDUCTION_TYPES, INTERNAL_DEPOSIT_DEDUCTION_TYPES,
} from '@/lib/constants';
import type {
  Charge, ChargeCalculationType, ChargeTransactionType, GlAccount, SavingsProduct, StandingOrderClass,
  TransactionChargeWithDetail, TransactionRecoveryDeductionType, TransactionRecoveryType,
} from '@/lib/types';

/** Only this transaction type actually runs a recovery waterfall (Checkoff & Salary
 *  Processing's Calculate step) — see lib/charges.ts's RECOVERY_ELIGIBLE_TYPE. */
const RECOVERY_ELIGIBLE_TYPE: ChargeTransactionType = 'End Month Salary';

interface RecoveryRow {
  recovery_type: TransactionRecoveryType;
  deduction_type: TransactionRecoveryDeductionType | '';
  savings_product_id: number | '';
  sto_type: string;
  /** '' = any class. */
  standing_order_class: StandingOrderClass | '';
  priority: number;
  description: string;
  status: 'ACTIVE' | 'INACTIVE';
}

const emptyRecoveryRow = (priority: number): RecoveryRow => ({
  recovery_type: 'LOAN', deduction_type: 'INSTALLMENT', savings_product_id: '', sto_type: '', standing_order_class: '',
  priority, description: '', status: 'ACTIVE',
});

interface ComponentRow {
  charge_id: number | '';
  gl_account_id: number | '';
  calculation_type: ChargeCalculationType;
  /** Index of another row in this same table — resolved to a real setup id server-side. */
  source_index: number | '';
  priority: number;
  status: 'ACTIVE' | 'INACTIVE';
  scheme: SchemeBandRow[];
}

const emptyRow = (priority: number): ComponentRow => ({
  charge_id: '', gl_account_id: '', calculation_type: 'SCHEME', source_index: '', priority, status: 'ACTIVE',
  scheme: [emptyBand()],
});

export function TransactionChargeFormButton({
  transactionCharge, charges, accounts, savingsProducts = [], className = 'btn', children,
}: {
  transactionCharge?: TransactionChargeWithDetail | null;
  /** The reusable charge codes (Admin Centre → Charges → Charge Codes) this component list
   *  picks from. */
  charges: Charge[];
  /** Postable G/L accounts a component may post to. */
  accounts: GlAccount[];
  /** Internal Deposit recoveries' account picklist — only needed for RECOVERY_ELIGIBLE_TYPE. */
  savingsProducts?: SavingsProduct[];
  className?: string;
  children: React.ReactNode;
}) {
  const [open, setOpen] = useState(false);
  const tc = transactionCharge ?? null;
  const [transactionType, setTransactionType] = useState<ChargeTransactionType>(
    tc?.transaction_type ?? CHARGE_TRANSACTION_TYPES[0].value,
  );
  const [rows, setRows] = useState<ComponentRow[]>(() => {
    if (!tc) return [];
    // Resolve each PERCENT_OF_CHARGE component's source_setup_id back to this array's own
    // index — the id doesn't exist yet for a brand-new row, so the draft always speaks in
    // indexes; loading an existing charge has to translate the other way once.
    const idToIndex = new Map(tc.components.map((c, i) => [c.id, i]));
    return tc.components.map((c) => ({
      charge_id: c.charge_id, gl_account_id: c.gl_account_id, calculation_type: c.calculation_type,
      source_index: c.source_setup_id != null ? idToIndex.get(c.source_setup_id) ?? '' : '',
      priority: c.priority, status: c.status,
      scheme: c.scheme.length ? c.scheme.map(bandFromScheme) : [emptyBand()],
    }));
  });
  const [recoveryRows, setRecoveryRows] = useState<RecoveryRow[]>(() => (tc?.recoveries ?? []).map((r) => ({
    recovery_type: r.recovery_type, deduction_type: r.deduction_type ?? '',
    savings_product_id: r.savings_product_id ?? '', sto_type: r.sto_type ?? '',
    standing_order_class: r.standing_order_class ?? '', priority: r.priority,
    description: r.description ?? '', status: r.status,
  })));
  const [stoTypes, setStoTypes] = useState<string[]>([]);
  useEffect(() => {
    listStandingOrderStoTypes().then((res) => { if (res.ok) setStoTypes(res.data); });
  }, []);
  // Which component's Tariff Matrix is currently expanded — at most one at a time keeps the
  // already-tall components table from growing unmanageably.
  const [expanded, setExpanded] = useState<number | null>(null);

  const update = (i: number, patch: Partial<ComponentRow>) =>
    setRows((cur) => cur.map((r, k) => (k === i ? { ...r, ...patch } : r)));
  const remove = (i: number) => {
    setRows((cur) => cur.filter((_, k) => k !== i));
    setExpanded((cur) => (cur === i ? null : cur));
  };

  const updateScheme = (rowIndex: number, scheme: SchemeBandRow[]) =>
    setRows((cur) => cur.map((r, k) => (k === rowIndex ? { ...r, scheme } : r)));

  const toDrafts = (): TransactionChargeSetupDraft[] => rows.map((r) => ({
    charge_id: Number(r.charge_id) || 0,
    gl_account_id: Number(r.gl_account_id) || 0,
    calculation_type: r.calculation_type,
    source_index: r.calculation_type === 'PERCENT_OF_CHARGE' && r.source_index !== '' ? Number(r.source_index) : null,
    priority: r.priority,
    status: r.status,
    scheme: r.scheme.map((b): TransactionCalcSchemeDraft => bandToDraft(b)),
  }));

  const updateRecovery = (i: number, patch: Partial<RecoveryRow>) =>
    setRecoveryRows((cur) => cur.map((r, k) => (k === i ? { ...r, ...patch } : r)));
  const removeRecovery = (i: number) => setRecoveryRows((cur) => cur.filter((_, k) => k !== i));

  const toRecoveryDrafts = (): TransactionRecoveryDraft[] => recoveryRows.map((r) => ({
    recovery_type: r.recovery_type,
    deduction_type: r.recovery_type === 'STANDING_ORDER' ? null : (r.deduction_type || null),
    savings_product_id: r.recovery_type === 'INTERNAL_DEPOSIT' ? (Number(r.savings_product_id) || null) : null,
    sto_type: r.recovery_type === 'STANDING_ORDER' ? (r.sto_type.trim() || null) : null,
    standing_order_class: r.recovery_type === 'STANDING_ORDER' ? (r.standing_order_class || null) : null,
    priority: r.priority,
    description: r.description.trim() || null,
    status: r.status,
  }));

  const showRecoveries = transactionType === RECOVERY_ELIGIBLE_TYPE;

  return (
    <>
      <button type="button" className={className} onClick={() => setOpen(true)}>{children}</button>
      {open ? (
        <FormModal
          wide
          title={tc ? `Edit ${tc.code}` : 'Add a transaction charge'}
          onClose={() => setOpen(false)}
          onSubmit={(values) => saveTransactionCharge(tc ? tc.id : null, values, toDrafts(), toRecoveryDrafts())}
          submitLabel="Save"
          successTitle="Transaction charge saved"
        >
          <div className="grid g3">
            <Field name="code" label="Code" required placeholder="e.g. REACTIVATION"
              defaultValue={tc?.code} disabled={!!tc} uppercase />
            <Field name="description" label="Description" required defaultValue={tc?.description} />
            <Field name="transaction_type" label="Transaction type" type="select" required
              options={CHARGE_TRANSACTION_TYPES} defaultValue={tc?.transaction_type}
              onChange={(e) => setTransactionType(e.target.value as ChargeTransactionType)} />
          </div>
          {tc ? (
            <Field name="status" label="Status" type="select" options={PRODUCT_STATUSES} defaultValue={tc.status} />
          ) : null}

          <h4 className="section-title">Charge components</h4>
          <div className="card-sub">
            Processed in Priority order. A Percentage of Charge component is calculated against
            another component's already-resolved amount instead of the transaction's own base amount.
            Each component's own Tariff Matrix (its Calculation Scheme) decides the actual rate.
          </div>
          <div style={{ overflowX: 'auto', marginTop: 8 }}>
            <table>
              <thead>
                <tr>
                  <th>Charge</th><th>Post to account</th><th>Calc. type</th><th>Source</th>
                  <th style={{ width: 60 }}>Priority</th><th>Tariff matrix</th><th style={{ width: 40 }} />
                </tr>
              </thead>
              <tbody>
                {rows.map((row, i) => (
                  <Fragment key={i}>
                    <tr>
                      <td>
                        <select value={row.charge_id} aria-label="Charge"
                          onChange={(e) => update(i, { charge_id: e.target.value ? Number(e.target.value) : '' })}>
                          <option value="">Select…</option>
                          {charges.map((c) => <option key={c.id} value={c.id}>{c.code} — {c.description}</option>)}
                        </select>
                      </td>
                      <td>
                        <select value={row.gl_account_id} aria-label="Post to account"
                          onChange={(e) => update(i, { gl_account_id: e.target.value ? Number(e.target.value) : '' })}>
                          <option value="">Select…</option>
                          {accounts.map((a) => <option key={a.id} value={a.id}>{a.code} — {a.name}</option>)}
                        </select>
                      </td>
                      <td>
                        <select value={row.calculation_type} aria-label="Calculation type"
                          onChange={(e) => update(i, { calculation_type: e.target.value as ChargeCalculationType, source_index: '' })}>
                          {CHARGE_CALCULATION_TYPES.map((t) => <option key={t.value} value={t.value}>{t.label}</option>)}
                        </select>
                      </td>
                      <td>
                        {row.calculation_type === 'PERCENT_OF_CHARGE' ? (
                          <select value={row.source_index} aria-label="Source component"
                            onChange={(e) => update(i, { source_index: e.target.value ? Number(e.target.value) : '' })}>
                            <option value="">Select…</option>
                            {rows.map((r, k) => (
                              k === i || !r.charge_id ? null : (
                                <option key={k} value={k}>
                                  {charges.find((c) => c.id === r.charge_id)?.code ?? `Row ${k + 1}`}
                                </option>
                              )
                            ))}
                          </select>
                        ) : <span className="tiny">—</span>}
                      </td>
                      <td>
                        <input type="number" min={1} value={row.priority} aria-label="Priority" style={{ width: 56 }}
                          onChange={(e) => update(i, { priority: Number(e.target.value) || 1 })} />
                      </td>
                      <td>
                        <button type="button" className="btn sm ghost" aria-expanded={expanded === i}
                          onClick={() => setExpanded((cur) => (cur === i ? null : i))}>
                          {expanded === i ? '▾' : '▸'} {schemeSummary(row.scheme)}
                        </button>
                      </td>
                      <td>
                        <button type="button" className="btn sm ghost" onClick={() => remove(i)} aria-label="Remove component">×</button>
                      </td>
                    </tr>
                    {expanded === i ? (
                      <tr key={`${i}-scheme`}>
                        <td colSpan={7} style={{ background: 'var(--surface-2)', padding: '10px 10px 14px 30px' }}>
                          <TariffMatrix
                            bands={row.scheme}
                            baseLabel={row.calculation_type === 'PERCENT_OF_CHARGE'
                              ? "the source component's resolved amount" : "the transaction's base amount"}
                            hint="For a flat amount per unit of base amount (e.g. a per-page statement fee), use a Percentage band and check the preview under the Rate field rather than guessing the rate."
                            onChange={(next) => updateScheme(i, next)}
                          />
                        </td>
                      </tr>
                    ) : null}
                  </Fragment>
                ))}
                {!rows.length ? (
                  <tr><td colSpan={7} className="tiny">No components yet — this charge won't calculate anything.</td></tr>
                ) : null}
              </tbody>
            </table>
          </div>
          <div className="inline" style={{ marginTop: 10 }}>
            <button
              type="button" className="btn ghost sm"
              onClick={() => setRows((cur) => {
                const next = [...cur, emptyRow(cur.length + 1)];
                setExpanded(next.length - 1);
                return next;
              })}
            >
              Add component
            </button>
          </div>

          {showRecoveries ? (
            <>
              <h4 className="section-title">Transaction recoveries</h4>
              <div className="card-sub">
                Runs in Priority order, after charge components, against whatever remains of the
                amount remitted for a member on a salary-processing batch. A Loan recovery pays
                down the member's own payroll-deducted loans; a Standing Order recovery pays a
                member's own salary-based standing order(s) tagged with the given type (see
                Standing Orders — Salary based) — leave its class as "Any class" to match every
                one of that type regardless of class, or pin it to Internal/External/Loan and add
                a separate row per class to give each its own priority; an Internal Deposit
                recovery sweeps or tops up one of their savings accounts. Used by Checkoff &amp;
                Salary Processing's Calculate step.
              </div>
              <div style={{ overflowX: 'auto', marginTop: 8 }}>
                <table>
                  <thead>
                    <tr>
                      <th>Recovery type</th><th>Detail</th>
                      <th style={{ width: 60 }}>Priority</th><th>Description</th><th style={{ width: 40 }} />
                    </tr>
                  </thead>
                  <tbody>
                    {recoveryRows.map((row, i) => (
                      <tr key={i}>
                        <td>
                          <select value={row.recovery_type} aria-label="Recovery type"
                            onChange={(e) => {
                              const nextType = e.target.value as TransactionRecoveryType;
                              updateRecovery(i, {
                                recovery_type: nextType,
                                deduction_type: nextType === 'LOAN' ? 'INSTALLMENT' : nextType === 'INTERNAL_DEPOSIT' ? 'FULL_REMAINING' : '',
                                savings_product_id: '', sto_type: '',
                              });
                            }}>
                            {TRANSACTION_RECOVERY_TYPES.map((t) => <option key={t.value} value={t.value}>{t.label}</option>)}
                          </select>
                        </td>
                        <td>
                          {row.recovery_type === 'STANDING_ORDER' ? (
                            <div className="inline" style={{ gap: 6 }}>
                              <input type="text" list="sto-type-options" value={row.sto_type} aria-label="Standing order type"
                                placeholder="Standing order type" style={{ width: 130 }}
                                onChange={(e) => updateRecovery(i, { sto_type: e.target.value })} />
                              <datalist id="sto-type-options">
                                {stoTypes.map((t) => <option key={t} value={t} />)}
                              </datalist>
                              <select value={row.standing_order_class} aria-label="Standing order class"
                                onChange={(e) => updateRecovery(i, { standing_order_class: e.target.value as StandingOrderClass | '' })}>
                                <option value="">Any class</option>
                                {STANDING_ORDER_CLASSES.map((c) => <option key={c.value} value={c.value}>{c.label}</option>)}
                              </select>
                            </div>
                          ) : (
                            <div className="inline" style={{ gap: 6 }}>
                              <select value={row.deduction_type} aria-label="Deduction type"
                                onChange={(e) => updateRecovery(i, { deduction_type: e.target.value as TransactionRecoveryDeductionType })}>
                                {(row.recovery_type === 'LOAN' ? LOAN_DEDUCTION_TYPES : INTERNAL_DEPOSIT_DEDUCTION_TYPES)
                                  .map((t) => <option key={t.value} value={t.value}>{t.label}</option>)}
                              </select>
                              {row.recovery_type === 'INTERNAL_DEPOSIT' ? (
                                <select value={row.savings_product_id} aria-label="Savings product"
                                  onChange={(e) => updateRecovery(i, { savings_product_id: e.target.value ? Number(e.target.value) : '' })}>
                                  <option value="">Select product…</option>
                                  {savingsProducts.map((p) => <option key={p.id} value={p.id}>{p.code} — {p.name}</option>)}
                                </select>
                              ) : null}
                            </div>
                          )}
                        </td>
                        <td>
                          <input type="number" min={1} value={row.priority} aria-label="Priority" style={{ width: 56 }}
                            onChange={(e) => updateRecovery(i, { priority: Number(e.target.value) || 1 })} />
                        </td>
                        <td>
                          <input type="text" value={row.description} aria-label="Description" style={{ width: 160 }}
                            onChange={(e) => updateRecovery(i, { description: e.target.value })} />
                        </td>
                        <td>
                          <button type="button" className="btn sm ghost" onClick={() => removeRecovery(i)} aria-label="Remove recovery">×</button>
                        </td>
                      </tr>
                    ))}
                    {!recoveryRows.length ? (
                      <tr><td colSpan={5} className="tiny">No recoveries configured — Calculate will only apply the charge components above.</td></tr>
                    ) : null}
                  </tbody>
                </table>
              </div>
              <div className="inline" style={{ marginTop: 10 }}>
                <button type="button" className="btn ghost sm"
                  onClick={() => setRecoveryRows((cur) => [...cur, emptyRecoveryRow(cur.length + 1)])}>
                  Add recovery
                </button>
              </div>
            </>
          ) : null}
        </FormModal>
      ) : null}
    </>
  );
}
