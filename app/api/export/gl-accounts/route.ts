import { listGlAccounts } from '@/lib/gl';
import { parseFilters } from '@/lib/listFilters';
import { parseSort } from '@/lib/listSort';
import { buildWorkbookBuffer, excelExportResponse, type ExcelColumn } from '@/lib/excel';
import type { GlAccount } from '@/lib/types';

export async function GET(request: Request): Promise<Response> {
  const { searchParams } = new URL(request.url);
  const q = searchParams.get('q') ?? '';
  const filters = parseFilters(searchParams.get('filters'));
  const sort = parseSort(searchParams.get('sort'));

  return excelExportResponse('GL_READ', async () => {
    const rows = await listGlAccounts({ search: q, filters, sort });
    const columns: ExcelColumn<GlAccount>[] = [
      { header: 'Code', key: 'code', value: (r) => r.code },
      { header: 'Account', key: 'name', value: (r) => r.name },
      { header: 'Type', key: 'type', value: (r) => r.type },
      { header: 'Parent', key: 'parent_code', value: (r) => r.parent_code },
      { header: 'Postable', key: 'postable', value: (r) => (r.is_postable ? 'Yes' : 'Header') },
      { header: 'Status', key: 'status', value: (r) => r.status },
      { header: 'Balance', key: 'balance', width: 14, value: (r) => (r.is_postable ? r.balance / 100 : null) },
    ];
    return { filename: 'chart-of-accounts.xlsx', buffer: await buildWorkbookBuffer('Chart of Accounts', columns, rows) };
  });
}
