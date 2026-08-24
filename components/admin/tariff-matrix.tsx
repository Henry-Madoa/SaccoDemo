'use client';

import { useFormat } from '@/components/ui/format-provider';
import { CHARGE_RATE_TYPES } from '@/lib/constants';
import { toCents, toUnits } from '@/lib/format';
import type { Cents, ChargeRateType } from '@/lib/types';

/**
 * Shared "Tariff matrix" editor — one component's amount-banded rate table, the Calculation
 * Scheme lib/charges.ts's Transaction Charges use and Loan Product Charges' own Calculate from
 * Scheme lines (lib/loanProductCharges.ts) both configure the same way. Draft rows speak in Sh
 * strings for the inputs; bandToDraft() below converts a row back to the Cents-based scheme
 * shape both modules' save actions post.
 */
export interface SchemeBandRow {
  lower_limit_sh: string;
  upper_limit_sh: string;
  rate_type: ChargeRateType;
  rate_sh: string;
  lower_charge_limit_sh: string;
  upper_charge_limit_sh: string;
}

export interface SchemeBandDraft {
  lower_limit: Cents;
  upper_limit: Cents | null;
  rate_type: ChargeRateType;
  flat_amount: Cents;
  percentage_rate: number;
  upper_charge_limit: Cents;
  lower_charge_limit: Cents;
}

export const emptyBand = (): SchemeBandRow => ({
  lower_limit_sh: '0', upper_limit_sh: '', rate_type: 'FLAT', rate_sh: '0',
  lower_charge_limit_sh: '0', upper_charge_limit_sh: '0',
});

/** A persisted scheme band (Transaction Calc. Scheme or Loan Product Charge Scheme — same
 *  shape) back into editable Sh-string form. */
export function bandFromScheme(band: {
  lower_limit: Cents; upper_limit: Cents | null; rate_type: ChargeRateType;
  flat_amount: Cents; percentage_rate: number; lower_charge_limit: Cents; upper_charge_limit: Cents;
}): SchemeBandRow {
  return {
    lower_limit_sh: toUnits(band.lower_limit),
    upper_limit_sh: band.upper_limit != null ? toUnits(band.upper_limit) : '',
    rate_type: band.rate_type,
    rate_sh: band.rate_type === 'FLAT' ? toUnits(band.flat_amount) : String(band.percentage_rate),
    lower_charge_limit_sh: toUnits(band.lower_charge_limit),
    upper_charge_limit_sh: toUnits(band.upper_charge_limit),
  };
}

/** An editable row back into the Cents-based draft a save action posts. */
export function bandToDraft(b: SchemeBandRow): SchemeBandDraft {
  return {
    lower_limit: toCents(b.lower_limit_sh),
    upper_limit: b.upper_limit_sh === '' ? null : toCents(b.upper_limit_sh),
    rate_type: b.rate_type,
    flat_amount: b.rate_type === 'FLAT' ? toCents(b.rate_sh) : 0,
    percentage_rate: b.rate_type === 'PERCENTAGE' ? Number(b.rate_sh) || 0 : 0,
    lower_charge_limit: toCents(b.lower_charge_limit_sh),
    upper_charge_limit: toCents(b.upper_charge_limit_sh),
  };
}

export const schemeSummary = (scheme: SchemeBandRow[]): string => {
  if (!scheme.length) return 'No rates configured';
  if (scheme.length === 1) {
    const b = scheme[0];
    return b.rate_type === 'FLAT' ? `Flat ${b.rate_sh || 0}` : `${b.rate_sh || 0}%`;
  }
  return `${scheme.length} bands`;
};

export function TariffMatrix({ bands, baseLabel, hint, onChange }: {
  bands: SchemeBandRow[];
  /** What the band's Lower/Upper limit is matched against — e.g. "the transaction's base
   *  amount", "the source component's resolved amount", "the loan principal". */
  baseLabel: string;
  /** Extra guidance appended below the standard explanation — e.g. a worked example specific
   *  to the caller's own charge codes. */
  hint?: string;
  onChange: (next: SchemeBandRow[]) => void;
}) {
  const { cur } = useFormat();
  const update = (bi: number, patch: Partial<SchemeBandRow>) =>
    onChange(bands.map((b, k) => (k === bi ? { ...b, ...patch } : b)));
  const add = () => onChange([...bands, emptyBand()]);
  const remove = (bi: number) => onChange(bands.filter((_, k) => k !== bi));

  return (
    <>
      <div className="tiny" style={{ marginBottom: 8 }}>
        Tariff matrix — bands are matched in order against {baseLabel}; leave Upper limit blank
        for unbounded. Min/Max charge only apply to a Percentage band.{hint ? ` ${hint}` : ''}
      </div>
      <table>
        <thead>
          <tr>
            <th>Lower limit</th><th>Upper limit</th><th>Rate type</th><th>Rate</th>
            <th>Min charge</th><th>Max charge</th><th style={{ width: 40 }} />
          </tr>
        </thead>
        <tbody>
          {bands.map((band, bi) => (
            <tr key={bi}>
              <td>
                <input type="number" step="0.01" value={band.lower_limit_sh} aria-label="Lower limit" style={{ width: 100 }}
                  onChange={(e) => update(bi, { lower_limit_sh: e.target.value })} />
              </td>
              <td>
                <input type="number" step="0.01" value={band.upper_limit_sh} aria-label="Upper limit" style={{ width: 100 }}
                  placeholder="Unbounded"
                  onChange={(e) => update(bi, { upper_limit_sh: e.target.value })} />
              </td>
              <td>
                <select value={band.rate_type} aria-label="Rate type"
                  onChange={(e) => update(bi, { rate_type: e.target.value as ChargeRateType })}>
                  {CHARGE_RATE_TYPES.map((t) => <option key={t.value} value={t.value}>{t.label}</option>)}
                </select>
              </td>
              <td>
                <input type="number" step="0.01" value={band.rate_sh} aria-label="Rate" style={{ width: 90 }}
                  onChange={(e) => update(bi, { rate_sh: e.target.value })} />
                {band.rate_type === 'PERCENTAGE' ? (
                  <>
                    <span className="tiny">%</span>
                    <div className="tiny muted-cell" style={{ marginTop: 2 }}>
                      = {cur(Math.round(Number(band.rate_sh) || 0))} per KSh 1.00 of the amount
                    </div>
                  </>
                ) : null}
              </td>
              <td>
                <input
                  type="number" step="0.01" value={band.lower_charge_limit_sh} aria-label="Minimum charge"
                  style={{ width: 100 }} disabled={band.rate_type !== 'PERCENTAGE'}
                  onChange={(e) => update(bi, { lower_charge_limit_sh: e.target.value })}
                />
              </td>
              <td>
                <input
                  type="number" step="0.01" value={band.upper_charge_limit_sh} aria-label="Maximum charge"
                  style={{ width: 100 }} disabled={band.rate_type !== 'PERCENTAGE'}
                  onChange={(e) => update(bi, { upper_charge_limit_sh: e.target.value })}
                />
              </td>
              <td>
                <button type="button" className="btn sm ghost" onClick={() => remove(bi)} aria-label="Remove band">×</button>
              </td>
            </tr>
          ))}
          {!bands.length ? (
            <tr><td colSpan={7} className="tiny">No bands — this component will never calculate an amount.</td></tr>
          ) : null}
        </tbody>
      </table>
      <div className="inline" style={{ marginTop: 8 }}>
        <button type="button" className="btn ghost sm" onClick={add}>Add band</button>
      </div>
    </>
  );
}
