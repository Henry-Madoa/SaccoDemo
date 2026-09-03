import { notFound } from 'next/navigation';
import { requireAction, currentCanAction } from '@/lib/session';
import { getPaymentVoucher } from '@/lib/paymentVouchers';
import { getWhtCertificatesForVoucher } from '@/lib/whtCertificate';
import { Page } from '@/components/layout/page';
import { Card, CardHead, Pill, TableWrap } from '@/components/ui/primitives';
import { Money } from '@/components/ui/money';
import { formatDate } from '@/lib/format';
import {
  SubmitButton, CancelApprovalButton, ApproveButton, RejectButton, ReopenButton, DeleteButton, PostPvButton,
} from '../../document-actions';

export default async function PvDetailPage({ params }: { params: Promise<{ no: string }> }) {
  const user = await requireAction('CASH_MGMT_READ');
  const { no } = await params;
  const r = await getPaymentVoucher(no);
  if (!r) notFound();
  const [canCreate, canApprove, canPost, certs] = await Promise.all([
    currentCanAction('CASH_MGMT_PV_CREATE'), currentCanAction('CASH_MGMT_PV_APPROVE'),
    currentCanAction('CASH_MGMT_PV_POST'), getWhtCertificatesForVoucher(no),
  ]);
  const isOwn = r.created_by === user.username;
  const vatTotal = r.lines.reduce((s, l) => s + l.vat_amount, 0);
  const whtTotal = r.lines.reduce((s, l) => s + l.wht_amount_one + l.wht_amount_two, 0);

  return (
    <Page title={`Payment Voucher ${r.no}`} crumb="Cash Management → Payment Vouchers" user={user}>
      <Card>
        <CardHead title={`Payment Voucher ${r.no}`} sub={r.description ?? ''}>
          {r.posted ? <Pill status="ok">Posted</Pill> : <Pill status={r.status} />}
        </CardHead>
        <TableWrap>
          <tbody>
            <tr><td>Date</td><td>{formatDate(r.date)}</td></tr>
            <tr><td>Paying bank</td><td className="mono">{r.paying_bank_account_code}</td></tr>
            <tr><td>Currency</td><td className="mono">{r.currency_code} @ {r.currency_factor}</td></tr>
            <tr><td>Payee</td><td>{r.payee_name ?? '—'}</td></tr>
            <tr><td>Payment mode / cheque</td><td>{r.pay_mode_code ?? '—'} {r.cheque_no ? `· ${r.cheque_no}` : ''}</td></tr>
            <tr><td>VAT included</td><td><Money cents={vatTotal} /></td></tr>
            <tr><td>Withholding tax</td><td><Money cents={whtTotal} /></td></tr>
            <tr><td>Net paid</td><td><Money cents={r.total_amount} /></td></tr>
            <tr><td>Journal</td><td className="mono">{r.journal_no ?? '—'}</td></tr>
          </tbody>
        </TableWrap>
      </Card>
      <Card>
        <CardHead title="Lines" />
        <TableWrap>
          <thead><tr><th>Type</th><th>Account</th><th className="num">Gross</th><th className="num">VAT</th><th>WHT 1</th><th className="num">WHT 1 amt</th><th>WHT 2</th><th className="num">WHT 2 amt</th><th className="num">Net</th></tr></thead>
          <tbody>
            {r.lines.map((l) => (
              <tr key={l.id}>
                <td>{l.line_type}</td>
                <td className="mono">{l.account_no} <span className="tiny muted-cell">{l.account_name}</span></td>
                <td className="num"><Money cents={l.amount} /></td>
                <td className="num"><Money cents={l.vat_amount} /></td>
                <td className="mono muted-cell">{l.wht_code_one ?? '—'}</td>
                <td className="num"><Money cents={l.wht_amount_one} /></td>
                <td className="mono muted-cell">{l.wht_code_two ?? '—'}</td>
                <td className="num"><Money cents={l.wht_amount_two} /></td>
                <td className="num"><Money cents={l.net_amount} /></td>
              </tr>
            ))}
          </tbody>
        </TableWrap>
      </Card>
      {certs.length ? (
        <Card>
          <CardHead title="Withholding Tax Certificates" />
          <TableWrap>
            <thead><tr><th>No.</th><th>Payee</th><th className="num">WHT</th><th>Status</th><th /></tr></thead>
            <tbody>
              {certs.map((c) => (
                <tr key={c.id}>
                  <td className="mono">{c.no}</td>
                  <td>{c.vendor_name ?? '—'}</td>
                  <td className="num"><Money cents={c.total_wht} /></td>
                  <td>{c.remitted ? <Pill status="ok">Remitted</Pill> : <Pill tone="warn">Pending</Pill>}</td>
                  <td className="num"><a className="btn sm ghost" href={`/wht-certificate/${c.no}`} target="_blank" rel="noreferrer">Print</a></td>
                </tr>
              ))}
            </tbody>
          </TableWrap>
        </Card>
      ) : null}
      <div className="inline" style={{ gap: 8, flexWrap: 'wrap' }}>
        {!r.posted && r.status === 'Open' && canCreate && isOwn ? (<><SubmitButton no={r.no} kind="pv" /><DeleteButton no={r.no} kind="pv" /></>) : null}
        {r.status === 'Pending Approval' && canCreate && isOwn ? <CancelApprovalButton no={r.no} kind="pv" /> : null}
        {r.status === 'Pending Approval' && canApprove ? (<><ApproveButton no={r.no} kind="pv" /><RejectButton no={r.no} kind="pv" /></>) : null}
        {!r.posted && r.status === 'Approved' && canApprove ? <ReopenButton no={r.no} kind="pv" /> : null}
        {!r.posted && (r.status === 'Approved' || r.status === 'Open') && canPost ? <PostPvButton no={r.no} /> : null}
        {r.posted ? <a className="btn" href={`/pv-slip/${r.no}`} target="_blank" rel="noreferrer">Print voucher slip</a> : null}
      </div>
    </Page>
  );
}
