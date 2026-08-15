import { notFound } from 'next/navigation';
import { requireAction, currentCanAction } from '@/lib/session';
import {
  getTrialBalance, listJournals, listGlAccounts, listPeriods, listPostableAccounts, totalingBalance,
  JOURNAL_FILTER_FIELDS, GL_ACCOUNT_FILTER_FIELDS, TRIAL_BALANCE_FILTER_FIELDS, PERIOD_FILTER_FIELDS,
  GL_DIMENSION_FILTER_FIELDS,
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
import { PeriodToggle } from '../period-toggle';

const TABS: TabDefinition[] = [
  { key: 'trial-balance', label: 'Trial balance' },
  { key: 'journals', label: 'Journals' },
  { key: 'accounts', label: 'Chart of accounts' },
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
      {tab === 'periods' ? <PeriodsTab search={q} filtersRaw={filtersRaw} sortRaw={sortRaw} /> : null}
    </Page>
  );
}

async function TrialBalanceTab({ filtersRaw, asOf }: { filtersRaw?: string; asOf?: string }) {
  const filters = parseFilters(filtersRaw);
  const [{ rows, totals, balanced }, gd1Values, gd2Values, { caption1, caption2 }] = await Promise.all([
    getTrialBalance({ asOf: asOf || null, filters }),
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
        <DynamicFilterBar fields={tbFields} />
        <DateFilterInput paramName="asOf" label="As of" placeholder="As of" />
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
                  <b>{r.debit_balance ? <LedgerLink code={r.code}><Money cents={r.debit_balance} symbol={false} /></LedgerLink> : ''}</b>
                </td>
                <td className="num">
                  <b>{r.credit_balance ? <LedgerLink code={r.code}><Money cents={r.credit_balance} symbol={false} /></LedgerLink> : ''}</b>
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
  const [rows, canCreate, canReverse, postableAccounts, gd1Values, gd2Values, { caption1, caption2 }] =
    await Promise.all([
      listJournals({ search, filters, sort }),
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
        <SearchInput placeholder="Search journal number, description or reference…" />
        <DynamicFilterBar fields={journalFields} />
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
  const [rows, canManage, { rows: tbRows }, gd1Values, gd2Values, { caption1, caption2 }] = await Promise.all([
    listGlAccounts({ search, filters, sort }),
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
        <SearchInput placeholder="Search code or name…" />
        <DynamicFilterBar fields={accountFields} />
        <DateFilterInput paramName="asOf" label="As of" placeholder="As of" />
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
                        <LedgerLink code={a.code}><Money cents={balance ?? 0} /></LedgerLink>
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

async function PeriodsTab({ search, filtersRaw, sortRaw }: { search: string; filtersRaw?: string; sortRaw?: string }) {
  const filters = parseFilters(filtersRaw);
  const sort = parseSort(sortRaw);
  const [rows, canClose] = await Promise.all([
    listPeriods({ search, filters, sort }), currentCanAction('GL_PERIOD_CLOSE'),
  ]);

  return (
    <>
      <Toolbar>
        <SearchInput placeholder="Search period…" />
        <DynamicFilterBar fields={PERIOD_FILTER_FIELDS} />
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
