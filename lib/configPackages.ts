/*
 * Configuration Packages — Admin Centre → Data Management.
 *
 * Modeled on Dynamics Business Central's Configuration Packages/RapidStart: an
 * admin picks a table and a subset of its columns, then can export that data to
 * CSV and re-import a CSV to bulk insert/update rows, writing straight into the
 * base table for data migration — bypassing whatever approval workflow that
 * entity normally goes through (e.g. Member Application approval).
 *
 * Table and column discovery both introspect Postgres directly (the same
 * information_schema approach as lib/workflow.ts's tableSchema()), generalized
 * from "one fixed table per document type" to "any admin-picked table." Because
 * that makes this a direct line into the database, EXCLUDED_TABLES below is a
 * hard denylist, not a suggestion — it keeps the double-entry ledger and
 * auth/session state off-limits no matter what an admin configures.
 */
import { one, all, run, tx, audit } from './db.ts';
import { AppError } from './errors.ts';
import { toCsv, parseCsv } from './csv.ts';
import type {
  Actor, ConfigImportResult, ConfigImportRowResult, ConfigPackage, ConfigPackageColumn,
  ConfigPackageField, ConfigPackageTableOption, ConfigPackageWithFields,
} from './types.ts';

const humanize = (identifier: string): string => identifier
  .replace(/_id$/, '')
  .replace(/_/g, ' ')
  .replace(/\b\w/g, (c) => c.toUpperCase());

/** Tables a Configuration Package may never target, however an admin configures it. */
const EXCLUDED_TABLES = new Set([
  'session', 'sequence', 'audit_log', 'change_log_setup', 'change_log_entry',
  'config_package', 'config_package_field',
  'app_user', 'role',                                 // auth — already has its own Admin Centre UI
  'journal', 'journal_line',                          // double-entry ledger — only postJournal() may write these
  'workflow_task',                                     // approval routing state
  'savings_account', 'loan', 'loan_schedule', 'txn',   // balance-bearing operational ledgers
]);

/* ------------------------------------------------------------- table + column discovery */

/** The live, denylist-filtered set of tables an admin may build a Configuration Package against. */
export async function listConfigPackageTables(): Promise<ConfigPackageTableOption[]> {
  const rows = await all<{ table_name: string }>(
    "SELECT table_name FROM information_schema.tables WHERE table_schema = 'public' AND table_type = 'BASE TABLE' ORDER BY table_name",
  );
  return rows
    .filter((r) => !EXCLUDED_TABLES.has(r.table_name) && !r.table_name.startsWith('_'))
    .map((r) => ({ table_name: r.table_name, label: humanize(r.table_name) }));
}

/** Throws unless `table` is currently in the live, denylist-filtered set — re-checked before
 *  every dynamic query this module builds, since a client payload (or a schema change since
 *  the package was configured) can't be trusted to still be safe. */
async function assertConfigPackageTable(table: string): Promise<void> {
  const tables = await listConfigPackageTables();
  if (!tables.some((t) => t.table_name === table)) {
    throw new AppError('That table is not available for Configuration Packages', 'FORBIDDEN_TABLE');
  }
}

/** Real columns of `table` and, for foreign keys, which table they reference — the same
 *  introspection lib/workflow.ts's tableSchema() runs for its own (fixed-table) condition fields. */
async function tableSchema(table: string): Promise<{
  columns: Map<string, { default: string | null }>;
  referencedTableByColumn: Map<string, string>;
}> {
  const [columns, foreignKeys] = await Promise.all([
    all<{ column_name: string; column_default: string | null }>(
      "SELECT column_name, column_default FROM information_schema.columns WHERE table_schema = 'public' AND table_name = ?",
      table,
    ),
    all<{ column_name: string; referenced_table: string }>(
      `SELECT kcu.column_name, ccu.table_name AS referenced_table
       FROM information_schema.table_constraints tc
       JOIN information_schema.key_column_usage kcu
         ON kcu.constraint_name = tc.constraint_name AND kcu.table_schema = tc.table_schema
       JOIN information_schema.constraint_column_usage ccu
         ON ccu.constraint_name = tc.constraint_name AND ccu.table_schema = tc.table_schema
       WHERE tc.constraint_type = 'FOREIGN KEY' AND tc.table_name = ?`,
      table,
    ),
  ]);
  return {
    columns: new Map(columns.map((c) => [c.column_name, { default: c.column_default }])),
    referencedTableByColumn: new Map(foreignKeys.map((fk) => [fk.column_name, fk.referenced_table])),
  };
}

/** The columns of `table` a package may include — everything except `id` and any
 *  database-generated identity column (default `nextval(...)`), which are never
 *  meaningful to export or safe to overwrite on import. */
export async function listConfigPackageColumns(tableName: string): Promise<ConfigPackageColumn[]> {
  await assertConfigPackageTable(tableName);
  const { columns, referencedTableByColumn } = await tableSchema(tableName);
  return [...columns.entries()]
    .filter(([name, meta]) => name !== 'id' && !(meta.default ?? '').startsWith('nextval('))
    .map(([name]) => ({
      name,
      label: humanize(name),
      relation_table: referencedTableByColumn.get(name) ?? null,
    }))
    .sort((a, b) => a.name.localeCompare(b.name));
}

const validateFields = (fieldNames: string[], columns: ConfigPackageColumn[]): string[] => {
  const valid = new Set(columns.map((c) => c.name));
  return [...new Set(fieldNames)].filter((f) => valid.has(f));
};

/* ------------------------------------------------------------------------- package CRUD */

export async function listConfigPackages(): Promise<ConfigPackageWithFields[]> {
  const packages = await all<ConfigPackage>('SELECT * FROM config_package ORDER BY code');
  const fields = await all<ConfigPackageField>('SELECT * FROM config_package_field ORDER BY column_no');
  const byPackage = new Map<number, ConfigPackageField[]>();
  for (const f of fields) byPackage.set(f.package_id, [...(byPackage.get(f.package_id) ?? []), f]);
  return packages.map((p) => ({ ...p, fields: byPackage.get(p.id) ?? [] }));
}

export async function getConfigPackage(code: string): Promise<ConfigPackageWithFields | null> {
  const pkg = await one<ConfigPackage>('SELECT * FROM config_package WHERE code = ?', code);
  if (!pkg) return null;
  const fields = await all<ConfigPackageField>(
    'SELECT * FROM config_package_field WHERE package_id = ? ORDER BY column_no', pkg.id,
  );
  return { ...pkg, fields };
}

async function replaceFields(packageId: number, fieldNames: string[]): Promise<void> {
  await run('DELETE FROM config_package_field WHERE package_id = ?', packageId);
  let columnNo = 1;
  for (const field of fieldNames) {
    await run(
      'INSERT INTO config_package_field (package_id, field_name, column_no) VALUES (?,?,?)',
      packageId, field, columnNo++,
    );
  }
}

export interface ConfigPackageInput {
  code: string;
  name: string;
  table_name: string;
  key_field: string | null;
}

export async function createConfigPackage(
  body: ConfigPackageInput, fieldNames: string[], user: Actor,
): Promise<{ id: number }> {
  if (!body.code?.trim() || !body.name?.trim() || !body.table_name) {
    throw new AppError('Code, name and table are required', 'VALIDATION');
  }
  await assertConfigPackageTable(body.table_name);
  const columns = await listConfigPackageColumns(body.table_name);
  const valid = validateFields(fieldNames, columns);
  if (!valid.length) throw new AppError('Select at least one field', 'VALIDATION');
  if (body.key_field && !valid.includes(body.key_field)) {
    throw new AppError('The key field must be one of the selected fields', 'VALIDATION');
  }

  return tx(async () => {
    if (await one('SELECT 1 FROM config_package WHERE code = ?', body.code.trim())) {
      throw new AppError('That package code already exists', 'DUPLICATE');
    }
    const info = await run(
      'INSERT INTO config_package (code, name, table_name, key_field, created_at, created_by) VALUES (?,?,?,?,?,?)',
      body.code.trim(), body.name.trim(), body.table_name, body.key_field || null,
      new Date().toISOString(), user.username,
    );
    const id = Number(info.lastInsertRowid);
    await replaceFields(id, valid);
    await audit(user, 'CONFIG_PACKAGE_CREATE', 'config_package', id, { code: body.code, table_name: body.table_name });
    return { id };
  });
}

export async function updateConfigPackage(
  code: string, body: { name?: string; key_field?: string | null }, fieldNames: string[], user: Actor,
): Promise<{ id: number }> {
  const pkg = await one<ConfigPackage>('SELECT * FROM config_package WHERE code = ?', code);
  if (!pkg) throw new AppError('Package not found', 'NOT_FOUND');

  const columns = await listConfigPackageColumns(pkg.table_name);
  const valid = validateFields(fieldNames, columns);
  if (!valid.length) throw new AppError('Select at least one field', 'VALIDATION');
  const keyField = body.key_field !== undefined ? body.key_field : pkg.key_field;
  if (keyField && !valid.includes(keyField)) {
    throw new AppError('The key field must be one of the selected fields', 'VALIDATION');
  }

  return tx(async () => {
    await run(
      'UPDATE config_package SET name = COALESCE(?, name), key_field = ? WHERE id = ?',
      body.name?.trim() || null, keyField || null, pkg.id,
    );
    await replaceFields(pkg.id, valid);
    await audit(user, 'CONFIG_PACKAGE_UPDATE', 'config_package', pkg.id, { code });
    return { id: pkg.id };
  });
}

export async function deleteConfigPackage(code: string, user: Actor): Promise<void> {
  const pkg = await one<ConfigPackage>('SELECT * FROM config_package WHERE code = ?', code);
  if (!pkg) throw new AppError('Package not found', 'NOT_FOUND');
  await run('DELETE FROM config_package WHERE id = ?', pkg.id);
  await audit(user, 'CONFIG_PACKAGE_DELETE', 'config_package', pkg.id, { code });
}

/* ---------------------------------------------------------------------------------- export */

/** The referenced table's own display column for a foreign key — a code, else a name,
 *  else (no better option) its raw id — resolved live rather than hardcoded, since a
 *  package's relation may point at any table, not a fixed catalogue. */
async function displayColumnFor(referencedTable: string): Promise<string> {
  const refColumns = await all<{ column_name: string }>(
    "SELECT column_name FROM information_schema.columns WHERE table_schema='public' AND table_name = ?",
    referencedTable,
  );
  const names = new Set(refColumns.map((c) => c.column_name));
  return names.has('code') ? 'code' : names.has('name') ? 'name' : 'id';
}

export async function exportConfigPackage(code: string): Promise<{ filename: string; csv: string }> {
  const pkg = await getConfigPackage(code);
  if (!pkg) throw new AppError('Package not found', 'NOT_FOUND');
  await assertConfigPackageTable(pkg.table_name);

  const columns = await listConfigPackageColumns(pkg.table_name);
  const byName = new Map(columns.map((c) => [c.name, c]));
  const fieldNames = pkg.fields.map((f) => f.field_name).filter((f) => byName.has(f));
  if (!fieldNames.length) throw new AppError('This package has no valid fields configured', 'VALIDATION');

  const relationTables = [...new Set(
    fieldNames.map((f) => byName.get(f)!.relation_table).filter((t): t is string => !!t),
  )];
  const displayColumnByTable = new Map<string, string>();
  for (const table of relationTables) displayColumnByTable.set(table, await displayColumnFor(table));

  const selectList = fieldNames.map((f) => {
    const col = byName.get(f)!;
    if (col.relation_table) {
      const display = displayColumnByTable.get(col.relation_table)!;
      return display === 'id'
        ? `t."${f}" AS "${f}"`
        : `(SELECT r."${display}" FROM "${col.relation_table}" r WHERE r.id = t."${f}") AS "${f}"`;
    }
    return `t."${f}" AS "${f}"`;
  }).join(', ');
  const orderBy = pkg.key_field && fieldNames.includes(pkg.key_field) ? `t."${pkg.key_field}"` : 't.id';

  const rows = await all<Record<string, string | number | null>>(
    `SELECT ${selectList} FROM "${pkg.table_name}" t ORDER BY ${orderBy}`,
  );
  const headers = fieldNames.map((f) => byName.get(f)!.label);
  const csv = toCsv(headers, rows.map((r) => fieldNames.map((f) => r[f] ?? null)));
  return { filename: `${pkg.code}.csv`, csv };
}

/* ---------------------------------------------------------------------------------- import */

/** Resolves one CSV cell to the value that should actually be written: a plain scalar for a
 *  normal column, or (for a foreign key) the referenced row's id — accepting either a raw id
 *  or the same code/name value export() would have produced. */
async function resolveCell(cell: string, col: ConfigPackageColumn): Promise<string | number | null> {
  const trimmed = cell.trim();
  if (!trimmed) return null;
  if (!col.relation_table) return trimmed;

  if (/^\d+$/.test(trimmed)) {
    const byId = await one<{ id: number }>(`SELECT id FROM "${col.relation_table}" WHERE id = ?`, Number(trimmed));
    if (byId) return Number(trimmed);
  }
  const display = await displayColumnFor(col.relation_table);
  const match = await one<{ id: number }>(`SELECT id FROM "${col.relation_table}" WHERE "${display}" = ?`, trimmed);
  if (!match) throw new AppError(`No ${humanize(col.relation_table)} found for "${trimmed}" in ${col.label}`, 'LOOKUP_FAILED');
  return match.id;
}

export async function importConfigPackage(code: string, csvText: string, user: Actor): Promise<ConfigImportResult> {
  const pkg = await getConfigPackage(code);
  if (!pkg) throw new AppError('Package not found', 'NOT_FOUND');
  await assertConfigPackageTable(pkg.table_name);

  const columns = await listConfigPackageColumns(pkg.table_name);
  const byName = new Map(columns.map((c) => [c.name, c]));
  const fieldNames = pkg.fields.map((f) => f.field_name).filter((f) => byName.has(f));
  if (!fieldNames.length) throw new AppError('This package has no valid fields configured', 'VALIDATION');

  const allRows = parseCsv(csvText);
  if (!allRows.length) throw new AppError('The file is empty', 'VALIDATION');
  const [header, ...dataRows] = allRows;

  // Header cells match either the export's own field labels or the raw field names, so a
  // file round-tripped from export() and a hand-built one both work.
  const labelToField = new Map(fieldNames.map((f) => [byName.get(f)!.label, f]));
  const headerFields = header.map((h) => {
    const trimmed = h.trim();
    return labelToField.get(trimmed) ?? (fieldNames.includes(trimmed) ? trimmed : null);
  });

  const results: ConfigImportRowResult[] = [];
  let inserted = 0;
  let updated = 0;
  let errors = 0;

  for (let i = 0; i < dataRows.length; i++) {
    const rowNo = i + 2; // header is row 1
    const raw = dataRows[i];
    try {
      const values: Record<string, string | number | null> = {};
      for (let c = 0; c < headerFields.length; c++) {
        const field = headerFields[c];
        if (!field) continue;
        values[field] = await resolveCell(raw[c] ?? '', byName.get(field)!);
      }
      const setFields = fieldNames.filter((f) => f in values);
      if (!setFields.length) throw new AppError('No recognised columns in this row', 'VALIDATION');

      const status = await tx(async () => {
        let existingId: number | null = null;
        if (pkg.key_field && values[pkg.key_field] != null) {
          const existing = await one<{ id: number }>(
            `SELECT id FROM "${pkg.table_name}" WHERE "${pkg.key_field}" = ? ORDER BY id LIMIT 1`,
            values[pkg.key_field],
          );
          existingId = existing?.id ?? null;
        }
        if (existingId) {
          const setClause = setFields.map((f) => `"${f}" = ?`).join(', ');
          await run(
            `UPDATE "${pkg.table_name}" SET ${setClause} WHERE id = ?`,
            ...setFields.map((f) => values[f]), existingId,
          );
          return 'UPDATED' as const;
        }
        const colList = setFields.map((f) => `"${f}"`).join(', ');
        const placeholders = setFields.map(() => '?').join(', ');
        await run(
          `INSERT INTO "${pkg.table_name}" (${colList}) VALUES (${placeholders})`,
          ...setFields.map((f) => values[f]),
        );
        return 'INSERTED' as const;
      });

      if (status === 'UPDATED') updated++; else inserted++;
      results.push({ row: rowNo, status });
    } catch (err) {
      errors++;
      results.push({
        row: rowNo, status: 'ERROR',
        message: err instanceof AppError ? err.message : err instanceof Error ? err.message : 'Unknown error',
      });
    }
  }

  await audit(user, 'CONFIG_PACKAGE_IMPORT', pkg.table_name, pkg.id, {
    code: pkg.code, inserted, updated, errors, rows: dataRows.length,
  });

  return { inserted, updated, errors, rows: results };
}
