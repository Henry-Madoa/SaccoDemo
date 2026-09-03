import { notFound } from 'next/navigation';
import { requireAction, currentCanAction } from '@/lib/session';
import { parseFilters } from '@/lib/listFilters';
import { parseSort } from '@/lib/listSort';
import { listPostableAccounts, listActiveBankAccounts } from '@/lib/gl';
import { listItems } from '@/lib/items';
import { listActiveLocations } from '@/lib/inventorySetup';
import { listFixedAssets } from '@/lib/fixedAssets';
import { listActivePaymentTerms, listActivePaymentMethods, listPaymentTerms } from '@/lib/receivablesSetup';
import {
  listVendors, hasAnyVendors, VENDOR_FILTER_FIELDS, listActiveVendors, getVendorLedgerEntries,
} from '@/lib/vendors';
import {
  listPurchaseDocuments, hasAnyPurchaseDocuments, PURCHASE_DOC_FILTER_FIELDS,
} from '@/lib/purchaseDocuments';
import { listPaymentJournals, hasAnyPaymentJournals } from '@/lib/paymentJournal';
import { listVendorPostingGroups, getPurchasesPayablesSetup } from '@/lib/payablesSetup';
import { getAgedAccountsPayable, AGED_AP_FILTER_FIELDS } from '@/lib/payablesReports';
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
import type { PurchaseDocumentType } from '@/lib/types';
import {
  VendorFormButton, VendorPostingGroupFormButton, PurchasesPayablesSetupButton,
} from '../payables-forms';
import { NewPurchaseDocumentButton } from '../purchase-document-form';
import {
  MakeOrderButton, SubmitDocButton, CancelApprovalButton, ApproveDocButton, RejectDocButton, ReopenDocButton,
  DeleteDocButton, PostPurchaseDocButton, PostPaymentJournalButton,
} from '../document-actions';
import { NewPaymentJournalButton, SuggestVendorPaymentsPanel } from '../payment-journal-form';
import { ApplyEntriesButton, UnapplyButton } from '../apply-entries';
import { VendorStatementPanel } from '../statement-panel';

const TABS: TabDefinition[] = [
  { key: 'vendors', label: 'Vendors' },
  { key: 'quotes', label: 'Quotes' },
  { key: 'orders', label: 'Orders' },
  { key: 'purchase-invoices', label: 'Purchase Invoices' },
  { key: 'credit-memos', label: 'Credit Memos' },
  { key: 'posted-documents', label: 'Posted' },
  { key: 'payment-journal', label: 'Payment Journal' },
  { key: 'ledger-entries', label: 'Vendor Ledger' },
  { key: 'aged-ap', label: 'Aged AP' },
  { key: 'statement', label: 'Statement' },
  { key: 'posting-groups', label: 'Posting Groups' },
  { key: 'setup', label: 'Setup' },
];

export default async function PayablesPage({ params, searchParams }: {
  params: Promise<{ tab?: string[] }>;
  searchParams: Promise<{ q?: string; filters?: string; sort?: string; view?: string; vendor?: string; asOf?: string; from?: string; to?: string }>;
}) {
  const user = await requireAction('PAYABLES_READ');
  const { tab: segments } = await params;
  const sp = await searchParams;
  const tab = segments?.[0] ?? 'vendors';
  if (!TABS.some((t) => t.key === tab)) notFound();

  return (
    <Page title="Payables" crumb="Vendors, purchase invoices, payments and aging" user={user}>
      <Tabs tabs={TABS} active={tab} hrefFor={(k) => `/payables/${k === 'vendors' ? '' : k}`} />
      {tab === 'vendors' ? <VendorsTab search={sp.q ?? ''} filtersRaw={sp.filters} sortRaw={sp.sort} /> : null}
      {tab === 'quotes' ? <PurchaseDocTab documentType="Quote" search={sp.q ?? ''} filtersRaw={sp.filters} sortRaw={sp.sort} username={user.username} /> : null}
      {tab === 'orders' ? <PurchaseDocTab documentType="Order" search={sp.q ?? ''} filtersRaw={sp.filters} sortRaw={sp.sort} username={user.username} /> : null}
      {tab === 'purchase-invoices' ? <PurchaseDocTab documentType="Invoice" search={sp.q ?? ''} filtersRaw={sp.filters} sortRaw={sp.sort} username={user.username} /> : null}
      {tab === 'credit-memos' ? <PurchaseDocTab documentType="Credit Memo" search={sp.q ?? ''} filtersRaw={sp.filters} sortRaw={sp.sort} username={user.username} /> : null}
      {tab === 'posted-documents' ? <PostedDocsTab search={sp.q ?? ''} /> : null}
      {tab === 'payment-journal' ? <PaymentJournalTab search={sp.q ?? ''} username={user.username} /> : null}
      {tab === 'ledger-entries' ? <LedgerTab /> : null}
      {tab === 'aged-ap' ? <AgedApTab asOf={sp.asOf} filtersRaw={sp.filters} /> : null}
      {tab === 'statement' ? <StatementTab vendorNo={sp.vendor} from={sp.from} to={sp.to} /> : null}
      {tab === 'posting-groups' ? <PostingGroupsTab /> : null}
      {tab === 'setup' ? <SetupTab /> : null}
    </Page>
  );
}

async function vendorFormProps() {
  const [postingGroups, paymentTerms, paymentMethods] = await Promise.all([
    listVendorPostingGroups(), listActivePaymentTerms(), listActivePaymentMethods(),
  ]);
  return { postingGroups, paymentTerms, paymentMethods };
}

/* ------------------------------------------------------------------ Vendors */

async function VendorsTab({ search, filtersRaw, sortRaw }: { search: string; filtersRaw?: string; sortRaw?: string }) {
  const filters = parseFilters(filtersRaw);
  const sort = parseSort(sortRaw);
  const [rows, empty, canManage, fp] = await Promise.all([
    listVendors({ search, filters, sort }),
    hasAnyVendors().then((a) => !a),
    currentCanAction('PAYABLES_VENDOR_MANAGE'),
    vendorFormProps(),
  ]);
  const fields = VENDOR_FILTER_FIELDS.map((f) =>
    (f.key === 'vendor_posting_group_code' ? { ...f, options: fp.postingGroups.map((g) => ({ value: g.code, label: g.code })) } : f));

  return (
    <>
      <Toolbar>
        <SearchInput placeholder="Search vendor no., name, city…" disabled={empty} />
        <DynamicFilterBar fields={fields} disabled={empty} />
        <Spacer />
        {canManage ? <VendorFormButton {...fp}>New vendor</VendorFormButton> : null}
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
              {rows.map((v) => (
                <tr key={v.id}>
                  <td className="mono">{v.no}</td>
                  <td>{v.name}</td>
                  <td className="muted-cell">{v.city ?? '—'}</td>
                  <td className="mono muted-cell">{v.vendor_posting_group_code ?? '—'}</td>
                  <td className="mono muted-cell">{v.payment_terms_code ?? '—'}</td>
                  <td className="num"><Money cents={v.balance} /></td>
                  <td className="num">{v.balance_due > 0 ? <span className="bad"><Money cents={v.balance_due} /></span> : <Money cents={0} />}</td>
                  <td>{v.blocked ? <Pill tone="bad">Blocked: {v.blocked}</Pill> : <Pill status="ok">Active</Pill>}</td>
                  <td className="num">{canManage ? <VendorFormButton vendor={v} {...fp} className="btn sm ghost">Edit</VendorFormButton> : null}</td>
                </tr>
              ))}
            </tbody>
          </TableWrap>
        ) : <EmptyState icon="🏭" title={empty ? 'No vendors yet' : 'No vendors match'} />}
      </Card>
    </>
  );
}

/* ----------------------------------------------------------- Purchase Documents */

async function PurchaseDocTab({ documentType, search, filtersRaw, sortRaw, username }: {
  documentType: PurchaseDocumentType; search: string; filtersRaw?: string; sortRaw?: string; username: string;
}) {
  const filters = parseFilters(filtersRaw);
  const sort = parseSort(sortRaw);
  const [rows, empty, canCreate, canApprove, canPost, vendors, accounts, items, fixedAssets, locations, paymentTerms, paymentMethods] = await Promise.all([
    listPurchaseDocuments({ documentType, search, filters, sort }),
    hasAnyPurchaseDocuments(documentType).then((a) => !a),
    currentCanAction('PAYABLES_PURCHASE_CREATE'),
    currentCanAction('PAYABLES_PURCHASE_APPROVE'),
    currentCanAction('PAYABLES_PURCHASE_POST'),
    listActiveVendors(),
    listPostableAccounts(),
    listItems(),
    listFixedAssets(),
    listActiveLocations(),
    listActivePaymentTerms(),
    listActivePaymentMethods(),
  ]);
  const routed = new Map(await Promise.all(
    rows.filter((r) => r.status === 'Pending Approval').map((r) => findPendingRoutedTask('PURCHASE_DOCUMENT', r.no).then((t) => [r.no, !!t] as const)),
  ));
  const fields = PURCHASE_DOC_FILTER_FIELDS.map((f) =>
    (f.key === 'vendor_id' ? { ...f, options: vendors.map((v) => ({ value: v.id, label: `${v.no} — ${v.name}` })) } : f));
  const formProps = {
    vendors, paymentTerms, paymentMethods,
    accounts: accounts.map((a) => ({ code: a.code, name: a.name })),
    items: items.map((i) => ({ no: i.no, description: i.description })),
    fixedAssets: fixedAssets.filter((a) => !a.disposed && !a.acquisition_cost).map((a) => ({ no: a.no, description: a.description })),
    locations: locations.map((l) => ({ code: l.code, name: l.name })),
  };

  return (
    <>
      <Toolbar>
        <SearchInput placeholder="Search no., vendor, invoice no.…" disabled={empty} />
        <DynamicFilterBar fields={fields} disabled={empty} />
        <Spacer />
        {canCreate && documentType !== 'Order' ? <NewPurchaseDocumentButton documentType={documentType} {...formProps} /> : null}
      </Toolbar>
      <Card>
        {rows.length ? (
          <TableWrap>
            <thead>
              <tr>
                <th><SortLink sortKey="no">No.</SortLink></th>
                <th><SortLink sortKey="vendor">Vendor</SortLink></th>
                <th>Vendor Inv.</th>
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
                    <td>{d.vendor_no} <span className="tiny muted-cell">{d.vendor_name}</span></td>
                    <td className="mono muted-cell">{d.vendor_invoice_no ?? '—'}</td>
                    <td className="num"><Money cents={d.amount} /></td>
                    <td>{formatDate(d.posting_date)}</td>
                    <td>{d.due_date ? formatDate(d.due_date) : '—'}</td>
                    <td><Pill status={d.status} /></td>
                    <td className="num">
                      <div className="inline" style={{ justifyContent: 'flex-end' }}>
                        {documentType === 'Quote' && d.status === 'Open' && canCreate ? <MakeOrderButton no={d.no} /> : null}
                        {d.status === 'Open' && canCreate && isOwn && documentType !== 'Quote' ? <SubmitDocButton no={d.no} kind="purchase" /> : null}
                        {d.status === 'Open' && canCreate && isOwn ? <DeleteDocButton no={d.no} kind="purchase" /> : null}
                        {d.status === 'Pending Approval' && canCreate && isOwn && !routed.get(d.no) ? <CancelApprovalButton no={d.no} kind="purchase" /> : null}
                        {d.status === 'Pending Approval' && (canApprove || routed.get(d.no)) ? (<><ApproveDocButton no={d.no} kind="purchase" /><RejectDocButton no={d.no} kind="purchase" /></>) : null}
                        {d.status === 'Released' && canApprove ? <ReopenDocButton no={d.no} kind="purchase" /> : null}
                        {d.status === 'Released' && canPost ? <PostPurchaseDocButton no={d.no} isOrder={documentType === 'Order'} /> : null}
                      </div>
                    </td>
                  </tr>
                );
              })}
            </tbody>
          </TableWrap>
        ) : <EmptyState icon="📄" title={empty ? `No purchase ${documentType.toLowerCase()}s yet` : 'No documents match'} />}
      </Card>
    </>
  );
}

async function PostedDocsTab({ search }: { search: string }) {
  const { all } = await import('@/lib/db');
  const rows = await all<{
    id: number; document_type: string; no: string; posting_date: string; amount: number;
    vendor_no: string; vendor_name: string; order_no: string | null; vendor_invoice_no: string | null;
  }>(
    `SELECT d.id, d.document_type, d.no, d.posting_date, d.amount, d.order_no, d.vendor_invoice_no,
            v.no AS vendor_no, v.name AS vendor_name
     FROM posted_purchase_document d JOIN vendor v ON v.id = d.vendor_id
     WHERE d.no LIKE @like OR v.no LIKE @like OR v.name LIKE @like
     ORDER BY d.id DESC LIMIT 500`,
    { like: `%${String(search).trim()}%` },
  );
  return (
    <>
      <Toolbar><SearchInput placeholder="Search posted document no. or vendor…" /><Spacer /></Toolbar>
      <Card>
        <CardHead title="Posted Purchase Documents" sub="Receipts, invoices and credit memos — the immutable record behind the vendor ledger" />
        {rows.length ? (
          <TableWrap>
            <thead><tr><th>No.</th><th>Type</th><th>Vendor</th><th>Vendor Inv.</th><th>Order</th><th>Date</th><th className="num">Amount</th></tr></thead>
            <tbody>
              {rows.map((r) => (
                <tr key={r.id}>
                  <td className="mono">{r.no}</td>
                  <td>{r.document_type}</td>
                  <td>{r.vendor_no} <span className="tiny muted-cell">{r.vendor_name}</span></td>
                  <td className="mono muted-cell">{r.vendor_invoice_no ?? '—'}</td>
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

/* -------------------------------------------------------------- Payment Journal */

async function PaymentJournalTab({ search, username }: { search: string; username: string }) {
  const [rows, empty, canCreate, canPost, banks, vendors, paymentMethods] = await Promise.all([
    listPaymentJournals({ search }),
    hasAnyPaymentJournals().then((a) => !a),
    currentCanAction('PAYABLES_PAYMENT_CREATE'),
    currentCanAction('PAYABLES_PAYMENT_POST'),
    listActiveBankAccounts(),
    listActiveVendors(),
    listActivePaymentMethods(),
  ]);
  const routed = new Map(await Promise.all(
    rows.filter((r) => r.status === 'Pending Approval').map((r) => findPendingRoutedTask('PAYMENT_JOURNAL', r.no).then((t) => [r.no, !!t] as const)),
  ));
  const bankList = banks.map((b) => ({ id: b.id, code: b.code, name: b.name }));
  return (
    <>
      {canCreate ? (
        <Card>
          <CardHead title="Suggest Vendor Payments" sub="Business Central Report 393 — fills a payment journal from open, not-on-hold vendor invoices due on or before a date" />
          <SuggestVendorPaymentsPanel banks={bankList} vendors={vendors} />
        </Card>
      ) : null}
      <Toolbar>
        <SearchInput placeholder="Search journal no. or description…" disabled={empty} />
        <Spacer />
        {canCreate ? <NewPaymentJournalButton banks={bankList} vendors={vendors} paymentMethods={paymentMethods} /> : null}
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
                        {r.status === 'Open' && canCreate && isOwn ? (<><SubmitDocButton no={r.no} kind="payment" /><DeleteDocButton no={r.no} kind="payment" /></>) : null}
                        {r.status === 'Pending Approval' && canCreate && isOwn && !routed.get(r.no) ? <CancelApprovalButton no={r.no} kind="payment" /> : null}
                        {r.status === 'Pending Approval' && (canPost || routed.get(r.no)) ? (<><ApproveDocButton no={r.no} kind="payment" /><RejectDocButton no={r.no} kind="payment" /></>) : null}
                        {r.status === 'Approved' && !r.posted && canPost ? (<><ReopenDocButton no={r.no} kind="payment" /><PostPaymentJournalButton no={r.no} /></>) : null}
                      </div>
                    </td>
                  </tr>
                );
              })}
            </tbody>
          </TableWrap>
        ) : <EmptyState icon="💸" title={empty ? 'No payment journals yet' : 'Nothing matches'} />}
      </Card>
    </>
  );
}

/* -------------------------------------------------------------- Vendor Ledger */

async function LedgerTab() {
  const [rows, canApply] = await Promise.all([
    getVendorLedgerEntries(),
    currentCanAction('PAYABLES_APPLY_ENTRIES'),
  ]);
  return (
    <Card>
      <CardHead title="Vendor Ledger Entries" sub="Every invoice, credit memo and payment posted against a vendor" />
      {rows.length ? (
        <TableWrap>
          <thead><tr><th>Date</th><th>Vendor</th><th>Type</th><th>Document</th><th>Due</th><th className="num">Amount</th><th className="num">Remaining</th><th>Open</th><th className="num" /></tr></thead>
          <tbody>
            {rows.map((e) => (
              <tr key={e.id} className={e.open ? undefined : 'muted'}>
                <td>{formatDate(e.posting_date)}</td>
                <td>{e.vendor_no} <span className="tiny muted-cell">{e.vendor_name}</span></td>
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
      ) : <EmptyState icon="📄" title="No vendor ledger entries yet" />}
    </Card>
  );
}

/* ---------------------------------------------------------------- Aged AP */

async function AgedApTab({ asOf, filtersRaw }: { asOf?: string; filtersRaw?: string }) {
  const filters = parseFilters(filtersRaw);
  const [report, postingGroups] = await Promise.all([
    getAgedAccountsPayable({ asOf, filters }),
    listVendorPostingGroups(),
  ]);
  const fields = AGED_AP_FILTER_FIELDS.map((f) =>
    (f.key === 'vendor_posting_group_code' ? { ...f, options: postingGroups.map((g) => ({ value: g.code, label: g.code })) } : f));
  return (
    <>
      <Toolbar>
        <form className="inline" style={{ gap: 8 }}>
          <input type="date" name="asOf" defaultValue={report.as_of} aria-label="As of date" />
          <button type="submit" className="btn sm">Refresh</button>
        </form>
        <DynamicFilterBar fields={fields} />
        <Spacer />
        <ExportButton href="/api/export/aged-ap" params={{ asOf: report.as_of, filters: filtersRaw }} disabled={!report.rows.length} />
      </Toolbar>
      <Card>
        <CardHead title="Aged Accounts Payable" sub={`As of ${formatDate(report.as_of)}, aged by ${report.aging_by.toLowerCase()}`} />
        {report.rows.length ? (
          <TableWrap>
            <thead>
              <tr>
                <th>Vendor</th><th className="num">Balance</th>
                {report.bucket_labels.map((l) => <th key={l} className="num">{l}</th>)}
              </tr>
            </thead>
            <tbody>
              {report.rows.map((r) => (
                <tr key={r.vendor_id}>
                  <td>{r.vendor_no} <span className="tiny muted-cell">{r.vendor_name}</span></td>
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
        ) : <EmptyState icon="📊" title="No open payables" />}
      </Card>
    </>
  );
}

async function StatementTab({ vendorNo, from, to }: { vendorNo?: string; from?: string; to?: string }) {
  const vendors = await listActiveVendors();
  return (
    <Card>
      <CardHead title="Vendor Statement" sub="Opening balance, movements and closing balance for a date range" />
      <VendorStatementPanel vendors={vendors} vendorNo={vendorNo} from={from} to={to} />
    </Card>
  );
}

/* ----------------------------------------------------------------- Setup tabs */

async function PostingGroupsTab() {
  const [rows, canManage, accounts] = await Promise.all([
    listVendorPostingGroups(), currentCanAction('PAYABLES_SETUP_MANAGE'), listPostableAccounts(),
  ]);
  return (
    <Card>
      <CardHead title="Vendor Posting Groups" sub="Business Central Table 93 — the G/L accounts every vendor posting resolves against">
        {canManage ? <VendorPostingGroupFormButton accounts={accounts}>New group</VendorPostingGroupFormButton> : null}
      </CardHead>
      {rows.length ? (
        <TableWrap>
          <thead><tr><th>Code</th><th>Description</th><th>Payables</th><th>Service charge</th><th>Pmt. disc. received</th><th className="num">Vendors</th><th /></tr></thead>
          <tbody>
            {rows.map((g) => (
              <tr key={g.id}>
                <td className="mono">{g.code}</td>
                <td>{g.description}</td>
                <td className="mono muted-cell">{g.payables_account_code}</td>
                <td className="mono muted-cell">{g.service_charge_account_code}</td>
                <td className="mono muted-cell">{g.payment_disc_credit_account_code}</td>
                <td className="num">{g.vendors_using}</td>
                <td>{canManage ? <VendorPostingGroupFormButton row={g} accounts={accounts} className="btn sm ghost">Edit</VendorPostingGroupFormButton> : null}</td>
              </tr>
            ))}
          </tbody>
        </TableWrap>
      ) : <EmptyState icon="⚖" title="No vendor posting groups yet" />}
    </Card>
  );
}

async function SetupTab() {
  const [setup, postingGroups, paymentTerms, canManage] = await Promise.all([
    getPurchasesPayablesSetup(), listVendorPostingGroups(), listPaymentTerms(), currentCanAction('PAYABLES_SETUP_MANAGE'),
  ]);
  return (
    <Card>
      <CardHead title="Purchases & Payables Setup" sub="Business Central Table 312 — module-wide defaults and the payables posting-date window">
        {canManage ? <PurchasesPayablesSetupButton setup={setup} postingGroups={postingGroups} paymentTerms={paymentTerms}>Edit setup</PurchasesPayablesSetupButton> : null}
      </CardHead>
      <TableWrap>
        <tbody>
          <tr><td>Default vendor posting group</td><td className="mono">{setup.default_vendor_posting_group_code ?? '—'}</td></tr>
          <tr><td>Default payment terms</td><td className="mono">{setup.default_payment_terms_code ?? '—'}</td></tr>
          <tr><td>Receipt on Invoice</td><td>{setup.receipt_on_invoice ? 'Yes' : 'No'}</td></tr>
          <tr><td>Allow posting from / to</td><td>{setup.allow_payables_posting_from ?? '—'} / {setup.allow_payables_posting_to ?? '—'}</td></tr>
        </tbody>
      </TableWrap>
    </Card>
  );
}
