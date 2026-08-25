import { one, all, run, tx, audit } from './db.ts';
import { AppError } from './errors.ts';
import { openAccount } from './savings.ts';
import { MEMBER_CATEGORY_TYPES } from './constants.ts';
import type {
  Actor, County, CountyWithUsage, DefaultAccountBacklogItem, DimensionValue, MemberCategory,
  MemberCategoryDefaultAccountRow, MemberCategoryWithUsage, SubCounty, SubCountyWithUsage,
} from './types.ts';

/* ------------------------------------------------------------------- counties */
export const listCounties = (): Promise<CountyWithUsage[]> =>
  all<CountyWithUsage>(
    `SELECT c.*, COUNT(DISTINCT s.id) AS sub_counties, COUNT(DISTINCT m.id) AS members
     FROM county c
     LEFT JOIN sub_county s ON s.county_id = c.id
     LEFT JOIN member m ON m.county_id = c.id
     GROUP BY c.id ORDER BY c.name`,
  );

export const listActiveCounties = (): Promise<County[]> =>
  all<County>("SELECT * FROM county WHERE status = 'ACTIVE' ORDER BY name");

export const listSubCounties = (): Promise<SubCountyWithUsage[]> =>
  all<SubCountyWithUsage>(
    `SELECT s.*, c.name AS county_name, COUNT(m.id) AS members
     FROM sub_county s
     JOIN county c ON c.id = s.county_id
     LEFT JOIN member m ON m.sub_county_id = s.id
     GROUP BY s.id, c.name ORDER BY c.name, s.name`,
  );

export const listActiveSubCounties = (): Promise<SubCounty[]> =>
  all<SubCounty>("SELECT * FROM sub_county WHERE status = 'ACTIVE' ORDER BY name");

export interface CountyInput {
  name?: string;
  status?: string | null;
}

/** A sub-county row as drafted in a county's own child grid — `id` is unset for a new row. */
export interface SubCountyDraft {
  id?: number | string | null;
  name: string;
  status?: string | null;
}

/**
 * Reconciles a county's sub-counties against the submitted grid, the same
 * "replace the child set" shape as a member category's default accounts —
 * except a sub-county can already be referenced by member.sub_county_id, so
 * rows are matched by id and updated in place rather than wiped and reinserted,
 * and a row can only be dropped once no member still points at it.
 */
async function replaceSubCounties(countyId: number, rows: SubCountyDraft[]): Promise<void> {
  const existing = await all<SubCounty>('SELECT * FROM sub_county WHERE county_id = ?', countyId);
  const submittedIds = new Set(rows.filter((r) => r.id).map((r) => Number(r.id)));

  for (const old of existing) {
    if (submittedIds.has(old.id)) continue;
    if (await one('SELECT 1 FROM member WHERE sub_county_id = ?', old.id)) {
      throw new AppError(`Cannot remove "${old.name}" — members are already assigned to it`, 'IN_USE');
    }
    await run('DELETE FROM sub_county WHERE id = ?', old.id);
  }

  const seen = new Set<string>();
  for (const row of rows) {
    const name = String(row.name || '').trim();
    if (!name) continue;
    const key = name.toLowerCase();
    if (seen.has(key)) throw new AppError(`Duplicate sub-county name "${name}"`, 'VALIDATION');
    seen.add(key);

    const id = row.id ? Number(row.id) : null;
    if (await one(
      `SELECT 1 FROM sub_county WHERE county_id = ? AND lower(name) = lower(?) AND id ${id ? '<> ?' : 'IS NOT NULL'}`,
      ...(id ? [countyId, name, id] : [countyId, name]),
    )) {
      throw new AppError(`Sub-county "${name}" already exists for this county`, 'DUPLICATE');
    }

    if (id) {
      await run('UPDATE sub_county SET name=?, status=? WHERE id=? AND county_id=?', name, row.status || 'ACTIVE', id, countyId);
    } else {
      await run('INSERT INTO sub_county (county_id, name, status) VALUES (?,?,?)', countyId, name, row.status || 'ACTIVE');
    }
  }
}

export async function createCounty(
  { name, status }: CountyInput,
  subCountyRows: SubCountyDraft[],
  user: Actor,
): Promise<{ id: number }> {
  if (!name) throw new AppError('County name is required', 'VALIDATION');

  return tx(async () => {
    if (await one('SELECT 1 FROM county WHERE name = ?', name)) {
      throw new AppError('That county already exists', 'DUPLICATE');
    }
    const info = await run('INSERT INTO county (name, status) VALUES (?,?)', name, status || 'ACTIVE');
    const id = Number(info.lastInsertRowid);
    await replaceSubCounties(id, subCountyRows);
    await audit(user, 'COUNTY_CREATE', 'county', id, { name, subCounties: subCountyRows.length });
    return { id };
  });
}

export async function updateCounty(
  id: number,
  { name, status }: CountyInput,
  subCountyRows: SubCountyDraft[],
  user: Actor,
): Promise<County> {
  return tx(async () => {
    await run(
      'UPDATE county SET name=COALESCE(?,name), status=COALESCE(?,status) WHERE id=?',
      name ?? null, status ?? null, id,
    );
    await replaceSubCounties(id, subCountyRows);
    await audit(user, 'COUNTY_UPDATE', 'county', id, { name, status, subCounties: subCountyRows.length });
    return (await one<County>('SELECT * FROM county WHERE id=?', id))!;
  });
}

/* ------------------------------------------------------------- member categories */
const MEMBER_CATEGORY_FIELDS = [
  'code', 'description', 'category_type', 'registration_fee', 'registration_fee_account_id', 'status',
] as const satisfies readonly (keyof MemberCategory)[];

export type MemberCategoryInput =
  Partial<Record<(typeof MEMBER_CATEGORY_FIELDS)[number], string | number | null>>;

export const listMemberCategories = (): Promise<MemberCategoryWithUsage[]> =>
  all<MemberCategoryWithUsage>(
    `SELECT c.*, g.code AS registration_fee_account_code, g.name AS registration_fee_account_name,
            COUNT(DISTINCT d.id) AS default_accounts, COUNT(DISTINCT m.id) AS members
     FROM member_category c
     LEFT JOIN gl_account g ON g.id = c.registration_fee_account_id
     LEFT JOIN member_category_default_account d ON d.member_category_id = c.id
     LEFT JOIN member m ON m.member_category_id = c.id
     GROUP BY c.id, g.code, g.name ORDER BY c.code`,
  );

export const listActiveMemberCategories = (): Promise<MemberCategory[]> =>
  all<MemberCategory>("SELECT * FROM member_category WHERE status = 'ACTIVE' ORDER BY code");

export const getMemberCategoryDefaultAccounts = (memberCategoryId: number): Promise<MemberCategoryDefaultAccountRow[]> =>
  all<MemberCategoryDefaultAccountRow>(
    `SELECT d.*, p.code AS savings_product_code, p.name AS savings_product_name
     FROM member_category_default_account d
     JOIN savings_product p ON p.id = d.savings_product_id
     WHERE d.member_category_id = ? ORDER BY p.code`,
    memberCategoryId,
  );

/**
 * The default accounts a category's existing members are still missing — for when defaults
 * are added (or a category's default set changes) after members were already registered,
 * since normally these only get provisioned once, at Member Application processing time (see
 * lib/memberApplications.ts) or via the Account Opening module for anything else. Excludes
 * members who have exited the society (WITHDRAWN/DECEASED) and any product a member already
 * holds. One item per (member, missing product) pair — the caller (a client-driven progress
 * UI) opens them one at a time via openDefaultAccountForMember() so it can show real progress.
 */
export async function getDefaultAccountsBacklog(memberCategoryId: number): Promise<DefaultAccountBacklogItem[]> {
  const defaults = await getMemberCategoryDefaultAccounts(memberCategoryId);
  if (!defaults.length) {
    throw new AppError('This category has no default accounts configured', 'VALIDATION');
  }

  const members = await all<{ id: number; member_no: string; first_name: string; last_name: string }>(
    `SELECT id, member_no, first_name, last_name FROM member
     WHERE member_category_id = ? AND status NOT IN ('WITHDRAWN','DECEASED') ORDER BY member_no`,
    memberCategoryId,
  );
  if (!members.length) return [];

  const memberIds = members.map((m) => m.id);
  const existing = await all<{ member_id: number; product_id: number }>(
    `SELECT member_id, product_id FROM savings_account WHERE member_id IN (${memberIds.map(() => '?').join(',')})`,
    ...memberIds,
  );
  const held = new Set(existing.map((e) => `${e.member_id}:${e.product_id}`));

  const items: DefaultAccountBacklogItem[] = [];
  for (const m of members) {
    for (const d of defaults) {
      if (held.has(`${m.id}:${d.savings_product_id}`)) continue;
      items.push({
        memberId: m.id, memberNo: m.member_no, memberName: `${m.first_name} ${m.last_name}`,
        productId: d.savings_product_id, productCode: d.savings_product_code, productName: d.savings_product_name,
      });
    }
  }
  return items;
}

/** Opens one backlog item's account. Re-checks the member doesn't already hold the product —
 *  a concurrent run, or someone opening it by hand — could have closed the gap since the
 *  backlog was computed, so this is safe to call even against a stale item. */
export async function openDefaultAccountForMember(
  memberId: number, productId: number, user: Actor,
): Promise<{ accountId: number } | { skipped: true }> {
  const already = await one('SELECT 1 FROM savings_account WHERE member_id = ? AND product_id = ?', memberId, productId);
  if (already) return { skipped: true };
  const account = await openAccount({ memberId, productId, user, enforceMinOpening: false });
  await audit(user, 'MEMBER_CATEGORY_DEFAULT_ACCOUNT_CREATE', 'member', memberId, { productId, accountId: account.id });
  return { accountId: account.id };
}

/** Replaces the full default-account set for a category with the given product ids. */
async function replaceDefaultAccounts(memberCategoryId: number, savingsProductIds: number[]): Promise<void> {
  await run('DELETE FROM member_category_default_account WHERE member_category_id = ?', memberCategoryId);
  for (const productId of savingsProductIds) {
    const product = await one<{ name: string }>('SELECT name FROM savings_product WHERE id = ?', productId);
    if (!product) throw new AppError('One of the selected savings products no longer exists', 'VALIDATION');
    await run(
      `INSERT INTO member_category_default_account (member_category_id, savings_product_id, description)
       VALUES (?,?,?)`,
      memberCategoryId, productId, product.name,
    );
  }
}

/**
 * A configured Registration Fee is worthless unless it can actually be recovered —
 * lib/entranceFeeRecovery.ts's recoverOne() posts a credit line to this account every time it
 * sweeps a Not Paid Up member's deposit, and postJournal() rejects a non-postable/inactive
 * target with GL_NOT_POSTABLE. That used to only surface at the next unattended recovery run,
 * per-member, with the failure swallowed into a skipped_reason nothing displayed — checked here
 * instead so a bad account is caught the moment it's configured, the same way a Registration Fee
 * amount itself is required up front rather than discovered missing later.
 */
async function assertValidRegistrationFeeAccount(
  fee: number | null | undefined, accountId: number | null | undefined,
): Promise<void> {
  if (!fee || fee <= 0) return;
  if (!accountId) {
    throw new AppError('A Registration Fee Account is required whenever a Registration Fee is set', 'VALIDATION');
  }
  const account = await one<{ code: string; is_postable: number; status: string }>(
    'SELECT code, is_postable, status FROM gl_account WHERE id = ?', accountId,
  );
  if (!account) throw new AppError('Registration Fee Account not found', 'VALIDATION');
  if (!account.is_postable) {
    throw new AppError(
      `GL account ${account.code} is a header account and cannot be posted to — choose a postable account`, 'VALIDATION',
    );
  }
  if (account.status !== 'ACTIVE') {
    throw new AppError(`GL account ${account.code} is not active`, 'VALIDATION');
  }
}

export async function createMemberCategory(
  body: MemberCategoryInput,
  savingsProductIds: number[],
  user: Actor,
): Promise<{ id: number }> {
  if (!body.code || !body.description || !body.category_type) {
    throw new AppError('Code, description and category type are required', 'VALIDATION');
  }
  if (!MEMBER_CATEGORY_TYPES.some((t) => t.value === body.category_type)) {
    throw new AppError('Invalid category type', 'VALIDATION');
  }
  if (await one('SELECT 1 FROM member_category WHERE code = ?', body.code)) {
    throw new AppError('Category code already exists', 'DUPLICATE');
  }
  await assertValidRegistrationFeeAccount(
    body.registration_fee != null ? Number(body.registration_fee) : null,
    body.registration_fee_account_id != null ? Number(body.registration_fee_account_id) : null,
  );

  return tx(async () => {
    const cols = MEMBER_CATEGORY_FIELDS.filter((f) => body[f] !== undefined);
    const info = await run(
      `INSERT INTO member_category (${cols.join(',')}) VALUES (${cols.map(() => '?').join(',')})`,
      ...cols.map((c) => body[c]!),
    );
    const id = Number(info.lastInsertRowid);
    await replaceDefaultAccounts(id, savingsProductIds);
    await audit(user, 'MEMBER_CATEGORY_CREATE', 'member_category', id, { code: body.code });
    return { id };
  });
}

export async function updateMemberCategory(
  id: number,
  body: MemberCategoryInput,
  savingsProductIds: number[],
  user: Actor,
): Promise<MemberCategory> {
  const before = await one<MemberCategory>('SELECT * FROM member_category WHERE id = ?', id);
  if (!before) throw new AppError('Category not found', 'NOT_FOUND');
  if (body.category_type && !MEMBER_CATEGORY_TYPES.some((t) => t.value === body.category_type)) {
    throw new AppError('Invalid category type', 'VALIDATION');
  }
  // Validated against the *effective* post-update value, not just what this call happens to
  // submit — editing only the fee (leaving a stale bad account untouched) must still be caught,
  // and so must editing only the account while an existing fee is already set.
  const effectiveFee = body.registration_fee !== undefined ? Number(body.registration_fee) : before.registration_fee;
  const effectiveAccountId = body.registration_fee_account_id !== undefined
    ? (body.registration_fee_account_id != null ? Number(body.registration_fee_account_id) : null)
    : before.registration_fee_account_id;
  await assertValidRegistrationFeeAccount(effectiveFee, effectiveAccountId);

  return tx(async () => {
    const cols = MEMBER_CATEGORY_FIELDS.filter((f) => body[f] !== undefined && f !== 'code');
    if (cols.length) {
      await run(
        `UPDATE member_category SET ${cols.map((c) => `${c}=?`).join(',')} WHERE id=?`,
        ...cols.map((c) => body[c]!), id,
      );
    }
    await replaceDefaultAccounts(id, savingsProductIds);
    await audit(user, 'MEMBER_CATEGORY_UPDATE', 'member_category', id, { fields: cols });
    return (await one<MemberCategory>('SELECT * FROM member_category WHERE id=?', id))!;
  });
}

/* ------------------------------------------------------------- global dimensions */

export type DimensionSlot = 1 | 2;

const DIMENSION_TABLE: Record<DimensionSlot, string> = {
  1: 'global_dimension_1_value',
  2: 'global_dimension_2_value',
};

export interface DimensionValueInput {
  code?: string;
  name?: string;
  status?: string | null;
}

export const listDimensionValues = (slot: DimensionSlot): Promise<DimensionValue[]> =>
  all<DimensionValue>(`SELECT * FROM ${DIMENSION_TABLE[slot]} ORDER BY name`);

export const listActiveDimensionValues = (slot: DimensionSlot): Promise<DimensionValue[]> =>
  all<DimensionValue>(`SELECT * FROM ${DIMENSION_TABLE[slot]} WHERE status = 'ACTIVE' ORDER BY name`);

export async function createDimensionValue(
  slot: DimensionSlot, { code, name, status }: DimensionValueInput, user: Actor,
): Promise<{ id: number }> {
  if (!code || !name) throw new AppError('Code and name are required', 'VALIDATION');
  const table = DIMENSION_TABLE[slot];
  if (await one(`SELECT 1 FROM ${table} WHERE code = ? OR name = ?`, code, name)) {
    throw new AppError('That value already exists', 'DUPLICATE');
  }
  const info = await run(
    `INSERT INTO ${table} (code, name, status) VALUES (?,?,?)`,
    code, name, status || 'ACTIVE',
  );
  await audit(user, `GLOBAL_DIMENSION_${slot}_VALUE_CREATE`, table, info.lastInsertRowid, { code, name });
  return { id: Number(info.lastInsertRowid) };
}

export async function updateDimensionValue(
  slot: DimensionSlot, id: number, { name, status }: DimensionValueInput, user: Actor,
): Promise<DimensionValue> {
  const table = DIMENSION_TABLE[slot];
  await run(
    `UPDATE ${table} SET name=COALESCE(?,name), status=COALESCE(?,status) WHERE id=?`,
    name ?? null, status ?? null, id,
  );
  await audit(user, `GLOBAL_DIMENSION_${slot}_VALUE_UPDATE`, table, id, { name, status });
  return (await one<DimensionValue>(`SELECT * FROM ${table} WHERE id=?`, id))!;
}
