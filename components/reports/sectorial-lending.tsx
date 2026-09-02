import { sectorialLendingReport } from '@/lib/sectorialLending';
import { formatDate, today } from '@/lib/format';
import { Card, CardHead, EmptyState, TableWrap, Toolbar } from '@/components/ui/primitives';
import { DateFilterExpressionInput } from '@/components/ui/filters';
import { DocumentActionsMenu } from '@/components/ui/document-actions';
import { Money } from '@/components/ui/money';

/** SASRA Sectorial Lending Return — AL Rep52204034. One line per economic sector / sub-sector /
 *  sub-subsector: current outstanding portfolio, plus the period's disbursements, recoveries and
 *  their net movement (AL's own "Net Change-Principal"). Shared by the Credit → Reports hub and
 *  the Financial Reports page. */
export async function SectorialLendingReport({ from, to }: { from?: string; to?: string }) {
  const rows = await sectorialLendingReport({ from, to });
  const totals = rows.reduce((t, r) => ({
    loans: t.loans + r.loans, disbursed: t.disbursed + r.disbursed, repaid: t.repaid + r.repaid,
    net_change: t.net_change + r.net_change, outstanding: t.outstanding + r.outstanding,
  }), { loans: 0, disbursed: 0, repaid: 0, net_change: 0, outstanding: 0 });

  return (
    <>
      <Toolbar>
        <DateFilterExpressionInput fromParam="from" toParam="to" placeholder="Period — e.g. 01/01/26..31/03/26" />
      </Toolbar>
      <Card>
        <CardHead
          title="Sectorial Lending Return"
          sub={`Outstanding portfolio by economic sector${from || to ? `, movement ${from ? formatDate(from) : '…'} – ${to ? formatDate(to) : today()}` : ''}`}
        >
          <DocumentActionsMenu
            className="btn ghost sm"
            excel={{ href: '/api/export/sectorial-lending', params: { from, to } }}
          />
        </CardHead>
        <TableWrap>
          <thead>
            <tr>
              <th>Sector</th><th>Sub-sector</th><th>Sub-subsector</th>
              <th className="num">Loans</th><th className="num">Disbursed</th><th className="num">Repaid</th>
              <th className="num">Net change</th><th className="num">Outstanding</th>
            </tr>
          </thead>
          <tbody>
            {rows.length ? rows.map((r) => (
              <tr key={`${r.sector_code ?? ''}|${r.sub_sector_code ?? ''}|${r.sub_subsector_code ?? ''}`}>
                <td>{r.sector_name}</td>
                <td>{r.sub_sector_name}</td>
                <td>{r.sub_subsector_name}</td>
                <td className="num">{r.loans}</td>
                <td className="num"><Money cents={r.disbursed} symbol={false} /></td>
                <td className="num"><Money cents={r.repaid} symbol={false} /></td>
                <td className="num"><Money cents={r.net_change} symbol={false} /></td>
                <td className="num"><Money cents={r.outstanding} symbol={false} /></td>
              </tr>
            )) : (
              <tr><td colSpan={8}><EmptyState icon="🌾" title="No loans to report"
                sub="Classify loans by sector on the loan card to populate this return" /></td></tr>
            )}
          </tbody>
          {rows.length ? (
            <tfoot>
              <tr>
                <td colSpan={3}><b>Total</b></td>
                <td className="num"><b>{totals.loans}</b></td>
                <td className="num"><b><Money cents={totals.disbursed} symbol={false} /></b></td>
                <td className="num"><b><Money cents={totals.repaid} symbol={false} /></b></td>
                <td className="num"><b><Money cents={totals.net_change} symbol={false} /></b></td>
                <td className="num"><b><Money cents={totals.outstanding} symbol={false} /></b></td>
              </tr>
            </tfoot>
          ) : null}
        </TableWrap>
        <p className="note" style={{ margin: '16px 0 0' }}>
          Outstanding is the current disbursed portfolio; Disbursed/Repaid/Net change are the
          principal movement for the period above (blank = all time). Loans not yet classified by
          sector appear under &quot;Unclassified&quot; — confirm this layout against SASRA&apos;s
          currently published Sectorial Lending Return format before filing.
        </p>
      </Card>
    </>
  );
}
