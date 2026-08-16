/*
 * Charge Management — Business Central-style Transaction Charges (Codeunit 52204012 "Journal
 * Management" in the source documentation). A Charge is a reusable fee code; a Transaction
 * Charge attaches one or more prioritised, calculated components to a document/transaction
 * type (lib/types.ts's ChargeTransactionType); each component is either a direct Calculation
 * Scheme lookup (an amount-banded flat/percentage rate, optionally capped) or a percentage of
 * another component's already-resolved amount, and posts to its own G/L account when
 * postTransactionCharges() runs it.
 *
 * Scoped down from the source documentation for this SACCO's actual domain: no Bank
 * Account/Vendor posting destinations (this app only ever posts to gl_account), no Cash
 * Deposit/ATM/Bankers Cheque cooperative-charge split or Control Account (this app has no such
 * transaction types), and no Transaction Recoveries (the source's own recovery table/posting
 * logic wasn't supplied). The calculation engine — bands, flat/percentage, percentage-of-
 * charge chaining, priority order, min/max charge limits — is otherwise faithful to it.
 */
import { one, all, run, tx, audit } from './db.ts';
import { AppError } from './errors.ts';
import { postJournal } from './accounting.ts';
import { diffFields, logTableChange } from './changeLog.ts';
import { CHARGE_TRANSACTION_TYPES } from './constants.ts';
import type {
  Actor, CalculatedCharge, Cents, Charge, ChargeCalculationType, ChargeRateType, ChargeTransactionType,
  IsoDate, JournalLineInput, PostedJournal, TransactionCalcScheme, TransactionCharge,
  TransactionChargeSetupDetail, TransactionChargeWithDetail,
} from './types.ts';

/* --------------------------------------------------------------- charge master */

export const listCharges = (): Promise<Charge[]> => all<Charge>('SELECT * FROM charge ORDER BY code');

export async function createCharge(code: string, description: string, user: Actor): Promise<{ id: number }> {
  code = code.trim().toUpperCase();
  description = description.trim();
  if (!code || !description) throw new AppError('Code and description are required', 'VALIDATION');
  if (await one('SELECT 1 FROM charge WHERE code = ?', code)) {
    throw new AppError('Charge code already exists', 'DUPLICATE');
  }
  const info = await run('INSERT INTO charge (code, description) VALUES (?,?)', code, description);
  await audit(user, 'CHARGE_CREATE', 'charge', info.lastInsertRowid, { code });
  return { id: Number(info.lastInsertRowid) };
}

export async function updateCharge(
  id: number, description: string, status: 'ACTIVE' | 'INACTIVE', user: Actor,
): Promise<Charge> {
  const before = await one<Charge>('SELECT * FROM charge WHERE id = ?', id);
  if (!before) throw new AppError('Charge not found', 'NOT_FOUND');
  description = description.trim();
  if (!description) throw new AppError('Description is required', 'VALIDATION');
  await run('UPDATE charge SET description = ?, status = ? WHERE id = ?', description, status, id);
  const changes = diffFields(before as unknown as Record<string, unknown>, { description, status });
  await logTableChange('charge', before.code, 'Modification', changes, user);
  return (await one<Charge>('SELECT * FROM charge WHERE id = ?', id))!;
}

/* ------------------------------------------------------- transaction charges */

const SELECT_SETUP_DETAIL = `
  SELECT s.*, c.code AS charge_code, c.description AS charge_description,
         g.code AS gl_account_code, g.name AS gl_account_name
  FROM transaction_charge_setup s
  JOIN charge c ON c.id = s.charge_id
  JOIN gl_account g ON g.id = s.gl_account_id`;

export const listTransactionCharges = (): Promise<TransactionCharge[]> =>
  all<TransactionCharge>('SELECT * FROM transaction_charge ORDER BY transaction_type');

/** Every enabled Transaction Charge, any type — the Charge Code picklist for a document (e.g.
 *  Member Charging) that isn't tied to one specific transaction type the way Account
 *  Activation's own picker is (see listTransactionChargesByType()). */
export const listActiveTransactionCharges = (): Promise<TransactionCharge[]> =>
  all<TransactionCharge>("SELECT * FROM transaction_charge WHERE status = 'ACTIVE' ORDER BY code");

/** Every enabled Transaction Charge configured for one type — the Charge Code picklist for a
 *  document that lets its user choose which applies (e.g. Account Activation), as opposed to
 *  getTransactionChargeByType()'s single auto-resolved pick. */
export const listTransactionChargesByType = (transactionType: ChargeTransactionType): Promise<TransactionCharge[]> =>
  all<TransactionCharge>(
    "SELECT * FROM transaction_charge WHERE transaction_type = ? AND status = 'ACTIVE' ORDER BY code",
    transactionType,
  );

async function schemesForSetups(setupIds: number[]): Promise<Map<number, TransactionCalcScheme[]>> {
  const map = new Map<number, TransactionCalcScheme[]>();
  if (!setupIds.length) return map;
  const rows = await all<TransactionCalcScheme>(
    `SELECT * FROM transaction_calc_scheme
     WHERE transaction_charge_setup_id IN (${setupIds.map(() => '?').join(',')})
     ORDER BY lower_limit`,
    ...setupIds,
  );
  for (const r of rows) {
    const list = map.get(r.transaction_charge_setup_id) ?? [];
    list.push(r);
    map.set(r.transaction_charge_setup_id, list);
  }
  return map;
}

export async function getTransactionCharge(id: number): Promise<TransactionChargeWithDetail | null> {
  const parent = await one<TransactionCharge>('SELECT * FROM transaction_charge WHERE id = ?', id);
  if (!parent) return null;
  const setups = await all<TransactionChargeSetupDetail>(
    `${SELECT_SETUP_DETAIL} WHERE s.transaction_charge_id = ? ORDER BY s.priority`, id,
  );
  const schemesBySetup = await schemesForSetups(setups.map((s) => s.id));
  return { ...parent, components: setups.map((s) => ({ ...s, scheme: schemesBySetup.get(s.id) ?? [] })) };
}

/** The one enabled Transaction Charge configured for a transaction type, if any — the lookup
 *  postTransactionCharges() and every "how much would this cost" preview resolve off. */
export async function getTransactionChargeByType(
  transactionType: ChargeTransactionType,
): Promise<TransactionChargeWithDetail | null> {
  const row = await one<{ id: number }>(
    "SELECT id FROM transaction_charge WHERE transaction_type = ? AND status = 'ACTIVE'", transactionType,
  );
  return row ? getTransactionCharge(row.id) : null;
}

export interface TransactionCalcSchemeDraft {
  lower_limit?: Cents;
  upper_limit?: Cents | null;
  rate_type: ChargeRateType;
  flat_amount?: Cents;
  percentage_rate?: number;
  upper_charge_limit?: Cents;
  lower_charge_limit?: Cents;
}

export interface TransactionChargeSetupDraft {
  charge_id: number;
  gl_account_id: number;
  calculation_type: ChargeCalculationType;
  /** Index into this same components array (not a database id, which doesn't exist yet for a
   *  new row) — resolved to a real transaction_charge_setup_id once every component in the
   *  batch has been (re)inserted. */
  source_index: number | null;
  priority?: number;
  status?: 'ACTIVE' | 'INACTIVE';
  scheme: TransactionCalcSchemeDraft[];
}

/** Wholesale replace, the same shape lib/workflow.ts's replaceConditionsAndSteps() uses for a
 *  workflow's conditions/steps: delete every existing component (and its scheme bands) for
 *  this Transaction Charge and reinsert the submitted set, inside the caller's transaction.
 *  Percentage-of-Charge source references are wired in a second pass since a new component's
 *  real id doesn't exist until after it's inserted. */
async function replaceComponents(
  transactionChargeId: number, components: TransactionChargeSetupDraft[],
): Promise<void> {
  const existing = (await all<{ id: number }>(
    'SELECT id FROM transaction_charge_setup WHERE transaction_charge_id = ?', transactionChargeId,
  )).map((r) => r.id);
  if (existing.length) {
    await run(
      `DELETE FROM transaction_calc_scheme WHERE transaction_charge_setup_id IN (${existing.map(() => '?').join(',')})`,
      ...existing,
    );
  }
  await run('DELETE FROM transaction_charge_setup WHERE transaction_charge_id = ?', transactionChargeId);

  const newIds: (number | undefined)[] = [];
  for (const [i, c] of components.entries()) {
    if (!c.charge_id || !c.gl_account_id) continue;
    const info = await run(
      `INSERT INTO transaction_charge_setup
         (transaction_charge_id, charge_id, gl_account_id, calculation_type, priority, status)
       VALUES (?,?,?,?,?,?)`,
      transactionChargeId, c.charge_id, c.gl_account_id, c.calculation_type, c.priority || i + 1,
      c.status || 'ACTIVE',
    );
    const setupId = Number(info.lastInsertRowid);
    newIds[i] = setupId;
    for (const b of c.scheme) {
      await run(
        `INSERT INTO transaction_calc_scheme
           (transaction_charge_setup_id, lower_limit, upper_limit, rate_type, flat_amount,
            percentage_rate, upper_charge_limit, lower_charge_limit)
         VALUES (?,?,?,?,?,?,?,?)`,
        setupId, b.lower_limit || 0, b.upper_limit ?? null, b.rate_type, b.flat_amount || 0,
        b.percentage_rate || 0, b.upper_charge_limit || 0, b.lower_charge_limit || 0,
      );
    }
  }
  for (const [i, c] of components.entries()) {
    if (c.calculation_type !== 'PERCENT_OF_CHARGE' || c.source_index == null) continue;
    const setupId = newIds[i];
    const sourceId = newIds[c.source_index];
    if (setupId && sourceId) {
      await run('UPDATE transaction_charge_setup SET source_setup_id = ? WHERE id = ?', sourceId, setupId);
    }
  }
}

export interface TransactionChargeInput {
  code: string;
  description: string;
  transaction_type: ChargeTransactionType;
  status?: 'ACTIVE' | 'INACTIVE';
}

export async function createTransactionCharge(
  body: TransactionChargeInput, components: TransactionChargeSetupDraft[], user: Actor,
): Promise<{ id: number }> {
  const code = body.code.trim().toUpperCase();
  const description = body.description.trim();
  if (!code || !description || !body.transaction_type) {
    throw new AppError('Code, description and transaction type are required', 'VALIDATION');
  }
  if (!CHARGE_TRANSACTION_TYPES.some((t) => t.value === body.transaction_type)) {
    throw new AppError('Invalid transaction type', 'VALIDATION');
  }
  return tx(async () => {
    if (await one('SELECT 1 FROM transaction_charge WHERE code = ?', code)) {
      throw new AppError('Transaction charge code already exists', 'DUPLICATE');
    }
    if (await one('SELECT 1 FROM transaction_charge WHERE transaction_type = ?', body.transaction_type)) {
      throw new AppError('A transaction charge is already configured for this transaction type', 'DUPLICATE');
    }
    const info = await run(
      'INSERT INTO transaction_charge (code, description, transaction_type, status) VALUES (?,?,?,?)',
      code, description, body.transaction_type, body.status || 'ACTIVE',
    );
    const id = Number(info.lastInsertRowid);
    await replaceComponents(id, components);
    await audit(user, 'TRANSACTION_CHARGE_CREATE', 'transaction_charge', id, { code, transaction_type: body.transaction_type });
    return { id };
  });
}

export async function updateTransactionCharge(
  id: number, body: Pick<TransactionChargeInput, 'description' | 'status' | 'transaction_type'>,
  components: TransactionChargeSetupDraft[], user: Actor,
): Promise<{ id: number }> {
  return tx(async () => {
    const before = await one<TransactionCharge>('SELECT * FROM transaction_charge WHERE id = ?', id);
    if (!before) throw new AppError('Transaction charge not found', 'NOT_FOUND');
    const description = body.description?.trim();
    if (!description) throw new AppError('Description is required', 'VALIDATION');
    if (!body.transaction_type || !CHARGE_TRANSACTION_TYPES.some((t) => t.value === body.transaction_type)) {
      throw new AppError('Invalid transaction type', 'VALIDATION');
    }
    if (body.transaction_type !== before.transaction_type
      && await one('SELECT 1 FROM transaction_charge WHERE transaction_type = ? AND id != ?', body.transaction_type, id)) {
      throw new AppError('A transaction charge is already configured for this transaction type', 'DUPLICATE');
    }
    await run(
      'UPDATE transaction_charge SET description = ?, transaction_type = ?, status = ? WHERE id = ?',
      description, body.transaction_type, body.status || 'ACTIVE', id,
    );
    await replaceComponents(id, components);
    await audit(user, 'TRANSACTION_CHARGE_UPDATE', 'transaction_charge', id, { code: before.code });
    return { id };
  });
}

/* ------------------------------------------------------------- calculation */

/** Finds the amount band whose Lower/Upper Limit contains `baseAmount`, computes the flat or
 *  percentage rate against it, then clamps by the band's Upper/Lower Charge Limit when set
 *  (non-zero) — the same rule for a direct Calculation Scheme lookup and for the second stage
 *  of a Percentage of Charge calculation; only the base amount handed in differs between them. */
function calculateFromScheme(scheme: TransactionCalcScheme[], baseAmount: Cents): Cents {
  const band = scheme.find((b) => (
    baseAmount >= b.lower_limit && (b.upper_limit == null || baseAmount <= b.upper_limit)
  ));
  if (!band) return 0;
  let amount = band.rate_type === 'FLAT'
    ? band.flat_amount
    : Math.round((band.percentage_rate / 100) * baseAmount);
  if (band.rate_type === 'PERCENTAGE') {
    if (band.lower_charge_limit > 0) amount = Math.max(amount, band.lower_charge_limit);
    if (band.upper_charge_limit > 0) amount = Math.min(amount, band.upper_charge_limit);
  }
  return Math.max(amount, 0);
}

/** Runs every enabled component of a Transaction Charge against `baseAmount` — direct-Scheme
 *  components first (their resolved amount is what a Percentage of Charge component may then
 *  read as its own base), then Percentage of Charge components — mirroring Journal
 *  Management's two-stage AddCharges/GetChargesAmount calculation. Zero-amount components
 *  (no band matched, or a flat/percentage rate of zero) are dropped rather than posted as a
 *  no-op line. */
export function calculateTransactionCharges(
  detail: TransactionChargeWithDetail, baseAmount: Cents,
): CalculatedCharge[] {
  const active = detail.components.filter((c) => c.status === 'ACTIVE');
  const resolved = new Map<number, Cents>();

  for (const c of active) {
    if (c.calculation_type === 'SCHEME') resolved.set(c.id, calculateFromScheme(c.scheme, baseAmount));
  }
  for (const c of active) {
    if (c.calculation_type !== 'PERCENT_OF_CHARGE') continue;
    const sourceAmount = c.source_setup_id != null ? resolved.get(c.source_setup_id) ?? 0 : 0;
    resolved.set(c.id, calculateFromScheme(c.scheme, sourceAmount));
  }

  return active
    .filter((c) => (resolved.get(c.id) ?? 0) > 0)
    .sort((a, b) => a.priority - b.priority)
    .map((c) => ({
      setupId: c.id, chargeCode: c.charge_code, chargeDescription: c.charge_description,
      glAccountId: c.gl_account_id, glAccountCode: c.gl_account_code, amount: resolved.get(c.id) ?? 0,
    }));
}

/** Inquiry-only preview — Journal Management's GetChargesAmount/GetTransactionChargesAmount,
 *  for a UI to show the fee total (and its component breakdown) before the transaction that
 *  would trigger it actually runs. Returns [] rather than erroring when nothing is configured
 *  for the type, so a caller can charge-if-configured without a special case. */
export async function previewTransactionCharges(
  transactionType: ChargeTransactionType, baseAmount: Cents,
): Promise<CalculatedCharge[]> {
  const detail = await getTransactionChargeByType(transactionType);
  return detail ? calculateTransactionCharges(detail, baseAmount) : [];
}

/** Same preview, but against one specific Transaction Charge rather than a type's auto-resolved
 *  one — for a document that lets its user pick which configured Charge Code applies (e.g.
 *  Account Activation's own Charge Code field) instead of always taking the type's only one. */
export async function previewTransactionChargeById(id: number, baseAmount: Cents): Promise<CalculatedCharge[]> {
  const detail = await getTransactionCharge(id);
  return detail ? calculateTransactionCharges(detail, baseAmount) : [];
}

export interface PostTransactionChargesInput {
  /** Run this specific Transaction Charge (a document that lets its user pick a Charge Code)
   *  — takes precedence over `transactionType` when both are given. */
  transactionChargeId?: number;
  /** Auto-resolve the one enabled Transaction Charge configured for this type — used when a
   *  caller has no per-document choice to make. */
  transactionType?: ChargeTransactionType;
  baseAmount: Cents;
  /** GL account id or code the aggregate charge is debited from — the caller's own concern,
   *  same as AddCharges' explicit debit-account parameter; this module has no opinion on it. */
  debitAccountCode: number | string;
  valueDate: IsoDate;
  module?: string;
  eventType?: string;
  memberId?: number | null;
  description?: string;
  /** The caller's own source document number (e.g. Member Charging's or Account Activation's
   *  `no`) — carried straight through to the journal's `reference`, so the G/L Entry always
   *  traces back to the document that caused it. */
  reference?: string | null;
  user: Actor;
  /** Passed straight through to postJournal — lets a caller with its own natural document key
   *  (e.g. Member Charging's own No.) guarantee a retried post can never create a second
   *  journal for the same document. */
  idempotencyKey?: string | null;
}

/**
 * Posts every calculated component of a transaction charge as one self-balancing journal: each
 * component credits its own configured G/L account, and the combined total is debited from
 * `debitAccountCode` in a single line — Journal Management's AddCharges with
 * SelfBalancing=true, the mode needed here since (unlike a deposit/withdrawal, which already
 * has its own principal journal for a charge line to ride along on) the caller may have no
 * other journal in flight. Returns null — posts nothing — when no charge is configured (or
 * resolvable) or every component resolves to zero, so callers can invoke this unconditionally.
 */
export async function postTransactionCharges({
  transactionChargeId, transactionType, baseAmount, debitAccountCode, valueDate, module: sourceModule = 'GL',
  eventType, memberId = null, description, reference = null, user, idempotencyKey = null,
}: PostTransactionChargesInput): Promise<{ journal: PostedJournal; charges: CalculatedCharge[] } | null> {
  const charges = transactionChargeId != null
    ? await previewTransactionChargeById(transactionChargeId, baseAmount)
    : transactionType ? await previewTransactionCharges(transactionType, baseAmount) : [];
  if (!charges.length) return null;

  const label = transactionType || charges[0].chargeCode;
  const total = charges.reduce((sum, c) => sum + c.amount, 0);
  // Every line leaves narration unset so postJournal's own fallback (line narration -> header
  // description) applies uniformly — debit and credit legs of the same posting must read the
  // same Description, not the debit side showing the document's description while each credit
  // component shows its own Charge Code description instead.
  const lines: JournalLineInput[] = [
    { account: debitAccountCode, debit: total, credit: 0 },
    ...charges.map((c) => ({ account: c.glAccountId, debit: 0, credit: c.amount })),
  ];
  const journal = await postJournal({
    valueDate, module: sourceModule, eventType: eventType || label,
    description: description || `${label} charge`, reference, memberId, user, lines, idempotencyKey,
  });
  await audit(user, 'TRANSACTION_CHARGE_POST', 'transaction_charge', transactionChargeId ?? label, {
    total, charges: charges.map((c) => c.chargeCode),
  });
  return { journal, charges };
}
