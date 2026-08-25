import Link from 'next/link';
import { notFound } from 'next/navigation';
import { requireAction, currentCanAction } from '@/lib/session';
import { getLoanDetail, getAdjacentLoanIds, LOAN_TAB_STATUS, processedSalarySummary } from '@/lib/loanService';
import { findPendingRoutedTask, isEligibleApprover, listWorkflowTasksForDocument } from '@/lib/workflow';
import { getMemberDetail, listActiveMembers } from '@/lib/members';
import { listActiveLoanProductsWithCharges } from '@/lib/admin';
import { listAttachments } from '@/lib/attachments';
import { listActiveBankAccounts } from '@/lib/gl';
import { isConfigured } from '@/lib/cloudinary';
import { calculateLoanProductCharges } from '@/lib/loans';
import { listLoanProductCharges } from '@/lib/loanProductCharges';
import { ensureSalaryAppraisalLines } from '@/lib/salaryAppraisal';
import { hasLiveGuarantorChange } from '@/lib/loanGuarantorChanges';
import { listLoanFdLiens } from '@/lib/loanFdSecurity';
import { formatDate, formatDateTime, humanise } from '@/lib/format';
import { parseSort } from '@/lib/listSort';
import { getDimensionCaptions } from '@/lib/org';
import { Page } from '@/components/layout/page';
import {
  DefinitionList, EmptyState, Pill, Stat, TableWrap, Toolbar, Spacer,
} from '@/components/ui/primitives';
import { CollapsibleCard } from '@/components/ui/collapsible-card';
import { SearchInput } from '@/components/ui/filters';
import { SortLink } from '@/components/ui/sort-link';
import { Money } from '@/components/ui/money';
import { DocumentActionsMenu } from '@/components/ui/document-actions';
import { CardNav } from '@/components/ui/card-nav';
import { JournalLink } from '@/app/accounting/drill-downs';
import {
  SubmitButton, DecideButtons, DisburseButton, RepayButton, AttachCollateralButton, DetachCollateralButton,
  AttachFdSecurityButton, DetachFdSecurityButton,
  AddGuarantorButton, ReleaseGuarantorButton, RunAppraisalButton,
} from './loan-actions';
import { EditLoanButton } from '../../application-form';
import { AttachmentPanel } from '@/components/attachments/attachment-panel';
import { AppraisalCard, AppraisalHistoryTable, AppraisalMeta, toAppraisal } from '@/components/loans/appraisal-card';
import { ChargesBreakdownButton } from '@/components/loans/charges-breakdown';
import { SalaryAppraisalCard } from '@/components/loans/salary-appraisal-card';

export default async function LoanDetailPage({ params, searchParams }: {
  params: Promise<{ id: string }>;
  searchParams: Promise<{ tab?: string; schSort?: string; actQ?: string; actSort?: string }>;
}) {
  const user = await requireAction('LOAN_READ');
  const { id } = await params;
  const { tab, schSort: schSortRaw, actQ = '', actSort: actSortRaw } = await searchParams;
  const schSort = parseSort(schSortRaw);
  const actSort = parseSort(actSortRaw);
  const detail = await getLoanDetail(Number(id));
  if (!detail) notFound();

  const { loan: l, schedule, guarantors, collateral, transactions, appraisals } = detail;
  const latestAppraisal = appraisals[0] ?? null;
  const canAppraise = ['OPEN', 'PENDING APPROVAL', 'APPROVED'].includes(l.status);
  const [
    canApprove, canDisburse, canRepay, canCreate, canChangeGuarantors, attachments, tasks,
    { prevId, nextId }, { caption1, caption2 }, fdLiens,
  ] = await Promise.all([
      currentCanAction('LOAN_APPROVE'), currentCanAction('LOAN_DISBURSE'), currentCanAction('LOAN_REPAY'),
      currentCanAction('LOAN_CREATE'), currentCanAction('GUARANTOR_CHANGES_CREATE'), listAttachments('loan', l.id),
      listWorkflowTasksForDocument('LOAN', String(l.id)),
      getAdjacentLoanIds(l.id, tab ? LOAN_TAB_STATUS[tab] : undefined),
      getDimensionCaptions(), listLoanFdLiens(l.id),
    ]);

  // Offered only once the loan is DISBURSED (guarantors are otherwise still editable inline via
  // Edit above), it still has committed guarantors to review, and no other change document is
  // already open/in-progress against it — same eligibility lib/loanGuarantorChanges.ts's
  // listChangeableLoans() itself enforces.
  const canOpenGuarantorChange = l.status === 'DISBURSED' && canChangeGuarantors && guarantors.length > 0
    && !(await hasLiveGuarantorChange(l.id));

  // Whether the Guarantors/Collateral security tiles appear at all — editable while OPEN (always
  // shown then, even with nothing committed yet, so there's somewhere to add the first one),
  // read-only afterwards only once there's something to show. Paired side by side only when both
  // are actually going to render, so a lone tile never sits next to empty grid space.
  const showGuarantors = (l.status === 'OPEN' && canCreate) || guarantors.length > 0;
  const showCollateral = (l.status === 'OPEN' && canCreate) || collateral.length > 0;
  const showFdSecurity = (l.status === 'OPEN' && canCreate) || fdLiens.length > 0;

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

  // The Bank/Cashbook picker both Disburse and Repay need whenever the money doesn't move
  // through a member's own savings account — fetched lazily for the same reason as above.
  const bankAccounts = (l.status === 'APPROVED' && canDisburse) || (l.status === 'DISBURSED' && canRepay)
    ? await listActiveBankAccounts()
    : [];

  // Edit is offered under the same rule and the same OPEN-only window as Send for approval, so
  // the member/product picklists it needs are fetched only when it will actually be shown.
  const canEdit = l.status === 'OPEN' && canSubmit;
  const [editMembers, editProducts] = canEdit
    ? await Promise.all([listActiveMembers(), listActiveLoanProductsWithCharges()])
    : [[], []];

  const outstanding = l.principal_balance + l.interest_balance + l.penalty_balance;
  const paidPct = l.principal ? Math.min(100, (l.principal_paid / l.principal) * 100) : 0;
  // Charges auto-computed by the Loan Product Charges module (lib/loans.ts's
  // calculateLoanProductCharges) — the same list disburse() itself posts, one credit line per
  // charge to its own revenue account — shown here (click the amount to see the breakdown) right
  // through appraisal and approval, not just at the point of application.
  const chargeLines = await listLoanProductCharges(l.product_id);
  const computedCharges = calculateLoanProductCharges(chargeLines, l.principal, l.term_months);

  // Auto-seeds/refreshes the Salary Appraisal section on every view for a non-salary-based
  // product (lib/salaryAppraisal.ts's ensureSalaryAppraisalLines) — cheap to no-op once the
  // parameter lines are on file, and always keeps the auto-derived other-loan deduction rows
  // current. A salary_based product uses actually-processed payroll instead — see
  // processedSalary below — and never shows this manual card at all.
  const salaryLines = !l.salary_based ? await ensureSalaryAppraisalLines(l.id, l.member_id) : [];
  const canEditSalary = l.status === 'OPEN' && canCreate;
  const processedSalary = l.salary_based
    ? await processedSalarySummary(l.member_id, l.min_salary_count, l.salary_appraisal_type)
    : null;

  const totals = schedule.reduce(
    (a, s) => ({
      principal: a.principal + s.principal_due,
      interest: a.interest + s.interest_due,
      paid: a.paid + s.principal_paid + s.interest_paid,
    }),
    { principal: 0, interest: 0, paid: 0 },
  );
  const pendingWith = tasks.find((t) => t.status === 'PENDING')?.pending_with;

  // Sorting is applied to display copies only — the tfoot totals above are always the
  // schedule's true (unsorted) totals.
  const SCHEDULE_SORT_KEYS: Record<string, (s: typeof schedule[number]) => string | number> = {
    installment_no: (s) => s.installment_no,
    due_date: (s) => s.due_date,
    opening_balance: (s) => s.opening_balance,
    principal_due: (s) => s.principal_due,
    interest_due: (s) => s.interest_due,
    instalment: (s) => s.principal_due + s.interest_due,
    paid: (s) => s.principal_paid + s.interest_paid,
    status: (s) => s.status,
  };
  const displaySchedule = [...schedule].sort((a, b) => {
    const get = schSort && SCHEDULE_SORT_KEYS[schSort.field];
    if (!get) return 0;
    const av = get(a); const bv = get(b);
    const cmp = av < bv ? -1 : av > bv ? 1 : 0;
    return schSort!.dir === 'desc' ? -cmp : cmp;
  });

  const actNeedle = actQ.trim().toLowerCase();
  const ACTIVITY_SORT_KEYS: Record<string, (t: typeof transactions[number]) => string | number> = {
    txn_ref: (t) => t.txn_ref,
    document_no: (t) => t.document_no || '',
    value_date: (t) => t.value_date,
    txn_type: (t) => t.txn_type,
    description: (t) => t.description || '',
    amount: (t) => t.amount,
  };
  const displayTransactions = transactions
    .filter((t) => !actNeedle || [t.txn_ref, t.document_no, t.description, t.txn_type]
      .some((v) => (v || '').toLowerCase().includes(actNeedle)))
    .sort((a, b) => {
      const get = actSort && ACTIVITY_SORT_KEYS[actSort.field];
      if (!get) return 0;
      const av = get(a); const bv = get(b);
      const cmp = av < bv ? -1 : av > bv ? 1 : 0;
      return actSort!.dir === 'desc' ? -cmp : cmp;
    });

  const facilityDetailsCard = (
    <CollapsibleCard title="Facility details" sub={<>Status <Pill status={l.status} /></>}>
      <DefinitionList items={[
        ['Loan number', <span className="mono" key="no">{l.loan_no}</span>],
        ['Member', <>{l.first_name} {l.last_name} <span className="mono">({l.member_no})</span></>],
        ['Product', l.product_name],
        ['Purpose', l.purpose || '—'],
        ['Recovery mode', humanise(l.recovery_mode)],
        ['Applied', `${formatDate(l.applied_date)} by ${l.created_by || '—'}`],
        ['Approved', l.approved_date ? `${formatDate(l.approved_date)} by ${l.approved_by}` : '—'],
        l.rejected_reason ? ['Rejected because', l.rejected_reason] : null,
        ['Disbursed', formatDate(l.disbursed_date)],
        ['First instalment', formatDate(l.first_due_date)],
        ['Total interest', <Money cents={l.total_interest} key="ti" />],
        l.status === 'DISBURSED' || l.status === 'CLOSED'
          ? ['Charges recovered',
            <ChargesBreakdownButton key="fees" charges={computedCharges} totalOverride={l.fees_charged}
              label="Charges recovered at disbursement" />]
          : ['Estimated charges',
            <ChargesBreakdownButton key="fees" charges={computedCharges} label="Estimated charges" />],
        ['Principal repaid', <Money cents={l.principal_paid} key="pp" />],
        ['Interest repaid', <Money cents={l.interest_paid} key="ip" />],
      ]} />
    </CollapsibleCard>
  );

  const salaryCard = l.salary_based ? (
    <CollapsibleCard
      title="Processed Salary"
      sub="Read from actually-processed payroll (Checkoff & Salary Processing) — not a typed-in mimic of the payslip"
    >
      <DefinitionList items={[
        ['Appraisal method', l.salary_appraisal_type === 'LOWEST_NET' ? 'Lowest net salary' : 'Average net salary'],
        ['Minimum months required', String(l.min_salary_count)],
        ['Processed months found', processedSalary ? `${processedSalary.count} (last ${processedSalary.windowMonths} months)` : '0'],
        ['Base income', processedSalary && processedSalary.sufficient
          ? <Money cents={processedSalary.base} key="base" />
          : <span className="neg" key="base">Not yet sufficient</span>],
      ]} />
      {!processedSalary?.sufficient ? (
        <div className="note" style={{ marginTop: 8 }}>
          Needs at least {l.min_salary_count} processed salary payment{l.min_salary_count === 1 ? '' : 's'} for{' '}
          {l.first_name} {l.last_name} via Checkoff &amp; Salary Processing before affordability can be assessed.
        </div>
      ) : null}
    </CollapsibleCard>
  ) : (
    <CollapsibleCard
      title="Earnings and Deductions"
      sub="Predefined payslip lines the officer fills in to mimic the member's payslip — the 1/3 cap and headroom below update as amounts are typed"
    >
      <SalaryAppraisalCard loanId={l.id} lines={salaryLines} editable={canEditSalary} />
    </CollapsibleCard>
  );

  const guarantorsCard = showGuarantors ? (
    l.status === 'OPEN' && canCreate ? (
      <CollapsibleCard title="Guarantors" sub="Members who have committed to guarantee this loan">
        {guarantors.length ? (
          <TableWrap>
            <thead><tr><th>Member</th><th className="num">Committed</th><th className="num" /></tr></thead>
            <tbody>
              {guarantors.map((g) => (
                <tr key={g.id}>
                  <td><Link href={`/members/${g.member_id}`}>{g.first_name} {g.last_name}</Link></td>
                  <td className="num"><Money cents={g.amount} decimals={0} /></td>
                  <td className="num"><ReleaseGuarantorButton loanId={l.id} memberId={g.member_id} /></td>
                </tr>
              ))}
            </tbody>
          </TableWrap>
        ) : <EmptyState icon="🤝" title="No guarantors committed" />}
        <Toolbar>
          <Spacer />
          <AddGuarantorButton loanId={l.id} memberId={l.member_id} existingMemberIds={guarantors.map((g) => g.member_id)} />
        </Toolbar>
      </CollapsibleCard>
    ) : (
      <CollapsibleCard title="Guarantors" sub="Members who have committed to guarantee this loan">
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
        {canOpenGuarantorChange ? (
          <Toolbar>
            <Spacer />
            <Link href={`/guarantor-changes?new=${l.id}`} className="btn sm ghost">Change guarantors</Link>
          </Toolbar>
        ) : null}
      </CollapsibleCard>
    )
  ) : null;

  const collateralCard = showCollateral ? (
    l.status === 'OPEN' && canCreate ? (
      <CollapsibleCard title="Collateral security" sub="Registered assets pledged against this loan">
        {collateral.length ? (
          <TableWrap>
            <thead><tr><th>Collateral</th><th className="num">Cover drawn</th><th className="num" /></tr></thead>
            <tbody>
              {collateral.map((c) => (
                <tr key={c.id}>
                  <td>
                    <Link href={`/collateral-register/view/${c.collateral_no}`} className="mono">{c.collateral_no}</Link>
                    <div className="tiny">{c.collateral_description || '—'}</div>
                  </td>
                  <td className="num"><Money cents={c.guarantee} decimals={0} /></td>
                  <td className="num"><DetachCollateralButton loanId={l.id} collateralNo={c.collateral_no} /></td>
                </tr>
              ))}
            </tbody>
          </TableWrap>
        ) : <EmptyState icon="🏠" title="No collateral attached" />}
        <Toolbar><Spacer /><AttachCollateralButton loanId={l.id} memberId={l.member_id} /></Toolbar>
      </CollapsibleCard>
    ) : (
      <CollapsibleCard title="Collateral security" sub="Registered assets pledged against this loan">
        <TableWrap>
          <thead><tr><th>Collateral</th><th className="num">Cover drawn</th></tr></thead>
          <tbody>
            {collateral.map((c) => (
              <tr key={c.id}>
                <td>
                  <Link href={`/collateral-register/view/${c.collateral_no}`} className="mono">{c.collateral_no}</Link>
                  <div className="tiny">{c.collateral_description || '—'}</div>
                </td>
                <td className="num"><Money cents={c.guarantee} decimals={0} /></td>
              </tr>
            ))}
          </tbody>
        </TableWrap>
      </CollapsibleCard>
    )
  ) : null;

  const fdSecurityCard = showFdSecurity ? (
    l.status === 'OPEN' && canCreate ? (
      <CollapsibleCard title="FD security" sub="Fixed deposits pledged against this loan">
        {fdLiens.length ? (
          <TableWrap>
            <thead><tr><th>Fixed deposit</th><th className="num">Cover drawn</th><th className="num" /></tr></thead>
            <tbody>
              {fdLiens.map((f) => (
                <tr key={f.id}>
                  <td>
                    <Link href={`/fixed-deposits/view/${f.fd_no}`} className="mono">{f.fd_no}</Link>
                  </td>
                  <td className="num"><Money cents={f.guarantee} decimals={0} /></td>
                  <td className="num"><DetachFdSecurityButton loanId={l.id} fdNo={f.fd_no} /></td>
                </tr>
              ))}
            </tbody>
          </TableWrap>
        ) : <EmptyState icon="🏛" title="No fixed deposit attached" />}
        <Toolbar><Spacer /><AttachFdSecurityButton loanId={l.id} memberId={l.member_id} /></Toolbar>
      </CollapsibleCard>
    ) : (
      <CollapsibleCard title="FD security" sub="Fixed deposits pledged against this loan">
        <TableWrap>
          <thead><tr><th>Fixed deposit</th><th className="num">Cover drawn</th></tr></thead>
          <tbody>
            {fdLiens.map((f) => (
              <tr key={f.id}>
                <td><Link href={`/fixed-deposits/view/${f.fd_no}`} className="mono">{f.fd_no}</Link></td>
                <td className="num"><Money cents={f.guarantee} decimals={0} /></td>
              </tr>
            ))}
          </tbody>
        </TableWrap>
      </CollapsibleCard>
    )
  ) : null;

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
        <Link href={`/loan-documents?loan=${l.id}`} className="btn ghost sm">Loan Documents</Link>
        <Spacer />
        {canEdit ? (
          <EditLoanButton
            members={editMembers} products={editProducts}
            loan={{
              id: l.id, loan_no: l.loan_no, member_id: l.member_id, product_id: l.product_id,
              principal: l.principal, term_months: l.term_months, purpose: l.purpose,
              disburse_to_account_id: l.disburse_to_account_id, recovery_mode: l.recovery_mode,
            }}
          />
        ) : null}
        {l.status === 'OPEN' && canSubmit ? (
          <SubmitButton loanId={l.id} appraisalDecision={latestAppraisal?.decision ?? null} />
        ) : null}
        {l.status === 'PENDING APPROVAL' && canDecideThis ? (
          <DecideButtons loan={l} routedTaskId={routedTask?.id ?? null} />
        ) : null}
        {l.status === 'APPROVED' && canDisburse ? <DisburseButton loan={l} bankAccounts={bankAccounts} /> : null}
        {l.status === 'DISBURSED' && canRepay ? (
          <RepayButton loan={l} accounts={repayAccounts} bankAccounts={bankAccounts} />
        ) : null}
        {canAppraise && canCreate ? <RunAppraisalButton loanId={l.id} /> : null}
        <DocumentActionsMenu
          excel={{
            href: '/api/export/loan-appraisal', params: { id: String(l.id) }, disabled: !latestAppraisal,
            label: 'Appraisal Report (.xlsx)',
          }}
        />
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

      <div className="grid g2 stack-2">
        {facilityDetailsCard}
        {salaryCard}
      </div>

      {(() => {
        const securityCards = [guarantorsCard, collateralCard, fdSecurityCard].filter(Boolean);
        if (securityCards.length > 1) {
          return <div className={`grid g${securityCards.length} stack-2`}>{securityCards}</div>;
        }
        return securityCards[0] ?? null;
      })()}

      <CollapsibleCard
        title="Appraisal"
        sub={latestAppraisal
          ? `Latest run · ${appraisals.length} on file`
          : 'No appraisal has been run against this application yet'}
      >
        {latestAppraisal ? (
          <>
            <AppraisalMeta appraisal={latestAppraisal} />
            <AppraisalCard appraisal={toAppraisal(latestAppraisal)} />
          </>
        ) : (
          <EmptyState icon="🧮" title="Not yet appraised"
            sub={canAppraise && canCreate ? 'Run appraisal above to file the first decision.' : undefined} />
        )}
      </CollapsibleCard>

      <AppraisalHistoryTable appraisals={appraisals} />

      <AttachmentPanel
        entity="loan"
        entityId={l.id}
        attachments={attachments}
        canManage={canCreate}
        mediaEnabled={isConfigured()}
      />

      {/* Repayment schedule and Loan account activity close out the page — the two widest,
          most detail-dense tables, so they read best with the full page width to themselves
          rather than squeezed alongside the detail cards above. */}
      <CollapsibleCard
        title="Repayment schedule"
        sub={`${l.interest_method === 'REDUCING' ? 'Reducing balance amortisation' : 'Flat rate'} · ${schedule.length} instalments`
          + (l.status === 'DISBURSED' || l.status === 'CLOSED' ? '' : ' · projected from the appraisal, regenerated at disbursement')}
      >
        {schedule.length ? (
          <TableWrap>
            <thead>
              <tr>
                <th className="num"><SortLink sortKey="installment_no" paramName="schSort">#</SortLink></th>
                <th><SortLink sortKey="due_date" paramName="schSort">Due date</SortLink></th>
                <th className="num"><SortLink sortKey="opening_balance" paramName="schSort">Opening</SortLink></th>
                <th className="num"><SortLink sortKey="principal_due" paramName="schSort">Principal</SortLink></th>
                <th className="num"><SortLink sortKey="interest_due" paramName="schSort">Interest</SortLink></th>
                <th className="num"><SortLink sortKey="instalment" paramName="schSort">Instalment</SortLink></th>
                <th className="num"><SortLink sortKey="paid" paramName="schSort">Paid</SortLink></th>
                <th><SortLink sortKey="status" paramName="schSort">Status</SortLink></th>
              </tr>
            </thead>
            <tbody>
              {displaySchedule.map((s) => (
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
        ) : <EmptyState icon="📅" title="Run appraisal to generate a projected schedule" />}
      </CollapsibleCard>

      <CollapsibleCard title="Loan account activity" sub="Every entry carries the journal it posted">
        {transactions.length ? (
          <>
            <Toolbar>
              <SearchInput paramName="actQ" placeholder="Find entries — reference, document no., description or type…" />
            </Toolbar>
            <TableWrap>
              <thead>
                <tr>
                  <th><SortLink sortKey="txn_ref" paramName="actSort">Reference</SortLink></th>
                  <th><SortLink sortKey="document_no" paramName="actSort">Document No.</SortLink></th>
                  <th><SortLink sortKey="value_date" paramName="actSort">Date</SortLink></th>
                  <th><SortLink sortKey="txn_type" paramName="actSort">Type</SortLink></th>
                  <th><SortLink sortKey="description" paramName="actSort">Description</SortLink></th>
                  <th className="num"><SortLink sortKey="amount" paramName="actSort">Amount</SortLink></th>
                </tr>
              </thead>
              <tbody>
                {displayTransactions.length ? displayTransactions.map((t) => (
                  <tr key={t.id}>
                    <td className="mono">{t.txn_ref}</td>
                    <td className="mono">
                      {t.journal_id ? (
                        <JournalLink id={t.journal_id} canReverse={false} caption1={caption1} caption2={caption2}>
                          {t.document_no || '—'}
                        </JournalLink>
                      ) : (t.document_no || '—')}
                    </td>
                    <td>{formatDate(t.value_date)}</td>
                    <td><Pill status={t.txn_type} /></td>
                    <td>
                      {t.description || ''}
                      {t.bank_account_code ? (
                        <div className="tiny muted-cell">
                          {humanise(t.pay_mode || '')} · {t.bank_account_code} — {t.bank_account_name}
                          {t.cheque_no ? ` · Cheque ${t.cheque_no}${t.cheque_date ? ` (${formatDate(t.cheque_date)})` : ''}` : ''}
                          {t.reference_no ? ` · Ref ${t.reference_no}` : ''}
                        </div>
                      ) : null}
                    </td>
                    <td className="num"><Money cents={t.amount} /></td>
                  </tr>
                )) : (
                  <tr><td colSpan={6}><EmptyState icon="🔎" title="No entries match your search" /></td></tr>
                )}
              </tbody>
            </TableWrap>
          </>
        ) : <EmptyState icon="🧾" title="No postings yet" />}
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
