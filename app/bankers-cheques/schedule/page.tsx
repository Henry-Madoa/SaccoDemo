import Link from 'next/link';
import { notFound } from 'next/navigation';
import { requireAction } from '@/lib/session';
import { buildBankersChequeScheduleDocument, renderDocument } from '@/lib/bankersChequeSchedule';
import { PrintSheets } from '@/components/ui/print-sheets';

export const dynamic = 'force-dynamic';

/** Print-friendly Banker's Cheque Schedule — AL Rep52204097. Posted cheques only, filtered by
 *  posting-date range and/or document No. via ?from=&to=&no=. */
export default async function BankersChequeSchedulePage({ searchParams }: {
  searchParams: Promise<{ from?: string; to?: string; no?: string; print?: string }>;
}) {
  await requireAction('BANKERS_CHEQUES_READ');
  const { from, to, no, print } = await searchParams;

  const doc = await buildBankersChequeScheduleDocument({ from, to, no });
  if (!doc) notFound();

  return (
    <>
      <div className="no-print" style={{ maxWidth: '301mm', margin: '16px auto 12px' }}>
        <form method="get" className="inline" style={{ gap: 8, flexWrap: 'wrap', alignItems: 'flex-end' }}>
          <label className="tiny">From<br /><input type="date" name="from" defaultValue={from} /></label>
          <label className="tiny">To<br /><input type="date" name="to" defaultValue={to} /></label>
          <label className="tiny">Cheque no.<br /><input type="text" name="no" defaultValue={no} placeholder="BCQ…" /></label>
          <button type="submit" className="btn sm">Apply</button>
          <button type="button" className="btn sm ghost" data-print>Print / Save as PDF</button>
          <Link href="/bankers-cheques" className="btn sm ghost">← Back</Link>
        </form>
      </div>
      <PrintSheets style={{ paddingBottom: 24 }} html={renderDocument(doc)} />
      <script
        dangerouslySetInnerHTML={{
          __html: "document.querySelector('[data-print]')?.addEventListener('click',function(){window.print();});"
            + (print ? "window.addEventListener('load',function(){setTimeout(function(){window.print();},300);});" : ''),
        }}
      />
    </>
  );
}
