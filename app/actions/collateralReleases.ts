'use server';

import { revalidatePath } from 'next/cache';
import { requireAction, requireUser } from '@/lib/session';
import { actionResult } from '@/lib/errors';
import {
  createCollateralRelease, updateCollateralRelease, deleteCollateralRelease, submitCollateralRelease,
  cancelCollateralReleaseApproval, approveCollateralRelease, rejectCollateralRelease, postCollateralRelease,
} from '@/lib/collateralReleases';
import { findPendingRoutedTask, decideWorkflowTask } from '@/lib/workflow';
import type { ActionResult, CollateralReleaseWithDetails, FormValues } from '@/lib/types';

export async function requestCollateralRelease(values: FormValues): Promise<ActionResult<{ no: string }>> {
  return actionResult(async () => {
    const user = await requireAction('COLLATERAL_RELEASES_CREATE');
    const result = await createCollateralRelease({
      collateralNo: String(values.collateralNo || ''),
      collectionDate: values.collectionDate ? String(values.collectionDate) : null,
      collectedBy: values.collectedBy ? String(values.collectedBy) : null,
      collectedByIdNo: values.collectedByIdNo ? String(values.collectedByIdNo) : null,
      nationality: String(values.nationality || 'LOCAL'),
      domicileCountry: values.domicileCountry ? String(values.domicileCountry) : null,
      comments: values.comments ? String(values.comments) : null,
      remarks: values.remarks ? String(values.remarks) : null,
    }, user);
    revalidatePath('/collateral-releases');
    return result;
  });
}

export async function saveCollateralRelease(
  no: string, values: FormValues,
): Promise<ActionResult<CollateralReleaseWithDetails>> {
  return actionResult(async () => {
    const user = await requireAction('COLLATERAL_RELEASES_CREATE');
    const saved = await updateCollateralRelease(no, {
      collateralNo: values.collateralNo !== undefined ? String(values.collateralNo) : undefined,
      collectionDate: values.collectionDate !== undefined ? String(values.collectionDate) : undefined,
      collectedBy: values.collectedBy !== undefined ? String(values.collectedBy) : undefined,
      collectedByIdNo: values.collectedByIdNo !== undefined ? String(values.collectedByIdNo) : undefined,
      nationality: values.nationality !== undefined ? String(values.nationality) : undefined,
      domicileCountry: values.domicileCountry !== undefined ? String(values.domicileCountry) : undefined,
      comments: values.comments !== undefined ? String(values.comments) : undefined,
      remarks: values.remarks !== undefined ? String(values.remarks) : undefined,
    }, user);
    revalidatePath('/collateral-releases');
    revalidatePath(`/collateral-releases/view/${no}`);
    return saved;
  });
}

export async function deleteCollateralReleaseRequest(no: string): Promise<ActionResult<{ deleted: true }>> {
  return actionResult(async () => {
    const user = await requireAction('COLLATERAL_RELEASES_CREATE');
    await deleteCollateralRelease(no, user);
    revalidatePath('/collateral-releases');
    return { deleted: true };
  });
}

export async function submitCollateralReleaseRequest(no: string): Promise<ActionResult<{ updated: true; autoApproved: boolean }>> {
  return actionResult(async () => {
    const user = await requireAction('COLLATERAL_RELEASES_CREATE');
    const { autoApproved } = await submitCollateralRelease(no, user);
    revalidatePath('/collateral-releases');
    revalidatePath(`/collateral-releases/view/${no}`);
    return { updated: true, autoApproved };
  });
}

export async function cancelCollateralReleaseApprovalRequest(no: string): Promise<ActionResult<{ updated: true }>> {
  return actionResult(async () => {
    const user = await requireAction('COLLATERAL_RELEASES_CREATE');
    await cancelCollateralReleaseApproval(no, user);
    revalidatePath('/collateral-releases');
    revalidatePath(`/collateral-releases/view/${no}`);
    return { updated: true };
  });
}

export async function approveCollateralReleaseRequest(no: string): Promise<ActionResult<{ updated: true }>> {
  return actionResult(async () => {
    const routed = await findPendingRoutedTask('COLLATERAL_RELEASE', no);
    if (routed) {
      const user = await requireUser();
      await decideWorkflowTask(routed.id, true, null, user);
    } else {
      const user = await requireAction('COLLATERAL_RELEASES_APPROVE');
      await approveCollateralRelease(no, user);
    }
    revalidatePath('/collateral-releases');
    revalidatePath(`/collateral-releases/view/${no}`);
    return { updated: true };
  });
}

export async function rejectCollateralReleaseRequest(no: string, reason: string): Promise<ActionResult<{ updated: true }>> {
  return actionResult(async () => {
    const routed = await findPendingRoutedTask('COLLATERAL_RELEASE', no);
    if (routed) {
      const user = await requireUser();
      await decideWorkflowTask(routed.id, false, reason || null, user);
    } else {
      const user = await requireAction('COLLATERAL_RELEASES_APPROVE');
      await rejectCollateralRelease(no, reason, user);
    }
    revalidatePath('/collateral-releases');
    revalidatePath(`/collateral-releases/view/${no}`);
    return { updated: true };
  });
}

export async function postCollateralReleaseRequest(no: string): Promise<ActionResult<{ collateralNo: string }>> {
  return actionResult(async () => {
    const user = await requireAction('COLLATERAL_RELEASES_APPROVE');
    const result = await postCollateralRelease(no, user);
    revalidatePath('/collateral-releases');
    revalidatePath(`/collateral-releases/view/${no}`);
    revalidatePath('/collateral-register');
    return result;
  });
}
