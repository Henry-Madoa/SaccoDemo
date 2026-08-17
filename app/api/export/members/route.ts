import { listMembers } from '@/lib/members';
import { getDimensionCaptions } from '@/lib/org';
import { parseFilters } from '@/lib/listFilters';
import { parseSort } from '@/lib/listSort';
import { buildWorkbookBuffer, excelExportResponse, type ExcelColumn } from '@/lib/excel';
import { formatDate, humanise } from '@/lib/format';
import type { MemberListRow } from '@/lib/types';

export async function GET(request: Request): Promise<Response> {
  const { searchParams } = new URL(request.url);
  const q = searchParams.get('q') ?? '';
  const filters = parseFilters(searchParams.get('filters'));
  const sort = parseSort(searchParams.get('sort'));

  return excelExportResponse('MEMBERS_READ', async () => {
    const [{ rows }, { caption1, caption2 }] = await Promise.all([
      listMembers({ search: q, filters, sort, limit: 5000 }),
      getDimensionCaptions(),
    ]);
    const columns: ExcelColumn<MemberListRow>[] = [
      { header: 'Member no.', key: 'member_no', value: (r) => r.member_no },
      { header: 'Name', key: 'name', value: (r) => `${r.first_name} ${r.last_name}`.trim() },
      { header: 'Identification No.', key: 'identification_no', value: (r) => r.identification_no },
      { header: 'Phone', key: 'phone', value: (r) => r.phone },
      { header: 'Email', key: 'email', value: (r) => r.email },
      { header: 'Category', key: 'category', value: (r) => r.member_category_name },
      { header: 'County', key: 'county', value: (r) => r.county_name },
      { header: caption1, key: 'gd1', value: (r) => r.global_dimension_1_name },
      { header: caption2, key: 'gd2', value: (r) => r.global_dimension_2_name },
      { header: 'Savings', key: 'total_savings', width: 14, value: (r) => r.total_savings / 100 },
      { header: 'Loan balance', key: 'loan_balance', width: 14, value: (r) => r.loan_balance / 100 },
      { header: 'Status', key: 'status', value: (r) => humanise(r.status) },
      { header: 'Join date', key: 'join_date', value: (r) => (r.join_date ? formatDate(r.join_date) : null) },
    ];
    return { filename: 'members.xlsx', buffer: await buildWorkbookBuffer('Members', columns, rows) };
  });
}
