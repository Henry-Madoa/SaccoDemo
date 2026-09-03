/*
 * Role Centre analytics.
 *
 * One aggregate per Role Centre, each a composition of the reused report helpers (lib/reports.ts,
 * lib/financialReports.ts, lib/gl.ts, lib/receivablesReports.ts, lib/payablesReports.ts) plus a
 * few focused queries for the trend series. All money is integer cents.
 *
 * These functions do NOT check permissions — the Role Centre page renders each widget only when
 * the viewer's permission set grants the underlying right (currentCanAction / currentCanPage),
 * so a profile without permission shows locked cards.
 */
import { one, all } from './db.ts';
import { accountBalances, trialBalance } from './accounting.ts';
import { getIncomeStatement, getBalanceSheet, getPortfolioAtRisk } from './reports.ts';
import { getDormancyAging } from './gl.ts';
import { runFinancialReport } from './financialReports.ts';
import { today } from './format.ts';
import { addMonths } from './loans.ts';
import type { Cents, IsoDate } from './types.ts';

/* ------------------------------------------------------------------- shared */

/** The last `n` calendar months as `YYYY-MM`, oldest first (includes the current month). */
export function recentMonths(n = 12): string[] {
  const base = `${today().slice(0, 8)}01`;
  return Array.from({ length: n }, (_, i) => addMonths(base, -(n - 1 - i)).slice(0, 7));
}

export interface MonthPoint { month: string; [k: string]: string | number }

/** Deposits received, withdrawals paid, loan disbursements and loan repayments per month, over
 *  the last `n` months, from the shared `txn` ledger. */
async function monthlyFlows(n = 12): Promise<{ month: string; deposits: Cents; withdrawals: Cents; disbursements: Cents; repayments: Cents }[]> {
  const months = recentMonths(n);
  const rows = await all<{ month: string; deposits: Cents; withdrawals: Cents; disbursements: Cents; repayments: Cents }>(
    `SELECT substr(value_date,1,7) AS month,
            COALESCE(SUM(CASE WHEN txn_type='DEPOSIT' THEN amount ELSE 0 END),0) deposits,
            COALESCE(SUM(CASE WHEN txn_type='WITHDRAWAL' THEN amount ELSE 0 END),0) withdrawals,
            COALESCE(SUM(CASE WHEN txn_type='DISBURSEMENT' AND module='LOAN' THEN amount ELSE 0 END),0) disbursements,
            COALESCE(SUM(CASE WHEN txn_type IN ('REPAYMENT','PRINCIPAL','INTEREST') AND module='LOAN' THEN amount ELSE 0 END),0) repayments
     FROM txn
     WHERE status='POSTED' AND value_date >= @from
     GROUP BY month`,
    { from: `${months[0]}-01` },
  );
  const byMonth = new Map(rows.map((r) => [r.month, r]));
  return months.map((m) => byMonth.get(m)
    ?? { month: m, deposits: 0, withdrawals: 0, disbursements: 0, repayments: 0 });
}

const DEPOSIT_CODES = ['2010', '2020', '2030', '2040'];
const FOSA_CODE = '2020';
const CASH_CODES = ['1010', '1015', '1016', '1017', '1020', '1030'];
/** Physical cash under the SACCO's own control — tellers' tills and the vault only (not bank or
 *  mobile-money settlement balances). */
const TILL_VAULT_CODES = ['1010', '1015', '1016', '1017'];
const SHARE_CODE = '3010';

/* ---------------------------------------------------------------------- CRM */

export interface CrmRoleCenter {
  members: { total: number; active: number; dormant: number; notPaidUp: number; joinedThisMonth: number };
  membersByMonth: { month: string; joined: number; running: number }[];
  pipeline: { stage: string; count: number }[];
  byCategory: { name: string; count: number }[];
  dormancy: { bucket: string; accounts: number; balance: Cents }[];
  churn: { exitsYtd: number; readmissionsYtd: number };
}

export async function getCrmRoleCenter(): Promise<CrmRoleCenter> {
  const months = recentMonths(12);
  const yearStart = `${today().slice(0, 4)}-01-01`;
  const [counts, joined, priorCount, pipeline, byCategory, dormancyRows, churn] = await Promise.all([
    one<{ total: number; active: number; dormant: number; not_paid_up: number; this_month: number }>(
      `SELECT COUNT(*) total,
              SUM(CASE WHEN status='ACTIVE' THEN 1 ELSE 0 END) active,
              SUM(CASE WHEN status='DORMANT' THEN 1 ELSE 0 END) dormant,
              SUM(CASE WHEN status='NOT PAID UP' OR status='NOT_PAID_UP' THEN 1 ELSE 0 END) not_paid_up,
              SUM(CASE WHEN substr(COALESCE(registration_date, join_date, created_at),1,7) = @ym THEN 1 ELSE 0 END) this_month
       FROM member`,
      { ym: today().slice(0, 7) },
    ),
    all<{ month: string; n: number }>(
      `SELECT substr(COALESCE(registration_date, join_date, created_at),1,7) AS month, COUNT(*) n
       FROM member WHERE COALESCE(registration_date, join_date, created_at) >= @from GROUP BY month`,
      { from: `${months[0]}-01` },
    ),
    one<{ n: number }>(
      'SELECT COUNT(*) n FROM member WHERE COALESCE(registration_date, join_date, created_at) < @from',
      { from: `${months[0]}-01` },
    ),
    all<{ status: string; n: number }>(
      'SELECT status, COUNT(*) n FROM member_application GROUP BY status',
    ),
    all<{ name: string; n: number }>(
      `SELECT COALESCE(c.description, 'Unclassified') AS name, COUNT(m.id) n
       FROM member m LEFT JOIN member_category c ON c.id = m.member_category_id
       GROUP BY c.description ORDER BY n DESC`,
    ),
    getDormancyAging().catch(() => []),
    one<{ exits: number; readmissions: number }>(
      `SELECT
        (SELECT COUNT(*) FROM member_exit WHERE status = 'Processed' AND COALESCE(processed_at, created_at, '') >= @ys) exits,
        (SELECT COUNT(*) FROM member_readmission_request WHERE COALESCE(created_at, '') >= @ys) readmissions`,
      { ys: yearStart },
    ).catch(() => ({ exits: 0, readmissions: 0 })),
  ]);

  const joinedByMonth = new Map(joined.map((r) => [r.month, Number(r.n)]));
  let running = Number(priorCount?.n ?? 0);
  const membersByMonth = months.map((m) => {
    const j = joinedByMonth.get(m) ?? 0;
    running += j;
    return { month: m, joined: j, running };
  });

  const dormBucket = new Map<string, { accounts: number; balance: Cents }>();
  for (const r of dormancyRows) {
    const b = dormBucket.get(r.bucket) ?? { accounts: 0, balance: 0 };
    b.accounts += 1; b.balance += r.balance;
    dormBucket.set(r.bucket, b);
  }

  return {
    members: {
      total: Number(counts?.total ?? 0),
      active: Number(counts?.active ?? 0),
      dormant: Number(counts?.dormant ?? 0),
      notPaidUp: Number(counts?.not_paid_up ?? 0),
      joinedThisMonth: Number(counts?.this_month ?? 0),
    },
    membersByMonth,
    pipeline: ['Open', 'Pending Approval', 'Approved', 'Rejected']
      .map((stage) => ({ stage, count: Number(pipeline.find((p) => p.status === stage)?.n ?? 0) })),
    byCategory: byCategory.slice(0, 6).map((r) => ({ name: r.name, count: Number(r.n) })),
    dormancy: ['0-30', '31-90', '91-180', '180+'].map((bucket) => ({
      bucket, accounts: dormBucket.get(bucket)?.accounts ?? 0, balance: dormBucket.get(bucket)?.balance ?? 0,
    })),
    churn: { exitsYtd: Number(churn?.exits ?? 0), readmissionsYtd: Number(churn?.readmissions ?? 0) },
  };
}

/* -------------------------------------------------------------------- Credit */

export interface CreditRoleCenter {
  kpi: { portfolio: Cents; activeLoans: number; parPct: number; arrears: Cents; disbursedThisMonth: Cents; pendingApprovals: number };
  byProduct: { name: string; balance: Cents; loans: number }[];
  byClassification: { classification: string; loans: number; balance: Cents }[];
  flows: { month: string; disbursements: Cents; repayments: Cents }[];
  par: Awaited<ReturnType<typeof getPortfolioAtRisk>>;
  sectors: { name: string; balance: Cents; loans: number }[];
  topArrears: { loan_no: string; member: string; arrears: Cents; classification: string }[];
}

export async function getCreditRoleCenter(): Promise<CreditRoleCenter> {
  const [agg, byProduct, byClass, flows, par, sectors, topArrears, pending] = await Promise.all([
    one<{ portfolio: Cents; active: number; arrears: Cents; disbursed_month: Cents }>(
      `SELECT COALESCE(SUM(CASE WHEN status='DISBURSED' THEN principal_balance ELSE 0 END),0) portfolio,
              SUM(CASE WHEN status='DISBURSED' THEN 1 ELSE 0 END) active,
              COALESCE(SUM(CASE WHEN status='DISBURSED' THEN arrears_amount ELSE 0 END),0) arrears,
              COALESCE(SUM(CASE WHEN substr(COALESCE(disbursed_date,''),1,7) = @ym THEN principal ELSE 0 END),0) disbursed_month
       FROM loan`,
      { ym: today().slice(0, 7) },
    ),
    all<{ name: string; balance: Cents; loans: number }>(
      `SELECT p.name, COALESCE(SUM(CASE WHEN l.status='DISBURSED' THEN l.principal_balance ELSE 0 END),0) balance,
              SUM(CASE WHEN l.status='DISBURSED' THEN 1 ELSE 0 END) loans
       FROM loan_product p LEFT JOIN loan l ON l.product_id = p.id
       GROUP BY p.id ORDER BY balance DESC`,
    ),
    all<{ classification: string; loans: number; balance: Cents }>(
      `SELECT classification, COUNT(*) loans, COALESCE(SUM(principal_balance),0) balance
       FROM loan WHERE status='DISBURSED' GROUP BY classification`,
    ),
    monthlyFlows(12),
    getPortfolioAtRisk(),
    all<{ name: string; balance: Cents; loans: number }>(
      `SELECT COALESCE(s.name, l.sector_code, 'Unclassified') AS name,
              COALESCE(SUM(l.principal_balance),0) balance, COUNT(*) loans
       FROM loan l LEFT JOIN economic_sector s ON s.code = l.sector_code
       WHERE l.status='DISBURSED'
       GROUP BY name ORDER BY balance DESC`,
    ).catch(() => []),
    all<{ loan_no: string; first_name: string; last_name: string; arrears: Cents; classification: string }>(
      `SELECT l.loan_no, m.first_name, m.last_name, l.arrears_amount AS arrears, l.classification
       FROM loan l JOIN member m ON m.id = l.member_id
       WHERE l.status='DISBURSED' AND l.arrears_amount > 0
       ORDER BY l.arrears_amount DESC LIMIT 8`,
    ),
    one<{ n: number }>("SELECT COUNT(*) n FROM loan WHERE status='PENDING APPROVAL'"),
  ]);

  const portfolio = Number(agg?.portfolio ?? 0);
  return {
    kpi: {
      portfolio,
      activeLoans: Number(agg?.active ?? 0),
      parPct: portfolio ? Number(((Number(agg?.arrears ?? 0) / portfolio) * 100).toFixed(2)) : 0,
      arrears: Number(agg?.arrears ?? 0),
      disbursedThisMonth: Number(agg?.disbursed_month ?? 0),
      pendingApprovals: Number(pending?.n ?? 0),
    },
    byProduct: byProduct.filter((r) => r.loans > 0).map((r) => ({ name: r.name, balance: r.balance, loans: Number(r.loans) })),
    byClassification: byClass.map((r) => ({ classification: r.classification, loans: Number(r.loans), balance: r.balance })),
    flows: flows.map((f) => ({ month: f.month, disbursements: f.disbursements, repayments: f.repayments })),
    par,
    sectors: sectors.slice(0, 6).map((r) => ({ name: r.name, balance: r.balance, loans: Number(r.loans) })),
    topArrears: topArrears.map((r) => ({
      loan_no: r.loan_no, member: `${r.first_name} ${r.last_name}`, arrears: r.arrears, classification: r.classification,
    })),
  };
}

/* --------------------------------------------------------------------- FOSA */

export interface FosaRoleCenter {
  kpi: { fosaDeposits: Cents; depositsToday: Cents; withdrawalsToday: Cents; chequesInClearing: number; chequesInClearingValue: Cents; standingOrders: number; tillCash: Cents };
  tills: { name: string; balance: Cents; type: string }[];
  flows: { month: string; deposits: Cents; withdrawals: Cents }[];
  chequeStatus: { status: string; count: number; value: Cents }[];
  liens: { count: number; amount: Cents };
  maturingFd: { count: number; amount: Cents };
}

export async function getFosaRoleCenter(): Promise<FosaRoleCenter> {
  const t = today();
  const [bal, todays, cheques, so, tills, flows, chequeStatus, liens, fd] = await Promise.all([
    accountBalances([FOSA_CODE, ...CASH_CODES, ...TILL_VAULT_CODES]),
    one<{ dep: Cents; wd: Cents }>(
      `SELECT COALESCE(SUM(CASE WHEN txn_type='DEPOSIT' THEN amount ELSE 0 END),0) dep,
              COALESCE(SUM(CASE WHEN txn_type='WITHDRAWAL' THEN amount ELSE 0 END),0) wd
       FROM txn WHERE status='POSTED' AND value_date = @t`,
      { t },
    ),
    one<{ n: number; v: Cents }>(
      "SELECT COUNT(*) n, COALESCE(SUM(amount),0) v FROM cheque_deposit WHERE status IN ('Pending','Cleared Pending','Open','Deposited')",
    ).catch(() => ({ n: 0, v: 0 })),
    one<{ n: number }>("SELECT COUNT(*) n FROM standing_order WHERE status IN ('Active','Running')").catch(() => ({ n: 0 })),
    all<{ name: string; balance: Cents; account_type: string }>(
      "SELECT name, balance, account_type FROM bank_account WHERE account_type IN ('TILL','TREASURY') ORDER BY account_type, name",
    ).catch(() => []),
    monthlyFlows(12),
    all<{ status: string; n: number; v: Cents }>(
      'SELECT status, COUNT(*) n, COALESCE(SUM(amount),0) v FROM cheque_deposit GROUP BY status',
    ).catch(() => []),
    one<{ n: number; a: Cents }>("SELECT COUNT(*) n, COALESCE(SUM(amount),0) a FROM member_lien WHERE status='Open'").catch(() => ({ n: 0, a: 0 })),
    one<{ n: number; a: Cents }>(
      "SELECT COUNT(*) n, COALESCE(SUM(amount),0) a FROM member_fixed_deposit WHERE status='Active' AND maturity_date <= @m",
      { m: addMonths(`${t.slice(0, 8)}01`, 1) },
    ).catch(() => ({ n: 0, a: 0 })),
  ]);

  return {
    kpi: {
      fosaDeposits: bal[FOSA_CODE] ?? 0,
      depositsToday: Number(todays?.dep ?? 0),
      withdrawalsToday: Number(todays?.wd ?? 0),
      chequesInClearing: Number(cheques?.n ?? 0),
      chequesInClearingValue: Number(cheques?.v ?? 0),
      standingOrders: Number(so?.n ?? 0),
      tillCash: TILL_VAULT_CODES.reduce((a, c) => a + (bal[c] ?? 0), 0),
    },
    tills: tills.map((r) => ({ name: r.name, balance: r.balance, type: r.account_type })),
    flows: flows.map((f) => ({ month: f.month, deposits: f.deposits, withdrawals: f.withdrawals })),
    chequeStatus: chequeStatus.map((r) => ({ status: r.status, count: Number(r.n), value: r.v })),
    liens: { count: Number(liens?.n ?? 0), amount: Number(liens?.a ?? 0) },
    maturingFd: { count: Number(fd?.n ?? 0), amount: Number(fd?.a ?? 0) },
  };
}

/* ---------------------------------------------------------- Finance Manager */

export interface FinanceManagerRoleCenter {
  kpi: { surplus: Cents; income: Cents; expense: Cents; cash: Cents; deposits: Cents; shareCapital: Cents };
  pl: { month: string; income: Cents; expense: Cents; surplus: Cents }[];
  incomeMix: { name: string; amount: Cents }[];
  expenseMix: { name: string; amount: Cents }[];
  balanceSheet: { assets: Cents; liabilities: Cents; equity: Cents; surplus: Cents; balanced: boolean };
  ratios: { label: string; value: number; threshold: number; higherIsWorse?: boolean }[];
  approvals: { type: string; count: number }[];
}

export async function getFinanceManagerRoleCenter(): Promise<FinanceManagerRoleCenter> {
  const yearStart = `${today().slice(0, 4)}-01-01`;
  const months = recentMonths(12);
  const [bal, is, bs, monthlyPl, approvals, cap, liq] = await Promise.all([
    accountBalances([...DEPOSIT_CODES, ...CASH_CODES, SHARE_CODE, '4010', '4020', '4030', '4040', '4050', '5010', '5020', '5030', '5040', '5050']),
    getIncomeStatement({ from: yearStart, to: today() }),
    getBalanceSheet({ asOf: today() }),
    all<{ month: string; income: Cents; expense: Cents }>(
      `SELECT substr(j.value_date,1,7) AS month,
              COALESCE(SUM(CASE WHEN a.type='INCOME' THEN jl.credit_lcy - jl.debit_lcy ELSE 0 END),0) income,
              COALESCE(SUM(CASE WHEN a.type='EXPENSE' THEN jl.debit_lcy - jl.credit_lcy ELSE 0 END),0) expense
       FROM journal_line jl JOIN journal j ON j.id = jl.journal_id JOIN gl_account a ON a.id = jl.gl_account_id
       WHERE a.type IN ('INCOME','EXPENSE') AND j.value_date >= @from
       GROUP BY month`,
      { from: `${months[0]}-01` },
    ),
    all<{ document_type: string; n: number }>(
      "SELECT document_type, COUNT(*) n FROM workflow_task WHERE status='PENDING' GROUP BY document_type ORDER BY n DESC",
    ).catch(() => []),
    runFinancialReport({ reportName: 'SASRA-CAPITAL-ADEQUACY', to: today() }).catch(() => null),
    runFinancialReport({ reportName: 'SASRA-LIQUIDITY', to: today() }).catch(() => null),
  ]);

  const byMonth = new Map(monthlyPl.map((r) => [r.month, r]));
  const pl = months.map((m) => {
    const r = byMonth.get(m) ?? { income: 0, expense: 0 };
    return { month: m, income: r.income, expense: r.expense, surplus: r.income - r.expense };
  });

  const capRow = (rowNo: string) => cap?.rows.find((r) => r.rowNo === rowNo)?.cells[0]?.value ?? 0;
  const liqRow = (rowNo: string) => liq?.rows.find((r) => r.rowNo === rowNo)?.cells[0]?.value ?? 0;
  const par = await getPortfolioAtRisk().catch(() => ({ parPct: 0 }));

  return {
    kpi: {
      surplus: is.surplus,
      income: is.totalIncome,
      expense: is.totalExpense,
      cash: CASH_CODES.reduce((a, c) => a + (bal[c] ?? 0), 0),
      deposits: DEPOSIT_CODES.reduce((a, c) => a + (bal[c] ?? 0), 0),
      shareCapital: bal[SHARE_CODE] ?? 0,
    },
    pl,
    incomeMix: is.income.filter((r) => r.amount !== 0).slice(0, 6).map((r) => ({ name: r.name, amount: r.amount })),
    expenseMix: is.expense.filter((r) => r.amount !== 0).slice(0, 6).map((r) => ({ name: r.name, amount: r.amount })),
    balanceSheet: {
      assets: bs.totals.assets, liabilities: bs.totals.liabilities, equity: bs.totals.equity,
      surplus: bs.surplus, balanced: bs.balanced,
    },
    ratios: [
      { label: 'Core capital / total assets', value: capRow('R1'), threshold: 10 },
      { label: 'Core capital / total deposits', value: capRow('R2'), threshold: 8 },
      { label: 'Liquidity ratio', value: liqRow('RATIO'), threshold: 15 },
      { label: 'Portfolio at risk', value: Number((par as { parPct: number }).parPct) || 0, threshold: 5, higherIsWorse: true },
    ],
    approvals: approvals.map((r) => ({ type: humaniseDoc(r.document_type), count: Number(r.n) })),
  };
}

function humaniseDoc(t: string): string {
  return String(t || '').replace(/_/g, ' ').replace(/\b\w/g, (c) => c.toUpperCase());
}

/* ----------------------------------------------------------------- Accountant */

export interface AccountantRoleCenter {
  kpi: { balanced: boolean; outOfBalanceBy: Cents; draftJournals: number; journalsThisMonth: number; agedArTotal: Cents; agedApTotal: Cents };
  journalsByMonth: { month: string; journals: number; amount: Cents }[];
  bySource: { name: string; amount: Cents; entries: number }[];
  bankRec: { name: string; glBalance: Cents; lastReconciled: IsoDate | null; status: string }[];
  tax: { vatInput: Cents; whtWithheld: Cents };
}

export async function getAccountantRoleCenter(): Promise<AccountantRoleCenter> {
  const months = recentMonths(12);
  const ym = today().slice(0, 7);
  const yearStart = `${today().slice(0, 4)}-01-01`;
  const [tb, drafts, thisMonth, jByMonth, bySource, banks, vat, wht] = await Promise.all([
    trialBalance(),
    one<{ n: number }>("SELECT COUNT(*) n FROM journal WHERE COALESCE(status,'POSTED') NOT IN ('POSTED','REVERSED')").catch(() => ({ n: 0 })),
    one<{ n: number }>('SELECT COUNT(*) n FROM journal WHERE substr(value_date,1,7) = @ym', { ym }),
    all<{ month: string; n: number; amt: Cents }>(
      `SELECT substr(value_date,1,7) AS month, COUNT(*) n, COALESCE(SUM(amount),0) amt
       FROM journal WHERE value_date >= @from GROUP BY month`,
      { from: `${months[0]}-01` },
    ),
    all<{ source_module: string; amt: Cents; n: number }>(
      `SELECT COALESCE(source_module,'GL') AS source_module, COALESCE(SUM(amount),0) amt, COUNT(*) n
       FROM journal WHERE value_date >= @ys GROUP BY source_module ORDER BY amt DESC`,
      { ys: yearStart },
    ),
    all<{ name: string; balance: Cents; last_reconciled: IsoDate | null }>(
      `SELECT ba.name, ba.balance,
              (SELECT MAX(br.statement_date) FROM bank_reconciliation br
               WHERE br.bank_account_id = ba.id AND br.status = 'POSTED') AS last_reconciled
       FROM bank_account ba WHERE ba.status='ACTIVE' ORDER BY ba.name`,
    ).catch(() => []),
    one<{ v: Cents }>(
      "SELECT COALESCE(SUM(amount),0) v FROM vat_entry WHERE tax_type='VAT' AND type='Purchase' AND posting_date >= @ys",
      { ys: yearStart },
    ).catch(() => ({ v: 0 })),
    one<{ v: Cents }>(
      "SELECT COALESCE(SUM(amount),0) v FROM vat_entry WHERE tax_type='WHT' AND posting_date >= @ys",
      { ys: yearStart },
    ).catch(() => ({ v: 0 })),
  ]);

  const totals = tb.reduce((a, r) => ({ d: a.d + r.debit_balance, c: a.c + r.credit_balance }), { d: 0, c: 0 });
  const arAp = await Promise.all([
    import('./receivablesReports.ts').then((m) => m.getAgedAccountsReceivable({ asOf: today() })).catch(() => null),
    import('./payablesReports.ts').then((m) => m.getAgedAccountsPayable({ asOf: today() })).catch(() => null),
  ]);
  const agedArTotal = sumAgedBalance(arAp[0]);
  const agedApTotal = sumAgedBalance(arAp[1]);

  const jMap = new Map(jByMonth.map((r) => [r.month, r]));
  const daysSince = (d: IsoDate | null): number =>
    d ? Math.floor((Date.now() - new Date(d).getTime()) / 86_400_000) : 9999;

  return {
    kpi: {
      balanced: totals.d === totals.c,
      outOfBalanceBy: Math.abs(totals.d - totals.c),
      draftJournals: Number(drafts?.n ?? 0),
      journalsThisMonth: Number(thisMonth?.n ?? 0),
      agedArTotal,
      agedApTotal,
    },
    journalsByMonth: months.map((m) => {
      const r = jMap.get(m);
      return { month: m, journals: Number(r?.n ?? 0), amount: Number(r?.amt ?? 0) };
    }),
    bySource: bySource.slice(0, 7).map((r) => ({ name: humaniseDoc(r.source_module), amount: r.amt, entries: Number(r.n) })),
    bankRec: banks.map((b) => ({
      name: b.name, glBalance: b.balance, lastReconciled: b.last_reconciled,
      status: daysSince(b.last_reconciled) <= 35 ? 'Current' : daysSince(b.last_reconciled) >= 9999 ? 'Never' : 'Overdue',
    })),
    tax: { vatInput: Number(vat?.v ?? 0), whtWithheld: Number(wht?.v ?? 0) },
  };
}

function sumAgedBalance(report: unknown): Cents {
  const r = report as { totals?: { balance?: number }; rows?: { balance?: number }[] } | null;
  if (r?.totals && typeof r.totals.balance === 'number') return r.totals.balance;
  if (!Array.isArray(r?.rows)) return 0;
  return r.rows.reduce((a, x) => a + (Number(x.balance) || 0), 0);
}
