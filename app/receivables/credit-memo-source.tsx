'use client';

import { useEffect, useState } from 'react';
import { SearchableSelect } from '@/components/ui/searchable-select';
import { useFormat } from '@/components/ui/format-provider';
import {
  listPostedInvoicesForCreditRequest, getInvoiceForCreditMemoRequest, type SalesLineDraft,
} from '@/app/actions/receivables';
import type { CreditMemoSource, PostedInvoiceOption } from '@/lib/salesDocuments';

/**
 * "Copy from posted invoice" on a sales credit memo — Business Central's Copy Document /
 * Create Corrective Credit Memo.
 *
 * Picking an invoice fills the memo in: the customer it was billed to, the payment terms and
 * reference it carried, and every line at the same quantity, price and discount. Quantities come
 * across positive — a credit memo is negative by virtue of its document type, not by carrying
 * negative lines — and the invoice number is remembered as the Applies-to Doc. No., so posting
 * settles that invoice instead of leaving an open invoice beside an open credit note.
 *
 * Nothing is forced: the copied lines are ordinary drafts, so a partial credit is just a matter
 * of deleting or editing lines before saving.
 */
export function CreditMemoSourcePicker({ customerId, onCopy }: {
  /** Narrows the list once the memo already has a customer. */
  customerId: string;
  onCopy: (source: CreditMemoSource) => void;
}) {
  const { cur, fdate } = useFormat();
  const [invoices, setInvoices] = useState<PostedInvoiceOption[]>([]);
  const [picked, setPicked] = useState('');
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    let cancelled = false;
    listPostedInvoicesForCreditRequest(customerId ? Number(customerId) : null).then((res) => {
      if (!cancelled) setInvoices(res.ok ? res.data : []);
    });
    return () => { cancelled = true; };
  }, [customerId]);

  const copy = async (no: string) => {
    setPicked(no);
    setError(null);
    if (!no) return;
    setBusy(true);
    try {
      const res = await getInvoiceForCreditMemoRequest(no);
      if (!res.ok) { setError(res.error ?? 'Could not read that invoice'); return; }
      onCopy(res.data);
    } finally {
      setBusy(false);
    }
  };

  return (
    <div className="card inset" style={{ marginBottom: 'calc(var(--sp)*1.5)' }}>
      <SearchableSelect
        name="appliesToDocNo" label="Credit against posted invoice" items={invoices}
        getValue={(i) => i.no} value={picked} onChange={copy} disabled={busy}
        getLabel={(i) => `${i.no} — ${i.customer_no} ${i.customer_name} · ${fdate(i.posting_date)} · ${cur(i.amount)}${
          i.remaining_amount ? ` · ${cur(i.remaining_amount)} open` : ' · settled'}`}
        placeholder={busy ? 'Copying…' : 'Search invoice no., customer…'}
        emptyText={customerId ? 'No posted invoices for this customer' : 'No posted invoices'}
        hint="Optional — picking one fills in the customer and copies its lines, and the memo settles that invoice when posted."
      />
      {error ? <div className="tiny" style={{ color: 'var(--danger)' }}>{error}</div> : null}
    </div>
  );
}
