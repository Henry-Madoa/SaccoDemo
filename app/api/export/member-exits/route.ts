import { listMemberExits, type MemberExitView } from '@/lib/memberExits';
import { buildWorkbookBuffer, excelExportResponse, type ExcelColumn } from '@/lib/excel';
import { humanise } from '@/lib/format';
import type { MemberExitWithDetails } from '@/lib/types';

const VIEWS: MemberExitView[] = ['open', 'pending', 'approved', 'processed'];

export async function GET(request: Request): Promise<Response> {
  const { searchParams } = new URL(request.url);
  const q = searchParams.get('q') ?? '';
  const viewParam = searchParams.get('view');
  const view = VIEWS.includes(viewParam as MemberExitView) ? (viewParam as MemberExitView) : undefined;

  return excelExportResponse('MEMBER_EXITS_READ', async () => {
    const rows = await listMemberExits({ view, search: q });
    const columns: ExcelColumn<MemberExitWithDetails>[] = [
      { header: 'No.', key: 'no', value: (r) => r.no },
      { header: 'Member', key: 'member', value: (r) => `${r.member_first_name} ${r.member_last_name}`.trim() },
      { header: 'Member no.', key: 'member_no', value: (r) => r.member_no },
      { header: 'Exit type', key: 'exit_type', value: (r) => humanise(r.exit_type) },
      { header: 'Net amount', key: 'net_amount', value: (r) => r.net_amount / 100 },
      { header: 'Status', key: 'status', value: (r) => r.status },
      { header: 'Created by', key: 'created_by', value: (r) => r.created_by || '' },
    ];
    return { filename: 'member-exits.xlsx', buffer: await buildWorkbookBuffer('Member Exits', columns, rows) };
  });
}
