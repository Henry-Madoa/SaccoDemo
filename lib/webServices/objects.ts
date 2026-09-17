/*
 * Web Services — the objects that can be published (Business Central's object list behind the
 * Web Services page): Pages (an entity with fields, readable and — where the domain allows —
 * writable), Queries (read-only datasets) and Codeunits (procedures). Both the OData V4 and the
 * SOAP endpoints are generated from these definitions, so adding an object here is all it takes
 * to expose it in both protocols.
 *
 * Money columns are stored in cents and exposed as decimals (12.50), as BC exposes Decimal.
 * Field names follow BC's PascalCase convention ("No", "Name", "Balance").
 */
import { one, all, run } from '../db.ts';
import { AppError } from '../errors.ts';
import { deposit, withdraw } from '../savings.ts';
import { createCustomer, updateCustomer, type CustomerInput } from '../customers.ts';
import { createVendor, updateVendor, type VendorInput } from '../vendors.ts';
import type { Actor, SessionUser, WebServiceObjectType, Channel, CustomerBlocked } from '../types.ts';
import type { ActionKey } from '../permissions.ts';
import { CHANNELS_INTEGRATION } from './channels.ts';

export type WsType = 'Code' | 'Text' | 'Integer' | 'Decimal' | 'Money' | 'Boolean' | 'Date' | 'DateTime';

export interface WsField {
  /** The field's name in both protocols (BC-style PascalCase). */
  name: string;
  /** SQL expression yielding the value — a column of the object's FROM clause. */
  column: string;
  type: WsType;
  /** The primary key field — exactly one per page/query. */
  key?: boolean;
  /** Not accepted on Create/Update (system fields, balances, computed columns). */
  readOnly?: boolean;
  /** Required on Create. */
  required?: boolean;
  caption?: string;
}

export interface WsContext { user: SessionUser; actor: Actor }

export interface WsPage {
  kind: 'PAGE';
  id: number;
  name: string;
  caption: string;
  /** Singular entity type name and the entity set (URL segment default). */
  entityName: string;
  entitySetName: string;
  /** FROM clause — a table or a joined subquery aliased `t`. */
  from: string;
  /** Tables whose Read permission a caller needs. */
  readTables: string[];
  fields: WsField[];
  /** Absent = read-only in both protocols. */
  insert?: (values: Record<string, unknown>, ctx: WsContext) => Promise<string | number>;
  modify?: (key: string, values: Record<string, unknown>, ctx: WsContext) => Promise<void>;
  delete?: (key: string, ctx: WsContext) => Promise<void>;
  /** Permission table checked for insert/modify/delete. */
  writeTable?: string;
}

export interface WsQuery {
  kind: 'QUERY';
  id: number;
  name: string;
  caption: string;
  entityName: string;
  entitySetName: string;
  from: string;
  readTables: string[];
  fields: WsField[];
}

export interface WsProcedure {
  name: string;
  caption: string;
  params: { name: string; type: WsType; required?: boolean }[];
  /** 'Json' returns a structured object (OData) / a JSON string (SOAP). */
  returns: WsType | 'Json';
  /** The action the caller must hold — the same grant the equivalent screen needs. */
  action?: ActionKey;
  run: (args: Record<string, unknown>, ctx: WsContext) => Promise<unknown>;
}

export interface WsCodeunit {
  kind: 'CODEUNIT';
  id: number;
  name: string;
  caption: string;
  procedures: WsProcedure[];
}

export type WsObject = WsPage | WsQuery | WsCodeunit;

/* ------------------------------------------------------------------------------ helpers */

const str = (v: unknown): string | null => (v == null || v === '' ? null : String(v));
const num = (v: unknown): number | null => (v == null || v === '' ? null : Number(v));
const cents = (v: unknown): number => Math.round(Number(v ?? 0) * 100);
const bool = (v: unknown): boolean => v === true || v === 'true' || v === 1 || v === '1';
const F = (name: string, column: string, type: WsType, extra: Partial<WsField> = {}): WsField => ({ name, column, type, ...extra });

/** A code that names a savings account, member or loan, resolved to its row id. */
async function idOf(table: string, codeColumn: string, code: unknown, what: string): Promise<number> {
  const row = await one<{ id: number }>(`SELECT id FROM ${table} WHERE ${codeColumn} = ?`, String(code ?? '').trim());
  if (!row) throw new AppError(`${what} ${String(code ?? '')} not found`, 'NOT_FOUND');
  return row.id;
}

/* ------------------------------------------------------------------------------ pages */

const MEMBER_FIELDS: WsField[] = [
  F('No', 'member_no', 'Code', { key: true, readOnly: true }),
  F('MemberType', 'member_type', 'Code', { readOnly: true }),
  F('Title', 'title', 'Text'),
  F('FirstName', 'first_name', 'Text'),
  F('MiddleName', 'middle_name', 'Text'),
  F('LastName', 'last_name', 'Text'),
  F('IdentificationNo', 'identification_no', 'Code', { readOnly: true }),
  F('KraPin', 'kra_pin', 'Code'),
  F('DateOfBirth', 'date_of_birth', 'Date'),
  F('Gender', 'gender', 'Code'),
  F('MaritalStatus', 'marital_status', 'Code'),
  F('Phone', 'phone', 'Text'),
  F('Email', 'email', 'Text'),
  F('PostalAddress', 'postal_address', 'Text'),
  F('PhysicalAddress', 'physical_address', 'Text'),
  F('Employer', 'employer', 'Text'),
  F('EmploymentStatus', 'employment_status', 'Code'),
  F('StaffNo', 'staff_no', 'Code'),
  F('Status', 'status', 'Code', { readOnly: true }),
  F('KycVerified', 'kyc_verified', 'Boolean', { readOnly: true }),
  F('JoinDate', 'join_date', 'Date', { readOnly: true }),
  F('GroupName', 'group_name', 'Text'),
  F('RegistrationNo', 'registration_no', 'Code'),
  F('CreatedAt', 'created_at', 'DateTime', { readOnly: true }),
];

/** The columns an integration may change on a member — contact details only; identity, status
 *  and membership dates change through the member-editing workflow, never a raw write. */
const MEMBER_EDITABLE = new Set(['Title', 'FirstName', 'MiddleName', 'LastName', 'KraPin', 'DateOfBirth', 'Gender', 'MaritalStatus', 'Phone', 'Email', 'PostalAddress', 'PhysicalAddress', 'Employer', 'EmploymentStatus', 'StaffNo', 'GroupName', 'RegistrationNo']);

async function genericModify(table: string, keyColumn: string, key: string, fields: WsField[], editable: Set<string> | null, values: Record<string, unknown>, ctx: WsContext, auditAction: string): Promise<void> {
  const sets: string[] = []; const args: unknown[] = [];
  for (const [name, value] of Object.entries(values)) {
    const f = fields.find((x) => x.name === name);
    if (!f) throw new AppError(`Unknown field ${name}`, 'VALIDATION');
    if (f.key) continue;
    if (f.readOnly || (editable && !editable.has(name))) throw new AppError(`Field ${name} is read-only`, 'VALIDATION');
    sets.push(`${f.column} = ?`);
    args.push(f.type === 'Money' ? cents(value) : f.type === 'Boolean' ? (bool(value) ? 1 : 0) : f.type === 'Integer' || f.type === 'Decimal' ? num(value) : str(value));
  }
  if (!sets.length) return;
  const res = await run(`UPDATE ${table} SET ${sets.join(', ')} WHERE ${keyColumn} = ?`, ...args, key);
  if (!res.changes) throw new AppError(`${table} ${key} not found`, 'NOT_FOUND');
  const { audit } = await import('../db.ts');
  await audit(ctx.actor, auditAction, table, key, { via: 'WEB_SERVICE', fields: Object.keys(values) });
}

const CUSTOMER_FIELDS: WsField[] = [
  F('No', 'no', 'Code', { key: true, readOnly: true }),
  F('Name', 'name', 'Text', { required: true }),
  F('Name2', 'name_2', 'Text'),
  F('Address', 'address', 'Text'), F('Address2', 'address_2', 'Text'), F('City', 'city', 'Text'), F('PostCode', 'post_code', 'Code'), F('Country', 'country', 'Code'),
  F('Contact', 'contact', 'Text'), F('Phone', 'phone', 'Text'), F('Email', 'email', 'Text'),
  F('CustomerPostingGroup', 'customer_posting_group_code', 'Code'),
  F('PaymentTermsCode', 'payment_terms_code', 'Code'), F('PaymentMethodCode', 'payment_method_code', 'Code'),
  F('ReminderTermsCode', 'reminder_terms_code', 'Code'), F('FinChargeTermsCode', 'fin_charge_terms_code', 'Code'),
  F('Salesperson', 'salesperson', 'Code'), F('CurrencyCode', 'currency_code', 'Code'),
  F('CreditLimit', 'credit_limit', 'Money'), F('Blocked', 'blocked', 'Code'),
  F('GlobalDimension1Id', 'global_dimension_1_id', 'Integer'), F('GlobalDimension2Id', 'global_dimension_2_id', 'Integer'),
  F('Balance', 'balance', 'Money', { readOnly: true }),
  F('CreatedAt', 'created_at', 'DateTime', { readOnly: true }),
];
function customerInput(cur: Record<string, unknown> | null, v: Record<string, unknown>): CustomerInput {
  const g = (name: string, col: string) => (name in v ? v[name] : cur?.[col]);
  return {
    name: String(g('Name', 'name') ?? ''), name2: str(g('Name2', 'name_2')), address: str(g('Address', 'address')), address2: str(g('Address2', 'address_2')),
    city: str(g('City', 'city')), postCode: str(g('PostCode', 'post_code')), country: str(g('Country', 'country')), contact: str(g('Contact', 'contact')),
    phone: str(g('Phone', 'phone')), email: str(g('Email', 'email')), customerPostingGroupCode: str(g('CustomerPostingGroup', 'customer_posting_group_code')),
    paymentTermsCode: str(g('PaymentTermsCode', 'payment_terms_code')), paymentMethodCode: str(g('PaymentMethodCode', 'payment_method_code')),
    reminderTermsCode: str(g('ReminderTermsCode', 'reminder_terms_code')), finChargeTermsCode: str(g('FinChargeTermsCode', 'fin_charge_terms_code')),
    salesperson: str(g('Salesperson', 'salesperson')), currencyCode: str(g('CurrencyCode', 'currency_code')),
    creditLimit: 'CreditLimit' in v ? cents(v.CreditLimit) : Number(cur?.credit_limit ?? 0),
    blocked: (str(g('Blocked', 'blocked')) ?? '') as CustomerBlocked,
    globalDimension1Id: num(g('GlobalDimension1Id', 'global_dimension_1_id')), globalDimension2Id: num(g('GlobalDimension2Id', 'global_dimension_2_id')),
  };
}

const VENDOR_FIELDS: WsField[] = [
  F('No', 'no', 'Code', { key: true, readOnly: true }),
  F('Name', 'name', 'Text', { required: true }), F('Name2', 'name_2', 'Text'),
  F('Address', 'address', 'Text'), F('Address2', 'address_2', 'Text'), F('City', 'city', 'Text'), F('PostCode', 'post_code', 'Code'), F('Country', 'country', 'Code'),
  F('Contact', 'contact', 'Text'), F('Phone', 'phone', 'Text'), F('Email', 'email', 'Text'),
  F('VendorPostingGroup', 'vendor_posting_group_code', 'Code'), F('VatBusPostingGroup', 'vat_bus_posting_group_code', 'Code'),
  F('PinNo', 'pin_no', 'Code'), F('WhtExempt', 'wht_exempt', 'Boolean'),
  F('PaymentTermsCode', 'payment_terms_code', 'Code'), F('PaymentMethodCode', 'payment_method_code', 'Code'),
  F('Purchaser', 'purchaser', 'Code'), F('OurAccountNo', 'our_account_no', 'Code'), F('CurrencyCode', 'currency_code', 'Code'),
  F('CreditLimit', 'credit_limit', 'Money'), F('Blocked', 'blocked', 'Code'),
  F('Balance', 'balance', 'Money', { readOnly: true }),
  F('CreatedAt', 'created_at', 'DateTime', { readOnly: true }),
];
function vendorInput(cur: Record<string, unknown> | null, v: Record<string, unknown>): VendorInput {
  const g = (name: string, col: string) => (name in v ? v[name] : cur?.[col]);
  return {
    name: String(g('Name', 'name') ?? ''), name2: str(g('Name2', 'name_2')), address: str(g('Address', 'address')), address2: str(g('Address2', 'address_2')),
    city: str(g('City', 'city')), postCode: str(g('PostCode', 'post_code')), country: str(g('Country', 'country')), contact: str(g('Contact', 'contact')),
    phone: str(g('Phone', 'phone')), email: str(g('Email', 'email')), vendorPostingGroupCode: str(g('VendorPostingGroup', 'vendor_posting_group_code')),
    vatBusPostingGroupCode: str(g('VatBusPostingGroup', 'vat_bus_posting_group_code')), pinNo: str(g('PinNo', 'pin_no')),
    whtExempt: 'WhtExempt' in v ? bool(v.WhtExempt) : !!Number(cur?.wht_exempt ?? 0),
    paymentTermsCode: str(g('PaymentTermsCode', 'payment_terms_code')), paymentMethodCode: str(g('PaymentMethodCode', 'payment_method_code')),
    purchaser: str(g('Purchaser', 'purchaser')), ourAccountNo: str(g('OurAccountNo', 'our_account_no')), currencyCode: str(g('CurrencyCode', 'currency_code')),
    creditLimit: 'CreditLimit' in v ? cents(v.CreditLimit) : Number(cur?.credit_limit ?? 0),
    blocked: (str(g('Blocked', 'blocked')) ?? '') as VendorInput['blocked'],
  };
}

export const PAGES: WsPage[] = [
  {
    kind: 'PAGE', id: 50100, name: 'Member Card', caption: 'Members', entityName: 'Member', entitySetName: 'Members',
    from: 'member t', readTables: ['member'], writeTable: 'member', fields: MEMBER_FIELDS,
    modify: (key, values, ctx) => genericModify('member', 'member_no', key, MEMBER_FIELDS, MEMBER_EDITABLE, values, ctx, 'MEMBER_UPDATE'),
  },
  {
    kind: 'PAGE', id: 50101, name: 'Savings Account Card', caption: 'Savings Accounts', entityName: 'SavingsAccount', entitySetName: 'SavingsAccounts',
    from: `(SELECT a.*, m.member_no, m.first_name || ' ' || m.last_name AS member_name, p.code AS product_code, p.name AS product_name,
                   a.balance - a.hold_amount AS available_balance
            FROM savings_account a JOIN member m ON m.id = a.member_id JOIN savings_product p ON p.id = a.product_id) t`,
    readTables: ['savings_account', 'member'],
    fields: [
      F('No', 'account_no', 'Code', { key: true }), F('MemberNo', 'member_no', 'Code'), F('MemberName', 'member_name', 'Text'),
      F('ProductCode', 'product_code', 'Code'), F('ProductName', 'product_name', 'Text'),
      F('Balance', 'balance', 'Money'), F('HoldAmount', 'hold_amount', 'Money'), F('AvailableBalance', 'available_balance', 'Money'),
      F('Status', 'status', 'Code'), F('OpenedDate', 'opened_date', 'Date'), F('LastActivity', 'last_activity', 'DateTime'),
    ].map((f) => ({ ...f, readOnly: true })),
  },
  {
    kind: 'PAGE', id: 50102, name: 'Loan Card', caption: 'Loans', entityName: 'Loan', entitySetName: 'Loans',
    from: `(SELECT l.*, m.member_no, m.first_name || ' ' || m.last_name AS member_name, p.code AS product_code, p.name AS product_name,
                   l.principal_balance + l.interest_balance + l.penalty_balance AS outstanding_balance
            FROM loan l JOIN member m ON m.id = l.member_id JOIN loan_product p ON p.id = l.product_id) t`,
    readTables: ['loan', 'member'],
    fields: [
      F('No', 'loan_no', 'Code', { key: true }), F('MemberNo', 'member_no', 'Code'), F('MemberName', 'member_name', 'Text'),
      F('ProductCode', 'product_code', 'Code'), F('ProductName', 'product_name', 'Text'),
      F('Principal', 'principal', 'Money'), F('InterestRate', 'interest_rate', 'Decimal'), F('InterestMethod', 'interest_method', 'Code'),
      F('TermMonths', 'term_months', 'Integer'), F('Purpose', 'purpose', 'Text'), F('Status', 'status', 'Code'),
      F('AppliedDate', 'applied_date', 'Date'), F('ApprovedDate', 'approved_date', 'Date'), F('DisbursedDate', 'disbursed_date', 'Date'), F('FirstDueDate', 'first_due_date', 'Date'),
      F('Installment', 'installment', 'Money'), F('TotalInterest', 'total_interest', 'Money'),
      F('PrincipalBalance', 'principal_balance', 'Money'), F('InterestBalance', 'interest_balance', 'Money'), F('PenaltyBalance', 'penalty_balance', 'Money'),
      F('OutstandingBalance', 'outstanding_balance', 'Money'), F('PrincipalPaid', 'principal_paid', 'Money'), F('InterestPaid', 'interest_paid', 'Money'),
      F('ArrearsAmount', 'arrears_amount', 'Money'), F('DaysInArrears', 'days_in_arrears', 'Integer'), F('Classification', 'classification', 'Code'),
      F('SectorCode', 'sector_code', 'Code'), F('SubSectorCode', 'sub_sector_code', 'Code'),
    ].map((f) => ({ ...f, readOnly: true })),
  },
  {
    kind: 'PAGE', id: 50103, name: 'Employee Card', caption: 'Employees', entityName: 'Employee', entitySetName: 'Employees',
    from: `(SELECT e.*, g.code AS job_grade_code, g.name AS job_grade_name, cj.job_id AS company_job_code, cj.name AS company_job_name,
                   d1.code AS global_dimension_1_code, d2.code AS global_dimension_2_code
            FROM employee e LEFT JOIN hr_job_grade g ON g.id = e.job_grade_id LEFT JOIN company_job cj ON cj.id = e.company_job_id
            LEFT JOIN global_dimension_1_value d1 ON d1.id = e.global_dimension_1_id LEFT JOIN global_dimension_2_value d2 ON d2.id = e.global_dimension_2_id) t`,
    readTables: ['employee'],
    fields: [
      F('No', 'employee_no', 'Code', { key: true }), F('FirstName', 'first_name', 'Text'), F('MiddleName', 'middle_name', 'Text'), F('LastName', 'last_name', 'Text'),
      F('Gender', 'gender', 'Code'), F('DateOfBirth', 'date_of_birth', 'Date'), F('NationalId', 'national_id', 'Code'), F('KraPin', 'kra_pin', 'Code'),
      F('NssfNo', 'nssf_no', 'Code'), F('ShifNo', 'shif_no', 'Code'), F('Phone', 'phone', 'Text'), F('Email', 'email', 'Text'),
      F('JobTitle', 'job_title', 'Text'), F('JobGradeCode', 'job_grade_code', 'Code'), F('CompanyJobCode', 'company_job_code', 'Code'), F('CompanyJobName', 'company_job_name', 'Text'),
      F('GlobalDimension1Code', 'global_dimension_1_code', 'Code'), F('GlobalDimension2Code', 'global_dimension_2_code', 'Code'),
      F('EmploymentDate', 'employment_date', 'Date'), F('NatureOfEmployment', 'nature_of_employment', 'Code'), F('EmployeeType', 'employee_type', 'Code'),
      F('Status', 'status', 'Code'), F('TerminationDate', 'termination_date', 'Date'),
    ].map((f) => ({ ...f, readOnly: true })),
  },
  {
    kind: 'PAGE', id: 50104, name: 'Customer Card', caption: 'Customers', entityName: 'Customer', entitySetName: 'Customers',
    from: 'customer t', readTables: ['customer'], writeTable: 'customer', fields: CUSTOMER_FIELDS,
    insert: async (values, ctx) => (await createCustomer(customerInput(null, values), ctx.actor)).no,
    modify: async (key, values, ctx) => {
      const cur = await one<Record<string, unknown>>('SELECT * FROM customer WHERE no = ?', key);
      if (!cur) throw new AppError(`Customer ${key} not found`, 'NOT_FOUND');
      await updateCustomer(key, customerInput(cur, values), ctx.actor);
    },
  },
  {
    kind: 'PAGE', id: 50105, name: 'Vendor Card', caption: 'Vendors', entityName: 'Vendor', entitySetName: 'Vendors',
    from: 'vendor t', readTables: ['vendor'], writeTable: 'vendor', fields: VENDOR_FIELDS,
    insert: async (values, ctx) => (await createVendor(vendorInput(null, values), ctx.actor)).no,
    modify: async (key, values, ctx) => {
      const cur = await one<Record<string, unknown>>('SELECT * FROM vendor WHERE no = ?', key);
      if (!cur) throw new AppError(`Vendor ${key} not found`, 'NOT_FOUND');
      await updateVendor(key, vendorInput(cur, values), ctx.actor);
    },
  },
  {
    kind: 'PAGE', id: 50106, name: 'G/L Account Card', caption: 'G/L Accounts', entityName: 'GLAccount', entitySetName: 'GLAccounts',
    from: 'gl_account t', readTables: ['gl_account'],
    fields: [
      F('No', 'code', 'Code', { key: true }), F('Name', 'name', 'Text'), F('IncomeBalance', 'type', 'Code'), F('AccountType', 'account_type', 'Code'),
      F('Totaling', 'totaling', 'Text'), F('ParentNo', 'parent_code', 'Code'), F('Indentation', 'indentation', 'Integer'),
      F('DirectPosting', 'CASE WHEN t.no_direct_posting = 1 THEN 0 ELSE 1 END', 'Boolean'), F('Balance', 'balance', 'Money'), F('Blocked', "CASE WHEN t.status = 'ACTIVE' THEN 0 ELSE 1 END", 'Boolean'),
    ].map((f) => ({ ...f, readOnly: true })),
  },
  {
    kind: 'PAGE', id: 50107, name: 'Item Card', caption: 'Items', entityName: 'Item', entitySetName: 'Items',
    from: 'item t', readTables: ['item'],
    fields: [
      F('No', 'no', 'Code', { key: true }), F('Description', 'description', 'Text'), F('Description2', 'description_2', 'Text'),
      F('CostingMethod', 'costing_method', 'Code'), F('UnitCost', 'unit_cost', 'Money'), F('UnitPrice', 'unit_price', 'Money'), F('Inventory', 'inventory', 'Integer'),
      F('ReorderingPolicy', 'reordering_policy', 'Code'), F('ReorderPoint', 'reorder_point', 'Integer'), F('ReorderQuantity', 'reorder_quantity', 'Integer'), F('MaximumInventory', 'maximum_inventory', 'Integer'),
      F('Status', 'status', 'Code'),
    ].map((f) => ({ ...f, readOnly: true })),
  },
  {
    kind: 'PAGE', id: 50108, name: 'Fixed Asset Card', caption: 'Fixed Assets', entityName: 'FixedAsset', entitySetName: 'FixedAssets',
    from: 'fixed_asset t', readTables: ['fixed_asset'],
    fields: [
      F('No', 'no', 'Code', { key: true }), F('Description', 'description', 'Text'), F('Description2', 'description_2', 'Text'),
      F('FAClassCode', 'fa_class_code', 'Code'), F('FASubclassCode', 'fa_subclass_code', 'Code'), F('FALocationCode', 'fa_location_code', 'Code'),
      F('ResponsibleEmployee', 'responsible_employee', 'Code'), F('SerialNo', 'serial_no', 'Code'), F('VendorName', 'vendor_name', 'Text'), F('AssetTag', 'asset_tag', 'Code'),
      F('AcquisitionDate', 'acquisition_date', 'Date'), F('DisposalDate', 'disposal_date', 'Date'), F('Blocked', 'blocked', 'Boolean'), F('Inactive', 'inactive', 'Boolean'),
    ].map((f) => ({ ...f, readOnly: true })),
  },
  {
    kind: 'PAGE', id: 50109, name: 'Company Job Card', caption: 'Company Jobs', entityName: 'CompanyJob', entitySetName: 'CompanyJobs',
    from: `(SELECT j.*, p.job_id AS reports_to_job_code,
                   (SELECT COUNT(*) FROM employee e WHERE e.company_job_id = j.id AND e.status IN ('ACTIVE','ON_LEAVE')) AS occupied
            FROM company_job j LEFT JOIN company_job p ON p.id = j.reports_to_job_id) t`,
    readTables: ['company_job'],
    fields: [
      F('No', 'job_id', 'Code', { key: true }), F('Name', 'name', 'Text'), F('Objective', 'objective', 'Text'), F('ReportsToJobNo', 'reports_to_job_code', 'Code'),
      F('NoOfPosts', 'no_of_posts', 'Integer'), F('Occupied', 'occupied', 'Integer'), F('Vacant', 'GREATEST(t.no_of_posts - t.occupied, 0)', 'Integer'),
      F('IsManagement', 'is_management', 'Boolean'), F('Profession', 'profession', 'Text'), F('Status', 'status', 'Code'),
    ].map((f) => ({ ...f, readOnly: true })),
  },
  {
    kind: 'PAGE', id: 50110, name: 'Savings Product Card', caption: 'Savings Products', entityName: 'SavingsProduct', entitySetName: 'SavingsProducts',
    from: 'savings_product t', readTables: ['savings_product'],
    fields: [
      F('Code', 'code', 'Code', { key: true }), F('Name', 'name', 'Text'), F('Category', 'category', 'Code'),
      F('MinBalance', 'min_balance', 'Money'), F('MinOpening', 'min_opening', 'Money'), F('InterestRate', 'interest_rate', 'Decimal'),
      F('AllowWithdrawal', 'allow_withdrawal', 'Boolean'), F('WithdrawalFee', 'withdrawal_fee', 'Money'), F('AllowTransfer', 'allow_transfer', 'Boolean'), F('Status', 'status', 'Code'),
    ].map((f) => ({ ...f, readOnly: true })),
  },
  {
    kind: 'PAGE', id: 50111, name: 'Loan Product Card', caption: 'Loan Products', entityName: 'LoanProduct', entitySetName: 'LoanProducts',
    from: 'loan_product t', readTables: ['loan_product'],
    fields: [
      F('Code', 'code', 'Code', { key: true }), F('Name', 'name', 'Text'), F('InterestRate', 'interest_rate', 'Decimal'), F('InterestMethod', 'interest_method', 'Code'),
      F('MaxTermMonths', 'max_term_months', 'Integer'), F('MinAmount', 'min_amount', 'Money'), F('MaxAmount', 'max_amount', 'Money'),
      F('DepositMultiplier', 'deposit_multiplier', 'Decimal'), F('PenaltyRate', 'penalty_rate', 'Decimal'), F('GuarantorsRequired', 'guarantors_required', 'Integer'), F('Status', 'status', 'Code'),
    ].map((f) => ({ ...f, readOnly: true })),
  },
];

/* ------------------------------------------------------------------------------ queries */

export const QUERIES: WsQuery[] = [
  {
    kind: 'QUERY', id: 50200, name: 'Trial Balance', caption: 'Trial Balance', entityName: 'TrialBalanceLine', entitySetName: 'TrialBalance',
    from: `(SELECT g.code, g.name, g.type, g.account_type,
                   COALESCE(SUM(jl.debit_lcy), 0) AS debits, COALESCE(SUM(jl.credit_lcy), 0) AS credits,
                   COALESCE(SUM(jl.debit_lcy), 0) - COALESCE(SUM(jl.credit_lcy), 0) AS net
            FROM gl_account g LEFT JOIN journal_line jl ON jl.gl_account_id = g.id
            WHERE g.is_postable = 1 GROUP BY g.id, g.code, g.name, g.type, g.account_type) t`,
    readTables: ['gl_account', 'journal_line'],
    fields: [
      F('AccountNo', 'code', 'Code', { key: true }), F('AccountName', 'name', 'Text'), F('IncomeBalance', 'type', 'Code'), F('AccountType', 'account_type', 'Code'),
      F('Debits', 'debits', 'Money'), F('Credits', 'credits', 'Money'), F('NetBalance', 'net', 'Money'),
    ].map((f) => ({ ...f, readOnly: true })),
  },
  {
    kind: 'QUERY', id: 50201, name: 'Member Balances', caption: 'Member Balances', entityName: 'MemberBalance', entitySetName: 'MemberBalances',
    from: `(SELECT m.member_no, m.first_name || ' ' || m.last_name AS member_name, m.status, m.phone,
                   COALESCE((SELECT SUM(a.balance) FROM savings_account a WHERE a.member_id = m.id AND a.status <> 'CLOSED'), 0) AS deposits,
                   COALESCE((SELECT SUM(l.principal_balance + l.interest_balance + l.penalty_balance) FROM loan l WHERE l.member_id = m.id AND l.status = 'DISBURSED'), 0) AS loans_outstanding,
                   (SELECT COUNT(*) FROM savings_account a WHERE a.member_id = m.id AND a.status <> 'CLOSED') AS accounts,
                   (SELECT COUNT(*) FROM loan l WHERE l.member_id = m.id AND l.status = 'DISBURSED') AS active_loans
            FROM member m) t`,
    readTables: ['member', 'savings_account', 'loan'],
    fields: [
      F('MemberNo', 'member_no', 'Code', { key: true }), F('MemberName', 'member_name', 'Text'), F('Status', 'status', 'Code'), F('Phone', 'phone', 'Text'),
      F('Deposits', 'deposits', 'Money'), F('LoansOutstanding', 'loans_outstanding', 'Money'), F('NetPosition', 't.deposits - t.loans_outstanding', 'Money'),
      F('Accounts', 'accounts', 'Integer'), F('ActiveLoans', 'active_loans', 'Integer'),
    ].map((f) => ({ ...f, readOnly: true })),
  },
  {
    kind: 'QUERY', id: 50202, name: 'G/L Entries', caption: 'G/L Entries', entityName: 'GLEntry', entitySetName: 'GLEntries',
    from: `(SELECT jl.id, j.journal_no, j.value_date, j.posted_at, j.source_module, j.event_type, j.description AS journal_description, j.reference,
                   g.code AS account_no, g.name AS account_name, jl.debit_lcy, jl.credit_lcy, jl.debit_lcy - jl.credit_lcy AS amount, jl.narration,
                   d1.code AS global_dimension_1_code, d2.code AS global_dimension_2_code, j.posted_by
            FROM journal_line jl JOIN journal j ON j.id = jl.journal_id JOIN gl_account g ON g.id = jl.gl_account_id
            LEFT JOIN global_dimension_1_value d1 ON d1.id = jl.global_dimension_1_id LEFT JOIN global_dimension_2_value d2 ON d2.id = jl.global_dimension_2_id) t`,
    readTables: ['journal', 'journal_line', 'gl_account'],
    fields: [
      F('EntryNo', 'id', 'Integer', { key: true }), F('DocumentNo', 'journal_no', 'Code'), F('PostingDate', 'value_date', 'Date'), F('PostedAt', 'posted_at', 'DateTime'),
      F('SourceModule', 'source_module', 'Code'), F('EventType', 'event_type', 'Code'), F('Description', 'journal_description', 'Text'), F('ExternalDocumentNo', 'reference', 'Code'),
      F('GLAccountNo', 'account_no', 'Code'), F('GLAccountName', 'account_name', 'Text'),
      F('DebitAmount', 'debit_lcy', 'Money'), F('CreditAmount', 'credit_lcy', 'Money'), F('Amount', 'amount', 'Money'), F('Narration', 'narration', 'Text'),
      F('GlobalDimension1Code', 'global_dimension_1_code', 'Code'), F('GlobalDimension2Code', 'global_dimension_2_code', 'Code'), F('UserId', 'posted_by', 'Code'),
    ].map((f) => ({ ...f, readOnly: true })),
  },
  {
    kind: 'QUERY', id: 50203, name: 'Loan Arrears', caption: 'Loans in Arrears', entityName: 'LoanArrear', entitySetName: 'LoanArrears',
    from: `(SELECT l.loan_no, m.member_no, m.first_name || ' ' || m.last_name AS member_name, m.phone, p.name AS product_name,
                   l.principal_balance + l.interest_balance + l.penalty_balance AS outstanding, l.arrears_amount, l.days_in_arrears, l.classification, l.installment
            FROM loan l JOIN member m ON m.id = l.member_id JOIN loan_product p ON p.id = l.product_id WHERE l.days_in_arrears > 0) t`,
    readTables: ['loan', 'member'],
    fields: [
      F('LoanNo', 'loan_no', 'Code', { key: true }), F('MemberNo', 'member_no', 'Code'), F('MemberName', 'member_name', 'Text'), F('Phone', 'phone', 'Text'), F('ProductName', 'product_name', 'Text'),
      F('Outstanding', 'outstanding', 'Money'), F('ArrearsAmount', 'arrears_amount', 'Money'), F('DaysInArrears', 'days_in_arrears', 'Integer'), F('Classification', 'classification', 'Code'), F('Installment', 'installment', 'Money'),
    ].map((f) => ({ ...f, readOnly: true })),
  },
];

/* ------------------------------------------------------------------------------ codeunits */

const P = (name: string, type: WsType, required = true) => ({ name, type, required });

export const CODEUNITS: WsCodeunit[] = [
  {
    kind: 'CODEUNIT', id: 50300, name: 'Sacco Integration', caption: 'Sacco Integration',
    procedures: [
      {
        name: 'GetMemberBalance', caption: 'Total deposits held by a member', params: [P('memberNo', 'Code')], returns: 'Decimal', action: 'SAVINGS_READ',
        run: async ({ memberNo }) => {
          const id = await idOf('member', 'member_no', memberNo, 'Member');
          const r = await one<{ s: number }>("SELECT COALESCE(SUM(balance), 0) AS s FROM savings_account WHERE member_id = ? AND status <> 'CLOSED'", id);
          return Number(r?.s ?? 0) / 100;
        },
      },
      {
        name: 'GetAccountBalance', caption: 'Balance and available balance of a savings account', params: [P('accountNo', 'Code')], returns: 'Json', action: 'SAVINGS_READ',
        run: async ({ accountNo }) => {
          const a = await one<{ account_no: string; balance: number; hold_amount: number; status: string; member_no: string }>(
            'SELECT a.account_no, a.balance, a.hold_amount, a.status, m.member_no FROM savings_account a JOIN member m ON m.id = a.member_id WHERE a.account_no = ?', String(accountNo ?? '').trim());
          if (!a) throw new AppError(`Account ${String(accountNo ?? '')} not found`, 'NOT_FOUND');
          return { accountNo: a.account_no, memberNo: a.member_no, status: a.status, balance: Number(a.balance) / 100, holdAmount: Number(a.hold_amount) / 100, availableBalance: (Number(a.balance) - Number(a.hold_amount)) / 100 };
        },
      },
      {
        name: 'GetLoanBalance', caption: 'Outstanding balance of a loan', params: [P('loanNo', 'Code')], returns: 'Json', action: 'LOAN_READ',
        run: async ({ loanNo }) => {
          const l = await one<Record<string, number | string>>('SELECT loan_no, status, principal_balance, interest_balance, penalty_balance, arrears_amount, days_in_arrears, installment FROM loan WHERE loan_no = ?', String(loanNo ?? '').trim());
          if (!l) throw new AppError(`Loan ${String(loanNo ?? '')} not found`, 'NOT_FOUND');
          const c = (v: unknown) => Number(v ?? 0) / 100;
          return {
            loanNo: l.loan_no, status: l.status, principalBalance: c(l.principal_balance), interestBalance: c(l.interest_balance), penaltyBalance: c(l.penalty_balance),
            outstandingBalance: c(Number(l.principal_balance) + Number(l.interest_balance) + Number(l.penalty_balance)),
            arrearsAmount: c(l.arrears_amount), daysInArrears: Number(l.days_in_arrears), installment: c(l.installment),
          };
        },
      },
      {
        name: 'FindMember', caption: 'Look a member up by national ID or phone', params: [P('identificationNo', 'Code', false), P('phone', 'Text', false)], returns: 'Json', action: 'MEMBERS_READ',
        run: async ({ identificationNo, phone }) => {
          const idNo = str(identificationNo); const ph = str(phone);
          if (!idNo && !ph) throw new AppError('Give identificationNo or phone', 'VALIDATION');
          const m = await one<Record<string, unknown>>(
            `SELECT member_no, first_name, middle_name, last_name, status, phone, email, identification_no FROM member
             WHERE ${idNo ? 'identification_no = ?' : 'phone = ?'} ORDER BY id LIMIT 1`, idNo ?? ph);
          if (!m) return null;
          return { memberNo: m.member_no, name: [m.first_name, m.middle_name, m.last_name].filter(Boolean).join(' '), status: m.status, phone: m.phone, email: m.email, identificationNo: m.identification_no };
        },
      },
      {
        name: 'PostDeposit', caption: 'Credit a savings account (a bank, M-Pesa or check-off receipt)',
        params: [P('accountNo', 'Code'), P('amount', 'Decimal'), P('reference', 'Code'), P('description', 'Text', false), P('channel', 'Code', false)],
        returns: 'Json', action: 'SAVINGS_DEPOSIT',
        run: async ({ accountNo, amount, reference, description, channel }, ctx) => {
          const accountId = await idOf('savings_account', 'account_no', accountNo, 'Account');
          const ch = (String(channel ?? 'BANK').toUpperCase()) as Channel;
          if (!['BANK', 'MPESA', 'CHECKOFF', 'SYSTEM'].includes(ch)) throw new AppError('channel must be BANK, MPESA or CHECKOFF', 'VALIDATION');
          const ref = str(reference);
          if (!ref) throw new AppError('reference is required — it makes the posting idempotent', 'VALIDATION');
          const res = await deposit({
            accountId, amount: cents(amount), channel: ch, reference: ref, user: ctx.actor,
            description: str(description) ?? `Web service deposit ${ref}`, idempotencyKey: `WS-DEP-${accountNo}-${ref}`,
          });
          return { transactionNo: res.txn.txn_ref, accountNo, amount: Number(amount), balance: Number(res.balance) / 100 };
        },
      },
      {
        name: 'PostWithdrawal', caption: 'Debit a savings account (a bank or M-Pesa payout)',
        params: [P('accountNo', 'Code'), P('amount', 'Decimal'), P('reference', 'Code'), P('description', 'Text', false), P('channel', 'Code', false)],
        returns: 'Json', action: 'SAVINGS_WITHDRAW',
        run: async ({ accountNo, amount, reference, description, channel }, ctx) => {
          const accountId = await idOf('savings_account', 'account_no', accountNo, 'Account');
          const ch = (String(channel ?? 'BANK').toUpperCase()) as Channel;
          if (!['BANK', 'MPESA', 'SYSTEM'].includes(ch)) throw new AppError('channel must be BANK or MPESA', 'VALIDATION');
          const ref = str(reference);
          if (!ref) throw new AppError('reference is required — it makes the posting idempotent', 'VALIDATION');
          const res = await withdraw({
            accountId, amount: cents(amount), channel: ch, user: ctx.actor,
            description: str(description) ?? `Web service withdrawal ${ref}`, idempotencyKey: `WS-WDR-${accountNo}-${ref}`,
          });
          return { transactionNo: res.txn.txn_ref, accountNo, amount: Number(amount), balance: Number(res.balance) / 100 };
        },
      },
    ],
  },
  {
    kind: 'CODEUNIT', id: 50301, name: 'System Service', caption: 'System Service',
    procedures: [
      {
        name: 'Companies', caption: 'The companies on this server', params: [], returns: 'Json',
        run: async () => {
          const org = await one<{ name: string; short_name: string | null }>('SELECT name, short_name FROM organisation LIMIT 1').catch(() => undefined);
          return [org?.name ?? 'SACCO'];
        },
      },
      {
        name: 'Ping', caption: 'Connectivity and authentication check', params: [], returns: 'Json',
        run: async (_a, ctx) => ({ ok: true, user: ctx.user.username, serverTime: new Date().toISOString() }),
      },
    ],
  },
];

export const ALL_OBJECTS: WsObject[] = [...PAGES, ...QUERIES, ...CODEUNITS, CHANNELS_INTEGRATION];

export function findObject(type: WebServiceObjectType, id: number): WsObject | undefined {
  return ALL_OBJECTS.find((o) => o.kind === type && o.id === id);
}

/** The key field of a page or query. */
export const keyField = (o: WsPage | WsQuery): WsField => o.fields.find((f) => f.key) ?? o.fields[0];

/** Fetch every row a SELECT * of the object's FROM produces — for a codeunit or a test. */
export const rawRows = (o: WsPage | WsQuery): Promise<Record<string, unknown>[]> => all(`SELECT * FROM ${o.from}`);
