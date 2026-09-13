/*
 * Payroll — the calculation engine + period lifecycle. Unlike the AL source (which only tags
 * lines with a G/L account for an external export), this posts real double-entry journals via
 * the existing postJournal() engine on period close (user-confirmed design choice) — every other
 * financial module here already works that way.
 *
 * Corrections versus the AL source: NSSF is a correct Kenyan Tier I/Tier II tiered accumulation
 * (AL only reads its first tier row); PAYE is a clean progressive-band function; proration uses
 * the real `monthly_working_days` setting (AL hardcodes 22 despite having that exact field).
 *
 * Known simplifications (documented, not silent): a transaction code's `is_formula` amount is not
 * evaluated — the amount stored on the employee's own recurring transaction line is used as-is;
 * there is no pension-contribution cap or "1/3 net pay" soft-flag; NSSF is always based on gross
 * pay (SHIF/Housing Levy base is configurable via Payroll Setup).
 */
import { one, all, run, tx, audit } from './db.ts';
import { AppError } from './errors.ts';
import { postJournal } from './accounting.ts';
import { getEmployee, getCurrentContract } from './employees.ts';
import { getPayrollSetup, listPayeBands, listNssfTiers } from './payrollSetup.ts';
import { findMatchingWorkflow, findPendingRoutedTask, pickConditionFields, startWorkflow } from './workflow.ts';
import { settleImprestsFromPayroll } from './imprest.ts';
import type {
  Actor, PayrollPeriod, PayrollPeriodStatus, PayrollPostingGroup, PayrollTransactionCode,
  PayrollTransactionType, EmployeePayrollTransactionView, PayrollPeriodLineView, EmployeeExitDueType,
} from './types.ts';

/* ============================================================================ system tx codes */

const SYSTEM_CODES: { code: string; name: string; type: PayrollTransactionType }[] = [
  { code: 'BASIC', name: 'Basic Salary', type: 'INCOME' },
  { code: 'NSSF_EE', name: 'NSSF (Employee)', type: 'DEDUCTION' },
  { code: 'NSSF_ER', name: 'NSSF (Employer)', type: 'COMPANY_DEDUCTION' },
  { code: 'SHIF', name: 'SHIF', type: 'DEDUCTION' },
  { code: 'HLEVY_EE', name: 'Housing Levy (Employee)', type: 'DEDUCTION' },
  { code: 'HLEVY_ER', name: 'Housing Levy (Employer)', type: 'COMPANY_DEDUCTION' },
  { code: 'PAYE', name: 'PAYE', type: 'DEDUCTION' },
  { code: 'NETPAY', name: 'Net Pay', type: 'DEDUCTION' },
  { code: 'LVALLOW', name: 'Leave Allowance', type: 'INCOME' },
  { code: 'LVENC', name: 'Leave Encashment (Exit)', type: 'INCOME' },
  { code: 'GRATUITY', name: 'Gratuity (Exit)', type: 'INCOME' },
  { code: 'NOTICEINC', name: 'Notice Income (Exit)', type: 'INCOME' },
  { code: 'NOTICEPEN', name: 'Notice Penalty (Exit)', type: 'DEDUCTION' },
  { code: 'UNCLEARED', name: 'Uncleared Items (Exit)', type: 'DEDUCTION' },
];

async function ensureSystemTransactionCodes(): Promise<Record<string, number>> {
  const ids: Record<string, number> = {};
  for (const c of SYSTEM_CODES) {
    const row = await one<{ id: number }>('SELECT id FROM payroll_transaction_code WHERE code = ?', c.code);
    if (row) { ids[c.code] = row.id; continue; }
    const info = await run(
      'INSERT INTO payroll_transaction_code (code, name, type, taxable, created_at, created_by) VALUES (?,?,?,?,?,?)',
      c.code, c.name, c.type, false, new Date().toISOString(), 'SYSTEM',
    );
    ids[c.code] = Number(info.lastInsertRowid);
  }
  return ids;
}

/* ================================================================================ calculation */

function daysBetweenInclusive(fromIso: string, toIso: string): number {
  const a = new Date(fromIso + 'T00:00:00Z').getTime();
  const b = new Date(toIso + 'T00:00:00Z').getTime();
  return Math.round((b - a) / 86_400_000) + 1;
}

/** Progressive PAYE — walks the bands in order, taxing only the slice of taxable pay that falls
 *  in each band (a band's `upper_bound_cents` is that band's own width; null = unbounded/last). */
export async function calculatePaye(taxablePayCents: number): Promise<number> {
  const bands = await listPayeBands();
  let remaining = Math.max(0, taxablePayCents);
  let tax = 0;
  for (const band of bands) {
    if (remaining <= 0) break;
    const width = band.upper_bound_cents ?? Infinity;
    const inBand = Math.min(remaining, width);
    tax += inBand * (band.rate_pct / 100);
    remaining -= inBand;
  }
  return Math.round(tax);
}

/** Correct Kenyan NSSF Tier I/II tiered accumulation — sums the contribution owed for the slice
 *  of `baseCents` that falls in each configured tier (the AL source only reads its first tier
 *  row, which is a bug this port does not reproduce). */
export async function calculateNssf(baseCents: number): Promise<{ employee: number; employer: number }> {
  const tiers = await listNssfTiers();
  let employee = 0; let employer = 0;
  for (const tier of tiers) {
    const inTier = Math.max(0, Math.min(baseCents, tier.upper_limit_cents) - tier.lower_limit_cents);
    if (inTier <= 0) continue;
    employee += inTier * (tier.employee_rate_pct / 100);
    employer += inTier * (tier.employer_rate_pct / 100);
  }
  return { employee: Math.round(employee), employer: Math.round(employer) };
}

/** Runs (or re-runs — safe, purges this employee's prior lines for the period first) the full
 *  calculation for one employee in one open period, writing payroll_period_line rows (the
 *  GL-postable payslip) and one payroll_p9_line row. */
export async function runPayrollForEmployee(periodId: number, employeeId: number, user: Actor): Promise<void> {
  return tx(async () => {
    const period = await one<PayrollPeriod>('SELECT * FROM payroll_period WHERE id = ?', periodId);
    if (!period) throw new AppError('Payroll period not found', 'NOT_FOUND');
    if (period.status !== 'OPEN') throw new AppError('Payroll can only be run for an Open period', 'VALIDATION');

    const emp = await getEmployee(employeeId);
    if (!emp) throw new AppError('Employee not found', 'NOT_FOUND');
    if (!emp.posting_group_id) throw new AppError(`${emp.employee_no} has no payroll posting group set`, 'VALIDATION');
    const postingGroup = await one<PayrollPostingGroup>('SELECT * FROM payroll_posting_group WHERE id = ?', emp.posting_group_id);
    if (!postingGroup) throw new AppError('Posting group not found', 'NOT_FOUND');

    const setup = await getPayrollSetup();
    const contract = await getCurrentContract(employeeId);
    const basicPayFull = Number(contract?.salary_cents || 0);
    const sys = await ensureSystemTransactionCodes();

    await run('DELETE FROM payroll_period_line WHERE payroll_period_id = ? AND employee_id = ?', periodId, employeeId);
    await run('DELETE FROM payroll_p9_line WHERE payroll_period_id = ? AND employee_id = ?', periodId, employeeId);

    // Proration for a mid-period joiner — uses the real Monthly Working Days setting.
    let basicPay = basicPayFull;
    if (contract?.start_date && contract.start_date > period.start_date) {
      const workedDays = Math.max(0, daysBetweenInclusive(contract.start_date, period.end_date));
      const ratio = Math.min(1, workedDays / setup.monthly_working_days);
      basicPay = Math.round(basicPayFull * ratio);
    }

    const lines: { transactionCodeId: number; section: string; sortOrder: number; amountCents: number; glAccountId: number; isDebit: boolean }[] = [];
    const addLine = (transactionCodeId: number, section: string, sortOrder: number, amountCents: number, glAccountId: number, isDebit: boolean) => {
      if (amountCents === 0) return;
      lines.push({ transactionCodeId, section, sortOrder, amountCents: Math.round(amountCents), glAccountId, isDebit });
    };

    addLine(sys.BASIC, 'BASIC', 1, basicPay, postingGroup.salary_expense_account_id, true);

    // Recurring earnings — the employee's own configured allowances (upper-limit capped).
    const incomeRows = await all<EmployeePayrollTransactionView>(
      `SELECT t.*, c.name AS transaction_code_name, c.type AS transaction_type
       FROM employee_payroll_transaction t JOIN payroll_transaction_code c ON c.id = t.transaction_code_id
       WHERE t.employee_id = ? AND t.payroll_period_id = ? AND t.stopped = false AND c.type = 'INCOME'`,
      employeeId, periodId,
    );
    let taxableAllowances = 0; let nonTaxableAllowances = 0;
    for (const row of incomeRows) {
      const code = await one<PayrollTransactionCode>('SELECT * FROM payroll_transaction_code WHERE id = ?', row.transaction_code_id);
      if (!code) continue;
      let amount = Number(row.amount_cents);
      if (code.upper_limit_cents != null) amount = Math.min(amount, Number(code.upper_limit_cents));
      if (code.taxable) taxableAllowances += amount; else nonTaxableAllowances += amount;
      const glAccount = code.gl_account_id ?? postingGroup.salary_expense_account_id;
      addLine(code.id, 'ALLOWANCE', 3, amount, glAccount, true);
    }

    const grossPay = basicPay + taxableAllowances + nonTaxableAllowances;
    const taxableGross = basicPay + taxableAllowances;

    // Deductions — statutory-relevant special types (Pension/Insurance/Mortgage) also feed the
    // PAYE relief stack below; every deduction reduces net pay regardless of special type.
    const deductionRows = await all<EmployeePayrollTransactionView>(
      `SELECT t.*, c.name AS transaction_code_name, c.type AS transaction_type
       FROM employee_payroll_transaction t JOIN payroll_transaction_code c ON c.id = t.transaction_code_id
       WHERE t.employee_id = ? AND t.payroll_period_id = ? AND t.stopped = false AND c.type = 'DEDUCTION'`,
      employeeId, periodId,
    );
    let pensionDeduction = 0; let insurancePremium = 0; let mortgageInterest = 0; let otherDeductions = 0;
    const deductionCodeCache = new Map<number, PayrollTransactionCode>();
    for (const row of deductionRows) {
      let code = deductionCodeCache.get(row.transaction_code_id);
      if (!code) {
        const found = await one<PayrollTransactionCode>('SELECT * FROM payroll_transaction_code WHERE id = ?', row.transaction_code_id);
        if (!found) continue;
        code = found; deductionCodeCache.set(row.transaction_code_id, found);
      }
      let amount = Number(row.amount_cents);
      if (code.upper_limit_cents != null) amount = Math.min(amount, Number(code.upper_limit_cents));
      if (code.special_type === 'PENSION') pensionDeduction += amount;
      else if (code.special_type === 'INSURANCE') insurancePremium += amount;
      else if (code.special_type === 'MORTGAGE') mortgageInterest += amount;
      else otherDeductions += amount;

      if (!code.gl_account_id) throw new AppError(`Transaction code ${code.code} has no G/L account configured`, 'VALIDATION');
      addLine(code.id, 'DEDUCTION', 8, amount, code.gl_account_id, false);

      if (code.balance_type === 'REDUCING' && row.balance_cents != null) {
        const newBalance = Math.max(0, Number(row.balance_cents) - amount);
        await run('UPDATE employee_payroll_transaction SET balance_cents = ?, executed_periods = executed_periods + 1 WHERE id = ?', newBalance, row.id);
        if (newBalance === 0) await run('UPDATE employee_payroll_transaction SET stopped = true WHERE id = ?', row.id);
      } else if (row.no_of_periods != null) {
        const executed = row.executed_periods + 1;
        await run('UPDATE employee_payroll_transaction SET executed_periods = ? WHERE id = ?', executed, row.id);
        if (executed >= row.no_of_periods) await run('UPDATE employee_payroll_transaction SET stopped = true WHERE id = ?', row.id);
      }
    }

    // Company (employer) deductions — an employer-side cost, not deducted from the employee's pay.
    const companyRows = await all<EmployeePayrollTransactionView>(
      `SELECT t.*, c.name AS transaction_code_name, c.type AS transaction_type
       FROM employee_payroll_transaction t JOIN payroll_transaction_code c ON c.id = t.transaction_code_id
       WHERE t.employee_id = ? AND t.payroll_period_id = ? AND t.stopped = false AND c.type = 'COMPANY_DEDUCTION'`,
      employeeId, periodId,
    );
    for (const row of companyRows) {
      const code = await one<PayrollTransactionCode>('SELECT * FROM payroll_transaction_code WHERE id = ?', row.transaction_code_id);
      if (!code) continue;
      const amount = Number(row.amount_cents);
      const expenseAccount = code.employer_gl_account_id ?? code.gl_account_id;
      if (!expenseAccount || !code.gl_account_id) throw new AppError(`Company deduction ${code.code} needs both a G/L expense and payable account`, 'VALIDATION');
      addLine(code.id, 'EMPLOYER', 8, amount, expenseAccount, true);
      addLine(code.id, 'EMPLOYER', 8, amount, code.gl_account_id, false);
    }

    // Statutory: NSSF (always on gross), SHIF and Housing Levy (base per Payroll Setup).
    const nssf = await calculateNssf(grossPay);
    addLine(sys.NSSF_EE, 'STATUTORY', 7, nssf.employee, postingGroup.nssf_employee_payable_account_id, false);
    const nssfEmployer = Math.round(nssf.employer * setup.nssf_employer_factor);
    addLine(sys.NSSF_ER, 'EMPLOYER', 7, nssfEmployer, postingGroup.nssf_employer_expense_account_id, true);
    addLine(sys.NSSF_ER, 'EMPLOYER', 7, nssfEmployer, postingGroup.nssf_employer_payable_account_id, false);

    const shifBase = setup.shif_based_on === 'BASIC' ? basicPay : setup.shif_based_on === 'TAXABLE' ? taxableGross : grossPay;
    const shif = Math.round(shifBase * (setup.shif_pct / 100));
    addLine(sys.SHIF, 'STATUTORY', 7, shif, postingGroup.shif_payable_account_id, false);

    let housingLevyEmployee = 0;
    if (setup.housing_levy_enabled) {
      const hlBase = setup.housing_levy_based_on === 'BASIC' ? basicPay : setup.housing_levy_based_on === 'TAXABLE' ? taxableGross : grossPay;
      housingLevyEmployee = Math.round(hlBase * (setup.housing_levy_pct / 100));
      addLine(sys.HLEVY_EE, 'STATUTORY', 7, housingLevyEmployee, postingGroup.housing_levy_employee_payable_account_id, false);
      addLine(sys.HLEVY_ER, 'EMPLOYER', 7, housingLevyEmployee, postingGroup.housing_levy_employer_expense_account_id, true);
      addLine(sys.HLEVY_ER, 'EMPLOYER', 7, housingLevyEmployee, postingGroup.housing_levy_employer_payable_account_id, false);
    }

    // PAYE — taxable pay net of the pension pre-tax deduction, relief stack capped at Max Relief.
    const taxablePay = Math.max(0, taxableGross - pensionDeduction);
    const exempt = (grossPay - nssf.employee) <= setup.minimum_relief_threshold_cents;
    const taxCharged = exempt ? 0 : await calculatePaye(taxablePay);
    const insuranceRelief = Math.round(insurancePremium * (setup.insurance_relief_pct / 100));
    const mortgageRelief = Math.min(mortgageInterest, setup.mortgage_relief_cents);
    const totalRelief = exempt ? 0 : Math.min(setup.personal_relief_cents + insuranceRelief + mortgageRelief, setup.max_relief_cents);
    const paye = exempt ? 0 : Math.max(0, taxCharged - totalRelief);
    addLine(sys.PAYE, 'STATUTORY', 7, paye, postingGroup.paye_payable_account_id, false);

    const netPay = grossPay - nssf.employee - shif - housingLevyEmployee - paye - otherDeductions - pensionDeduction - insurancePremium - mortgageInterest;
    if (netPay < 0) throw new AppError(`${emp.employee_no}'s net pay would be negative — review their deductions`, 'VALIDATION');
    addLine(sys.NETPAY, 'NET', 9, netPay, postingGroup.net_pay_payable_account_id, false);

    for (const l of lines) {
      await run(
        'INSERT INTO payroll_period_line (payroll_period_id, employee_id, transaction_code_id, section, sort_order, amount_cents, gl_account_id, is_debit) VALUES (?,?,?,?,?,?,?,?)',
        periodId, employeeId, l.transactionCodeId, l.section, l.sortOrder, l.amountCents, l.glAccountId, l.isDebit,
      );
    }
    await run(
      `INSERT INTO payroll_p9_line
         (employee_id, payroll_period_id, basic_pay_cents, gross_pay_cents, taxable_pay_cents, tax_charged_cents,
          insurance_relief_cents, personal_relief_cents, paye_cents, nssf_cents, shif_cents, housing_levy_cents,
          deductions_cents, net_pay_cents, created_at)
       VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)`,
      employeeId, periodId, basicPay, grossPay, taxablePay, taxCharged, insuranceRelief,
      exempt ? 0 : setup.personal_relief_cents, paye, nssf.employee, shif, housingLevyEmployee,
      otherDeductions + pensionDeduction + insurancePremium + mortgageInterest, netPay, new Date().toISOString(),
    );
    await audit(user, 'PAYROLL_RUN_EMPLOYEE', 'payroll_period', periodId, { employeeId, netPay });
  });
}

export async function runPayrollForPeriod(periodId: number, user: Actor): Promise<{ processed: number; failed: { employeeId: number; error: string }[] }> {
  const employees = await all<{ id: number }>("SELECT id FROM employee WHERE status IN ('ACTIVE','ON_LEAVE','PENDING_FINAL_PAYMENT') AND posting_group_id IS NOT NULL");
  let processed = 0;
  const failed: { employeeId: number; error: string }[] = [];
  for (const emp of employees) {
    try {
      await runPayrollForEmployee(periodId, emp.id, user);
      processed += 1;
    } catch (err) {
      failed.push({ employeeId: emp.id, error: err instanceof AppError ? err.message : 'Unexpected error' });
    }
  }
  return { processed, failed };
}

/* ============================================================================ period lifecycle */

export const listPayrollPeriods = (): Promise<PayrollPeriod[]> => all('SELECT * FROM payroll_period ORDER BY start_date DESC');
export const getPayrollPeriod = (id: number): Promise<PayrollPeriod | undefined> => one('SELECT * FROM payroll_period WHERE id = ?', id);
export const getOpenPayrollPeriod = (): Promise<PayrollPeriod | undefined> => one("SELECT * FROM payroll_period WHERE status = 'OPEN'");

export async function createPayrollPeriod(input: { periodName: string; startDate: string; endDate: string }, user: Actor): Promise<{ id: number }> {
  if (await one("SELECT 1 FROM payroll_period WHERE status IN ('OPEN','PENDING_APPROVAL')")) {
    throw new AppError('There is already an Open or Pending Approval payroll period', 'VALIDATION');
  }
  const info = await run(
    'INSERT INTO payroll_period (period_name, start_date, end_date, created_at, created_by) VALUES (?,?,?,?,?)',
    input.periodName.trim(), input.startDate, input.endDate, new Date().toISOString(), user.username,
  );
  await audit(user, 'PAYROLL_PERIOD_CREATE', 'payroll_period', info.lastInsertRowid, {});
  return { id: Number(info.lastInsertRowid) };
}

export async function submitPayrollPeriod(id: number, user: Actor): Promise<{ autoApproved: boolean }> {
  const period = await getPayrollPeriod(id);
  if (!period) throw new AppError('Not found', 'NOT_FOUND');
  if (period.status !== 'OPEN') throw new AppError('Only an open period can be submitted for approval', 'VALIDATION');
  if (!(await one('SELECT 1 FROM payroll_period_line WHERE payroll_period_id = ?', id))) {
    throw new AppError('Run payroll for at least one employee first', 'VALIDATION');
  }
  const matched = await findMatchingWorkflow('PAYROLL_PERIOD', await pickConditionFields('PAYROLL_PERIOD', period));
  if (!matched) throw new AppError('There is no enabled workflow for this document', 'NO_WORKFLOW');
  await tx(async () => {
    await run("UPDATE payroll_period SET status = 'PENDING_APPROVAL' WHERE id = ?", id);
    await startWorkflow(matched.workflow, matched.steps, { documentType: 'PAYROLL_PERIOD', entityId: String(id), requestedBy: user.username, amount: 0 });
  });
  const after = await getPayrollPeriod(id);
  return { autoApproved: after?.status === 'APPROVED' };
}

export async function cancelPayrollPeriodApproval(id: number, user: Actor): Promise<void> {
  const period = await getPayrollPeriod(id);
  if (!period) throw new AppError('Not found', 'NOT_FOUND');
  if (period.status !== 'PENDING_APPROVAL') throw new AppError('Only a period pending approval can be recalled', 'VALIDATION');
  const routed = await findPendingRoutedTask('PAYROLL_PERIOD', String(id));
  const requestedBy = routed?.requested_by ?? period.created_by;
  if (requestedBy !== user.username) throw new AppError('Only the person who submitted this can cancel it', 'NOT_REQUESTER');
  await run("UPDATE payroll_period SET status = 'OPEN' WHERE id = ?", id);
  await audit(user, 'PAYROLL_PERIOD_CANCEL_APPROVAL', 'payroll_period', id, {});
}

export async function approvePayrollPeriod(id: number, user: Actor): Promise<void> {
  const period = await getPayrollPeriod(id);
  if (!period) throw new AppError('Not found', 'NOT_FOUND');
  if (period.status !== 'PENDING_APPROVAL') throw new AppError('Only a period pending approval can be approved', 'VALIDATION');
  await run("UPDATE payroll_period SET status = 'APPROVED', decision_reason = NULL WHERE id = ?", id);
  await audit(user, 'PAYROLL_PERIOD_APPROVE', 'payroll_period', id, {});
}

export async function rejectPayrollPeriod(id: number, reason: string | null, user: Actor): Promise<void> {
  if (!reason?.trim()) throw new AppError('A reason is required', 'VALIDATION');
  const period = await getPayrollPeriod(id);
  if (!period) throw new AppError('Not found', 'NOT_FOUND');
  if (period.status !== 'PENDING_APPROVAL') throw new AppError('Only a period pending approval can be rejected', 'VALIDATION');
  await run("UPDATE payroll_period SET status = 'OPEN', decision_reason = ? WHERE id = ?", reason, id);
  await audit(user, 'PAYROLL_PERIOD_REJECT', 'payroll_period', id, { reason });
}

/** Approved -> posts one balanced journal for the whole period (aggregated by G/L account) and
 *  rolls every recurring, non-temporary employee_payroll_transaction line forward into a newly
 *  opened next period. */
export async function closePayrollPeriod(id: number, nextPeriod: { periodName: string; startDate: string; endDate: string }, user: Actor): Promise<{ nextPeriodId: number; journalNo: string }> {
  return tx(async () => {
    const period = await getPayrollPeriod(id);
    if (!period) throw new AppError('Not found', 'NOT_FOUND');
    if (period.status !== 'APPROVED') throw new AppError('Only an approved period can be closed', 'VALIDATION');

    const lines = await all<{ gl_account_id: number | null; is_debit: boolean; total: string }>(
      'SELECT gl_account_id, is_debit, SUM(amount_cents) AS total FROM payroll_period_line WHERE payroll_period_id = ? GROUP BY gl_account_id, is_debit',
      id,
    );
    const journalLines = lines.filter((l) => l.gl_account_id != null).map((l) => ({
      account: l.gl_account_id!,
      debit: l.is_debit ? Number(l.total) : undefined,
      credit: !l.is_debit ? Number(l.total) : undefined,
      narration: `Payroll ${period.period_name}`,
    }));
    const posted = await postJournal({
      valueDate: period.end_date, module: 'PAYROLL', eventType: 'PAYROLL_PERIOD_CLOSE',
      description: `Payroll — ${period.period_name}`, reference: period.period_name,
      lines: journalLines, user, idempotencyKey: `PAYROLL-${id}`,
    });
    // Imprest recoveries and claim reimbursements on this payroll settle the employee subledger.
    await settleImprestsFromPayroll(id, period.end_date, posted.id, user);

    const info = await run(
      'INSERT INTO payroll_period (period_name, start_date, end_date, created_at, created_by) VALUES (?,?,?,?,?)',
      nextPeriod.periodName.trim(), nextPeriod.startDate, nextPeriod.endDate, new Date().toISOString(), user.username,
    );
    const nextPeriodId = Number(info.lastInsertRowid);

    const recurring = await all<{ id: number; employee_id: number; transaction_code_id: number; amount_cents: number; original_amount_cents: number | null; balance_cents: number | null; no_of_periods: number | null; executed_periods: number; stopped: boolean; temporary: boolean; notes: string | null }>(
      'SELECT * FROM employee_payroll_transaction WHERE payroll_period_id = ? AND temporary = false AND stopped = false', id,
    );
    for (const r of recurring) {
      await run(
        `INSERT INTO employee_payroll_transaction
           (employee_id, transaction_code_id, payroll_period_id, amount_cents, original_amount_cents, balance_cents,
            no_of_periods, executed_periods, temporary, notes, created_at, created_by)
         VALUES (?,?,?,?,?,?,?,?,false,?,?,?)`,
        r.employee_id, r.transaction_code_id, nextPeriodId, r.amount_cents, r.original_amount_cents, r.balance_cents,
        r.no_of_periods, r.executed_periods, r.notes, new Date().toISOString(), user.username,
      );
    }

    await run("UPDATE payroll_period SET status = 'CLOSED', closed_at = ?, closed_by = ? WHERE id = ?", new Date().toISOString(), user.username, id);
    await audit(user, 'PAYROLL_PERIOD_CLOSE', 'payroll_period', id, { nextPeriodId, journalNo: posted.journal_no });
    return { nextPeriodId, journalNo: posted.journal_no };
  });
}

/* ==================================================================== employee payroll lines */

export const listEmployeeTransactions = (employeeId: number, periodId: number): Promise<EmployeePayrollTransactionView[]> =>
  all(
    `SELECT t.*, c.name AS transaction_code_name, c.type AS transaction_type
     FROM employee_payroll_transaction t JOIN payroll_transaction_code c ON c.id = t.transaction_code_id
     WHERE t.employee_id = ? AND t.payroll_period_id = ? ORDER BY c.name`,
    employeeId, periodId,
  );

export const listPeriodLines = (periodId: number, employeeId?: number): Promise<PayrollPeriodLineView[]> =>
  all(
    `SELECT l.*, c.name AS transaction_code_name, e.employee_no, e.first_name AS employee_first_name, e.last_name AS employee_last_name
     FROM payroll_period_line l JOIN payroll_transaction_code c ON c.id = l.transaction_code_id JOIN employee e ON e.id = l.employee_id
     WHERE l.payroll_period_id = ? ${employeeId ? 'AND l.employee_id = ?' : ''} ORDER BY e.first_name, l.sort_order`,
    ...(employeeId ? [periodId, employeeId] : [periodId]),
  );

export interface EmployeeTransactionInput {
  employeeId: number; periodId: number; transactionCodeId: number; amountCents: number;
  originalAmountCents?: number | null; noOfPeriods?: number | null; temporary?: boolean; notes?: string | null;
}

export async function addEmployeeTransaction(input: EmployeeTransactionInput, user: Actor): Promise<{ id: number }> {
  const period = await getPayrollPeriod(input.periodId);
  if (!period || period.status !== 'OPEN') throw new AppError('Transactions can only be added to an Open period', 'VALIDATION');
  const code = await one<PayrollTransactionCode>('SELECT * FROM payroll_transaction_code WHERE id = ?', input.transactionCodeId);
  if (!code) throw new AppError('Transaction code not found', 'NOT_FOUND');
  const info = await run(
    `INSERT INTO employee_payroll_transaction
       (employee_id, transaction_code_id, payroll_period_id, amount_cents, original_amount_cents, balance_cents,
        no_of_periods, temporary, notes, created_at, created_by)
     VALUES (?,?,?,?,?,?,?,?,?,?,?)`,
    input.employeeId, input.transactionCodeId, input.periodId, Math.round(input.amountCents),
    input.originalAmountCents != null ? Math.round(input.originalAmountCents) : null,
    code.balance_type === 'REDUCING' ? Math.round(input.originalAmountCents ?? input.amountCents) : null,
    input.noOfPeriods ?? null, !!input.temporary, input.notes?.trim() || null, new Date().toISOString(), user.username,
  );
  await audit(user, 'PAYROLL_EMPLOYEE_TRANSACTION_ADD', 'employee_payroll_transaction', info.lastInsertRowid, {});
  return { id: Number(info.lastInsertRowid) };
}

export async function removeEmployeeTransaction(id: number, user: Actor): Promise<void> {
  const row = await one<{ payroll_period_id: number }>('SELECT payroll_period_id FROM employee_payroll_transaction WHERE id = ?', id);
  if (!row) throw new AppError('Not found', 'NOT_FOUND');
  const period = await getPayrollPeriod(row.payroll_period_id);
  if (!period || period.status !== 'OPEN') throw new AppError('Transactions can only be removed from an Open period', 'VALIDATION');
  await run('DELETE FROM employee_payroll_transaction WHERE id = ?', id);
  await audit(user, 'PAYROLL_EMPLOYEE_TRANSACTION_REMOVE', 'employee_payroll_transaction', id, {});
}

export async function stopEmployeeTransaction(id: number, stopped: boolean, user: Actor): Promise<void> {
  await run('UPDATE employee_payroll_transaction SET stopped = ? WHERE id = ?', stopped, id);
  await audit(user, 'PAYROLL_EMPLOYEE_TRANSACTION_STOP', 'employee_payroll_transaction', id, { stopped });
}

/* ======================================================================= cross-module hooks */

/** Leave Management hook: a leave application flagged `leave_allowance_payable` credits the
 *  employee's grade-based Leave Allowance amount into the currently open payroll period, once
 *  (skipped silently if there is no open period yet — the next run's operator adds it manually). */
export async function applyLeaveAllowance(employeeId: number, user: Actor): Promise<void> {
  const period = await getOpenPayrollPeriod();
  if (!period) return;
  const emp = await getEmployee(employeeId);
  if (!emp?.job_grade_id) return;
  const grade = await one<{ leave_allowance_amount: number }>('SELECT leave_allowance_amount FROM hr_job_grade WHERE id = ?', emp.job_grade_id);
  if (!grade || !(Number(grade.leave_allowance_amount) > 0)) return;
  const sys = await ensureSystemTransactionCodes();
  const already = await one(
    'SELECT 1 FROM employee_payroll_transaction WHERE employee_id = ? AND payroll_period_id = ? AND transaction_code_id = ?',
    employeeId, period.id, sys.LVALLOW,
  );
  if (already) return;
  await addEmployeeTransaction({
    employeeId, periodId: period.id, transactionCodeId: sys.LVALLOW, amountCents: Number(grade.leave_allowance_amount),
    temporary: true, notes: 'Leave allowance on approved annual leave',
  }, user);
}

/* ================================================================================== reports */

export interface PayslipData {
  employee: { id: number; employee_no: string; first_name: string; last_name: string; job_title: string | null };
  period: PayrollPeriod;
  lines: { section: string; code: string; name: string; amountCents: number; isDebit: boolean }[];
  p9: import('./types.ts').PayrollP9Line | undefined;
}

/** One employee's printable payslip for a period — every posted line grouped by section, plus
 *  the P9 summary row that run produced. */
export async function getPayslip(periodId: number, employeeId: number): Promise<PayslipData> {
  const [period, emp, lines, p9] = await Promise.all([
    getPayrollPeriod(periodId),
    one<{ id: number; employee_no: string; first_name: string; last_name: string; job_title: string | null }>(
      'SELECT id, employee_no, first_name, last_name, job_title FROM employee WHERE id = ?', employeeId,
    ),
    all<{ section: string; code: string; name: string; amount_cents: number; is_debit: boolean }>(
      `SELECT l.section, c.code, c.name, l.amount_cents, l.is_debit
       FROM payroll_period_line l JOIN payroll_transaction_code c ON c.id = l.transaction_code_id
       WHERE l.payroll_period_id = ? AND l.employee_id = ? ORDER BY l.sort_order, c.name`,
      periodId, employeeId,
    ),
    one<import('./types.ts').PayrollP9Line>('SELECT * FROM payroll_p9_line WHERE payroll_period_id = ? AND employee_id = ?', periodId, employeeId),
  ]);
  if (!period) throw new AppError('Payroll period not found', 'NOT_FOUND');
  if (!emp) throw new AppError('Employee not found', 'NOT_FOUND');
  return {
    employee: emp, period,
    lines: lines.map((l) => ({ section: l.section, code: l.code, name: l.name, amountCents: Number(l.amount_cents), isDebit: l.is_debit })),
    p9,
  };
}

export interface NetPayReportRow { employeeId: number; employeeNo: string; name: string; grossPayCents: number; totalDeductionsCents: number; netPayCents: number }

/** Net Pay Report — one row per employee: gross pay, everything withheld, and net pay. */
export async function getNetPayReport(periodId: number): Promise<NetPayReportRow[]> {
  const rows = await all<{ id: number; employee_no: string; name: string; gross: number; net: number }>(
    `SELECT e.id, e.employee_no, (e.first_name || ' ' || e.last_name) AS name,
            COALESCE(p9.gross_pay_cents, 0) AS gross, COALESCE(p9.net_pay_cents, 0) AS net
     FROM employee e JOIN payroll_p9_line p9 ON p9.employee_id = e.id AND p9.payroll_period_id = ?
     ORDER BY e.first_name, e.last_name`,
    periodId,
  );
  return rows.map((r) => ({
    employeeId: r.id, employeeNo: r.employee_no, name: r.name,
    grossPayCents: Number(r.gross), netPayCents: Number(r.net),
    totalDeductionsCents: Number(r.gross) - Number(r.net),
  }));
}

export interface StatutoryReportRow { employeeId: number; employeeNo: string; name: string; amountCents: number }

/** NSSF / SHIF (or any system code) remittance listing — one row per employee who has a line
 *  for that code in the period. */
async function getStatutoryReport(periodId: number, systemCode: string): Promise<StatutoryReportRow[]> {
  const rows = await all<{ id: number; employee_no: string; name: string; amount: number }>(
    `SELECT e.id, e.employee_no, (e.first_name || ' ' || e.last_name) AS name, l.amount_cents AS amount
     FROM payroll_period_line l
     JOIN payroll_transaction_code c ON c.id = l.transaction_code_id
     JOIN employee e ON e.id = l.employee_id
     WHERE l.payroll_period_id = ? AND c.code = ? ORDER BY e.first_name, e.last_name`,
    periodId, systemCode,
  );
  return rows.map((r) => ({ employeeId: r.id, employeeNo: r.employee_no, name: r.name, amountCents: Number(r.amount) }));
}
export const getNssfReport = (periodId: number): Promise<StatutoryReportRow[]> => getStatutoryReport(periodId, 'NSSF_EE');
export const getShifReport = (periodId: number): Promise<StatutoryReportRow[]> => getStatutoryReport(periodId, 'SHIF');
export const getPayeReport = (periodId: number): Promise<StatutoryReportRow[]> => getStatutoryReport(periodId, 'PAYE');
export const getHousingLevyReport = (periodId: number): Promise<StatutoryReportRow[]> => getStatutoryReport(periodId, 'HLEVY_EE');

export interface CompanySummaryReport {
  period: PayrollPeriod; employeeCount: number;
  grossPayCents: number; taxablePayCents: number; payeCents: number; nssfEmployeeCents: number; nssfEmployerCents: number;
  shifCents: number; housingLevyEmployeeCents: number; housingLevyEmployerCents: number; deductionsCents: number; netPayCents: number;
  byDepartment: { name: string; employeeCount: number; grossPayCents: number; netPayCents: number }[];
}

/** Company Summary — the whole period's statutory + net-pay totals, plus a per-department
 *  breakdown, for the approver's overview before Approve/Close. */
export async function getCompanySummary(periodId: number): Promise<CompanySummaryReport> {
  const period = await getPayrollPeriod(periodId);
  if (!period) throw new AppError('Payroll period not found', 'NOT_FOUND');

  const totals = await one<{
    n: number; gross: number; taxable: number; paye: number; nssf: number; shif: number; hlevy: number; deductions: number; net: number;
  }>(
    `SELECT COUNT(*) AS n, COALESCE(SUM(gross_pay_cents),0) AS gross, COALESCE(SUM(taxable_pay_cents),0) AS taxable,
            COALESCE(SUM(paye_cents),0) AS paye, COALESCE(SUM(nssf_cents),0) AS nssf, COALESCE(SUM(shif_cents),0) AS shif,
            COALESCE(SUM(housing_levy_cents),0) AS hlevy, COALESCE(SUM(deductions_cents),0) AS deductions,
            COALESCE(SUM(net_pay_cents),0) AS net
     FROM payroll_p9_line WHERE payroll_period_id = ?`,
    periodId,
  );
  const nssfEmployer = await one<{ v: number }>(
    `SELECT COALESCE(SUM(l.amount_cents),0) AS v FROM payroll_period_line l JOIN payroll_transaction_code c ON c.id = l.transaction_code_id
     WHERE l.payroll_period_id = ? AND c.code = 'NSSF_ER' AND l.is_debit = true`,
    periodId,
  );
  const hlevyEmployer = await one<{ v: number }>(
    `SELECT COALESCE(SUM(l.amount_cents),0) AS v FROM payroll_period_line l JOIN payroll_transaction_code c ON c.id = l.transaction_code_id
     WHERE l.payroll_period_id = ? AND c.code = 'HLEVY_ER' AND l.is_debit = true`,
    periodId,
  );
  const byDept = await all<{ name: string; n: number; gross: number; net: number }>(
    `SELECT COALESCE(gd2.name, 'Unassigned') AS name, COUNT(*) AS n,
            COALESCE(SUM(p9.gross_pay_cents),0) AS gross, COALESCE(SUM(p9.net_pay_cents),0) AS net
     FROM payroll_p9_line p9 JOIN employee e ON e.id = p9.employee_id
     LEFT JOIN global_dimension_2_value gd2 ON gd2.id = e.global_dimension_2_id
     WHERE p9.payroll_period_id = ? GROUP BY gd2.name ORDER BY gross DESC`,
    periodId,
  );

  return {
    period, employeeCount: Number(totals?.n ?? 0), grossPayCents: Number(totals?.gross ?? 0),
    taxablePayCents: Number(totals?.taxable ?? 0), payeCents: Number(totals?.paye ?? 0),
    nssfEmployeeCents: Number(totals?.nssf ?? 0), nssfEmployerCents: Number(nssfEmployer?.v ?? 0),
    shifCents: Number(totals?.shif ?? 0),
    housingLevyEmployeeCents: Number(totals?.hlevy ?? 0), housingLevyEmployerCents: Number(hlevyEmployer?.v ?? 0),
    deductionsCents: Number(totals?.deductions ?? 0), netPayCents: Number(totals?.net ?? 0),
    byDepartment: byDept.map((d) => ({ name: d.name, employeeCount: Number(d.n), grossPayCents: Number(d.gross), netPayCents: Number(d.net) })),
  };
}

export interface PayrollRegisterRow {
  employeeId: number; employeeNo: string; name: string;
  basicCents: number; allowancesCents: number; grossCents: number; taxableCents: number;
  payeCents: number; nssfCents: number; shifCents: number; housingLevyCents: number;
  deductionsCents: number; netCents: number;
}

/** Payroll Register — the master report, one wide row per employee covering every figure on
 *  their payslip for the period. */
export async function getPayrollRegister(periodId: number): Promise<PayrollRegisterRow[]> {
  const [p9Rows, basicAllowance] = await Promise.all([
    all<{ employee_id: number; employee_no: string; name: string; basic: number; gross: number; taxable: number; paye: number; nssf: number; shif: number; hlevy: number; deductions: number; net: number }>(
      `SELECT p9.employee_id, e.employee_no, (e.first_name || ' ' || e.last_name) AS name,
              p9.basic_pay_cents AS basic, p9.gross_pay_cents AS gross, p9.taxable_pay_cents AS taxable,
              p9.paye_cents AS paye, p9.nssf_cents AS nssf, p9.shif_cents AS shif, p9.housing_levy_cents AS hlevy,
              p9.deductions_cents AS deductions, p9.net_pay_cents AS net
       FROM payroll_p9_line p9 JOIN employee e ON e.id = p9.employee_id
       WHERE p9.payroll_period_id = ? ORDER BY e.first_name, e.last_name`,
      periodId,
    ),
    all<{ employee_id: number; total: number }>(
      "SELECT employee_id, COALESCE(SUM(amount_cents),0) AS total FROM payroll_period_line WHERE payroll_period_id = ? AND section = 'ALLOWANCE' GROUP BY employee_id",
      periodId,
    ),
  ]);
  const allowanceByEmployee = new Map(basicAllowance.map((r) => [r.employee_id, Number(r.total)]));
  return p9Rows.map((r) => ({
    employeeId: r.employee_id, employeeNo: r.employee_no, name: r.name,
    basicCents: Number(r.basic), allowancesCents: allowanceByEmployee.get(r.employee_id) ?? 0,
    grossCents: Number(r.gross), taxableCents: Number(r.taxable), payeCents: Number(r.paye),
    nssfCents: Number(r.nssf), shifCents: Number(r.shif), housingLevyCents: Number(r.hlevy),
    deductionsCents: Number(r.deductions), netCents: Number(r.net),
  }));
}

export interface DeductionsReportRow { employeeId: number; employeeNo: string; name: string; code: string; codeName: string; amountCents: number }

/** Deductions Report — every non-statutory deduction line (loans, welfare, insurance, ...) per
 *  employee, for remitting to whichever third party each code represents. */
export async function getDeductionsReport(periodId: number): Promise<DeductionsReportRow[]> {
  const rows = await all<{ employee_id: number; employee_no: string; name: string; code: string; code_name: string; amount: number }>(
    `SELECT l.employee_id, e.employee_no, (e.first_name || ' ' || e.last_name) AS name, c.code, c.name AS code_name, l.amount_cents AS amount
     FROM payroll_period_line l
     JOIN payroll_transaction_code c ON c.id = l.transaction_code_id
     JOIN employee e ON e.id = l.employee_id
     WHERE l.payroll_period_id = ? AND l.section = 'DEDUCTION'
       AND c.code NOT IN ('NSSF_EE','SHIF','HLEVY_EE','PAYE')
     ORDER BY e.first_name, e.last_name, c.name`,
    periodId,
  );
  return rows.map((r) => ({ employeeId: r.employee_id, employeeNo: r.employee_no, name: r.name, code: r.code, codeName: r.code_name, amountCents: Number(r.amount) }));
}

export interface P9AnnualRow {
  periodName: string; grossCents: number; taxableCents: number; payeCents: number; nssfCents: number;
  shifCents: number; personalReliefCents: number; insuranceReliefCents: number; netCents: number;
}

/** KRA P9 — one employee's monthly breakdown for a calendar year, for the annual tax
 *  certificate. `year` is a 4-digit string (e.g. "2026"), matched against the payroll period's
 *  own name (YYYY-MM) or its start date. */
export async function getP9Annual(employeeId: number, year: string): Promise<{ employee: { employee_no: string; first_name: string; last_name: string; kra_pin: string | null }; rows: P9AnnualRow[]; totals: P9AnnualRow }> {
  const employee = await one<{ employee_no: string; first_name: string; last_name: string; kra_pin: string | null }>(
    'SELECT employee_no, first_name, last_name, kra_pin FROM employee WHERE id = ?', employeeId,
  );
  if (!employee) throw new AppError('Employee not found', 'NOT_FOUND');
  const rows = await all<{ period_name: string; gross: number; taxable: number; paye: number; nssf: number; shif: number; relief: number; ins_relief: number; net: number }>(
    `SELECT pp.period_name, p9.gross_pay_cents AS gross, p9.taxable_pay_cents AS taxable, p9.paye_cents AS paye,
            p9.nssf_cents AS nssf, p9.shif_cents AS shif, p9.personal_relief_cents AS relief,
            p9.insurance_relief_cents AS ins_relief, p9.net_pay_cents AS net
     FROM payroll_p9_line p9 JOIN payroll_period pp ON pp.id = p9.payroll_period_id
     WHERE p9.employee_id = ? AND (pp.period_name LIKE ? OR pp.start_date LIKE ?)
     ORDER BY pp.start_date`,
    employeeId, `${year}-%`, `${year}-%`,
  );
  const mapped = rows.map((r) => ({
    periodName: r.period_name, grossCents: Number(r.gross), taxableCents: Number(r.taxable), payeCents: Number(r.paye),
    nssfCents: Number(r.nssf), shifCents: Number(r.shif), personalReliefCents: Number(r.relief),
    insuranceReliefCents: Number(r.ins_relief), netCents: Number(r.net),
  }));
  const totals = mapped.reduce<P9AnnualRow>((a, r) => ({
    periodName: 'Total', grossCents: a.grossCents + r.grossCents, taxableCents: a.taxableCents + r.taxableCents,
    payeCents: a.payeCents + r.payeCents, nssfCents: a.nssfCents + r.nssfCents, shifCents: a.shifCents + r.shifCents,
    personalReliefCents: a.personalReliefCents + r.personalReliefCents, insuranceReliefCents: a.insuranceReliefCents + r.insuranceReliefCents,
    netCents: a.netCents + r.netCents,
  }), { periodName: 'Total', grossCents: 0, taxableCents: 0, payeCents: 0, nssfCents: 0, shifCents: 0, personalReliefCents: 0, insuranceReliefCents: 0, netCents: 0 });
  return { employee, rows: mapped, totals };
}

/** Employee Exit hook: once every clearance section is cleared, the exit's final-dues lines are
 *  pushed into the currently open payroll period as one-off transactions. */
export async function transferExitDuesToPayroll(exitNo: string, user: Actor): Promise<{ transferred: number }> {
  const period = await getOpenPayrollPeriod();
  if (!period) return { transferred: 0 };
  const exit = await one<{ employee_id: number }>('SELECT employee_id FROM employee_exit WHERE no = ?', exitNo);
  if (!exit) throw new AppError('Exit not found', 'NOT_FOUND');
  const dueLines = await all<{ due_type: EmployeeExitDueType; amount_cents: number }>(
    'SELECT due_type, amount_cents FROM employee_exit_final_due_line WHERE exit_no = ?', exitNo,
  );
  const sys = await ensureSystemTransactionCodes();
  const codeFor: Record<EmployeeExitDueType, string> = {
    LEAVE_ENCASHMENT: 'LVENC', NOTICE_PENALTY: 'NOTICEPEN', NOTICE_INCOME: 'NOTICEINC',
    GRATUITY: 'GRATUITY', UNCLEARED_ITEMS: 'UNCLEARED',
  };
  let transferred = 0;
  for (const line of dueLines) {
    if (!(Number(line.amount_cents) > 0)) continue;
    await addEmployeeTransaction({
      employeeId: exit.employee_id, periodId: period.id, transactionCodeId: sys[codeFor[line.due_type]],
      amountCents: Number(line.amount_cents), temporary: true, notes: `Final settlement — ${exitNo}`,
    }, user);
    transferred += 1;
  }
  return { transferred };
}
