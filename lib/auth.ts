import crypto from 'node:crypto';
import { one, all, run, audit } from './db.ts';
import type { Actor, AppUser, PermissionSet, PermissionSetLine, SessionUser } from './types.ts';

const SESSION_HOURS = 12;
export const SESSION_COOKIE = 'sacco_session';

export function hashPassword(plain: string, salt?: string): string {
  const s = salt || crypto.randomBytes(16).toString('hex');
  const h = crypto.scryptSync(plain, s, 64).toString('hex');
  return `scrypt$${s}$${h}`;
}

export function verifyPassword(plain: string, stored: string): boolean {
  try {
    const [alg, salt, hash] = String(stored).split('$');
    if (alg !== 'scrypt') return false;
    const candidate = crypto.scryptSync(plain, salt, 64).toString('hex');
    return crypto.timingSafeEqual(Buffer.from(candidate, 'hex'), Buffer.from(hash, 'hex'));
  } catch {
    return false;
  }
}

async function createSession(user: Pick<AppUser, 'id'>): Promise<{ token: string; expiresAt: Date }> {
  const token = crypto.randomBytes(32).toString('hex');
  const now = new Date();
  const expiresAt = new Date(now.getTime() + SESSION_HOURS * 3600 * 1000);
  await run(
    'INSERT INTO session (token, user_id, created_at, expires_at) VALUES (?,?,?,?)',
    token, user.id, now.toISOString(), expiresAt.toISOString(),
  );
  await run('UPDATE app_user SET last_login_at = ? WHERE id = ?', now.toISOString(), user.id);
  return { token, expiresAt };
}

export async function destroySession(token: string | undefined): Promise<void> {
  if (token) await run('DELETE FROM session WHERE token = ?', token);
}

export async function userFromToken(token: string | undefined): Promise<SessionUser | null> {
  if (!token) return null;
  const session = await one<{ token: string; user_id: number; expires_at: string }>(
    'SELECT * FROM session WHERE token = ?', token,
  );
  if (!session) return null;
  if (new Date(session.expires_at) < new Date()) {
    await run('DELETE FROM session WHERE token = ?', token);
    return null;
  }

  const row = await one<AppUser & { role_name: string; is_system: 0 | 1 }>(
    `SELECT u.*, r.name AS role_name, r.is_system AS is_system
     FROM app_user u JOIN role r ON r.id = u.role_id WHERE u.id = ?`,
    session.user_id,
  );
  if (!row || row.status !== 'ACTIVE') return null;

  const { password_hash: _hash, ...rest } = row;
  return { ...rest, permissionSet: row.is_system ? { tables: {}, pages: {} } : await loadPermissionSet(row.role_id) };
}

/** Folds a role's permission_set_line rows into direct {table}/{page} lookups. */
export async function loadPermissionSet(roleId: number): Promise<PermissionSet> {
  const lines = await all<PermissionSetLine>('SELECT * FROM permission_set_line WHERE role_id = ?', roleId);
  const set: PermissionSet = { tables: {}, pages: {} };
  for (const line of lines) {
    if (line.object_type === 'PAGE') {
      if (line.execute_perm) set.pages[line.object_name] = true;
    } else {
      set.tables[line.object_name] = {
        read: !!line.read_perm, insert: !!line.insert_perm, modify: !!line.modify_perm, delete: !!line.delete_perm,
      };
    }
  }
  return set;
}

export interface LoginResult {
  token: string;
  expiresAt: Date;
  user: SessionUser | null;
}

export async function login(username: unknown, password: unknown, ip?: string): Promise<LoginResult | null> {
  const row = await one<AppUser>('SELECT * FROM app_user WHERE username = ?', String(username || '').trim());
  if (!row || row.status !== 'ACTIVE' || !verifyPassword(String(password ?? ''), row.password_hash)) {
    await audit(null, 'LOGIN_FAILED', 'app_user', null, { username, ip });
    return null;
  }
  const { token, expiresAt } = await createSession(row);
  await audit(row as Actor, 'LOGIN', 'app_user', row.id, { ip });
  return { token, expiresAt, user: await userFromToken(token) };
}
