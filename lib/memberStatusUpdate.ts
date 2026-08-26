/*
 * Member Status Update — ported from the AL reference's "Update Member Status" report
 * (Rep 52204078), run either on demand (app/member-status-update) or unattended off a Job Queue
 * Entry (lib/jobQueue.ts). The source report drives dormancy off a member's Last Transaction
 * Date across every account they hold; this port narrows that to the specific rule requested:
 * dormancy is driven by the member's own Non-Withdrawable Deposit (BOSA) account — the same
 * account lib/entranceFeeRecovery.ts already reads — carrying no money for the admin's
 * configured Dormancy Period (organisation.dormancy_days).
 *
 * Reactivation (Dormant -> Active) happens the moment that account picks up a positive balance
 * again. If a "Member Reactivation" Transaction Charge is configured (Admin Centre -> Charges),
 * its amount is recovered from that same balance first — mirroring AL's Member Activation
 * card's own Reactivation Fee, but applied automatically rather than through a manual
 * maker-checker document. Unlike lib/entranceFeeRecovery.ts's registration fee, this charge is
 * never partially collected: if the account can't yet afford it in full, reactivation simply
 * waits for a later run once more has accumulated, the same "must be fully affordable, or the
 * whole step is blocked" rule lib/accountActivation.ts's own reactivation fee already applies.
 *
 * While Dormant, lib/memberDormancy.ts's assertMemberNotDormant() blocks withdrawals,
 * disbursement, non-Checkoff repayment and member charging — see its own header for the exact
 * exceptions (deposits, Member Exit, Checkoff & Salary Processing).
 */
import {
  one, all, run, tx, nextSequence, audit,
} from './db.ts';
import { postTransactionCharges, previewTransactionCharges } from './charges.ts';
import { today } from './format.ts';
import { resolvePostingDate } from './postingDates.ts';
import { getOrg } from './org.ts';
import type {
  Actor, Cents, MemberStatusUpdateAction, MemberStatusUpdateCandidate, MemberStatusUpdateResult,
  MemberStatusUpdateRunSummary,
} from './types.ts';

interface CandidateMember {
  id: number;
  member_no: string;
  first_name: string;
  last_name: string;
  status: 'ACTIVE' | 'DORMANT';
}

interface DepositAccount {
  id: number;
  account_no: string;
  balance: Cents;
  hold_amount: Cents;
  min_balance: Cents;
  gl_control_id: number;
  last_activity: string | null;
  opened_date: string | null;
}

/** Every member Update Member Status actually evaluates — AL's `where(Status = filter(Active |
 *  Dormant))`, skipping Deceased (and, in this port, every other terminal/pre-membership status
 *  the source report never touches either). */
const listCandidateMembers = (): Promise<CandidateMember[]> =>
  all<CandidateMember>(
    "SELECT id, member_no, first_name, last_name, status FROM member WHERE status IN ('ACTIVE','DORMANT') ORDER BY member_no",
  );

/** The member's own Non-Withdrawable Deposit account — same lookup as
 *  lib/entranceFeeRecovery.ts's getDepositAccount(). */
const getDepositAccount = (memberId: number): Promise<DepositAccount | undefined> =>
  one<DepositAccount>(
    `SELECT sa.id, sa.account_no, sa.balance, sa.hold_amount, p.min_balance, p.gl_control_id,
            sa.last_activity, sa.opened_date
     FROM savings_account sa JOIN savings_product p ON p.id = sa.product_id
     WHERE sa.member_id = ? AND sa.status = 'ACTIVE' AND p.category = 'NON WITHDRAWABLE DEPOSIT'
     ORDER BY sa.id LIMIT 1`,
    memberId,
  );

const daysSince = (dateStr: string | null): number | null => {
  if (!dateStr) return null;
  return Math.floor((Date.now() - new Date(dateStr).getTime()) / 86_400_000);
};

/** Mirrors AL's own fallback ("no Last Transaction Date at all" -> immediately Dormant): a
 *  never-funded account has no last_activity, so its opened_date stands in; the rare account
 *  with neither is treated as maximally overdue rather than never-dormant. */
function accountAgeDays(account: DepositAccount): number | null {
  const anchor = account.last_activity ?? account.opened_date;
  return daysSince(anchor);
}

async function resolveAction(
  m: CandidateMember, account: DepositAccount | undefined, dormancyDays: number,
): Promise<{ action: MemberStatusUpdateAction; age: number | null; reactivationCharge: Cents | null }> {
  if (!account) return { action: 'NONE', age: null, reactivationCharge: null };

  if (account.balance > 0) {
    if (m.status !== 'DORMANT') return { action: 'NONE', age: null, reactivationCharge: null };
    const charges = await previewTransactionCharges('Member Reactivation', 0);
    const total = charges.reduce((sum, c) => sum + c.amount, 0);
    const available = Math.max(account.balance - account.hold_amount - account.min_balance, 0);
    const action: MemberStatusUpdateAction = total > available ? 'REACTIVATION_BLOCKED' : 'REACTIVATE';
    return { action, age: null, reactivationCharge: total };
  }

  const age = accountAgeDays(account);
  if (m.status !== 'ACTIVE') return { action: 'NONE', age, reactivationCharge: null };
  const dormant = age === null || age >= dormancyDays;
  return { action: dormant ? 'MARK_DORMANT' : 'NONE', age, reactivationCharge: null };
}

/** Preview — every Active/Dormant member, their Non-Withdrawable Deposit account position, and
 *  what a run would do (or is blocked from doing) to them right now. */
export async function listMemberStatusUpdateCandidates(): Promise<MemberStatusUpdateCandidate[]> {
  const org = await getOrg();
  const dormancyDays = org?.dormancy_days ?? 90;
  const members = await listCandidateMembers();

  return Promise.all(members.map(async (m) => {
    const account = await getDepositAccount(m.id);
    const { action, age, reactivationCharge } = await resolveAction(m, account, dormancyDays);
    return {
      member_id: m.id, member_no: m.member_no, first_name: m.first_name, last_name: m.last_name,
      status: m.status, deposit_account_id: account?.id ?? null, deposit_account_no: account?.account_no ?? null,
      balance: account?.balance ?? 0, days_since_activity: age, reactivation_charge: reactivationCharge, action,
    };
  }));
}

/** Applies one member's resolved action inside its own transaction — re-resolved from a fresh
 *  read rather than trusting the caller's preview, the same re-check-right-before-posting
 *  discipline lib/entranceFeeRecovery.ts's recoverOne() follows. Returns null for a member this
 *  run has nothing to do to. */
async function processOne(m: CandidateMember, dormancyDays: number, user: Actor): Promise<MemberStatusUpdateResult | null> {
  return tx(async () => {
    const account = await getDepositAccount(m.id);
    const { action, reactivationCharge } = await resolveAction(m, account, dormancyDays);

    if (action === 'NONE') return null;

    if (action === 'MARK_DORMANT') {
      await run("UPDATE member SET status = 'DORMANT' WHERE id = ?", m.id);
      return { member_id: m.id, member_no: m.member_no, action, charged: 0, note: null };
    }

    if (action === 'REACTIVATION_BLOCKED') {
      return {
        member_id: m.id, member_no: m.member_no, action, charged: 0,
        note: `The Member Reactivation charge of ${((reactivationCharge ?? 0) / 100).toFixed(2)} exceeds what's available in ${account!.account_no}`,
      };
    }

    // REACTIVATE
    let charged = 0;
    if ((reactivationCharge ?? 0) > 0) {
      const description = `Reactivation charge — ${account!.account_no}`;
      const vd = await resolvePostingDate(user);
      const posted = await postTransactionCharges({
        transactionType: 'Member Reactivation', baseAmount: 0, debitAccountCode: account!.gl_control_id,
        valueDate: vd, module: 'SAVINGS', eventType: 'MEMBER_REACTIVATION', memberId: m.id,
        description, user,
      });
      if (posted) {
        charged = posted.charges.reduce((sum, c) => sum + c.amount, 0);
        const newBalance = account!.balance - charged;
        await run('UPDATE savings_account SET balance = ?, last_activity = ? WHERE id = ?', newBalance, vd, account!.id);
        await run(
          `INSERT INTO txn (txn_ref, value_date, created_at, module, txn_type, member_id,
             savings_account_id, amount, running_balance, channel, description, journal_id, created_by)
           VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?)`,
          await nextSequence('TXN'), vd, new Date().toISOString(), 'SAVINGS', 'FEE',
          m.id, account!.id, -charged, newBalance, 'SYSTEM', description, posted.journal.id, user.username,
        );
      }
    }
    await run("UPDATE member SET status = 'ACTIVE' WHERE id = ?", m.id);
    return { member_id: m.id, member_no: m.member_no, action, charged, note: null };
  });
}

/**
 * Runs Member Status Update across every Active/Dormant member. Each member is processed in its
 * own transaction — one member's failure doesn't roll back everyone else already updated in the
 * same run, matching lib/entranceFeeRecovery.ts's own per-member isolation.
 */
export async function runMemberStatusUpdate(user: Actor): Promise<MemberStatusUpdateRunSummary> {
  const org = await getOrg();
  const dormancyDays = org?.dormancy_days ?? 90;
  const members = await listCandidateMembers();
  const results: MemberStatusUpdateResult[] = [];

  for (const m of members) {
    try {
      const outcome = await processOne(m, dormancyDays, user);
      if (outcome) results.push(outcome);
    } catch (e) {
      results.push({
        member_id: m.id, member_no: m.member_no, action: 'NONE', charged: 0,
        note: (e as Error).message || 'Update failed',
      });
    }
  }

  const summary: MemberStatusUpdateRunSummary = {
    results,
    markedDormant: results.filter((r) => r.action === 'MARK_DORMANT').length,
    reactivated: results.filter((r) => r.action === 'REACTIVATE').length,
    totalCharged: results.reduce((sum, r) => sum + r.charged, 0),
  };
  await audit(user, 'MEMBER_STATUS_UPDATE_RUN', 'member', null, {
    markedDormant: summary.markedDormant, reactivated: summary.reactivated, totalCharged: summary.totalCharged,
  });
  return summary;
}
