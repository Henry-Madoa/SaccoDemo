import { notFound } from 'next/navigation';
import { requireAction, currentCanAction } from '@/lib/session';
import { parseFilters } from '@/lib/listFilters';
import { parseSort } from '@/lib/listSort';
import { listPostableAccounts, listActiveBankAccounts } from '@/lib/gl';
import { listItems } from '@/lib/items';
import { listActiveLocations } from '@/lib/inventorySetup';
import { listFixedAssets } from '@/lib/fixedAssets';
import {
  listCustomers, hasAnyCustomers, CUSTOMER_FILTER_FIELDS, listActiveCustomers, getCustomerLedgerEntries,
} from '@/lib/customers';
import {
  listSalesDocuments, hasAnySalesDocuments, SALES_DOC_FILTER_FIELDS,
} from '@/lib/salesDocuments';
import { listCashReceipts, hasAnyCashReceipts } from '@/lib/cashReceipts';
import { listReminders, hasAnyReminders } from '@/lib/reminders';
import {
  listCustomerPostingGroups, listPaymentTerms, listPaymentMethods, listActivePaymentTerms, listActivePaymentMethods,
  listReminderTerms, listReminderLevels, listFinanceChargeTerms, listActiveReminderTerms, listActiveFinanceChargeTerms,
  getSalesReceivablesSetup,
} from '@/lib/receivablesSetup';
import { getAgedAccountsReceivable, AGED_AR_FILTER_FIELDS } from '@/lib/receivablesReports';
import { findPendingRoutedTask } from '@/lib/workflow';
import { Page } from '@/components/layout/page';
import {
  Card, CardHead, EmptyState, Pill, TableWrap, Tabs, Toolbar, Spacer, type TabDefinition,
} from '@/components/ui/primitives';
import { SearchInput } from '@/components/ui/filters';
import { DynamicFilterBar } from '@/components/ui/dynamic-filter';
import { SortLink } from '@/components/ui/sort-link';
import { Money } from '@/components/ui/money';
import { ExportButton } from '@/components/ui/export-button';
import { formatDate } from '@/lib/format';
import type { SalesDocumentType } from '@/lib/types';
import {
  CustomerFormButton, CustomerPostingGroupFormButton, PaymentTermsFormButton, PaymentMethodFormButton,
  FinanceChargeTermsFormButton, ReminderTermsFormButton, SalesReceivablesSetupButton,
} from '../receivables-forms';
import { NewSalesDocumentButton } from '../sales-document-form';
import {
  MakeOrderButton, SubmitDocButton, CancelApprovalButton, ApproveDocButton, RejectDocButton, ReopenDocButton,
  DeleteDocButton, PostSalesDocButton, PostCashReceiptButton, IssueReminderButton,
} from '../document-actions';
import { NewCashReceiptButton } from '../cash-receipt-form';
import { ReminderBatchPanel } from '../reminder-batch';
import { ApplyEntriesButton, UnapplyButton } from '../apply-entries';
import { CustomerStatementPanel } from '../statement-panel';

const TABS: TabDefinition[] = [
  { key: 'customers', label: 'Customers' },
  { key: 'quotes', label: 'Quotes' },
  { key: 'orders', label: 'Orders' },
  { key: 'sales-invoices', label: 'Sales Invoices' },
  { key: 'credit-memos', label: 'Credit Memos' },
  { key: 'posted-documents', label: 'Posted' },
  { key: 'cash-receipts', label: 'Cash Receipts' },
  { key: 'reminders', label: 'Reminders' },
  { key: 'finance-charges', label: 'Finance Charges' },
  { key: 'ledger-entries', label: 'Cust. Ledger' },
  { key: 'aged-ar', label: 'Aged AR' },
  { key: 'statement', label: 'Statement' },
  { key: 'posting-groups', label: 'Posting Groups' },
  { key: 'payment-terms', label: 'Payment Terms' },
  { key: 'payment-methods', label: 'Payment Methods' },
  { key: 'reminder-terms', label: 'Reminder Terms' },
  { key: 'setup', label: 'Setup' },
];

export default async function ReceivablesPage({ params, searchParams }: {
  params: Promise<{ tab?: string[] }>;
  searchParams: Promise<{ q?: string; filters?: string; sort?: string; view?: string; customer?: string; asOf?: string; from?: string; to?: string }>;
}) {
  const user = await requireAction('RECEIVABLES_READ');
  const { tab: segments } = await params;
  const sp = await searchParams;
  const tab = segments?.[0] ?? 'customers';
  if (!TABS.some((t) => t.key === tab)) notFound();

  return (
    <Page title="Receivables" crumb="Customers, sales invoices, cash receipts, reminders and aging" user={user}>
      <Tabs tabs={TABS} active={tab} hrefFor={(k) => `/receivables/${k === 'customers' ? '' : k}`} />
      {tab === 'customers' ? <CustomersTab search={sp.q ?? ''} filtersRaw={sp.filters} sortRaw={sp.sort} /> : null}
      {tab === 'quotes' ? <SalesDocTab documentType="Quote" search={sp.q ?? ''} filtersRaw={sp.filters} sortRaw={sp.sort} username={user.username} /> : null}
      {tab === 'orders' ? <SalesDocTab documentType="Order" search={sp.q ?? ''} filtersRaw={sp.filters} sortRaw={sp.sort} username={user.username} /> : null}
      {tab === 'sales-invoices' ? <SalesDocTab documentType="Invoice" search={sp.q ?? ''} filtersRaw={sp.filters} sortRaw={sp.sort} username={user.username} /> : null}
      {tab === 'credit-memos' ? <SalesDocTab documentType="Credit Memo" search={sp.q ?? ''} filtersRaw={sp.filters} sortRaw={sp.sort} username={user.username} /> : null}
      {tab === 'posted-documents' ? <PostedDocsTab search={sp.q ?? ''} /> : null}
      {tab === 'cash-receipts' ? <CashReceiptsTab search={sp.q ?? ''} username={user.username} /> : null}
      {tab === 'reminders' ? <RemindersTab kind="Reminder" search={sp.q ?? ''} /> : null}
      {tab === 'finance-charges' ? <RemindersTab kind="Finance Charge Memo" search={sp.q ?? ''} /> : null}
      {tab === 'ledger-entries' ? <LedgerTab /> : null}
      {tab === 'aged-ar' ? <AgedArTab asOf={sp.asOf} filtersRaw={sp.filters} /> : null}
      {tab === 'statement' ? <StatementTab customerNo={sp.customer} from={sp.from} to={sp.to} /> : null}
      {tab === 'posting-groups' ? <PostingGroupsTab /> : null}
      {tab === 'payment-terms' ? <PaymentTermsTab /> : null}
      {tab === 'payment-methods' ? <PaymentMethodsTab /> : null}
      {tab === 'reminder-terms' ? <ReminderTermsTab /> : null}
      {tab === 'setup' ? <SetupTab /> : null}
    </Page>
  );
}

async function customerFormProps() {
  const [postingGroups, paymentTerms, paymentMethods, reminderTerms, finChargeTerms] = await Promise.all([
    listCustomerPostingGroups(), listPaymentTerms(), listPaymentMethods(), listReminderTerms(), listFinanceChargeTerms(),
  ]);
  return { postingGroups, paymentTerms, paymentMethods, reminderTerms, finChargeTerms };
}

/* ------------------------------------------------------------------ Customers */

async function CustomersTab({ search, filtersRaw, sortRaw }: { search: string; filtersRaw?: string; sortRaw?: string }) {
  const filters = parseFilters(filtersRaw);
  const sort = parseSort(sortRaw);
  const [rows, empty, canManage, fp] = await Promise.all([
    listCustomers({ search, filters, sort }),
    hasAnyCustomers().then((a) => !a),
    currentCanAction('RECEIVABLES_CUSTOMER_MANAGE'),
    customerFormProps(),
  ]);
  const fields = CUSTOMER_FILTER_FIELDS.map((f) =>
    (f.key === 'customer_posting_group_code' ? { ...f, options: fp.postingGroups.map((g) => ({ value: g.code, label: g.code })) } : f));

  return (
    <>
      <Toolbar>
        <SearchInput placeholder="Search customer no., name, city…" disabled={empty} />
        <DynamicFilterBar fields={fields} disabled={empty} />
        <Spacer />
        {canManage ? <CustomerFormButton {...fp}>New customer</CustomerFormButton> : null}
      </Toolbar>
      <Card>
        {rows.length ? (
          <TableWrap>
            <thead>
              <tr>
                <th><SortLink sortKey="no">No.</SortLink></th>
                <th><SortLink sortKey="name">Name</SortLink></th>
                <th><SortLink sortKey="city">City</SortLink></th>
                <th>Posting group</th>
                <th>Terms</th>
                <th className="num"><SortLink sortKey="balance">Balance</SortLink></th>
                <th className="num"><SortLink sortKey="balance_due">Overdue</SortLink></th>
                <th>Status</th>
                <th />
              </tr>
            </thead>
            <tbody>
              {rows.map((c) => (
                <tr key={c.id}>
                  <td className="mono">{c.no}</td>
                  <td>{c.name}</td>
                  <td className="muted-cell">{c.city ?? '—'}</td>
                  <td className="mono muted-cell">{c.customer_posting_group_code ?? '—'}</td>
                  <td className="mono muted-cell">{c.payment_terms_code ?? '—'}</td>
                  <td className="num"><Money cents={c.balance} /></td>
                  <td className="num">{c.balance_due > 0 ? <span className="bad"><Money cents={c.balance_due} /></span> : <Money cents={0} />}</td>
                  <td>
                    {c.blocked ? <Pill tone="bad">Blocked: {c.blocked}</Pill>
                      : c.credit_limit_exceeded ? <Pill tone="warn">Over limit</Pill>
                        : <Pill status="ok">Active</Pill>}
                  </td>
                  <td className="num">{canManage ? <CustomerFormButton customer={c} {...fp} className="btn sm ghost">Edit</CustomerFormButton> : null}</td>
                </tr>
              ))}
            </tbody>
          </TableWrap>
        ) : <EmptyState icon="👤" title={empty ? 'No customers yet' : 'No customers match'} />}
      </Card>
    </>
  );
}

/* ------------------------------------------------------------ Sales Documents */

async function SalesDocTab({ documentType, search, filtersRaw, sortRaw, username }: {
  documentType: SalesDocumentType; search: string; filtersRaw?: string; sortRaw?: string; username: string;
}) {
  const filters = parseFilters(filtersRaw);
  const sort = parseSort(sortRaw);
  const [rows, empty, canCreate, canApprove, canPost, customers, accounts, items, fixedAssets, locations, paymentTerms, paymentMethods] = await Promise.all([
    listSalesDocuments({ documentType, search, filters, sort }),
    hasAnySalesDocuments(documentType).then((a) => !a),
    currentCanAction('RECEIVABLES_SALES_CREATE'),
    currentCanAction('RECEIVABLES_SALES_APPROVE'),
    currentCanAction('RECEIVABLES_SALES_POST'),
    listActiveCustomers(),
    listPostableAccounts(),
    listItems(),
    listFixedAssets(),
    listActiveLocations(),
    listActivePaymentTerms(),
    listActivePaymentMethods(),
  ]);
  const routed = new Map(await Promise.all(
    rows.filter((r) => r.status === 'Pending Approval').map((r) => findPendingRoutedTask('SALES_DOCUMENT', r.no).then((t) => [r.no, !!t] as const)),
  ));
  const fields = SALES_DOC_FILTER_FIELDS.map((f) =>
    (f.key === 'customer_id' ? { ...f, options: customers.map((c) => ({ value: c.id, label: `${c.no} — ${c.name}` })) } : f));
  const formProps = {
    customers, paymentTerms, paymentMethods,
    accounts: accounts.map((a) => ({ code: a.code, name: a.name })),
    items: items.map((i) => ({ no: i.no, description: i.description })),
    fixedAssets: fixedAssets.filter((a) => !a.disposed).map((a) => ({ no: a.no, description: a.description })),
    locations: locations.map((l) => ({ code: l.code, name: l.name })),
  };

  return (
    <>
      <Toolbar>
        <SearchInput placeholder="Search no., customer, reference…" disabled={empty} />
        <DynamicFilterBar fields={fields} disabled={empty} />
        <Spacer />
        {canCreate && documentType !== 'Order' ? <NewSalesDocumentButton documentType={documentType} {...formProps} /> : null}
      </Toolbar>
      <Card>
        {rows.length ? (
          <TableWrap>
            <thead>
              <tr>
                <th><SortLink sortKey="no">No.</SortLink></th>
                <th><SortLink sortKey="customer">Customer</SortLink></th>
                <th className="num"><SortLink sortKey="amount">Amount</SortLink></th>
                <th><SortLink sortKey="posting_date">Posting date</SortLink></th>
                <th><SortLink sortKey="due_date">Due date</SortLink></th>
                <th><SortLink sortKey="status">Status</SortLink></th>
                <th className="num" />
              </tr>
            </thead>
            <tbody>
              {rows.map((d) => {
                const isOwn = d.created_by === username;
                return (
                  <tr key={d.no}>
                    <td className="mono">{d.no}</td>
                    <td>{d.customer_no} <span className="tiny muted-cell">{d.customer_name}</span></td>
                    <td className="num"><Money cents={d.amount} /></td>
                    <td>{formatDate(d.posting_date)}</td>
                    <td>{d.due_date ? formatDate(d.due_date) : '—'}</td>
                    <td><Pill status={d.status} /></td>
                    <td className="num">
                      <div className="inline" style={{ justifyContent: 'flex-end' }}>
                        {documentType === 'Quote' && d.status === 'Open' && canCreate ? <MakeOrderButton no={d.no} /> : null}
                        {d.status === 'Open' && canCreate && isOwn && documentType !== 'Quote' ? <SubmitDocButton no={d.no} kind="sales" /> : null}
                        {d.status === 'Open' && canCreate && isOwn ? <DeleteDocButton no={d.no} kind="sales" /> : null}
                        {d.status === 'Pending Approval' && canCreate && isOwn && !routed.get(d.no) ? <CancelApprovalButton no={d.no} kind="sales" /> : null}
                        {d.status === 'Pending Approval' && (canApprove || routed.get(d.no)) ? (<><ApproveDocButton no={d.no} kind="sales" /><RejectDocButton no={d.no} kind="sales" /></>) : null}
                        {d.status === 'Released' && canApprove ? <ReopenDocButton no={d.no} kind="sales" /> : null}
                        {d.status === 'Released' && canPost ? <PostSalesDocButton no={d.no} isOrder={documentType === 'Order'} /> : null}
                      </div>
                    </td>
                  </tr>
                );
              })}
            </tbody>
          </TableWrap>
        ) : <EmptyState icon="📄" title={empty ? `No sales ${documentType.toLowerCase()}s yet` : 'No documents match'} />}
      </Card>
    </>
  );
}

async function PostedDocsTab({ search }: { search: string }) {
  const { all } = await import('@/lib/db');
  const rows = await all<{
    id: number; document_type: string; no: string; posting_date: string; amount: number;
    customer_no: string; customer_name: string; order_no: string | null;
  }>(
    `SELECT d.id, d.document_type, d.no, d.posting_date, d.amount, d.order_no, c.no AS customer_no, c.name AS customer_name
     FROM posted_sales_document d JOIN customer c ON c.id = d.customer_id
     WHERE d.no LIKE @like OR c.no LIKE @like OR c.name LIKE @like
     ORDER BY d.id DESC LIMIT 500`,
    { like: `%${String(search).trim()}%` },
  );
  return (
    <>
      <Toolbar><SearchInput placeholder="Search posted document no. or customer…" /><Spacer /></Toolbar>
      <Card>
        <CardHead title="Posted Sales Documents" sub="Shipments, invoices and credit memos — the immutable record behind the customer ledger" />
        {rows.length ? (
          <TableWrap>
            <thead><tr><th>No.</th><th>Type</th><th>Customer</th><th>Order</th><th>Date</th><th className="num">Amount</th></tr></thead>
            <tbody>
              {rows.map((r) => (
                <tr key={r.id}>
                  <td className="mono">{r.no}</td>
                  <td>{r.document_type}</td>
                  <td>{r.customer_no} <span className="tiny muted-cell">{r.customer_name}</span></td>
                  <td className="mono muted-cell">{r.order_no ?? '—'}</td>
                  <td>{formatDate(r.posting_date)}</td>
                  <td className="num"><Money cents={r.amount} /></td>
                </tr>
              ))}
            </tbody>
          </TableWrap>
        ) : <EmptyState icon="📄" title="Nothing posted yet" />}
      </Card>
    </>
  );
}

/* ------------------------------------------------------------- Cash Receipts */

async function CashReceiptsTab({ search, username }: { search: string; username: string }) {
  const [rows, empty, canCreate, canPost, banks, customers, paymentMethods] = await Promise.all([
    listCashReceipts({ search }),
    hasAnyCashReceipts().then((a) => !a),
    currentCanAction('RECEIVABLES_CASH_RECEIPT_CREATE'),
    currentCanAction('RECEIVABLES_CASH_RECEIPT_POST'),
    listActiveBankAccounts(),
    listActiveCustomers(),
    listActivePaymentMethods(),
  ]);
  const routed = new Map(await Promise.all(
    rows.filter((r) => r.status === 'Pending Approval').map((r) => findPendingRoutedTask('CASH_RECEIPT', r.no).then((t) => [r.no, !!t] as const)),
  ));
  return (
    <>
      <Toolbar>
        <SearchInput placeholder="Search receipt no. or description…" disabled={empty} />
        <Spacer />
        {canCreate ? <NewCashReceiptButton banks={banks.map((b) => ({ id: b.id, code: b.code, name: b.name }))} customers={customers} paymentMethods={paymentMethods} /> : null}
      </Toolbar>
      <Card>
        {rows.length ? (
          <TableWrap>
            <thead><tr><th>No.</th><th>Bank</th><th className="num">Total</th><th>Lines</th><th>Posting date</th><th>Status</th><th className="num" /></tr></thead>
            <tbody>
              {rows.map((r) => {
                const isOwn = r.created_by === username;
                return (
                  <tr key={r.no} className={r.status === 'Processed' ? 'muted' : undefined}>
                    <td className="mono">{r.no}</td>
                    <td className="mono muted-cell">{r.bank_account_code}</td>
                    <td className="num"><Money cents={r.total_amount} /></td>
                    <td>{r.line_count}</td>
                    <td>{formatDate(r.posting_date)}</td>
                    <td><Pill status={r.status} /></td>
                    <td className="num">
                      <div className="inline" style={{ justifyContent: 'flex-end' }}>
                        {r.status === 'Open' && canCreate && isOwn ? (<><SubmitDocButton no={r.no} kind="cash" /><DeleteDocButton no={r.no} kind="cash" /></>) : null}
                        {r.status === 'Pending Approval' && canCreate && isOwn && !routed.get(r.no) ? <CancelApprovalButton no={r.no} kind="cash" /> : null}
                        {r.status === 'Pending Approval' && (canPost || routed.get(r.no)) ? (<><ApproveDocButton no={r.no} kind="cash" /><RejectDocButton no={r.no} kind="cash" /></>) : null}
                        {r.status === 'Approved' && !r.posted && canPost ? (<><ReopenDocButton no={r.no} kind="cash" /><PostCashReceiptButton no={r.no} /></>) : null}
                      </div>
                    </td>
                  </tr>
                );
              })}
            </tbody>
          </TableWrap>
        ) : <EmptyState icon="💰" title={empty ? 'No cash receipts yet' : 'No receipts match'} />}
      </Card>
    </>
  );
}

/* -------------------------------------------------------------- Reminders */

async function RemindersTab({ kind, search }: { kind: 'Reminder' | 'Finance Charge Memo'; search: string }) {
  const [rows, empty, canManage, customers] = await Promise.all([
    listReminders({ documentType: kind, search }),
    hasAnyReminders(kind).then((a) => !a),
    currentCanAction('RECEIVABLES_REMINDER_MANAGE'),
    listActiveCustomers(),
  ]);
  return (
    <>
      {canManage ? (
        <Card>
          <CardHead title={kind === 'Reminder' ? 'Create Reminders' : 'Create Finance Charge Memos'} sub="Business Central Report 188 / 190 — drafts one document per customer with overdue open entries" />
          <ReminderBatchPanel customers={customers} kind={kind === 'Reminder' ? 'reminder' : 'finance-charge'} />
        </Card>
      ) : null}
      <Toolbar><SearchInput placeholder="Search no. or customer…" disabled={empty} /><Spacer /></Toolbar>
      <Card>
        {rows.length ? (
          <TableWrap>
            <thead><tr><th>No.</th><th>Customer</th><th>Level</th><th className="num">Overdue</th><th className="num">Interest</th><th className="num">Fee</th><th>Status</th><th className="num" /></tr></thead>
            <tbody>
              {rows.map((r) => (
                <tr key={r.no} className={r.status === 'Issued' ? 'muted' : undefined}>
                  <td className="mono">{r.no}</td>
                  <td>{r.customer_no} <span className="tiny muted-cell">{r.customer_name}</span></td>
                  <td>{kind === 'Reminder' ? r.reminder_level : '—'}</td>
                  <td className="num"><Money cents={r.remaining_amount} /></td>
                  <td className="num"><Money cents={r.interest_amount} /></td>
                  <td className="num"><Money cents={r.additional_fee} /></td>
                  <td><Pill status={r.status === 'Issued' ? 'ok' : ''}>{r.status}</Pill></td>
                  <td className="num">
                    <div className="inline" style={{ justifyContent: 'flex-end' }}>
                      {r.status === 'Open' && canManage ? (<><IssueReminderButton no={r.no} /><DeleteDocButton no={r.no} kind="reminder" /></>) : null}
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </TableWrap>
        ) : <EmptyState icon="⏰" title={empty ? `No ${kind.toLowerCase()}s yet` : 'Nothing matches'} />}
      </Card>
    </>
  );
}

/* -------------------------------------------------------------- Cust. Ledger */

async function LedgerTab() {
  const [rows, canApply] = await Promise.all([
    getCustomerLedgerEntries(),
    currentCanAction('RECEIVABLES_APPLY_ENTRIES'),
  ]);
  return (
    <Card>
      <CardHead title="Cust. Ledger Entries" sub="Every invoice, credit memo, payment, reminder and finance charge posted against a customer" />
      {rows.length ? (
        <TableWrap>
          <thead><tr><th>Date</th><th>Customer</th><th>Type</th><th>Document</th><th>Due</th><th className="num">Amount</th><th className="num">Remaining</th><th>Open</th><th className="num" /></tr></thead>
          <tbody>
            {rows.map((e) => (
              <tr key={e.id} className={e.open ? undefined : 'muted'}>
                <td>{formatDate(e.posting_date)}</td>
                <td>{e.customer_no} <span className="tiny muted-cell">{e.customer_name}</span></td>
                <td>{e.document_type}</td>
                <td className="mono">{e.document_no}</td>
                <td>{e.due_date ? formatDate(e.due_date) : '—'}</td>
                <td className="num"><Money cents={e.amount} /></td>
                <td className="num"><Money cents={e.remaining_amount} /></td>
                <td>{e.open ? <Pill tone="warn">Open</Pill> : <Pill status="ok">Closed</Pill>}</td>
                <td className="num">
                  <div className="inline" style={{ justifyContent: 'flex-end' }}>
                    {e.open && canApply ? <ApplyEntriesButton entry={e} /> : null}
                    {!e.open && canApply ? <UnapplyButton entryId={e.id} /> : null}
                  </div>
                </td>
              </tr>
            ))}
          </tbody>
        </TableWrap>
      ) : <EmptyState icon="📄" title="No customer ledger entries yet" />}
    </Card>
  );
}

/* ---------------------------------------------------------------- Aged AR */

async function AgedArTab({ asOf, filtersRaw }: { asOf?: string; filtersRaw?: string }) {
  const filters = parseFilters(filtersRaw);
  const [report, postingGroups] = await Promise.all([
    getAgedAccountsReceivable({ asOf, filters }),
    listCustomerPostingGroups(),
  ]);
  const fields = AGED_AR_FILTER_FIELDS.map((f) =>
    (f.key === 'customer_posting_group_code' ? { ...f, options: postingGroups.map((g) => ({ value: g.code, label: g.code })) } : f));
  return (
    <>
      <Toolbar>
        <form className="inline" style={{ gap: 8 }}>
          <input type="date" name="asOf" defaultValue={report.as_of} aria-label="As of date" />
          <button type="submit" className="btn sm">Refresh</button>
        </form>
        <DynamicFilterBar fields={fields} />
        <Spacer />
        <ExportButton href="/api/export/aged-ar" params={{ asOf: report.as_of, filters: filtersRaw }} disabled={!report.rows.length} />
      </Toolbar>
      <Card>
        <CardHead title="Aged Accounts Receivable" sub={`As of ${formatDate(report.as_of)}, aged by ${report.aging_by.toLowerCase()}`} />
        {report.rows.length ? (
          <TableWrap>
            <thead>
              <tr>
                <th>Customer</th><th className="num">Balance</th>
                {report.bucket_labels.map((l) => <th key={l} className="num">{l}</th>)}
              </tr>
            </thead>
            <tbody>
              {report.rows.map((r) => (
                <tr key={r.customer_id}>
                  <td>{r.customer_no} <span className="tiny muted-cell">{r.customer_name}</span></td>
                  <td className="num"><Money cents={r.balance} /></td>
                  <td className="num"><Money cents={r.not_due} /></td>
                  <td className="num"><Money cents={r.bucket_1} /></td>
                  <td className="num"><Money cents={r.bucket_2} /></td>
                  <td className="num"><Money cents={r.bucket_3} /></td>
                  <td className="num"><Money cents={r.bucket_over} /></td>
                </tr>
              ))}
            </tbody>
            <tfoot>
              <tr>
                <td>Totals</td>
                <td className="num"><Money cents={report.totals.balance} /></td>
                <td className="num"><Money cents={report.totals.not_due} /></td>
                <td className="num"><Money cents={report.totals.bucket_1} /></td>
                <td className="num"><Money cents={report.totals.bucket_2} /></td>
                <td className="num"><Money cents={report.totals.bucket_3} /></td>
                <td className="num"><Money cents={report.totals.bucket_over} /></td>
              </tr>
            </tfoot>
          </TableWrap>
        ) : <EmptyState icon="📊" title="No open receivables" />}
      </Card>
    </>
  );
}

async function StatementTab({ customerNo, from, to }: { customerNo?: string; from?: string; to?: string }) {
  const customers = await listActiveCustomers();
  return (
    <Card>
      <CardHead title="Customer Statement" sub="Business Central Report 116 — opening balance, movements and closing balance for a date range" />
      <CustomerStatementPanel customers={customers} customerNo={customerNo} from={from} to={to} />
    </Card>
  );
}

/* ----------------------------------------------------------------- Setup tabs */

async function PostingGroupsTab() {
  const [rows, canManage, accounts] = await Promise.all([
    listCustomerPostingGroups(), currentCanAction('RECEIVABLES_SETUP_MANAGE'), listPostableAccounts(),
  ]);
  return (
    <Card>
      <CardHead title="Customer Posting Groups" sub="Business Central Table 92 — the G/L accounts every customer posting resolves against">
        {canManage ? <CustomerPostingGroupFormButton accounts={accounts}>New group</CustomerPostingGroupFormButton> : null}
      </CardHead>
      {rows.length ? (
        <TableWrap>
          <thead><tr><th>Code</th><th>Description</th><th>Receivables</th><th>Service charge</th><th>Additional fee</th><th className="num">Customers</th><th /></tr></thead>
          <tbody>
            {rows.map((g) => (
              <tr key={g.id}>
                <td className="mono">{g.code}</td>
                <td>{g.description}</td>
                <td className="mono muted-cell">{g.receivables_account_code}</td>
                <td className="mono muted-cell">{g.service_charge_account_code}</td>
                <td className="mono muted-cell">{g.additional_fee_account_code}</td>
                <td className="num">{g.customers_using}</td>
                <td>{canManage ? <CustomerPostingGroupFormButton row={g} accounts={accounts} className="btn sm ghost">Edit</CustomerPostingGroupFormButton> : null}</td>
              </tr>
            ))}
          </tbody>
        </TableWrap>
      ) : <EmptyState icon="⚖" title="No customer posting groups yet" />}
    </Card>
  );
}

async function PaymentTermsTab() {
  const [rows, canManage] = await Promise.all([listPaymentTerms(), currentCanAction('RECEIVABLES_SETUP_MANAGE')]);
  return (
    <Card>
      <CardHead title="Payment Terms" sub="Business Central Table 3 — Due Date / Discount Date calculations use a BC date formula (30D, CM, CM+10D)">
        {canManage ? <PaymentTermsFormButton>New terms</PaymentTermsFormButton> : null}
      </CardHead>
      {rows.length ? (
        <TableWrap>
          <thead><tr><th>Code</th><th>Description</th><th>Due Date Calc.</th><th>Discount Date Calc.</th><th className="num">Discount %</th><th>Status</th><th /></tr></thead>
          <tbody>
            {rows.map((p) => (
              <tr key={p.id}>
                <td className="mono">{p.code}</td><td>{p.description}</td>
                <td className="mono">{p.due_date_calculation || '—'}</td><td className="mono">{p.discount_date_calculation || '—'}</td>
                <td className="num">{p.discount_pct}</td><td><Pill status={p.status} /></td>
                <td>{canManage ? <PaymentTermsFormButton row={p} className="btn sm ghost">Edit</PaymentTermsFormButton> : null}</td>
              </tr>
            ))}
          </tbody>
        </TableWrap>
      ) : <EmptyState icon="🗓" title="No payment terms yet" />}
    </Card>
  );
}

async function PaymentMethodsTab() {
  const [rows, canManage, banks] = await Promise.all([listPaymentMethods(), currentCanAction('RECEIVABLES_SETUP_MANAGE'), listActiveBankAccounts()]);
  return (
    <Card>
      <CardHead title="Payment Methods" sub="Business Central Table 289">
        {canManage ? <PaymentMethodFormButton banks={banks.map((b) => ({ code: b.code, name: b.name }))}>New method</PaymentMethodFormButton> : null}
      </CardHead>
      {rows.length ? (
        <TableWrap>
          <thead><tr><th>Code</th><th>Description</th><th>Bal. Account Type</th><th>Bal. Account No.</th><th>Status</th><th /></tr></thead>
          <tbody>
            {rows.map((m) => (
              <tr key={m.id}>
                <td className="mono">{m.code}</td><td>{m.description}</td><td>{m.bal_account_type}</td>
                <td className="mono muted-cell">{m.bal_account_no ?? '—'}</td><td><Pill status={m.status} /></td>
                <td>{canManage ? <PaymentMethodFormButton row={m} banks={banks.map((b) => ({ code: b.code, name: b.name }))} className="btn sm ghost">Edit</PaymentMethodFormButton> : null}</td>
              </tr>
            ))}
          </tbody>
        </TableWrap>
      ) : <EmptyState icon="💳" title="No payment methods yet" />}
    </Card>
  );
}

async function ReminderTermsTab() {
  const [terms, fcTerms, canManage] = await Promise.all([
    listReminderTerms(), listFinanceChargeTerms(), currentCanAction('RECEIVABLES_SETUP_MANAGE'),
  ]);
  const levelsByTerms = new Map(await Promise.all(terms.map((t) => listReminderLevels(t.code).then((l) => [t.code, l] as const))));
  return (
    <>
      <Card>
        <CardHead title="Reminder Terms" sub="Business Central Tables 293 / 294 — reminder levels with grace period, interest and fee">
          {canManage ? <ReminderTermsFormButton>New terms</ReminderTermsFormButton> : null}
        </CardHead>
        {terms.length ? (
          <TableWrap>
            <thead><tr><th>Code</th><th>Description</th><th className="num">Max</th><th>Levels</th><th>Post Interest</th><th>Post Fee</th><th /></tr></thead>
            <tbody>
              {terms.map((t) => (
                <tr key={t.id}>
                  <td className="mono">{t.code}</td><td>{t.description}</td><td className="num">{t.max_no_of_reminders}</td>
                  <td>{(levelsByTerms.get(t.code) ?? []).length}</td>
                  <td>{t.post_interest ? 'Yes' : 'No'}</td><td>{t.post_additional_fee ? 'Yes' : 'No'}</td>
                  <td>{canManage ? <ReminderTermsFormButton row={t} initialLevels={levelsByTerms.get(t.code)} className="btn sm ghost">Edit</ReminderTermsFormButton> : null}</td>
                </tr>
              ))}
            </tbody>
          </TableWrap>
        ) : <EmptyState icon="⏰" title="No reminder terms yet" />}
      </Card>
      <Card>
        <CardHead title="Finance Charge Terms" sub="Business Central Table 5">
          {canManage ? <FinanceChargeTermsFormButton>New terms</FinanceChargeTermsFormButton> : null}
        </CardHead>
        {fcTerms.length ? (
          <TableWrap>
            <thead><tr><th>Code</th><th>Description</th><th className="num">Rate % p.a.</th><th className="num">Min Amount</th><th>Post Interest</th><th /></tr></thead>
            <tbody>
              {fcTerms.map((f) => (
                <tr key={f.id}>
                  <td className="mono">{f.code}</td><td>{f.description}</td><td className="num">{f.interest_rate}</td>
                  <td className="num"><Money cents={f.min_amount} /></td><td>{f.post_interest ? 'Yes' : 'No'}</td>
                  <td>{canManage ? <FinanceChargeTermsFormButton row={f} className="btn sm ghost">Edit</FinanceChargeTermsFormButton> : null}</td>
                </tr>
              ))}
            </tbody>
          </TableWrap>
        ) : <EmptyState icon="📈" title="No finance charge terms yet" />}
      </Card>
    </>
  );
}

async function SetupTab() {
  const [setup, postingGroups, paymentTerms, reminderTerms, finChargeTerms, canManage] = await Promise.all([
    getSalesReceivablesSetup(), listCustomerPostingGroups(), listPaymentTerms(),
    listActiveReminderTerms(), listActiveFinanceChargeTerms(), currentCanAction('RECEIVABLES_SETUP_MANAGE'),
  ]);
  return (
    <Card>
      <CardHead title="Sales & Receivables Setup" sub="Business Central Table 311 — module-wide defaults and the receivables posting-date window">
        {canManage ? <SalesReceivablesSetupButton setup={setup} postingGroups={postingGroups} paymentTerms={paymentTerms} reminderTerms={reminderTerms} finChargeTerms={finChargeTerms}>Edit setup</SalesReceivablesSetupButton> : null}
      </CardHead>
      <TableWrap>
        <tbody>
          <tr><td>Default customer posting group</td><td className="mono">{setup.default_customer_posting_group_code ?? '—'}</td></tr>
          <tr><td>Default payment terms</td><td className="mono">{setup.default_payment_terms_code ?? '—'}</td></tr>
          <tr><td>Default reminder terms</td><td className="mono">{setup.default_reminder_terms_code ?? '—'}</td></tr>
          <tr><td>Default fin. charge terms</td><td className="mono">{setup.default_fin_charge_terms_code ?? '—'}</td></tr>
          <tr><td>Credit warnings</td><td>{setup.credit_warnings}</td></tr>
          <tr><td>Allow posting from / to</td><td>{setup.allow_receivables_posting_from ?? '—'} / {setup.allow_receivables_posting_to ?? '—'}</td></tr>
        </tbody>
      </TableWrap>
    </Card>
  );
}
