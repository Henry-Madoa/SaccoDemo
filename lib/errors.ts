import type { ActionResult } from './types.ts';

/**
 * A business-rule failure that is safe to show the user verbatim.
 *
 * Server Actions must not throw across the network boundary — Next.js replaces
 * an uncaught error with a generic digest in production — so actions catch this
 * and return `{ ok: false, error }` instead.
 */
export class AppError extends Error {
  readonly code: string;

  constructor(message: string, code = 'APP_ERROR') {
    super(message);
    this.name = 'AppError';
    this.code = code;
  }
}

/** Raised by the posting engine and the services that drive it. */
export class PostingError extends AppError {
  constructor(message: string, code = 'POSTING_ERROR') {
    super(message, code);
    this.name = 'PostingError';
  }
}

export class ForbiddenError extends AppError {
  constructor(permission: string) {
    super(`Your role does not carry the ${permission} permission`, 'FORBIDDEN');
    this.name = 'ForbiddenError';
  }
}

/** Wrap a Server Action body so business failures come back as data. */
export async function actionResult<T>(fn: () => T | Promise<T>): Promise<ActionResult<T>> {
  try {
    return { ok: true, data: await fn() };
  } catch (err) {
    if (err instanceof AppError) return { ok: false, error: err.message, code: err.code };
    console.error('[action]', err);
    const message = err instanceof Error ? err.message : 'Unexpected error';
    return { ok: false, error: message, code: 'INTERNAL_ERROR' };
  }
}
