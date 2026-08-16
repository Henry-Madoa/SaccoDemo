/*
 * Account Opening — a maker-checker request to open an additional savings account for an
 * existing member (anything that isn't the member's category default account, which is
 * provisioned automatically — see lib/memberApplications.ts and pool.getDefaultAccountsBacklog()).
 * Same Open -> Pending Approval -> Approved -> Processed shape as lib/memberApplications.ts /
 * lib/memberEdits.ts: the request only actually opens the account (via lib/savings.ts
 * openAccount()) once processAccountOpeningRequest() runs on an Approved request.
 *
 * This module only ever opens a zero-balance account — funding it is a separate concern,
 * done afterwards through the ordinary Savings & FOSA deposit flow (lib/savings.ts deposit()),
 * not captured here.
 */
import {
  one, all, run, tx, nextSequence, hasAnyRow,
} from './db.ts';
import { AppError } from './errors.ts';
import { diffFields, logTableChange } from './changeLog.ts';
import { findMatchingWorkflow, findPendingRoutedTask, pickConditionFields, startWorkflow } from './workflow.ts';
import { getMemberCategoryDefaultAccounts } from './pool.ts';
import { openAccount } from './savings.ts';
import { buildFilterClause, type FilterCondition, type FilterFieldDef } from './listFilters.ts';
import { buildOrderClause, type SortState } from './listSort.ts';
import type {
  Actor, AccountOpeningRequest, AccountOpeningRequestWithDimensions, Member, SavingsProduct,
} from './types.ts';

/** The four nav sub-views — "processed" means the savings account has actually been opened. */
export type AccountOpeningView = 'open' | 'pending' | 'approved' | 'processed';

const VIEW_CLAUSE: Record<AccountOpeningView, string> = {
  open: "a.status = 'Open'",
  pending: "a.status = 'Pending Approval'",
  approved: "a.status = 'Approved'",
  processed: "a.status = 'Processed'",
};

const SELECT_REQUEST = `
  SELECT a.*, m.member_no AS member_no, m.first_name AS member_first_name, m.last_name AS member_last_name,
         p.code AS savings_product_code, p.name AS savings_product_name,
         p.category AS savings_product_category, p.is_business_account AS savings_product_is_business_account
  FROM account_opening_request a
  JOIN member m ON m.id = a.member_id
  JOIN savings_product p ON p.id = a.savings_product_id`;

/** Account Opening list's dynamic-filter registry — every meaningful column, alongside the
 *  view tabs (which remain the primary Open/Pending/Approved/Processed navigation, so `status`
 *  is deliberately left out here). member_id/savings_product_id ship without `options` — the
 *  page fills them in from lookups it already fetches. */
export const ACCOUNT_OPENING_FILTER_FIELDS: FilterFieldDef[] = [
  { key: 'no', label: 'Request No.', type: 'text', column: 'a.no' },
  { key: 'member_id', label: 'Member', type: 'select', column: 'a.member_id' },
  { key: 'savings_product_id', label: 'Product', type: 'select', column: 'a.savings_product_id' },
  { key: 'notes', label: 'Notes', type: 'text', column: 'a.notes' },
  { key: 'business_name', label: 'Business Name', type: 'text', column: 'a.business_name' },
  { key: 'business_location', label: 'Business Location', type: 'text', column: 'a.business_location' },
  { key: 'business_paybill_till_no', label: 'Paybill / Till No.', type: 'text', column: 'a.business_paybill_till_no' },
  { key: 'business_phone_no', label: 'Business Phone No.', type: 'text', column: 'a.business_phone_no' },
  { key: 'junior_name', label: 'Junior Name', type: 'text', column: 'a.junior_name' },
  { key: 'junior_birth_cert_no', label: 'Birth Notification / Certificate No.', type: 'text', column: 'a.junior_birth_cert_no' },
  { key: 'junior_date_of_birth', label: 'Junior Date of Birth', type: 'date', column: 'a.junior_date_of_birth' },
  { key: 'decision_reason', label: 'Decision Reason', type: 'text', column: 'a.decision_reason' },
  { key: 'created_by', label: 'Created By', type: 'text', column: 'a.created_by' },
  { key: 'created_at', label: 'Created', type: 'date', column: 'a.created_at', datetime: true },
  { key: 'processed_by', label: 'Processed By', type: 'text', column: 'a.processed_by' },
  { key: 'processed_at', label: 'Processed', type: 'date', column: 'a.processed_at', datetime: true },
];

/** Account Opening list's sortable columns — every column shown in the table. */
const ACCOUNT_OPENING_SORT_COLUMNS: Record<string, string> = {
  no: 'a.no',
  member: 'm.first_name',
  member_no: 'm.member_no',
  product: 'p.name',
  status: 'a.status',
};

export interface ListAccountOpeningOptions {
  view?: AccountOpeningView;
  search?: string;
  filters?: FilterCondition[];
  sort?: SortState | null;
}

export const listAccountOpeningRequests = (
  { view, search = '', filters = [], sort = null }: ListAccountOpeningOptions = {},
): Promise<AccountOpeningRequestWithDimensions[]> => {
  const { clause, params } = buildFilterClause(ACCOUNT_OPENING_FILTER_FIELDS, filters);
  const orderBy = buildOrderClause(ACCOUNT_OPENING_SORT_COLUMNS, sort, 'a.no DESC');
  return all<AccountOpeningRequestWithDimensions>(
    `${SELECT_REQUEST}
     WHERE (m.first_name LIKE @like OR m.last_name LIKE @like OR m.member_no LIKE @like OR a.no LIKE @like)
       ${view ? `AND ${VIEW_CLAUSE[view]}` : ''}
       ${clause}
     ${orderBy}`,
    { like: `%${String(search).trim()}%`, ...params },
  );
};

export const getAccountOpeningRequest = (no: string): Promise<AccountOpeningRequestWithDimensions | undefined> =>
  one<AccountOpeningRequestWithDimensions>(`${SELECT_REQUEST} WHERE a.no = ?`, no);

/** Whether the current view tab has any requests at all, ignoring search and dynamic filters —
 *  lets the page grey out its filter controls only when there's truly nothing to filter. */
export const hasAnyAccountOpeningRequests = (view?: AccountOpeningView): Promise<boolean> =>
  hasAnyRow('account_opening_request a', view ? VIEW_CLAUSE[view] : undefined);

/** The request immediately before/after this one by number — for the card's
 *  Business-Central-style Previous/Next navigation. Scoped to the same `view` tab the record
 *  was opened from (when given), so paging never steps outside the list the user came from. */
export async function getAdjacentAccountOpeningNos(
  no: string, view?: AccountOpeningView,
): Promise<{ prevNo: string | null; nextNo: string | null }> {
  const clause = view ? `AND ${VIEW_CLAUSE[view]}` : '';
  const [prev, next] = await Promise.all([
    one<{ no: string }>(`SELECT a.no FROM account_opening_request a WHERE a.no < ? ${clause} ORDER BY a.no DESC LIMIT 1`, no),
    one<{ no: string }>(`SELECT a.no FROM account_opening_request a WHERE a.no > ? ${clause} ORDER BY a.no ASC LIMIT 1`, no),
  ]);
  return { prevNo: prev?.no ?? null, nextNo: next?.no ?? null };
}

/** Every active product the member could still request through this module — every ACTIVE
 *  savings product except whichever ones are that member's category's default accounts (those
 *  are provisioned automatically, not requested here). */
export async function eligibleProducts(memberId: number): Promise<SavingsProduct[]> {
  const member = await one<Member>('SELECT * FROM member WHERE id = ?', memberId);
  if (!member) throw new AppError('Member not found', 'NOT_FOUND');
  const products = await all<SavingsProduct>("SELECT * FROM savings_product WHERE status = 'ACTIVE' ORDER BY id");
  if (!member.member_category_id) return products;
  const defaults = await getMemberCategoryDefaultAccounts(member.member_category_id);
  const defaultProductIds = new Set(defaults.map((d) => d.savings_product_id));
  return products.filter((p) => !defaultProductIds.has(p.id));
}

/**
 * Validates + normalizes the Junior/Business account rules before staging a request — the same
 * rules lib/savings.ts's openAccount() enforces authoritatively when the account is actually
 * opened, checked here too so the requester finds out immediately rather than only once the
 * request has already been through approval.
 */
async function validateProductRules(
  memberId: number, product: SavingsProduct, juniorBirthCertNo: string | null | undefined,
  excludeRequestNo?: string,
): Promise<{ normalizedJuniorBirthCertNo: string | null }> {
  const isJunior = product.category === 'JUNIOR ACCOUNT';
  if (!isJunior && !product.is_business_account) {
    const existing = await one(
      'SELECT 1 FROM savings_account WHERE member_id = ? AND product_id = ?', memberId, product.id,
    );
    if (existing) {
      throw new AppError(
        `This member already has a ${product.name} account — only one is allowed per member`, 'VALIDATION',
      );
    }
  }

  let normalizedJuniorBirthCertNo: string | null = null;
  if (isJunior) {
    normalizedJuniorBirthCertNo = (juniorBirthCertNo || '').trim().toUpperCase() || null;
    if (!normalizedJuniorBirthCertNo) {
      throw new AppError('A Birth Notification/Certificate No. is required to open a Junior Account', 'VALIDATION');
    }
    const dupAccount = await one(
      'SELECT 1 FROM savings_account WHERE junior_birth_cert_no = ?', normalizedJuniorBirthCertNo,
    );
    const dupRequest = await one(
      `SELECT 1 FROM account_opening_request
       WHERE junior_birth_cert_no = ? AND status != 'Processed' ${excludeRequestNo ? 'AND no != ?' : ''}`,
      ...(excludeRequestNo ? [normalizedJuniorBirthCertNo, excludeRequestNo] : [normalizedJuniorBirthCertNo]),
    );
    if (dupAccount || dupRequest) {
      throw new AppError(
        `A Junior Account already exists (or is already requested) for Birth Notification/Certificate No. "${normalizedJuniorBirthCertNo}"`,
        'VALIDATION',
      );
    }
  }

  return { normalizedJuniorBirthCertNo };
}

export interface CreateAccountOpeningInput {
  memberId: number;
  productId: number;
  notes?: string | null;
  businessName?: string | null;
  businessLocation?: string | null;
  businessPaybillTillNo?: string | null;
  businessPhoneNo?: string | null;
  juniorName?: string | null;
  juniorBirthCertNo?: string | null;
  juniorDateOfBirth?: string | null;
}

export async function createAccountOpeningRequest(
  {
    memberId, productId, notes = null,
    businessName = null, businessLocation = null, businessPaybillTillNo = null, businessPhoneNo = null,
    juniorName = null, juniorBirthCertNo = null, juniorDateOfBirth = null,
  }: CreateAccountOpeningInput,
  user: Actor,
): Promise<{ no: string }> {
  const member = await one<Member>('SELECT * FROM member WHERE id = ?', memberId);
  if (!member) throw new AppError('Member not found', 'NOT_FOUND');
  if (member.status === 'WITHDRAWN' || member.status === 'DECEASED') {
    throw new AppError('This member has exited the society', 'VALIDATION');
  }
  const product = await one<SavingsProduct>('SELECT * FROM savings_product WHERE id = ?', productId);
  if (!product) throw new AppError('Savings product not found', 'NOT_FOUND');
  if (product.status !== 'ACTIVE') throw new AppError('Savings product is not active', 'VALIDATION');

  if (member.member_category_id) {
    const defaults = await getMemberCategoryDefaultAccounts(member.member_category_id);
    if (defaults.some((d) => d.savings_product_id === productId)) {
      throw new AppError(
        `${product.name} is a default account for this member's category — it is provisioned automatically, not requested here`,
        'VALIDATION',
      );
    }
  }

  const { normalizedJuniorBirthCertNo } = await validateProductRules(memberId, product, juniorBirthCertNo);

  const no = await nextSequence('ACCOUNT_OPENING');
  await run(
    `INSERT INTO account_opening_request
       (no, member_id, savings_product_id, notes,
        business_name, business_location, business_paybill_till_no, business_phone_no,
        junior_name, junior_birth_cert_no, junior_date_of_birth,
        created_at, created_by)
     VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?)`,
    no, memberId, productId, notes,
    businessName, businessLocation, businessPaybillTillNo, businessPhoneNo,
    juniorName, normalizedJuniorBirthCertNo, juniorDateOfBirth,
    new Date().toISOString(), user.username,
  );
  await logTableChange(
    'account_opening_request', no, 'Insertion',
    [
      { field: 'member_id', oldValue: null, newValue: memberId },
      { field: 'savings_product_id', oldValue: null, newValue: productId },
      { field: 'notes', oldValue: null, newValue: notes },
      { field: 'business_name', oldValue: null, newValue: businessName },
      { field: 'business_location', oldValue: null, newValue: businessLocation },
      { field: 'business_paybill_till_no', oldValue: null, newValue: businessPaybillTillNo },
      { field: 'business_phone_no', oldValue: null, newValue: businessPhoneNo },
      { field: 'junior_name', oldValue: null, newValue: juniorName },
      { field: 'junior_birth_cert_no', oldValue: null, newValue: normalizedJuniorBirthCertNo },
      { field: 'junior_date_of_birth', oldValue: null, newValue: juniorDateOfBirth },
    ],
    user,
  );
  return { no };
}

export interface UpdateAccountOpeningInput {
  productId?: number;
  notes?: string | null;
  businessName?: string | null;
  businessLocation?: string | null;
  businessPaybillTillNo?: string | null;
  businessPhoneNo?: string | null;
  juniorName?: string | null;
  juniorBirthCertNo?: string | null;
  juniorDateOfBirth?: string | null;
  juniorPhoto?: string | null;
}

export async function updateAccountOpeningRequest(
  no: string, body: UpdateAccountOpeningInput, user: Actor,
): Promise<AccountOpeningRequestWithDimensions> {
  const req = await one<AccountOpeningRequest>('SELECT * FROM account_opening_request WHERE no = ?', no);
  if (!req) throw new AppError('Account opening request not found', 'NOT_FOUND');
  if (req.status !== 'Open') throw new AppError('Only an open request can be edited', 'VALIDATION');

  const cols: Record<string, unknown> = {};
  if (body.productId !== undefined) cols.savings_product_id = body.productId;
  if (body.notes !== undefined) cols.notes = body.notes;
  if (body.businessName !== undefined) cols.business_name = body.businessName;
  if (body.businessLocation !== undefined) cols.business_location = body.businessLocation;
  if (body.businessPaybillTillNo !== undefined) cols.business_paybill_till_no = body.businessPaybillTillNo;
  if (body.businessPhoneNo !== undefined) cols.business_phone_no = body.businessPhoneNo;
  if (body.juniorName !== undefined) cols.junior_name = body.juniorName;
  if (body.juniorBirthCertNo !== undefined) cols.junior_birth_cert_no = body.juniorBirthCertNo;
  if (body.juniorDateOfBirth !== undefined) cols.junior_date_of_birth = body.juniorDateOfBirth;
  if (body.juniorPhoto !== undefined) cols.junior_photo = body.juniorPhoto;

  // Only re-validate the Junior/Business rules when something they actually depend on is
  // changing — a product switch, or the cert no itself — not on every field edit.
  if (body.productId !== undefined || body.juniorBirthCertNo !== undefined) {
    const effectiveProductId = body.productId ?? req.savings_product_id;
    const product = await one<SavingsProduct>('SELECT * FROM savings_product WHERE id = ?', effectiveProductId);
    if (!product) throw new AppError('Savings product not found', 'NOT_FOUND');
    const effectiveJuniorCert = body.juniorBirthCertNo !== undefined ? body.juniorBirthCertNo : req.junior_birth_cert_no;
    const { normalizedJuniorBirthCertNo } = await validateProductRules(req.member_id, product, effectiveJuniorCert, no);
    if (body.juniorBirthCertNo !== undefined) cols.junior_birth_cert_no = normalizedJuniorBirthCertNo;
  }

  const keys = Object.keys(cols);
  if (keys.length) {
    await run(
      `UPDATE account_opening_request SET ${keys.map((c) => `${c}=?`).join(',')} WHERE no=?`,
      ...keys.map((c) => cols[c]), no,
    );
    const changes = diffFields(req as unknown as Record<string, unknown>, cols);
    await logTableChange('account_opening_request', no, 'Modification', changes, user);
  }
  return (await getAccountOpeningRequest(no))!;
}

/** Sends the request into the matched workflow — `autoApproved` tells the caller whether it
 *  came straight back out the other side already Approved (the requester was the resolved
 *  approver at every step; see lib/workflow.ts's requesterClearsLevel()), so the UI can say so
 *  instead of the generic "sent for approval". */
export async function submitAccountOpeningRequest(no: string, user: Actor): Promise<{ autoApproved: boolean }> {
  const req = await one<AccountOpeningRequest>('SELECT * FROM account_opening_request WHERE no = ?', no);
  if (!req) throw new AppError('Account opening request not found', 'NOT_FOUND');
  if (req.status !== 'Open') {
    throw new AppError('Only an open request can be submitted for approval', 'VALIDATION');
  }

  const matched = await findMatchingWorkflow(
    'ACCOUNT_OPENING', await pickConditionFields('ACCOUNT_OPENING', req),
  );
  if (!matched) {
    throw new AppError('There is no enabled workflow for this document', 'NO_WORKFLOW');
  }

  await tx(async () => {
    await run("UPDATE account_opening_request SET status = 'Pending Approval' WHERE no = ?", no);
    await logTableChange(
      'account_opening_request', no, 'Modification',
      [{ field: 'status', oldValue: req.status, newValue: 'Pending Approval' }], user,
    );
    // No monetary amount is involved in opening a (zero-balance) account — funding it is a
    // separate Savings & FOSA deposit, done after the fact.
    await startWorkflow(matched.workflow, matched.steps, {
      documentType: 'ACCOUNT_OPENING', entityId: no, requestedBy: user.username, amount: 0,
    });
  });

  const after = await one<{ status: string }>('SELECT status FROM account_opening_request WHERE no = ?', no);
  return { autoApproved: after?.status === 'Approved' };
}

/** Pulls a submission back to Open — same rules as cancelEditApproval(). */
export async function cancelAccountOpeningApproval(no: string, user: Actor): Promise<void> {
  const req = await one<Pick<AccountOpeningRequest, 'status' | 'created_by'>>(
    'SELECT status, created_by FROM account_opening_request WHERE no = ?', no,
  );
  if (!req) throw new AppError('Account opening request not found', 'NOT_FOUND');
  if (req.status !== 'Pending Approval') {
    throw new AppError('Only a request pending approval can have its approval request cancelled', 'VALIDATION');
  }
  const routed = await findPendingRoutedTask('ACCOUNT_OPENING', no);
  const requestedBy = routed?.requested_by ?? req.created_by;
  if (requestedBy !== user.username) {
    throw new AppError('Only the person who submitted this request for approval can cancel it', 'NOT_REQUESTER');
  }
  await run("UPDATE account_opening_request SET status = 'Open' WHERE no = ?", no);
  await logTableChange(
    'account_opening_request', no, 'Modification',
    [{ field: 'status', oldValue: req.status, newValue: 'Open' }], user,
  );
}

export async function approveAccountOpeningRequest(no: string, user: Actor): Promise<void> {
  const req = await one<AccountOpeningRequest>('SELECT * FROM account_opening_request WHERE no = ?', no);
  if (!req) throw new AppError('Account opening request not found', 'NOT_FOUND');
  if (req.status !== 'Pending Approval') {
    throw new AppError('Only a request pending approval can be approved', 'VALIDATION');
  }
  await run("UPDATE account_opening_request SET status = 'Approved', decision_reason = NULL WHERE no = ?", no);
  const changes = diffFields(
    req as unknown as Record<string, unknown>, { status: 'Approved', decision_reason: null },
  );
  await logTableChange('account_opening_request', no, 'Modification', changes, user);
}

/** Rejection sends the request back to Open, not a terminal state — the requester can amend
 *  and resubmit it, the same shape lib/loanService.ts's approve(approve: false) already uses.
 *  decision_reason carries the rejection comment along, so it's visible on the reopened
 *  request until the next decision overwrites or clears it. */
export async function rejectAccountOpeningRequest(no: string, reason: string | null, user: Actor): Promise<void> {
  if (!reason || !reason.trim()) throw new AppError('A reason is required to reject a request', 'VALIDATION');
  const req = await one<AccountOpeningRequest>('SELECT * FROM account_opening_request WHERE no = ?', no);
  if (!req) throw new AppError('Account opening request not found', 'NOT_FOUND');
  if (req.status !== 'Pending Approval') {
    throw new AppError('Only a request pending approval can be rejected', 'VALIDATION');
  }
  await run("UPDATE account_opening_request SET status = 'Open', decision_reason = ? WHERE no = ?", reason || null, no);
  const changes = diffFields(
    req as unknown as Record<string, unknown>, { status: 'Open', decision_reason: reason || null },
  );
  await logTableChange('account_opening_request', no, 'Modification', changes, user);
}

/** Approved -> a real savings.openAccount() call, linked back onto the request as "Processed". */
export async function processAccountOpeningRequest(no: string, user: Actor): Promise<{ accountId: number }> {
  return tx(async () => {
    const req = await one<AccountOpeningRequest>('SELECT * FROM account_opening_request WHERE no = ?', no);
    if (!req) throw new AppError('Account opening request not found', 'NOT_FOUND');
    if (req.status !== 'Approved') {
      throw new AppError('Only an approved request can be processed', 'VALIDATION');
    }

    // Always opened at a zero balance — funding it is a separate Savings & FOSA deposit,
    // not part of this request, so the product's minimum-opening rule doesn't apply here.
    // Whatever business/junior details the request staged carry straight onto the account.
    const account = await openAccount({
      memberId: req.member_id, productId: req.savings_product_id, user, enforceMinOpening: false,
      businessName: req.business_name, businessLocation: req.business_location,
      businessPaybillTillNo: req.business_paybill_till_no, businessPhoneNo: req.business_phone_no,
      juniorName: req.junior_name, juniorBirthCertNo: req.junior_birth_cert_no,
      juniorDateOfBirth: req.junior_date_of_birth, juniorPhoto: req.junior_photo,
    });

    await run(
      `UPDATE account_opening_request
       SET account_id = ?, status = 'Processed', processed_at = ?, processed_by = ? WHERE no = ?`,
      account.id, new Date().toISOString(), user.username, no,
    );
    const changes = diffFields(
      req as unknown as Record<string, unknown>, { account_id: account.id, status: 'Processed' },
    );
    await logTableChange('account_opening_request', no, 'Modification', changes, user);
    return { accountId: account.id };
  });
}
