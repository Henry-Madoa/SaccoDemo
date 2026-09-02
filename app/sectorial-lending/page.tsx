import { requireAction } from '@/lib/session';
import { Page } from '@/components/layout/page';
import { SectorialLendingReport } from '@/components/reports/sectorial-lending';

/** SASRA Sectorial Lending Return — the loan portfolio by economic sector. Stands on its own
 *  under Credit → Reports (see lib/nav.ts); the report body is the shared
 *  `<SectorialLendingReport>` used nowhere else now. */
export default async function SectorialLendingPage({ searchParams }: {
  searchParams: Promise<{ from?: string; to?: string }>;
}) {
  const user = await requireAction('LOAN_READ');
  const { from, to } = await searchParams;

  return (
    <Page
      title="Sectorial Lending Return"
      crumb="SASRA loan-portfolio return by economic sector, sub-sector and sub-subsector"
      user={user}
    >
      <SectorialLendingReport from={from} to={to} />
    </Page>
  );
}
