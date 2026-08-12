import { notFound } from 'next/navigation';
import { requirePerm, currentCan } from '@/lib/session';
import {
  getTrialBalance, listJournals, listGlAccounts, listPeriods, listPostableAccounts,
} from '@/lib/gl';
import { formatDate } from '@/lib/format';
import { Page } from '@/components/layout/page';
import {
  Card, CardHead, EmptyState, Pill, TableWrap, Tabs, Toolbar, Spacer, type TabDefinition,
} from '@/components/ui/primitives';
import { SearchInput } from '@/components/ui/filters';
import { Money } from '@/components/ui/money';
import { LedgerLink, JournalLink } from '../drill-downs';
import { NewJournalButton } from '../journal-form';
import { AddGlAccountButton } from '../gl-account-form';
import { PeriodToggle } from '../period-toggle';

const TABS: TabDefinition[] = [
  { key: 'trial-balance', label: 'Trial balance' },
  { key: 'journals', label: 'Journals' },
  { key: 'accounts', label: 'Chart of accounts' },
  { key: 'periods', label: 'Accounting periods' },
];

export default async function AccountingPage({ params, searchParams }: {
  params: Promise<{ tab?: string[] }>;
  searchParams: Promise<{ q?: string }>;
}) {
  const user = await requirePerm('GL:READ');
  const { tab: segments } = await params;
  const { q = '' } = await searchParams;
  const tab = segments?.[0] ?? 'trial-balance';
  if (!TABS.some((t) => t.key === tab)) notFound();

  return (
    <Page
      title="General Ledger"
      crumb="Financial system of record — every module posts here"
      user={user}
    >
      <Tabs tabs={TABS} active={tab} hrefFor={(k) => `/accounting/${k}`} />
      {tab === 'trial-balance' ? <TrialBalanceTab /> : null}
      {tab === 'journals' ? <JournalsTab search={q} /> : null}
      {tab === 'accounts' ? <AccountsTab /> : null}
      {tab === 'periods' ? <PeriodsTab /> : null}
    </Page>
  );
}

async function TrialBalanceTab() {
  const { rows, totals, balanced } = await getTrialBalance();
  return (
    <Card>
      <CardHead title="Trial balance" sub="Derived from posted journal lines, not from stored balances">
        <Pill tone={balanced ? 'ok' : 'bad'}>{balanced ? 'IN BALANCE' : 'OUT OF BALANCE'}</Pill>
      </CardHead>
      <TableWrap>
        <thead>
          <tr>
            <th>Code</th><th>Account</th><th>Type</th>
            <th className="num">Debits</th><th className="num">Credits</th>
            <th className="num">Debit balance</th><th className="num">Credit balance</th>
          </tr>
        </thead>
        <tbody>
          {rows.map((r) => (
            <tr key={r.id}>
              <td className="mono"><LedgerLink code={r.code}>{r.code}</LedgerLink></td>
              <td><LedgerLink code={r.code}>{r.name}</LedgerLink></td>
              <td className="tiny">{r.type}</td>
              <td className="num"><Money cents={r.debit} symbol={false} decimals={0} /></td>
              <td className="num"><Money cents={r.credit} symbol={false} decimals={0} /></td>
              <td className="num">
                <b>{r.debit_balance ? <Money cents={r.debit_balance} symbol={false} /> : ''}</b>
              </td>
              <td className="num">
                <b>{r.credit_balance ? <Money cents={r.credit_balance} symbol={false} /> : ''}</b>
              </td>
            </tr>
          ))}
        </tbody>
        <tfoot>
          <tr>
            <td colSpan={5}>Totals</td>
            <td className="num"><Money cents={totals.debit} symbol={false} /></td>
            <td className="num"><Money cents={totals.credit} symbol={false} /></td>
          </tr>
        </tfoot>
      </TableWrap>
    </Card>
  );
}

async function JournalsTab({ search }: { search: string }) {
  const [rows, canCreate, canReverse, postableAccounts] = await Promise.all([
    listJournals(search),
    currentCan('GL:JOURNAL_CREATE'), currentCan('GL:JOURNAL_APPROVE'),
    listPostableAccounts(),
  ]);

  return (
    <>
      <Toolbar>
        <SearchInput placeholder="Search journal number, description or reference…" />
        <Spacer />
        {canCreate ? <NewJournalButton accounts={postableAccounts} /> : null}
      </Toolbar>
      <Card>
        {rows.length ? (
          <TableWrap>
            <thead>
              <tr>
                <th>Journal</th><th>Value date</th><th>Source</th><th>Event</th>
                <th>Description</th><th>Member</th><th className="num">Amount</th>
                <th>Posted by</th><th />
              </tr>
            </thead>
            <tbody>
              {rows.map((j) => (
                <tr key={j.id} className={j.reversed_by_id ? 'muted' : undefined}>
                  <td className="mono">
                    <JournalLink id={j.id} canReverse={canReverse}>{j.journal_no}</JournalLink>
                  </td>
                  <td>{formatDate(j.value_date)}</td>
                  <td>{j.source_module}</td>
                  <td><Pill status={j.event_type} /></td>
                  <td>{j.description || ''}</td>
                  <td>{j.member_no ? `${j.first_name} ${j.last_name}` : '—'}</td>
                  <td className="num"><Money cents={j.amount} /></td>
                  <td className="muted-cell">{j.posted_by || ''}</td>
                  <td>
                    {j.reversed_by_id ? <Pill tone="bad">REVERSED</Pill>
                      : j.reverses_id ? <Pill>REVERSAL</Pill> : null}
                  </td>
                </tr>
              ))}
            </tbody>
          </TableWrap>
        ) : <EmptyState icon="📚" title="No journals found" />}
      </Card>
    </>
  );
}

async function AccountsTab() {
  const rows = await listGlAccounts();
  const canManage = await currentCan('ADMIN:COA_MANAGE');

  return (
    <>
      <Toolbar>
        <Spacer />
        {canManage ? <AddGlAccountButton /> : null}
      </Toolbar>
      <Card>
        <CardHead
          title="Chart of accounts"
          sub="Header accounts are not postable — modules post only to leaf accounts"
        />
        <TableWrap>
          <thead>
            <tr>
              <th>Code</th><th>Account</th><th>Type</th><th>Parent</th>
              <th>Postable</th><th className="num">Balance</th>
            </tr>
          </thead>
          <tbody>
            {rows.map((a) => (
              <tr key={a.id} className={a.is_postable ? undefined : 'header-row'}>
                <td className="mono">{a.code}</td>
                <td>{a.name}</td>
                <td className="tiny">{a.type}</td>
                <td className="mono muted-cell">{a.parent_code || ''}</td>
                <td>{a.is_postable ? <Pill tone="ok">YES</Pill> : <Pill>HEADER</Pill>}</td>
                <td className="num">{a.is_postable ? <Money cents={a.balance} /> : ''}</td>
              </tr>
            ))}
          </tbody>
        </TableWrap>
      </Card>
    </>
  );
}

async function PeriodsTab() {
  const rows = await listPeriods();
  const canClose = await currentCan('GL:PERIOD_CLOSE');

  return (
    <Card>
      <CardHead
        title="Accounting periods"
        sub="A closed period rejects every posting, including automated ones"
      />
      <TableWrap>
        <thead>
          <tr><th>Period</th><th>From</th><th>To</th><th>Status</th><th className="num" /></tr>
        </thead>
        <tbody>
          {rows.map((p) => (
            <tr key={p.id}>
              <td className="mono">{p.code}</td>
              <td>{formatDate(p.start_date)}</td>
              <td>{formatDate(p.end_date)}</td>
              <td><Pill status={p.status} /></td>
              <td className="num">{canClose ? <PeriodToggle period={p} /> : null}</td>
            </tr>
          ))}
        </tbody>
      </TableWrap>
    </Card>
  );
}
