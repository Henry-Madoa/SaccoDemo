'use client';

import { useRef, useState, type ReactNode } from 'react';
import { useRouter } from 'next/navigation';
import { Modal } from './modal';
import { readForm } from './field';
import { useToast } from './toast';
import { useResultDialog } from './result-dialog';
import type { ActionResult, FormValues } from '@/lib/types';

export interface FormModalProps<T> {
  title: string;
  wide?: boolean;
  onClose: () => void;
  onSubmit: (values: FormValues) => Promise<ActionResult<T>>;
  submitLabel?: string;
  submitClass?: string;
  successTitle?: string;
  successDetail?: string | ((data: T) => string);
  /** 'popup' for a workflow decision or document posting (deposit, withdrawal, reversal,
   *  journal, disbursement, repayment, approve/reject) — the appealing centered card via
   *  useResultDialog(). Defaults to 'toast', the small corner notification, for everything
   *  else (uploads, admin config saves, profile edits). */
  resultStyle?: 'toast' | 'popup';
  extraFooter?: ReactNode;
  children: ReactNode;
}

/**
 * Modal wrapping a form that submits to a Server Action.
 *
 * A failure keeps the modal open with the message in place, so the user does
 * not lose what they typed — the old modal closed and fired a toast, which
 * meant re-keying an entire loan application.
 */
export function FormModal<T>({
  title, wide, onClose, onSubmit, submitLabel = 'Save', submitClass = 'btn',
  successTitle, successDetail, resultStyle = 'toast', extraFooter, children,
}: FormModalProps<T>) {
  const formRef = useRef<HTMLFormElement>(null);
  const router = useRouter();
  const toast = useToast();
  const showResult = useResultDialog();
  const notify = resultStyle === 'popup' ? showResult : toast;
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState('');

  const submit = async (e?: React.FormEvent) => {
    e?.preventDefault();
    const form = formRef.current;
    if (!form || !form.reportValidity()) return;
    setBusy(true);
    setError('');
    try {
      const res = await onSubmit(readForm(form));
      if (!res?.ok) {
        setError(res?.error || 'Could not complete');
        return;
      }
      if (successTitle) {
        notify(successTitle, typeof successDetail === 'function' ? successDetail(res.data) : successDetail, 'ok');
      }
      onClose();
      router.refresh();
    } finally {
      setBusy(false);
    }
  };

  return (
    <Modal
      title={title}
      wide={wide}
      onClose={onClose}
      footer={
        <>
          {error ? <div className="modal-error">{error}</div> : null}
          <button type="button" className="btn ghost" onClick={onClose} disabled={busy}>Cancel</button>
          {extraFooter}
          <button type="button" className={submitClass} onClick={() => submit()} disabled={busy}>
            {busy ? 'Working…' : submitLabel}
          </button>
        </>
      }
    >
      <form ref={formRef} onSubmit={submit}>{children}</form>
    </Modal>
  );
}
