import Link from 'next/link';
import { notFound } from 'next/navigation';
import { requireAction, currentCanAction } from '@/lib/session';
import {
  getDividend, getAdjacentDividendNos, listDividendLines, listDividendEarnedEntries,
  type DividendView,
} from '@/lib/dividends';
import { listActiveSavingsProducts } from '@/lib/admin';
import { listPostableAccounts } from '@/lib/gl';
import { listActiveTransactionCharges } from '@/lib/charges';
import { findPendingRoutedTask, isEligibleApprover, listWorkflowTasksForDocument } from '@/lib/workflow';
import { formatDateTime } from '@/lib/format';
import { Page } from '@/components/layout/page';
import { DefinitionList, EmptyState, Pill, TableWrap, Toolbar, Spacer } from '@/components/ui/primitives';
import { CollapsibleCard } from '@/components/ui/collapsible-card';
import { Money } from '@/components/ui/money';
import { DocumentActionsMenu } from '@/components/ui/document-actions';
import { CardNav } from '@/components/ui/card-nav';
import {
  EditDividendButton, DeleteDividendButton, EditParamsButton, CalculateButton, SubmitButton,
  CancelApprovalButton, ApproveButton, RejectButton, DelegateButton, ReopenButton, PostButton,
  EditLineButton, PrintSlipsLink,
} from '../../dividend-actions';

export const dynamic = 'force-dynamic';

const VIEWS: DividendView[] = ['all', 'open', 'pending', 'approved', 'posted'];

/** Enough of the member roll to review before approving; the printed slips carry the rest. */
const LINE_PREVIEW = 200;

export default async function DividendDetailPage({ params, searchParams }: {
  params: Promise<{ no: string }>;
  searchParams: Promise<{ view?: string; q?: string }>;
}) {
  const user = await requireAction('DIVIDENDS_READ');
  const { no } = await params;
  const { view: viewRaw, q = '' } = await searchParams;
  const view = VIEWS.includes(viewRaw as DividendView) ? (viewRaw as DividendView) : undefined;

  const dividend = await getDividend(no);
  if (!dividend) notFound();

  const [canCreate, canCalculate, canApprove, canPost, tasks, { prevNo, nextNo }, lines, uploaded] =
    await Promise.all([
      currentCanAction('DIVIDENDS_CREATE'),
      currentCanAction('DIVIDENDS_CALCULATE'),
      currentCanAction('DIVIDENDS_APPROVE'),
      currentCanAction('DIVIDENDS_POST'),
      listWorkflowTasksForDocument('DIVIDEND', no),
      getAdjacentDividendNos(no, view),
      listDividendLines(dividend.id, { search: q, onlyEarning: true, limit: LINE_PREVIEW }),
      dividend.computation_type === 'Manual Upload' ? listDividendEarnedEntries(dividend.id) : [],
    ]);

  const isOwn = dividend.created_by === user.username;
  const isOpen = dividend.status === 'Open';
  const posted = Number(dividend.posted) === 1;
  const calculated = !!dividend.calculated_at;

  const routedTask = dividend.status === 'Pending Approval' ? await findPendingRoutedTask('DIVIDEND', no) : null;
  const canDecideThis = routedTask ? await isEligibleApprover(routedTask, user.id) : canApprove;
  const requestedBy = routedTask?.requested_by ?? dividend.created_by;
  const canCancelThis = canCreate && requestedBy === user.username;
  const pendingWith = tasks.find((t) => t.status === 'PENDING')?.pending_with;
  const qs = view ? `?view=${view}` : '';

  const options = isOpen && canCreate
    ? {
      products: (await listActiveSavingsProducts()).map((p) => ({
        id: p.id, code: p.code, name: p.name, category: p.category, min_balance: Number(p.min_balance),
      })),
      accounts: (await listPostableAccounts()).map((a) => ({ id: a.id, code: a.code, name: a.name })),
      charges: (await listActiveTransactionCharges()).map((c) => ({ id: c.id, code: c.code, description: c.description })),
    }
    : { products: [], accounts: [], charges: [] };

  return (
    <>
      <CardNav
        prevHref={prevNo ? `/dividends/view/${prevNo}${qs}` : null}
        nextHref={nextNo ? `/dividends/view/${nextNo}${qs}` : null}
      />
      <Page
        title={`${dividend.no} — ${dividend.document_type} Dividend`}
        crumb={`${posted ? 'Posted' : dividend.status} · ${dividend.description}${pendingWith ? ` · pending with ${pendingWith}` : ''}`}
        user={user}
      >
        <Toolbar>
          <Link href="/dividends" className="btn ghost sm">← All dividends</Link>
          {calculated ? <PrintSlipsLink no={dividend.no} /> : null}
          <Spacer />
          {isOpen && canCreate && isOwn ? <EditDividendButton dividend={dividend} options={options} /> : null}
          {isOpen && canCreate && isOwn
            ? <EditParamsButton no={dividend.no} params={dividend.params} products={options.products} />
            : null}
          {isOpen && canCalculate && dividend.params.length
            ? <CalculateButton no={dividend.no} recalculating={calculated} />
            : null}
          {isOpen && canCreate && isOwn ? <DeleteDividendButton no={dividend.no} /> : null}
          {isOpen && canCreate && isOwn && calculated ? <SubmitButton no={dividend.no} className="btn ghost" /> : null}
          {dividend.status === 'Pending Approval' && canCancelThis
            ? <CancelApprovalButton no={dividend.no} className="btn ghost" />
            : null}
          {dividend.status === 'Pending Approval' && canDecideThis ? (
            <>
              {routedTask ? <DelegateButton taskId={routedTask.id} className="btn ghost" /> : null}
              <ApproveButton no={dividend.no} />
              <RejectButton no={dividend.no} className="btn ghost" />
            </>
          ) : null}
          {dividend.status === 'Approved' && !posted && canApprove ? <ReopenButton no={dividend.no} className="btn ghost" /> : null}
          {dividend.status === 'Approved' && !posted && canPost
            ? <PostButton no={dividend.no} postingType={dividend.posting_type} />
            : null}
          <DocumentActionsMenu />
        </Toolbar>

        <CollapsibleCard title="Declaration" sub="The period, the book and where it posts">
          <div className="grid g2">
            <DefinitionList items={[
              ['Dividend no.', <span className="mono" key="no">{dividend.no}</span>],
              ['Description', dividend.description],
              ['Posting description', dividend.posting_description || '—'],
              ['Book', dividend.document_type === 'FOSA' ? 'FOSA — interest on savings' : 'BOSA — dividend on deposits'],
              ['Year', String(dividend.dividend_year)],
              ['Period', `${dividend.start_date} → ${dividend.end_date}`],
              ['Posting date', dividend.posting_date],
              ['Status', <Pill status={posted ? 'Posted' : dividend.status} key="st" />],
              dividend.decision_reason ? ['Decision reason', dividend.decision_reason] : null,
            ]} />
            <DefinitionList items={[
              ['Posting type', dividend.posting_type],
              ['Computation', dividend.computation_type],
              ['Recover loans', Number(dividend.recover_loans) ? 'Yes' : 'No'],
              ['Boost to minimum share capital', Number(dividend.boost_to_minimum) ? 'Yes' : 'No'],
              ['Maximum boost', dividend.maximum_boost_amount
                ? <Money cents={dividend.maximum_boost_amount} key="mb" />
                : 'No ceiling'],
              ['Preferential boost allowed', Number(dividend.preferential_boost) ? 'Yes' : 'No'],
              ['Calculated', dividend.calculated_at ? formatDateTime(dividend.calculated_at) : 'Not yet'],
              dividend.journal_no ? ['Journal', <span className="mono" key="j">{dividend.journal_no}</span>] : null,
            ]} />
          </div>
        </CollapsibleCard>

        <CollapsibleCard
          title="Rates"
          sub={`${dividend.params.length} product${dividend.params.length === 1 ? '' : 's'} participating`}
        >
          {dividend.params.length ? (
            <TableWrap>
              <thead>
                <tr>
                  <th>Product</th><th>Posting description</th><th className="num">Rate</th>
                  <th>Rate type</th><th>Post to</th><th className="num">Min. balance</th>
                  <th className="num">Balances</th><th className="num">Calculated</th>
                </tr>
              </thead>
              <tbody>
                {dividend.params.map((p) => (
                  <tr key={p.id}>
                    <td><b>{p.product_code}</b> <span className="tiny muted-cell">{p.product_name}</span></td>
                    <td>{p.posting_description}</td>
                    <td className="num">{p.rate}%</td>
                    <td>{p.rate_type}</td>
                    <td>{p.post_to}</td>
                    <td className="num"><Money cents={p.minimum_balance} /></td>
                    <td className="num"><Money cents={p.account_balances} /></td>
                    <td className="num"><Money cents={p.calculated_amount} /></td>
                  </tr>
                ))}
              </tbody>
            </TableWrap>
          ) : (
            <EmptyState icon="📊" title="No rates set yet"
              sub="Add a row per savings product the dividend is declared on, each with its own rate, before calculating." />
          )}
        </CollapsibleCard>

        <CollapsibleCard
          title="Member lines"
          sub={calculated
            ? `${Number(dividend.line_count).toLocaleString()} accounts · earned ${''}`
            : 'Calculate the dividend to work these out'}
        >
          {lines.length ? (
            <>
              <TableWrap>
                <thead>
                  <tr>
                    <th>Member</th><th>Account</th><th>Product</th>
                    <th className="num">Balance</th><th className="num">Earned</th>
                    <th className="num">Recovered</th><th className="num">Net payable</th>
                    <th>Paid to</th><th className="num" />
                  </tr>
                </thead>
                <tbody>
                  {lines.map((l) => (
                    <tr key={l.id}>
                      <td>
                        <b>{l.member_name}</b>
                        <div className="tiny mono">{l.member_no}</div>
                      </td>
                      <td className="mono">{l.account_no}</td>
                      <td>{l.product_code}</td>
                      <td className="num"><Money cents={l.account_balance} /></td>
                      <td className="num"><Money cents={l.amount_earned} /></td>
                      <td className="num"><Money cents={Math.abs(l.total_recoveries)} /></td>
                      <td className="num"><b><Money cents={l.net_amount} /></b></td>
                      <td className="mono tiny">{l.destination_account_no || 'Accrued'}</td>
                      <td className="num">
                        <div className="inline" style={{ justifyContent: 'flex-end' }}>
                          <Link href={`/print/dividend-slip/${encodeURIComponent(`${dividend.no}:${l.id}`)}`}
                            target="_blank" className="btn sm ghost">Slip</Link>
                          {isOpen && canCalculate ? <EditLineButton no={dividend.no} line={l} /> : null}
                        </div>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </TableWrap>
              {lines.length >= LINE_PREVIEW ? (
                <div className="note">
                  Showing the first {LINE_PREVIEW.toLocaleString()} earning accounts of{' '}
                  {Number(dividend.line_count).toLocaleString()}. Print the dividend slips for the full run.
                </div>
              ) : null}
            </>
          ) : (
            <EmptyState icon="👥" title={calculated ? 'No account earned anything' : 'Not yet calculated'}
              sub={calculated
                ? 'Every participating account fell below its product’s minimum balance, or the rate is zero.'
                : 'Set the rates, then run Calculate to work out what each member account earned.'} />
          )}
        </CollapsibleCard>

        {dividend.computation_type === 'Manual Upload' ? (
          <CollapsibleCard title="Uploaded amounts" sub={`${uploaded.length} account${uploaded.length === 1 ? '' : 's'}`}>
            {uploaded.length ? (
              <TableWrap>
                <thead><tr><th>Member</th><th>Account</th><th>Description</th><th className="num">Amount</th></tr></thead>
                <tbody>
                  {uploaded.map((e) => (
                    <tr key={e.id}>
                      <td>{e.member_name} <span className="tiny mono">{e.member_no}</span></td>
                      <td className="mono">{e.account_no}</td>
                      <td>{e.description || '—'}</td>
                      <td className="num"><Money cents={e.amount} /></td>
                    </tr>
                  ))}
                </tbody>
              </TableWrap>
            ) : <EmptyState icon="📥" title="Nothing uploaded yet" />}
          </CollapsibleCard>
        ) : null}

        <CollapsibleCard
          title="Withdrawn members"
          sub={`${dividend.withdrawn.length} member${dividend.withdrawn.length === 1 ? '' : 's'} exited during ${dividend.dividend_year}`}
        >
          {dividend.withdrawn.length ? (
            <>
              <div className="note">
                These members left during the dividend year. They are listed for review, not excluded
                automatically — whether a leaver still earns is a policy decision.
              </div>
              <TableWrap>
                <thead><tr><th>Member</th><th>Member no.</th><th>Exit no.</th><th>Matured</th></tr></thead>
                <tbody>
                  {dividend.withdrawn.map((w) => (
                    <tr key={w.id}>
                      <td>{w.member_name}</td>
                      <td className="mono">{w.member_no}</td>
                      <td className="mono">{w.exit_no || '—'}</td>
                      <td>{w.maturity_date || '—'}</td>
                    </tr>
                  ))}
                </tbody>
              </TableWrap>
            </>
          ) : <EmptyState icon="🚪" title="No member exited during this year" />}
        </CollapsibleCard>

        <CollapsibleCard title="Document trail" sub="Who raised this, and when">
          <DefinitionList items={[
            ['Created by', dividend.created_by || '—'],
            ['Created on', formatDateTime(dividend.created_at)],
            ['Posted by', dividend.posted_by || '—'],
            ['Posted on', formatDateTime(dividend.posted_at)],
          ]} />
        </CollapsibleCard>

        <CollapsibleCard title="Approval details" sub={`${tasks.length} approval step${tasks.length === 1 ? '' : 's'} routed`}>
          {tasks.length ? (
            <TableWrap>
              <thead><tr><th>Sent by</th><th>Sent date</th><th>Approver</th><th>Approved on</th><th /></tr></thead>
              <tbody>
                {tasks.map((t) => (
                  <tr key={t.id}>
                    <td>{t.requested_by || '—'}</td>
                    <td>{formatDateTime(t.requested_at)}</td>
                    <td className="muted-cell">{t.decided_by || t.pending_with || '—'}</td>
                    <td>{t.decided_at ? formatDateTime(t.decided_at) : '—'}</td>
                    <td><Pill status={t.status} /></td>
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
