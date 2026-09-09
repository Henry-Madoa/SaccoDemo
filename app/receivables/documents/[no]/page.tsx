import Link from 'next/link';
import { notFound } from 'next/navigation';
import { requireAction, currentCanAction } from '@/lib/session';
import { getSalesDocument } from '@/lib/salesDocuments';
import { listPostableAccounts } from '@/lib/gl';
import { listItems } from '@/lib/items';
import { listActiveLocations } from '@/lib/inventorySetup';
import { listFixedAssets } from '@/lib/fixedAssets';
import { listActivePaymentTerms, listActivePaymentMethods } from '@/lib/receivablesSetup';
import { listActiveCustomers } from '@/lib/customers';
import { findPendingRoutedTask, listWorkflowTasksForDocument } from '@/lib/workflow';
import { Page } from '@/components/layout/page';
import { Card, CardHead, DefinitionList, Stat, Toolbar, Spacer } from '@/components/ui/primitives';
import { Money } from '@/components/ui/money';
import type { SalesDocumentType } from '@/lib/types';
import { ApprovalDetailsCard } from '@/components/ui/approval-details';
import { SalesDocumentCard } from '../../sales-document-card';
import {
  MakeOrderButton, SubmitDocButton, CancelApprovalButton, ApproveDocButton, RejectDocButton, ReopenDocButton,
  DeleteDocButton, PostSalesDocButton,
} from '../../document-actions';

/** The tab each document type lists under, for the card's "back to the list" link. */
const TAB_FOR: Record<SalesDocumentType, string> = {
  Quote: 'quotes', Order: 'orders', Invoice: 'sales-invoices', 'Credit Memo': 'credit-memos',
};

export default async function SalesDocumentPage({ params }: { params: Promise<{ no: string }> }) {
  const user = await requireAction('RECEIVABLES_READ');
  const { no } = await params;
  const doc = await getSalesDocument(no);
  if (!doc) notFound();

  const [canCreate, canApprove, canPost, customers, accounts, items, fixedAssets, locations, paymentTerms, paymentMethods, tasks] =
    await Promise.all([
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
      listWorkflowTasksForDocument('SALES_DOCUMENT', doc.no),
    ]);
  const routed = doc.status === 'Pending Approval'
    ? !!(await findPendingRoutedTask('SALES_DOCUMENT', doc.no))
    : false;

  const lookups = {
    customers, paymentTerms, paymentMethods,
    accounts: accounts.map((a) => ({ code: a.code, name: a.name })),
    items: items.map((i) => ({ no: i.no, description: i.description })),
    fixedAssets: fixedAssets.filter((a) => !a.disposed).map((a) => ({ no: a.no, description: a.description })),
    locations: locations.map((l) => ({ code: l.code, name: l.name })),
  };
  const isOwn = doc.created_by === user.username;
  const open = doc.status === 'Open';

  return (
    <Page title={`${doc.document_type} ${doc.no}`} crumb={`${doc.customer_no} · ${doc.customer_name}`} user={user}>
      <Toolbar>
        <Link href={`/receivables/${TAB_FOR[doc.document_type]}`} className="btn ghost sm">← All {doc.document_type.toLowerCase()}s</Link>
        <Link href={`/receivables/customers/${encodeURIComponent(doc.customer_no)}`} className="btn ghost sm">Customer card</Link>
        <a className="btn ghost sm" href={`/print/sales/${encodeURIComponent(doc.no)}`} target="_blank" rel="noreferrer">Print</a>
        <Spacer />
        {doc.document_type === 'Quote' && open && canCreate ? <MakeOrderButton no={doc.no} /> : null}
        {open && canCreate && isOwn && doc.document_type !== 'Quote' ? <SubmitDocButton no={doc.no} kind="sales" /> : null}
        {open && canCreate && isOwn ? <DeleteDocButton no={doc.no} kind="sales" /> : null}
        {doc.status === 'Pending Approval' && canCreate && isOwn && !routed ? <CancelApprovalButton no={doc.no} kind="sales" /> : null}
        {doc.status === 'Pending Approval' && (canApprove || routed)
          ? (<><ApproveDocButton no={doc.no} kind="sales" /><RejectDocButton no={doc.no} kind="sales" /></>) : null}
        {doc.status === 'Released' && canApprove ? <ReopenDocButton no={doc.no} kind="sales" /> : null}
        {doc.status === 'Released' && canPost ? <PostSalesDocButton no={doc.no} isOrder={doc.document_type === 'Order'} /> : null}
      </Toolbar>

      <div className="grid g3 stack-2">
        <Stat label="Amount" value={<Money cents={doc.amount} decimals={0} />}
          foot={`${doc.lines.length} line${doc.lines.length === 1 ? '' : 's'}`} />
        <Stat label="Outstanding" value={<Money cents={doc.outstanding_amount} decimals={0} />}
          foot="Not yet invoiced" />
        <Stat label="Shipped not invoiced" value={<Money cents={doc.shipped_not_invoiced} decimals={0} />}
          foot={doc.document_type === 'Order' ? 'Shipments posted but not yet invoiced' : 'Orders only'} />
      </div>

      <SalesDocumentCard doc={doc} lookups={lookups} canEdit={open && canCreate && isOwn} />

      <ApprovalDetailsCard
        tasks={tasks} status={doc.status} decisionReason={doc.decision_reason}
        createdBy={doc.created_by} createdAt={doc.created_at} subject="sales document"
      />

      <Card>
        <CardHead title="Posting details" sub="The groups this document will post against" />
        <DefinitionList items={[
          ['Customer posting group', doc.customer_posting_group_code || '—'],
          ['Salesperson', doc.salesperson || '—'],
          ['Currency', `${doc.currency_code}${doc.currency_code === 'KES' ? '' : ` @ ${doc.currency_factor}`}`],
        ]} />
      </Card>
    </Page>
  );
}
