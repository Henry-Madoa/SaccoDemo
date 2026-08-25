import Link from 'next/link';
import { notFound } from 'next/navigation';
import { requireAction, currentCanAction } from '@/lib/session';
import {
  getGuarantorChange, getAdjacentGuarantorChangeNos, listGuarantorChangeLines, type GuarantorChangeView,
} from '@/lib/loanGuarantorChanges';
import { findPendingRoutedTask, isEligibleApprover, listWorkflowTasksForDocument } from '@/lib/workflow';
import { formatDateTime } from '@/lib/format';
import { Page } from '@/components/layout/page';
import {
  Card, CardHead, DefinitionList, EmptyState, Pill, Stat, TableWrap, Toolbar, Spacer,
} from '@/components/ui/primitives';
import { Money } from '@/components/ui/money';
import {
  SubmitButton, CancelApprovalButton, ApproveButton, RejectButton, DelegateButton, ProcessButton,
  RefreshLinesButton, ReleaseToggle, ReplacementsModal,
} from '../../guarantor-change-actions';
import { CardNav } from '@/components/ui/card-nav';
import { DocumentActionsMenu } from '@/components/ui/document-actions';

const VIEWS: GuarantorChangeView[] = ['open', 'pending', 'approved', 'processed'];

export default async function GuarantorChangeDetailPage({ params, searchParams }: {
  params: Promise<{ no: string }>;
  searchParams: Promise<{ view?: string }>;
}) {
  const user = await requireAction('GUARANTOR_CHANGES_READ');
  const { no } = await params;
  const { view: viewRaw } = await searchParams;
  const view = VIEWS.includes(viewRaw as GuarantorChangeView) ? (viewRaw as GuarantorChangeView) : undefined;
  const change = await getGuarantorChange(no);
  if (!change) notFound();

  const [canCreate, canApprove, tasks, { prevNo, nextNo }, lines] = await Promise.all([
    currentCanAction('GUARANTOR_CHANGES_CREATE'), currentCanAction('GUARANTOR_CHANGES_APPROVE'),
    listWorkflowTasksForDocument('GUARANTOR_CHANGE', no),
    getAdjacentGuarantorChangeNos(no, view),
    listGuarantorChangeLines(no),
  ]);

  const isOpen = change.status === 'Open';
  const isOwnRequest = change.created_by === user.username;
  const canEditThis = canCreate && (!canApprove || isOwnRequest);

  const routedTask = change.status === 'Pending Approval'
    ? await findPendingRoutedTask('GUARANTOR_CHANGE', no)
    : null;
  const canDecideThis = routedTask ? await isEligibleApprover(routedTask, user.id) : canApprove;
  const requestedBy = routedTask?.requested_by ?? change.created_by;
  const canCancelThis = canCreate && requestedBy === user.username;
  const processed = change.status === 'Processed';
  const pendingWith = tasks.find((t) => t.status === 'PENDING')?.pending_with;
  const canEditLines = isOpen && canEditThis;

  return (
    <>
      <CardNav
        prevHref={prevNo ? `/guarantor-changes/view/${prevNo}${view ? `?view=${view}` : ''}` : null}
        nextHref={nextNo ? `/guarantor-changes/view/${nextNo}${view ? `?view=${view}` : ''}` : null}
      />
      <Page
        title={`Guarantor change ${change.no}`}
        crumb={`${change.loan_no} · ${change.status} · ${change.member_no}${pendingWith ? ` · pending with ${pendingWith}` : ''}`}
        user={user}
      >
      <Toolbar>
        <Link href="/guarantor-changes" className="btn ghost sm">← All guarantor changes</Link>
        <Link href={`/loans/view/${change.loan_id}`} className="btn ghost sm">View loan</Link>
        <Link href={`/members/${change.member_id}`} className="btn ghost sm">View member</Link>
        <Spacer />
        {canEditLines ? <RefreshLinesButton no={change.no} className="btn ghost" /> : null}
        {canEditLines ? <SubmitButton no={change.no} className="btn ghost" /> : null}
        {change.status === 'Pending Approval' && canCancelThis ? (
          <CancelApprovalButton no={change.no} className="btn ghost" />
        ) : null}
        {change.status === 'Pending Approval' && canDecideThis ? (
          <>
            {routedTask ? <DelegateButton taskId={routedTask.id} className="btn ghost" /> : null}
            <ApproveButton no={change.no} />
            <RejectButton no={change.no} className="btn ghost" />
          </>
        ) : null}
        {change.status === 'Approved' && canApprove ? <ProcessButton no={change.no} /> : null}
        <DocumentActionsMenu />
      </Toolbar>

      <div className="grid g4 stack-2">
        <Stat label="Loan" value={<Link href={`/loans/view/${change.loan_id}`} className="mono">{change.loan_no}</Link>} />
        <Stat label="Loan outstanding balance" value={<Money cents={change.loan_outstanding_balance} decimals={0} />} />
        <Stat label="Status" value={<Pill status={change.status} />} />
        <Stat label="Lines" value={String(lines.length)}
          foot={`${lines.filter((l) => l.release).length} released · ${lines.filter((l) => l.replacements.length).length} substituted`} />
      </div>

      <div className="grid split-side-sm">
        <div>
          <Card>
            <CardHead title="Guarantor change details" />
            <DefinitionList items={[
              ['No.', <span className="mono" key="no">{change.no}</span>],
              ['Loan', <Link href={`/loans/view/${change.loan_id}`} key="loan">{change.loan_no}</Link>],
              ['Member', <>{change.member_first_name} {change.member_last_name} <span className="mono">({change.member_no})</span></>],
              change.decision_reason ? ['Decision reason', change.decision_reason] : null,
            ]} />
          </Card>

          <Card>
            <CardHead title="Document trail" sub="Who requested and processed this change, and when" />
            <DefinitionList items={[
              ['Created by', change.created_by || '—'],
              ['Created on', formatDateTime(change.created_at)],
              ['Processed', processed
                ? <Pill tone="ok" key="processed">YES — guarantors updated</Pill>
                : <Pill tone="warn" key="processed">NOT YET</Pill>],
              processed ? ['Processed by', change.processed_by || '—'] : null,
              processed ? ['Processed on', formatDateTime(change.processed_at)] : null,
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
        </div>

        <div>
          <Card>
            <CardHead
              title="Guarantor lines"
              sub={canEditLines
                ? 'Release a guarantor outright, or add one or more replacements to cover their amount'
                : 'Snapshotted when this document was opened or last refreshed'}
            />
            {lines.length ? (
              <TableWrap>
                <thead>
                  <tr>
                    <th>Guarantor</th>
                    <th className="num">Initial</th>
                    <th className="num">Outstanding</th>
                    <th>Release</th>
                    <th className="num" />
                  </tr>
                </thead>
                <tbody>
                  {lines.map((l) => (
                    <tr key={l.id}>
                      <td>
                        <Link href={`/members/${l.guarantor_member_id}`}>{l.guarantor_first_name} {l.guarantor_last_name}</Link>
                        <div className="tiny mono">{l.guarantor_member_no}</div>
                      </td>
                      <td className="num"><Money cents={l.initial_guaranteed} decimals={0} /></td>
                      <td className="num"><Money cents={l.outstanding_guaranteed} decimals={0} /></td>
                      <td>
                        {canEditLines ? (
                          <ReleaseToggle no={change.no} lineId={l.id} release={l.release} hasReplacements={l.replacements.length > 0} />
                        ) : (l.release ? <Pill tone="warn">Released</Pill> : '—')}
                      </td>
                      <td className="num">
                        {!l.release ? <ReplacementsModal no={change.no} line={l} disabled={!canEditLines} /> : null}
                      </td>
                    </tr>
                  ))}
                </tbody>
              </TableWrap>
            ) : <EmptyState icon="🧾" title="No lines" sub={canEditLines ? 'Refresh lines to populate from the loan’s current guarantors.' : undefined} />}
          </Card>
        </div>
      </div>
      </Page>
    </>
  );
}
