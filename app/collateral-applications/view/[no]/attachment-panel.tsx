'use client';

import { useState } from 'react';
import { useRouter } from 'next/navigation';
import { Card, CardHead, EmptyState, Pill, TableWrap } from '@/components/ui/primitives';
import { FilePicker } from '@/components/ui/uploader';
import { useToast } from '@/components/ui/toast';
import { addCollateralAttachment, removeCollateralAttachment } from '@/app/actions/collateralAttachments';
import { COLLATERAL_ATTACHMENT_CATEGORIES } from '@/lib/constants';
import { formatBytes, formatDateTime } from '@/lib/format';
import type { CollateralApplicationAttachment, UploadedFile } from '@/lib/types';

export interface CollateralAttachmentPanelProps {
  applicationNo: string;
  attachments: CollateralApplicationAttachment[];
  /** Whether this user may add or remove files. Viewing needs only READ. */
  canManage: boolean;
  mediaEnabled: boolean;
}

/** Replaces the source specification's five BLOB image fields (DEF-23) with photographs and
 *  documents held as ordinary attachments — the same Cloudinary-backed pattern every other
 *  document in this application already uses. */
export function CollateralAttachmentPanel({
  applicationNo, attachments, canManage, mediaEnabled,
}: CollateralAttachmentPanelProps) {
  const router = useRouter();
  const toast = useToast();
  const [category, setCategory] = useState(COLLATERAL_ATTACHMENT_CATEGORIES[0]);
  const [busy, setBusy] = useState(false);

  const attach = async (file: UploadedFile) => {
    setBusy(true);
    try {
      const res = await addCollateralAttachment(applicationNo, file, category);
      if (!res.ok) { toast('Could not attach', res.error, 'err'); return; }
      toast('File attached', res.data.filename, 'ok');
      router.refresh();
    } finally {
      setBusy(false);
    }
  };

  const remove = async (a: CollateralApplicationAttachment) => {
    setBusy(true);
    try {
      const res = await removeCollateralAttachment(applicationNo, a.id);
      if (!res.ok) { toast('Could not remove', res.error, 'err'); return; }
      toast('File removed', a.filename, 'ok');
      router.refresh();
    } finally {
      setBusy(false);
    }
  };

  return (
    <Card>
      <CardHead
        title="Photographs and documents"
        sub={`${attachments.length} file${attachments.length === 1 ? '' : 's'} held against this application`}
      />

      {canManage ? (
        mediaEnabled ? (
          <div className="attach-add">
            <label className="field" style={{ margin: 0 }}>
              <span className="attach-label">Category</span>
              <select value={category} onChange={(e) => setCategory(e.target.value)} disabled={busy}>
                {COLLATERAL_ATTACHMENT_CATEGORIES.map((c) => <option key={c} value={c}>{c}</option>)}
              </select>
            </label>
            <FilePicker
              kind="attachment"
              accept="image/*,.pdf,.doc,.docx,.txt,.csv"
              label="Attach a photo or document"
              disabled={busy}
              onUploaded={attach}
            />
          </div>
        ) : (
          <div className="note" style={{ marginBottom: 'var(--sp)' }}>
            Media storage is not configured. Set the <code>CLOUDINARY_*</code> environment variables to enable uploads.
          </div>
        )
      ) : null}

      {attachments.length ? (
        <TableWrap>
          <thead>
            <tr>
              <th>File</th><th>Category</th><th className="num">Size</th>
              <th>Uploaded</th><th>By</th><th className="num" />
            </tr>
          </thead>
          <tbody>
            {attachments.map((a) => (
              <tr key={a.id}>
                <td>
                  <a href={a.url} target="_blank" rel="noopener noreferrer">{a.filename}</a>
                  {a.format ? <span className="tiny mono"> .{a.format}</span> : null}
                </td>
                <td>{a.category ? <Pill tone="info">{a.category}</Pill> : '—'}</td>
                <td className="num">{formatBytes(a.bytes)}</td>
                <td>{formatDateTime(a.uploaded_at)}</td>
                <td className="muted-cell">{a.uploaded_by}</td>
                <td className="num">
                  {canManage ? (
                    <button type="button" className="btn sm ghost" disabled={busy}
                      onClick={() => remove(a)}>
                      Remove
                    </button>
                  ) : null}
                </td>
              </tr>
            ))}
          </tbody>
        </TableWrap>
      ) : (
        <EmptyState icon="📷" title="No photographs or documents attached"
          sub={canManage ? 'Attach photos of the asset, the title deed / logbook, and any valuation report' : undefined} />
      )}
    </Card>
  );
}
