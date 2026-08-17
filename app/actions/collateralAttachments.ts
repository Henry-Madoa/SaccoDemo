'use server';

import { revalidatePath } from 'next/cache';
import { requireAction } from '@/lib/session';
import { actionResult, AppError } from '@/lib/errors';
import { verifyUpload } from '@/lib/cloudinary';
import {
  recordCollateralAttachment, deleteCollateralAttachment, listCollateralAttachments,
} from '@/lib/collateralAttachments';
import type { ActionResult, CollateralApplicationAttachment, UploadedFile } from '@/lib/types';

export async function addCollateralAttachment(
  applicationNo: string,
  file: UploadedFile,
  category: string,
): Promise<ActionResult<CollateralApplicationAttachment>> {
  return actionResult(async () => {
    const user = await requireAction('COLLATERAL_APPLICATIONS_CREATE');
    const asset = await verifyUpload(file.publicId, 'attachment', file.resourceType);
    const saved = await recordCollateralAttachment({
      applicationNo,
      asset,
      filename: file.originalFilename || asset.public_id.split('/').pop() || 'file',
      category: category || null,
    }, user);
    revalidatePath(`/collateral-applications/view/${applicationNo}`);
    return saved;
  });
}

export async function removeCollateralAttachment(
  applicationNo: string,
  attachmentId: number,
): Promise<ActionResult<{ deleted: true }>> {
  return actionResult(async () => {
    await requireAction('COLLATERAL_APPLICATIONS_CREATE');
    const owned = (await listCollateralAttachments(applicationNo)).some((a) => a.id === attachmentId);
    if (!owned) throw new AppError('Attachment not found on this application', 'NOT_FOUND');

    const result = await deleteCollateralAttachment(attachmentId);
    revalidatePath(`/collateral-applications/view/${applicationNo}`);
    return result;
  });
}
