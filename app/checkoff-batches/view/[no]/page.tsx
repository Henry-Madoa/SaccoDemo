import { Fragment } from 'react';
import Link from 'next/link';
import { notFound } from 'next/navigation';
import { requireAction, currentCanAction } from '@/lib/session';
import {
  getCheckoffBatch, getAdjacentCheckoffBatchNos, listCheckoffBatchLines, listCheckoffCalculations,
  listSalaryChargeCodes, type CheckoffBatchView,
} from '@/lib/checkoffBatches';
import { listActiveEmployers } from '@/lib/employers';
import { CHECKOFF_SEARCH_TYPES } from '@/lib/constants';
import { findPendingRoutedTask, isEligibleApprover, listWorkflowTasksForDocument } from '@/lib/workflow';
import { formatDate, formatDateTime, humanise } from '@/lib/format';
import { Page } from '@/components/layout/page';
import {
  Card, CardHead, DefinitionList, EmptyState, Pill, Stat, TableWrap, Toolbar, Spacer,
} from '@/components/ui/primitives';
import { Money } from '@/components/ui/money';
import {
  SubmitButton, CancelApprovalButton, ApproveButton, RejectButton, DelegateButton, ProcessButton,
  RefreshLinesButton, RemittedAmountField, EditCheckoffBatchButton, CheckoffCsvUploadForm, ValidateBatchButton,
  CalculateBatchButton,
} from '../../checkoff-batch-actions';
import { CardNav } from '@/components/ui/card-nav';
import { DocumentActionsMenu } from '@/components/ui/document-actions';

const VIEWS: CheckoffBatchView[] = ['open', 'pending', 'approved', 'processed'];

export default async function CheckoffBatchDetailPage({ params, searchParams }: {
  params: Promise<{ no: string }>;
  searchParams: Promise<{ view?: string }>;
}) {
  const user = await requireAction('CHECKOFF_BATCHES_READ');
  const { no } = await params;
  const { view: viewRaw } = await searchParams;
  const view = VIEWS.includes(viewRaw as CheckoffBatchView) ? (viewRaw as CheckoffBatchView) : undefined;
  const batch = await getCheckoffBatch(no);
  if (!batch) notFound();

  const isSalary = batch.batch_type === 'SALARY';
  const isOpenForEdit = batch.status === 'Open';
  const [canCreate, canApprove, tasks, { prevNo, nextNo }, lines, calculations, salaryChargeCodes, employers] = await Promise.all([
    currentCanAction('CHECKOFF_BATCHES_CREATE'), currentCanAction('CHECKOFF_BATCHES_APPROVE'),
    listWorkflowTasksForDocument('CHECKOFF_BATCH', no),
    getAdjacentCheckoffBatchNos(no, view),
    listCheckoffBatchLines(no),
    isSalary && batch.calculated ? listCheckoffCalculations(no) : Promise.resolve([]),
    isSalary ? listSalaryChargeCodes() : Promise.resolve([]),
    isOpenForEdit ? listActiveEmployers() : Promise.resolve([]),
  ]);

  const isOpen = batch.status === 'Open';
  const isCheckoff = batch.batch_type === 'CHECKOFF';
  const isOwnRequest = batch.created_by === user.username;
  const canEditThis = canCreate && (!canApprove || isOwnRequest);
  const calculationsByLine = new Map<number, typeof calculations>();
  for (const c of calculations) {
    const list = calculationsByLine.get(c.line_id) ?? [];
    list.push(c);
    calculationsByLine.set(c.line_id, list);
  }
  const ENTRY_TYPE_LABEL: Record<string, string> = {
    CHARGE: 'Charge', LOAN_RECOVERY: 'Loan recovery', INTERNAL_DEPOSIT: 'Internal deposit', NET_AMOUNT: 'Net amount',
  };
  const searchTypeLabel = CHECKOFF_SEARCH_TYPES.find((t) => t.value === batch.search_type)?.label ?? batch.search_type;

  const routedTask = batch.status === 'Pending Approval'
    ? await findPendingRoutedTask('CHECKOFF_BATCH', no)
    : null;
  const canDecideThis = routedTask ? await isEligibleApprover(routedTask, user.id) : canApprove;
  const requestedBy = routedTask?.requested_by ?? batch.created_by;
  const canCancelThis = canCreate && requestedBy === user.username;
  const processed = batch.status === 'Processed';
  const pendingWith = tasks.find((t) => t.status === 'PENDING')?.pending_with;
  const canEditLines = isOpen && canEditThis;

  return (
    <>
      <CardNav
        prevHref={prevNo ? `/checkoff-batches/view/${prevNo}${view ? `?view=${view}` : ''}` : null}
        nextHref={nextNo ? `/checkoff-batches/view/${nextNo}${view ? `?view=${view}` : ''}` : null}
      />
      <Page
        title={`${humanise(batch.batch_type)} batch ${batch.no}`}
        crumb={`${batch.employer_name} · ${formatDate(batch.period)} · ${batch.status}${pendingWith ? ` · pending with ${pendingWith}` : ''}`}
        user={user}
      >
      <Toolbar>
        <Link href="/checkoff-batches" className="btn ghost sm">← All batches</Link>
        <Spacer />
        {canEditLines ? (
          <EditCheckoffBatchButton batch={batch} employers={employers} salaryChargeCodes={salaryChargeCodes} className="btn ghost sm" />
        ) : null}
        {canEditLines ? <ValidateBatchButton no={batch.no} /> : null}
        {canEditLines && isSalary ? <CalculateBatchButton no={batch.no} /> : null}
        {canEditLines ? <RefreshLinesButton no={batch.no} className="btn ghost" /> : null}
        {canEditLines ? <SubmitButton no={batch.no} className="btn ghost" /> : null}
        {batch.status === 'Pending Approval' && canCancelThis ? (
          <CancelApprovalButton no={batch.no} className="btn ghost" />
        ) : null}
        {batch.status === 'Pending Approval' && canDecideThis ? (
          <>
            {routedTask ? <DelegateButton taskId={routedTask.id} className="btn ghost" /> : null}
            <ApproveButton no={batch.no} />
            <RejectButton no={batch.no} className="btn ghost" />
          </>
        ) : null}
        {batch.status === 'Approved' && canApprove ? <ProcessButton no={batch.no} /> : null}
        <DocumentActionsMenu />
      </Toolbar>

      {canEditLines ? (
        <Card>
          <CardHead title="CSV upload"
            sub={`${searchTypeLabel}, Name, Amount — matched rows overwrite that line's remitted amount`} />
          <CheckoffCsvUploadForm no={batch.no} />
        </Card>
      ) : null}

      <div className="grid g4 stack-2">
        <Stat label="Members" value={String(batch.line_count)} />
        {isCheckoff ? <Stat label="Total expected" value={<Money cents={batch.total_expected} decimals={0} />} /> : null}
        <Stat label="Total remitted" value={<Money cents={batch.total_remitted} decimals={0} />} />
        {isCheckoff ? (
          <Stat label="Total variance"
            value={<span className={batch.total_variance ? 'neg' : undefined}><Money cents={batch.total_variance} decimals={0} /></span>}
            foot={batch.total_variance ? 'Remitted differs from expected' : 'Fully reconciled'} />
        ) : (
          <Stat label="Uploaded via CSV" value={<Money cents={batch.total_uploaded} decimals={0} />}
            foot={batch.total_uploaded !== batch.total_remitted ? 'Differs from what the card shows' : 'Matches the card'} />
        )}
      </div>

      <div className="grid split-side-sm">
        <div>
          <Card>
            <CardHead title="Batch details" />
            <DefinitionList items={[
              ['No.', <span className="mono" key="no">{batch.no}</span>],
              ['Employer', <>{batch.employer_name} <span className="mono">({batch.employer_code})</span></>],
              ['Type', humanise(batch.batch_type)],
              ['Period', formatDate(batch.period)],
              ['Posting date', batch.posting_date ? formatDate(batch.posting_date) : '—'],
              ['Search type', searchTypeLabel],
              isSalary ? ['Charge code', batch.transaction_charge_code || '—'] : null,
              isSalary ? ['Calculated', batch.calculated
                ? <Pill tone="ok" key="calc">YES</Pill>
                : <Pill tone="warn" key="calc">NOT YET</Pill>] : null,
              batch.decision_reason ? ['Decision reason', batch.decision_reason] : null,
            ]} />
          </Card>

          <Card>
            <CardHead title="Document trail" sub="Who requested and processed this batch, and when" />
            <DefinitionList items={[
              ['Created by', batch.created_by || '—'],
              ['Created on', formatDateTime(batch.created_at)],
              ['Processed', processed
                ? <Pill tone="ok" key="processed">YES — postings complete</Pill>
                : <Pill tone="warn" key="processed">NOT YET</Pill>],
              processed ? ['Processed by', batch.processed_by || '—'] : null,
              processed ? ['Processed on', formatDateTime(batch.processed_at)] : null,
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
              title="Lines"
              sub={canEditLines
                ? 'Record what each member actually remitted this period'
                : 'Snapshotted when this batch was opened or last refreshed'}
            />
            {lines.length ? (
              <TableWrap>
                <thead>
                  <tr>
                    <th>Member</th><th>Payroll No.</th>
                    {isCheckoff ? <th className="num">Expected</th> : null}
                    {isSalary ? <th className="num">Uploaded</th> : null}
                    <th className="num">Remitted</th>
                    {isCheckoff ? <th className="num">Variance</th> : null}
                  </tr>
                </thead>
                <tbody>
                  {lines.map((l) => {
                    const lineCalcs = calculationsByLine.get(l.id) ?? [];
                    const mismatched = isSalary && l.uploaded_amount > 0 && l.uploaded_amount !== l.remitted_amount;
                    return (
                    <Fragment key={l.id}>
                    <tr>
                      <td>
                        <Link href={`/members/${l.member_id}`}>{l.member_first_name} {l.member_last_name}</Link>
                        <div className="tiny mono">{l.member_no}</div>
                      </td>
                      <td className="mono">{l.payroll_no || '—'}</td>
                      {isCheckoff ? <td className="num"><Money cents={l.expected_amount} decimals={0} /></td> : null}
                      {isSalary ? (
                        <td className="num">
                          {l.uploaded_amount > 0 ? <Money cents={l.uploaded_amount} decimals={0} /> : '—'}
                        </td>
                      ) : null}
                      <td className="num">
                        {canEditLines ? (
                          <RemittedAmountField no={batch.no} line={l} isCheckoff={isCheckoff} />
                        ) : <Money cents={l.remitted_amount} decimals={0} />}
                        {mismatched ? <div className="tiny neg">≠ uploaded</div> : null}
                      </td>
                      {isCheckoff ? (
                        <td className="num">
                          <span className={l.variance ? 'neg' : undefined}><Money cents={l.variance} decimals={0} /></span>
                        </td>
                      ) : null}
                    </tr>
                    {lineCalcs.length ? (
                      <tr>
                        <td colSpan={isSalary ? 4 : (isCheckoff ? 5 : 3)} style={{ background: 'var(--surface-2)', padding: '6px 10px 10px 30px' }}>
                          <table className="tiny">
                            <tbody>
                              {lineCalcs.map((c) => (
                                <tr key={c.id}>
                                  <td>{ENTRY_TYPE_LABEL[c.entry_type] ?? c.entry_type}</td>
                                  <td>
                                    {c.description}
                                    {c.loan_no ? ` — ${c.loan_no}` : ''}
                                    {c.savings_account_no ? ` — ${c.savings_account_no}` : ''}
                                    {c.gl_account_code ? ` — GL ${c.gl_account_code}` : ''}
                                  </td>
                                  <td className="num"><Money cents={c.amount} decimals={0} /></td>
                                </tr>
                              ))}
                            </tbody>
                          </table>
                        </td>
                      </tr>
                    ) : null}
                    </Fragment>
                    );
                  })}
                </tbody>
              </TableWrap>
            ) : <EmptyState icon="🧾" title="No lines" sub={canEditLines ? 'Refresh lines to populate from the employer’s current members.' : undefined} />}
          </Card>
        </div>
      </div>
      </Page>
    </>
  );
}
