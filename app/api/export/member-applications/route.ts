import { listMemberApplications, type MemberApplicationView } from '@/lib/memberApplications';
import { parseFilters } from '@/lib/listFilters';
import { parseSort } from '@/lib/listSort';
import { buildWorkbookBuffer, excelExportResponse, type ExcelColumn } from '@/lib/excel';
import { humanise } from '@/lib/format';
import type { MemberApplicationWithDimensions } from '@/lib/types';

const VIEWS: MemberApplicationView[] = ['open', 'pending', 'approved', 'processed'];

export async function GET(request: Request): Promise<Response> {
  const { searchParams } = new URL(request.url);
  const q = searchParams.get('q') ?? '';
  const viewParam = searchParams.get('view');
  const view = VIEWS.includes(viewParam as MemberApplicationView) ? (viewParam as MemberApplicationView) : undefined;
  const filters = parseFilters(searchParams.get('filters'));
  const sort = parseSort(searchParams.get('sort'));

  return excelExportResponse('MEMBER_APPLICATIONS_READ', async () => {
    const rows = await listMemberApplications({ view, search: q, filters, sort });
    const columns: ExcelColumn<MemberApplicationWithDimensions>[] = [
      { header: 'No.', key: 'no', value: (r) => r.no },
      { header: 'Name', key: 'name', value: (r) => `${r.first_name ?? ''} ${r.last_name ?? ''}`.trim() },
      { header: 'Identification No.', key: 'national_id', value: (r) => r.national_id },
      { header: 'Phone', key: 'phone', value: (r) => r.phone },
      { header: 'Member category', key: 'category', value: (r) => r.member_category_name },
      { header: 'Status', key: 'status', value: (r) => humanise(r.status) },
      { header: 'Member no.', key: 'member_no', value: (r) => r.member_no },
    ];
    return {
      filename: 'member-applications.xlsx',
      buffer: await buildWorkbookBuffer('Member Applications', columns, rows),
    };
  });
}
