import { notFound } from 'next/navigation';
import { requireAction } from '@/lib/session';
import { buildTellerSlip, renderSlipHtml } from '@/lib/tellerSlip';

export const dynamic = 'force-dynamic';

/** Print-friendly deposit/withdrawal slip — AL Rep52204068 / Rep52204069. Opened in a new tab
 *  from the transaction card; auto-invokes the browser print dialog. */
export default async function TellerSlipPage({ params }: { params: Promise<{ no: string }> }) {
  await requireAction('TELLER_TRANSACTIONS_READ');
  const { no } = await params;
  const slip = await buildTellerSlip(no);
  if (!slip) notFound();

  return (
    <>
      <div className="no-print" style={{ maxWidth: 620, margin: '0 auto 12px', textAlign: 'right' }}>
        <button type="button" className="btn" data-print>Print / Save as PDF</button>
      </div>
      <div dangerouslySetInnerHTML={{ __html: renderSlipHtml(slip) }} />
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
