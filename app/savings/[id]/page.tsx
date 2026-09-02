import Link from 'next/link';
import { notFound } from 'next/navigation';
import { requireAction, currentCanAction } from '@/lib/session';
import { statement, getAdjacentAccountIds, hasAnyTxns } from '@/lib/savings';
import { getOrgBrand, getDimensionCaptions } from '@/lib/org';
import { formatDate } from '@/lib/format';
import { imageSrc } from '@/lib/cloudinary';
import { parseSort } from '@/lib/listSort';
import { Page } from '@/components/layout/page';
import {
  Card, CardHead, DefinitionList, EmptyState, Pill, Stat, TableWrap, Toolbar, Spacer,
} from '@/components/ui/primitives';
import { DateFilterExpressionInput, SearchInput } from '@/components/ui/filters';
import { SortLink } from '@/components/ui/sort-link';
import { Money } from '@/components/ui/money';
import { DocumentActionsMenu } from '@/components/ui/document-actions';
import { CardNav } from '@/components/ui/card-nav';
import { JournalLink } from '@/app/accounting/drill-downs';
import { ReverseButton } from './reverse-button';

export default async function SavingsAccountPage({ params, searchParams }: {
  params: Promise<{ id: string }>;
  searchParams: Promise<{ from?: string; to?: string; q?: string; sort?: string }>;
}) {
  const user = await requireAction('SAVINGS_READ');
  const { id } = await params;
  const { from, to, q = '', sort: sortRaw } = await searchParams;
  const sort = parseSort(sortRaw);

  let data;
  try {
    data = await statement(Number(id), from || undefined, to || undefined);
  } catch {
    notFound();
  }

  const { account: a, opening, lines } = data;
  const [
    org, empty, canReverse, canDeactivate, canActivate, canTeller, { prevId, nextId }, { caption1, caption2 },
  ] = await Promise.all([
    getOrgBrand(),
    hasAnyTxns(a.id).then((any) => !any),
    currentCanAction('SAVINGS_REVERSE'),
    currentCanAction('ACCOUNT_DEACTIVATION_CREATE'), currentCanAction('ACCOUNT_ACTIVATION_CREATE'),
    currentCanAction('TELLER_TRANSACTIONS_CREATE'),
    getAdjacentAccountIds(a.id),
    getDimensionCaptions(),
  ]);

  const available = a.balance - a.hold_amount - a.min_balance;

  // The statement's running balance starts from the opening figure and walks
  // the period's postings, so it reconciles to the closing balance on screen.
  let running = opening;
  const rows = lines.map((t) => {
    running += t.amount;
    return { txn: t, running };
  });
  const closing = rows.length ? rows[rows.length - 1].running : opening;

  // Find Entries + sorting are applied to a display copy only — opening/closing and each
  // row's running balance stay pinned to the true chronological order computed above.
  const needle = q.trim().toLowerCase();
  const STATEMENT_SORT_KEYS: Record<string, (r: typeof rows[number]) => string | number> = {
    value_date: (r) => r.txn.value_date,
    txn_ref: (r) => r.txn.txn_ref,
    document_no: (r) => r.txn.document_no || '',
    description: (r) => r.txn.description || '',
    channel: (r) => r.txn.channel,
    gd1: (r) => r.txn.global_dimension_1_code || '',
    gd2: (r) => r.txn.global_dimension_2_code || '',
    amount: (r) => r.txn.amount,
    balance: (r) => r.running,
  };
  const displayRows = rows
    .filter(({ txn: t }) => !needle || [
      t.txn_ref, t.document_no, t.description, t.channel, t.global_dimension_1_code, t.global_dimension_2_code,
    ].some((v) => (v || '').toLowerCase().includes(needle)))
    .sort((a, b) => {
      const get = sort && STATEMENT_SORT_KEYS[sort.field];
      if (!get) return 0;
      const av = get(a); const bv = get(b);
      const cmp = av < bv ? -1 : av > bv ? 1 : 0;
      return sort!.dir === 'desc' ? -cmp : cmp;
    });

  return (
    <>
      <CardNav
        prevHref={prevId ? `/savings/${prevId}` : null}
        nextHref={nextId ? `/savings/${nextId}` : null}
      />
      <Page
        title={`Account ${a.account_no}`}
        crumb={`${a.first_name} ${a.last_name} · ${a.product_name}`}
        user={user}
      >
      <Toolbar>
        <Link href="/savings" className="btn ghost sm">← All accounts</Link>
        <Link href={`/members/${a.member_id}`} className="btn ghost sm">Member 360</Link>
        <Spacer />
        {canTeller && a.status === 'ACTIVE' ? (
          <Link href="/teller-transactions" className="btn ghost">Cash deposit / withdrawal</Link>
        ) : null}
        {canDeactivate && a.status === 'ACTIVE' ? (
          <Link href={`/account-deactivations?new=${a.member_id}`} className="btn ghost">Deactivate account</Link>
        ) : null}
        {canActivate && a.status === 'INACTIVE' ? (
          <Link href={`/account-activations?new=${a.member_id}`} className="btn ghost">Activate account</Link>
        ) : null}
      </Toolbar>

      <div className="grid g4 stack-2">
        <Stat label="Balance" value={<Money cents={a.balance} />} />
        <Stat label="Available" value={<Money cents={Math.max(available, 0)} />}
          foot="after minimum balance and holds" />
        <Stat label="Status" small value={<Pill status={a.status} />}
          foot={`opened ${formatDate(a.opened_date)}`} />
        <Stat label="Product" small value={a.product_code} foot={a.product_name} />
      </div>

      {a.is_business_account ? (
        <Card>
          <CardHead title="Business details" />
          <DefinitionList items={[
            ['Business name', a.business_name || '—'],
            ['Business location', a.business_location || '—'],
            ['Paybill / Till No.', a.business_paybill_till_no || '—'],
            ['Business phone no.', a.business_phone_no || '—'],
          ]} />
        </Card>
      ) : null}

      {a.category === 'JUNIOR ACCOUNT' ? (
        <Card>
          <CardHead title="Junior details" />
          <div className="grid split-side-sm">
            <DefinitionList items={[
              ["Junior's name", a.junior_name || '—'],
              ['Birth notification / certificate no.', a.junior_birth_cert_no || '—'],
              ['Date of birth', a.junior_date_of_birth ? formatDate(a.junior_date_of_birth) : '—'],
            ]} />
            {a.junior_photo ? (
              <img
                src={imageSrc(a.junior_photo, { width: 140, height: 140 }) ?? undefined}
                alt={a.junior_name || 'Junior profile'}
                className="photo"
                style={{ width: 140, height: 140 }}
              />
            ) : null}
          </div>
        </Card>
      ) : null}

      <Card>
        <CardHead
          title="Statement of account"
          sub={`${org!.name} · ${a.first_name} ${a.last_name} (${a.member_no}) · account ${a.account_no}`}
        />
        <Toolbar>
          <SearchInput placeholder="Find entries — reference, document no., description or channel…" disabled={empty} />
          <DateFilterExpressionInput
            fromParam="from" toParam="to" placeholder="Date filter — e.g. 01/01/26..31/12/26 or ..T" disabled={empty}
          />
          <Spacer />
          <DocumentActionsMenu
            excel={{ href: '/api/export/savings-statement', params: { id: String(a.id), from, to }, disabled: !lines.length }}
          />
        </Toolbar>
        {lines.length ? (
          <TableWrap>
            <thead>
              <tr>
                <th><SortLink sortKey="value_date">Date</SortLink></th>
                <th><SortLink sortKey="txn_ref">Reference</SortLink></th>
                <th><SortLink sortKey="document_no">Document No.</SortLink></th>
                <th><SortLink sortKey="description">Description</SortLink></th>
                <th><SortLink sortKey="channel">Channel</SortLink></th>
                <th><SortLink sortKey="gd1">{caption1}</SortLink></th>
                <th><SortLink sortKey="gd2">{caption2}</SortLink></th>
                <th className="num"><SortLink sortKey="amount">Debit</SortLink></th>
                <th className="num"><SortLink sortKey="amount">Credit</SortLink></th>
                <th className="num"><SortLink sortKey="balance">Balance</SortLink></th><th />
              </tr>
            </thead>
            <tbody>
              <tr>
                <td colSpan={9}><i>Opening balance</i></td>
                <td className="num"><b><Money cents={opening} symbol={false} /></b></td>
                <td />
              </tr>
              {displayRows.length ? displayRows.map(({ txn: t, running: bal }) => {
                const reversed = t.status === 'REVERSED';
                return (
                  <tr key={t.id} className={reversed ? 'muted' : undefined}>
                    <td>{formatDate(t.value_date)}</td>
                    <td className="mono">{t.txn_ref}</td>
                    <td className="mono">
                      {t.journal_id ? (
                        <JournalLink id={t.journal_id} canReverse={false} caption1={caption1} caption2={caption2}>
                          {t.document_no || '—'}
                        </JournalLink>
                      ) : (t.document_no || '—')}
                    </td>
                    <td>
                      {t.description || ''}
                      {reversed ? <> <Pill tone="bad">REVERSED</Pill></> : null}
                    </td>
                    <td>{t.channel}</td>
                    <td className="tiny">{t.global_dimension_1_code || '—'}</td>
                    <td className="tiny">{t.global_dimension_2_code || '—'}</td>
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
              }) : (
                <tr><td colSpan={11}><EmptyState icon="🔎" title="No entries match your search" /></td></tr>
              )}
            </tbody>
            <tfoot>
              <tr>
                <td colSpan={9}>Closing balance</td>
                <td className="num"><Money cents={closing} symbol={false} /></td>
                <td />
              </tr>
            </tfoot>
          </TableWrap>
        ) : <EmptyState icon="🧾" title="No transactions on this account" />}
      </Card>
      </Page>
    </>
  );
}
