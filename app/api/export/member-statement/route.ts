import { buildMemberStatements, type StatementAccountSection, type StatementLoanSection } from '@/lib/memberStatement';
import { buildWorkbookBuffer, excelExportResponse, type ExcelColumn } from '@/lib/excel';
import { formatDate } from '@/lib/format';

interface StatementExportRow {
  memberNo: string;
  memberName: string;
  kind: 'Account' | 'Loan';
  ref: string;
  product: string;
  date: string | null;
  documentNo: string | null;
  description: string;
  debit: number | null;
  credit: number | null;
  balance: number;
}

/** One flattened sheet — Member No./Name repeated on every row is what lets the sheet be
 *  filtered/pivoted per member in Excel, since a single workbook here (unlike the printout)
 *  covers every selected member and section at once. */
function flatten(
  memberNo: string, memberName: string,
  accounts: StatementAccountSection[], loans: StatementLoanSection[],
): StatementExportRow[] {
  const rows: StatementExportRow[] = [];

  for (const { account, opening, lines, closing } of accounts) {
    const ref = account.account_no;
    const product = account.product_name;
    rows.push({
      memberNo, memberName, kind: 'Account', ref, product,
      date: null, documentNo: null, description: 'Opening balance', debit: null, credit: null, balance: opening / 100,
    });
    for (const { txn: t, running } of lines) {
      rows.push({
        memberNo, memberName, kind: 'Account', ref, product,
        date: formatDate(t.value_date), documentNo: t.document_no, description: t.description || '',
        debit: t.amount < 0 ? -t.amount / 100 : null,
        credit: t.amount > 0 ? t.amount / 100 : null,
        balance: running / 100,
      });
    }
    rows.push({
      memberNo, memberName, kind: 'Account', ref, product,
      date: null, documentNo: null, description: 'Closing balance', debit: null, credit: null, balance: closing / 100,
    });
  }

  for (const { loan, opening, lines, closing } of loans) {
    const ref = loan.loan_no;
    const product = loan.product_name;
    if (opening !== 0) {
      rows.push({
        memberNo, memberName, kind: 'Loan', ref, product,
        date: null, documentNo: null, description: 'Opening balance', debit: null, credit: null, balance: opening / 100,
      });
    }
    for (const { txn: t, running } of lines) {
      rows.push({
        memberNo, memberName, kind: 'Loan', ref, product,
        date: formatDate(t.value_date), documentNo: t.document_no, description: t.description || '',
        debit: t.amount > 0 ? t.amount / 100 : null, credit: t.amount < 0 ? -t.amount / 100 : null,
        balance: running / 100,
      });
    }
    rows.push({
      memberNo, memberName, kind: 'Loan', ref, product,
      date: null, documentNo: null, description: 'Closing balance', debit: null, credit: null, balance: closing / 100,
    });
  }

  return rows;
}

const parseIds = (raw: string | null): number[] =>
  (raw ? raw.split(',') : []).map(Number).filter((n) => Number.isFinite(n) && n > 0);

export async function GET(request: Request): Promise<Response> {
  const { searchParams } = new URL(request.url);
  const memberIds = parseIds(searchParams.get('member'));
  const accountIds = parseIds(searchParams.get('account'));
  const loanIds = parseIds(searchParams.get('loan'));
  const from = searchParams.get('from') || undefined;
  const to = searchParams.get('to') || undefined;
  const showAccounts = searchParams.get('showAccounts') !== '0';
  const showLoans = searchParams.get('showLoans') !== '0';

  return excelExportResponse('MEMBER_STATEMENTS_READ', async () => {
    const docs = await buildMemberStatements({ memberIds, accountIds, loanIds, from, to, showAccounts, showLoans });
    const rows = docs.flatMap((d) => flatten(
      d.member.member_no, `${d.member.first_name} ${d.member.last_name}`, d.accounts, d.loans,
    ));

    const columns: ExcelColumn<StatementExportRow>[] = [
      { header: 'Member No.', key: 'memberNo', value: (r) => r.memberNo },
      { header: 'Member Name', key: 'memberName', width: 24, value: (r) => r.memberName },
      { header: 'Type', key: 'kind', value: (r) => r.kind },
      { header: 'Account / Loan No.', key: 'ref', value: (r) => r.ref },
      { header: 'Product', key: 'product', width: 24, value: (r) => r.product },
      { header: 'Date', key: 'date', value: (r) => r.date },
      { header: 'Document No.', key: 'documentNo', value: (r) => r.documentNo },
      { header: 'Description', key: 'description', width: 28, value: (r) => r.description },
      { header: 'Debit', key: 'debit', width: 14, value: (r) => r.debit },
      { header: 'Credit', key: 'credit', width: 14, value: (r) => r.credit },
      { header: 'Balance', key: 'balance', width: 14, value: (r) => r.balance },
    ];

    return {
      filename: `member-statement-${docs.map((d) => d.member.member_no).join('_') || 'export'}.xlsx`,
      buffer: await buildWorkbookBuffer('Member Statement', columns, rows),
    };
  });
}
