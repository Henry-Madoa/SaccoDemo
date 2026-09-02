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
  ['1300', 'Property and Equipment', 'ASSET', null, 1],
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
  ['5000', 'EXPENDITURE', 'EXPENSE', null, 0],
  ['5010', 'Interest on Member Deposits', 'EXPENSE', '5000', 1],
  ['5020', 'Staff Costs', 'EXPENSE', '5000', 1],
  ['5030', 'Administrative Expenses', 'EXPENSE', '5000', 1],
  ['5040', 'Loan Loss Provision Expense', 'EXPENSE', '5000', 1],
  ['5050', 'Governance and Board Expenses', 'EXPENSE', '5000', 1],
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
      'LOAN_CALCULATOR_READ', 'LOAN_CALCULATOR_CREATE', 'LOAN_CALCULATOR_DELETE', 'LOAN_CALCULATOR_CONVERT',
      'COLLATERAL_APPLICATIONS_READ', 'COLLATERAL_APPLICATIONS_CREATE', 'COLLATERAL_APPLICATIONS_APPROVE',
      'COLLATERAL_REGISTER_READ', 'COLLATERAL_RELEASES_READ', 'COLLATERAL_RELEASES_CREATE',
      'COLLATERAL_RELEASES_APPROVE', 'ADMIN_PRODUCTS_COLLATERAL_MANAGE', 'ADMIN_POOL_SECTORS_MANAGE',
      'ADMIN_NO_SERIES_READ', 'ADMIN_NO_SERIES_MANAGE',
      'GUARANTOR_CHANGES_READ', 'GUARANTOR_CHANGES_CREATE', 'GUARANTOR_CHANGES_APPROVE',
      'MEMBER_EXITS_READ', 'MEMBER_EXITS_CREATE', 'MEMBER_EXITS_APPROVE',
      'CHECKOFF_BATCHES_READ', 'CHECKOFF_BATCHES_CREATE', 'CHECKOFF_BATCHES_APPROVE', 'EMPLOYERS_MANAGE',
      'FIXED_DEPOSITS_READ', 'FIXED_DEPOSITS_CREATE', 'FIXED_DEPOSITS_APPROVE', 'ADMIN_PRODUCTS_FD_MANAGE',
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
      'ADMIN_CHARGES_MASTER_MANAGE', 'ADMIN_CHARGES_TRANSACTION_MANAGE',
      'COLLATERAL_APPLICATIONS_READ', 'COLLATERAL_REGISTER_READ', 'COLLATERAL_RELEASES_READ', 'GUARANTOR_CHANGES_READ',
      'FIXED_DEPOSITS_READ',
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
      'FIXED_DEPOSITS_READ',
      'DASHBOARD_VIEW', 'REPORTS_VIEW', 'APPROVALS_VIEW', 'ADMIN_AUDIT_VIEW',
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
    return seedMembersAndHistory(now, todayIso);
  });

  return { seeded: true, ...counts };
}
