import { notFound } from 'next/navigation';
import { requireAction, currentCanAction } from '@/lib/session';
import { getReceipt } from '@/lib/receipts';
import { Page } from '@/components/layout/page';
import { Card, CardHead, Pill, TableWrap } from '@/components/ui/primitives';
import { Money } from '@/components/ui/money';
import { formatDate } from '@/lib/format';
import {
  SubmitButton, CancelApprovalButton, ApproveButton, RejectButton, ReopenButton, DeleteButton, PostReceiptButton,
} from '../../document-actions';

export default async function ReceiptDetailPage({ params }: { params: Promise<{ no: string }> }) {
  const user = await requireAction('CASH_MGMT_READ');
  const { no } = await params;
  const r = await getReceipt(no);
  if (!r) notFound();
  const [canCreate, canApprove, canPost] = await Promise.all([
    currentCanAction('CASH_MGMT_RECEIPT_CREATE'), currentCanAction('CASH_MGMT_RECEIPT_APPROVE'), currentCanAction('CASH_MGMT_RECEIPT_POST'),
  ]);
  const isOwn = r.created_by === user.username;

  return (
    <Page title={`Receipt ${r.no}`} crumb="Cash Management → Receipts" user={user}>
      <Card>
        <CardHead title={`Receipt ${r.no}`} sub={r.description ?? ''}>
          {r.posted ? <Pill status="ok">Posted</Pill> : <Pill status={r.status} />}
        </CardHead>
        <TableWrap>
          <tbody>
            <tr><td>Posting date</td><td>{formatDate(r.posting_date)}</td></tr>
            <tr><td>Bank account</td><td className="mono">{r.bank_account_code} — {r.bank_account_name}</td></tr>
            <tr><td>Currency</td><td className="mono">{r.currency_code} @ {r.currency_factor}</td></tr>
            <tr><td>Payment mode</td><td>{r.pay_mode_code ?? '—'}</td></tr>
            <tr><td>Cheque / M-Pesa ref.</td><td className="mono">{r.external_document_no ?? '—'}</td></tr>
            <tr><td>Amount</td><td><Money cents={r.amount} /></td></tr>
            <tr><td>Journal</td><td className="mono">{r.journal_no ?? '—'}</td></tr>
          </tbody>
        </TableWrap>
      </Card>
      <Card>
        <CardHead title="Lines" />
        <TableWrap>
          <thead><tr><th>Type</th><th>Account</th><th>Description</th><th className="num">Amount</th><th>Applies to</th></tr></thead>
          <tbody>
            {r.lines.map((l) => (
              <tr key={l.id}>
                <td>{l.line_type}</td>
                <td className="mono">{l.account_no} <span className="tiny muted-cell">{l.account_name}</span></td>
                <td>{l.description ?? '—'}</td>
                <td className="num"><Money cents={l.amount} /></td>
                <td className="mono muted-cell">{l.applies_to_doc_no ?? '—'}</td>
              </tr>
            ))}
          </tbody>
        </TableWrap>
      </Card>
      <div className="inline" style={{ gap: 8, flexWrap: 'wrap' }}>
        {!r.posted && r.status === 'Open' && canCreate && isOwn ? (<><SubmitButton no={r.no} kind="receipt" /><DeleteButton no={r.no} kind="receipt" /></>) : null}
        {r.status === 'Pending Approval' && canCreate && isOwn ? <CancelApprovalButton no={r.no} kind="receipt" /> : null}
        {r.status === 'Pending Approval' && canApprove ? (<><ApproveButton no={r.no} kind="receipt" /><RejectButton no={r.no} kind="receipt" /></>) : null}
        {!r.posted && r.status === 'Approved' && canApprove ? <ReopenButton no={r.no} kind="receipt" /> : null}
        {!r.posted && (r.status === 'Approved' || r.status === 'Open') && canPost ? <PostReceiptButton no={r.no} /> : null}
        {r.posted ? <a className="btn" href={`/receipt-slip/${r.no}`} target="_blank" rel="noreferrer">Print official receipt</a> : null}
      </div>
    </Page>
  );
}
