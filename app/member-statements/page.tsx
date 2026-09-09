import { requireAction } from '@/lib/session';
import { renderDocuments } from '@/lib/documentPrint';
import {
  listMemberAccountsForFilter, listMemberLoansForFilter, listMembersForStatementPicker,
} from '@/lib/memberStatement';
import { buildMemberStatementPrints } from '@/lib/memberStatementPrint';
import { Page } from '@/components/layout/page';
import { EmptyState, Toolbar, Spacer } from '@/components/ui/primitives';
import { DateFilterExpressionInput } from '@/components/ui/filters';
import { MultiSelectFilter, BoolToggle } from '@/components/ui/multi-select-filter';
import { DocumentActionsMenu } from '@/components/ui/document-actions';
import type { PrintDocument } from '@/lib/documentPrint';

const parseIds = (raw?: string): number[] =>
  (raw ? raw.split(',') : []).map(Number).filter((n) => Number.isFinite(n) && n > 0);

/**
 * Member Statement — filters on top, and below them the statement itself, rendered through the
 * shared document chrome (lib/documentPrint.ts) that prints the Sales Invoice and the Payment
 * Voucher. What is on screen IS the printout: the filters and the action bar are `@media print`
 * casualties, so Print / Save as PDF and the ?preview=1 tab all emit the same sheets.
 */
export default async function MemberStatementsPage({ searchParams }: {
  searchParams: Promise<{
    member?: string; account?: string; loan?: string; from?: string; to?: string;
    showAccounts?: string; showLoans?: string;
  }>;
}) {
  const user = await requireAction('MEMBER_STATEMENTS_READ');
  const {
    member, account, loan, from, to, showAccounts: showAccountsRaw, showLoans: showLoansRaw,
  } = await searchParams;

  const memberIds = parseIds(member);
  const accountIds = parseIds(account);
  const loanIds = parseIds(loan);
  const showAccounts = showAccountsRaw !== '0';
  const showLoans = showLoansRaw !== '0';

  const [allMembers, accountOptionRows, loanOptionRows, docs] = await Promise.all([
    listMembersForStatementPicker(),
    listMemberAccountsForFilter(memberIds),
    listMemberLoansForFilter(memberIds),
    memberIds.length
      ? buildMemberStatementPrints(
        { memberIds, accountIds, loanIds, from, to, showAccounts, showLoans },
        { username: user.username, full_name: user.full_name },
      )
      : Promise.resolve([] as PrintDocument[]),
  ]);

  const memberOptions = allMembers.map((m) => ({ value: String(m.id), label: `${m.member_no} — ${m.first_name} ${m.last_name}` }));
  const accountOptions = accountOptionRows.map((a) => ({ value: String(a.id), label: `${a.account_no} — ${a.product_name}` }));
  const loanOptions = loanOptionRows.map((l) => ({ value: String(l.id), label: `${l.loan_no} — ${l.product_name}` }));

  const exportParams = {
    member, account, loan, from, to,
    showAccounts: showAccounts ? undefined : '0',
    showLoans: showLoans ? undefined : '0',
  };

  return (
    <Page title="Member Statement" crumb="Multi-filter statement of account and loan activity" user={user}>
      <Toolbar>
        <MultiSelectFilter paramName="member" label="Member" required options={memberOptions} placeholder="Search member no. or name…" />
        <MultiSelectFilter
          paramName="account" label="Account" options={accountOptions}
          disabled={!memberIds.length} placeholder="All eligible accounts"
        />
        <MultiSelectFilter
          paramName="loan" label="Loan" options={loanOptions}
          disabled={!memberIds.length} placeholder="All disbursed loans"
        />
        <DateFilterExpressionInput fromParam="from" toParam="to" placeholder="Date filter — e.g. 01/01/26..31/12/26 or ..T" />
      </Toolbar>
      <Toolbar>
        <BoolToggle paramName="showAccounts" label="Show accounts" />
        <BoolToggle paramName="showLoans" label="Show loans" />
        <Spacer />
        <DocumentActionsMenu
          excel={{ href: '/api/export/member-statement', params: exportParams, disabled: !docs.length, label: 'Statement (.xlsx)' }}
        />
      </Toolbar>

      {!memberIds.length ? (
        <EmptyState icon="🧾" title="Select at least one member" sub="Pick one or more members above to generate their statement." />
      ) : !docs.length ? (
        <EmptyState icon="🔎" title="No matching members" sub="The selected member(s) could not be found." />
      ) : (
        // One sheet per member — renderDocuments() emits the shared stylesheet once and breaks
        // the page between documents.
        <div dangerouslySetInnerHTML={{ __html: renderDocuments(docs) }} />
      )}
    </Page>
  );
}
