'use server';

import { revalidatePath } from 'next/cache';
import { requireAction, requireUser } from '@/lib/session';
import { actionResult } from '@/lib/errors';
import {
  createCollateralApplication, updateCollateralApplication, deleteCollateralApplication,
  submitCollateralApplication, cancelCollateralApplicationApproval, approveCollateralApplication,
  rejectCollateralApplication, postCollateralApplication,
} from '@/lib/collateralApplications';
import { findPendingRoutedTask, decideWorkflowTask } from '@/lib/workflow';
import { listActiveCollateralTypes } from '@/lib/collateralTypes';
import type {
  ActionResult, CollateralApplicationWithDetails, CollateralType, FormValues,
} from '@/lib/types';

const num = (v: unknown) => Math.round(Number(String(v ?? '').replace(/,/g, '')) * 100) || 0;

export async function createCollateralApplicationRequest(values: FormValues): Promise<ActionResult<{ no: string }>> {
  return actionResult(async () => {
    const user = await requireAction('COLLATERAL_APPLICATIONS_CREATE');
    const result = await createCollateralApplication({
      memberId: Number(values.memberId),
      category: String(values.category || ''),
      collateralTypeId: Number(values.collateralTypeId),
      collateralValue: num(values.collateralValueSh),
      serialRegNo: values.serialRegNo ? String(values.serialRegNo) : null,
      multiLinking: !!Number(values.multiLinking),
      countyId: values.countyId ? Number(values.countyId) : null,
      lastValuationDate: values.lastValuationDate ? String(values.lastValuationDate) : null,
      jointOwnership: !!Number(values.jointOwnership),
      ownerName: values.ownerName ? String(values.ownerName) : null,
      ownerIdNo: values.ownerIdNo ? String(values.ownerIdNo) : null,
      ownerPhoneNo: values.ownerPhoneNo ? String(values.ownerPhoneNo) : null,
      insuranceExpiryDate: values.insuranceExpiryDate ? String(values.insuranceExpiryDate) : null,
      carTrackDueDate: values.carTrackDueDate ? String(values.carTrackDueDate) : null,
      chequeNo: values.chequeNo ? String(values.chequeNo) : null,
    }, user);
    revalidatePath('/collateral-applications');
    revalidatePath(`/members/${values.memberId}`);
    return result;
  });
}

export async function saveCollateralApplication(
  no: string, values: FormValues,
): Promise<ActionResult<CollateralApplicationWithDetails>> {
  return actionResult(async () => {
    const user = await requireAction('COLLATERAL_APPLICATIONS_CREATE');
    const saved = await updateCollateralApplication(no, {
      category: values.category !== undefined ? String(values.category) : undefined,
      collateralTypeId: values.collateralTypeId !== undefined ? Number(values.collateralTypeId) : undefined,
      collateralValue: values.collateralValueSh !== undefined ? num(values.collateralValueSh) : undefined,
      serialRegNo: values.serialRegNo !== undefined ? String(values.serialRegNo) : undefined,
      multiLinking: values.multiLinking !== undefined ? !!Number(values.multiLinking) : undefined,
      countyId: values.countyId !== undefined ? (values.countyId ? Number(values.countyId) : null) : undefined,
      lastValuationDate: values.lastValuationDate !== undefined ? String(values.lastValuationDate) : undefined,
      jointOwnership: values.jointOwnership !== undefined ? !!Number(values.jointOwnership) : undefined,
      ownerName: values.ownerName !== undefined ? String(values.ownerName) : undefined,
      ownerIdNo: values.ownerIdNo !== undefined ? String(values.ownerIdNo) : undefined,
      ownerPhoneNo: values.ownerPhoneNo !== undefined ? String(values.ownerPhoneNo) : undefined,
      insuranceExpiryDate: values.insuranceExpiryDate !== undefined ? String(values.insuranceExpiryDate) : undefined,
      carTrackDueDate: values.carTrackDueDate !== undefined ? String(values.carTrackDueDate) : undefined,
      chequeNo: values.chequeNo !== undefined ? String(values.chequeNo) : undefined,
    }, user);
    revalidatePath('/collateral-applications');
    revalidatePath(`/collateral-applications/view/${no}`);
    return saved;
  });
}

export async function deleteCollateralApplicationRequest(no: string): Promise<ActionResult<{ deleted: true }>> {
  return actionResult(async () => {
    const user = await requireAction('COLLATERAL_APPLICATIONS_CREATE');
    await deleteCollateralApplication(no, user);
    revalidatePath('/collateral-applications');
    return { deleted: true };
  });
}

export async function submitCollateralApplicationRequest(
  no: string,
): Promise<ActionResult<{ updated: true; autoApproved: boolean }>> {
  return actionResult(async () => {
    const user = await requireAction('COLLATERAL_APPLICATIONS_CREATE');
    const { autoApproved } = await submitCollateralApplication(no, user);
    revalidatePath('/collateral-applications');
    revalidatePath(`/collateral-applications/view/${no}`);
    return { updated: true, autoApproved };
  });
}

export async function cancelCollateralApplicationApprovalRequest(no: string): Promise<ActionResult<{ updated: true }>> {
  return actionResult(async () => {
    const user = await requireAction('COLLATERAL_APPLICATIONS_CREATE');
    await cancelCollateralApplicationApproval(no, user);
    revalidatePath('/collateral-applications');
    revalidatePath(`/collateral-applications/view/${no}`);
    return { updated: true };
  });
}

/** Delegates to whichever approval path actually governs this request: if a workflow routed it
 *  to a specific approver, only that assignee may decide it; otherwise this falls back to the
 *  flat COLLATERAL_APPLICATIONS_APPROVE permission. */
export async function approveCollateralApplicationRequest(no: string): Promise<ActionResult<{ updated: true }>> {
  return actionResult(async () => {
    const routed = await findPendingRoutedTask('COLLATERAL_APPLICATION', no);
    if (routed) {
      const user = await requireUser();
      await decideWorkflowTask(routed.id, true, null, user);
    } else {
      const user = await requireAction('COLLATERAL_APPLICATIONS_APPROVE');
      await approveCollateralApplication(no, user);
    }
    revalidatePath('/collateral-applications');
    revalidatePath(`/collateral-applications/view/${no}`);
    return { updated: true };
  });
}

export async function rejectCollateralApplicationRequest(no: string, reason: string): Promise<ActionResult<{ updated: true }>> {
  return actionResult(async () => {
    const routed = await findPendingRoutedTask('COLLATERAL_APPLICATION', no);
    if (routed) {
      const user = await requireUser();
      await decideWorkflowTask(routed.id, false, reason || null, user);
    } else {
      const user = await requireAction('COLLATERAL_APPLICATIONS_APPROVE');
      await rejectCollateralApplication(no, reason, user);
    }
    revalidatePath('/collateral-applications');
    revalidatePath(`/collateral-applications/view/${no}`);
    return { updated: true };
  });
}

export async function postCollateralApplicationRequest(no: string): Promise<ActionResult<{ registerNo: string }>> {
  return actionResult(async () => {
    const user = await requireAction('COLLATERAL_APPLICATIONS_APPROVE');
    const result = await postCollateralApplication(no, user);
    revalidatePath('/collateral-applications');
    revalidatePath(`/collateral-applications/view/${no}`);
    revalidatePath('/collateral-register');
    return result;
  });
}

export async function eligibleCollateralTypesForCategory(category: string): Promise<ActionResult<CollateralType[]>> {
  return actionResult(async () => {
    await requireAction('COLLATERAL_APPLICATIONS_CREATE');
    return listActiveCollateralTypes(category);
  });
}
