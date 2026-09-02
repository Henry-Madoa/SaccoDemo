import { notFound } from 'next/navigation';
import { requireAction } from '@/lib/session';
import { buildChequeDepositSlip, renderChequeDepositSlipHtml } from '@/lib/chequeDepositSlip';

export const dynamic = 'force-dynamic';

/** Print-friendly Cheque Deposit Slip — AL Rep52204082. Opened in a new tab from the card. */
export default async function ChequeDepositSlipPage({ params }: { params: Promise<{ no: string }> }) {
  await requireAction('CHEQUE_DEPOSITS_READ');
  const { no } = await params;
  const slip = await buildChequeDepositSlip(no);
  if (!slip) notFound();

  return (
    <>
      <div className="no-print" style={{ maxWidth: 620, margin: '0 auto 12px', textAlign: 'right' }}>
        <button type="button" className="btn" data-print>Print / Save as PDF</button>
      </div>
      <div dangerouslySetInnerHTML={{ __html: renderChequeDepositSlipHtml(slip) }} />
      <script
        dangerouslySetInnerHTML={{
          __html: `
            document.querySelector('[data-print]')?.addEventListener('click', function(){ window.print(); });
            window.addEventListener('load', function(){ setTimeout(function(){ window.print(); }, 300); });
          `,
        }}
      />
    </>
  );
}
