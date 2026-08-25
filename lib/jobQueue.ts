/*
 * System Automation (Job Queue) — mirrors Business Central's Job Queue Entry: an admin-managed
 * list of recurring background tasks, each dispatched by `job_type` (JOB_HANDLERS below) and
 * polled unattended by the in-process scheduler (instrumentation.ts's setInterval, since this
 * app has no separate worker process). AL's own Recurrence (a Day/Time-of-day pattern) is
 * simplified here to a plain "every N minutes" interval plus an optional earliest-start date —
 * the same kind of simplification lib/memberExits.ts's member_exit_notice_days already applies
 * to a DateFormula elsewhere in this port.
 *
 * Implemented jobs: Entrance Fee Recovery (lib/entranceFeeRecovery.ts), Member Status Update
 * (lib/memberStatusUpdate.ts) and Standing Order Run (lib/standingOrders.ts). JOB_HANDLERS is
 * where a future job type would register its own runner.
 */
import { one, all, run, audit } from './db.ts';
import { AppError } from './errors.ts';
import { runEntranceFeeRecovery } from './entranceFeeRecovery.ts';
import { runMemberStatusUpdate } from './memberStatusUpdate.ts';
import { runStandingOrders } from './standingOrders.ts';
import type { Actor, JobQueueEntry, JobQueueRunStatus, JobQueueStatus, JobQueueType } from './types.ts';

/** One named runner per JobQueueType — the dispatch table both the manual "Run now" button and
 *  the unattended poller call through. A handler throws to signal failure (caught and recorded
 *  by the caller) and returns a short human-readable outcome to store as last_run_message. */
const JOB_HANDLERS: Record<JobQueueType, (user: Actor) => Promise<string>> = {
  ENTRANCE_FEE_RECOVERY: async (user) => {
    const summary = await runEntranceFeeRecovery(user);
    return `${summary.membersRecovered} member(s) recovered, ${summary.membersActivated} activated, `
      + `total ${(summary.totalPosted / 100).toFixed(2)} posted`;
  },
  MEMBER_STATUS_UPDATE: async (user) => {
    const summary = await runMemberStatusUpdate(user);
    return `${summary.markedDormant} member(s) marked Dormant, ${summary.reactivated} reactivated, `
      + `total ${(summary.totalCharged / 100).toFixed(2)} charged`;
  },
  STANDING_ORDER_RUN: async (user) => {
    const summary = await runStandingOrders(user);
    return `${summary.posted} order(s) posted, ${summary.terminated} auto-terminated, `
      + `total ${(summary.totalPosted / 100).toFixed(2)} moved`;
  },
};

export const listJobQueueEntries = (): Promise<JobQueueEntry[]> =>
  all<JobQueueEntry>('SELECT * FROM job_queue_entry ORDER BY code');

export const getJobQueueEntry = (id: number): Promise<JobQueueEntry | undefined> =>
  one<JobQueueEntry>('SELECT * FROM job_queue_entry WHERE id = ?', id);

/** now + run_every_minutes, expressed the way every other IsoDateTime in this app is: a plain
 *  ISO string, not a DB-side interval — keeps computeNextRunAt trivially testable and mirrors
 *  how the rest of the codebase (e.g. lib/format.ts's addMonths) does date arithmetic in JS. */
const minutesFromNow = (minutes: number): string => new Date(Date.now() + minutes * 60_000).toISOString();

export interface JobQueueEntryInput {
  code: string;
  description: string;
  job_type: JobQueueType;
  run_every_minutes: number;
  earliest_start_date?: string | null;
}

/** Shared by create and update. Code is deliberately not checked here — the edit form disables
 *  its Code field (immutable once created), and a disabled <input> is omitted from FormData
 *  entirely, so requiring it here would reject every edit. createJobQueueEntry() checks it
 *  separately, since only creation actually needs one. */
function assertValid(input: JobQueueEntryInput): void {
  if (!input.description?.trim()) throw new AppError('Description is required', 'VALIDATION');
  if (!JOB_HANDLERS[input.job_type]) throw new AppError('Invalid job type', 'VALIDATION');
  if (!Number.isFinite(input.run_every_minutes) || input.run_every_minutes < 1) {
    throw new AppError('Run every (minutes) must be at least 1', 'VALIDATION');
  }
}

/** New entries start ON HOLD — the same "an admin must deliberately switch this on" default a
 *  freshly seeded system automation should have, rather than silently moving money the moment
 *  it's created. next_run_at is still seeded to now so it is immediately due the moment the
 *  admin flips it to Ready, instead of waiting a full run_every_minutes first. */
export async function createJobQueueEntry(input: JobQueueEntryInput, user: Actor): Promise<{ id: number }> {
  if (!input.code?.trim()) throw new AppError('Code is required', 'VALIDATION');
  assertValid(input);
  const code = input.code.trim().toUpperCase();
  if (await one('SELECT 1 FROM job_queue_entry WHERE code = ?', code)) {
    throw new AppError('Job Queue Entry code already exists', 'DUPLICATE');
  }
  const now = new Date().toISOString();
  const info = await run(
    `INSERT INTO job_queue_entry
       (code, description, job_type, run_every_minutes, earliest_start_date, status, next_run_at,
        created_at, created_by)
     VALUES (?,?,?,?,?,'ON HOLD',?,?,?)`,
    code, input.description.trim(), input.job_type, Math.round(input.run_every_minutes),
    input.earliest_start_date || null, now, now, user.username,
  );
  await audit(user, 'JOB_QUEUE_ENTRY_CREATE', 'job_queue_entry', info.lastInsertRowid, { code, jobType: input.job_type });
  return { id: Number(info.lastInsertRowid) };
}

export async function updateJobQueueEntry(
  id: number, input: JobQueueEntryInput, user: Actor,
): Promise<JobQueueEntry> {
  const before = await getJobQueueEntry(id);
  if (!before) throw new AppError('Job Queue Entry not found', 'NOT_FOUND');
  assertValid(input);
  await run(
    `UPDATE job_queue_entry
     SET description = ?, job_type = ?, run_every_minutes = ?, earliest_start_date = ?, updated_at = ?, updated_by = ?
     WHERE id = ?`,
    input.description.trim(), input.job_type, Math.round(input.run_every_minutes),
    input.earliest_start_date || null, new Date().toISOString(), user.username, id,
  );
  await audit(user, 'JOB_QUEUE_ENTRY_UPDATE', 'job_queue_entry', id, { fields: Object.keys(input) });
  return (await getJobQueueEntry(id))!;
}

/** Ready <-> On Hold — flipping to Ready also seeds next_run_at to now, the same "immediately
 *  due" treatment createJobQueueEntry gives a brand new entry, so re-enabling a long-dormant
 *  entry doesn't silently wait out a full interval before its first run. */
export async function setJobQueueEntryStatus(id: number, status: JobQueueStatus, user: Actor): Promise<void> {
  const before = await getJobQueueEntry(id);
  if (!before) throw new AppError('Job Queue Entry not found', 'NOT_FOUND');
  await run(
    'UPDATE job_queue_entry SET status = ?, next_run_at = ?, updated_at = ?, updated_by = ? WHERE id = ?',
    status, status === 'READY' ? new Date().toISOString() : before.next_run_at,
    new Date().toISOString(), user.username, id,
  );
  await audit(user, 'JOB_QUEUE_ENTRY_SET_STATUS', 'job_queue_entry', id, { status });
}

export async function deleteJobQueueEntry(id: number, user: Actor): Promise<void> {
  const before = await getJobQueueEntry(id);
  if (!before) throw new AppError('Job Queue Entry not found', 'NOT_FOUND');
  await run('DELETE FROM job_queue_entry WHERE id = ?', id);
  await audit(user, 'JOB_QUEUE_ENTRY_DELETE', 'job_queue_entry', id, { code: before.code });
}

/** Guards against the poller and a manual "Run now" click overlapping on the same entry — this
 *  is a single Node process (no separate worker), so an in-memory set is enough; it resets on
 *  every restart, which is fine since nothing is "in flight" across a restart anyway. */
const running = new Set<number>();

async function execute(entry: JobQueueEntry, user: Actor): Promise<void> {
  if (running.has(entry.id)) return;
  running.add(entry.id);
  const startedAt = new Date().toISOString();
  try {
    const message = await JOB_HANDLERS[entry.job_type](user);
    await run(
      `UPDATE job_queue_entry
       SET last_run_at = ?, last_run_status = 'SUCCESS', last_run_message = ?, next_run_at = ?
       WHERE id = ?`,
      startedAt, message, minutesFromNow(entry.run_every_minutes), entry.id,
    );
  } catch (e) {
    const message = (e as Error).message || 'Run failed';
    await run(
      `UPDATE job_queue_entry
       SET last_run_at = ?, last_run_status = 'ERROR', last_run_message = ?, next_run_at = ?
       WHERE id = ?`,
      startedAt, message, minutesFromNow(entry.run_every_minutes), entry.id,
    );
    await audit(user, 'JOB_QUEUE_ENTRY_RUN_ERROR', 'job_queue_entry', entry.id, { message });
  } finally {
    running.delete(entry.id);
  }
}

/** Runs one entry immediately regardless of next_run_at or status — the admin screen's "Run
 *  now". Still reschedules next_run_at from this run, so a manual run doesn't leave the next
 *  unattended run due sooner than run_every_minutes after it. */
export async function runJobQueueEntryNow(id: number, user: Actor): Promise<void> {
  const entry = await getJobQueueEntry(id);
  if (!entry) throw new AppError('Job Queue Entry not found', 'NOT_FOUND');
  if (running.has(id)) throw new AppError('This entry is already running', 'VALIDATION');
  await execute(entry, user);
}

/** The unattended poller's own entry point — called on an interval by instrumentation.ts.
 *  Picks up every READY entry whose earliest_start_date has arrived (or is unset) and whose
 *  next_run_at is due (or unset), and runs each as the system actor. Entries run sequentially:
 *  this is a lightly loaded background sweep, not a high-throughput queue, so there is no
 *  benefit to parallelising it and every extra concurrent job is one more thing that could
 *  contend with interactive requests for a DB connection. */
export async function runDueJobQueueEntries(): Promise<void> {
  const nowIso = new Date().toISOString();
  const today = nowIso.slice(0, 10);
  const due = await all<JobQueueEntry>(
    `SELECT * FROM job_queue_entry
     WHERE status = 'READY'
       AND (earliest_start_date IS NULL OR earliest_start_date <= ?)
       AND (next_run_at IS NULL OR next_run_at <= ?)
     ORDER BY id`,
    today, nowIso,
  );
  const system: Actor = { id: 1, username: 'system' };
  for (const entry of due) {
    await execute(entry, system);
  }
}
