'use server';

import { revalidatePath } from 'next/cache';
import { requireAction } from '@/lib/session';
import { actionResult, AppError } from '@/lib/errors';
import { verifyUpload } from '@/lib/cloudinary';
import {
  recordEditAttachment, deleteEditAttachment, listEditAttachments,
} from '@/lib/editAttachments';
import type { ActionResult, MemberEditAttachment, UploadedFile } from '@/lib/types';

export async function addEditAttachment(
  editNo: string,
  file: UploadedFile,
  category: string,
): Promise<ActionResult<MemberEditAttachment>> {
  return actionResult(async () => {
    const user = await requireAction('MEMBER_EDITS_UPDATE');
    const asset = await verifyUpload(file.publicId, 'attachment', file.resourceType);
    const saved = await recordEditAttachment({
      editNo,
      asset,
      filename: file.originalFilename || asset.public_id.split('/').pop() || 'file',
      category: category || null,
    }, user);
    revalidatePath(`/member-edits/view/${editNo}`);
    return saved;
  });
}

export async function removeEditAttachment(
  editNo: string,
  attachmentId: number,
): Promise<ActionResult<{ deleted: true }>> {
  return actionResult(async () => {
    await requireAction('MEMBER_EDITS_UPDATE');
    // Confirm the attachment really belongs to the request named in the URL,
    // so an id from another request's file cannot be deleted through this page.
    const owned = (await listEditAttachments(editNo)).some((a) => a.id === attachmentId);
    if (!owned) throw new AppError('Attachment not found on this request', 'NOT_FOUND');

    const result = await deleteEditAttachment(attachmentId);
    revalidatePath(`/member-edits/view/${editNo}`);
    return result;
  });
}
