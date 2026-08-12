import Link from 'next/link';
import { requirePerm, currentCan } from '@/lib/session';
import { listAccounts } from '@/lib/savings';
import { Page } from '@/components/layout/page';
import { Card, CardHead, EmptyState, Pill, TableWrap, Toolbar, Spacer } from '@/components/ui/primitives';
import { SearchInput } from '@/components/ui/filters';
import { Money } from '@/components/ui/money';
import { TxnButton, type TxnAccount } from './txn-form';

export default async function SavingsPage({ searchParams }: {
  searchParams: Promise<{ q?: string }>;
}) {
  const user = await requirePerm('SAVINGS:READ');
  const { q = '' } = await searchParams;
  const [rows, canDeposit, canWithdraw] = await Promise.all([
    listAccounts(q), currentCan('SAVINGS:DEPOSIT'), currentCan('SAVINGS:WITHDRAW'),
  ]);

  const total = rows.reduce((a, r) => a + r.balance, 0);

  return (
    <Page title="Savings & FOSA" crumb="Member deposit accounts and teller operations" user={user}>
      <Toolbar>
        <SearchInput placeholder="Search account number, member number or name…" />
        <Spacer />
      </Toolbar>

      <Card>
        {rows.length ? (
          <>
            <CardHead
              title={`${rows.length} account${rows.length === 1 ? '' : 's'}`}
              sub={<>Combined balance <Money cents={total} /></>}
            />
            <TableWrap>
              <thead>
                <tr>
                  <th>Account no.</th><th>Member</th><th>Product</th><th>Status</th>
                  <th className="num">Balance</th><th className="num">Available</th>
                  <th className="num">Actions</th>
                </tr>
              </thead>
              <tbody>
                {rows.map((a) => {
                  const available = a.balance - a.hold_amount - a.min_balance;
                  // The modal needs the account shape, not the whole row.
                  const account: TxnAccount = {
                    id: a.id, account_no: a.account_no, product_name: a.product_name,
                    balance: a.balance, hold_amount: a.hold_amount, min_balance: a.min_balance,
                    member_no: a.member_no, first_name: a.first_name, last_name: a.last_name,
                  };
                  return (
                    <tr key={a.id}>
                      <td className="mono"><Link href={`/savings/${a.id}`}>{a.account_no}</Link></td>
                      <td>
                        {a.first_name} {a.last_name}
                        <div className="tiny mono">{a.member_no}</div>
                      </td>
                      <td>{a.product_name}</td>
                      <td><Pill status={a.status} /></td>
                      <td className="num"><b><Money cents={a.balance} /></b></td>
                      <td className="num muted-cell"><Money cents={Math.max(available, 0)} /></td>
                      <td className="num">
                        {canDeposit ? <TxnButton kind="DEPOSIT" account={account} /> : null}
                        {canWithdraw && a.allow_withdrawal && a.status === 'ACTIVE'
                          ? <TxnButton kind="WITHDRAWAL" account={account} />
                          : null}
                      </td>
                    </tr>
                  );
                })}
              </tbody>
            </TableWrap>
          </>
        ) : <EmptyState icon="💰" title="No accounts found" />}
      </Card>
    </Page>
  );
}
