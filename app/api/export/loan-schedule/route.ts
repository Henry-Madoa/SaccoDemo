import { buildLoanScheduleDocuments } from '@/lib/loanDocuments';
import { buildWorkbookBuffer, excelExportResponse, type ExcelColumn } from '@/lib/excel';
import { formatDate } from '@/lib/format';

interface ScheduleExportRow {
  loanNo: string;
  memberNo: string;
  memberName: string;
  installmentNo: number;
  dueDate: string;
  opening: number;
  principal: number;
  interest: number;
  instalment: number;
  paid: number;
  balance: number;
  status: string;
}

const parseIds = (raw: string | null): number[] =>
  (raw ? raw.split(',') : []).map(Number).filter((n) => Number.isFinite(n) && n > 0);
const parseList = (raw: string | null): string[] => (raw ? raw.split(',').filter(Boolean) : []);

export async function GET(request: Request): Promise<Response> {
  const { searchParams } = new URL(request.url);
  const loanIds = parseIds(searchParams.get('loan'));
  const memberIds = parseIds(searchParams.get('member'));
  const productIds = parseIds(searchParams.get('product'));
  const statuses = parseList(searchParams.get('status'));
  const expFrom = searchParams.get('expFrom') || undefined;
  const expTo = searchParams.get('expTo') || undefined;

  return excelExportResponse('LOAN_READ', async () => {
    const docs = await buildLoanScheduleDocuments({
      loanIds, memberIds, productIds, statuses, expFrom, expTo,
    });
    const rows: ScheduleExportRow[] = docs.flatMap((d) => d.rows.map((r) => ({
      loanNo: d.loan.loan_no,
      memberNo: d.loan.member_no,
      memberName: `${d.loan.first_name} ${d.loan.last_name}`,
      installmentNo: r.installment_no,
      dueDate: formatDate(r.due_date),
      opening: r.opening_balance / 100,
      principal: r.principal_due / 100,
      interest: r.interest_due / 100,
      instalment: (r.principal_due + r.interest_due) / 100,
      paid: (r.principal_paid + r.interest_paid) / 100,
      balance: r.closingBalance / 100,
      status: r.status,
    })));

    const columns: ExcelColumn<ScheduleExportRow>[] = [
      { header: 'Loan No.', key: 'loanNo', value: (r) => r.loanNo },
      { header: 'Member No.', key: 'memberNo', value: (r) => r.memberNo },
      { header: 'Member Name', key: 'memberName', width: 24, value: (r) => r.memberName },
      { header: '#', key: 'installmentNo', value: (r) => r.installmentNo },
      { header: 'Due Date', key: 'dueDate', value: (r) => r.dueDate },
      { header: 'Opening', key: 'opening', width: 14, value: (r) => r.opening },
      { header: 'Principal', key: 'principal', width: 14, value: (r) => r.principal },
      { header: 'Interest', key: 'interest', width: 14, value: (r) => r.interest },
      { header: 'Instalment', key: 'instalment', width: 14, value: (r) => r.instalment },
      { header: 'Paid', key: 'paid', width: 14, value: (r) => r.paid },
      { header: 'Balance', key: 'balance', width: 14, value: (r) => r.balance },
      { header: 'Status', key: 'status', value: (r) => r.status },
    ];

    return {
      filename: `loan-schedule-${docs.map((d) => d.loan.loan_no).join('_') || 'export'}.xlsx`,
      buffer: await buildWorkbookBuffer('Repayment Schedule', columns, rows),
    };
  });
}
