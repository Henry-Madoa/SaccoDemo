import 'server-only';
import { cookies } from 'next/headers';
import { cache } from 'react';
import { redirect } from 'next/navigation';
import { SESSION_COOKIE, userFromToken, can } from './auth.ts';
import { ForbiddenError } from './errors.ts';
import type { Permission, SessionUser } from './types.ts';

/**
 * The signed-in user for the current request.
 *
 * The SPA kept its bearer token in localStorage; Server Components cannot read
 * that, and it was readable by any injected script. The token now lives in an
 * httpOnly cookie. `cache()` dedupes the session lookup across every component
 * that asks for the user while rendering one request.
 */
export const getCurrentUser = cache(async (): Promise<SessionUser | null> => {
  const store = await cookies();
  return userFromToken(store.get(SESSION_COOKIE)?.value);
});

/** The current user, or a redirect to the sign-in screen. */
export async function requireUser(): Promise<SessionUser> {
  const user = await getCurrentUser();
  if (!user) redirect('/login');
  return user;
}

/** The current user, or a redirect / thrown ForbiddenError if they lack `permission`. */
export async function requirePerm(permission: Permission): Promise<SessionUser> {
  const user = await requireUser();
  if (!can(user, permission)) throw new ForbiddenError(permission);
  return user;
}

/** Non-throwing permission check for the current user. */
export async function currentCan(permission: Permission): Promise<boolean> {
  return can(await getCurrentUser(), permission);
}
