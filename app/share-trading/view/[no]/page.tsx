import Link from 'next/link';
import { notFound } from 'next/navigation';
import { requireAction, currentCanAction } from '@/lib/session';
import {
  getShareFloatingDetail, getAdjacentShareFloatingNos, listShareFloatingJournals, listShareTradingWindows,
  type ShareFloatingListView,
} from '@/lib/shareTrading';
import { listActiveMembers } from '@/lib/members';
import { listPaymentMethods } from '@/lib/receivablesSetup';
import { findPendingRoutedTask, isEligibleApprover, listWorkflowTasksForDocument } from '@/lib/workflow';
import { formatDate, formatDateTime, today } from '@/lib/format';
import { Page } from '@/components/layout/page';
import { DefinitionList, EmptyState, Pill, Stat, TableWrap, Toolbar, Spacer } from '@/components/ui/primitives';
import { CollapsibleCard } from '@/components/ui/collapsible-card';
import { EditableCard } from '@/components/ui/editable-card';
import { Money } from '@/components/ui/money';
import { DocumentActionsMenu } from '@/components/ui/document-actions';
import { CardNav } from '@/components/ui/card-nav';
import {
  EditForm, SubmitButton, CancelApprovalButton, ApproveButton, RejectButton, DelegateButton, ReopenButton, DeleteButton,
  PublishSaleButton, PlaceBidButton, WithdrawBidButton, AnalyseBidsButton, NotifyAwardButton, PostPurchaseButton,
  AllocatePaymentButton, RemoveAllocationButton, TransferSharesButton, TakeDownButton, NoBidRuleButton,
} from '../../share-trading-actions';

export const dynamic = 'force-dynamic';

const VIEWS: ShareFloatingListView[] = ['open', 'pending', 'approved', 'market', 'awarded', 'closed', 'all'];

export default async function ShareFloatingPage({ params, searchParams }: {
  params: Promise<{ no: string }>;
  searchParams: Promise<{ view?: string }>;
}) {
  const user = await requireAction('SHARE_TRADING_READ');
  const { no } = await params;
  const { view: viewRaw } = await searchParams;
  const view = VIEWS.includes(viewRaw as ShareFloatingListView) ? (viewRaw as ShareFloatingListView) : undefined;

  const f = await getShareFloatingDetail(no);
  if (!f) notFound();

  const [canCreate, canApprove, canBid, canProcess, tasks, { prevNo, nextNo }, journals] = await Promise.all([
    currentCanAction('SHARE_TRADING_CREATE'), currentCanAction('SHARE_TRADING_APPROVE'),
    currentCanAction('SHARE_TRADING_BID'), currentCanAction('SHARE_TRADING_PROCESS'),
    listWorkflowTasksForDocument('SHARE_FLOATING', no), getAdjacentShareFloatingNos(no, view), listShareFloatingJournals(no),
  ]);

  const isOwn = f.created_by === user.username;
  const isOpen = f.status === 'Open';
  const onMarket = f.published && !f.awarded && !f.archived;
  const awaitingTransfer = f.awarded && !f.archived;
  const expired = onMarket && !!f.expiry_date && f.expiry_date < today();
  const winner = f.bid_lines.find((b) => b.awarded) ?? null;
  const paidInFull = f.payment_amount > 0 && f.allocated_amount === f.payment_amount;

  const routedTask = f.status === 'Pending Approval' ? await findPendingRoutedTask('SHARE_FLOATING', no) : null;
  const canDecideThis = routedTask ? await isEligibleApprover(routedTask, user.id) : canApprove;
  const requestedBy = routedTask?.requested_by ?? f.created_by;
  const canCancelThis = canCreate && requestedBy === user.username;
  const pendingWith = tasks.find((t) => t.status === 'PENDING')?.pending_with;
  const q = view ? `?view=${view}` : '';

  const needsMembers = (isOpen && canCreate && isOwn) || (onMarket && canBid);
  const [members, windows, payMethods] = needsMembers
    ? await Promise.all([listActiveMembers(), listShareTradingWindows(), listPaymentMethods()])
    : [[], [], []];
  const lookups = {
    members,
    windows: windows.map((w) => ({ no: w.no, description: w.description, base_price: w.base_price, reserve_price: w.reserve_price, published: w.published })),
    payMethods: payMethods.map((m) => ({ code: m.code, description: m.description })),
  };

  return (
    <>
      <CardNav prevHref={prevNo ? `/share-trading/view/${prevNo}${q}` : null} nextHref={nextNo ? `/share-trading/view/${nextNo}${q}` : null} />
      <Page
        title={`${f.no} — Share Floating`}
        crumb={`${f.archived ? f.outcome : f.stage} · ${f.first_name} ${f.last_name} · ${f.shares_to_float} shares${pendingWith ? ` · pending with ${pendingWith}` : ''}`}
        user={user}
      >
        <Toolbar>
          <Link href="/share-trading" className="btn ghost sm">← All floatings</Link>
          <Link href={`/members/${f.member_id}`} className="btn ghost sm">Seller</Link>
          {f.outcome === 'Transferred' ? (
            <a className="btn ghost sm" href={`/print/share-transfer/${encodeURIComponent(f.no)}`} target="_blank" rel="noreferrer">Print transfer certificate</a>
          ) : null}
          <Spacer />
          {isOpen && canCreate && isOwn ? <DeleteButton no={f.no} className="btn ghost" /> : null}
          {isOpen && canCreate && isOwn ? <SubmitButton no={f.no} className="btn ghost" /> : null}
          {f.status === 'Pending Approval' && canCancelThis ? <CancelApprovalButton no={f.no} className="btn ghost" /> : null}
          {f.status === 'Pending Approval' && canDecideThis ? (
            <>
              {routedTask ? <DelegateButton taskId={routedTask.id} className="btn ghost" /> : null}
              <ApproveButton no={f.no} />
              <RejectButton no={f.no} className="btn ghost" />
            </>
          ) : null}
          {f.status === 'Approved' && !f.published && !f.archived && canApprove ? <ReopenButton no={f.no} className="btn ghost" /> : null}
          {f.status === 'Approved' && !f.published && !f.archived && canProcess ? <PublishSaleButton no={f.no} /> : null}
          {onMarket && canBid && !expired ? <PlaceBidButton floating={f} members={members} className="btn ghost" /> : null}
          {onMarket && canProcess && f.bids > 0 ? <AnalyseBidsButton no={f.no} className="btn ghost" /> : null}
          {onMarket && canProcess && winner ? <NotifyAwardButton no={f.no} className="btn ghost" /> : null}
          {onMarket && canProcess && winner ? <PostPurchaseButton no={f.no} /> : null}
          {onMarket && canProcess && expired && f.bids === 0 ? <NoBidRuleButton no={f.no} rule={f.on_no_bid} className="btn ghost" /> : null}
          {onMarket && canProcess ? <TakeDownButton no={f.no} className="btn ghost" /> : null}
          {awaitingTransfer && canProcess && winner ? <NotifyAwardButton no={f.no} className="btn ghost" /> : null}
          {awaitingTransfer && canProcess && winner && !paidInFull ? <AllocatePaymentButton floating={f} buyerMemberId={winner.member_id} className="btn ghost" /> : null}
          {awaitingTransfer && canProcess && paidInFull ? <TransferSharesButton no={f.no} /> : null}
          <DocumentActionsMenu />
        </Toolbar>

        <div className="grid g4 stack-2">
          <Stat label="Shares floated" value={String(f.shares_to_float)} foot={`${f.float_type} · of ${f.total_shares} held`} />
          <Stat label="Floated value" value={<Money cents={f.floated_value} decimals={0} />} foot={<>at par <Money cents={f.par_value} /></>} />
          <Stat label="Best bid" value={f.maximum_bid_price ? <Money cents={f.maximum_bid_price} /> : '—'}
            foot={<>{f.bids} bid{f.bids === 1 ? '' : 's'} · asking from <Money cents={f.minimum_acceptable_price} /></>} />
          <Stat label={f.awarded ? 'Payment' : 'Expires'}
            value={f.awarded ? <><Money cents={f.allocated_amount} decimals={0} /> / <Money cents={f.payment_amount} decimals={0} /></> : (f.expiry_date ? formatDate(f.expiry_date) : '—')}
            foot={f.awarded ? (f.payment_due_date ? `due ${formatDate(f.payment_due_date)}` : 'allocated / due') : (expired ? 'Expired — apply the no-bid rule' : f.published_on ? `published ${formatDate(f.published_on)}` : 'not yet published')} />
        </div>

        <EditableCard collapsible title="Floating details" sub="What is for sale, on what terms, and where the proceeds go"
          canEdit={isOpen && canCreate && isOwn} form={<EditForm floating={f} lookups={lookups} />}>
          <div className="grid g2">
            <DefinitionList items={[
              ['Floating no.', <span className="mono" key="no">{f.no}</span>],
              ['Trading window', <><span className="mono">{f.window_no}</span> — {f.window_description}</>],
              ['Seller', <>{f.first_name} {f.last_name} <span className="mono">({f.member_no})</span></>],
              ['Share account', <><span className="mono">{f.share_account_no}</span> — {f.share_product_name}</>],
              ['Float type', f.float_type],
              ['Shares held / floated', `${f.total_shares} / ${f.shares_to_float}`],
              ['Par value per share', <Money cents={f.par_value} key="pv" />],
              ['Reserve price', <Money cents={f.reserve_price} key="rp" />],
              ['Minimum acceptable price', <Money cents={f.minimum_acceptable_price} key="mp" />],
              ['Floated value', <Money cents={f.floated_value} key="fv" />],
              ['Trading charge (buyer)', <Money cents={f.charge_amount} key="ch" />],
            ]} />
            <DefinitionList items={[
              ['Stage', f.archived ? <Pill key="o">{f.outcome}</Pill> : <Pill key="s" tone={f.stage === 'On Market' ? 'ok' : f.stage === 'Awarded' ? 'warn' : 'info'}>{f.stage}</Pill>],
              ['Status', <Pill status={f.status} key="st" />],
              f.decision_reason ? ['Decision reason', f.decision_reason] : null,
              ['Proceeds to', `${f.proceeds_type}${f.proceeds_account_no ? ` — ${f.proceeds_account_no} (${f.proceeds_product_name})` : ' (first account of the type)'}`],
              ['Share life / tolerance', `${f.share_life || '30D'} / ${f.tolerance_period || '—'}`],
              ['On no bid', f.on_no_bid],
              ['Published on', f.published_on ? formatDate(f.published_on) : '—'],
              ['Bidding closes', f.expiry_date ? formatDate(f.expiry_date) : '—'],
              ['Purchase posted', f.purchase_date ? formatDate(f.purchase_date) : '—'],
              ['Payment due', f.payment_due_date ? formatDate(f.payment_due_date) : '—'],
              ['Payment method / ref.', `${f.payment_method_code || '—'} / ${f.external_reference_no || '—'}`],
              ['Source', f.source],
              ['Narration', f.narration || '—'],
            ]} />
          </div>
        </EditableCard>

        <CollapsibleCard title="Bids" sub={`${f.bids} bid${f.bids === 1 ? '' : 's'} · highest wins, earliest on a tie`}>
          {f.bid_lines.length ? (
            <TableWrap>
              <thead>
                <tr><th>Bidder</th><th>Share account</th><th className="num">Bid / share</th><th className="num">Shares</th><th className="num">Charges</th><th className="num">Total</th><th>Bid on</th><th>Source</th><th /><th className="num" /></tr>
              </thead>
              <tbody>
                {f.bid_lines.map((b) => (
                  <tr key={b.id} className={b.awarded ? 'dp-strong-row' : undefined}>
                    <td><b>{b.first_name} {b.last_name}</b><div className="tiny mono">{b.member_no}</div></td>
                    <td className="mono">{b.share_account_no}</td>
                    <td className="num"><Money cents={b.bid_price} /></td>
                    <td className="num">{b.shares}</td>
                    <td className="num"><Money cents={b.charges} /></td>
                    <td className="num"><b><Money cents={b.total_amount} /></b></td>
                    <td>{formatDateTime(b.bid_date)}</td>
                    <td>{b.source}</td>
                    <td>{b.bought ? <Pill status="ok">Bought</Pill> : b.awarded ? <Pill tone="warn">Awarded</Pill> : null}</td>
                    <td className="num">{onMarket && canBid && !b.bought ? <WithdrawBidButton no={f.no} bidId={b.id} /> : null}</td>
                  </tr>
                ))}
              </tbody>
            </TableWrap>
          ) : <EmptyState icon="🙋" title={onMarket ? 'No bids yet' : 'No bids'} sub={onMarket ? 'Members may bid until the floating expires.' : undefined} />}
        </CollapsibleCard>

        {f.awarded || f.receipts.length ? (
          <CollapsibleCard title="Payment" sub={winner ? <>{winner.first_name} {winner.last_name} ({winner.member_no}) owes <Money cents={winner.total_amount} /></> : 'The buyer’s payment allocations'}>
            {f.receipts.length ? (
              <TableWrap>
                <thead><tr><th>Buyer’s account</th><th>Product</th><th className="num">Available</th><th className="num">Allocated</th><th>By</th><th className="num" /></tr></thead>
                <tbody>
                  {f.receipts.map((r) => (
                    <tr key={r.id}>
                      <td className="mono">{r.account_no}</td>
                      <td>{r.product_name}</td>
                      <td className="num"><Money cents={r.available} /></td>
                      <td className="num"><b><Money cents={r.allocated_amount} /></b></td>
                      <td className="muted-cell">{r.created_by}</td>
                      <td className="num">{awaitingTransfer && canProcess ? <RemoveAllocationButton no={f.no} id={r.id} /> : null}</td>
                    </tr>
                  ))}
                </tbody>
                <tfoot>
                  <tr><td colSpan={3}>Allocated / due</td><td className="num"><b><Money cents={f.allocated_amount} /> / <Money cents={f.payment_amount} /></b></td><td colSpan={2} /></tr>
                </tfoot>
              </TableWrap>
            ) : <EmptyState icon="💳" title="Nothing allocated yet" sub={awaitingTransfer ? 'Allocate the buyer’s payment from their deposit accounts, then transfer the shares.' : undefined} />}
          </CollapsibleCard>
        ) : null}

        <CollapsibleCard title="Journal postings" sub={`${journals.length} G/L journal${journals.length === 1 ? '' : 's'} for ${f.no}`}>
          {journals.length ? (
            <TableWrap>
              <thead><tr><th>Journal</th><th>Value date</th><th>Description</th><th className="num">Amount</th></tr></thead>
              <tbody>
                {journals.map((h) => (
                  <tr key={h.journal_no}><td className="mono">{h.journal_no}</td><td>{formatDate(h.value_date)}</td><td>{h.description || '—'}</td><td className="num"><Money cents={h.amount} /></td></tr>
                ))}
              </tbody>
            </TableWrap>
          ) : <EmptyState icon="🧾" title="Nothing posted yet" />}
        </CollapsibleCard>

        <CollapsibleCard title="Document trail" sub="Who raised this, and when">
          <DefinitionList items={[
            ['Created by', f.created_by || '—'],
            ['Created on', formatDateTime(f.created_at)],
            ['Transferred by', f.transferred_by || '—'],
            ['Transferred on', f.transferred_at ? formatDateTime(f.transferred_at) : '—'],
          ]} />
        </CollapsibleCard>

        <CollapsibleCard title="Approval details" sub={`${tasks.length} approval step${tasks.length === 1 ? '' : 's'} routed`}>
          {tasks.length ? (
            <TableWrap>
              <thead><tr><th>Sent by</th><th>Sent date</th><th>Approver</th><th>Approved on</th><th /></tr></thead>
              <tbody>
                {tasks.map((t) => (
                  <tr key={t.id}>
                    <td>{t.requested_by || '—'}</td><td>{formatDateTime(t.requested_at)}</td>
                    <td className="muted-cell">{t.decided_by || t.pending_with || '—'}</td>
                    <td>{t.decided_at ? formatDateTime(t.decided_at) : '—'}</td><td><Pill status={t.status} /></td>
                  </tr>
                ))}
              </tbody>
            </TableWrap>
          ) : <EmptyState icon="🕓" title="Not yet sent for approval" />}
        </CollapsibleCard>
      </Page>
    </>
  );
}
