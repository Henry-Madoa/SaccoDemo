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
      'MEMBERS_READ', 'MEMBER_APPLICATIONS_READ', 'MEMBER_EDITS_READ', 'MEMBER_APPLICATIONS_CREATE',
      'MEMBERS_UPDATE', 'MEMBER_APPLICATIONS_UPDATE', 'MEMBER_EDITS_UPDATE', 'MEMBER_APPLICATIONS_APPROVE',
      'MEMBER_EDITS_APPROVE', 'ACCOUNT_OPENING_READ', 'ACCOUNT_OPENING_CREATE', 'ACCOUNT_OPENING_APPROVE',
      'ACCOUNT_DEACTIVATION_READ', 'ACCOUNT_DEACTIVATION_CREATE', 'ACCOUNT_DEACTIVATION_APPROVE',
      'ACCOUNT_ACTIVATION_READ', 'ACCOUNT_ACTIVATION_CREATE', 'ACCOUNT_ACTIVATION_APPROVE',
      'MEMBER_CHARGING_READ', 'MEMBER_CHARGING_CREATE', 'MEMBER_CHARGING_POST',
      'SAVINGS_READ', 'SAVINGS_DEPOSIT', 'SAVINGS_WITHDRAW',
      'SAVINGS_REVERSE', 'LOAN_READ', 'LOAN_CREATE', 'LOAN_APPROVE', 'LOAN_DISBURSE', 'LOAN_REPAY', 'GL_READ',
      'DASHBOARD_VIEW', 'REPORTS_VIEW', 'APPROVALS_VIEW', 'ADMIN_AUDIT_VIEW', 'ADMIN_CHANGE_LOG_MANAGE',
    ],
  },
  {
    name: 'Loans Officer',
    description: 'Captures and appraises loan applications. Cannot approve own work.',
    actions: [
      'MEMBERS_READ', 'MEMBER_APPLICATIONS_READ', 'MEMBER_EDITS_READ', 'MEMBER_APPLICATIONS_CREATE',
      'MEMBERS_UPDATE', 'MEMBER_APPLICATIONS_UPDATE', 'MEMBER_EDITS_UPDATE', 'ACCOUNT_OPENING_READ',
      'ACCOUNT_DEACTIVATION_READ', 'ACCOUNT_ACTIVATION_READ',
      'SAVINGS_READ', 'LOAN_READ', 'LOAN_CREATE', 'LOAN_REPAY', 'DASHBOARD_VIEW', 'REPORTS_VIEW', 'APPROVALS_VIEW',
    ],
  },
  {
    name: 'Teller',
    description: 'Front-office cash operations.',
    actions: [
      'MEMBERS_READ', 'MEMBER_APPLICATIONS_READ', 'MEMBER_EDITS_READ', 'ACCOUNT_OPENING_READ',
      'ACCOUNT_OPENING_CREATE', 'ACCOUNT_DEACTIVATION_READ', 'ACCOUNT_DEACTIVATION_CREATE',
      'ACCOUNT_ACTIVATION_READ', 'ACCOUNT_ACTIVATION_CREATE',
      'MEMBER_CHARGING_READ', 'MEMBER_CHARGING_CREATE', 'MEMBER_CHARGING_POST',
      'SAVINGS_READ', 'SAVINGS_DEPOSIT', 'SAVINGS_WITHDRAW', 'LOAN_READ', 'LOAN_REPAY',
      'DASHBOARD_VIEW', 'REPORTS_VIEW', 'APPROVALS_VIEW',
    ],
  },
  {
    name: 'Finance Officer',
    description: 'General ledger, journals and financial reporting.',
    actions: [
      'MEMBERS_READ', 'MEMBER_APPLICATIONS_READ', 'MEMBER_EDITS_READ', 'ACCOUNT_OPENING_READ',
      'ACCOUNT_DEACTIVATION_READ', 'ACCOUNT_ACTIVATION_READ', 'MEMBER_CHARGING_READ', 'SAVINGS_READ',
      'LOAN_READ', 'GL_READ', 'GL_JOURNAL_CREATE', 'GL_JOURNAL_APPROVE', 'GL_JOURNAL_REVERSE', 'GL_PERIOD_CLOSE', 'GL_ACCOUNT_MANAGE',
      'ADMIN_CHARGES_MASTER_MANAGE', 'ADMIN_CHARGES_TRANSACTION_MANAGE',
      'DASHBOARD_VIEW', 'REPORTS_VIEW', 'APPROVALS_VIEW',
    ],
  },
  {
    name: 'Internal Auditor',
    description: 'Read-only across the system, including the audit trail.',
    actions: [
      'MEMBERS_READ', 'MEMBER_APPLICATIONS_READ', 'MEMBER_EDITS_READ', 'ACCOUNT_OPENING_READ',
      'ACCOUNT_DEACTIVATION_READ', 'ACCOUNT_ACTIVATION_READ', 'MEMBER_CHARGING_READ', 'SAVINGS_READ',
      'LOAN_READ', 'GL_READ', 'DASHBOARD_VIEW', 'REPORTS_VIEW', 'APPROVALS_VIEW', 'ADMIN_AUDIT_VIEW',
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
  const [a2010, a2020, a2030, a2040, a3010, a4010, a4020, a4030, a4040, a5010,
    a1110, a1120, a1130, a1140] = await Promise.all([
    accId('2010'), accId('2020'), accId('2030'), accId('2040'), accId('3010'),
    accId('4010'), accId('4020'), accId('4030'), accId('4040'), accId('5010'),
    accId('1110'), accId('1120'), accId('1130'), accId('1140'),
  ]);

  const INS_SP =
    `INSERT INTO savings_product (code, name, category, min_balance, min_opening, interest_rate,
      allow_withdrawal, withdrawal_fee, is_loanable_base, withdrawal_notice_days,
      gl_control_id, gl_interest_exp_id, gl_fee_income_id)
     VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?)`;
  await run(INS_SP, 'SHR', 'Member Share Capital', 'SHARE', 0, K(5000), 0, 0, 0, 0, 0, a3010, a5010, a4040);
  await run(INS_SP, 'BOSA', 'BOSA Member Deposits', 'DEPOSIT', 0, K(1000), 8, 0, 0, 1, 60, a2010, a5010, a4040);
  await run(INS_SP, 'FOSA', 'FOSA Savings Account', 'SAVINGS', K(500), K(500), 2, 1, K(50), 0, 0, a2020, a5010, a4040);
  await run(INS_SP, 'FIXED', 'Fixed Deposit Account', 'FIXED', 0, K(20000), 9.5, 0, 0, 0, 90, a2030, a5010, a4040);
  await run(INS_SP, 'HOL', 'Holiday & Education Savings', 'SAVINGS', 0, K(500), 4, 1, K(30), 0, 0, a2040, a5010, a4040);

  const INS_LP =
    `INSERT INTO loan_product (code, name, interest_rate, interest_method, max_term_months, min_amount,
      max_amount, deposit_multiplier, min_membership_months, processing_fee_pct, insurance_pct, penalty_rate,
      guarantors_required, max_dsr_pct, gl_receivable_id, gl_interest_income_id, gl_fee_income_id, gl_penalty_income_id)
     VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)`;
  await run(INS_LP, 'NORM', 'Normal Loan', 12, 'REDUCING', 48, K(10000), K(4000000), 3, 6, 1, 0.5, 1, 2, 66.7,
    a1110, a4010, a4020, a4030);
  await run(INS_LP, 'EMER', 'Emergency Loan', 12, 'REDUCING', 12, K(5000), K(300000), 1, 3, 1, 0.5, 1, 1, 66.7,
    a1120, a4010, a4020, a4030);
  await run(INS_LP, 'SCHL', 'School Fees Loan', 12, 'REDUCING', 12, K(5000), K(500000), 2, 6, 1, 0.5, 1, 2, 66.7,
    a1130, a4010, a4020, a4030);
  await run(INS_LP, 'DEV', 'Development Loan', 14, 'REDUCING', 60, K(50000), K(6000000), 3, 12, 1.5, 0.5, 1, 3, 66.7,
    a1140, a4010, a4020, a4030);
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
    `INSERT INTO member (member_no, member_type, title, first_name, middle_name, last_name, national_id, kra_pin,
      date_of_birth, gender, marital_status, phone, email, postal_address, physical_address, county_id, employer,
      employment_status, staff_no, gross_income, other_deductions,
      status, kyc_verified, join_date, created_at, created_by)
     VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)`;
  const INS_NOK =
    'INSERT INTO member_next_of_kin (member_id, name, relationship, phone) VALUES (?,?,?,?)';

  const memberIds: { id: number; joinDate: IsoDate; income: Cents }[] = [];
  for (let i = 0; i < 120; i++) {
    const female = rnd() < 0.48;
    const fn = female ? pick(FIRST_F) : pick(FIRST_M);
    const mn = female ? pick(FIRST_F) : pick(FIRST_M);
    const ln = pick(LAST);
    const joinDate = addMonths(todayIso, -int(7, 24));
    const income = K(int(35, 220) * 1000);
    const info = await run(
      INS_MEMBER,
      await nextSequence('MEMBER'), 'INDIVIDUAL', female ? 'Ms.' : 'Mr.', fn, mn, ln,
      String(int(20000000, 39999999)), 'A0' + int(10000000, 99999999) + 'Z',
      addMonths(todayIso, -int(22, 55) * 12), female ? 'FEMALE' : 'MALE',
      pick(['SINGLE', 'MARRIED', 'MARRIED', 'WIDOWED']),
      '+2547' + int(10000000, 99999999), `${fn.toLowerCase()}.${ln.toLowerCase()}@example.co.ke`,
      'P.O. Box ' + int(100, 9999) + '–20100', pick(COUNTIES) + ' Town', countyByName[pick(COUNTIES)], pick(EMPLOYERS),
      pick(['PERMANENT', 'PERMANENT', 'CONTRACT', 'SELF_EMPLOYED']), 'EMP' + int(1000, 9999),
      income, K(int(0, 15) * 1000),
      i < 112 ? 'ACTIVE' : pick(['DORMANT', 'WITHDRAWN', 'INACTIVE']), i < 115 ? 1 : 0,
      joinDate, now, 'system',
    );
    const memberId = Number(info.lastInsertRowid);
    await run(
      INS_NOK, memberId, pick(FIRST_F) + ' ' + ln,
      pick(['Spouse', 'Parent', 'Sibling', 'Child']), '+2547' + int(10000000, 99999999),
    );
    memberIds.push({ id: memberId, joinDate, income });
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
