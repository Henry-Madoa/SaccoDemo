import Link from 'next/link';
import { notFound } from 'next/navigation';
import { requireAction, currentCanAction } from '@/lib/session';
import {
  listDividends, hasAnyDividends, DIVIDEND_FILTER_FIELDS, type DividendView,
} from '@/lib/dividends';
import { listActiveSavingsProducts } from '@/lib/admin';
import { listPostableAccounts } from '@/lib/gl';
import { listActiveTransactionCharges } from '@/lib/charges';
import { parseFilters } from '@/lib/listFilters';
import { parseSort } from '@/lib/listSort';
import { Page } from '@/components/layout/page';
import {
  Card, EmptyState, Pill, TableWrap, Tabs, Toolbar, Spacer, type TabDefinition,
} from '@/components/ui/primitives';
import { SearchInput } from '@/components/ui/filters';
import { DynamicFilterBar } from '@/components/ui/dynamic-filter';
import { SortLink } from '@/components/ui/sort-link';
import { Money } from '@/components/ui/money';
import { NewDividendButton, SubmitButton, CancelApprovalButton, PostButton } from '../dividend-actions';

export const dynamic = 'force-dynamic';

const TABS: TabDefinition[] = [
  { key: 'open', label: 'Open', tone: 'info' },
  { key: 'pending', label: 'Pending Approval', tone: 'warn' },
  { key: 'approved', label: 'Approved', tone: 'accent' },
  { key: 'posted', label: 'Posted', tone: 'ok' },
  { key: 'all', label: 'All' },
];

export default async function DividendsPage({ params, searchParams }: {
  params: Promise<{ tab?: string[] }>;
  searchParams: Promise<{ q?: string; filters?: string; sort?: string }>;
}) {
  const user = await requireAction('DIVIDENDS_READ');
  const { tab: segments } = await params;
  const { q = '', filters: filtersRaw, sort: sortRaw } = await searchParams;
  const filters = parseFilters(filtersRaw);
  const sort = parseSort(sortRaw);

  const requested = segments?.[0];
  if (requested && !TABS.some((t) => t.key === requested)) notFound();
  const tab = (requested ?? 'open') as DividendView;

  const [rows, empty, canCreate, canPost] = await Promise.all([
    listDividends({ view: tab, search: q, filters, sort }),
    hasAnyDividends().then((any) => !any),
    currentCanAction('DIVIDENDS_CREATE'),
    currentCanAction('DIVIDENDS_POST'),
  ]);

  const options = canCreate
    ? {
      products: (await listActiveSavingsProducts()).map((p) => ({
        id: p.id, code: p.code, name: p.name, category: p.category, min_balance: Number(p.min_balance),
      })),
      accounts: (await listPostableAccounts()).map((a) => ({ id: a.id, code: a.code, name: a.name })),
      charges: (await listActiveTransactionCharges()).map((c) => ({ id: c.id, code: c.code, description: c.description })),
    }
    : { products: [], accounts: [], charges: [] };

  return (
    <Page title="Dividends" crumb="Declare and pay the annual dividend on member savings and share capital" user={user}>
      <Tabs tabs={TABS} active={tab} hrefFor={(k) => `/dividends/${k}`} />
      <Toolbar>
        <SearchInput placeholder="Search dividend no. or description…" disabled={empty} />
        <DynamicFilterBar fields={DIVIDEND_FILTER_FIELDS} disabled={empty} />
        <Spacer />
        {canCreate ? <NewDividendButton options={options} /> : null}
      </Toolbar>

      <Card>
        {rows.length ? (
          <TableWrap>
            <thead>
              <tr>
                <th><SortLink sortKey="no">No.</SortLink></th>
                <th><SortLink sortKey="description">Description</SortLink></th>
                <th><SortLink sortKey="dividend_year">Year</SortLink></th>
                <th>Book</th>
                <th>Posting type</th>
                <th className="num">Accounts</th>
                <th className="num">Earned</th>
                <th className="num">Net payable</th>
                <th><SortLink sortKey="posting_date">Posting date</SortLink></th>
                <th><SortLink sortKey="status">Status</SortLink></th>
                <th className="num" />
              </tr>
            </thead>
            <tbody>
              {rows.map((d) => {
                const isOwn = d.created_by === user.username;
                return (
                  <tr key={d.no}>
                    <td className="mono"><Link href={`/dividends/view/${d.no}?view=${tab}`}>{d.no}</Link></td>
                    <td>
                      <b>{d.description}</b>
                      {d.calculated_at ? null : <div className="tiny muted-cell">Not yet calculated</div>}
                    </td>
                    <td>{d.dividend_year}</td>
                    <td>{d.document_type}</td>
                    <td>{d.posting_type}</td>
                    <td className="num">{Number(d.line_count).toLocaleString()}</td>
                    <td className="num"><Money cents={d.total_earned} /></td>
                    <td className="num"><Money cents={d.total_net} /></td>
                    <td>{d.posting_date}</td>
                    <td><Pill status={Number(d.posted) ? 'Posted' : d.status} /></td>
                    <td className="num">
                      <div className="inline" style={{ justifyContent: 'flex-end' }}>
                        {d.status === 'Open' && canCreate && isOwn && d.calculated_at ? <SubmitButton no={d.no} /> : null}
                        {d.status === 'Pending Approval' && canCreate && isOwn ? <CancelApprovalButton no={d.no} /> : null}
                        {d.status === 'Approved' && !Number(d.posted) && canPost
                          ? <PostButton no={d.no} postingType={d.posting_type} />
                          : null}
                      </div>
                    </td>
                  </tr>
                );
              })}
            </tbody>
          </TableWrap>
        ) : (
          <EmptyState icon="💰" title="No dividends here"
            sub="A dividend declares a rate on each savings product, works out what every member account earned month by month, recovers charges and loans, and pays the balance over." />
        )}
      </Card>
    </Page>
  );
}
