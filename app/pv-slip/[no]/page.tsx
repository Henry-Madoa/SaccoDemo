import { notFound } from 'next/navigation';
import { requireAction } from '@/lib/session';
import { buildPaymentVoucherSlip, renderVoucherHtml } from '@/lib/paymentVoucherSlip';

export const dynamic = 'force-dynamic';

export default async function PvSlipPage({ params }: { params: Promise<{ no: string }> }) {
  await requireAction('CASH_MGMT_READ');
  const { no } = await params;
  const slip = await buildPaymentVoucherSlip(no);
  if (!slip) notFound();
  return (
    <>
      <div className="no-print" style={{ maxWidth: 640, margin: '0 auto 12px', textAlign: 'right' }}>
        <button type="button" className="btn" data-print>Print / Save as PDF</button>
      </div>
      <div dangerouslySetInnerHTML={{ __html: renderVoucherHtml(slip) }} />
      <script dangerouslySetInnerHTML={{ __html: `document.querySelector('[data-print]')?.addEventListener('click',function(){window.print();});window.addEventListener('load',function(){setTimeout(function(){window.print();},300);});` }} />
    </>
  );
}
