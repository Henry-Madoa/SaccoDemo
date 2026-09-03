/*
 * Receipt — a maker-checker cash-in document (AL Tab52203423/424, Cod52203434.PostReceipt). The
 * SACCO records money received (by cash, cheque or M-Pesa) into a bank account; posting is one
 * journal: Dr the bank account, Cr each line's account. Customer lines write + apply a Payment;
 * Vendor lines a Refund; G/L / Bank lines credit the account directly.
 *
 * Lifecycle: Open → Pending Approval → Approved → Posted. A receipt whose amount is below the
 * Receipt Approval Limit (Cash Management Setup) can be posted directly by its creator without a
 * workflow (BC's `Amount < Approval Limit` path); at/above the limit it must be approved.
 */
import { one, all, run, tx, nextSequence, audit, hasAnyRow } from './db.ts';
import { AppError } from './errors.ts';
import { postJournal } from './accounting.ts';
import { getEffectivePostingRange } from './postingDates.ts';
import { resolveDocCurrency } from './currency.ts';
import { getCashManagementSetup } from './cashMgmtSetup.ts';
import { createCustLedgerEntry, applyCustomerEntries, recomputeCustomerBalance } from './custLedger.ts';
import { createVendorLedgerEntry, applyVendorEntries, recomputeVendorBalance } from './vendLedger.ts';
import { findMatchingWorkflow, findPendingRoutedTask, pickConditionFields, startWorkflow } from './workflow.ts';
import { buildFilterClause, type FilterCondition, type FilterFieldDef } from './listFilters.ts';
import { buildOrderClause, type SortState } from './listSort.ts';
import type {
  Actor, Cents, IsoDate, ReceiptDetail, ReceiptHeader, ReceiptHeaderView, ReceiptLine, ReceiptLineType,
} from './types.ts';

export type ReceiptView = 'open' | 'pending' | 'approved' | 'posted';

const VIEW_CLAUSE: Record<ReceiptView, string> = {
  open: "rh.status = 'Open'",
  pending: "rh.status = 'Pending Approval'",
  approved: "rh.status = 'Approved'",
  posted: 'rh.posted = true',
};

const LINE_TYPES: ReceiptLineType[] = ['Customer', 'Vendor', 'G/L Account', 'Bank Account'];

const SELECT_ROW = `
  SELECT rh.*, ba.code AS bank_account_code,
         (SELECT COUNT(*) FROM receipt_line l WHERE l.receipt_header_id = rh.id) AS line_count,
         j.journal_no AS journal_no
  FROM receipt_header rh
  JOIN bank_account ba ON ba.id = rh.bank_account_id
  LEFT JOIN journal j ON j.id = rh.journal_id`;

export const RECEIPT_FILTER_FIELDS: FilterFieldDef[] = [
  { key: 'no', label: 'No.', type: 'text', column: 'rh.no' },
  { key: 'receipt_type', label: 'Type', type: 'select', column: 'rh.receipt_type',
    options: LINE_TYPES.map((v) => ({ value: v, label: v })) },
  { key: 'bank_account_id', label: 'Bank Account', type: 'select', column: 'rh.bank_account_id' },
  { key: 'created_by', label: 'Created By', type: 'text', column: 'rh.created_by' },
];

const SORT_COLUMNS: Record<string, string> = {
  no: 'rh.no', amount: 'rh.amount', status: 'rh.status', created_at: 'rh.created_at',
};

export interface ListReceiptsOptions {
  view?: ReceiptView; search?: string; filters?: FilterCondition[]; sort?: SortState | null;
}

export const listReceipts = (
  { view, search = '', filters = [], sort = null }: ListReceiptsOptions = {},
): Promise<ReceiptHeaderView[]> => {
  const { clause, params } = buildFilterClause(RECEIPT_FILTER_FIELDS, filters);
  const orderBy = buildOrderClause(SORT_COLUMNS, sort, 'rh.no DESC');
  return all<ReceiptHeaderView>(
    `${SELECT_ROW}
     WHERE (rh.no LIKE @like OR rh.description LIKE @like OR rh.external_document_no LIKE @like)
       ${view ? `AND ${VIEW_CLAUSE[view]}` : ''}
       ${clause}
     ${orderBy}`,
    { like: `%${String(search).trim()}%`, ...params },
  );
};

export async function getReceipt(no: string): Promise<ReceiptDetail | undefined> {
  const header = await one<ReceiptHeaderView>(`${SELECT_ROW} WHERE rh.no = ?`, no);
  if (!header) return undefined;
  const lines = await all<ReceiptLine>('SELECT * FROM receipt_line WHERE receipt_header_id = ? ORDER BY line_no', header.id);
  return { ...header, lines };
}

export const hasAnyReceipts = (view?: ReceiptView): Promise<boolean> =>
  hasAnyRow('receipt_header rh', view ? VIEW_CLAUSE[view] : undefined);

/* -------------------------------------------------------------------- create / edit */

export interface ReceiptLineInput {
  lineType: ReceiptLineType;
  accountNo: string;
  description?: string | null;
  amount: Cents;
  appliesToDocNo?: string | null;
}
export interface ReceiptInput {
  receiptType: ReceiptLineType;
  bankAccountId: number;
  postingDate: IsoDate;
  payModeCode?: string | null;
  externalDocumentNo?: string | null;
  manualReceiptNo?: string | null;
  description: string;
  currencyCode?: string | null;
  lines: ReceiptLineInput[];
}

async function loadBank(id: number): Promise<{ id: number; code: string; name: string; gl_account_id: number; currency_code: string; status: string }> {
  const ba = await one<{ id: number; code: string; name: string; gl_account_id: number; currency_code: string; status: string }>(
    'SELECT id, code, name, gl_account_id, currency_code, status FROM bank_account WHERE id = ?', id,
  );
  if (!ba) throw new AppError('Bank account not found', 'NOT_FOUND');
  if (ba.status !== 'ACTIVE') throw new AppError('That bank account is not active', 'VALIDATION');
  return ba;
}

async function resolveLine(input: ReceiptLineInput, currencyCode: string): Promise<{ accountName: string }> {
  if (!LINE_TYPES.includes(input.lineType)) throw new AppError('Invalid line type', 'VALIDATION');
  if (!input.accountNo?.trim()) throw new AppError(`A ${input.lineType} is required on every line`, 'VALIDATION');
  if (!(input.amount > 0)) throw new AppError('Every line needs an amount greater than zero', 'VALIDATION');
  const no = input.accountNo.trim();
  if (input.lineType === 'Customer') {
    const c = await one<{ name: string; blocked: string; currency_code: string | null }>('SELECT name, blocked, currency_code FROM customer WHERE no = ?', no);
    if (!c) throw new AppError(`Customer ${no} not found`, 'NOT_FOUND');
    if (c.blocked === 'All') throw new AppError(`Customer ${no} is blocked`, 'VALIDATION');
    return { accountName: c.name };
  }
  if (input.lineType === 'Vendor') {
    const v = await one<{ name: string; blocked: string }>('SELECT name, blocked FROM vendor WHERE no = ?', no);
    if (!v) throw new AppError(`Vendor ${no} not found`, 'NOT_FOUND');
    return { accountName: v.name };
  }
  if (input.lineType === 'Bank Account') {
    const b = await one<{ name: string; currency_code: string }>('SELECT name, currency_code FROM bank_account WHERE code = ?', no);
    if (!b) throw new AppError(`Bank account ${no} not found`, 'NOT_FOUND');
    if (b.currency_code !== currencyCode) throw new AppError('An inter-bank line must be in the same currency as the receipt', 'VALIDATION');
    return { accountName: b.name };
  }
  const acc = await one<{ name: string; is_postable: number; status: string; no_direct_posting: number }>(
    'SELECT name, is_postable, status, no_direct_posting FROM gl_account WHERE code = ?', no,
  );
  if (!acc || !acc.is_postable || acc.status !== 'ACTIVE') throw new AppError(`G/L account ${no} is not an active posting account`, 'VALIDATION');
  if (acc.no_direct_posting) throw new AppError(`G/L account ${no} is a subledger control account`, 'VALIDATION');
  return { accountName: acc.name };
}

export async function createReceipt(input: ReceiptInput, user: Actor): Promise<{ no: string }> {
  if (!input.postingDate) throw new AppError('A posting date is required', 'VALIDATION');
  if (!input.description?.trim()) throw new AppError('A description (received from) is required', 'VALIDATION');
  const bank = await loadBank(input.bankAccountId);
  const cur = await resolveDocCurrency(input.currencyCode ?? bank.currency_code, input.postingDate);
  if (cur.code !== bank.currency_code) throw new AppError(`The receipt is in ${cur.code} but bank account ${bank.code} is a ${bank.currency_code} account`, 'VALIDATION');
  const setup = await getCashManagementSetup();
  const no = await nextSequence('RECEIPT');
  return tx(async () => {
    const info = await run(
      `INSERT INTO receipt_header
         (no, receipt_type, posting_date, bank_account_id, bank_account_name, pay_mode_code, external_document_no, manual_receipt_no,
          description, currency_code, currency_factor, approval_limit, created_at, created_by)
       VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?)`,
      no, input.receiptType, input.postingDate, bank.id, bank.name, input.payModeCode || null, input.externalDocumentNo?.trim() || null,
      input.manualReceiptNo?.trim() || null, input.description.trim(), cur.code, cur.factor,
      setup.receipt_approval_limit, new Date().toISOString(), user.username,
    );
    await replaceLines(Number(info.lastInsertRowid), input.lines, cur.code);
    await audit(user, 'RECEIPT_CREATE', 'receipt_header', no, { lineCount: input.lines.length });
    return { no };
  });
}

export async function updateReceipt(no: string, input: ReceiptInput, user: Actor): Promise<void> {
  const before = await one<ReceiptHeader>('SELECT * FROM receipt_header WHERE no = ?', no);
  if (!before) throw new AppError('Receipt not found', 'NOT_FOUND');
  if (before.status !== 'Open') throw new AppError('Only an open receipt can be edited', 'VALIDATION');
  if (before.created_by !== user.username) throw new AppError('Only the person who created this can edit it', 'NOT_CREATOR');
  const bank = await loadBank(input.bankAccountId);
  const cur = await resolveDocCurrency(input.currencyCode ?? before.currency_code, input.postingDate);
  if (cur.code !== bank.currency_code) throw new AppError('The receipt currency must match the bank account currency', 'VALIDATION');
  await tx(async () => {
    await run(
      `UPDATE receipt_header SET receipt_type = ?, posting_date = ?, bank_account_id = ?, bank_account_name = ?, pay_mode_code = ?,
         external_document_no = ?, manual_receipt_no = ?, description = ?, currency_code = ?, currency_factor = ? WHERE id = ?`,
      input.receiptType, input.postingDate, bank.id, bank.name, input.payModeCode || null, input.externalDocumentNo?.trim() || null,
      input.manualReceiptNo?.trim() || null, input.description.trim(), cur.code, cur.factor, before.id,
    );
    await replaceLines(before.id, input.lines, cur.code);
  });
  await audit(user, 'RECEIPT_UPDATE', 'receipt_header', no, {});
}

async function replaceLines(headerId: number, lines: ReceiptLineInput[], currencyCode: string): Promise<void> {
  await run('DELETE FROM receipt_line WHERE receipt_header_id = ?', headerId);
  let lineNo = 10000;
  let total = 0;
  for (const l of lines) {
    if (!l.accountNo?.trim() || !(l.amount > 0)) continue;
    const resolved = await resolveLine(l, currencyCode);
    total += Math.round(l.amount);
    await run(
      `INSERT INTO receipt_line (receipt_header_id, line_no, line_type, account_no, account_name, description, amount, applies_to_doc_no)
       VALUES (?,?,?,?,?,?,?,?)`,
      headerId, lineNo, l.lineType, l.accountNo.trim(), resolved.accountName, l.description?.trim() || null,
      Math.round(l.amount), l.appliesToDocNo?.trim() || null,
    );
    lineNo += 10000;
  }
  await run('UPDATE receipt_header SET amount = ? WHERE id = ?', total, headerId);
}

export async function deleteReceipt(no: string, user: Actor): Promise<void> {
  const before = await one<Pick<ReceiptHeader, 'status' | 'created_by'>>('SELECT status, created_by FROM receipt_header WHERE no = ?', no);
  if (!before) throw new AppError('Receipt not found', 'NOT_FOUND');
  if (before.status !== 'Open') throw new AppError('Only an open receipt can be deleted', 'VALIDATION');
  if (before.created_by !== user.username) throw new AppError('Only the person who created this can delete it', 'NOT_CREATOR');
  await run('DELETE FROM receipt_header WHERE no = ?', no);
  await audit(user, 'RECEIPT_DELETE', 'receipt_header', no, {});
}

/* --------------------------------------------------------------- maker-checker */

export async function submitReceipt(no: string, user: Actor): Promise<{ autoApproved: boolean }> {
  const req = await one<ReceiptHeader>('SELECT * FROM receipt_header WHERE no = ?', no);
  if (!req) throw new AppError('Receipt not found', 'NOT_FOUND');
  if (req.status !== 'Open') throw new AppError('Only an open receipt can be submitted', 'VALIDATION');
  if (req.amount <= 0) throw new AppError('Add at least one receipt line before submitting', 'VALIDATION');
  const matched = await findMatchingWorkflow('RECEIPT', await pickConditionFields('RECEIPT', req));
  if (!matched) throw new AppError('There is no enabled workflow for this document', 'NO_WORKFLOW');
  await tx(async () => {
    await run("UPDATE receipt_header SET status = 'Pending Approval' WHERE no = ?", no);
    await startWorkflow(matched.workflow, matched.steps, {
      documentType: 'RECEIPT', entityId: no, requestedBy: user.username, amount: Number(req.amount),
    });
  });
  const after = await one<{ status: string }>('SELECT status FROM receipt_header WHERE no = ?', no);
  return { autoApproved: after?.status === 'Approved' };
}

export async function cancelReceiptApproval(no: string, user: Actor): Promise<void> {
  const req = await one<Pick<ReceiptHeader, 'status' | 'created_by'>>('SELECT status, created_by FROM receipt_header WHERE no = ?', no);
  if (!req) throw new AppError('Receipt not found', 'NOT_FOUND');
  if (req.status !== 'Pending Approval') throw new AppError('Only a receipt pending approval can be recalled', 'VALIDATION');
  const routed = await findPendingRoutedTask('RECEIPT', no);
  if ((routed?.requested_by ?? req.created_by) !== user.username) throw new AppError('Only the person who submitted this can recall it', 'NOT_REQUESTER');
  await run("UPDATE receipt_header SET status = 'Open' WHERE no = ?", no);
  await audit(user, 'RECEIPT_CANCEL_APPROVAL', 'receipt_header', no, {});
}

export async function approveReceipt(no: string, user: Actor): Promise<void> {
  const req = await one<ReceiptHeader>('SELECT * FROM receipt_header WHERE no = ?', no);
  if (!req) throw new AppError('Receipt not found', 'NOT_FOUND');
  if (req.status !== 'Pending Approval') throw new AppError('Only a receipt pending approval can be approved', 'VALIDATION');
  await run("UPDATE receipt_header SET status = 'Approved', decision_reason = NULL WHERE no = ?", no);
  await audit(user, 'RECEIPT_APPROVE', 'receipt_header', no, {});
}

export async function rejectReceipt(no: string, reason: string | null, user: Actor): Promise<void> {
  if (!reason?.trim()) throw new AppError('A reason is required to reject a receipt', 'VALIDATION');
  const req = await one<ReceiptHeader>('SELECT * FROM receipt_header WHERE no = ?', no);
  if (!req) throw new AppError('Receipt not found', 'NOT_FOUND');
  if (req.status !== 'Pending Approval') throw new AppError('Only a receipt pending approval can be rejected', 'VALIDATION');
  await run("UPDATE receipt_header SET status = 'Open', decision_reason = ? WHERE no = ?", reason, no);
  await audit(user, 'RECEIPT_REJECT', 'receipt_header', no, { reason });
}

export async function reopenReceipt(no: string, user: Actor): Promise<void> {
  const req = await one<ReceiptHeader>('SELECT * FROM receipt_header WHERE no = ?', no);
  if (!req) throw new AppError('Receipt not found', 'NOT_FOUND');
  if (req.status !== 'Approved' || req.posted) throw new AppError('Only an approved, unposted receipt can be reopened', 'VALIDATION');
  await run("UPDATE receipt_header SET status = 'Open' WHERE no = ?", no);
  await audit(user, 'RECEIPT_REOPEN', 'receipt_header', no, {});
}

/* ------------------------------------------------------------------- posting */

export async function postReceipt(no: string, user: Actor): Promise<{ postedReceiptNo: string; journalNo: string | null }> {
  return tx(async () => {
    const header = await one<ReceiptHeader>('SELECT * FROM receipt_header WHERE no = ?', no);
    if (!header) throw new AppError('Receipt not found', 'NOT_FOUND');
    if (header.posted) throw new AppError('This receipt has already been posted', 'VALIDATION');
    // A receipt at/above the approval limit must be Approved; below it the creator can post directly.
    if (header.amount >= header.approval_limit && header.status !== 'Approved') {
      throw new AppError('This receipt is at or above the approval limit and must be approved before posting', 'VALIDATION');
    }
    if (header.amount < header.approval_limit && header.status === 'Open' && header.created_by !== user.username) {
      throw new AppError('Only the person who created this receipt can post it directly', 'NOT_CREATOR');
    }
    if (!['Open', 'Approved'].includes(header.status)) throw new AppError('This receipt cannot be posted', 'VALIDATION');

    const vd = header.posting_date;
    const setup = await getCashManagementSetup();
    if (setup.allow_cm_posting_from && vd < setup.allow_cm_posting_from) throw new AppError(`Cash Management posting is not allowed before ${setup.allow_cm_posting_from}`, 'VALIDATION');
    if (setup.allow_cm_posting_to && vd > setup.allow_cm_posting_to) throw new AppError(`Cash Management posting is not allowed after ${setup.allow_cm_posting_to}`, 'VALIDATION');
    const range = await getEffectivePostingRange(user.id);
    if (range.from && vd < range.from) throw new AppError(`Posting date ${vd} is before your earliest allowed date (${range.from})`, 'VALIDATION');
    if (range.to && vd > range.to) throw new AppError(`Posting date ${vd} is after your latest allowed date (${range.to})`, 'VALIDATION');

    const bank = await loadBank(header.bank_account_id);
    const lines = await all<ReceiptLine>('SELECT * FROM receipt_line WHERE receipt_header_id = ? ORDER BY line_no', header.id);
    if (!lines.length) throw new AppError('This receipt has no lines', 'VALIDATION');

    const glLines: { account: number; debit: Cents; credit: Cents; narration: string; bankDocumentType?: string; bankDocumentNo?: string; bankExternalDocumentNo?: string | null }[] = [
      { account: bank.gl_account_id, debit: header.amount, credit: 0, narration: `Receipt ${no} — ${header.description}`.slice(0, 250),
        bankDocumentType: 'Receipt', bankDocumentNo: no, bankExternalDocumentNo: header.external_document_no },
    ];
    const touchedCustomers = new Set<number>();
    const touchedVendors = new Set<number>();

    for (const line of lines) {
      const narration = `Receipt ${no} — ${line.description || line.account_name || line.account_no}`.slice(0, 250);
      if (line.line_type === 'G/L Account') {
        const acc = await one<{ id: number }>('SELECT id FROM gl_account WHERE code = ?', line.account_no!);
        glLines.push({ account: acc!.id, debit: 0, credit: line.amount, narration });
      } else if (line.line_type === 'Bank Account') {
        const b = await one<{ gl_account_id: number }>('SELECT gl_account_id FROM bank_account WHERE code = ?', line.account_no!);
        glLines.push({ account: b!.gl_account_id, debit: 0, credit: line.amount, narration, bankDocumentType: 'Transfer', bankDocumentNo: no });
      } else if (line.line_type === 'Customer') {
        const c = await one<{ id: number; customer_posting_group_code: string | null }>('SELECT id, customer_posting_group_code FROM customer WHERE no = ?', line.account_no!);
        if (!c?.customer_posting_group_code) throw new AppError(`Customer ${line.account_no} has no Customer Posting Group`, 'VALIDATION');
        const pg = await one<{ receivables_account_id: number }>('SELECT receivables_account_id FROM customer_posting_group WHERE code = ?', c.customer_posting_group_code);
        glLines.push({ account: pg!.receivables_account_id, debit: 0, credit: line.amount, narration });
        const pay = await createCustLedgerEntry({
          customerId: c.id, postingDate: vd, documentType: 'Payment', documentNo: no,
          description: narration, amount: -line.amount, currencyCode: header.currency_code, currencyFactor: header.currency_factor,
          sourceType: 'Receipt', sourceId: header.id,
        });
        const target: number[] = [];
        if (line.applies_to_doc_no) {
          const t = await one<{ id: number }>("SELECT id FROM cust_ledger_entry WHERE customer_id = ? AND document_no = ? AND open = 1 AND positive = 1 ORDER BY id LIMIT 1", c.id, line.applies_to_doc_no);
          if (t) target.push(t.id);
        }
        await applyCustomerEntries({ applyingEntryId: pay, appliedTo: target.length ? target : 'auto', postingDate: vd }, user);
        touchedCustomers.add(c.id);
      } else {
        const v = await one<{ id: number; vendor_posting_group_code: string | null }>('SELECT id, vendor_posting_group_code FROM vendor WHERE no = ?', line.account_no!);
        if (!v?.vendor_posting_group_code) throw new AppError(`Vendor ${line.account_no} has no Vendor Posting Group`, 'VALIDATION');
        const pg = await one<{ payables_account_id: number }>('SELECT payables_account_id FROM vendor_posting_group WHERE code = ?', v.vendor_posting_group_code);
        glLines.push({ account: pg!.payables_account_id, debit: 0, credit: line.amount, narration });
        const ref = await createVendorLedgerEntry({
          vendorId: v.id, postingDate: vd, documentType: 'Refund', documentNo: no, description: narration,
          amount: -line.amount, currencyCode: header.currency_code, currencyFactor: header.currency_factor, sourceType: 'Receipt', sourceId: header.id,
        });
        const target: number[] = [];
        if (line.applies_to_doc_no) {
          const t = await one<{ id: number }>("SELECT id FROM vendor_ledger_entry WHERE vendor_id = ? AND document_no = ? AND open = 1 AND positive = 1 ORDER BY id LIMIT 1", v.id, line.applies_to_doc_no);
          if (t) target.push(t.id);
        }
        await applyVendorEntries({ applyingEntryId: ref, appliedTo: target.length ? target : 'auto', postingDate: vd }, user);
        touchedVendors.add(v.id);
      }
    }

    const j = await postJournal({
      valueDate: vd, module: 'CASH_MGMT', eventType: 'RECEIPT',
      description: `Receipt ${no} — ${header.description}`.slice(0, 250), reference: no, user,
      idempotencyKey: `RECEIPT-${no}`, currencyCode: header.currency_code, currencyFactor: header.currency_factor,
      lines: glLines.map((l) => ({
        account: l.account, debit: l.debit, credit: l.credit, narration: l.narration,
        bankDocumentType: l.bankDocumentType, bankDocumentNo: l.bankDocumentNo, bankExternalDocumentNo: l.bankExternalDocumentNo,
      })),
    });
    await run("UPDATE cust_ledger_entry SET journal_id = ? WHERE source_type = 'Receipt' AND source_id = ? AND journal_id IS NULL", j.id, header.id);
    await run("UPDATE vendor_ledger_entry SET journal_id = ? WHERE source_type = 'Receipt' AND source_id = ? AND journal_id IS NULL", j.id, header.id);
    for (const c of touchedCustomers) await recomputeCustomerBalance(c);
    for (const v of touchedVendors) await recomputeVendorBalance(v);

    const postedNo = await nextSequence('POSTED_RECEIPT');
    const info = await run(
      `INSERT INTO posted_receipt
         (no, receipt_no, receipt_type, bank_account_id, bank_account_name, pay_mode_code, external_document_no,
          manual_receipt_no, description, currency_code, currency_factor, posting_date, amount, journal_id, created_at, created_by)
       VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)`,
      postedNo, no, header.receipt_type, bank.id, header.bank_account_name, header.pay_mode_code, header.external_document_no,
      header.manual_receipt_no, header.description, header.currency_code, header.currency_factor, vd, header.amount, j.id,
      new Date().toISOString(), user.username,
    );
    const prId = Number(info.lastInsertRowid);
    let ln = 10000;
    for (const line of lines) {
      await run(
        `INSERT INTO posted_receipt_line (posted_receipt_id, line_no, line_type, account_no, account_name, description, amount, applies_to_doc_no)
         VALUES (?,?,?,?,?,?,?,?)`,
        prId, ln, line.line_type, line.account_no, line.account_name, line.description, line.amount, line.applies_to_doc_no,
      );
      ln += 10000;
    }

    await run("UPDATE receipt_header SET posted = true, journal_id = ?, posted_at = ?, posted_by = ? WHERE no = ?", j.id, new Date().toISOString(), user.username, no);
    await audit(user, 'RECEIPT_POST', 'receipt_header', no, { postedNo, journalNo: j.journal_no });
    return { postedReceiptNo: postedNo, journalNo: j.journal_no };
  });
}
