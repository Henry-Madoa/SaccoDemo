'use client';

import { useState } from 'react';
import { useRouter } from 'next/navigation';
import { FilePicker } from '@/components/ui/uploader';
import { useToast } from '@/components/ui/toast';
import { saveMemberPhoto } from '@/app/actions/media';
import { initials } from '@/lib/format';
import type { UploadedFile } from '@/lib/types';

export interface MemberPhotoProps {
  memberId: number;
  name: string;
  /** Delivery URL resolved server-side, or null when there is no photo. */
  photoSrc: string | null;
  canEdit: boolean;
  mediaEnabled: boolean;
}

/** The member 360 avatar, with upload/remove for anyone holding MEMBER:UPDATE. */
export function MemberPhoto({ memberId, name, photoSrc, canEdit, mediaEnabled }: MemberPhotoProps) {
  const router = useRouter();
  const toast = useToast();
  const [busy, setBusy] = useState(false);

  const apply = async (file: UploadedFile | null) => {
    setBusy(true);
    try {
      const res = await saveMemberPhoto(memberId, file);
      if (!res.ok) { toast('Could not update photo', res.error, 'err'); return; }
      toast(file ? 'Photo updated' : 'Photo removed', name, 'ok');
      router.refresh();
    } finally {
      setBusy(false);
    }
  };

  return (
    <div className="member-photo">
      {photoSrc
        ? <img src={photoSrc} alt={name} className="photo" />
        : <div className="avatar" aria-hidden="true">{initials(name)}</div>}

      {canEdit && mediaEnabled ? (
        <div className="photo-actions">
          <FilePicker kind="photo" accept="image/*" label="Upload photo"
            disabled={busy} onUploaded={apply} />
          {photoSrc ? (
            <button type="button" className="btn ghost sm" disabled={busy} onClick={() => apply(null)}>
              Remove photo
            </button>
          ) : null}
        </div>
      ) : null}
    </div>
  );
}
