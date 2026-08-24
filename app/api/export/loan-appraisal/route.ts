import { getLoan, listLoanAppraisals } from '@/lib/loanService';
import { buildWorkbookBuffer, excelExportResponse, type ExcelColumn } from '@/lib/excel';
import { formatDateTime } from '@/lib/format';
import type { LoanAppraisalFactorRow, LoanAppraisalRow, LoanFull } from '@/lib/types';

interface AppraisalReportRow {
  loan: LoanFull;
  appraisal: LoanAppraisalRow;
  factor: LoanAppraisalFactorRow;
}

/** The printable/exportable Appraisal Report: the latest loan_appraisal on file for a loan
 *  (or a specific earlier run, via ?appraisalId=), one row per policy factor it assessed —
 *  same shape savings-statement's export follows, narrowed to a single loan's decision. */
export async function GET(request: Request): Promise<Response> {
  const { searchParams } = new URL(request.url);
  const id = Number(searchParams.get('id'));
  const appraisalId = searchParams.get('appraisalId') ? Number(searchParams.get('appraisalId')) : undefined;

  return excelExportResponse('LOAN_READ', async () => {
    const [loan, appraisals] = await Promise.all([getLoan(id), listLoanAppraisals(id)]);
    if (!loan) throw new Error('Loan not found');
    const appraisal = appraisalId ? appraisals.find((a) => a.id === appraisalId) : appraisals[0];

    const rows: AppraisalReportRow[] = appraisal
      ? appraisal.factors.map((factor) => ({ loan, appraisal, factor }))
      : [];

    const columns: ExcelColumn<AppraisalReportRow>[] = [
      { header: 'Loan No.', key: 'loan_no', value: (r) => r.loan.loan_no },
      { header: 'Member', key: 'member', value: (r) => `${r.loan.first_name} ${r.loan.last_name}` },
      { header: 'Product', key: 'product', value: (r) => r.loan.product_name },
      { header: 'Decision', key: 'decision', value: (r) => r.appraisal.decision },
      { header: 'Score', key: 'score', width: 10, value: (r) => r.appraisal.score },
      { header: 'Factor', key: 'factor', width: 32, value: (r) => r.factor.label },
      { header: 'Result', key: 'result', width: 10, value: (r) => (r.factor.pass ? 'PASS' : 'FAIL') },
      { header: 'Detail', key: 'detail', width: 40, value: (r) => r.factor.detail },
      { header: 'Monthly instalment', key: 'installment', width: 18, value: (r) => r.appraisal.installment / 100 },
      { header: 'Deposit ceiling', key: 'ceiling', width: 18, value: (r) => r.appraisal.max_by_multiplier / 100 },
      { header: 'Existing exposure', key: 'exposure', width: 18, value: (r) => r.appraisal.exposure / 100 },
      { header: 'Deduction ratio %', key: 'dsr', width: 16, value: (r) => r.appraisal.dsr },
      { header: 'Appraised by', key: 'appraised_by', value: (r) => r.appraisal.appraised_by },
      { header: 'Appraised on', key: 'appraised_on', width: 20, value: (r) => formatDateTime(r.appraisal.appraised_at) },
    ];

    return {
      filename: `appraisal-${loan.loan_no}.xlsx`,
      buffer: await buildWorkbookBuffer('Appraisal Report', columns, rows),
    };
  });
}
