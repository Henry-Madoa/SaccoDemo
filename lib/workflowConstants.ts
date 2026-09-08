/*
 * Plain constants shared by both the server-only workflow engine (lib/workflow.ts)
 * and client-side admin forms (app/admin/workflow-form.tsx). Kept in their own
 * module with no database or mailer imports so a 'use client' component can
 * pull these in without dragging lib/db.ts / lib/mailer.ts into the browser
 * bundle (mailer.ts is 'server-only' and Next.js fails the build otherwise).
 */
import type { WorkflowApproverType, WorkflowConditionOperator, WorkflowDocumentType } from './types.ts';

/** Keys into the option lists a workflow-form.tsx caller supplies (see `RelationOptions`
 *  there) — lets a condition field that stores a foreign key render a picklist of the
 *  actual related rows instead of asking the admin to type a raw id. */
export type DocumentFieldRelation = 'memberCategory' | 'county' | 'globalDimension1' | 'globalDimension2' | 'loanProduct';

/** A condition field as shown in the admin UI — `label` and `relation` are read off the
 *  real table/column metadata by `listConditionFieldDefs()` in lib/workflow.ts, not hand-typed. */
export interface DocumentFieldDef { key: string; label: string; relation?: DocumentFieldRelation }

/** The DB table backing each document type — the parent row `listWorkflowTableRelations()`
 *  registers per document type, and what `listConditionFieldDefs()` introspects for columns
 *  and foreign keys. Never admin-editable: it's the only table the document's own submission
 *  code (lib/memberApplications.ts, lib/loanService.ts, lib/gl.ts) actually fetches condition
 *  values from, so letting it be freely set would let an admin configure fields that silently
 *  never match. Which of that table's columns are actually enabled for conditioning is the
 *  admin-managed part — see Admin Centre → Workflow Management → Table Relations. */
export const DOCUMENT_TABLE: Record<WorkflowDocumentType, string> = {
  MEMBER_APPLICATION: 'member_application',
  MEMBER_EDIT: 'member_edit_request',
  LOAN: 'loan',
  JOURNAL: 'journal',
  ACCOUNT_OPENING: 'account_opening_request',
  ACCOUNT_DEACTIVATION: 'account_deactivation_request',
  ACCOUNT_ACTIVATION: 'account_activation_request',
  MEMBER_ACTIVATION: 'member_activation_request',
  MEMBER_READMISSION: 'member_readmission_request',
  STANDING_ORDER: 'standing_order',
  COLLATERAL_APPLICATION: 'collateral_application',
  COLLATERAL_RELEASE: 'collateral_release',
  GUARANTOR_CHANGE: 'loan_guarantor_change',
  MEMBER_EXIT: 'member_exit',
  CHECKOFF_BATCH: 'checkoff_batch',
  FIXED_DEPOSIT: 'member_fixed_deposit',
  FOSA_TRANSACTION: 'fosa_transaction',
  TELLER_TRANSACTION: 'teller_transaction',
  MEMBER_LIEN: 'member_lien',
  INTER_ACCOUNT_TRANSFER: 'inter_account_transfer',
  BANKERS_CHEQUE: 'bankers_cheque',
  CHEQUE_DEPOSIT: 'cheque_deposit',
  ITEM_JOURNAL: 'item_journal_line',
  FA_JOURNAL: 'fa_journal_line',
  SALES_DOCUMENT: 'sales_header',
  CASH_RECEIPT: 'cash_receipt_header',
  REMINDER: 'reminder_header',
  PURCHASE_DOCUMENT: 'purchase_header',
  PAYMENT_JOURNAL: 'payment_journal_header',
  RECEIPT: 'receipt_header',
  PAYMENT_VOUCHER: 'payment_voucher_header',
  EMPLOYEE_ONBOARDING: 'employee',
  EMPLOYEE_EDIT: 'employee_edit_request',
  EMPLOYEE_CONTRACT_CHANGE: 'employee_contract_change',
  EMPLOYEE_EXIT: 'employee_exit',
  LEAVE_APPLICATION: 'hr_leave_application',
  LEAVE_ADJUSTMENT: 'hr_leave_adjustment',
  LEAVE_RECALL: 'hr_leave_recall',
  LEAVE_PLAN: 'hr_leave_plan',
  PAYROLL_PERIOD: 'payroll_period',
};

export const DOCUMENT_TYPE_LABELS: Record<WorkflowDocumentType, string> = {
  MEMBER_APPLICATION: 'Member Application',
  MEMBER_EDIT: 'Member Detail Edit',
  LOAN: 'Loan',
  JOURNAL: 'Journal',
  ACCOUNT_OPENING: 'Account Opening',
  ACCOUNT_DEACTIVATION: 'Account Deactivation',
  ACCOUNT_ACTIVATION: 'Account Activation',
  MEMBER_ACTIVATION: 'Member Activation',
  MEMBER_READMISSION: 'Member Re-admission',
  STANDING_ORDER: 'Standing Order',
  COLLATERAL_APPLICATION: 'Collateral Application',
  COLLATERAL_RELEASE: 'Collateral Release',
  GUARANTOR_CHANGE: 'Guarantor Change',
  MEMBER_EXIT: 'Member Exit',
  CHECKOFF_BATCH: 'Checkoff Batch',
  FIXED_DEPOSIT: 'Fixed Deposit',
  FOSA_TRANSACTION: 'FOSA Cash Movement',
  TELLER_TRANSACTION: 'Teller Transaction',
  MEMBER_LIEN: 'Lien / Hold',
  INTER_ACCOUNT_TRANSFER: 'Inter Account Transfer',
  BANKERS_CHEQUE: 'Banker’s Cheque',
  CHEQUE_DEPOSIT: 'Cheque Deposit',
  ITEM_JOURNAL: 'Item Journal',
  FA_JOURNAL: 'Fixed Asset Journal',
  SALES_DOCUMENT: 'Sales Document',
  CASH_RECEIPT: 'Cash Receipt',
  REMINDER: 'Reminder / Finance Charge',
  PURCHASE_DOCUMENT: 'Purchase Document',
  PAYMENT_JOURNAL: 'Payment Journal',
  RECEIPT: 'Receipt',
  PAYMENT_VOUCHER: 'Payment Voucher',
  EMPLOYEE_ONBOARDING: 'Employee Onboarding',
  EMPLOYEE_EDIT: 'Employee Detail Edit',
  EMPLOYEE_CONTRACT_CHANGE: 'Employee Contract / Salary Change',
  EMPLOYEE_EXIT: 'Employee Exit',
  LEAVE_APPLICATION: 'Leave Application',
  LEAVE_ADJUSTMENT: 'Leave Adjustment',
  LEAVE_RECALL: 'Leave Recall',
  LEAVE_PLAN: 'Leave Plan',
  PAYROLL_PERIOD: 'Payroll Period',
};

const humanizeIdentifier = (identifier: string): string => identifier
  .replace(/_id$/, '')
  .replace(/_/g, ' ')
  .replace(/\b\w/g, (c) => c.toUpperCase());

/** A document type's display label: the curated business name for a wired type, or the
 *  humanized table name for any other document type returned by listDocumentTypeOptions(). */
export function documentTypeLabel(documentType: string): string {
  return DOCUMENT_TYPE_LABELS[documentType as WorkflowDocumentType] ?? humanizeIdentifier(documentType);
}

export const CONDITION_OPERATORS: { value: WorkflowConditionOperator; label: string }[] = [
  { value: '=', label: 'equals' },
  { value: '!=', label: 'does not equal' },
  { value: '>', label: 'greater than' },
  { value: '>=', label: 'greater than or equal to' },
  { value: '<', label: 'less than' },
  { value: '<=', label: 'less than or equal to' },
  { value: 'BETWEEN', label: 'between' },
];

export const APPROVER_TYPES: { value: WorkflowApproverType; label: string }[] = [
  { value: 'USER', label: 'Specific user' },
  { value: 'DIRECT_APPROVER', label: "Requester's approver" },
  { value: 'USER_GROUP', label: 'Workflow user group' },
];

export const DOCUMENT_LINK: Record<WorkflowDocumentType, (entityId: string) => string> = {
  MEMBER_APPLICATION: (id) => `/member-applications/view/${id}`,
  MEMBER_EDIT: (id) => `/member-edits/view/${id}`,
  LOAN: (id) => `/loans/view/${id}`,
  JOURNAL: () => '/approvals',
  ACCOUNT_OPENING: (id) => `/account-openings/view/${id}`,
  ACCOUNT_DEACTIVATION: (id) => `/account-deactivations/view/${id}`,
  ACCOUNT_ACTIVATION: (id) => `/account-activations/view/${id}`,
  MEMBER_ACTIVATION: (id) => `/member-activations/view/${id}`,
  MEMBER_READMISSION: (id) => `/member-readmissions/view/${id}`,
  STANDING_ORDER: (id) => `/standing-orders/view/${id}`,
  COLLATERAL_APPLICATION: (id) => `/collateral-applications/view/${id}`,
  COLLATERAL_RELEASE: (id) => `/collateral-releases/view/${id}`,
  GUARANTOR_CHANGE: (id) => `/guarantor-changes/view/${id}`,
  MEMBER_EXIT: (id) => `/member-exits/view/${id}`,
  CHECKOFF_BATCH: (id) => `/checkoff-batches/view/${id}`,
  FIXED_DEPOSIT: (id) => `/fixed-deposits/view/${id}`,
  FOSA_TRANSACTION: (id) => `/branch-cash/view/${id}`,
  TELLER_TRANSACTION: (id) => `/teller-transactions/view/${id}`,
  MEMBER_LIEN: (id) => `/liens/view/${id}`,
  INTER_ACCOUNT_TRANSFER: (id) => `/inter-account-transfers/view/${id}`,
  BANKERS_CHEQUE: (id) => `/bankers-cheques/view/${id}`,
  CHEQUE_DEPOSIT: (id) => `/cheque-deposits/view/${id}`,
  ITEM_JOURNAL: () => '/inventory/item-journal',
  FA_JOURNAL: () => '/fixed-assets/journal',
  SALES_DOCUMENT: () => '/receivables/sales-invoices',
  CASH_RECEIPT: () => '/receivables/cash-receipts',
  REMINDER: () => '/receivables/reminders',
  PURCHASE_DOCUMENT: () => '/payables/purchase-invoices',
  PAYMENT_JOURNAL: () => '/payables/payment-journal',
  RECEIPT: (id) => `/cash-management/receipts/${id}`,
  PAYMENT_VOUCHER: (id) => `/cash-management/payment-vouchers/${id}`,
  EMPLOYEE_ONBOARDING: (id) => `/employees/view/${id}`,
  EMPLOYEE_EDIT: (id) => `/employee-edits/view/${id}`,
  EMPLOYEE_CONTRACT_CHANGE: (id) => `/employee-contract-changes/view/${id}`,
  EMPLOYEE_EXIT: (id) => `/employee-exits/view/${id}`,
  LEAVE_APPLICATION: (id) => `/leave-applications/view/${id}`,
  LEAVE_ADJUSTMENT: (id) => `/leave-adjustments/view/${id}`,
  LEAVE_RECALL: (id) => `/leave-recalls/view/${id}`,
  LEAVE_PLAN: (id) => `/leave-plans/view/${id}`,
  PAYROLL_PERIOD: (id) => `/payroll/periods/view/${id}`,
};

export function documentLabel(documentType: WorkflowDocumentType, entityId: string): string {
  return `${DOCUMENT_TYPE_LABELS[documentType]} ${entityId}`;
}
