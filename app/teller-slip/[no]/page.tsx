import { notFound } from 'next/navigation';
import { requireAction } from '@/lib/session';
import { buildTellerSlipDocument, renderDocument } from '@/lib/tellerSlip';
import { Printable } from '@/components/ui/printable';

export const dynamic = 'force-dynamic';

/** Print-friendly deposit/withdrawal slip — AL Rep52204068 / Rep52204069. Opened in a new tab
 *  from the transaction card; auto-invokes the browser print dialog. */
export default async function TellerSlipPage({ params }: { params: Promise<{ no: string }> }) {
  await requireAction('TELLER_TRANSACTIONS_READ');
  const { no } = await params;
  const slip = await buildTellerSlipDocument(no);
  if (!slip) notFound();
  return <Printable html={renderDocument(slip)} />;
}
