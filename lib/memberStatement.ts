/*
 * Member Statement — a multi-filter, multi-member statement of account and loan
 * activity. Reuses the exact opening/running-balance recipe lib/savings.ts's
 * statement() already established (SUM(amount) strictly before the range for the
 * opening balance, then a chronological running scan for the period) against the
 * unified `txn` ledger, scoped per member instead of per single account.
 *
 * A loan's own ledger entries carry `loan_id` alongside `savings_account_id` on
 * the disbursement/repayment leg that also moves a savings account (see
 * lib/loanService.ts) — `savings_account_id IS NULL` is what tells a loan's own
 * entry apart from that account-side leg, so a loan's ledger never double-counts
 * a movement already shown under the account it landed in.
 */
import { all, one } from './db.ts';
import { getMember } from './members.ts';
import type {
  Cents, IsoDate, LoanWithProductName, MemberWithDimensions, SavingsAccountWithProduct, TxnWithDocument,
} from './types.ts';

export interface MemberStatementFilters {
  memberIds: number[];
  /** Empty/omitted = every eligible account for each member. */
  accountIds?: number[];
  /** Empty/omitted = every disbursed loan for each member. */
  loanIds?: number[];
  from?: IsoDate | null;
  to?: IsoDate | null;
  showAccounts?: boolean;
  showLoans?: boolean;
}

export interface StatementLine {
  txn: TxnWithDocument;
  running: Cents;
}

export interface StatementAccountSection {
  account: SavingsAccountWithProduct;
  opening: Cents;
  lines: StatementLine[];
  closing: Cents;
}

export interface StatementLoanSection {
  loan: LoanWithProductName;
  opening: Cents;
  lines: StatementLine[];
  closing: Cents;
}

export interface MemberStatementDocument {
  member: MemberWithDimensions;
  accounts: StatementAccountSection[];
  loans: StatementLoanSection[];
}

const LEDGER_SELECT = `
  SELECT t.*, j.reference AS document_no,
         gd1.code AS global_dimension_1_code, gd2.code AS global_dimension_2_code
  FROM txn t
  LEFT JOIN journal j ON j.id = t.journal_id
  LEFT JOIN global_dimension_1_value gd1 ON gd1.id = j.global_dimension_1_id
  LEFT JOIN global_dimension_2_value gd2 ON gd2.id = j.global_dimension_2_id`;

/** Walks lines in chronological order, carrying a running balance forward from `opening` —
 *  `txn.amount` already carries the correct sign for both a savings account and a loan (a
 *  disbursement is a positive LOAN-module amount, a repayment negative — see loanService.ts),
 *  so one accumulation rule serves both ledger kinds; there is no BC-style sign flip to port. */
function walkRunningBalance(lines: TxnWithDocument[], opening: Cents): { lines: StatementLine[]; closing: Cents } {
  let running = opening;
  const rows = lines.map((txn) => {
    running += txn.amount;
    return { txn, running };
  });
  return { lines: rows, closing: rows.length ? rows[rows.length - 1].running : opening };
}

async function buildAccountSection(
  account: SavingsAccountWithProduct, from?: IsoDate | null, to?: IsoDate | null,
): Promise<StatementAccountSection> {
  const [lines, prior] = await Promise.all([
    all<TxnWithDocument>(
      `${LEDGER_SELECT}
       WHERE t.savings_account_id = ?
         AND t.value_date >= COALESCE(?, '0000-01-01')
         AND t.value_date <= COALESCE(?, '9999-12-31')
       ORDER BY t.id`,
      account.id, from || null, to || null,
    ),
    one<{ s: Cents }>(
      `SELECT COALESCE(SUM(amount),0) s FROM txn
       WHERE savings_account_id = ? AND value_date < COALESCE(?, '0000-01-01')`,
      account.id, from || null,
    ),
  ]);
  const opening = prior!.s;
  const { lines: rows, closing } = walkRunningBalance(lines, opening);
  return { account, opening, lines: rows, closing };
}

async function buildLoanSection(
  loan: LoanWithProductName, from?: IsoDate | null, to?: IsoDate | null,
): Promise<StatementLoanSection> {
  const [lines, prior] = await Promise.all([
    all<TxnWithDocument>(
      `${LEDGER_SELECT}
       WHERE t.loan_id = ? AND t.savings_account_id IS NULL
         AND t.value_date >= COALESCE(?, '0000-01-01')
         AND t.value_date <= COALESCE(?, '9999-12-31')
       ORDER BY t.id`,
      loan.id, from || null, to || null,
    ),
    one<{ s: Cents }>(
      `SELECT COALESCE(SUM(amount),0) s FROM txn
       WHERE loan_id = ? AND savings_account_id IS NULL AND value_date < COALESCE(?, '0000-01-01')`,
      loan.id, from || null,
    ),
  ]);
  const opening = prior!.s;
  const { lines: rows, closing } = walkRunningBalance(lines, opening);
  return { loan, opening, lines: rows, closing };
}

/** A member's savings accounts eligible for the statement, optionally narrowed to `accountIds` —
 *  scoping by `member_id` in the same query that applies the id filter means a crafted id
 *  belonging to a different member simply matches nothing, rather than needing a separate
 *  ownership check (see the API layer's authorization notes). */
const eligibleAccounts = (memberId: number, accountIds?: number[]): Promise<SavingsAccountWithProduct[]> =>
  all<SavingsAccountWithProduct>(
    `SELECT sa.*, p.name AS product_name, p.code AS product_code, p.category, p.min_balance, p.allow_withdrawal
     FROM savings_account sa JOIN savings_product p ON p.id = sa.product_id
     WHERE sa.member_id = @memberId
       ${accountIds?.length ? 'AND sa.id = ANY(@accountIds)' : ''}
     ORDER BY p.id`,
    { memberId, accountIds: accountIds?.length ? accountIds : null },
  );

/** A member's disbursed loans eligible for the statement, optionally narrowed to `loanIds` — a
 *  loan that was never disbursed has no ledger entries at all, so it is excluded unconditionally
 *  (an undisbursed application has nothing to state), matching the source report's behaviour. */
const eligibleLoans = (memberId: number, loanIds?: number[]): Promise<LoanWithProductName[]> =>
  all<LoanWithProductName>(
    `SELECT l.*, p.name AS product_name
     FROM loan l JOIN loan_product p ON p.id = l.product_id
     WHERE l.member_id = @memberId AND l.disbursed_date IS NOT NULL
       ${loanIds?.length ? 'AND l.id = ANY(@loanIds)' : ''}
     ORDER BY l.id`,
    { memberId, loanIds: loanIds?.length ? loanIds : null },
  );

/** Assembles one StatementDocument per requested member, in the order requested — the
 *  single place the statement's balance math runs, so the on-screen preview, the print
 *  layout and the Excel export always agree on the same figures. Members that no longer
 *  exist (a stale id typed into a shared URL) are silently dropped rather than failing
 *  the whole batch. */
export async function buildMemberStatements(filters: MemberStatementFilters): Promise<MemberStatementDocument[]> {
  const {
    memberIds, accountIds, loanIds, from = null, to = null, showAccounts = true, showLoans = true,
  } = filters;

  const docs = await Promise.all(memberIds.map(async (memberId): Promise<MemberStatementDocument | null> => {
    const member = await getMember(memberId);
    if (!member) return null;

    const [accounts, loans] = await Promise.all([
      showAccounts ? eligibleAccounts(memberId, accountIds) : Promise.resolve([]),
      showLoans ? eligibleLoans(memberId, loanIds) : Promise.resolve([]),
    ]);
    const [accountSections, loanSections] = await Promise.all([
      Promise.all(accounts.map((a) => buildAccountSection(a, from, to))),
      Promise.all(loans.map((l) => buildLoanSection(l, from, to))),
    ]);

    return { member, accounts: accountSections, loans: loanSections };
  }));

  return docs.filter((d): d is MemberStatementDocument => d !== null);
}

export interface StatementMemberOption { id: number; member_no: string; first_name: string; last_name: string; }
export interface StatementAccountOption { id: number; account_no: string; product_name: string; member_id: number; }
export interface StatementLoanOption { id: number; loan_no: string; product_name: string; member_id: number; }

/** Every member, any status — the Member filter's typeahead source. Unlike listActiveMembers()
 *  (which backs the Loan Application picker and is deliberately ACTIVE-only), a statement is
 *  routinely pulled for someone who has since exited, so no status filter applies here. */
export const listMembersForStatementPicker = (): Promise<StatementMemberOption[]> =>
  all<StatementMemberOption>('SELECT id, member_no, first_name, last_name FROM member ORDER BY member_no');

/** Accounts across the currently-selected members — populates the Account filter's options once
 *  member(s) are chosen, so a picked option is guaranteed to belong to one of them. */
export const listMemberAccountsForFilter = (memberIds: number[]): Promise<StatementAccountOption[]> =>
  memberIds.length
    ? all<StatementAccountOption>(
        `SELECT sa.id, sa.account_no, p.name AS product_name, sa.member_id
         FROM savings_account sa JOIN savings_product p ON p.id = sa.product_id
         WHERE sa.member_id = ANY(@memberIds) ORDER BY sa.account_no`,
        { memberIds },
      )
    : Promise.resolve([]);

/** Disbursed loans across the currently-selected members — populates the Loan filter's options
 *  the same way listMemberAccountsForFilter() does for accounts. */
export const listMemberLoansForFilter = (memberIds: number[]): Promise<StatementLoanOption[]> =>
  memberIds.length
    ? all<StatementLoanOption>(
        `SELECT l.id, l.loan_no, p.name AS product_name, l.member_id
         FROM loan l JOIN loan_product p ON p.id = l.product_id
         WHERE l.member_id = ANY(@memberIds) AND l.disbursed_date IS NOT NULL ORDER BY l.loan_no`,
        { memberIds },
      )
    : Promise.resolve([]);
