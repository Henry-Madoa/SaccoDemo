'use client';

import { useRef, useState } from 'react';
import { useRouter } from 'next/navigation';
import { DefinitionList, Pill } from '@/components/ui/primitives';
import { CollapsibleCard } from '@/components/ui/collapsible-card';
import { readForm } from '@/components/ui/field';
import { useToast } from '@/components/ui/toast';
import { Money } from '@/components/ui/money';
import { formatDateTime } from '@/lib/format';
import { saveDividend } from '@/app/actions/dividends';
import { DividendFields, type DividendFormOptions } from './dividend-actions';
import type { DividendDetail } from '@/lib/types';

/**
 * The declaration card, edited in place — no modal, the same pattern as the receipt, voucher,
 * sales and purchase cards. Edit sits on the card's own header; the form takes the card's body
 * and hands it back on Save or Cancel.
 */
export function DividendDeclarationCard({ dividend, options, canEdit }: {
  dividend: DividendDetail; options: DividendFormOptions; canEdit: boolean;
}) {
  const router = useRouter();
  const toast = useToast();
  const formRef = useRef<HTMLFormElement>(null);
  const [editing, setEditing] = useState(false);
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState('');

  const posted = !!Number(dividend.posted);

  const save = async () => {
    const form = formRef.current;
    if (!form || !form.reportValidity()) return;
    setBusy(true);
    setError('');
    try {
      const res = await saveDividend(dividend.no, readForm(form));
      if (!res.ok) { setError(res.error || 'Could not save'); return; }
      toast('Dividend updated', undefined, 'ok');
      setEditing(false);
      router.refresh();
    } finally {
      setBusy(false);
    }
  };

  return (
    <CollapsibleCard
      title="Declaration"
      sub="The period, the book and where it posts"
      actions={canEdit && !editing
        ? <button type="button" className="btn sm ghost" onClick={() => { setError(''); setEditing(true); }}>Edit</button>
        : null}
    >
      {!editing ? (
        <div className="grid g2">
          <DefinitionList items={[
            ['Dividend no.', <span className="mono" key="no">{dividend.no}</span>],
            ['Description', dividend.description],
            ['Posting description', dividend.posting_description || '—'],
            ['Book', dividend.document_type === 'FOSA' ? 'FOSA — interest on savings' : 'BOSA — dividend on deposits'],
            ['Year', String(dividend.dividend_year)],
            ['Period', `${dividend.start_date} → ${dividend.end_date}`],
            ['Posting date', dividend.posting_date],
            ['Status', <Pill status={posted ? 'Posted' : dividend.status} key="st" />],
            dividend.decision_reason ? ['Decision reason', dividend.decision_reason] : null,
          ]} />
          <DefinitionList items={[
            ['Posting type', dividend.posting_type],
            ['Computation', dividend.computation_type],
            ['Recover loans', Number(dividend.recover_loans) ? 'Yes' : 'No'],
            ['Boost to minimum share capital', Number(dividend.boost_to_minimum) ? 'Yes' : 'No'],
            ['Maximum boost', dividend.maximum_boost_amount
              ? <Money cents={dividend.maximum_boost_amount} key="mb" />
              : 'No ceiling'],
            ['Preferential boost allowed', Number(dividend.preferential_boost) ? 'Yes' : 'No'],
            ['Calculated', dividend.calculated_at ? formatDateTime(dividend.calculated_at) : 'Not yet'],
            dividend.journal_no ? ['Journal', <span className="mono" key="j">{dividend.journal_no}</span>] : null,
          ]} />
        </div>
      ) : (
        <>
          <form ref={formRef} onSubmit={(e) => e.preventDefault()}>
            <DividendFields options={options} initial={dividend} />
          </form>
          <div className="inline" style={{ marginTop: 'var(--sp)' }}>
            {error ? <div className="modal-error">{error}</div> : null}
            <button type="button" className="btn ghost sm" onClick={() => setEditing(false)} disabled={busy}>Cancel</button>
            <button type="button" className="btn sm" onClick={save} disabled={busy}>{busy ? 'Saving…' : 'Save'}</button>
          </div>
        </>
      )}
    </CollapsibleCard>
  );
}
