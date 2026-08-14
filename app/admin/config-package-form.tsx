'use client';

import { useEffect, useState } from 'react';
import { FormModal } from '@/components/ui/form-modal';
import { Field } from '@/components/ui/field';
import { saveConfigPackage, getConfigPackageColumns } from '@/app/actions/configPackages';
import type { ConfigPackageColumn, ConfigPackageTableOption, ConfigPackageWithFields } from '@/lib/types';

const humanize = (identifier: string): string => identifier
  .replace(/_id$/, '')
  .replace(/_/g, ' ')
  .replace(/\b\w/g, (c) => c.toUpperCase());

export function ConfigPackageFormButton({ pkg, tables, className = 'btn', children }: {
  pkg?: ConfigPackageWithFields | null;
  /** The live, denylist-filtered table dropdown — fetched once by the Admin Centre page. */
  tables: ConfigPackageTableOption[];
  className?: string;
  children: React.ReactNode;
}) {
  const [open, setOpen] = useState(false);
  const [tableName, setTableName] = useState(pkg?.table_name ?? '');
  const [columns, setColumns] = useState<ConfigPackageColumn[]>([]);
  const [fields, setFields] = useState<string[]>(() => (pkg?.fields ?? []).map((f) => f.field_name));
  const [keyField, setKeyField] = useState(pkg?.key_field ?? '');
  const [picked, setPicked] = useState('');
  const [loadingColumns, setLoadingColumns] = useState(false);

  // Loads the selected table's columns whenever it changes (or the modal opens on an existing
  // package) — the dropdown only carries table names, not every table's full column set.
  useEffect(() => {
    if (!open || !tableName) { setColumns([]); return; }
    let cancelled = false;
    setLoadingColumns(true);
    getConfigPackageColumns(tableName).then((res) => {
      if (cancelled) return;
      setColumns(res.ok ? res.data : []);
      setLoadingColumns(false);
    });
    return () => { cancelled = true; };
  }, [open, tableName]);

  const pickTable = (name: string) => {
    setTableName(name);
    if (name !== pkg?.table_name) { setFields([]); setKeyField(''); }
    setPicked('');
  };

  const remaining = columns.filter((c) => !fields.includes(c.name));
  const labelFor = (name: string) => columns.find((c) => c.name === name)?.label ?? humanize(name);

  const addField = () => {
    if (!picked) return;
    setFields((cur) => [...cur, picked]);
    setPicked('');
  };
  const removeField = (name: string) => {
    setFields((cur) => cur.filter((f) => f !== name));
    if (keyField === name) setKeyField('');
  };

  return (
    <>
      <button type="button" className={className} onClick={() => setOpen(true)}>{children}</button>
      {open ? (
        <FormModal
          wide
          title={pkg ? `Edit package — ${pkg.name}` : 'New configuration package'}
          onClose={() => setOpen(false)}
          onSubmit={(values) => saveConfigPackage(pkg?.code ?? null, values, fields)}
          submitLabel="Save"
          successTitle="Configuration package saved"
        >
          <div className="grid g3">
            {pkg ? (
              <div className="field">
                <label>Code</label>
                <div className="mono" style={{ padding: '6px 0' }}>{pkg.code}</div>
              </div>
            ) : (
              <Field name="code" label="Code" defaultValue="" required maxLength={30} uppercase
                hint="A short unique identifier, e.g. MEMBER-MIGRATE" />
            )}
            <Field name="name" label="Name" defaultValue={pkg?.name} required maxLength={100} />
            {pkg ? (
              <div className="field">
                <label>Table</label>
                <div className="mono" style={{ padding: '6px 0' }}>{pkg.table_name}</div>
              </div>
            ) : (
              <div className="field">
                <label>Table<span className="req"> *</span></label>
                <select name="table_name" value={tableName} required onChange={(e) => pickTable(e.target.value)}>
                  <option value="">Select a table…</option>
                  {tables.map((t) => <option key={t.table_name} value={t.table_name}>{t.label} ({t.table_name})</option>)}
                </select>
              </div>
            )}
          </div>

          {tableName ? (
            <>
              <div className="card-sub" style={{ marginTop: 8 }}>
                Fields included in this package's CSV export/import.
              </div>
              <div className="inline" style={{ marginTop: 8 }}>
                <select
                  value={picked} aria-label="Field to add" style={{ flex: 1 }}
                  disabled={loadingColumns} onChange={(e) => setPicked(e.target.value)}
                >
                  <option value="">{loadingColumns ? 'Loading fields…' : 'Select a field…'}</option>
                  {remaining.map((c) => (
                    <option key={c.name} value={c.name}>
                      {c.label} ({c.name}){c.relation_table ? ` → ${c.relation_table}` : ''}
                    </option>
                  ))}
                </select>
                <button type="button" className="btn sm" disabled={!picked} onClick={addField}>Add field</button>
              </div>

              <table style={{ marginTop: 10 }}>
                <thead>
                  <tr><th>Field</th><th style={{ width: 110 }}>Key field</th><th style={{ width: 40 }} /></tr>
                </thead>
                <tbody>
                  {fields.map((name) => (
                    <tr key={name}>
                      <td>{labelFor(name)} <span className="tiny mono">({name})</span></td>
                      <td>
                        <input
                          type="radio" name="_key_field_pick" aria-label={`Use ${name} as the key field`}
                          checked={keyField === name} onChange={() => setKeyField(name)}
                        />
                      </td>
                      <td>
                        <button type="button" className="btn sm ghost" onClick={() => removeField(name)}
                          aria-label={`Remove ${name}`}>×</button>
                      </td>
                    </tr>
                  ))}
                  {!fields.length ? (
                    <tr><td colSpan={3} className="tiny">No fields added yet.</td></tr>
                  ) : null}
                </tbody>
              </table>
              <div className="tiny" style={{ marginTop: 4 }}>
                The key field matches an import row to an existing record for update; with no key
                field, every imported row is always inserted as new.
              </div>
              <input type="hidden" name="key_field" value={keyField} />
            </>
          ) : null}
        </FormModal>
      ) : null}
    </>
  );
}
