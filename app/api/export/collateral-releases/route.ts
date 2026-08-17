import { listCollateralReleases, type CollateralReleaseView } from '@/lib/collateralReleases';
import { parseFilters } from '@/lib/listFilters';
import { parseSort } from '@/lib/listSort';
import { buildWorkbookBuffer, excelExportResponse, type ExcelColumn } from '@/lib/excel';
import { formatDate } from '@/lib/format';
import type { CollateralReleaseWithDetails } from '@/lib/types';

const VIEWS: CollateralReleaseView[] = ['open', 'pending', 'approved', 'processed'];

export async function GET(request: Request): Promise<Response> {
  const { searchParams } = new URL(request.url);
  const q = searchParams.get('q') ?? '';
  const viewParam = searchParams.get('view');
  const view = VIEWS.includes(viewParam as CollateralReleaseView) ? (viewParam as CollateralReleaseView) : undefined;
  const filters = parseFilters(searchParams.get('filters'));
  const sort = parseSort(searchParams.get('sort'));

  return excelExportResponse('COLLATERAL_RELEASES_READ', async () => {
    const rows = await listCollateralReleases({ view, search: q, filters, sort });
    const columns: ExcelColumn<CollateralReleaseWithDetails>[] = [
      { header: 'No.', key: 'no', value: (r) => r.no },
      { header: 'Collateral no.', key: 'collateral_no', value: (r) => r.collateral_no },
      { header: 'Member', key: 'member', value: (r) => `${r.member_first_name} ${r.member_last_name}`.trim() },
      { header: 'Member no.', key: 'member_no', value: (r) => r.member_no },
      { header: 'Collection date', key: 'collection_date', value: (r) => (r.collection_date ? formatDate(r.collection_date) : '') },
      { header: 'Collected by', key: 'collected_by', value: (r) => r.collected_by || '' },
      { header: 'Nationality', key: 'nationality', value: (r) => r.nationality },
      { header: 'Status', key: 'status', value: (r) => r.status },
    ];
    return { filename: 'collateral-releases.xlsx', buffer: await buildWorkbookBuffer('Collateral Releases', columns, rows) };
  });
}
