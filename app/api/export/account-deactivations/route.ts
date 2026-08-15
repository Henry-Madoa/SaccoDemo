import { listAccountDeactivationRequests, type AccountDeactivationView } from '@/lib/accountDeactivation';
import { parseFilters } from '@/lib/listFilters';
import { parseSort } from '@/lib/listSort';
import { buildWorkbookBuffer, excelExportResponse, type ExcelColumn } from '@/lib/excel';
import { humanise } from '@/lib/format';
import type { AccountDeactivationRequestWithDimensions } from '@/lib/types';

const VIEWS: AccountDeactivationView[] = ['open', 'pending', 'approved', 'processed'];

export async function GET(request: Request): Promise<Response> {
  const { searchParams } = new URL(request.url);
  const q = searchParams.get('q') ?? '';
  const viewParam = searchParams.get('view');
  const view = VIEWS.includes(viewParam as AccountDeactivationView) ? (viewParam as AccountDeactivationView) : undefined;
  const filters = parseFilters(searchParams.get('filters'));
  const sort = parseSort(searchParams.get('sort'));

  return excelExportResponse('ACCOUNT_DEACTIVATION_READ', async () => {
    const rows = await listAccountDeactivationRequests({ view, search: q, filters, sort });
    const columns: ExcelColumn<AccountDeactivationRequestWithDimensions>[] = [
      { header: 'No.', key: 'no', value: (r) => r.no },
      { header: 'Member', key: 'member', value: (r) => `${r.member_first_name} ${r.member_last_name}`.trim() },
      { header: 'Member no.', key: 'member_no', value: (r) => r.member_no },
      { header: 'Account no.', key: 'account_no', value: (r) => r.account_no },
      { header: 'Product', key: 'product', value: (r) => r.savings_product_name },
      { header: 'Reason', key: 'reason', value: (r) => r.reason ?? '' },
      { header: 'Status', key: 'status', value: (r) => humanise(r.status) },
    ];
    return { filename: 'account-deactivations.xlsx', buffer: await buildWorkbookBuffer('Account Deactivations', columns, rows) };
  });
}
