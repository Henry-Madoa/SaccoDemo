/*
 * BOSA / savings service. Balances are never written directly — every change
 * is the product of a transaction that also posts a balanced journal.
 */
import {
  one, all, run, tx, nextSequence, audit, hasAnyRow,
} from './db.ts';
import { postJournal, reverseJournal } from './accounting.ts';
import { PostingError } from './errors.ts';
import { buildFilterClause, type FilterCondition, type FilterFieldDef } from './listFilters.ts';
import { buildOrderClause, type SortState } from './listSort.ts';
import { SAVINGS_ACCOUNT_STATUSES, SAVINGS_CATEGORIES } from './constants.ts';
import type {
  Actor, Cents, Channel, IsoDate, JournalLineInput, Member,
  SavingsAccountFull, SavingsAccountListRow, SavingsProduct, Statement, Txn, TxnWithDocument,
} from './types.ts';

export const CHANNEL_GL: Record<Channel, string> = {
  TELLER: '1010',   // Cash in hand
  MPESA: '1030',    // M-Pesa settlement
  BANK: '1020',     // Bank current account
  CHECKOFF: '1040', // Check-off receivable clearing
  SYSTEM: '1020',
};

const today = (): IsoDate => new Date().toISOString().slice(0, 10);

export function getAccount(id: number): Promise<SavingsAccountFull | undefined> {
  return one<SavingsAccountFull>(
    `SELECT sa.*, p.name AS product_name, p.code AS product_code, p.category,
            p.min_balance, p.allow_withdrawal, p.withdrawal_fee,
            p.gl_control_id, p.gl_fee_income_id, p.is_loanable_base, p.is_business_account,
            m.member_no, m.first_name, m.last_name
     FROM savings_account sa
     JOIN savings_product p ON p.id = sa.product_id
     JOIN member m ON m.id = sa.member_id
     WHERE sa.id = ?`,
    id,
  );
}

/** The account immediately before/after this one by id — for the card's Business-Central-style
 *  Previous/Next navigation. */
export async function getAdjacentAccountIds(id: number): Promise<{ prevId: number | null; nextId: number | null }> {
  const [prev, next] = await Promise.all([
    one<{ id: number }>('SELECT id FROM savings_account WHERE id < ? ORDER BY id DESC LIMIT 1', id),
    one<{ id: number }>('SELECT id FROM savings_account WHERE id > ? ORDER BY id ASC LIMIT 1', id),
  ]);
  return { prevId: prev?.id ?? null, nextId: next?.id ?? null };
}

/** Savings accounts list's dynamic-filter registry — every meaningful column, including a
 *  couple joined in from the product (category, min_balance). product_id ships without
 *  `options` since it's DB-driven; the page fills it in from listActiveSavingsProducts(). */
export const SAVINGS_ACCOUNT_FILTER_FIELDS: FilterFieldDef[] = [
  { key: 'account_no', label: 'Account No.', type: 'text', column: 'sa.account_no' },
  {
    key: 'status', label: 'Status', type: 'select', column: 'sa.status',
    options: SAVINGS_ACCOUNT_STATUSES.map((s) => ({ value: s, label: s })),
  },
  { key: 'product_id', label: 'Product', type: 'select', column: 'sa.product_id' },
  { key: 'category', label: 'Category', type: 'select', column: 'p.category', options: SAVINGS_CATEGORIES.map((c) => ({ value: c, label: c })) },
  { key: 'balance', label: 'Balance', type: 'number', column: 'sa.balance' },
  { key: 'hold_amount', label: 'Hold Amount', type: 'number', column: 'sa.hold_amount' },
  { key: 'min_balance', label: 'Min. Balance', type: 'number', column: 'p.min_balance' },
  { key: 'opened_date', label: 'Opened Date', type: 'date', column: 'sa.opened_date' },
  { key: 'last_activity', label: 'Last Activity', type: 'date', column: 'sa.last_activity' },
];

/** Savings accounts list's sortable columns — every column shown in the table. */
const SAVINGS_ACCOUNT_SORT_COLUMNS: Record<string, string> = {
  account_no: 'sa.account_no',
  member: 'm.first_name',
  product_name: 'p.name',
  status: 'sa.status',
  balance: 'sa.balance',
  available: '(sa.balance - sa.hold_amount - p.min_balance)',
};

export interface ListAccountsOptions {
  search?: string;
  filters?: FilterCondition[];
  sort?: SortState | null;
}

/** Whether any savings account exists at all, ignoring search and dynamic filters — lets the
 *  page grey out its filter controls only when there's truly nothing to filter. */
export const hasAnyAccounts = (): Promise<boolean> => hasAnyRow('savings_account sa');

/** Accounts matching a free-text search over account number, member number or name,
 *  further narrowed by any dynamic filter conditions. */
export function listAccounts(
  { search = '', filters = [], sort = null }: ListAccountsOptions = {},
): Promise<SavingsAccountListRow[]> {
  const { clause, params } = buildFilterClause(SAVINGS_ACCOUNT_FILTER_FIELDS, filters);
  const orderBy = buildOrderClause(SAVINGS_ACCOUNT_SORT_COLUMNS, sort, 'sa.id DESC');
  return all<SavingsAccountListRow>(
    `SELECT sa.*, p.name AS product_name, p.code AS product_code, p.category,
            p.allow_withdrawal, p.min_balance,
            m.member_no, m.first_name, m.last_name
     FROM savings_account sa
     JOIN savings_product p ON p.id = sa.product_id
     JOIN member m ON m.id = sa.member_id
     WHERE (sa.account_no LIKE @like OR m.member_no LIKE @like
        OR m.first_name LIKE @like OR m.last_name LIKE @like)
       ${clause}
     ${orderBy} LIMIT 200`,
    { like: `%${String(search).trim()}%`, ...params },
  );
}

export interface OpenAccountInput {
  memberId: number;
  productId: number;
  openingBalance?: Cents;
  channel?: Channel;
  user?: Actor | null;
  /** Set false to provision an unfunded account (e.g. a category default opened at registration, before any teller deposit) without the minimum-opening-deposit rule. */
  enforceMinOpening?: boolean;
  /** Captured by the Account Opening module when the product is flagged is_business_account. */
  businessName?: string | null;
  businessLocation?: string | null;
  businessPaybillTillNo?: string | null;
  businessPhoneNo?: string | null;
  /** Captured by the Account Opening module when the product's category is JUNIOR ACCOUNT. */
  juniorName?: string | null;
  juniorBirthCertNo?: string | null;
  juniorDateOfBirth?: IsoDate | null;
  juniorPhoto?: string | null;
}

export async function openAccount({
  memberId, productId, openingBalance = 0, channel = 'TELLER', user = null, enforceMinOpening = true,
  businessName = null, businessLocation = null, businessPaybillTillNo = null, businessPhoneNo = null,
  juniorName = null, juniorBirthCertNo = null, juniorDateOfBirth = null, juniorPhoto = null,
}: OpenAccountInput): Promise<SavingsAccountFull> {
  const member = await one<Member>('SELECT * FROM member WHERE id = ?', memberId);
  if (!member) throw new PostingError('Member not found', 'MEMBER_NOT_FOUND');
  if (member.status === 'WITHDRAWN') throw new PostingError('Member has exited the society', 'MEMBER_EXITED');
  const product = await one<SavingsProduct>('SELECT * FROM savings_product WHERE id = ?', productId);
  if (!product) throw new PostingError('Savings product not found', 'PRODUCT_NOT_FOUND');
  if (product.status !== 'ACTIVE') throw new PostingError('Savings product is not active', 'PRODUCT_INACTIVE');
  if (enforceMinOpening && openingBalance < product.min_opening) {
    throw new PostingError(
      `Opening deposit must be at least ${product.min_opening / 100} for ${product.name}`, 'BELOW_MIN_OPENING',
    );
  }

  // A member may hold only one account per product — except Junior and Business products,
  // where multiple make sense (one per child, one per business) and are told apart by their
  // own identifying details instead.
  const isJunior = product.category === 'JUNIOR ACCOUNT';
  if (!isJunior && !product.is_business_account) {
    const existing = await one('SELECT 1 FROM savings_account WHERE member_id = ? AND product_id = ?', memberId, productId);
    if (existing) {
      throw new PostingError(
        `${member.first_name} ${member.last_name} already has a ${product.name} account — only one is allowed per member`,
        'DUPLICATE_PRODUCT_ACCOUNT',
      );
    }
  }

  // The Birth Notification/Certificate No. is a Junior Account's unique identifier — always
  // uppercase, and required precisely because multiple Junior accounts per member are allowed
  // (it's what tells them apart).
  let normalizedJuniorBirthCertNo: string | null = null;
  if (isJunior) {
    normalizedJuniorBirthCertNo = (juniorBirthCertNo || '').trim().toUpperCase() || null;
    if (!normalizedJuniorBirthCertNo) {
      throw new PostingError('A Birth Notification/Certificate No. is required to open a Junior Account', 'JUNIOR_CERT_REQUIRED');
    }
    const dup = await one('SELECT 1 FROM savings_account WHERE junior_birth_cert_no = ?', normalizedJuniorBirthCertNo);
    if (dup) {
      throw new PostingError(
        `A Junior Account already exists for Birth Notification/Certificate No. "${normalizedJuniorBirthCertNo}"`,
        'DUPLICATE_JUNIOR_CERT',
      );
    }
  }

  const id = await tx(async () => {
    const accountNo = await nextSequence('SAVINGS_ACCOUNT');
    const info = await run(
      `INSERT INTO savings_account
         (account_no, member_id, product_id, balance, status, opened_date, last_activity,
          business_name, business_location, business_paybill_till_no, business_phone_no,
          junior_name, junior_birth_cert_no, junior_date_of_birth, junior_photo)
       VALUES (?,?,?,0,'ACTIVE',?,?,?,?,?,?,?,?,?,?)`,
      accountNo, memberId, productId, today(), today(),
      businessName, businessLocation, businessPaybillTillNo, businessPhoneNo,
      juniorName, normalizedJuniorBirthCertNo, juniorDateOfBirth, juniorPhoto,
    );
    const accountId = Number(info.lastInsertRowid);
    if (openingBalance > 0) {
      await deposit({ accountId, amount: openingBalance, channel, description: 'Opening deposit', user });
    }
    await audit(user, 'SAVINGS_ACCOUNT_OPEN', 'savings_account', accountId, { accountNo, productId, openingBalance });
    return accountId;
  });

  return (await getAccount(id))!;
}

export interface DepositInput {
  accountId: number;
  amount: Cents;
  channel?: Channel;
  valueDate?: IsoDate;
  description?: string;
  reference?: string | null;
  user?: Actor | null;
  idempotencyKey?: string | null;
}

export interface PostingResult {
  txn: Txn;
  balance: Cents;
  fee?: Cents;
  duplicate?: boolean;
}

export async function deposit({
  accountId, amount, channel = 'TELLER', valueDate, description,
  reference = null, user = null, idempotencyKey = null,
}: DepositInput): Promise<PostingResult> {
  amount = Math.round(amount);
  if (!(amount > 0)) throw new PostingError('Deposit amount must be greater than zero', 'INVALID_AMOUNT');
  const acct = await getAccount(accountId);
  if (!acct) throw new PostingError('Savings account not found', 'ACCOUNT_NOT_FOUND');
  if (acct.status === 'CLOSED') throw new PostingError('Account is closed', 'ACCOUNT_CLOSED');
  if (acct.status === 'FROZEN') throw new PostingError('Account is frozen — posting prohibited', 'ACCOUNT_FROZEN');
  if (acct.status === 'INACTIVE') throw new PostingError('Account is inactive — posting prohibited', 'ACCOUNT_INACTIVE');

  const vd = valueDate || today();
  const res = await tx<PostingResult>(async () => {
    if (idempotencyKey) {
      const dup = await one<Txn>('SELECT * FROM txn WHERE txn_ref = ?', idempotencyKey);
      if (dup) return { duplicate: true, txn: dup, balance: acct.balance };
    }
    const j = await postJournal({
      valueDate: vd,
      module: 'SAVINGS',
      eventType: 'DEPOSIT',
      description: description || `Deposit to ${acct.account_no}`,
      reference,
      memberId: acct.member_id,
      user,
      idempotencyKey,
      lines: [
        { account: CHANNEL_GL[channel] || CHANNEL_GL.TELLER, debit: amount, credit: 0 },
        { account: acct.gl_control_id, debit: 0, credit: amount },
      ],
    });
    const newBal = acct.balance + amount;
    await run(
      `UPDATE savings_account SET balance = ?, last_activity = ?, version = version + 1,
        status = CASE WHEN status = 'DORMANT' THEN 'ACTIVE' ELSE status END WHERE id = ?`,
      newBal, vd, accountId,
    );
    const info = await run(
      `INSERT INTO txn (txn_ref, value_date, created_at, module, txn_type, member_id,
         savings_account_id, amount, running_balance, channel, description, journal_id, created_by)
       VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?)`,
      idempotencyKey || await nextSequence('TXN'), vd, new Date().toISOString(), 'SAVINGS', 'DEPOSIT',
      acct.member_id, accountId, amount, newBal, channel, description || 'Deposit', j.id,
      user ? user.username : 'system',
    );
    return {
      txn: (await one<Txn>('SELECT * FROM txn WHERE id = ?', Number(info.lastInsertRowid)))!,
      balance: newBal,
    };
  });

  await audit(user, 'SAVINGS_DEPOSIT', 'savings_account', accountId, { amount, channel });
  return res;
}

export interface WithdrawInput extends DepositInput {}

export async function withdraw({
  accountId, amount, channel = 'TELLER', valueDate, description, user = null, idempotencyKey = null,
}: WithdrawInput): Promise<PostingResult> {
  amount = Math.round(amount);
  if (!(amount > 0)) throw new PostingError('Withdrawal amount must be greater than zero', 'INVALID_AMOUNT');
  const acct = await getAccount(accountId);
  if (!acct) throw new PostingError('Savings account not found', 'ACCOUNT_NOT_FOUND');
  if (acct.status !== 'ACTIVE') throw new PostingError(`Account status is ${acct.status} — withdrawal prohibited`, 'ACCOUNT_NOT_ACTIVE');
  if (!acct.allow_withdrawal) throw new PostingError(`${acct.product_name} does not permit withdrawals`, 'WITHDRAWAL_NOT_ALLOWED');

  const fee = acct.withdrawal_fee || 0;
  const available = acct.balance - acct.hold_amount - acct.min_balance;
  if (amount + fee > available) {
    throw new PostingError(
      `Insufficient available funds. Available ${(available / 100).toFixed(2)}, requested ${((amount + fee) / 100).toFixed(2)} (incl. fee)`,
      'INSUFFICIENT_FUNDS',
    );
  }

  const vd = valueDate || today();
  const res = await tx<PostingResult>(async () => {
    const lines: JournalLineInput[] = [
      { account: acct.gl_control_id, debit: amount, credit: 0, narration: 'Member withdrawal' },
      { account: CHANNEL_GL[channel] || CHANNEL_GL.TELLER, debit: 0, credit: amount },
    ];
    if (fee > 0) {
      lines.push({ account: acct.gl_control_id, debit: fee, credit: 0, narration: 'Withdrawal charge' });
      lines.push({ account: acct.gl_fee_income_id, debit: 0, credit: fee, narration: 'Withdrawal charge' });
    }
    const j = await postJournal({
      valueDate: vd, module: 'SAVINGS', eventType: 'WITHDRAWAL',
      description: description || `Withdrawal from ${acct.account_no}`,
      memberId: acct.member_id, user, idempotencyKey, lines,
    });
    const newBal = acct.balance - amount - fee;
    await run(
      'UPDATE savings_account SET balance = ?, last_activity = ?, version = version + 1 WHERE id = ?',
      newBal, vd, accountId,
    );
    const info = await run(
      `INSERT INTO txn (txn_ref, value_date, created_at, module, txn_type, member_id,
         savings_account_id, amount, running_balance, channel, description, journal_id, created_by)
       VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?)`,
      await nextSequence('TXN'), vd, new Date().toISOString(), 'SAVINGS', 'WITHDRAWAL', acct.member_id,
      accountId, -(amount + fee), newBal, channel, description || 'Withdrawal', j.id,
      user ? user.username : 'system',
    );
    return {
      txn: (await one<Txn>('SELECT * FROM txn WHERE id = ?', Number(info.lastInsertRowid)))!,
      balance: newBal,
      fee,
    };
  });

  await audit(user, 'SAVINGS_WITHDRAWAL', 'savings_account', accountId, { amount, fee, channel });
  return res;
}

export interface ReverseTxnInput {
  txnId: number;
  reason: string;
  user?: Actor | null;
}

export async function reverseTxn(
  { txnId, reason, user = null }: ReverseTxnInput,
): Promise<{ balance: Cents; journal_no: string }> {
  const t = await one<Txn>('SELECT * FROM txn WHERE id = ?', txnId);
  if (!t) throw new PostingError('Transaction not found', 'NOT_FOUND');
  if (t.status === 'REVERSED') throw new PostingError('Transaction already reversed', 'ALREADY_REVERSED');
  if (!reason) throw new PostingError('A reversal reason is required', 'REASON_REQUIRED');

  const res = await tx(async () => {
    const rev = await reverseJournal(t.journal_id!, user, reason);
    const acct = (await getAccount(t.savings_account_id!))!;
    const newBal = acct.balance - t.amount;
    await run('UPDATE savings_account SET balance = ?, version = version + 1 WHERE id = ?', newBal, acct.id);
    await run("UPDATE txn SET status = 'REVERSED' WHERE id = ?", txnId);
    await run(
      `INSERT INTO txn (txn_ref, value_date, created_at, module, txn_type, member_id,
         savings_account_id, amount, running_balance, channel, description, journal_id, created_by, reversal_of)
       VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?)`,
      await nextSequence('TXN'), today(), new Date().toISOString(), 'SAVINGS', 'REVERSAL', t.member_id,
      t.savings_account_id, -t.amount, newBal, t.channel, `Reversal of ${t.txn_ref}: ${reason}`, rev.id,
      user ? user.username : 'system', txnId,
    );
    return { balance: newBal, journal_no: rev.journal_no };
  });

  await audit(user, 'SAVINGS_REVERSAL', 'txn', txnId, { reason });
  return res;
}

/** Whether an account has any transactions at all, ignoring the statement's from/to range —
 *  lets the page grey out its date filters only when there's truly nothing to filter. */
export const hasAnyTxns = (accountId: number): Promise<boolean> =>
  hasAnyRow('txn', 'savings_account_id = ?', accountId);

export async function statement(accountId: number, from?: IsoDate, to?: IsoDate): Promise<Statement> {
  const account = await getAccount(accountId);
  if (!account) throw new PostingError('Account not found', 'NOT_FOUND');
  const [lines, prior] = await Promise.all([
    all<TxnWithDocument>(
      `SELECT t.*, j.reference AS document_no,
              gd1.code AS global_dimension_1_code, gd2.code AS global_dimension_2_code
       FROM txn t
       LEFT JOIN journal j ON j.id = t.journal_id
       LEFT JOIN global_dimension_1_value gd1 ON gd1.id = j.global_dimension_1_id
       LEFT JOIN global_dimension_2_value gd2 ON gd2.id = j.global_dimension_2_id
       WHERE t.savings_account_id = ?
         AND t.value_date >= COALESCE(?, '0000-01-01')
         AND t.value_date <= COALESCE(?, '9999-12-31')
       ORDER BY t.id`,
      accountId, from || null, to || null,
    ),
    one<{ s: Cents }>(
      `SELECT COALESCE(SUM(amount),0) s FROM txn
       WHERE savings_account_id = ? AND value_date < COALESCE(?, '0000-01-01')`,
      accountId, from || null,
    ),
  ]);
  return { account, opening: prior!.s, lines };
}
