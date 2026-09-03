-- Inventory — Business Central-style Item/Item Journal, with no AL source to port (see
-- lib/itemJournal.ts's header). Locations (multi-location), Units of Measure (per-item Base/
-- Purchase/Sales conversion via item_unit_of_measure), an Item card with Reorder Point/Quantity/
-- Maximum Inventory + Costing Method (FIFO/LIFO/Average/Standard/Specific), stockkeeping_unit for
-- per item+location qty-on-hand, and item_journal_line -> item_ledger_entry (+
-- item_application_entry for lot-costed methods) posting Positive/Negative Adjustments through
-- the shared postJournal() engine. Maker-checker, same shape as bankers_cheque.

-- CreateTable: Locations (BC Table 14).
CREATE TABLE "location" (
    "id" SERIAL NOT NULL,
    "code" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "address" TEXT,
    "status" TEXT NOT NULL DEFAULT 'ACTIVE',
    "created_at" TEXT,
    "created_by" TEXT,

    CONSTRAINT "location_pkey" PRIMARY KEY ("id")
);
CREATE UNIQUE INDEX "location_code_key" ON "location"("code");

-- CreateTable: Units of Measure (BC Table 204).
CREATE TABLE "unit_of_measure" (
    "id" SERIAL NOT NULL,
    "code" TEXT NOT NULL,
    "description" TEXT NOT NULL,
    "symbol" TEXT,
    "created_at" TEXT,
    "created_by" TEXT,

    CONSTRAINT "unit_of_measure_pkey" PRIMARY KEY ("id")
);
CREATE UNIQUE INDEX "unit_of_measure_code_key" ON "unit_of_measure"("code");

-- CreateTable: Inventory Posting Groups — Business Central's Inventory Posting Group (paired
-- with Location in the real Inventory Posting Setup; collapsed to a direct account here). Names
-- the balance-sheet subledger control account a posting moves stock value into/out of — the
-- ledger side of the ledger-subledger mapping.
CREATE TABLE "inventory_posting_group" (
    "id" SERIAL NOT NULL,
    "code" TEXT NOT NULL,
    "description" TEXT NOT NULL,
    "inventory_gl_account_id" INTEGER NOT NULL,
    "created_at" TEXT,
    "created_by" TEXT,

    CONSTRAINT "inventory_posting_group_pkey" PRIMARY KEY ("id")
);
CREATE UNIQUE INDEX "inventory_posting_group_code_key" ON "inventory_posting_group"("code");

ALTER TABLE "inventory_posting_group" ADD CONSTRAINT "inventory_posting_group_inventory_gl_account_id_fkey" FOREIGN KEY ("inventory_gl_account_id") REFERENCES "gl_account"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- CreateTable: Product Posting Groups — Business Central's Gen. Prod. Posting Group. Names the
-- P&L account a Positive/Negative Adjmt. offsets against — the subledger side of the
-- ledger-subledger mapping, configured (and reconciled) independently of the Inventory Posting
-- Group above, exactly as Business Central keeps the two posting-group axes independent.
CREATE TABLE "product_posting_group" (
    "id" SERIAL NOT NULL,
    "code" TEXT NOT NULL,
    "description" TEXT NOT NULL,
    "adjustment_gl_account_id" INTEGER NOT NULL,
    "created_at" TEXT,
    "created_by" TEXT,

    CONSTRAINT "product_posting_group_pkey" PRIMARY KEY ("id")
);
CREATE UNIQUE INDEX "product_posting_group_code_key" ON "product_posting_group"("code");

ALTER TABLE "product_posting_group" ADD CONSTRAINT "product_posting_group_adjustment_gl_account_id_fkey" FOREIGN KEY ("adjustment_gl_account_id") REFERENCES "gl_account"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- CreateTable: Items (BC Table 27, trimmed — no variants/serials/lots/Item Charges).
CREATE TABLE "item" (
    "id" SERIAL NOT NULL,
    "no" TEXT NOT NULL,
    "description" TEXT NOT NULL,
    "description_2" TEXT,
    "base_unit_of_measure_id" INTEGER NOT NULL,
    "purch_unit_of_measure_id" INTEGER,
    "sales_unit_of_measure_id" INTEGER,
    "inventory_posting_group_id" INTEGER NOT NULL,
    "product_posting_group_id" INTEGER NOT NULL,
    "costing_method" TEXT NOT NULL DEFAULT 'FIFO',
    "unit_cost" BIGINT NOT NULL DEFAULT 0,
    "unit_price" BIGINT NOT NULL DEFAULT 0,
    "inventory" INTEGER NOT NULL DEFAULT 0,
    "reordering_policy" TEXT NOT NULL DEFAULT 'Fixed Reorder Qty.',
    "reorder_point" INTEGER NOT NULL DEFAULT 0,
    "reorder_quantity" INTEGER NOT NULL DEFAULT 0,
    "maximum_inventory" INTEGER NOT NULL DEFAULT 0,
    "status" TEXT NOT NULL DEFAULT 'ACTIVE',
    "created_at" TEXT,
    "created_by" TEXT,

    CONSTRAINT "item_pkey" PRIMARY KEY ("id")
);
CREATE UNIQUE INDEX "item_no_key" ON "item"("no");
CREATE INDEX "ix_item_status" ON "item"("status");

ALTER TABLE "item" ADD CONSTRAINT "item_base_unit_of_measure_id_fkey" FOREIGN KEY ("base_unit_of_measure_id") REFERENCES "unit_of_measure"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE "item" ADD CONSTRAINT "item_purch_unit_of_measure_id_fkey" FOREIGN KEY ("purch_unit_of_measure_id") REFERENCES "unit_of_measure"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE "item" ADD CONSTRAINT "item_sales_unit_of_measure_id_fkey" FOREIGN KEY ("sales_unit_of_measure_id") REFERENCES "unit_of_measure"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE "item" ADD CONSTRAINT "item_inventory_posting_group_id_fkey" FOREIGN KEY ("inventory_posting_group_id") REFERENCES "inventory_posting_group"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE "item" ADD CONSTRAINT "item_product_posting_group_id_fkey" FOREIGN KEY ("product_posting_group_id") REFERENCES "product_posting_group"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- CreateTable: Item Unit of Measure (BC Table 5404) — which units an item may be entered in, and
-- each one's conversion factor to the item's own Base UoM.
CREATE TABLE "item_unit_of_measure" (
    "id" SERIAL NOT NULL,
    "item_id" INTEGER NOT NULL,
    "unit_of_measure_id" INTEGER NOT NULL,
    "qty_per_unit_of_measure" INTEGER NOT NULL DEFAULT 1,

    CONSTRAINT "item_unit_of_measure_pkey" PRIMARY KEY ("id")
);
CREATE UNIQUE INDEX "item_unit_of_measure_item_id_unit_of_measure_id_key" ON "item_unit_of_measure"("item_id", "unit_of_measure_id");

ALTER TABLE "item_unit_of_measure" ADD CONSTRAINT "item_unit_of_measure_item_id_fkey" FOREIGN KEY ("item_id") REFERENCES "item"("id") ON DELETE CASCADE ON UPDATE NO ACTION;
ALTER TABLE "item_unit_of_measure" ADD CONSTRAINT "item_unit_of_measure_unit_of_measure_id_fkey" FOREIGN KEY ("unit_of_measure_id") REFERENCES "unit_of_measure"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- CreateTable: Stockkeeping Unit (BC Table 5700) — per item+location qty-on-hand, with an
-- optional per-location override of the item's reordering defaults.
CREATE TABLE "stockkeeping_unit" (
    "id" SERIAL NOT NULL,
    "item_id" INTEGER NOT NULL,
    "location_id" INTEGER NOT NULL,
    "reordering_policy" TEXT,
    "reorder_point" INTEGER,
    "reorder_quantity" INTEGER,
    "maximum_inventory" INTEGER,
    "inventory" INTEGER NOT NULL DEFAULT 0,

    CONSTRAINT "stockkeeping_unit_pkey" PRIMARY KEY ("id")
);
CREATE UNIQUE INDEX "stockkeeping_unit_item_id_location_id_key" ON "stockkeeping_unit"("item_id", "location_id");

ALTER TABLE "stockkeeping_unit" ADD CONSTRAINT "stockkeeping_unit_item_id_fkey" FOREIGN KEY ("item_id") REFERENCES "item"("id") ON DELETE CASCADE ON UPDATE NO ACTION;
ALTER TABLE "stockkeeping_unit" ADD CONSTRAINT "stockkeeping_unit_location_id_fkey" FOREIGN KEY ("location_id") REFERENCES "location"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- CreateTable: Item Journal Line (BC Table 83, Positive/Negative Adjmt. only). Maker-checker,
-- same lifecycle shape as bankers_cheque. journal_id / applies_to_entry_id carry no FK
-- constraint, the same convention bankers_cheque.journal_id already uses in this schema.
CREATE TABLE "item_journal_line" (
    "id" SERIAL NOT NULL,
    "no" TEXT NOT NULL,
    "posting_date" TEXT NOT NULL,
    "entry_type" TEXT NOT NULL,
    "item_id" INTEGER NOT NULL,
    "location_id" INTEGER NOT NULL,
    "description" TEXT,
    "unit_of_measure_id" INTEGER NOT NULL,
    "qty_per_unit_of_measure" INTEGER NOT NULL DEFAULT 1,
    "quantity" INTEGER NOT NULL DEFAULT 0,
    "base_quantity" INTEGER NOT NULL DEFAULT 0,
    "applies_to_entry_id" INTEGER,
    "unit_cost" BIGINT NOT NULL DEFAULT 0,
    "amount" BIGINT NOT NULL DEFAULT 0,
    "status" TEXT NOT NULL DEFAULT 'Open',
    "decision_reason" TEXT,
    "posted" BOOLEAN NOT NULL DEFAULT false,
    "journal_id" INTEGER,
    "global_dimension_1_id" INTEGER,
    "global_dimension_2_id" INTEGER,
    "created_at" TEXT,
    "created_by" TEXT,
    "posted_at" TEXT,
    "posted_by" TEXT,

    CONSTRAINT "item_journal_line_pkey" PRIMARY KEY ("id")
);
CREATE UNIQUE INDEX "item_journal_line_no_key" ON "item_journal_line"("no");
CREATE INDEX "ix_ijl_item" ON "item_journal_line"("item_id");
CREATE INDEX "ix_ijl_location" ON "item_journal_line"("location_id");
CREATE INDEX "ix_ijl_status" ON "item_journal_line"("status");
CREATE INDEX "ix_ijl_created_by" ON "item_journal_line"("created_by");
CREATE INDEX "ix_ijl_posting_date" ON "item_journal_line"("posting_date");

ALTER TABLE "item_journal_line" ADD CONSTRAINT "item_journal_line_item_id_fkey" FOREIGN KEY ("item_id") REFERENCES "item"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE "item_journal_line" ADD CONSTRAINT "item_journal_line_location_id_fkey" FOREIGN KEY ("location_id") REFERENCES "location"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE "item_journal_line" ADD CONSTRAINT "item_journal_line_unit_of_measure_id_fkey" FOREIGN KEY ("unit_of_measure_id") REFERENCES "unit_of_measure"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- CreateTable: Item Ledger Entry (BC Table 32) — the posted, immutable stock movement / cost lot.
CREATE TABLE "item_ledger_entry" (
    "id" SERIAL NOT NULL,
    "item_id" INTEGER NOT NULL,
    "location_id" INTEGER NOT NULL,
    "posting_date" TEXT NOT NULL,
    "entry_type" TEXT NOT NULL,
    "document_no" TEXT NOT NULL,
    "quantity" INTEGER NOT NULL,
    "remaining_quantity" INTEGER NOT NULL DEFAULT 0,
    "open" BOOLEAN NOT NULL DEFAULT false,
    "unit_cost" BIGINT NOT NULL DEFAULT 0,
    "amount" BIGINT NOT NULL DEFAULT 0,
    "item_journal_line_id" INTEGER NOT NULL,
    "created_at" TEXT,

    CONSTRAINT "item_ledger_entry_pkey" PRIMARY KEY ("id")
);
CREATE INDEX "ix_ile_item" ON "item_ledger_entry"("item_id");
CREATE INDEX "ix_ile_location" ON "item_ledger_entry"("location_id");

ALTER TABLE "item_ledger_entry" ADD CONSTRAINT "item_ledger_entry_item_id_fkey" FOREIGN KEY ("item_id") REFERENCES "item"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE "item_ledger_entry" ADD CONSTRAINT "item_ledger_entry_location_id_fkey" FOREIGN KEY ("location_id") REFERENCES "location"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE "item_ledger_entry" ADD CONSTRAINT "item_ledger_entry_item_journal_line_id_fkey" FOREIGN KEY ("item_journal_line_id") REFERENCES "item_journal_line"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- CreateTable: Item Application Entry (BC Table 339) — which inbound lot(s) an outbound entry
-- consumed and how much of each. Written for FIFO/LIFO/Average/Specific; Standard writes none.
CREATE TABLE "item_application_entry" (
    "id" SERIAL NOT NULL,
    "outbound_entry_id" INTEGER NOT NULL,
    "inbound_entry_id" INTEGER NOT NULL,
    "quantity" INTEGER NOT NULL,
    "posting_date" TEXT NOT NULL,
    "created_at" TEXT,

    CONSTRAINT "item_application_entry_pkey" PRIMARY KEY ("id")
);
CREATE INDEX "ix_iae_outbound" ON "item_application_entry"("outbound_entry_id");
CREATE INDEX "ix_iae_inbound" ON "item_application_entry"("inbound_entry_id");

ALTER TABLE "item_application_entry" ADD CONSTRAINT "item_application_entry_outbound_entry_id_fkey" FOREIGN KEY ("outbound_entry_id") REFERENCES "item_ledger_entry"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE "item_application_entry" ADD CONSTRAINT "item_application_entry_inbound_entry_id_fkey" FOREIGN KEY ("inbound_entry_id") REFERENCES "item_ledger_entry"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- Data: document number sequences (fallback for nextSequence() until placed on a No. Series).
INSERT INTO "sequence" ("name", "prefix", "next_no", "width") VALUES ('ITEM', 'ITM', 1, 6)
ON CONFLICT ("name") DO NOTHING;
INSERT INTO "sequence" ("name", "prefix", "next_no", "width") VALUES ('ITEM_JOURNAL', 'IJL', 1, 6)
ON CONFLICT ("name") DO NOTHING;

-- Permission backfill: grant the Inventory page + its tables to the seeded roles, keyed by name
-- (mirrors the ROLES action lists in lib/seed.ts). GREATEST keeps any right already held; System
-- Administrator is is_system and bypasses permission lines entirely.
INSERT INTO "permission_set_line"
  ("role_id", "object_type", "object_name", "read_perm", "insert_perm", "modify_perm", "delete_perm", "execute_perm")
SELECT r.id, g.object_type, g.object_name, g.r, g.i, g.m, g.d, g.e
FROM "role" r
JOIN (VALUES
  ('Branch Manager',  'PAGE',  'INVENTORY',              0,0,0,0,1),
  ('Branch Manager',  'TABLE', 'location',                1,1,1,1,0),
  ('Branch Manager',  'TABLE', 'unit_of_measure',         1,1,1,1,0),
  ('Branch Manager',  'TABLE', 'inventory_posting_group', 1,1,1,1,0),
  ('Branch Manager',  'TABLE', 'product_posting_group',   1,1,1,1,0),
  ('Branch Manager',  'TABLE', 'item',                    1,1,1,1,0),
  ('Branch Manager',  'TABLE', 'item_unit_of_measure',    1,1,1,1,0),
  ('Branch Manager',  'TABLE', 'stockkeeping_unit',       1,1,1,1,0),
  ('Branch Manager',  'TABLE', 'item_journal_line',       1,1,1,1,0),
  ('Branch Manager',  'TABLE', 'item_ledger_entry',       1,1,0,0,0),
  ('Branch Manager',  'TABLE', 'item_application_entry',  1,1,0,0,0),
  ('Branch Manager',  'TABLE', 'journal',                 0,1,0,0,0),
  ('Branch Manager',  'TABLE', 'journal_line',            0,1,0,0,0),
  ('Finance Officer', 'PAGE',  'INVENTORY',              0,0,0,0,1),
  ('Finance Officer', 'TABLE', 'location',                1,1,1,1,0),
  ('Finance Officer', 'TABLE', 'unit_of_measure',         1,1,1,1,0),
  ('Finance Officer', 'TABLE', 'inventory_posting_group', 1,1,1,1,0),
  ('Finance Officer', 'TABLE', 'product_posting_group',   1,1,1,1,0),
  ('Finance Officer', 'TABLE', 'item',                    1,1,1,1,0),
  ('Finance Officer', 'TABLE', 'item_unit_of_measure',    1,1,1,1,0),
  ('Finance Officer', 'TABLE', 'stockkeeping_unit',       1,1,1,1,0),
  ('Finance Officer', 'TABLE', 'item_journal_line',       1,1,1,1,0),
  ('Finance Officer', 'TABLE', 'item_ledger_entry',       1,1,0,0,0),
  ('Finance Officer', 'TABLE', 'item_application_entry',  1,1,0,0,0),
  ('Finance Officer', 'TABLE', 'journal',                 0,1,0,0,0),
  ('Finance Officer', 'TABLE', 'journal_line',            0,1,0,0,0),
  ('Internal Auditor','PAGE',  'INVENTORY',              0,0,0,0,1),
  ('Internal Auditor','TABLE', 'location',                1,0,0,0,0),
  ('Internal Auditor','TABLE', 'unit_of_measure',         1,0,0,0,0),
  ('Internal Auditor','TABLE', 'inventory_posting_group', 1,0,0,0,0),
  ('Internal Auditor','TABLE', 'product_posting_group',   1,0,0,0,0),
  ('Internal Auditor','TABLE', 'item',                    1,0,0,0,0),
  ('Internal Auditor','TABLE', 'item_unit_of_measure',    1,0,0,0,0),
  ('Internal Auditor','TABLE', 'stockkeeping_unit',       1,0,0,0,0),
  ('Internal Auditor','TABLE', 'item_journal_line',       1,0,0,0,0),
  ('Internal Auditor','TABLE', 'item_ledger_entry',       1,0,0,0,0),
  ('Internal Auditor','TABLE', 'item_application_entry',  1,0,0,0,0)
) AS g(role_name, object_type, object_name, r, i, m, d, e) ON g.role_name = r.name
ON CONFLICT ("role_id", "object_type", "object_name") DO UPDATE SET
  "read_perm"    = GREATEST("permission_set_line"."read_perm",    EXCLUDED."read_perm"),
  "insert_perm"  = GREATEST("permission_set_line"."insert_perm",  EXCLUDED."insert_perm"),
  "modify_perm"  = GREATEST("permission_set_line"."modify_perm",  EXCLUDED."modify_perm"),
  "delete_perm"  = GREATEST("permission_set_line"."delete_perm",  EXCLUDED."delete_perm"),
  "execute_perm" = GREATEST("permission_set_line"."execute_perm", EXCLUDED."execute_perm");
