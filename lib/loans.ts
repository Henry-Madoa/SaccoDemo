/*
 * Loan mathematics: amortisation schedules and repayment allocation.
 * All amounts are integer minor units (cents). Rounding drift is absorbed by
 * the final installment so that sum(principal_due) === principal exactly.
 *
 * Pure functions — no database access — so they are safe to import from both
 * server code and client components (the schedule preview runs in the browser).
 */
import type {
  Cents, Classification, InterestMethod, IsoDate, LoanScheduleRow,
  RepaymentAllocation, Schedule, ScheduleDraftRow,
} from './types.ts';

export function addMonths(isoDate: IsoDate, n: number): IsoDate {
  const d = new Date(isoDate + 'T00:00:00Z');
  const day = d.getUTCDate();
  d.setUTCDate(1);
  d.setUTCMonth(d.getUTCMonth() + n);
  const lastDay = new Date(Date.UTC(d.getUTCFullYear(), d.getUTCMonth() + 1, 0)).getUTCDate();
  d.setUTCDate(Math.min(day, lastDay));
  return d.toISOString().slice(0, 10);
}

/**
 * Build an amortisation schedule.
 * @param principal  minor units
 * @param annualRate percent per annum
 * @param months     term
 * @param firstDue   YYYY-MM-DD
 */
export function buildSchedule(
  principal: Cents,
  annualRate: number,
  months: number,
  method: InterestMethod,
  firstDue: IsoDate,
): Schedule {
  if (principal <= 0) throw new Error('Principal must be positive');
  if (months <= 0) throw new Error('Term must be at least one month');

  const r = annualRate / 100 / 12;
  const rows: ScheduleDraftRow[] = [];

  if (method === 'FLAT') {
    const totalFlatInterest = Math.round((principal * (annualRate / 100) * months) / 12);
    const basePrincipal = Math.floor(principal / months);
    const baseInterest = Math.floor(totalFlatInterest / months);
    let pRem = principal;
    let iRem = totalFlatInterest;
    let opening = principal;
    for (let i = 1; i <= months; i++) {
      const pDue = i === months ? pRem : basePrincipal;
      const iDue = i === months ? iRem : baseInterest;
      rows.push({
        installment_no: i,
        due_date: addMonths(firstDue, i - 1),
        opening_balance: opening,
        principal_due: pDue,
        interest_due: iDue,
      });
      pRem -= pDue; iRem -= iDue; opening -= pDue;
    }
  } else {
    // Reducing balance, equal total installment (EMI)
    const emi = r === 0
      ? Math.round(principal / months)
      : Math.round((principal * r) / (1 - Math.pow(1 + r, -months)));

    let balance = principal;
    for (let i = 1; i <= months; i++) {
      const interest = Math.round(balance * r);
      let principalPart = emi - interest;
      if (i === months || principalPart >= balance) principalPart = balance;
      rows.push({
        installment_no: i,
        due_date: addMonths(firstDue, i - 1),
        opening_balance: balance,
        principal_due: principalPart,
        interest_due: interest,
      });
      balance -= principalPart;
      // Fully amortised early (can happen with rounding); stop here.
      if (balance <= 0) break;
    }
    // Guarantee the schedule fully repays principal
    const sumP = rows.reduce((a, x) => a + x.principal_due, 0);
    if (sumP !== principal) rows[rows.length - 1].principal_due += principal - sumP;
  }

  return {
    rows,
    totalPrincipal: rows.reduce((a, x) => a + x.principal_due, 0),
    totalInterest: rows.reduce((a, x) => a + x.interest_due, 0),
    installment: rows.length ? rows[0].principal_due + rows[0].interest_due : 0,
  };
}

/**
 * Allocate a repayment across outstanding installments.
 *
 * The waterfall runs installment by installment, oldest first, settling the
 * interest then the principal of each instalment before moving to the next.
 * (Penalties are settled by the caller before this is reached.) Clearing the
 * whole schedule's interest first would starve the earliest instalment of
 * principal and push a member who paid exactly their instalment into arrears.
 */
export function allocateRepayment(schedule: LoanScheduleRow[], amount: Cents): RepaymentAllocation {
  let remaining = amount;
  const allocations: RepaymentAllocation['allocations'] = [];
  let interest = 0;
  let principal = 0;

  for (const s of schedule) {
    if (remaining <= 0) break;
    const owedI = Math.max(s.interest_due - s.interest_paid, 0);
    const owedP = Math.max(s.principal_due - s.principal_paid, 0);
    if (owedI === 0 && owedP === 0) continue;

    const payI = Math.min(owedI, remaining);
    remaining -= payI;
    const payP = Math.min(owedP, remaining);
    remaining -= payP;

    if (payI || payP) {
      allocations.push({ installment_no: s.installment_no, interest: payI, principal: payP });
      interest += payI;
      principal += payP;
    }
  }

  return { allocations, interest, principal, unallocated: remaining };
}

/** Days between two ISO dates. */
export function daysBetween(a: IsoDate, b: IsoDate): number {
  return Math.floor((new Date(b + 'T00:00:00Z').getTime() - new Date(a + 'T00:00:00Z').getTime()) / 86400000);
}

/** SASRA-style risk classification from days in arrears. */
export function classify(days: number): Classification {
  if (days <= 30) return 'PERFORMING';
  if (days <= 180) return 'WATCH';
  if (days <= 360) return 'SUBSTANDARD';
  if (days <= 540) return 'DOUBTFUL';
  return 'LOSS';
}

export const PROVISION_RATE: Record<Classification, number> = {
  PERFORMING: 0, WATCH: 0.05, SUBSTANDARD: 0.25, DOUBTFUL: 0.5, LOSS: 1,
};

export const CLASSIFICATION_ORDER: Classification[] =
  ['PERFORMING', 'WATCH', 'SUBSTANDARD', 'DOUBTFUL', 'LOSS'];
