import Link from 'next/link';
import { notFound } from 'next/navigation';
import { requireAction, currentCanAction } from '@/lib/session';
import { getBankReconciliationWorksheet } from '@/lib/gl';
import { formatDate, formatDateTime } from '@/lib/format';
import { Page } from '@/components/layout/page';
import {
  Card, CardHead, DefinitionList, EmptyState, Pill, Stat, TableWrap, Toolbar, Spacer,
} from '@/components/ui/primitives';
import { Money } from '@/components/ui/money';
import { ReconcileCheckbox, CompleteReconciliationButton } from './reconciliation-actions';

export default async function BankReconciliationPage({ params }: { params: Promise<{ id: string }> }) {
  const user = await requireAction('GL_READ');
  const { id } = await params;
  const [worksheet, canReconcile] = await Promise.all([
    getBankReconciliationWorksheet(Number(id)),
    currentCanAction('GL_BANK_RECONCILE'),
  ]);
  if (!worksheet) notFound();

  const { reconciliation: r, bankAccount, entries, clearedTotal, difference } = worksheet;
  const editable = canReconcile && r.status === 'OPEN';
  const clearedCount = entries.filter((e) => e.reconciled === 1).length;

  return (
    <Page
      title={`Reconcile ${bankAccount.code} — ${bankAccount.name}`}
      crumb={`Statement ${formatDate(r.statement_date)} · ${r.status}`}
      user={user}
    >
      <Toolbar>
        <Link href="/accounting/bank-accounts" className="btn ghost sm">← All bank accounts</Link>
        <Spacer />
        {editable ? <CompleteReconciliationButton id={r.id} disabled={difference !== 0} /> : null}
      </Toolbar>

      <div className="grid g4 stack-2">
        <Stat label="Statement balance" value={<Money cents={r.statement_balance} />} />
        <Stat label="Cleared total" value={<Money cents={clearedTotal} />} foot={`${clearedCount} of ${entries.length} ticked`} />
        <Stat
          label="Difference"
          value={<span className={difference === 0 ? 'pos' : 'neg'}><Money cents={difference} /></span>}
          foot={difference === 0 ? 'Ready to complete' : 'Tick every matching entry'}
        />
        <Stat label="Status" small value={<Pill status={r.status} />} />
      </div>

      <Card>
        <CardHead title="Bank account" />
        <DefinitionList items={[
          ['Bank account', `${bankAccount.code} — ${bankAccount.name}`],
          ['G/L balance', <Money cents={bankAccount.balance} key="bal" />],
          ['Started', r.created_at ? `${formatDateTime(r.created_at)} by ${r.created_by || '—'}` : '—'],
          r.status === 'COMPLETED'
            ? ['Completed', `${r.completed_at ? formatDateTime(r.completed_at) : ''} by ${r.completed_by || '—'}`]
            : null,
        ]} />
      </Card>

      <Card>
        <CardHead
          title="Entries up to statement date"
          sub="Tick every entry the bank statement confirms — the difference must reach zero before completing"
        />
        {entries.length ? (
          <TableWrap>
            <thead>
              <tr>
                <th />
                <th>Date</th><th>Journal</th><th>Source</th><th>Description</th>
                <th className="num">Amount</th><th className="num">Running balance</th>
              </tr>
            </thead>
            <tbody>
              {entries.map((e) => (
                <tr key={e.id}>
                  <td><ReconcileCheckbox entry={e} reconciliationId={r.id} editable={editable} /></td>
                  <td>{formatDate(e.posting_date)}</td>
                  <td className="mono">{e.journal_no}</td>
                  <td>{e.source_module}</td>
                  <td>{e.description || ''}</td>
                  <td className="num"><Money cents={e.amount} /></td>
                  <td className="num"><Money cents={e.running_balance} /></td>
                </tr>
              ))}
            </tbody>
          </TableWrap>
        ) : <EmptyState icon="🏦" title="No entries up to this statement date" />}
      </Card>
    </Page>
  );
}
