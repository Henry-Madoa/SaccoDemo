'use client';

import { useState } from 'react';
import { useRouter } from 'next/navigation';
import { useToast } from '@/components/ui/toast';
import { decideMyTask } from '@/app/actions/workflows';

/** Inline approve/reject for a task assigned to me — no modal, just a comment box. */
export function TaskActions({ taskId }: { taskId: number }) {
  const router = useRouter();
  const toast = useToast();
  const [mode, setMode] = useState<'approve' | 'reject' | null>(null);
  const [comment, setComment] = useState('');
  const [busy, setBusy] = useState(false);

  const decide = async (approve: boolean) => {
    setBusy(true);
    try {
      const res = await decideMyTask(taskId, approve, comment);
      if (!res.ok) { toast(approve ? 'Could not approve' : 'Could not reject', res.error, 'err'); return; }
      toast(approve ? 'Approved' : 'Rejected', undefined, 'ok');
      setMode(null);
      setComment('');
      router.refresh();
    } finally {
      setBusy(false);
    }
  };

  if (!mode) {
    return (
      <div className="inline" style={{ justifyContent: 'flex-end' }}>
        <button type="button" className="btn sm ghost" onClick={() => setMode('reject')}>Reject</button>
        <button type="button" className="btn sm" onClick={() => setMode('approve')}>Approve</button>
      </div>
    );
  }

  return (
    <div className="inline" style={{ justifyContent: 'flex-end', flexWrap: 'wrap' }}>
      <input
        type="text"
        placeholder={mode === 'approve' ? 'Comment (optional)' : 'Reason (optional)'}
        value={comment}
        onChange={(e) => setComment(e.target.value)}
        style={{ width: 160 }}
      />
      <button type="button" className="btn sm ghost" onClick={() => setMode(null)} disabled={busy}>Cancel</button>
      <button
        type="button"
        className={mode === 'approve' ? 'btn sm' : 'btn sm danger'}
        onClick={() => decide(mode === 'approve')}
        disabled={busy}
      >
        {busy ? 'Working…' : mode === 'approve' ? 'Confirm approve' : 'Confirm reject'}
      </button>
    </div>
  );
}
