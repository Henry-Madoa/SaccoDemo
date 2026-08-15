import { listAccountActivationRequests, type AccountActivationView } from '@/lib/accountActivation';
import { parseFilters } from '@/lib/listFilters';
import { parseSort } from '@/lib/listSort';
import { buildWorkbookBuffer, excelExportResponse, type ExcelColumn } from '@/lib/excel';
import { humanise } from '@/lib/format';
import type { AccountActivationRequestWithDimensions } from '@/lib/types';

const VIEWS: AccountActivationView[] = ['open', 'pending', 'approved', 'processed'];

export async function GET(request: Request): Promise<Response> {
  const { searchParams } = new URL(request.url);
  const q = searchParams.get('q') ?? '';
  const viewParam = searchParams.get('view');
  const view = VIEWS.includes(viewParam as AccountActivationView) ? (viewParam as AccountActivationView) : undefined;
  const filters = parseFilters(searchParams.get('filters'));
  const sort = parseSort(searchParams.get('sort'));

  return excelExportResponse('ACCOUNT_ACTIVATION_READ', async () => {
    const rows = await listAccountActivationRequests({ view, search: q, filters, sort });
    const columns: ExcelColumn<AccountActivationRequestWithDimensions>[] = [
      { header: 'No.', key: 'no', value: (r) => r.no },
      { header: 'Member', key: 'member', value: (r) => `${r.member_first_name} ${r.member_last_name}`.trim() },
      { header: 'Member no.', key: 'member_no', value: (r) => r.member_no },
      { header: 'Account no.', key: 'account_no', value: (r) => r.account_no },
      { header: 'Product', key: 'product', value: (r) => r.savings_product_name },
      { header: 'Reason', key: 'reason', value: (r) => r.reason ?? '' },
      { header: 'Status', key: 'status', value: (r) => humanise(r.status) },
    ];
    return { filename: 'account-activations.xlsx', buffer: await buildWorkbookBuffer('Account Activations', columns, rows) };
  });
}
