import { one, all, run } from './db.ts';
import { AppError } from './errors.ts';
import { destroyAsset, signedAttachmentUrl } from './cloudinary.ts';
import type { Actor, CollateralApplicationAttachment, CloudinaryAsset } from './types.ts';

/** Links are re-signed on every read — see signedAttachmentUrl() for why the stored url is not served directly. */
export async function listCollateralAttachments(applicationNo: string): Promise<CollateralApplicationAttachment[]> {
  const rows = await all<CollateralApplicationAttachment>(
    'SELECT * FROM collateral_application_attachment WHERE application_no = ? ORDER BY id DESC',
    applicationNo,
  );
  return rows.map((r) => ({ ...r, url: signedAttachmentUrl(r.public_id, r.resource_type, r.format) || r.url }));
}

export interface RecordCollateralAttachmentInput {
  applicationNo: string;
  asset: CloudinaryAsset;
  filename: string;
  category?: string | null;
}

/**
 * Index an asset that has already been verified against Cloudinary.
 * `asset` must come from verifyUpload() — never straight from the browser. Replaces the source
 * specification's five BLOB image fields (DEF-23) with a child table plus object storage, the
 * same shape as member_application_attachment.
 */
export async function recordCollateralAttachment(
  { applicationNo, asset, filename, category }: RecordCollateralAttachmentInput,
  user: Actor,
): Promise<CollateralApplicationAttachment> {
  if (await one('SELECT 1 FROM collateral_application_attachment WHERE public_id = ?', asset.public_id)) {
    throw new AppError('That file has already been attached', 'DUPLICATE_ASSET');
  }
  const info = await run(
    `INSERT INTO collateral_application_attachment (application_no, public_id, url, filename, resource_type,
       format, bytes, category, uploaded_at, uploaded_by)
     VALUES (?,?,?,?,?,?,?,?,?,?)`,
    applicationNo, asset.public_id, asset.url, filename, asset.resource_type,
    asset.format, asset.bytes, category || null, new Date().toISOString(), user.username,
  );
  return (await one<CollateralApplicationAttachment>(
    'SELECT * FROM collateral_application_attachment WHERE id = ?', Number(info.lastInsertRowid),
  ))!;
}

/**
 * Remove the index row and then the asset.
 * The row goes first: an orphaned Cloudinary file is recoverable, a row pointing at a deleted
 * asset is a broken link on the application's file.
 */
export async function deleteCollateralAttachment(id: number): Promise<{ deleted: true }> {
  const row = await one<CollateralApplicationAttachment>('SELECT * FROM collateral_application_attachment WHERE id = ?', id);
  if (!row) throw new AppError('Attachment not found', 'NOT_FOUND');

  await run('DELETE FROM collateral_application_attachment WHERE id = ?', id);
  await destroyAsset(row.public_id, row.resource_type);
  return { deleted: true };
}
