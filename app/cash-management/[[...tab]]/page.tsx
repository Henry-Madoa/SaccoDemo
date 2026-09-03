import { notFound } from 'next/navigation';
import { requireAction, currentCanAction } from '@/lib/session';
import { all } from '@/lib/db';
import { listPostableAccounts } from '@/lib/gl';
import { listActivePaymentMethods } from '@/lib/receivablesSetup';
import { listActiveVendors } from '@/lib/vendors';
import {
  listBankAccounts, hasAnyBankAccounts, listBankAccountLedgerEntries, listBankReconciliations,
} from '@/lib/bankMgmt';
import {
  listCurrencies, listActiveCurrencies, listExchangeRates, listBankAccPostingGroups, listExternalBanks,
  getCashManagementSetup,
} from '@/lib/cashMgmtSetup';
import { listReceipts, hasAnyReceipts } from '@/lib/receipts';
import { listPaymentVouchers, hasAnyPaymentVouchers } from '@/lib/paymentVouchers';
import { listVatProductPostingGroups } from '@/lib/vatSetup';
import { findPendingRoutedTask } from '@/lib/workflow';
import { Page } from '@/components/layout/page';
import { Card, CardHead, EmptyState, Pill, TableWrap, Tabs, Toolbar, Spacer, type TabDefinition } from '@/components/ui/primitives';
import { SearchInput } from '@/components/ui/filters';
import { Money } from '@/components/ui/money';
import { ExportButton } from '@/components/ui/export-button';
import { formatDate } from '@/lib/format';
import {
  BankAccountFormButton, CurrencyFormButton, ExchangeRateFormButton, DeleteRateButton, CashMgmtSetupButton,
  BankAccPostingGroupButton, AdjustFxPanel,
} from '../cash-mgmt-forms';
import { NewReceiptButton } from '../receipt-form';
import { NewPvButton } from '../payment-voucher-form';
import { StartReconciliationButton } from '../reconciliation-actions';
import {
  SubmitButton, CancelApprovalButton, ApproveButton, RejectButton, ReopenButton, DeleteButton,
  PostReceiptButton, PostPvButton,
} from '../document-actions';

const TABS: TabDefinition[] = [
  { key: 'bank-accounts', label: 'Bank Accounts' },
  { key: 'ledger-entries', label: 'Bank Ledger' },
  { key: 'reconciliations', label: 'Reconciliation' },
  { key: 'receipts', label: 'Receipts' },
  { key: 'payment-vouchers', label: 'Payment Vouchers' },
  { key: 'currencies', label: 'Currencies' },
  { key: 'exchange-rates', label: 'Exchange Rates' },
  { key: 'posting-groups', label: 'Posting Groups' },
  { key: 'external-banks', label: 'External Banks' },
  { key: 'setup', label: 'Setup' },
];

export default async function CashManagementPage({ params, searchParams }: {
  params: Promise<{ tab?: string[] }>;
  searchParams: Promise<{ q?: string; bank?: string }>;
}) {
  const user = await requireAction('CASH_MGMT_READ');
  const { tab: segments } = await params;
  const sp = await searchParams;
  const tab = segments?.[0] ?? 'bank-accounts';
  if (!TABS.some((t) => t.key === tab)) notFound();

  return (
    <Page title="Cash Management" crumb="Bank accounts, reconciliation, receipts, payment vouchers and currencies" user={user}>
      <Tabs tabs={TABS} active={tab} hrefFor={(k) => `/cash-management/${k === 'bank-accounts' ? '' : k}`} />
      {tab === 'bank-accounts' ? <BankAccountsTab /> : null}
      {tab === 'ledger-entries' ? <LedgerTab bank={sp.bank} /> : null}
      {tab === 'reconciliations' ? <ReconciliationsTab /> : null}
      {tab === 'receipts' ? <ReceiptsTab search={sp.q ?? ''} username={user.username} /> : null}
      {tab === 'payment-vouchers' ? <PvTab search={sp.q ?? ''} username={user.username} /> : null}
      {tab === 'currencies' ? <CurrenciesTab /> : null}
      {tab === 'exchange-rates' ? <ExchangeRatesTab /> : null}
      {tab === 'posting-groups' ? <PostingGroupsTab /> : null}
      {tab === 'external-banks' ? <ExternalBanksTab /> : null}
      {tab === 'setup' ? <SetupTab /> : null}
    </Page>
  );
}

async function docFormProps() {
  const [banks, accounts, vendors, currencies, payMethods, vatGroups, extBanks] = await Promise.all([
    listBankAccounts(), listPostableAccounts(), listActiveVendors(), listActiveCurrencies(),
    listActivePaymentMethods(), listVatProductPostingGroups(), listExternalBanks(),
  ]);
  const customers = await all<{ no: string; name: string }>("SELECT no, name FROM customer ORDER BY no LIMIT 500");
  return {
    banks: banks.map((b) => ({ id: b.id, code: b.code, name: b.name, currency_code: b.currency_code })),
    accounts: accounts.map((a) => ({ code: a.code, name: a.name })),
    vendors: vendors.map((v) => ({ no: v.no, name: v.name })),
    customers,
    currencies: currencies.map((c) => ({ code: c.code })),
    payMethods: payMethods.map((m) => ({ code: m.code })),
    vatCodes: vatGroups.filter((g) => g.tax_type === 'VAT').map((g) => ({ code: g.code, description: g.description })),
    whtCodes: vatGroups.filter((g) => g.tax_type === 'WHT').map((g) => ({ code: g.code, description: g.description })),
    externalBanks: extBanks.map((b) => ({ code: b.code, name: b.name })),
  };
}

/* ---------------------------------------------------------------- Bank Accounts */

async function BankAccountsTab() {
  const [rows, empty, canManage, postingGroups, extBanks, currencies, accounts] = await Promise.all([
    listBankAccounts(), hasAnyBankAccounts().then((a) => !a), currentCanAction('CASH_MGMT_BANK_MANAGE'),
    listBankAccPostingGroups(), listExternalBanks(), listActiveCurrencies(), listPostableAccounts(),
  ]);
  const fp = { postingGroups, externalBanks: extBanks.map((b) => ({ code: b.code, name: b.name })), currencies: currencies.map((c) => ({ code: c.code })), accounts };
  return (
    <>
      <Toolbar><Spacer />{canManage ? <BankAccountFormButton {...fp}>New bank account</BankAccountFormButton> : null}</Toolbar>
      <Card>
        {rows.length ? (
          <TableWrap>
            <thead><tr><th>Code</th><th>Name</th><th>Currency</th><th>Posting group</th><th>Control acct</th><th className="num">Balance</th><th className="num">Balance (LCY)</th><th>Status</th><th /></tr></thead>
            <tbody>
              {rows.map((b) => (
                <tr key={b.id} className={b.status === 'ACTIVE' ? undefined : 'muted'}>
                  <td className="mono">{b.code}</td>
                  <td>{b.name}</td>
                  <td className="mono">{b.currency_code}</td>
                  <td className="mono muted-cell">{b.bank_acc_posting_group_code ?? '—'}</td>
                  <td className="mono muted-cell">{b.gl_account_code}</td>
                  <td className="num"><Money cents={b.balance} /></td>
                  <td className="num"><Money cents={b.balance_lcy} /></td>
                  <td>{b.blocked ? <Pill tone="bad">Blocked</Pill> : b.status === 'ACTIVE' ? <Pill status="ok">Active</Pill> : <Pill tone="warn">Inactive</Pill>}</td>
                  <td className="num">
                    <div className="inline" style={{ justifyContent: 'flex-end' }}>
                      <a className="btn sm ghost" href={`/cash-management/ledger-entries?bank=${b.id}`}>Ledger</a>
                      {canManage ? <BankAccountFormButton account={b} {...fp} className="btn sm ghost">Edit</BankAccountFormButton> : null}
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </TableWrap>
        ) : <EmptyState icon="🏦" title="No bank accounts yet" />}
      </Card>
    </>
  );
}

async function LedgerTab({ bank }: { bank?: string }) {
  const banks = await listBankAccounts();
  const bankId = bank ? Number(bank) : banks[0]?.id;
  const rows = bankId ? await listBankAccountLedgerEntries({ bankAccountId: bankId }) : [];
  return (
    <>
      <Toolbar>
        <form className="inline" style={{ gap: 8 }}>
          <select name="bank" defaultValue={String(bankId ?? '')} aria-label="Bank account">
            {banks.map((b) => <option key={b.id} value={b.id}>{b.code} — {b.name}</option>)}
          </select>
          <button type="submit" className="btn sm">View</button>
        </form>
        <Spacer />
        <ExportButton href="/api/export/bank-ledger" params={{ bankAccountId: String(bankId ?? '') }} disabled={!rows.length} />
      </Toolbar>
      <Card>
        <CardHead title="Bank Account Ledger Entries" sub="Every movement through this account — the reconcilable record" />
        {rows.length ? (
          <TableWrap>
            <thead><tr><th>Date</th><th>Doc type</th><th>Doc no.</th><th>External</th><th>Description</th><th className="num">Amount</th><th className="num">Amount (LCY)</th><th>Open</th><th>Stmt</th></tr></thead>
            <tbody>
              {rows.map((e) => (
                <tr key={e.id} className={e.open ? undefined : 'muted'}>
                  <td>{formatDate(e.posting_date)}</td>
                  <td>{e.document_type || '—'}</td>
                  <td className="mono">{e.document_no ?? '—'}</td>
                  <td className="mono muted-cell">{e.external_document_no ?? '—'}</td>
                  <td>{e.description ?? '—'}</td>
                  <td className="num"><Money cents={e.amount} /></td>
                  <td className="num"><Money cents={e.amount_lcy} /></td>
                  <td>{e.open ? <Pill tone="warn">Open</Pill> : <Pill status="ok">Reconciled</Pill>}</td>
                  <td className="mono muted-cell">{e.statement_no ?? '—'}</td>
                </tr>
              ))}
            </tbody>
          </TableWrap>
        ) : <EmptyState icon="📓" title="No ledger entries" />}
      </Card>
    </>
  );
}

async function ReconciliationsTab() {
  const [rows, banks, canManage] = await Promise.all([
    listBankReconciliations(), listBankAccounts(), currentCanAction('CASH_MGMT_RECONCILE'),
  ]);
  return (
    <>
      <Toolbar><Spacer />{canManage ? <StartReconciliationButton banks={banks.map((b) => ({ id: b.id, code: b.code, name: b.name }))} /> : null}</Toolbar>
      <Card>
        {rows.length ? (
          <TableWrap>
            <thead><tr><th>Statement no.</th><th>Bank</th><th>Date</th><th className="num">Ending balance</th><th>Status</th><th /></tr></thead>
            <tbody>
              {rows.map((r) => (
                <tr key={r.id}>
                  <td className="mono">{r.statement_no ?? '—'}</td>
                  <td className="mono">{r.bank_account_code}</td>
                  <td>{formatDate(r.statement_date)}</td>
                  <td className="num"><Money cents={r.statement_balance} /></td>
                  <td><Pill status={r.status === 'POSTED' ? 'ok' : 'warn'}>{r.status}</Pill></td>
                  <td className="num"><a className="btn sm ghost" href={`/cash-management/reconciliations/${r.id}`}>Open</a></td>
                </tr>
              ))}
            </tbody>
          </TableWrap>
        ) : <EmptyState icon="✔" title="No reconciliations yet" />}
      </Card>
    </>
  );
}

/* ------------------------------------------------------------------ Receipts */

async function ReceiptsTab({ search, username }: { search: string; username: string }) {
  const [rows, empty, canCreate, canApprove, canPost, fp] = await Promise.all([
    listReceipts({ search }), hasAnyReceipts().then((a) => !a),
    currentCanAction('CASH_MGMT_RECEIPT_CREATE'), currentCanAction('CASH_MGMT_RECEIPT_APPROVE'),
    currentCanAction('CASH_MGMT_RECEIPT_POST'), docFormProps(),
  ]);
  const routed = new Map(await Promise.all(
    rows.filter((r) => r.status === 'Pending Approval').map((r) => findPendingRoutedTask('RECEIPT', r.no).then((t) => [r.no, !!t] as const)),
  ));
  return (
    <>
      <Toolbar>
        <SearchInput placeholder="Search no., narration, ref…" disabled={empty} />
        <Spacer />
        {canCreate ? <NewReceiptButton {...fp} /> : null}
      </Toolbar>
      <Card>
        {rows.length ? (
          <TableWrap>
            <thead><tr><th>No.</th><th>Date</th><th>Bank</th><th>Received from</th><th className="num">Amount</th><th>Status</th><th className="num" /></tr></thead>
            <tbody>
              {rows.map((r) => {
                const isOwn = r.created_by === username;
                return (
                  <tr key={r.no} className={r.posted ? 'muted' : undefined}>
                    <td className="mono"><a href={`/cash-management/receipts/${r.no}`}>{r.no}</a></td>
                    <td>{formatDate(r.posting_date)}</td>
                    <td className="mono muted-cell">{r.bank_account_code}</td>
                    <td>{r.description ?? '—'}</td>
                    <td className="num"><Money cents={r.amount} /> <span className="tiny muted-cell">{r.currency_code}</span></td>
                    <td>{r.posted ? <Pill status="ok">Posted</Pill> : <Pill status={r.status} />}</td>
                    <td className="num">
                      <div className="inline" style={{ justifyContent: 'flex-end' }}>
                        {!r.posted && r.status === 'Open' && canCreate && isOwn ? (<><SubmitButton no={r.no} kind="receipt" /><DeleteButton no={r.no} kind="receipt" /></>) : null}
                        {r.status === 'Pending Approval' && canCreate && isOwn && !routed.get(r.no) ? <CancelApprovalButton no={r.no} kind="receipt" /> : null}
                        {r.status === 'Pending Approval' && (canApprove || routed.get(r.no)) ? (<><ApproveButton no={r.no} kind="receipt" /><RejectButton no={r.no} kind="receipt" /></>) : null}
                        {!r.posted && r.status === 'Approved' && canApprove ? <ReopenButton no={r.no} kind="receipt" /> : null}
                        {!r.posted && (r.status === 'Approved' || r.status === 'Open') && canPost ? <PostReceiptButton no={r.no} /> : null}
                        {r.posted ? <a className="btn sm ghost" href={`/receipt-slip/${r.no}`} target="_blank" rel="noreferrer">Print</a> : null}
                      </div>
                    </td>
                  </tr>
                );
              })}
            </tbody>
          </TableWrap>
        ) : <EmptyState icon="🧾" title={empty ? 'No receipts yet' : 'Nothing matches'} />}
      </Card>
    </>
  );
}

async function PvTab({ search, username }: { search: string; username: string }) {
  const [rows, empty, canCreate, canApprove, canPost, fp] = await Promise.all([
    listPaymentVouchers({ search }), hasAnyPaymentVouchers().then((a) => !a),
    currentCanAction('CASH_MGMT_PV_CREATE'), currentCanAction('CASH_MGMT_PV_APPROVE'),
    currentCanAction('CASH_MGMT_PV_POST'), docFormProps(),
  ]);
  const routed = new Map(await Promise.all(
    rows.filter((r) => r.status === 'Pending Approval').map((r) => findPendingRoutedTask('PAYMENT_VOUCHER', r.no).then((t) => [r.no, !!t] as const)),
  ));
  return (
    <>
      <Toolbar>
        <SearchInput placeholder="Search no., payee, cheque…" disabled={empty} />
        <Spacer />
        {canCreate ? <NewPvButton {...fp} /> : null}
      </Toolbar>
      <Card>
        {rows.length ? (
          <TableWrap>
            <thead><tr><th>No.</th><th>Date</th><th>Paying bank</th><th>Payee</th><th>Cheque</th><th className="num">Net paid</th><th>Status</th><th className="num" /></tr></thead>
            <tbody>
              {rows.map((r) => {
                const isOwn = r.created_by === username;
                return (
                  <tr key={r.no} className={r.posted ? 'muted' : undefined}>
                    <td className="mono"><a href={`/cash-management/payment-vouchers/${r.no}`}>{r.no}</a></td>
                    <td>{formatDate(r.date)}</td>
                    <td className="mono muted-cell">{r.paying_bank_account_code}</td>
                    <td>{r.payee_name ?? '—'}</td>
                    <td className="mono muted-cell">{r.cheque_no ?? '—'}</td>
                    <td className="num"><Money cents={r.total_amount} /> <span className="tiny muted-cell">{r.currency_code}</span></td>
                    <td>{r.posted ? <Pill status="ok">Posted</Pill> : <Pill status={r.status} />}</td>
                    <td className="num">
                      <div className="inline" style={{ justifyContent: 'flex-end' }}>
                        {!r.posted && r.status === 'Open' && canCreate && isOwn ? (<><SubmitButton no={r.no} kind="pv" /><DeleteButton no={r.no} kind="pv" /></>) : null}
                        {r.status === 'Pending Approval' && canCreate && isOwn && !routed.get(r.no) ? <CancelApprovalButton no={r.no} kind="pv" /> : null}
                        {r.status === 'Pending Approval' && (canApprove || routed.get(r.no)) ? (<><ApproveButton no={r.no} kind="pv" /><RejectButton no={r.no} kind="pv" /></>) : null}
                        {!r.posted && r.status === 'Approved' && canApprove ? <ReopenButton no={r.no} kind="pv" /> : null}
                        {!r.posted && (r.status === 'Approved' || r.status === 'Open') && canPost ? <PostPvButton no={r.no} /> : null}
                        {r.posted ? <a className="btn sm ghost" href={`/pv-slip/${r.no}`} target="_blank" rel="noreferrer">Slip</a> : null}
                      </div>
                    </td>
                  </tr>
                );
              })}
            </tbody>
          </TableWrap>
        ) : <EmptyState icon="💸" title={empty ? 'No payment vouchers yet' : 'Nothing matches'} />}
      </Card>
    </>
  );
}

/* ---------------------------------------------------------------- Currencies */

async function CurrenciesTab() {
  const [rows, canManage, accounts] = await Promise.all([
    listCurrencies(), currentCanAction('CURRENCY_SETUP_MANAGE'), listPostableAccounts(),
  ]);
  return (
    <>
      <Toolbar><Spacer />{canManage ? <CurrencyFormButton accounts={accounts}>New currency</CurrencyFormButton> : null}</Toolbar>
      <Card>
        <CardHead title="Currencies" sub="Business Central Table 4 — the base currency plus every foreign currency the SACCO transacts in" />
        <TableWrap>
          <thead><tr><th>Code</th><th>Description</th><th>Base</th><th className="num">Latest rate</th><th className="num">Rates</th><th>Status</th><th /></tr></thead>
          <tbody>
            {rows.map((c) => (
              <tr key={c.id}>
                <td className="mono">{c.code}</td>
                <td>{c.description}</td>
                <td>{c.is_base ? <Pill status="ok">Base</Pill> : '—'}</td>
                <td className="num">{c.latest_rate ?? '—'}</td>
                <td className="num">{c.rate_count}</td>
                <td>{c.blocked ? <Pill tone="bad">Blocked</Pill> : <Pill status="ok">Active</Pill>}</td>
                <td className="num">{canManage && !c.is_base ? <CurrencyFormButton currency={c} accounts={accounts} className="btn sm ghost">Edit</CurrencyFormButton> : null}</td>
              </tr>
            ))}
          </tbody>
        </TableWrap>
      </Card>
    </>
  );
}

async function ExchangeRatesTab() {
  const [rates, currencies, canManage] = await Promise.all([
    listExchangeRates(), listActiveCurrencies(), currentCanAction('CASH_MGMT_CURRENCY_MANAGE'),
  ]);
  const fx = currencies.filter((c) => !c.is_base).map((c) => ({ code: c.code }));
  return (
    <>
      <Toolbar>
        <Spacer />
        {canManage ? <ExchangeRateFormButton currencies={fx}>Add rate</ExchangeRateFormButton> : null}
      </Toolbar>
      <Card>
        <CardHead title="Currency Exchange Rates" sub="LCY per the stated units — the factor postJournal() uses to convert FCY to KES" />
        {rates.length ? (
          <TableWrap>
            <thead><tr><th>Currency</th><th>Starting date</th><th className="num">Units</th><th className="num">Relational (LCY)</th><th className="num">Factor</th><th /></tr></thead>
            <tbody>
              {rates.map((r) => (
                <tr key={r.id}>
                  <td className="mono">{r.currency_code}</td>
                  <td>{formatDate(r.starting_date)}</td>
                  <td className="num">{r.exchange_rate_amount}</td>
                  <td className="num">{r.relational_exch_rate_amount}</td>
                  <td className="num">{(r.relational_exch_rate_amount / (r.exchange_rate_amount || 1)).toFixed(4)}</td>
                  <td className="num">{canManage ? <DeleteRateButton id={r.id} /> : null}</td>
                </tr>
              ))}
            </tbody>
          </TableWrap>
        ) : <EmptyState icon="💱" title="No exchange rates entered" />}
      </Card>
      <Card>
        <CardHead title="Adjust Exchange Rates" sub="Revalue open foreign-currency customer / vendor entries and bank balances to a period-end rate" />
        <AdjustFxPanel currencies={fx} />
      </Card>
    </>
  );
}

async function PostingGroupsTab() {
  const [rows, canManage, accounts] = await Promise.all([
    listBankAccPostingGroups(), currentCanAction('CASH_MGMT_BANK_MANAGE'), listPostableAccounts(),
  ]);
  return (
    <Card>
      <CardHead title="Bank Acc. Posting Groups" sub="Business Central Table 277 — the G/L control account a bank account resolves through">
        {canManage ? <BankAccPostingGroupButton accounts={accounts}>New group</BankAccPostingGroupButton> : null}
      </CardHead>
      <TableWrap>
        <thead><tr><th>Code</th><th>Description</th><th>Control acct</th><th className="num">Accounts</th><th /></tr></thead>
        <tbody>
          {rows.map((g) => (
            <tr key={g.id}>
              <td className="mono">{g.code}</td>
              <td>{g.description}</td>
              <td className="mono muted-cell">{g.gl_account_code} — {g.gl_account_name}</td>
              <td className="num">{g.accounts_using}</td>
              <td className="num">{canManage ? <BankAccPostingGroupButton row={g} accounts={accounts} className="btn sm ghost">Edit</BankAccPostingGroupButton> : null}</td>
            </tr>
          ))}
        </tbody>
      </TableWrap>
    </Card>
  );
}

async function ExternalBanksTab() {
  const banks = await listExternalBanks();
  return (
    <Card>
      <CardHead title="External Banks" sub="The Kenyan commercial-bank directory used for payee bank details" />
      <TableWrap>
        <thead><tr><th>Code</th><th>Name</th><th className="num">Branches</th></tr></thead>
        <tbody>{banks.map((b) => <tr key={b.id}><td className="mono">{b.code}</td><td>{b.name}</td><td className="num">{b.branch_count}</td></tr>)}</tbody>
      </TableWrap>
    </Card>
  );
}

async function SetupTab() {
  const [setup, banks, accounts, canManage] = await Promise.all([
    getCashManagementSetup(), listBankAccounts(), listPostableAccounts(), currentCanAction('CASH_MGMT_SETUP_MANAGE'),
  ]);
  return (
    <Card>
      <CardHead title="Cash Management Setup" sub="Approval limits, Transfer-to-G/L defaults and the posting-date window">
        {canManage ? <CashMgmtSetupButton setup={setup} banks={banks.map((b) => ({ id: b.id, code: b.code }))} accounts={accounts}>Edit setup</CashMgmtSetupButton> : null}
      </CardHead>
      <TableWrap>
        <tbody>
          <tr><td>Receipt approval limit</td><td><Money cents={setup.receipt_approval_limit} /></td></tr>
          <tr><td>Payment voucher approval limit</td><td><Money cents={setup.pv_approval_limit} /></td></tr>
          <tr><td>Default VAT business group</td><td className="mono">{setup.default_vat_bus_posting_group_code ?? '—'}</td></tr>
          <tr><td>Allow posting from / to</td><td>{setup.allow_cm_posting_from ?? '—'} / {setup.allow_cm_posting_to ?? '—'}</td></tr>
        </tbody>
      </TableWrap>
    </Card>
  );
}
