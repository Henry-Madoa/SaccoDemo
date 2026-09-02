import { buildLoanAppraisalDocuments } from '@/lib/loanDocuments';
import { buildWorkbookBuffer, excelExportResponse, type ExcelColumn } from '@/lib/excel';
import { formatDate, formatDateTime } from '@/lib/format';
import type { LoanAppraisalDocument } from '@/lib/loanDocuments';

const parseIds = (raw: string | null): number[] =>
  (raw ? raw.split(',') : []).map(Number).filter((n) => Number.isFinite(n) && n > 0);
const parseList = (raw: string | null): string[] => (raw ? raw.split(',').filter(Boolean) : []);

/** The Loan Appraisal report as a flat table — one row per loan, summarising the decision plus
 *  the guarantor / collateral / charge cover the printed appraisal lays out in full. */
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
    const docs = await buildLoanAppraisalDocuments(selection);

    const columns: ExcelColumn<LoanAppraisalDocument>[] = [
      { header: 'Loan No.', key: 'loan_no', value: (d) => d.loan.loan_no },
      { header: 'Applied Date', key: 'applied', value: (d) => formatDate(d.loan.applied_date) },
      { header: 'Status', key: 'status', value: (d) => d.loan.status },
      { header: 'Member No.', key: 'member_no', value: (d) => d.loan.member_no },
      { header: 'Applicant', key: 'applicant', width: 24, value: (d) => `${d.applicant.first_name} ${d.applicant.last_name}` },
      { header: 'Product', key: 'product', width: 22, value: (d) => d.loan.product_name },
      { header: 'Applied Amount', key: 'principal', width: 16, value: (d) => d.loan.principal / 100 },
      { header: 'Term (months)', key: 'term', width: 14, value: (d) => d.loan.term_months },
      { header: 'Appraised', key: 'appraised', width: 10, value: (d) => (d.appraisal ? 'Yes' : 'No') },
      { header: 'Decision', key: 'decision', width: 12, value: (d) => d.appraisal?.decision ?? '' },
      { header: 'Score', key: 'score', width: 10, value: (d) => d.appraisal?.score ?? '' },
      { header: 'Monthly Instalment', key: 'installment', width: 16, value: (d) => (d.appraisal ? d.appraisal.installment / 100 : '') },
      { header: 'Deposit Ceiling', key: 'ceiling', width: 16, value: (d) => (d.appraisal ? d.appraisal.max_by_multiplier / 100 : '') },
      { header: 'Existing Exposure', key: 'exposure', width: 16, value: (d) => (d.appraisal ? d.appraisal.exposure / 100 : '') },
      { header: 'Deduction Ratio %', key: 'dsr', width: 16, value: (d) => d.appraisal?.dsr ?? '' },
      { header: 'Guarantors', key: 'g_count', width: 12, value: (d) => d.guarantors.length },
      { header: 'Guaranteed Total', key: 'g_total', width: 16, value: (d) => d.guarantors.reduce((s, g) => s + g.amount, 0) / 100 },
      { header: 'Collateral Items', key: 'c_count', width: 14, value: (d) => d.collateral.length },
      { header: 'Collateral Cover', key: 'c_total', width: 16, value: (d) => d.collateral.reduce((s, c) => s + c.guarantee, 0) / 100 },
      { header: 'Charges Total', key: 'ch_total', width: 16, value: (d) => d.charges.reduce((s, c) => s + c.amount, 0) / 100 },
      { header: 'Appraised By', key: 'appraised_by', width: 18, value: (d) => d.appraisal?.appraised_by ?? '' },
      { header: 'Appraised On', key: 'appraised_on', width: 20, value: (d) => (d.appraisal?.appraised_at ? formatDateTime(d.appraisal.appraised_at) : '') },
    ];

    return {
      filename: `loan-appraisal-${docs.map((d) => d.loan.loan_no).join('_') || 'export'}.xlsx`,
      buffer: await buildWorkbookBuffer('Loan Appraisal', columns, docs),
    };
  });
}
