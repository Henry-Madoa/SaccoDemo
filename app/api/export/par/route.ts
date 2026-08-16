import { getPortfolioAtRisk } from '@/lib/reports';
import { buildWorkbookBuffer, excelExportResponse, type ExcelColumn } from '@/lib/excel';
import type { ParRow } from '@/lib/types';

export async function GET(): Promise<Response> {
  return excelExportResponse('REPORTS_VIEW', async () => {
    const d = await getPortfolioAtRisk();
    const columns: ExcelColumn<ParRow>[] = [
      { header: 'Classification', key: 'classification', width: 16, value: (r) => r.classification },
      { header: 'Loans', key: 'loans', value: (r) => r.loans },
      { header: 'Outstanding balance', key: 'balance', width: 16, value: (r) => r.balance / 100 },
      { header: 'Arrears', key: 'arrears', width: 16, value: (r) => r.arrears / 100 },
      { header: 'Provision rate', key: 'provision_rate', width: 14, value: (r) => r.provision_rate },
      { header: 'Provision', key: 'provision', width: 16, value: (r) => r.provision / 100 },
    ];
    return {
      filename: 'risk-classification-and-provisioning.xlsx',
      buffer: await buildWorkbookBuffer('Risk Classification', columns, d.rows),
    };
  });
}
