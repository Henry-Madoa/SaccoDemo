import { listLoans } from '@/lib/loanService';
import { parseFilters } from '@/lib/listFilters';
import { parseSort } from '@/lib/listSort';
import { buildWorkbookBuffer, excelExportResponse, type ExcelColumn } from '@/lib/excel';
import { humanise } from '@/lib/format';
import type { LoanListRow } from '@/lib/types';

export async function GET(request: Request): Promise<Response> {
  const { searchParams } = new URL(request.url);
  const q = searchParams.get('q') ?? '';
  const filters = parseFilters(searchParams.get('filters'));
  const sort = parseSort(searchParams.get('sort'));

  return excelExportResponse('LOAN_READ', async () => {
    const rows = await listLoans({ search: q, filters, sort });
    const columns: ExcelColumn<LoanListRow>[] = [
      { header: 'Loan no.', key: 'loan_no', value: (r) => r.loan_no },
      { header: 'Member', key: 'member', value: (r) => `${r.first_name} ${r.last_name}`.trim() },
      { header: 'Member no.', key: 'member_no', value: (r) => r.member_no },
      { header: 'Product', key: 'product_name', value: (r) => r.product_name },
      { header: 'Principal', key: 'principal', width: 14, value: (r) => r.principal / 100 },
      { header: 'Outstanding', key: 'outstanding', width: 14, value: (r) => (r.status === 'DISBURSED' ? (r.principal_balance + r.interest_balance) / 100 : null) },
      { header: 'Instalment', key: 'installment', width: 14, value: (r) => (r.installment ? r.installment / 100 : null) },
      { header: 'Arrears', key: 'arrears', width: 14, value: (r) => (r.arrears_amount ? r.arrears_amount / 100 : null) },
      { header: 'Status', key: 'status', value: (r) => humanise(r.status) },
      { header: 'Classification', key: 'classification', value: (r) => (r.status === 'DISBURSED' ? humanise(r.classification) : null) },
    ];
    return { filename: 'loans.xlsx', buffer: await buildWorkbookBuffer('Loans', columns, rows) };
  });
}
