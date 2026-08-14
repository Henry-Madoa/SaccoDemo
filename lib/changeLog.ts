import { one, all, run } from './db.ts';
import type { Actor, ChangeLogEntry, ChangeLogSetup, ChangeLogType } from './types.ts';

/**
 * Field-level change tracking, modelled on Business Central's Change Log Management:
 * nothing is written here for a table until an admin opts it into Insertion/Modification/
 * Deletion via Change Log Setup (Admin Centre). Unlike audit_log — which every workflow
 * action writes to unconditionally — this is opt-in per table and per change type.
 */

export const listChangeLogSetup = (): Promise<ChangeLogSetup[]> =>
  all<ChangeLogSetup>('SELECT * FROM change_log_setup ORDER BY table_caption');

/** Tables this feature can never track, opted in or not: the log tables themselves
 *  and Postgres/Prisma internals with no business record to diff. */
const UNTRACKABLE_TABLES = new Set(['change_log_setup', 'change_log_entry', 'session', 'sequence']);

const captionFor = (tableName: string): string =>
  tableName.split('_').map((w) => w[0].toUpperCase() + w.slice(1)).join(' ');

export interface ChangeLogTableOption {
  table_name: string;
  table_caption: string;
}

/**
 * Every table the admin could still add to Change Log Setup, read straight from the
 * database's own catalogue rather than a list maintained in code — so a table added
 * to the schema shows up here without a code change, and it's the admin's call
 * whether it belongs under change tracking, not this module's.
 */
export async function listAvailableChangeLogTables(): Promise<ChangeLogTableOption[]> {
  const [tables, configured] = await Promise.all([
    all<{ table_name: string }>(
      `SELECT table_name FROM information_schema.tables
       WHERE table_schema = 'public' AND table_type = 'BASE TABLE' ORDER BY table_name`,
    ),
    all<{ table_name: string }>('SELECT table_name FROM change_log_setup'),
  ]);
  const configuredNames = new Set(configured.map((c) => c.table_name));
  return tables
    .filter((t) => !t.table_name.startsWith('_')
      && !UNTRACKABLE_TABLES.has(t.table_name) && !configuredNames.has(t.table_name))
    .map((t) => ({ table_name: t.table_name, table_caption: captionFor(t.table_name) }));
}

/** Opts a table into Change Log Setup with all three flags off — the admin switches
 *  on whichever of Insertion/Modification/Deletion they actually want tracked. */
export async function addChangeLogSetupTable(tableName: string, tableCaption: string): Promise<void> {
  await run(
    'INSERT INTO change_log_setup (table_name, table_caption) VALUES (?, ?) ON CONFLICT (table_name) DO NOTHING',
    tableName, tableCaption,
  );
}

export async function removeChangeLogSetupTable(tableName: string): Promise<void> {
  await run('DELETE FROM change_log_setup WHERE table_name = ?', tableName);
}

const SETUP_FLAG: Record<ChangeLogType, keyof Pick<ChangeLogSetup, 'log_insertion' | 'log_modification' | 'log_deletion'>> = {
  Insertion: 'log_insertion',
  Modification: 'log_modification',
  Deletion: 'log_deletion',
};

export async function updateChangeLogSetup(
  tableName: string,
  patch: Partial<Pick<ChangeLogSetup, 'log_insertion' | 'log_modification' | 'log_deletion'>>,
): Promise<void> {
  const cols = Object.keys(patch) as (keyof typeof patch)[];
  if (!cols.length) return;
  await run(
    `UPDATE change_log_setup SET ${cols.map((c) => `${c}=?`).join(',')} WHERE table_name=?`,
    ...cols.map((c) => patch[c]), tableName,
  );
}

export interface FieldChange {
  field: string;
  oldValue: unknown;
  newValue: unknown;
}

/**
 * Every field in `patch` whose value differs from `before` — the shared diffing logic
 * behind Modification entries. `before` and `patch` use the raw DB row shape.
 */
export function diffFields(
  before: Record<string, unknown>, patch: Record<string, unknown | undefined>,
): FieldChange[] {
  const changes: FieldChange[] = [];
  for (const [field, newValue] of Object.entries(patch)) {
    if (newValue === undefined) continue;
    const oldValue = before[field] ?? null;
    if (String(oldValue ?? '') === String(newValue ?? '')) continue;
    changes.push({ field, oldValue, newValue });
  }
  return changes;
}

/**
 * Writes one change_log_entry row per changed field — a no-op unless `tableName` is
 * opted into logging `type` via Change Log Setup, and a no-op for an empty change set.
 */
export async function logTableChange(
  tableName: string, recordId: string, type: ChangeLogType, changes: FieldChange[], user: Actor,
): Promise<void> {
  if (!changes.length) return;
  const setup = await one<ChangeLogSetup>('SELECT * FROM change_log_setup WHERE table_name = ?', tableName);
  if (!setup || !setup[SETUP_FLAG[type]]) return;

  const at = new Date().toISOString();
  for (const c of changes) {
    await run(
      `INSERT INTO change_log_entry
         (table_name, table_caption, record_id, field_name, old_value, new_value, type, changed_at, user_id, username)
       VALUES (?,?,?,?,?,?,?,?,?,?)`,
      tableName, setup.table_caption, recordId, c.field,
      c.oldValue == null ? null : String(c.oldValue), c.newValue == null ? null : String(c.newValue),
      type, at, user.id, user.username,
    );
  }
}

export interface ListChangeLogEntriesOptions {
  tableName?: string;
  search?: string;
}

export const listChangeLogEntries = (
  { tableName, search = '' }: ListChangeLogEntriesOptions = {},
): Promise<ChangeLogEntry[]> =>
  all<ChangeLogEntry>(
    `SELECT * FROM change_log_entry
     WHERE (record_id LIKE @like OR field_name LIKE @like OR username LIKE @like OR table_caption LIKE @like)
       ${tableName ? 'AND table_name = @tableName' : ''}
     ORDER BY id DESC LIMIT 500`,
    { like: `%${String(search).trim()}%`, tableName },
  );
