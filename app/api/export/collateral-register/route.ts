import { listCollateralRegister } from '@/lib/collateralRegister';
import { parseFilters } from '@/lib/listFilters';
import { parseSort } from '@/lib/listSort';
import { buildWorkbookBuffer, excelExportResponse, type ExcelColumn } from '@/lib/excel';
import { humanise } from '@/lib/format';
import type { CollateralRegisterRow } from '@/lib/types';

export async function GET(request: Request): Promise<Response> {
  const { searchParams } = new URL(request.url);
  const q = searchParams.get('q') ?? '';
  const filters = parseFilters(searchParams.get('filters'));
  const sort = parseSort(searchParams.get('sort'));

  return excelExportResponse('COLLATERAL_REGISTER_READ', async () => {
    const rows = await listCollateralRegister({ search: q, filters, sort });
    const columns: ExcelColumn<CollateralRegisterRow>[] = [
      { header: 'No.', key: 'no', value: (r) => r.no },
      { header: 'Member', key: 'member', value: (r) => `${r.member_first_name} ${r.member_last_name}`.trim() },
      { header: 'Member no.', key: 'member_no', value: (r) => r.member_no },
      { header: 'Category', key: 'category', value: (r) => humanise(r.category) },
      { header: 'Collateral type', key: 'collateral_type', value: (r) => r.collateral_type_code || '' },
      { header: 'Serial / reg. no.', key: 'serial_reg_no', value: (r) => r.serial_reg_no || '' },
      { header: 'Collateral value', key: 'collateral_value', value: (r) => r.collateral_value / 100 },
      { header: 'Guarantee (LTV)', key: 'guarantee', value: (r) => r.guarantee / 100 },
      { header: 'Linked loan balance', key: 'linked_loan_balance', value: (r) => r.linked_loan_balance / 100 },
      { header: 'Available cover', key: 'collateral_balance', value: (r) => r.collateral_balance / 100 },
      { header: 'Status', key: 'status', value: (r) => humanise(r.status) },
    ];
    return { filename: 'collateral-register.xlsx', buffer: await buildWorkbookBuffer('Collateral Register', columns, rows) };
  });
}
