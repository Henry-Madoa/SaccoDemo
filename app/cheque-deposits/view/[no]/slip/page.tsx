import { notFound } from 'next/navigation';
import { requireAction } from '@/lib/session';
import { buildChequeDepositSlipDocument, renderDocument } from '@/lib/chequeDepositSlip';
import { Printable } from '@/components/ui/printable';

export const dynamic = 'force-dynamic';

/** Print-friendly Cheque Deposit Slip — AL Rep52204082. Opened in a new tab from the card. */
export default async function ChequeDepositSlipPage({ params }: { params: Promise<{ no: string }> }) {
  await requireAction('CHEQUE_DEPOSITS_READ');
  const { no } = await params;
  const slip = await buildChequeDepositSlipDocument(no);
  if (!slip) notFound();
  return <Printable html={renderDocument(slip)} />;
}
