'use client';

import { useState } from 'react';
import { useToast } from '@/components/ui/toast';
import { saveActiveProfile } from '@/app/actions/mySettings';
import type { Profile } from '@/lib/types';

/** My Settings → Role Centre. Picks which assigned Profile's Role Centre the user lands on and
 *  which navigation groups their sidebar shows. */
export function ProfileSwitcher({ profiles, activeId }: { profiles: Profile[]; activeId: number }) {
  const toast = useToast();
  const [choice, setChoice] = useState(String(activeId));
  const [busy, setBusy] = useState(false);

  if (profiles.length <= 1) {
    return (
      <p className="hint" style={{ marginTop: 8 }}>
        You have one Role Centre. An administrator can assign you more from Admin Centre → Users,
        and you can then switch between them here.
      </p>
    );
  }

  const save = async () => {
    setBusy(true);
    const res = await saveActiveProfile(Number(choice) || null);
    if (!res.ok) { toast('Could not switch', res.error, 'err'); setBusy(false); return; }
    // A full navigation to the dashboard so the whole shell — sidebar groups included — rebuilds
    // for the new Role Centre; a soft router.refresh() does not always re-run a cached layout.
    window.location.assign('/dashboard');
  };

  const current = profiles.find((p) => String(p.id) === choice);

  return (
    <div className="inline" style={{ marginTop: 'calc(var(--sp)*1.5)', alignItems: 'end', flexWrap: 'wrap' }}>
      <div className="field" style={{ marginBottom: 0, minWidth: 280 }}>
        <label htmlFor="f_activeProfile">Active Role Centre</label>
        <select id="f_activeProfile" value={choice} disabled={busy}
          onChange={(e) => setChoice(e.target.value)}>
          {profiles.map((p) => (
            <option key={p.id} value={String(p.id)}>{p.icon ? `${p.icon}  ` : ''}{p.name}</option>
          ))}
        </select>
        {current?.description ? <div className="hint">{current.description}</div> : null}
      </div>
      <button type="button" className="btn" disabled={busy || choice === String(activeId)} onClick={save}>
        {busy ? 'Switching…' : 'Switch Role Centre'}
      </button>
    </div>
  );
}
