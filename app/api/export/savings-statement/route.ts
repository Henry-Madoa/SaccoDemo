import { statement } from '@/lib/savings';
import { buildWorkbookBuffer, excelExportResponse, type ExcelColumn } from '@/lib/excel';
import { formatDate } from '@/lib/format';
import type { Txn } from '@/lib/types';

export async function GET(request: Request): Promise<Response> {
  const { searchParams } = new URL(request.url);
  const id = Number(searchParams.get('id'));
  const from = searchParams.get('from') || undefined;
  const to = searchParams.get('to') || undefined;

  return excelExportResponse('SAVINGS_READ', async () => {
    const { account, lines } = await statement(id, from, to);
    const columns: ExcelColumn<Txn>[] = [
      { header: 'Date', key: 'value_date', value: (r) => formatDate(r.value_date) },
      { header: 'Reference', key: 'txn_ref', value: (r) => r.txn_ref },
      { header: 'Description', key: 'description', value: (r) => r.description },
      { header: 'Channel', key: 'channel', value: (r) => r.channel },
      { header: 'Debit', key: 'debit', width: 14, value: (r) => (r.amount < 0 ? -r.amount / 100 : null) },
      { header: 'Credit', key: 'credit', width: 14, value: (r) => (r.amount > 0 ? r.amount / 100 : null) },
      { header: 'Status', key: 'status', value: (r) => r.status },
    ];
    return {
      filename: `statement-${account.account_no}.xlsx`,
      buffer: await buildWorkbookBuffer('Statement of Account', columns, lines),
    };
  });
}
