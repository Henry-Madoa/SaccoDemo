'use client';

import { useState } from 'react';
import { useRouter } from 'next/navigation';
import { Card, CardHead } from '@/components/ui/primitives';
import { FilePicker } from '@/components/ui/uploader';
import { useToast } from '@/components/ui/toast';
import { saveMemberBiometric, type BiometricKind } from '@/app/actions/media';
import type { UploadedFile } from '@/lib/types';

type TabKey = 'id' | 'signature' | 'fingerprints';

const TABS: { key: TabKey; label: string }[] = [
  { key: 'id', label: 'ID document' },
  { key: 'signature', label: 'Signature' },
  { key: 'fingerprints', label: 'Fingerprints' },
];

const SLOTS_BY_TAB: Record<TabKey, { kind: BiometricKind; label: string }[]> = {
  id: [
    { kind: 'id_front', label: 'Front ID image' },
    { kind: 'id_back', label: 'Back ID image' },
  ],
  signature: [
    { kind: 'signature', label: 'Signature' },
  ],
  fingerprints: [
    { kind: 'fingerprint1', label: 'Fingerprint 1' },
    { kind: 'fingerprint2', label: 'Fingerprint 2' },
  ],
};

export interface BiometricPanelProps {
  memberId: number;
  images: Record<BiometricKind, string | null>;
  canEdit: boolean;
  mediaEnabled: boolean;
}

/** Front/back ID scan, signature and fingerprint capture — tabbed, one slot each, alongside the member profile. */
export function BiometricPanel({ memberId, images, canEdit, mediaEnabled }: BiometricPanelProps) {
  const [tab, setTab] = useState<TabKey>('id');

  return (
    <Card>
      <CardHead title="Biometric information" sub="ID scans, signature and fingerprint capture" />
      {!mediaEnabled ? (
        <div className="note" style={{ marginBottom: 'var(--sp)' }}>
          Media storage is not configured. Set the <code>CLOUDINARY_*</code> environment variables to enable uploads.
        </div>
      ) : null}
      <div className="tabs">
        {TABS.map((t) => (
          <button key={t.key} type="button" className={t.key === tab ? 'active' : ''}
            onClick={() => setTab(t.key)}>
            {t.label}
          </button>
        ))}
      </div>
      <div className="biometric-grid">
        {SLOTS_BY_TAB[tab].map((slot) => (
          <BiometricSlot
            key={slot.kind}
            memberId={memberId}
            kind={slot.kind}
            label={slot.label}
            src={images[slot.kind]}
            canEdit={canEdit}
            mediaEnabled={mediaEnabled}
          />
        ))}
      </div>
    </Card>
  );
}

function BiometricSlot({ memberId, kind, label, src, canEdit, mediaEnabled }: {
  memberId: number; kind: BiometricKind; label: string; src: string | null;
  canEdit: boolean; mediaEnabled: boolean;
}) {
  const router = useRouter();
  const toast = useToast();
  const [busy, setBusy] = useState(false);

  const apply = async (file: UploadedFile | null) => {
    setBusy(true);
    try {
      const res = await saveMemberBiometric(memberId, kind, file);
      if (!res.ok) { toast(`Could not update ${label.toLowerCase()}`, res.error, 'err'); return; }
      toast(file ? `${label} updated` : `${label} removed`, undefined, 'ok');
      router.refresh();
    } finally {
      setBusy(false);
    }
  };

  return (
    <div className="biometric-slot">
      <div className="biometric-thumb">
        {src
          ? <img src={src} alt={label} />
          : <div className="biometric-placeholder" aria-hidden="true">No image</div>}
      </div>
      <div className="biometric-info">
        <div className="biometric-label">{label}</div>
        {canEdit && mediaEnabled ? (
          <div className="photo-actions">
            <FilePicker kind={kind} accept="image/*" label={`Upload ${label.toLowerCase()}`}
              disabled={busy} onUploaded={apply} />
            {src ? (
              <button type="button" className="btn ghost sm" disabled={busy} onClick={() => apply(null)}>
                Remove
              </button>
            ) : null}
          </div>
        ) : null}
      </div>
    </div>
  );
}
