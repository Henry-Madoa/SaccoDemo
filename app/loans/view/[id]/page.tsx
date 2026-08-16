import Link from 'next/link';
import { notFound } from 'next/navigation';
import { requireAction, currentCanAction } from '@/lib/session';
import { getLoanDetail, getAdjacentLoanIds, LOAN_TAB_STATUS } from '@/lib/loanService';
import { findPendingRoutedTask, isEligibleApprover, listWorkflowTasksForDocument } from '@/lib/workflow';
import { getMemberDetail } from '@/lib/members';
import { listAttachments } from '@/lib/attachments';
import { isConfigured } from '@/lib/cloudinary';
import { formatDate, formatDateTime, humanise } from '@/lib/format';
import { Page } from '@/components/layout/page';
import {
  Card, CardHead, DefinitionList, EmptyState, Pill, Stat, TableWrap, Toolbar, Spacer,
} from '@/components/ui/primitives';
import { Money } from '@/components/ui/money';
import { DocumentActionsMenu } from '@/components/ui/document-actions';
import { CardNav } from '@/components/ui/card-nav';
import { SubmitButton, DecideButtons, DisburseButton, RepayButton } from './loan-actions';
import { AttachmentPanel } from '@/components/attachments/attachment-panel';

export default async function LoanDetailPage({ params, searchParams }: {
  params: Promise<{ id: string }>;
  searchParams: Promise<{ tab?: string }>;
}) {
  const user = await requireAction('LOAN_READ');
  const { id } = await params;
  const { tab } = await searchParams;
  const detail = await getLoanDetail(Number(id));
  if (!detail) notFound();

  const { loan: l, schedule, guarantors, transactions } = detail;
  const [canApprove, canDisburse, canRepay, canCreate, attachments, tasks, { prevId, nextId }] = await Promise.all([
    currentCanAction('LOAN_APPROVE'), currentCanAction('LOAN_DISBURSE'), currentCanAction('LOAN_REPAY'),
    currentCanAction('LOAN_CREATE'), listAttachments('loan', l.id),
    listWorkflowTasksForDocument('LOAN', String(l.id)),
    getAdjacentLoanIds(l.id, tab ? LOAN_TAB_STATUS[tab] : undefined),
  ]);

  // Send for approval is only offered to whoever captured this loan — unless they can also
  // approve loans, in which case only their own drafts (an approver editing someone else's
  // captured-but-unsubmitted loan is out of scope) — same rule Member Applications' own
  // SubmitButton eligibility uses.
  const canSubmit = canCreate && (!canApprove || l.created_by === user.username);

  // Approve/Reject are only ever shown to whoever can actually decide this specific
  // loan: the routed task's current approver (or their substitute/delegate); a loan
  // with no matching workflow falls back to the coarse LOAN:APPROVE permission.
  const routedTask = l.status === 'PENDING APPROVAL' ? await findPendingRoutedTask('LOAN', String(l.id)) : null;
  const canDecideThis = routedTask ? await isEligibleApprover(routedTask, user.id) : canApprove;

  // Only the repayment modal needs the member's accounts, so fetch them lazily.
  const repayAccounts = l.status === 'DISBURSED' && canRepay
    ? ((await getMemberDetail(l.member_id))?.accounts ?? [])
      .filter((a) => a.status === 'ACTIVE' && a.allow_withdrawal)
    : [];

  const outstanding = l.principal_balance + l.interest_balance + l.penalty_balance;
  const paidPct = l.principal ? Math.min(100, (l.principal_paid / l.principal) * 100) : 0;

  const totals = schedule.reduce(
    (a, s) => ({
      principal: a.principal + s.principal_due,
      interest: a.interest + s.interest_due,
      paid: a.paid + s.principal_paid + s.interest_paid,
    }),
    { principal: 0, interest: 0, paid: 0 },
  );
  const pendingWith = tasks.find((t) => t.status === 'PENDING')?.pending_with;

  return (
    <>
      <CardNav
        prevHref={prevId ? `/loans/view/${prevId}${tab ? `?tab=${tab}` : ''}` : null}
        nextHref={nextId ? `/loans/view/${nextId}${tab ? `?tab=${tab}` : ''}` : null}
      />
      <Page
        title={`Loan ${l.loan_no}`}
        crumb={`${l.first_name} ${l.last_name} · ${l.product_name}${pendingWith ? ` · pending with ${pendingWith}` : ''}`}
        user={user}
      >
      <Toolbar>
        <Link href="/loans" className="btn ghost sm">← All loans</Link>
        <Link href={`/members/${l.member_id}`} className="btn ghost sm">Member 360</Link>
        <Spacer />
        {l.status === 'OPEN' && canSubmit ? <SubmitButton loanId={l.id} /> : null}
        {l.status === 'PENDING APPROVAL' && canDecideThis ? (
          <DecideButtons loan={l} routedTaskId={routedTask?.id ?? null} />
        ) : null}
        {l.status === 'APPROVED' && canDisburse ? <DisburseButton loan={l} /> : null}
        {l.status === 'DISBURSED' && canRepay ? <RepayButton loan={l} accounts={repayAccounts} /> : null}
        <DocumentActionsMenu />
      </Toolbar>

      <div className="grid g4 stack-2">
        <Stat label="Principal" value={<Money cents={l.principal} decimals={0} />}
          foot={`${l.term_months} months at ${l.interest_rate}% ${l.interest_method.toLowerCase()}`} />
        <Stat label="Outstanding" value={<Money cents={outstanding} decimals={0} />}
          foot={<>principal <Money cents={l.principal_balance} decimals={0} /> · interest{' '}
            <Money cents={l.interest_balance} decimals={0} /></>} />
        <Stat label="Monthly instalment" value={<Money cents={l.installment} decimals={0} />}
          foot={`${paidPct.toFixed(0)}% of principal repaid`} />
        <Stat label="Arrears"
          value={<span className={l.arrears_amount ? 'neg' : undefined}>
            <Money cents={l.arrears_amount} decimals={0} />
          </span>}
          foot={`${l.days_in_arrears} days · ${humanise(l.classification)}`} />
      </div>

      <div className="grid split-side-sm">
        <div>
          <Card>
            <h3>Facility details</h3>
            <div className="card-sub">Status <Pill status={l.status} /></div>
            <DefinitionList items={[
              ['Loan number', <span className="mono" key="no">{l.loan_no}</span>],
              ['Member', <>{l.first_name} {l.last_name} <span className="mono">({l.member_no})</span></>],
              ['Product', l.product_name],
              ['Purpose', l.purpose || '—'],
              ['Applied', `${formatDate(l.applied_date)} by ${l.created_by || '—'}`],
              ['Approved', l.approved_date ? `${formatDate(l.approved_date)} by ${l.approved_by}` : '—'],
              l.rejected_reason ? ['Rejected because', l.rejected_reason] : null,
              ['Disbursed', formatDate(l.disbursed_date)],
              ['First instalment', formatDate(l.first_due_date)],
              ['Total interest', <Money cents={l.total_interest} key="ti" />],
              ['Charges recovered', <Money cents={l.fees_charged} key="fees" />],
              ['Principal repaid', <Money cents={l.principal_paid} key="pp" />],
              ['Interest repaid', <Money cents={l.interest_paid} key="ip" />],
            ]} />
          </Card>

          <Card>
            <CardHead
              title="Approval details"
              sub={`${tasks.length} approval step${tasks.length === 1 ? '' : 's'} routed`}
            />
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
          </Card>

          {guarantors.length ? (
            <Card>
              <h3>Guarantors</h3>
              <TableWrap>
                <thead><tr><th>Member</th><th className="num">Committed</th></tr></thead>
                <tbody>
                  {guarantors.map((g) => (
                    <tr key={g.id}>
                      <td><Link href={`/members/${g.member_id}`}>{g.first_name} {g.last_name}</Link></td>
                      <td className="num"><Money cents={g.amount} decimals={0} /></td>
                    </tr>
                  ))}
                </tbody>
              </TableWrap>
            </Card>
          ) : null}
        </div>

        <div>
          <Card>
            <CardHead
              title="Repayment schedule"
              sub={`${l.interest_method === 'REDUCING' ? 'Reducing balance amortisation' : 'Flat rate'} · ${schedule.length} instalments`}
            />
            {schedule.length ? (
              <TableWrap>
                <thead>
                  <tr>
                    <th className="num">#</th><th>Due date</th><th className="num">Opening</th>
                    <th className="num">Principal</th><th className="num">Interest</th>
                    <th className="num">Instalment</th><th className="num">Paid</th><th>Status</th>
                  </tr>
                </thead>
                <tbody>
                  {schedule.map((s) => (
                    <tr key={s.id}>
                      <td className="num">{s.installment_no}</td>
                      <td>{formatDate(s.due_date)}</td>
                      <td className="num"><Money cents={s.opening_balance} symbol={false} decimals={0} /></td>
                      <td className="num"><Money cents={s.principal_due} symbol={false} /></td>
                      <td className="num"><Money cents={s.interest_due} symbol={false} /></td>
                      <td className="num">
                        <b><Money cents={s.principal_due + s.interest_due} symbol={false} /></b>
                      </td>
                      <td className="num"><Money cents={s.principal_paid + s.interest_paid} symbol={false} /></td>
                      <td><Pill status={s.status} /></td>
                    </tr>
                  ))}
                </tbody>
                <tfoot>
                  <tr>
                    <td colSpan={3}>Totals</td>
                    <td className="num"><Money cents={totals.principal} symbol={false} /></td>
                    <td className="num"><Money cents={totals.interest} symbol={false} /></td>
                    <td className="num"><Money cents={totals.principal + totals.interest} symbol={false} /></td>
                    <td className="num"><Money cents={totals.paid} symbol={false} /></td>
                    <td />
                  </tr>
                </tfoot>
              </TableWrap>
            ) : <EmptyState icon="📅" title="The schedule is generated on disbursement" />}
          </Card>

          <AttachmentPanel
            entity="loan"
            entityId={l.id}
            attachments={attachments}
            canManage={canCreate}
            mediaEnabled={isConfigured()}
          />

          <Card>
            <CardHead title="Loan account activity" sub="Every entry carries the journal it posted" />
            {transactions.length ? (
              <TableWrap>
                <thead>
                  <tr>
                    <th>Reference</th><th>Date</th><th>Type</th><th>Description</th>
                    <th className="num">Amount</th>
                  </tr>
                </thead>
                <tbody>
                  {transactions.map((t) => (
                    <tr key={t.id}>
                      <td className="mono">{t.txn_ref}</td>
                      <td>{formatDate(t.value_date)}</td>
                      <td><Pill status={t.txn_type} /></td>
                      <td>{t.description || ''}</td>
                      <td className="num"><Money cents={t.amount} /></td>
                    </tr>
                  ))}
                </tbody>
              </TableWrap>
            ) : <EmptyState icon="🧾" title="No postings yet" />}
          </Card>
        </div>
      </div>
      </Page>
    </>
  );
}
