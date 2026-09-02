import Link from 'next/link';
import { notFound } from 'next/navigation';
import { requireAction, currentCanAction } from '@/lib/session';
import {
  getChequeDeposit, getAdjacentChequeDepositNos, listChequeDepositHistory, listChequeInstructions,
  instructableAmount, type ChequeDepositTab,
} from '@/lib/chequeDeposits';
import { listActiveChequeTypes } from '@/lib/chequeTypes';
import { listActiveMembers } from '@/lib/members';
import { findPendingRoutedTask, isEligibleApprover, listWorkflowTasksForDocument } from '@/lib/workflow';
import { formatDateTime } from '@/lib/format';
import { Page } from '@/components/layout/page';
import {
  DefinitionList, EmptyState, Pill, TableWrap, Toolbar, Spacer,
} from '@/components/ui/primitives';
import { CollapsibleCard } from '@/components/ui/collapsible-card';
import { Money } from '@/components/ui/money';
import { DocumentActionsMenu } from '@/components/ui/document-actions';
import { CardNav } from '@/components/ui/card-nav';
import {
  EditButton, SubmitButton, CancelApprovalButton, ApproveButton, RejectButton, DelegateButton, ReopenButton,
  ClearButton, ExpressClearButton, ReleaseHoldButton, BounceButton, DeleteButton,
} from '../../cheque-deposit-actions';
import { ChequeInstructions } from '../../cheque-instructions';

const VIEWS: ChequeDepositTab[] = ['open', 'pending', 'approved', 'cleared', 'bounced'];

export default async function ChequeDepositDetailPage({ params, searchParams }: {
  params: Promise<{ no: string }>;
  searchParams: Promise<{ view?: string }>;
}) {
  const user = await requireAction('CHEQUE_DEPOSITS_READ');
  const { no } = await params;
  const { view: viewRaw } = await searchParams;
  const view = VIEWS.includes(viewRaw as ChequeDepositTab) ? (viewRaw as ChequeDepositTab) : undefined;

  const deposit = await getChequeDeposit(no);
  if (!deposit) notFound();

  const [canCreate, canApprove, canClear, tasks, { prevNo, nextNo }, history, instructions, cap] = await Promise.all([
    currentCanAction('CHEQUE_DEPOSITS_CREATE'),
    currentCanAction('CHEQUE_DEPOSITS_APPROVE'),
    currentCanAction('CHEQUE_DEPOSITS_CLEAR'),
    listWorkflowTasksForDocument('CHEQUE_DEPOSIT', no),
    getAdjacentChequeDepositNos(no, view),
    listChequeDepositHistory(no),
    listChequeInstructions(no),
    instructableAmount(deposit),
  ]);

  const isOwn = deposit.created_by === user.username;
  const isOpen = deposit.status === 'Open';
  const [editMembers, editChequeTypes] = isOpen && canCreate && isOwn
    ? await Promise.all([listActiveMembers(), listActiveChequeTypes('EXTERNAL')])
    : [[], []];

  const routedTask = deposit.status === 'Pending Approval' ? await findPendingRoutedTask('CHEQUE_DEPOSIT', no) : null;
  const canDecideThis = routedTask ? await isEligibleApprover(routedTask, user.id) : canApprove;
  const requestedBy = routedTask?.requested_by ?? deposit.created_by;
  const canCancelThis = canCreate && requestedBy === user.username;
  const pendingWith = tasks.find((t) => t.status === 'PENDING')?.pending_with;
  const q = view ? `?view=${view}` : '';
  const heldOut = deposit.status === 'Cleared' && deposit.express_hold_amount > 0;

  return (
    <>
      <CardNav
        prevHref={prevNo ? `/cheque-deposits/view/${prevNo}${q}` : null}
        nextHref={nextNo ? `/cheque-deposits/view/${nextNo}${q}` : null}
      />
      <Page
        title={`${deposit.no} — Cheque Deposit`}
        crumb={`${deposit.status} · ${deposit.member_first_name} ${deposit.member_last_name} (${deposit.member_no}) · matures ${deposit.maturity_date}${pendingWith ? ` · pending with ${pendingWith}` : ''}`}
        user={user}
      >
        <Toolbar>
          <Link href="/cheque-deposits" className="btn ghost sm">← All cheque deposits</Link>
          <Link href={`/members/${deposit.member_id}`} className="btn ghost sm">View member</Link>
          <Link href={`/cheque-deposits/view/${deposit.no}/slip`} target="_blank" className="btn ghost sm">Deposit slip</Link>
          <Spacer />
          {isOpen && canCreate && isOwn ? <EditButton deposit={deposit} members={editMembers} chequeTypes={editChequeTypes} className="btn ghost" /> : null}
          {isOpen && canCreate && isOwn ? <DeleteButton no={deposit.no} className="btn ghost" /> : null}
          {isOpen && canCreate && isOwn ? <SubmitButton no={deposit.no} className="btn ghost" /> : null}
          {deposit.status === 'Pending Approval' && canCancelThis ? <CancelApprovalButton no={deposit.no} className="btn ghost" /> : null}
          {deposit.status === 'Pending Approval' && canDecideThis ? (
            <>
              {routedTask ? <DelegateButton taskId={routedTask.id} className="btn ghost" /> : null}
              <ApproveButton no={deposit.no} />
              <RejectButton no={deposit.no} className="btn ghost" />
            </>
          ) : null}
          {deposit.status === 'Approved' && canApprove ? <ReopenButton no={deposit.no} className="btn ghost" /> : null}
          {deposit.status === 'Approved' && canClear && deposit.matured ? <ClearButton no={deposit.no} /> : null}
          {deposit.status === 'Approved' && canClear && !deposit.matured && deposit.express_cheque ? <ExpressClearButton no={deposit.no} /> : null}
          {deposit.status === 'Approved' && canClear ? <BounceButton no={deposit.no} className="btn ghost" /> : null}
          {heldOut && canClear && deposit.matured ? <ReleaseHoldButton no={deposit.no} /> : null}
          {heldOut && canClear ? <BounceButton no={deposit.no} className="btn ghost" /> : null}
          <DocumentActionsMenu />
        </Toolbar>

        <CollapsibleCard title="Cheque deposit details" sub="Banked against the member's account; clears on the maturity date">
          <div className="grid g2">
            <DefinitionList items={[
              ['Document no.', <span className="mono" key="no">{deposit.no}</span>],
              ['Type', <><span className="mono">{deposit.cheque_type_code}</span> — {deposit.description}</>],
              ['Member', <>{deposit.member_first_name} {deposit.member_last_name} <span className="mono">({deposit.member_no})</span></>],
              ['Deposit into', <><span className="mono">{deposit.account_no}</span> — {deposit.account_product_name}</>],
              ['Cheque no.', deposit.cheque_no || '—'],
              ['Cheque date', deposit.cheque_date || '—'],
              ['Deposit date', deposit.deposit_date],
              ['Maturity date', <>{deposit.maturity_date}{deposit.in_house ? ' (in-house)' : ''}</>],
              ['Express clearing', deposit.express_cheque ? 'Yes' : 'No'],
            ]} />
            <DefinitionList items={[
              ['Amount', <Money cents={deposit.amount} key="a" />],
              ['Instructed', <Money cents={deposit.instructions_total} key="it" />],
              ['Charge taken', <Money cents={deposit.charge_amount} key="c" />],
              ['Held (uncleared)', <Money cents={deposit.express_hold_amount} key="h" />],
              ['Account balance', <Money cents={deposit.account_balance} key="b" />],
              ['Clearing account', <span className="mono" key="cl">{deposit.clearing_gl_account_code}</span>],
              ['Drawer', [deposit.drawer_account_name, deposit.drawer_bank, deposit.drawer_branch].filter(Boolean).join(' · ') || '—'],
              ['Drawer account no.', deposit.drawer_account_no || '—'],
              ['Status', <Pill status={deposit.status} key="st" />],
              deposit.decision_reason ? ['Reason', deposit.decision_reason] : null,
              deposit.journal_no ? ['Journal', <span className="mono" key="j">{deposit.journal_no}</span>] : null,
            ]} />
          </div>
        </CollapsibleCard>

        <CollapsibleCard
          title="Cheque instructions"
          sub={`How the cleared funds are distributed across ${deposit.member_first_name} ${deposit.member_last_name}'s accounts and loans`}
        >
          <ChequeInstructions
            no={deposit.no}
            memberId={deposit.member_id}
            depositAccountId={deposit.savings_account_id}
            instructions={instructions}
            cap={cap}
            editable={deposit.status === 'Open' && canCreate && isOwn}
          />
        </CollapsibleCard>

        <CollapsibleCard title="Document trail" sub="Who raised and cleared this, and when">
          <DefinitionList items={[
            ['Created by', deposit.created_by || '—'],
            ['Created on', formatDateTime(deposit.created_at)],
            ['Cleared/bounced by', deposit.cleared_by || '—'],
            ['Clearance date', deposit.clearance_date || '—'],
          ]} />
        </CollapsibleCard>

        <CollapsibleCard title="Journal postings" sub={`${history.length} G/L journal${history.length === 1 ? '' : 's'} for ${deposit.no}`}>
          {history.length ? (
            <TableWrap>
              <thead><tr><th>Journal</th><th>Value date</th><th>Description</th><th className="num">Amount</th></tr></thead>
              <tbody>
                {history.map((h) => (
                  <tr key={h.journal_no}>
                    <td className="mono">{h.journal_no}</td>
                    <td>{h.value_date}</td>
                    <td>{h.description || '—'}</td>
                    <td className="num"><Money cents={h.amount} /></td>
                  </tr>
                ))}
              </tbody>
            </TableWrap>
          ) : <EmptyState icon="🧾" title="Not yet cleared" />}
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
