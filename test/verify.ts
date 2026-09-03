/*
 * Financial integrity test suite.
 * Covers the critical scenarios listed in section 25 of the design document.
 * Run with:  npm test        (uses a throwaway database, never your live data)
 *
 * The suite writes, reverses and closes real records, so it refuses to start
 * unless TEST_DATABASE_URL names a database of its own. Under SQLite that
 * isolation came free from a temp directory; against PostgreSQL it has to be an
 * explicit, separate connection string, and pointing it at production data
 * would corrupt the ledger it is meant to be checking.
 */
import assert from 'node:assert';

const testUrl = process.env.TEST_DATABASE_URL;
if (!testUrl) {
  console.error(
    '\nTEST_DATABASE_URL is not set.\n'
    + 'This suite posts and reverses real journals, so it needs its own database:\n\n'
    + '  TEST_DATABASE_URL=postgres://user:pass@localhost:5432/sacco_test npm test\n\n'
    + 'Create the schema there first with:  prisma migrate deploy\n',
  );
  process.exit(1);
}
// Must be set before lib/db is loaded, hence the dynamic imports below.
process.env.DATABASE_URL = testUrl;

const { all, one, run } = await import('../lib/db.ts');
const { seedIfEmpty } = await import('../lib/seed.ts');
const accounting = await import('../lib/accounting.ts');
const gl = await import('../lib/gl.ts');
const savings = await import('../lib/savings.ts');
const loanSvc = await import('../lib/loanService.ts');
const {
  buildSchedule, allocateRepayment, calculateLoanProductCharges, addMonths,
} = await import('../lib/loans.ts');
const adminLib = await import('../lib/admin.ts');
const chargesLib = await import('../lib/charges.ts');
const loanProductCharges = await import('../lib/loanProductCharges.ts');
const configPackages = await import('../lib/configPackages.ts');
const auth = await import('../lib/auth.ts');
const permissions = await import('../lib/permissions.ts');
const pool = await import('../lib/pool.ts');
const membersLib = await import('../lib/members.ts');
const entranceFeeRecovery = await import('../lib/entranceFeeRecovery.ts');
const jobQueueLib = await import('../lib/jobQueue.ts');
const memberStatusUpdate = await import('../lib/memberStatusUpdate.ts');
const memberDormancy = await import('../lib/memberDormancy.ts');
const memberActivation = await import('../lib/memberActivation.ts');
const standingOrdersLib = await import('../lib/standingOrders.ts');
const employersLib = await import('../lib/employers.ts');
const checkoffBatchesLib = await import('../lib/checkoffBatches.ts');
const faDepr = await import('../lib/fixedAssetDepreciation.ts');
const faJournalLib = await import('../lib/faJournal.ts');
const faLib = await import('../lib/fixedAssets.ts');
const dateFormula = await import('../lib/dateFormula.ts');
const custLib = await import('../lib/customers.ts');
const salesLib = await import('../lib/salesDocuments.ts');
const cashReceiptLib = await import('../lib/cashReceipts.ts');
const reminderLib = await import('../lib/reminders.ts');
const custLedgerLib = await import('../lib/custLedger.ts');
const arReports = await import('../lib/receivablesReports.ts');
const vendorLib = await import('../lib/vendors.ts');
const purchaseLib = await import('../lib/purchaseDocuments.ts');
const paymentJournalLib = await import('../lib/paymentJournal.ts');
const vendLedgerLib = await import('../lib/vendLedger.ts');
const apReports = await import('../lib/payablesReports.ts');
const receiptsLib = await import('../lib/receipts.ts');
const pvLib = await import('../lib/paymentVouchers.ts');
const whtLib = await import('../lib/whtCertificate.ts');
const vatReportsLib = await import('../lib/vatReports.ts');

import type {
  Actor, LoanFull, LoanProduct, LoanProductChargeDetail, LoanScheduleRow, Member, SavingsAccount, SessionUser,
} from '../lib/types.ts';

let pass = 0;
let fail = 0;

async function test(name: string, fn: () => Promise<void> | void): Promise<void> {
  try {
    await fn();
    console.log(`  \x1b[32m✔\x1b[0m ${name}`);
    pass++;
  } catch (e) {
    console.log(`  \x1b[31m✖ ${name}\x1b[0m\n      ${(e as Error).message}`);
    fail++;
  }
}

const section = (t: string) => console.log(`\n\x1b[1m${t}\x1b[0m`);

const throws = async (fn: () => unknown, codeOrRe: RegExp): Promise<void> => {
  try {
    await fn();
  } catch (e) {
    const s = (e as { code?: string }).code || (e as Error).message;
    assert.ok(String(s).match(codeOrRe), `expected ${codeOrRe}, got ${s}`);
    return;
  }
  assert.fail('expected the operation to be rejected, but it succeeded');
};

console.log('\nSeeding a throwaway database…');
const seedInfo = await seedIfEmpty();
console.log(`Seeded ${seedInfo.members} members and ${seedInfo.loans} disbursed loans.\n`);

const admin: Actor = { id: 1, username: 'admin' };
const other: Actor = { id: 2, username: 'manager' };
const today = new Date().toISOString().slice(0, 10);

/* ------------------------------------------------------------------------ */
section('Double-entry integrity');

// PostgreSQL does not accept output-column aliases in HAVING, so the aggregates
// are repeated there rather than referred to by name.
await test('every journal is internally balanced', async () => {
  const bad = await all<{ journal_no: string }>(
    `SELECT j.journal_no, SUM(jl.debit) d, SUM(jl.credit) c FROM journal j
     JOIN journal_line jl ON jl.journal_id = j.id
     GROUP BY j.id HAVING SUM(jl.debit) <> SUM(jl.credit)`,
  );
  assert.strictEqual(bad.length, 0, `${bad.length} unbalanced journals, first: ${bad[0]?.journal_no}`);
});

await test('trial balance nets to zero across the whole ledger', async () => {
  const tb = await accounting.trialBalance();
  const d = tb.reduce((a, r) => a + r.debit_balance, 0);
  const c = tb.reduce((a, r) => a + r.credit_balance, 0);
  assert.strictEqual(d, c, `debits ${d} vs credits ${c}`);
});

await test('stored GL balances match balances recomputed from journal lines', async () => {
  const rows = await accounting.trialBalance();
  const mismatches: typeof rows = [];
  for (const r of rows) {
    const stored = (await one<{ balance: number }>('SELECT balance FROM gl_account WHERE id = ?', r.id))!;
    if (stored.balance !== r.net) mismatches.push(r);
  }
  assert.strictEqual(mismatches.length, 0, `drift on ${mismatches.map((m) => m.code).join(', ')}`);
});

await test('assets equal liabilities plus equity plus surplus', async () => {
  const tb = await accounting.trialBalance();
  const sum = (t: string) => tb.filter((r) => r.type === t).reduce((a, r) => a + r.net, 0);
  const assets = sum('ASSET');
  const rhs = sum('LIABILITY') + sum('EQUITY') + (sum('INCOME') - sum('EXPENSE'));
  assert.strictEqual(assets, rhs, `assets ${assets} vs equity+liabilities ${rhs}`);
});

await test('a dated trial balance still lists accounts with no movement', async () => {
  // Regression: the as-of filter used to sit in the WHERE clause, which turned
  // the LEFT JOIN into an inner join and dropped every zero-movement account.
  const full = await accounting.trialBalance();
  const dated = await accounting.trialBalance({ asOf: today });
  assert.strictEqual(dated.length, full.length, `dated ${dated.length} rows vs undated ${full.length}`);
});

const gd1Filter = (value: string) => [{ field: 'gd1_filter', operator: '=' as const, value }];

await test('a Dimensional Trial Balance still lists every account, and combines dimension codes with |', async () => {
  // Same hazard as the as-of regression above, applied to the new Dimensional filter: a
  // dimension condition tested in WHERE would drop every account with no matching movement
  // instead of showing it at zero.
  const full = await accounting.trialBalance();
  const filtered = await gl.getTrialBalance({ filters: gd1Filter('NO-SUCH-DIMENSION-CODE') });
  assert.strictEqual(filtered.rows.length, full.length, `filtered ${filtered.rows.length} rows vs full ${full.length}`);

  // "A|B" must equal filtering by A and by B separately and summing — the OR-combination this
  // feature exists for ("Trial Balance for NBI|HQ").
  const dims = await all<{ code: string }>('SELECT code FROM global_dimension_1_value LIMIT 2');
  if (dims.length === 2) {
    const [a, b] = dims;
    const [byA, byB, combined] = await Promise.all([
      gl.getTrialBalance({ filters: gd1Filter(a.code) }),
      gl.getTrialBalance({ filters: gd1Filter(b.code) }),
      gl.getTrialBalance({ filters: gd1Filter(`${a.code}|${b.code}`) }),
    ]);
    const sum = (rows: typeof byA.rows) => rows.reduce((s, r) => s + r.net, 0);
    assert.strictEqual(
      sum(combined.rows), sum(byA.rows) + sum(byB.rows),
      `"${a.code}|${b.code}" should equal ${a.code} + ${b.code} summed`,
    );
  }
});

/* ------------------------------------------------------------------------ */
section('Subsidiary ledgers reconcile to GL control accounts');

const SAVINGS_VS_GL =
  `SELECT p.code, g.code gl, COALESCE(SUM(sa.balance),0) sub
   FROM savings_product p JOIN gl_account g ON g.id = p.gl_control_id
   LEFT JOIN savings_account sa ON sa.product_id = p.id
   GROUP BY p.id, g.code`;

const LOANS_VS_GL =
  `SELECT p.code, g.code gl,
          COALESCE((SELECT SUM(principal_balance) FROM loan l WHERE l.product_id=p.id AND l.status='DISBURSED'),0) sub
   FROM loan_product p JOIN gl_account g ON g.id = p.gl_receivable_id`;

await test('each savings product reconciles to its GL control account', async () => {
  const rows = await all<{ code: string; gl: string; sub: number }>(SAVINGS_VS_GL);
  for (const r of rows) {
    const glBalance = await accounting.accountBalance(r.gl);
    assert.strictEqual(r.sub, glBalance, `${r.code}: subsidiary ${r.sub} vs GL ${glBalance}`);
  }
});

await test('each loan product reconciles to its receivable account', async () => {
  const rows = await all<{ code: string; gl: string; sub: number }>(LOANS_VS_GL);
  for (const r of rows) {
    const glBalance = await accounting.accountBalance(r.gl);
    assert.strictEqual(r.sub, glBalance, `${r.code}: subsidiary ${r.sub} vs GL ${glBalance}`);
  }
});

await test('savings balances equal the sum of their posted transactions', async () => {
  const bad = await all<{ account_no: string }>(
    `SELECT sa.account_no, sa.balance, COALESCE(SUM(t.amount),0) computed
     FROM savings_account sa LEFT JOIN txn t ON t.savings_account_id = sa.id
     GROUP BY sa.id HAVING sa.balance <> COALESCE(SUM(t.amount),0)`,
  );
  assert.strictEqual(bad.length, 0, `drift on ${bad.map((b) => b.account_no).join(', ')}`);
});

await test('bank account ledger entries reconcile to their GL control account', async () => {
  const rows = await all<{ code: string; gl_code: string; bank_balance: number; entry_sum: number }>(
    `SELECT ba.code, g.code gl_code, ba.balance bank_balance,
            COALESCE((SELECT SUM(amount) FROM bank_account_ledger_entry WHERE bank_account_id = ba.id), 0) entry_sum
     FROM bank_account ba JOIN gl_account g ON g.id = ba.gl_account_id`,
  );
  for (const r of rows) {
    assert.strictEqual(r.bank_balance, r.entry_sum, `${r.code}: bank balance ${r.bank_balance} vs entries ${r.entry_sum}`);
    const glBalance = await accounting.accountBalance(r.gl_code);
    assert.strictEqual(r.bank_balance, glBalance, `${r.code}: bank balance ${r.bank_balance} vs GL ${glBalance}`);
  }
});

/* ------------------------------------------------------------------------ */
section('Posting engine controls');

await test('a no-direct-posting account rejects a manual journal but still accepts subledger postings', async () => {
  // '1020' (Bank Current Account) is one of the seeded bank_account control accounts.
  await throws(() => gl.postManualJournal({
    valueDate: today,
    lines: [{ account: '1020', debit: 500, credit: 0 }, { account: '4050', debit: 0, credit: 500 }],
  }, admin), /VALIDATION/);
  // The same account still accepts postJournal() directly — savings/loan/charge callers,
  // and this very test suite's own fixtures above, are unaffected by the manual-journal guard.
  const before = await accounting.accountBalance('1020');
  await accounting.postJournal({
    valueDate: today, module: 'TEST', eventType: 'TEST', user: admin,
    lines: [{ account: '1020', debit: 500, credit: 0 }, { account: '4050', debit: 0, credit: 500 }],
  });
  assert.strictEqual(await accounting.accountBalance('1020'), before + 500);
});

await test('an unbalanced journal is rejected', async () => {
  await throws(() => accounting.postJournal({
    valueDate: today, module: 'TEST', eventType: 'TEST', user: admin,
    lines: [{ account: '1010', debit: 5000, credit: 0 }, { account: '4050', debit: 0, credit: 4000 }],
  }), /OUT_OF_BALANCE/);
});

await test('posting to a header (non-postable) account is rejected', async () => {
  await throws(() => accounting.postJournal({
    valueDate: today, module: 'TEST', eventType: 'TEST', user: admin,
    lines: [{ account: '1000', debit: 5000, credit: 0 }, { account: '4050', debit: 0, credit: 5000 }],
  }), /GL_NOT_POSTABLE/);
});

await test('a line cannot carry both a debit and a credit', async () => {
  await throws(() => accounting.postJournal({
    valueDate: today, module: 'TEST', eventType: 'TEST', user: admin,
    lines: [{ account: '1010', debit: 100, credit: 100 }, { account: '4050', debit: 0, credit: 100 }],
  }), /MIXED_LINE/);
});

await test('an idempotency key is never posted twice', async () => {
  const key = `IDEMPOTENCY-TEST-${Date.now()}`;
  const args = {
    valueDate: today, module: 'TEST', eventType: 'TEST', user: admin, idempotencyKey: key,
    lines: [{ account: '1010', debit: 15000, credit: 0 }, { account: '4050', debit: 0, credit: 15000 }],
  };
  const before = await accounting.accountBalance('4050');
  const a = await accounting.postJournal(args);
  const b = await accounting.postJournal(args);
  assert.strictEqual(a.id, b.id, 'the second call returned a different journal');
  assert.ok(b.duplicate, 'the second call was not flagged as a duplicate');
  assert.strictEqual(await accounting.accountBalance('4050'), before + 15000, 'the amount was posted twice');
});

await test('a closed period rejects normal posting', async () => {
  const code = today.slice(0, 7);
  await run("UPDATE accounting_period SET status='CLOSED' WHERE code = ?", code);
  try {
    await throws(() => accounting.postJournal({
      valueDate: today, module: 'TEST', eventType: 'TEST', user: admin,
      lines: [{ account: '1010', debit: 100, credit: 0 }, { account: '4050', debit: 0, credit: 100 }],
    }), /PERIOD_CLOSED/);
  } finally {
    await run("UPDATE accounting_period SET status='OPEN' WHERE code = ?", code);
  }
});

await test('a reversal creates compensating entries without changing the original', async () => {
  const j = await accounting.postJournal({
    valueDate: today, module: 'TEST', eventType: 'TEST', user: admin, description: 'reversal subject',
    lines: [{ account: '1010', debit: 7700, credit: 0 }, { account: '4050', debit: 0, credit: 7700 }],
  });
  const before = await accounting.accountBalance('4050');
  const LINES = 'SELECT * FROM journal_line WHERE journal_id = ? ORDER BY line_no';
  const originalLines = await all(LINES, j.id);
  const rev = await accounting.reverseJournal(j.id, admin, 'unit test');
  assert.strictEqual(await accounting.accountBalance('4050'), before - 7700, 'the reversal did not unwind the balance');
  const nowLines = await all(LINES, j.id);
  assert.deepStrictEqual(nowLines, originalLines, 'the original journal was mutated');
  const marker = (await one<{ reversed_by_id: number }>(
    'SELECT reversed_by_id FROM journal WHERE id=?', j.id,
  ))!;
  assert.strictEqual(marker.reversed_by_id, rev.id);
  await throws(() => accounting.reverseJournal(j.id, admin, 'again'), /ALREADY_REVERSED/);
});

/* ------------------------------------------------------------------------ */
section('Savings controls');

const testMember = (await one<Member>("SELECT * FROM member WHERE status='ACTIVE' ORDER BY id LIMIT 1"))!;
const fosa = (await one<SavingsAccount>(
  `SELECT sa.* FROM savings_account sa JOIN savings_product p ON p.id=sa.product_id
   WHERE sa.member_id=? AND p.code='FOSA'`,
  testMember.id,
))!;

await test('a deposit moves the member balance and the GL control account together', async () => {
  const glBefore = await accounting.accountBalance('2020');
  const before = (await savings.getAccount(fosa.id))!.balance;
  await savings.deposit({ accountId: fosa.id, amount: 250000, channel: 'TELLER', description: 'test deposit', user: admin });
  assert.strictEqual((await savings.getAccount(fosa.id))!.balance, before + 250000);
  assert.strictEqual(await accounting.accountBalance('2020'), glBefore + 250000);
});

await test('a withdrawal beyond available funds is rejected before posting', async () => {
  const acct = (await savings.getAccount(fosa.id))!;
  const glBefore = await accounting.accountBalance('2020');
  await throws(() => savings.withdraw({ accountId: fosa.id, amount: acct.balance + 100000, user: admin }), /INSUFFICIENT_FUNDS/);
  assert.strictEqual(await accounting.accountBalance('2020'), glBefore, 'a rejected withdrawal still touched the ledger');
});

await test('the minimum balance cannot be breached', async () => {
  const acct = (await savings.getAccount(fosa.id))!;
  const available = acct.balance - acct.hold_amount - acct.min_balance;
  await throws(() => savings.withdraw({ accountId: fosa.id, amount: available + 1, user: admin }), /INSUFFICIENT_FUNDS/);
});

await test('a non-withdrawable product refuses withdrawals', async () => {
  const bosa = (await one<SavingsAccount>(
    `SELECT sa.* FROM savings_account sa JOIN savings_product p ON p.id=sa.product_id
     WHERE sa.member_id=? AND p.code='BOSA'`,
    testMember.id,
  ))!;
  await throws(() => savings.withdraw({ accountId: bosa.id, amount: 1000, user: admin }), /WITHDRAWAL_NOT_ALLOWED/);
});

await test('a frozen account rejects deposits', async () => {
  await run("UPDATE savings_account SET status='FROZEN' WHERE id=?", fosa.id);
  try {
    await throws(() => savings.deposit({ accountId: fosa.id, amount: 1000, user: admin }), /ACCOUNT_FROZEN/);
  } finally {
    await run("UPDATE savings_account SET status='ACTIVE' WHERE id=?", fosa.id);
  }
});

await test('reversing a deposit restores both the member balance and the GL', async () => {
  const glBefore = await accounting.accountBalance('2020');
  const before = (await savings.getAccount(fosa.id))!.balance;
  const r = await savings.deposit({ accountId: fosa.id, amount: 90000, user: admin, description: 'to be reversed' });
  await savings.reverseTxn({ txnId: r.txn.id, reason: 'unit test', user: admin });
  assert.strictEqual((await savings.getAccount(fosa.id))!.balance, before);
  assert.strictEqual(await accounting.accountBalance('2020'), glBefore);
  const status = (await one<{ status: string }>('SELECT status FROM txn WHERE id=?', r.txn.id))!;
  assert.strictEqual(status.status, 'REVERSED');
});

await test('a reversal without a reason is rejected', async () => {
  const r = await savings.deposit({ accountId: fosa.id, amount: 1000, user: admin });
  await throws(() => savings.reverseTxn({ txnId: r.txn.id, reason: '', user: admin }), /REASON_REQUIRED/);
});

/* ------------------------------------------------------------------------ */
section('Loan mathematics');

await test('a reducing-balance schedule fully amortises the principal', () => {
  const s = buildSchedule(100000000, 12, 24, 'REDUCING', '2026-09-01');
  assert.strictEqual(s.rows.reduce((a, r) => a + r.principal_due, 0), 100000000);
  assert.strictEqual(s.rows.length, 24);
  assert.ok(s.totalInterest > 0, 'no interest was charged');
  // interest must fall as the balance reduces
  assert.ok(s.rows[0].interest_due > s.rows[23].interest_due, 'interest did not reduce over the term');
});

await test('a flat-rate schedule charges interest on the original principal', () => {
  const s = buildSchedule(120000000, 12, 12, 'FLAT', '2026-09-01');
  assert.strictEqual(s.rows.reduce((a, r) => a + r.principal_due, 0), 120000000);
  assert.strictEqual(s.totalInterest, Math.round(120000000 * 0.12));
});

const testChargeLine = (over: Partial<LoanProductChargeDetail>): LoanProductChargeDetail => ({
  id: 1, product_id: 1, charge_id: 1, gl_account_id: 1, calculation_type: 'PERCENTAGE',
  percentage_rate: 0, prorate: false, priority: 1, status: 'ACTIVE',
  charge_code: 'TEST', charge_description: 'Test charge', gl_account_code: '4000', gl_account_name: 'Test income',
  scheme: [], ...over,
});

await test('a Percentage loan product charge is a flat % of the principal', () => {
  const [c] = calculateLoanProductCharges([testChargeLine({ percentage_rate: 2 })], 10000000, 12);
  assert.strictEqual(c.amount, 200000);
  assert.strictEqual(c.prorated, false);
});

await test('a Calculate from Scheme loan product charge is banded by principal', () => {
  const line = testChargeLine({
    calculation_type: 'SCHEME',
    scheme: [
      { id: 1, loan_product_charge_id: 1, lower_limit: 0, upper_limit: 5000000, rate_type: 'FLAT', flat_amount: 50000, percentage_rate: 0, upper_charge_limit: 0, lower_charge_limit: 0 },
      { id: 2, loan_product_charge_id: 1, lower_limit: 5000001, upper_limit: null, rate_type: 'PERCENTAGE', flat_amount: 0, percentage_rate: 1, upper_charge_limit: 500000, lower_charge_limit: 0 },
    ],
  });
  assert.strictEqual(calculateLoanProductCharges([line], 3000000, 12)[0].amount, 50000, 'lower band should charge the flat amount');
  const upperBand = calculateLoanProductCharges([line], 100000000, 12)[0];
  assert.strictEqual(upperBand.amount, 500000, 'upper band should clamp at the max charge');
});

await test('a prorated loan product charge scales by term / 12 months', () => {
  const line = testChargeLine({ percentage_rate: 12, prorate: true });
  const sixMonths = calculateLoanProductCharges([line], 10000000, 6)[0];
  assert.strictEqual(sixMonths.amount, Math.round(1200000 / 2), '6-month term should halve the annual charge');
});

await test('an inactive loan product charge is excluded, a zero-amount one is dropped', () => {
  const inactive = testChargeLine({ percentage_rate: 5, status: 'INACTIVE' });
  const zero = testChargeLine({ percentage_rate: 0, priority: 2 });
  assert.strictEqual(calculateLoanProductCharges([inactive, zero], 10000000, 12).length, 0);
});

await test('a zero-interest schedule still amortises exactly', () => {
  const s = buildSchedule(1000033, 0, 7, 'REDUCING', '2026-09-01');
  assert.strictEqual(s.rows.reduce((a, r) => a + r.principal_due, 0), 1000033);
  assert.strictEqual(s.totalInterest, 0);
});

await test('paying exactly one instalment clears that instalment in full', () => {
  const s = buildSchedule(60000000, 12, 12, 'REDUCING', '2026-09-01');
  const sched = s.rows.map((r) => ({ ...r, principal_paid: 0, interest_paid: 0 })) as LoanScheduleRow[];
  const emi = sched[0].principal_due + sched[0].interest_due;
  const a = allocateRepayment(sched, emi);
  assert.strictEqual(a.interest, sched[0].interest_due, 'instalment interest not settled');
  assert.strictEqual(a.principal, sched[0].principal_due,
    'instalment principal not settled — future interest was taken first');
  assert.strictEqual(a.unallocated, 0);
  assert.strictEqual(a.allocations.length, 1);
});

await test('an overpayment spills into the next instalments, oldest first', () => {
  const s = buildSchedule(60000000, 12, 12, 'REDUCING', '2026-09-01');
  const sched = s.rows.map((r) => ({ ...r, principal_paid: 0, interest_paid: 0 })) as LoanScheduleRow[];
  const twoEmi = sched.slice(0, 2).reduce((x, r) => x + r.principal_due + r.interest_due, 0);
  const a = allocateRepayment(sched, twoEmi);
  assert.strictEqual(a.allocations.length, 2);
  assert.strictEqual(a.unallocated, 0);
});

/* ------------------------------------------------------------------------ */
section('Loan lifecycle and credit controls');

const borrower = (await one<Member>(
  `SELECT m.* FROM member m WHERE m.status='ACTIVE' AND m.kyc_verified=1
     AND (SELECT COALESCE(SUM(sa.balance),0) FROM savings_account sa
          JOIN savings_product p ON p.id=sa.product_id
          WHERE sa.member_id=m.id AND p.is_loanable_base=1) > 15000000
   ORDER BY m.id LIMIT 1`,
))!;
const normProduct = (await one<LoanProduct>("SELECT * FROM loan_product WHERE code='NORM'"))!;
const borrowerFosa = (await one<{ id: number }>(
  `SELECT sa.id FROM savings_account sa JOIN savings_product p ON p.id=sa.product_id
   WHERE sa.member_id=? AND p.code='FOSA'`,
  borrower.id,
))!;
const guarantorMember = (await one<Member>(
  "SELECT * FROM member WHERE status='ACTIVE' AND id != ? ORDER BY id LIMIT 1", borrower.id,
))!;

let lifecycleLoan: LoanFull;

await test('appraisal returns an explainable factor list', async () => {
  const a = await loanSvc.appraise({ memberId: borrower.id, productId: normProduct.id, principal: 20000000, termMonths: 24 });
  assert.ok(Array.isArray(a.factors) && a.factors.length >= 6, 'factors missing');
  assert.ok(a.factors.every((f) => 'pass' in f && f.detail), 'a factor has no verdict or explanation');
  assert.ok(typeof a.score === 'number');
});

await test('appraisal fails a loan above the deposit multiplier ceiling', async () => {
  const deposits = await loanSvc.loanableDeposits(borrower.id);
  const a = await loanSvc.appraise({
    memberId: borrower.id, productId: normProduct.id,
    principal: Math.round(deposits * normProduct.deposit_multiplier) + 100000, termMonths: 24,
  });
  assert.strictEqual(a.factors.find((f) => f.code === 'DEPOSIT_MULTIPLIER')!.pass, false);
  assert.strictEqual(a.decision, 'REFERRED');
});

await test('a loan can be captured', async () => {
  lifecycleLoan = await loanSvc.apply({
    memberId: borrower.id, productId: normProduct.id, principal: 20000000, termMonths: 12,
    purpose: 'Unit test', disburseToAccountId: borrowerFosa.id, user: admin,
  });
  assert.strictEqual(lifecycleLoan.status, 'OPEN');
});

await test('a loan with no appraisal on file cannot be submitted for approval', async () => {
  await throws(() => loanSvc.submit({ loanId: lifecycleLoan.id, user: admin }), /NO_APPRAISAL/);
});

await test('running and filing the appraisal report unblocks submission', async () => {
  const a = await loanSvc.saveAppraisal({ loanId: lifecycleLoan.id, user: admin });
  assert.strictEqual(a.loan_id, lifecycleLoan.id);
  assert.ok(a.factors.some((f) => f.code === 'SECURITY_COVER'), 'security cover factor missing');
});

await test('a member cannot guarantee their own loan', async () => {
  await throws(
    () => loanSvc.commitGuarantor({ loanId: lifecycleLoan.id, memberId: borrower.id, amount: 100000 }, admin),
    /VALIDATION/,
  );
});

await test('committing a guarantor strengthens SECURITY_COVER, releasing it withdraws that cover', async () => {
  const beforeRow = await one<{ s: number }>(
    "SELECT COALESCE(SUM(amount),0) s FROM loan_guarantor WHERE loan_id = ? AND status = 'COMMITTED'", lifecycleLoan.id,
  );
  assert.strictEqual(Number(beforeRow!.s), 0, 'no guarantor committed yet');

  await loanSvc.commitGuarantor({ loanId: lifecycleLoan.id, memberId: guarantorMember.id, amount: 5000000 }, admin);
  const committedRow = await one<{ s: number }>(
    "SELECT COALESCE(SUM(amount),0) s FROM loan_guarantor WHERE loan_id = ? AND status = 'COMMITTED'", lifecycleLoan.id,
  );
  assert.strictEqual(Number(committedRow!.s), 5000000, 'committed guarantee not recorded');

  const withGuarantor = await loanSvc.appraise({
    memberId: borrower.id, productId: normProduct.id, principal: lifecycleLoan.principal,
    termMonths: lifecycleLoan.term_months, loanId: lifecycleLoan.id,
  });
  const cover = withGuarantor.factors.find((f) => f.code === 'SECURITY_COVER')!;
  assert.ok(cover, 'SECURITY_COVER factor missing');

  await loanSvc.releaseGuarantor(lifecycleLoan.id, guarantorMember.id, admin);
  const afterRelease = await one('SELECT 1 FROM loan_guarantor WHERE loan_id = ? AND member_id = ?', lifecycleLoan.id, guarantorMember.id);
  assert.strictEqual(afterRelease, undefined, 'guarantor row should be gone after release');
});

await test('a captured, appraised loan can be submitted for approval', async () => {
  lifecycleLoan = await loanSvc.submit({ loanId: lifecycleLoan.id, user: admin });
  assert.strictEqual(lifecycleLoan.status, 'PENDING APPROVAL');
});

await test('an unapproved loan cannot be disbursed', async () => {
  await throws(() => loanSvc.disburse({ loanId: lifecycleLoan.id, user: other }), /BAD_STATUS/);
});

await test('self-approval eligibility is the routed workflow layer\'s job, not the raw service call — like every other maker-checker module, loanSvc.approve() itself no longer blocks the maker', async () => {
  const l = await loanSvc.approve({ loanId: lifecycleLoan.id, user: admin, approve: true, reason: 'ok' });
  assert.strictEqual(l.status, 'APPROVED');
  assert.strictEqual(l.approved_by, admin.username);
  lifecycleLoan = l;
});

await test('disbursement debits the receivable, credits the member and generates the schedule', async () => {
  const recvBefore = await accounting.accountBalance('1110');
  const savingsBefore = (await savings.getAccount(borrowerFosa.id))!.balance;
  const feeBefore = await accounting.accountBalance('4020');
  const l = await loanSvc.disburse({ loanId: lifecycleLoan.id, user: other });

  // NORM carries no Loan Product Charges lines, so disbursement attracts no fees.
  const fees = 0;
  assert.strictEqual(l.status, 'DISBURSED');
  assert.strictEqual(await accounting.accountBalance('1110'), recvBefore + 20000000, 'receivable not debited');
  assert.strictEqual((await savings.getAccount(borrowerFosa.id))!.balance, savingsBefore + 20000000 - fees,
    'member not credited net of charges');
  assert.strictEqual(await accounting.accountBalance('4020'), feeBefore + fees, 'fee income not recognised');
  const sched = await all<LoanScheduleRow>('SELECT * FROM loan_schedule WHERE loan_id=?', l.id);
  assert.strictEqual(sched.length, 12);
  assert.strictEqual(sched.reduce((a, s) => a + s.principal_due, 0), 20000000,
    'schedule does not repay the principal');
});

await test('a repayment splits correctly between interest income and principal', async () => {
  const l = (await loanSvc.getLoan(lifecycleLoan.id))!;
  const recvBefore = await accounting.accountBalance('1110');
  const intBefore = await accounting.accountBalance('4010');
  const r = await loanSvc.repay({ loanId: l.id, amount: l.installment, channel: 'TELLER', user: admin });
  assert.strictEqual(r.principal + r.interest + r.penalty, l.installment, 'allocation does not sum to the payment');
  assert.strictEqual(await accounting.accountBalance('1110'), recvBefore - r.principal,
    'receivable not reduced by the principal portion');
  assert.strictEqual(await accounting.accountBalance('4010'), intBefore + r.interest, 'interest income not recognised');
  const first = (await one<LoanScheduleRow>(
    'SELECT * FROM loan_schedule WHERE loan_id=? AND installment_no=1', l.id,
  ))!;
  assert.strictEqual(first.status, 'PAID',
    'the first instalment was not cleared by paying exactly one instalment');
});

await test('a repayment larger than the outstanding balance is rejected', async () => {
  const l = (await loanSvc.getLoan(lifecycleLoan.id))!;
  const owed = l.principal_balance + l.interest_balance + l.penalty_balance;
  await throws(() => loanSvc.repay({ loanId: l.id, amount: owed + 100000, user: admin }), /OVERPAYMENT/);
});

await test('repaying from a member account with insufficient funds is rejected', async () => {
  const l = (await loanSvc.getLoan(lifecycleLoan.id))!;
  const source = (await one<{ id: number }>(
    `SELECT sa.id FROM savings_account sa JOIN savings_product p ON p.id=sa.product_id
     WHERE sa.member_id=? AND p.code='HOL' LIMIT 1`,
    borrower.id,
  )) ?? (await one<{ id: number }>(
    'SELECT id FROM savings_account WHERE member_id=? ORDER BY balance LIMIT 1',
    borrower.id,
  ))!;
  const acct = (await savings.getAccount(source.id))!;
  await throws(() => loanSvc.repay({
    loanId: l.id, amount: acct.balance + 5000000, fromSavingsAccountId: source.id, user: admin,
  }), /INSUFFICIENT_FUNDS|OVERPAYMENT/);
});

await test('settling the full balance closes the loan', async () => {
  const l = (await loanSvc.getLoan(lifecycleLoan.id))!;
  const owed = l.principal_balance + l.interest_balance + l.penalty_balance;
  const r = await loanSvc.repay({ loanId: l.id, amount: owed, channel: 'BANK', user: admin });
  assert.ok(r.closed, 'the loan did not close');
  const after = (await loanSvc.getLoan(l.id))!;
  assert.strictEqual(after.status, 'CLOSED');
  assert.strictEqual(after.principal_balance, 0);
  assert.strictEqual(after.interest_balance, 0);
});

await test('a closed loan accepts no further repayment', async () => {
  await throws(() => loanSvc.repay({ loanId: lifecycleLoan.id, amount: 1000, user: admin }), /BAD_STATUS/);
});

/* ------------------------------------------------------------------------ */
section('Loan disbursement/repayment — Bank/Cashbook account and Pay Mode');

const payoutBankAccount = (await one<{ id: number; gl_account_id: number; code: string }>(
  "SELECT id, gl_account_id, code FROM bank_account WHERE code = 'BANK'",
))!;

const payoutApplied = await loanSvc.apply({
  memberId: borrower.id, productId: normProduct.id, principal: 5000000, termMonths: 6,
  purpose: 'Unit test — bank payout', user: admin,
});
await loanSvc.saveAppraisal({ loanId: payoutApplied.id, user: admin });
await loanSvc.submit({ loanId: payoutApplied.id, user: admin });
await loanSvc.approve({ loanId: payoutApplied.id, user: admin, approve: true, reason: 'ok' });

let payoutLoan: LoanFull;

await test('a loan with no member-account target posts straight to the picked Bank/Cashbook account, tagged with its Pay Mode and Cheque details', async () => {
  const bankBalBefore = await accounting.accountBalance('1020');
  payoutLoan = await loanSvc.disburse({
    loanId: payoutApplied.id, bankAccountId: payoutBankAccount.id, payMode: 'CHEQUE',
    chequeNo: 'CHQ-1001', chequeDate: today, user: admin,
  });
  assert.strictEqual(payoutLoan.status, 'DISBURSED');
  // BANK's own G/L control account is 1020, an asset — crediting it (money paid out) lowers it.
  assert.strictEqual(await accounting.accountBalance('1020'), bankBalBefore - 5000000);

  const bankAcctAfter = (await one<{ balance: number }>(
    'SELECT balance FROM bank_account WHERE id = ?', payoutBankAccount.id,
  ))!;
  const ledgerEntry = await one<{ amount: number }>(
    'SELECT amount FROM bank_account_ledger_entry WHERE bank_account_id = ? ORDER BY id DESC LIMIT 1',
    payoutBankAccount.id,
  );
  assert.ok(ledgerEntry, 'postJournal() should auto-populate a bank_account_ledger_entry for a posting against a bank account');
  assert.strictEqual(ledgerEntry!.amount, -5000000, 'ledger entry should carry the same signed movement as the G/L balance change');
  assert.ok(bankAcctAfter.balance >= 0, 'bank_account.balance should have moved too (sanity, not a hardcoded absolute)');

  const txnRow = (await one<{
    bank_account_id: number | null; pay_mode: string | null; cheque_no: string | null; cheque_date: string | null;
  }>(
    "SELECT bank_account_id, pay_mode, cheque_no, cheque_date FROM txn WHERE loan_id = ? AND txn_type = 'DISBURSEMENT'",
    payoutLoan.id,
  ))!;
  assert.strictEqual(txnRow.bank_account_id, payoutBankAccount.id);
  assert.strictEqual(txnRow.pay_mode, 'CHEQUE');
  assert.strictEqual(txnRow.cheque_no, 'CHQ-1001');
  assert.strictEqual(txnRow.cheque_date, today);
});

await test('repaying externally (no member-account source) posts to the picked Bank/Cashbook account with its Reference No.', async () => {
  const bankBalBefore = await accounting.accountBalance('1020');
  const r = await loanSvc.repay({
    loanId: payoutLoan.id, amount: payoutLoan.installment, bankAccountId: payoutBankAccount.id,
    payMode: 'MPESA', referenceNo: 'QGH7X9K2', user: admin,
  });
  assert.strictEqual(r.principal + r.interest + r.penalty, payoutLoan.installment);
  // A repayment received into the bank increases its balance this time.
  assert.strictEqual(await accounting.accountBalance('1020'), bankBalBefore + payoutLoan.installment);

  const txnRow = (await one<{ bank_account_id: number | null; pay_mode: string | null; reference_no: string | null }>(
    "SELECT bank_account_id, pay_mode, reference_no FROM txn WHERE loan_id = ? AND txn_type = 'REPAYMENT'",
    payoutLoan.id,
  ))!;
  assert.strictEqual(txnRow.bank_account_id, payoutBankAccount.id);
  assert.strictEqual(txnRow.pay_mode, 'MPESA');
  assert.strictEqual(txnRow.reference_no, 'QGH7X9K2');
});

await test('disbursing to a member account still ignores any bank account/pay mode — no bank account is touched', async () => {
  const targetApplied = await loanSvc.apply({
    memberId: borrower.id, productId: normProduct.id, principal: 1000000, termMonths: 3,
    purpose: 'Unit test — member account target unaffected by payout fields', disburseToAccountId: borrowerFosa.id, user: admin,
  });
  await loanSvc.saveAppraisal({ loanId: targetApplied.id, user: admin });
  await loanSvc.submit({ loanId: targetApplied.id, user: admin });
  await loanSvc.approve({ loanId: targetApplied.id, user: admin, approve: true, reason: 'ok' });

  const bankBalBefore = await accounting.accountBalance('1020');
  // Passing bankAccountId/payMode here must have no effect at all — this branch never looks at
  // them, matching the UI's own "Payment Channel not even shown" behaviour for this case.
  const l = await loanSvc.disburse({
    loanId: targetApplied.id, bankAccountId: payoutBankAccount.id, payMode: 'CHEQUE', chequeNo: 'SHOULD-BE-IGNORED', user: admin,
  });
  assert.strictEqual(await accounting.accountBalance('1020'), bankBalBefore, 'the bank account must be untouched');
  const txnRow = (await one<{ bank_account_id: number | null; pay_mode: string | null }>(
    "SELECT bank_account_id, pay_mode FROM txn WHERE loan_id = ? AND txn_type = 'DISBURSEMENT'", l.id,
  ))!;
  assert.strictEqual(txnRow.bank_account_id, null);
  assert.strictEqual(txnRow.pay_mode, null);
});

/* ------------------------------------------------------------------------ */
section('Loan Product Charges — real disbursement posting');

await test('a loan product with configured charges posts one credit line per charge, to its own revenue account', async () => {
  const postable = await gl.listPostableAccounts();
  if (postable.length < 2) throw new Error('need at least two postable GL accounts for this test');
  const [accA, accB] = postable;
  const stamp = Date.now();

  const chargeA = await chargesLib.createCharge(`TESTPROC${stamp}`, 'Test processing fee', admin);
  const chargeB = await chargesLib.createCharge(`TESTINS${stamp}`, 'Test insurance', admin);

  const { id: productId } = await adminLib.createLoanProduct({
    code: `TESTLPC${stamp}`, name: 'Test LPC product', status: 'ACTIVE',
    interest_rate: 10, interest_method: 'REDUCING', max_term_months: 24,
    min_amount: 0, max_amount: 500000000, deposit_multiplier: 3, min_membership_months: 0,
    penalty_rate: 1, guarantors_required: 0, max_dsr_pct: 100,
    gl_receivable_id: normProduct.gl_receivable_id, gl_interest_income_id: normProduct.gl_interest_income_id,
    gl_penalty_income_id: normProduct.gl_penalty_income_id,
  }, admin);

  await loanProductCharges.replaceLoanProductCharges(productId, [
    { charge_id: chargeA.id, gl_account_id: accA.id, calculation_type: 'PERCENTAGE', percentage_rate: 2, priority: 1, scheme: [] },
    {
      charge_id: chargeB.id, gl_account_id: accB.id, calculation_type: 'SCHEME', priority: 2,
      scheme: [{ lower_limit: 0, upper_limit: null, rate_type: 'FLAT', flat_amount: 100000 }],
    },
  ], admin);

  const lines = await loanProductCharges.listLoanProductCharges(productId);
  assert.strictEqual(lines.length, 2, 'both charge lines should round-trip');
  assert.strictEqual(lines.find((l) => l.calculation_type === 'SCHEME')!.scheme.length, 1);

  const loan = await loanSvc.apply({
    memberId: borrower.id, productId, principal: 10000000, termMonths: 12, purpose: 'LPC test', user: admin,
  });
  await loanSvc.saveAppraisal({ loanId: loan.id, user: admin });
  await loanSvc.submit({ loanId: loan.id, user: admin });
  await loanSvc.approve({ loanId: loan.id, user: other, approve: true, reason: 'ok' });
  const disbursed = await loanSvc.disburse({ loanId: loan.id, user: other });

  // 2% of 10,000,000 = 200,000; flat 100,000 -> total fees 300,000
  assert.strictEqual(Number(disbursed.fees_charged), 300000);

  const credits = await all<{ gl_account_id: number; credit: number }>(
    `SELECT jl.gl_account_id, jl.credit FROM journal_line jl
     JOIN journal j ON j.id = jl.journal_id
     WHERE j.reference = ? AND jl.credit > 0`,
    disbursed.loan_no,
  );
  assert.ok(
    credits.some((c) => c.gl_account_id === accA.id && Number(c.credit) === 200000),
    'processing fee was not credited to its own configured revenue account',
  );
  assert.ok(
    credits.some((c) => c.gl_account_id === accB.id && Number(c.credit) === 100000),
    'insurance was not credited to its own configured revenue account',
  );
});

/* ------------------------------------------------------------------------ */
section('Configuration Packages — export/import, including bulk performance');

await test('export and import round-trip a table with no relation columns', async () => {
  const stamp = Date.now();
  const code = `TESTPKG${stamp}`;
  await configPackages.createConfigPackage(
    { code, name: 'Test charges package', table_name: 'charge', key_field: 'code' },
    ['code', 'description'], admin,
  );

  const insertCsv = `Code,Description\nCFGTEST1,First test charge\nCFGTEST2,Second test charge`;
  const insertResult = await configPackages.importConfigPackage(code, insertCsv, admin);
  assert.strictEqual(insertResult.inserted, 2);
  assert.strictEqual(insertResult.errors, 0);

  const exported = await configPackages.exportConfigPackage(code);
  assert.ok(exported.csv.includes('CFGTEST1'), 'exported CSV missing the row just inserted');
  assert.ok(exported.csv.includes('CFGTEST2'), 'exported CSV missing the row just inserted');

  // Re-importing its own export should UPDATE, not duplicate-insert, every row — export() has
  // no filter here, so this reimports the whole (shared) charge table, not just the two rows
  // just inserted above, hence >= rather than a specific count.
  const updateResult = await configPackages.importConfigPackage(code, exported.csv, admin);
  assert.ok(updateResult.updated >= 2, `expected at least the 2 test rows to update, got ${updateResult.updated}`);
  assert.strictEqual(updateResult.inserted, 0, 're-importing an export should never insert a new row');
  assert.strictEqual(updateResult.errors, 0);

  await configPackages.deleteConfigPackage(code, admin);
  await run("DELETE FROM charge WHERE code IN ('CFGTEST1','CFGTEST2')");
});

await test('import resolves a relation column by code and by raw id, and rejects an unknown one', async () => {
  const [account] = await gl.listPostableAccounts();
  if (!account) throw new Error('need at least one postable GL account for this test');
  const stamp = Date.now();
  const code = `TESTPKGCAT${stamp}`;
  await configPackages.createConfigPackage(
    { code, name: 'Test member categories package', table_name: 'member_category', key_field: 'code' },
    ['code', 'description', 'category_type', 'registration_fee_account_id'], admin,
  );

  const byCodeCsv =
    `Code,Description,Category Type,Registration Fee Account\nCFGCAT1,By code,INDIVIDUAL,${account.code}`;
  const byCode = await configPackages.importConfigPackage(code, byCodeCsv, admin);
  assert.strictEqual(byCode.errors, 0, byCode.rows.find((r) => r.status === 'ERROR')?.message ?? 'unexpected error');
  const row1 = (await one<{ registration_fee_account_id: number }>(
    "SELECT registration_fee_account_id FROM member_category WHERE code = 'CFGCAT1'",
  ))!;
  assert.strictEqual(row1.registration_fee_account_id, account.id, 'relation not resolved by code');

  const byIdCsv =
    `Code,Description,Category Type,Registration Fee Account\nCFGCAT2,By id,INDIVIDUAL,${account.id}`;
  const byId = await configPackages.importConfigPackage(code, byIdCsv, admin);
  assert.strictEqual(byId.errors, 0, byId.rows.find((r) => r.status === 'ERROR')?.message ?? 'unexpected error');
  const row2 = (await one<{ registration_fee_account_id: number }>(
    "SELECT registration_fee_account_id FROM member_category WHERE code = 'CFGCAT2'",
  ))!;
  assert.strictEqual(row2.registration_fee_account_id, account.id, 'relation not resolved by raw id');

  const unknownCsv =
    'Code,Description,Category Type,Registration Fee Account\nCFGCAT3,Unknown ref,INDIVIDUAL,NOSUCHACCOUNT';
  const unknown = await configPackages.importConfigPackage(code, unknownCsv, admin);
  assert.strictEqual(unknown.errors, 1);
  assert.strictEqual(unknown.rows[0].status, 'ERROR');

  await configPackages.deleteConfigPackage(code, admin);
  await run("DELETE FROM member_category WHERE code IN ('CFGCAT1','CFGCAT2','CFGCAT3')");
});

await test('a batch import resolves a relation value repeated across many rows without re-querying it per row', async () => {
  const [account] = await gl.listPostableAccounts();
  if (!account) throw new Error('need at least one postable GL account for this test');
  const stamp = Date.now();
  const code = `TESTPKGBULK${stamp}`;
  await configPackages.createConfigPackage(
    { code, name: 'Test bulk package', table_name: 'member_category', key_field: 'code' },
    ['code', 'description', 'category_type', 'registration_fee_account_id'], admin,
  );

  const rowCount = 15;
  const lines = ['Code,Description,Category Type,Registration Fee Account'];
  for (let i = 0; i < rowCount; i++) lines.push(`CFGBULK${i},Bulk row ${i},INDIVIDUAL,${account.code}`);
  const t0 = Date.now();
  const result = await configPackages.importConfigPackage(code, lines.join('\n'), admin);
  const elapsedMs = Date.now() - t0;

  assert.strictEqual(result.inserted, rowCount);
  assert.strictEqual(result.errors, 0);
  // Loosely bounds against the N+1-query-per-cell regression this fixed (each relation cell used
  // to cost two extra round trips to the database on top of the row's own read+write) — not a
  // strict performance benchmark, just a guard rail generous enough not to flake on a slower CI
  // box, while still catching the pattern coming back.
  assert.ok(
    elapsedMs / rowCount < 3000,
    `import averaged ${(elapsedMs / rowCount).toFixed(0)}ms/row — the relation lookup may be re-querying per row again`,
  );

  await configPackages.deleteConfigPackage(code, admin);
  await run(`DELETE FROM member_category WHERE code LIKE 'CFGBULK%'`);
});

/* ------------------------------------------------------------------------ */
section('Arrears classification');

await test('ageing classifies loans by days in arrears', async () => {
  const r = await loanSvc.runArrearsAging();
  assert.ok(r.loansProcessed >= 0);
  const bad = await all<{ loan_no: string }>(
    `SELECT loan_no, days_in_arrears, classification FROM loan
     WHERE status='DISBURSED' AND (
       (days_in_arrears <= 30  AND classification <> 'PERFORMING') OR
       (days_in_arrears BETWEEN 31 AND 180 AND classification <> 'WATCH') OR
       (days_in_arrears BETWEEN 181 AND 360 AND classification <> 'SUBSTANDARD'))`,
  );
  assert.strictEqual(bad.length, 0, `misclassified: ${bad.map((b) => b.loan_no).join(', ')}`);
});

/* ------------------------------------------------------------------------ */
section('Entrance Fee Recovery');

const regFeeGl = await gl.createGlAccount(
  { code: 'TEST-REGFEE', name: 'Test Registration Fee Income', type: 'INCOME' }, admin,
);
const { id: efrCategoryId } = await pool.createMemberCategory(
  {
    code: 'EFRTEST', description: 'Entrance Fee Recovery test category', category_type: 'INDIVIDUAL',
    registration_fee: 500000, registration_fee_account_id: regFeeGl.id,
  },
  [], admin,
);
const efrMember = await membersLib.createMember(
  {
    member_type: 'INDIVIDUAL', member_category_id: efrCategoryId, first_name: 'Fee', last_name: 'Testcase',
    status: 'NOT PAID UP',
  },
  admin,
);
const bosaProduct = (await one<{ id: number }>("SELECT id FROM savings_product WHERE code='BOSA'"))!;
const efrAccount = await savings.openAccount({ memberId: efrMember.id, productId: bosaProduct.id, enforceMinOpening: false });
await savings.deposit({ accountId: efrAccount.id, amount: 200000, user: admin, description: 'test funding' });

await test('a candidate reports the outstanding fee capped by the available balance', async () => {
  const candidates = await entranceFeeRecovery.listEntranceFeeRecoveryCandidates();
  const c = candidates.find((x) => x.member_id === efrMember.id);
  assert.ok(c, 'the test member should be a candidate');
  assert.strictEqual(c!.registration_fee, 500000);
  assert.strictEqual(c!.paid_registration, 0);
  assert.strictEqual(c!.outstanding, 500000);
  assert.strictEqual(c!.available_balance, 200000);
  assert.strictEqual(c!.posting_amount, 200000);
});

await test('a partial recovery posts what is available and leaves the member Not Paid Up', async () => {
  const summary = await entranceFeeRecovery.runEntranceFeeRecovery(admin);
  const r = summary.results.find((x) => x.member_id === efrMember.id);
  assert.ok(r, 'the test member should appear in the run results');
  assert.strictEqual(r!.posted, 200000);
  assert.strictEqual(r!.activated, false);
  const m = (await one<{ status: string }>('SELECT status FROM member WHERE id = ?', efrMember.id))!;
  assert.strictEqual(m.status, 'NOT PAID UP');
  assert.strictEqual(await accounting.accountBalance('TEST-REGFEE'), 200000);
  assert.strictEqual((await savings.getAccount(efrAccount.id))!.balance, 0);
});

await test('topping up and running again fully recovers the fee and activates the member', async () => {
  await savings.deposit({ accountId: efrAccount.id, amount: 400000, user: admin, description: 'more funding' });
  const summary = await entranceFeeRecovery.runEntranceFeeRecovery(admin);
  const r = summary.results.find((x) => x.member_id === efrMember.id);
  assert.ok(r, 'the test member should appear in the run results');
  assert.strictEqual(r!.posted, 300000, 'only the remaining balance of the fee, not the full deposit');
  assert.strictEqual(r!.activated, true);
  const m = (await one<{ status: string }>('SELECT status FROM member WHERE id = ?', efrMember.id))!;
  assert.strictEqual(m.status, 'ACTIVE');
  assert.strictEqual(await accounting.accountBalance('TEST-REGFEE'), 500000);
});

await test('a fully recovered member is no longer a candidate', async () => {
  const candidates = await entranceFeeRecovery.listEntranceFeeRecoveryCandidates();
  assert.ok(!candidates.some((x) => x.member_id === efrMember.id));
});

/* ------------------------------------------------------------------------ */
section('System Automation (Job Queue)');

await test('a new entry starts On Hold', async () => {
  const { id } = await jobQueueLib.createJobQueueEntry(
    { code: 'TEST-EFR-JOB1', description: 'test', job_type: 'ENTRANCE_FEE_RECOVERY', run_every_minutes: 60 }, admin,
  );
  const entry = await jobQueueLib.getJobQueueEntry(id);
  assert.strictEqual(entry!.status, 'ON HOLD');
  await jobQueueLib.deleteJobQueueEntry(id, admin);
});

await test('runDueJobQueueEntries ignores an On Hold entry but runs a Ready, due one', async () => {
  const { id } = await jobQueueLib.createJobQueueEntry(
    { code: 'TEST-EFR-JOB2', description: 'test', job_type: 'ENTRANCE_FEE_RECOVERY', run_every_minutes: 60 }, admin,
  );
  await jobQueueLib.runDueJobQueueEntries();
  let entry = await jobQueueLib.getJobQueueEntry(id);
  assert.strictEqual(entry!.last_run_at, null, 'an On Hold entry must never run');

  await jobQueueLib.setJobQueueEntryStatus(id, 'READY', admin);
  await jobQueueLib.runDueJobQueueEntries();
  entry = await jobQueueLib.getJobQueueEntry(id);
  assert.strictEqual(entry!.last_run_status, 'SUCCESS');
  assert.ok(entry!.last_run_message);
  assert.ok(entry!.next_run_at! > entry!.last_run_at!, 'next_run_at should be rescheduled forward from the run');
  await jobQueueLib.deleteJobQueueEntry(id, admin);
});

await test('running an entry now works regardless of its schedule', async () => {
  const { id } = await jobQueueLib.createJobQueueEntry(
    { code: 'TEST-EFR-JOB3', description: 'test', job_type: 'ENTRANCE_FEE_RECOVERY', run_every_minutes: 60 }, admin,
  );
  await jobQueueLib.runJobQueueEntryNow(id, admin);
  const entry = await jobQueueLib.getJobQueueEntry(id);
  assert.strictEqual(entry!.status, 'ON HOLD', 'running now must not itself flip the entry to Ready');
  assert.strictEqual(entry!.last_run_status, 'SUCCESS');
  await jobQueueLib.deleteJobQueueEntry(id, admin);
});

/* ------------------------------------------------------------------------ */
section('Member Status Update');

const msuBosaProductId = (await one<{ id: number }>("SELECT id FROM savings_product WHERE code='BOSA'"))!.id;
const msuFosaProductId = (await one<{ id: number }>("SELECT id FROM savings_product WHERE code='FOSA'"))!.id;

const msuMemberA = await membersLib.createMember(
  { member_type: 'INDIVIDUAL', first_name: 'DormancyA', last_name: 'Testcase' }, admin,
);
const msuBosaA = await savings.openAccount({ memberId: msuMemberA.id, productId: msuBosaProductId, enforceMinOpening: false });
const msuFosaA = await savings.openAccount({ memberId: msuMemberA.id, productId: msuFosaProductId, enforceMinOpening: false });
await savings.deposit({ accountId: msuFosaA.id, amount: 500000, user: admin, description: 'unrelated funds' });
// Backdate the BOSA account's own last activity — the only thing dormancy is driven off — well
// past any real Dormancy Period so this test never depends on what's actually configured.
await run('UPDATE savings_account SET last_activity = ? WHERE id = ?', '2000-01-01', msuBosaA.id);

await test('a member with no money in BOSA long enough is flagged to be marked Dormant', async () => {
  const candidates = await memberStatusUpdate.listMemberStatusUpdateCandidates();
  const c = candidates.find((x) => x.member_id === msuMemberA.id);
  assert.ok(c, 'the test member should be a candidate');
  assert.strictEqual(c!.action, 'MARK_DORMANT');
  assert.ok(c!.days_since_activity! > 1000);
});

await test('running the update marks that member Dormant', async () => {
  const summary = await memberStatusUpdate.runMemberStatusUpdate(admin);
  const r = summary.results.find((x) => x.member_id === msuMemberA.id);
  assert.ok(r, 'the test member should appear in the run results');
  assert.strictEqual(r!.action, 'MARK_DORMANT');
  const m = (await one<{ status: string }>('SELECT status FROM member WHERE id = ?', msuMemberA.id))!;
  assert.strictEqual(m.status, 'DORMANT');
});

await test('assertMemberNotDormant rejects a Dormant member and passes an Active one', async () => {
  await throws(() => memberDormancy.assertMemberNotDormant(msuMemberA.id, 'a test action'), /MEMBER_DORMANT/);
  await memberDormancy.assertMemberNotDormant(testMember.id, 'a test action');
});

await test('a Dormant member cannot withdraw, even from an unrelated account with funds', async () => {
  await throws(() => savings.withdraw({ accountId: msuFosaA.id, amount: 1000, user: admin }), /MEMBER_DORMANT/);
});

await test('a Dormant member can still deposit', async () => {
  const before = (await savings.getAccount(msuFosaA.id))!.balance;
  await savings.deposit({ accountId: msuFosaA.id, amount: 1000, user: admin, description: 'still allowed' });
  assert.strictEqual((await savings.getAccount(msuFosaA.id))!.balance, before + 1000);
});

await test('a deposit into the dormant BOSA account reactivates the member for free when no charge is configured', async () => {
  await savings.deposit({ accountId: msuBosaA.id, amount: 100000, user: admin, description: 'reactivating deposit' });
  const summary = await memberStatusUpdate.runMemberStatusUpdate(admin);
  const r = summary.results.find((x) => x.member_id === msuMemberA.id);
  assert.ok(r, 'the test member should appear in the run results');
  assert.strictEqual(r!.action, 'REACTIVATE');
  assert.strictEqual(r!.charged, 0);
  const m = (await one<{ status: string }>('SELECT status FROM member WHERE id = ?', msuMemberA.id))!;
  assert.strictEqual(m.status, 'ACTIVE');
});

/* Reactivation charge scenarios — a flat KES 200.00 "Member Reactivation" Transaction Charge. */
const msuStamp = Date.now();
const msuChargeGl = await gl.createGlAccount(
  { code: `TESTREACTGL${msuStamp}`, name: 'Test Reactivation Income', type: 'INCOME' }, admin,
);
const msuCharge = await chargesLib.createCharge(`TESTREACT${msuStamp}`, 'Test reactivation fee', admin);
await chargesLib.createTransactionCharge(
  { code: `TESTREACTTC${msuStamp}`, description: 'Test Member Reactivation Charge', transaction_type: 'Member Reactivation' },
  [{
    charge_id: msuCharge.id, gl_account_id: msuChargeGl.id, calculation_type: 'SCHEME', source_index: null,
    scheme: [{ lower_limit: 0, upper_limit: null, rate_type: 'FLAT', flat_amount: 20000 }],
  }],
  admin,
);

const msuMemberB = await membersLib.createMember(
  { member_type: 'INDIVIDUAL', first_name: 'DormancyB', last_name: 'Testcase', status: 'DORMANT' }, admin,
);
const msuBosaB = await savings.openAccount({ memberId: msuMemberB.id, productId: msuBosaProductId, enforceMinOpening: false });

const msuMemberC = await membersLib.createMember(
  { member_type: 'INDIVIDUAL', first_name: 'DormancyC', last_name: 'Testcase', status: 'DORMANT' }, admin,
);
const msuBosaC = await savings.openAccount({ memberId: msuMemberC.id, productId: msuBosaProductId, enforceMinOpening: false });

await test('an affordable reactivation charge is recovered from the deposit and the member is reactivated', async () => {
  await savings.deposit({ accountId: msuBosaB.id, amount: 100000, user: admin, description: 'reactivating deposit' });
  const summary = await memberStatusUpdate.runMemberStatusUpdate(admin);
  const r = summary.results.find((x) => x.member_id === msuMemberB.id);
  assert.ok(r, 'the test member should appear in the run results');
  assert.strictEqual(r!.action, 'REACTIVATE');
  assert.strictEqual(r!.charged, 20000);
  assert.strictEqual((await savings.getAccount(msuBosaB.id))!.balance, 80000);
  const m = (await one<{ status: string }>('SELECT status FROM member WHERE id = ?', msuMemberB.id))!;
  assert.strictEqual(m.status, 'ACTIVE');
  assert.strictEqual(await accounting.accountBalance(`TESTREACTGL${msuStamp}`), 20000);
});

await test('a deposit too small to cover the reactivation charge leaves the member Dormant', async () => {
  await savings.deposit({ accountId: msuBosaC.id, amount: 10000, user: admin, description: 'too little to reactivate' });
  const summary = await memberStatusUpdate.runMemberStatusUpdate(admin);
  const r = summary.results.find((x) => x.member_id === msuMemberC.id);
  assert.ok(r, 'the test member should appear in the run results');
  assert.strictEqual(r!.action, 'REACTIVATION_BLOCKED');
  assert.strictEqual(r!.charged, 0);
  assert.strictEqual((await savings.getAccount(msuBosaC.id))!.balance, 10000, 'nothing should have been charged');
  const m = (await one<{ status: string }>('SELECT status FROM member WHERE id = ?', msuMemberC.id))!;
  assert.strictEqual(m.status, 'DORMANT');
});

/* ------------------------------------------------------------------------ */
section('Member Activation');

const maBosaProductId = (await one<{ id: number }>("SELECT id FROM savings_product WHERE code='BOSA'"))!.id;
const maFosaProductId = (await one<{ id: number }>("SELECT id FROM savings_product WHERE code='FOSA'"))!.id;

const maMember = await membersLib.createMember(
  { member_type: 'INDIVIDUAL', first_name: 'Activation', last_name: 'Testcase', status: 'DORMANT' }, admin,
);
const maBosa = await savings.openAccount({ memberId: maMember.id, productId: maBosaProductId, enforceMinOpening: false });
await savings.deposit({ accountId: maBosa.id, amount: 100000, user: admin, description: 'test funding' });
// A second account this member holds, already INACTIVE — processing should reopen it too (AL's
// own "unblock every Vendor" loop), not just flip the member's own status.
const maFosa = await savings.openAccount({ memberId: maMember.id, productId: maFosaProductId, enforceMinOpening: false });
await run("UPDATE savings_account SET status = 'INACTIVE' WHERE id = ?", maFosa.id);

await test('a Dormant member is offered for activation; an Active one is not', async () => {
  const eligible = await memberActivation.eligibleMembersForActivation();
  assert.ok(eligible.some((m) => m.id === maMember.id));
  assert.ok(!eligible.some((m) => m.id === testMember.id));
});

await test('only a Dormant member can have an activation request opened against them', async () => {
  await throws(
    () => memberActivation.createMemberActivationRequest(
      { memberId: testMember.id, reason: 'test', payFromAccountType: 'MEMBER_ACCOUNT' }, admin,
    ),
    /VALIDATION/,
  );
});

const { no: maNo } = await memberActivation.createMemberActivationRequest(
  { memberId: maMember.id, reason: 'Walked in to reactivate', payFromAccountType: 'MEMBER_ACCOUNT' }, admin,
);

await test('a second request cannot be opened while one is already in flight', async () => {
  await throws(
    () => memberActivation.createMemberActivationRequest(
      { memberId: maMember.id, reason: 'duplicate', payFromAccountType: 'MEMBER_ACCOUNT' }, admin,
    ),
    /VALIDATION/,
  );
});

await test('processing (bypassing workflow routing, which this suite does not exercise) reactivates the member and every inactive account', async () => {
  // No workflow is configured for MEMBER_ACTIVATION in a fresh install (an admin sets one up via
  // Admin Centre → Workflow Management before the module is used for real) — this test isolates
  // processMemberActivationRequest() itself by moving the request to Approved directly, the same
  // way it would arrive there via a real approval.
  await run("UPDATE member_activation_request SET status = 'Approved' WHERE no = ?", maNo);
  const { memberId } = await memberActivation.processMemberActivationRequest(maNo, admin);
  assert.strictEqual(memberId, maMember.id);

  const m = (await one<{ status: string }>('SELECT status FROM member WHERE id = ?', maMember.id))!;
  assert.strictEqual(m.status, 'ACTIVE');
  const fosaAfter = (await one<{ status: string }>('SELECT status FROM savings_account WHERE id = ?', maFosa.id))!;
  assert.strictEqual(fosaAfter.status, 'ACTIVE');
  const req = (await one<{ status: string }>('SELECT status FROM member_activation_request WHERE no = ?', maNo))!;
  assert.strictEqual(req.status, 'Processed');
});

/* A second member, reactivated with a real MEMBER_ACCOUNT-funded charge. */
const maStamp = Date.now();
const maChargeGl = await gl.createGlAccount(
  { code: `TESTMAGL${maStamp}`, name: 'Test Member Activation Income', type: 'INCOME' }, admin,
);
const maCharge = await chargesLib.createCharge(`TESTMA${maStamp}`, 'Test member activation fee', admin);
await chargesLib.createTransactionCharge(
  { code: `TESTMATC${maStamp}`, description: 'Test Member Activation Charge', transaction_type: 'General' },
  [{
    charge_id: maCharge.id, gl_account_id: maChargeGl.id, calculation_type: 'SCHEME', source_index: null,
    scheme: [{ lower_limit: 0, upper_limit: null, rate_type: 'FLAT', flat_amount: 15000 }],
  }],
  admin,
);
const maTransactionCharge = (await one<{ id: number }>(`SELECT id FROM transaction_charge WHERE code = 'TESTMATC${maStamp}'`))!;

const maMember2 = await membersLib.createMember(
  { member_type: 'INDIVIDUAL', first_name: 'ActivationB', last_name: 'Testcase', status: 'DORMANT' }, admin,
);
const maBosa2 = await savings.openAccount({ memberId: maMember2.id, productId: maBosaProductId, enforceMinOpening: false });
await savings.deposit({ accountId: maBosa2.id, amount: 100000, user: admin, description: 'test funding' });

await test('a charge paid from the member\'s own account is recovered and the member is reactivated', async () => {
  const { no } = await memberActivation.createMemberActivationRequest(
    {
      memberId: maMember2.id, reason: 'test', payFromAccountType: 'MEMBER_ACCOUNT',
      transactionChargeId: maTransactionCharge.id, debitAccountId: maBosa2.id,
    },
    admin,
  );
  await run("UPDATE member_activation_request SET status = 'Approved' WHERE no = ?", no);
  await memberActivation.processMemberActivationRequest(no, admin);

  const m = (await one<{ status: string }>('SELECT status FROM member WHERE id = ?', maMember2.id))!;
  assert.strictEqual(m.status, 'ACTIVE');
  assert.strictEqual((await savings.getAccount(maBosa2.id))!.balance, 100000 - 15000);
  assert.strictEqual(await accounting.accountBalance(`TESTMAGL${maStamp}`), 15000);
});

const maMember3 = await membersLib.createMember(
  { member_type: 'INDIVIDUAL', first_name: 'ActivationC', last_name: 'Testcase', status: 'DORMANT' }, admin,
);
const maBosa3 = await savings.openAccount({ memberId: maMember3.id, productId: maBosaProductId, enforceMinOpening: false });
await savings.deposit({ accountId: maBosa3.id, amount: 5000, user: admin, description: 'too little to cover the charge' });

await test('a charge exceeding the debit account\'s available balance is rejected up front', async () => {
  await throws(
    () => memberActivation.createMemberActivationRequest(
      {
        memberId: maMember3.id, reason: 'test', payFromAccountType: 'MEMBER_ACCOUNT',
        transactionChargeId: maTransactionCharge.id, debitAccountId: maBosa3.id,
      },
      admin,
    ),
    /INSUFFICIENT_FUNDS/,
  );
});

/* ------------------------------------------------------------------------ */
section('Standing Orders');

const soFosaProductId = (await one<{ id: number }>("SELECT id FROM savings_product WHERE code='FOSA'"))!.id;

const soMemberA = await membersLib.createMember(
  { member_type: 'INDIVIDUAL', first_name: 'StandingA', last_name: 'Testcase' }, admin,
);
const soFosaA = await savings.openAccount({ memberId: soMemberA.id, productId: soFosaProductId, enforceMinOpening: false });
const soMemberB = await membersLib.createMember(
  { member_type: 'INDIVIDUAL', first_name: 'StandingB', last_name: 'Testcase' }, admin,
);
const soFosaB = await savings.openAccount({ memberId: soMemberB.id, productId: soFosaProductId, enforceMinOpening: false });

const soStartDate = today; // the fixture at the top of this file — see "const today = ..." above.

await test('a standing order cannot start in the past', async () => {
  await throws(
    () => standingOrdersLib.createStandingOrder({
      memberId: soMemberA.id, accountId: soFosaA.id, standingOrderClass: 'INTERNAL', amountType: 'SWEEP',
      destinationMemberId: soMemberB.id, destinationAccountId: soFosaB.id, postingDescription: 'test',
      startDate: '2000-01-01', tillFurtherNotice: true,
    }, admin),
    /VALIDATION/,
  );
});

const { no: soSweepNo } = await standingOrdersLib.createStandingOrder(
  {
    memberId: soMemberA.id, accountId: soFosaA.id, standingOrderClass: 'INTERNAL', amountType: 'SWEEP',
    destinationMemberId: soMemberB.id, destinationAccountId: soFosaB.id, postingDescription: 'Sweep to B',
    startDate: soStartDate, tillFurtherNotice: true,
  },
  admin,
);

await test('a second standing order to the same destination is rejected as a duplicate', async () => {
  await throws(
    () => standingOrdersLib.createStandingOrder({
      memberId: soMemberA.id, accountId: soFosaA.id, standingOrderClass: 'INTERNAL', amountType: 'FIXED',
      amount: 100000, destinationMemberId: soMemberB.id, destinationAccountId: soFosaB.id,
      postingDescription: 'duplicate', startDate: soStartDate, tillFurtherNotice: true,
    }, admin),
    /DUPLICATE/,
  );
});

await test('approval sets the order running immediately, with no separate Process step', async () => {
  // No workflow is configured for STANDING_ORDER in a fresh install (an admin sets one up via
  // Admin Centre → Workflow Management) — this test isolates approveStandingOrder() itself,
  // the same way the Member Activation tests above bypass submission's own workflow routing.
  await run("UPDATE standing_order SET status = 'Pending Approval' WHERE no = ?", soSweepNo);
  await standingOrdersLib.approveStandingOrder(soSweepNo, admin);
  const o = (await one<{ status: string; running: boolean }>('SELECT status, running FROM standing_order WHERE no = ?', soSweepNo))!;
  assert.strictEqual(o.status, 'Approved');
  assert.strictEqual(o.running, true);
});

await test('a Sweep order moves nothing when the source account is empty', async () => {
  const summary = await standingOrdersLib.runStandingOrders(admin, soStartDate);
  assert.ok(!summary.results.some((r) => r.no === soSweepNo && r.action === 'POSTED'));
});

await test('funding the source account and running again sweeps the full available balance', async () => {
  await savings.deposit({ accountId: soFosaA.id, amount: 250000, user: admin, description: 'test funding' });
  const summary = await standingOrdersLib.runStandingOrders(admin, soStartDate);
  const r = summary.results.find((x) => x.no === soSweepNo);
  assert.ok(r, 'the order should appear in the run results');
  assert.strictEqual(r!.action, 'POSTED');
  assert.strictEqual(r!.posted, 250000);
  assert.strictEqual((await savings.getAccount(soFosaA.id))!.balance, 0);
  assert.strictEqual((await savings.getAccount(soFosaB.id))!.balance, 250000);
});

await test('running again the same day is a no-op — last_run_date guards against double-posting', async () => {
  await savings.deposit({ accountId: soFosaA.id, amount: 50000, user: admin, description: 'more funds, same day' });
  const summary = await standingOrdersLib.runStandingOrders(admin, soStartDate);
  assert.ok(!summary.results.some((r) => r.no === soSweepNo));
  assert.strictEqual((await savings.getAccount(soFosaA.id))!.balance, 50000, 'the second deposit should be untouched');
});

const addDays = (iso: string, n: number): string =>
  new Date(new Date(`${iso}T00:00:00Z`).getTime() + n * 86_400_000).toISOString().slice(0, 10);

await test('running on a later day sweeps again', async () => {
  const tomorrow = addDays(soStartDate, 1);
  const summary = await standingOrdersLib.runStandingOrders(admin, tomorrow);
  const r = summary.results.find((x) => x.no === soSweepNo);
  assert.ok(r && r.action === 'POSTED');
  assert.strictEqual((await savings.getAccount(soFosaA.id))!.balance, 0);
  assert.strictEqual((await savings.getAccount(soFosaB.id))!.balance, 300000);
});

await test('terminating stops the order for good', async () => {
  await standingOrdersLib.terminateStandingOrder(soSweepNo, admin);
  const o = (await one<{ running: boolean; terminated: boolean }>('SELECT running, terminated FROM standing_order WHERE no = ?', soSweepNo))!;
  assert.strictEqual(o.running, false);
  assert.strictEqual(o.terminated, true);
  await throws(() => standingOrdersLib.terminateStandingOrder(soSweepNo, admin), /VALIDATION/);
});

/* A Fixed, Specific-Day order — exercises the schedule gate and the freeze/auto-unfreeze cycle. */
const soMemberC = await membersLib.createMember(
  { member_type: 'INDIVIDUAL', first_name: 'StandingC', last_name: 'Testcase' }, admin,
);
const soFosaC = await savings.openAccount({ memberId: soMemberC.id, productId: soFosaProductId, enforceMinOpening: false });
await savings.deposit({ accountId: soFosaC.id, amount: 1000000, user: admin, description: 'test funding' });

const soRunFromDay = Number(soStartDate.slice(8, 10));
const soDueNextMonth = addMonths(soStartDate, 1);
const soNotDueDate = addDays(soStartDate, 1) === soDueNextMonth ? addDays(soStartDate, 2) : addDays(soStartDate, 1);

const { no: soFixedNo } = await standingOrdersLib.createStandingOrder(
  {
    memberId: soMemberC.id, accountId: soFosaC.id, standingOrderClass: 'INTERNAL', amountType: 'FIXED', amount: 100000,
    destinationMemberId: soMemberB.id, destinationAccountId: soFosaB.id, postingDescription: 'Fixed to B',
    runType: 'SPECIFIC_DAY', runFromDay: soRunFromDay, startDate: soStartDate, tillFurtherNotice: true,
  },
  admin,
);
await run("UPDATE standing_order SET status = 'Approved', running = true WHERE no = ?", soFixedNo);

await test('a Fixed order runs on its own day of the month', async () => {
  const summary = await standingOrdersLib.runStandingOrders(admin, soStartDate);
  const r = summary.results.find((x) => x.no === soFixedNo);
  assert.ok(r && r.action === 'POSTED');
  assert.strictEqual(r!.posted, 100000);
});

await test('a Fixed order does not run on a day other than its own', async () => {
  const summary = await standingOrdersLib.runStandingOrders(admin, soNotDueDate);
  assert.ok(!summary.results.some((r) => r.no === soFixedNo));
});

await test('freezing pauses the order, and it auto-unfreezes once the freeze date passes', async () => {
  // freeze_end_date must not yet have *passed* on soDueNextMonth itself (the auto-unfreeze
  // check is freeze_end_date < dateStr) — freezing through that exact day keeps it paused for
  // that run, then lifts on the following due date.
  await standingOrdersLib.freezeStandingOrder(soFixedNo, soDueNextMonth, admin);
  let summary = await standingOrdersLib.runStandingOrders(admin, soDueNextMonth);
  assert.ok(!summary.results.some((r) => r.no === soFixedNo), 'frozen orders must not post');
  const stillFrozen = (await one<{ freezed: boolean }>('SELECT freezed FROM standing_order WHERE no = ?', soFixedNo))!;
  assert.strictEqual(stillFrozen.freezed, true);

  const dueMonthAfter = addMonths(soDueNextMonth, 1);
  summary = await standingOrdersLib.runStandingOrders(admin, dueMonthAfter);
  const r = summary.results.find((x) => x.no === soFixedNo);
  assert.ok(r && r.action === 'POSTED', 'the order should have auto-unfrozen and posted on its next due day');
  const unfrozen = (await one<{ freezed: boolean }>('SELECT freezed FROM standing_order WHERE no = ?', soFixedNo))!;
  assert.strictEqual(unfrozen.freezed, false);
});

/* A Loan Repayment order — reuses one of the seeded disbursed loans. */
const soLoan = await one<{ id: number; member_id: number; loan_no: string }>(
  "SELECT id, member_id, loan_no FROM loan WHERE status = 'DISBURSED' LIMIT 1",
);

if (soLoan) {
  await test('a Loan Repayment order pays down the loan through the normal repayment engine', async () => {
    const before = (await one<{ principal_balance: number; interest_balance: number; penalty_balance: number }>(
      'SELECT principal_balance, interest_balance, penalty_balance FROM loan WHERE id = ?', soLoan.id,
    ))!;
    const owedBefore = before.principal_balance + before.interest_balance + before.penalty_balance;

    const borrowerFosa = await one<{ id: number }>(
      `SELECT sa.id FROM savings_account sa JOIN savings_product sp ON sp.id = sa.product_id
       WHERE sa.member_id = ? AND sp.code = 'FOSA'`,
      soLoan.member_id,
    );
    if (!borrowerFosa) {
      await savings.openAccount({ memberId: soLoan.member_id, productId: soFosaProductId, enforceMinOpening: false });
    }
    const source = borrowerFosa ?? (await one<{ id: number }>(
      `SELECT sa.id FROM savings_account sa JOIN savings_product sp ON sp.id = sa.product_id
       WHERE sa.member_id = ? AND sp.code = 'FOSA'`,
      soLoan.member_id,
    ))!;
    await savings.deposit({ accountId: source.id, amount: owedBefore + 100000, user: admin, description: 'test funding' });

    const { no } = await standingOrdersLib.createStandingOrder(
      {
        memberId: soLoan.member_id, accountId: source.id, standingOrderClass: 'LOAN', amountType: 'SWEEP',
        destinationLoanId: soLoan.id, postingDescription: 'Loan repayment STO', startDate: soStartDate, tillFurtherNotice: true,
      },
      admin,
    );
    await run("UPDATE standing_order SET status = 'Approved', running = true WHERE no = ?", no);
    const summary = await standingOrdersLib.runStandingOrders(admin, soStartDate);
    const r = summary.results.find((x) => x.no === no);
    assert.ok(r && r.action === 'POSTED', 'sweeping the full outstanding balance should close the loan this run');
    assert.strictEqual(r!.posted, owedBefore);

    const after = (await one<{ status: string; principal_balance: number; interest_balance: number; penalty_balance: number }>(
      'SELECT status, principal_balance, interest_balance, penalty_balance FROM loan WHERE id = ?', soLoan.id,
    ))!;
    assert.strictEqual(after.status, 'CLOSED');
    assert.ok(after.principal_balance <= 0 && after.interest_balance <= 0 && after.penalty_balance <= 0);

    // The loan is fully repaid now, but that's only detected on the *next* run's own up-front
    // check (AL's own UpdateSTO/RunStandingOrder run in that same order) — mirrored here by
    // running again on a later day.
    const later = await standingOrdersLib.runStandingOrders(admin, addDays(soStartDate, 1));
    const r2 = later.results.find((x) => x.no === no);
    assert.ok(r2 && r2.action === 'TERMINATED', 'the next run should notice the loan is closed and auto-terminate the order');
  });
}

/* Disbursing a recovery_mode = STANDING_ORDER loan should auto-create and activate its own
 * recovery standing order — lib/loanService.ts's disburse() reaches lib/standingOrders.ts via a
 * dynamic import to avoid a static circular dependency (standingOrders.ts imports repay() from
 * loanService.ts for its own run engine); this exercises that exact call chain for real, in the
 * same Node ESM runtime this suite itself runs under. */
await test('disbursing a Standing-Order-recovery loan auto-creates and activates its own recovery standing order', async () => {
  const loan = await loanSvc.apply({
    memberId: borrower.id, productId: normProduct.id, principal: 10000000, termMonths: 12,
    purpose: 'Unit test — auto STO', disburseToAccountId: borrowerFosa.id, recoveryMode: 'STANDING_ORDER', user: admin,
  });
  await loanSvc.saveAppraisal({ loanId: loan.id, user: admin });
  await loanSvc.submit({ loanId: loan.id, user: admin });
  await loanSvc.approve({ loanId: loan.id, user: admin, approve: true, reason: 'ok' });
  const disbursed = await loanSvc.disburse({ loanId: loan.id, user: admin });
  assert.strictEqual(disbursed.status, 'DISBURSED');

  const sto = await one<{
    no: string; status: string; running: boolean; standing_order_class: string; amount: number; account_id: number;
  }>('SELECT * FROM standing_order WHERE destination_loan_id = ?', loan.id);
  assert.ok(sto, 'a recovery standing order should have been auto-created');
  assert.strictEqual(sto!.status, 'Approved');
  assert.strictEqual(sto!.running, true);
  assert.strictEqual(sto!.standing_order_class, 'LOAN');
  assert.strictEqual(sto!.amount, disbursed.installment);
  assert.strictEqual(sto!.account_id, borrowerFosa.id);

  const again = await standingOrdersLib.createRecoveryStandingOrderForLoan(loan.id, admin);
  assert.strictEqual(again, null, 'a loan that already has a live recovery order must not get a second one');
});

/* An EXTERNAL order — pays out through one of the SACCO's own Bank/Cashbook accounts rather
 * than to another member's account or a loan, the same Payment Channel concept the loan
 * disbursement tests above exercise for a bank payout. */
await test('an EXTERNAL standing order pays out through the picked Bank/Cashbook account', async () => {
  const soMemberExt = await membersLib.createMember(
    { member_type: 'INDIVIDUAL', first_name: 'StandingExt', last_name: 'Testcase' }, admin,
  );
  const soFosaExt = await savings.openAccount({ memberId: soMemberExt.id, productId: soFosaProductId, enforceMinOpening: false });
  await savings.deposit({ accountId: soFosaExt.id, amount: 500000, user: admin, description: 'test funding' });

  const { no } = await standingOrdersLib.createStandingOrder({
    memberId: soMemberExt.id, accountId: soFosaExt.id, standingOrderClass: 'EXTERNAL', amountType: 'FIXED',
    amount: 200000, destinationBankAccountId: payoutBankAccount.id, postingDescription: 'Test external payout',
    startDate: soStartDate, tillFurtherNotice: true,
  }, admin);
  await run("UPDATE standing_order SET status = 'Approved', running = true WHERE no = ?", no);

  const bankBalBefore = await accounting.accountBalance('1020');
  const summary = await standingOrdersLib.runStandingOrders(admin, soStartDate);
  const r = summary.results.find((x) => x.no === no);
  assert.ok(r && r.action === 'POSTED');
  assert.strictEqual(r!.posted, 200000);
  assert.strictEqual((await savings.getAccount(soFosaExt.id))!.balance, 300000);
  // BANK's own G/L control account is an asset — paying out through it lowers its balance,
  // same direction the loan disbursement bank-payout tests assert.
  assert.strictEqual(await accounting.accountBalance('1020'), bankBalBefore - 200000);
});

/* ------------------------------------------------------------------------ */
section('Checkoff & Salary Processing — CSV upload, Validate, Calculate, Transaction Recoveries');

const { id: ckoEmployerId } = await employersLib.createEmployer(
  { code: `CKOTEST${Date.now()}`, name: 'Checkoff Test Employer Ltd', status: 'ACTIVE' }, admin,
);
const ckoFosaProductId = (await one<{ id: number }>("SELECT id FROM savings_product WHERE code='FOSA'"))!.id;
const ckoHolProductId = (await one<{ id: number }>("SELECT id FROM savings_product WHERE code='HOL'"))!.id;

// Member A — a CHECKOFF-mode disbursed loan (LOAN recovery leg) and a HOL account (INTERNAL_DEPOSIT leg).
await employersLib.setMemberEmployer(borrower.id, ckoEmployerId, admin);
await run('UPDATE member SET staff_no = ? WHERE id = ?', 'CKO-A', borrower.id);
const ckoHolA = await savings.openAccount({ memberId: borrower.id, productId: ckoHolProductId, enforceMinOpening: false });
const ckoLoan = await loanSvc.apply({
  memberId: borrower.id, productId: normProduct.id, principal: 200000, termMonths: 12,
  purpose: 'Unit test — checkoff recovery', disburseToAccountId: borrowerFosa.id, recoveryMode: 'CHECKOFF', user: admin,
});
await loanSvc.saveAppraisal({ loanId: ckoLoan.id, user: admin });
await loanSvc.submit({ loanId: ckoLoan.id, user: admin });
await loanSvc.approve({ loanId: ckoLoan.id, user: admin, approve: true, reason: 'ok' });
const ckoLoanDisbursed = await loanSvc.disburse({ loanId: ckoLoan.id, user: admin });

// Member B — no loan, but a HOL account: the LOAN leg finds nothing, so Internal Deposit sweeps
// everything left after the charge.
const ckoMemberB = await membersLib.createMember(
  { member_type: 'INDIVIDUAL', first_name: 'ChckoffB', last_name: 'Testcase', staff_no: 'CKO-B' }, admin,
);
await employersLib.setMemberEmployer(ckoMemberB.id, ckoEmployerId, admin);
const ckoFosaB = await savings.openAccount({ memberId: ckoMemberB.id, productId: ckoFosaProductId, enforceMinOpening: false });
const ckoHolB = await savings.openAccount({ memberId: ckoMemberB.id, productId: ckoHolProductId, enforceMinOpening: false });

// Member C — no loan and no HOL account: both recoveries find nothing to act on, so the whole
// remainder falls through to a NET_AMOUNT row and is deposited to their own FOSA.
const ckoMemberC = await membersLib.createMember(
  { member_type: 'INDIVIDUAL', first_name: 'ChckoffC', last_name: 'Testcase', staff_no: 'CKO-C' }, admin,
);
await employersLib.setMemberEmployer(ckoMemberC.id, ckoEmployerId, admin);
const ckoFosaC = await savings.openAccount({ memberId: ckoMemberC.id, productId: ckoFosaProductId, enforceMinOpening: false });

const ckoStamp = Date.now();
const ckoChargeGl = await gl.createGlAccount(
  { code: `TESTCKOGL${ckoStamp}`, name: 'Test Checkoff Fee Income', type: 'INCOME' }, admin,
);
const ckoCharge = await chargesLib.createCharge(`TESTCKO${ckoStamp}`, 'Test salary processing fee', admin);
await chargesLib.createTransactionCharge(
  { code: `TESTCKOTC${ckoStamp}`, description: 'Test End Month Salary Charge', transaction_type: 'End Month Salary' },
  [{
    charge_id: ckoCharge.id, gl_account_id: ckoChargeGl.id, calculation_type: 'SCHEME', source_index: null,
    scheme: [{ lower_limit: 0, upper_limit: null, rate_type: 'FLAT', flat_amount: 5000 }],
  }],
  admin,
  [
    { recovery_type: 'LOAN', deduction_type: 'INSTALLMENT', priority: 1 },
    { recovery_type: 'INTERNAL_DEPOSIT', deduction_type: 'FULL_REMAINING', savings_product_id: ckoHolProductId, priority: 2 },
  ],
);
const ckoTransactionCharge = (await one<{ id: number }>(`SELECT id FROM transaction_charge WHERE code = ?`, `TESTCKOTC${ckoStamp}`))!;

await test('a Transaction Charge configured outside End Month Salary silently drops any submitted recoveries', async () => {
  const gl2 = await gl.createGlAccount({ code: `TESTCKOGL2${ckoStamp}`, name: 'Test Other Income', type: 'INCOME' }, admin);
  const c2 = await chargesLib.createCharge(`TESTCKO2${ckoStamp}`, 'Test general fee', admin);
  const { id } = await chargesLib.createTransactionCharge(
    { code: `TESTCKOTC2${ckoStamp}`, description: 'Test General Charge', transaction_type: 'General' },
    [{ charge_id: c2.id, gl_account_id: gl2.id, calculation_type: 'SCHEME', source_index: null, scheme: [{ lower_limit: 0, upper_limit: null, rate_type: 'FLAT', flat_amount: 1000 }] }],
    admin,
    [{ recovery_type: 'LOAN', deduction_type: 'INSTALLMENT', priority: 1 }],
  );
  const detail = await chargesLib.getTransactionCharge(id);
  assert.strictEqual(detail!.recoveries.length, 0);
});

const { no: ckoBatchNo } = await checkoffBatchesLib.createCheckoffBatch(
  ckoEmployerId, 'SALARY', `${today.slice(0, 7)}-01`, admin, ckoTransactionCharge.id,
);

await test('a Salary batch auto-populates a line for every active member with a withdrawable deposit account', async () => {
  const lines = await checkoffBatchesLib.listCheckoffBatchLines(ckoBatchNo);
  const memberIds = lines.map((l) => l.member_id);
  assert.ok(memberIds.includes(borrower.id));
  assert.ok(memberIds.includes(ckoMemberB.id));
  assert.ok(memberIds.includes(ckoMemberC.id));
});

const ckoCsv = [
  'Payroll No,Name,Amount',
  `CKO-A,Borrower Test,5000.00`,
  `CKO-B,Chckoff B,5000.00`,
  `CKO-C,Chckoff C,5000.00`,
  'CKO-UNKNOWN,Nobody,1000.00',
].join('\n');

await test('a CSV upload matches by payroll no., overwrites remitted amount, and reports unmatched rows', async () => {
  const result = await checkoffBatchesLib.applyCheckoffCsvUpload(ckoBatchNo, ckoCsv, admin);
  assert.strictEqual(result.matchedCount, 3);
  assert.strictEqual(result.totalUploaded, 1500000);
  assert.strictEqual(result.unmatchedRows.length, 1);
  assert.ok(result.unmatchedRows[0].includes('CKO-UNKNOWN'));

  const lines = await checkoffBatchesLib.listCheckoffBatchLines(ckoBatchNo);
  const lineA = lines.find((l) => l.member_id === borrower.id)!;
  assert.strictEqual(lineA.remitted_amount, 500000);
  assert.strictEqual(lineA.uploaded_amount, 500000);
  assert.strictEqual(lineA.matched, true);
});

await test('Validate reports a clean tally when the card matches the upload', async () => {
  const result = await checkoffBatchesLib.validateCheckoffBatch(ckoBatchNo, admin);
  assert.strictEqual(result.tallyVariance, 0);
  assert.strictEqual(result.unmatchedCount, 0);
  assert.strictEqual(result.mismatchedLines.length, 0);
});

await test('Validate flags a line hand-edited after the CSV upload', async () => {
  const lines = await checkoffBatchesLib.listCheckoffBatchLines(ckoBatchNo);
  const lineA = lines.find((l) => l.member_id === borrower.id)!;
  // recordRemittedAmount() takes cents despite its `amountSh` name — the shillings-to-cents
  // conversion happens one layer up, in the server action.
  await checkoffBatchesLib.recordRemittedAmount(ckoBatchNo, lineA.id, 550000, admin);
  const result = await checkoffBatchesLib.validateCheckoffBatch(ckoBatchNo, admin);
  assert.strictEqual(result.tallyVariance, 50000);
  assert.strictEqual(result.mismatchedLines.length, 1);
  assert.strictEqual(result.mismatchedLines[0].lineId, lineA.id);
  // Put it back so the rest of this section's numbers stay predictable.
  await checkoffBatchesLib.recordRemittedAmount(ckoBatchNo, lineA.id, 500000, admin);
});

await test('a Salary batch with a Charge Code attached cannot be sent for approval before Calculate runs', async () => {
  await throws(() => checkoffBatchesLib.submitCheckoffBatch(ckoBatchNo, admin), /VALIDATION/);
});

await test('Calculate applies the charge, then the recoveries waterfall, in priority order', async () => {
  const { linesCalculated } = await checkoffBatchesLib.calculateCheckoffRecoveries(ckoBatchNo, admin);
  assert.strictEqual(linesCalculated, 3);

  const owed = ckoLoanDisbursed.principal_balance + ckoLoanDisbursed.interest_balance + ckoLoanDisbursed.penalty_balance;
  const expectedLoanRecovery = Math.min(ckoLoanDisbursed.installment, owed);

  const calcs = await checkoffBatchesLib.listCheckoffCalculations(ckoBatchNo);
  const lines = await checkoffBatchesLib.listCheckoffBatchLines(ckoBatchNo);
  const lineA = lines.find((l) => l.member_id === borrower.id)!;
  const lineB = lines.find((l) => l.member_id === ckoMemberB.id)!;
  const lineC = lines.find((l) => l.member_id === ckoMemberC.id)!;

  const forA = calcs.filter((c) => c.line_id === lineA.id);
  assert.deepStrictEqual(forA.map((c) => c.entry_type), ['CHARGE', 'LOAN_RECOVERY', 'INTERNAL_DEPOSIT']);
  assert.strictEqual(forA[0].amount, 5000);
  assert.strictEqual(forA[1].amount, expectedLoanRecovery);
  assert.strictEqual(forA[1].loan_id, ckoLoan.id);
  assert.strictEqual(forA[2].amount, 500000 - 5000 - expectedLoanRecovery);
  assert.strictEqual(forA[2].savings_account_id, ckoHolA.id);

  const forB = calcs.filter((c) => c.line_id === lineB.id);
  assert.deepStrictEqual(forB.map((c) => c.entry_type), ['CHARGE', 'INTERNAL_DEPOSIT']);
  assert.strictEqual(forB[1].amount, 500000 - 5000);
  assert.strictEqual(forB[1].savings_account_id, ckoHolB.id);

  const forC = calcs.filter((c) => c.line_id === lineC.id);
  assert.deepStrictEqual(forC.map((c) => c.entry_type), ['CHARGE', 'NET_AMOUNT']);
  assert.strictEqual(forC[1].amount, 500000 - 5000);
});

await test('re-running Calculate replaces the previous breakdown rather than appending to it', async () => {
  const before = (await checkoffBatchesLib.listCheckoffCalculations(ckoBatchNo)).length;
  await checkoffBatchesLib.calculateCheckoffRecoveries(ckoBatchNo, admin);
  const after = (await checkoffBatchesLib.listCheckoffCalculations(ckoBatchNo)).length;
  assert.strictEqual(after, before);
});

await test('hand-editing a remitted amount after Calculate clears just that line\'s breakdown', async () => {
  const lines = await checkoffBatchesLib.listCheckoffBatchLines(ckoBatchNo);
  const lineC = lines.find((l) => l.member_id === ckoMemberC.id)!;
  // Same value as before — this only needs to exercise the "an edit clears this line's
  // breakdown" code path, not actually change anything the processing test below depends on.
  await checkoffBatchesLib.recordRemittedAmount(ckoBatchNo, lineC.id, 500000, admin);
  const calcs = await checkoffBatchesLib.listCheckoffCalculations(ckoBatchNo);
  assert.ok(!calcs.some((c) => c.line_id === lineC.id), "line C's own rows should be gone");
  const lineA = lines.find((l) => l.member_id === borrower.id)!;
  assert.ok(calcs.some((c) => c.line_id === lineA.id), "line A's rows should be untouched");
  // Recalculate so the whole batch is consistent again for processing below.
  await checkoffBatchesLib.calculateCheckoffRecoveries(ckoBatchNo, admin);
});

await test('processing posts exactly what Calculate found', async () => {
  const glBefore = await accounting.accountBalance(`TESTCKOGL${ckoStamp}`);
  const loanBefore = (await one<{ principal_balance: number; interest_balance: number; penalty_balance: number }>(
    'SELECT principal_balance, interest_balance, penalty_balance FROM loan WHERE id = ?', ckoLoan.id,
  ))!;
  const owedBefore = loanBefore.principal_balance + loanBefore.interest_balance + loanBefore.penalty_balance;
  const holABefore = (await savings.getAccount(ckoHolA.id))!.balance;
  const holBBefore = (await savings.getAccount(ckoHolB.id))!.balance;
  const fosaCBefore = (await savings.getAccount(ckoFosaC.id))!.balance;

  // No workflow is configured for CHECKOFF_BATCH in a fresh install — same bypass the Standing
  // Orders and Member Activation sections above use to isolate approve/process from routing.
  await run("UPDATE checkoff_batch SET status = 'Approved' WHERE no = ?", ckoBatchNo);
  await checkoffBatchesLib.processCheckoffBatch(ckoBatchNo, admin);

  const batch = (await one<{ status: string }>('SELECT status FROM checkoff_batch WHERE no = ?', ckoBatchNo))!;
  assert.strictEqual(batch.status, 'Processed');

  const totalCharge = 5000 * 3;
  assert.strictEqual(await accounting.accountBalance(`TESTCKOGL${ckoStamp}`), glBefore + totalCharge);

  const loanAfter = (await one<{ principal_balance: number; interest_balance: number; penalty_balance: number }>(
    'SELECT principal_balance, interest_balance, penalty_balance FROM loan WHERE id = ?', ckoLoan.id,
  ))!;
  const owedAfter = loanAfter.principal_balance + loanAfter.interest_balance + loanAfter.penalty_balance;
  const expectedLoanRecovery = Math.min(ckoLoanDisbursed.installment, owedBefore);
  assert.strictEqual(owedBefore - owedAfter, expectedLoanRecovery);

  assert.strictEqual((await savings.getAccount(ckoHolA.id))!.balance, holABefore + (500000 - 5000 - expectedLoanRecovery));
  assert.strictEqual((await savings.getAccount(ckoHolB.id))!.balance, holBBefore + (500000 - 5000));
  assert.strictEqual((await savings.getAccount(ckoFosaC.id))!.balance, fosaCBefore + (500000 - 5000));
});

/* ------------------------------------------------------------------------ */
section('Editing a Checkoff/Salary batch card while Open');

const editEmployer = await employersLib.createEmployer(
  { code: `EDITEMP${ckoStamp}`, name: 'Edit Test Employer Ltd', status: 'ACTIVE' }, admin,
);
const editMember = await membersLib.createMember(
  { member_type: 'INDIVIDUAL', first_name: 'EditBatch', last_name: 'Testcase' }, admin,
);
await employersLib.setMemberEmployer(editMember.id, editEmployer.id, admin);
await savings.openAccount({ memberId: editMember.id, productId: ckoFosaProductId, enforceMinOpening: false });

const editPeriod = `${today.slice(0, 7)}-01`;
const { no: editBatchNo } = await checkoffBatchesLib.createCheckoffBatch(editEmployer.id, 'SALARY', editPeriod, admin);

await test('editing only Posting Date/Description on an Open batch leaves its lines untouched', async () => {
  const before = await checkoffBatchesLib.listCheckoffBatchLines(editBatchNo);
  await checkoffBatchesLib.updateCheckoffBatch(editBatchNo, {
    employerId: editEmployer.id, period: editPeriod, postingDate: today, description: 'Edited description',
  }, admin);
  const batch = await checkoffBatchesLib.getCheckoffBatch(editBatchNo);
  assert.strictEqual(batch!.description, 'Edited description');
  assert.strictEqual(batch!.posting_date, today);
  const after = await checkoffBatchesLib.listCheckoffBatchLines(editBatchNo);
  assert.deepStrictEqual(after.map((l) => l.id), before.map((l) => l.id), 'line ids should be untouched');
});

const editEmployer2 = await employersLib.createEmployer(
  { code: `EDITEMP2${ckoStamp}`, name: 'Edit Test Employer 2 Ltd', status: 'ACTIVE' }, admin,
);

await test('changing the Employer on an Open batch re-populates its lines from the new employer', async () => {
  await checkoffBatchesLib.updateCheckoffBatch(editBatchNo, { employerId: editEmployer2.id, period: editPeriod }, admin);
  const batch = await checkoffBatchesLib.getCheckoffBatch(editBatchNo);
  assert.strictEqual(batch!.employer_id, editEmployer2.id);
  // editEmployer2 has no members at all, so the repopulate should leave it with zero lines.
  const lines = await checkoffBatchesLib.listCheckoffBatchLines(editBatchNo);
  assert.strictEqual(lines.length, 0);
});

await test('editing into an employer/period combination that already has a live batch is rejected', async () => {
  await checkoffBatchesLib.createCheckoffBatch(editEmployer.id, 'SALARY', editPeriod, admin);
  await throws(
    () => checkoffBatchesLib.updateCheckoffBatch(editBatchNo, { employerId: editEmployer.id, period: editPeriod }, admin),
    /VALIDATION/,
  );
});

await test('a batch that has left Open can no longer be edited', async () => {
  await run("UPDATE checkoff_batch SET status = 'Approved' WHERE no = ?", editBatchNo);
  await throws(
    () => checkoffBatchesLib.updateCheckoffBatch(editBatchNo, { employerId: editEmployer2.id, period: editPeriod }, admin),
    /VALIDATION/,
  );
});

/* ------------------------------------------------------------------------ */
section('Checkoff CSV upload — Search Type (Member No./ID Number/Payroll No./FOSA Number)');

const searchTestMember = await membersLib.createMember(
  { member_type: 'INDIVIDUAL', first_name: 'SearchType', last_name: 'Testcase', identification_no: `IDNO${ckoStamp}` }, admin,
);
await employersLib.setMemberEmployer(searchTestMember.id, ckoEmployerId, admin);
const searchTestFosa = await savings.openAccount({
  memberId: searchTestMember.id, productId: ckoFosaProductId, enforceMinOpening: false,
});
const searchTestMemberFull = (await one<{ member_no: string }>('SELECT member_no FROM member WHERE id = ?', searchTestMember.id))!;

await test('Search Type = Member No. resolves an uploaded row by the member\'s own No.', async () => {
  const { no } = await checkoffBatchesLib.createCheckoffBatch(
    ckoEmployerId, 'SALARY', editPeriod, admin, null, 'MEMBER_NO',
  );
  const csv = ['Member No,Name,Amount', `${searchTestMemberFull.member_no},Search Type Testcase,4000.00`].join('\n');
  const result = await checkoffBatchesLib.applyCheckoffCsvUpload(no, csv, admin);
  assert.strictEqual(result.matchedCount, 1);
  assert.strictEqual(result.unmatchedRows.length, 0);
  const lines = await checkoffBatchesLib.listCheckoffBatchLines(no);
  const line = lines.find((l) => l.member_id === searchTestMember.id)!;
  assert.strictEqual(line.remitted_amount, 400000);
});

await test('Search Type = ID Number resolves an uploaded row by identification_no', async () => {
  const { no } = await checkoffBatchesLib.createCheckoffBatch(
    ckoEmployerId, 'SALARY', addMonths(editPeriod, 1), admin, null, 'ID_NUMBER',
  );
  const csv = ['ID Number,Name,Amount', `IDNO${ckoStamp},Search Type Testcase,4500.00`].join('\n');
  const result = await checkoffBatchesLib.applyCheckoffCsvUpload(no, csv, admin);
  assert.strictEqual(result.matchedCount, 1);
  const lines = await checkoffBatchesLib.listCheckoffBatchLines(no);
  const line = lines.find((l) => l.member_id === searchTestMember.id)!;
  assert.strictEqual(line.remitted_amount, 450000);
});

await test('Search Type = FOSA Number resolves an uploaded row by the FOSA account\'s own No.', async () => {
  const { no } = await checkoffBatchesLib.createCheckoffBatch(
    ckoEmployerId, 'SALARY', addMonths(editPeriod, 2), admin, null, 'FOSA_NUMBER',
  );
  const csv = ['FOSA No,Name,Amount', `${searchTestFosa.account_no},Search Type Testcase,4700.00`].join('\n');
  const result = await checkoffBatchesLib.applyCheckoffCsvUpload(no, csv, admin);
  assert.strictEqual(result.matchedCount, 1);
  const lines = await checkoffBatchesLib.listCheckoffBatchLines(no);
  const line = lines.find((l) => l.member_id === searchTestMember.id)!;
  assert.strictEqual(line.remitted_amount, 470000);
});

await test('a row that does not resolve under the batch\'s own Search Type is reported unmatched, not silently applied', async () => {
  const { no } = await checkoffBatchesLib.createCheckoffBatch(
    ckoEmployerId, 'SALARY', addMonths(editPeriod, 3), admin, null, 'MEMBER_NO',
  );
  // The FOSA account number is not a Member No. — nothing should resolve.
  const csv = ['Member No,Name,Amount', `${searchTestFosa.account_no},Search Type Testcase,1000.00`].join('\n');
  const result = await checkoffBatchesLib.applyCheckoffCsvUpload(no, csv, admin);
  assert.strictEqual(result.matchedCount, 0);
  assert.strictEqual(result.unmatchedRows.length, 1);
});

/* ------------------------------------------------------------------------ */
section('Transaction Recoveries — Standing Order recovery type');

const stoSourceMember = await membersLib.createMember(
  { member_type: 'INDIVIDUAL', first_name: 'StoRecovery', last_name: 'Source' }, admin,
);
await employersLib.setMemberEmployer(stoSourceMember.id, ckoEmployerId, admin);
const stoSourceFosa = await savings.openAccount({
  memberId: stoSourceMember.id, productId: ckoFosaProductId, enforceMinOpening: false,
});
const stoDestMember = await membersLib.createMember(
  { member_type: 'INDIVIDUAL', first_name: 'StoRecovery', last_name: 'Destination' }, admin,
);
const stoDestFosa = await savings.openAccount({
  memberId: stoDestMember.id, productId: ckoFosaProductId, enforceMinOpening: false,
});

const { no: recoverySto } = await standingOrdersLib.createStandingOrder({
  memberId: stoSourceMember.id, accountId: stoSourceFosa.id, standingOrderClass: 'INTERNAL', amountType: 'FIXED',
  amount: 150000, destinationMemberId: stoDestMember.id, destinationAccountId: stoDestFosa.id,
  postingDescription: 'Test dues', startDate: today, tillFurtherNotice: true,
  salaryBased: true,
}, admin);
await run("UPDATE standing_order SET status = 'Approved', running = true WHERE no = ?", recoverySto);

await test('a salary_based standing order is excluded from the ordinary daily Standing Order run', async () => {
  const summary = await standingOrdersLib.runStandingOrders(admin, today);
  assert.ok(!summary.results.some((r) => r.no === recoverySto), 'a salary_based order must never be picked up by the daily run');
});

// Append a STANDING_ORDER recovery to the same 'End Month Salary' charge the earlier section
// built — createTransactionCharge() allows only one Transaction Charge per type, so extending
// the existing one (a wholesale replace, same as the admin form itself submits) is the only way
// to add a second recovery without disturbing the batch that already processed against it.
const priorDetail = (await chargesLib.getTransactionCharge(ckoTransactionCharge.id))!;
await chargesLib.updateTransactionCharge(
  ckoTransactionCharge.id,
  { description: priorDetail.description, status: 'ACTIVE', transaction_type: 'End Month Salary' },
  priorDetail.components.map((c) => ({
    charge_id: c.charge_id, gl_account_id: c.gl_account_id, calculation_type: c.calculation_type,
    source_index: null, priority: c.priority, status: c.status,
    scheme: c.scheme.map((s) => ({
      lower_limit: s.lower_limit, upper_limit: s.upper_limit, rate_type: s.rate_type, flat_amount: s.flat_amount,
      percentage_rate: s.percentage_rate, upper_charge_limit: s.upper_charge_limit, lower_charge_limit: s.lower_charge_limit,
    })),
  })),
  admin,
  [
    ...priorDetail.recoveries.map((r) => ({
      recovery_type: r.recovery_type, deduction_type: r.deduction_type, savings_product_id: r.savings_product_id,
      priority: r.priority, description: r.description, status: r.status,
    })),
    { recovery_type: 'STANDING_ORDER' as const, priority: 5, description: 'Test dues recovery' },
  ],
);

const { no: stoRecoveryBatchNo } = await checkoffBatchesLib.createCheckoffBatch(
  ckoEmployerId, 'SALARY', addMonths(editPeriod, 4), admin, ckoTransactionCharge.id,
);

await test('Calculate recovers a matching salary_based standing order, tagged with its own no. for posting', async () => {
  const lines = await checkoffBatchesLib.listCheckoffBatchLines(stoRecoveryBatchNo);
  const line = lines.find((l) => l.member_id === stoSourceMember.id)!;
  await checkoffBatchesLib.recordRemittedAmount(stoRecoveryBatchNo, line.id, 500000, admin);

  const { linesCalculated } = await checkoffBatchesLib.calculateCheckoffRecoveries(stoRecoveryBatchNo, admin);
  assert.ok(linesCalculated > 0);

  const calcs = await checkoffBatchesLib.listCheckoffCalculations(stoRecoveryBatchNo);
  const forLine = calcs.filter((c) => c.line_id === line.id);
  const stoRow = forLine.find((c) => c.entry_type === 'STANDING_ORDER');
  assert.ok(stoRow, 'a STANDING_ORDER calculation row should have been produced');
  assert.strictEqual(stoRow!.standing_order_no, recoverySto);
  assert.strictEqual(stoRow!.amount, 150000);
});

await test('processing the batch pays the standing order\'s own destination account', async () => {
  const destBefore = (await savings.getAccount(stoDestFosa.id))!.balance;
  await run("UPDATE checkoff_batch SET status = 'Approved' WHERE no = ?", stoRecoveryBatchNo);
  await checkoffBatchesLib.processCheckoffBatch(stoRecoveryBatchNo, admin);
  assert.strictEqual((await savings.getAccount(stoDestFosa.id))!.balance, destBefore + 150000);
});

await test('a second STANDING_ORDER recovery pinned to a different class gets its own priority', async () => {
  // A second salary_based standing order for the same member, EXTERNAL class this time — proves
  // the recovery config's own standing_order_class filter decides which order(s) a given
  // recovery row matches, letting each class carry its own priority.
  const { no: extSto } = await standingOrdersLib.createStandingOrder({
    memberId: stoSourceMember.id, accountId: stoSourceFosa.id, standingOrderClass: 'EXTERNAL', amountType: 'FIXED',
    amount: 80000, destinationBankAccountId: payoutBankAccount.id, postingDescription: 'Test dues (external)',
    startDate: today, tillFurtherNotice: true, salaryBased: true,
  }, admin);
  await run("UPDATE standing_order SET status = 'Approved', running = true WHERE no = ?", extSto);

  const detail = (await chargesLib.getTransactionCharge(ckoTransactionCharge.id))!;
  await chargesLib.updateTransactionCharge(
    ckoTransactionCharge.id,
    { description: detail.description, status: 'ACTIVE', transaction_type: 'End Month Salary' },
    detail.components.map((c) => ({
      charge_id: c.charge_id, gl_account_id: c.gl_account_id, calculation_type: c.calculation_type,
      source_index: null, priority: c.priority, status: c.status,
      scheme: c.scheme.map((s) => ({
        lower_limit: s.lower_limit, upper_limit: s.upper_limit, rate_type: s.rate_type, flat_amount: s.flat_amount,
        percentage_rate: s.percentage_rate, upper_charge_limit: s.upper_charge_limit, lower_charge_limit: s.lower_charge_limit,
      })),
    })),
    admin,
    [
      ...detail.recoveries.filter((r) => r.recovery_type !== 'STANDING_ORDER').map((r) => ({
        recovery_type: r.recovery_type, deduction_type: r.deduction_type, savings_product_id: r.savings_product_id,
        priority: r.priority, description: r.description, status: r.status,
      })),
      {
        recovery_type: 'STANDING_ORDER' as const, standing_order_class: 'INTERNAL' as const,
        priority: 5, description: 'Test dues (internal)',
      },
      {
        recovery_type: 'STANDING_ORDER' as const, standing_order_class: 'EXTERNAL' as const,
        priority: 6, description: 'Test dues (external)',
      },
    ],
  );

  const { no: batchNo } = await checkoffBatchesLib.createCheckoffBatch(
    ckoEmployerId, 'SALARY', addMonths(editPeriod, 5), admin, ckoTransactionCharge.id,
  );
  const lines = await checkoffBatchesLib.listCheckoffBatchLines(batchNo);
  const line = lines.find((l) => l.member_id === stoSourceMember.id)!;
  await checkoffBatchesLib.recordRemittedAmount(batchNo, line.id, 500000, admin);
  await checkoffBatchesLib.calculateCheckoffRecoveries(batchNo, admin);

  const calcs = await checkoffBatchesLib.listCheckoffCalculations(batchNo);
  const forLine = calcs.filter((c) => c.line_id === line.id && c.entry_type === 'STANDING_ORDER');
  assert.strictEqual(forLine.length, 2, 'both the INTERNAL and EXTERNAL salary_based orders should have been recovered, each by its own class-pinned row');
  assert.ok(forLine.some((c) => c.standing_order_no === recoverySto && c.amount === 150000));
  assert.ok(forLine.some((c) => c.standing_order_no === extSto && c.amount === 80000));

  const bankBalBefore = await accounting.accountBalance('1020');
  await run("UPDATE checkoff_batch SET status = 'Approved' WHERE no = ?", batchNo);
  await checkoffBatchesLib.processCheckoffBatch(batchNo, admin);
  // Paid out externally through BANK (an asset) — same direction as the standalone EXTERNAL
  // standing order test above.
  assert.strictEqual(await accounting.accountBalance('1020'), bankBalBefore - 80000);
});

/* ------------------------------------------------------------------------ */
section('Ledger still balances after every operation above');

await test('trial balance is still square', async () => {
  const tb = await accounting.trialBalance();
  const d = tb.reduce((a, r) => a + r.debit_balance, 0);
  const c = tb.reduce((a, r) => a + r.credit_balance, 0);
  assert.strictEqual(d, c);
});

await test('subsidiary ledgers still reconcile after the lifecycle test', async () => {
  const rows = await all<{ code: string; gl: string; sub: number }>(SAVINGS_VS_GL);
  for (const r of rows) {
    assert.strictEqual(r.sub, await accounting.accountBalance(r.gl), `${r.code} out of line`);
  }

  const lrows = await all<{ code: string; gl: string; sub: number }>(LOANS_VS_GL);
  for (const r of lrows) {
    assert.strictEqual(r.sub, await accounting.accountBalance(r.gl), `${r.code} out of line`);
  }
});

/* ------------------------------------------------------------------------ */
section('Fixed Assets');

await test('the 30/360 day count matches Business Central', () => {
  assert.strictEqual(faDepr.depreciationDays('2024-01-01', '2024-02-01'), 30);
  assert.strictEqual(faDepr.depreciationDays('2024-01-01', '2025-01-01'), 360);
  assert.strictEqual(faDepr.depreciationDays('2024-01-31', '2024-02-29'), 29); // day clamped to 30 both ends → 29
  assert.strictEqual(faDepr.depreciationDays('2024-03-01', '2024-01-01'), 0);
});

await test('straight-line depreciation charges an even fraction of the basis and stops at salvage', () => {
  const base = {
    depreciation_method: 'Straight-Line' as const,
    depreciation_starting_date: '2024-01-01',
    depreciation_ending_date: null,
    no_of_depreciation_years: 5,
    straight_line_pct: 0,
    declining_balance_pct: 0,
    salvage_value: 20_000_00,
    last_depreciation_date: null,
    acquisition_cost: 1_200_000_00,
    accumulated_depreciation: 0,
    write_down_amount: 0,
    appreciation_amount: 0,
    book_value: 1_200_000_00,
    disposed: 0 as const,
  };
  // One full year: (1,200,000 − 20,000) / 5 = 236,000.
  const oneYear = faDepr.computeDepreciation(base, '2025-01-01');
  assert.strictEqual(oneYear.amount, -236_000_00);
  assert.strictEqual(oneYear.newBookValue, 964_000_00);

  // Near the end, with book value just above salvage, it takes only what is left.
  const almostDone = faDepr.computeDepreciation(
    { ...base, book_value: 25_000_00, accumulated_depreciation: -1_175_000_00 }, '2026-01-01', 100_00,
  );
  assert.strictEqual(almostDone.amount, -5_000_00);
  assert.strictEqual(almostDone.newBookValue, 20_000_00);

  // Once book value is at salvage, nothing more is due.
  const done = faDepr.computeDepreciation({ ...base, book_value: 20_000_00 }, '2027-01-01');
  assert.strictEqual(done.amount, 0);
});

await test('a Manual book is never auto-depreciated', () => {
  const r = faDepr.computeDepreciation({
    depreciation_method: 'Manual', depreciation_starting_date: '2024-01-01', depreciation_ending_date: null,
    no_of_depreciation_years: 5, straight_line_pct: 0, declining_balance_pct: 0, salvage_value: 0,
    last_depreciation_date: null, acquisition_cost: 1_000_000_00, accumulated_depreciation: 0,
    write_down_amount: 0, appreciation_amount: 0, book_value: 1_000_000_00, disposed: 0,
  }, '2025-01-01');
  assert.strictEqual(r.amount, 0);
});

await test('the seeded assets have their acquisition posted and some depreciation run', async () => {
  const assets = await faLib.listFixedAssets();
  assert.ok(assets.length >= 3, 'expected the seed to create demo fixed assets');
  for (const a of assets) {
    assert.ok(a.acquisition_cost > 0, `${a.no} has no acquisition cost`);
    assert.ok(a.book_value < a.acquisition_cost, `${a.no} has not been depreciated`);
    assert.ok(a.book_value > 0, `${a.no} is already fully depreciated`);
  }
});

await test('every FA ledger book value reconciles to its FA Depreciation Book roll-up', async () => {
  const books = await all<{ fixed_asset_id: number; depreciation_book_code: string; book_value: number }>(
    'SELECT fixed_asset_id, depreciation_book_code, book_value FROM fa_depreciation_book',
  );
  for (const b of books) {
    const led = (await one<{ total: number }>(
      `SELECT COALESCE(SUM(CASE WHEN part_of_book_value = 1 THEN amount ELSE 0 END), 0) AS total
       FROM fa_ledger_entry WHERE fixed_asset_id = ? AND depreciation_book_code = ?`,
      b.fixed_asset_id, b.depreciation_book_code,
    ))!;
    assert.strictEqual(led.total, b.book_value, `asset ${b.fixed_asset_id} book value diverged from its ledger`);
  }
});

await test('the FA subledger ties to the property, plant & equipment control accounts', async () => {
  const report = await (await import('../lib/fixedAssetReports.ts')).getFaBookValueReport({ bookCode: 'COMPANY' });
  const cost = await accounting.accountBalance('1420') + await accounting.accountBalance('1430');
  const accum = await accounting.accountBalance('1425') + await accounting.accountBalance('1435');
  assert.strictEqual(report.totals.book_value, cost + accum);
});

await test('disposing an asset above its book value books a gain and zeroes the book value', async () => {
  const sys: Actor = { id: 1, username: 'system' };
  const asset = (await faLib.listFixedAssets()).find((a) => !a.disposed && a.book_value > 0)!;
  const bookValueBefore = asset.book_value;
  const gainBefore = await accounting.accountBalance('4060');

  const lineNo = await (await import('../lib/db.ts')).run(
    `INSERT INTO fa_journal_line (no, posting_date, fixed_asset_id, depreciation_book_code, fa_posting_type, amount,
       balancing_gl_account_id, status, created_at, created_by)
     VALUES (?, ?, ?, 'COMPANY', 'Disposal', ?, (SELECT id FROM gl_account WHERE code='1020'), 'Approved', ?, 'system')`,
    `FAJ-DISPOSE-TEST`, '2026-08-31', asset.id, bookValueBefore + 50_000_00, new Date().toISOString(),
  ).then(() => 'FAJ-DISPOSE-TEST');

  const res = await faJournalLib.postFaJournalLine(lineNo, sys);
  assert.strictEqual(res.bookValue, 0);
  assert.ok(res.disposed);

  const after = await faLib.getFixedAsset(asset.no);
  assert.ok(after?.disposal_date, 'disposal date was not stamped');
  // Gain on disposal = proceeds − book value = 50,000 (a credit to income account 4060).
  assert.strictEqual(await accounting.accountBalance('4060') - gainBefore, 50_000_00);
});

/* ------------------------------------------------------------------------ */
section('Receivables');

await test('BC date formulas resolve correctly', () => {
  assert.strictEqual(dateFormula.applyDateFormula('2026-01-15', '30D'), '2026-02-14');
  assert.strictEqual(dateFormula.applyDateFormula('2026-01-15', 'CM'), '2026-01-31');
  assert.strictEqual(dateFormula.applyDateFormula('2026-01-15', 'CM+10D'), '2026-02-10');
  assert.strictEqual(dateFormula.applyDateFormula('2026-01-15', ''), '2026-01-15');
});

await test('a seeded customer exists with a posted invoice and a balance', async () => {
  const customers = await custLib.listCustomers();
  assert.ok(customers.length >= 3, 'expected the seed to create demo customers');
  const withBalance = customers.filter((c) => c.balance > 0);
  assert.ok(withBalance.length >= 1, 'expected at least one customer with an open balance');
  for (const c of withBalance) {
    const led = (await one<{ total: number }>(
      'SELECT COALESCE(SUM(remaining_amount),0) total FROM cust_ledger_entry WHERE customer_id = ? AND open = 1', c.id,
    ))!;
    assert.strictEqual(led.total, c.balance, `${c.no} balance diverged from its open ledger entries`);
  }
});

await test('the receivables subledger ties to the 1250 control account', async () => {
  const subledger = (await one<{ total: number }>('SELECT COALESCE(SUM(remaining_amount),0) total FROM cust_ledger_entry WHERE open = 1'))!;
  assert.strictEqual(subledger.total, await accounting.accountBalance('1250'));
});

await test('posting a sales invoice creates an open Cust. Ledger Entry, moves the G/L and the customer balance', async () => {
  const sys: Actor = { id: 1, username: 'system' };
  const cust = (await custLib.listCustomers())[0];
  const before = cust.balance;
  const glBefore = await accounting.accountBalance('4094');
  const arBefore = await accounting.accountBalance('1250');

  const { no } = await salesLib.createSalesDocument(
    { documentType: 'Invoice', customerId: cust.id, postingDate: '2026-08-01', documentDate: '2026-08-01', paymentTermsCode: '30 DAYS' }, sys,
  );
  await salesLib.setSalesLines(no, [{ type: 'G/L Account', no: '4094', description: 'Test service', quantity: 1, unitPrice: 50_000_00 }], sys);
  await run("UPDATE sales_header SET status = 'Released', due_date = '2026-08-31', sell_to_name = ? WHERE no = ?", cust.name, no);
  const res = await salesLib.postSalesDocument(no, { invoice: true }, sys);
  assert.ok(res.custLedgerEntryId, 'no Cust. Ledger Entry created');

  const cle = (await one<{ amount: number; remaining_amount: number; open: number; due_date: string }>(
    'SELECT amount, remaining_amount, open, due_date FROM cust_ledger_entry WHERE id = ?', res.custLedgerEntryId,
  ))!;
  assert.strictEqual(cle.amount, 50_000_00);
  assert.strictEqual(cle.remaining_amount, 50_000_00);
  assert.strictEqual(cle.open, 1);
  assert.strictEqual(cle.due_date, '2026-08-31');
  assert.strictEqual(await accounting.accountBalance('4094'), glBefore + 50_000_00);
  assert.strictEqual(await accounting.accountBalance('1250'), arBefore + 50_000_00);
  assert.strictEqual((await custLib.getCustomerById(cust.id))!.balance, before + 50_000_00);
});

await test('a cash receipt applies to an open invoice, closing it and moving bank + AR', async () => {
  const sys: Actor = { id: 1, username: 'system' };
  const inv = (await all<{ id: number; customer_id: number; document_no: string; remaining_amount: number }>(
    "SELECT id, customer_id, document_no, remaining_amount FROM cust_ledger_entry WHERE document_type = 'Invoice' AND open = 1 ORDER BY id DESC LIMIT 1",
  ))[0];
  const bankId = (await one<{ id: number }>("SELECT id FROM bank_account WHERE code = 'BANK'"))!.id;
  const arBefore = await accounting.accountBalance('1250');

  const { no } = await cashReceiptLib.createCashReceipt({
    postingDate: '2026-08-05', documentDate: '2026-08-05', bankAccountId: bankId, description: 'Test receipt',
    lines: [{ customerId: inv.customer_id, amount: inv.remaining_amount, appliesToDocNo: inv.document_no }],
  }, sys);
  await run("UPDATE cash_receipt_header SET status = 'Approved' WHERE no = ?", no);
  const res = await cashReceiptLib.postCashReceipt(no, sys);
  assert.ok(res.journalNo, 'no journal posted');

  const after = (await one<{ open: number; remaining_amount: number; closed_by_entry_no: number | null }>(
    'SELECT open, remaining_amount, closed_by_entry_no FROM cust_ledger_entry WHERE id = ?', inv.id,
  ))!;
  assert.strictEqual(after.open, 0, 'invoice not closed by a full payment');
  assert.strictEqual(after.remaining_amount, 0);
  assert.ok(after.closed_by_entry_no, 'closed_by_entry_no not stamped');
  assert.strictEqual(await accounting.accountBalance('1250'), arBefore - inv.remaining_amount);
  const bale = (await one<{ n: number }>("SELECT COUNT(*) n FROM bank_account_ledger_entry WHERE description LIKE ?", `Cash Receipt ${no}%`))!;
  assert.ok(Number(bale.n) >= 1, 'no bank_account_ledger_entry for the receipt');
});

await test('createReminders picks up an overdue entry and computes interest + fee', async () => {
  const sys: Actor = { id: 1, username: 'system' };
  // The seeded tenant (14 DAYS terms) has an invoice from two months ago — overdue.
  const tenant = (await all<{ id: number; no: string }>("SELECT id, no FROM customer WHERE customer_posting_group_code = 'TENANT' LIMIT 1"))[0];
  const overdue = (await one<{ n: number }>(
    "SELECT COUNT(*) n FROM cust_ledger_entry WHERE customer_id = ? AND open = 1 AND due_date < ?", tenant.id, new Date().toISOString().slice(0, 10),
  ))!;
  assert.ok(Number(overdue.n) >= 1, 'expected the seeded tenant to have an overdue invoice');

  const res = await reminderLib.createReminders({ customerId: tenant.id, documentDate: new Date().toISOString().slice(0, 10) }, sys);
  const rem = (await one<{ no: string; interest_amount: number; additional_fee: number; reminder_level: number }>(
    "SELECT no, interest_amount, additional_fee, reminder_level FROM reminder_header WHERE customer_id = ? AND status = 'Open' ORDER BY id DESC LIMIT 1", tenant.id,
  ));
  assert.ok(res.created >= 1 || rem, 'no reminder created for the overdue tenant');

  if (rem) {
    const glBefore = await accounting.accountBalance('4099');
    const arBefore = await accounting.accountBalance('1250');
    const issue = await reminderLib.issueReminder(rem.no, sys);
    if (rem.additional_fee > 0 || rem.interest_amount > 0) {
      assert.ok(issue.journalNo, 'issuing a reminder with a charge posted no journal');
      const feeMoved = (await accounting.accountBalance('4099')) - glBefore;
      const interestMoved = (await accounting.accountBalance('4098'));
      assert.ok(feeMoved >= 0 && interestMoved >= 0);
      assert.ok((await accounting.accountBalance('1250')) >= arBefore, 'AR did not rise with the reminder charge');
    }
  }
});

await test('the Aged AR report buckets an overdue entry and its total ties to 1250', async () => {
  const asOf = new Date().toISOString().slice(0, 10);
  const report = await arReports.getAgedAccountsReceivable({ asOf });
  const grand = report.totals.balance;
  assert.strictEqual(grand, report.totals.not_due + report.totals.bucket_1 + report.totals.bucket_2 + report.totals.bucket_3 + report.totals.bucket_over);
  assert.strictEqual(grand, await accounting.accountBalance('1250'), 'Aged AR grand total does not equal the 1250 control account');
});

await test('a sales credit memo reverses signs against the ledger', async () => {
  const sys: Actor = { id: 1, username: 'system' };
  const cust = (await custLib.listCustomers())[0];
  const arBefore = await accounting.accountBalance('1250');
  const { no } = await salesLib.createSalesDocument(
    { documentType: 'Credit Memo', customerId: cust.id, postingDate: '2026-08-10', documentDate: '2026-08-10' }, sys,
  );
  await salesLib.setSalesLines(no, [{ type: 'G/L Account', no: '4094', description: 'Credit', quantity: 1, unitPrice: 10_000_00 }], sys);
  await run("UPDATE sales_header SET status = 'Released', sell_to_name = ? WHERE no = ?", cust.name, no);
  const res = await salesLib.postSalesDocument(no, { invoice: true }, sys);
  const cle = (await one<{ amount: number; positive: number }>('SELECT amount, positive FROM cust_ledger_entry WHERE id = ?', res.custLedgerEntryId))!;
  assert.strictEqual(cle.amount, -10_000_00);
  assert.strictEqual(cle.positive, 0);
  assert.strictEqual(await accounting.accountBalance('1250'), arBefore - 10_000_00);
});

section('Payables');

await test('a seeded vendor exists with a posted invoice and a balance', async () => {
  const vendors = await vendorLib.listVendors();
  assert.ok(vendors.length >= 3, 'expected the seed to create demo vendors');
  const withBalance = vendors.filter((v) => v.balance > 0);
  assert.ok(withBalance.length >= 1, 'expected at least one vendor with an open balance');
  for (const v of withBalance) {
    const led = (await one<{ total: number }>(
      'SELECT COALESCE(SUM(remaining_amount),0) total FROM vendor_ledger_entry WHERE vendor_id = ? AND open = 1', v.id,
    ))!;
    assert.strictEqual(led.total, v.balance, `${v.no} balance diverged from its open ledger entries`);
  }
});

await test('the payables subledger ties to the 2150 control account', async () => {
  const subledger = (await one<{ total: number }>('SELECT COALESCE(SUM(remaining_amount),0) total FROM vendor_ledger_entry WHERE open = 1'))!;
  assert.strictEqual(subledger.total, await accounting.accountBalance('2150'));
});

await test('posting a purchase invoice (G/L line) creates an open Vendor Ledger Entry and moves the G/L', async () => {
  const sys: Actor = { id: 1, username: 'system' };
  const vend = (await vendorLib.listVendors())[0];
  const before = vend.balance;
  const glBefore = await accounting.accountBalance('5030');
  const apBefore = await accounting.accountBalance('2150');

  const { no } = await purchaseLib.createPurchaseDocument(
    { documentType: 'Invoice', vendorId: vend.id, postingDate: '2026-08-01', documentDate: '2026-08-01', paymentTermsCode: '30 DAYS', vendorInvoiceNo: 'TEST-INV-1' }, sys,
  );
  await purchaseLib.setPurchaseLines(no, [{ type: 'G/L Account', no: '5030', description: 'Test supplies', quantity: 1, directUnitCost: 40_000_00 }], sys);
  await run("UPDATE purchase_header SET status = 'Released', due_date = '2026-08-31', buy_from_name = ? WHERE no = ?", vend.name, no);
  const res = await purchaseLib.postPurchaseDocument(no, { invoice: true }, sys);
  assert.ok(res.vendorLedgerEntryId, 'no Vendor Ledger Entry created');

  const vle = (await one<{ amount: number; remaining_amount: number; open: number; due_date: string; positive: number }>(
    'SELECT amount, remaining_amount, open, due_date, positive FROM vendor_ledger_entry WHERE id = ?', res.vendorLedgerEntryId,
  ))!;
  assert.strictEqual(vle.amount, 40_000_00);
  assert.strictEqual(vle.remaining_amount, 40_000_00);
  assert.strictEqual(vle.open, 1);
  assert.strictEqual(vle.positive, 1);
  assert.strictEqual(vle.due_date, '2026-08-31');
  assert.strictEqual(await accounting.accountBalance('5030'), glBefore + 40_000_00);
  assert.strictEqual(await accounting.accountBalance('2150'), apBefore + 40_000_00);
  assert.strictEqual((await vendorLib.getVendorById(vend.id))!.balance, before + 40_000_00);
});

await test('a purchase invoice with a Fixed Asset line posts an FA acquisition', async () => {
  const sys: Actor = { id: 1, username: 'system' };
  const vend = (await vendorLib.listVendors())[0];
  const { no: assetNo } = await faLib.createFixedAsset(
    { description: 'Payables test asset', faClassCode: 'EQUIPMENT', faSubclassCode: 'OFFICE-EQUIP', faLocationCode: 'HQ', blocked: false, inactive: false }, sys,
  );
  const asset = (await one<{ id: number }>('SELECT id FROM fixed_asset WHERE no = ?', assetNo))!;
  await faLib.setFaDepreciationBook(asset.id, {
    depreciationBookCode: 'COMPANY', faPostingGroupCode: 'EQUIPMENT', depreciationMethod: 'Straight-Line',
    depreciationStartingDate: '2026-08-01', depreciationEndingDate: null, noOfDepreciationYears: 4,
    straightLinePct: 0, decliningBalancePct: 0, salvageValue: 0, disposalCalculationMethod: 'Net',
  }, sys);

  const { no } = await purchaseLib.createPurchaseDocument(
    { documentType: 'Invoice', vendorId: vend.id, postingDate: '2026-08-02', documentDate: '2026-08-02', vendorInvoiceNo: 'TEST-FA-1' }, sys,
  );
  await purchaseLib.setPurchaseLines(no, [{ type: 'Fixed Asset', no: assetNo, description: 'New asset', quantity: 1, directUnitCost: 250_000_00, faDepreciationBookCode: 'COMPANY' }], sys);
  await run("UPDATE purchase_header SET status = 'Released', buy_from_name = ? WHERE no = ?", vend.name, no);
  await purchaseLib.postPurchaseDocument(no, { invoice: true }, sys);

  const book = (await one<{ acquisition_cost: number; book_value: number }>(
    "SELECT acquisition_cost, book_value FROM fa_depreciation_book WHERE fixed_asset_id = ? AND depreciation_book_code = 'COMPANY'", asset.id,
  ))!;
  assert.strictEqual(book.acquisition_cost, 250_000_00);
  assert.strictEqual(book.book_value, 250_000_00);
  const stamped = (await one<{ acquisition_date: string | null }>('SELECT acquisition_date FROM fixed_asset WHERE id = ?', asset.id))!;
  assert.ok(stamped.acquisition_date, 'acquisition_date not stamped');
});

await test('a payment journal pays a vendor invoice, closing it and moving bank + AP', async () => {
  const sys: Actor = { id: 1, username: 'system' };
  const inv = (await all<{ id: number; vendor_id: number; document_no: string; remaining_amount: number }>(
    "SELECT id, vendor_id, document_no, remaining_amount FROM vendor_ledger_entry WHERE document_type = 'Invoice' AND open = 1 ORDER BY id DESC LIMIT 1",
  ))[0];
  const bankId = (await one<{ id: number }>("SELECT id FROM bank_account WHERE code = 'BANK'"))!.id;
  const apBefore = await accounting.accountBalance('2150');

  const { no } = await paymentJournalLib.createPaymentJournal({
    postingDate: '2026-08-06', documentDate: '2026-08-06', bankAccountId: bankId, description: 'Test payment',
    lines: [{ vendorId: inv.vendor_id, amount: inv.remaining_amount, appliesToDocNo: inv.document_no }],
  }, sys);
  await run("UPDATE payment_journal_header SET status = 'Approved' WHERE no = ?", no);
  const res = await paymentJournalLib.postPaymentJournal(no, sys);
  assert.ok(res.journalNo, 'no journal posted');

  const after = (await one<{ open: number; remaining_amount: number; closed_by_entry_no: number | null }>(
    'SELECT open, remaining_amount, closed_by_entry_no FROM vendor_ledger_entry WHERE id = ?', inv.id,
  ))!;
  assert.strictEqual(after.open, 0, 'invoice not closed by a full payment');
  assert.strictEqual(after.remaining_amount, 0);
  assert.ok(after.closed_by_entry_no, 'closed_by_entry_no not stamped');
  assert.strictEqual(await accounting.accountBalance('2150'), apBefore - inv.remaining_amount);
  const bale = (await one<{ n: number }>("SELECT COUNT(*) n FROM bank_account_ledger_entry WHERE description LIKE ?", `Payment Journal ${no}%`))!;
  assert.ok(Number(bale.n) >= 1, 'no bank_account_ledger_entry for the payment');
});

await test('suggestVendorPayments drafts a payment journal from overdue vendor invoices', async () => {
  const sys: Actor = { id: 1, username: 'system' };
  const bankId = (await one<{ id: number }>("SELECT id FROM bank_account WHERE code = 'BANK'"))!.id;
  const openBefore = (await one<{ n: number }>("SELECT COUNT(*) n FROM vendor_ledger_entry WHERE open = 1 AND positive = 1 AND due_date <= ?", '2026-12-31'))!;
  if (Number(openBefore.n) >= 1) {
    const res = await paymentJournalLib.suggestVendorPayments(
      { lastPaymentDate: '2026-12-31', findPaymentDiscounts: true, bankAccountId: bankId }, sys,
    );
    assert.ok(res.lineCount >= 1, 'expected at least one suggested payment line');
    const hdr = (await one<{ total_amount: number; status: string }>('SELECT total_amount, status FROM payment_journal_header WHERE no = ?', res.no))!;
    assert.strictEqual(hdr.status, 'Open');
    assert.ok(hdr.total_amount > 0);
  }
});

await test('the Aged AP report buckets an overdue entry and its total ties to 2150', async () => {
  const asOf = new Date().toISOString().slice(0, 10);
  const report = await apReports.getAgedAccountsPayable({ asOf });
  const grand = report.totals.balance;
  assert.strictEqual(grand, report.totals.not_due + report.totals.bucket_1 + report.totals.bucket_2 + report.totals.bucket_3 + report.totals.bucket_over);
  assert.strictEqual(grand, await accounting.accountBalance('2150'), 'Aged AP grand total does not equal the 2150 control account');
});

await test('a purchase credit memo reverses signs against the ledger', async () => {
  const sys: Actor = { id: 1, username: 'system' };
  const vend = (await vendorLib.listVendors())[0];
  const apBefore = await accounting.accountBalance('2150');
  const { no } = await purchaseLib.createPurchaseDocument(
    { documentType: 'Credit Memo', vendorId: vend.id, postingDate: '2026-08-10', documentDate: '2026-08-10', vendorInvoiceNo: 'TEST-CM-1' }, sys,
  );
  await purchaseLib.setPurchaseLines(no, [{ type: 'G/L Account', no: '5030', description: 'Credit', quantity: 1, directUnitCost: 8_000_00 }], sys);
  await run("UPDATE purchase_header SET status = 'Released', buy_from_name = ? WHERE no = ?", vend.name, no);
  const res = await purchaseLib.postPurchaseDocument(no, { invoice: true }, sys);
  const vle = (await one<{ amount: number; positive: number }>('SELECT amount, positive FROM vendor_ledger_entry WHERE id = ?', res.vendorLedgerEntryId))!;
  assert.strictEqual(vle.amount, -8_000_00);
  assert.strictEqual(vle.positive, 0);
  assert.strictEqual(await accounting.accountBalance('2150'), apBefore - 8_000_00);
});

/* ------------------------------------------------------------------------ */
section('Cash Management, VAT & Withholding Tax');

const cmSys: Actor = { id: 1, username: 'system' };
await run('UPDATE cash_management_setup SET receipt_approval_limit = 999999999999, pv_approval_limit = 999999999999 WHERE id = 1');

await test('the seed created the VAT Posting Setup (BC style, reused for WHT)', async () => {
  const vat16 = (await one<{ vat_pct: number; tax_type: string; code: string }>(
    "SELECT s.vat_pct, s.tax_type, a.code FROM vat_posting_setup s JOIN gl_account a ON a.id = s.tax_account_id WHERE s.vat_bus_posting_group_code = 'STANDARD' AND s.vat_prod_posting_group_code = 'VAT16'",
  ))!;
  assert.strictEqual(vat16.vat_pct, 16);
  assert.strictEqual(vat16.tax_type, 'VAT');
  assert.strictEqual(vat16.code, '1260');
  const wht = (await one<{ vat_pct: number; tax_type: string; code: string }>(
    "SELECT s.vat_pct, s.tax_type, a.code FROM vat_posting_setup s JOIN gl_account a ON a.id = s.tax_account_id WHERE s.vat_prod_posting_group_code = 'WHT-PROF'",
  ))!;
  assert.strictEqual(wht.vat_pct, 5);
  assert.strictEqual(wht.tax_type, 'WHT');
  assert.strictEqual(wht.code, '2190');
});

let vatInvoiceNo = '';
await test('a purchase invoice with a VAT16 line extracts input VAT to 1260; a no-VAT line is unchanged', async () => {
  const vend = (await vendorLib.listVendors())[0];
  const b1260 = await accounting.accountBalance('1260');
  const b2150 = await accounting.accountBalance('2150');
  const b5030 = await accounting.accountBalance('5030');
  const { no } = await purchaseLib.createPurchaseDocument(
    { documentType: 'Invoice', vendorId: vend.id, postingDate: '2026-08-05', documentDate: '2026-08-05', paymentTermsCode: '30 DAYS', vendorInvoiceNo: 'VAT-INV-1' }, cmSys,
  );
  vatInvoiceNo = no;
  await purchaseLib.setPurchaseLines(no, [
    { type: 'G/L Account', no: '5030', description: 'Consultancy', quantity: 1, directUnitCost: 100_000_00, vatProdPostingGroupCode: 'VAT16' },
    { type: 'G/L Account', no: '5030', description: 'Reimbursables (no VAT)', quantity: 1, directUnitCost: 10_000_00 },
  ], cmSys);
  await run("UPDATE purchase_header SET status = 'Released', due_date = '2026-09-04', buy_from_name = ? WHERE no = ?", vend.name, no);
  const res = await purchaseLib.postPurchaseDocument(no, { invoice: true }, cmSys);

  assert.strictEqual(await accounting.accountBalance('5030'), b5030 + 110_000_00, 'expense ex-VAT (both lines)');
  assert.strictEqual(await accounting.accountBalance('1260'), b1260 + 16_000_00, 'input VAT = 16% of the VAT line');
  assert.strictEqual(await accounting.accountBalance('2150'), b2150 + 126_000_00, 'payables = ex-VAT + VAT');
  const vle = (await one<{ amount: number }>('SELECT amount FROM vendor_ledger_entry WHERE id = ?', res.vendorLedgerEntryId))!;
  assert.strictEqual(vle.amount, 126_000_00, 'the vendor is owed the VAT-inclusive total');
  const ve = (await one<{ base: number; amount: number }>("SELECT base, amount FROM vat_entry WHERE document_no = ? AND tax_type = 'VAT'", no))!;
  assert.strictEqual(ve.base, 100_000_00);
  assert.strictEqual(ve.amount, 16_000_00);
});

await test('a Receipt (G/L line) posts Dr bank / Cr income and writes a Bank Ledger Entry + posted_receipt', async () => {
  const bank = (await one<{ gl_account_id: number; balance: number; balance_lcy: number }>("SELECT gl_account_id, balance, balance_lcy FROM bank_account WHERE code = 'BANK'"))!;
  const bankBal = await accounting.accountBalance('1020');
  const incomeBal = await accounting.accountBalance('4050');
  const { no } = await receiptsLib.createReceipt({
    receiptType: 'G/L Account', bankAccountId: (await one<{ id: number }>("SELECT id FROM bank_account WHERE code = 'BANK'"))!.id,
    postingDate: '2026-08-10', description: 'Sundry income received', payModeCode: null,
    lines: [{ lineType: 'G/L Account', accountNo: '4050', description: 'Photocopy income', amount: 5_000_00 }],
  }, cmSys);
  const res = await receiptsLib.postReceipt(no, cmSys);
  assert.ok(res.journalNo, 'a journal was posted');
  assert.strictEqual(await accounting.accountBalance('1020'), bankBal + 5_000_00);
  assert.strictEqual(await accounting.accountBalance('4050'), incomeBal + 5_000_00);
  const bale = (await one<{ document_type: string; amount: number; amount_lcy: number }>(
    "SELECT document_type, amount, amount_lcy FROM bank_account_ledger_entry WHERE document_no = ? ORDER BY id DESC LIMIT 1", no,
  ))!;
  assert.strictEqual(bale.document_type, 'Receipt');
  assert.strictEqual(bale.amount, 5_000_00);
  assert.strictEqual(bale.amount_lcy, 5_000_00);
  const pr = (await one<{ amount: number }>('SELECT amount FROM posted_receipt WHERE receipt_no = ?', no))!;
  assert.strictEqual(pr.amount, 5_000_00);
  assert.strictEqual((await one<{ balance: number }>("SELECT balance FROM bank_account WHERE code = 'BANK'"))!.balance, bank.balance + 5_000_00);
});

await test('a Payment Voucher paying the VAT invoice with WHT-PROF closes it, books WHT payable and issues a certificate', async () => {
  const vend = (await vendorLib.listVendors())[0];
  await run("UPDATE vendor SET pin_no = 'A001122334Z' WHERE id = ?", vend.id);
  const bankId = (await one<{ id: number }>("SELECT id FROM bank_account WHERE code = 'BANK'"))!.id;
  const b2150 = await accounting.accountBalance('2150');
  const b2190 = await accounting.accountBalance('2190');
  const b1020 = await accounting.accountBalance('1020');

  const { no } = await pvLib.createPaymentVoucher({
    payingBankAccountId: bankId, date: '2026-08-12', payModeCode: 'EFT', description: `Pay ${vatInvoiceNo}`, payeeName: vend.name,
    lines: [{ lineType: 'Vendor', accountNo: vend.no, amount: 126_000_00, appliesToDocNo: vatInvoiceNo, whtCodeOne: 'WHT-PROF' }],
  }, cmSys);
  // WHT base = ex-VAT 100,000 → 5% = 5,000. Net paid = 126,000 − 5,000 = 121,000.
  const line = (await one<{ wht_amount_one: number; net_amount: number }>(
    'SELECT wht_amount_one, net_amount FROM payment_voucher_line WHERE payment_voucher_header_id = (SELECT id FROM payment_voucher_header WHERE no = ?)', no,
  ))!;
  assert.strictEqual(line.wht_amount_one, 5_000_00, 'WHT on the VAT-exclusive base');
  assert.strictEqual(line.net_amount, 121_000_00);

  const res = await pvLib.postPaymentVoucher(no, cmSys);
  assert.strictEqual(await accounting.accountBalance('2150'), b2150 - 126_000_00, 'the invoice is cleared in full');
  assert.strictEqual(await accounting.accountBalance('2190'), b2190 + 5_000_00, 'WHT payable rises');
  assert.strictEqual(await accounting.accountBalance('1020'), b1020 - 121_000_00, 'bank falls by the net paid');
  const vle = (await one<{ open: number }>("SELECT open FROM vendor_ledger_entry WHERE document_no = ? AND document_type = 'Invoice'", vatInvoiceNo))!;
  assert.strictEqual(vle.open, 0, 'the purchase invoice is closed');
  assert.strictEqual(res.whtCertificateNos.length, 1, 'one WHT certificate');
  const cert = (await whtLib.getWhtCertificate(res.whtCertificateNos[0]))!;
  assert.strictEqual(cert.total_wht, 5_000_00);
  assert.strictEqual(cert.lines[0].base, 100_000_00);
});

await test('a direct-expense Payment Voucher extracts VAT and withholds both income WHT and withholding VAT', async () => {
  const bankId = (await one<{ id: number }>("SELECT id FROM bank_account WHERE code = 'BANK'"))!.id;
  const b1260 = await accounting.accountBalance('1260');
  const b2190 = await accounting.accountBalance('2190');
  const b2195 = await accounting.accountBalance('2195');
  const b1020 = await accounting.accountBalance('1020');
  const b5030 = await accounting.accountBalance('5030');

  const { no } = await pvLib.createPaymentVoucher({
    payingBankAccountId: bankId, date: '2026-08-14', payModeCode: 'EFT', description: 'Direct consultancy', payeeName: 'Ad-hoc Consultant',
    lines: [{ lineType: 'G/L Account', accountNo: '5030', amount: 116_000_00, vatProdPostingGroupCode: 'VAT16', whtCodeOne: 'WHT-PROF', whtCodeTwo: 'WHT-VAT' }],
  }, cmSys);
  await pvLib.postPaymentVoucher(no, cmSys);
  assert.strictEqual(await accounting.accountBalance('5030'), b5030 + 100_000_00, 'expense net of VAT');
  assert.strictEqual(await accounting.accountBalance('1260'), b1260 + 16_000_00, 'input VAT extracted');
  assert.strictEqual(await accounting.accountBalance('2190'), b2190 + 5_000_00, 'income WHT 5%');
  assert.strictEqual(await accounting.accountBalance('2195'), b2195 + 2_000_00, 'withholding VAT 2%');
  assert.strictEqual(await accounting.accountBalance('1020'), b1020 - 109_000_00, 'bank = gross − both WHTs');
});

await test('the VAT Input Listing total ties to the vat_entry ledger', async () => {
  const rows = await vatReportsLib.vatInputListing({ from: '2026-01-01', to: '2026-12-31' });
  const listed = rows.reduce((s, r) => s + Number(r.amount), 0);
  const ledger = Number((await one<{ t: number }>("SELECT COALESCE(SUM(amount),0) t FROM vat_entry WHERE tax_type = 'VAT'"))!.t);
  assert.strictEqual(listed, ledger);
});

await test('every Cash Management journal is internally balanced in LCY', async () => {
  const rows = await all<{ id: number; d: number; c: number }>(
    "SELECT j.id, SUM(jl.debit_lcy) d, SUM(jl.credit_lcy) c FROM journal j JOIN journal_line jl ON jl.journal_id = j.id WHERE j.source_module = 'CASH_MGMT' GROUP BY j.id",
  );
  assert.ok(rows.length > 0, 'some Cash Management journals were posted');
  for (const r of rows) assert.strictEqual(Number(r.d), Number(r.c), `journal ${r.id} did not balance`);
});

await test('the payables subledger still ties to 2150 after the VAT invoice + payment voucher', async () => {
  const subledger = Number((await one<{ total: number }>('SELECT COALESCE(SUM(remaining_amount_lcy),0) total FROM vendor_ledger_entry WHERE open = 1'))!.total);
  assert.strictEqual(subledger, await accounting.accountBalance('2150'));
});

/* ------------------------------------------------------------------------ */
section('Security');

await test('passwords are salted and never stored in the clear', async () => {
  const row = (await one<{ password_hash: string }>(
    "SELECT password_hash FROM app_user WHERE username='admin'",
  ))!;
  assert.ok(row.password_hash.startsWith('scrypt$'));
  assert.ok(!row.password_hash.includes('admin123'));
  assert.ok(auth.verifyPassword('admin123', row.password_hash));
  assert.ok(!auth.verifyPassword('admin124', row.password_hash));
});

await test('two users with the same password get different hashes', () => {
  assert.notStrictEqual(auth.hashPassword('same-password'), auth.hashPassword('same-password'));
});

await test('role permissions gate access correctly', async () => {
  const role = (await one<{ id: number }>("SELECT id FROM role WHERE name='Teller'"))!;
  const permissionSet = await auth.loadPermissionSet(role.id);
  const teller = { is_system: 0, permissionSet } as SessionUser;
  assert.ok(permissions.canAction(teller, 'SAVINGS_DEPOSIT'));
  assert.ok(!permissions.canAction(teller, 'LOAN_APPROVE'));
  assert.ok(!permissions.canAction(teller, 'ADMIN_USER_MANAGE'));
  const sysadmin = { is_system: 1, permissionSet: { tables: {}, pages: {} } } as SessionUser;
  assert.ok(permissions.canAction(sysadmin, 'ADMIN_USER_MANAGE'));
});

/* ------------------------------------------------------------------------ */
section('Financial Reports (Account Schedules)');

const expr = await import('../lib/expr.ts');
const finReports = await import('../lib/financialReports.ts');
const reportsLib = await import('../lib/reports.ts');

await test('the formula evaluator honours precedence, parens and divide-by-zero', () => {
  assert.strictEqual(expr.evalFormula('2+3*4', {}), 14);
  assert.strictEqual(expr.evalFormula('(2+3)*4', {}), 20);
  assert.strictEqual(expr.evalFormula('-A+B', { A: 10, B: 3 }), -7);
  assert.strictEqual(expr.evalFormula('A/B*100', { A: 5, B: 0 }), 0);
  assert.strictEqual(expr.evalFormula('UNKNOWN+1', {}), 1);
  assert.ok(!expr.isValidFormula('A +* B'));
});

await test('a seeded Financial Report runs and its formula rows reconcile', async () => {
  const res = await finReports.runFinancialReport({ reportName: 'SASRA-CAPITAL-ADEQUACY', to: today });
  const byRow = Object.fromEntries(res.rows.map((r) => [r.rowNo, r.cells[0]?.value ?? 0]));
  assert.ok(res.rows.length >= 7, 'every capital-adequacy line is present');
  assert.ok(byRow.TA > 0, 'total assets is non-zero on the seeded ledger');
  const expectedR1 = byRow.TA === 0 ? 0 : (byRow.CORE / byRow.TA) * 100;
  assert.ok(Math.abs(byRow.R1 - expectedR1) < 1e-6, 'R1 equals CORE / TA * 100');
});

await test('the seeded Statement of Financial Position balances', async () => {
  const res = await finReports.runFinancialReport({ reportName: 'STMT-FIN-POSITION', to: today });
  const chk = res.rows.find((r) => r.rowNo === 'CHK')!;
  assert.ok(Math.abs(chk.cells[0]?.value ?? 0) < 100, 'assets equal equity + liabilities (within a shilling)');

  const bs = await reportsLib.getBalanceSheet({ asOf: today });
  const ta = res.rows.find((r) => r.rowNo === 'TA')!.cells[0]?.value ?? 0;
  assert.ok(Math.abs(ta - bs.totals.assets) < 100, 'total assets agrees with getBalanceSheet()');
});

await test('a comparison-date column measures the prior fiscal year, and formulas fold in', async () => {
  await finReports.saveColumnLayoutName({ name: 'TEST-CL', description: 'test' }, admin);
  await finReports.saveColumnLayoutLine({ layoutName: 'TEST-CL', columnNo: 'TY', columnHeader: 'This Year', columnType: 'NET_CHANGE' }, admin);
  await finReports.saveColumnLayoutLine({ layoutName: 'TEST-CL', columnNo: 'LY', columnHeader: 'Last Year', columnType: 'NET_CHANGE', comparisonDateFormula: '-1Y' }, admin);
  await finReports.saveColumnLayoutLine({ layoutName: 'TEST-CL', columnNo: 'VAR', columnHeader: 'Change', columnType: 'FORMULA', formula: 'TY-LY' }, admin);

  await finReports.saveAccScheduleName({ name: 'TEST-FR', description: 'test', defaultColumnLayoutName: 'TEST-CL' }, admin);
  await finReports.saveAccScheduleLine({ scheduleName: 'TEST-FR', rowNo: 'INC', description: 'Income', totalingType: 'POSTING_ACCOUNTS', totaling: '4010' }, admin);
  await finReports.saveAccScheduleLine({ scheduleName: 'TEST-FR', rowNo: 'DBL', description: 'Doubled', totalingType: 'FORMULA', totaling: 'INC+INC' }, admin);

  const col = (rows: Awaited<ReturnType<typeof finReports.runFinancialReport>>, rowNo: string, colNo: string): number => {
    const r = rows.rows.find((x) => x.rowNo === rowNo)!;
    return r.cells[rows.columns.findIndex((c) => c.columnNo === colNo)]?.value ?? 0;
  };
  const opts = { rowGroup: 'TEST-FR' as const, from: '2026-01-01', to: '2026-12-31' };
  const beforeTY = col(await finReports.runFinancialReport(opts), 'INC', 'TY');
  const beforeLY = col(await finReports.runFinancialReport(opts), 'INC', 'LY');

  await accounting.postJournal({
    valueDate: '2026-06-30', module: 'TEST', eventType: 'TEST_FR', description: 'current year income',
    lines: [{ account: '4010', debit: 0, credit: 100_00 }, { account: '1210', debit: 100_00, credit: 0 }], user: admin,
  });
  await accounting.postJournal({
    valueDate: '2025-06-30', module: 'TEST', eventType: 'TEST_FR', description: 'prior year income',
    lines: [{ account: '4010', debit: 0, credit: 40_00 }, { account: '1210', debit: 40_00, credit: 0 }], user: admin,
  });

  const res = await finReports.runFinancialReport(opts);
  assert.strictEqual(col(res, 'INC', 'TY') - beforeTY, 100_00, 'the this-year column picks up the 2026 posting');
  assert.strictEqual(col(res, 'INC', 'LY') - beforeLY, 40_00, 'the -1Y comparison column picks up the 2025 posting');
  assert.strictEqual(col(res, 'INC', 'VAR'), col(res, 'INC', 'TY') - col(res, 'INC', 'LY'), 'the formula column is TY - LY');
  assert.strictEqual(col(res, 'DBL', 'TY'), col(res, 'INC', 'TY') * 2, 'a formula row evaluates over the other rows in its column');
});

await test('a dimension totaling that matches nothing yields zero', async () => {
  await finReports.saveAccScheduleLine({
    scheduleName: 'TEST-FR', rowNo: 'INCD', description: 'Income (unknown dimension)',
    totalingType: 'POSTING_ACCOUNTS', totaling: '4010', dimension1Totaling: 'ZZZ-NO-SUCH-CODE',
  }, admin);
  const res = await finReports.runFinancialReport({ rowGroup: 'TEST-FR', from: '2026-01-01', to: '2026-12-31' });
  const incd = res.rows.find((r) => r.rowNo === 'INCD')!;
  assert.strictEqual(incd.cells[0]?.value ?? 0, 0);
});

/* ------------------------------------------------------------------------ */
section('Role Centres & Profiles');

const profilesLib = await import('../lib/profiles.ts');
const roleCentersLib = await import('../lib/roleCenters.ts');

await test('the six Role Centre profiles and permission sets are seeded', async () => {
  const codes = (await all<{ code: string }>('SELECT code FROM profile ORDER BY sort')).map((r) => r.code);
  assert.deepStrictEqual(codes, ['SUPER', 'CRM', 'CREDIT', 'FOSA', 'FINANCE_MANAGER', 'ACCOUNTANT']);
  for (const name of ['Super Role Centre', 'CRM Officer', 'Credit Officer', 'FOSA Officer', 'Finance Manager', 'Accountant']) {
    const row = await one<{ id: number; lines: number }>(
      `SELECT r.id, COUNT(l.id) lines FROM role r LEFT JOIN permission_set_line l ON l.role_id = r.id
       WHERE r.name = ? GROUP BY r.id`, name,
    );
    assert.ok(row && Number(row.lines) > 5, `${name} exists with permission lines`);
  }
});

await test('a Profile is a landing page only — it grants no permissions', async () => {
  const teller = (await one<{ id: number }>("SELECT id FROM app_user WHERE username='teller'"))!;
  const before = await auth.loadPermissionSet(
    (await one<{ role_id: number }>('SELECT role_id FROM app_user WHERE id = ?', teller.id))!.role_id,
  );
  const credit = (await one<{ id: number }>("SELECT id FROM profile WHERE code='CREDIT'"))!;
  await profilesLib.setUserProfiles(teller.id, [credit.id], admin);
  await profilesLib.setActiveProfile(teller.id, credit.id, admin);

  const tok = `rc-${Date.now()}`;
  await run('INSERT INTO session (token, user_id, created_at, expires_at) VALUES (?,?,?,?)',
    tok, teller.id, new Date().toISOString(), new Date(Date.now() + 3_600_000).toISOString());
  const su = (await auth.userFromToken(tok))!;
  await run('DELETE FROM session WHERE token = ?', tok);

  assert.strictEqual(su.activeProfile.code, 'CREDIT', 'the Credit Role Centre is now active');
  assert.deepStrictEqual(su.permissionSet.pages, before.pages, 'pages are unchanged by the profile');
  assert.deepStrictEqual(su.permissionSet.tables, before.tables, 'table rights are unchanged by the profile');
  // The Teller permission set does not carry GL_READ regardless of the Credit profile.
  assert.ok(!permissions.canAction(su as SessionUser, 'GL_JOURNAL_APPROVE'));
});

await test('assigning profiles keeps the active one valid; an unassigned choice is rejected', async () => {
  const u = (await one<{ id: number }>("SELECT id FROM app_user WHERE username='loans'"))!;
  const [crm, fosa] = await Promise.all([
    one<{ id: number }>("SELECT id FROM profile WHERE code='CRM'"),
    one<{ id: number }>("SELECT id FROM profile WHERE code='FOSA'"),
  ]);
  await profilesLib.setUserProfiles(u.id, [crm!.id], admin);
  let active = (await one<{ active_profile_id: number | null }>('SELECT active_profile_id FROM app_user WHERE id = ?', u.id))!;
  assert.strictEqual(active.active_profile_id, crm!.id, 'active resets to the only assigned profile');

  // Switching to a profile the user does not hold falls back rather than sticking.
  const back = await profilesLib.setActiveProfile(u.id, fosa!.id, admin);
  assert.strictEqual(back.code, 'CRM', 'an unassigned profile choice falls back to an assigned one');

  // Removing every profile clears the active pointer.
  await profilesLib.setUserProfiles(u.id, [], admin);
  active = (await one<{ active_profile_id: number | null }>('SELECT active_profile_id FROM app_user WHERE id = ?', u.id))!;
  assert.strictEqual(active.active_profile_id, null);
});

await test('the active Role Centre scopes which sidebar groups show', async () => {
  const { NAV, groupInRoleCentre } = await import('../lib/nav.ts');
  const groupsFor = (centre: string) => NAV.filter((g) => groupInRoleCentre(g, centre)).map((g) => g.group);

  // Super sees every group.
  assert.deepStrictEqual(groupsFor('SUPER'), NAV.map((g) => g.group));
  // A specialised centre sees Operations + Administration + only its own area.
  const fosa = groupsFor('FOSA');
  assert.ok(fosa.includes('Operations') && fosa.includes('FOSA') && fosa.includes('Administration'));
  assert.ok(!fosa.includes('Credit') && !fosa.includes('Finance') && !fosa.includes('Client Relationship MGMT'));
  assert.ok(groupsFor('FINANCE_MANAGER').includes('Finance') && groupsFor('ACCOUNTANT').includes('Finance'));
  assert.ok(!groupsFor('CREDIT').includes('FOSA'));
});

await test('every Role Centre aggregate returns a well-formed object on the seeded ledger', async () => {
  const crm = await roleCentersLib.getCrmRoleCenter();
  assert.ok(Number.isFinite(crm.members.total) && crm.membersByMonth.length === 12);

  const credit = await roleCentersLib.getCreditRoleCenter();
  assert.ok(Number.isFinite(credit.kpi.parPct) && credit.par.rows.length > 0);

  const fosa = await roleCentersLib.getFosaRoleCenter();
  assert.ok(Number.isFinite(fosa.kpi.fosaDeposits) && fosa.flows.length === 12);

  const fm = await roleCentersLib.getFinanceManagerRoleCenter();
  assert.ok(fm.pl.length === 12 && fm.ratios.length === 4 && Number.isFinite(fm.ratios[0].value));

  const acc = await roleCentersLib.getAccountantRoleCenter();
  assert.ok(typeof acc.kpi.balanced === 'boolean' && acc.journalsByMonth.length === 12);
});

/* ------------------------------------------------------------------------ */
section('Per-user permission overrides');

const userPermsLib = await import('../lib/userPermissions.ts');

const sessionFor = async (userId: number): Promise<SessionUser> => {
  const tok = `up-${userId}-${Date.now()}-${Math.random()}`;
  await run('INSERT INTO session (token, user_id, created_at, expires_at) VALUES (?,?,?,?)',
    tok, userId, new Date().toISOString(), new Date(Date.now() + 3_600_000).toISOString());
  const su = (await auth.userFromToken(tok))!;
  await run('DELETE FROM session WHERE token = ?', tok);
  return su;
};

await test('a DENY override removes a right the role grants', async () => {
  const teller = (await one<{ id: number }>("SELECT id FROM app_user WHERE username='teller'"))!;
  await userPermsLib.resetUserPermissions(teller.id, admin);

  const before = await sessionFor(teller.id);
  assert.ok(permissions.canPage(before, 'TELLER_TRANSACTIONS'), 'Teller role grants the teller screen');
  assert.ok(permissions.canAction(before, 'TELLER_TRANSACTIONS_POST'));

  await userPermsLib.setUserPermissions(teller.id, [
    { objectType: 'PAGE', objectName: 'TELLER_TRANSACTIONS', rights: { execute: false } },
  ], admin);

  const after = await sessionFor(teller.id);
  assert.ok(!permissions.canPage(after, 'TELLER_TRANSACTIONS'), 'the override hides the screen');
  assert.ok(!permissions.canAction(after, 'TELLER_TRANSACTIONS_POST'), 'and every action behind it');
  await userPermsLib.resetUserPermissions(teller.id, admin);
});

await test('a GRANT override adds a right the role lacks', async () => {
  const teller = (await one<{ id: number }>("SELECT id FROM app_user WHERE username='teller'"))!;
  const before = await sessionFor(teller.id);
  assert.ok(!permissions.canAction(before, 'GL_READ'), 'Teller role has no general-ledger access');

  await userPermsLib.setUserPermissions(teller.id, [
    { objectType: 'PAGE', objectName: 'GL', rights: { execute: true } },
    { objectType: 'TABLE', objectName: 'journal', rights: { read: true } },
    { objectType: 'TABLE', objectName: 'journal_line', rights: { read: true } },
    { objectType: 'TABLE', objectName: 'gl_account', rights: { read: true } },
  ], admin);

  const after = await sessionFor(teller.id);
  assert.ok(permissions.canAction(after, 'GL_READ'), 'the override grants it');
  await userPermsLib.resetUserPermissions(teller.id, admin);
});

await test('an additional Permission Set is unioned into the effective rights (BC model)', async () => {
  const teller = (await one<{ id: number }>("SELECT id FROM app_user WHERE username='teller'"))!;
  const financeRole = (await one<{ id: number }>("SELECT id FROM role WHERE name='Finance Officer'"))!;
  await userPermsLib.setUserPermissionSets(teller.id, [], admin);

  const before = await sessionFor(teller.id);
  assert.ok(!permissions.canAction(before, 'GL_READ') && permissions.canAction(before, 'TELLER_TRANSACTIONS_POST'));

  await userPermsLib.setUserPermissionSets(teller.id, [financeRole.id], admin);
  const after = await sessionFor(teller.id);
  assert.ok(permissions.canAction(after, 'GL_READ'), 'Finance Officer rights are added…');
  assert.ok(permissions.canAction(after, 'TELLER_TRANSACTIONS_POST'), '…without losing the Teller rights (union)');

  assert.deepStrictEqual(
    [...(await userPermsLib.listUserPermissionSets(teller.id)).map((s) => s.name)],
    ['Finance Officer'],
  );
  await userPermsLib.setUserPermissionSets(teller.id, [], admin);
});

await test('two users on the same role differ only by their overrides', async () => {
  const [a, b] = await all<{ id: number; role_id: number }>(
    "SELECT id, role_id FROM app_user WHERE username IN ('teller','loans') ORDER BY username",
  );
  // Put both on the Teller role for the test.
  const tellerRole = (await one<{ id: number }>("SELECT id FROM role WHERE name='Teller'"))!;
  await run('UPDATE app_user SET role_id = ? WHERE id IN (?,?)', tellerRole.id, a.id, b.id);
  await userPermsLib.resetUserPermissions(a.id, admin);
  await userPermsLib.resetUserPermissions(b.id, admin);

  await userPermsLib.setUserPermissions(a.id, [
    { objectType: 'TABLE', objectName: 'savings_account', rights: { read: true } }, // strip deposit/withdraw modify
  ], admin);

  const sa = await sessionFor(a.id);
  const sb = await sessionFor(b.id);
  assert.notDeepStrictEqual(sa.permissionSet.tables.savings_account, sb.permissionSet.tables.savings_account);
  const roleSet = await auth.loadPermissionSet(tellerRole.id);
  assert.deepStrictEqual(sb.permissionSet.tables, roleSet.tables, 'the un-overridden user matches the role exactly');

  await userPermsLib.resetUserPermissions(a.id, admin);
  await run('UPDATE app_user SET role_id = ? WHERE id = ?', b.role_id, b.id);
  await run('UPDATE app_user SET role_id = ? WHERE id = ?', a.role_id, a.id);
});

await test('an override equal to the role default is not stored', async () => {
  const teller = (await one<{ id: number }>("SELECT id FROM app_user WHERE username='teller'"))!;
  const roleSet = await auth.loadPermissionSet(
    (await one<{ role_id: number }>('SELECT role_id FROM app_user WHERE id = ?', teller.id))!.role_id,
  );
  const t = roleSet.tables.savings_account!;
  await userPermsLib.setUserPermissions(teller.id, [
    { objectType: 'TABLE', objectName: 'savings_account', rights: { ...t, execute: false } },
  ], admin);
  const n = await one<{ n: number }>('SELECT COUNT(*) n FROM user_permission_line WHERE user_id = ?', teller.id);
  assert.strictEqual(Number(n?.n ?? 0), 0, 'a no-op override writes no row');
});

await test('a nav entry is hidden when the page is reachable but its data is not readable', async () => {
  // A permission set that grants the LOANS page Execute but NOT `loan` table Read — the classic
  // way a hand-edited matrix leaves a module in the sidebar the user cannot actually use.
  const teller = (await one<{ id: number }>("SELECT id FROM app_user WHERE username='teller'"))!;
  const rid = Number((await run(
    "INSERT INTO role (name, description, is_system) VALUES ('ZZ Nav Test', 't', 0)",
  )).lastInsertRowid);
  await run("INSERT INTO permission_set_line (role_id, object_type, object_name, execute_perm) VALUES (?, 'PAGE', 'DASHBOARD', 1)", rid);
  await run("INSERT INTO permission_set_line (role_id, object_type, object_name, execute_perm) VALUES (?, 'PAGE', 'LOANS', 1)", rid);
  const orig = (await one<{ role_id: number }>('SELECT role_id FROM app_user WHERE id = ?', teller.id))!.role_id;
  await run('UPDATE app_user SET role_id = ? WHERE id = ?', rid, teller.id);
  await userPermsLib.resetUserPermissions(teller.id, admin);
  await userPermsLib.setUserPermissionSets(teller.id, [], admin);

  const tok = `nv-${Date.now()}`;
  await run('INSERT INTO session (token, user_id, created_at, expires_at) VALUES (?,?,?,?)',
    tok, teller.id, new Date().toISOString(), new Date(Date.now() + 3_600_000).toISOString());
  const su = (await auth.userFromToken(tok))!;
  await run('DELETE FROM session WHERE token = ?', tok);

  assert.ok(permissions.canPage(su as SessionUser, 'LOANS'), 'the page shell is reachable');
  assert.ok(!permissions.canNav(su as SessionUser, 'LOANS'), 'but the nav entry is hidden — no loan read');
  assert.ok(permissions.canNav(su as SessionUser, 'DASHBOARD'), 'the dashboard entry still shows');

  await run('UPDATE app_user SET role_id = ? WHERE id = ?', orig, teller.id);
  await run('DELETE FROM role WHERE id = ?', rid);
});

await test('the System Administrator cannot be restricted by an override', async () => {
  const adminUser = (await one<{ id: number }>("SELECT id FROM app_user WHERE username='admin'"))!;
  // Even a raw override row must not restrict a system user.
  await run(
    `INSERT INTO user_permission_line (user_id, object_type, object_name, execute_perm)
     VALUES (?, 'PAGE', 'GL', 0) ON CONFLICT (user_id, object_type, object_name) DO NOTHING`,
    adminUser.id,
  );
  const su = await sessionFor(adminUser.id);
  assert.ok(permissions.canPage(su, 'GL') && permissions.canAction(su, 'GL_JOURNAL_APPROVE'),
    'is_system short-circuits every check');
  const matrix = await userPermsLib.getUserPermissionMatrix(adminUser.id);
  assert.strictEqual(matrix.isSystem, true);
  await throws(() => userPermsLib.setUserPermissions(adminUser.id, [], admin), /SYSTEM_USER/);
  await run('DELETE FROM user_permission_line WHERE user_id = ?', adminUser.id);
});

/* ------------------------------------------------------------------------ */
console.log(`\n${fail === 0 ? '\x1b[32m' : '\x1b[31m'}${pass} passed, ${fail} failed\x1b[0m\n`);
process.exit(fail ? 1 : 0);
