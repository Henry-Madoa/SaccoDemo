/*
 * Payment Journal — a maker-checker batch of vendor payments (Business Central General Journal,
 * vendor payment lines) plus BC's "Suggest Vendor Payments" batch (Report 393). Posting writes
 * one Vendor Ledger Entry (Payment) per line, applies it against the named open invoice /
 * oldest-open-first (lib/vendLedger.ts), and posts one balanced journal: Dr each vendor's
 * Payables control account, Cr the Bank Account. The mirror of lib/cashReceipts.ts.
 *
 * Lifecycle: Open -> Pending Approval -> Approved -> Processed.
 */
import { one, all, run, tx, nextSequence, audit, hasAnyRow } from './db.ts';
import { AppError } from './errors.ts';
import { postJournal } from './accounting.ts';
import { getEffectivePostingRange } from './postingDates.ts';
import { createVendorLedgerEntry, applyVendorEntries, recomputeVendorBalance } from './vendLedger.ts';
import { findMatchingWorkflow, findPendingRoutedTask, pickConditionFields, startWorkflow } from './workflow.ts';
import { buildFilterClause, type FilterCondition, type FilterFieldDef } from './listFilters.ts';
import { buildOrderClause, type SortState } from './listSort.ts';
import type {
  Actor, Cents, IsoDate, PaymentJournalDetail, PaymentJournalHeader, PaymentJournalHeaderView, PaymentJournalLineView,
} from './types.ts';

export type PaymentJournalView = 'open' | 'pending' | 'approved' | 'processed';

const VIEW_CLAUSE: Record<PaymentJournalView, string> = {
  open: "pjh.status = 'Open'",
  pending: "pjh.status = 'Pending Approval'",
  approved: "pjh.status = 'Approved'",
  processed: "pjh.status = 'Processed'",
};

const SELECT_ROW = `
  SELECT pjh.*, ba.code AS bank_account_code, ba.name AS bank_account_name,
         (SELECT COUNT(*) FROM payment_journal_line l WHERE l.payment_journal_header_id = pjh.id) AS line_count,
         j.journal_no AS journal_no
  FROM payment_journal_header pjh
  JOIN bank_account ba ON ba.id = pjh.bank_account_id
  LEFT JOIN journal j ON j.id = pjh.journal_id`;

export const PAYMENT_JOURNAL_FILTER_FIELDS: FilterFieldDef[] = [
  { key: 'no', label: 'No.', type: 'text', column: 'pjh.no' },
  { key: 'bank_account_id', label: 'Bank Account', type: 'select', column: 'pjh.bank_account_id' },
  { key: 'posting_date', label: 'Posting Date', type: 'date', column: 'pjh.posting_date' },
  { key: 'created_by', label: 'Created By', type: 'text', column: 'pjh.created_by' },
];

const SORT_COLUMNS: Record<string, string> = {
  no: 'pjh.no', posting_date: 'pjh.posting_date', amount: 'pjh.total_amount', status: 'pjh.status',
};

export interface ListPaymentJournalsOptions {
  view?: PaymentJournalView; search?: string; filters?: FilterCondition[]; sort?: SortState | null;
}

export const listPaymentJournals = (
  { view, search = '', filters = [], sort = null }: ListPaymentJournalsOptions = {},
): Promise<PaymentJournalHeaderView[]> => {
  const { clause, params } = buildFilterClause(PAYMENT_JOURNAL_FILTER_FIELDS, filters);
  const orderBy = buildOrderClause(SORT_COLUMNS, sort, 'pjh.no DESC');
  return all<PaymentJournalHeaderView>(
    `${SELECT_ROW}
     WHERE (pjh.no LIKE @like OR pjh.description LIKE @like)
       ${view ? `AND ${VIEW_CLAUSE[view]}` : ''}
       ${clause}
     ${orderBy}`,
    { like: `%${String(search).trim()}%`, ...params },
  );
};

export async function getPaymentJournal(no: string): Promise<PaymentJournalDetail | undefined> {
  const header = await one<PaymentJournalHeaderView>(`${SELECT_ROW} WHERE pjh.no = ?`, no);
  if (!header) return undefined;
  const lines = await all<PaymentJournalLineView>(
    `SELECT l.*, v.no AS vendor_no, v.name AS vendor_name
     FROM payment_journal_line l JOIN vendor v ON v.id = l.vendor_id
     WHERE l.payment_journal_header_id = ? ORDER BY l.line_no`,
    header.id,
  );
  return { ...header, lines };
}

export const hasAnyPaymentJournals = (view?: PaymentJournalView): Promise<boolean> =>
  hasAnyRow('payment_journal_header pjh', view ? VIEW_CLAUSE[view] : undefined);

/* -------------------------------------------------------------------- create / edit */

export interface PaymentJournalLineInput {
  vendorId: number;
  amount: Cents;
  paymentMethodCode?: string | null;
  appliesToDocNo?: string | null;
  externalDocumentNo?: string | null;
  description?: string | null;
  takePmtDiscount?: boolean;
}
export interface PaymentJournalInput {
  postingDate: IsoDate;
  documentDate: IsoDate;
  bankAccountId: number;
  description?: string | null;
  lines: PaymentJournalLineInput[];
}

async function assertHeader(input: PaymentJournalInput): Promise<void> {
  if (!input.postingDate) throw new AppError('A posting date is required', 'VALIDATION');
  if (!input.bankAccountId) throw new AppError('A bank account is required', 'VALIDATION');
  const ba = await one<{ status: string }>('SELECT status FROM bank_account WHERE id = ?', input.bankAccountId);
  if (!ba || ba.status !== 'ACTIVE') throw new AppError('That bank account is not active', 'VALIDATION');
}

export async function createPaymentJournal(input: PaymentJournalInput, user: Actor): Promise<{ no: string }> {
  await assertHeader(input);
  const no = await nextSequence('PAYMENT_JOURNAL');
  return tx(async () => {
    const info = await run(
      `INSERT INTO payment_journal_header (no, posting_date, document_date, bank_account_id, description, created_at, created_by)
       VALUES (?,?,?,?,?,?,?)`,
      no, input.postingDate, input.documentDate || input.postingDate, input.bankAccountId,
      input.description?.trim() || null, new Date().toISOString(), user.username,
    );
    await replaceLines(Number(info.lastInsertRowid), no, input.lines);
    await audit(user, 'PAYMENT_JOURNAL_CREATE', 'payment_journal_header', no, { lineCount: input.lines.length });
    return { no };
  });
}

export async function updatePaymentJournal(no: string, input: PaymentJournalInput, user: Actor): Promise<void> {
  const before = await one<PaymentJournalHeader>('SELECT * FROM payment_journal_header WHERE no = ?', no);
  if (!before) throw new AppError('Payment journal not found', 'NOT_FOUND');
  if (before.status !== 'Open') throw new AppError('Only an open payment journal can be edited', 'VALIDATION');
  if (before.created_by !== user.username) throw new AppError('Only the person who created this can edit it', 'NOT_CREATOR');
  await assertHeader(input);
  await tx(async () => {
    await run(
      'UPDATE payment_journal_header SET posting_date = ?, document_date = ?, bank_account_id = ?, description = ? WHERE id = ?',
      input.postingDate, input.documentDate || input.postingDate, input.bankAccountId, input.description?.trim() || null, before.id,
    );
    await replaceLines(before.id, no, input.lines);
  });
  await audit(user, 'PAYMENT_JOURNAL_UPDATE', 'payment_journal_header', no, {});
}

async function replaceLines(headerId: number, headerNo: string, lines: PaymentJournalLineInput[]): Promise<void> {
  await run('DELETE FROM payment_journal_line WHERE payment_journal_header_id = ?', headerId);
  let lineNo = 10000;
  let total = 0;
  for (const l of lines) {
    if (!l.vendorId || !(l.amount > 0)) continue;
    if (!(await hasAnyRow('vendor', 'id = ?', l.vendorId))) throw new AppError('Unknown vendor on a payment line', 'VALIDATION');
    total += Math.round(l.amount);
    await run(
      `INSERT INTO payment_journal_line
         (payment_journal_header_id, line_no, vendor_id, amount, payment_method_code, document_no, applies_to_doc_no, external_document_no, description, take_pmt_discount)
       VALUES (?,?,?,?,?,?,?,?,?,?)`,
      headerId, lineNo, l.vendorId, Math.round(l.amount), l.paymentMethodCode || null, headerNo,
      l.appliesToDocNo?.trim() || null, l.externalDocumentNo?.trim() || null, l.description?.trim() || null,
      l.takePmtDiscount ? 1 : 0,
    );
    lineNo += 10000;
  }
  await run('UPDATE payment_journal_header SET total_amount = ? WHERE id = ?', total, headerId);
}

export async function deletePaymentJournal(no: string, user: Actor): Promise<void> {
  const before = await one<Pick<PaymentJournalHeader, 'status' | 'created_by'>>('SELECT status, created_by FROM payment_journal_header WHERE no = ?', no);
  if (!before) throw new AppError('Payment journal not found', 'NOT_FOUND');
  if (before.status !== 'Open') throw new AppError('Only an open payment journal can be deleted', 'VALIDATION');
  if (before.created_by !== user.username) throw new AppError('Only the person who created this can delete it', 'NOT_CREATOR');
  await run('DELETE FROM payment_journal_header WHERE no = ?', no);
  await audit(user, 'PAYMENT_JOURNAL_DELETE', 'payment_journal_header', no, {});
}

/* ------------------------------------------------ Suggest Vendor Payments (BC Report 393) */

export interface SuggestVendorPaymentsInput {
  lastPaymentDate: IsoDate;
  findPaymentDiscounts: boolean;
  bankAccountId: number;
  postingDate?: IsoDate;
  onlyVendorId?: number | null;
}

export async function suggestVendorPayments(input: SuggestVendorPaymentsInput, user: Actor): Promise<{ no: string; lineCount: number }> {
  if (!input.lastPaymentDate) throw new AppError('A last payment date is required', 'VALIDATION');
  await assertHeader({ postingDate: input.postingDate || input.lastPaymentDate, documentDate: input.postingDate || input.lastPaymentDate, bankAccountId: input.bankAccountId, lines: [] });

  const open = await all<{
    id: number; vendor_id: number; document_no: string; remaining_amount: Cents; due_date: IsoDate | null;
    pmt_discount_date: IsoDate | null; original_pmt_disc_possible: Cents; original_amount: Cents;
  }>(
    `SELECT e.id, e.vendor_id, e.document_no, e.remaining_amount, e.due_date, e.pmt_discount_date,
            e.original_pmt_disc_possible, e.original_amount
     FROM vendor_ledger_entry e
     JOIN vendor v ON v.id = e.vendor_id
     WHERE e.open = 1 AND e.positive = 1 AND e.remaining_amount > 0
       AND (e.on_hold IS NULL OR e.on_hold = '')
       AND (v.blocked IS NULL OR v.blocked NOT IN ('Payment', 'All'))
       ${input.onlyVendorId ? 'AND e.vendor_id = @onlyVendorId' : ''}
       AND (
         (e.due_date IS NOT NULL AND e.due_date <= @lastDate)
         ${input.findPaymentDiscounts ? 'OR (e.pmt_discount_date IS NOT NULL AND e.pmt_discount_date <= @lastDate AND e.original_pmt_disc_possible > 0)' : ''}
       )
     ORDER BY e.vendor_id, e.due_date NULLS LAST, e.id`,
    { lastDate: input.lastPaymentDate, onlyVendorId: input.onlyVendorId },
  );
  if (!open.length) throw new AppError('No open vendor invoices match — nothing to suggest', 'VALIDATION');

  const lines: PaymentJournalLineInput[] = open.map((e) => {
    const takeDiscount = input.findPaymentDiscounts
      && !!e.pmt_discount_date && e.pmt_discount_date <= input.lastPaymentDate
      && e.original_pmt_disc_possible > 0 && Math.abs(e.remaining_amount) === e.original_amount;
    const discount = takeDiscount ? Math.min(e.original_pmt_disc_possible, e.remaining_amount) : 0;
    return {
      vendorId: e.vendor_id, amount: e.remaining_amount - discount, appliesToDocNo: e.document_no,
      description: `Payment — ${e.document_no}`, takePmtDiscount: takeDiscount,
    };
  }).filter((l) => l.amount > 0);

  const created = await createPaymentJournal({
    postingDate: input.postingDate || input.lastPaymentDate,
    documentDate: input.postingDate || input.lastPaymentDate,
    bankAccountId: input.bankAccountId,
    description: `Suggested payments as of ${input.lastPaymentDate}`,
    lines,
  }, user);
  await audit(user, 'SUGGEST_VENDOR_PAYMENTS', 'payment_journal_header', created.no, { lineCount: lines.length });
  return { no: created.no, lineCount: lines.length };
}

/* --------------------------------------------------------------- maker-checker */

export async function submitPaymentJournal(no: string, user: Actor): Promise<{ autoApproved: boolean }> {
  const req = await one<PaymentJournalHeader>('SELECT * FROM payment_journal_header WHERE no = ?', no);
  if (!req) throw new AppError('Payment journal not found', 'NOT_FOUND');
  if (req.status !== 'Open') throw new AppError('Only an open payment journal can be submitted', 'VALIDATION');
  if (req.total_amount <= 0) throw new AppError('Add at least one payment line before submitting', 'VALIDATION');
  const matched = await findMatchingWorkflow('PAYMENT_JOURNAL', await pickConditionFields('PAYMENT_JOURNAL', req));
  if (!matched) throw new AppError('There is no enabled workflow for this document', 'NO_WORKFLOW');
  await tx(async () => {
    await run("UPDATE payment_journal_header SET status = 'Pending Approval' WHERE no = ?", no);
    await startWorkflow(matched.workflow, matched.steps, {
      documentType: 'PAYMENT_JOURNAL', entityId: no, requestedBy: user.username, amount: Number(req.total_amount),
    });
  });
  const after = await one<{ status: string }>('SELECT status FROM payment_journal_header WHERE no = ?', no);
  return { autoApproved: after?.status === 'Approved' };
}

export async function cancelPaymentJournalApproval(no: string, user: Actor): Promise<void> {
  const req = await one<Pick<PaymentJournalHeader, 'status' | 'created_by'>>('SELECT status, created_by FROM payment_journal_header WHERE no = ?', no);
  if (!req) throw new AppError('Payment journal not found', 'NOT_FOUND');
  if (req.status !== 'Pending Approval') throw new AppError('Only a payment journal pending approval can be recalled', 'VALIDATION');
  const routed = await findPendingRoutedTask('PAYMENT_JOURNAL', no);
  if ((routed?.requested_by ?? req.created_by) !== user.username) throw new AppError('Only the person who submitted this can recall it', 'NOT_REQUESTER');
  await run("UPDATE payment_journal_header SET status = 'Open' WHERE no = ?", no);
  await audit(user, 'PAYMENT_JOURNAL_CANCEL_APPROVAL', 'payment_journal_header', no, {});
}

export async function approvePaymentJournal(no: string, user: Actor): Promise<void> {
  const req = await one<PaymentJournalHeader>('SELECT * FROM payment_journal_header WHERE no = ?', no);
  if (!req) throw new AppError('Payment journal not found', 'NOT_FOUND');
  if (req.status !== 'Pending Approval') throw new AppError('Only a payment journal pending approval can be approved', 'VALIDATION');
  await run("UPDATE payment_journal_header SET status = 'Approved', decision_reason = NULL WHERE no = ?", no);
  await audit(user, 'PAYMENT_JOURNAL_APPROVE', 'payment_journal_header', no, {});
}

export async function rejectPaymentJournal(no: string, reason: string | null, user: Actor): Promise<void> {
  if (!reason?.trim()) throw new AppError('A reason is required to reject a payment journal', 'VALIDATION');
  const req = await one<PaymentJournalHeader>('SELECT * FROM payment_journal_header WHERE no = ?', no);
  if (!req) throw new AppError('Payment journal not found', 'NOT_FOUND');
  if (req.status !== 'Pending Approval') throw new AppError('Only a payment journal pending approval can be rejected', 'VALIDATION');
  await run("UPDATE payment_journal_header SET status = 'Open', decision_reason = ? WHERE no = ?", reason, no);
  await audit(user, 'PAYMENT_JOURNAL_REJECT', 'payment_journal_header', no, { reason });
}

export async function reopenPaymentJournal(no: string, user: Actor): Promise<void> {
  const req = await one<PaymentJournalHeader>('SELECT * FROM payment_journal_header WHERE no = ?', no);
  if (!req) throw new AppError('Payment journal not found', 'NOT_FOUND');
  if (req.status !== 'Approved' || req.posted) throw new AppError('Only an approved, unposted payment journal can be reopened', 'VALIDATION');
  await run("UPDATE payment_journal_header SET status = 'Open' WHERE no = ?", no);
  await audit(user, 'PAYMENT_JOURNAL_REOPEN', 'payment_journal_header', no, {});
}

/* ------------------------------------------------------------------- posting */

export async function postPaymentJournal(no: string, user: Actor): Promise<{ journalNo: string | null; applied: number }> {
  return tx(async () => {
    const header = await one<PaymentJournalHeader>('SELECT * FROM payment_journal_header WHERE no = ?', no);
    if (!header) throw new AppError('Payment journal not found', 'NOT_FOUND');
    if (header.posted) throw new AppError('This payment journal has already been posted', 'VALIDATION');
    if (header.status !== 'Approved') throw new AppError('Only an approved payment journal can be posted', 'VALIDATION');

    const vd = header.posting_date;
    const range = await getEffectivePostingRange(user.id);
    if (range.from && vd < range.from) throw new AppError(`Posting date ${vd} is before your earliest allowed date (${range.from})`, 'VALIDATION');
    if (range.to && vd > range.to) throw new AppError(`Posting date ${vd} is after your latest allowed date (${range.to})`, 'VALIDATION');

    const bank = await one<{ gl_account_id: number; code: string }>('SELECT gl_account_id, code FROM bank_account WHERE id = ?', header.bank_account_id);
    if (!bank) throw new AppError('Bank account not found', 'NOT_FOUND');

    const lines = await all<{
      id: number; line_no: number; vendor_id: number; amount: Cents; document_no: string | null; applies_to_doc_no: string | null;
    }>('SELECT id, line_no, vendor_id, amount, document_no, applies_to_doc_no FROM payment_journal_line WHERE payment_journal_header_id = ? ORDER BY line_no', header.id);
    if (!lines.length) throw new AppError('This payment journal has no lines', 'VALIDATION');

    const glLines: { account: number; debit: Cents; credit: Cents; narration: string }[] = [
      { account: bank.gl_account_id, debit: 0, credit: header.total_amount, narration: `Payment Journal ${no}` },
    ];
    const debitByAccount = new Map<number, number>();
    let applied = 0;
    const touchedVendors = new Set<number>();

    for (const line of lines) {
      const vend = await one<{ no: string; vendor_posting_group_code: string | null }>(
        'SELECT no, vendor_posting_group_code FROM vendor WHERE id = ?', line.vendor_id,
      );
      if (!vend?.vendor_posting_group_code) throw new AppError(`Vendor ${vend?.no ?? line.vendor_id} has no Vendor Posting Group`, 'VALIDATION');
      const pg = await one<{ payables_account_id: number }>(
        'SELECT payables_account_id FROM vendor_posting_group WHERE code = ?', vend.vendor_posting_group_code,
      );
      if (!pg) throw new AppError('Vendor Posting Group setup is missing', 'VALIDATION');
      debitByAccount.set(pg.payables_account_id, (debitByAccount.get(pg.payables_account_id) ?? 0) + line.amount);

      const paymentEntryId = await createVendorLedgerEntry({
        vendorId: line.vendor_id, postingDate: vd, documentType: 'Payment',
        documentNo: line.document_no || no, description: `Payment Journal ${no}`,
        amount: -line.amount, sourceType: 'Payment Journal', sourceId: header.id,
      });
      touchedVendors.add(line.vendor_id);

      const targetIds: number[] = [];
      if (line.applies_to_doc_no) {
        const target = await one<{ id: number }>(
          "SELECT id FROM vendor_ledger_entry WHERE vendor_id = ? AND document_no = ? AND open = 1 AND positive = 1 ORDER BY id LIMIT 1",
          line.vendor_id, line.applies_to_doc_no,
        );
        if (target) targetIds.push(target.id);
      }
      const res = await applyVendorEntries(
        { applyingEntryId: paymentEntryId, appliedTo: targetIds.length ? targetIds : 'auto', postingDate: vd }, user,
      );
      applied += res.closedEntryNos.length;
    }

    for (const [account, amount] of debitByAccount) {
      glLines.push({ account, debit: amount, credit: 0, narration: `Payment Journal ${no}` });
    }

    const j = await postJournal({
      valueDate: vd, module: 'PAYABLES', eventType: 'PAYMENT_JOURNAL',
      description: `Payment Journal ${no} — ${bank.code}`, reference: no, user,
      idempotencyKey: `PAYMENT_JOURNAL-${no}`,
      lines: glLines,
    });

    await run("UPDATE vendor_ledger_entry SET journal_id = ? WHERE source_type = 'Payment Journal' AND source_id = ? AND journal_id IS NULL", j.id, header.id);
    for (const vid of touchedVendors) await recomputeVendorBalance(vid);

    await run(
      `UPDATE payment_journal_header SET status = 'Processed', posted = true, journal_id = ?, posted_at = ?, posted_by = ? WHERE no = ?`,
      j.id, new Date().toISOString(), user.username, no,
    );
    await audit(user, 'PAYMENT_JOURNAL_POST', 'payment_journal_header', no, { journalNo: j.journal_no, applied });
    return { journalNo: j.journal_no, applied };
  });
}
