'use server';

import { revalidatePath } from 'next/cache';
import { requireAction } from '@/lib/session';
import { actionResult, AppError } from '@/lib/errors';
import {
  createMemberCharging, updateMemberCharging, deleteMemberCharging, postMemberCharging, getMemberCharging,
  withdrawableAccountsForMember, calculateMemberChargingAmount, getMemberChargingJournal,
  type CalculatedMemberCharge, type MemberChargingInput,
} from '@/lib/memberCharging';
import { listActiveTransactionCharges } from '@/lib/charges';
import type { JournalDetail } from '@/lib/gl';
import type {
  ActionResult, FormValues, MemberChargingWithDimensions, SavingsAccountForDebit, TransactionCharge,
} from '@/lib/types';

const toInput = (values: FormValues): MemberChargingInput => ({
  memberId: Number(values.memberId),
  sourceAccountId: Number(values.sourceAccountId),
  transactionChargeId: Number(values.transactionChargeId),
  description: String(values.description || ''),
  noOfPages: values.noOfPages ? Number(values.noOfPages) : null,
});

export async function requestMemberCharging(values: FormValues): Promise<ActionResult<{ no: string }>> {
  return actionResult(async () => {
    const user = await requireAction('MEMBER_CHARGING_CREATE');
    const result = await createMemberCharging(toInput(values), user);
    revalidatePath('/member-chargings');
    return result;
  });
}

/** Member No. is fixed at creation — the same rule lib/accountActivation.ts's own EditButton
 *  follows for its Account — so the document's existing member is always what gets revalidated
 *  against here, never one resubmitted from the client. */
export async function saveMemberCharging(
  no: string, values: FormValues,
): Promise<ActionResult<MemberChargingWithDimensions>> {
  return actionResult(async () => {
    const user = await requireAction('MEMBER_CHARGING_CREATE');
    const existing = await getMemberCharging(no);
    if (!existing) throw new AppError('Member charging document not found', 'NOT_FOUND');
    const saved = await updateMemberCharging(no, { ...toInput(values), memberId: existing.member_id }, user);
    revalidatePath('/member-chargings');
    revalidatePath(`/member-chargings/view/${no}`);
    return saved;
  });
}

export async function deleteMemberChargingRequest(no: string): Promise<ActionResult<{ deleted: true }>> {
  return actionResult(async () => {
    const user = await requireAction('MEMBER_CHARGING_CREATE');
    await deleteMemberCharging(no, user);
    revalidatePath('/member-chargings');
    return { deleted: true };
  });
}

/** The initiator posts their own document directly — no approval routing, so this is gated
 *  purely by the flat MEMBER_CHARGING_POST permission (granted alongside _CREATE on every role
 *  meant to use this module end to end). */
export async function postMemberChargingRequest(no: string): Promise<ActionResult<{ journalNo: string; amount: number }>> {
  return actionResult(async () => {
    const user = await requireAction('MEMBER_CHARGING_POST');
    const result = await postMemberCharging(no, user);
    revalidatePath('/member-chargings');
    revalidatePath(`/member-chargings/view/${no}`);
    revalidatePath('/savings');
    return result;
  });
}

/** The member's withdrawable deposit accounts — Table 52204206's "Source Account" picklist. */
export async function accountsForMemberCharging(memberId: number): Promise<ActionResult<SavingsAccountForDebit[]>> {
  return actionResult(async () => {
    await requireAction('MEMBER_CHARGING_CREATE');
    return withdrawableAccountsForMember(memberId);
  });
}

/** Every enabled Transaction Charge — the Charge Code picklist. */
export async function memberChargingChargeCodes(): Promise<ActionResult<TransactionCharge[]>> {
  return actionResult(async () => {
    await requireAction('MEMBER_CHARGING_CREATE');
    return listActiveTransactionCharges();
  });
}

/** GetChargesAmount(Charge Code, No Of Pages) — the live fee preview the form re-runs on every
 *  Charge Code / No Of Pages change, mirroring Table 52204206's own recalculation rule. */
export async function previewMemberChargingAmount(
  transactionChargeId: number, noOfPages: number | null,
): Promise<ActionResult<CalculatedMemberCharge | null>> {
  return actionResult(async () => {
    await requireAction('MEMBER_CHARGING_CREATE');
    return calculateMemberChargingAmount(transactionChargeId, noOfPages);
  });
}

/** Table 52204262/263's "Navigate" — the journal a posted document actually created. */
export async function memberChargingJournal(no: string): Promise<ActionResult<JournalDetail | null>> {
  return actionResult(async () => {
    await requireAction('MEMBER_CHARGING_READ');
    return getMemberChargingJournal(no);
  });
}
