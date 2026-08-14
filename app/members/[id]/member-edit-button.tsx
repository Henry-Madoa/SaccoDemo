'use client';

import Link from 'next/link';
import { useState } from 'react';
import { useRouter } from 'next/navigation';
import { useToast } from '@/components/ui/toast';
import { requestMemberEdit } from '@/app/actions/memberEdits';
import type { MemberEditRequest } from '@/lib/types';

export interface MemberEditButtonProps {
  memberId: number;
  /** The member's own in-flight (Open/Pending Approval/Approved-but-unprocessed) request, if any. */
  openRequest: MemberEditRequest | null;
}

/** Starts (or links to) the approval-gated edit flow for this member — see /member-edits. */
export function MemberEditButton({ memberId, openRequest }: MemberEditButtonProps) {
  const router = useRouter();
  const toast = useToast();
  const [busy, setBusy] = useState(false);

  if (openRequest) {
    return (
      <Link href={`/member-edits/view/${openRequest.no}`} className="btn ghost">
        Edit request pending — {openRequest.no}
      </Link>
    );
  }

  const request = async () => {
    setBusy(true);
    try {
      const res = await requestMemberEdit(memberId);
      if (!res.ok) { toast('Could not start edit request', res.error, 'err'); return; }
      router.push(`/member-edits/view/${res.data.no}`);
    } finally {
      setBusy(false);
    }
  };

  return (
    <button type="button" className="btn ghost" disabled={busy} onClick={request}>
      {busy ? 'Working…' : 'Request edit'}
    </button>
  );
}
