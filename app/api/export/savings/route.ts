import { listAccounts } from '@/lib/savings';
import { parseFilters } from '@/lib/listFilters';
import { parseSort } from '@/lib/listSort';
import { buildWorkbookBuffer, excelExportResponse, type ExcelColumn } from '@/lib/excel';
import { humanise } from '@/lib/format';
import type { SavingsAccountListRow } from '@/lib/types';

export async function GET(request: Request): Promise<Response> {
  const { searchParams } = new URL(request.url);
  const q = searchParams.get('q') ?? '';
  const filters = parseFilters(searchParams.get('filters'));
  const sort = parseSort(searchParams.get('sort'));

  return excelExportResponse('SAVINGS_READ', async () => {
    const rows = await listAccounts({ search: q, filters, sort });
    const columns: ExcelColumn<SavingsAccountListRow>[] = [
      { header: 'Account no.', key: 'account_no', value: (r) => r.account_no },
      { header: 'Member', key: 'member', value: (r) => `${r.first_name} ${r.last_name}`.trim() },
      { header: 'Member no.', key: 'member_no', value: (r) => r.member_no },
      { header: 'Product', key: 'product_name', value: (r) => r.product_name },
      { header: 'Status', key: 'status', value: (r) => humanise(r.status) },
      { header: 'Balance', key: 'balance', width: 14, value: (r) => r.balance / 100 },
      { header: 'Hold amount', key: 'hold_amount', width: 14, value: (r) => r.hold_amount / 100 },
    ];
    return { filename: 'savings-accounts.xlsx', buffer: await buildWorkbookBuffer('Savings Accounts', columns, rows) };
  });
}
