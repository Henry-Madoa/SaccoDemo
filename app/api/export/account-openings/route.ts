import { listAccountOpeningRequests, type AccountOpeningView } from '@/lib/accountOpening';
import { parseFilters } from '@/lib/listFilters';
import { parseSort } from '@/lib/listSort';
import { buildWorkbookBuffer, excelExportResponse, type ExcelColumn } from '@/lib/excel';
import { humanise } from '@/lib/format';
import type { AccountOpeningRequestWithDimensions } from '@/lib/types';

const VIEWS: AccountOpeningView[] = ['open', 'pending', 'approved', 'processed'];

export async function GET(request: Request): Promise<Response> {
  const { searchParams } = new URL(request.url);
  const q = searchParams.get('q') ?? '';
  const viewParam = searchParams.get('view');
  const view = VIEWS.includes(viewParam as AccountOpeningView) ? (viewParam as AccountOpeningView) : undefined;
  const filters = parseFilters(searchParams.get('filters'));
  const sort = parseSort(searchParams.get('sort'));

  return excelExportResponse('ACCOUNT_OPENING_READ', async () => {
    const rows = await listAccountOpeningRequests({ view, search: q, filters, sort });
    const columns: ExcelColumn<AccountOpeningRequestWithDimensions>[] = [
      { header: 'No.', key: 'no', value: (r) => r.no },
      { header: 'Member', key: 'member', value: (r) => `${r.member_first_name} ${r.member_last_name}`.trim() },
      { header: 'Member no.', key: 'member_no', value: (r) => r.member_no },
      { header: 'Product', key: 'product', value: (r) => r.savings_product_name },
      { header: 'Status', key: 'status', value: (r) => humanise(r.status) },
    ];
    return { filename: 'account-openings.xlsx', buffer: await buildWorkbookBuffer('Account Openings', columns, rows) };
  });
}
