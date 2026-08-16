import { one, all } from './db.ts';
import { accountBalances } from './accounting.ts';
import { getTrialBalance, resolveDimensionFilterIds, TRIAL_BALANCE_FILTER_FIELDS } from './gl.ts';
import { PROVISION_RATE, CLASSIFICATION_ORDER } from './loans.ts';
import { myPendingWorkflowTaskCount } from './workflow.ts';
import { buildFilterClause, type FilterCondition } from './listFilters.ts';
import type {
  BalanceSheet, Cents, DashboardData, IncomeStatement, IsoDate,
  ParRow, PortfolioAtRisk, ReportLine, TxnWithMember,
} from './types.ts';

const DEPOSIT_CODES = ['2010', '2020', '2030', '2040'] as const;
const CASH_CODES = ['1010', '1020', '1030'] as const;
const LOAN_CODES = ['1110', '1120', '1130', '1140'] as const;
const INCOME_CODES = ['4010', '4020', '4030', '4040', '4050'] as const;
const EXPENSE_CODES = ['5010', '5020', '5030', '5040', '5050'] as const;
const SHARE_CODE = '3010';

export async function getDashboard(userId: number, username: string): Promise<DashboardData> {
  // One grouped scan for every control account the tiles need, instead of the
  // thirteen separate balance queries the old endpoint issued. The tiles are
  // independent of one another, so the whole dashboard is one wave of queries.
  const [bal, members, loans, deposits, monthlyDesc, par, pendingApprovals, recentTxns] = await Promise.all([
    accountBalances([
      ...DEPOSIT_CODES, ...CASH_CODES, ...LOAN_CODES, ...INCOME_CODES, ...EXPENSE_CODES, SHARE_CODE,
    ]),
    one<DashboardData['members']>(
      `SELECT COUNT(*) total,
              SUM(CASE WHEN status='ACTIVE' THEN 1 ELSE 0 END) active,
              SUM(CASE WHEN status='DORMANT' THEN 1 ELSE 0 END) dormant
       FROM member`,
    ),
    one<DashboardData['loans']>(
      `SELECT COUNT(*) total,
              SUM(CASE WHEN status='PENDING APPROVAL' THEN 1 ELSE 0 END) pending,
              SUM(CASE WHEN status='APPROVED' THEN 1 ELSE 0 END) approved,
              SUM(CASE WHEN status='DISBURSED' THEN 1 ELSE 0 END) active,
              COALESCE(SUM(CASE WHEN status='DISBURSED' THEN principal_balance ELSE 0 END),0) portfolio,
              COALESCE(SUM(CASE WHEN status='DISBURSED' THEN arrears_amount ELSE 0 END),0) arrears
       FROM loan`,
    ),
    all<DashboardData['deposits'][number]>(
      `SELECT p.category, p.name, COALESCE(SUM(sa.balance),0) total, COUNT(sa.id) accounts
       FROM savings_product p LEFT JOIN savings_account sa ON sa.product_id = p.id
       GROUP BY p.id ORDER BY total DESC`,
    ),
    all<DashboardData['monthly'][number]>(
      // "month" is a keyword in PostgreSQL and cannot be a bare column alias.
      `SELECT substr(value_date,1,7) AS month,
              COALESCE(SUM(CASE WHEN txn_type='DEPOSIT' THEN amount ELSE 0 END),0) deposits,
              COALESCE(SUM(CASE WHEN txn_type='WITHDRAWAL' THEN -amount ELSE 0 END),0) withdrawals,
              COALESCE(SUM(CASE WHEN txn_type='DISBURSEMENT' AND module='LOAN' THEN amount ELSE 0 END),0) disbursements
       FROM txn WHERE status='POSTED' GROUP BY month ORDER BY month DESC LIMIT 12`,
    ),
    all<DashboardData['par'][number]>(
      `SELECT classification, COUNT(*) loans, COALESCE(SUM(principal_balance),0) balance
       FROM loan WHERE status='DISBURSED' GROUP BY classification`,
    ),
    myPendingWorkflowTaskCount(userId, username),
    all<TxnWithMember>(
      `SELECT t.*, m.member_no, m.first_name, m.last_name
       FROM txn t LEFT JOIN member m ON m.id = t.member_id
       ORDER BY t.id DESC LIMIT 12`,
    ),
  ]);

  const sum = (codes: readonly string[]): Cents => codes.reduce((a, c) => a + bal[c], 0);
  const income = sum(INCOME_CODES);
  const expense = sum(EXPENSE_CODES);

  return {
    members: members!,
    loans: loans!,
    deposits,
    totalDeposits: sum(DEPOSIT_CODES),
    shareCapital: bal[SHARE_CODE],
    cash: sum(CASH_CODES),
    loanPortfolio: sum(LOAN_CODES),
    income,
    expense,
    surplus: income - expense,
    par,
    monthly: monthlyDesc.reverse(),
    pendingApprovals,
    recentTxns,
  };
}

export interface GetBalanceSheetOptions {
  /** One-line Date Filter range (see lib/format.ts's parseDateFilterExpression) — left unset,
   *  the usual cumulative Balance at Date; paired with `asOf`, a Net Change for that period,
   *  the same Date Filter FlowField behaviour as the Trial Balance this reuses. */
  from?: IsoDate | null;
  asOf?: IsoDate | null;
  /** Same filter bar as the Trial Balance: Code/Name/Type plus the Dimensional filter
   *  (Global Dimension combination/range expression) — see TRIAL_BALANCE_DIMENSION_FILTER_
   *  FIELDS in gl.ts. */
  filters?: FilterCondition[];
}

export async function getBalanceSheet(
  { from, asOf, filters = [] }: GetBalanceSheetOptions = {},
): Promise<BalanceSheet> {
  const { rows } = await getTrialBalance({ from, asOf, filters });
  const group = (t: string): ReportLine[] =>
    rows.filter((r) => r.type === t).map((r) => ({ code: r.code, name: r.name, amount: r.net }));
  const sum = (a: ReportLine[]): Cents => a.reduce((x, y) => x + y.amount, 0);

  const assets = group('ASSET');
  const liabilities = group('LIABILITY');
  const equity = group('EQUITY');
  const surplus = sum(group('INCOME')) - sum(group('EXPENSE'));

  const totals = {
    assets: sum(assets),
    liabilities: sum(liabilities),
    equity: sum(equity),
    equityAndLiabilities: sum(liabilities) + sum(equity) + surplus,
  };
  return { assets, liabilities, equity, surplus, totals, balanced: totals.assets === totals.equityAndLiabilities };
}

export interface GetIncomeStatementOptions {
  from?: string;
  to?: string;
  /** Same filter bar as the Trial Balance — see GetBalanceSheetOptions.filters. */
  filters?: FilterCondition[];
}

export async function getIncomeStatement(
  { from, to, filters = [] }: GetIncomeStatementOptions = {},
): Promise<IncomeStatement> {
  // A plain INNER JOIN, unlike the Trial Balance's own LEFT JOIN aggregate — an income/expense
  // account with nothing posted in the period is meant to be absent here (the report only ever
  // shows accounts with real activity; Section's own render already drops amount === 0 lines
  // regardless), so a dimension/account condition is safe straight in the WHERE clause.
  const { clause: whereClause, params: whereParams } = buildFilterClause(TRIAL_BALANCE_FILTER_FIELDS, filters, 'is');
  const gd1 = filters.find((f) => f.field === 'gd1_filter' && f.value !== '');
  const gd2 = filters.find((f) => f.field === 'gd2_filter' && f.value !== '');
  const [gd1Ids, gd2Ids] = await Promise.all([
    gd1 ? resolveDimensionFilterIds(1, gd1.value) : Promise.resolve(null),
    gd2 ? resolveDimensionFilterIds(2, gd2.value) : Promise.resolve(null),
  ]);
  const dimParams: Record<string, unknown> = {};
  const dimParts: string[] = [];
  if (gd1Ids !== null) { dimParts.push('AND jl.global_dimension_1_id = ANY(@gd1Ids)'); dimParams.gd1Ids = gd1Ids; }
  if (gd2Ids !== null) { dimParts.push('AND jl.global_dimension_2_id = ANY(@gd2Ids)'); dimParams.gd2Ids = gd2Ids; }

  const rows = await all<{ code: string; name: string; type: string; d: Cents; c: Cents }>(
    `SELECT a.code, a.name, a.type, COALESCE(SUM(jl.debit),0) d, COALESCE(SUM(jl.credit),0) c
     FROM gl_account a
     JOIN journal_line jl ON jl.gl_account_id = a.id
     JOIN journal j ON j.id = jl.journal_id
     WHERE a.type IN ('INCOME','EXPENSE')
       AND j.value_date >= COALESCE(@from::text, '0000-01-01') AND j.value_date <= COALESCE(@to::text, '9999-12-31')
       ${whereClause}
       ${dimParts.join(' ')}
     GROUP BY a.id ORDER BY a.code`,
    { from: from || null, to: to || null, ...whereParams, ...dimParams },
  );
  const income = rows.filter((r) => r.type === 'INCOME')
    .map((r) => ({ code: r.code, name: r.name, amount: r.c - r.d }));
  const expense = rows.filter((r) => r.type === 'EXPENSE')
    .map((r) => ({ code: r.code, name: r.name, amount: r.d - r.c }));
  const s = (a: ReportLine[]): Cents => a.reduce((x, y) => x + y.amount, 0);
  return {
    income, expense,
    totalIncome: s(income), totalExpense: s(expense),
    surplus: s(income) - s(expense),
    from, to,
  };
}

/** Portfolio at risk / SASRA-style risk classification (Form 4 shape). */
export async function getPortfolioAtRisk(): Promise<PortfolioAtRisk> {
  const raw = await all<Pick<ParRow, 'classification' | 'loans' | 'balance' | 'arrears'>>(
    `SELECT classification, COUNT(*) loans, COALESCE(SUM(principal_balance),0) balance,
            COALESCE(SUM(arrears_amount),0) arrears
     FROM loan WHERE status='DISBURSED' GROUP BY classification`,
  );
  const rows: ParRow[] = CLASSIFICATION_ORDER.map((classification) => {
    const r = raw.find((x) => x.classification === classification);
    const balance = r?.balance ?? 0;
    const rate = PROVISION_RATE[classification];
    return {
      classification,
      loans: r?.loans ?? 0,
      balance,
      arrears: r?.arrears ?? 0,
      provision_rate: rate,
      provision: Math.round(balance * rate),
    };
  });
  const total = rows.reduce((a, r) => a + r.balance, 0);
  const atRisk = rows.filter((r) => r.classification !== 'PERFORMING').reduce((a, r) => a + r.balance, 0);
  return {
    rows,
    total,
    atRisk,
    parPct: total ? Number(((atRisk / total) * 100).toFixed(2)) : 0,
    totalProvision: rows.reduce((a, r) => a + r.provision, 0),
  };
}

