-- Fixed Assets — a Business Central-style Fixed Asset subledger under Finance, with no complete
-- AL source to port (the companion "Sacco Demo AL" extension only adds Motor Vehicle fields and
-- an Asset Assignment concept on top of BC's stock FA tables). Built from Business Central
-- domain knowledge, matched to this codebase's conventions — closest precedent is the Inventory
-- / Item Journal module (prisma/migrations/20260902170000_add_inventory): setup masters, an
-- asset card, a maker-checker journal (Open -> Pending Approval -> Approved -> Processed) that
-- posts through the shared postJournal() engine, and an immutable ledger.
--
-- Scope: Acquisition Cost, Depreciation, Write-Down, Appreciation, Disposal and Maintenance FA
-- Posting Types; Straight-Line / Declining-Balance 1 / DB1-SL / Manual depreciation methods; a
-- Calculate Depreciation batch; an FA Book Value report. Out of scope: FA Reclassification
-- Journal, the FA Insurance module, and the Declining-Balance 2 / Half-Year / User-Defined
-- depreciation methods.
--
-- Data rows below (GL accounts, setup masters, No. Series, sequences) are all guarded by
-- `WHERE EXISTS (SELECT 1 FROM organisation)` so a fresh database — where this migration runs
-- BEFORE lib/seed.ts — takes none of them and lets the seed own them; an already-seeded
-- database takes them here so the module is usable straight after `prisma migrate deploy`.

-- CreateTable: FA Class (BC Table 5628).
CREATE TABLE "fa_class" (
    "id" SERIAL NOT NULL,
    "code" TEXT NOT NULL,
    "description" TEXT NOT NULL,
    "status" TEXT NOT NULL DEFAULT 'ACTIVE',
    "created_at" TEXT,
    "created_by" TEXT,

    CONSTRAINT "fa_class_pkey" PRIMARY KEY ("id")
);
CREATE UNIQUE INDEX "fa_class_code_key" ON "fa_class"("code");

-- CreateTable: FA Subclass (BC Table 5629).
CREATE TABLE "fa_subclass" (
    "id" SERIAL NOT NULL,
    "code" TEXT NOT NULL,
    "description" TEXT NOT NULL,
    "fa_class_code" TEXT,
    "status" TEXT NOT NULL DEFAULT 'ACTIVE',
    "created_at" TEXT,
    "created_by" TEXT,

    CONSTRAINT "fa_subclass_pkey" PRIMARY KEY ("id")
);
CREATE UNIQUE INDEX "fa_subclass_code_key" ON "fa_subclass"("code");

-- CreateTable: FA Location (BC Table 5643) — where an asset physically sits. Separate from the
-- Inventory "location" master.
CREATE TABLE "fa_location" (
    "id" SERIAL NOT NULL,
    "code" TEXT NOT NULL,
    "description" TEXT NOT NULL,
    "status" TEXT NOT NULL DEFAULT 'ACTIVE',
    "created_at" TEXT,
    "created_by" TEXT,

    CONSTRAINT "fa_location_pkey" PRIMARY KEY ("id")
);
CREATE UNIQUE INDEX "fa_location_code_key" ON "fa_location"("code");

-- CreateTable: Depreciation Book (BC Table 5611). This port always integrates to the G/L
-- (g_l_integration is informational), so there is no separate non-integrated FA Journal.
CREATE TABLE "depreciation_book" (
    "id" SERIAL NOT NULL,
    "code" TEXT NOT NULL,
    "description" TEXT NOT NULL,
    "g_l_integration" INTEGER NOT NULL DEFAULT 1,
    "default_final_rounding_amount" BIGINT NOT NULL DEFAULT 0,
    "use_rounding_in_periodic_depr" INTEGER NOT NULL DEFAULT 0,
    "created_at" TEXT,
    "created_by" TEXT,

    CONSTRAINT "depreciation_book_pkey" PRIMARY KEY ("id")
);
CREATE UNIQUE INDEX "depreciation_book_code_key" ON "depreciation_book"("code");

-- CreateTable: FA Posting Group (BC Table 5606, trimmed of the book-value / proceeds-on-disposal
-- accounts, which this port nets straight into the gains / losses accounts). Every FA G/L
-- posting resolves its debit and credit from the asset's posting group.
CREATE TABLE "fa_posting_group" (
    "id" SERIAL NOT NULL,
    "code" TEXT NOT NULL,
    "description" TEXT NOT NULL,
    "acquisition_cost_account_id" INTEGER NOT NULL,
    "accum_depreciation_account_id" INTEGER NOT NULL,
    "depreciation_expense_account_id" INTEGER NOT NULL,
    "write_down_expense_account_id" INTEGER NOT NULL,
    "appreciation_account_id" INTEGER NOT NULL,
    "maintenance_expense_account_id" INTEGER NOT NULL,
    "gains_acc_on_disposal_id" INTEGER NOT NULL,
    "losses_acc_on_disposal_id" INTEGER NOT NULL,
    "created_at" TEXT,
    "created_by" TEXT,

    CONSTRAINT "fa_posting_group_pkey" PRIMARY KEY ("id")
);
CREATE UNIQUE INDEX "fa_posting_group_code_key" ON "fa_posting_group"("code");

ALTER TABLE "fa_posting_group" ADD CONSTRAINT "fa_posting_group_acquisition_cost_account_id_fkey" FOREIGN KEY ("acquisition_cost_account_id") REFERENCES "gl_account"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE "fa_posting_group" ADD CONSTRAINT "fa_posting_group_accum_depreciation_account_id_fkey" FOREIGN KEY ("accum_depreciation_account_id") REFERENCES "gl_account"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE "fa_posting_group" ADD CONSTRAINT "fa_posting_group_depreciation_expense_account_id_fkey" FOREIGN KEY ("depreciation_expense_account_id") REFERENCES "gl_account"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE "fa_posting_group" ADD CONSTRAINT "fa_posting_group_write_down_expense_account_id_fkey" FOREIGN KEY ("write_down_expense_account_id") REFERENCES "gl_account"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE "fa_posting_group" ADD CONSTRAINT "fa_posting_group_appreciation_account_id_fkey" FOREIGN KEY ("appreciation_account_id") REFERENCES "gl_account"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE "fa_posting_group" ADD CONSTRAINT "fa_posting_group_maintenance_expense_account_id_fkey" FOREIGN KEY ("maintenance_expense_account_id") REFERENCES "gl_account"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE "fa_posting_group" ADD CONSTRAINT "fa_posting_group_gains_acc_on_disposal_id_fkey" FOREIGN KEY ("gains_acc_on_disposal_id") REFERENCES "gl_account"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE "fa_posting_group" ADD CONSTRAINT "fa_posting_group_losses_acc_on_disposal_id_fkey" FOREIGN KEY ("losses_acc_on_disposal_id") REFERENCES "gl_account"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- CreateTable: FA Setup (BC Table 5603) — singleton (id is always 1). FA Nos. / FA Journal Nos.
-- are handled by the No. Series module, not stored here.
CREATE TABLE "fa_setup" (
    "id" INTEGER NOT NULL DEFAULT 1,
    "default_depreciation_book_code" TEXT,
    "default_fa_posting_group_code" TEXT,
    "allow_fa_posting_from" TEXT,
    "allow_fa_posting_to" TEXT,
    "updated_at" TEXT,
    "updated_by" TEXT,

    CONSTRAINT "fa_setup_pkey" PRIMARY KEY ("id")
);

-- CreateTable: Maintenance (BC Table 5616) — the master list of maintenance / service types.
CREATE TABLE "maintenance" (
    "id" SERIAL NOT NULL,
    "code" TEXT NOT NULL,
    "description" TEXT NOT NULL,
    "status" TEXT NOT NULL DEFAULT 'ACTIVE',
    "created_at" TEXT,
    "created_by" TEXT,

    CONSTRAINT "maintenance_pkey" PRIMARY KEY ("id")
);
CREATE UNIQUE INDEX "maintenance_code_key" ON "maintenance"("code");

-- CreateTable: Fixed Asset (BC Table 5600) + the companion AL tableextension's Motor Vehicle
-- fields. acquisition_date / disposal_date are stamped by posting, never entered by hand.
CREATE TABLE "fixed_asset" (
    "id" SERIAL NOT NULL,
    "no" TEXT NOT NULL,
    "description" TEXT NOT NULL,
    "description_2" TEXT,
    "fa_class_code" TEXT,
    "fa_subclass_code" TEXT,
    "fa_location_code" TEXT,
    "responsible_employee" TEXT,
    "serial_no" TEXT,
    "vendor_name" TEXT,
    "asset_tag" TEXT,
    "asset_type" TEXT NOT NULL DEFAULT 'Fixed Asset',
    "global_dimension_1_id" INTEGER,
    "global_dimension_2_id" INTEGER,
    "blocked" INTEGER NOT NULL DEFAULT 0,
    "inactive" INTEGER NOT NULL DEFAULT 0,
    "vehicle_registration_no" TEXT,
    "vehicle_make" TEXT,
    "vehicle_model" TEXT,
    "colour" TEXT,
    "frame_no" TEXT,
    "engine_no" TEXT,
    "log_book_no" TEXT,
    "year_of_manufacture" TEXT,
    "load_limit_kgs" DOUBLE PRECISION,
    "passenger_capacity" INTEGER,
    "fuel_capacity" DOUBLE PRECISION,
    "acquisition_date" TEXT,
    "disposal_date" TEXT,
    "created_at" TEXT,
    "created_by" TEXT,

    CONSTRAINT "fixed_asset_pkey" PRIMARY KEY ("id")
);
CREATE UNIQUE INDEX "fixed_asset_no_key" ON "fixed_asset"("no");
CREATE INDEX "ix_fa_class" ON "fixed_asset"("fa_class_code");
CREATE INDEX "ix_fa_location" ON "fixed_asset"("fa_location_code");
CREATE INDEX "ix_fa_asset_type" ON "fixed_asset"("asset_type");

ALTER TABLE "fixed_asset" ADD CONSTRAINT "fixed_asset_global_dimension_1_id_fkey" FOREIGN KEY ("global_dimension_1_id") REFERENCES "global_dimension_1_value"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE "fixed_asset" ADD CONSTRAINT "fixed_asset_global_dimension_2_id_fkey" FOREIGN KEY ("global_dimension_2_id") REFERENCES "global_dimension_2_value"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- CreateTable: FA Depreciation Book (BC Table 5612) — one row per asset + depreciation book,
-- carrying the depreciation parameters and a maintained roll-up of the ledger amounts.
CREATE TABLE "fa_depreciation_book" (
    "id" SERIAL NOT NULL,
    "fixed_asset_id" INTEGER NOT NULL,
    "depreciation_book_code" TEXT NOT NULL,
    "fa_posting_group_code" TEXT NOT NULL,
    "depreciation_method" TEXT NOT NULL DEFAULT 'Straight-Line',
    "depreciation_starting_date" TEXT,
    "depreciation_ending_date" TEXT,
    "no_of_depreciation_years" DOUBLE PRECISION,
    "straight_line_pct" DOUBLE PRECISION NOT NULL DEFAULT 0,
    "declining_balance_pct" DOUBLE PRECISION NOT NULL DEFAULT 0,
    "fixed_depr_amount" BIGINT NOT NULL DEFAULT 0,
    "salvage_value" BIGINT NOT NULL DEFAULT 0,
    "last_depreciation_date" TEXT,
    "disposal_calculation_method" TEXT NOT NULL DEFAULT 'Net',
    "acquisition_cost" BIGINT NOT NULL DEFAULT 0,
    "accumulated_depreciation" BIGINT NOT NULL DEFAULT 0,
    "write_down_amount" BIGINT NOT NULL DEFAULT 0,
    "appreciation_amount" BIGINT NOT NULL DEFAULT 0,
    "book_value" BIGINT NOT NULL DEFAULT 0,
    "proceeds_on_disposal" BIGINT NOT NULL DEFAULT 0,
    "gain_loss_on_disposal" BIGINT NOT NULL DEFAULT 0,
    "maintenance_total" BIGINT NOT NULL DEFAULT 0,
    "disposed" INTEGER NOT NULL DEFAULT 0,

    CONSTRAINT "fa_depreciation_book_pkey" PRIMARY KEY ("id")
);
CREATE UNIQUE INDEX "fa_depreciation_book_fixed_asset_id_depreciation_book_code_key" ON "fa_depreciation_book"("fixed_asset_id", "depreciation_book_code");
CREATE INDEX "ix_fadb_book" ON "fa_depreciation_book"("depreciation_book_code");

ALTER TABLE "fa_depreciation_book" ADD CONSTRAINT "fa_depreciation_book_fixed_asset_id_fkey" FOREIGN KEY ("fixed_asset_id") REFERENCES "fixed_asset"("id") ON DELETE CASCADE ON UPDATE NO ACTION;
ALTER TABLE "fa_depreciation_book" ADD CONSTRAINT "fa_depreciation_book_depreciation_book_code_fkey" FOREIGN KEY ("depreciation_book_code") REFERENCES "depreciation_book"("code") ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE "fa_depreciation_book" ADD CONSTRAINT "fa_depreciation_book_fa_posting_group_code_fkey" FOREIGN KEY ("fa_posting_group_code") REFERENCES "fa_posting_group"("code") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- CreateTable: FA Journal Line — the maker-checker document. Same lifecycle shape as
-- item_journal_line. journal_id / balancing_gl_account_id carry no FK where they mirror an
-- existing loose convention; balancing_gl_account_id does get one (it is a plain G/L account).
CREATE TABLE "fa_journal_line" (
    "id" SERIAL NOT NULL,
    "no" TEXT NOT NULL,
    "posting_date" TEXT NOT NULL,
    "document_no" TEXT,
    "fixed_asset_id" INTEGER NOT NULL,
    "depreciation_book_code" TEXT NOT NULL,
    "fa_posting_type" TEXT NOT NULL,
    "amount" BIGINT NOT NULL DEFAULT 0,
    "balancing_gl_account_id" INTEGER,
    "maintenance_code" TEXT,
    "depr_until_fa_posting_date" INTEGER NOT NULL DEFAULT 0,
    "no_of_depreciation_days" INTEGER,
    "description" TEXT,
    "source" TEXT NOT NULL DEFAULT 'MANUAL',
    "status" TEXT NOT NULL DEFAULT 'Open',
    "decision_reason" TEXT,
    "posted" BOOLEAN NOT NULL DEFAULT false,
    "journal_id" INTEGER,
    "created_at" TEXT,
    "created_by" TEXT,
    "posted_at" TEXT,
    "posted_by" TEXT,

    CONSTRAINT "fa_journal_line_pkey" PRIMARY KEY ("id")
);
CREATE UNIQUE INDEX "fa_journal_line_no_key" ON "fa_journal_line"("no");
CREATE INDEX "ix_faj_asset" ON "fa_journal_line"("fixed_asset_id");
CREATE INDEX "ix_faj_status" ON "fa_journal_line"("status");
CREATE INDEX "ix_faj_created_by" ON "fa_journal_line"("created_by");
CREATE INDEX "ix_faj_posting_date" ON "fa_journal_line"("posting_date");

ALTER TABLE "fa_journal_line" ADD CONSTRAINT "fa_journal_line_fixed_asset_id_fkey" FOREIGN KEY ("fixed_asset_id") REFERENCES "fixed_asset"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE "fa_journal_line" ADD CONSTRAINT "fa_journal_line_depreciation_book_code_fkey" FOREIGN KEY ("depreciation_book_code") REFERENCES "depreciation_book"("code") ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE "fa_journal_line" ADD CONSTRAINT "fa_journal_line_balancing_gl_account_id_fkey" FOREIGN KEY ("balancing_gl_account_id") REFERENCES "gl_account"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- CreateTable: FA Ledger Entry (BC Table 5601) — the posted, immutable FA movement. amount is
-- signed (negative for Depreciation / Write-Down, positive for Acquisition / Appreciation).
CREATE TABLE "fa_ledger_entry" (
    "id" SERIAL NOT NULL,
    "fixed_asset_id" INTEGER NOT NULL,
    "depreciation_book_code" TEXT NOT NULL,
    "fa_posting_date" TEXT NOT NULL,
    "fa_posting_type" TEXT NOT NULL,
    "document_no" TEXT NOT NULL,
    "description" TEXT,
    "amount" BIGINT NOT NULL DEFAULT 0,
    "no_of_depreciation_days" INTEGER,
    "journal_id" INTEGER,
    "fa_journal_line_id" INTEGER,
    "part_of_book_value" INTEGER NOT NULL DEFAULT 1,
    "maintenance_code" TEXT,
    "reversed" INTEGER NOT NULL DEFAULT 0,
    "created_at" TEXT,

    CONSTRAINT "fa_ledger_entry_pkey" PRIMARY KEY ("id")
);
CREATE INDEX "ix_fale_asset_book" ON "fa_ledger_entry"("fixed_asset_id", "depreciation_book_code");
CREATE INDEX "ix_fale_date" ON "fa_ledger_entry"("fa_posting_date");
CREATE INDEX "ix_fale_type" ON "fa_ledger_entry"("fa_posting_type");

ALTER TABLE "fa_ledger_entry" ADD CONSTRAINT "fa_ledger_entry_fixed_asset_id_fkey" FOREIGN KEY ("fixed_asset_id") REFERENCES "fixed_asset"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE "fa_ledger_entry" ADD CONSTRAINT "fa_ledger_entry_depreciation_book_code_fkey" FOREIGN KEY ("depreciation_book_code") REFERENCES "depreciation_book"("code") ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE "fa_ledger_entry" ADD CONSTRAINT "fa_ledger_entry_fa_journal_line_id_fkey" FOREIGN KEY ("fa_journal_line_id") REFERENCES "fa_journal_line"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- ---------------------------------------------------------------------------------------------
-- Data backfill — already-seeded databases only (see the file header).
-- ---------------------------------------------------------------------------------------------

-- Chart of accounts: a Property, Plant & Equipment heading with at-cost / accumulated-
-- depreciation children, plus the depreciation, maintenance and disposal P&L accounts. 1300
-- "Property and Equipment" is left exactly as it is.
INSERT INTO "gl_account" ("code", "name", "type", "parent_code", "is_postable", "account_type")
SELECT v.code, v.name, v.type, v.parent_code, v.is_postable, v.account_type
FROM (VALUES
  ('1400', 'PROPERTY, PLANT AND EQUIPMENT', 'ASSET', NULL, 0, 'HEADING'),
  ('1410', 'Land and Buildings at Cost', 'ASSET', '1400', 1, 'POSTING'),
  ('1420', 'Furniture, Fittings & Equipment at Cost', 'ASSET', '1400', 1, 'POSTING'),
  ('1425', 'Accum. Depreciation — Furniture, Fittings & Equipment', 'ASSET', '1400', 1, 'POSTING'),
  ('1430', 'Motor Vehicles at Cost', 'ASSET', '1400', 1, 'POSTING'),
  ('1435', 'Accum. Depreciation — Motor Vehicles', 'ASSET', '1400', 1, 'POSTING'),
  ('4060', 'Gain on Disposal of Property & Equipment', 'INCOME', '4000', 1, 'POSTING'),
  ('5060', 'Depreciation Expense', 'EXPENSE', '5000', 1, 'POSTING'),
  ('5070', 'Repairs and Maintenance', 'EXPENSE', '5000', 1, 'POSTING'),
  ('5080', 'Loss on Disposal of Property & Equipment', 'EXPENSE', '5000', 1, 'POSTING')
) AS v(code, name, type, parent_code, is_postable, account_type)
WHERE EXISTS (SELECT 1 FROM "organisation")
ON CONFLICT ("code") DO NOTHING;

-- Document number sequences (fallback for nextSequence() until placed on a No. Series).
INSERT INTO "sequence" ("name", "prefix", "next_no", "width")
SELECT * FROM (VALUES ('FIXED_ASSET', 'FA', 1, 6), ('FA_JOURNAL', 'FAJ', 1, 6)) AS v(name, prefix, next_no, width)
WHERE EXISTS (SELECT 1 FROM "organisation")
ON CONFLICT ("name") DO NOTHING;

-- No. Series (header + one open line + the Admin Centre assignment row), mirroring how
-- lib/seed.ts wires every other numbered document.
INSERT INTO "no_series" ("code", "description", "default_nos", "manual_nos", "date_order")
SELECT * FROM (VALUES ('FIXED_ASSET', 'Fixed Asset No.', 1, 0, 0), ('FA_JOURNAL', 'FA Journal No.', 1, 0, 0)) AS v(code, description, default_nos, manual_nos, date_order)
WHERE EXISTS (SELECT 1 FROM "organisation")
ON CONFLICT ("code") DO NOTHING;

INSERT INTO "no_series_line" ("series_code", "line_no", "starting_date", "starting_no", "increment_by_no", "open", "allow_gaps")
SELECT v.series_code, 10000, NULL, v.starting_no, 1, 1, 0
FROM (VALUES ('FIXED_ASSET', 'FA000001'), ('FA_JOURNAL', 'FAJ000001')) AS v(series_code, starting_no)
WHERE EXISTS (SELECT 1 FROM "organisation")
  AND NOT EXISTS (SELECT 1 FROM "no_series_line" l WHERE l.series_code = v.series_code);

INSERT INTO "no_series_setup" ("document_code", "label", "category", "sort", "series_code")
SELECT v.document_code, v.label, 'Fixed Assets', v.sort, v.document_code
FROM (VALUES ('FIXED_ASSET', 'Fixed Asset No.', 30), ('FA_JOURNAL', 'FA Journal No.', 31)) AS v(document_code, label, sort)
WHERE EXISTS (SELECT 1 FROM "organisation")
ON CONFLICT ("document_code") DO NOTHING;

-- Setup masters.
INSERT INTO "depreciation_book" ("code", "description", "g_l_integration", "default_final_rounding_amount")
SELECT 'COMPANY', 'Company Book', 1, 100
WHERE EXISTS (SELECT 1 FROM "organisation")
ON CONFLICT ("code") DO NOTHING;

INSERT INTO "fa_class" ("code", "description")
SELECT * FROM (VALUES ('TANGIBLE', 'Tangible Assets'), ('EQUIPMENT', 'Equipment'), ('VEHICLES', 'Motor Vehicles'), ('BUILDINGS', 'Land and Buildings')) AS v(code, description)
WHERE EXISTS (SELECT 1 FROM "organisation")
ON CONFLICT ("code") DO NOTHING;

INSERT INTO "fa_subclass" ("code", "description", "fa_class_code")
SELECT * FROM (VALUES
  ('OFFICE-EQUIP', 'Office Equipment', 'EQUIPMENT'),
  ('COMPUTERS', 'Computers and IT Equipment', 'EQUIPMENT'),
  ('FURNITURE', 'Furniture and Fittings', 'EQUIPMENT'),
  ('SALOON', 'Saloon Vehicles', 'VEHICLES')
) AS v(code, description, fa_class_code)
WHERE EXISTS (SELECT 1 FROM "organisation")
ON CONFLICT ("code") DO NOTHING;

INSERT INTO "fa_location" ("code", "description")
SELECT * FROM (VALUES ('HQ', 'Head Office'), ('BRANCH-01', 'Branch 01')) AS v(code, description)
WHERE EXISTS (SELECT 1 FROM "organisation")
ON CONFLICT ("code") DO NOTHING;

INSERT INTO "maintenance" ("code", "description")
SELECT * FROM (VALUES ('SERVICE', 'Routine Service'), ('REPAIR', 'Repair'), ('INSPECTION', 'Inspection')) AS v(code, description)
WHERE EXISTS (SELECT 1 FROM "organisation")
ON CONFLICT ("code") DO NOTHING;

INSERT INTO "fa_posting_group" (
  "code", "description", "acquisition_cost_account_id", "accum_depreciation_account_id",
  "depreciation_expense_account_id", "write_down_expense_account_id", "appreciation_account_id",
  "maintenance_expense_account_id", "gains_acc_on_disposal_id", "losses_acc_on_disposal_id"
)
SELECT v.code, v.description,
  (SELECT id FROM "gl_account" WHERE code = v.cost),
  (SELECT id FROM "gl_account" WHERE code = v.accum),
  (SELECT id FROM "gl_account" WHERE code = '5060'),
  (SELECT id FROM "gl_account" WHERE code = '5060'),
  (SELECT id FROM "gl_account" WHERE code = v.cost),
  (SELECT id FROM "gl_account" WHERE code = '5070'),
  (SELECT id FROM "gl_account" WHERE code = '4060'),
  (SELECT id FROM "gl_account" WHERE code = '5080')
FROM (VALUES
  ('EQUIPMENT', 'Furniture, Fittings & Equipment', '1420', '1425'),
  ('VEHICLES', 'Motor Vehicles', '1430', '1435')
) AS v(code, description, cost, accum)
WHERE EXISTS (SELECT 1 FROM "organisation")
ON CONFLICT ("code") DO NOTHING;

INSERT INTO "fa_setup" ("id", "default_depreciation_book_code", "default_fa_posting_group_code", "updated_at", "updated_by")
SELECT 1, 'COMPANY', 'EQUIPMENT', NOW()::text, 'system'
WHERE EXISTS (SELECT 1 FROM "organisation")
ON CONFLICT ("id") DO NOTHING;

-- Permission backfill for the seeded roles (keyed by name, mirrors the ROLES action lists in
-- lib/seed.ts). GREATEST keeps any right already held; System Administrator is is_system and
-- bypasses permission lines entirely. On a fresh database no roles exist yet, so this JOIN
-- inserts nothing and lib/seed.ts's expandActionsToLines() owns the grants.
INSERT INTO "permission_set_line"
  ("role_id", "object_type", "object_name", "read_perm", "insert_perm", "modify_perm", "delete_perm", "execute_perm")
SELECT r.id, g.object_type, g.object_name, g.r, g.i, g.m, g.d, g.e
FROM "role" r
JOIN (VALUES
  ('Branch Manager',  'PAGE',  'FIXED_ASSETS',          0,0,0,0,1),
  ('Branch Manager',  'TABLE', 'fixed_asset',           1,0,0,0,0),
  ('Branch Manager',  'TABLE', 'fa_depreciation_book',  1,0,0,0,0),
  ('Branch Manager',  'TABLE', 'fa_journal_line',       1,0,1,0,0),
  ('Branch Manager',  'TABLE', 'fa_ledger_entry',       1,0,0,0,0),
  ('Branch Manager',  'TABLE', 'fa_class',              1,0,0,0,0),
  ('Branch Manager',  'TABLE', 'fa_subclass',           1,0,0,0,0),
  ('Branch Manager',  'TABLE', 'fa_location',           1,0,0,0,0),
  ('Branch Manager',  'TABLE', 'fa_posting_group',      1,0,0,0,0),
  ('Branch Manager',  'TABLE', 'depreciation_book',     1,0,0,0,0),
  ('Branch Manager',  'TABLE', 'fa_setup',              1,0,0,0,0),
  ('Branch Manager',  'TABLE', 'maintenance',           1,0,0,0,0),
  ('Branch Manager',  'TABLE', 'gl_account',            1,0,0,0,0),
  ('Finance Officer', 'PAGE',  'FIXED_ASSETS',          0,0,0,0,1),
  ('Finance Officer', 'TABLE', 'fixed_asset',           1,1,1,1,0),
  ('Finance Officer', 'TABLE', 'fa_depreciation_book',  1,1,1,0,0),
  ('Finance Officer', 'TABLE', 'fa_journal_line',       1,1,1,1,0),
  ('Finance Officer', 'TABLE', 'fa_ledger_entry',       1,1,0,0,0),
  ('Finance Officer', 'TABLE', 'fa_class',              1,1,1,1,0),
  ('Finance Officer', 'TABLE', 'fa_subclass',           1,1,1,1,0),
  ('Finance Officer', 'TABLE', 'fa_location',           1,1,1,1,0),
  ('Finance Officer', 'TABLE', 'fa_posting_group',      1,1,1,1,0),
  ('Finance Officer', 'TABLE', 'depreciation_book',     1,1,1,1,0),
  ('Finance Officer', 'TABLE', 'fa_setup',              1,1,1,0,0),
  ('Finance Officer', 'TABLE', 'maintenance',           1,1,1,1,0),
  ('Finance Officer', 'TABLE', 'gl_account',            1,0,0,0,0),
  ('Finance Officer', 'TABLE', 'journal',               0,1,0,0,0),
  ('Finance Officer', 'TABLE', 'journal_line',          0,1,0,0,0),
  ('Finance Officer', 'TABLE', 'workflow_task',         0,1,1,0,0),
  ('Internal Auditor','PAGE',  'FIXED_ASSETS',          0,0,0,0,1),
  ('Internal Auditor','TABLE', 'fixed_asset',           1,0,0,0,0),
  ('Internal Auditor','TABLE', 'fa_depreciation_book',  1,0,0,0,0),
  ('Internal Auditor','TABLE', 'fa_journal_line',       1,0,0,0,0),
  ('Internal Auditor','TABLE', 'fa_ledger_entry',       1,0,0,0,0),
  ('Internal Auditor','TABLE', 'fa_class',              1,0,0,0,0),
  ('Internal Auditor','TABLE', 'fa_subclass',           1,0,0,0,0),
  ('Internal Auditor','TABLE', 'fa_location',           1,0,0,0,0),
  ('Internal Auditor','TABLE', 'fa_posting_group',      1,0,0,0,0),
  ('Internal Auditor','TABLE', 'depreciation_book',     1,0,0,0,0),
  ('Internal Auditor','TABLE', 'fa_setup',              1,0,0,0,0),
  ('Internal Auditor','TABLE', 'maintenance',           1,0,0,0,0),
  ('Internal Auditor','TABLE', 'gl_account',            1,0,0,0,0)
) AS g(role_name, object_type, object_name, r, i, m, d, e) ON g.role_name = r.name
ON CONFLICT ("role_id", "object_type", "object_name") DO UPDATE SET
  "read_perm"    = GREATEST("permission_set_line"."read_perm",    EXCLUDED."read_perm"),
  "insert_perm"  = GREATEST("permission_set_line"."insert_perm",  EXCLUDED."insert_perm"),
  "modify_perm"  = GREATEST("permission_set_line"."modify_perm",  EXCLUDED."modify_perm"),
  "delete_perm"  = GREATEST("permission_set_line"."delete_perm",  EXCLUDED."delete_perm"),
  "execute_perm" = GREATEST("permission_set_line"."execute_perm", EXCLUDED."execute_perm");
