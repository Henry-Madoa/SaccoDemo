import Link from 'next/link';
import { notFound } from 'next/navigation';
import { requireAction, currentCanAction } from '@/lib/session';
import {
  getFixedDeposit, getAdjacentFixedDepositNos, listFixedDepositSchedule, type FixedDepositView,
} from '@/lib/fixedDeposits';
import { findPendingRoutedTask, isEligibleApprover, listWorkflowTasksForDocument } from '@/lib/workflow';
import { formatDate, formatDateTime, humanise, today } from '@/lib/format';
import { Page } from '@/components/layout/page';
import {
  Card, CardHead, DefinitionList, EmptyState, Pill, Stat, TableWrap, Toolbar, Spacer,
} from '@/components/ui/primitives';
import { Money } from '@/components/ui/money';
import {
  SubmitButton, CancelApprovalButton, ApproveButton, RejectButton, DelegateButton,
  ActivateButton, AccrueInterestButton, MatureButton, TerminateButton,
} from '../../fixed-deposit-actions';
import { CardNav } from '@/components/ui/card-nav';
import { DocumentActionsMenu } from '@/components/ui/document-actions';

const VIEWS: FixedDepositView[] = ['open', 'pending', 'approved', 'active', 'matured', 'terminated'];

export default async function FixedDepositDetailPage({ params, searchParams }: {
  params: Promise<{ no: string }>;
  searchParams: Promise<{ view?: string }>;
}) {
  const user = await requireAction('FIXED_DEPOSITS_READ');
  const { no } = await params;
  const { view: viewRaw } = await searchParams;
  const view = VIEWS.includes(viewRaw as FixedDepositView) ? (viewRaw as FixedDepositView) : undefined;
  const fd = await getFixedDeposit(no);
  if (!fd) notFound();

  const [canCreate, canApprove, tasks, { prevNo, nextNo }, schedule] = await Promise.all([
    currentCanAction('FIXED_DEPOSITS_CREATE'), currentCanAction('FIXED_DEPOSITS_APPROVE'),
    listWorkflowTasksForDocument('FIXED_DEPOSIT', no),
    getAdjacentFixedDepositNos(no, view),
    listFixedDepositSchedule(no),
  ]);

  const routedTask = fd.status === 'Pending Approval'
    ? await findPendingRoutedTask('FIXED_DEPOSIT', no)
    : null;
  const canDecideThis = routedTask ? await isEligibleApprover(routedTask, user.id) : canApprove;
  const requestedBy = routedTask?.requested_by ?? fd.created_by;
  const canCancelThis = canCreate && requestedBy === user.username;
  const pendingWith = tasks.find((t) => t.status === 'PENDING')?.pending_with;
  const canMatureThis = fd.status === 'Active' && canApprove && fd.end_date <= today();

  return (
    <>
      <CardNav
        prevHref={prevNo ? `/fixed-deposits/view/${prevNo}${view ? `?view=${view}` : ''}` : null}
        nextHref={nextNo ? `/fixed-deposits/view/${nextNo}${view ? `?view=${view}` : ''}` : null}
      />
      <Page
        title={`Fixed deposit ${fd.no}`}
        crumb={`${fd.member_first_name} ${fd.member_last_name} · ${fd.status}${pendingWith ? ` · pending with ${pendingWith}` : ''}`}
        user={user}
      >
      <Toolbar>
        <Link href="/fixed-deposits" className="btn ghost sm">← All fixed deposits</Link>
        <Link href={`/members/${fd.member_id}`} className="btn ghost sm">View member</Link>
        <Spacer />
        {fd.status === 'Open' && canCreate ? <SubmitButton no={fd.no} className="btn ghost" /> : null}
        {fd.status === 'Pending Approval' && canCancelThis ? (
          <CancelApprovalButton no={fd.no} className="btn ghost" />
        ) : null}
        {fd.status === 'Pending Approval' && canDecideThis ? (
          <>
            {routedTask ? <DelegateButton taskId={routedTask.id} className="btn ghost" /> : null}
            <ApproveButton no={fd.no} />
            <RejectButton no={fd.no} className="btn ghost" />
          </>
        ) : null}
        {fd.status === 'Approved' && canApprove ? <ActivateButton no={fd.no} /> : null}
        {fd.status === 'Active' && canApprove ? (
          <>
            <AccrueInterestButton no={fd.no} className="btn ghost" />
            {canMatureThis ? <MatureButton no={fd.no} /> : null}
            <TerminateButton no={fd.no} className="btn ghost" />
          </>
        ) : null}
        <DocumentActionsMenu />
      </Toolbar>

      <div className="grid g4 stack-2">
        <Stat label="Amount" value={<Money cents={fd.amount} decimals={0} />} />
        <Stat label="Running balance" value={<Money cents={fd.running_balance} decimals={0} />}
          foot={fd.fd_account_no ? fd.fd_account_no : 'Not yet activated'} />
        <Stat label="Total interest" value={<Money cents={fd.total_interest_payable} decimals={0} />}
          foot={<>Accrued so far: <Money cents={fd.total_interest_accrued} decimals={0} /></>} />
        <Stat label="Linked loan balance"
          value={<span className={fd.linked_loan_balance ? 'neg' : undefined}><Money cents={fd.linked_loan_balance} decimals={0} /></span>}
          foot={fd.linked_loan_balance ? 'Must be cleared before maturity/termination' : 'Free to mature/terminate'} />
      </div>

      <div className="grid split-side-sm">
        <div>
          <Card>
            <CardHead title="Fixed deposit details" />
            <DefinitionList items={[
              ['No.', <span className="mono" key="no">{fd.no}</span>],
              ['Member', <Link href={`/members/${fd.member_id}`} key="m">{fd.member_first_name} {fd.member_last_name} <span className="mono">({fd.member_no})</span></Link>],
              ['Type', `${fd.fd_type_code} — ${fd.fd_type_description}`],
              ['Rate', `${fd.rate}%`],
              ['Maturity instructions', humanise(fd.maturity_instructions)],
              ['Source account', <span className="mono" key="src">{fd.source_account_no}</span>],
              ['Start date', formatDate(fd.start_date)],
              ['Term', `${fd.term_months} month${fd.term_months === 1 ? '' : 's'}`],
              ['End date', formatDate(fd.end_date)],
              fd.rolled_from_no ? ['Rolled over from', <Link href={`/fixed-deposits/view/${fd.rolled_from_no}`} key="rf">{fd.rolled_from_no}</Link>] : null,
              fd.rolled_to_no ? ['Rolled over to', <Link href={`/fixed-deposits/view/${fd.rolled_to_no}`} key="rt">{fd.rolled_to_no}</Link>] : null,
              fd.decision_reason ? ['Decision reason', fd.decision_reason] : null,
            ]} />
          </Card>

          <Card>
            <CardHead title="Document trail" />
            <DefinitionList items={[
              ['Created by', fd.created_by || '—'],
              ['Created on', formatDateTime(fd.created_at)],
              ['Activated by', fd.activated_by || '—'],
              ['Activated on', fd.activated_at ? formatDateTime(fd.activated_at) : '—'],
              fd.processed_at ? ['Settled on', formatDateTime(fd.processed_at)] : null,
              fd.processed_by ? ['Settled by', fd.processed_by] : null,
            ]} />
          </Card>
        </div>

        <div>
          <Card>
            <CardHead title="Interest schedule" sub="One line per month over the term" />
            {schedule.length ? (
              <TableWrap>
                <thead>
                  <tr><th>Posting date</th><th>Description</th><th className="num">Amount</th><th>Posted</th></tr>
                </thead>
                <tbody>
                  {schedule.map((s) => (
                    <tr key={s.id}>
                      <td>{formatDate(s.posting_date)}</td>
                      <td>{s.description}</td>
                      <td className="num"><Money cents={s.amount} decimals={0} /></td>
                      <td>{s.transferred ? <Pill tone="ok">Posted</Pill> : <Pill tone="warn">Pending</Pill>}</td>
                    </tr>
                  ))}
                </tbody>
              </TableWrap>
            ) : <EmptyState icon="📅" title="No schedule yet" sub="Generated automatically when this fixed deposit is activated" />}
          </Card>
        </div>
      </div>
      </Page>
    </>
  );
}
