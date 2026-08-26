import Link from 'next/link';
import { notFound } from 'next/navigation';
import { requireAction, currentCanAction } from '@/lib/session';
import {
  getMemberExit, getAdjacentMemberExitNos, listMemberExitLines, eligibleMembersForExit, type MemberExitView,
} from '@/lib/memberExits';
import { findPendingRoutedTask, isEligibleApprover, listWorkflowTasksForDocument } from '@/lib/workflow';
import { getOrg } from '@/lib/org';
import { formatDate, formatDateTime, humanise } from '@/lib/format';
import { Page } from '@/components/layout/page';
import {
  DefinitionList, EmptyState, Pill, Stat, TableWrap, Toolbar, Spacer,
} from '@/components/ui/primitives';
import { CollapsibleCard } from '@/components/ui/collapsible-card';
import { Money } from '@/components/ui/money';
import {
  EditButton, SubmitButton, CancelApprovalButton, ApproveButton, RejectButton, DelegateButton,
  ReopenButton, ProcessButton, RefreshLinesButton,
} from '../../member-exit-actions';
import { CardNav } from '@/components/ui/card-nav';
import { DocumentActionsMenu } from '@/components/ui/document-actions';
import type { Tone } from '@/lib/format';

const VIEWS: MemberExitView[] = ['open', 'pending', 'approved', 'processed'];

const ENTRY_TONE: Record<string, Tone> = { ASSET: 'ok', LIABILITY: 'bad', GUARANTEE: 'warn' };

export default async function MemberExitDetailPage({ params, searchParams }: {
  params: Promise<{ no: string }>;
  searchParams: Promise<{ view?: string }>;
}) {
  const user = await requireAction('MEMBER_EXITS_READ');
  const { no } = await params;
  const { view: viewRaw } = await searchParams;
  const view = VIEWS.includes(viewRaw as MemberExitView) ? (viewRaw as MemberExitView) : undefined;
  const exit = await getMemberExit(no);
  if (!exit) notFound();

  const [canCreate, canApprove, tasks, { prevNo, nextNo }, lines, eligibleMembers, org] = await Promise.all([
    currentCanAction('MEMBER_EXITS_CREATE'), currentCanAction('MEMBER_EXITS_APPROVE'),
    listWorkflowTasksForDocument('MEMBER_EXIT', no),
    getAdjacentMemberExitNos(no, view),
    listMemberExitLines(no),
    eligibleMembersForExit(no),
    getOrg(),
  ]);

  const isOpen = exit.status === 'Open';
  const isOwnRequest = exit.created_by === user.username;
  const canEditThis = canCreate && (!canApprove || isOwnRequest);

  const routedTask = exit.status === 'Pending Approval'
    ? await findPendingRoutedTask('MEMBER_EXIT', no)
    : null;
  const canDecideThis = routedTask ? await isEligibleApprover(routedTask, user.id) : canApprove;
  const requestedBy = routedTask?.requested_by ?? exit.created_by;
  const canCancelThis = canCreate && requestedBy === user.username;
  const processed = exit.status === 'Processed';
  const pendingWith = tasks.find((t) => t.status === 'PENDING')?.pending_with;
  const canEditFields = isOpen && canEditThis;

  return (
    <>
      <CardNav
        prevHref={prevNo ? `/member-exits/view/${prevNo}${view ? `?view=${view}` : ''}` : null}
        nextHref={nextNo ? `/member-exits/view/${nextNo}${view ? `?view=${view}` : ''}` : null}
      />
      <Page
        title={`Member exit ${exit.no}`}
        crumb={`${exit.member_first_name} ${exit.member_last_name} · ${exit.status}${pendingWith ? ` · pending with ${pendingWith}` : ''}`}
        user={user}
      >
      <Toolbar>
        <Link href="/member-exits" className="btn ghost sm">← All member exits</Link>
        <Link href={`/members/${exit.member_id}`} className="btn ghost sm">View member</Link>
        <Spacer />
        {canEditFields ? <RefreshLinesButton no={exit.no} className="btn ghost" /> : null}
        {canEditFields ? (
          <EditButton exit={exit} members={eligibleMembers} instantWithdrawalChargeId={org?.instant_withdrawal_charge_id} className="btn ghost" />
        ) : null}
        {canEditFields ? <SubmitButton no={exit.no} className="btn ghost" /> : null}
        {exit.status === 'Pending Approval' && canCancelThis ? (
          <CancelApprovalButton no={exit.no} className="btn ghost" />
        ) : null}
        {exit.status === 'Pending Approval' && canDecideThis ? (
          <>
            {routedTask ? <DelegateButton taskId={routedTask.id} className="btn ghost" /> : null}
            <ApproveButton no={exit.no} />
            <RejectButton no={exit.no} className="btn ghost" />
          </>
        ) : null}
        {exit.status === 'Approved' && canApprove ? (
          <>
            <ReopenButton no={exit.no} className="btn ghost" />
            <ProcessButton no={exit.no} />
          </>
        ) : null}
        <DocumentActionsMenu />
      </Toolbar>

      <div className="grid g4 stack-2">
        <Stat label="Total assets" value={<Money cents={exit.total_assets} decimals={0} />}
          foot="Excludes share capital" />
        <Stat label="Liabilities" value={<Money cents={exit.liabilities} decimals={0} />} />
        <Stat label="Guarantees"
          value={<span className={exit.guarantees ? 'neg' : undefined}><Money cents={exit.guarantees} decimals={0} /></span>}
          foot={exit.guarantees ? 'Must be cleared before approval' : 'Clear to proceed'} />
        <Stat label="Net amount" value={<Money cents={exit.net_amount} decimals={0} />} />
      </div>

      <div className="grid g2">
        <CollapsibleCard title="Member exit details">
          <DefinitionList items={[
            ['No.', <span className="mono" key="no">{exit.no}</span>],
            ['Member', <Link href={`/members/${exit.member_id}`} key="m">{exit.member_first_name} {exit.member_last_name} <span className="mono">({exit.member_no})</span></Link>],
            ['Exit type', humanise(exit.exit_type)],
            ['Payout method', humanise(exit.payout_method)],
            ['Charge code', exit.transaction_charge_code ? `${exit.transaction_charge_code} — ${exit.transaction_charge_description}` : '—'],
            exit.is_instant ? ['Instant withdrawal', <Pill tone="warn" key="instant">YES — skips notice period</Pill>] : null,
            ['Exit date', exit.exit_date ? formatDate(exit.exit_date) : '—'],
            ['Maturity date', exit.is_instant ? 'N/A — instant' : exit.maturity_date ? formatDate(exit.maturity_date) : '—'],
            ['Reason', exit.reason || '—'],
            exit.decision_reason ? ['Decision reason', exit.decision_reason] : null,
          ]} />
        </CollapsibleCard>

        <CollapsibleCard title="Document trail" sub="Who requested and processed this exit, and when">
          <DefinitionList items={[
            ['Created by', exit.created_by || '—'],
            ['Created on', formatDateTime(exit.created_at)],
            ['Processed', processed
              ? <Pill tone="ok" key="processed">YES — accounts settled and closed</Pill>
              : <Pill tone="warn" key="processed">NOT YET</Pill>],
            processed ? ['Processed by', exit.processed_by || '—'] : null,
            processed ? ['Processed on', formatDateTime(exit.processed_at)] : null,
          ]} />
        </CollapsibleCard>
      </div>

      <CollapsibleCard
        title="Lines"
        sub={isOpen ? 'Snapshotted from the member’s current accounts, loans and guarantees' : 'Snapshotted when this document was opened or last refreshed'}
      >
        {lines.length ? (
          <TableWrap>
            <thead>
              <tr>
                <th>Type</th><th>Account</th><th className="num">Balance</th><th className="num">Amount</th><th>Share capital</th>
              </tr>
            </thead>
            <tbody>
              {lines.map((l) => (
                <tr key={l.id}>
                  <td><Pill tone={ENTRY_TONE[l.entry_type]}>{humanise(l.entry_type)}</Pill></td>
                  <td>
                    {l.savings_account_id ? (
                      <Link href={`/savings/${l.savings_account_id}`} className="mono">{l.account_no}</Link>
                    ) : l.loan_id ? (
                      <Link href={`/loans/view/${l.loan_id}`} className="mono">{l.account_no}</Link>
                    ) : '—'}
                    {l.account_name ? <div className="tiny">{l.account_name}</div> : null}
                  </td>
                  <td className="num"><Money cents={l.balance} decimals={0} /></td>
                  <td className="num"><Money cents={l.amount} decimals={0} /></td>
                  <td>{l.is_share_capital ? <Pill tone="info">Yes</Pill> : '—'}</td>
                </tr>
              ))}
            </tbody>
          </TableWrap>
        ) : <EmptyState icon="🧾" title="No lines" sub={canEditFields ? 'Refresh lines to populate from the member’s current position.' : undefined} />}
      </CollapsibleCard>

      <CollapsibleCard
        title="Approval details"
        sub={`${tasks.length} approval step${tasks.length === 1 ? '' : 's'} routed`}
      >
        {tasks.length ? (
          <TableWrap>
            <thead>
              <tr><th>Sent by</th><th>Sent date</th><th>Approver</th><th>Approved on</th><th /></tr>
            </thead>
            <tbody>
              {tasks.flatMap((t) => [
                ...t.level_decisions.map((ld, i) => (
                  <tr key={`${t.id}-level-${i}`} className="muted">
                    <td>—</td>
                    <td>—</td>
                    <td className="muted-cell">
                      Level {ld.sequence}: {ld.decided_by}
                      {ld.comment ? ` — "${ld.comment}"` : ''}
                    </td>
                    <td>{formatDateTime(ld.decided_at)}</td>
                    <td><Pill tone="ok">CLEARED</Pill></td>
                  </tr>
                )),
                <tr key={t.id}>
                  <td>{t.requested_by || '—'}</td>
                  <td>{formatDateTime(t.requested_at)}</td>
                  <td className="muted-cell">{t.decided_by || t.pending_with || '—'}</td>
                  <td>{t.decided_at ? formatDateTime(t.decided_at) : '—'}</td>
                  <td><Pill status={t.status} /></td>
                </tr>,
              ])}
            </tbody>
          </TableWrap>
        ) : <EmptyState icon="🕓" title="Not yet sent for approval" />}
      </CollapsibleCard>
      </Page>
    </>
  );
}
