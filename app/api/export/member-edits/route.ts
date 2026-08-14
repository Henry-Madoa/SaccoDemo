import { listMemberEditRequests, type MemberEditView } from '@/lib/memberEdits';
import { parseFilters } from '@/lib/listFilters';
import { parseSort } from '@/lib/listSort';
import { buildWorkbookBuffer, excelExportResponse, type ExcelColumn } from '@/lib/excel';
import { humanise } from '@/lib/format';
import type { MemberEditRequestWithDimensions } from '@/lib/types';

const VIEWS: MemberEditView[] = ['open', 'pending', 'approved', 'processed'];

export async function GET(request: Request): Promise<Response> {
  const { searchParams } = new URL(request.url);
  const q = searchParams.get('q') ?? '';
  const viewParam = searchParams.get('view');
  const view = VIEWS.includes(viewParam as MemberEditView) ? (viewParam as MemberEditView) : undefined;
  const filters = parseFilters(searchParams.get('filters'));
  const sort = parseSort(searchParams.get('sort'));

  return excelExportResponse('MEMBER_EDITS_READ', async () => {
    const rows = await listMemberEditRequests({ view, search: q, filters, sort });
    const columns: ExcelColumn<MemberEditRequestWithDimensions>[] = [
      { header: 'No.', key: 'no', value: (r) => r.no },
      { header: 'Member', key: 'member', value: (r) => `${r.member_first_name} ${r.member_last_name}`.trim() },
      { header: 'Member no.', key: 'member_no', value: (r) => r.member_no },
      { header: 'Status', key: 'status', value: (r) => humanise(r.status) },
    ];
    return { filename: 'member-edits.xlsx', buffer: await buildWorkbookBuffer('Member Edits', columns, rows) };
  });
}
