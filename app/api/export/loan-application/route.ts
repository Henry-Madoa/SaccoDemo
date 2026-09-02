import { buildLoanApplicationDocuments } from '@/lib/loanDocuments';
import { buildWorkbookBuffer, excelExportResponse, type ExcelColumn } from '@/lib/excel';
import { formatDate } from '@/lib/format';
import type { LoanApplicationDocument } from '@/lib/loanDocuments';

const parseIds = (raw: string | null): number[] =>
  (raw ? raw.split(',') : []).map(Number).filter((n) => Number.isFinite(n) && n > 0);
const parseList = (raw: string | null): string[] => (raw ? raw.split(',').filter(Boolean) : []);

/** The Loan Application report as a flat table — one row per loan, carrying the same header-level
 *  data the printed application form shows (applicant, terms, disbursement, guarantor cover). */
export async function GET(request: Request): Promise<Response> {
  const { searchParams } = new URL(request.url);
  const selection = {
    loanIds: parseIds(searchParams.get('loan')),
    memberIds: parseIds(searchParams.get('member')),
    productIds: parseIds(searchParams.get('product')),
    statuses: parseList(searchParams.get('status')),
    appFrom: searchParams.get('appFrom') || null,
    appTo: searchParams.get('appTo') || null,
  };

  return excelExportResponse('LOAN_READ', async () => {
    const docs = await buildLoanApplicationDocuments(selection);

    const columns: ExcelColumn<LoanApplicationDocument>[] = [
      { header: 'Loan No.', key: 'loan_no', value: (d) => d.loan.loan_no },
      { header: 'Applied Date', key: 'applied', value: (d) => formatDate(d.loan.applied_date) },
      { header: 'Status', key: 'status', value: (d) => d.loan.status },
      { header: 'Member No.', key: 'member_no', value: (d) => d.loan.member_no },
      { header: 'Applicant', key: 'applicant', width: 24, value: (d) => `${d.applicant.first_name} ${d.applicant.last_name}` },
      { header: 'ID No.', key: 'id_no', value: (d) => d.applicant.identification_no ?? '' },
      { header: 'Age', key: 'age', width: 8, value: (d) => d.age ?? '' },
      { header: 'Phone', key: 'phone', value: (d) => d.applicant.phone ?? '' },
      { header: 'Email', key: 'email', width: 24, value: (d) => d.applicant.email ?? '' },
      { header: 'Staff / Payroll No.', key: 'staff_no', value: (d) => d.applicant.staff_no ?? '' },
      { header: 'Employer', key: 'employer', width: 22, value: (d) => d.applicant.employer ?? '' },
      { header: 'Product', key: 'product', width: 22, value: (d) => d.loan.product_name },
      { header: 'Amount Applied', key: 'principal', width: 16, value: (d) => d.loan.principal / 100 },
      { header: 'Term (months)', key: 'term', width: 14, value: (d) => d.loan.term_months },
      { header: 'Interest Rate %', key: 'rate', width: 14, value: (d) => d.loan.interest_rate },
      { header: 'Interest Method', key: 'method', width: 16, value: (d) => d.loan.interest_method },
      { header: 'Monthly Instalment', key: 'installment', width: 16, value: (d) => d.loan.installment / 100 },
      { header: 'Total Interest', key: 'total_interest', width: 16, value: (d) => d.loan.total_interest / 100 },
      { header: 'Purpose', key: 'purpose', width: 30, value: (d) => d.loan.purpose ?? '' },
      { header: 'Amount in Words', key: 'words', width: 40, value: (d) => d.amountInWords },
      {
        header: 'Disbursement Account', key: 'disb', width: 28,
        value: (d) => (d.disbursement ? `${d.disbursement.accountNo} — ${d.disbursement.productName}` : 'Cash / bank'),
      },
      { header: 'Guarantors', key: 'g_count', width: 12, value: (d) => d.guarantors.length },
      {
        header: 'Guaranteed Total', key: 'g_total', width: 16,
        value: (d) => d.guarantors.reduce((s, g) => s + g.amount, 0) / 100,
      },
    ];

    return {
      filename: `loan-application-${docs.map((d) => d.loan.loan_no).join('_') || 'export'}.xlsx`,
      buffer: await buildWorkbookBuffer('Loan Application', columns, docs),
    };
  });
}
