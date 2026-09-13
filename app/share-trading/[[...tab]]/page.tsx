import Link from 'next/link';
import { notFound } from 'next/navigation';
import { requireAction, currentCanAction } from '@/lib/session';
import {
  listShareFloatings, hasAnyShareFloatings, listShareTradingWindows, publishedShareTradingWindow,
  SHARE_FLOATING_FILTER_FIELDS, type ShareFloatingListView,
} from '@/lib/shareTrading';
import { listActiveMembers } from '@/lib/members';
import { listPostableAccounts } from '@/lib/gl';
import { listActiveTransactionCharges } from '@/lib/charges';
import { listPaymentMethods } from '@/lib/receivablesSetup';
import { parseFilters } from '@/lib/listFilters';
import { parseSort } from '@/lib/listSort';
import { formatDate, today } from '@/lib/format';
import { Page } from '@/components/layout/page';
import {
  Card, CardHead, EmptyState, Pill, TableWrap, Tabs, Toolbar, Spacer, type TabDefinition,
} from '@/components/ui/primitives';
import { SearchInput } from '@/components/ui/filters';
import { DynamicFilterBar } from '@/components/ui/dynamic-filter';
import { SortLink } from '@/components/ui/sort-link';
import { Money } from '@/components/ui/money';
import {
  NewFloatingButton, NewWindowButton, SubmitButton, CancelApprovalButton, PublishSaleButton, ProcessExpiredButton,
  PublishWindowButton, RetireWindowButton,
} from '../share-trading-actions';

export const dynamic = 'force-dynamic';

const TABS: TabDefinition[] = [
  { key: 'open', label: 'Open', tone: 'info' },
  { key: 'pending', label: 'Pending Approval', tone: 'warn' },
  { key: 'approved', label: 'Approved', tone: 'accent' },
  { key: 'market', label: 'On Market', tone: 'ok' },
  { key: 'awarded', label: 'Awarded' },
  { key: 'closed', label: 'Closed' },
  { key: 'all', label: 'All' },
  { key: 'windows', label: 'Trading Windows' },
];

const STAGE_TONE: Record<string, 'ok' | 'warn' | 'info' | undefined> = { 'On Market': 'ok', Awarded: 'warn', Draft: 'info' };

export default async function ShareTradingPage({ params, searchParams }: {
  params: Promise<{ tab?: string[] }>;
  searchParams: Promise<{ q?: string; filters?: string; sort?: string }>;
}) {
  const user = await requireAction('SHARE_TRADING_READ');
  const { tab: segments } = await params;
  const { q = '', filters: filtersRaw, sort: sortRaw } = await searchParams;
  const requested = segments?.[0];
  if (requested && !TABS.some((t) => t.key === requested)) notFound();
  const tab = requested ?? 'open';

  const [canCreate, canProcess, canManageWindows, published] = await Promise.all([
    currentCanAction('SHARE_TRADING_CREATE'), currentCanAction('SHARE_TRADING_PROCESS'),
    currentCanAction('SHARE_TRADING_WINDOW_MANAGE'), publishedShareTradingWindow(),
  ]);

  return (
    <Page title="Share Trading" crumb="Members selling share capital to one another — float, bid, award, pay, transfer" user={user}>
      <Tabs tabs={TABS} active={tab} hrefFor={(k) => `/share-trading/${k === 'open' ? '' : k}`} />
      {tab === 'windows'
        ? <WindowsTab canManage={canManageWindows} />
        : <FloatingsTab view={tab as ShareFloatingListView} search={q} filtersRaw={filtersRaw} sortRaw={sortRaw}
            username={user.username} canCreate={canCreate} canProcess={canProcess}
            publishedWindow={published ? `${published.no} — ${published.description}` : null} />}
    </Page>
  );
}

async function FloatingsTab({ view, search, filtersRaw, sortRaw, username, canCreate, canProcess, publishedWindow }: {
  view: ShareFloatingListView; search: string; filtersRaw?: string; sortRaw?: string; username: string;
  canCreate: boolean; canProcess: boolean; publishedWindow: string | null;
}) {
  const filters = parseFilters(filtersRaw);
  const sort = parseSort(sortRaw);
  const [rows, empty, members, windows, payMethods] = await Promise.all([
    listShareFloatings({ view, search, filters, sort }),
    hasAnyShareFloatings(view).then((a) => !a),
    listActiveMembers(),
    listShareTradingWindows(),
    listPaymentMethods(),
  ]);
  const fields = SHARE_FLOATING_FILTER_FIELDS.map((f) => (
    f.key === 'member_id' ? { ...f, options: members.map((m) => ({ value: m.id, label: `${m.member_no} — ${m.first_name} ${m.last_name}` })) }
      : f.key === 'window_no' ? { ...f, options: windows.map((w) => ({ value: w.no, label: `${w.no} — ${w.description}` })) }
        : f));
  const lookups = {
    members,
    windows: windows.map((w) => ({ no: w.no, description: w.description, base_price: w.base_price, reserve_price: w.reserve_price, published: w.published })),
    payMethods: payMethods.map((m) => ({ code: m.code, description: m.description })),
  };
  const expired = view === 'market' && rows.some((r) => r.expiry_date && r.expiry_date < today());

  return (
    <>
      <Toolbar>
        <SearchInput placeholder="Search floating no., seller or account…" disabled={empty} />
        <DynamicFilterBar fields={fields} disabled={empty} />
        <Spacer />
        {expired && canProcess ? <ProcessExpiredButton /> : null}
        {canCreate ? <NewFloatingButton lookups={lookups} /> : null}
      </Toolbar>
      {!publishedWindow ? (
        <div className="note" style={{ marginBottom: 'var(--sp)' }}>
          No trading window is published — new floatings need one. Set it up under <Link href="/share-trading/windows">Trading Windows</Link>.
        </div>
      ) : null}
      <Card>
        {rows.length ? (
          <TableWrap>
            <thead>
              <tr>
                <th><SortLink sortKey="no">No.</SortLink></th>
                <th><SortLink sortKey="member">Seller</SortLink></th>
                <th className="num"><SortLink sortKey="shares">Shares</SortLink></th>
                <th className="num"><SortLink sortKey="price">Min. price</SortLink></th>
                <th className="num"><SortLink sortKey="value">Floated value</SortLink></th>
                <th className="num">Bids</th>
                <th className="num">Best bid</th>
                <th><SortLink sortKey="expiry">Expires</SortLink></th>
                <th>Stage</th>
                <th><SortLink sortKey="status">Status</SortLink></th>
                <th className="num" />
              </tr>
            </thead>
            <tbody>
              {rows.map((f) => {
                const isOwn = f.created_by === username;
                const closed = f.archived;
                return (
                  <tr key={f.no}>
                    <td className="mono"><Link href={`/share-trading/view/${f.no}?view=${view}`}>{f.no}</Link></td>
                    <td><b>{f.first_name} {f.last_name}</b><div className="tiny mono">{f.member_no} · {f.share_account_no}</div></td>
                    <td className="num">{f.shares_to_float}<div className="tiny muted-cell">{f.float_type}</div></td>
                    <td className="num"><Money cents={f.minimum_acceptable_price} /></td>
                    <td className="num"><Money cents={f.floated_value} /></td>
                    <td className="num">{f.bids}</td>
                    <td className="num">{f.maximum_bid_price ? <Money cents={f.maximum_bid_price} /> : '—'}</td>
                    <td>{f.expiry_date ? formatDate(f.expiry_date) : '—'}</td>
                    <td>{closed ? <Pill>{f.outcome ?? 'Closed'}</Pill> : <Pill tone={STAGE_TONE[f.stage]}>{f.stage}</Pill>}</td>
                    <td><Pill status={f.status} /></td>
                    <td className="num">
                      <div className="inline" style={{ justifyContent: 'flex-end' }}>
                        {f.status === 'Open' && canCreate && isOwn ? <SubmitButton no={f.no} /> : null}
                        {f.status === 'Pending Approval' && canCreate && isOwn ? <CancelApprovalButton no={f.no} /> : null}
                        {f.status === 'Approved' && !f.published && !closed && canProcess ? <PublishSaleButton no={f.no} /> : null}
                      </div>
                    </td>
                  </tr>
                );
              })}
            </tbody>
          </TableWrap>
        ) : (
          <EmptyState icon="📈" title="No floatings here"
            sub="A member floats some or all of their share capital; other members bid; the highest bid buys the shares at par with the premium going to the seller." />
        )}
      </Card>
    </>
  );
}

async function WindowsTab({ canManage }: { canManage: boolean }) {
  const [windows, accounts, charges] = await Promise.all([
    listShareTradingWindows(),
    listPostableAccounts().then((rows) => rows.map((a) => ({ id: a.id, code: a.code, name: a.name }))),
    listActiveTransactionCharges().then((rows) => rows.map((c) => ({ id: c.id, code: c.code, description: c.description }))),
  ]);
  return (
    <>
      <Toolbar>
        <Spacer />
        {canManage ? <NewWindowButton lookups={{ accounts, charges }} /> : null}
      </Toolbar>
      <Card>
        <CardHead title="Trading windows" sub="The terms every sale runs on — par and reserve price, the holding and clearing accounts, the charge, how long a sale stays up and how long a buyer has to pay. One window is on the market at a time." />
        {windows.length ? (
          <TableWrap>
            <thead>
              <tr>
                <th>No.</th><th>Description</th><th>Period</th><th className="num">Par</th><th className="num">Reserve</th>
                <th className="num">Shares on market</th><th className="num">Value on market</th><th className="num">Floatings</th><th>Status</th><th className="num" />
              </tr>
            </thead>
            <tbody>
              {windows.map((w) => (
                <tr key={w.no}>
                  <td className="mono"><Link href={`/share-trading/windows/${w.no}`}>{w.no}</Link></td>
                  <td>{w.description}</td>
                  <td>{formatDate(w.start_date)} → {formatDate(w.end_date)}</td>
                  <td className="num"><Money cents={w.base_price} /></td>
                  <td className="num"><Money cents={w.reserve_price} /></td>
                  <td className="num">{w.shares_on_market}</td>
                  <td className="num"><Money cents={w.value_on_market} /></td>
                  <td className="num">{w.floatings}</td>
                  <td>{w.published ? <Pill status="ok">Published</Pill> : <Pill>{w.status}</Pill>}</td>
                  <td className="num">
                    <div className="inline" style={{ justifyContent: 'flex-end' }}>
                      {canManage && !w.published ? <PublishWindowButton no={w.no} /> : null}
                      {canManage && w.published ? <RetireWindowButton no={w.no} /> : null}
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </TableWrap>
        ) : <EmptyState icon="🪟" title="No trading windows yet" sub="Create one and publish it to open the share market." />}
      </Card>
    </>
  );
}
