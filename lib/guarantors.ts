/*
 * Guarantee-capacity engine — how much of another member's loan a member qualifies to
 * guarantee, and how much of their own loan their own deposits can secure. Mirrors the AL
 * reference's Cod52204008.LoansManagement.al: GetNonSelfGuaranteeEligibility (line 2116) and
 * GetSelfGuaranteeEligibility (line 2042), driven by two global setup multipliers
 * (Guarantor Multiplier / Self Guarantor Multiplier — Tab-Ext52204001.GeneralLedgerSetupCBS.al),
 * both defaulting to 1 when unset.
 */
import { all, one } from './db.ts';
import { getOrg } from './org.ts';
import type { Cents } from './types.ts';

/** Deposits that count toward guarantee capacity — the same "counts as loan security" set the
 *  deposit-multiplier ceiling already uses (lib/loanService.ts's loanableDeposits()), kept as
 *  its own query here rather than a cross-import to avoid a loanService.ts <-> guarantors.ts
 *  import cycle (loanService.ts calls into this module for appraise()/commitGuarantor()). */
async function memberDeposits(memberId: number): Promise<Cents> {
  return (await one<{ s: Cents }>(
    `SELECT COALESCE(SUM(sa.balance),0) s FROM savings_account sa
     JOIN savings_product p ON p.id = sa.product_id
     WHERE sa.member_id = ? AND p.is_loanable_base = 1 AND sa.status <> 'CLOSED'`,
    memberId,
  ))!.s;
}

/** Self vs non-self split of a member's currently COMMITTED guarantee exposure, each row
 *  pro-rated by the guaranteed loan's current outstanding balance and capped at what was
 *  actually committed (a loan that hasn't disbursed yet contributes 0 — nothing is at stake
 *  until money has actually moved). Mirrors GetSelfGuaranteeAmount/GetMemberOutstandingGuarantee
 *  (Cod52204008.LoansManagement.al:2095-2157), simplified to skip AL's further clamp against
 *  the guaranteed loan's *combined* Total Guarantees across every guarantor — a defensive clamp
 *  there, not a meaningful business rule for one guarantor's own exposure. */
async function guaranteeSplit(memberId: number): Promise<{ self: Cents; nonSelf: Cents }> {
  const rows = await all<{ is_self: boolean; exposure: number }>(
    `SELECT (l.member_id = lg.member_id) AS is_self,
            LEAST(lg.amount, (lg.amount::float8 / NULLIF(l.principal, 0)) * (l.principal_balance + l.interest_balance)) AS exposure
     FROM loan_guarantor lg JOIN loan l ON l.id = lg.loan_id
     WHERE lg.member_id = ? AND lg.status = 'COMMITTED'`,
    memberId,
  );
  let self = 0;
  let nonSelf = 0;
  for (const r of rows) {
    if (r.is_self) self += r.exposure || 0;
    else nonSelf += r.exposure || 0;
  }
  return { self: Math.round(self), nonSelf: Math.round(nonSelf) };
}

export interface GuarantorCapacity {
  deposits: Cents;
  outstanding: Cents;
  available: Cents;
}

/** How much of OTHER members' loans this member currently qualifies to guarantee —
 *  (deposits × Guarantor Multiplier) minus what they've already committed, capped at their raw
 *  deposits regardless of multiplier. Mirrors GetNonSelfGuaranteeEligibility. */
export async function guarantorCapacity(memberId: number): Promise<GuarantorCapacity> {
  const [deposits, { self, nonSelf }, org] = await Promise.all([
    memberDeposits(memberId), guaranteeSplit(memberId), getOrg(),
  ]);
  const outstanding = self + nonSelf;
  const multiplier = org?.guarantor_multiplier || 1;
  const available = Math.max(0, Math.min(deposits, Math.round(deposits * multiplier) - outstanding));
  return { deposits, outstanding, available };
}

/** How much of the member's OWN loan their own deposits can secure, using the separate Self
 *  Guarantor Multiplier — not capped at raw deposits (can exceed it when that multiplier is
 *  greater than 1). Mirrors GetSelfGuaranteeEligibility's two-branch formula: when the member
 *  has no outstanding guarantees for others, it's simply their self-prorated deposits minus
 *  whatever self-guarantee they've already committed to their own other loans; when they also
 *  guarantee others, that non-self exposure is converted back through the Guarantor Multiplier
 *  and netted out too, so the same deposits are never double-counted as security for both. */
export async function selfGuaranteeCapacity(memberId: number): Promise<Cents> {
  const [deposits, { self, nonSelf }, org] = await Promise.all([
    memberDeposits(memberId), guaranteeSplit(memberId), getOrg(),
  ]);
  const selfMultiplier = org?.self_guarantor_multiplier || 1;
  const guarantorMultiplier = org?.guarantor_multiplier || 1;
  const proratedDeposits = Math.round(deposits * selfMultiplier);
  if (nonSelf === 0) return Math.max(0, proratedDeposits - self);
  return Math.max(0, Math.round(proratedDeposits - ((nonSelf / guarantorMultiplier) + self)));
}
