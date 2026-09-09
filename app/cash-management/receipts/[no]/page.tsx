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
import { EditReceiptButton } from '../../receipt-form';
import { docFormProps } from '../../doc-form-props';

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
        <CardHead title="Lines" sub={`${r.lines.length} line${r.lines.length === 1 ? '' : 's'}`} />
        <TableWrap>
          <thead>
            <tr>
              <th style={{ width: 110 }}>Type</th>
              <th style={{ width: '26%' }}>Account</th>
              <th>Description</th>
              <th style={{ width: '20%' }}>Applies to Doc. No.</th>
              <th className="num" style={{ width: 140 }}>Amount</th>
            </tr>
          </thead>
          <tbody>
            {r.lines.map((l) => (
              <tr key={l.id}>
                <td>{l.line_type}</td>
                {/* Account no. and its name stack rather than run together — a G/L name is long. */}
                <td>
                  <span className="mono">{l.account_no}</span>
                  {l.account_name ? <div className="tiny muted-cell">{l.account_name}</div> : null}
                </td>
                <td>{l.description || <span className="muted-cell">—</span>}</td>
                <td>
                  {l.applies_to_doc_no
                    ? (<><span className="mono">{l.applies_to_doc_no}</span><div className="tiny muted-cell">Settles this invoice</div></>)
                    : <span className="muted-cell">— on account</span>}
                </td>
                <td className="num"><Money cents={l.amount} /></td>
              </tr>
            ))}
          </tbody>
          <tfoot>
            <tr><td colSpan={4}>Total</td><td className="num"><b><Money cents={r.amount} /></b></td></tr>
          </tfoot>
        </TableWrap>
      </Card>
      <div className="inline" style={{ gap: 8, flexWrap: 'wrap' }}>
        {editable && formProps ? <EditReceiptButton receipt={r} p={formProps} className="btn" /> : null}
        {editable ? (<><SubmitButton no={r.no} kind="receipt" /><DeleteButton no={r.no} kind="receipt" /></>) : null}
        {r.status === 'Pending Approval' && canCreate && isOwn ? <CancelApprovalButton no={r.no} kind="receipt" /> : null}
        {r.status === 'Pending Approval' && canApprove ? (<><ApproveButton no={r.no} kind="receipt" /><RejectButton no={r.no} kind="receipt" /></>) : null}
        {!r.posted && r.status === 'Approved' && canApprove ? <ReopenButton no={r.no} kind="receipt" /> : null}
        {!r.posted && (r.status === 'Approved' || r.status === 'Open') && canPost ? <PostReceiptButton no={r.no} /> : null}
        {r.posted ? <a className="btn" href={`/print/receipt/${encodeURIComponent(r.no)}`} target="_blank" rel="noreferrer">Print official receipt</a> : null}
      </div>
    </Page>
  );
}
