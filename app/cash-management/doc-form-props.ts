import { all } from '@/lib/db';
import { listBankAccounts } from '@/lib/bankMgmt';
import { listPostableAccounts } from '@/lib/gl';
import { listActiveVendors } from '@/lib/vendors';
import { listActiveCurrencies, listExternalBanks } from '@/lib/cashMgmtSetup';
import { listActivePaymentMethods } from '@/lib/receivablesSetup';
import { listVatProductPostingGroups } from '@/lib/vatSetup';
import { listReceiptMembers } from '@/lib/receipts';

/**
 * The lookups a Receipt or Payment Voucher line editor needs — banks, postable accounts,
 * customers, vendors, members, currencies, payment methods and the VAT / WHT codes.
 *
 * Shared by the Cash Management list tabs (which create documents) and the two document cards
 * (which now edit them in place while Open), so a document is offered exactly the same choices
 * wherever it is being worked on.
 */
export async function docFormProps() {
  const [banks, accounts, vendors, currencies, payMethods, vatGroups, extBanks, members] = await Promise.all([
    listBankAccounts(), listPostableAccounts(), listActiveVendors(), listActiveCurrencies(),
    listActivePaymentMethods(), listVatProductPostingGroups(), listExternalBanks(), listReceiptMembers(),
  ]);
  const customers = await all<{ no: string; name: string }>('SELECT no, name FROM customer ORDER BY no LIMIT 500');
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
    members,
  };
}
