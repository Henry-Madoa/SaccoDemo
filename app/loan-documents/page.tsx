import { requireAction } from '@/lib/session';
import { getOrg } from '@/lib/org';
import { imageSrc } from '@/lib/cloudinary';
import { formatDate, formatDateTime } from '@/lib/format';
import { listMembersForStatementPicker } from '@/lib/memberStatement';
import { listActiveLoanProductsWithCharges } from '@/lib/admin';
import { LOAN_STATUSES } from '@/lib/constants';
import {
  buildLoanApplicationDocuments, buildLoanAppraisalDocuments, buildLoanScheduleDocuments, listLoansForFilterPicker,
  type LoanApplicationDocument, type LoanAppraisalDocument, type LoanScheduleDocument,
} from '@/lib/loanDocuments';
import { Page } from '@/components/layout/page';
import {
  Card, CardHead, DefinitionList, EmptyState, Pill, TableWrap, Tabs, Toolbar, Spacer, type TabDefinition,
} from '@/components/ui/primitives';
import { DateFilterExpressionInput } from '@/components/ui/filters';
import { MultiSelectFilter } from '@/components/ui/multi-select-filter';
import { Money } from '@/components/ui/money';
import { DocumentActionsMenu } from '@/components/ui/document-actions';
import { AppraisalCard, AppraisalMeta, toAppraisal } from '@/components/loans/appraisal-card';
import type { Organisation } from '@/lib/types';

type DocType = 'application' | 'appraisal' | 'schedule';
const DOC_TYPES: DocType[] = ['application', 'appraisal', 'schedule'];
const TABS: TabDefinition[] = [
  { key: 'application', label: 'Loan Application' },
  { key: 'appraisal', label: 'Loan Appraisal' },
  { key: 'schedule', label: 'Repayment Schedule' },
];

const parseIds = (raw?: string): number[] =>
  (raw ? raw.split(',') : []).map(Number).filter((n) => Number.isFinite(n) && n > 0);
const parseList = (raw?: string): string[] => (raw ? raw.split(',').filter(Boolean) : []);

export default async function LoanDocumentsPage({ searchParams }: {
  searchParams: Promise<{
    type?: string; loan?: string; member?: string; product?: string; status?: string;
    appFrom?: string; appTo?: string; expFrom?: string; expTo?: string;
  }>;
}) {
  const user = await requireAction('LOAN_READ');
  const sp = await searchParams;
  const type: DocType = DOC_TYPES.includes(sp.type as DocType) ? (sp.type as DocType) : 'application';

  const loanIds = parseIds(sp.loan);
  const memberIds = parseIds(sp.member);
  const productIds = parseIds(sp.product);
  const statuses = parseList(sp.status);
  const hasFilter = !!(loanIds.length || memberIds.length || productIds.length || statuses.length);

  const [org, loanOptionRows, memberOptionRows, productOptionRows] = await Promise.all([
    getOrg(),
    listLoansForFilterPicker(),
    listMembersForStatementPicker(),
    listActiveLoanProductsWithCharges(),
  ]);

  const loanOptions = loanOptionRows.map((l) => ({ value: String(l.id), label: `${l.loan_no} — ${l.first_name} ${l.last_name}` }));
  const memberOptions = memberOptionRows.map((m) => ({ value: String(m.id), label: `${m.member_no} — ${m.first_name} ${m.last_name}` }));
  const productOptions = productOptionRows.map((p) => ({ value: String(p.id), label: `${p.code} — ${p.name}` }));
  const statusOptions = LOAN_STATUSES.map((s) => ({ value: s, label: s }));

  const selection = { loanIds, memberIds, productIds, statuses, appFrom: sp.appFrom, appTo: sp.appTo };

  const buildTabHref = (t: string) => {
    const qs = new URLSearchParams();
    if (sp.loan) qs.set('loan', sp.loan);
    if (sp.member) qs.set('member', sp.member);
    if (sp.product) qs.set('product', sp.product);
    if (sp.status) qs.set('status', sp.status);
    if (sp.appFrom) qs.set('appFrom', sp.appFrom);
    if (sp.appTo) qs.set('appTo', sp.appTo);
    if (sp.expFrom) qs.set('expFrom', sp.expFrom);
    if (sp.expTo) qs.set('expTo', sp.expTo);
    qs.set('type', t);
    return `/loan-documents?${qs}`;
  };

  let applicationDocs: LoanApplicationDocument[] = [];
  let appraisalDocs: LoanAppraisalDocument[] = [];
  let scheduleDocs: LoanScheduleDocument[] = [];
  if (hasFilter) {
    if (type === 'application') applicationDocs = await buildLoanApplicationDocuments(selection);
    else if (type === 'appraisal') appraisalDocs = await buildLoanAppraisalDocuments(selection);
    else scheduleDocs = await buildLoanScheduleDocuments({ ...selection, expFrom: sp.expFrom, expTo: sp.expTo });
  }
  const docCount = type === 'application' ? applicationDocs.length
    : type === 'appraisal' ? appraisalDocs.length : scheduleDocs.length;

  const exportParams = {
    loan: sp.loan, member: sp.member, product: sp.product, status: sp.status,
    appFrom: sp.appFrom, appTo: sp.appTo, expFrom: sp.expFrom, expTo: sp.expTo,
  };
  const excelForType = {
    application: { href: '/api/export/loan-application', label: 'Loan Application (.xlsx)' },
    appraisal: { href: '/api/export/loan-appraisals', label: 'Loan Appraisal (.xlsx)' },
    schedule: { href: '/api/export/loan-schedule', label: 'Repayment Schedule (.xlsx)' },
  }[type];

  return (
    <Page title="Loan Documents" crumb="Loan application, appraisal and repayment-schedule printouts" user={user}>
      <Tabs tabs={TABS} active={type} hrefFor={buildTabHref} />
      <Toolbar>
        <MultiSelectFilter paramName="loan" label="Loan" options={loanOptions} placeholder="Search loan no…" />
        <MultiSelectFilter paramName="member" label="Member" options={memberOptions} placeholder="Search member no. or name…" />
        <MultiSelectFilter paramName="product" label="Product" options={productOptions} placeholder="All products" />
        <MultiSelectFilter paramName="status" label="Status" options={statusOptions} placeholder="All statuses" />
        {type === 'schedule' ? (
          <DateFilterExpressionInput
            fromParam="expFrom" toParam="expTo" placeholder="Instalment date filter — e.g. 01/01/26..31/12/26"
          />
        ) : (
          <DateFilterExpressionInput
            fromParam="appFrom" toParam="appTo" placeholder="Application date filter — e.g. 01/01/26..31/12/26"
          />
        )}
        <Spacer />
        <DocumentActionsMenu
          excel={{ href: excelForType.href, params: exportParams, disabled: !docCount, label: excelForType.label }}
        />
      </Toolbar>

      {!hasFilter ? (
        <EmptyState
          icon="🖨" title="Select at least one filter"
          sub="Pick a loan, member, product, or status above to generate documents."
        />
      ) : !docCount ? (
        <EmptyState icon="🔎" title="No matching loans" />
      ) : type === 'application' ? (
        applicationDocs.map((d) => <ApplicationDoc key={d.loan.id} doc={d} org={org} />)
      ) : type === 'appraisal' ? (
        appraisalDocs.map((d) => <AppraisalDoc key={d.loan.id} doc={d} org={org} />)
      ) : (
        scheduleDocs.map((d) => <ScheduleDoc key={d.loan.id} doc={d} org={org} />)
      )}
    </Page>
  );
}

function Letterhead({ org }: { org: Organisation | undefined }) {
  const logo = imageSrc(org?.logo, { width: 72, height: 72, crop: 'fit' });
  return (
    <div className="statement-letterhead">
      {logo ? <img src={logo} alt={org?.name ?? ''} className="statement-logo" /> : null}
      <div>
        <div className="statement-org-name">{org?.name ?? '—'}</div>
        <div className="tiny">{[org?.physical_address, org?.postal_address].filter(Boolean).join(' · ')}</div>
        <div className="tiny">{[org?.phone_primary, org?.email, org?.website].filter(Boolean).join(' · ')}</div>
      </div>
    </div>
  );
}

function Signature({ url, label }: { url: string | null; label: string }) {
  const src = imageSrc(url, { width: 180, height: 70, crop: 'fit' });
  if (!src) return <div className="tiny">No signature on file</div>;
  return <img src={src} alt={`${label} signature`} className="signature-img" />;
}

/* -------------------------------------------------------------- Loan Application */

function ApplicationDoc({ doc, org }: { doc: LoanApplicationDocument; org: Organisation | undefined }) {
  const {
    loan: l, applicant: m, age, disbursement, guarantors, amountInWords,
  } = doc;
  const fullName = [m.first_name, m.middle_name, m.last_name].filter(Boolean).join(' ');

  return (
    <div className="loan-doc-block">
      <Card>
        <Letterhead org={org} />
        <CardHead title="Loan Application Form" sub={`Loan ${l.loan_no} · applied ${formatDate(l.applied_date)}`} />
        <div className="grid split-side-sm">
          <DefinitionList items={[
            ['Applicant', fullName],
            ['Member No.', l.member_no],
            ['ID No.', m.identification_no || '—'],
            ['Age', age != null ? `${age} years` : '—'],
            ['Phone', m.phone || '—'],
            ['Email', m.email || '—'],
          ]}
          />
          <DefinitionList items={[
            ['Staff / Payroll No.', m.staff_no || '—'],
            ['Employer', m.employer || '—'],
          ]}
          />
        </div>
      </Card>

      <Card>
        <CardHead title="Loan terms" />
        <div className="grid split-side-sm">
          <DefinitionList items={[
            ['Product', l.product_name],
            ['Amount applied for', <Money cents={l.principal} />],
            ['Term', `${l.term_months} months`],
            ['Interest', `${l.interest_rate}% ${l.interest_method.toLowerCase()}`],
          ]}
          />
          <DefinitionList items={[
            ['Monthly instalment', <Money cents={l.installment} />],
            ['Total interest', <Money cents={l.total_interest} />],
            ['Purpose', l.purpose || '—'],
            ['Amount in words', amountInWords],
          ]}
          />
        </div>
      </Card>

      <Card>
        <CardHead title="Disbursement" />
        <DefinitionList items={[[
          'Account',
          disbursement ? `${disbursement.accountNo} — ${disbursement.productName}` : 'Cash / bank disbursement',
        ]]}
        />
      </Card>

      <Card>
        <CardHead title="Guarantors" sub={`${guarantors.length} committed`} />
        {guarantors.length ? (
          <TableWrap className="statement-ledger">
            <thead>
              <tr>
                <th>Member No.</th><th>Name</th><th>Phone</th><th>ID No.</th>
                <th className="num">Guaranteed</th><th>Signature</th>
              </tr>
            </thead>
            <tbody>
              {guarantors.map((g) => (
                <tr key={g.id}>
                  <td className="mono">{g.member_no}</td>
                  <td>{g.first_name} {g.last_name}</td>
                  <td>{g.phone || '—'}</td>
                  <td className="mono">{g.identification_no || '—'}</td>
                  <td className="num"><Money cents={g.amount} /></td>
                  <td><Signature url={g.signature_image} label={`${g.first_name} ${g.last_name}`} /></td>
                </tr>
              ))}
            </tbody>
          </TableWrap>
        ) : <EmptyState icon="🤝" title="No guarantors committed" />}
      </Card>

      <Card>
        <CardHead title="Member's signature" />
        <Signature url={m.signature_image} label={fullName} />
      </Card>
    </div>
  );
}

/* -------------------------------------------------------------------- Loan Appraisal */

function AppraisalDoc({ doc, org }: { doc: LoanAppraisalDocument; org: Organisation | undefined }) {
  const {
    loan: l, applicant: m, age, appraisal, guarantors, collateral, existingLoans, charges, approvals,
  } = doc;
  const fullName = [m.first_name, m.middle_name, m.last_name].filter(Boolean).join(' ');

  return (
    <div className="loan-doc-block">
      <Card>
        <Letterhead org={org} />
        <CardHead title="Loan Appraisal" sub={`Loan ${l.loan_no} · ${l.product_name}`} />
        <div className="grid split-side-sm">
          <DefinitionList items={[
            ['Applicant', fullName],
            ['Member No.', l.member_no],
            ['ID No.', m.identification_no || '—'],
            ['Age', age != null ? `${age} years` : '—'],
          ]}
          />
          <DefinitionList items={[
            ['Staff / Payroll No.', m.staff_no || '—'],
            ['Applied amount', <Money cents={l.principal} />],
            ['Term', `${l.term_months} months`],
          ]}
          />
        </div>
      </Card>

      {appraisal ? (
        <>
          <Card><AppraisalMeta appraisal={appraisal} /></Card>
          <AppraisalCard appraisal={toAppraisal(appraisal)} />
        </>
      ) : (
        <Card><EmptyState icon="🧮" title="Not yet appraised" /></Card>
      )}

      <Card>
        <CardHead title="Guarantor coverage" />
        {guarantors.length ? (
          <TableWrap>
            <thead><tr><th>Member</th><th className="num">Guaranteed</th><th>Status</th></tr></thead>
            <tbody>
              {guarantors.map((g) => (
                <tr key={g.id}>
                  <td>{g.first_name} {g.last_name} <span className="mono tiny">({g.member_no})</span></td>
                  <td className="num"><Money cents={g.amount} /></td>
                  <td><Pill status={g.status} /></td>
                </tr>
              ))}
            </tbody>
          </TableWrap>
        ) : <EmptyState icon="🤝" title="No guarantors" />}
      </Card>

      <Card>
        <CardHead title="Security coverage" />
        {collateral.length ? (
          <TableWrap>
            <thead><tr><th>Collateral</th><th className="num">Cover</th><th>Status</th></tr></thead>
            <tbody>
              {collateral.map((c) => (
                <tr key={c.id}>
                  <td className="mono">{c.collateral_no}<div className="tiny">{c.collateral_description || '—'}</div></td>
                  <td className="num"><Money cents={c.guarantee} /></td>
                  <td><Pill status={c.status} /></td>
                </tr>
              ))}
            </tbody>
          </TableWrap>
        ) : <EmptyState icon="🏠" title="No collateral attached" />}
      </Card>

      <Card>
        <CardHead title="Existing loan exposure" sub="The member's other disbursed loans" />
        {existingLoans.length ? (
          <TableWrap>
            <thead>
              <tr>
                <th>Loan No.</th><th>Product</th><th>Disbursed</th><th className="num">Instalment</th>
                <th className="num">Balance</th><th className="num">Arrears</th><th>Class</th>
              </tr>
            </thead>
            <tbody>
              {existingLoans.map((x) => (
                <tr key={x.loan_no}>
                  <td className="mono">{x.loan_no}</td>
                  <td>{x.product_name}</td>
                  <td>{formatDate(x.disbursed_date)}</td>
                  <td className="num"><Money cents={x.installment} /></td>
                  <td className="num"><Money cents={x.balance} /></td>
                  <td className="num"><Money cents={x.arrears_amount} /></td>
                  <td><Pill status={x.classification} /></td>
                </tr>
              ))}
            </tbody>
          </TableWrap>
        ) : <EmptyState icon="📄" title="No other disbursed loans" />}
      </Card>

      <Card>
        <CardHead title="Loan charges" />
        {charges.length ? (
          <TableWrap>
            <thead><tr><th>Code</th><th>Description</th><th className="num">Amount</th></tr></thead>
            <tbody>
              {charges.map((c) => (
                <tr key={c.chargeId}>
                  <td className="mono">{c.chargeCode}</td>
                  <td>{c.chargeDescription}</td>
                  <td className="num"><Money cents={c.amount} /></td>
                </tr>
              ))}
            </tbody>
          </TableWrap>
        ) : <EmptyState icon="🧾" title="No charges configured" />}
      </Card>

      <Card>
        <CardHead title="Approval trail" sub={`${approvals.length} step${approvals.length === 1 ? '' : 's'} routed`} />
        {approvals.length ? (
          <TableWrap>
            <thead><tr><th>Sent by</th><th>Sent</th><th>Approver</th><th>Decided</th><th>Status</th></tr></thead>
            <tbody>
              {approvals.flatMap((t) => [
                ...t.level_decisions.map((ld, i) => (
                  <tr key={`${t.id}-l-${i}`} className="muted">
                    <td>—</td>
                    <td>—</td>
                    <td className="muted-cell">
                      Level {ld.sequence}: {ld.decided_by}{ld.comment ? ` — "${ld.comment}"` : ''}
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
  );
}

/* ------------------------------------------------------------ Loan Repayment Schedule */

function ScheduleDoc({ doc, org }: { doc: LoanScheduleDocument; org: Organisation | undefined }) {
  const { loan: l, rows, totals } = doc;

  return (
    <div className="loan-doc-block">
      <Card>
        <Letterhead org={org} />
        <CardHead
          title="Loan Repayment Schedule"
          sub={`Loan ${l.loan_no} · ${l.first_name} ${l.last_name} (${l.member_no}) · ${l.product_name}`}
        />
        <div className="grid split-side-sm">
          <DefinitionList items={[
            ['Principal disbursed', <Money cents={l.principal} />],
            ['Term', `${l.term_months} months`],
          ]}
          />
          <DefinitionList items={[
            ['Interest', `${l.interest_rate}% ${l.interest_method.toLowerCase()}`],
            ['Monthly instalment', <Money cents={l.installment} />],
          ]}
          />
        </div>
      </Card>

      <Card>
        {rows.length ? (
          <TableWrap className="statement-ledger">
            <thead>
              <tr>
                <th className="num">#</th><th>Due date</th><th className="num">Opening</th>
                <th className="num">Principal</th><th className="num">Interest</th><th className="num">Instalment</th>
                <th className="num">Paid</th><th className="num">Balance</th><th>Status</th>
              </tr>
            </thead>
            <tbody>
              {rows.map((r) => (
                <tr key={r.id}>
                  <td className="num">{r.installment_no}</td>
                  <td>{formatDate(r.due_date)}</td>
                  <td className="num"><Money cents={r.opening_balance} symbol={false} /></td>
                  <td className="num"><Money cents={r.principal_due} symbol={false} /></td>
                  <td className="num"><Money cents={r.interest_due} symbol={false} /></td>
                  <td className="num"><b><Money cents={r.principal_due + r.interest_due} symbol={false} /></b></td>
                  <td className="num"><Money cents={r.principal_paid + r.interest_paid} symbol={false} /></td>
                  <td className="num"><Money cents={r.closingBalance} symbol={false} /></td>
                  <td><Pill status={r.status} /></td>
                </tr>
              ))}
            </tbody>
            <tfoot>
              <tr>
                <td colSpan={3}>Totals</td>
                <td className="num"><Money cents={totals.principal} symbol={false} /></td>
                <td className="num"><Money cents={totals.interest} symbol={false} /></td>
                <td className="num"><Money cents={totals.instalment} symbol={false} /></td>
                <td className="num"><Money cents={totals.paid} symbol={false} /></td>
                <td className="num"><b><Money cents={totals.outstanding} symbol={false} /></b></td>
                <td />
              </tr>
            </tfoot>
          </TableWrap>
        ) : (
          <EmptyState icon="📅" title="No schedule in the selected window" sub="The schedule is generated on disbursement." />
        )}
      </Card>
    </div>
  );
}
