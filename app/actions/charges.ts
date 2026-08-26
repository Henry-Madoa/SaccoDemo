'use server';

import { revalidatePath } from 'next/cache';
import { requireAction } from '@/lib/session';
import { actionResult } from '@/lib/errors';
import * as chargesLib from '@/lib/charges';
import type { TransactionChargeSetupDraft, TransactionRecoveryDraft } from '@/lib/charges';
import type {
  ActionResult, CalculatedCharge, Charge, ChargeTransactionType, FormValues, TransactionCharge,
} from '@/lib/types';

export async function createCharge(values: FormValues): Promise<ActionResult<{ id: number }>> {
  return actionResult(async () => {
    const user = await requireAction('ADMIN_CHARGES_MASTER_MANAGE');
    const created = await chargesLib.createCharge(String(values.code || ''), String(values.description || ''), user);
    revalidatePath('/admin/charges');
    return created;
  });
}

export async function updateCharge(id: number, values: FormValues): Promise<ActionResult<Charge>> {
  return actionResult(async () => {
    const user = await requireAction('ADMIN_CHARGES_MASTER_MANAGE');
    const updated = await chargesLib.updateCharge(
      id, String(values.description || ''), String(values.status || 'ACTIVE') as 'ACTIVE' | 'INACTIVE', user,
    );
    revalidatePath('/admin/charges');
    return updated;
  });
}

export async function saveTransactionCharge(
  id: number | null,
  values: FormValues,
  components: TransactionChargeSetupDraft[],
  recoveries: TransactionRecoveryDraft[] = [],
): Promise<ActionResult<{ id: number }>> {
  return actionResult(async () => {
    const user = await requireAction('ADMIN_CHARGES_TRANSACTION_MANAGE');
    const status = String(values.status || 'ACTIVE') as 'ACTIVE' | 'INACTIVE';
    const result = id
      ? await chargesLib.updateTransactionCharge(
        id, {
          description: String(values.description || ''),
          transaction_type: values.transaction_type as ChargeTransactionType,
          status,
        }, components, user, recoveries,
      )
      : await chargesLib.createTransactionCharge({
        code: String(values.code || ''),
        description: String(values.description || ''),
        transaction_type: values.transaction_type as ChargeTransactionType,
        status,
      }, components, user, recoveries);
    revalidatePath('/admin/charges');
    return result;
  });
}

/** The Charge Code picklist for Account Activation's request form — every enabled Transaction
 *  Charge configured for 'General' (there can be more than one; the request picks which
 *  applies rather than the system always auto-resolving a single one). Account Activation has
 *  no dedicated ChargeTransactionType of its own, so its reactivation fee reuses 'General'. */
export async function listAccountActivationChargeCodes(): Promise<ActionResult<TransactionCharge[]>> {
  return actionResult(async () => {
    await requireAction('ACCOUNT_ACTIVATION_CREATE');
    return chargesLib.listTransactionChargesByType('General');
  });
}

/** Same 'General' Charge Code pool as Account Activation's own picker — a Member Activation's
 *  reactivation fee is the same kind of manual, freely-chosen ad-hoc charge. */
export async function listMemberActivationChargeCodes(): Promise<ActionResult<TransactionCharge[]>> {
  return actionResult(async () => {
    await requireAction('MEMBER_ACTIVATIONS_CREATE');
    return chargesLib.listTransactionChargesByType('General');
  });
}

/** Read-only fee preview for one specific Transaction Charge — the same permission that
 *  already gates seeing/creating the triggering document, since a preview reveals nothing an
 *  admin with rights to Charges couldn't already see in the charge's own configuration. */
export async function previewTransactionChargeAmount(
  transactionChargeId: number, baseAmount = 0,
): Promise<ActionResult<CalculatedCharge[]>> {
  return actionResult(async () => {
    await requireAction('ACCOUNT_ACTIVATION_CREATE');
    return chargesLib.previewTransactionChargeById(transactionChargeId, baseAmount);
  });
}

/** Same preview, gated by MEMBER_ACTIVATIONS_CREATE instead — see previewTransactionChargeAmount(). */
export async function previewMemberActivationChargeAmount(
  transactionChargeId: number, baseAmount = 0,
): Promise<ActionResult<CalculatedCharge[]>> {
  return actionResult(async () => {
    await requireAction('MEMBER_ACTIVATIONS_CREATE');
    return chargesLib.previewTransactionChargeById(transactionChargeId, baseAmount);
  });
}

/** Same 'General' Charge Code pool as Member Activation's own picker — a Member Re-admission's
 *  fee is the same kind of manual, freely-chosen ad-hoc charge. */
export async function listMemberReadmissionChargeCodes(): Promise<ActionResult<TransactionCharge[]>> {
  return actionResult(async () => {
    await requireAction('MEMBER_READMISSIONS_CREATE');
    return chargesLib.listTransactionChargesByType('General');
  });
}

/** Same preview, gated by MEMBER_READMISSIONS_CREATE instead — see previewTransactionChargeAmount(). */
export async function previewMemberReadmissionChargeAmount(
  transactionChargeId: number, baseAmount = 0,
): Promise<ActionResult<CalculatedCharge[]>> {
  return actionResult(async () => {
    await requireAction('MEMBER_READMISSIONS_CREATE');
    return chargesLib.previewTransactionChargeById(transactionChargeId, baseAmount);
  });
}

/** The Charge Code picklist for Member Exit — same 'General' reuse as Account Activation's
 *  reactivation fee (AL's own Charge Code field on Member Withdrawal has no type restriction
 *  either — it's a free Transaction Charges lookup). */
export async function listMemberExitChargeCodes(): Promise<ActionResult<TransactionCharge[]>> {
  return actionResult(async () => {
    await requireAction('MEMBER_EXITS_CREATE');
    return chargesLib.listTransactionChargesByType('General');
  });
}
