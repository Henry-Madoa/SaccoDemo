/*
 * Cash Receipt Journal — a maker-checker batch of customer payments (Business Central General
 * Journal, payment lines). Posting writes one Cust. Ledger Entry (Payment) per line, applies it
 * against the named open invoice / oldest-open-first (lib/custLedger.ts), and posts one balanced
 * journal: Dr the Bank Account, Cr each customer's Receivables control account. postJournal()'s
 * automatic bank_account_ledger_entry gives the receipt a reconcilable bank movement for free.
 *
 * Lifecycle: Open -> Pending Approval -> Approved -> Processed (verbatim shape of fa_journal_line).
 */
import { one, all, run, tx, nextSequence, audit, hasAnyRow } from './db.ts';
import { AppError } from './errors.ts';
import { postJournal } from './accounting.ts';
import { getEffectivePostingRange } from './postingDates.ts';
import { createCustLedgerEntry, applyCustomerEntries, recomputeCustomerBalance } from './custLedger.ts';
import { findMatchingWorkflow, findPendingRoutedTask, pickConditionFields, startWorkflow } from './workflow.ts';
import { buildFilterClause, type FilterCondition, type FilterFieldDef } from './listFilters.ts';
import { buildOrderClause, type SortState } from './listSort.ts';
import type {
  Actor, CashReceiptDetail, CashReceiptHeader, CashReceiptHeaderView, CashReceiptLineView, Cents, IsoDate,
} from './types.ts';

export type CashReceiptView = 'open' | 'pending' | 'approved' | 'processed';

const VIEW_CLAUSE: Record<CashReceiptView, string> = {
  open: "crh.status = 'Open'",
  pending: "crh.status = 'Pending Approval'",
  approved: "crh.status = 'Approved'",
  processed: "crh.status = 'Processed'",
};

const SELECT_ROW = `
  SELECT crh.*, ba.code AS bank_account_code, ba.name AS bank_account_name,
         (SELECT COUNT(*) FROM cash_receipt_line l WHERE l.cash_receipt_header_id = crh.id) AS line_count,
         j.journal_no AS journal_no
  FROM cash_receipt_header crh
  JOIN bank_account ba ON ba.id = crh.bank_account_id
  LEFT JOIN journal j ON j.id = crh.journal_id`;

export const CASH_RECEIPT_FILTER_FIELDS: FilterFieldDef[] = [
  { key: 'no', label: 'No.', type: 'text', column: 'crh.no' },
  { key: 'bank_account_id', label: 'Bank Account', type: 'select', column: 'crh.bank_account_id' },
  { key: 'posting_date', label: 'Posting Date', type: 'date', column: 'crh.posting_date' },
  { key: 'created_by', label: 'Created By', type: 'text', column: 'crh.created_by' },
];

const SORT_COLUMNS: Record<string, string> = {
  no: 'crh.no', posting_date: 'crh.posting_date', amount: 'crh.total_amount', status: 'crh.status',
};

export interface ListCashReceiptsOptions {
  view?: CashReceiptView; search?: string; filters?: FilterCondition[]; sort?: SortState | null;
}

export const listCashReceipts = (
  { view, search = '', filters = [], sort = null }: ListCashReceiptsOptions = {},
): Promise<CashReceiptHeaderView[]> => {
  const { clause, params } = buildFilterClause(CASH_RECEIPT_FILTER_FIELDS, filters);
  const orderBy = buildOrderClause(SORT_COLUMNS, sort, 'crh.no DESC');
  return all<CashReceiptHeaderView>(
    `${SELECT_ROW}
     WHERE (crh.no LIKE @like OR crh.description LIKE @like)
       ${view ? `AND ${VIEW_CLAUSE[view]}` : ''}
       ${clause}
     ${orderBy}`,
    { like: `%${String(search).trim()}%`, ...params },
  );
};

export async function getCashReceipt(no: string): Promise<CashReceiptDetail | undefined> {
  const header = await one<CashReceiptHeaderView>(`${SELECT_ROW} WHERE crh.no = ?`, no);
  if (!header) return undefined;
  const lines = await all<CashReceiptLineView>(
    `SELECT l.*, c.no AS customer_no, c.name AS customer_name
     FROM cash_receipt_line l JOIN customer c ON c.id = l.customer_id
     WHERE l.cash_receipt_header_id = ? ORDER BY l.line_no`,
    header.id,
  );
  return { ...header, lines };
}

export const hasAnyCashReceipts = (view?: CashReceiptView): Promise<boolean> =>
  hasAnyRow('cash_receipt_header crh', view ? VIEW_CLAUSE[view] : undefined);

/* -------------------------------------------------------------------- create / edit */

export interface CashReceiptLineInput {
  customerId: number;
  amount: Cents;
  paymentMethodCode?: string | null;
  appliesToDocNo?: string | null;
  externalDocumentNo?: string | null;
  description?: string | null;
}
export interface CashReceiptInput {
  postingDate: IsoDate;
  documentDate: IsoDate;
  bankAccountId: number;
  description?: string | null;
  lines: CashReceiptLineInput[];
}

async function assertHeader(input: CashReceiptInput): Promise<void> {
  if (!input.postingDate) throw new AppError('A posting date is required', 'VALIDATION');
  if (!input.bankAccountId) throw new AppError('A bank account is required', 'VALIDATION');
  const ba = await one<{ status: string }>('SELECT status FROM bank_account WHERE id = ?', input.bankAccountId);
  if (!ba || ba.status !== 'ACTIVE') throw new AppError('That bank account is not active', 'VALIDATION');
}

export async function createCashReceipt(input: CashReceiptInput, user: Actor): Promise<{ no: string }> {
  await assertHeader(input);
  const no = await nextSequence('CASH_RECEIPT');
  return tx(async () => {
    const info = await run(
      `INSERT INTO cash_receipt_header (no, posting_date, document_date, bank_account_id, description, created_at, created_by)
       VALUES (?,?,?,?,?,?,?)`,
      no, input.postingDate, input.documentDate || input.postingDate, input.bankAccountId,
      input.description?.trim() || null, new Date().toISOString(), user.username,
    );
    await replaceLines(Number(info.lastInsertRowid), no, input.lines);
    await audit(user, 'CASH_RECEIPT_CREATE', 'cash_receipt_header', no, { lineCount: input.lines.length });
    return { no };
  });
}

export async function updateCashReceipt(no: string, input: CashReceiptInput, user: Actor): Promise<void> {
  const before = await one<CashReceiptHeader>('SELECT * FROM cash_receipt_header WHERE no = ?', no);
  if (!before) throw new AppError('Cash receipt not found', 'NOT_FOUND');
  if (before.status !== 'Open') throw new AppError('Only an open cash receipt can be edited', 'VALIDATION');
  if (before.created_by !== user.username) throw new AppError('Only the person who created this can edit it', 'NOT_CREATOR');
  await assertHeader(input);
  await tx(async () => {
    await run(
      'UPDATE cash_receipt_header SET posting_date = ?, document_date = ?, bank_account_id = ?, description = ? WHERE id = ?',
      input.postingDate, input.documentDate || input.postingDate, input.bankAccountId, input.description?.trim() || null, before.id,
    );
    await replaceLines(before.id, no, input.lines);
  });
  await audit(user, 'CASH_RECEIPT_UPDATE', 'cash_receipt_header', no, {});
}

async function replaceLines(headerId: number, headerNo: string, lines: CashReceiptLineInput[]): Promise<void> {
  await run('DELETE FROM cash_receipt_line WHERE cash_receipt_header_id = ?', headerId);
  let lineNo = 10000;
  let total = 0;
  for (const l of lines) {
    if (!l.customerId || !(l.amount > 0)) continue;
    if (!(await hasAnyRow('customer', 'id = ?', l.customerId))) throw new AppError('Unknown customer on a receipt line', 'VALIDATION');
    total += Math.round(l.amount);
    await run(
      `INSERT INTO cash_receipt_line
         (cash_receipt_header_id, line_no, customer_id, amount, payment_method_code, document_no, applies_to_doc_no, external_document_no, description)
       VALUES (?,?,?,?,?,?,?,?,?)`,
      headerId, lineNo, l.customerId, Math.round(l.amount), l.paymentMethodCode || null, headerNo,
      l.appliesToDocNo?.trim() || null, l.externalDocumentNo?.trim() || null, l.description?.trim() || null,
    );
    lineNo += 10000;
  }
  await run('UPDATE cash_receipt_header SET total_amount = ? WHERE id = ?', total, headerId);
}

export async function deleteCashReceipt(no: string, user: Actor): Promise<void> {
  const before = await one<Pick<CashReceiptHeader, 'status' | 'created_by'>>('SELECT status, created_by FROM cash_receipt_header WHERE no = ?', no);
  if (!before) throw new AppError('Cash receipt not found', 'NOT_FOUND');
  if (before.status !== 'Open') throw new AppError('Only an open cash receipt can be deleted', 'VALIDATION');
  if (before.created_by !== user.username) throw new AppError('Only the person who created this can delete it', 'NOT_CREATOR');
  await run('DELETE FROM cash_receipt_header WHERE no = ?', no);
  await audit(user, 'CASH_RECEIPT_DELETE', 'cash_receipt_header', no, {});
}

/* --------------------------------------------------------------- maker-checker */

export async function submitCashReceipt(no: string, user: Actor): Promise<{ autoApproved: boolean }> {
  const req = await one<CashReceiptHeader>('SELECT * FROM cash_receipt_header WHERE no = ?', no);
  if (!req) throw new AppError('Cash receipt not found', 'NOT_FOUND');
  if (req.status !== 'Open') throw new AppError('Only an open cash receipt can be submitted', 'VALIDATION');
  if (req.total_amount <= 0) throw new AppError('Add at least one receipt line before submitting', 'VALIDATION');
  const matched = await findMatchingWorkflow('CASH_RECEIPT', await pickConditionFields('CASH_RECEIPT', req));
  if (!matched) throw new AppError('There is no enabled workflow for this document', 'NO_WORKFLOW');
  await tx(async () => {
    await run("UPDATE cash_receipt_header SET status = 'Pending Approval' WHERE no = ?", no);
    await startWorkflow(matched.workflow, matched.steps, {
      documentType: 'CASH_RECEIPT', entityId: no, requestedBy: user.username, amount: Number(req.total_amount),
    });
  });
  const after = await one<{ status: string }>('SELECT status FROM cash_receipt_header WHERE no = ?', no);
  return { autoApproved: after?.status === 'Approved' };
}

export async function cancelCashReceiptApproval(no: string, user: Actor): Promise<void> {
  const req = await one<Pick<CashReceiptHeader, 'status' | 'created_by'>>('SELECT status, created_by FROM cash_receipt_header WHERE no = ?', no);
  if (!req) throw new AppError('Cash receipt not found', 'NOT_FOUND');
  if (req.status !== 'Pending Approval') throw new AppError('Only a receipt pending approval can be recalled', 'VALIDATION');
  const routed = await findPendingRoutedTask('CASH_RECEIPT', no);
  if ((routed?.requested_by ?? req.created_by) !== user.username) throw new AppError('Only the person who submitted this can recall it', 'NOT_REQUESTER');
  await run("UPDATE cash_receipt_header SET status = 'Open' WHERE no = ?", no);
  await audit(user, 'CASH_RECEIPT_CANCEL_APPROVAL', 'cash_receipt_header', no, {});
}

export async function approveCashReceipt(no: string, user: Actor): Promise<void> {
  const req = await one<CashReceiptHeader>('SELECT * FROM cash_receipt_header WHERE no = ?', no);
  if (!req) throw new AppError('Cash receipt not found', 'NOT_FOUND');
  if (req.status !== 'Pending Approval') throw new AppError('Only a receipt pending approval can be approved', 'VALIDATION');
  await run("UPDATE cash_receipt_header SET status = 'Approved', decision_reason = NULL WHERE no = ?", no);
  await audit(user, 'CASH_RECEIPT_APPROVE', 'cash_receipt_header', no, {});
}

export async function rejectCashReceipt(no: string, reason: string | null, user: Actor): Promise<void> {
  if (!reason?.trim()) throw new AppError('A reason is required to reject a cash receipt', 'VALIDATION');
  const req = await one<CashReceiptHeader>('SELECT * FROM cash_receipt_header WHERE no = ?', no);
  if (!req) throw new AppError('Cash receipt not found', 'NOT_FOUND');
  if (req.status !== 'Pending Approval') throw new AppError('Only a receipt pending approval can be rejected', 'VALIDATION');
  await run("UPDATE cash_receipt_header SET status = 'Open', decision_reason = ? WHERE no = ?", reason, no);
  await audit(user, 'CASH_RECEIPT_REJECT', 'cash_receipt_header', no, { reason });
}

export async function reopenCashReceipt(no: string, user: Actor): Promise<void> {
  const req = await one<CashReceiptHeader>('SELECT * FROM cash_receipt_header WHERE no = ?', no);
  if (!req) throw new AppError('Cash receipt not found', 'NOT_FOUND');
  if (req.status !== 'Approved' || req.posted) throw new AppError('Only an approved, unposted receipt can be reopened', 'VALIDATION');
  await run("UPDATE cash_receipt_header SET status = 'Open' WHERE no = ?", no);
  await audit(user, 'CASH_RECEIPT_REOPEN', 'cash_receipt_header', no, {});
}

/* ------------------------------------------------------------------- posting */

export async function postCashReceipt(no: string, user: Actor): Promise<{ journalNo: string | null; applied: number }> {
  return tx(async () => {
    const header = await one<CashReceiptHeader>('SELECT * FROM cash_receipt_header WHERE no = ?', no);
    if (!header) throw new AppError('Cash receipt not found', 'NOT_FOUND');
    if (header.posted) throw new AppError('This cash receipt has already been posted', 'VALIDATION');
    if (header.status !== 'Approved') throw new AppError('Only an approved cash receipt can be posted', 'VALIDATION');

    const vd = header.posting_date;
    const range = await getEffectivePostingRange(user.id);
    if (range.from && vd < range.from) throw new AppError(`Posting date ${vd} is before your earliest allowed date (${range.from})`, 'VALIDATION');
    if (range.to && vd > range.to) throw new AppError(`Posting date ${vd} is after your latest allowed date (${range.to})`, 'VALIDATION');

    const bank = await one<{ gl_account_id: number; code: string }>('SELECT gl_account_id, code FROM bank_account WHERE id = ?', header.bank_account_id);
    if (!bank) throw new AppError('Bank account not found', 'NOT_FOUND');

    const lines = await all<{
      id: number; line_no: number; customer_id: number; amount: Cents; document_no: string | null; applies_to_doc_no: string | null;
    }>('SELECT id, line_no, customer_id, amount, document_no, applies_to_doc_no FROM cash_receipt_line WHERE cash_receipt_header_id = ? ORDER BY line_no', header.id);
    if (!lines.length) throw new AppError('This cash receipt has no lines', 'VALIDATION');

    // Group the receivables credit by customer posting group.
    const glLines: { account: number; debit: Cents; credit: Cents; narration: string }[] = [
      { account: bank.gl_account_id, debit: header.total_amount, credit: 0, narration: `Cash Receipt ${no}` },
    ];
    const creditByAccount = new Map<number, number>();
    let applied = 0;
    const touchedCustomers = new Set<number>();

    for (const line of lines) {
      const cust = await one<{ no: string; customer_posting_group_code: string | null }>(
        'SELECT no, customer_posting_group_code FROM customer WHERE id = ?', line.customer_id,
      );
      if (!cust?.customer_posting_group_code) throw new AppError(`Customer ${cust?.no ?? line.customer_id} has no Customer Posting Group`, 'VALIDATION');
      const pg = await one<{ receivables_account_id: number }>(
        'SELECT receivables_account_id FROM customer_posting_group WHERE code = ?', cust.customer_posting_group_code,
      );
      if (!pg) throw new AppError('Customer Posting Group setup is missing', 'VALIDATION');
      creditByAccount.set(pg.receivables_account_id, (creditByAccount.get(pg.receivables_account_id) ?? 0) + line.amount);

      const paymentEntryId = await createCustLedgerEntry({
        customerId: line.customer_id, postingDate: vd, documentType: 'Payment',
        documentNo: line.document_no || no, description: `Cash Receipt ${no}`,
        amount: -line.amount, sourceType: 'Cash Receipt', sourceId: header.id,
      });
      touchedCustomers.add(line.customer_id);

      // Apply the payment.
      const targetIds: number[] = [];
      if (line.applies_to_doc_no) {
        const target = await one<{ id: number }>(
          "SELECT id FROM cust_ledger_entry WHERE customer_id = ? AND document_no = ? AND open = 1 AND positive = 1 ORDER BY id LIMIT 1",
          line.customer_id, line.applies_to_doc_no,
        );
        if (target) targetIds.push(target.id);
      }
      const res = await applyCustomerEntries(
        { applyingEntryId: paymentEntryId, appliedTo: targetIds.length ? targetIds : 'auto', postingDate: vd }, user,
      );
      applied += res.closedEntryNos.length;
    }

    for (const [account, amount] of creditByAccount) {
      glLines.push({ account, debit: 0, credit: amount, narration: `Cash Receipt ${no}` });
    }

    const j = await postJournal({
      valueDate: vd, module: 'RECEIVABLES', eventType: 'CASH_RECEIPT',
      description: `Cash Receipt ${no} — ${bank.code}`, reference: no, user,
      idempotencyKey: `CASH_RECEIPT-${no}`,
      lines: glLines,
    });

    // Re-link the payment cust_ledger_entry rows to the journal.
    await run("UPDATE cust_ledger_entry SET journal_id = ? WHERE source_type = 'Cash Receipt' AND source_id = ? AND journal_id IS NULL", j.id, header.id);
    for (const cid of touchedCustomers) await recomputeCustomerBalance(cid);

    await run(
      `UPDATE cash_receipt_header SET status = 'Processed', posted = true, journal_id = ?, posted_at = ?, posted_by = ? WHERE no = ?`,
      j.id, new Date().toISOString(), user.username, no,
    );
    await audit(user, 'CASH_RECEIPT_POST', 'cash_receipt_header', no, { journalNo: j.journal_no, applied });
    return { journalNo: j.journal_no, applied };
  });
}
