import { notFound } from 'next/navigation';
import { requireAction, currentCanAction } from '@/lib/session';
import { all } from '@/lib/db';
import { getReceipt } from '@/lib/receipts';
import { Page } from '@/components/layout/page';
import { Toolbar, Spacer } from '@/components/ui/primitives';
import {
  SubmitButton, CancelApprovalButton, ApproveButton, RejectButton, ReopenButton, DeleteButton, PostReceiptButton,
} from '../../document-actions';
import { ReceiptCard } from '../../receipt-card';
import { docFormProps } from '../../doc-form-props';

export const dynamic = 'force-dynamic';

export default async function ReceiptDetailPage({ params }: { params: Promise<{ no: string }> }) {
  const user = await requireAction('CASH_MGMT_READ');
  const { no } = await params;
  const r = await getReceipt(no);
  if (!r) notFound();
  const [canCreate, canApprove, canPost] = await Promise.all([
    currentCanAction('CASH_MGMT_RECEIPT_CREATE'), currentCanAction('CASH_MGMT_RECEIPT_APPROVE'), currentCanAction('CASH_MGMT_RECEIPT_POST'),
  ]);
  const isOwn = r.created_by === user.username;
  // An Open receipt is still the creator's draft, so it is edited here on its own card rather
  // than only from the list — the lookups the line editor needs are loaded only when it can be.
  const editable = !r.posted && r.status === 'Open' && canCreate && isOwn;
  const formProps = editable ? await docFormProps() : null;

  // Only the lines that name somebody other than the header member need looking up.
  const otherIds = [...new Set(r.lines.map((l) => l.member_id).filter((id): id is number => !!id && id !== r.member_id))];
  const memberNos = new Map(
    otherIds.length
      ? (await all<{ id: number; member_no: string }>(
        `SELECT id, member_no FROM member WHERE id IN (${otherIds.map(() => '?').join(',')})`, ...otherIds,
      )).map((m) => [Number(m.id), m.member_no] as const)
      : [],
  );

  return (
    <Page title={`Receipt ${r.no}`} crumb="Cash Management → Receipts" user={user}>
      {/* The actions sit above the document, where they are reachable without scrolling past it. */}
      <Toolbar>
        <a href="/cash-management/receipts" className="btn ghost sm">← All receipts</a>
        {r.posted ? (
          <a className="btn ghost sm" href={`/print/receipt/${encodeURIComponent(r.no)}`} target="_blank" rel="noreferrer">
            Print official receipt
          </a>
        ) : null}
        <Spacer />
        {editable ? (<><SubmitButton no={r.no} kind="receipt" /><DeleteButton no={r.no} kind="receipt" /></>) : null}
        {r.status === 'Pending Approval' && canCreate && isOwn ? <CancelApprovalButton no={r.no} kind="receipt" /> : null}
        {r.status === 'Pending Approval' && canApprove ? (<><ApproveButton no={r.no} kind="receipt" /><RejectButton no={r.no} kind="receipt" /></>) : null}
        {!r.posted && r.status === 'Approved' && canApprove ? <ReopenButton no={r.no} kind="receipt" /> : null}
        {!r.posted && (r.status === 'Approved' || r.status === 'Open') && canPost ? <PostReceiptButton no={r.no} /> : null}
      </Toolbar>

      <ReceiptCard receipt={r} lookups={formProps} canEdit={editable} memberNos={memberNos} />
    </Page>
  );
}
