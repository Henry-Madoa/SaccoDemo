import { listCollateralApplications, type CollateralApplicationView } from '@/lib/collateralApplications';
import { parseFilters } from '@/lib/listFilters';
import { parseSort } from '@/lib/listSort';
import { buildWorkbookBuffer, excelExportResponse, type ExcelColumn } from '@/lib/excel';
import { humanise } from '@/lib/format';
import type { CollateralApplicationWithDetails } from '@/lib/types';

const VIEWS: CollateralApplicationView[] = ['open', 'pending', 'approved', 'processed'];

export async function GET(request: Request): Promise<Response> {
  const { searchParams } = new URL(request.url);
  const q = searchParams.get('q') ?? '';
  const viewParam = searchParams.get('view');
  const view = VIEWS.includes(viewParam as CollateralApplicationView) ? (viewParam as CollateralApplicationView) : undefined;
  const filters = parseFilters(searchParams.get('filters'));
  const sort = parseSort(searchParams.get('sort'));

  return excelExportResponse('COLLATERAL_APPLICATIONS_READ', async () => {
    const rows = await listCollateralApplications({ view, search: q, filters, sort });
    const columns: ExcelColumn<CollateralApplicationWithDetails>[] = [
      { header: 'No.', key: 'no', value: (r) => r.no },
      { header: 'Member', key: 'member', value: (r) => `${r.member_first_name} ${r.member_last_name}`.trim() },
      { header: 'Member no.', key: 'member_no', value: (r) => r.member_no },
      { header: 'Category', key: 'category', value: (r) => humanise(r.category) },
      { header: 'Collateral type', key: 'collateral_type', value: (r) => r.collateral_type_code || '' },
      { header: 'Serial / reg. no.', key: 'serial_reg_no', value: (r) => r.serial_reg_no || '' },
      { header: 'Collateral value', key: 'collateral_value', value: (r) => r.collateral_value / 100 },
      { header: 'Guarantee', key: 'guarantee', value: (r) => r.guarantee / 100 },
      { header: 'Status', key: 'status', value: (r) => r.status },
    ];
    return { filename: 'collateral-applications.xlsx', buffer: await buildWorkbookBuffer('Collateral Applications', columns, rows) };
  });
}
