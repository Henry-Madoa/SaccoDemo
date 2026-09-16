import { requireAction } from '@/lib/session';
import { listMembersForStatementPicker } from '@/lib/memberStatement';
import { listActiveLoanProductsWithCharges } from '@/lib/admin';
import { LOAN_STATUSES } from '@/lib/constants';
import { listLoansForFilterPicker } from '@/lib/loanDocuments';
import { renderDocuments } from '@/lib/documentPrint';
import {
  buildLoanApplicationPrints, buildLoanAppraisalPrints, buildLoanSchedulePrints,
} from '@/lib/loanDocumentPrint';
import { Page } from '@/components/layout/page';
import { EmptyState, Tabs, Toolbar, Spacer, type TabDefinition } from '@/components/ui/primitives';
import { DateFilterExpressionInput } from '@/components/ui/filters';
import { MultiSelectFilter } from '@/components/ui/multi-select-filter';
import { DocumentActionsMenu } from '@/components/ui/document-actions';
import type { PrintDocument } from '@/lib/documentPrint';
import { PrintSheets } from '@/components/ui/print-sheets';

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

  const [loanOptionRows, memberOptionRows, productOptionRows] = await Promise.all([
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

  let docs: PrintDocument[] = [];
  if (hasFilter) {
    if (type === 'application') docs = await buildLoanApplicationPrints(selection);
    else if (type === 'appraisal') docs = await buildLoanAppraisalPrints(selection);
    else docs = await buildLoanSchedulePrints({ ...selection, expFrom: sp.expFrom, expTo: sp.expTo });
  }

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
          excel={{ href: excelForType.href, params: exportParams, disabled: !docs.length, label: excelForType.label }}
        />
      </Toolbar>

      {!hasFilter ? (
        <EmptyState
          icon="🖨" title="Select at least one filter"
          sub="Pick a loan, member, product, or status above to generate documents."
        />
      ) : !docs.length ? (
        <EmptyState icon="🔎" title="No matching loans" />
      ) : (
        // One sheet per loan — renderDocuments() emits the shared stylesheet once and breaks
        // the page between documents.
        <PrintSheets html={renderDocuments(docs)} />
      )}
    </Page>
  );
}
