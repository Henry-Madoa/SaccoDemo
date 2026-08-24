import { requireAction } from '@/lib/session';
import { getOrg } from '@/lib/org';
import { imageSrc } from '@/lib/cloudinary';
import { formatDate, formatStatementTimestamp } from '@/lib/format';
import {
  buildMemberStatements, listMemberAccountsForFilter, listMemberLoansForFilter, listMembersForStatementPicker,
  type MemberStatementDocument, type StatementAccountSection, type StatementLoanSection,
} from '@/lib/memberStatement';
import { Page } from '@/components/layout/page';
import {
  Card, CardHead, DefinitionList, EmptyState, Pill, TableWrap, Toolbar, Spacer,
} from '@/components/ui/primitives';
import { DateFilterExpressionInput } from '@/components/ui/filters';
import { MultiSelectFilter, BoolToggle } from '@/components/ui/multi-select-filter';
import { Money } from '@/components/ui/money';
import { DocumentActionsMenu } from '@/components/ui/document-actions';
import type { Organisation } from '@/lib/types';

const parseIds = (raw?: string): number[] =>
  (raw ? raw.split(',') : []).map(Number).filter((n) => Number.isFinite(n) && n > 0);

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

  const [org, allMembers, accountOptionRows, loanOptionRows, docs] = await Promise.all([
    getOrg(),
    listMembersForStatementPicker(),
    listMemberAccountsForFilter(memberIds),
    listMemberLoansForFilter(memberIds),
    memberIds.length
      ? buildMemberStatements({ memberIds, accountIds, loanIds, from, to, showAccounts, showLoans })
      : Promise.resolve([] as MemberStatementDocument[]),
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
        docs.map((doc) => (
          <StatementBlock
            key={doc.member.id} doc={doc} org={org} generatedBy={user.full_name}
            showAccounts={showAccounts} showLoans={showLoans}
          />
        ))
      )}
    </Page>
  );
}

function StatementBlock({ doc, org, generatedBy, showAccounts, showLoans }: {
  doc: MemberStatementDocument;
  org: Organisation | undefined;
  generatedBy: string;
  showAccounts: boolean;
  showLoans: boolean;
}) {
  const { member, accounts, loans } = doc;
  const fullName = [member.first_name, member.middle_name, member.last_name].filter(Boolean).join(' ');
  const generatedAt = formatStatementTimestamp();
  const logo = imageSrc(org?.logo, { width: 72, height: 72, crop: 'fit' });

  return (
    <div className="statement-block">
      <Card>
        <div className="statement-letterhead">
          {logo ? <img src={logo} alt={org?.name ?? ''} className="statement-logo" /> : null}
          <div>
            <div className="statement-org-name">{org?.name ?? '—'}</div>
            <div className="tiny">{[org?.physical_address, org?.postal_address].filter(Boolean).join(' · ')}</div>
            <div className="tiny">{[org?.phone_primary, org?.email, org?.website].filter(Boolean).join(' · ')}</div>
          </div>
        </div>
        <CardHead title="Account Statement" sub={`Member ${member.member_no} · generated ${generatedAt}`} />
        <div className="grid split-side-sm">
          <DefinitionList items={[
            ['Member No.', member.member_no],
            ['Member Name', fullName],
            ['ID No.', member.identification_no || '—'],
            ['KRA PIN', member.kra_pin || '—'],
            ['Staff / Payroll No.', member.staff_no || '—'],
          ]}
          />
          <DefinitionList items={[
            ['Phone No.', member.phone || '—'],
            ['Email Address', member.email || '—'],
            ['Employer', member.employer || '—'],
            ['Status', <Pill status={member.status} />],
          ]}
          />
        </div>
      </Card>

      {showAccounts ? (
        accounts.length
          ? accounts.map((s) => <AccountLedgerCard key={s.account.id} section={s} />)
          : <Card><EmptyState icon="💰" title="No eligible savings accounts for this member" /></Card>
      ) : null}

      {showLoans ? (
        loans.length
          ? loans.map((s) => <LoanLedgerCard key={s.loan.id} section={s} />)
          : <Card><EmptyState icon="📄" title="No disbursed loans for this member" /></Card>
      ) : null}

      <Card>
        <CardHead title="Attestation" />
        <div className="grid split-side-sm">
          <DefinitionList items={[
            ['Member No.', member.member_no],
            ['Member Name', fullName],
            ['ID No.', member.identification_no || '—'],
          ]}
          />
          <DefinitionList items={[
            ['Generated By', generatedBy],
            ['Date & Time', generatedAt],
            ['Stamp', '—'],
          ]}
          />
        </div>
      </Card>

      {org?.statement_footer ? <p className="note statement-footnote">{org.statement_footer}</p> : null}
    </div>
  );
}

/** Accounts: a deposit (credit) grows the member's balance, a withdrawal/charge (debit) shrinks
 *  it — see lib/memberStatement.ts's header comment for why the underlying running-balance math
 *  needs no separate sign rule per ledger kind; only which column a positive/negative amount is
 *  displayed under differs between an account and a loan. */
function AccountLedgerCard({ section }: { section: StatementAccountSection }) {
  const { account, opening, lines, closing } = section;
  return (
    <Card>
      <CardHead title={`${account.account_no} — ${account.product_name}`} sub="Savings account activity" />
      <TableWrap className="statement-ledger">
        <thead>
          <tr>
            <th>Date</th><th>Document No.</th><th>Description</th>
            <th className="num">Debit</th><th className="num">Credit</th><th className="num">Balance</th>
          </tr>
        </thead>
        <tbody>
          <tr>
            <td colSpan={5}><i>Opening balance</i></td>
            <td className="num"><b><Money cents={opening} symbol={false} /></b></td>
          </tr>
          {lines.length ? lines.map(({ txn: t, running }) => {
            const reversed = t.status === 'REVERSED';
            return (
              <tr key={t.id} className={reversed ? 'muted' : undefined}>
                <td>{formatDate(t.value_date)}</td>
                <td className="mono">{t.document_no || '—'}</td>
                <td>{t.description || ''}{reversed ? <> <Pill tone="bad">REVERSED</Pill></> : null}</td>
                <td className="num">{t.amount < 0 ? <Money cents={-t.amount} symbol={false} /> : ''}</td>
                <td className="num">{t.amount > 0 ? <Money cents={t.amount} symbol={false} /> : ''}</td>
                <td className="num"><Money cents={running} symbol={false} /></td>
              </tr>
            );
          }) : (
            <tr><td colSpan={6}><EmptyState icon="🧾" title="No activity in the selected period" /></td></tr>
          )}
        </tbody>
        <tfoot>
          <tr>
            <td colSpan={5}>Closing balance</td>
            <td className="num"><b><Money cents={closing} symbol={false} /></b></td>
          </tr>
        </tfoot>
      </TableWrap>
    </Card>
  );
}

/** Loans: a disbursement or charge (debit) grows the outstanding balance, a repayment (credit)
 *  shrinks it — the opposite column mapping from an account, even though `amount`'s sign already
 *  carries the correct arithmetic in both cases (see lib/memberStatement.ts). The Opening Balance
 *  row is only shown when non-zero, matching the reference statement (a loan with no pre-period
 *  history renders no opening line at all rather than a redundant "0.00" one). */
function LoanLedgerCard({ section }: { section: StatementLoanSection }) {
  const { loan, opening, lines, closing } = section;
  return (
    <Card>
      <CardHead title={`${loan.loan_no} — ${loan.product_name}`} sub="Loan account activity" />
      <TableWrap className="statement-ledger">
        <thead>
          <tr>
            <th>Date</th><th>Document No.</th><th>Description</th>
            <th className="num">Debit</th><th className="num">Credit</th><th className="num">Balance</th>
          </tr>
        </thead>
        <tbody>
          {opening !== 0 ? (
            <tr>
              <td colSpan={5}><i>Opening balance</i></td>
              <td className="num"><b><Money cents={opening} symbol={false} /></b></td>
            </tr>
          ) : null}
          {lines.length ? lines.map(({ txn: t, running }) => (
            <tr key={t.id} className={t.status === 'REVERSED' ? 'muted' : undefined}>
              <td>{formatDate(t.value_date)}</td>
              <td className="mono">{t.document_no || '—'}</td>
              <td>{t.description || ''}</td>
              <td className="num">{t.amount > 0 ? <Money cents={t.amount} symbol={false} /> : ''}</td>
              <td className="num">{t.amount < 0 ? <Money cents={-t.amount} symbol={false} /> : ''}</td>
              <td className="num"><Money cents={running} symbol={false} /></td>
            </tr>
          )) : (
            <tr><td colSpan={6}><EmptyState icon="🧾" title="No activity in the selected period" /></td></tr>
          )}
        </tbody>
        <tfoot>
          <tr>
            <td colSpan={5}>Closing balance</td>
            <td className="num"><b><Money cents={closing} symbol={false} /></b></td>
          </tr>
        </tfoot>
      </TableWrap>
    </Card>
  );
}
