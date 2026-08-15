'use server';

import { revalidatePath } from 'next/cache';
import { requireAction } from '@/lib/session';
import { actionResult } from '@/lib/errors';
import * as pool from '@/lib/pool';
import { updateOrg } from '@/lib/org';
import { toCents } from '@/lib/format';
import type {
  ActionResult, County, DefaultAccountBacklogItem, DimensionValue, FormValues, MemberCategory,
  MemberCategoryType, Organisation,
} from '@/lib/types';

/* ------------------------------------------------------------------- counties */
export async function saveCounty(
  id: number | null,
  values: FormValues,
  rows: pool.SubCountyDraft[],
): Promise<ActionResult<County | { id: number }>> {
  return actionResult(async () => {
    const user = await requireAction('ADMIN_POOL_COUNTIES_MANAGE');
    const body: pool.CountyInput = {
      name: String(values.name || '').trim(),
      status: values.status ? String(values.status) : null,
    };
    const subCountyRows = rows.filter((r) => String(r.name || '').trim());
    const result = id
      ? await pool.updateCounty(id, body, subCountyRows, user)
      : await pool.createCounty(body, subCountyRows, user);
    revalidatePath('/admin/pool');
    return result;
  });
}

/** A default-account row as drafted in the child grid. */
export interface DefaultAccountDraft {
  savings_product_id: number | string;
}

export async function saveMemberCategory(
  id: number | null,
  values: FormValues,
  rows: DefaultAccountDraft[],
): Promise<ActionResult<MemberCategory | { id: number }>> {
  return actionResult(async () => {
    const user = await requireAction('ADMIN_POOL_CATEGORIES_MANAGE');
    const body: pool.MemberCategoryInput = {
      code: String(values.code || '').trim().toUpperCase(),
      description: String(values.description || '').trim(),
      category_type: values.category_type as MemberCategoryType,
      registration_fee: toCents(values.registration_fee_sh),
      registration_fee_account_id: Number(values.registration_fee_account_id) || null,
      status: String(values.status || 'ACTIVE'),
    };
    const productIds = rows
      .map((r) => Number(r.savings_product_id))
      .filter((n) => Number.isInteger(n) && n > 0);

    const result = id
      ? await pool.updateMemberCategory(id, body, productIds, user)
      : await pool.createMemberCategory(body, productIds, user);
    revalidatePath('/admin/pool');
    return result;
  });
}

/** The default accounts a category's existing members are still missing — the plan a "Create
 *  Default Accounts" progress run works through, one item at a time (see createOneDefaultAccount). */
export async function loadDefaultAccountsBacklog(categoryId: number): Promise<ActionResult<DefaultAccountBacklogItem[]>> {
  return actionResult(async () => {
    await requireAction('ADMIN_POOL_CATEGORIES_MANAGE');
    return pool.getDefaultAccountsBacklog(categoryId);
  });
}

/** Opens exactly one backlog item's account — called once per item by the client-driven
 *  progress UI, so the browser can show real per-item progress instead of a single opaque
 *  bulk call. */
export async function createOneDefaultAccount(
  memberId: number, productId: number,
): Promise<ActionResult<{ accountId: number } | { skipped: true }>> {
  return actionResult(async () => {
    const user = await requireAction('ADMIN_POOL_CATEGORIES_MANAGE');
    return pool.openDefaultAccountForMember(memberId, productId, user);
  });
}

/** Refreshes the affected pages once a Create Default Accounts run finishes (or is cancelled)
 *  — called once at the end rather than after every item, since a run can touch dozens of them. */
export async function finishDefaultAccountsRun(): Promise<ActionResult<{ done: true }>> {
  return actionResult(async () => {
    await requireAction('ADMIN_POOL_CATEGORIES_MANAGE');
    revalidatePath('/admin/pool');
    revalidatePath('/members');
    return { done: true };
  });
}

/* ------------------------------------------------------------- global dimensions */
export async function saveDimensionValue(
  slot: pool.DimensionSlot,
  id: number | null,
  values: FormValues,
): Promise<ActionResult<DimensionValue | { id: number }>> {
  return actionResult(async () => {
    const user = await requireAction('ADMIN_POOL_DIMENSIONS_MANAGE');
    const body: pool.DimensionValueInput = {
      code: String(values.code || '').trim().toUpperCase(),
      name: String(values.name || '').trim(),
      status: values.status ? String(values.status) : null,
    };
    const result = id
      ? await pool.updateDimensionValue(slot, id, body, user)
      : await pool.createDimensionValue(slot, body, user);
    revalidatePath('/admin/pool');
    return result;
  });
}

/** Renames the Global Dimension 1/2 field captions app-wide. Kept under ADMIN:POOL_MANAGE
 *  (not ADMIN:ORG_MANAGE) so it stays alongside the rest of the Dimensions setup tab. */
export async function saveDimensionCaptions(values: FormValues): Promise<ActionResult<Organisation>> {
  return actionResult(async () => {
    const user = await requireAction('ADMIN_POOL_DIMENSIONS_MANAGE');
    const org = await updateOrg({
      global_dimension_1_caption: String(values.global_dimension_1_caption || '').trim() || 'Global Dimension 1 Code',
      global_dimension_2_caption: String(values.global_dimension_2_caption || '').trim() || 'Global Dimension 2 Code',
    }, user);
    revalidatePath('/', 'layout');
    return org;
  });
}
