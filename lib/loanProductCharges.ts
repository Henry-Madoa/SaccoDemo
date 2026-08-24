/*
 * Loan Product Charges — one loan product's own charge lines, each drawing its Charge Code from
 * the same reusable Charges master Transaction Charges uses (lib/charges.ts), posting to its
 * own configured revenue (G/L) account, and priced either as a flat Percentage of the loan
 * principal or Calculate from Scheme — an amount-banded tariff table. Structured like
 * Transaction Charges Setup / Transaction Calc. Scheme, scoped to a product instead of a
 * transaction type, and without Percentage-of-Charge chaining (a loan product charge's base is
 * always the principal). The calculation engine itself (calculateLoanProductCharges,
 * calculateChargeFromScheme) is pure and lives in lib/loans.ts so the New Application form can
 * preview it in the browser; this module is the server-only CRUD around it.
 */
import { all, run, audit } from './db.ts';
import type {
  Actor, Cents, ChargeRateType, LoanChargeCalculationType, LoanProductChargeDetail, LoanProductChargeScheme,
} from './types.ts';

const SELECT_LINE = `
  SELECT lpc.*, c.code AS charge_code, c.description AS charge_description,
         g.code AS gl_account_code, g.name AS gl_account_name
  FROM loan_product_charge lpc
  JOIN charge c ON c.id = lpc.charge_id
  JOIN gl_account g ON g.id = lpc.gl_account_id`;

/** Every charge line configured for a loan product, in priority order, each with its Calculate
 *  from Scheme tariff bands attached — the Loan Products edit form's own table, and the input
 *  calculateLoanProductCharges() (lib/loans.ts) reads directly. */
export async function listLoanProductCharges(productId: number): Promise<LoanProductChargeDetail[]> {
  const rows = await all<Omit<LoanProductChargeDetail, 'scheme'>>(
    `${SELECT_LINE} WHERE lpc.product_id = ? ORDER BY lpc.priority`, productId,
  );
  if (!rows.length) return [];
  const ids = rows.map((r) => r.id);
  const schemes = await all<LoanProductChargeScheme>(
    `SELECT * FROM loan_product_charge_scheme WHERE loan_product_charge_id IN (${ids.map(() => '?').join(',')}) ORDER BY lower_limit`,
    ...ids,
  );
  return rows.map((r) => ({
    ...r,
    scheme: schemes.filter((s) => s.loan_product_charge_id === r.id),
  }));
}

export interface LoanProductChargeSchemeDraft {
  lower_limit?: Cents;
  upper_limit?: Cents | null;
  rate_type: ChargeRateType;
  flat_amount?: Cents;
  percentage_rate?: number;
  upper_charge_limit?: Cents;
  lower_charge_limit?: Cents;
}

export interface LoanProductChargeDraft {
  charge_id: number;
  gl_account_id: number;
  calculation_type: LoanChargeCalculationType;
  /** Only meaningful when calculation_type is PERCENTAGE. */
  percentage_rate?: number;
  prorate?: boolean;
  priority?: number;
  status?: 'ACTIVE' | 'INACTIVE';
  /** Only inserted when calculation_type is SCHEME. */
  scheme: LoanProductChargeSchemeDraft[];
}

/** Wholesale replace, the same shape lib/charges.ts's replaceComponents() uses for a Transaction
 *  Charge's components: delete every existing line (and its scheme bands) for this product and
 *  reinsert the submitted set — called from within saveLoanProduct's own transaction, so the
 *  product's fields and its charge lines are saved atomically. */
export async function replaceLoanProductCharges(
  productId: number, lines: LoanProductChargeDraft[], user: Actor,
): Promise<void> {
  const existing = (await all<{ id: number }>(
    'SELECT id FROM loan_product_charge WHERE product_id = ?', productId,
  )).map((r) => r.id);
  if (existing.length) {
    await run(
      `DELETE FROM loan_product_charge_scheme WHERE loan_product_charge_id IN (${existing.map(() => '?').join(',')})`,
      ...existing,
    );
  }
  await run('DELETE FROM loan_product_charge WHERE product_id = ?', productId);

  for (const [i, l] of lines.entries()) {
    if (!l.charge_id || !l.gl_account_id) continue;
    const info = await run(
      `INSERT INTO loan_product_charge
         (product_id, charge_id, gl_account_id, calculation_type, percentage_rate, prorate, priority, status)
       VALUES (?,?,?,?,?,?,?,?)`,
      productId, l.charge_id, l.gl_account_id, l.calculation_type, l.percentage_rate || 0,
      !!l.prorate, l.priority || i + 1, l.status || 'ACTIVE',
    );
    if (l.calculation_type !== 'SCHEME' || !l.scheme.length) continue;
    const lineId = Number(info.lastInsertRowid);
    for (const b of l.scheme) {
      await run(
        `INSERT INTO loan_product_charge_scheme
           (loan_product_charge_id, lower_limit, upper_limit, rate_type, flat_amount,
            percentage_rate, upper_charge_limit, lower_charge_limit)
         VALUES (?,?,?,?,?,?,?,?)`,
        lineId, b.lower_limit || 0, b.upper_limit ?? null, b.rate_type, b.flat_amount || 0,
        b.percentage_rate || 0, b.upper_charge_limit || 0, b.lower_charge_limit || 0,
      );
    }
  }
  await audit(user, 'LOAN_PRODUCT_CHARGES_REPLACE', 'loan_product', productId, { lines: lines.length });
}
