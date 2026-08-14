import { one, all, run } from './db.ts';
import { AppError } from './errors.ts';
import { destroyAsset, signedAttachmentUrl } from './cloudinary.ts';
import type { Actor, MemberApplicationAttachment, CloudinaryAsset } from './types.ts';

/** Links are re-signed on every read — see signedAttachmentUrl() for why the stored url is not served directly. */
export async function listApplicationAttachments(applicationNo: string): Promise<MemberApplicationAttachment[]> {
  const rows = await all<MemberApplicationAttachment>(
    'SELECT * FROM member_application_attachment WHERE application_no = ? ORDER BY id DESC',
    applicationNo,
  );
  return rows.map((r) => ({ ...r, url: signedAttachmentUrl(r.public_id, r.resource_type, r.format) || r.url }));
}

export interface RecordApplicationAttachmentInput {
  applicationNo: string;
  asset: CloudinaryAsset;
  filename: string;
  category?: string | null;
}

/**
 * Index an asset that has already been verified against Cloudinary.
 * `asset` must come from verifyUpload() — never straight from the browser.
 */
export async function recordApplicationAttachment(
  { applicationNo, asset, filename, category }: RecordApplicationAttachmentInput,
  user: Actor,
): Promise<MemberApplicationAttachment> {
  if (await one('SELECT 1 FROM member_application_attachment WHERE public_id = ?', asset.public_id)) {
    throw new AppError('That file has already been attached', 'DUPLICATE_ASSET');
  }
  const info = await run(
    `INSERT INTO member_application_attachment (application_no, public_id, url, filename, resource_type,
       format, bytes, category, uploaded_at, uploaded_by)
     VALUES (?,?,?,?,?,?,?,?,?,?)`,
    applicationNo, asset.public_id, asset.url, filename, asset.resource_type,
    asset.format, asset.bytes, category || null, new Date().toISOString(), user.username,
  );
  return (await one<MemberApplicationAttachment>(
    'SELECT * FROM member_application_attachment WHERE id = ?', Number(info.lastInsertRowid),
  ))!;
}

/**
 * Remove the index row and then the asset.
 * The row goes first: an orphaned Cloudinary file is recoverable, a row
 * pointing at a deleted asset is a broken link on the application's file.
 */
export async function deleteApplicationAttachment(id: number): Promise<{ deleted: true }> {
  const row = await one<MemberApplicationAttachment>('SELECT * FROM member_application_attachment WHERE id = ?', id);
  if (!row) throw new AppError('Attachment not found', 'NOT_FOUND');

  await run('DELETE FROM member_application_attachment WHERE id = ?', id);
  await destroyAsset(row.public_id, row.resource_type);
  return { deleted: true };
}
