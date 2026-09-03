import { notFound } from 'next/navigation';
import { requireAction } from '@/lib/session';
import { buildWhtCertificateSlip, renderWhtCertificateHtml } from '@/lib/whtCertificateSlip';

export const dynamic = 'force-dynamic';

export default async function WhtCertificatePage({ params }: { params: Promise<{ no: string }> }) {
  await requireAction('WHT_CERTIFICATE_PRINT');
  const { no } = await params;
  const slip = await buildWhtCertificateSlip(no);
  if (!slip) notFound();
  return (
    <>
      <div className="no-print" style={{ maxWidth: 700, margin: '0 auto 12px', textAlign: 'right' }}>
        <button type="button" className="btn" data-print>Print / Save as PDF</button>
      </div>
      <div dangerouslySetInnerHTML={{ __html: renderWhtCertificateHtml(slip) }} />
      <script dangerouslySetInnerHTML={{ __html: `document.querySelector('[data-print]')?.addEventListener('click',function(){window.print();});window.addEventListener('load',function(){setTimeout(function(){window.print();},300);});` }} />
    </>
  );
}
