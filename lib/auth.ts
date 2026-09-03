import crypto from 'node:crypto';
import { one, all, run, audit } from './db.ts';
import type {
  Actor, AppUser, PermissionSet, PermissionSetLine, Profile, SessionUser, UserPermissionLine,
} from './types.ts';

/** Used when a user has no Profile assigned yet (or the row is somehow missing) — the app must
 *  still land somewhere, and Super is the original all-round dashboard. */
const SUPER_FALLBACK: Profile = {
  id: 0, code: 'SUPER', name: 'Super Role Centre', description: '', role_centre: 'SUPER',
  icon: '▤', sort: 0, is_default: 1, is_system: 1, created_at: null, created_by: null,
};

/** Every Profile assigned to a user, plus the active one (resolved, never null). A system-admin
 *  user implicitly holds every Profile. */
async function loadProfiles(
  userId: number, activeProfileId: number | null, isSystem: boolean,
): Promise<{ profiles: Profile[]; activeProfile: Profile }> {
  const all_ = await all<Profile>('SELECT * FROM profile ORDER BY sort, id');
  const profiles = isSystem
    ? all_
    : await all<Profile>(
      `SELECT p.* FROM user_profile up JOIN profile p ON p.id = up.profile_id
       WHERE up.user_id = ? ORDER BY p.sort, p.id`,
      userId,
    );
  if (!profiles.length) return { profiles: [SUPER_FALLBACK], activeProfile: SUPER_FALLBACK };
  const activeProfile = profiles.find((p) => p.id === activeProfileId)
    ?? profiles.find((p) => p.is_default)
    ?? profiles[0];
  return { profiles, activeProfile };
}

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
  const [permissionSet, { profiles, activeProfile }] = await Promise.all([
    loadUserEffectivePermissions(row.id, row.role_id, !!row.is_system),
    loadProfiles(row.id, row.active_profile_id, !!row.is_system),
  ]);
  return { ...rest, permissionSet, profiles, activeProfile };
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

/** ORs `other` into `set` in place — the Business Central "union of every assigned Permission
 *  Set" rule. */
function unionInto(set: PermissionSet, other: PermissionSet): void {
  for (const [code, on] of Object.entries(other.pages)) {
    if (on) set.pages[code] = true;
  }
  for (const [name, r] of Object.entries(other.tables)) {
    const cur = set.tables[name] ?? { read: false, insert: false, modify: false, delete: false };
    set.tables[name] = {
      read: cur.read || r.read, insert: cur.insert || r.insert,
      modify: cur.modify || r.modify, delete: cur.delete || r.delete,
    };
  }
}

/**
 * The permissions a user is *granted* — the Business Central union of their primary role
 * (`app_user.role_id`) plus every additional Permission Set assigned to them
 * (`user_permission_set`). Per-user overrides are NOT applied here — this is the baseline the
 * override editor diffs against.
 */
export async function loadGrantedPermissions(userId: number, roleId: number): Promise<PermissionSet> {
  const [set, extraSetIds] = await Promise.all([
    loadPermissionSet(roleId),
    all<{ role_id: number }>('SELECT role_id FROM user_permission_set WHERE user_id = ?', userId),
  ]);
  for (const { role_id } of extraSetIds) {
    if (role_id !== roleId) unionInto(set, await loadPermissionSet(role_id));
  }
  return set;
}

/**
 * A user's *effective* permissions, Business Central style:
 *   1. `loadGrantedPermissions` — the union of the primary role + every additional Permission Set
 *   2. then each per-user override (`user_permission_line`) applied on top — an override row
 *      replaces the granted rights for that one object, so an admin can also *restrict* a user.
 * System-admin users are unrestricted; canX() short-circuits on is_system, so their set is left
 * empty regardless of any assigned sets or override rows.
 */
export async function loadUserEffectivePermissions(
  userId: number, roleId: number, isSystem: boolean,
): Promise<PermissionSet> {
  if (isSystem) return { tables: {}, pages: {} };
  const [set, overrides] = await Promise.all([
    loadGrantedPermissions(userId, roleId),
    all<UserPermissionLine>('SELECT * FROM user_permission_line WHERE user_id = ?', userId),
  ]);
  for (const o of overrides) {
    if (o.object_type === 'PAGE') {
      if (o.execute_perm) set.pages[o.object_name] = true;
      else delete set.pages[o.object_name];
    } else {
      set.tables[o.object_name] = {
        read: !!o.read_perm, insert: !!o.insert_perm, modify: !!o.modify_perm, delete: !!o.delete_perm,
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
