import { one, all, run } from './db.ts';
import { AppError } from './errors.ts';
import { deleteAttachment } from './attachments.ts';
import { destroyAsset, signedAttachmentUrl } from './cloudinary.ts';
import type { Actor, Attachment, MemberEditAttachment, CloudinaryAsset } from './types.ts';

/** Links are re-signed on every read — see signedAttachmentUrl() for why the stored url is not served directly. */
export async function listEditAttachments(editNo: string): Promise<MemberEditAttachment[]> {
  const rows = await all<MemberEditAttachment>(
    'SELECT * FROM member_edit_attachment WHERE edit_no = ? ORDER BY id DESC',
    editNo,
  );
  return rows.map((r) => ({ ...r, url: signedAttachmentUrl(r.public_id, r.resource_type, r.format) || r.url }));
}

export interface RecordEditAttachmentInput {
  editNo: string;
  asset: CloudinaryAsset;
  filename: string;
  category?: string | null;
}

/**
 * Index an asset that has already been verified against Cloudinary.
 * `asset` must come from verifyUpload() — never straight from the browser.
 */
export async function recordEditAttachment(
  { editNo, asset, filename, category }: RecordEditAttachmentInput,
  user: Actor,
): Promise<MemberEditAttachment> {
  if (await one('SELECT 1 FROM member_edit_attachment WHERE public_id = ?', asset.public_id)) {
    throw new AppError('That file has already been attached', 'DUPLICATE_ASSET');
  }
  const info = await run(
    `INSERT INTO member_edit_attachment (edit_no, public_id, url, filename, resource_type,
       format, bytes, category, uploaded_at, uploaded_by)
     VALUES (?,?,?,?,?,?,?,?,?,?)`,
    editNo, asset.public_id, asset.url, filename, asset.resource_type,
    asset.format, asset.bytes, category || null, new Date().toISOString(), user.username,
  );
  return (await one<MemberEditAttachment>(
    'SELECT * FROM member_edit_attachment WHERE id = ?', Number(info.lastInsertRowid),
  ))!;
}

/**
 * Remove the index row and then the asset.
 * The row goes first: an orphaned Cloudinary file is recoverable, a row
 * pointing at a deleted asset is a broken link on the request's file.
 */
export async function deleteEditAttachment(id: number): Promise<{ deleted: true }> {
  const row = await one<MemberEditAttachment>('SELECT * FROM member_edit_attachment WHERE id = ?', id);
  if (!row) throw new AppError('Attachment not found', 'NOT_FOUND');

  await run('DELETE FROM member_edit_attachment WHERE id = ?', id);
  await destroyAsset(row.public_id, row.resource_type);
  return { deleted: true };
}

/**
 * Snapshots the member's current KYC documents into the fresh edit request — same
 * rationale as the flat fields: references the same Cloudinary assets (no re-upload),
 * just indexed against the edit request until it is processed.
 */
export async function cloneMemberAttachmentsToEdit(memberId: number, editNo: string): Promise<void> {
  const live = await all<Attachment>("SELECT * FROM attachment WHERE entity = 'member' AND entity_id = ?", memberId);
  for (const a of live) {
    await run(
      `INSERT INTO member_edit_attachment (edit_no, public_id, url, filename, resource_type,
         format, bytes, category, uploaded_at, uploaded_by)
       VALUES (?,?,?,?,?,?,?,?,?,?)`,
      editNo, a.public_id, a.url, a.filename, a.resource_type, a.format, a.bytes, a.category,
      a.uploaded_at, a.uploaded_by,
    );
  }
}

/**
 * Reconciles the live member's attachments against what was staged on the edit
 * request — added documents land on the member, dropped ones are removed and their
 * Cloudinary asset destroyed. Unchanged files (same public_id on both sides) are
 * left alone rather than destroyed and recreated.
 */
export async function applyEditAttachments(editNo: string, memberId: number, user: Actor): Promise<void> {
  // Raw rows, not listEditAttachments()'s re-signed ones — a signed (expiring)
  // url must never be the one persisted onto the live member's attachment row.
  const staged = await all<MemberEditAttachment>('SELECT * FROM member_edit_attachment WHERE edit_no = ?', editNo);
  const live = await all<Attachment>("SELECT * FROM attachment WHERE entity = 'member' AND entity_id = ?", memberId);

  const stagedIds = new Set(staged.map((s) => s.public_id));
  const liveIds = new Set(live.map((l) => l.public_id));

  for (const l of live) {
    if (!stagedIds.has(l.public_id)) await deleteAttachment(l.id, user);
  }
  for (const s of staged) {
    if (!liveIds.has(s.public_id)) {
      await run(
        `INSERT INTO attachment (entity, entity_id, public_id, url, filename, resource_type,
           format, bytes, category, uploaded_at, uploaded_by)
         VALUES ('member',?,?,?,?,?,?,?,?,?,?)`,
        memberId, s.public_id, s.url, s.filename, s.resource_type, s.format, s.bytes, s.category,
        s.uploaded_at, s.uploaded_by,
      );
    }
  }
}
