'use client';

import { useActionState, useEffect, useRef, useState, useTransition } from 'react';
import { useFormStatus } from 'react-dom';
import { useRouter } from 'next/navigation';
import { useToast } from '@/components/ui/toast';
import { deleteConfigPackageAction, importConfigPackageAction, type ImportState } from '@/app/actions/configPackages';

function ImportSubmitButton() {
  const { pending } = useFormStatus();
  return (
    <button type="submit" className="btn sm" disabled={pending}>{pending ? 'Importing…' : 'Import'}</button>
  );
}

/** Export (a plain GET download link) plus a CSV Import form for one package row. Import can't
 *  use FormModal — its readForm() only reads scalar values and silently drops a File — so this
 *  follows the same useActionState + raw <form action> pattern as app/login/login-form.tsx. */
export function ConfigPackageIo({ code }: { code: string }) {
  const [state, formAction] = useActionState<ImportState, FormData>(importConfigPackageAction, {});
  const fileRef = useRef<HTMLInputElement>(null);

  // Clear the picked file once an import completes, successfully or not, so re-choosing the
  // same file for a retry still fires a change (and the form doesn't silently resubmit it).
  useEffect(() => {
    if ((state.result || state.error) && fileRef.current) fileRef.current.value = '';
  }, [state]);

  return (
    <div className="inline" style={{ gap: 8, flexWrap: 'wrap' }}>
      <a className="btn sm ghost" href={`/api/config-packages/${code}/export`}>⬇ Export CSV</a>

      <form action={formAction} className="inline" style={{ gap: 6 }}>
        <input type="hidden" name="code" value={code} />
        <input ref={fileRef} type="file" name="file" accept=".csv,text/csv" aria-label="CSV file to import" required />
        <ImportSubmitButton />
      </form>

      {state.error ? <div className="pill bad">{state.error}</div> : null}
      {state.result ? (
        <div className="tiny">
          {state.result.inserted} inserted · {state.result.updated} updated · {state.result.errors} error(s)
          {state.result.errors ? (
            <ul style={{ margin: '4px 0 0', paddingLeft: 18 }}>
              {state.result.rows.filter((r) => r.status === 'ERROR').slice(0, 20).map((r) => (
                <li key={r.row}>Row {r.row}: {r.message}</li>
              ))}
            </ul>
          ) : null}
        </div>
      ) : null}
    </div>
  );
}

export function DeleteConfigPackageButton({ code }: { code: string }) {
  const router = useRouter();
  const toast = useToast();
  const [busy, startTransition] = useTransition();
  const [confirming, setConfirming] = useState(false);

  const remove = () => startTransition(async () => {
    const res = await deleteConfigPackageAction(code);
    if (!res.ok) { toast('Could not delete package', res.error, 'err'); return; }
    toast('Configuration package deleted', code, 'ok');
    router.refresh();
  });

  if (!confirming) {
    return <button type="button" className="btn sm ghost" onClick={() => setConfirming(true)}>Delete</button>;
  }
  return (
    <span className="inline" style={{ gap: 4 }}>
      <span className="tiny">Delete {code}?</span>
      <button type="button" className="btn sm" disabled={busy} onClick={remove}>{busy ? 'Working…' : 'Confirm'}</button>
      <button type="button" className="btn sm ghost" disabled={busy} onClick={() => setConfirming(false)}>Cancel</button>
    </span>
  );
}
