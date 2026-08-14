'use server';

import { revalidatePath } from 'next/cache';
import { requireAction } from '@/lib/session';
import { actionResult, AppError } from '@/lib/errors';
import { verifyUpload } from '@/lib/cloudinary';
import {
  recordApplicationAttachment, deleteApplicationAttachment, listApplicationAttachments,
} from '@/lib/applicationAttachments';
import type { ActionResult, MemberApplicationAttachment, UploadedFile } from '@/lib/types';

export async function addApplicationAttachment(
  applicationNo: string,
  file: UploadedFile,
  category: string,
): Promise<ActionResult<MemberApplicationAttachment>> {
  return actionResult(async () => {
    const user = await requireAction('MEMBER_APPLICATIONS_UPDATE');
    const asset = await verifyUpload(file.publicId, 'attachment', file.resourceType);
    const saved = await recordApplicationAttachment({
      applicationNo,
      asset,
      filename: file.originalFilename || asset.public_id.split('/').pop() || 'file',
      category: category || null,
    }, user);
    revalidatePath(`/member-applications/view/${applicationNo}`);
    return saved;
  });
}

export async function removeApplicationAttachment(
  applicationNo: string,
  attachmentId: number,
): Promise<ActionResult<{ deleted: true }>> {
  return actionResult(async () => {
    await requireAction('MEMBER_APPLICATIONS_UPDATE');
    // Confirm the attachment really belongs to the application named in the URL,
    // so an id from another application's file cannot be deleted through this page.
    const owned = (await listApplicationAttachments(applicationNo)).some((a) => a.id === attachmentId);
    if (!owned) throw new AppError('Attachment not found on this application', 'NOT_FOUND');

    const result = await deleteApplicationAttachment(attachmentId);
    revalidatePath(`/member-applications/view/${applicationNo}`);
    return result;
  });
}
