import Link from 'next/link';
import { notFound } from 'next/navigation';
import { requireAction, currentCanAction } from '@/lib/session';
import { getShareTradingWindow, listShareFloatings } from '@/lib/shareTrading';
import { listPostableAccounts } from '@/lib/gl';
import { listActiveTransactionCharges } from '@/lib/charges';
import { formatDate, formatDateTime } from '@/lib/format';
import { Page } from '@/components/layout/page';
import { DefinitionList, EmptyState, Pill, Stat, TableWrap, Toolbar, Spacer } from '@/components/ui/primitives';
import { CollapsibleCard } from '@/components/ui/collapsible-card';
import { EditableCard } from '@/components/ui/editable-card';
import { Money } from '@/components/ui/money';
import { WindowEditForm, PublishWindowButton, RetireWindowButton, DeleteWindowButton } from '../../share-trading-actions';

export const dynamic = 'force-dynamic';

export default async function ShareTradingWindowPage({ params }: { params: Promise<{ no: string }> }) {
  const user = await requireAction('SHARE_TRADING_READ');
  const { no } = await params;
  const w = await getShareTradingWindow(no);
  if (!w) notFound();
  const [canManage, floatings] = await Promise.all([
    currentCanAction('SHARE_TRADING_WINDOW_MANAGE'),
    listShareFloatings({ view: 'all', filters: [{ field: 'window_no', operator: '=', value: no }] }),
  ]);
  const lookups = canManage ? {
    accounts: (await listPostableAccounts()).map((a) => ({ id: a.id, code: a.code, name: a.name })),
    charges: (await listActiveTransactionCharges()).map((c) => ({ id: c.id, code: c.code, description: c.description })),
  } : { accounts: [], charges: [] };

  return (
    <Page title={`${w.no} — ${w.description}`} crumb={`Share trading window · ${w.published ? 'Published' : w.status}`} user={user}>
      <Toolbar>
        <Link href="/share-trading/windows" className="btn ghost sm">← All trading windows</Link>
        <a className="btn ghost sm" href={`/print/share-market/${encodeURIComponent(w.no)}`} target="_blank" rel="noreferrer">Print market report</a>
        <Spacer />
        {canManage && !w.floatings ? <DeleteWindowButton no={w.no} className="btn ghost" /> : null}
        {canManage && !w.published ? <PublishWindowButton no={w.no} /> : null}
        {canManage && w.published ? <RetireWindowButton no={w.no} className="btn ghost" /> : null}
      </Toolbar>

      <div className="grid g4 stack-2">
        <Stat label="Par value" value={<Money cents={w.base_price} />} foot={<>reserve <Money cents={w.reserve_price} /></>} />
        <Stat label="Shares on market" value={String(w.shares_on_market)} foot={<>worth <Money cents={w.value_on_market} decimals={0} /></>} />
        <Stat label="Floatings" value={String(w.floatings)} foot="raised in this window" />
        <Stat label="Trading period" value={formatDate(w.start_date)} foot={`to ${formatDate(w.end_date)}`} />
      </div>

      <EditableCard collapsible title="Window terms" sub="Copied onto every floating when it is raised — a change here reaches only new sales"
        canEdit={canManage} form={<WindowEditForm window={w} lookups={lookups} />}>
        <div className="grid g2">
          <DefinitionList items={[
            ['Window no.', <span className="mono" key="no">{w.no}</span>],
            ['Description', w.description],
            ['Trading period', `${formatDate(w.start_date)} → ${formatDate(w.end_date)}`],
            ['Base (par) price', <Money cents={w.base_price} key="bp" />],
            ['Reserve price', <Money cents={w.reserve_price} key="rp" />],
            ['Trading charge', w.transaction_charge_code || '—'],
            ['Status', w.published ? <Pill status="ok" key="p">Published</Pill> : <Pill key="s">{w.status}</Pill>],
          ]} />
          <DefinitionList items={[
            ['Holding account', <><span className="mono">{w.holding_account_code}</span> — {w.holding_account_name}</>],
            ['Clearing account', <><span className="mono">{w.clearing_account_code}</span> — {w.clearing_account_name}</>],
            ['Share life', w.share_life || '30D (default)'],
            ['Payment tolerance', w.tolerance_period || '—'],
            ['On no bid', w.on_no_bid],
            ['Minimum shares per floating', String(w.minimum_shares_to_float)],
            ['Created', `${w.created_by || '—'} · ${formatDateTime(w.created_at)}`],
          ]} />
        </div>
      </EditableCard>

      <CollapsibleCard title="Floatings in this window" sub={`${floatings.length} raised`}>
        {floatings.length ? (
          <TableWrap>
            <thead><tr><th>No.</th><th>Seller</th><th className="num">Shares</th><th className="num">Min. price</th><th className="num">Best bid</th><th>Stage</th><th>Status</th></tr></thead>
            <tbody>
              {floatings.map((f) => (
                <tr key={f.no}>
                  <td className="mono"><Link href={`/share-trading/view/${f.no}`}>{f.no}</Link></td>
                  <td>{f.first_name} {f.last_name} <span className="tiny mono">{f.member_no}</span></td>
                  <td className="num">{f.shares_to_float}</td>
                  <td className="num"><Money cents={f.minimum_acceptable_price} /></td>
                  <td className="num">{f.maximum_bid_price ? <Money cents={f.maximum_bid_price} /> : '—'}</td>
                  <td>{f.archived ? <Pill>{f.outcome}</Pill> : <Pill tone={f.stage === 'On Market' ? 'ok' : 'info'}>{f.stage}</Pill>}</td>
                  <td><Pill status={f.status} /></td>
                </tr>
              ))}
            </tbody>
          </TableWrap>
        ) : <EmptyState icon="📈" title="No floatings yet" />}
      </CollapsibleCard>
    </Page>
  );
}
