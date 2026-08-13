'use client';

import { useState } from 'react';
import { FormModal } from '@/components/ui/form-modal';
import { Field } from '@/components/ui/field';
import { saveWorkflow } from '@/app/actions/workflows';
import {
  DOCUMENT_FIELDS, DOCUMENT_TYPE_LABELS, CONDITION_OPERATORS, APPROVER_TYPES,
} from '@/lib/workflowConstants';
import { PRODUCT_STATUSES } from '@/lib/constants';
import type {
  UserListRow, WorkflowUserGroupWithUsage, WorkflowWithDetail, WorkflowDocumentType,
  WorkflowConditionOperator, WorkflowApproverType,
} from '@/lib/types';

const DOCUMENT_TYPES = Object.keys(DOCUMENT_TYPE_LABELS) as WorkflowDocumentType[];

interface ConditionRow {
  field: string;
  operator: WorkflowConditionOperator;
  value: string;
  value2: string;
}

interface StepRow {
  approver_type: WorkflowApproverType;
  approver_user_id: number | '';
  approver_group_id: number | '';
  notify_email: boolean;
}

const emptyCondition = (documentType: WorkflowDocumentType): ConditionRow => ({
  field: DOCUMENT_FIELDS[documentType][0]?.key || '', operator: '>', value: '', value2: '',
});
const emptyStep = (): StepRow => ({ approver_type: 'USER', approver_user_id: '', approver_group_id: '', notify_email: true });

export function WorkflowFormButton({ workflow, users, groups, className = 'btn', children }: {
  workflow?: WorkflowWithDetail | null;
  users: UserListRow[];
  groups: WorkflowUserGroupWithUsage[];
  className?: string;
  children: React.ReactNode;
}) {
  const [open, setOpen] = useState(false);
  const w = workflow ?? null;
  const [documentType, setDocumentType] = useState<WorkflowDocumentType>(w?.document_type || 'MEMBER_APPLICATION');
  const [conditions, setConditions] = useState<ConditionRow[]>(() =>
    (w?.conditions || []).map((c) => ({
      field: c.field, operator: c.operator, value: c.value, value2: c.value2 || '',
    })));
  const [steps, setSteps] = useState<StepRow[]>(() =>
    (w?.steps || []).map((s) => ({
      approver_type: s.approver_type,
      approver_user_id: s.approver_user_id || '',
      approver_group_id: s.approver_group_id || '',
      notify_email: !!s.notify_email,
    })));

  const updateCondition = (i: number, patch: Partial<ConditionRow>) =>
    setConditions((cur) => cur.map((r, k) => (k === i ? { ...r, ...patch } : r)));
  const removeCondition = (i: number) => setConditions((cur) => cur.filter((_, k) => k !== i));

  const updateStep = (i: number, patch: Partial<StepRow>) =>
    setSteps((cur) => cur.map((r, k) => (k === i ? { ...r, ...patch } : r)));
  const removeStep = (i: number) => setSteps((cur) => cur.filter((_, k) => k !== i));
  const moveStep = (i: number, dir: -1 | 1) =>
    setSteps((cur) => {
      const j = i + dir;
      if (j < 0 || j >= cur.length) return cur;
      const next = [...cur];
      [next[i], next[j]] = [next[j], next[i]];
      return next;
    });

  return (
    <>
      <button type="button" className={className} onClick={() => setOpen(true)}>{children}</button>
      {open ? (
        <FormModal
          wide
          title={w ? `Edit ${w.name}` : 'Add a workflow'}
          onClose={() => setOpen(false)}
          onSubmit={(values) => saveWorkflow(
            w ? w.id : null,
            values,
            conditions.filter((c) => c.field && c.value !== ''),
            steps.map((s) => ({
              approver_type: s.approver_type,
              approver_user_id: s.approver_user_id || null,
              approver_group_id: s.approver_group_id || null,
              notify_email: s.notify_email ? 1 : 0,
            })),
          )}
          submitLabel="Save workflow"
          successTitle="Workflow saved"
        >
          <div className="grid g3">
            <Field name="name" label="Workflow name" defaultValue={w?.name} required maxLength={80} />
            <Field name="document_type" label="Document type" type="select" required
              defaultValue={documentType}
              options={DOCUMENT_TYPES.map((t) => ({ value: t, label: DOCUMENT_TYPE_LABELS[t] }))}
              onChange={(e) => setDocumentType(e.target.value as WorkflowDocumentType)} />
            {w ? (
              <Field name="status" label="Status" type="select" defaultValue={w.status} options={PRODUCT_STATUSES} />
            ) : null}
          </div>

          <h4 className="section-title">Conditions</h4>
          <div className="card-sub">
            All conditions must match for this workflow to apply — leave empty to apply to every submission.
          </div>
          <table style={{ marginTop: 8 }}>
            <thead>
              <tr>
                <th>Field</th><th>Operator</th><th>Value</th><th>Value 2</th><th style={{ width: 40 }} />
              </tr>
            </thead>
            <tbody>
              {conditions.map((row, i) => (
                <tr key={i}>
                  <td>
                    <select value={row.field} aria-label="Field"
                      onChange={(e) => updateCondition(i, { field: e.target.value })}>
                      {DOCUMENT_FIELDS[documentType].map((f) => (
                        <option key={f.key} value={f.key}>{f.label}</option>
                      ))}
                    </select>
                  </td>
                  <td>
                    <select value={row.operator} aria-label="Operator"
                      onChange={(e) => updateCondition(i, { operator: e.target.value as WorkflowConditionOperator })}>
                      {CONDITION_OPERATORS.map((o) => <option key={o.value} value={o.value}>{o.label}</option>)}
                    </select>
                  </td>
                  <td>
                    <input type="text" value={row.value} aria-label="Value"
                      onChange={(e) => updateCondition(i, { value: e.target.value })} />
                  </td>
                  <td>
                    {row.operator === 'BETWEEN' ? (
                      <input type="text" value={row.value2} aria-label="Value 2"
                        onChange={(e) => updateCondition(i, { value2: e.target.value })} />
                    ) : null}
                  </td>
                  <td>
                    <button type="button" className="btn sm ghost" onClick={() => removeCondition(i)}
                      aria-label="Remove condition">×</button>
                  </td>
                </tr>
              ))}
              {!conditions.length ? <tr><td colSpan={5} className="tiny">Applies to every submission.</td></tr> : null}
            </tbody>
          </table>
          <div className="inline" style={{ marginTop: 10 }}>
            <button type="button" className="btn ghost sm" onClick={() => setConditions((c) => [...c, emptyCondition(documentType)])}>
              Add condition
            </button>
          </div>

          <h4 className="section-title">Approval steps</h4>
          <div className="card-sub">Executed in order — every step must approve before the document is finalised.</div>
          <table style={{ marginTop: 8 }}>
            <thead>
              <tr>
                <th style={{ width: 30 }}>#</th><th>Approver type</th><th>Approver</th>
                <th style={{ width: 90 }}>Email</th><th style={{ width: 90 }} />
              </tr>
            </thead>
            <tbody>
              {steps.map((row, i) => (
                <tr key={i}>
                  <td className="num">{i + 1}</td>
                  <td>
                    <select value={row.approver_type} aria-label="Approver type"
                      onChange={(e) => updateStep(i, { approver_type: e.target.value as WorkflowApproverType })}>
                      {APPROVER_TYPES.map((t) => <option key={t.value} value={t.value}>{t.label}</option>)}
                    </select>
                  </td>
                  <td>
                    {row.approver_type === 'USER' ? (
                      <select value={row.approver_user_id} aria-label="User"
                        onChange={(e) => updateStep(i, { approver_user_id: e.target.value ? Number(e.target.value) : '' })}>
                        <option value="">Select user…</option>
                        {users.map((u) => <option key={u.id} value={u.id}>{u.full_name}</option>)}
                      </select>
                    ) : row.approver_type === 'USER_GROUP' ? (
                      <select value={row.approver_group_id} aria-label="Group"
                        onChange={(e) => updateStep(i, { approver_group_id: e.target.value ? Number(e.target.value) : '' })}>
                        <option value="">Select group…</option>
                        {groups.map((g) => <option key={g.id} value={g.id}>{g.name}</option>)}
                      </select>
                    ) : (
                      <span className="tiny">Resolved from Approval User Setup at request time</span>
                    )}
                  </td>
                  <td>
                    <div className="checkline">
                      <input type="checkbox" checked={row.notify_email} aria-label="Notify by email"
                        onChange={(e) => updateStep(i, { notify_email: e.target.checked })} />
                    </div>
                  </td>
                  <td className="num">
                    <button type="button" className="btn sm ghost" onClick={() => moveStep(i, -1)} disabled={i === 0} aria-label="Move up">↑</button>{' '}
                    <button type="button" className="btn sm ghost" onClick={() => moveStep(i, 1)} disabled={i === steps.length - 1} aria-label="Move down">↓</button>{' '}
                    <button type="button" className="btn sm ghost" onClick={() => removeStep(i)} aria-label="Remove step">×</button>
                  </td>
                </tr>
              ))}
              {!steps.length ? <tr><td colSpan={5} className="tiny">Add at least one step for this workflow to route anything.</td></tr> : null}
            </tbody>
          </table>
          <div className="inline" style={{ marginTop: 10 }}>
            <button type="button" className="btn ghost sm" onClick={() => setSteps((s) => [...s, emptyStep()])}>
              Add step
            </button>
          </div>
        </FormModal>
      ) : null}
    </>
  );
}
