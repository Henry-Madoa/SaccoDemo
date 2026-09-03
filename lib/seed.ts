/*
 * Seeds the organisation, chart of accounts, products, RBAC, members and a
 * year of realistic transaction history. Idempotent: skips if already seeded.
 */
import { one, all, run, tx, nextSequence } from './db.ts';
import { hashPassword } from './auth.ts';
import { PRESETS } from './themes.ts';
import { postJournal } from './accounting.ts';
import * as savings from './savings.ts';
import * as loanSvc from './loanService.ts';
import { addMonths } from './loans.ts';
import { expandActionsToLines, type ActionKey } from './permissions.ts';
import { NO_SERIES_DOCUMENTS } from './noSeries.ts';
import * as faLib from './fixedAssets.ts';
import * as faJournalLib from './faJournal.ts';
import * as faDeprLib from './fixedAssetDepreciation.ts';
import * as custLib from './customers.ts';
import * as salesLib from './salesDocuments.ts';
import * as cashReceiptLib from './cashReceipts.ts';
import * as reminderLib from './reminders.ts';
import * as vendorLib from './vendors.ts';
import * as purchaseLib from './purchaseDocuments.ts';
import * as paymentJournalLib from './paymentJournal.ts';
import type {
  Actor, Cents, Channel, GlAccountType, IsoDate, IsoDateTime, LoanProduct, Member,
} from './types.ts';

const K = (n: number): Cents => Math.round(n * 100); // shillings -> cents

// deterministic PRNG so demo data is reproducible
let seedState = 20260811;
const rnd = (): number => ((seedState = (seedState * 1103515245 + 12345) & 0x7fffffff) / 0x7fffffff);
const pick = <T>(a: readonly T[]): T => a[Math.floor(rnd() * a.length)];
const int = (a: number, b: number): number => a + Math.floor(rnd() * (b - a + 1));

type ChartRow = [code: string, name: string, type: GlAccountType, parent: string | null, postable: 0 | 1];

const CHART: ChartRow[] = [
  ['1000', 'CASH AND CASH EQUIVALENTS', 'ASSET', null, 0],
  ['1010', 'Cash in Hand — Tellers', 'ASSET', '1000', 1],
  ['1020', 'Bank Current Account', 'ASSET', '1000', 1],
  ['1030', 'M-Pesa Settlement Account', 'ASSET', '1000', 1],
  ['1040', 'Check-off Receivable Clearing', 'ASSET', '1000', 1],
  ['1050', 'Cheques in Clearing', 'ASSET', '1000', 1],
  ['1015', 'Main Vault — Treasury', 'ASSET', '1000', 1],
  ['1016', 'Till 01 — Cash', 'ASSET', '1000', 1],
  ['1017', 'Till 02 — Cash', 'ASSET', '1000', 1],
  ['1100', 'LOANS AND ADVANCES TO MEMBERS', 'ASSET', null, 0],
  ['1110', 'Normal Loans Receivable', 'ASSET', '1100', 1],
  ['1120', 'Emergency Loans Receivable', 'ASSET', '1100', 1],
  ['1130', 'School Fees Loans Receivable', 'ASSET', '1100', 1],
  ['1140', 'Development Loans Receivable', 'ASSET', '1100', 1],
  ['1190', 'Provision for Loan Losses', 'ASSET', '1100', 1],
  ['1200', 'OTHER ASSETS', 'ASSET', null, 0],
  ['1210', 'Prepayments and Deposits', 'ASSET', '1200', 1],
  ['1240', 'TRADE AND OTHER RECEIVABLES', 'ASSET', null, 0],
  ['1250', 'Trade Receivables — Customers', 'ASSET', '1240', 1],
  ['1300', 'Property and Equipment', 'ASSET', null, 1],
  ['1400', 'PROPERTY, PLANT AND EQUIPMENT', 'ASSET', null, 0],
  ['1410', 'Land and Buildings at Cost', 'ASSET', '1400', 1],
  ['1420', 'Furniture, Fittings & Equipment at Cost', 'ASSET', '1400', 1],
  ['1425', 'Accum. Depreciation — Furniture, Fittings & Equipment', 'ASSET', '1400', 1],
  ['1430', 'Motor Vehicles at Cost', 'ASSET', '1400', 1],
  ['1435', 'Accum. Depreciation — Motor Vehicles', 'ASSET', '1400', 1],
  ['2000', 'MEMBER DEPOSITS', 'LIABILITY', null, 0],
  ['2010', 'BOSA Member Deposits', 'LIABILITY', '2000', 1],
  ['2020', 'FOSA Savings Accounts', 'LIABILITY', '2000', 1],
  ['2030', 'Fixed Deposits', 'LIABILITY', '2000', 1],
  ['2040', 'Holiday Savings', 'LIABILITY', '2000', 1],
  ['2100', 'OTHER LIABILITIES', 'LIABILITY', null, 0],
  ['2110', 'Accounts Payable and Accruals', 'LIABILITY', '2100', 1],
  ['2120', 'Interest Payable on Deposits', 'LIABILITY', '2100', 1],
  ['2130', 'Unallocated Receipts (Suspense)', 'LIABILITY', '2100', 1],
  ['2140', 'Bankers Cheques Payable', 'LIABILITY', '2100', 1],
  ['2145', 'TRADE AND OTHER PAYABLES', 'LIABILITY', null, 0],
  ['2150', 'Trade Payables — Vendors', 'LIABILITY', '2145', 1],
  ['2160', 'Goods Received Not Invoiced', 'LIABILITY', '2145', 1],
  ['3000', 'CAPITAL AND RESERVES', 'EQUITY', null, 0],
  ['3010', 'Member Share Capital', 'EQUITY', '3000', 1],
  ['3020', 'Statutory Reserve Fund', 'EQUITY', '3000', 1],
  ['3030', 'Retained Earnings', 'EQUITY', '3000', 1],
  ['4000', 'INCOME', 'INCOME', null, 0],
  ['4010', 'Interest on Member Loans', 'INCOME', '4000', 1],
  ['4020', 'Loan Processing and Insurance Fees', 'INCOME', '4000', 1],
  ['4030', 'Penalty and Default Income', 'INCOME', '4000', 1],
  ['4040', 'FOSA Commissions and Charges', 'INCOME', '4000', 1],
  ['4050', 'Other Operating Income', 'INCOME', '4000', 1],
  ['4060', 'Gain on Disposal of Property & Equipment', 'INCOME', '4000', 1],
  ['4090', 'SALES AND SERVICE INCOME', 'INCOME', null, 0],
  ['4092', 'Rental Income', 'INCOME', '4090', 1],
  ['4094', 'Service and Sundry Income', 'INCOME', '4090', 1],
  ['4096', 'Merchandise Sales', 'INCOME', '4090', 1],
  ['4098', 'Interest on Overdue Receivables', 'INCOME', '4090', 1],
  ['4099', 'Late Payment and Reminder Fees', 'INCOME', '4090', 1],
  ['5000', 'EXPENDITURE', 'EXPENSE', null, 0],
  ['5010', 'Interest on Member Deposits', 'EXPENSE', '5000', 1],
  ['5020', 'Staff Costs', 'EXPENSE', '5000', 1],
  ['5030', 'Administrative Expenses', 'EXPENSE', '5000', 1],
  ['5040', 'Loan Loss Provision Expense', 'EXPENSE', '5000', 1],
  ['5050', 'Governance and Board Expenses', 'EXPENSE', '5000', 1],
  ['5060', 'Depreciation Expense', 'EXPENSE', '5000', 1],
  ['5070', 'Repairs and Maintenance', 'EXPENSE', '5000', 1],
  ['5080', 'Loss on Disposal of Property & Equipment', 'EXPENSE', '5000', 1],
  ['5090', 'Cost of Goods Sold', 'EXPENSE', '5000', 1],
  // Cash Management + multi-currency + VAT/WHT
  ['1260', 'Input VAT (Recoverable)', 'ASSET', '1240', 1],
  ['2170', 'Cheques Not Presented', 'LIABILITY', '2145', 1],
  ['2190', 'Withholding Tax Payable', 'LIABILITY', '2100', 1],
  ['2195', 'Withholding VAT Payable', 'LIABILITY', '2100', 1],
  ['4070', 'Realized Exchange Gain', 'INCOME', '4000', 1],
  ['4072', 'Unrealized Exchange Gain', 'INCOME', '4000', 1],
  ['5085', 'Realized Exchange Loss', 'EXPENSE', '5000', 1],
  ['5087', 'Unrealized Exchange Loss', 'EXPENSE', '5000', 1],
];

interface RoleSeed {
  name: string;
  description: string;
  /** Which named actions (see lib/permissions.ts) this role's Permission Set lines
   *  are expanded from. System Administrator gets none — is_system implies full access. */
  actions: ActionKey[];
}

/** Every non-auditor operational role could reach /approvals under the old
 *  flat permission model (it had no gate of its own, just a login check) —
 *  carried forward here as an explicit grant on every seeded role. */
export const ROLES: RoleSeed[] = [
  { name: 'System Administrator', description: 'Full access including configuration and security.', actions: [] },
  {
    name: 'Branch Manager',
    description: 'Approves loans and oversees branch operations.',
    actions: [
      'MEMBERS_READ', 'MEMBER_STATEMENTS_READ', 'MEMBER_APPLICATIONS_READ', 'MEMBER_EDITS_READ', 'MEMBER_APPLICATIONS_CREATE',
      'MEMBERS_UPDATE', 'MEMBER_APPLICATIONS_UPDATE', 'MEMBER_EDITS_UPDATE', 'MEMBER_APPLICATIONS_APPROVE',
      'MEMBER_EDITS_APPROVE', 'ACCOUNT_OPENING_READ', 'ACCOUNT_OPENING_CREATE', 'ACCOUNT_OPENING_APPROVE',
      'ACCOUNT_DEACTIVATION_READ', 'ACCOUNT_DEACTIVATION_CREATE', 'ACCOUNT_DEACTIVATION_APPROVE',
      'ACCOUNT_ACTIVATION_READ', 'ACCOUNT_ACTIVATION_CREATE', 'ACCOUNT_ACTIVATION_APPROVE',
      'MEMBER_ACTIVATIONS_READ', 'MEMBER_ACTIVATIONS_CREATE', 'MEMBER_ACTIVATIONS_APPROVE',
      'MEMBER_READMISSIONS_READ', 'MEMBER_READMISSIONS_CREATE', 'MEMBER_READMISSIONS_APPROVE',
      'STANDING_ORDERS_READ', 'STANDING_ORDERS_CREATE', 'STANDING_ORDERS_APPROVE', 'STANDING_ORDERS_RUN',
      'MEMBER_CHARGING_READ', 'MEMBER_CHARGING_CREATE', 'MEMBER_CHARGING_POST',
      'CASH_MANAGEMENT_READ', 'CASH_MANAGEMENT_CREATE', 'CASH_MANAGEMENT_APPROVE', 'CASH_MANAGEMENT_POST',
      'TELLER_TRANSACTIONS_READ', 'TELLER_TRANSACTIONS_CREATE', 'TELLER_TRANSACTIONS_APPROVE', 'TELLER_TRANSACTIONS_POST',
      'LIENS_READ', 'LIENS_CREATE', 'LIENS_APPROVE', 'LIENS_POST',
      'INTER_ACCOUNT_TRANSFERS_READ', 'INTER_ACCOUNT_TRANSFERS_CREATE', 'INTER_ACCOUNT_TRANSFERS_APPROVE',
      'INTER_ACCOUNT_TRANSFERS_POST', 'INTER_ACCOUNT_TRANSFERS_CROSS_MEMBER',
      'BANKERS_CHEQUES_READ', 'BANKERS_CHEQUES_CREATE', 'BANKERS_CHEQUES_APPROVE', 'BANKERS_CHEQUES_POST',
      'BANKERS_CHEQUES_TYPES_MANAGE',
      'CHEQUE_DEPOSITS_READ', 'CHEQUE_DEPOSITS_CREATE', 'CHEQUE_DEPOSITS_APPROVE', 'CHEQUE_DEPOSITS_CLEAR',
      'CHEQUE_DEPOSITS_TYPES_MANAGE',
      'TELLER_SETUP_READ', 'TELLER_SETUP_MANAGE', 'DENOMINATIONS_READ',
      'ENTRANCE_FEE_RECOVERY_READ', 'ENTRANCE_FEE_RECOVERY_RUN',
      'MEMBER_STATUS_UPDATE_READ', 'MEMBER_STATUS_UPDATE_RUN', 'ADMIN_JOB_QUEUE_MANAGE',
      'SAVINGS_READ', 'SAVINGS_DEPOSIT', 'SAVINGS_WITHDRAW',
      'SAVINGS_REVERSE', 'LOAN_READ', 'LOAN_CREATE', 'LOAN_APPROVE', 'LOAN_DISBURSE', 'LOAN_REPAY', 'GL_READ',
      'INVENTORY_READ', 'INVENTORY_ITEM_MANAGE', 'INVENTORY_SETUP_MANAGE', 'INVENTORY_JOURNAL_CREATE',
      'INVENTORY_JOURNAL_APPROVE', 'INVENTORY_JOURNAL_POST',
      'FIXED_ASSETS_READ', 'FIXED_ASSETS_JOURNAL_APPROVE',
      'RECEIVABLES_READ', 'RECEIVABLES_SALES_APPROVE',
      'PAYABLES_READ', 'PAYABLES_PURCHASE_APPROVE',
      'CASH_MGMT_READ', 'CASH_MGMT_RECEIPT_APPROVE', 'CASH_MGMT_PV_APPROVE', 'CASH_MGMT_RECONCILE', 'VAT_REPORT_READ',
      'LOAN_CALCULATOR_READ', 'LOAN_CALCULATOR_CREATE', 'LOAN_CALCULATOR_DELETE', 'LOAN_CALCULATOR_CONVERT',
      'COLLATERAL_APPLICATIONS_READ', 'COLLATERAL_APPLICATIONS_CREATE', 'COLLATERAL_APPLICATIONS_APPROVE',
      'COLLATERAL_REGISTER_READ', 'COLLATERAL_RELEASES_READ', 'COLLATERAL_RELEASES_CREATE',
      'COLLATERAL_RELEASES_APPROVE', 'ADMIN_PRODUCTS_COLLATERAL_MANAGE', 'ADMIN_POOL_SECTORS_MANAGE',
      'ADMIN_NO_SERIES_READ', 'ADMIN_NO_SERIES_MANAGE',
      'ADMIN_ACCOUNT_INSTRUCTIONS_READ', 'ADMIN_ACCOUNT_INSTRUCTIONS_MANAGE',
      'GUARANTOR_CHANGES_READ', 'GUARANTOR_CHANGES_CREATE', 'GUARANTOR_CHANGES_APPROVE',
      'MEMBER_EXITS_READ', 'MEMBER_EXITS_CREATE', 'MEMBER_EXITS_APPROVE',
      'CHECKOFF_BATCHES_READ', 'CHECKOFF_BATCHES_CREATE', 'CHECKOFF_BATCHES_APPROVE', 'EMPLOYERS_MANAGE',
      'FIXED_DEPOSITS_READ', 'FIXED_DEPOSITS_CREATE', 'FIXED_DEPOSITS_APPROVE', 'ADMIN_PRODUCTS_FD_MANAGE',
      'FINANCIAL_REPORTS_READ',
      'DASHBOARD_VIEW', 'REPORTS_VIEW', 'APPROVALS_VIEW', 'ADMIN_AUDIT_VIEW', 'ADMIN_CHANGE_LOG_MANAGE',
    ],
  },
  {
    name: 'Loans Officer',
    description: 'Captures and appraises loan applications. Cannot approve own work.',
    actions: [
      'MEMBERS_READ', 'MEMBER_STATEMENTS_READ', 'MEMBER_APPLICATIONS_READ', 'MEMBER_EDITS_READ', 'MEMBER_APPLICATIONS_CREATE',
      'MEMBERS_UPDATE', 'MEMBER_APPLICATIONS_UPDATE', 'MEMBER_EDITS_UPDATE', 'ACCOUNT_OPENING_READ',
      'ACCOUNT_DEACTIVATION_READ', 'ACCOUNT_ACTIVATION_READ', 'MEMBER_ACTIVATIONS_READ', 'MEMBER_READMISSIONS_READ', 'STANDING_ORDERS_READ',
      'MEMBER_EXITS_READ', 'CHECKOFF_BATCHES_READ',
      'SAVINGS_READ', 'LOAN_READ', 'LOAN_CREATE', 'LOAN_REPAY',
      'LOAN_CALCULATOR_READ', 'LOAN_CALCULATOR_CREATE', 'LOAN_CALCULATOR_DELETE', 'LOAN_CALCULATOR_CONVERT',
      'COLLATERAL_APPLICATIONS_READ', 'COLLATERAL_APPLICATIONS_CREATE', 'COLLATERAL_REGISTER_READ',
      'COLLATERAL_RELEASES_READ', 'COLLATERAL_RELEASES_CREATE',
      'GUARANTOR_CHANGES_READ', 'GUARANTOR_CHANGES_CREATE',
      'FIXED_DEPOSITS_READ', 'FIXED_DEPOSITS_CREATE',
      'FINANCIAL_REPORTS_READ',
      'DASHBOARD_VIEW', 'REPORTS_VIEW', 'APPROVALS_VIEW',
    ],
  },
  {
    name: 'Teller',
    description: 'Front-office cash operations.',
    actions: [
      'MEMBERS_READ', 'MEMBER_STATEMENTS_READ', 'MEMBER_APPLICATIONS_READ', 'MEMBER_EDITS_READ', 'ACCOUNT_OPENING_READ',
      'ACCOUNT_OPENING_CREATE', 'ACCOUNT_DEACTIVATION_READ', 'ACCOUNT_DEACTIVATION_CREATE',
      'ACCOUNT_ACTIVATION_READ', 'ACCOUNT_ACTIVATION_CREATE',
      'MEMBER_ACTIVATIONS_READ', 'MEMBER_ACTIVATIONS_CREATE',
      'MEMBER_READMISSIONS_READ', 'MEMBER_READMISSIONS_CREATE',
      'STANDING_ORDERS_READ', 'STANDING_ORDERS_CREATE',
      'MEMBER_EXITS_READ', 'MEMBER_EXITS_CREATE',
      'CHECKOFF_BATCHES_READ', 'CHECKOFF_BATCHES_CREATE',
      'MEMBER_CHARGING_READ', 'MEMBER_CHARGING_CREATE', 'MEMBER_CHARGING_POST',
      'CASH_MANAGEMENT_READ', 'CASH_MANAGEMENT_CREATE', 'CASH_MANAGEMENT_POST',
      'TELLER_TRANSACTIONS_READ', 'TELLER_TRANSACTIONS_CREATE', 'TELLER_TRANSACTIONS_POST',
      'LIENS_READ', 'LIENS_CREATE', 'LIENS_POST',
      'INTER_ACCOUNT_TRANSFERS_READ', 'INTER_ACCOUNT_TRANSFERS_CREATE', 'INTER_ACCOUNT_TRANSFERS_POST',
      'INTER_ACCOUNT_TRANSFERS_CROSS_MEMBER',
      'BANKERS_CHEQUES_READ', 'BANKERS_CHEQUES_CREATE', 'BANKERS_CHEQUES_POST',
      'CHEQUE_DEPOSITS_READ', 'CHEQUE_DEPOSITS_CREATE', 'CHEQUE_DEPOSITS_CLEAR',
      'ENTRANCE_FEE_RECOVERY_READ', 'ENTRANCE_FEE_RECOVERY_RUN',
      'MEMBER_STATUS_UPDATE_READ', 'MEMBER_STATUS_UPDATE_RUN',
      'SAVINGS_READ', 'SAVINGS_DEPOSIT', 'SAVINGS_WITHDRAW', 'LOAN_READ', 'LOAN_REPAY',
      'COLLATERAL_APPLICATIONS_READ', 'COLLATERAL_REGISTER_READ', 'COLLATERAL_RELEASES_READ', 'GUARANTOR_CHANGES_READ',
      'FIXED_DEPOSITS_READ', 'FIXED_DEPOSITS_CREATE',
      'DASHBOARD_VIEW', 'REPORTS_VIEW', 'APPROVALS_VIEW',
    ],
  },
  {
    name: 'Finance Officer',
    description: 'General ledger, journals and financial reporting.',
    actions: [
      'MEMBERS_READ', 'MEMBER_STATEMENTS_READ', 'MEMBER_APPLICATIONS_READ', 'MEMBER_EDITS_READ', 'ACCOUNT_OPENING_READ',
      'ACCOUNT_DEACTIVATION_READ', 'ACCOUNT_ACTIVATION_READ', 'MEMBER_ACTIVATIONS_READ', 'MEMBER_READMISSIONS_READ', 'STANDING_ORDERS_READ',
      'MEMBER_CHARGING_READ', 'SAVINGS_READ', 'MEMBER_EXITS_READ',
      'CASH_MANAGEMENT_READ', 'CASH_MANAGEMENT_CREATE', 'CASH_MANAGEMENT_APPROVE', 'CASH_MANAGEMENT_POST',
      'TELLER_TRANSACTIONS_READ', 'TELLER_TRANSACTIONS_APPROVE',
      'LIENS_READ', 'LIENS_CREATE', 'LIENS_APPROVE', 'LIENS_POST',
      'INTER_ACCOUNT_TRANSFERS_READ', 'INTER_ACCOUNT_TRANSFERS_CREATE', 'INTER_ACCOUNT_TRANSFERS_APPROVE',
      'INTER_ACCOUNT_TRANSFERS_POST', 'INTER_ACCOUNT_TRANSFERS_CROSS_MEMBER',
      'BANKERS_CHEQUES_READ', 'BANKERS_CHEQUES_CREATE', 'BANKERS_CHEQUES_APPROVE', 'BANKERS_CHEQUES_POST',
      'BANKERS_CHEQUES_TYPES_MANAGE',
      'CHEQUE_DEPOSITS_READ', 'CHEQUE_DEPOSITS_CREATE', 'CHEQUE_DEPOSITS_APPROVE', 'CHEQUE_DEPOSITS_CLEAR',
      'CHEQUE_DEPOSITS_TYPES_MANAGE',
      'ENTRANCE_FEE_RECOVERY_READ', 'MEMBER_STATUS_UPDATE_READ',
      'CHECKOFF_BATCHES_READ',
      'LOAN_READ', 'GL_READ', 'GL_JOURNAL_CREATE', 'GL_JOURNAL_APPROVE', 'GL_JOURNAL_REVERSE', 'GL_PERIOD_CLOSE',
      'GL_ACCOUNT_MANAGE', 'GL_BANK_RECONCILE',
      'INVENTORY_READ', 'INVENTORY_ITEM_MANAGE', 'INVENTORY_SETUP_MANAGE', 'INVENTORY_JOURNAL_CREATE',
      'INVENTORY_JOURNAL_APPROVE', 'INVENTORY_JOURNAL_POST',
      'FIXED_ASSETS_READ', 'FIXED_ASSETS_ASSET_MANAGE', 'FIXED_ASSETS_SETUP_MANAGE', 'FIXED_ASSETS_JOURNAL_CREATE',
      'FIXED_ASSETS_JOURNAL_APPROVE', 'FIXED_ASSETS_JOURNAL_POST', 'FIXED_ASSETS_DEPRECIATION_RUN',
      'RECEIVABLES_READ', 'RECEIVABLES_CUSTOMER_MANAGE', 'RECEIVABLES_SETUP_MANAGE', 'RECEIVABLES_SALES_CREATE',
      'RECEIVABLES_SALES_APPROVE', 'RECEIVABLES_SALES_POST', 'RECEIVABLES_CASH_RECEIPT_CREATE',
      'RECEIVABLES_CASH_RECEIPT_POST', 'RECEIVABLES_REMINDER_MANAGE', 'RECEIVABLES_APPLY_ENTRIES',
      'PAYABLES_READ', 'PAYABLES_VENDOR_MANAGE', 'PAYABLES_SETUP_MANAGE', 'PAYABLES_PURCHASE_CREATE',
      'PAYABLES_PURCHASE_APPROVE', 'PAYABLES_PURCHASE_POST', 'PAYABLES_PAYMENT_CREATE',
      'PAYABLES_PAYMENT_POST', 'PAYABLES_APPLY_ENTRIES',
      'CASH_MGMT_READ', 'CASH_MGMT_BANK_MANAGE', 'CASH_MGMT_SETUP_MANAGE', 'CASH_MGMT_CURRENCY_MANAGE',
      'CASH_MGMT_RECONCILE', 'CASH_MGMT_FX_ADJUST', 'CASH_MGMT_RECEIPT_CREATE', 'CASH_MGMT_RECEIPT_APPROVE',
      'CASH_MGMT_RECEIPT_POST', 'CASH_MGMT_PV_CREATE', 'CASH_MGMT_PV_APPROVE', 'CASH_MGMT_PV_POST',
      'CASH_MGMT_APPLY_ENTRIES', 'WHT_CERTIFICATE_PRINT',
      'VAT_REPORT_READ', 'VAT_SETUP_MANAGE', 'WHT_MARK_REMITTED', 'CURRENCY_SETUP_MANAGE',
      'ADMIN_CHARGES_MASTER_MANAGE', 'ADMIN_CHARGES_TRANSACTION_MANAGE',
      'COLLATERAL_APPLICATIONS_READ', 'COLLATERAL_REGISTER_READ', 'COLLATERAL_RELEASES_READ', 'GUARANTOR_CHANGES_READ',
      'FIXED_DEPOSITS_READ',
      'FINANCIAL_REPORTS_READ', 'FINANCIAL_REPORTS_MANAGE',
      'DASHBOARD_VIEW', 'REPORTS_VIEW', 'APPROVALS_VIEW',
    ],
  },
  {
    name: 'Internal Auditor',
    description: 'Read-only across the system, including the audit trail.',
    actions: [
      'MEMBERS_READ', 'MEMBER_STATEMENTS_READ', 'MEMBER_APPLICATIONS_READ', 'MEMBER_EDITS_READ', 'ACCOUNT_OPENING_READ',
      'ACCOUNT_DEACTIVATION_READ', 'ACCOUNT_ACTIVATION_READ', 'MEMBER_ACTIVATIONS_READ', 'MEMBER_READMISSIONS_READ', 'STANDING_ORDERS_READ',
      'MEMBER_CHARGING_READ', 'SAVINGS_READ', 'MEMBER_EXITS_READ',
      'CASH_MANAGEMENT_READ', 'TELLER_TRANSACTIONS_READ', 'LIENS_READ', 'INTER_ACCOUNT_TRANSFERS_READ',
      'BANKERS_CHEQUES_READ', 'CHEQUE_DEPOSITS_READ',
      'TELLER_SETUP_READ', 'DENOMINATIONS_READ',
      'ENTRANCE_FEE_RECOVERY_READ', 'MEMBER_STATUS_UPDATE_READ',
      'CHECKOFF_BATCHES_READ',
      'LOAN_READ', 'GL_READ', 'COLLATERAL_APPLICATIONS_READ', 'COLLATERAL_REGISTER_READ', 'COLLATERAL_RELEASES_READ',
      'GUARANTOR_CHANGES_READ',
      'FIXED_DEPOSITS_READ', 'INVENTORY_READ', 'FIXED_ASSETS_READ', 'RECEIVABLES_READ', 'PAYABLES_READ',
      'CASH_MGMT_READ', 'VAT_REPORT_READ', 'FINANCIAL_REPORTS_READ',
      'DASHBOARD_VIEW', 'REPORTS_VIEW', 'APPROVALS_VIEW', 'ADMIN_AUDIT_VIEW',
    ],
  },

  /* ---------------------------------------------------------------------------------------------
   * Role-centre permission sets. Independent of the Profile catalogue — an admin pairs a matching
   * permission set with a Profile, but either can be used without the other. The migration
   * backfills the identical lines for an already-seeded DB (scripts/gen-role-center-perms.ts).
   * ------------------------------------------------------------------------------------------- */
  {
    name: 'Super Role Centre',
    description: 'Broad cross-society access — pairs with the Super role centre.',
    actions: [
      'MEMBERS_READ', 'MEMBERS_UPDATE', 'MEMBER_STATEMENTS_READ',
      'MEMBER_APPLICATIONS_READ', 'MEMBER_APPLICATIONS_CREATE', 'MEMBER_APPLICATIONS_UPDATE', 'MEMBER_APPLICATIONS_APPROVE',
      'MEMBER_EDITS_READ', 'MEMBER_EDITS_UPDATE', 'MEMBER_EDITS_APPROVE',
      'MEMBER_EXITS_READ', 'MEMBER_EXITS_CREATE', 'MEMBER_EXITS_APPROVE',
      'MEMBER_ACTIVATIONS_READ', 'MEMBER_ACTIVATIONS_CREATE', 'MEMBER_ACTIVATIONS_APPROVE',
      'MEMBER_READMISSIONS_READ', 'MEMBER_READMISSIONS_CREATE', 'MEMBER_READMISSIONS_APPROVE',
      'ACCOUNT_OPENING_READ', 'ACCOUNT_OPENING_CREATE', 'ACCOUNT_OPENING_APPROVE',
      'ACCOUNT_DEACTIVATION_READ', 'ACCOUNT_DEACTIVATION_CREATE', 'ACCOUNT_DEACTIVATION_APPROVE',
      'ACCOUNT_ACTIVATION_READ', 'ACCOUNT_ACTIVATION_CREATE', 'ACCOUNT_ACTIVATION_APPROVE',
      'MEMBER_CHARGING_READ', 'MEMBER_CHARGING_CREATE', 'MEMBER_CHARGING_POST',
      'STANDING_ORDERS_READ', 'STANDING_ORDERS_CREATE', 'STANDING_ORDERS_APPROVE', 'STANDING_ORDERS_RUN',
      'CHECKOFF_BATCHES_READ', 'CHECKOFF_BATCHES_CREATE', 'CHECKOFF_BATCHES_APPROVE',
      'FIXED_DEPOSITS_READ', 'FIXED_DEPOSITS_CREATE', 'FIXED_DEPOSITS_APPROVE',
      'CASH_MANAGEMENT_READ', 'CASH_MANAGEMENT_CREATE', 'CASH_MANAGEMENT_APPROVE', 'CASH_MANAGEMENT_POST',
      'TELLER_TRANSACTIONS_READ', 'TELLER_TRANSACTIONS_CREATE', 'TELLER_TRANSACTIONS_APPROVE', 'TELLER_TRANSACTIONS_POST',
      'LIENS_READ', 'LIENS_CREATE', 'LIENS_APPROVE', 'LIENS_POST',
      'INTER_ACCOUNT_TRANSFERS_READ', 'INTER_ACCOUNT_TRANSFERS_CREATE', 'INTER_ACCOUNT_TRANSFERS_APPROVE',
      'INTER_ACCOUNT_TRANSFERS_POST', 'INTER_ACCOUNT_TRANSFERS_CROSS_MEMBER',
      'BANKERS_CHEQUES_READ', 'BANKERS_CHEQUES_CREATE', 'BANKERS_CHEQUES_APPROVE', 'BANKERS_CHEQUES_POST',
      'CHEQUE_DEPOSITS_READ', 'CHEQUE_DEPOSITS_CREATE', 'CHEQUE_DEPOSITS_APPROVE', 'CHEQUE_DEPOSITS_CLEAR',
      'ENTRANCE_FEE_RECOVERY_READ', 'ENTRANCE_FEE_RECOVERY_RUN', 'MEMBER_STATUS_UPDATE_READ', 'MEMBER_STATUS_UPDATE_RUN',
      'SAVINGS_READ', 'SAVINGS_DEPOSIT', 'SAVINGS_WITHDRAW', 'SAVINGS_REVERSE',
      'LOAN_READ', 'LOAN_CREATE', 'LOAN_APPROVE', 'LOAN_DISBURSE', 'LOAN_REPAY',
      'LOAN_CALCULATOR_READ', 'LOAN_CALCULATOR_CREATE', 'LOAN_CALCULATOR_DELETE', 'LOAN_CALCULATOR_CONVERT',
      'COLLATERAL_APPLICATIONS_READ', 'COLLATERAL_APPLICATIONS_CREATE', 'COLLATERAL_APPLICATIONS_APPROVE',
      'COLLATERAL_REGISTER_READ', 'COLLATERAL_RELEASES_READ', 'COLLATERAL_RELEASES_CREATE', 'COLLATERAL_RELEASES_APPROVE',
      'GUARANTOR_CHANGES_READ', 'GUARANTOR_CHANGES_CREATE', 'GUARANTOR_CHANGES_APPROVE',
      'GL_READ', 'GL_JOURNAL_CREATE', 'GL_JOURNAL_APPROVE',
      'INVENTORY_READ', 'FIXED_ASSETS_READ', 'RECEIVABLES_READ', 'PAYABLES_READ', 'CASH_MGMT_READ',
      'VAT_REPORT_READ', 'FINANCIAL_REPORTS_READ',
      'DASHBOARD_VIEW', 'REPORTS_VIEW', 'APPROVALS_VIEW', 'ADMIN_AUDIT_VIEW', 'ADMIN_PROFILES_READ',
    ],
  },
  {
    name: 'CRM Officer',
    description: 'Membership, applications and member care — pairs with the CRM role centre.',
    actions: [
      'MEMBERS_READ', 'MEMBERS_UPDATE', 'MEMBER_STATEMENTS_READ',
      'MEMBER_APPLICATIONS_READ', 'MEMBER_APPLICATIONS_CREATE', 'MEMBER_APPLICATIONS_UPDATE', 'MEMBER_APPLICATIONS_APPROVE',
      'MEMBER_EDITS_READ', 'MEMBER_EDITS_UPDATE', 'MEMBER_EDITS_APPROVE',
      'MEMBER_EXITS_READ', 'MEMBER_EXITS_CREATE', 'MEMBER_EXITS_APPROVE',
      'MEMBER_ACTIVATIONS_READ', 'MEMBER_ACTIVATIONS_CREATE', 'MEMBER_ACTIVATIONS_APPROVE',
      'MEMBER_READMISSIONS_READ', 'MEMBER_READMISSIONS_CREATE', 'MEMBER_READMISSIONS_APPROVE',
      'ACCOUNT_OPENING_READ', 'ACCOUNT_OPENING_CREATE', 'ACCOUNT_OPENING_APPROVE',
      'ACCOUNT_DEACTIVATION_READ', 'ACCOUNT_DEACTIVATION_CREATE',
      'ACCOUNT_ACTIVATION_READ', 'ACCOUNT_ACTIVATION_CREATE',
      'MEMBER_CHARGING_READ', 'STANDING_ORDERS_READ', 'MEMBER_STATUS_UPDATE_READ', 'ENTRANCE_FEE_RECOVERY_READ',
      'SAVINGS_READ', 'LOAN_READ', 'FIXED_DEPOSITS_READ',
      'COLLATERAL_APPLICATIONS_READ', 'COLLATERAL_REGISTER_READ', 'COLLATERAL_RELEASES_READ', 'GUARANTOR_CHANGES_READ',
      'DASHBOARD_VIEW', 'REPORTS_VIEW', 'APPROVALS_VIEW',
    ],
  },
  {
    name: 'Credit Officer',
    description: 'Loans, collateral and guarantors — pairs with the Credit role centre.',
    actions: [
      'MEMBERS_READ', 'MEMBER_STATEMENTS_READ', 'SAVINGS_READ',
      'LOAN_READ', 'LOAN_CREATE', 'LOAN_APPROVE', 'LOAN_DISBURSE', 'LOAN_REPAY',
      'LOAN_CALCULATOR_READ', 'LOAN_CALCULATOR_CREATE', 'LOAN_CALCULATOR_DELETE', 'LOAN_CALCULATOR_CONVERT',
      'COLLATERAL_APPLICATIONS_READ', 'COLLATERAL_APPLICATIONS_CREATE', 'COLLATERAL_APPLICATIONS_APPROVE',
      'COLLATERAL_REGISTER_READ', 'COLLATERAL_RELEASES_READ', 'COLLATERAL_RELEASES_CREATE', 'COLLATERAL_RELEASES_APPROVE',
      'GUARANTOR_CHANGES_READ', 'GUARANTOR_CHANGES_CREATE', 'GUARANTOR_CHANGES_APPROVE',
      'CHECKOFF_BATCHES_READ', 'CHECKOFF_BATCHES_CREATE', 'CHECKOFF_BATCHES_APPROVE',
      'FIXED_DEPOSITS_READ', 'GL_READ',
      'DASHBOARD_VIEW', 'REPORTS_VIEW', 'APPROVALS_VIEW', 'FINANCIAL_REPORTS_READ',
    ],
  },
  {
    name: 'FOSA Officer',
    description: 'Teller and front-office operations — pairs with the FOSA role centre.',
    actions: [
      'MEMBERS_READ', 'MEMBER_STATEMENTS_READ',
      'SAVINGS_READ', 'SAVINGS_DEPOSIT', 'SAVINGS_WITHDRAW',
      'TELLER_TRANSACTIONS_READ', 'TELLER_TRANSACTIONS_CREATE', 'TELLER_TRANSACTIONS_POST',
      'CASH_MANAGEMENT_READ', 'CASH_MANAGEMENT_CREATE', 'CASH_MANAGEMENT_POST',
      'LIENS_READ', 'LIENS_CREATE', 'LIENS_POST',
      'INTER_ACCOUNT_TRANSFERS_READ', 'INTER_ACCOUNT_TRANSFERS_CREATE', 'INTER_ACCOUNT_TRANSFERS_POST', 'INTER_ACCOUNT_TRANSFERS_CROSS_MEMBER',
      'BANKERS_CHEQUES_READ', 'BANKERS_CHEQUES_CREATE', 'BANKERS_CHEQUES_POST',
      'CHEQUE_DEPOSITS_READ', 'CHEQUE_DEPOSITS_CREATE', 'CHEQUE_DEPOSITS_CLEAR',
      'STANDING_ORDERS_READ', 'STANDING_ORDERS_CREATE',
      'FIXED_DEPOSITS_READ', 'FIXED_DEPOSITS_CREATE',
      'MEMBER_CHARGING_READ', 'MEMBER_CHARGING_CREATE', 'MEMBER_CHARGING_POST',
      'ENTRANCE_FEE_RECOVERY_READ', 'ENTRANCE_FEE_RECOVERY_RUN', 'MEMBER_STATUS_UPDATE_READ', 'MEMBER_STATUS_UPDATE_RUN',
      'ACCOUNT_OPENING_READ', 'ACCOUNT_OPENING_CREATE', 'ACCOUNT_ACTIVATION_READ', 'ACCOUNT_ACTIVATION_CREATE',
      'DENOMINATIONS_READ', 'TELLER_SETUP_READ', 'LOAN_READ', 'LOAN_REPAY',
      'DASHBOARD_VIEW', 'REPORTS_VIEW', 'APPROVALS_VIEW',
    ],
  },
  {
    name: 'Finance Manager',
    description: 'Reporting, approvals and oversight — pairs with the Finance Manager role centre.',
    actions: [
      'MEMBERS_READ', 'MEMBER_STATEMENTS_READ', 'SAVINGS_READ', 'LOAN_READ', 'MEMBER_EXITS_READ', 'CHECKOFF_BATCHES_READ',
      'GL_READ', 'GL_JOURNAL_APPROVE', 'GL_PERIOD_CLOSE', 'GL_BANK_RECONCILE',
      'FINANCIAL_REPORTS_READ', 'FINANCIAL_REPORTS_MANAGE', 'REPORTS_VIEW', 'DASHBOARD_VIEW', 'APPROVALS_VIEW',
      'RECEIVABLES_READ', 'PAYABLES_READ', 'CASH_MGMT_READ', 'CASH_MGMT_RECONCILE',
      'INVENTORY_READ', 'FIXED_ASSETS_READ', 'VAT_REPORT_READ',
      'TELLER_TRANSACTIONS_READ', 'TELLER_TRANSACTIONS_APPROVE',
      'CASH_MANAGEMENT_READ', 'CASH_MANAGEMENT_APPROVE',
      'LIENS_READ', 'LIENS_APPROVE', 'INTER_ACCOUNT_TRANSFERS_READ', 'INTER_ACCOUNT_TRANSFERS_APPROVE',
      'BANKERS_CHEQUES_READ', 'BANKERS_CHEQUES_APPROVE', 'CHEQUE_DEPOSITS_READ', 'CHEQUE_DEPOSITS_APPROVE',
      'CASH_MGMT_RECEIPT_APPROVE', 'CASH_MGMT_PV_APPROVE', 'ADMIN_AUDIT_VIEW',
    ],
  },
  {
    name: 'Accountant',
    description: 'General ledger, journals, reconciliation and tax — pairs with the Accountant role centre.',
    actions: [
      'GL_READ', 'GL_JOURNAL_CREATE', 'GL_JOURNAL_APPROVE', 'GL_JOURNAL_REVERSE', 'GL_ACCOUNT_MANAGE',
      'GL_BANK_RECONCILE', 'GL_PERIOD_CLOSE',
      'FINANCIAL_REPORTS_READ', 'FINANCIAL_REPORTS_MANAGE', 'REPORTS_VIEW', 'DASHBOARD_VIEW', 'APPROVALS_VIEW',
      'RECEIVABLES_READ', 'RECEIVABLES_APPLY_ENTRIES', 'RECEIVABLES_CASH_RECEIPT_CREATE', 'RECEIVABLES_CASH_RECEIPT_POST',
      'PAYABLES_READ', 'PAYABLES_APPLY_ENTRIES', 'PAYABLES_PAYMENT_CREATE', 'PAYABLES_PAYMENT_POST',
      'CASH_MGMT_READ', 'CASH_MGMT_RECONCILE', 'CASH_MGMT_RECEIPT_CREATE', 'CASH_MGMT_RECEIPT_POST',
      'CASH_MGMT_PV_CREATE', 'CASH_MGMT_PV_POST', 'CASH_MGMT_APPLY_ENTRIES', 'CASH_MGMT_FX_ADJUST',
      'VAT_REPORT_READ', 'VAT_SETUP_MANAGE', 'WHT_CERTIFICATE_PRINT', 'WHT_MARK_REMITTED',
      'INVENTORY_READ', 'INVENTORY_JOURNAL_CREATE', 'INVENTORY_JOURNAL_POST',
      'FIXED_ASSETS_READ', 'FIXED_ASSETS_JOURNAL_CREATE', 'FIXED_ASSETS_JOURNAL_POST', 'FIXED_ASSETS_DEPRECIATION_RUN',
      'SAVINGS_READ', 'LOAN_READ', 'MEMBERS_READ',
    ],
  },
];

const FIRST_M = ['John', 'Peter', 'James', 'Samuel', 'Daniel', 'Joseph', 'David', 'Brian', 'Kevin', 'Dennis', 'Collins', 'Elias', 'Victor', 'Anthony'];
const FIRST_F = ['Mary', 'Grace', 'Faith', 'Esther', 'Ann', 'Caroline', 'Mercy', 'Joyce', 'Beatrice', 'Lydia', 'Purity', 'Naomi', 'Doreen', 'Susan'];
const LAST = ['Kamau', 'Otieno', 'Wanjiru', 'Kiprotich', 'Mutiso', 'Achieng', 'Njoroge', 'Chebet', 'Mwangi', 'Odhiambo', 'Wafula', 'Nyambura', 'Kiptoo', 'Muthoni', 'Barasa', 'Auma', 'Gitonga', 'Cheruiyot', 'Wekesa', 'Kariuki', 'Atieno', 'Maina', 'Rono', 'Simiyu'];
const EMPLOYERS = ['Ministry of Education', 'County Government of Nakuru', 'Kenya Power', 'Safaricom PLC', 'Nakuru Level 5 Hospital', 'Egerton University', 'Self Employed', 'Kenya Revenue Authority', 'Rift Valley Water Works'];
const COUNTIES = ['Nakuru', 'Nairobi', 'Kiambu', 'Uasin Gishu', 'Kisumu', 'Machakos', 'Bungoma', 'Kericho'];

async function seedReferenceData(now: IsoDateTime, todayIso: IsoDate): Promise<void> {
  const INS_SEQ = 'INSERT INTO sequence (name, prefix, next_no, width) VALUES (?,?,?,?)';
  await run(INS_SEQ, 'MEMBER', 'M', 1001, 5);
  await run(INS_SEQ, 'MEMBER_APPLICATION', 'APP', 1, 6);
  await run(INS_SEQ, 'SAVINGS_ACCOUNT', 'SA', 100001, 7);
  await run(INS_SEQ, 'LOAN', 'LN', 5001, 6);
  await run(INS_SEQ, 'JOURNAL', 'JV', 1, 8);
  await run(INS_SEQ, 'JOURNAL_DRAFT', 'JVD', 1, 6);
  await run(INS_SEQ, 'TXN', 'TX', 1, 9);
  await run(INS_SEQ, 'FOSA_TRANSACTION', 'FT', 1, 6);
  await run(INS_SEQ, 'TELLER_TRANSACTION', 'TT', 1, 6);
  await run(INS_SEQ, 'MEMBER_LIEN', 'LIEN', 1, 6);
  await run(INS_SEQ, 'INTER_ACCOUNT_TRANSFER', 'IAT', 1, 6);
  await run(INS_SEQ, 'BANKERS_CHEQUE', 'BCQ', 1, 6);
  await run(INS_SEQ, 'CHEQUE_DEPOSIT', 'CHQ', 1, 6);
  await run(INS_SEQ, 'ITEM', 'ITM', 1, 6);
  await run(INS_SEQ, 'ITEM_JOURNAL', 'IJL', 1, 6);
  await run(INS_SEQ, 'FIXED_ASSET', 'FA', 1, 6);
  await run(INS_SEQ, 'FA_JOURNAL', 'FAJ', 1, 6);
  await run(INS_SEQ, 'CUSTOMER', 'C', 1001, 5);
  await run(INS_SEQ, 'SALES_QUOTE', 'SQ', 1, 6);
  await run(INS_SEQ, 'SALES_ORDER', 'SO', 1, 6);
  await run(INS_SEQ, 'SALES_INVOICE', 'SI', 1, 6);
  await run(INS_SEQ, 'SALES_CREDIT_MEMO', 'SM', 1, 6);
  await run(INS_SEQ, 'POSTED_SALES_SHIPMENT', 'PSHP', 1, 6);
  await run(INS_SEQ, 'POSTED_SALES_INVOICE', 'PSI', 1, 6);
  await run(INS_SEQ, 'POSTED_SALES_CREDIT_MEMO', 'PSM', 1, 6);
  await run(INS_SEQ, 'CASH_RECEIPT', 'CR', 1, 6);
  await run(INS_SEQ, 'REMINDER', 'REM', 1, 6);
  await run(INS_SEQ, 'FIN_CHARGE_MEMO', 'FCM', 1, 6);
  await run(INS_SEQ, 'VENDOR', 'V', 1001, 5);
  await run(INS_SEQ, 'PURCHASE_QUOTE', 'PQ', 1, 6);
  await run(INS_SEQ, 'PURCHASE_ORDER', 'PO', 1, 6);
  await run(INS_SEQ, 'PURCHASE_INVOICE', 'PI', 1, 6);
  await run(INS_SEQ, 'PURCHASE_CREDIT_MEMO', 'PM', 1, 6);
  await run(INS_SEQ, 'POSTED_PURCHASE_RECEIPT', 'PRCP', 1, 6);
  await run(INS_SEQ, 'POSTED_PURCHASE_INVOICE', 'PPI', 1, 6);
  await run(INS_SEQ, 'POSTED_PURCHASE_CREDIT_MEMO', 'PPM', 1, 6);
  await run(INS_SEQ, 'PAYMENT_JOURNAL', 'PAY', 1, 6);
  await run(INS_SEQ, 'RECEIPT', 'RCT', 1, 6);
  await run(INS_SEQ, 'POSTED_RECEIPT', 'PRCT', 1, 6);
  await run(INS_SEQ, 'PAYMENT_VOUCHER', 'PV', 1, 6);
  await run(INS_SEQ, 'POSTED_PAYMENT_VOUCHER', 'PPV', 1, 6);
  await run(INS_SEQ, 'BANK_RECONCILIATION', 'BREC', 1, 6);
  await run(INS_SEQ, 'WHT_CERTIFICATE', 'WHT', 1, 6);

  // Business Central No. Series — mirror every flat counter into a managed series (code ==
  // document code) plus its Admin Centre → No. Series assignment row. From here on the services'
  // nextSequence() calls draw from these; the `sequence` rows above are the fall-back only.
  for (const doc of NO_SERIES_DOCUMENTS) {
    const seq = await one<{ prefix: string; next_no: number; width: number }>(
      'SELECT prefix, next_no, width FROM sequence WHERE name = ?', doc.code,
    );
    if (!seq) continue;
    const startNo = seq.prefix + String(seq.next_no).padStart(seq.width, '0');
    await run(
      'INSERT INTO no_series (code, description, default_nos, manual_nos, date_order) VALUES (?,?,1,0,0) ON CONFLICT (code) DO NOTHING',
      doc.code, doc.label,
    );
    const hasLine = await one<{ c: number }>(
      'SELECT COUNT(*) AS c FROM no_series_line WHERE series_code = ?', doc.code,
    );
    if (!Number(hasLine?.c ?? 0)) {
      await run(
        `INSERT INTO no_series_line (series_code, line_no, starting_date, starting_no, increment_by_no, open, allow_gaps)
         VALUES (?, 10000, NULL, ?, 1, 1, 0)`,
        doc.code, startNo,
      );
    }
    await run(
      `INSERT INTO no_series_setup (document_code, label, category, sort, series_code) VALUES (?,?,?,?,?)
       ON CONFLICT (document_code) DO NOTHING`,
      doc.code, doc.label, doc.category, NO_SERIES_DOCUMENTS.indexOf(doc), doc.code,
    );
  }

  await run(
    `INSERT INTO organisation (id, name, short_name, motto, registration_no, sasra_licence_no, kra_pin,
      society_type, physical_address, postal_address, city, county, country, phone_primary, phone_secondary,
      email, website, paybill_no, bank_name, bank_account_no, currency_code, currency_symbol, locale, timezone,
      date_format, fy_start_month, fy_start_day, statement_footer, updated_at, updated_by)
     VALUES (1,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)`,
    'Tier One SACCO Society Limited', 'Tier One SACCO',
    'Growing Together, Prospering Together',
    'CS/12345', 'DT/SACCO/0187', 'P051234567X', 'Deposit Taking SACCO',
    'Tier One Plaza, 3rd Floor, Kenyatta Avenue', 'P.O. Box 4471–20100', 'Nakuru', 'Nakuru', 'Kenya',
    '+254 700 000 100', '+254 20 200 0100', 'info@tieronesacco.co.ke', 'www.tieronesacco.co.ke',
    '400200', 'Co-operative Bank of Kenya', '01100123456789',
    'KES', 'KSh', 'en-KE', 'Africa/Nairobi', 'dd MMM yyyy', 1, 1,
    'This statement is issued without alteration or erasure. Please report any discrepancy within 30 days.',
    now, 'system',
  );

  await run(
    'INSERT INTO theme (id, preset, tokens, updated_at, updated_by) VALUES (1,?,?,?,?)',
    'emerald-standard', JSON.stringify(PRESETS['emerald-standard'].tokens), now, 'system',
  );

  const INS_ACC = 'INSERT INTO gl_account (code, name, type, parent_code, is_postable, account_type) VALUES (?,?,?,?,?,?)';
  for (const [code, name, type, parent, postable] of CHART) {
    await run(INS_ACC, code, name, type, parent, postable, postable ? 'POSTING' : 'HEADING');
  }
  const accId = async (code: string): Promise<number> =>
    (await one<{ id: number }>('SELECT id FROM gl_account WHERE code = ?', code))!.id;

  const INS_ROLE = 'INSERT INTO role (name, description, is_system) VALUES (?,?,?)';
  const INS_LINE = `INSERT INTO permission_set_line
    (role_id, object_type, object_name, read_perm, insert_perm, modify_perm, delete_perm, execute_perm)
    VALUES (?,?,?,?,?,?,?,?)`;
  for (const r of ROLES) {
    const isSystem = r.name === 'System Administrator';
    const info = await run(INS_ROLE, r.name, r.description, isSystem ? 1 : 0);
    const roleId = Number(info.lastInsertRowid);
    for (const line of expandActionsToLines(roleId, r.actions)) {
      await run(
        INS_LINE, line.role_id, line.object_type, line.object_name,
        line.read ? 1 : 0, line.insert ? 1 : 0, line.modify ? 1 : 0, line.delete ? 1 : 0, line.execute ? 1 : 0,
      );
    }
  }
  const roleId = async (n: string): Promise<number> =>
    (await one<{ id: number }>('SELECT id FROM role WHERE name = ?', n))!.id;

  const INS_USER =
    `INSERT INTO app_user (username, full_name, email, phone, password_hash, role_id, created_at)
     VALUES (?,?,?,?,?,?,?)`;
  const users: [string, string, string, string, string][] = [
    ['admin', 'Cosmas Rono', 'admin@tieronesacco.co.ke', 'System Administrator', 'admin123'],
    ['manager', 'Beatrice Njeri', 'manager@tieronesacco.co.ke', 'Branch Manager', 'manager123'],
    ['loans', 'Dennis Kiptoo', 'loans@tieronesacco.co.ke', 'Loans Officer', 'loans123'],
    ['teller', 'Purity Wanjiku', 'teller@tieronesacco.co.ke', 'Teller', 'teller123'],
    ['finance', 'Samuel Otieno', 'finance@tieronesacco.co.ke', 'Finance Officer', 'finance123'],
    ['auditor', 'Grace Achieng', 'auditor@tieronesacco.co.ke', 'Internal Auditor', 'auditor123'],
  ];
  for (const [un, fn, em, role, pw] of users) {
    await run(INS_USER, un, fn, em, '+254 7' + int(10000000, 99999999), hashPassword(pw), await roleId(role), now);
  }

  // A "Requester's approver" workflow step falls back to whoever is flagged an
  // Approval Administrator when the requester has no approver configured —
  // give a new install a working fallback out of the box. Also grants admin the new
  // Can Reverse Journal setup, since — like is_approval_administrator — it's an explicit
  // per-user grant that even the System Administrator role doesn't bypass.
  const adminId = await one<{ id: number }>('SELECT id FROM app_user WHERE username = ?', 'admin');
  if (adminId) {
    await run(
      'INSERT INTO approval_user_setup (user_id, is_approval_administrator, can_reverse_journal) VALUES (?,1,1)',
      adminId.id,
    );
  }

  // Finance Officer is the seeded role that actually carries GL_JOURNAL_REVERSE — grant the
  // demo "finance" login the per-user setup too, so it can reverse a journal out of the box.
  const financeId = await one<{ id: number }>('SELECT id FROM app_user WHERE username = ?', 'finance');
  if (financeId) {
    await run('INSERT INTO approval_user_setup (user_id, can_reverse_journal) VALUES (?,1)', financeId.id);
  }

  // Role Centre Profiles (Business Central "Profile") — a landing-page selector, independent of
  // permissions. The 20260910000000_add_role_centers migration seeds the identical rows for a
  // database that was already migrated before this feature landed.
  const INS_PROFILE = `INSERT INTO profile (code, name, description, role_centre, icon, sort, is_default, is_system, created_at, created_by)
    VALUES (?,?,?,?,?,?,?,1,?,'system')`;
  const PROFILES: [string, string, string, string, number, 0 | 1][] = [
    ['SUPER', 'Super Role Centre', 'Full cross-society overview — the original dashboard.', '▤', 10, 1],
    ['CRM', 'Client Relationship Management', 'Membership growth, the application pipeline and member care.', '👥', 20, 0],
    ['CREDIT', 'Credit Role Centre', 'Loan portfolio, disbursements, arrears and sectorial lending.', '💳', 30, 0],
    ['FOSA', 'FOSA Role Centre', 'Teller cash, deposits and withdrawals, cheques and standing orders.', '💵', 40, 0],
    ['FINANCE_MANAGER', 'Finance Manager Role Centre', 'Profitability, the balance sheet, capital adequacy and approvals.', '📈', 50, 0],
    ['ACCOUNTANT', 'Accountant Role Centre', 'Journals, the trial balance, reconciliations and tax.', '📒', 60, 0],
  ];
  for (const [code, name, description, icon, sort, isDefault] of PROFILES) {
    await run(INS_PROFILE, code, name, description, code, icon, sort, isDefault, now);
  }
  const profileId = async (code: string): Promise<number> =>
    (await one<{ id: number }>('SELECT id FROM profile WHERE code = ?', code))!.id;

  // Assign the demo logins a sensible spread of profiles + an active one, so every Role Centre is
  // reachable on first run.
  const assign: Record<string, string[]> = {
    admin: ['SUPER', 'CRM', 'CREDIT', 'FOSA', 'FINANCE_MANAGER', 'ACCOUNTANT'],
    manager: ['SUPER', 'CRM', 'CREDIT', 'FOSA'],
    loans: ['CREDIT', 'CRM'],
    teller: ['FOSA', 'CRM'],
    finance: ['FINANCE_MANAGER', 'ACCOUNTANT', 'SUPER'],
    auditor: ['SUPER', 'FINANCE_MANAGER', 'ACCOUNTANT'],
  };
  for (const [un, codes] of Object.entries(assign)) {
    const uid = (await one<{ id: number }>('SELECT id FROM app_user WHERE username = ?', un))?.id;
    if (!uid) continue;
    for (const code of codes) {
      await run('INSERT INTO user_profile (user_id, profile_id) VALUES (?,?)', uid, await profileId(code));
    }
    await run('UPDATE app_user SET active_profile_id = ? WHERE id = ?', await profileId(codes[0]), uid);
  }

  // accounting periods (25 months back through 2 ahead, all open)
  const INS_PERIOD = 'INSERT INTO accounting_period (code, start_date, end_date, status) VALUES (?,?,?,?)';
  for (let i = 25; i >= -2; i--) {
    const start = addMonths(todayIso.slice(0, 8) + '01', -i);
    const end = addMonths(start, 1);
    const endDate = new Date(new Date(end + 'T00:00:00Z').getTime() - 86400000).toISOString().slice(0, 10);
    await run(INS_PERIOD, start.slice(0, 7), start, endDate, 'OPEN');
  }

  // The control accounts every product points at, resolved once.
  const [a2010, a2020, a2030, a2040, a3010, a4010, a4030, a4040, a5010,
    a1110, a1120, a1130, a1140] = await Promise.all([
    accId('2010'), accId('2020'), accId('2030'), accId('2040'), accId('3010'),
    accId('4010'), accId('4030'), accId('4040'), accId('5010'),
    accId('1110'), accId('1120'), accId('1130'), accId('1140'),
  ]);

  // Bank Account subledger masters, one per CHANNEL_GL entry (lib/savings.ts) — so every
  // channel a teller already posts through has a matching reconcilable bank account from day
  // one, and each of these control accounts is flagged no_direct_posting so a manual G/L
  // journal can no longer touch it (see lib/gl.ts's createJournal/postManualJournal).
  const [a1010, a1020, a1030, a1040, a1015, a1016, a1017] = await Promise.all([
    accId('1010'), accId('1020'), accId('1030'), accId('1040'),
    accId('1015'), accId('1016'), accId('1017'),
  ]);
  const INS_BANK_ACCOUNT =
    'INSERT INTO bank_account (code, name, gl_account_id, bank_name, account_no, account_type, created_at) VALUES (?,?,?,?,?,?,?)';
  await run(INS_BANK_ACCOUNT, 'CASH', 'Cash in Hand — Tellers', a1010, null, null, 'OTHER', now);
  await run(INS_BANK_ACCOUNT, 'BANK', 'Bank Current Account', a1020, 'Co-operative Bank of Kenya', '01100123456789', 'MAIN', now);
  await run(INS_BANK_ACCOUNT, 'MPESA', 'M-Pesa Settlement Account', a1030, 'Safaricom M-Pesa', '400200', 'OTHER', now);
  await run(INS_BANK_ACCOUNT, 'CHECKOFF', 'Check-off Receivable Clearing', a1040, null, null, 'OTHER', now);
  // FOSA tellering — the branch Treasury vault and two tills (AL "Teller Setup" targets).
  await run(INS_BANK_ACCOUNT, 'TREASURY', 'Main Vault — Treasury', a1015, null, null, 'TREASURY', now);
  await run(INS_BANK_ACCOUNT, 'TILL-01', 'Till 01', a1016, null, null, 'TILL', now);
  await run(INS_BANK_ACCOUNT, 'TILL-02', 'Till 02', a1017, null, null, 'TILL', now);

  const noDirectPosting = [
    a1010, a1020, a1030, a1040, a1015, a1016, a1017, // bank / cash accounts
    a3010, a2010, a2020, a2030, a2040, // savings control accounts
    a1110, a1120, a1130, a1140, // loan receivable accounts
  ];
  await run(
    `UPDATE gl_account SET no_direct_posting = 1 WHERE id IN (${noDirectPosting.map(() => '?').join(',')})`,
    ...noDirectPosting,
  );

  // FOSA cash denomination master (Kenyan notes & coins; value in cents).
  const INS_DENOM = 'INSERT INTO denomination (code, description, value, active, sort_order) VALUES (?,?,?,true,?)';
  const DENOMS: [string, string, number][] = [
    ['N1000', 'KSh 1,000 note', K(1000)], ['N500', 'KSh 500 note', K(500)], ['N200', 'KSh 200 note', K(200)],
    ['N100', 'KSh 100 note', K(100)], ['N50', 'KSh 50 note', K(50)], ['C40', 'KSh 40 coin', K(40)],
    ['C20', 'KSh 20 coin', K(20)], ['C10', 'KSh 10 coin', K(10)], ['C5', 'KSh 5 coin', K(5)], ['C1', 'KSh 1 coin', K(1)],
  ];
  for (const [code, desc, value] of DENOMS) await run(INS_DENOM, code, desc, value, DENOMS.findIndex((d) => d[0] === code) + 1);

  // Teller Setup (AL Tab52204042) — the demo teller operates Till 01; finance & manager run the vault.
  const bankId = async (code: string): Promise<number> =>
    (await one<{ id: number }>('SELECT id FROM bank_account WHERE code = ?', code))!.id;
  const [tillOne, vault] = await Promise.all([bankId('TILL-01'), bankId('TREASURY')]);
  const INS_TS =
    `INSERT INTO teller_setup (user_username, setup_type, bank_account_id, max_capacity, min_capacity, approval_limit, created_at, created_by)
     VALUES (?,?,?,?,?,?,?,?)`;
  await run(INS_TS, 'teller', 'TELLER', tillOne, K(5000000), 0, K(200000), now, 'system');
  await run(INS_TS, 'finance', 'TREASURY', vault, K(50000000), K(1000000), 0, now, 'system');
  await run(INS_TS, 'manager', 'TREASURY', vault, K(50000000), K(1000000), 0, now, 'system');

  const INS_SP =
    `INSERT INTO savings_product (code, name, category, min_balance, min_opening, interest_rate,
      allow_withdrawal, allow_transfer, withdrawal_fee, is_loanable_base, withdrawal_notice_days,
      gl_control_id, gl_interest_exp_id, gl_fee_income_id)
     VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?)`;
  await run(INS_SP, 'SHR', 'Member Share Capital', 'SHARE CAPITAL ACCOUNT', 0, K(5000), 0, 0, 0, 0, 0, 0, a3010, a5010, a4040);
  await run(INS_SP, 'BOSA', 'BOSA Member Deposits', 'NON WITHDRAWABLE DEPOSIT', 0, K(1000), 8, 0, 0, 0, 0, 1, 60, a2010, a5010, a4040);
  await run(INS_SP, 'FOSA', 'FOSA Savings Account', 'WITHDRAWABLE DEPOSIT', K(500), K(500), 2, 1, 1, K(50), 0, 0, a2020, a5010, a4040);
  await run(INS_SP, 'FIXED', 'Fixed Deposit Account', 'FIXED DEPOSIT ACCOUNT', 0, K(20000), 9.5, 0, 0, 0, 0, 90, a2030, a5010, a4040);
  await run(INS_SP, 'HOL', 'Holiday & Education Savings', 'HOLIDAY ACCOUNT', 0, K(500), 4, 1, 1, K(30), 0, 0, a2040, a5010, a4040);

  // Cheque Types (AL "Cheque Types"): a BANKERS type sold by the SACCO (cleared against the
  // Bankers Cheques Payable liability) and an EXTERNAL type members bank (cleared through
  // Cheques in Clearing). No charges configured out of the box.
  const INS_CT =
    `INSERT INTO cheque_type (code, type, description, maximum_amount, clearing_gl_account_id, clearing_charge_id,
       bouncing_charge_id, express_charge_id, in_house, maturity_days, status, created_at, created_by)
     VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?)`;
  await run(INS_CT, 'STD', 'BANKERS', 'Standard Banker’s Cheque', K(1000000), await accId('2140'), null, null, null, false, 0, 'ACTIVE', now, 'system');
  await run(INS_CT, 'EXT', 'EXTERNAL', 'Local Bank Cheque', 0, await accId('1050'), null, null, null, false, 3, 'ACTIVE', now, 'system');

  const INS_LP =
    `INSERT INTO loan_product (code, name, interest_rate, interest_method, max_term_months, min_amount,
      max_amount, deposit_multiplier, min_membership_months, penalty_rate,
      guarantors_required, max_dsr_pct, salary_based, gl_receivable_id, gl_interest_income_id, gl_penalty_income_id)
     VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)`;
  // salary_based = 0: none of these members have real processed payroll (Checkoff & Salary
  // Processing) behind them, so affordability is assessed via the manual Salary Appraisal card
  // instead — see lib/loanService.ts's appraise().
  await run(INS_LP, 'NORM', 'Normal Loan', 12, 'REDUCING', 48, K(10000), K(4000000), 3, 6, 1, 2, 66.7, 0,
    a1110, a4010, a4030);
  await run(INS_LP, 'EMER', 'Emergency Loan', 12, 'REDUCING', 12, K(5000), K(300000), 1, 3, 1, 1, 66.7, 0,
    a1120, a4010, a4030);
  await run(INS_LP, 'SCHL', 'School Fees Loan', 12, 'REDUCING', 12, K(5000), K(500000), 2, 6, 1, 2, 66.7, 0,
    a1130, a4010, a4030);
  await run(INS_LP, 'DEV', 'Development Loan', 14, 'REDUCING', 60, K(50000), K(6000000), 3, 12, 1, 3, 66.7, 0,
    a1140, a4010, a4030);

  // Salary Appraisal Parameters (Table 52204034 "Loanees Payroll Codes") — the predefined
  // payslip line items the Normal Loan (salary_based above) auto-adds to its loan card.
  const INS_SAP = 'INSERT INTO salary_appraisal_parameter (code, name, type, special_type, sort_order) VALUES (?,?,?,?,?)';
  await run(INS_SAP, 'BASIC', 'Basic Salary', 'EARNING', 'BASIC_SALARY', 1);
  await run(INS_SAP, 'HOUSE', 'House Allowance', 'EARNING', 'NONE', 2);
  await run(INS_SAP, 'OTHALLOW', 'Other Allowances', 'EARNING', 'NONE', 3);
  await run(INS_SAP, 'PAYE', 'PAYE (Income Tax)', 'DEDUCTION', 'NONE', 4);
  await run(INS_SAP, 'NHIF', 'NHIF / SHIF', 'DEDUCTION', 'NONE', 5);
  await run(INS_SAP, 'NSSF', 'NSSF', 'DEDUCTION', 'NONE', 6);

  // System Automation (Job Queue) — a ready-to-use template for Entrance Fee Recovery, seeded
  // On Hold: the admin decides when it's safe to switch it to Ready, the same "off until someone
  // deliberately turns it on" default lib/jobQueue.ts's createJobQueueEntry() itself applies.
  await run(
    `INSERT INTO job_queue_entry (code, description, job_type, run_every_minutes, status, created_at, created_by)
     VALUES (?,?,?,?,'ON HOLD',?,?)`,
    'ENTRANCE-FEE-RECOVERY', 'Recovers outstanding registration fees from Not Paid Up members and activates them once fully paid',
    'ENTRANCE_FEE_RECOVERY', 60, now, 'system',
  );
  await run(
    `INSERT INTO job_queue_entry (code, description, job_type, run_every_minutes, status, created_at, created_by)
     VALUES (?,?,?,?,'ON HOLD',?,?)`,
    'MEMBER-STATUS-UPDATE', 'Marks a member Dormant with no money in their Non-Withdrawable Deposit account long enough, and reactivates a Dormant member once it has money again',
    'MEMBER_STATUS_UPDATE', 1440, now, 'system',
  );
  await run(
    `INSERT INTO job_queue_entry (code, description, job_type, run_every_minutes, status, created_at, created_by)
     VALUES (?,?,?,?,'ON HOLD',?,?)`,
    'STANDING-ORDER-RUN', 'Runs every live standing order that is due — transfers, sweeps and loan repayments',
    'STANDING_ORDER_RUN', 1440, now, 'system',
  );
}

async function seedMembersAndHistory(
  now: IsoDateTime,
  todayIso: IsoDate,
): Promise<{ members: number; loans: number }> {
  const sys: Actor = { id: 1, username: 'system' };

  // Opening capital position: institutional capital brought forward.
  await postJournal({
    valueDate: addMonths(todayIso, -24), module: 'GL', eventType: 'OPENING_BALANCE', user: sys,
    description: 'Opening institutional capital brought forward',
    lines: [
      { account: '1020', debit: K(24000000), credit: 0, narration: 'Bank current account' },
      { account: '1300', debit: K(6000000), credit: 0, narration: 'Property and equipment' },
      { account: '3020', debit: 0, credit: K(12000000), narration: 'Statutory reserve fund' },
      { account: '3030', debit: 0, credit: K(18000000), narration: 'Retained earnings brought forward' },
    ],
  });

  const productId = async (code: string): Promise<number> =>
    (await one<{ id: number }>('SELECT id FROM savings_product WHERE code=?', code))!.id;
  const loanProductId = async (code: string): Promise<number> =>
    (await one<{ id: number }>('SELECT id FROM loan_product WHERE code=?', code))!.id;
  const [shareP, bosaP, fosaP, holP, normLP, emerLP, devLP] = await Promise.all([
    productId('SHR'), productId('BOSA'), productId('FOSA'), productId('HOL'),
    loanProductId('NORM'), loanProductId('EMER'), loanProductId('DEV'),
  ]);

  const countyByName = Object.fromEntries(
    (await all<{ id: number; name: string }>('SELECT id, name FROM county')).map((c) => [c.name, c.id]),
  );

  const INS_MEMBER =
    `INSERT INTO member (member_no, member_type, title, first_name, middle_name, last_name, identification_no, kra_pin,
      date_of_birth, gender, marital_status, phone, email, postal_address, physical_address, county_id, employer,
      employment_status, staff_no,
      status, kyc_verified, join_date, created_at, created_by)
     VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)`;
  const INS_NOK =
    'INSERT INTO member_next_of_kin (member_id, name, relationship, phone) VALUES (?,?,?,?)';

  const memberIds: { id: number; joinDate: IsoDate }[] = [];
  for (let i = 0; i < 120; i++) {
    const female = rnd() < 0.48;
    const fn = female ? pick(FIRST_F) : pick(FIRST_M);
    const mn = female ? pick(FIRST_F) : pick(FIRST_M);
    const ln = pick(LAST);
    const joinDate = addMonths(todayIso, -int(7, 24));
    const info = await run(
      INS_MEMBER,
      await nextSequence('MEMBER'), 'INDIVIDUAL', female ? 'Ms.' : 'Mr.', fn, mn, ln,
      String(int(20000000, 39999999)), 'A0' + int(10000000, 99999999) + 'Z',
      addMonths(todayIso, -int(22, 55) * 12), female ? 'FEMALE' : 'MALE',
      pick(['SINGLE', 'MARRIED', 'MARRIED', 'WIDOWED']),
      '+2547' + int(10000000, 99999999), `${fn.toLowerCase()}.${ln.toLowerCase()}@example.co.ke`,
      'P.O. Box ' + int(100, 9999) + '–20100', pick(COUNTIES) + ' Town', countyByName[pick(COUNTIES)], pick(EMPLOYERS),
      pick(['PERMANENT', 'PERMANENT', 'CONTRACT', 'SELF_EMPLOYED']), 'EMP' + int(1000, 9999),
      i < 112 ? 'ACTIVE' : pick(['DORMANT', 'WITHDRAWN', 'INACTIVE']), i < 115 ? 1 : 0,
      joinDate, now, 'system',
    );
    const memberId = Number(info.lastInsertRowid);
    await run(
      INS_NOK, memberId, pick(FIRST_F) + ' ' + ln,
      pick(['Spouse', 'Parent', 'Sibling', 'Child']), '+2547' + int(10000000, 99999999),
    );
    memberIds.push({ id: memberId, joinDate });
  }

  // Share capital + deposits + FOSA activity
  for (const m of memberIds) {
    const mem = (await one<Pick<Member, 'status'>>('SELECT status FROM member WHERE id = ?', m.id))!;
    if (mem.status === 'WITHDRAWN') continue;

    await savings.openAccount({ memberId: m.id, productId: shareP, openingBalance: K(int(5, 20) * 1000), channel: 'BANK', user: sys });
    const bosa = await savings.openAccount({ memberId: m.id, productId: bosaP, openingBalance: K(int(25, 70) * 1000), channel: 'CHECKOFF', user: sys });
    const fosa = await savings.openAccount({ memberId: m.id, productId: fosaP, openingBalance: K(int(5, 60) * 1000), channel: 'TELLER', user: sys });
    if (rnd() < 0.35) await savings.openAccount({ memberId: m.id, productId: holP, openingBalance: K(int(1, 8) * 1000), channel: 'MPESA', user: sys });

    const months = int(6, 12);
    for (let k = months; k >= 1; k--) {
      const vd = addMonths(todayIso, -k);
      await savings.deposit({
        accountId: bosa.id, amount: K(int(6, 18) * 1000), channel: 'CHECKOFF', valueDate: vd,
        description: 'Monthly check-off contribution', user: sys,
      });
      if (rnd() < 0.7) {
        await savings.deposit({
          accountId: fosa.id, amount: K(int(8, 45) * 1000),
          channel: pick<Channel>(['MPESA', 'TELLER', 'BANK']),
          valueDate: vd, description: 'Salary / cash deposit', user: sys,
        });
      }
      if (rnd() < 0.5) {
        const acct = (await savings.getAccount(fosa.id))!;
        const avail = acct.balance - acct.min_balance - acct.withdrawal_fee;
        if (avail > K(2000)) {
          await savings.withdraw({
            accountId: fosa.id,
            amount: K(Math.max(1, Math.floor((avail / 100) * (0.1 + rnd() * 0.4) / 1000)) * 1000),
            channel: pick<Channel>(['TELLER', 'MPESA']), valueDate: vd,
            description: 'Counter withdrawal', user: sys,
          });
        }
      }
    }
  }

  // Loans
  const officer: Actor = { id: 3, username: 'loans' };
  const approver: Actor = { id: 2, username: 'manager' };
  let created = 0;
  for (const m of memberIds) {
    if (rnd() > 0.88) continue;
    const mem = (await one<Pick<Member, 'status'>>('SELECT status FROM member WHERE id = ?', m.id))!;
    if (mem.status !== 'ACTIVE') continue;
    const deposits = await loanSvc.loanableDeposits(m.id);
    if (deposits < K(40000)) continue;

    const prodId = pick([normLP, normLP, emerLP, devLP]);
    const prod = (await one<LoanProduct>('SELECT * FROM loan_product WHERE id = ?', prodId))!;
    const ceiling = Math.min(deposits * prod.deposit_multiplier, prod.max_amount);
    const principal = Math.round(Math.max(prod.min_amount, ceiling * (0.4 + rnd() * 0.5)) / K(1000)) * K(1000);
    if (principal < prod.min_amount) continue;
    const term = Math.min(prod.max_term_months, pick([12, 18, 24, 36]));
    const fosa = await one<{ id: number }>(
      "SELECT sa.id FROM savings_account sa JOIN savings_product p ON p.id=sa.product_id WHERE sa.member_id=? AND p.code='FOSA'",
      m.id,
    );

    let loanId: number;
    try {
      loanId = (await loanSvc.apply({
        memberId: m.id, productId: prodId, principal, termMonths: term,
        purpose: pick(['Business expansion', 'School fees', 'Land purchase', 'Home improvement', 'Medical', 'Farm inputs']),
        disburseToAccountId: fosa ? fosa.id : null, user: officer,
      })).id;
    } catch { continue; }

    const roll = rnd();
    if (roll < 0.18) continue;                       // leave pending for the approvals queue
    if (roll < 0.24) {
      await loanSvc.approve({ loanId, user: approver, approve: false, reason: 'Insufficient guarantor cover' });
      continue;
    }
    await loanSvc.approve({ loanId, user: approver, approve: true, reason: 'Meets product criteria' });
    if (roll < 0.34) continue;                       // approved, awaiting disbursement

    const monthsAgo = int(2, 10);
    const disbDate = addMonths(todayIso, -monthsAgo);
    try { await loanSvc.disburse({ loanId, valueDate: disbDate, channel: 'BANK', user: approver }); } catch { continue; }
    created++;

    // repayments — most members pay, some fall into arrears
    const payAll = rnd() < 0.75;
    const live = (await loanSvc.getLoan(loanId))!;
    for (let k = 1; k <= monthsAgo; k++) {
      if (!payAll && k > Math.max(1, Math.floor(monthsAgo * 0.5))) break;
      const vd = addMonths(disbDate, k);
      if (vd > todayIso) break;
      const current = (await loanSvc.getLoan(loanId))!;
      if (current.status !== 'DISBURSED') break;
      const owed = current.principal_balance + current.interest_balance + current.penalty_balance;
      const amt = Math.min(live.installment || current.installment, owed);
      if (amt <= 0) break;
      try {
        await loanSvc.repay({
          loanId, amount: amt, channel: 'CHECKOFF', valueDate: vd,
          description: 'Check-off repayment', user: officer,
        });
      } catch { break; }
    }
  }

  // Operating expenses so the income statement is not empty
  for (let k = 11; k >= 0; k--) {
    const vd = addMonths(todayIso, -k);
    const payroll = K(int(40, 50) * 1000);
    await postJournal({
      valueDate: vd, module: 'GL', eventType: 'EXPENSE', description: 'Monthly staff payroll', user: sys,
      lines: [{ account: '5020', debit: payroll, credit: 0 }, { account: '1020', debit: 0, credit: payroll }],
    });
    const adminCost = K(int(12, 18) * 1000);
    await postJournal({
      valueDate: vd, module: 'GL', eventType: 'EXPENSE', description: 'Administrative expenses', user: sys,
      lines: [{ account: '5030', debit: adminCost, credit: 0 }, { account: '1020', debit: 0, credit: adminCost }],
    });
  }

  await loanSvc.runArrearsAging();
  return { members: memberIds.length, loans: created };
}

export interface SeedResult {
  seeded: boolean;
  members?: number;
  loans?: number;
}

export async function seedIfEmpty(): Promise<SeedResult> {
  if ((await one<{ c: number }>('SELECT COUNT(*) c FROM organisation'))!.c > 0) return { seeded: false };

  const now = new Date().toISOString();
  const todayIso = now.slice(0, 10);

  /*
   * One outer transaction for the whole seed. Every service call nests into a
   * SAVEPOINT rather than committing on its own, which turns tens of thousands
   * of WAL commits into one and cuts a cold start from minutes to seconds.
   */
  const counts = await tx(async () => {
    await seedReferenceData(now, todayIso);
    const result = await seedMembersAndHistory(now, todayIso);
    await seedFixedAssets(now, todayIso);
    await seedReceivables(now, todayIso);
    await seedPayables(now, todayIso);
    await seedCashAndTax(now, todayIso);
    await seedFinancialReports(now, todayIso);
    return result;
  });

  return { seeded: true, ...counts };
}

/**
 * A small Fixed Assets demo — one depreciation book, FA classes / a location / posting groups
 * pointing at the new 1400-range G/L accounts, plus three assets (one in the Motor Vehicles
 * class) with their acquisition posted and ~a year of depreciation run, so every FA screen is
 * on first run. Mirrors how the migration backfills the same masters for an already-seeded DB.
 */
async function seedFixedAssets(now: IsoDateTime, todayIso: IsoDate): Promise<void> {
  const sys: Actor = { id: 1, username: 'system' };
  const acctId = async (code: string): Promise<number> =>
    (await one<{ id: number }>('SELECT id FROM gl_account WHERE code = ?', code))!.id;

  await run(
    `INSERT INTO depreciation_book (code, description, g_l_integration, default_final_rounding_amount, created_at, created_by)
     VALUES ('COMPANY', 'Company Book', 1, 100, ?, 'system')`,
    now,
  );
  const INS_FA_CLASS = 'INSERT INTO fa_class (code, description, created_at, created_by) VALUES (?,?,?,?)';
  for (const [code, desc] of [['EQUIPMENT', 'Equipment'], ['VEHICLES', 'Motor Vehicles'], ['BUILDINGS', 'Land and Buildings']]) {
    await run(INS_FA_CLASS, code, desc, now, 'system');
  }
  const INS_FA_SUBCLASS = 'INSERT INTO fa_subclass (code, description, fa_class_code, created_at, created_by) VALUES (?,?,?,?,?)';
  for (const [code, desc, cls] of [
    ['OFFICE-EQUIP', 'Office Equipment', 'EQUIPMENT'],
    ['COMPUTERS', 'Computers and IT Equipment', 'EQUIPMENT'],
    ['SALOON', 'Saloon Vehicles', 'VEHICLES'],
  ]) {
    await run(INS_FA_SUBCLASS, code, desc, cls, now, 'system');
  }
  await run('INSERT INTO fa_location (code, description, created_at, created_by) VALUES (?,?,?,?)', 'HQ', 'Head Office', now, 'system');
  for (const [code, desc] of [['SERVICE', 'Routine Service'], ['REPAIR', 'Repair'], ['INSPECTION', 'Inspection']]) {
    await run('INSERT INTO maintenance (code, description, created_at, created_by) VALUES (?,?,?,?)', code, desc, now, 'system');
  }

  const [a1420, a1425, a1430, a1435, a5060, a5070, a4060, a5080] = await Promise.all([
    acctId('1420'), acctId('1425'), acctId('1430'), acctId('1435'),
    acctId('5060'), acctId('5070'), acctId('4060'), acctId('5080'),
  ]);
  const INS_FAPG = `INSERT INTO fa_posting_group
    (code, description, acquisition_cost_account_id, accum_depreciation_account_id, depreciation_expense_account_id,
     write_down_expense_account_id, appreciation_account_id, maintenance_expense_account_id,
     gains_acc_on_disposal_id, losses_acc_on_disposal_id, created_at, created_by)
    VALUES (?,?,?,?,?,?,?,?,?,?,?,'system')`;
  await run(INS_FAPG, 'EQUIPMENT', 'Furniture, Fittings & Equipment', a1420, a1425, a5060, a5060, a1420, a5070, a4060, a5080, now);
  await run(INS_FAPG, 'VEHICLES', 'Motor Vehicles', a1430, a1435, a5060, a5060, a1430, a5070, a4060, a5080, now);

  await run(
    `INSERT INTO fa_setup (id, default_depreciation_book_code, default_fa_posting_group_code, updated_at, updated_by)
     VALUES (1, 'COMPANY', 'EQUIPMENT', ?, 'system')`,
    now,
  );

  const bankId = await acctId('1020');
  const startDate = addMonths(todayIso, -14).slice(0, 10);
  // Last day of the previous month — the depreciation batch's FA posting date.
  const firstOfThisMonth = `${todayIso.slice(0, 8)}01`;
  const lastMonthEnd = new Date(new Date(`${firstOfThisMonth}T00:00:00Z`).getTime() - 86400000).toISOString().slice(0, 10);

  const demo: {
    input: Parameters<typeof faLib.createFixedAsset>[0]; group: string; life: number; cost: number; salvage: number;
  }[] = [
    {
      input: {
        description: 'HP ProLiant Server', faClassCode: 'EQUIPMENT',
        faSubclassCode: 'COMPUTERS', faLocationCode: 'HQ', responsibleEmployee: 'Samuel Otieno',
        serialNo: 'SGH1234ABC', vendorName: 'Copy Cat Ltd', assetTag: 'IT-0001', blocked: false, inactive: false,
      },
      group: 'EQUIPMENT', life: 4, cost: K(850000), salvage: K(50000),
    },
    {
      input: {
        description: 'Boardroom Furniture Set', faClassCode: 'EQUIPMENT',
        faSubclassCode: 'OFFICE-EQUIP', faLocationCode: 'HQ', responsibleEmployee: 'Beatrice Njeri',
        vendorName: 'Victoria Furnitures', assetTag: 'FF-0007', blocked: false, inactive: false,
      },
      group: 'EQUIPMENT', life: 8, cost: K(420000), salvage: 0,
    },
    {
      input: {
        description: 'Toyota Hilux Double Cab', faClassCode: 'VEHICLES',
        faSubclassCode: 'SALOON', faLocationCode: 'HQ', responsibleEmployee: 'Purity Wanjiku',
        vendorName: 'Toyota Kenya', assetTag: 'MV-0003', serialNo: 'AHTFR22G000112233', blocked: false, inactive: false,
      },
      group: 'VEHICLES', life: 5, cost: K(4200000), salvage: K(600000),
    },
  ];

  for (const d of demo) {
    const { no } = await faLib.createFixedAsset(d.input, sys);
    const asset = (await one<{ id: number }>('SELECT id FROM fixed_asset WHERE no = ?', no))!;
    await faLib.setFaDepreciationBook(asset.id, {
      depreciationBookCode: 'COMPANY', faPostingGroupCode: d.group, depreciationMethod: 'Straight-Line',
      depreciationStartingDate: startDate, depreciationEndingDate: null, noOfDepreciationYears: d.life,
      straightLinePct: 0, decliningBalancePct: 0, salvageValue: d.salvage, disposalCalculationMethod: 'Net',
    }, sys);

    // Post the acquisition directly as an Approved line (the maker-checker flow needs an admin
    // workflow that a fresh install doesn't have yet).
    const lineNo = await nextSequence('FA_JOURNAL');
    await run(
      `INSERT INTO fa_journal_line
        (no, posting_date, fixed_asset_id, depreciation_book_code, fa_posting_type, amount,
         balancing_gl_account_id, description, status, created_at, created_by)
       VALUES (?,?,?,?,'Acquisition Cost',?,?,?, 'Approved', ?, 'system')`,
      lineNo, startDate, asset.id, 'COMPANY', d.cost, bankId, 'Opening acquisition', now,
    );
    await faJournalLib.postFaJournalLine(lineNo, sys);
  }

  // One year of depreciation, then post every line it drafts.
  await faDeprLib.calculateDepreciation('COMPANY', lastMonthEnd, sys);
  const drafted = await all<{ no: string }>(
    "SELECT no FROM fa_journal_line WHERE fa_posting_type = 'Depreciation' AND status = 'Open'",
  );
  for (const l of drafted) {
    await run("UPDATE fa_journal_line SET status = 'Approved' WHERE no = ?", l.no);
    await faJournalLib.postFaJournalLine(l.no, sys);
  }

  // A maintenance entry and a disposal, so those screens have data too.
  const svcAsset = (await one<{ id: number }>("SELECT id FROM fixed_asset WHERE no = (SELECT no FROM fixed_asset WHERE description = 'Toyota Hilux Double Cab')"))!;
  const maintNo = await nextSequence('FA_JOURNAL');
  await run(
    `INSERT INTO fa_journal_line
      (no, posting_date, fixed_asset_id, depreciation_book_code, fa_posting_type, amount, balancing_gl_account_id,
       maintenance_code, description, status, created_at, created_by)
     VALUES (?,?,?,?,'Maintenance',?,?,?,?, 'Approved', ?, 'system')`,
    maintNo, lastMonthEnd, svcAsset.id, 'COMPANY', K(18500), bankId, 'SERVICE', '30,000 km service', now,
  );
  await faJournalLib.postFaJournalLine(maintNo, sys);
}

/**
 * A small Receivables demo — Customer Posting Groups / Payment Terms / Methods / Reminder &
 * Finance Charge Terms / Sales & Receivables Setup, three customers, a couple of posted sales
 * invoices billing rent / service income, one part-paid via a Cash Receipt, and one left
 * overdue with a Reminder created — so every Receivables screen and the Aged AR report are
 * populated on first run.
 */
async function seedReceivables(now: IsoDateTime, todayIso: IsoDate): Promise<void> {
  const sys: Actor = { id: 1, username: 'system' };
  const acctId = async (code: string): Promise<number> =>
    (await one<{ id: number }>('SELECT id FROM gl_account WHERE code = ?', code))!.id;

  const [a1250, a4098, a4099, a5030, a4050, a4096, a5090] = await Promise.all([
    acctId('1250'), acctId('4098'), acctId('4099'), acctId('5030'), acctId('4050'), acctId('4096'), acctId('5090'),
  ]);
  await run('UPDATE gl_account SET no_direct_posting = 1 WHERE id = ?', a1250);

  const INS_PT = 'INSERT INTO payment_terms (code, description, due_date_calculation, discount_date_calculation, discount_pct, created_at, created_by) VALUES (?,?,?,?,?,?,\'system\')';
  await run(INS_PT, 'COD', 'Cash on Delivery', '0D', '', 0, now);
  await run(INS_PT, '14 DAYS', 'Net 14 days', '14D', '', 0, now);
  await run(INS_PT, '30 DAYS', 'Net 30 days', '30D', '', 0, now);
  await run(INS_PT, '1M(8D)', 'Net 1 month, 2% 8 days', '1M', '8D', 2, now);

  const INS_PM = 'INSERT INTO payment_method (code, description, bal_account_type, bal_account_no, created_at, created_by) VALUES (?,?,?,?,?,\'system\')';
  await run(INS_PM, 'CASH', 'Cash', 'Bank Account', 'CASH', now);
  await run(INS_PM, 'BANK', 'Bank Transfer', 'Bank Account', 'BANK', now);
  await run(INS_PM, 'MPESA', 'M-Pesa', 'Bank Account', 'MPESA', now);
  await run(INS_PM, 'CHEQUE', 'Cheque', 'None', null, now);

  const INS_CPG = `INSERT INTO customer_posting_group
    (code, description, receivables_account_id, service_charge_account_id, additional_fee_account_id,
     payment_disc_debit_account_id, payment_disc_credit_account_id, invoice_rounding_account_id, created_at, created_by)
    VALUES (?,?,?,?,?,?,?,?,?,'system')`;
  await run(INS_CPG, 'TRADE', 'Trade Debtors', a1250, a4098, a4099, a5030, a4050, a4050, now);
  await run(INS_CPG, 'TENANT', 'Tenants', a1250, a4098, a4099, a5030, a4050, a4050, now);

  await run(
    `INSERT INTO reminder_terms (code, description, max_no_of_reminders, post_interest, post_additional_fee, min_amount, created_at, created_by)
     VALUES ('DOMESTIC', 'Domestic Reminders', 3, 1, 1, ?, ?, 'system')`,
    K(100), now,
  );
  const INS_RL = `INSERT INTO reminder_level (reminder_terms_code, level_no, grace_period, due_date_calculation, calculate_interest, additional_fee, add_fee_per_line, begin_text, end_text)
    VALUES ('DOMESTIC', ?,?,?,?,?,?,?,?)`;
  await run(INS_RL, 1, '7D', '7D', 0, 0, 0, 'Our records show the following amounts as overdue. Please arrange payment.', 'If payment has already been made, please disregard this reminder.');
  await run(INS_RL, 2, '7D', '7D', 1, K(500), 0, 'This is our second reminder. The overdue amounts now attract interest.', 'Please settle immediately to avoid further charges.');
  await run(INS_RL, 3, '7D', '7D', 1, K(1000), 0, 'FINAL REMINDER. The account will be referred for collection if not settled.', 'Contact us immediately to make arrangements.');

  await run(
    `INSERT INTO finance_charge_terms (code, description, interest_rate, min_amount, additional_fee, grace_period, due_date_calculation, interest_period_days, post_interest, post_additional_fee, line_description, created_at, created_by)
     VALUES ('1.5%', '1.5% per month on overdue balances', 18.0, ?, 0, '0D', '14D', 360, 1, 0, 'Finance charge on overdue balance', ?, 'system')`,
    K(100), now,
  );

  await run(
    `INSERT INTO sales_receivables_setup (id, default_customer_posting_group_code, default_payment_terms_code, default_reminder_terms_code, default_fin_charge_terms_code, updated_at, updated_by)
     VALUES (1, 'TRADE', '30 DAYS', 'DOMESTIC', '1.5%', ?, 'system')`,
    now,
  );

  await run(
    'UPDATE product_posting_group SET sales_gl_account_id = ?, cogs_gl_account_id = ? WHERE sales_gl_account_id IS NULL',
    a4096, a5090,
  );

  // Three customers.
  const demo: { input: Parameters<typeof custLib.createCustomer>[0]; }[] = [
    { input: { name: 'Rift Valley Traders Ltd', city: 'Nakuru', phone: '+254 720 111 222', email: 'accounts@rvt.co.ke', contact: 'James Kariuki', customerPostingGroupCode: 'TRADE', paymentTermsCode: '30 DAYS', creditLimit: K(2000000), blocked: '' } },
    { input: { name: 'Lakeview Apartments (Tenant)', city: 'Nakuru', phone: '+254 733 444 555', email: 'lakeview@mail.co.ke', contact: 'Susan Wambui', customerPostingGroupCode: 'TENANT', paymentTermsCode: '14 DAYS', creditLimit: 0, blocked: '' } },
    { input: { name: 'Mwangi & Sons Hardware', city: 'Naivasha', phone: '+254 711 777 888', email: 'mwangi.hardware@mail.co.ke', contact: 'Peter Mwangi', customerPostingGroupCode: 'TRADE', paymentTermsCode: 'COD', creditLimit: K(500000), blocked: '' } },
  ];
  const customerIds: number[] = [];
  for (const d of demo) {
    const { no } = await custLib.createCustomer(d.input, sys);
    customerIds.push((await one<{ id: number }>('SELECT id FROM customer WHERE no = ?', no))!.id);
  }

  // A helper: create an Invoice with a single G/L-account line, release it, post it.
  const postInvoice = async (
    customerId: number, postingDate: IsoDate, glCode: string, description: string, qty: number, unitPrice: number,
  ): Promise<string> => {
    const { no } = await salesLib.createSalesDocument(
      { documentType: 'Invoice', customerId, postingDate, documentDate: postingDate }, sys,
    );
    await salesLib.setSalesLines(no, [
      { type: 'G/L Account', no: glCode, description, quantity: qty, unitPrice, lineDiscountPct: 0 },
    ], sys);
    // Bypass the (absent) workflow: mark Released + snapshot sell-to, mirroring approveSalesDocument.
    const cust = (await one<{ name: string; address: string | null; city: string | null; contact: string | null; payment_terms_code: string | null; document_date: string }>(
      `SELECT c.name, c.address, c.city, c.contact, sh.payment_terms_code, sh.document_date
       FROM sales_header sh JOIN customer c ON c.id = sh.customer_id WHERE sh.no = ?`, no,
    ))!;
    const pt = cust.payment_terms_code
      ? await one<{ due_date_calculation: string }>('SELECT due_date_calculation FROM payment_terms WHERE code = ?', cust.payment_terms_code)
      : null;
    const dueDate = pt ? applyDateFormulaSeed(cust.document_date, pt.due_date_calculation) : postingDate;
    await run(
      `UPDATE sales_header SET status = 'Released', due_date = ?, sell_to_name = ?, sell_to_address = ?, sell_to_city = ?, sell_to_contact = ? WHERE no = ?`,
      dueDate, cust.name, cust.address, cust.city, cust.contact, no,
    );
    const res = await salesLib.postSalesDocument(no, { invoice: true }, sys);
    return res.invoiceNo!;
  };

  const twoMonthsAgo = addMonths(todayIso, -2).slice(0, 10);
  const oneMonthAgo = addMonths(todayIso, -1).slice(0, 10);

  // Customer 1 — two invoices, one part-paid.
  await postInvoice(customerIds[0], oneMonthAgo, '4094', 'Consultancy — August', 1, K(180000));
  await postInvoice(customerIds[0], todayIso.slice(0, 8) + '05', '4094', 'Consultancy — September', 1, K(120000));
  // Customer 2 (tenant) — rent, left overdue.
  await postInvoice(customerIds[1], twoMonthsAgo, '4092', 'Monthly rent', 1, K(45000));
  // Customer 3 — a current invoice.
  await postInvoice(customerIds[2], todayIso.slice(0, 8) + '02', '4094', 'Delivery services', 1, K(32000));

  // A Cash Receipt part-paying customer 1's first invoice.
  const firstInvoiceDoc = (await one<{ document_no: string }>(
    "SELECT document_no FROM cust_ledger_entry WHERE customer_id = ? AND document_type = 'Invoice' ORDER BY id LIMIT 1", customerIds[0],
  ))!;
  const { no: crNo } = await cashReceiptLib.createCashReceipt({
    postingDate: todayIso, documentDate: todayIso, bankAccountId: (await one<{ id: number }>("SELECT id FROM bank_account WHERE code = 'BANK'"))!.id,
    description: 'Customer receipts',
    lines: [{ customerId: customerIds[0], amount: K(100000), appliesToDocNo: firstInvoiceDoc.document_no, paymentMethodCode: 'BANK' }],
  }, sys);
  await run("UPDATE cash_receipt_header SET status = 'Approved' WHERE no = ?", crNo);
  await cashReceiptLib.postCashReceipt(crNo, sys);

  // Create a Reminder for the overdue tenant.
  await reminderLib.createReminders({ customerId: customerIds[1], documentDate: todayIso }, sys);
}

/**
 * A small Payables demo — a Vendor Posting Group / Purchases & Payables Setup, three vendors, a
 * couple of posted purchase invoices (rent, utilities, audit fees on G/L expense lines) and one
 * Payment Journal paying a vendor — so every Payables screen and the Aged AP report are
 * populated on first run. Mirrors seedReceivables.
 */
async function seedPayables(now: IsoDateTime, todayIso: IsoDate): Promise<void> {
  const sys: Actor = { id: 1, username: 'system' };
  const acctId = async (code: string): Promise<number> =>
    (await one<{ id: number }>('SELECT id FROM gl_account WHERE code = ?', code))!.id;

  const [a2150, a5030, a4050] = await Promise.all([acctId('2150'), acctId('5030'), acctId('4050')]);
  await run('UPDATE gl_account SET no_direct_posting = 1 WHERE id = ?', a2150);

  const INS_VPG = `INSERT INTO vendor_posting_group
    (code, description, payables_account_id, service_charge_account_id,
     payment_disc_debit_account_id, payment_disc_credit_account_id, invoice_rounding_account_id, created_at, created_by)
    VALUES (?,?,?,?,?,?,?,?,'system')`;
  await run(INS_VPG, 'TRADE', 'Trade Creditors', a2150, a5030, a5030, a4050, a4050, now);
  await run(INS_VPG, 'EXPENSE', 'Expense Suppliers', a2150, a5030, a5030, a4050, a4050, now);

  await run(
    `INSERT INTO purchases_payables_setup (id, default_vendor_posting_group_code, default_payment_terms_code, updated_at, updated_by)
     VALUES (1, 'TRADE', '30 DAYS', ?, 'system')`,
    now,
  );

  const demo: { input: Parameters<typeof vendorLib.createVendor>[0] }[] = [
    { input: { name: 'Nakuru County Water & Sanitation', city: 'Nakuru', phone: '+254 51 221 3344', email: 'billing@nawassco.co.ke', contact: 'Billing Desk', vendorPostingGroupCode: 'EXPENSE', paymentTermsCode: '14 DAYS', creditLimit: 0, blocked: '' } },
    { input: { name: 'Lakefront Properties Ltd', city: 'Nakuru', phone: '+254 722 998 877', email: 'leases@lakefront.co.ke', contact: 'Anne Cheruiyot', vendorPostingGroupCode: 'TRADE', paymentTermsCode: '30 DAYS', creditLimit: K(5000000), blocked: '' } },
    { input: { name: 'Mwenda & Associates CPA', city: 'Nairobi', phone: '+254 733 112 233', email: 'audit@mwendacpa.co.ke', contact: 'CPA Mwenda', vendorPostingGroupCode: 'EXPENSE', paymentTermsCode: '1M(8D)', creditLimit: 0, blocked: '' } },
  ];
  const vendorIds: number[] = [];
  for (const d of demo) {
    const { no } = await vendorLib.createVendor(d.input, sys);
    vendorIds.push((await one<{ id: number }>('SELECT id FROM vendor WHERE no = ?', no))!.id);
  }

  const postInvoice = async (
    vendorId: number, postingDate: IsoDate, glCode: string, description: string, amount: number, vendorInvoiceNo: string,
  ): Promise<string> => {
    const { no } = await purchaseLib.createPurchaseDocument(
      { documentType: 'Invoice', vendorId, postingDate, documentDate: postingDate, vendorInvoiceNo }, sys,
    );
    await purchaseLib.setPurchaseLines(no, [
      { type: 'G/L Account', no: glCode, description, quantity: 1, directUnitCost: amount, lineDiscountPct: 0 },
    ], sys);
    const vend = (await one<{ name: string; address: string | null; city: string | null; contact: string | null; payment_terms_code: string | null; document_date: string }>(
      `SELECT v.name, v.address, v.city, v.contact, ph.payment_terms_code, ph.document_date
       FROM purchase_header ph JOIN vendor v ON v.id = ph.vendor_id WHERE ph.no = ?`, no,
    ))!;
    const pt = vend.payment_terms_code
      ? await one<{ due_date_calculation: string }>('SELECT due_date_calculation FROM payment_terms WHERE code = ?', vend.payment_terms_code)
      : null;
    const dueDate = pt ? applyDateFormulaSeed(vend.document_date, pt.due_date_calculation) : postingDate;
    await run(
      `UPDATE purchase_header SET status = 'Released', due_date = ?, buy_from_name = ?, buy_from_address = ?, buy_from_city = ?, buy_from_contact = ? WHERE no = ?`,
      dueDate, vend.name, vend.address, vend.city, vend.contact, no,
    );
    const res = await purchaseLib.postPurchaseDocument(no, { invoice: true }, sys);
    return res.invoiceNo!;
  };

  const twoMonthsAgo = addMonths(todayIso, -2).slice(0, 10);
  const oneMonthAgo = addMonths(todayIso, -1).slice(0, 10);

  await postInvoice(vendorIds[0], oneMonthAgo, '4040', 'Water & sewerage — August', K(18500), 'NAW-88213');
  await postInvoice(vendorIds[1], twoMonthsAgo, '5030', 'Office rent — Q3', K(360000), 'LFP-2026-041');
  await postInvoice(vendorIds[2], oneMonthAgo, '5050', 'Statutory audit fee 2025', K(240000), 'MWA-1187');

  // Pay the water bill in full through a Payment Journal.
  const waterDoc = (await one<{ document_no: string }>(
    "SELECT document_no FROM vendor_ledger_entry WHERE vendor_id = ? AND document_type = 'Invoice' ORDER BY id LIMIT 1", vendorIds[0],
  ))!;
  const bankId = (await one<{ id: number }>("SELECT id FROM bank_account WHERE code = 'BANK'"))!.id;
  const { no: payNo } = await paymentJournalLib.createPaymentJournal({
    postingDate: todayIso, documentDate: todayIso, bankAccountId: bankId, description: 'Vendor payments',
    lines: [{ vendorId: vendorIds[0], amount: K(18500), appliesToDocNo: waterDoc.document_no, paymentMethodCode: 'BANK' }],
  }, sys);
  await run("UPDATE payment_journal_header SET status = 'Approved' WHERE no = ?", payNo);
  await paymentJournalLib.postPaymentJournal(payNo, sys);
}

/**
 * Cash Management + multi-currency + VAT/WHT masters — Currencies (KES base + USD/EUR),
 * Bank Acc. Posting Groups, the Cash Management Setup singleton, and the VAT Posting Setup
 * (Business Central style, reused for WHT). Back-fills the existing bank accounts + vendors.
 * Mirrors the guarded backfill blocks in the 20260906 / 20260907 migrations.
 */
async function seedCashAndTax(now: IsoDateTime, _todayIso: IsoDate): Promise<void> {
  const acctId = async (code: string): Promise<number> =>
    (await one<{ id: number }>('SELECT id FROM gl_account WHERE code = ?', code))!.id;
  const [a4070, a4072, a5085, a5087, a1260, a2190, a2195, a1010, a1020, a1030, a1040, a5030, a4050] = await Promise.all([
    acctId('4070'), acctId('4072'), acctId('5085'), acctId('5087'), acctId('1260'), acctId('2190'), acctId('2195'),
    acctId('1010'), acctId('1020'), acctId('1030'), acctId('1040'), acctId('5030'), acctId('4050'),
  ]);

  // Currencies (BC T4). Base first, then two foreign with the four FX accounts.
  await run(
    `INSERT INTO currency (code, description, symbol, iso_numeric_code, is_base, amount_rounding_precision, created_at, created_by)
     VALUES ('KES', 'Kenya Shilling', 'KSh', '404', 1, 100, ?, 'system')`, now,
  );
  const INS_CCY = `INSERT INTO currency
    (code, description, symbol, iso_numeric_code, is_base, amount_rounding_precision,
     realized_gains_account_id, realized_losses_account_id, unrealized_gains_account_id, unrealized_losses_account_id,
     residual_gains_account_id, residual_losses_account_id, created_at, created_by)
    VALUES (?,?,?,?,0,1,?,?,?,?,?,?,?,'system')`;
  await run(INS_CCY, 'USD', 'US Dollar', '$', '840', a4070, a5085, a4072, a5087, a4070, a5085, now);
  await run(INS_CCY, 'EUR', 'Euro', '€', '978', a4070, a5085, a4072, a5087, a4070, a5085, now);

  // Bank Acc. Posting Groups (BC T277).
  const INS_BAPG = 'INSERT INTO bank_acc_posting_group (code, description, gl_account_id, created_at, created_by) VALUES (?,?,?,?,\'system\')';
  await run(INS_BAPG, 'BANK', 'Bank current accounts', a1020, now);
  await run(INS_BAPG, 'CASH', 'Cash accounts', a1010, now);
  await run(INS_BAPG, 'MPESA', 'Mobile-money settlement', a1030, now);
  await run(INS_BAPG, 'CLEARING', 'Clearing accounts', a1040, now);

  // Back-fill the bank accounts created by seedReferenceData.
  await run("UPDATE bank_account SET currency_code = 'KES', balance_lcy = balance WHERE currency_code IS NULL OR currency_code = ''");
  await run("UPDATE bank_account SET bank_acc_posting_group_code = 'BANK' WHERE code IN ('BANK')");
  await run("UPDATE bank_account SET bank_acc_posting_group_code = 'CASH' WHERE code IN ('CASH','TREASURY','TILL-01','TILL-02')");
  await run("UPDATE bank_account SET bank_acc_posting_group_code = 'MPESA' WHERE code = 'MPESA'");
  await run("UPDATE bank_account SET bank_acc_posting_group_code = 'CLEARING' WHERE code = 'CHECKOFF'");

  // Cash Management Setup singleton (BC-style limits + Transfer-to-G/L defaults).
  await run(
    `INSERT INTO cash_management_setup
       (id, receipt_approval_limit, pv_approval_limit, default_vat_bus_posting_group_code,
        bank_charges_account_id, bank_interest_income_account_id, default_receipt_bank_account_id, updated_at, updated_by)
     VALUES (1, ?, ?, 'STANDARD', ?, ?, (SELECT id FROM bank_account WHERE code = 'BANK'), ?, 'system')`,
    K(50000), K(20000), a5030, a4050, now,
  );

  // External bank directory (a handful of Kenyan banks + branches).
  const INS_EB = "INSERT INTO external_bank (code, name) VALUES (?,?)";
  for (const [c, n] of [['COOP', 'Co-operative Bank of Kenya'], ['EQUITY', 'Equity Bank'], ['KCB', 'Kenya Commercial Bank'], ['NCBA', 'NCBA Bank'], ['ABSA', 'Absa Bank Kenya'], ['DTB', 'Diamond Trust Bank']] as const) {
    await run(INS_EB, c, n);
  }
  const INS_EBB = "INSERT INTO external_bank_branch (bank_code, branch_code, branch_name) VALUES (?,?,?)";
  for (const [b, code, name] of [['COOP', '11000', 'Co-op House'], ['COOP', '11151', 'Nakuru'], ['EQUITY', '68000', 'Equity Centre'], ['EQUITY', '68012', 'Nakuru'], ['KCB', '01100', 'Moi Avenue'], ['KCB', '01169', 'Nakuru']] as const) {
    await run(INS_EBB, b, code, name);
  }

  // VAT + WHT (BC VAT Posting Setup, reused for WHT the way the AL localization does).
  await run("INSERT INTO vat_business_posting_group (code, description, created_at, created_by) VALUES ('STANDARD', 'Standard-rated domestic', ?, 'system')", now);
  const INS_VPPG = "INSERT INTO vat_product_posting_group (code, description, tax_type, created_at, created_by) VALUES (?,?,?,?,'system')";
  for (const [c, d, t] of [
    ['VAT16', 'VAT at 16%', 'VAT'], ['VAT0', 'Zero-rated', 'VAT'], ['EXEMPT', 'VAT exempt', 'VAT'],
    ['WHT-PROF', 'WHT — professional fees (5%)', 'WHT'], ['WHT-RENT', 'WHT — rent (10%)', 'WHT'], ['WHT-VAT', 'Withholding VAT (2%)', 'WHT'],
  ] as const) await run(INS_VPPG, c, d, t, now);
  const INS_VPS = `INSERT INTO vat_posting_setup
    (vat_bus_posting_group_code, vat_prod_posting_group_code, tax_type, vat_pct, vat_calculation_type, tax_account_id, wht_base, created_at, created_by)
    VALUES ('STANDARD', ?, ?, ?, ?, ?, 'Net', ?, 'system')`;
  await run(INS_VPS, 'VAT16', 'VAT', 16, 'Normal', a1260, now);
  await run(INS_VPS, 'VAT0', 'VAT', 0, 'Zero VAT', a1260, now);
  await run(INS_VPS, 'EXEMPT', 'VAT', 0, 'Exempt', a1260, now);
  await run(INS_VPS, 'WHT-PROF', 'WHT', 5, 'Normal', a2190, now);
  await run(INS_VPS, 'WHT-RENT', 'WHT', 10, 'Normal', a2190, now);
  await run(INS_VPS, 'WHT-VAT', 'WHT', 2, 'Normal', a2195, now);

  await run("UPDATE vendor SET vat_bus_posting_group_code = 'STANDARD' WHERE vat_bus_posting_group_code IS NULL");
  await run("UPDATE purchases_payables_setup SET default_vat_bus_posting_group_code = 'STANDARD' WHERE id = 1");
  // Give the CPA and property vendors a KRA PIN so a WHT certificate prints in full.
  await run("UPDATE vendor SET pin_no = 'P051' || LPAD((id)::text, 6, '0') || 'A' WHERE pin_no IS NULL");
}

/**
 * Financial Reports (Account Schedules) — Business Central-style row definitions + column
 * layouts + report pairings, built from the CHART above so every screen is populated on first
 * run. The 20260909000000_add_financial_reports migration seeds the identical content for a
 * database that was already migrated before this feature landed.
 */
async function seedFinancialReports(now: IsoDateTime, _todayIso: IsoDate): Promise<void> {
  const INS_CLN = 'INSERT INTO column_layout_name (name, description, created_at, created_by) VALUES (?,?,?,\'system\')';
  const INS_CL = `INSERT INTO column_layout
    (column_layout_name_id, line_no, column_no, column_header, column_type, amount_type, formula, comparison_date_formula, created_at, created_by)
    VALUES (?,?,?,?,?,?,?,?,?,'system')`;
  const layouts: [string, string, [number, string, string, string, string, string][]][] = [
    ['DEFAULT', 'Single net-change column', [
      [10000, 'NET', 'Net Change', 'NET_CHANGE', '', ''],
    ]],
    ['BALANCE', 'Single balance-at-date column', [
      [10000, 'BAL', 'Balance', 'BALANCE_AT_DATE', '', ''],
    ]],
    ['THIS-VS-LAST', 'This year, last year and the % change', [
      [10000, 'TY', 'This Year', 'NET_CHANGE', '', ''],
      [20000, 'LY', 'Last Year', 'NET_CHANGE', '', '-1Y'],
      [30000, 'CHG', 'Change %', 'FORMULA', '(TY-LY)/LY*100', ''],
    ]],
    ['YTD-BAL', 'Year to date and closing balance', [
      [10000, 'YTD', 'Year to Date', 'YEAR_TO_DATE', '', ''],
      [20000, 'BAL', 'Balance', 'BALANCE_AT_DATE', '', ''],
    ]],
  ];
  for (const [name, description, lines] of layouts) {
    const info = await run(INS_CLN, name, description, now);
    for (const [lineNo, colNo, header, type, formula, cmp] of lines) {
      await run(INS_CL, info.lastInsertRowid, lineNo, colNo, header, type, 'NET_AMOUNT', formula, cmp, now);
    }
  }

  const INS_ASN = 'INSERT INTO acc_schedule_name (name, description, default_column_layout_name, created_at, created_by) VALUES (?,?,?,?,\'system\')';
  const INS_ASL = `INSERT INTO acc_schedule_line
    (acc_schedule_name_id, line_no, row_no, description, totaling_type, totaling, row_type, show, bold, double_underline, indentation, created_at, created_by)
    VALUES (?,?,?,?,?,?,?,?,?,?,?,?,'system')`;
  // [lineNo, rowNo, description, totalingType, totaling, rowType, show, bold, doubleUnderline, indent]
  type Row = [number, string, string, string, string, string, string, 0 | 1, 0 | 1, number];
  const schedules: [string, string, string, Row[]][] = [
    ['SACCO-BS', 'Statement of Financial Position', 'BALANCE', [
      [10000, 'CA', 'Current assets', 'TOTAL_ACCOUNTS', '1000..1299', 'BALANCE_AT_DATE', 'YES', 0, 0, 1],
      [20000, 'PPE', 'Property, plant and equipment', 'TOTAL_ACCOUNTS', '1300..1499', 'BALANCE_AT_DATE', 'YES', 0, 0, 1],
      [30000, 'TA', 'Total assets', 'FORMULA', 'CA+PPE', 'BALANCE_AT_DATE', 'YES', 1, 1, 0],
      [40000, 'DEP', 'Member deposits', 'TOTAL_ACCOUNTS', '2000..2099', 'BALANCE_AT_DATE', 'YES', 0, 0, 1],
      [50000, 'OL', 'Other liabilities', 'TOTAL_ACCOUNTS', '2100..2199', 'BALANCE_AT_DATE', 'YES', 0, 0, 1],
      [60000, 'TL', 'Total liabilities', 'FORMULA', 'DEP+OL', 'BALANCE_AT_DATE', 'YES', 1, 0, 0],
      [70000, 'EQ', 'Capital and reserves', 'TOTAL_ACCOUNTS', '3000..3099', 'BALANCE_AT_DATE', 'YES', 0, 0, 1],
      [80000, 'INC', 'Income (period)', 'TOTAL_ACCOUNTS', '4000..4999', 'BALANCE_AT_DATE', 'NO', 0, 0, 0],
      [90000, 'EXP', 'Expenditure (period)', 'TOTAL_ACCOUNTS', '5000..5999', 'BALANCE_AT_DATE', 'NO', 0, 0, 0],
      [100000, 'SURP', 'Surplus for the period', 'FORMULA', 'INC-EXP', 'BALANCE_AT_DATE', 'YES', 0, 0, 1],
      [110000, 'TE', 'Total equity', 'FORMULA', 'EQ+SURP', 'BALANCE_AT_DATE', 'YES', 1, 0, 0],
      [120000, 'TLE', 'Total equity and liabilities', 'FORMULA', 'TL+TE', 'BALANCE_AT_DATE', 'YES', 1, 1, 0],
      [130000, 'CHK', 'Balance check (assets less equity and liabilities)', 'FORMULA', 'TA-TLE', 'BALANCE_AT_DATE', 'IF_ANY_NOT_ZERO', 0, 0, 0],
    ]],
    ['SACCO-PL', 'Statement of Comprehensive Income', 'THIS-VS-LAST', [
      [10000, 'II', 'Interest on member loans', 'POSTING_ACCOUNTS', '4010', 'NET_CHANGE', 'YES', 0, 0, 1],
      [20000, 'FEE', 'Fees, commissions and other income', 'TOTAL_ACCOUNTS', '4020..4099', 'NET_CHANGE', 'YES', 0, 0, 1],
      [30000, 'TINC', 'Total income', 'FORMULA', 'II+FEE', 'NET_CHANGE', 'YES', 1, 0, 0],
      [40000, 'FIN', 'Interest on member deposits', 'POSTING_ACCOUNTS', '5010', 'NET_CHANGE', 'YES', 0, 0, 1],
      [50000, 'STAFF', 'Staff costs', 'POSTING_ACCOUNTS', '5020', 'NET_CHANGE', 'YES', 0, 0, 1],
      [60000, 'ADMIN', 'Administrative and other expenses', 'TOTAL_ACCOUNTS', '5030..5099', 'NET_CHANGE', 'YES', 0, 0, 1],
      [70000, 'TEXP', 'Total expenditure', 'FORMULA', 'FIN+STAFF+ADMIN', 'NET_CHANGE', 'YES', 1, 0, 0],
      [80000, 'SURP', 'Surplus for the period', 'FORMULA', 'TINC-TEXP', 'NET_CHANGE', 'YES', 1, 1, 0],
    ]],
    ['SASRA-CAP', 'Capital Adequacy ratios (SASRA)', 'DEFAULT', [
      [10000, 'CORE', 'Core capital', 'TOTAL_ACCOUNTS', '3010..3020', 'BALANCE_AT_DATE', 'YES', 0, 0, 0],
      [20000, 'INST', 'Institutional capital', 'TOTAL_ACCOUNTS', '3020..3030', 'BALANCE_AT_DATE', 'YES', 0, 0, 0],
      [30000, 'TA', 'Total assets', 'TOTAL_ACCOUNTS', '1000..1499', 'BALANCE_AT_DATE', 'YES', 0, 0, 0],
      [40000, 'TD', 'Total deposits', 'TOTAL_ACCOUNTS', '2000..2099', 'BALANCE_AT_DATE', 'YES', 0, 0, 0],
      [50000, 'R1', 'Core capital / total assets (%) — min 10%', 'FORMULA', 'CORE/TA*100', 'BALANCE_AT_DATE', 'YES', 1, 0, 0],
      [60000, 'R2', 'Core capital / total deposits (%) — min 8%', 'FORMULA', 'CORE/TD*100', 'BALANCE_AT_DATE', 'YES', 1, 0, 0],
      [70000, 'R3', 'Institutional capital / total assets (%) — min 8%', 'FORMULA', 'INST/TA*100', 'BALANCE_AT_DATE', 'YES', 1, 0, 0],
    ]],
    ['SASRA-LIQ', 'Liquidity ratio (SASRA)', 'DEFAULT', [
      [10000, 'LA', 'Liquid assets', 'TOTAL_ACCOUNTS', '1000..1099', 'BALANCE_AT_DATE', 'YES', 0, 0, 0],
      [20000, 'DEP', 'Member deposits', 'TOTAL_ACCOUNTS', '2000..2099', 'BALANCE_AT_DATE', 'YES', 0, 0, 0],
      [30000, 'PAY', 'Payables and accruals', 'TOTAL_ACCOUNTS', '2100..2199', 'BALANCE_AT_DATE', 'YES', 0, 0, 0],
      [40000, 'STL', 'Short-term liabilities', 'FORMULA', 'DEP+PAY', 'BALANCE_AT_DATE', 'YES', 1, 0, 0],
      [50000, 'RATIO', 'Liquidity ratio (%) — min 15%', 'FORMULA', 'LA/STL*100', 'BALANCE_AT_DATE', 'YES', 1, 0, 0],
    ]],
  ];
  for (const [name, description, dcl, rows] of schedules) {
    const info = await run(INS_ASN, name, description, dcl, now);
    for (const [lineNo, rowNo, desc, tType, totaling, rowType, show, bold, dunder, indent] of rows) {
      await run(INS_ASL, info.lastInsertRowid, lineNo, rowNo, desc, tType, totaling, rowType, show, bold, dunder, indent, now);
    }
  }

  const INS_FR = 'INSERT INTO financial_report (name, description, row_group, column_group, created_at, created_by) VALUES (?,?,?,?,?,\'system\')';
  for (const [name, description, rowGroup, columnGroup] of [
    ['STMT-FIN-POSITION', 'Statement of Financial Position', 'SACCO-BS', 'BALANCE'],
    ['STMT-COMPR-INCOME', 'Statement of Comprehensive Income', 'SACCO-PL', 'THIS-VS-LAST'],
    ['SASRA-CAPITAL-ADEQUACY', 'SASRA Capital Adequacy Return', 'SASRA-CAP', 'DEFAULT'],
    ['SASRA-LIQUIDITY', 'SASRA Liquidity Return', 'SASRA-LIQ', 'DEFAULT'],
  ] as const) {
    await run(INS_FR, name, description, rowGroup, columnGroup, now);
  }
}

/** Local copy of applyDateFormula to keep seed.ts's import graph light (it already pulls a lot). */
function applyDateFormulaSeed(base: IsoDate, formula: string): IsoDate {
  const f = (formula || '').trim().toUpperCase();
  const m = f.match(/^(\d+)\s*D$/);
  if (m) return new Date(new Date(`${base}T00:00:00Z`).getTime() + Number(m[1]) * 86400000).toISOString().slice(0, 10);
  const mm = f.match(/^(\d+)\s*M$/);
  if (mm) return addMonths(base, Number(mm[1]));
  return base;
}
