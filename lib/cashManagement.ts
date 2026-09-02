/*
 * Cash Management — AL "FOSA Transactions" (Tab52204044 / Cod52204019 FOSA Management). One
 * table, five `document_type` flows moving cash between the SACCO's own bank/cash accounts:
 *
 *   RECEIVE_FROM_BANK  Main Bank  -> Treasury vault   (created by a treasury user)
 *   TREASURY_REQUEST   Treasury   -> the teller's till (created by a teller)
 *   INTER_TILL         another till -> the teller's till (created by a teller)
 *   TREASURY_RETURN    the teller's till -> Treasury   (created by a teller)
 *   SEND_TO_BANK       Treasury vault -> Main Bank     (created by a treasury user)
 *
 * Maker-checker: Open -> Pending Approval -> Approved -> Processed, the same shape as
 * lib/standingOrders.ts. Posting is one balanced journal — credit the source bank account's
 * control G/L, debit the destination's — through lib/accounting.ts's postJournal(), which then
 * maintains both bank_account balances and the reconciliation subledger automatically.
 */
import {
  one, all, run, tx, nextSequence, audit, hasAnyRow,
} from './db.ts';
import { AppError } from './errors.ts';
import { postJournal } from './accounting.ts';
import { getJournal, type JournalDetail } from './gl.ts';
import { resolvePostingDate } from './postingDates.ts';
import { assertDenominationsBalance, replaceDenominationLines, clearDenominationLines } from './denominations.ts';
import { tellerSetupForUser, treasurySetupForUser, setupForBankAccount } from './tellerSetup.ts';
import { findMatchingWorkflow, findPendingRoutedTask, pickConditionFields, startWorkflow } from './workflow.ts';
import { buildFilterClause, type FilterCondition, type FilterFieldDef } from './listFilters.ts';
import { buildOrderClause, type SortState } from './listSort.ts';
import { FOSA_DOC_TYPES, fosaDocTypeMeta, type FosaDocTypeMeta } from './constants.ts';
import type {
  Actor, BankAccountType, Cents, FosaDocumentType, FosaTransaction, FosaTransactionView, IsoDate,
} from './types.ts';

export { FOSA_DOC_TYPES, fosaDocTypeMeta };
export type { FosaDocTypeMeta };

export type CashManagementView = 'open' | 'pending' | 'approved' | 'posted';

const VIEW_CLAUSE: Record<CashManagementView, string> = {
  open: "ft.status = 'Open'",
  pending: "ft.status = 'Pending Approval'",
  approved: "ft.status = 'Approved'",
  posted: "ft.status = 'Processed'",
};

const SELECT_ROW = `
  SELECT ft.*,
         sb.code AS source_code, sb.name AS source_name, sb.account_type AS source_account_type,
         sb.balance AS source_balance,
         db.code AS destination_code, db.name AS destination_name, db.account_type AS destination_account_type,
         db.balance AS destination_balance,
         j.journal_no AS journal_no,
         COALESCE((SELECT SUM(cdl.quantity * d.value) FROM cash_denomination_line cdl
                   JOIN denomination d ON d.id = cdl.denomination_id
                   WHERE cdl.document_kind = 'FOSA' AND cdl.document_no = ft.no), 0) AS denomination_total
  FROM fosa_transaction ft
  JOIN bank_account sb ON sb.id = ft.source_bank_account_id
  JOIN bank_account db ON db.id = ft.destination_bank_account_id
  LEFT JOIN journal j ON j.id = ft.journal_id`;

export const CASH_MANAGEMENT_FILTER_FIELDS: FilterFieldDef[] = [
  { key: 'no', label: 'No.', type: 'text', column: 'ft.no' },
  {
    key: 'document_type', label: 'Document Type', type: 'select', column: 'ft.document_type',
    options: FOSA_DOC_TYPES.map((d) => ({ value: d.value, label: d.label })),
  },
  { key: 'created_by', label: 'Created By', type: 'text', column: 'ft.created_by' },
  { key: 'created_at', label: 'Created', type: 'date', column: 'ft.created_at', datetime: true },
  { key: 'posted_by', label: 'Posted By', type: 'text', column: 'ft.posted_by' },
];

const SORT_COLUMNS: Record<string, string> = {
  no: 'ft.no',
  document_type: 'ft.document_type',
  amount: 'ft.amount',
  status: 'ft.status',
  created_at: 'ft.created_at',
};

export interface ListFosaTransactionsOptions {
  view?: CashManagementView;
  search?: string;
  filters?: FilterCondition[];
  sort?: SortState | null;
}

export const listFosaTransactions = (
  { view, search = '', filters = [], sort = null }: ListFosaTransactionsOptions = {},
): Promise<FosaTransactionView[]> => {
  const { clause, params } = buildFilterClause(CASH_MANAGEMENT_FILTER_FIELDS, filters);
  const orderBy = buildOrderClause(SORT_COLUMNS, sort, 'ft.no DESC');
  return all<FosaTransactionView>(
    `${SELECT_ROW}
     WHERE (ft.no LIKE @like OR sb.name LIKE @like OR db.name LIKE @like OR ft.created_by LIKE @like)
       ${view ? `AND ${VIEW_CLAUSE[view]}` : ''}
       ${clause}
     ${orderBy}`,
    { like: `%${String(search).trim()}%`, ...params },
  );
};

export const getFosaTransaction = (no: string): Promise<FosaTransactionView | undefined> =>
  one<FosaTransactionView>(`${SELECT_ROW} WHERE ft.no = ?`, no);

export const hasAnyFosaTransactions = (view?: CashManagementView): Promise<boolean> =>
  hasAnyRow('fosa_transaction ft', view ? VIEW_CLAUSE[view] : undefined);

export async function getAdjacentFosaTransactionNos(
  no: string, view?: CashManagementView,
): Promise<{ prevNo: string | null; nextNo: string | null }> {
  const clause = view ? `AND ${VIEW_CLAUSE[view]}` : '';
  const [prev, next] = await Promise.all([
    one<{ no: string }>(`SELECT ft.no FROM fosa_transaction ft WHERE ft.no < ? ${clause} ORDER BY ft.no DESC LIMIT 1`, no),
    one<{ no: string }>(`SELECT ft.no FROM fosa_transaction ft WHERE ft.no > ? ${clause} ORDER BY ft.no ASC LIMIT 1`, no),
  ]);
  return { prevNo: prev?.no ?? null, nextNo: next?.no ?? null };
};

export const listFosaTransactionHistory = (no: string): Promise<{ journal_no: string; value_date: IsoDate; description: string | null; amount: Cents }[]> =>
  all(
    'SELECT journal_no, value_date, description, amount FROM journal WHERE reference = ? ORDER BY value_date DESC, id DESC',
    no,
  );

/* ------------------------------------------------------- picklists for the form */

export interface FosaAccountBrief {
  id: number;
  code: string;
  name: string;
  account_type: BankAccountType;
  balance: Cents;
  /** From the account's own Teller Setup (0 when none / no limit). */
  min_capacity: Cents;
  max_capacity: Cents;
}

const ACCOUNT_BRIEF_SELECT = `
  SELECT b.id, b.code, b.name, b.account_type, b.balance,
         COALESCE(ts.min_capacity, 0) AS min_capacity, COALESCE(ts.max_capacity, 0) AS max_capacity
  FROM bank_account b
  LEFT JOIN teller_setup ts ON ts.bank_account_id = b.id`;

export const listBankAccountsByType = (type: BankAccountType): Promise<FosaAccountBrief[]> =>
  all<FosaAccountBrief>(
    `${ACCOUNT_BRIEF_SELECT} WHERE b.account_type = ? AND b.status = 'ACTIVE' ORDER BY b.code`,
    type,
  );

/** Other tills — for an INTER_TILL request, every active till except the requester's own. */
export const listOtherTills = (excludeBankAccountId: number): Promise<FosaAccountBrief[]> =>
  all<FosaAccountBrief>(
    `${ACCOUNT_BRIEF_SELECT} WHERE b.account_type = 'TILL' AND b.status = 'ACTIVE' AND b.id <> ? ORDER BY b.code`,
    excludeBankAccountId,
  );

/* ------------------------------------------------------------------ resolution */

async function autoResolvedAccountId(documentType: FosaDocumentType, user: Actor): Promise<number> {
  const meta = fosaDocTypeMeta(documentType);
  const setup = meta.creatorSetup === 'TELLER'
    ? await tellerSetupForUser(user.username)
    : await treasurySetupForUser(user.username);
  if (!setup) {
    throw new AppError(
      meta.creatorSetup === 'TELLER'
        ? 'You are not set up as a teller — ask an administrator to add a Teller Setup for you'
        : 'You are not set up as a treasury user — ask an administrator to add a Teller Setup (Treasury) for you',
      'NO_TELLER_SETUP',
    );
  }
  return setup.bank_account_id;
}

/** The end of a movement that is auto-resolved from the acting user's own Teller Setup — the
 *  DESTINATION for the three "request" flows, the SOURCE for the two "return" flows. Returned
 *  with its capacity limits so the New form can pre-fill / cap the Amount against the real
 *  ceiling (a return can never take a source below its minimum float, nor push a destination
 *  above its maximum capacity). Null when the user has no matching Teller Setup. */
export async function myFosaAutoAccount(
  documentType: FosaDocumentType, user: Actor,
): Promise<(FosaAccountBrief & { role: 'SOURCE' | 'DESTINATION' }) | null> {
  const meta = fosaDocTypeMeta(documentType);
  const setup = meta.creatorSetup === 'TELLER'
    ? await tellerSetupForUser(user.username)
    : await treasurySetupForUser(user.username);
  if (!setup) return null;
  const row = await one<FosaAccountBrief>(`${ACCOUNT_BRIEF_SELECT} WHERE b.id = ? LIMIT 1`, setup.bank_account_id);
  if (!row) return null;
  return { ...row, role: meta.counterparty === 'SOURCE' ? 'DESTINATION' : 'SOURCE' };
}

async function resolveEnds(
  documentType: FosaDocumentType, counterpartyBankAccountId: number, user: Actor,
): Promise<{ sourceId: number; destinationId: number }> {
  const meta = fosaDocTypeMeta(documentType);
  const mine = await autoResolvedAccountId(documentType, user);

  const cp = await one<{ account_type: BankAccountType }>(
    'SELECT account_type FROM bank_account WHERE id = ?', counterpartyBankAccountId,
  );
  if (!cp) throw new AppError('The selected account was not found', 'NOT_FOUND');
  if (cp.account_type !== meta.counterpartyType) {
    throw new AppError(`The selected account must be a ${meta.counterpartyType} account`, 'VALIDATION');
  }
  if (counterpartyBankAccountId === mine) {
    throw new AppError('The source and destination cannot be the same account', 'VALIDATION');
  }
  return meta.counterparty === 'SOURCE'
    ? { sourceId: counterpartyBankAccountId, destinationId: mine }
    : { sourceId: mine, destinationId: counterpartyBankAccountId };
}

/* ----------------------------------------------------------------- capacity */

/** AL CheckFOSATransaction — a destination that has a Teller Setup with a Maximum Capacity may
 *  not be pushed above it; a source with a Minimum Capacity may not be pulled below it. */
async function assertCapacity(sourceId: number, destinationId: number, amount: Cents): Promise<void> {
  const [source, dest, srcSetup, dstSetup] = await Promise.all([
    one<{ balance: Cents; name: string; account_type: BankAccountType }>('SELECT balance, name, account_type FROM bank_account WHERE id = ?', sourceId),
    one<{ balance: Cents; name: string; account_type: BankAccountType }>('SELECT balance, name, account_type FROM bank_account WHERE id = ?', destinationId),
    setupForBankAccount(sourceId),
    setupForBankAccount(destinationId),
  ]);
  if (dstSetup && dstSetup.max_capacity > 0 && dest && dest.balance + amount > dstSetup.max_capacity) {
    throw new AppError(
      `This would take ${dest.name} to ${((dest.balance + amount) / 100).toFixed(2)}, above its maximum capacity of ${(dstSetup.max_capacity / 100).toFixed(2)}`,
      'OVER_CAPACITY',
    );
  }
  if (srcSetup && srcSetup.min_capacity > 0 && source && source.balance - amount < srcSetup.min_capacity) {
    throw new AppError(
      `This would take ${source.name} to ${((source.balance - amount) / 100).toFixed(2)}, below its minimum capacity of ${(srcSetup.min_capacity / 100).toFixed(2)}`,
      'UNDER_CAPACITY',
    );
  }
  // The external Main Bank isn't a cash drawer we track to the shilling, so a
  // Receive From Bank is not gated on its recorded balance (AL does the same).
  if (source && source.account_type !== 'MAIN' && source.balance - amount < 0) {
    throw new AppError(
      `${source.name} only holds ${(source.balance / 100).toFixed(2)} — you cannot move out ${(amount / 100).toFixed(2)}`,
      'INSUFFICIENT_FUNDS',
    );
  }
}

/* ------------------------------------------------------------------- create */

export interface FosaTransactionInput {
  documentType: FosaDocumentType;
  counterpartyBankAccountId: number;
  amount: Cents;
}

function assertAmount(amount: Cents): void {
  if (!(amount > 0)) throw new AppError('Amount must be greater than zero', 'VALIDATION');
}

/** AL Tab52204044.OnInsert — one open document of a type at a time per user (Receive/Send to
 *  Bank only block on an unposted one). */
async function assertNoOpenDocument(documentType: FosaDocumentType, user: Actor): Promise<void> {
  const existing = await one<{ no: string }>(
    `SELECT no FROM fosa_transaction
     WHERE created_by = ? AND document_type = ? AND status <> 'Processed'
     ORDER BY no DESC LIMIT 1`,
    user.username, documentType,
  );
  if (existing) {
    throw new AppError(
      `You already have an open ${fosaDocTypeMeta(documentType).label} document (${existing.no}) — finish or delete it first`,
      'OPEN_DOCUMENT_EXISTS',
    );
  }
}

async function seedDenominationGrid(no: string): Promise<void> {
  // Nothing to seed — getDenominationLines() already left-joins the active master, so an
  // untouched grid renders with every denomination at quantity 0. Kept as a hook.
  void no;
}

export async function createFosaTransaction(input: FosaTransactionInput, user: Actor): Promise<{ no: string }> {
  assertAmount(input.amount);
  await assertNoOpenDocument(input.documentType, user);
  const { sourceId, destinationId } = await resolveEnds(input.documentType, input.counterpartyBankAccountId, user);
  await assertCapacity(sourceId, destinationId, input.amount);

  const no = await nextSequence('FOSA_TRANSACTION');
  await run(
    `INSERT INTO fosa_transaction
       (no, document_type, source_bank_account_id, destination_bank_account_id, amount, created_at, created_by)
     VALUES (?,?,?,?,?,?,?)`,
    no, input.documentType, sourceId, destinationId, Math.round(input.amount),
    new Date().toISOString(), user.username,
  );
  await seedDenominationGrid(no);
  await audit(user, 'FOSA_TRANSACTION_CREATE', 'fosa_transaction', no, { documentType: input.documentType });
  return { no };
}

export async function updateFosaTransaction(
  no: string, input: FosaTransactionInput, user: Actor,
): Promise<FosaTransactionView> {
  const before = await one<FosaTransaction>('SELECT * FROM fosa_transaction WHERE no = ?', no);
  if (!before) throw new AppError('Document not found', 'NOT_FOUND');
  if (before.status !== 'Open') throw new AppError('Only an open document can be edited', 'VALIDATION');
  if (before.created_by !== user.username) throw new AppError('Only the person who created this document can edit it', 'NOT_CREATOR');
  if (input.documentType !== before.document_type) throw new AppError('The document type cannot be changed', 'VALIDATION');
  assertAmount(input.amount);
  const { sourceId, destinationId } = await resolveEnds(input.documentType, input.counterpartyBankAccountId, user);
  await assertCapacity(sourceId, destinationId, input.amount);

  await run(
    'UPDATE fosa_transaction SET source_bank_account_id = ?, destination_bank_account_id = ?, amount = ? WHERE no = ?',
    sourceId, destinationId, Math.round(input.amount), no,
  );
  await audit(user, 'FOSA_TRANSACTION_UPDATE', 'fosa_transaction', no, {});
  return (await getFosaTransaction(no))!;
}

export async function setFosaDenominations(
  no: string, lines: { denominationId: number; quantity: number }[], user: Actor,
): Promise<void> {
  const doc = await one<Pick<FosaTransaction, 'status' | 'created_by'>>(
    'SELECT status, created_by FROM fosa_transaction WHERE no = ?', no,
  );
  if (!doc) throw new AppError('Document not found', 'NOT_FOUND');
  if (doc.status !== 'Open') throw new AppError('The denomination breakdown can only be changed while the document is open', 'VALIDATION');
  if (doc.created_by !== user.username) throw new AppError('Only the person who created this document can edit it', 'NOT_CREATOR');
  await replaceDenominationLines('FOSA', no, lines);
}

export async function deleteFosaTransaction(no: string, user: Actor): Promise<void> {
  const before = await one<Pick<FosaTransaction, 'status' | 'created_by'>>(
    'SELECT status, created_by FROM fosa_transaction WHERE no = ?', no,
  );
  if (!before) throw new AppError('Document not found', 'NOT_FOUND');
  if (before.status !== 'Open') throw new AppError('Only an open document can be deleted', 'VALIDATION');
  if (before.created_by !== user.username) throw new AppError('Only the person who created this document can delete it', 'NOT_CREATOR');
  await clearDenominationLines('FOSA', no);
  await run('DELETE FROM fosa_transaction WHERE no = ?', no);
  await audit(user, 'FOSA_TRANSACTION_DELETE', 'fosa_transaction', no, {});
}

/* -------------------------------------------------------------- maker-checker */

export async function submitFosaTransaction(no: string, user: Actor): Promise<{ autoApproved: boolean }> {
  const req = await one<FosaTransaction>('SELECT * FROM fosa_transaction WHERE no = ?', no);
  if (!req) throw new AppError('Document not found', 'NOT_FOUND');
  if (req.status !== 'Open') throw new AppError('Only an open document can be submitted for approval', 'VALIDATION');
  assertAmount(req.amount);
  await assertCapacity(req.source_bank_account_id, req.destination_bank_account_id, req.amount);
  await assertDenominationsBalance('FOSA', no, req.amount);

  const matched = await findMatchingWorkflow('FOSA_TRANSACTION', await pickConditionFields('FOSA_TRANSACTION', req));
  if (!matched) throw new AppError('There is no enabled workflow for this document', 'NO_WORKFLOW');

  await tx(async () => {
    await run("UPDATE fosa_transaction SET status = 'Pending Approval' WHERE no = ?", no);
    await startWorkflow(matched.workflow, matched.steps, {
      documentType: 'FOSA_TRANSACTION', entityId: no, requestedBy: user.username, amount: Number(req.amount),
    });
  });

  const after = await one<{ status: string }>('SELECT status FROM fosa_transaction WHERE no = ?', no);
  return { autoApproved: after?.status === 'Approved' };
}

export async function cancelFosaApproval(no: string, user: Actor): Promise<void> {
  const req = await one<Pick<FosaTransaction, 'status' | 'created_by'>>(
    'SELECT status, created_by FROM fosa_transaction WHERE no = ?', no,
  );
  if (!req) throw new AppError('Document not found', 'NOT_FOUND');
  if (req.status !== 'Pending Approval') throw new AppError('Only a document pending approval can be recalled', 'VALIDATION');
  const routed = await findPendingRoutedTask('FOSA_TRANSACTION', no);
  const requestedBy = routed?.requested_by ?? req.created_by;
  if (requestedBy !== user.username) throw new AppError('Only the person who submitted this document can recall it', 'NOT_REQUESTER');
  await run("UPDATE fosa_transaction SET status = 'Open' WHERE no = ?", no);
  await audit(user, 'FOSA_TRANSACTION_CANCEL_APPROVAL', 'fosa_transaction', no, {});
}

export async function approveFosaTransaction(no: string, user: Actor): Promise<void> {
  const req = await one<FosaTransaction>('SELECT * FROM fosa_transaction WHERE no = ?', no);
  if (!req) throw new AppError('Document not found', 'NOT_FOUND');
  if (req.status !== 'Pending Approval') throw new AppError('Only a document pending approval can be approved', 'VALIDATION');
  await run("UPDATE fosa_transaction SET status = 'Approved', decision_reason = NULL WHERE no = ?", no);
  await audit(user, 'FOSA_TRANSACTION_APPROVE', 'fosa_transaction', no, {});
}

export async function rejectFosaTransaction(no: string, reason: string | null, user: Actor): Promise<void> {
  if (!reason || !reason.trim()) throw new AppError('A reason is required to reject a document', 'VALIDATION');
  const req = await one<FosaTransaction>('SELECT * FROM fosa_transaction WHERE no = ?', no);
  if (!req) throw new AppError('Document not found', 'NOT_FOUND');
  if (req.status !== 'Pending Approval') throw new AppError('Only a document pending approval can be rejected', 'VALIDATION');
  await run("UPDATE fosa_transaction SET status = 'Open', decision_reason = ? WHERE no = ?", reason, no);
  await audit(user, 'FOSA_TRANSACTION_REJECT', 'fosa_transaction', no, { reason });
}

/* ------------------------------------------------------------------- posting */

const POSTING_NARRATION: Record<FosaDocumentType, string> = {
  RECEIVE_FROM_BANK: 'Receive cash from Main Bank',
  TREASURY_REQUEST: 'Issue till cash from Treasury',
  INTER_TILL: 'Inter-till cash transfer',
  TREASURY_RETURN: 'Return till cash to Treasury',
  SEND_TO_BANK: 'Return cash to Main Bank',
};

/**
 * AL FOSAManagement.PostFOSATransaction — one balanced journal: credit the source bank
 * account's control G/L, debit the destination's, for the full amount. postJournal() maintains
 * both bank_account balances and their reconciliation subledger entries. The capacity guard is
 * re-run here, since balances may have moved since approval.
 */
export async function processFosaTransaction(no: string, user: Actor): Promise<{ journalNo: string; amount: Cents }> {
  return tx(async () => {
    const req = await one<FosaTransaction>('SELECT * FROM fosa_transaction WHERE no = ?', no);
    if (!req) throw new AppError('Document not found', 'NOT_FOUND');
    if (req.status !== 'Approved') throw new AppError('Only an approved document can be posted', 'VALIDATION');
    if (req.posted) throw new AppError('This document has already been posted', 'VALIDATION');
    await assertCapacity(req.source_bank_account_id, req.destination_bank_account_id, req.amount);
    await assertDenominationsBalance('FOSA', no, req.amount);

    const [source, destination] = await Promise.all([
      one<{ gl_account_id: number }>('SELECT gl_account_id FROM bank_account WHERE id = ?', req.source_bank_account_id),
      one<{ gl_account_id: number }>('SELECT gl_account_id FROM bank_account WHERE id = ?', req.destination_bank_account_id),
    ]);
    if (!source || !destination) throw new AppError('A bank account on this document no longer exists', 'NOT_FOUND');

    const vd = await resolvePostingDate(user);
    const narration = `${POSTING_NARRATION[req.document_type]} — ${no}`;
    const j = await postJournal({
      valueDate: vd, module: 'FOSA', eventType: req.document_type, description: narration, reference: no,
      globalDimension1Id: req.global_dimension_1_id, globalDimension2Id: req.global_dimension_2_id,
      user, idempotencyKey: `FOSA_TRANSACTION-${no}`,
      lines: [
        { account: source.gl_account_id, debit: 0, credit: Number(req.amount), narration },
        { account: destination.gl_account_id, debit: Number(req.amount), credit: 0, narration },
      ],
    });

    await run(
      `UPDATE fosa_transaction SET status = 'Processed', posted = true, journal_id = ?, posted_at = ?, posted_by = ?
       WHERE no = ?`,
      j.id, new Date().toISOString(), user.username, no,
    );
    await audit(user, 'FOSA_TRANSACTION_POST', 'fosa_transaction', no, { journalNo: j.journal_no });
    return { journalNo: j.journal_no, amount: Number(req.amount) };
  });
}

export async function getFosaTransactionJournal(no: string): Promise<JournalDetail | null> {
  const row = await one<{ journal_id: number | null }>('SELECT journal_id FROM fosa_transaction WHERE no = ?', no);
  if (!row?.journal_id) return null;
  return getJournal(row.journal_id);
}
