import { listMemberChargings, type MemberChargingView } from '@/lib/memberCharging';
import { parseFilters } from '@/lib/listFilters';
import { parseSort } from '@/lib/listSort';
import { buildWorkbookBuffer, excelExportResponse, type ExcelColumn } from '@/lib/excel';
import { humanise } from '@/lib/format';
import type { MemberChargingWithDimensions } from '@/lib/types';

const VIEWS: MemberChargingView[] = ['open', 'posted'];

export async function GET(request: Request): Promise<Response> {
  const { searchParams } = new URL(request.url);
  const q = searchParams.get('q') ?? '';
  const viewParam = searchParams.get('view');
  const view = VIEWS.includes(viewParam as MemberChargingView) ? (viewParam as MemberChargingView) : undefined;
  const filters = parseFilters(searchParams.get('filters'));
  const sort = parseSort(searchParams.get('sort'));

  return excelExportResponse('MEMBER_CHARGING_READ', async () => {
    const rows = await listMemberChargings({ view, search: q, filters, sort });
    const columns: ExcelColumn<MemberChargingWithDimensions>[] = [
      { header: 'No.', key: 'no', value: (r) => r.no },
      { header: 'Member', key: 'member', value: (r) => `${r.member_first_name} ${r.member_last_name}`.trim() },
      { header: 'Member no.', key: 'member_no', value: (r) => r.member_no },
      { header: 'Source account', key: 'source_account_no', value: (r) => r.source_account_no },
      { header: 'Description', key: 'description', value: (r) => r.description ?? '' },
      { header: 'Charge code', key: 'charge_code', value: (r) => r.transaction_charge_code },
      { header: 'Posting transaction type', key: 'posting_transaction_type', value: (r) => r.posting_transaction_type },
      { header: 'Amount charged', key: 'amount_charged', value: (r) => r.amount_charged / 100 },
      { header: 'Status', key: 'status', value: (r) => humanise(r.status) },
    ];
    return { filename: 'member-chargings.xlsx', buffer: await buildWorkbookBuffer('Member Charging', columns, rows) };
  });
}
