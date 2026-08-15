/*
 * Member Charging — an ad-hoc charge posted straight against a member's own withdrawable
 * deposit account (Table 52204206 / Pages 52204262 & 52204263 / Codeunit 52204019 in the
 * source documentation). Same lib/module shape as lib/accountActivation.ts — a document row,
 * a Charge Code that resolves the Posting Transaction Type and the calculated amount, and a
 * posting step that debits the source account and credits each charge component's own G/L
 * account — but with no approval workflow: the initiator who creates the document is also the
 * one who posts it, so `status` only ever moves Open -> Posted, never Pending Approval/Approved.
 *
 * "No Of Pages" is the only quantity Table 52204206 gives GetChargesAmount besides the Charge
 * Code itself, so it is threaded straight through as the existing calculation engine's
 * `baseAmount` (lib/charges.ts's calculateTransactionCharges): a flat-rate Charge Code ignores
 * it entirely, and a per-page Charge Code (Statement Charge) is configured as a PERCENTAGE band
 * whose percentage_rate is 100x the per-page rate in cents, since (rate/100)*pages already is
 * ratePerPage*pages. That is the "map it explicitly" the source documentation calls for — no
 * new tariff formula invented, no engine change.
 */
import { one, all, run, tx, nextSequence } from './db.ts';
import { AppError } from './errors.ts';
import { diffFields, logTableChange } from './changeLog.ts';
import { getTransactionCharge, calculateTransactionCharges, postTransactionCharges } from './charges.ts';
import { buildFilterClause, type FilterCondition, type FilterFieldDef } from './listFilters.ts';
import { buildOrderClause, type SortState } from './listSort.ts';
import { getJournal, type JournalDetail } from './gl.ts';
import type {
  Actor, Cents, ChargeTransactionType, MemberChargingWithDimensions, SavingsAccountForDebit,
} from './types.ts';

const today = () => new Date().toISOString().slice(0, 10);

export type MemberChargingView = 'open' | 'posted';

const VIEW_CLAUSE: Record<MemberChargingView, string> = {
  open: "mc.status = 'Open'",
  posted: "mc.status = 'Posted'",
};

const SELECT_ROW = `
  SELECT mc.*, m.member_no AS member_no, m.first_name AS member_first_name, m.last_name AS member_last_name,
         sa.account_no AS source_account_no, sa.balance AS source_account_balance,
         sa.hold_amount AS source_account_hold_amount, sp.min_balance AS source_account_min_balance,
         sp.gl_control_id AS source_account_gl_control_id,
         tc.code AS transaction_charge_code, tc.description AS transaction_charge_description,
         tc.transaction_type AS posting_transaction_type,
         j.journal_no AS journal_no
  FROM member_charging mc
  JOIN member m ON m.id = mc.member_id
  JOIN savings_account sa ON sa.id = mc.source_account_id
  JOIN savings_product sp ON sp.id = sa.product_id
  JOIN transaction_charge tc ON tc.id = mc.transaction_charge_id
  LEFT JOIN journal j ON j.id = mc.journal_id`;

/** Member Charging list's dynamic-filter registry — every meaningful column on the document
 *  itself (status is deliberately left out; the view tabs remain the primary Open/Posted nav). */
export const MEMBER_CHARGING_FILTER_FIELDS: FilterFieldDef[] = [
  { key: 'no', label: 'No.', type: 'text', column: 'mc.no' },
  { key: 'member_id', label: 'Member', type: 'select', column: 'm.id' },
  { key: 'description', label: 'Description', type: 'text', column: 'mc.description' },
  { key: 'created_by', label: 'Created By', type: 'text', column: 'mc.created_by' },
  { key: 'created_at', label: 'Created', type: 'date', column: 'mc.created_at', datetime: true },
  { key: 'posted_by', label: 'Posted By', type: 'text', column: 'mc.posted_by' },
  { key: 'posted_at', label: 'Posted', type: 'date', column: 'mc.posted_at', datetime: true },
];

const MEMBER_CHARGING_SORT_COLUMNS: Record<string, string> = {
  no: 'mc.no',
  member: 'm.first_name',
  source_account_no: 'sa.account_no',
  amount_charged: 'mc.amount_charged',
  status: 'mc.status',
};

/** Adds the account's currently-available balance to a fetched row — computed live (not
 *  stored) so it always reflects the source account's current balance, the same reason
 *  lib/accountActivation.ts's withChargeAmount() computes its charge amount live. */
const withSourceBalance = (row: MemberChargingWithDimensions): MemberChargingWithDimensions => ({
  ...row,
  source_balance: Math.max(
    row.source_account_balance - row.source_account_hold_amount - row.source_account_min_balance, 0,
  ),
});

export interface ListMemberChargingOptions {
  view?: MemberChargingView;
  search?: string;
  filters?: FilterCondition[];
  sort?: SortState | null;
}

export async function listMemberChargings(
  { view, search = '', filters = [], sort = null }: ListMemberChargingOptions = {},
): Promise<MemberChargingWithDimensions[]> {
  const { clause, params } = buildFilterClause(MEMBER_CHARGING_FILTER_FIELDS, filters);
  const orderBy = buildOrderClause(MEMBER_CHARGING_SORT_COLUMNS, sort, 'mc.no DESC');
  const rows = await all<MemberChargingWithDimensions>(
    `${SELECT_ROW}
     WHERE (m.first_name LIKE @like OR m.last_name LIKE @like OR m.member_no LIKE @like
        OR sa.account_no LIKE @like OR mc.no LIKE @like OR mc.description LIKE @like)
       ${view ? `AND ${VIEW_CLAUSE[view]}` : ''}
       ${clause}
     ${orderBy}`,
    { like: `%${String(search).trim()}%`, ...params },
  );
  return rows.map(withSourceBalance);
}

export async function getMemberCharging(no: string): Promise<MemberChargingWithDimensions | undefined> {
  const row = await one<MemberChargingWithDimensions>(`${SELECT_ROW} WHERE mc.no = ?`, no);
  return row ? withSourceBalance(row) : undefined;
}

/** The document immediately before/after this one by number — the same Business-Central-style
 *  Previous/Next navigation as lib/accountActivation.ts's getAdjacentAccountActivationNos(). */
export async function getAdjacentMemberChargingNos(
  no: string, view?: MemberChargingView,
): Promise<{ prevNo: string | null; nextNo: string | null }> {
  const clause = view ? `AND ${VIEW_CLAUSE[view]}` : '';
  const [prev, next] = await Promise.all([
    one<{ no: string }>(`SELECT mc.no FROM member_charging mc WHERE mc.no < ? ${clause} ORDER BY mc.no DESC LIMIT 1`, no),
    one<{ no: string }>(`SELECT mc.no FROM member_charging mc WHERE mc.no > ? ${clause} ORDER BY mc.no ASC LIMIT 1`, no),
  ]);
  return { prevNo: prev?.no ?? null, nextNo: next?.no ?? null };
}

/** The member's withdrawable deposit accounts — Table 52204206's "Source Account", resolved
 *  from the member rather than freely typed. Restricted to ACTIVE accounts whose product
 *  actually permits a withdrawal, same eligibility lib/savings.ts's withdraw() itself enforces.
 *  A member with more than one is asked to pick (auto-selecting the first), rather than this
 *  guessing which one is "the" account. */
export const withdrawableAccountsForMember = (memberId: number): Promise<SavingsAccountForDebit[]> =>
  all<SavingsAccountForDebit>(
    `SELECT sa.id, sa.account_no, sa.status, sa.balance, sa.hold_amount, p.name AS product_name,
            p.min_balance, p.gl_control_id
     FROM savings_account sa JOIN savings_product p ON p.id = sa.product_id
     WHERE sa.member_id = ? AND sa.status = 'ACTIVE' AND p.allow_withdrawal = 1
     ORDER BY sa.account_no`,
    memberId,
  );

export interface CalculatedMemberCharge {
  amount: Cents;
  postingTransactionType: ChargeTransactionType;
}

/** GetChargesAmount(Charge Code, No Of Pages) — see the file header for how No Of Pages maps
 *  onto the existing calculation engine's baseAmount. Returns null for an unknown/deleted
 *  Charge Code so the caller can surface a configuration error rather than crash. */
export async function calculateMemberChargingAmount(
  transactionChargeId: number, noOfPages: number | null,
): Promise<CalculatedMemberCharge | null> {
  const detail = await getTransactionCharge(transactionChargeId);
  if (!detail) return null;
  const charges = calculateTransactionCharges(detail, noOfPages || 0);
  return { amount: charges.reduce((sum, c) => sum + c.amount, 0), postingTransactionType: detail.transaction_type };
}

function assertMandatoryFields(input: {
  description: string; memberId: number; sourceAccountId: number; transactionChargeId: number;
  noOfPages?: number | null;
}, postingTransactionType: ChargeTransactionType): void {
  if (!input.description || !input.description.trim()) throw new AppError('Description is required', 'VALIDATION');
  if (!input.memberId) throw new AppError('Member No. is required', 'VALIDATION');
  if (!input.sourceAccountId) throw new AppError('No withdrawable deposit account is available', 'VALIDATION');
  if (!input.transactionChargeId) throw new AppError('Charge Code is required', 'VALIDATION');
  if (postingTransactionType === 'Statement Charge' && !input.noOfPages) {
    throw new AppError('No. Of Pages is required', 'VALIDATION');
  }
}

/** Checked at every gate: creation, edit and posting, since either the tariff or the source
 *  account's own balance can move between those moments — same shape as
 *  lib/accountActivation.ts's assertChargeAffordable(). */
async function assertAffordable(sourceAccountId: number, amount: Cents): Promise<void> {
  const acct = await one<{ account_no: string; balance: number; hold_amount: number; min_balance: number }>(
    `SELECT sa.account_no, sa.balance, sa.hold_amount, p.min_balance
     FROM savings_account sa JOIN savings_product p ON p.id = sa.product_id WHERE sa.id = ?`,
    sourceAccountId,
  );
  if (!acct) throw new AppError('Source account not found', 'NOT_FOUND');
  const available = Math.max(acct.balance - acct.hold_amount - acct.min_balance, 0);
  if (amount > available) {
    throw new AppError(
      `The charge of ${(amount / 100).toFixed(2)} exceeds ${acct.account_no}'s available balance of ${(available / 100).toFixed(2)}`,
      'INSUFFICIENT_FUNDS',
    );
  }
}

async function assertSourceAccountBelongsToMember(sourceAccountId: number, memberId: number): Promise<void> {
  const acct = await one<{ member_id: number }>('SELECT member_id FROM savings_account WHERE id = ?', sourceAccountId);
  if (!acct) throw new AppError('Source account not found', 'NOT_FOUND');
  if (acct.member_id !== memberId) throw new AppError('The source account does not belong to this member', 'VALIDATION');
}

export interface MemberChargingInput {
  memberId: number;
  sourceAccountId: number;
  transactionChargeId: number;
  description: string;
  noOfPages?: number | null;
}

/** Recomputes and validates one candidate Member Charging state — shared by create, update and
 *  the final re-check right before posting, so the same rules always run whether the document
 *  is brand new, being edited, or about to move money. */
async function resolveAndValidate(input: MemberChargingInput): Promise<{ amount: Cents; postingTransactionType: ChargeTransactionType }> {
  const charge = await getTransactionCharge(input.transactionChargeId);
  if (!charge) throw new AppError('Charge Code not found', 'NOT_FOUND');
  assertMandatoryFields(input, charge.transaction_type);
  await assertSourceAccountBelongsToMember(input.sourceAccountId, input.memberId);
  const charges = calculateTransactionCharges(charge, input.noOfPages || 0);
  const amount = charges.reduce((sum, c) => sum + c.amount, 0);
  await assertAffordable(input.sourceAccountId, amount);
  return { amount, postingTransactionType: charge.transaction_type };
}

export async function createMemberCharging(input: MemberChargingInput, user: Actor): Promise<{ no: string }> {
  const { amount } = await resolveAndValidate(input);

  const no = await nextSequence('MEMBER_CHARGING');
  await run(
    `INSERT INTO member_charging
       (no, description, member_id, source_account_id, transaction_charge_id, no_of_pages, amount_charged,
        created_at, created_by)
     VALUES (?,?,?,?,?,?,?,?,?)`,
    no, input.description.trim(), input.memberId, input.sourceAccountId, input.transactionChargeId,
    input.noOfPages || null, amount, new Date().toISOString(), user.username,
  );
  await logTableChange(
    'member_charging', no, 'Insertion',
    [
      { field: 'member_id', oldValue: null, newValue: input.memberId },
      { field: 'source_account_id', oldValue: null, newValue: input.sourceAccountId },
      { field: 'transaction_charge_id', oldValue: null, newValue: input.transactionChargeId },
      { field: 'description', oldValue: null, newValue: input.description.trim() },
      { field: 'no_of_pages', oldValue: null, newValue: input.noOfPages || null },
      { field: 'amount_charged', oldValue: null, newValue: amount },
    ],
    user,
  );
  return { no };
}

export async function updateMemberCharging(
  no: string, input: MemberChargingInput, user: Actor,
): Promise<MemberChargingWithDimensions> {
  const before = await one<{ status: string; description: string; member_id: number; source_account_id: number; transaction_charge_id: number; no_of_pages: number | null; amount_charged: number }>(
    'SELECT * FROM member_charging WHERE no = ?', no,
  );
  if (!before) throw new AppError('Member charging document not found', 'NOT_FOUND');
  if (before.status !== 'Open') throw new AppError('Only an unposted document can be edited', 'VALIDATION');
  const { amount } = await resolveAndValidate(input);

  const patch = {
    description: input.description.trim(), member_id: input.memberId, source_account_id: input.sourceAccountId,
    transaction_charge_id: input.transactionChargeId, no_of_pages: input.noOfPages || null, amount_charged: amount,
  };
  await run(
    `UPDATE member_charging
     SET description = ?, member_id = ?, source_account_id = ?, transaction_charge_id = ?, no_of_pages = ?, amount_charged = ?
     WHERE no = ?`,
    patch.description, patch.member_id, patch.source_account_id, patch.transaction_charge_id,
    patch.no_of_pages, patch.amount_charged, no,
  );
  const changes = diffFields(before as unknown as Record<string, unknown>, patch);
  await logTableChange('member_charging', no, 'Modification', changes, user);
  return (await getMemberCharging(no))!;
}

export async function deleteMemberCharging(no: string, user: Actor): Promise<void> {
  const before = await one<{ status: string }>('SELECT status FROM member_charging WHERE no = ?', no);
  if (!before) throw new AppError('Member charging document not found', 'NOT_FOUND');
  if (before.status !== 'Open') throw new AppError('Only an unposted document can be deleted', 'VALIDATION');
  await run('DELETE FROM member_charging WHERE no = ?', no);
  await logTableChange('member_charging', no, 'Deletion', [{ field: 'status', oldValue: before.status, newValue: null }], user);
}

/**
 * Posting sequence (Codeunit 52204019's PostMemberCharges): reload, re-validate every mandatory
 * field and the tariff/balance one final time (either may have moved since the document was
 * created), post the charge journal — the source account debited for the total, each component
 * credited to its own G/L account — debit the source account's own balance to match, record the
 * FEE txn, and only then flip the document to Posted. All inside one DB transaction, so a
 * failure at any point leaves the document untouched rather than half-posted. The Member
 * Charging No. doubles as postTransactionCharges' idempotency key: a retried call after a lost
 * response can never create a second journal for the same document (and if the first call's
 * transaction actually committed, this one's own `status !== 'Open'` guard below already
 * rejects the retry before reaching the posting engine at all).
 */
export async function postMemberCharging(no: string, user: Actor): Promise<{ journalNo: string; amount: Cents }> {
  return tx(async () => {
    const req = await one<{
      status: string; description: string; member_id: number; source_account_id: number;
      transaction_charge_id: number; no_of_pages: number | null;
    }>('SELECT * FROM member_charging WHERE no = ?', no);
    if (!req) throw new AppError('Member charging document not found', 'NOT_FOUND');
    if (req.status !== 'Open') throw new AppError('This document has already been posted', 'VALIDATION');

    const { amount } = await resolveAndValidate({
      memberId: req.member_id, sourceAccountId: req.source_account_id,
      transactionChargeId: req.transaction_charge_id, description: req.description, noOfPages: req.no_of_pages,
    });
    if (amount <= 0) {
      throw new AppError('This Charge Code does not resolve to a chargeable amount — check its configuration', 'VALIDATION');
    }

    const sourceAccount = await one<{ balance: number; account_no: string; gl_control_id: number }>(
      `SELECT sa.balance, sa.account_no, p.gl_control_id
       FROM savings_account sa JOIN savings_product p ON p.id = sa.product_id WHERE sa.id = ?`,
      req.source_account_id,
    );
    if (!sourceAccount) throw new AppError('Source account not found', 'NOT_FOUND');

    const posted = await postTransactionCharges({
      transactionChargeId: req.transaction_charge_id, baseAmount: req.no_of_pages || 0,
      debitAccountCode: sourceAccount.gl_control_id, valueDate: today(), module: 'SAVINGS', eventType: 'MEMBER_CHARGE',
      memberId: req.member_id, description: req.description || `Member charge — ${sourceAccount.account_no}`,
      user, idempotencyKey: `MEMBER_CHARGING-${no}`,
    });
    if (!posted) {
      throw new AppError('This Charge Code does not resolve to a chargeable amount — check its configuration', 'VALIDATION');
    }
    const total = posted.charges.reduce((sum, c) => sum + c.amount, 0);

    const newBalance = sourceAccount.balance - total;
    await run(
      'UPDATE savings_account SET balance = ?, last_activity = ? WHERE id = ?',
      newBalance, today(), req.source_account_id,
    );
    await run(
      `INSERT INTO txn (txn_ref, value_date, created_at, module, txn_type, member_id,
         savings_account_id, amount, running_balance, channel, description, journal_id, created_by)
       VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?)`,
      await nextSequence('TXN'), today(), new Date().toISOString(), 'SAVINGS', 'FEE', req.member_id,
      req.source_account_id, -total, newBalance, 'TELLER', req.description || `Member charge — ${sourceAccount.account_no}`,
      posted.journal.id, user.username,
    );

    await run(
      `UPDATE member_charging
       SET status = 'Posted', amount_charged = ?, journal_id = ?, posted_at = ?, posted_by = ? WHERE no = ?`,
      total, posted.journal.id, new Date().toISOString(), user.username, no,
    );
    await logTableChange(
      'member_charging', no, 'Modification',
      [
        { field: 'status', oldValue: req.status, newValue: 'Posted' },
        { field: 'amount_charged', oldValue: null, newValue: total },
      ],
      user,
    );
    return { journalNo: posted.journal.journal_no, amount: total };
  });
}

/** Table 52204262/263's "Navigate" — the posted journal and its lines, for a posted document.
 *  Gated by the caller on MEMBER_CHARGING_READ rather than GL_READ, since seeing what a
 *  document you're already entitled to read actually posted isn't a General Ledger concern. */
export async function getMemberChargingJournal(no: string): Promise<JournalDetail | null> {
  const row = await one<{ journal_id: number | null }>('SELECT journal_id FROM member_charging WHERE no = ?', no);
  if (!row?.journal_id) return null;
  return getJournal(row.journal_id);
}
