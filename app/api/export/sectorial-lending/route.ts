import { sectorialLendingReport } from '@/lib/sectorialLending';
import { buildWorkbookBuffer, excelExportResponse, type ExcelColumn } from '@/lib/excel';
import type { SectorialLendingRow } from '@/lib/types';

export async function GET(request: Request): Promise<Response> {
  const { searchParams } = new URL(request.url);
  const from = searchParams.get('from') || undefined;
  const to = searchParams.get('to') || undefined;

  return excelExportResponse('REPORTS_VIEW', async () => {
    const data = await sectorialLendingReport({ from, to });
    const totals = data.reduce((t, r) => ({
      loans: t.loans + r.loans, disbursed: t.disbursed + r.disbursed, repaid: t.repaid + r.repaid,
      net_change: t.net_change + r.net_change, outstanding: t.outstanding + r.outstanding,
    }), { loans: 0, disbursed: 0, repaid: 0, net_change: 0, outstanding: 0 });

    const rows: SectorialLendingRow[] = [
      ...data,
      {
        sector_code: null, sector_name: 'Total', sub_sector_code: null, sub_sector_name: '',
        sub_subsector_code: null, sub_subsector_name: '', ...totals,
      },
    ];

    const columns: ExcelColumn<SectorialLendingRow>[] = [
      { header: 'Sector', key: 'sector', width: 28, value: (r) => r.sector_name },
      { header: 'Sub-sector', key: 'sub_sector', width: 26, value: (r) => r.sub_sector_name },
      { header: 'Sub-subsector', key: 'sub_subsector', width: 26, value: (r) => r.sub_subsector_name },
      { header: 'Loans', key: 'loans', width: 10, value: (r) => r.loans },
      { header: 'Disbursed', key: 'disbursed', width: 16, value: (r) => r.disbursed / 100 },
      { header: 'Repaid', key: 'repaid', width: 16, value: (r) => r.repaid / 100 },
      { header: 'Net change', key: 'net_change', width: 16, value: (r) => r.net_change / 100 },
      { header: 'Outstanding', key: 'outstanding', width: 16, value: (r) => r.outstanding / 100 },
    ];

    return {
      filename: 'sectorial-lending-return.xlsx',
      buffer: await buildWorkbookBuffer('Sectorial Lending', columns, rows),
    };
  });
}
