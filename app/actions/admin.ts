'use server';

import { revalidatePath } from 'next/cache';
import { requirePerm } from '@/lib/session';
import { actionResult } from '@/lib/errors';
import * as admin from '@/lib/admin';
import { updateOrg, updateTheme } from '@/lib/org';
import { toCents } from '@/lib/format';
import type {
  ActionResult, Branch, FormValues, Organisation, Permission, Role, SavingsProduct,
  LoanProduct, Theme, ThemeTokens, UserStatus,
} from '@/lib/types';

/* --------------------------------------------------------------- company */
export async function saveOrganisation(values: FormValues): Promise<ActionResult<Organisation>> {
  return actionResult(async () => {
    const user = await requirePerm('ADMIN:ORG_MANAGE');
    const org = await updateOrg({
      ...values,
      fy_start_month: Number(values.fy_start_month),
      fy_start_day: Number(values.fy_start_day),
    }, user);
    // The society's name, logo and currency appear in the shell on every page.
    revalidatePath('/', 'layout');
    return org;
  });
}

/* ------------------------------------------------------------- appearance */
export async function saveTheme(tokens: ThemeTokens, preset: string): Promise<ActionResult<Theme>> {
  return actionResult(async () => {
    const user = await requirePerm('ADMIN:THEME_MANAGE');
    const theme = await updateTheme({ tokens, preset }, user);
    revalidatePath('/', 'layout');
    return theme;
  });
}

/* ------------------------------------------------------------------ users */
/** Create returns the new id; update just confirms. The caller only needs "it worked". */
export type SaveUserResult = { id: number } | { updated: true };

export async function saveUser(id: number | null, values: FormValues): Promise<ActionResult<SaveUserResult>> {
  return actionResult(async () => {
    const user = await requirePerm('ADMIN:USER_MANAGE');
    const body = {
      username: String(values.username || ''),
      full_name: String(values.full_name || ''),
      email: String(values.email || '') || null,
      phone: String(values.phone || '') || null,
      role_id: Number(values.role_id) || null,
      branch_id: Number(values.branch_id) || null,
      status: (values.status as UserStatus) || null,
      // An empty box means "leave the password alone", not "set it to empty".
      password: String(values.password || '') || null,
    };
    const result = id ? await admin.updateUser(id, body, user) : await admin.createUser(body, user);
    revalidatePath('/admin/users');
    return result;
  });
}

/* ------------------------------------------------------------------ roles */
export async function saveRole(
  id: number | null,
  values: FormValues,
  permissions: Permission[],
): Promise<ActionResult<{ id?: number } | Role>> {
  return actionResult(async () => {
    const user = await requirePerm('ADMIN:ROLE_MANAGE');
    const body = {
      name: String(values.name || ''),
      description: String(values.description || '') || null,
      permissions,
    };
    const result = id ? await admin.updateRole(id, body, user) : await admin.createRole(body, user);
    revalidatePath('/admin/roles');
    return result;
  });
}

/* --------------------------------------------------------------- branches */
export async function saveBranch(id: number | null, values: FormValues): Promise<ActionResult<Branch>> {
  return actionResult(async () => {
    const user = await requirePerm('ADMIN:BRANCH_MANAGE');
    const body = {
      code: String(values.code || ''),
      name: String(values.name || ''),
      town: String(values.town || '') || null,
      phone: String(values.phone || '') || null,
      status: values.status ? String(values.status) : null,
    };
    const branch = id ? await admin.updateBranch(id, body, user) : await admin.createBranch(body, user);
    revalidatePath('/admin/branches');
    return branch;
  });
}

/* -------------------------------------------------------- savings products */
export async function saveSavingsProduct(
  id: number | null,
  values: FormValues,
): Promise<ActionResult<SavingsProduct | { id: number }>> {
  return actionResult(async () => {
    const user = await requirePerm('ADMIN:PRODUCT_MANAGE');
    const body: admin.SavingsProductInput = {
      code: String(values.code || ''),
      name: String(values.name || ''),
      category: String(values.category || ''),
      status: String(values.status || 'ACTIVE'),
      interest_rate: Number(values.interest_rate) || 0,
      min_opening: toCents(values.min_opening_sh),
      min_balance: toCents(values.min_balance_sh),
      withdrawal_fee: toCents(values.withdrawal_fee_sh),
      withdrawal_notice_days: Number(values.withdrawal_notice_days) || 0,
      allow_withdrawal: Number(values.allow_withdrawal) ? 1 : 0,
      is_loanable_base: Number(values.is_loanable_base) ? 1 : 0,
      gl_control_id: Number(values.gl_control_id) || null,
      gl_interest_exp_id: Number(values.gl_interest_exp_id) || null,
      gl_fee_income_id: Number(values.gl_fee_income_id) || null,
    };
    const result = id
      ? await admin.updateSavingsProduct(id, body, user)
      : await admin.createSavingsProduct(body, user);
    revalidatePath('/admin/savings');
    return result;
  });
}

/* ----------------------------------------------------------- loan products */
const LOAN_NUMERIC = [
  'interest_rate', 'max_term_months', 'deposit_multiplier', 'min_membership_months',
  'processing_fee_pct', 'insurance_pct', 'penalty_rate', 'guarantors_required', 'max_dsr_pct',
  'gl_receivable_id', 'gl_interest_income_id', 'gl_fee_income_id', 'gl_penalty_income_id',
] as const;

export async function saveLoanProduct(
  id: number | null,
  values: FormValues,
): Promise<ActionResult<LoanProduct | { id: number }>> {
  return actionResult(async () => {
    const user = await requirePerm('ADMIN:PRODUCT_MANAGE');
    const body: admin.LoanProductInput = {
      code: String(values.code || ''),
      name: String(values.name || ''),
      status: String(values.status || 'ACTIVE'),
      interest_method: String(values.interest_method || 'REDUCING'),
      min_amount: toCents(values.min_amount_sh),
      max_amount: toCents(values.max_amount_sh),
    };
    for (const key of LOAN_NUMERIC) body[key] = Number(values[key]) || 0;

    const result = id
      ? await admin.updateLoanProduct(id, body, user)
      : await admin.createLoanProduct(body, user);
    revalidatePath('/admin/loans');
    return result;
  });
}
