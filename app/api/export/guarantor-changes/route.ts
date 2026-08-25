import { listGuarantorChanges, type GuarantorChangeView } from '@/lib/loanGuarantorChanges';
import { parseFilters } from '@/lib/listFilters';
import { parseSort } from '@/lib/listSort';
import { buildWorkbookBuffer, excelExportResponse, type ExcelColumn } from '@/lib/excel';
import type { LoanGuarantorChangeWithDetails } from '@/lib/types';

const VIEWS: GuarantorChangeView[] = ['open', 'pending', 'approved', 'processed'];

export async function GET(request: Request): Promise<Response> {
  const { searchParams } = new URL(request.url);
  const q = searchParams.get('q') ?? '';
  const viewParam = searchParams.get('view');
  const view = VIEWS.includes(viewParam as GuarantorChangeView) ? (viewParam as GuarantorChangeView) : undefined;
  const filters = parseFilters(searchParams.get('filters'));
  const sort = parseSort(searchParams.get('sort'));

  return excelExportResponse('GUARANTOR_CHANGES_READ', async () => {
    const rows = await listGuarantorChanges({ view, search: q, filters, sort });
    const columns: ExcelColumn<LoanGuarantorChangeWithDetails>[] = [
      { header: 'No.', key: 'no', value: (r) => r.no },
      { header: 'Loan no.', key: 'loan_no', value: (r) => r.loan_no },
      { header: 'Member', key: 'member', value: (r) => `${r.member_first_name} ${r.member_last_name}`.trim() },
      { header: 'Member no.', key: 'member_no', value: (r) => r.member_no },
      { header: 'Status', key: 'status', value: (r) => r.status },
      { header: 'Created by', key: 'created_by', value: (r) => r.created_by || '' },
    ];
    return { filename: 'guarantor-changes.xlsx', buffer: await buildWorkbookBuffer('Guarantor Changes', columns, rows) };
  });
}
