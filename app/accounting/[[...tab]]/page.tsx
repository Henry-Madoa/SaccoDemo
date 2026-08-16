import { notFound } from 'next/navigation';
import { requireAction, currentCanAction } from '@/lib/session';
import Link from 'next/link';
import {
  getTrialBalance, listJournals, hasAnyJournals, listGlAccounts, hasAnyGlAccounts, listPeriods, hasAnyPeriods,
  listPostableAccounts, totalingBalance,
  listVendorLedgerEntries, hasAnyVendorLedgerEntries, listCustomerLedgerEntries, hasAnyCustomerLedgerEntries,
  getDormancyAging, listBankAccounts, hasAnyBankAccounts,
  JOURNAL_FILTER_FIELDS, GL_ACCOUNT_FILTER_FIELDS, TRIAL_BALANCE_FILTER_FIELDS, PERIOD_FILTER_FIELDS,
  GL_DIMENSION_FILTER_FIELDS, SUBLEDGER_ENTRY_FILTER_FIELDS,
} from '@/lib/gl';
import { GL_ACCOUNT_STRUCTURE_TYPES } from '@/lib/constants';
import { listActiveDimensionValues } from '@/lib/pool';
import { getDimensionCaptions } from '@/lib/org';
import { formatDate } from '@/lib/format';
import { parseFilters } from '@/lib/listFilters';
import { parseSort } from '@/lib/listSort';
import { Page } from '@/components/layout/page';
import {
  Card, CardHead, EmptyState, Pill, TableWrap, Tabs, Toolbar, Spacer, type TabDefinition,
} from '@/components/ui/primitives';
import { SearchInput, DateFilterInput } from '@/components/ui/filters';
import { DynamicFilterBar } from '@/components/ui/dynamic-filter';
import { SortLink } from '@/components/ui/sort-link';
import { Money } from '@/components/ui/money';
import { ExportButton } from '@/components/ui/export-button';
import { LedgerLink, JournalLink } from '../drill-downs';
import { NewJournalButton } from '../journal-form';
import { GlAccountFormButton } from '../gl-account-form';
import { BankAccountFormButton } from '../bank-account-form';
import { StartReconciliationButton } from '../start-reconciliation-button';
import { PeriodToggle } from '../period-toggle';

const TABS: TabDefinition[] = [
  { key: 'trial-balance', label: 'Trial balance' },
  { key: 'journals', label: 'Journals' },
  { key: 'accounts', label: 'Chart of accounts' },
  { key: 'vendor-ledger', label: 'Vendor Ledger Entries' },
  { key: 'customer-ledger', label: 'Customer Ledger Entries' },
  { key: 'bank-accounts', label: 'Bank Accounts' },
  { key: 'periods', label: 'Accounting periods' },
];

export default async function AccountingPage({ params, searchParams }: {
  params: Promise<{ tab?: string[] }>;
  searchParams: Promise<{ q?: string; filters?: string; sort?: string; asOf?: string }>;
}) {
  const user = await requireAction('GL_READ');
  const { tab: segments } = await params;
  const { q = '', filters: filtersRaw, sort: sortRaw, asOf } = await searchParams;
  const tab = segments?.[0] ?? 'trial-balance';
  if (!TABS.some((t) => t.key === tab)) notFound();

  return (
    <Page
      title="General Ledger"
      crumb="Financial system of record — every module posts here"
      user={user}
    >
      <Tabs tabs={TABS} active={tab} hrefFor={(k) => `/accounting/${k}`} />
      {tab === 'trial-balance' ? <TrialBalanceTab filtersRaw={filtersRaw} asOf={asOf} /> : null}
      {tab === 'journals' ? <JournalsTab search={q} filtersRaw={filtersRaw} sortRaw={sortRaw} /> : null}
      {tab === 'accounts' ? <AccountsTab search={q} filtersRaw={filtersRaw} sortRaw={sortRaw} asOf={asOf} /> : null}
      {tab === 'vendor-ledger' ? <VendorLedgerTab search={q} filtersRaw={filtersRaw} sortRaw={sortRaw} /> : null}
      {tab === 'customer-ledger' ? <CustomerLedgerTab search={q} filtersRaw={filtersRaw} sortRaw={sortRaw} /> : null}
      {tab === 'bank-accounts' ? <BankAccountsTab /> : null}
      {tab === 'periods' ? <PeriodsTab search={q} filtersRaw={filtersRaw} sortRaw={sortRaw} /> : null}
    </Page>
  );
}

async function TrialBalanceTab({ filtersRaw, asOf }: { filtersRaw?: string; asOf?: string }) {
  const filters = parseFilters(filtersRaw);
  const [{ rows, totals, balanced }, empty, gd1Values, gd2Values, { caption1, caption2 }] = await Promise.all([
    getTrialBalance({ asOf: asOf || null, filters }),
    hasAnyGlAccounts().then((any) => !any),
    listActiveDimensionValues(1), listActiveDimensionValues(2), getDimensionCaptions(),
  ]);
  const tbFields = TRIAL_BALANCE_FILTER_FIELDS.map((f) => (
    f.key === 'global_dimension_1_id' ? { ...f, label: caption1, options: gd1Values.map((d) => ({ value: d.id, label: `${d.code} — ${d.name}` })) }
      : f.key === 'global_dimension_2_id' ? { ...f, label: caption2, options: gd2Values.map((d) => ({ value: d.id, label: `${d.code} — ${d.name}` })) }
        : f
  ));

  return (
    <>
      <Toolbar>
        <DynamicFilterBar fields={tbFields} disabled={empty} />
        <DateFilterInput paramName="asOf" label="As of" placeholder="As of" disabled={empty} />
        <Spacer />
        <ExportButton
          href="/api/export/trial-balance" params={{ filters: filtersRaw, asOf }} disabled={!rows.length}
        />
      </Toolbar>
      <Card>
      <CardHead title="Trial balance" sub="Derived from posted journal lines, not from stored balances — click a balance to drill into its entries">
        <Pill tone={balanced ? 'ok' : 'bad'}>{balanced ? 'IN BALANCE' : 'OUT OF BALANCE'}</Pill>
      </CardHead>
      {rows.length ? (
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
                <td className="mono">{r.code}</td>
                <td>{r.name}</td>
                <td className="tiny">{r.type}</td>
                <td className="num"><Money cents={r.debit} symbol={false} decimals={0} /></td>
                <td className="num"><Money cents={r.credit} symbol={false} decimals={0} /></td>
                <td className="num">
                  <b>{r.debit_balance ? (
                    <LedgerLink code={r.code} caption1={caption1} caption2={caption2}>
                      <Money cents={r.debit_balance} symbol={false} />
                    </LedgerLink>
                  ) : ''}</b>
                </td>
                <td className="num">
                  <b>{r.credit_balance ? (
                    <LedgerLink code={r.code} caption1={caption1} caption2={caption2}>
                      <Money cents={r.credit_balance} symbol={false} />
                    </LedgerLink>
                  ) : ''}</b>
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
      ) : <EmptyState icon="⚖" title="No accounts match" sub="Try a different filter or as-of date" />}
    </Card>
    </>
  );
}

async function JournalsTab({ search, filtersRaw, sortRaw }: { search: string; filtersRaw?: string; sortRaw?: string }) {
  const filters = parseFilters(filtersRaw);
  const sort = parseSort(sortRaw);
  const [rows, empty, canCreate, canReverse, postableAccounts, gd1Values, gd2Values, { caption1, caption2 }] =
    await Promise.all([
      listJournals({ search, filters, sort }),
      hasAnyJournals().then((any) => !any),
      currentCanAction('GL_JOURNAL_CREATE'), currentCanAction('GL_JOURNAL_REVERSE'),
      listPostableAccounts(),
      listActiveDimensionValues(1), listActiveDimensionValues(2), getDimensionCaptions(),
    ]);
  const journalFields = JOURNAL_FILTER_FIELDS.map((f) => (
    f.key === 'global_dimension_1_id' ? { ...f, label: caption1, options: gd1Values.map((d) => ({ value: d.id, label: `${d.code} — ${d.name}` })) }
      : f.key === 'global_dimension_2_id' ? { ...f, label: caption2, options: gd2Values.map((d) => ({ value: d.id, label: `${d.code} — ${d.name}` })) }
        : f
  ));

  return (
    <>
      <Toolbar>
        <SearchInput placeholder="Search journal number, description or reference…" disabled={empty} />
        <DynamicFilterBar fields={journalFields} disabled={empty} />
        <Spacer />
        <ExportButton href="/api/export/journal" params={{ q: search, filters: filtersRaw, sort: sortRaw }} disabled={!rows.length} />
        {canCreate ? (
          <NewJournalButton
            accounts={postableAccounts}
            globalDimension1Values={gd1Values}
            globalDimension2Values={gd2Values}
            caption1={caption1}
            caption2={caption2}
          />
        ) : null}
      </Toolbar>
      <Card>
        {rows.length ? (
          <TableWrap>
            <thead>
              <tr>
                <th><SortLink sortKey="journal_no">Journal</SortLink></th>
                <th><SortLink sortKey="value_date">Value date</SortLink></th>
                <th><SortLink sortKey="source_module">Source</SortLink></th>
                <th><SortLink sortKey="event_type">Event</SortLink></th>
                <th><SortLink sortKey="description">Description</SortLink></th>
                <th><SortLink sortKey="member">Member</SortLink></th>
                <th><SortLink sortKey="gd1">{caption1}</SortLink></th>
                <th><SortLink sortKey="gd2">{caption2}</SortLink></th>
                <th className="num"><SortLink sortKey="amount">Amount</SortLink></th>
                <th><SortLink sortKey="posted_by">Posted by</SortLink></th><th />
              </tr>
            </thead>
            <tbody>
              {rows.map((j) => (
                <tr key={j.id} className={j.reversed_by_id ? 'muted' : undefined}>
                  <td className="mono">
                    <JournalLink id={j.id} canReverse={canReverse} caption1={caption1} caption2={caption2}>
                      {j.journal_no}
                    </JournalLink>
                  </td>
                  <td>{formatDate(j.value_date)}</td>
                  <td>{j.source_module}</td>
                  <td><Pill status={j.event_type} /></td>
                  <td>{j.description || ''}</td>
                  <td>{j.member_no ? `${j.first_name} ${j.last_name}` : '—'}</td>
                  <td>{j.global_dimension_1_code || '—'}</td>
                  <td>{j.global_dimension_2_code || '—'}</td>
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

async function AccountsTab({ search, filtersRaw, sortRaw, asOf }: {
  search: string; filtersRaw?: string; sortRaw?: string; asOf?: string;
}) {
  const filters = parseFilters(filtersRaw);
  const sort = parseSort(sortRaw);
  // The stored gl_account.balance is a lifetime running total, unaware of the As Of date and
  // Global Dimension filters below — so the trial balance's own per-account aggregation is
  // reused here to get a balance that actually respects them (empty filters reproduce the
  // stored figure exactly, since that's how it's maintained on every posting).
  const [rows, empty, canManage, { rows: tbRows }, gd1Values, gd2Values, { caption1, caption2 }] = await Promise.all([
    listGlAccounts({ search, filters, sort }),
    hasAnyGlAccounts().then((any) => !any),
    currentCanAction('GL_ACCOUNT_MANAGE'),
    getTrialBalance({ asOf: asOf || null, filters }),
    listActiveDimensionValues(1), listActiveDimensionValues(2), getDimensionCaptions(),
  ]);
  const balanceByCode = new Map(tbRows.map((r) => [r.code, r.net]));
  const accountFields = [...GL_ACCOUNT_FILTER_FIELDS, ...GL_DIMENSION_FILTER_FIELDS].map((f) => (
    f.key === 'global_dimension_1_id' ? { ...f, label: caption1, options: gd1Values.map((d) => ({ value: d.id, label: `${d.code} — ${d.name}` })) }
      : f.key === 'global_dimension_2_id' ? { ...f, label: caption2, options: gd2Values.map((d) => ({ value: d.id, label: `${d.code} — ${d.name}` })) }
        : f
  ));
  const structureLabel = (t: string): string => GL_ACCOUNT_STRUCTURE_TYPES.find((s) => s.value === t)?.label ?? t;

  // Indentation follows Business Central's Begin-Total/End-Total bracketing, which only means
  // anything in code order — so depth is always resolved against the chart's natural order,
  // independent of whatever column the list itself is currently sorted by.
  const codeOrder = [...rows].sort((x, y) => x.code.localeCompare(y.code));
  const depthByCode = new Map<string, number>();
  let depth = 0;
  for (const r of codeOrder) {
    if (r.account_type === 'END_TOTAL') depth = Math.max(0, depth - 1);
    depthByCode.set(r.code, depth);
    if (r.account_type === 'BEGIN_TOTAL') depth += 1;
  }

  return (
    <>
      <Toolbar>
        <SearchInput placeholder="Search code or name…" disabled={empty} />
        <DynamicFilterBar fields={accountFields} disabled={empty} />
        <DateFilterInput paramName="asOf" label="As of" placeholder="As of" disabled={empty} />
        <Spacer />
        <ExportButton
          href="/api/export/gl-accounts" params={{ q: search, filters: filtersRaw, sort: sortRaw, asOf }}
          disabled={!rows.length}
        />
        {canManage ? <GlAccountFormButton className="btn">Add account</GlAccountFormButton> : null}
      </Toolbar>
      <Card>
        <CardHead
          title="Chart of accounts"
          sub="Only Posting accounts carry ledger entries — Total/End-Total roll one up from their Totaling range. Click a balance to drill into its entries"
        />
        {rows.length ? (
          <TableWrap>
            <thead>
              <tr>
                <th><SortLink sortKey="code">Code</SortLink></th>
                <th><SortLink sortKey="name">Account</SortLink></th>
                <th><SortLink sortKey="type">Type</SortLink></th>
                <th><SortLink sortKey="account_type">Account Type</SortLink></th>
                <th><SortLink sortKey="parent_code">Parent</SortLink></th>
                <th><SortLink sortKey="status">Status</SortLink></th>
                <th className="num"><SortLink sortKey="balance">Balance</SortLink></th><th />
              </tr>
            </thead>
            <tbody>
              {rows.map((a) => {
                const posting = a.account_type === 'POSTING';
                const rowDepth = depthByCode.get(a.code) ?? 0;
                const balance = posting
                  ? balanceByCode.get(a.code) ?? 0
                  : (a.account_type === 'TOTAL' || a.account_type === 'END_TOTAL')
                    ? totalingBalance(rows, balanceByCode, a.totaling)
                    : null;
                return (
                  <tr key={a.id} className={posting ? undefined : 'header-row'}>
                    <td className="mono" style={rowDepth ? { paddingLeft: 12 + rowDepth * 16 } : undefined}>
                      {a.code}
                    </td>
                    <td>{a.name}</td>
                    <td className="tiny">{a.type}</td>
                    <td className="tiny">{structureLabel(a.account_type)}</td>
                    <td className="mono muted-cell">{a.parent_code || ''}</td>
                    <td><Pill status={a.status} /></td>
                    <td className="num">
                      {posting ? (
                        <LedgerLink code={a.code} caption1={caption1} caption2={caption2}>
                          <Money cents={balance ?? 0} />
                        </LedgerLink>
                      ) : balance !== null ? <Money cents={balance} /> : ''}
                    </td>
                    <td>
                      {canManage ? (
                        <GlAccountFormButton account={a} className="btn sm ghost">Edit</GlAccountFormButton>
                      ) : null}
                    </td>
                  </tr>
                );
              })}
            </tbody>
          </TableWrap>
        ) : <EmptyState icon="⚖" title="No accounts match" sub="Try a different search or clear the filters" />}
      </Card>
    </>
  );
}

/** Shared table for Vendor (Savings) and Customer (Loans) Ledger Entries — same underlying
 *  `txn` data, filtered by module in lib/gl.ts's listSubledgerEntries(). */
function SubledgerEntryTable({ rows }: { rows: Awaited<ReturnType<typeof listVendorLedgerEntries>> }) {
  return (
    <TableWrap>
      <thead>
        <tr>
          <th><SortLink sortKey="value_date">Date</SortLink></th>
          <th><SortLink sortKey="txn_ref">Txn Ref</SortLink></th>
          <th>Document</th>
          <th><SortLink sortKey="member">Member</SortLink></th>
          <th>Type</th><th>Channel</th>
          <th className="num"><SortLink sortKey="amount">Amount</SortLink></th>
          <th><SortLink sortKey="status">Status</SortLink></th>
        </tr>
      </thead>
      <tbody>
        {rows.map((r) => (
          <tr key={r.id} className={r.status === 'REVERSED' ? 'muted' : undefined}>
            <td>{formatDate(r.value_date)}</td>
            <td className="mono">{r.txn_ref}</td>
            <td className="mono"><Link href={r.document_href}>{r.document_no}</Link></td>
            <td>{r.member_no ? `${r.first_name} ${r.last_name}` : '—'}</td>
            <td><Pill status={r.txn_type} /></td>
            <td>{r.channel}</td>
            <td className="num"><Money cents={r.amount} /></td>
            <td><Pill status={r.status} /></td>
          </tr>
        ))}
      </tbody>
    </TableWrap>
  );
}

async function VendorLedgerTab({ search, filtersRaw, sortRaw }: { search: string; filtersRaw?: string; sortRaw?: string }) {
  const filters = parseFilters(filtersRaw);
  const sort = parseSort(sortRaw);
  const [rows, empty, dormancy] = await Promise.all([
    listVendorLedgerEntries({ search, filters, sort }),
    hasAnyVendorLedgerEntries().then((any) => !any),
    getDormancyAging(),
  ]);
  const dormant = dormancy.filter((d) => d.bucket !== '0-30');

  return (
    <>
      <Toolbar>
        <SearchInput placeholder="Search txn ref, description or member…" disabled={empty} />
        <DynamicFilterBar fields={SUBLEDGER_ENTRY_FILTER_FIELDS} disabled={empty} />
      </Toolbar>
      <Card>
        <CardHead
          title="Vendor Ledger Entries"
          sub="Savings/deposit postings — the member is the 'vendor' since a deposit is a liability the SACCO owes them"
        />
        {rows.length ? <SubledgerEntryTable rows={rows} /> : <EmptyState icon="🏦" title="No entries found" />}
      </Card>
      <Card>
        <CardHead title="Dormancy" sub="Active accounts bucketed by days since their last transaction" />
        {dormant.length ? (
          <TableWrap>
            <thead>
              <tr>
                <th>Account</th><th>Member</th><th>Product</th>
                <th className="num">Balance</th><th className="num">Days idle</th><th>Bucket</th>
              </tr>
            </thead>
            <tbody>
              {dormant.map((d) => (
                <tr key={d.account_id}>
                  <td className="mono"><Link href={`/savings/${d.account_id}`}>{d.account_no}</Link></td>
                  <td>{d.first_name} {d.last_name} <span className="tiny mono">({d.member_no})</span></td>
                  <td>{d.product_name}</td>
                  <td className="num"><Money cents={d.balance} /></td>
                  <td className="num">{d.days_since_last_txn}</td>
                  <td><Pill tone={d.bucket === '180+' ? 'bad' : d.bucket === '91-180' ? 'warn' : 'info'}>{d.bucket}</Pill></td>
                </tr>
              ))}
            </tbody>
          </TableWrap>
        ) : <EmptyState icon="✅" title="Nothing dormant beyond 30 days" />}
      </Card>
    </>
  );
}

async function CustomerLedgerTab({ search, filtersRaw, sortRaw }: { search: string; filtersRaw?: string; sortRaw?: string }) {
  const filters = parseFilters(filtersRaw);
  const sort = parseSort(sortRaw);
  const [rows, empty] = await Promise.all([
    listCustomerLedgerEntries({ search, filters, sort }),
    hasAnyCustomerLedgerEntries().then((any) => !any),
  ]);

  return (
    <>
      <Toolbar>
        <SearchInput placeholder="Search txn ref, description or member…" disabled={empty} />
        <DynamicFilterBar fields={SUBLEDGER_ENTRY_FILTER_FIELDS} disabled={empty} />
      </Toolbar>
      <Card>
        <CardHead
          title="Customer Ledger Entries"
          sub="Loan disbursement/repayment postings — the member is the 'customer' since a loan is a receivable owed to the SACCO"
        />
        {rows.length ? <SubledgerEntryTable rows={rows} /> : <EmptyState icon="📄" title="No entries found" />}
      </Card>
      <Card>
        <CardHead
          title="Customer Aging Report"
          sub="Loan arrears are already classified against SASRA's bands — this is that same report, not a duplicate"
        />
        <Link href="/reports/par" className="btn ghost">Open risk classification &amp; provisioning report →</Link>
      </Card>
    </>
  );
}

async function BankAccountsTab() {
  const [rows, empty, canManage, postableAccounts] = await Promise.all([
    listBankAccounts(),
    hasAnyBankAccounts().then((any) => !any),
    currentCanAction('GL_ACCOUNT_MANAGE'),
    listPostableAccounts(),
  ]);

  return (
    <>
      <Toolbar>
        <Spacer />
        {canManage ? (
          <BankAccountFormButton postableAccounts={postableAccounts} className="btn">Add bank account</BankAccountFormButton>
        ) : null}
      </Toolbar>
      <Card>
        <CardHead
          title="Bank Accounts"
          sub="Subledger masters for reconciliation — each controls its own G/L account, which a manual journal can no longer post to directly"
        />
        {rows.length ? (
          <TableWrap>
            <thead>
              <tr>
                <th>Code</th><th>Name</th><th>G/L account</th><th>Bank</th>
                <th className="num">Balance</th><th>Status</th><th />
              </tr>
            </thead>
            <tbody>
              {rows.map((b) => (
                <tr key={b.id}>
                  <td className="mono">{b.code}</td>
                  <td>{b.name}</td>
                  <td className="mono muted-cell">{b.gl_account_code} — {b.gl_account_name}</td>
                  <td>{b.bank_name || '—'}{b.account_no ? <span className="tiny mono"> · {b.account_no}</span> : null}</td>
                  <td className="num"><Money cents={b.balance} /></td>
                  <td><Pill status={b.status} /></td>
                  <td className="num">
                    <div className="inline" style={{ justifyContent: 'flex-end' }}>
                      {canManage ? <StartReconciliationButton bankAccount={b} /> : null}
                      {canManage ? (
                        <BankAccountFormButton bankAccount={b} postableAccounts={postableAccounts} className="btn sm ghost">
                          Edit
                        </BankAccountFormButton>
                      ) : null}
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </TableWrap>
        ) : <EmptyState icon="🏦" title={empty ? 'No bank accounts yet' : 'No bank accounts match'} />}
      </Card>
    </>
  );
}

async function PeriodsTab({ search, filtersRaw, sortRaw }: { search: string; filtersRaw?: string; sortRaw?: string }) {
  const filters = parseFilters(filtersRaw);
  const sort = parseSort(sortRaw);
  const [rows, empty, canClose] = await Promise.all([
    listPeriods({ search, filters, sort }),
    hasAnyPeriods().then((any) => !any),
    currentCanAction('GL_PERIOD_CLOSE'),
  ]);

  return (
    <>
      <Toolbar>
        <SearchInput placeholder="Search period…" disabled={empty} />
        <DynamicFilterBar fields={PERIOD_FILTER_FIELDS} disabled={empty} />
        <Spacer />
        <ExportButton href="/api/export/periods" params={{ q: search, filters: filtersRaw, sort: sortRaw }} disabled={!rows.length} />
      </Toolbar>
      <Card>
      <CardHead
        title="Accounting periods"
        sub="A closed period rejects every posting, including automated ones"
      />
      {rows.length ? (
      <TableWrap>
        <thead>
          <tr>
            <th><SortLink sortKey="code">Period</SortLink></th>
            <th><SortLink sortKey="start_date">From</SortLink></th>
            <th><SortLink sortKey="end_date">To</SortLink></th>
            <th><SortLink sortKey="status">Status</SortLink></th>
            <th className="num" />
          </tr>
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
      ) : <EmptyState icon="🗓" title="No periods match" sub="Try a different search or clear the filters" />}
      </Card>
    </>
  );
}
