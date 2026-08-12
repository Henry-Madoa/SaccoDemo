import 'server-only';
import { seedIfEmpty } from './seed.ts';

/*
 * Seeding used to live in instrumentation.ts, but Next.js also compiles that
 * file for the edge runtime, where the database driver's node built-ins cannot
 * resolve — and that build failure takes down every route. Running it from the
 * root layout instead keeps the native module confined to the Node server
 * bundle, where `serverExternalPackages` applies.
 */
/*
 * The in-flight promise is what is memoised, not a boolean: the seed is now
 * asynchronous, and both generateMetadata() and the layout body call this while
 * rendering the same request. Caching the promise makes the later callers wait
 * for the first seed instead of racing past a flag that is set before the work
 * has actually finished.
 */
const globalForBootstrap = globalThis as typeof globalThis & { __saccoSeeding?: Promise<void> };

export function ensureSeeded(): Promise<void> {
  globalForBootstrap.__saccoSeeding ??= (async () => {
    const started = Date.now();
    const result = await seedIfEmpty();
    if (result.seeded) {
      console.log(`  Seeded ${result.members} members and ${result.loans} disbursed loans in ${Date.now() - started} ms.`);
      console.log('  Sign in as admin/admin123, manager/manager123, loans/loans123, teller/teller123, finance/finance123 or auditor/auditor123.');
    }
  })();
  return globalForBootstrap.__saccoSeeding;
}
