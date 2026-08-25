/*
 * Entrance Fee Recovery — ported from the source documentation's "Entrance Fee Recovery" report
 * (Rep 52204049), run either on demand (app/entrance-fee-recovery) or unattended off a Job Queue
 * Entry (lib/jobQueue.ts). A Not Paid Up member owes their Member Category's Registration Fee;
 * this sweeps whatever their Non-Withdrawable Deposit account can currently spare toward it —
 * capped at the account's available balance, same as any other withdrawal — and once the fee is
 * fully recovered flips the member from Not Paid Up to Active.
 *
 * "Paid Registration" (AL's Members FlowField, summing Detailed Vendor Ledger Entries of Entry
 * Type "Registration Fee") is reproduced here as a live sum of this module's own journal
 * postings (event_type = 'ENTRANCE_FEE_RECOVERY') for the member — nothing else in this port
 * posts toward a registration fee, so the two are equivalent. That also makes a partial recovery
 * safe to resume: a later run picks up from whatever was already recovered rather than
 * re-charging the fee from zero.
 */
import {
  one, all, run, tx, nextSequence, audit,
} from './db.ts';
import { postJournal } from './accounting.ts';
import { today } from './format.ts';
import type {
  Actor, Cents, EntranceFeeRecoveryCandidate, EntranceFeeRecoveryResult, EntranceFeeRecoveryRunSummary,
} from './types.ts';

interface DepositAccount {
  id: number;
  account_no: string;
  balance: Cents;
  hold_amount: Cents;
  min_balance: Cents;
  gl_control_id: number;
}

/** The member's own Non-Withdrawable Deposit account — AL's MemberMgt.GetMemberAccount(MemberNo,
 *  "Non Withdrawable Deposit"). A member holds at most one (see lib/savings.ts's openAccount()
 *  one-account-per-product rule), so the first is always the only one. */
const getDepositAccount = (memberId: number): Promise<DepositAccount | undefined> =>
  one<DepositAccount>(
    `SELECT sa.id, sa.account_no, sa.balance, sa.hold_amount, p.min_balance, p.gl_control_id
     FROM savings_account sa JOIN savings_product p ON p.id = sa.product_id
     WHERE sa.member_id = ? AND sa.status = 'ACTIVE' AND p.category = 'NON WITHDRAWABLE DEPOSIT'
     ORDER BY sa.id LIMIT 1`,
    memberId,
  );

const getPaidRegistration = async (memberId: number): Promise<Cents> => {
  const row = await one<{ s: Cents }>(
    "SELECT COALESCE(SUM(amount),0) s FROM journal WHERE member_id = ? AND event_type = 'ENTRANCE_FEE_RECOVERY'",
    memberId,
  );
  return row?.s || 0;
};

interface CandidateMember {
  id: number;
  member_no: string;
  first_name: string;
  last_name: string;
  category_code: string;
  registration_fee: Cents;
  registration_fee_account_id: number;
}

/** Every Not Paid Up member whose Member Category actually charges a Registration Fee with a
 *  Registration Fee Account configured (Admin Centre → Member Categories) — AL's own
 *  `MemberCategory.Get` + `TestField("Registration Fee Account")` + `"Registration Fee" > 0`
 *  guard, expressed as a join/filter instead of three sequential checks. */
const listCandidateMembers = (): Promise<CandidateMember[]> =>
  all<CandidateMember>(
    `SELECT m.id, m.member_no, m.first_name, m.last_name,
            mc.code AS category_code, mc.registration_fee, mc.registration_fee_account_id
     FROM member m JOIN member_category mc ON mc.id = m.member_category_id
     WHERE m.status = 'NOT PAID UP' AND mc.registration_fee > 0 AND mc.registration_fee_account_id IS NOT NULL
     ORDER BY m.member_no`,
  );

async function toCandidate(m: CandidateMember): Promise<EntranceFeeRecoveryCandidate> {
  const [paid, account] = await Promise.all([getPaidRegistration(m.id), getDepositAccount(m.id)]);
  const outstanding = Math.max(m.registration_fee - paid, 0);
  const available = account ? Math.max(account.balance - account.hold_amount - account.min_balance, 0) : 0;
  return {
    member_id: m.id, member_no: m.member_no, first_name: m.first_name, last_name: m.last_name,
    category_code: m.category_code, registration_fee: m.registration_fee, paid_registration: paid, outstanding,
    deposit_account_id: account?.id ?? null, deposit_account_no: account?.account_no ?? null,
    available_balance: available, posting_amount: Math.min(outstanding, available),
  };
}

/** Preview — every Not Paid Up member with an outstanding registration fee, what's already been
 *  recovered, and what a run would sweep right now. Drives both the manual screen's table and
 *  (indirectly, via runEntranceFeeRecovery reusing the same per-member computation) the Job
 *  Queue's own unattended run. */
export async function listEntranceFeeRecoveryCandidates(): Promise<EntranceFeeRecoveryCandidate[]> {
  const members = await listCandidateMembers();
  return Promise.all(members.map(toCandidate));
}

/** Posts one member's recovery — debits their deposit account, credits the category's
 *  Registration Fee Account, records the FEE txn — and, once fully recovered, flips Not Paid Up
 *  to Active. Recomputes everything from the live account/paid position inside its own
 *  transaction (not the caller's stale preview), the same re-check-right-before-posting
 *  discipline lib/memberCharging.ts's postMemberCharging() follows. Returns null when there is
 *  nothing left to post (already fully recovered, or nothing currently available). */
async function recoverOne(m: CandidateMember, user: Actor): Promise<EntranceFeeRecoveryResult | null> {
  return tx(async () => {
    const account = await getDepositAccount(m.id);
    if (!account) {
      return {
        member_id: m.id, member_no: m.member_no, posted: 0, activated: false,
        skipped_reason: 'No Non-Withdrawable Deposit account',
      };
    }

    const paid = await getPaidRegistration(m.id);
    const outstanding = Math.max(m.registration_fee - paid, 0);
    if (outstanding <= 0) return null;

    const available = Math.max(account.balance - account.hold_amount - account.min_balance, 0);
    const amount = Math.min(outstanding, available);
    if (amount <= 0) {
      return {
        member_id: m.id, member_no: m.member_no, posted: 0, activated: false,
        skipped_reason: `No available balance in ${account.account_no}`,
      };
    }

    const description = `Entrance Fee Recovery — ${m.member_no}`;
    const j = await postJournal({
      valueDate: today(), module: 'SAVINGS', eventType: 'ENTRANCE_FEE_RECOVERY', description,
      memberId: m.id, user,
      lines: [
        { account: account.gl_control_id, debit: amount, credit: 0 },
        { account: m.registration_fee_account_id, debit: 0, credit: amount },
      ],
    });
    const newBalance = account.balance - amount;
    await run('UPDATE savings_account SET balance = ?, last_activity = ? WHERE id = ?', newBalance, today(), account.id);
    await run(
      `INSERT INTO txn (txn_ref, value_date, created_at, module, txn_type, member_id,
         savings_account_id, amount, running_balance, channel, description, journal_id, created_by)
       VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?)`,
      await nextSequence('TXN'), today(), new Date().toISOString(), 'SAVINGS', 'FEE', m.id,
      account.id, -amount, newBalance, 'SYSTEM', description, j.id, user.username,
    );

    let activated = false;
    if (paid + amount >= m.registration_fee) {
      await run("UPDATE member SET status = 'ACTIVE' WHERE id = ?", m.id);
      activated = true;
    }
    return { member_id: m.id, member_no: m.member_no, posted: amount, activated, skipped_reason: null };
  });
}

/**
 * Runs Entrance Fee Recovery across every Not Paid Up member. Each member is posted in its own
 * transaction — one member's failure (a since-deactivated GL account, say) is recorded and
 * skipped rather than rolling back everyone else already recovered in the same run, matching
 * AL's own report loop where each posting commits independently row by row.
 */
export async function runEntranceFeeRecovery(user: Actor): Promise<EntranceFeeRecoveryRunSummary> {
  const members = await listCandidateMembers();
  const results: EntranceFeeRecoveryResult[] = [];

  for (const m of members) {
    try {
      const outcome = await recoverOne(m, user);
      if (outcome) results.push(outcome);
    } catch (e) {
      results.push({
        member_id: m.id, member_no: m.member_no, posted: 0, activated: false,
        skipped_reason: (e as Error).message || 'Posting failed',
      });
    }
  }

  const summary: EntranceFeeRecoveryRunSummary = {
    results,
    totalPosted: results.reduce((sum, r) => sum + r.posted, 0),
    membersRecovered: results.filter((r) => r.posted > 0).length,
    membersActivated: results.filter((r) => r.activated).length,
  };
  await audit(user, 'ENTRANCE_FEE_RECOVERY_RUN', 'member', null, {
    membersRecovered: summary.membersRecovered, membersActivated: summary.membersActivated, totalPosted: summary.totalPosted,
  });
  return summary;
}
