'use client';

import { useState } from 'react';
import { FormModal } from '@/components/ui/form-modal';
import { saveWorkflowTableRelationFields } from '@/app/actions/workflows';
import type { WorkflowDocumentType, WorkflowTableRelationWithFields } from '@/lib/types';

const humanize = (identifier: string): string => identifier
  .replace(/_id$/, '')
  .replace(/_/g, ' ')
  .replace(/\b\w/g, (c) => c.toUpperCase());

/** Global dimension columns are labeled with the org's own dimension captions (e.g. "Branch",
 *  "Cost Centre") rather than the generic column name, matching workflow-form.tsx's condition
 *  field labels. */
const DIMENSION_COLUMNS: Record<string, 'dimensionCaption1' | 'dimensionCaption2'> = {
  global_dimension_1_id: 'dimensionCaption1',
  global_dimension_2_id: 'dimensionCaption2',
};

export function WorkflowTableRelationFormButton({
  documentType, documentTypeLabel, tableName, relation, availableColumns,
  dimensionCaption1 = 'Global Dimension 1', dimensionCaption2 = 'Global Dimension 2',
  className = 'btn sm ghost', children,
}: {
  documentType: WorkflowDocumentType;
  documentTypeLabel: string;
  tableName: string;
  relation: WorkflowTableRelationWithFields | null;
  /** Real, not-yet-enabled columns of `tableName` — for LOAN/JOURNAL this is already capped
   *  server-side to the fields their submission code actually evaluates. */
  availableColumns: string[];
  /** The org's own labels for the two global dimension slots — falls back to the generic
   *  name if the caller doesn't have them on hand. */
  dimensionCaption1?: string;
  dimensionCaption2?: string;
  className?: string;
  children: React.ReactNode;
}) {
  const [open, setOpen] = useState(false);
  const [fields, setFields] = useState<string[]>(() => (relation?.fields ?? []).map((f) => f.field_name));
  const [picked, setPicked] = useState('');

  const captions = { dimensionCaption1, dimensionCaption2 };
  const fieldLabel = (name: string) => {
    const captionKey = DIMENSION_COLUMNS[name];
    return captionKey ? captions[captionKey] : humanize(name);
  };

  const remaining = availableColumns.filter((c) => !fields.includes(c));

  const addField = () => {
    if (!picked) return;
    setFields((cur) => [...cur, picked].sort((a, b) => a.localeCompare(b)));
    setPicked('');
  };
  const removeField = (name: string) => setFields((cur) => cur.filter((f) => f !== name));

  return (
    <>
      <button type="button" className={className} onClick={() => setOpen(true)}>{children}</button>
      {open ? (
        <FormModal
          title={`${documentTypeLabel} — condition fields`}
          onClose={() => setOpen(false)}
          onSubmit={() => saveWorkflowTableRelationFields(documentType, fields)}
          submitLabel="Save fields"
          successTitle="Table relation saved"
        >
          <div className="card-sub">
            Table: <span className="mono">{tableName}</span>. Fields enabled here are what a workflow's
            condition lines for {documentTypeLabel} may route approvals on.
          </div>

          <div className="inline" style={{ marginTop: 8 }}>
            <select
              value={picked} aria-label="Field to add" style={{ flex: 1 }}
              onChange={(e) => setPicked(e.target.value)}
            >
              <option value="">Select a field…</option>
              {remaining.map((c) => <option key={c} value={c}>{fieldLabel(c)} ({c})</option>)}
            </select>
            <button type="button" className="btn sm" disabled={!picked} onClick={addField}>Add field</button>
          </div>
          {!remaining.length && !fields.length ? (
            <div className="tiny" style={{ marginTop: 4 }}>
              No columns are available to add — LOAN and JOURNAL are capped to the fields their
              submission flow actually evaluates.
            </div>
          ) : null}

          <table style={{ marginTop: 10 }}>
            <thead>
              <tr><th>Field</th><th style={{ width: 40 }} /></tr>
            </thead>
            <tbody>
              {fields.map((name) => (
                <tr key={name}>
                  <td>{fieldLabel(name)} <span className="tiny mono">({name})</span></td>
                  <td>
                    <button type="button" className="btn sm ghost" onClick={() => removeField(name)}
                      aria-label={`Remove ${name}`}>×</button>
                  </td>
                </tr>
              ))}
              {!fields.length ? (
                <tr><td colSpan={2} className="tiny">No fields enabled — this document type's workflows can't have conditions yet.</td></tr>
              ) : null}
            </tbody>
          </table>
        </FormModal>
      ) : null}
    </>
  );
}
