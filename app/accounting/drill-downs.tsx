'use client';

import { useEffect, useState } from 'react';
import { useSearchParams } from 'next/navigation';
import { Modal } from '@/components/ui/modal';
import { FormModal } from '@/components/ui/form-modal';
import { Field } from '@/components/ui/field';
import { DefinitionList, EmptyState, Pill, TableWrap } from '@/components/ui/primitives';
import { useFormat } from '@/components/ui/format-provider';
import { fetchAccountLedger, fetchJournal, reverseJournal } from '@/app/actions/gl';
import { NATURAL_DEBIT_TYPES } from '@/lib/constants';
import { parseFilters } from '@/lib/listFilters';
import type { AccountLedger, JournalDetail } from '@/lib/gl';

/** Clickable balance that opens the account's ledger — drills through the exact same As Of
 *  date and Global Dimension filters currently applied to the Trial Balance / Chart of
 *  Accounts screen, so the entries shown always reconcile to the figure that was clicked. */
export function LedgerLink({ code, children }: { code: string; children: React.ReactNode }) {
  const [open, setOpen] = useState(false);
  return (
    <>
      <button type="button" className="linklike" onClick={() => setOpen(true)}>{children}</button>
      {open ? <LedgerModal code={code} onClose={() => setOpen(false)} /> : null}
    </>
  );
}

function LedgerModal({ code, onClose }: { code: string; onClose: () => void }) {
  const { cur, fdate } = useFormat();
  const params = useSearchParams();
  const asOf = params.get('asOf') || undefined;
  const filters = parseFilters(params.get('filters'));
  const [data, setData] = useState<AccountLedger | null>(null);
  const [error, setError] = useState('');

  useEffect(() => {
    fetchAccountLedger(code, { asOf, filters }).then((res) => {
      if (res.ok) setData(res.data);
      else setError(res.error);
    });
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [code, asOf, params.get('filters')]);

  const title = data ? `${data.account.code} — ${data.account.name}` : `Account ${code}`;
  const naturalDebit = data ? NATURAL_DEBIT_TYPES.includes(data.account.type) : true;
  const filtered = Boolean(asOf) || filters.some((f) => (
    f.field === 'global_dimension_1_id' || f.field === 'global_dimension_2_id'
  ) && f.value !== '');
  let running = 0;

  return (
    <Modal wide title={title} onClose={onClose}
      footer={<button type="button" className="btn ghost" onClick={onClose}>Close</button>}>
      {error ? <EmptyState icon="⚠" title={error} /> : null}
      {!data && !error ? <EmptyState title="Loading…" /> : null}
      {data ? (
        <>
          <div className="card-sub" style={{ marginBottom: 'calc(var(--sp)*2)' }}>
            {data.account.type} · balance {cur(data.balance)}
            {filtered ? <> · <Pill tone="info">FILTERED{asOf ? ` AS OF ${fdate(asOf)}` : ''}</Pill></> : null}
          </div>
          {data.lines.length ? (
            <TableWrap>
              <thead>
                <tr>
                  <th>Date</th><th>Journal</th><th>Description</th><th>Source</th>
                  <th className="num">Debit</th><th className="num">Credit</th><th className="num">Balance</th>
                </tr>
              </thead>
              <tbody>
                {data.lines.map((l) => {
                  running += naturalDebit ? l.debit - l.credit : l.credit - l.debit;
                  return (
                    <tr key={l.id}>
                      <td>{fdate(l.value_date)}</td>
                      <td className="mono">{l.journal_no}</td>
                      <td>{l.narration || l.description || ''}</td>
                      <td>{l.source_module}</td>
                      <td className="num">{l.debit ? cur(l.debit, { showSymbol: false }) : ''}</td>
                      <td className="num">{l.credit ? cur(l.credit, { showSymbol: false }) : ''}</td>
                      <td className="num">{cur(running, { showSymbol: false })}</td>
                    </tr>
                  );
                })}
              </tbody>
            </TableWrap>
          ) : <EmptyState icon="📖" title="No movement on this account" />}
        </>
      ) : null}
    </Modal>
  );
}

/** Clickable journal row that opens the posting and offers a reversal. */
export function JournalLink({ id, canReverse, caption1, caption2, children }: {
  id: number; canReverse: boolean; caption1: string; caption2: string; children: React.ReactNode;
}) {
  const [open, setOpen] = useState(false);
  return (
    <>
      <button type="button" className="linklike" onClick={() => setOpen(true)}>{children}</button>
      {open ? (
        <JournalModal id={id} canReverse={canReverse} caption1={caption1} caption2={caption2}
          onClose={() => setOpen(false)} />
      ) : null}
    </>
  );
}

function JournalModal({ id, canReverse, caption1, caption2, onClose }: {
  id: number; canReverse: boolean; caption1: string; caption2: string; onClose: () => void;
}) {
  const { cur, fdate, fdatetime } = useFormat();
  const [data, setData] = useState<JournalDetail | null>(null);
  const [error, setError] = useState('');
  const [reversing, setReversing] = useState(false);

  useEffect(() => {
    fetchJournal(id).then((res) => {
      if (res.ok) setData(res.data);
      else setError(res.error);
    });
  }, [id]);

  if (reversing && data) {
    return (
      <FormModal
        title={`Reverse ${data.journal.journal_no}`}
        onClose={() => setReversing(false)}
        onSubmit={(values) => reverseJournal(id, values)}
        submitLabel="Post reversal"
        submitClass="btn danger"
        successTitle="Reversed"
        successDetail={(rev) => `Compensating journal ${rev.journal_no}`}
        resultStyle="popup"
      >
        <p>A compensating journal will be posted. The original entry is preserved.</p>
        <Field name="reason" label="Reason" required />
      </FormModal>
    );
  }

  const j = data?.journal;
  const totals = (data?.lines ?? []).reduce(
    (a, l) => ({ d: a.d + l.debit, c: a.c + l.credit }), { d: 0, c: 0 },
  );
  const reversible = j && canReverse && !j.reversed_by_id && !j.reverses_id;

  return (
    <Modal wide title={j ? `Journal ${j.journal_no}` : 'Journal'} onClose={onClose}
      footer={
        <>
          <button type="button" className="btn ghost" onClick={onClose}>Close</button>
          {reversible
            ? <button type="button" className="btn danger" onClick={() => setReversing(true)}>Reverse journal</button>
            : null}
        </>
      }>
      {error ? <EmptyState icon="⚠" title={error} /> : null}
      {!data && !error ? <EmptyState title="Loading…" /> : null}
      {data && j ? (
        <>
          <DefinitionList items={[
            ['Value date', fdate(j.value_date)],
            ['Posted', `${fdatetime(j.posted_at)} by ${j.posted_by || ''}`],
            ['Source', `${j.source_module} · ${j.event_type}`],
            ['Description', j.description || ''],
            j.reference ? ['Reference', <span className="mono" key="ref">{j.reference}</span>] : null,
          ]} />
          <div style={{ marginTop: 'calc(var(--sp)*2)' }}>
            <TableWrap>
              <thead>
                <tr>
                  <th className="num">#</th><th>Account</th><th>Narration</th>
                  <th>{caption1}</th><th>{caption2}</th>
                  <th className="num">Debit</th><th className="num">Credit</th>
                </tr>
              </thead>
              <tbody>
                {data.lines.map((l) => (
                  <tr key={l.id}>
                    <td className="num">{l.line_no}</td>
                    <td><span className="mono">{l.code}</span> {l.name}</td>
                    <td className="muted-cell">{l.narration || ''}</td>
                    <td>{l.global_dimension_1_code || '—'}</td>
                    <td>{l.global_dimension_2_code || '—'}</td>
                    <td className="num">{l.debit ? cur(l.debit, { showSymbol: false }) : ''}</td>
                    <td className="num">{l.credit ? cur(l.credit, { showSymbol: false }) : ''}</td>
                  </tr>
                ))}
              </tbody>
              <tfoot>
                <tr>
                  <td colSpan={5}>Totals</td>
                  <td className="num">{cur(totals.d, { showSymbol: false })}</td>
                  <td className="num">{cur(totals.c, { showSymbol: false })}</td>
                </tr>
              </tfoot>
            </TableWrap>
          </div>
          {j.reversed_by_id ? (
            <div style={{ marginTop: 12 }}><Pill tone="bad">This journal has been reversed</Pill></div>
          ) : null}
        </>
      ) : null}
    </Modal>
  );
}
