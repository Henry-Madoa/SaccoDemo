import Link from 'next/link';
import { notFound } from 'next/navigation';
import { requireAction, currentCanAction } from '@/lib/session';
import { statement } from '@/lib/savings';
import { getOrgBrand } from '@/lib/org';
import { formatDate } from '@/lib/format';
import { Page } from '@/components/layout/page';
import { Card, CardHead, EmptyState, Pill, Stat, TableWrap, Toolbar, Spacer } from '@/components/ui/primitives';
import { Money } from '@/components/ui/money';
import { PrintButton } from '@/components/ui/print-button';
import { TxnButton, type TxnAccount } from '../txn-form';
import { ReverseButton } from './reverse-button';

export default async function SavingsAccountPage({ params }: { params: Promise<{ id: string }> }) {
  const user = await requireAction('SAVINGS_READ');
  const { id } = await params;

  let data;
  try {
    data = await statement(Number(id));
  } catch {
    notFound();
  }

  const { account: a, opening, lines } = data;
  const [org, canDeposit, canWithdraw, canReverse] = await Promise.all([
    getOrgBrand(),
    currentCanAction('SAVINGS_DEPOSIT'), currentCanAction('SAVINGS_WITHDRAW'), currentCanAction('SAVINGS_REVERSE'),
  ]);

  const available = a.balance - a.hold_amount - a.min_balance;
  const account: TxnAccount = {
    id: a.id, account_no: a.account_no, product_name: a.product_name,
    balance: a.balance, hold_amount: a.hold_amount, min_balance: a.min_balance,
    withdrawal_fee: a.withdrawal_fee,
    member_no: a.member_no, first_name: a.first_name, last_name: a.last_name,
  };

  // The statement's running balance starts from the opening figure and walks
  // the period's postings, so it reconciles to the closing balance on screen.
  let running = opening;
  const rows = lines.map((t) => {
    running += t.amount;
    return { txn: t, running };
  });

  return (
    <Page
      title={`Account ${a.account_no}`}
      crumb={`${a.first_name} ${a.last_name} · ${a.product_name}`}
      user={user}
    >
      <Toolbar>
        <Link href="/savings" className="btn ghost sm">← All accounts</Link>
        <Link href={`/members/${a.member_id}`} className="btn ghost sm">Member 360</Link>
        <Spacer />
        {canDeposit ? <TxnButton kind="DEPOSIT" account={account} className="btn ghost" /> : null}
        {canWithdraw && a.allow_withdrawal && a.status === 'ACTIVE'
          ? <TxnButton kind="WITHDRAWAL" account={account} className="btn ghost" />
          : null}
        <PrintButton>Print statement</PrintButton>
      </Toolbar>

      <div className="grid g4 stack-2">
        <Stat label="Balance" value={<Money cents={a.balance} />} />
        <Stat label="Available" value={<Money cents={Math.max(available, 0)} />}
          foot="after minimum balance and holds" />
        <Stat label="Status" small value={<Pill status={a.status} />}
          foot={`opened ${formatDate(a.opened_date)}`} />
        <Stat label="Product" small value={a.product_code} foot={a.product_name} />
      </div>

      <Card>
        <CardHead
          title="Statement of account"
          sub={`${org!.name} · ${a.first_name} ${a.last_name} (${a.member_no}) · account ${a.account_no}`}
        />
        {lines.length ? (
          <TableWrap>
            <thead>
              <tr>
                <th>Date</th><th>Reference</th><th>Description</th><th>Channel</th>
                <th className="num">Debit</th><th className="num">Credit</th>
                <th className="num">Balance</th><th />
              </tr>
            </thead>
            <tbody>
              <tr>
                <td colSpan={6}><i>Opening balance</i></td>
                <td className="num"><b><Money cents={opening} symbol={false} /></b></td>
                <td />
              </tr>
              {rows.map(({ txn: t, running: bal }) => {
                const reversed = t.status === 'REVERSED';
                return (
                  <tr key={t.id} className={reversed ? 'muted' : undefined}>
                    <td>{formatDate(t.value_date)}</td>
                    <td className="mono">{t.txn_ref}</td>
                    <td>
                      {t.description || ''}
                      {reversed ? <> <Pill tone="bad">REVERSED</Pill></> : null}
                    </td>
                    <td>{t.channel}</td>
                    <td className="num">
                      {t.amount < 0 ? <Money cents={-t.amount} symbol={false} /> : ''}
                    </td>
                    <td className="num">
                      {t.amount > 0 ? <Money cents={t.amount} symbol={false} /> : ''}
                    </td>
                    <td className="num"><Money cents={bal} symbol={false} /></td>
                    <td className="num">
                      {canReverse && !reversed && t.txn_type !== 'REVERSAL'
                        ? <ReverseButton accountId={a.id} txnId={t.id} />
                        : null}
                    </td>
                  </tr>
                );
              })}
            </tbody>
            <tfoot>
              <tr>
                <td colSpan={6}>Closing balance</td>
                <td className="num"><Money cents={a.balance} symbol={false} /></td>
                <td />
              </tr>
            </tfoot>
          </TableWrap>
        ) : <EmptyState icon="🧾" title="No transactions on this account" />}
      </Card>
    </Page>
  );
}
