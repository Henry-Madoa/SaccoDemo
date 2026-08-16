import { AsyncLocalStorage } from 'node:async_hooks';
import { setDefaultResultOrder } from 'node:dns';
import { PrismaClient } from '@prisma/client';
import { PrismaPg } from '@prisma/adapter-pg';
import type { Actor } from './types.ts';

/*
 * Neon resolves to both IPv4 and IPv6 addresses. On networks where the IPv6
 * route is dead rather than simply refused (as seen in local dev on Windows),
 * every new connection races Node's default DNS order, loses tens of seconds
 * to the unreachable IPv6 candidates, and only then falls back to IPv4 —
 * surfacing as a spurious ETIMEDOUT on the first query of a request. Since
 * Neon is only ever reached over IPv4 here, skip the race entirely.
 */
setDefaultResultOrder('ipv4first');

/*
 * PostgreSQL access, over Prisma's raw interface.
 *
 * Prisma owns the schema and the migrations; the queries stay as SQL because
 * this is a reporting-heavy ledger and the aggregates are what the financial
 * test suite pins hardest. Two translations make the existing SQL portable:
 *
 *   - placeholders: `?` and `@named` become `$1..$n`
 *   - identity:     an INSERT gets `RETURNING id` so `lastInsertRowid` survives
 *
 * Next.js reloads server modules on edit, so the client hangs off globalThis to
 * avoid opening a new pool per reload.
 */

const globalForDb = globalThis as typeof globalThis & { __saccoPrisma?: PrismaClient };

function connect(): PrismaClient {
  const url = process.env.DATABASE_URL;
  if (!url) throw new Error('DATABASE_URL is not set — the application cannot reach its database.');
  return new PrismaClient({
    adapter: new PrismaPg({
      connectionString: url,
      // node-postgres otherwise waits indefinitely: a connection that goes
      // stale without a clean close (Neon's pooler reclaiming it, a laptop
      // sleeping through a network change) leaves a query hanging forever
      // instead of failing, wedging every request behind ensureSeeded().
      query_timeout: 30_000,
      statement_timeout: 30_000,
      connectionTimeoutMillis: 10_000,
      keepAlive: true,
    }),
  });
}

const db: PrismaClient = globalForDb.__saccoPrisma ?? (globalForDb.__saccoPrisma = connect());

/** The client for the current call: the open transaction if there is one. */
type RawClient = Pick<PrismaClient, '$queryRawUnsafe' | '$executeRawUnsafe'>;
const txStore = new AsyncLocalStorage<RawClient>();
const client = (): RawClient => txStore.getStore() ?? db;

/* ------------------------------------------------------------- translation */

const NO_IDENTITY = /\binto\s+"?(session|sequence|member_application|member_edit_request|change_log_setup|account_opening_request|account_deactivation_request|account_activation_request|member_charging)"?\b/i;

/**
 * Rewrite the legacy `?` and `@named` placeholders into PostgreSQL's positional form.
 *
 * Both styles are in use: positional `?` with spread arguments, and `@named`
 * with a single object. A named parameter may appear more than once in one
 * statement and must reuse the same position.
 */
function bind(sql: string, args: unknown[]): { text: string; values: unknown[] } {
  const named = args.length === 1 && args[0] !== null
    && typeof args[0] === 'object' && !Array.isArray(args[0]);

  if (named) {
    const source = args[0] as Record<string, unknown>;
    const values: unknown[] = [];
    const seen = new Map<string, number>();
    const text = sql.replace(/@([a-zA-Z_][a-zA-Z0-9_]*)/g, (_m, key: string) => {
      let pos = seen.get(key);
      if (pos === undefined) {
        values.push(source[key] ?? null);
        pos = values.length;
        seen.set(key, pos);
      }
      return `$${pos}`;
    });
    return { text, values };
  }

  let i = 0;
  const text = sql.replace(/\?/g, () => `$${++i}`);
  return { text, values: args.map((v) => v ?? null) };
}

/**
 * Postgres hands back two numeric shapes this application does not want:
 *
 *   - `bigint` columns, and COUNT(), arrive as JavaScript BigInt
 *   - SUM()/AVG() over a bigint column are `numeric`, which the driver returns
 *     as a Decimal object — not a primitive
 *
 * Both must be flattened here. A Decimal that escapes this boundary reaches a
 * Server Component's props and React refuses to serialise it ("Only plain
 * objects can be passed to Client Components"), and `+` on one silently
 * concatenates instead of adding. Money is integer cents well inside 2^53, so
 * coercing to a plain number is lossless and lets the rest of the application
 * keep working in ordinary arithmetic.
 */
type DecimalLike = { toNumber: () => number };

const isDecimal = (v: unknown): v is DecimalLike =>
  typeof v === 'object' && v !== null && typeof (v as Partial<DecimalLike>).toNumber === 'function';

function scalar(v: unknown): unknown {
  if (typeof v === 'bigint') return Number(v);
  if (isDecimal(v)) return v.toNumber();
  return v;
}

function normalise<T>(rows: unknown): T {
  if (typeof rows === 'bigint' || isDecimal(rows)) return scalar(rows) as T;
  if (Array.isArray(rows)) return rows.map((r) => normalise(r)) as T;
  // Dates and Buffers are values, not row shapes — pass them through intact.
  if (rows && typeof rows === 'object' && !(rows instanceof Date) && !ArrayBuffer.isView(rows)) {
    const out: Record<string, unknown> = {};
    for (const [k, v] of Object.entries(rows as Record<string, unknown>)) {
      out[k] = scalar(v);
    }
    return out as T;
  }
  return rows as T;
}

/* ----------------------------------------------------------------- queries */

export async function all<T>(sql: string, ...args: unknown[]): Promise<T[]> {
  const { text, values } = bind(sql, args);
  return normalise<T[]>(await client().$queryRawUnsafe(text, ...values));
}

export async function one<T>(sql: string, ...args: unknown[]): Promise<T | undefined> {
  return (await all<T>(sql, ...args))[0];
}

/**
 * Whether `from` (e.g. `"member m"`) has any row matching `where`, ignoring search text and
 * dynamic filters entirely — this is what tells a genuinely empty list apart from a search or
 * filter that simply matched nothing, so a list page can grey out its filter controls only in
 * the former case instead of trapping a user who searched a non-empty list into zero results.
 * `where` takes this module's own `?`/`@name` placeholders, bound against `args` exactly like
 * `all`/`one` — never interpolate a caller-supplied value straight into it.
 */
export async function hasAnyRow(from: string, where?: string, ...args: unknown[]): Promise<boolean> {
  const row = await one<{ exists: boolean }>(
    `SELECT EXISTS(SELECT 1 FROM ${from} ${where ? `WHERE ${where}` : ''}) AS "exists"`,
    ...args,
  );
  return row?.exists ?? false;
}

export interface RunResult {
  changes: number;
  /** Named for continuity with the previous driver; it is the RETURNING id. */
  lastInsertRowid: number;
}

export async function run(sql: string, ...args: unknown[]): Promise<RunResult> {
  const isInsert = /^\s*insert\b/i.test(sql);
  const wantsId = isInsert && !/\breturning\b/i.test(sql) && !NO_IDENTITY.test(sql);
  const { text, values } = bind(wantsId ? `${sql} RETURNING id` : sql, args);

  // An INSERT with RETURNING is a query, not a command — $executeRaw discards
  // the row and would lose the new id.
  if (wantsId || /\breturning\b/i.test(sql)) {
    const rows = normalise<{ id?: number }[]>(await client().$queryRawUnsafe(text, ...values));
    return { changes: rows.length, lastInsertRowid: Number(rows[0]?.id ?? 0) };
  }
  const changes = await client().$executeRawUnsafe(text, ...values);
  return { changes, lastInsertRowid: 0 };
}

/**
 * Run `fn` atomically.
 *
 * PostgreSQL has no nested transactions, so a nested call joins the one already
 * open rather than starting a second — the semantics the services rely on when
 * openAccount() calls deposit(), or the seed wraps thousands of postings.
 *
 * The transaction client is threaded through AsyncLocalStorage so nested
 * services need no extra argument.
 */
export async function tx<T>(fn: () => Promise<T>): Promise<T> {
  if (txStore.getStore()) return fn();
  return db.$transaction(
    (client) => txStore.run(client as RawClient, fn),
    // The seed posts thousands of journals inside one transaction.
    { timeout: 120_000, maxWait: 15_000 },
  );
}

/* --------------------------------------------------------------- sequences */

export async function nextSequence(name: string): Promise<string> {
  // A single atomic statement: two clerks opening accounts at once cannot be
  // handed the same account number.
  const row = await one<{ prefix: string; next_no: number; width: number }>(
    'UPDATE sequence SET next_no = next_no + 1 WHERE name = ? RETURNING prefix, next_no - 1 AS next_no, width',
    name,
  );
  if (!row) throw new Error('Unknown sequence: ' + name);
  return row.prefix + String(row.next_no).padStart(row.width, '0');
}

export async function audit(
  user: Actor | null | undefined,
  action: string,
  entity?: string | null,
  entityId?: string | number | bigint | null,
  detail?: unknown,
): Promise<void> {
  await run(
    `INSERT INTO audit_log (at, user_id, username, action, entity, entity_id, detail)
     VALUES (?,?,?,?,?,?,?)`,
    new Date().toISOString(),
    user ? user.id : null,
    user ? user.username : 'system',
    action,
    entity ?? null,
    entityId != null ? String(entityId) : null,
    typeof detail === 'string' ? detail : detail ? JSON.stringify(detail) : null,
  );
}
