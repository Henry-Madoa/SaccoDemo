'use client';

import { Fragment, useState } from 'react';
import { FormModal } from '@/components/ui/form-modal';
import { Field } from '@/components/ui/field';
import { saveTransactionCharge } from '@/app/actions/charges';
import {
  TariffMatrix, emptyBand, bandFromScheme, bandToDraft, schemeSummary, type SchemeBandRow,
} from '@/components/admin/tariff-matrix';
import type { TransactionChargeSetupDraft, TransactionCalcSchemeDraft } from '@/lib/charges';
import {
  CHARGE_TRANSACTION_TYPES, CHARGE_CALCULATION_TYPES, PRODUCT_STATUSES,
} from '@/lib/constants';
import type { Charge, ChargeCalculationType, GlAccount, TransactionChargeWithDetail } from '@/lib/types';

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

export function TransactionChargeFormButton({ transactionCharge, charges, accounts, className = 'btn', children }: {
  transactionCharge?: TransactionChargeWithDetail | null;
  /** The reusable charge codes (Admin Centre → Charges → Charge Codes) this component list
   *  picks from. */
  charges: Charge[];
  /** Postable G/L accounts a component may post to. */
  accounts: GlAccount[];
  className?: string;
  children: React.ReactNode;
}) {
  const [open, setOpen] = useState(false);
  const tc = transactionCharge ?? null;
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

  return (
    <>
      <button type="button" className={className} onClick={() => setOpen(true)}>{children}</button>
      {open ? (
        <FormModal
          wide
          title={tc ? `Edit ${tc.code}` : 'Add a transaction charge'}
          onClose={() => setOpen(false)}
          onSubmit={(values) => saveTransactionCharge(tc ? tc.id : null, values, toDrafts())}
          submitLabel="Save"
          successTitle="Transaction charge saved"
        >
          <div className="grid g3">
            <Field name="code" label="Code" required placeholder="e.g. REACTIVATION"
              defaultValue={tc?.code} disabled={!!tc} uppercase />
            <Field name="description" label="Description" required defaultValue={tc?.description} />
            <Field name="transaction_type" label="Transaction type" type="select" required
              options={CHARGE_TRANSACTION_TYPES} defaultValue={tc?.transaction_type} />
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
                          {charges.map((c) => <option key={c.id} value={c.id}>{c.code}</option>)}
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
        </FormModal>
      ) : null}
    </>
  );
}
