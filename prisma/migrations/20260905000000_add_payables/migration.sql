-- Payables — a Business Central Purchases & Payables port under Finance, the mirror image of the
-- Receivables module (migration 20260904000000_add_receivables): Vendors, Vendor Posting Groups,
-- Purchases & Payables Setup (Payment Terms / Methods are shared with Receivables); the Purchase
-- Quote -> Order -> Invoice / Credit Memo flow (partial receive/invoice) with G/L-account, Item
-- (stock in + inventory value) and Fixed Asset (acquisition) lines; Vendor Ledger Entries +
-- Detailed Vendor Ledger Entries with payment application; a maker-checker Payment Journal plus
-- BC's "Suggest Vendor Payments" batch; and the Aged Accounts Payable report + Vendor Statement.
--
-- Consolidations from stock BC (documented): posted Receipt/Invoice/Cr.Memo share one
-- `posted_purchase_document`(+`_line`) keyed by document_type.
--
-- Data back-fills guarded by `WHERE EXISTS (SELECT 1 FROM organisation)` — a fresh database
-- takes none of them (lib/seed.ts owns them); an already-seeded database takes them here so the
-- module is usable straight after `prisma migrate deploy`.

-- ============================================================================== setup masters

CREATE TABLE "vendor_posting_group" (
    "id" SERIAL NOT NULL,
    "code" TEXT NOT NULL,
    "description" TEXT NOT NULL,
    "payables_account_id" INTEGER NOT NULL,
    "service_charge_account_id" INTEGER NOT NULL,
    "payment_disc_debit_account_id" INTEGER NOT NULL,
    "payment_disc_credit_account_id" INTEGER NOT NULL,
    "invoice_rounding_account_id" INTEGER NOT NULL,
    "created_at" TEXT,
    "created_by" TEXT,

    CONSTRAINT "vendor_posting_group_pkey" PRIMARY KEY ("id")
);
CREATE UNIQUE INDEX "vendor_posting_group_code_key" ON "vendor_posting_group"("code");
ALTER TABLE "vendor_posting_group" ADD CONSTRAINT "vpg_payables_fkey" FOREIGN KEY ("payables_account_id") REFERENCES "gl_account"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE "vendor_posting_group" ADD CONSTRAINT "vpg_service_charge_fkey" FOREIGN KEY ("service_charge_account_id") REFERENCES "gl_account"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE "vendor_posting_group" ADD CONSTRAINT "vpg_pmt_disc_debit_fkey" FOREIGN KEY ("payment_disc_debit_account_id") REFERENCES "gl_account"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE "vendor_posting_group" ADD CONSTRAINT "vpg_pmt_disc_credit_fkey" FOREIGN KEY ("payment_disc_credit_account_id") REFERENCES "gl_account"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE "vendor_posting_group" ADD CONSTRAINT "vpg_invoice_rounding_fkey" FOREIGN KEY ("invoice_rounding_account_id") REFERENCES "gl_account"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- Business Central Table 312 "Purchases & Payables Setup" — singleton (id is always 1).
CREATE TABLE "purchases_payables_setup" (
    "id" INTEGER NOT NULL DEFAULT 1,
    "default_vendor_posting_group_code" TEXT,
    "default_payment_terms_code" TEXT,
    "receipt_on_invoice" INTEGER NOT NULL DEFAULT 1,
    "exact_cost_reversing_mandatory" INTEGER NOT NULL DEFAULT 0,
    "allow_payables_posting_from" TEXT,
    "allow_payables_posting_to" TEXT,
    "updated_at" TEXT,
    "updated_by" TEXT,

    CONSTRAINT "purchases_payables_setup_pkey" PRIMARY KEY ("id")
);

-- ==================================================================================== vendor

-- Business Central Table 23 "Vendor".
CREATE TABLE "vendor" (
    "id" SERIAL NOT NULL,
    "no" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "name_2" TEXT,
    "address" TEXT,
    "address_2" TEXT,
    "city" TEXT,
    "post_code" TEXT,
    "country" TEXT,
    "contact" TEXT,
    "phone" TEXT,
    "email" TEXT,
    "vendor_posting_group_code" TEXT,
    "payment_terms_code" TEXT,
    "payment_method_code" TEXT,
    "purchaser" TEXT,
    "credit_limit" BIGINT NOT NULL DEFAULT 0,
    "blocked" TEXT NOT NULL DEFAULT '',
    "our_account_no" TEXT,
    "global_dimension_1_id" INTEGER,
    "global_dimension_2_id" INTEGER,
    "balance" BIGINT NOT NULL DEFAULT 0,
    "last_statement_no" INTEGER NOT NULL DEFAULT 0,
    "created_at" TEXT,
    "created_by" TEXT,

    CONSTRAINT "vendor_pkey" PRIMARY KEY ("id")
);
CREATE UNIQUE INDEX "vendor_no_key" ON "vendor"("no");
CREATE INDEX "ix_vendor_posting_group" ON "vendor"("vendor_posting_group_code");

-- ========================================================================= purchase documents

-- Business Central Table 38 "Purchase Header".
CREATE TABLE "purchase_header" (
    "id" SERIAL NOT NULL,
    "document_type" TEXT NOT NULL,
    "no" TEXT NOT NULL,
    "vendor_id" INTEGER NOT NULL,
    "buy_from_name" TEXT,
    "buy_from_address" TEXT,
    "buy_from_city" TEXT,
    "buy_from_contact" TEXT,
    "posting_date" TEXT NOT NULL,
    "document_date" TEXT NOT NULL,
    "due_date" TEXT,
    "payment_terms_code" TEXT,
    "payment_method_code" TEXT,
    "vendor_posting_group_code" TEXT,
    "vendor_invoice_no" TEXT,
    "purchaser" TEXT,
    "global_dimension_1_id" INTEGER,
    "global_dimension_2_id" INTEGER,
    "status" TEXT NOT NULL DEFAULT 'Open',
    "amount" BIGINT NOT NULL DEFAULT 0,
    "decision_reason" TEXT,
    "created_at" TEXT,
    "created_by" TEXT,

    CONSTRAINT "purchase_header_pkey" PRIMARY KEY ("id")
);
CREATE UNIQUE INDEX "purchase_header_no_key" ON "purchase_header"("no");
CREATE INDEX "ix_purchase_header_type_status" ON "purchase_header"("document_type", "status");
CREATE INDEX "ix_purchase_header_vendor" ON "purchase_header"("vendor_id");
CREATE INDEX "ix_purchase_header_created_by" ON "purchase_header"("created_by");
ALTER TABLE "purchase_header" ADD CONSTRAINT "purchase_header_vendor_fkey" FOREIGN KEY ("vendor_id") REFERENCES "vendor"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- Business Central Table 39 "Purchase Line".
CREATE TABLE "purchase_line" (
    "id" SERIAL NOT NULL,
    "purchase_header_id" INTEGER NOT NULL,
    "line_no" INTEGER NOT NULL,
    "type" TEXT NOT NULL DEFAULT 'G/L Account',
    "no" TEXT,
    "description" TEXT,
    "quantity" DOUBLE PRECISION NOT NULL DEFAULT 0,
    "direct_unit_cost" BIGINT NOT NULL DEFAULT 0,
    "line_discount_pct" DOUBLE PRECISION NOT NULL DEFAULT 0,
    "line_discount_amount" BIGINT NOT NULL DEFAULT 0,
    "line_amount" BIGINT NOT NULL DEFAULT 0,
    "qty_to_receive" DOUBLE PRECISION NOT NULL DEFAULT 0,
    "qty_received" DOUBLE PRECISION NOT NULL DEFAULT 0,
    "qty_to_invoice" DOUBLE PRECISION NOT NULL DEFAULT 0,
    "qty_invoiced" DOUBLE PRECISION NOT NULL DEFAULT 0,
    "location_code" TEXT,
    "fa_depreciation_book_code" TEXT,
    "global_dimension_1_id" INTEGER,
    "global_dimension_2_id" INTEGER,

    CONSTRAINT "purchase_line_pkey" PRIMARY KEY ("id")
);
CREATE UNIQUE INDEX "purchase_line_header_lineno_key" ON "purchase_line"("purchase_header_id", "line_no");
ALTER TABLE "purchase_line" ADD CONSTRAINT "purchase_line_header_fkey" FOREIGN KEY ("purchase_header_id") REFERENCES "purchase_header"("id") ON DELETE CASCADE ON UPDATE NO ACTION;

-- Posted Purchase Receipt / Invoice / Credit Memo header (BC Tables 120/122/124, consolidated).
CREATE TABLE "posted_purchase_document" (
    "id" SERIAL NOT NULL,
    "document_type" TEXT NOT NULL,
    "no" TEXT NOT NULL,
    "vendor_id" INTEGER NOT NULL,
    "buy_from_name" TEXT,
    "buy_from_address" TEXT,
    "buy_from_city" TEXT,
    "buy_from_contact" TEXT,
    "posting_date" TEXT NOT NULL,
    "document_date" TEXT NOT NULL,
    "due_date" TEXT,
    "order_no" TEXT,
    "vendor_invoice_no" TEXT,
    "payment_terms_code" TEXT,
    "amount" BIGINT NOT NULL DEFAULT 0,
    "vendor_ledger_entry_id" INTEGER,
    "journal_id" INTEGER,
    "created_at" TEXT,
    "created_by" TEXT,

    CONSTRAINT "posted_purchase_document_pkey" PRIMARY KEY ("id")
);
CREATE UNIQUE INDEX "posted_purchase_document_no_key" ON "posted_purchase_document"("no");
CREATE INDEX "ix_ppd_vendor" ON "posted_purchase_document"("vendor_id");
CREATE INDEX "ix_ppd_type" ON "posted_purchase_document"("document_type");
ALTER TABLE "posted_purchase_document" ADD CONSTRAINT "ppd_vendor_fkey" FOREIGN KEY ("vendor_id") REFERENCES "vendor"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

CREATE TABLE "posted_purchase_line" (
    "id" SERIAL NOT NULL,
    "posted_purchase_document_id" INTEGER NOT NULL,
    "line_no" INTEGER NOT NULL,
    "type" TEXT NOT NULL,
    "no" TEXT,
    "description" TEXT,
    "quantity" DOUBLE PRECISION NOT NULL DEFAULT 0,
    "direct_unit_cost" BIGINT NOT NULL DEFAULT 0,
    "line_discount_amount" BIGINT NOT NULL DEFAULT 0,
    "line_amount" BIGINT NOT NULL DEFAULT 0,
    "item_ledger_entry_id" INTEGER,
    "fa_ledger_entry_id" INTEGER,

    CONSTRAINT "posted_purchase_line_pkey" PRIMARY KEY ("id")
);
CREATE INDEX "ix_ppl_doc" ON "posted_purchase_line"("posted_purchase_document_id");
ALTER TABLE "posted_purchase_line" ADD CONSTRAINT "ppl_doc_fkey" FOREIGN KEY ("posted_purchase_document_id") REFERENCES "posted_purchase_document"("id") ON DELETE CASCADE ON UPDATE NO ACTION;

-- =========================================================================== vendor subledger

-- Business Central Table 25 "Vendor Ledger Entry".
CREATE TABLE "vendor_ledger_entry" (
    "id" SERIAL NOT NULL,
    "vendor_id" INTEGER NOT NULL,
    "posting_date" TEXT NOT NULL,
    "document_type" TEXT NOT NULL,
    "document_no" TEXT NOT NULL,
    "vendor_invoice_no" TEXT,
    "description" TEXT,
    "amount" BIGINT NOT NULL DEFAULT 0,
    "remaining_amount" BIGINT NOT NULL DEFAULT 0,
    "original_amount" BIGINT NOT NULL DEFAULT 0,
    "due_date" TEXT,
    "pmt_discount_date" TEXT,
    "original_pmt_disc_possible" BIGINT NOT NULL DEFAULT 0,
    "open" INTEGER NOT NULL DEFAULT 1,
    "positive" INTEGER NOT NULL DEFAULT 1,
    "closed_by_entry_no" INTEGER,
    "closed_at_date" TEXT,
    "on_hold" TEXT,
    "source_type" TEXT,
    "source_id" INTEGER,
    "journal_id" INTEGER,
    "created_at" TEXT,

    CONSTRAINT "vendor_ledger_entry_pkey" PRIMARY KEY ("id")
);
CREATE INDEX "ix_vle_vendor_open" ON "vendor_ledger_entry"("vendor_id", "open");
CREATE INDEX "ix_vle_due_date" ON "vendor_ledger_entry"("due_date");
CREATE INDEX "ix_vle_document_no" ON "vendor_ledger_entry"("document_no");
ALTER TABLE "vendor_ledger_entry" ADD CONSTRAINT "vle_vendor_fkey" FOREIGN KEY ("vendor_id") REFERENCES "vendor"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- Business Central Table 380 "Detailed Vendor Ledg. Entry".
CREATE TABLE "detailed_vendor_ledger_entry" (
    "id" SERIAL NOT NULL,
    "vendor_ledger_entry_id" INTEGER NOT NULL,
    "entry_type" TEXT NOT NULL,
    "posting_date" TEXT NOT NULL,
    "document_type" TEXT,
    "document_no" TEXT,
    "amount" BIGINT NOT NULL DEFAULT 0,
    "applied_vendor_ledger_entry_id" INTEGER,
    "journal_id" INTEGER,
    "unapplied" INTEGER NOT NULL DEFAULT 0,
    "unapplied_by_entry_id" INTEGER,
    "created_at" TEXT,

    CONSTRAINT "detailed_vendor_ledger_entry_pkey" PRIMARY KEY ("id")
);
CREATE INDEX "ix_dvle_vle" ON "detailed_vendor_ledger_entry"("vendor_ledger_entry_id");
CREATE INDEX "ix_dvle_applied" ON "detailed_vendor_ledger_entry"("applied_vendor_ledger_entry_id");
ALTER TABLE "detailed_vendor_ledger_entry" ADD CONSTRAINT "dvle_vle_fkey" FOREIGN KEY ("vendor_ledger_entry_id") REFERENCES "vendor_ledger_entry"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- ================================================================================ payment journal

CREATE TABLE "payment_journal_header" (
    "id" SERIAL NOT NULL,
    "no" TEXT NOT NULL,
    "posting_date" TEXT NOT NULL,
    "document_date" TEXT NOT NULL,
    "bank_account_id" INTEGER NOT NULL,
    "description" TEXT,
    "status" TEXT NOT NULL DEFAULT 'Open',
    "total_amount" BIGINT NOT NULL DEFAULT 0,
    "decision_reason" TEXT,
    "posted" BOOLEAN NOT NULL DEFAULT false,
    "journal_id" INTEGER,
    "created_at" TEXT,
    "created_by" TEXT,
    "posted_at" TEXT,
    "posted_by" TEXT,

    CONSTRAINT "payment_journal_header_pkey" PRIMARY KEY ("id")
);
CREATE UNIQUE INDEX "payment_journal_header_no_key" ON "payment_journal_header"("no");
CREATE INDEX "ix_pjh_status" ON "payment_journal_header"("status");
CREATE INDEX "ix_pjh_created_by" ON "payment_journal_header"("created_by");
ALTER TABLE "payment_journal_header" ADD CONSTRAINT "pjh_bank_account_fkey" FOREIGN KEY ("bank_account_id") REFERENCES "bank_account"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

CREATE TABLE "payment_journal_line" (
    "id" SERIAL NOT NULL,
    "payment_journal_header_id" INTEGER NOT NULL,
    "line_no" INTEGER NOT NULL,
    "vendor_id" INTEGER NOT NULL,
    "amount" BIGINT NOT NULL DEFAULT 0,
    "payment_method_code" TEXT,
    "document_no" TEXT,
    "applies_to_doc_no" TEXT,
    "external_document_no" TEXT,
    "description" TEXT,
    "take_pmt_discount" INTEGER NOT NULL DEFAULT 0,

    CONSTRAINT "payment_journal_line_pkey" PRIMARY KEY ("id")
);
CREATE UNIQUE INDEX "payment_journal_line_header_lineno_key" ON "payment_journal_line"("payment_journal_header_id", "line_no");
ALTER TABLE "payment_journal_line" ADD CONSTRAINT "pjl_header_fkey" FOREIGN KEY ("payment_journal_header_id") REFERENCES "payment_journal_header"("id") ON DELETE CASCADE ON UPDATE NO ACTION;
ALTER TABLE "payment_journal_line" ADD CONSTRAINT "pjl_vendor_fkey" FOREIGN KEY ("vendor_id") REFERENCES "vendor"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- ============================================================================== data back-fill

INSERT INTO "gl_account" ("code", "name", "type", "parent_code", "is_postable", "account_type")
SELECT v.code, v.name, v.type, v.parent_code, v.is_postable, v.account_type
FROM (VALUES
  ('2145', 'TRADE AND OTHER PAYABLES', 'LIABILITY', NULL, 0, 'HEADING'),
  ('2150', 'Trade Payables — Vendors', 'LIABILITY', '2145', 1, 'POSTING'),
  ('2160', 'Goods Received Not Invoiced', 'LIABILITY', '2145', 1, 'POSTING')
) AS v(code, name, type, parent_code, is_postable, account_type)
WHERE EXISTS (SELECT 1 FROM "organisation")
ON CONFLICT ("code") DO NOTHING;

UPDATE "gl_account" SET "no_direct_posting" = 1
WHERE "code" = '2150' AND EXISTS (SELECT 1 FROM "organisation");

INSERT INTO "sequence" ("name", "prefix", "next_no", "width")
SELECT * FROM (VALUES
  ('VENDOR', 'V', 1001, 5),
  ('PURCHASE_QUOTE', 'PQ', 1, 6),
  ('PURCHASE_ORDER', 'PO', 1, 6),
  ('PURCHASE_INVOICE', 'PI', 1, 6),
  ('PURCHASE_CREDIT_MEMO', 'PM', 1, 6),
  ('POSTED_PURCHASE_RECEIPT', 'PRCP', 1, 6),
  ('POSTED_PURCHASE_INVOICE', 'PPI', 1, 6),
  ('POSTED_PURCHASE_CREDIT_MEMO', 'PPM', 1, 6),
  ('PAYMENT_JOURNAL', 'PAY', 1, 6)
) AS v(name, prefix, next_no, width)
WHERE EXISTS (SELECT 1 FROM "organisation")
ON CONFLICT ("name") DO NOTHING;

INSERT INTO "no_series" ("code", "description", "default_nos", "manual_nos", "date_order")
SELECT v.code, v.description, 1, 0, 0
FROM (VALUES
  ('VENDOR', 'Vendor No.'),
  ('PURCHASE_QUOTE', 'Purchase Quote No.'),
  ('PURCHASE_ORDER', 'Purchase Order No.'),
  ('PURCHASE_INVOICE', 'Purchase Invoice No.'),
  ('PURCHASE_CREDIT_MEMO', 'Purchase Credit Memo No.'),
  ('POSTED_PURCHASE_RECEIPT', 'Posted Purchase Receipt No.'),
  ('POSTED_PURCHASE_INVOICE', 'Posted Purchase Invoice No.'),
  ('POSTED_PURCHASE_CREDIT_MEMO', 'Posted Purchase Credit Memo No.'),
  ('PAYMENT_JOURNAL', 'Payment Journal No.')
) AS v(code, description)
WHERE EXISTS (SELECT 1 FROM "organisation")
ON CONFLICT ("code") DO NOTHING;

INSERT INTO "no_series_line" ("series_code", "line_no", "starting_date", "starting_no", "increment_by_no", "open", "allow_gaps")
SELECT s.name, 10000, NULL, s.prefix || LPAD(s.next_no::text, s.width, '0'), 1, 1, 0
FROM "sequence" s
WHERE s.name IN ('VENDOR','PURCHASE_QUOTE','PURCHASE_ORDER','PURCHASE_INVOICE','PURCHASE_CREDIT_MEMO','POSTED_PURCHASE_RECEIPT','POSTED_PURCHASE_INVOICE','POSTED_PURCHASE_CREDIT_MEMO','PAYMENT_JOURNAL')
  AND EXISTS (SELECT 1 FROM "organisation")
  AND NOT EXISTS (SELECT 1 FROM "no_series_line" l WHERE l.series_code = s.name);

INSERT INTO "no_series_setup" ("document_code", "label", "category", "sort", "series_code")
SELECT v.code, v.label, 'Payables', v.sort, v.code
FROM (VALUES
  ('VENDOR', 'Vendor No.', 60),
  ('PURCHASE_QUOTE', 'Purchase Quote No.', 61),
  ('PURCHASE_ORDER', 'Purchase Order No.', 62),
  ('PURCHASE_INVOICE', 'Purchase Invoice No.', 63),
  ('PURCHASE_CREDIT_MEMO', 'Purchase Credit Memo No.', 64),
  ('POSTED_PURCHASE_RECEIPT', 'Posted Purchase Receipt No.', 65),
  ('POSTED_PURCHASE_INVOICE', 'Posted Purchase Invoice No.', 66),
  ('POSTED_PURCHASE_CREDIT_MEMO', 'Posted Purchase Credit Memo No.', 67),
  ('PAYMENT_JOURNAL', 'Payment Journal No.', 68)
) AS v(code, label, sort)
WHERE EXISTS (SELECT 1 FROM "organisation")
ON CONFLICT ("document_code") DO NOTHING;

INSERT INTO "vendor_posting_group" (
  "code", "description", "payables_account_id", "service_charge_account_id",
  "payment_disc_debit_account_id", "payment_disc_credit_account_id", "invoice_rounding_account_id"
)
SELECT v.code, v.description,
  (SELECT id FROM "gl_account" WHERE code = '2150'),
  (SELECT id FROM "gl_account" WHERE code = '5030'),
  (SELECT id FROM "gl_account" WHERE code = '5030'),
  (SELECT id FROM "gl_account" WHERE code = '4050'),
  (SELECT id FROM "gl_account" WHERE code = '4050')
FROM (VALUES ('TRADE', 'Trade Creditors'), ('EXPENSE', 'Expense Suppliers')) AS v(code, description)
WHERE EXISTS (SELECT 1 FROM "organisation")
ON CONFLICT ("code") DO NOTHING;

INSERT INTO "purchases_payables_setup" ("id", "default_vendor_posting_group_code", "default_payment_terms_code", "updated_at", "updated_by")
SELECT 1, 'TRADE', '30 DAYS', NOW()::text, 'system'
WHERE EXISTS (SELECT 1 FROM "organisation")
ON CONFLICT ("id") DO NOTHING;

-- Permission backfill for the seeded roles (keyed by name; on a fresh DB no roles exist yet so
-- this JOIN inserts nothing and lib/seed.ts's expandActionsToLines() owns the grants).
INSERT INTO "permission_set_line"
  ("role_id", "object_type", "object_name", "read_perm", "insert_perm", "modify_perm", "delete_perm", "execute_perm")
SELECT r.id, g.object_type, g.object_name, g.r, g.i, g.m, g.d, g.e
FROM "role" r
JOIN (VALUES
  ('Branch Manager',  'PAGE',  'PAYABLES',                    0,0,0,0,1),
  ('Branch Manager',  'TABLE', 'vendor',                      1,0,0,0,0),
  ('Branch Manager',  'TABLE', 'purchase_header',             1,0,1,0,0),
  ('Branch Manager',  'TABLE', 'purchase_line',               1,0,0,0,0),
  ('Branch Manager',  'TABLE', 'vendor_ledger_entry',         1,0,0,0,0),
  ('Branch Manager',  'TABLE', 'posted_purchase_document',    1,0,0,0,0),
  ('Branch Manager',  'TABLE', 'payment_journal_header',      1,0,0,0,0),
  ('Finance Officer', 'PAGE',  'PAYABLES',                    0,0,0,0,1),
  ('Finance Officer', 'TABLE', 'vendor',                      1,1,1,1,0),
  ('Finance Officer', 'TABLE', 'vendor_posting_group',        1,1,1,1,0),
  ('Finance Officer', 'TABLE', 'purchases_payables_setup',    1,1,1,0,0),
  ('Finance Officer', 'TABLE', 'purchase_header',             1,1,1,1,0),
  ('Finance Officer', 'TABLE', 'purchase_line',               1,1,1,1,0),
  ('Finance Officer', 'TABLE', 'posted_purchase_document',    1,1,0,0,0),
  ('Finance Officer', 'TABLE', 'posted_purchase_line',        1,1,0,0,0),
  ('Finance Officer', 'TABLE', 'vendor_ledger_entry',         1,1,1,0,0),
  ('Finance Officer', 'TABLE', 'detailed_vendor_ledger_entry',1,1,1,0,0),
  ('Finance Officer', 'TABLE', 'payment_journal_header',      1,1,1,1,0),
  ('Finance Officer', 'TABLE', 'payment_journal_line',        1,1,1,1,0),
  ('Finance Officer', 'TABLE', 'item_ledger_entry',           1,1,1,0,0),
  ('Finance Officer', 'TABLE', 'stockkeeping_unit',           1,1,1,0,0),
  ('Finance Officer', 'TABLE', 'item',                        1,0,1,0,0),
  ('Finance Officer', 'TABLE', 'fa_ledger_entry',             1,1,0,0,0),
  ('Finance Officer', 'TABLE', 'fa_depreciation_book',        1,1,1,0,0),
  ('Finance Officer', 'TABLE', 'fixed_asset',                 1,1,1,0,0),
  ('Finance Officer', 'TABLE', 'journal',                     0,1,0,0,0),
  ('Finance Officer', 'TABLE', 'journal_line',                0,1,0,0,0),
  ('Finance Officer', 'TABLE', 'workflow_task',               0,1,1,0,0),
  ('Finance Officer', 'TABLE', 'gl_account',                  1,0,0,0,0),
  ('Internal Auditor','PAGE',  'PAYABLES',                    0,0,0,0,1),
  ('Internal Auditor','TABLE', 'vendor',                      1,0,0,0,0),
  ('Internal Auditor','TABLE', 'vendor_posting_group',        1,0,0,0,0),
  ('Internal Auditor','TABLE', 'purchases_payables_setup',    1,0,0,0,0),
  ('Internal Auditor','TABLE', 'purchase_header',             1,0,0,0,0),
  ('Internal Auditor','TABLE', 'purchase_line',               1,0,0,0,0),
  ('Internal Auditor','TABLE', 'posted_purchase_document',    1,0,0,0,0),
  ('Internal Auditor','TABLE', 'posted_purchase_line',        1,0,0,0,0),
  ('Internal Auditor','TABLE', 'vendor_ledger_entry',         1,0,0,0,0),
  ('Internal Auditor','TABLE', 'detailed_vendor_ledger_entry',1,0,0,0,0),
  ('Internal Auditor','TABLE', 'payment_journal_header',      1,0,0,0,0),
  ('Internal Auditor','TABLE', 'payment_journal_line',        1,0,0,0,0)
) AS g(role_name, object_type, object_name, r, i, m, d, e) ON g.role_name = r.name
ON CONFLICT ("role_id", "object_type", "object_name") DO UPDATE SET
  "read_perm"    = GREATEST("permission_set_line"."read_perm",    EXCLUDED."read_perm"),
  "insert_perm"  = GREATEST("permission_set_line"."insert_perm",  EXCLUDED."insert_perm"),
  "modify_perm"  = GREATEST("permission_set_line"."modify_perm",  EXCLUDED."modify_perm"),
  "delete_perm"  = GREATEST("permission_set_line"."delete_perm",  EXCLUDED."delete_perm"),
  "execute_perm" = GREATEST("permission_set_line"."execute_perm", EXCLUDED."execute_perm");
