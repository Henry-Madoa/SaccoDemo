'use client';

import { useMemo, useState } from 'react';
import { FormModal } from '@/components/ui/form-modal';
import { Field } from '@/components/ui/field';
import { useFormat } from '@/components/ui/format-provider';
import { createJournal, type JournalLineDraft } from '@/app/actions/gl';
import { today, toCents } from '@/lib/format';
import type { GlAccount } from '@/lib/types';

const emptyLine = (): JournalLineDraft => ({ account: '', narration: '', debit: '', credit: '' });

export function NewJournalButton({ accounts }: { accounts: GlAccount[] }) {
  const [open, setOpen] = useState(false);
  return (
    <>
      <button type="button" className="btn" onClick={() => setOpen(true)}>New journal</button>
      {open ? <JournalForm accounts={accounts} onClose={() => setOpen(false)} /> : null}
    </>
  );
}

function JournalForm({ accounts, onClose }: { accounts: GlAccount[]; onClose: () => void }) {
  const { cur } = useFormat();
  const [lines, setLines] = useState<JournalLineDraft[]>([emptyLine(), emptyLine()]);

  const totals = useMemo(() => {
    const debit = lines.reduce((a, l) => a + toCents(l.debit), 0);
    const credit = lines.reduce((a, l) => a + toCents(l.credit), 0);
    return { debit, credit, balanced: debit === credit && debit > 0 };
  }, [lines]);

  const update = (i: number, patch: Partial<JournalLineDraft>) =>
    setLines((cur) => cur.map((l, k) => (k === i ? { ...l, ...patch } : l)));

  const remove = (i: number) =>
    setLines((cur) => (cur.length > 2 ? cur.filter((_, k) => k !== i) : cur));

  return (
    <FormModal
      wide
      title="New manual journal"
      onClose={onClose}
      onSubmit={(values) => createJournal(values, lines.filter((l) => l.account && (l.debit || l.credit)))}
      submitLabel="Post journal"
      successTitle="Journal posted"
      successDetail={(j) => j.journal_no}
    >
      <div className="grid g2">
        <Field name="valueDate" label="Value date" type="date" defaultValue={today()} required />
        <Field name="description" label="Description" required />
      </div>

      <table style={{ marginTop: 'calc(var(--sp)*1.5)' }}>
        <thead>
          <tr>
            <th style={{ width: '38%' }}>Account</th>
            <th>Narration</th>
            <th className="num" style={{ width: 130 }}>Debit</th>
            <th className="num" style={{ width: 130 }}>Credit</th>
            <th style={{ width: 40 }} />
          </tr>
        </thead>
        <tbody>
          {lines.map((line, i) => (
            <tr key={i}>
              <td>
                <select value={line.account} aria-label="Account"
                  onChange={(e) => update(i, { account: e.target.value })}>
                  <option value="">Select account…</option>
                  {accounts.map((a) => (
                    <option key={a.code} value={a.code}>{a.code} — {a.name}</option>
                  ))}
                </select>
              </td>
              <td>
                <input type="text" placeholder="Narration" value={line.narration} aria-label="Narration"
                  onChange={(e) => update(i, { narration: e.target.value })} />
              </td>
              <td>
                <input type="number" step="0.01" min="0" className="num" value={line.debit} aria-label="Debit"
                  onChange={(e) => update(i, { debit: e.target.value })} />
              </td>
              <td>
                <input type="number" step="0.01" min="0" className="num" value={line.credit} aria-label="Credit"
                  onChange={(e) => update(i, { credit: e.target.value })} />
              </td>
              <td>
                <button type="button" className="btn sm ghost" onClick={() => remove(i)}
                  disabled={lines.length <= 2} aria-label="Remove line">×</button>
              </td>
            </tr>
          ))}
        </tbody>
      </table>

      <div className="inline" style={{ marginTop: 10 }}>
        <button type="button" className="btn ghost sm" onClick={() => setLines((c) => [...c, emptyLine()])}>
          Add line
        </button>
        <div className="spacer" style={{ flex: 1 }} />
        <div style={{ fontSize: '12.5px', color: 'var(--text-muted)' }}>
          Debits <b>{cur(totals.debit)}</b> · Credits <b>{cur(totals.credit)}</b> —{' '}
          <span className={totals.balanced ? 'pos' : 'neg'}>
            {totals.balanced ? 'in balance' : 'out of balance'}
          </span>
        </div>
      </div>
    </FormModal>
  );
}
