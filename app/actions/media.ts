'use server';

import { revalidatePath } from 'next/cache';
import { requireAction } from '@/lib/session';
import { actionResult, AppError } from '@/lib/errors';
import { signUpload, verifyUpload, destroyAsset, type UploadKind } from '@/lib/cloudinary';
import { updateOrg, getOrg } from '@/lib/org';
import { updateMember, getMember } from '@/lib/members';
import { updateMemberApplication, getMemberApplication } from '@/lib/memberApplications';
import { updateMemberEditRequest, getMemberEditRequest } from '@/lib/memberEdits';
import {
  recordAttachment, deleteAttachment, listAttachments,
} from '@/lib/attachments';
import type { ActionKey } from '@/lib/permissions';
import type {
  ActionResult, Attachment, AttachmentEntity, Organisation, UploadSignature, UploadedFile,
} from '@/lib/types';

/** The action that governs writing media onto each kind of record. */
const WRITE_ACTION: Record<UploadKind, ActionKey> = {
  logo: 'ADMIN_ORG_MANAGE',
  photo: 'MEMBERS_UPDATE',
  attachment: 'MEMBERS_UPDATE',
  id_front: 'MEMBERS_UPDATE',
  id_back: 'MEMBERS_UPDATE',
  signature: 'MEMBERS_UPDATE',
  fingerprint1: 'MEMBERS_UPDATE',
  fingerprint2: 'MEMBERS_UPDATE',
};

/**
 * Issue one-shot upload credentials.
 *
 * Permission is checked *here*, before the browser is allowed to talk to
 * Cloudinary at all — an unsigned request cannot upload, so this is the gate.
 */
export async function requestUploadSignature(
  kind: UploadKind,
  entity?: AttachmentEntity,
): Promise<ActionResult<UploadSignature>> {
  return actionResult(async () => {
    // Loan documents are captured by whoever can originate the loan.
    const key = kind === 'attachment' && entity === 'loan' ? 'LOAN_CREATE' : WRITE_ACTION[kind];
    await requireAction(key);
    return signUpload(kind);
  });
}

/* --------------------------------------------------------------- org logo */

export async function saveOrgLogo(file: UploadedFile | null): Promise<ActionResult<Organisation>> {
  return actionResult(async () => {
    const user = await requireAction('ADMIN_ORG_MANAGE');
    const previous = (await getOrg())?.logo ?? null;

    let logo: string | null = null;
    if (file) {
      const asset = await verifyUpload(file.publicId, 'logo', file.resourceType);
      logo = asset.public_id;
    }

    const org = await updateOrg({ logo }, user);

    // Drop the superseded asset. Legacy data-URL logos have no asset to remove.
    if (previous && previous !== logo && !previous.startsWith('data:')) {
      await destroyAsset(previous);
    }
    revalidatePath('/', 'layout');
    return org;
  });
}

/* ----------------------------------------------------------- member photo */

export async function saveMemberPhoto(
  memberId: number,
  file: UploadedFile | null,
): Promise<ActionResult<{ photo: string | null }>> {
  return actionResult(async () => {
    const user = await requireAction('MEMBERS_UPDATE');
    const previous = (await getMember(memberId))?.photo ?? null;

    let photo: string | null = null;
    if (file) {
      const asset = await verifyUpload(file.publicId, 'photo', file.resourceType);
      photo = asset.public_id;
    }

    await updateMember(memberId, { photo }, user);
    if (previous && previous !== photo && !previous.startsWith('data:')) {
      await destroyAsset(previous);
    }
    revalidatePath(`/members/${memberId}`);
    revalidatePath('/members');
    return { photo };
  });
}

/* ------------------------------------------------------- member biometrics */

export type BiometricKind = 'id_front' | 'id_back' | 'signature' | 'fingerprint1' | 'fingerprint2';

const BIOMETRIC_FIELD: Record<BiometricKind,
  'front_id_image' | 'back_id_image' | 'signature_image' | 'fingerprint1_image' | 'fingerprint2_image'> = {
  id_front: 'front_id_image',
  id_back: 'back_id_image',
  signature: 'signature_image',
  fingerprint1: 'fingerprint1_image',
  fingerprint2: 'fingerprint2_image',
};

/** Front/back ID scan, signature and fingerprint capture — one image each, stored like the member photo. */
export async function saveMemberBiometric(
  memberId: number,
  kind: BiometricKind,
  file: UploadedFile | null,
): Promise<ActionResult<Record<string, string | null>>> {
  return actionResult(async () => {
    const user = await requireAction('MEMBERS_UPDATE');
    const field = BIOMETRIC_FIELD[kind];
    const previous = (await getMember(memberId))?.[field] ?? null;

    let value: string | null = null;
    if (file) {
      const asset = await verifyUpload(file.publicId, kind, file.resourceType);
      value = asset.public_id;
    }

    await updateMember(memberId, { [field]: value }, user);
    if (previous && previous !== value && !previous.startsWith('data:')) {
      await destroyAsset(previous);
    }
    revalidatePath(`/members/${memberId}`);
    return { [field]: value };
  });
}

/** Same slots, captured while the applicant is still a staged application. */
export async function saveMemberApplicationBiometric(
  applicationNo: string,
  kind: BiometricKind,
  file: UploadedFile | null,
): Promise<ActionResult<Record<string, string | null>>> {
  return actionResult(async () => {
    const user = await requireAction('MEMBER_APPLICATIONS_UPDATE');
    const field = BIOMETRIC_FIELD[kind];
    const previous = (await getMemberApplication(applicationNo))?.[field] ?? null;

    let value: string | null = null;
    if (file) {
      const asset = await verifyUpload(file.publicId, kind, file.resourceType);
      value = asset.public_id;
    }

    await updateMemberApplication(applicationNo, { [field]: value }, user);
    if (previous && previous !== value && !previous.startsWith('data:')) {
      await destroyAsset(previous);
    }
    revalidatePath(`/member-applications/view/${applicationNo}`);
    return { [field]: value };
  });
}

/** Same slots, captured while a member's changes are still a staged edit request. */
export async function saveMemberEditPhoto(
  editNo: string,
  file: UploadedFile | null,
): Promise<ActionResult<{ photo: string | null }>> {
  return actionResult(async () => {
    const user = await requireAction('MEMBER_EDITS_UPDATE');
    const previous = (await getMemberEditRequest(editNo))?.photo ?? null;

    let photo: string | null = null;
    if (file) {
      const asset = await verifyUpload(file.publicId, 'photo', file.resourceType);
      photo = asset.public_id;
    }

    await updateMemberEditRequest(editNo, { photo }, user);
    if (previous && previous !== photo && !previous.startsWith('data:')) {
      await destroyAsset(previous);
    }
    revalidatePath(`/member-edits/view/${editNo}`);
    return { photo };
  });
}

export async function saveMemberEditBiometric(
  editNo: string,
  kind: BiometricKind,
  file: UploadedFile | null,
): Promise<ActionResult<Record<string, string | null>>> {
  return actionResult(async () => {
    const user = await requireAction('MEMBER_EDITS_UPDATE');
    const field = BIOMETRIC_FIELD[kind];
    const previous = (await getMemberEditRequest(editNo))?.[field] ?? null;

    let value: string | null = null;
    if (file) {
      const asset = await verifyUpload(file.publicId, kind, file.resourceType);
      value = asset.public_id;
    }

    await updateMemberEditRequest(editNo, { [field]: value }, user);
    if (previous && previous !== value && !previous.startsWith('data:')) {
      await destroyAsset(previous);
    }
    revalidatePath(`/member-edits/view/${editNo}`);
    return { [field]: value };
  });
}

/* ------------------------------------------------------------ attachments */

function attachmentAction(entity: AttachmentEntity): ActionKey {
  return entity === 'loan' ? 'LOAN_CREATE' : 'MEMBERS_UPDATE';
}

export async function addAttachment(
  entity: AttachmentEntity,
  entityId: number,
  file: UploadedFile,
  category: string,
): Promise<ActionResult<Attachment>> {
  return actionResult(async () => {
    const user = await requireAction(attachmentAction(entity));
    const asset = await verifyUpload(file.publicId, 'attachment', file.resourceType);
    const saved = await recordAttachment({
      entity,
      entityId,
      asset,
      filename: file.originalFilename || asset.public_id.split('/').pop() || 'file',
      category: category || null,
    }, user);
    revalidatePath(`/${entity === 'loan' ? 'loans' : 'members'}/${entityId}`);
    return saved;
  });
}

export async function removeAttachment(
  entity: AttachmentEntity,
  entityId: number,
  attachmentId: number,
): Promise<ActionResult<{ deleted: true }>> {
  return actionResult(async () => {
    const user = await requireAction(attachmentAction(entity));
    // Confirm the attachment really belongs to the record named in the URL,
    // so an id from another member's file cannot be deleted through this page.
    const owned = (await listAttachments(entity, entityId)).some((a) => a.id === attachmentId);
    if (!owned) throw new AppError('Attachment not found on this record', 'NOT_FOUND');

    const result = await deleteAttachment(attachmentId, user);
    revalidatePath(`/${entity === 'loan' ? 'loans' : 'members'}/${entityId}`);
    return result;
  });
}
