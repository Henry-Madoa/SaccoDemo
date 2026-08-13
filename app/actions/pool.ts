'use server';

import { revalidatePath } from 'next/cache';
import { requirePerm } from '@/lib/session';
import { actionResult } from '@/lib/errors';
import * as pool from '@/lib/pool';
import { updateOrg } from '@/lib/org';
import { toCents } from '@/lib/format';
import type {
  ActionResult, County, DimensionValue, FormValues, MemberCategory, MemberCategoryType,
  Organisation,
} from '@/lib/types';

/* ------------------------------------------------------------------- counties */
export async function saveCounty(
  id: number | null,
  values: FormValues,
  rows: pool.SubCountyDraft[],
): Promise<ActionResult<County | { id: number }>> {
  return actionResult(async () => {
    const user = await requirePerm('ADMIN:POOL_MANAGE');
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
    const user = await requirePerm('ADMIN:POOL_MANAGE');
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

/* ------------------------------------------------------------- global dimensions */
export async function saveDimensionValue(
  slot: pool.DimensionSlot,
  id: number | null,
  values: FormValues,
): Promise<ActionResult<DimensionValue | { id: number }>> {
  return actionResult(async () => {
    const user = await requirePerm('ADMIN:POOL_MANAGE');
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
    const user = await requirePerm('ADMIN:POOL_MANAGE');
    const org = await updateOrg({
      global_dimension_1_caption: String(values.global_dimension_1_caption || '').trim() || 'Global Dimension 1 Code',
      global_dimension_2_caption: String(values.global_dimension_2_caption || '').trim() || 'Global Dimension 2 Code',
    }, user);
    revalidatePath('/', 'layout');
    return org;
  });
}
