/*
 * Plain constants shared by both the server-only workflow engine (lib/workflow.ts)
 * and client-side admin forms (app/admin/workflow-form.tsx). Kept in their own
 * module with no database or mailer imports so a 'use client' component can
 * pull these in without dragging lib/db.ts / lib/mailer.ts into the browser
 * bundle (mailer.ts is 'server-only' and Next.js fails the build otherwise).
 */
import type { WorkflowApproverType, WorkflowConditionOperator, WorkflowDocumentType } from './types.ts';

export interface DocumentFieldDef { key: string; label: string }

/** The fields each document type exposes to a workflow's conditions — kept as a
 *  small hardcoded catalogue rather than reflecting the table, since only a few
 *  fields make sense to route approvals on. */
export const DOCUMENT_FIELDS: Record<WorkflowDocumentType, DocumentFieldDef[]> = {
  MEMBER_APPLICATION: [
    { key: 'gross_income', label: 'Gross income (cents)' },
    { key: 'other_deductions', label: 'Other deductions (cents)' },
    { key: 'member_category_id', label: 'Member category (id)' },
    { key: 'global_dimension_1_id', label: 'Global Dimension 1 (id)' },
    { key: 'global_dimension_2_id', label: 'Global Dimension 2 (id)' },
    { key: 'county_id', label: 'County (id)' },
  ],
  LOAN: [
    { key: 'principal', label: 'Principal (cents)' },
    { key: 'product_id', label: 'Loan product (id)' },
    { key: 'term_months', label: 'Term (months)' },
  ],
  JOURNAL: [
    { key: 'amount', label: 'Amount (cents)' },
    { key: 'global_dimension_1_id', label: 'Global Dimension 1 (id)' },
    { key: 'global_dimension_2_id', label: 'Global Dimension 2 (id)' },
  ],
};

export const DOCUMENT_TYPE_LABELS: Record<WorkflowDocumentType, string> = {
  MEMBER_APPLICATION: 'Member Application',
  LOAN: 'Loan',
  JOURNAL: 'Journal',
};

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
  LOAN: (id) => `/loans/${id}`,
  JOURNAL: () => '/approvals',
};

export function documentLabel(documentType: WorkflowDocumentType, entityId: string): string {
  return `${DOCUMENT_TYPE_LABELS[documentType]} ${entityId}`;
}
