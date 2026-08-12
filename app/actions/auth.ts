'use server';

import { cookies, headers } from 'next/headers';
import { redirect } from 'next/navigation';
import * as auth from '@/lib/auth';
import { audit } from '@/lib/db';
import { getCurrentUser } from '@/lib/session';

export interface SignInState {
  error?: string;
}

export async function signIn(_prevState: SignInState, formData: FormData): Promise<SignInState> {
  const username = formData.get('username');
  const password = formData.get('password');

  const requestHeaders = await headers();
  const ip = requestHeaders.get('x-forwarded-for') || 'local';
  const result = await auth.login(username, password, ip);

  if (!result) return { error: 'Username or password is incorrect' };

  const store = await cookies();
  store.set(auth.SESSION_COOKIE, result.token, {
    httpOnly: true,          // the SPA kept this in localStorage, where any script could read it
    sameSite: 'lax',
    path: '/',
    secure: process.env.NODE_ENV === 'production',
    expires: result.expiresAt,
  });

  redirect('/dashboard');
}

export async function signOut(): Promise<void> {
  const store = await cookies();
  const token = store.get(auth.SESSION_COOKIE)?.value;
  const user = await getCurrentUser();
  if (user) await audit(user, 'LOGOUT', 'app_user', user.id);
  await auth.destroySession(token);
  store.delete(auth.SESSION_COOKIE);
  redirect('/login');
}
