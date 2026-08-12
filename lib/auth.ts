import crypto from 'node:crypto';
import { one, run, audit } from './db.ts';
import type { Actor, AppUser, Permission, PermissionResource, SessionUser } from './types.ts';

export const SESSION_HOURS = 12;
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

/* Permission catalogue — resource:action, as specified in section 4 of the design. */
export const PERMISSIONS: Record<PermissionResource, string[]> = {
  MEMBER: ['READ', 'CREATE', 'UPDATE', 'APPROVE'],
  SAVINGS: ['READ', 'OPEN', 'DEPOSIT', 'WITHDRAW', 'REVERSE'],
  LOAN: ['READ', 'CREATE', 'APPROVE', 'DISBURSE', 'REPAY', 'WRITE_OFF'],
  GL: ['READ', 'JOURNAL_CREATE', 'JOURNAL_APPROVE', 'PERIOD_CLOSE'],
  REPORT: ['VIEW', 'EXPORT'],
  ADMIN: ['ORG_MANAGE', 'THEME_MANAGE', 'USER_MANAGE', 'ROLE_MANAGE', 'PRODUCT_MANAGE', 'BRANCH_MANAGE', 'COA_MANAGE', 'AUDIT_VIEW'],
};

export async function createSession(user: Pick<AppUser, 'id'>): Promise<{ token: string; expiresAt: Date }> {
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

  const row = await one<AppUser & { role_name: string; permissions: string; branch_name: string | null }>(
    `SELECT u.*, r.name AS role_name, r.permissions AS permissions, b.name AS branch_name
     FROM app_user u JOIN role r ON r.id = u.role_id
     LEFT JOIN branch b ON b.id = u.branch_id WHERE u.id = ?`,
    session.user_id,
  );
  if (!row || row.status !== 'ACTIVE') return null;

  // Strip the credential and the raw JSON before the record leaves this layer.
  const { password_hash: _hash, permissions, ...rest } = row;
  return { ...rest, permissionList: JSON.parse(permissions || '[]') as Permission[] };
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

/** Does `user` hold `permission`? Understands the `*` and `RESOURCE:*` wildcards. */
export function can(user: SessionUser | null | undefined, permission: Permission): boolean {
  if (!user) return false;
  const list = user.permissionList || [];
  if (list.includes('*')) return true;
  if (list.includes(permission)) return true;
  return list.includes(`${permission.split(':')[0]}:*`);
}
