/*
 * The Dormant-member transaction lock — a Dormant member (see lib/memberStatusUpdate.ts) may
 * still be deposited to (that's how they reactivate), exited, or reached by a Checkoff & Salary
 * Processing batch, but every other money movement against them is refused. Kept as its own
 * tiny, dependency-free module (just db.ts/errors.ts) so lib/savings.ts, lib/loanService.ts and
 * lib/memberCharging.ts can all import it without pulling in lib/memberStatusUpdate.ts's own
 * heavier posting-engine dependencies.
 */
import { one } from './db.ts';
import { PostingError } from './errors.ts';

/** Throws when `memberId` is currently Dormant. Callers pass a short present-tense fragment for
 *  `action` (e.g. "a withdrawal", "disbursement") to slot into the error message. Not checked by
 *  lib/savings.ts's deposit(), lib/memberExits.ts (which posts money movements directly rather
 *  than through the functions this guards), or the CHECKOFF channel of
 *  lib/loanService.ts's repay() / lib/savings.ts's deposit() used by Checkoff & Salary
 *  Processing — those are this restriction's explicit exceptions. */
export async function assertMemberNotDormant(memberId: number, action: string): Promise<void> {
  const row = await one<{ status: string }>('SELECT status FROM member WHERE id = ?', memberId);
  if (row?.status === 'DORMANT') {
    throw new PostingError(
      `This member is Dormant — ${action} is not allowed until they make a deposit to reactivate`,
      'MEMBER_DORMANT',
    );
  }
}
