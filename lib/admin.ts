import { one, all, run, audit } from './db.ts';
import { AppError } from './errors.ts';
import { hashPassword } from './auth.ts';
import { passwordStrengthError } from './password.ts';
import type {
  Actor, AuditEntry, LoanProduct, LoanProductWithUsage, Permission, Role,
  RoleWithUsage, SavingsProduct, SavingsProductWithUsage, UserListRow, UserStatus,
} from './types.ts';

/* --------------------------------------------------------------------- roles */
/*
 * One grouped join instead of a COUNT(*) query per role — the old handler ran
 * 1 + N queries to fill in userCount.
 */
export const listRoles = async (): Promise<RoleWithUsage[]> =>
  (await all<Role & { userCount: number }>(
    `SELECT r.*, COUNT(u.id) AS userCount
     FROM role r LEFT JOIN app_user u ON u.role_id = r.id
     GROUP BY r.id ORDER BY r.id`,
  )).map((r) => ({ ...r, permissions: JSON.parse(r.permissions) as Permission[] }));

export interface RoleInput {
  name?: string;
  description?: string | null;
  permissions?: Permission[];
}

export async function createRole(
  { name, description, permissions = [] }: RoleInput,
  user: Actor,
): Promise<{ id: number }> {
  if (!name) throw new AppError('Role name is required', 'VALIDATION');
  const info = await run(
    'INSERT INTO role (name, description, permissions) VALUES (?,?,?)',
    name, description || null, JSON.stringify(permissions),
  );
  await audit(user, 'ROLE_CREATE', 'role', info.lastInsertRowid, { name, permissions });
  return { id: Number(info.lastInsertRowid) };
}

export async function updateRole(
  id: number,
  { name, description, permissions }: RoleInput,
  user: Actor,
): Promise<Role> {
  const role = await one<Role>('SELECT * FROM role WHERE id = ?', id);
  if (!role) throw new AppError('Role not found', 'NOT_FOUND');
  if (role.is_system) throw new AppError('The System Administrator role cannot be modified', 'SYSTEM_ROLE');
  await run(
    `UPDATE role SET name=COALESCE(?,name), description=COALESCE(?,description),
      permissions=COALESCE(?,permissions) WHERE id=?`,
    name ?? null, description ?? null, permissions ? JSON.stringify(permissions) : null, id,
  );
  await audit(user, 'ROLE_UPDATE', 'role', id, { permissions });
  return (await one<Role>('SELECT * FROM role WHERE id = ?', id))!;
}

/* --------------------------------------------------------------------- users */
export const listUsers = (): Promise<UserListRow[]> =>
  all<UserListRow>(
    `SELECT u.id, u.username, u.full_name, u.email, u.phone, u.status, u.last_login_at, u.created_at,
            r.name AS role_name, r.id AS role_id
     FROM app_user u JOIN role r ON r.id = u.role_id
     ORDER BY u.full_name`,
  );

export interface UserInput {
  username?: string;
  full_name?: string;
  email?: string | null;
  phone?: string | null;
  password?: string | null;
  role_id?: number | null;
  status?: UserStatus | null;
}

export async function createUser(
  { username, full_name, email, phone, password, role_id }: UserInput,
  user: Actor,
): Promise<{ id: number }> {
  if (!username || !full_name || !password || !role_id) {
    throw new AppError('Username, name, password and role are required', 'VALIDATION');
  }
  const pwError = passwordStrengthError(String(password), { username });
  if (pwError) throw new AppError(pwError, 'WEAK_PASSWORD');
  if (await one('SELECT 1 FROM app_user WHERE username = ?', username)) {
    throw new AppError('That username is already taken', 'DUPLICATE');
  }
  const info = await run(
    `INSERT INTO app_user (username, full_name, email, phone, password_hash, role_id, created_at)
     VALUES (?,?,?,?,?,?,?)`,
    username, full_name, email || null, phone || null, hashPassword(password),
    role_id, new Date().toISOString(),
  );
  await audit(user, 'USER_CREATE', 'app_user', info.lastInsertRowid, { username, role_id });
  return { id: Number(info.lastInsertRowid) };
}

export async function updateUser(
  id: number,
  { full_name, email, phone, role_id, status, password }: UserInput,
  user: Actor,
): Promise<{ updated: true }> {
  if (Number(id) === user.id && status && status !== 'ACTIVE') {
    throw new AppError('You cannot deactivate your own account', 'SELF_LOCKOUT');
  }
  if (password) {
    const existing = await one<{ username: string }>('SELECT username FROM app_user WHERE id = ?', id);
    const pwError = passwordStrengthError(String(password), { username: existing?.username });
    if (pwError) throw new AppError(pwError, 'WEAK_PASSWORD');
  }
  await run(
    `UPDATE app_user SET full_name=COALESCE(?,full_name), email=COALESCE(?,email), phone=COALESCE(?,phone),
      role_id=COALESCE(?,role_id), status=COALESCE(?,status),
      password_hash=COALESCE(?,password_hash) WHERE id=?`,
    full_name ?? null, email ?? null, phone ?? null, role_id ?? null, status ?? null,
    password ? hashPassword(password) : null, id,
  );
  await audit(user, 'USER_UPDATE', 'app_user', id, { role_id, status, passwordReset: !!password });
  return { updated: true };
}

/* ---------------------------------------------------------- savings products */
const SAVINGS_PRODUCT_FIELDS = [
  'code', 'name', 'category', 'min_balance', 'min_opening', 'interest_rate', 'allow_withdrawal',
  'withdrawal_fee', 'is_loanable_base', 'withdrawal_notice_days', 'gl_control_id', 'gl_interest_exp_id',
  'gl_fee_income_id', 'status',
] as const satisfies readonly (keyof SavingsProduct)[];

export type SavingsProductInput =
  Partial<Record<(typeof SAVINGS_PRODUCT_FIELDS)[number], string | number | null>>;

export const listSavingsProducts = (): Promise<SavingsProductWithUsage[]> =>
  all<SavingsProductWithUsage>(
    `SELECT p.*, g.code AS gl_control_code, g.name AS gl_control_name,
            COUNT(a.id) AS accounts, COALESCE(SUM(a.balance),0) AS portfolio
     FROM savings_product p
     LEFT JOIN gl_account g ON g.id = p.gl_control_id
     LEFT JOIN savings_account a ON a.product_id = p.id
     GROUP BY p.id, g.code, g.name ORDER BY p.id`,
  );

export const listActiveSavingsProducts = (): Promise<SavingsProduct[]> =>
  all<SavingsProduct>("SELECT * FROM savings_product WHERE status = 'ACTIVE' ORDER BY id");

export async function createSavingsProduct(
  body: SavingsProductInput,
  user: Actor,
): Promise<{ id: number }> {
  if (!body.code || !body.name || !body.gl_control_id) {
    throw new AppError('Code, name and GL control account are required', 'VALIDATION');
  }
  const cols = SAVINGS_PRODUCT_FIELDS.filter((f) => body[f] !== undefined);
  const info = await run(
    `INSERT INTO savings_product (${cols.join(',')}) VALUES (${cols.map(() => '?').join(',')})`,
    ...cols.map((c) => body[c]!),
  );
  await audit(user, 'SAVINGS_PRODUCT_CREATE', 'savings_product', info.lastInsertRowid, { code: body.code });
  return { id: Number(info.lastInsertRowid) };
}

export async function updateSavingsProduct(
  id: number,
  body: SavingsProductInput,
  user: Actor,
): Promise<SavingsProduct> {
  const cols = SAVINGS_PRODUCT_FIELDS.filter((f) => body[f] !== undefined && f !== 'code');
  if (cols.length) {
    await run(
      `UPDATE savings_product SET ${cols.map((c) => `${c}=?`).join(',')} WHERE id=?`,
      ...cols.map((c) => body[c]!), id,
    );
  }
  await audit(user, 'SAVINGS_PRODUCT_UPDATE', 'savings_product', id, { fields: cols });
  return (await one<SavingsProduct>('SELECT * FROM savings_product WHERE id=?', id))!;
}

/* ------------------------------------------------------------- loan products */
const LOAN_PRODUCT_FIELDS = [
  'code', 'name', 'interest_rate', 'interest_method', 'max_term_months', 'min_amount', 'max_amount',
  'deposit_multiplier', 'min_membership_months', 'processing_fee_pct', 'insurance_pct', 'penalty_rate',
  'guarantors_required', 'max_dsr_pct', 'gl_receivable_id', 'gl_interest_income_id', 'gl_fee_income_id',
  'gl_penalty_income_id', 'status',
] as const satisfies readonly (keyof LoanProduct)[];

export type LoanProductInput =
  Partial<Record<(typeof LOAN_PRODUCT_FIELDS)[number], string | number | null>>;

export const listLoanProducts = (): Promise<LoanProductWithUsage[]> =>
  all<LoanProductWithUsage>(
    `SELECT p.*,
            COUNT(CASE WHEN l.status='DISBURSED' THEN 1 END) AS active_loans,
            COALESCE(SUM(CASE WHEN l.status='DISBURSED' THEN l.principal_balance ELSE 0 END),0) AS portfolio
     FROM loan_product p LEFT JOIN loan l ON l.product_id = p.id
     GROUP BY p.id ORDER BY p.id`,
  );

export const listActiveLoanProducts = (): Promise<LoanProduct[]> =>
  all<LoanProduct>("SELECT * FROM loan_product WHERE status = 'ACTIVE' ORDER BY id");

export async function createLoanProduct(body: LoanProductInput, user: Actor): Promise<{ id: number }> {
  if (!body.code || !body.name || !body.gl_receivable_id) {
    throw new AppError('Code, name and receivable account are required', 'VALIDATION');
  }
  const cols = LOAN_PRODUCT_FIELDS.filter((f) => body[f] !== undefined);
  const info = await run(
    `INSERT INTO loan_product (${cols.join(',')}) VALUES (${cols.map(() => '?').join(',')})`,
    ...cols.map((c) => body[c]!),
  );
  await audit(user, 'LOAN_PRODUCT_CREATE', 'loan_product', info.lastInsertRowid, { code: body.code });
  return { id: Number(info.lastInsertRowid) };
}

export async function updateLoanProduct(
  id: number,
  body: LoanProductInput,
  user: Actor,
): Promise<LoanProduct> {
  const cols = LOAN_PRODUCT_FIELDS.filter((f) => body[f] !== undefined && f !== 'code');
  if (cols.length) {
    await run(
      `UPDATE loan_product SET ${cols.map((c) => `${c}=?`).join(',')} WHERE id=?`,
      ...cols.map((c) => body[c]!), id,
    );
  }
  await audit(user, 'LOAN_PRODUCT_UPDATE', 'loan_product', id, { fields: cols });
  return (await one<LoanProduct>('SELECT * FROM loan_product WHERE id=?', id))!;
}

/* --------------------------------------------------------------- audit trail */
export function listAuditLog({ search = '', limit = 300 } = {}): Promise<AuditEntry[]> {
  return all<AuditEntry>(
    `SELECT * FROM audit_log
     WHERE (username LIKE @like OR action LIKE @like OR entity LIKE @like)
     ORDER BY id DESC LIMIT @limit`,
    { like: `%${String(search).trim()}%`, limit: Math.min(limit, 500) },
  );
}
