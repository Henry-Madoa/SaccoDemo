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
const savings = await import('../lib/savings.ts');
const loanSvc = await import('../lib/loanService.ts');
const { buildSchedule, allocateRepayment } = await import('../lib/loans.ts');
const auth = await import('../lib/auth.ts');
const permissions = await import('../lib/permissions.ts');

import type {
  Actor, LoanFull, LoanProduct, LoanScheduleRow, Member, SavingsAccount, SessionUser,
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
  const dated = await accounting.trialBalance(today);
  assert.strictEqual(dated.length, full.length, `dated ${dated.length} rows vs undated ${full.length}`);
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

/* ------------------------------------------------------------------------ */
section('Posting engine controls');

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

await test('a captured loan can be submitted for approval', async () => {
  lifecycleLoan = await loanSvc.submit({ loanId: lifecycleLoan.id, user: admin });
  assert.strictEqual(lifecycleLoan.status, 'PENDING APPROVAL');
});

await test('an unapproved loan cannot be disbursed', async () => {
  await throws(() => loanSvc.disburse({ loanId: lifecycleLoan.id, user: other }), /BAD_STATUS/);
});

await test('segregation of duties: the maker cannot approve their own loan', async () => {
  await throws(() => loanSvc.approve({ loanId: lifecycleLoan.id, user: admin, approve: true }), /SOD_VIOLATION/);
});

await test('a different officer can approve it', async () => {
  const l = await loanSvc.approve({ loanId: lifecycleLoan.id, user: other, approve: true, reason: 'ok' });
  assert.strictEqual(l.status, 'APPROVED');
  assert.strictEqual(l.approved_by, other.username);
});

await test('disbursement debits the receivable, credits the member and generates the schedule', async () => {
  const recvBefore = await accounting.accountBalance('1110');
  const savingsBefore = (await savings.getAccount(borrowerFosa.id))!.balance;
  const feeBefore = await accounting.accountBalance('4020');
  const l = await loanSvc.disburse({ loanId: lifecycleLoan.id, user: other });

  const fees = Math.round(20000000 * (normProduct.processing_fee_pct + normProduct.insurance_pct) / 100);
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
console.log(`\n${fail === 0 ? '\x1b[32m' : '\x1b[31m'}${pass} passed, ${fail} failed\x1b[0m\n`);
process.exit(fail ? 1 : 0);
