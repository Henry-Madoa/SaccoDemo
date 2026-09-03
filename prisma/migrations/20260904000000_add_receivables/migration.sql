-- Receivables — a Business Central Sales & Receivables port under Finance. Customers, Customer
-- Posting Groups, Payment Terms / Methods, Reminder & Finance Charge Terms, Sales & Receivables
-- Setup; the Sales Quote -> Order -> Invoice / Credit Memo document flow (partial ship/invoice)
-- with G/L-account, Item (COGS + stock) and Fixed Asset (disposal) lines; Cust. Ledger Entries
-- + Detailed Cust. Ledger Entries with payment application; a Cash Receipt Journal; Reminders
-- and Finance Charge Memos; and the Aged Accounts Receivable report + Customer Statement.
--
-- Built from Business Central domain knowledge (the companion "Sacco Demo AL" extension only
-- adds property-management Customer/Sales fields). Closest precedent: the Fixed Assets and
-- Inventory modules — maker-checker documents (Open -> Pending Approval -> Approved/Released ->
-- Processed) posting through the shared postJournal() engine.
--
-- Consolidations from stock BC (documented): posted Shipment/Invoice/Cr.Memo share one
-- `posted_sales_document`(+`_line`) keyed by document_type; Reminders and Finance Charge Memos
-- share `reminder_header`(+`_line`) and flip status Open -> Issued in place rather than copying
-- to separate Issued tables.
--
-- Data back-fills (GL accounts, masters, No. Series, permissions) are guarded by
-- `WHERE EXISTS (SELECT 1 FROM organisation)` so a fresh database — where this migration runs
-- before lib/seed.ts — takes none of them and lets the seed own them; an already-seeded
-- database takes them here so the module is usable straight after `prisma migrate deploy`.

-- ============================================================================== setup masters

-- CreateTable: Customer Posting Group (BC Table 92).
CREATE TABLE "customer_posting_group" (
    "id" SERIAL NOT NULL,
    "code" TEXT NOT NULL,
    "description" TEXT NOT NULL,
    "receivables_account_id" INTEGER NOT NULL,
    "service_charge_account_id" INTEGER NOT NULL,
    "additional_fee_account_id" INTEGER NOT NULL,
    "payment_disc_debit_account_id" INTEGER NOT NULL,
    "payment_disc_credit_account_id" INTEGER NOT NULL,
    "invoice_rounding_account_id" INTEGER NOT NULL,
    "created_at" TEXT,
    "created_by" TEXT,

    CONSTRAINT "customer_posting_group_pkey" PRIMARY KEY ("id")
);
CREATE UNIQUE INDEX "customer_posting_group_code_key" ON "customer_posting_group"("code");
ALTER TABLE "customer_posting_group" ADD CONSTRAINT "cpg_receivables_fkey" FOREIGN KEY ("receivables_account_id") REFERENCES "gl_account"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE "customer_posting_group" ADD CONSTRAINT "cpg_service_charge_fkey" FOREIGN KEY ("service_charge_account_id") REFERENCES "gl_account"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE "customer_posting_group" ADD CONSTRAINT "cpg_additional_fee_fkey" FOREIGN KEY ("additional_fee_account_id") REFERENCES "gl_account"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE "customer_posting_group" ADD CONSTRAINT "cpg_pmt_disc_debit_fkey" FOREIGN KEY ("payment_disc_debit_account_id") REFERENCES "gl_account"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE "customer_posting_group" ADD CONSTRAINT "cpg_pmt_disc_credit_fkey" FOREIGN KEY ("payment_disc_credit_account_id") REFERENCES "gl_account"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE "customer_posting_group" ADD CONSTRAINT "cpg_invoice_rounding_fkey" FOREIGN KEY ("invoice_rounding_account_id") REFERENCES "gl_account"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- CreateTable: Payment Terms (BC Table 3).
CREATE TABLE "payment_terms" (
    "id" SERIAL NOT NULL,
    "code" TEXT NOT NULL,
    "description" TEXT NOT NULL,
    "due_date_calculation" TEXT NOT NULL DEFAULT '',
    "discount_date_calculation" TEXT NOT NULL DEFAULT '',
    "discount_pct" DOUBLE PRECISION NOT NULL DEFAULT 0,
    "calc_pmt_disc_on_credit_memos" INTEGER NOT NULL DEFAULT 0,
    "status" TEXT NOT NULL DEFAULT 'ACTIVE',
    "created_at" TEXT,
    "created_by" TEXT,

    CONSTRAINT "payment_terms_pkey" PRIMARY KEY ("id")
);
CREATE UNIQUE INDEX "payment_terms_code_key" ON "payment_terms"("code");

-- CreateTable: Payment Method (BC Table 289).
CREATE TABLE "payment_method" (
    "id" SERIAL NOT NULL,
    "code" TEXT NOT NULL,
    "description" TEXT NOT NULL,
    "bal_account_type" TEXT NOT NULL DEFAULT 'None',
    "bal_account_no" TEXT,
    "status" TEXT NOT NULL DEFAULT 'ACTIVE',
    "created_at" TEXT,
    "created_by" TEXT,

    CONSTRAINT "payment_method_pkey" PRIMARY KEY ("id")
);
CREATE UNIQUE INDEX "payment_method_code_key" ON "payment_method"("code");

-- CreateTable: Reminder Terms (BC Table 293).
CREATE TABLE "reminder_terms" (
    "id" SERIAL NOT NULL,
    "code" TEXT NOT NULL,
    "description" TEXT NOT NULL,
    "max_no_of_reminders" INTEGER NOT NULL DEFAULT 3,
    "post_interest" INTEGER NOT NULL DEFAULT 0,
    "post_additional_fee" INTEGER NOT NULL DEFAULT 0,
    "min_amount" BIGINT NOT NULL DEFAULT 0,
    "dont_remind_on_hold" INTEGER NOT NULL DEFAULT 1,
    "status" TEXT NOT NULL DEFAULT 'ACTIVE',
    "created_at" TEXT,
    "created_by" TEXT,

    CONSTRAINT "reminder_terms_pkey" PRIMARY KEY ("id")
);
CREATE UNIQUE INDEX "reminder_terms_code_key" ON "reminder_terms"("code");

-- CreateTable: Reminder Level (BC Table 294).
CREATE TABLE "reminder_level" (
    "id" SERIAL NOT NULL,
    "reminder_terms_code" TEXT NOT NULL,
    "level_no" INTEGER NOT NULL,
    "grace_period" TEXT NOT NULL DEFAULT '',
    "due_date_calculation" TEXT NOT NULL DEFAULT '',
    "calculate_interest" INTEGER NOT NULL DEFAULT 0,
    "additional_fee" BIGINT NOT NULL DEFAULT 0,
    "add_fee_per_line" BIGINT NOT NULL DEFAULT 0,
    "begin_text" TEXT,
    "end_text" TEXT,

    CONSTRAINT "reminder_level_pkey" PRIMARY KEY ("id")
);
CREATE UNIQUE INDEX "reminder_level_terms_level_key" ON "reminder_level"("reminder_terms_code", "level_no");
ALTER TABLE "reminder_level" ADD CONSTRAINT "reminder_level_terms_fkey" FOREIGN KEY ("reminder_terms_code") REFERENCES "reminder_terms"("code") ON DELETE CASCADE ON UPDATE NO ACTION;

-- CreateTable: Finance Charge Terms (BC Table 5).
CREATE TABLE "finance_charge_terms" (
    "id" SERIAL NOT NULL,
    "code" TEXT NOT NULL,
    "description" TEXT NOT NULL,
    "interest_rate" DOUBLE PRECISION NOT NULL DEFAULT 0,
    "min_amount" BIGINT NOT NULL DEFAULT 0,
    "additional_fee" BIGINT NOT NULL DEFAULT 0,
    "grace_period" TEXT NOT NULL DEFAULT '',
    "due_date_calculation" TEXT NOT NULL DEFAULT '',
    "interest_period_days" INTEGER NOT NULL DEFAULT 360,
    "interest_calculation_method" TEXT NOT NULL DEFAULT 'Balance Due',
    "post_interest" INTEGER NOT NULL DEFAULT 1,
    "post_additional_fee" INTEGER NOT NULL DEFAULT 1,
    "line_description" TEXT NOT NULL DEFAULT 'Finance Charge',
    "begin_text" TEXT,
    "end_text" TEXT,
    "status" TEXT NOT NULL DEFAULT 'ACTIVE',
    "created_at" TEXT,
    "created_by" TEXT,

    CONSTRAINT "finance_charge_terms_pkey" PRIMARY KEY ("id")
);
CREATE UNIQUE INDEX "finance_charge_terms_code_key" ON "finance_charge_terms"("code");

-- CreateTable: Sales & Receivables Setup (BC Table 311) — singleton (id is always 1).
CREATE TABLE "sales_receivables_setup" (
    "id" INTEGER NOT NULL DEFAULT 1,
    "default_customer_posting_group_code" TEXT,
    "default_payment_terms_code" TEXT,
    "default_reminder_terms_code" TEXT,
    "default_fin_charge_terms_code" TEXT,
    "stockout_warning" INTEGER NOT NULL DEFAULT 1,
    "credit_warnings" TEXT NOT NULL DEFAULT 'Both',
    "invoice_rounding" INTEGER NOT NULL DEFAULT 0,
    "invoice_rounding_precision" BIGINT NOT NULL DEFAULT 0,
    "allow_receivables_posting_from" TEXT,
    "allow_receivables_posting_to" TEXT,
    "updated_at" TEXT,
    "updated_by" TEXT,

    CONSTRAINT "sales_receivables_setup_pkey" PRIMARY KEY ("id")
);

-- ==================================================================================== customer

-- CreateTable: Customer (BC Table 18).
CREATE TABLE "customer" (
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
    "customer_posting_group_code" TEXT,
    "payment_terms_code" TEXT,
    "payment_method_code" TEXT,
    "reminder_terms_code" TEXT,
    "fin_charge_terms_code" TEXT,
    "salesperson" TEXT,
    "credit_limit" BIGINT NOT NULL DEFAULT 0,
    "blocked" TEXT NOT NULL DEFAULT '',
    "global_dimension_1_id" INTEGER,
    "global_dimension_2_id" INTEGER,
    "balance" BIGINT NOT NULL DEFAULT 0,
    "last_statement_no" INTEGER NOT NULL DEFAULT 0,
    "created_at" TEXT,
    "created_by" TEXT,

    CONSTRAINT "customer_pkey" PRIMARY KEY ("id")
);
CREATE UNIQUE INDEX "customer_no_key" ON "customer"("no");
CREATE INDEX "ix_customer_posting_group" ON "customer"("customer_posting_group_code");

-- ============================================================================ sales documents

-- CreateTable: Sales Header (BC Table 36).
CREATE TABLE "sales_header" (
    "id" SERIAL NOT NULL,
    "document_type" TEXT NOT NULL,
    "no" TEXT NOT NULL,
    "customer_id" INTEGER NOT NULL,
    "sell_to_name" TEXT,
    "sell_to_address" TEXT,
    "sell_to_city" TEXT,
    "sell_to_contact" TEXT,
    "posting_date" TEXT NOT NULL,
    "document_date" TEXT NOT NULL,
    "due_date" TEXT,
    "payment_terms_code" TEXT,
    "payment_method_code" TEXT,
    "customer_posting_group_code" TEXT,
    "your_reference" TEXT,
    "salesperson" TEXT,
    "global_dimension_1_id" INTEGER,
    "global_dimension_2_id" INTEGER,
    "status" TEXT NOT NULL DEFAULT 'Open',
    "amount" BIGINT NOT NULL DEFAULT 0,
    "decision_reason" TEXT,
    "created_at" TEXT,
    "created_by" TEXT,

    CONSTRAINT "sales_header_pkey" PRIMARY KEY ("id")
);
CREATE UNIQUE INDEX "sales_header_no_key" ON "sales_header"("no");
CREATE INDEX "ix_sales_header_type_status" ON "sales_header"("document_type", "status");
CREATE INDEX "ix_sales_header_customer" ON "sales_header"("customer_id");
CREATE INDEX "ix_sales_header_created_by" ON "sales_header"("created_by");
ALTER TABLE "sales_header" ADD CONSTRAINT "sales_header_customer_fkey" FOREIGN KEY ("customer_id") REFERENCES "customer"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- CreateTable: Sales Line (BC Table 37).
CREATE TABLE "sales_line" (
    "id" SERIAL NOT NULL,
    "sales_header_id" INTEGER NOT NULL,
    "line_no" INTEGER NOT NULL,
    "type" TEXT NOT NULL DEFAULT 'G/L Account',
    "no" TEXT,
    "description" TEXT,
    "quantity" DOUBLE PRECISION NOT NULL DEFAULT 0,
    "unit_price" BIGINT NOT NULL DEFAULT 0,
    "line_discount_pct" DOUBLE PRECISION NOT NULL DEFAULT 0,
    "line_discount_amount" BIGINT NOT NULL DEFAULT 0,
    "line_amount" BIGINT NOT NULL DEFAULT 0,
    "qty_to_ship" DOUBLE PRECISION NOT NULL DEFAULT 0,
    "qty_shipped" DOUBLE PRECISION NOT NULL DEFAULT 0,
    "qty_to_invoice" DOUBLE PRECISION NOT NULL DEFAULT 0,
    "qty_invoiced" DOUBLE PRECISION NOT NULL DEFAULT 0,
    "location_code" TEXT,
    "fa_depreciation_book_code" TEXT,
    "depr_until_date" TEXT,
    "global_dimension_1_id" INTEGER,
    "global_dimension_2_id" INTEGER,

    CONSTRAINT "sales_line_pkey" PRIMARY KEY ("id")
);
CREATE UNIQUE INDEX "sales_line_header_lineno_key" ON "sales_line"("sales_header_id", "line_no");
ALTER TABLE "sales_line" ADD CONSTRAINT "sales_line_header_fkey" FOREIGN KEY ("sales_header_id") REFERENCES "sales_header"("id") ON DELETE CASCADE ON UPDATE NO ACTION;

-- CreateTable: Posted Sales Document (consolidated Shipment / Invoice / Credit Memo header).
CREATE TABLE "posted_sales_document" (
    "id" SERIAL NOT NULL,
    "document_type" TEXT NOT NULL,
    "no" TEXT NOT NULL,
    "customer_id" INTEGER NOT NULL,
    "sell_to_name" TEXT,
    "sell_to_address" TEXT,
    "sell_to_city" TEXT,
    "sell_to_contact" TEXT,
    "posting_date" TEXT NOT NULL,
    "document_date" TEXT NOT NULL,
    "due_date" TEXT,
    "order_no" TEXT,
    "payment_terms_code" TEXT,
    "your_reference" TEXT,
    "amount" BIGINT NOT NULL DEFAULT 0,
    "cust_ledger_entry_id" INTEGER,
    "journal_id" INTEGER,
    "created_at" TEXT,
    "created_by" TEXT,

    CONSTRAINT "posted_sales_document_pkey" PRIMARY KEY ("id")
);
CREATE UNIQUE INDEX "posted_sales_document_no_key" ON "posted_sales_document"("no");
CREATE INDEX "ix_psd_customer" ON "posted_sales_document"("customer_id");
CREATE INDEX "ix_psd_type" ON "posted_sales_document"("document_type");
ALTER TABLE "posted_sales_document" ADD CONSTRAINT "psd_customer_fkey" FOREIGN KEY ("customer_id") REFERENCES "customer"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- CreateTable: Posted Sales Line.
CREATE TABLE "posted_sales_line" (
    "id" SERIAL NOT NULL,
    "posted_sales_document_id" INTEGER NOT NULL,
    "line_no" INTEGER NOT NULL,
    "type" TEXT NOT NULL,
    "no" TEXT,
    "description" TEXT,
    "quantity" DOUBLE PRECISION NOT NULL DEFAULT 0,
    "unit_price" BIGINT NOT NULL DEFAULT 0,
    "line_discount_amount" BIGINT NOT NULL DEFAULT 0,
    "line_amount" BIGINT NOT NULL DEFAULT 0,
    "cogs_amount" BIGINT NOT NULL DEFAULT 0,
    "item_ledger_entry_id" INTEGER,
    "fa_ledger_entry_id" INTEGER,

    CONSTRAINT "posted_sales_line_pkey" PRIMARY KEY ("id")
);
CREATE INDEX "ix_psl_doc" ON "posted_sales_line"("posted_sales_document_id");
ALTER TABLE "posted_sales_line" ADD CONSTRAINT "psl_doc_fkey" FOREIGN KEY ("posted_sales_document_id") REFERENCES "posted_sales_document"("id") ON DELETE CASCADE ON UPDATE NO ACTION;

-- =========================================================================== customer subledger

-- CreateTable: Cust. Ledger Entry (BC Table 21).
CREATE TABLE "cust_ledger_entry" (
    "id" SERIAL NOT NULL,
    "customer_id" INTEGER NOT NULL,
    "posting_date" TEXT NOT NULL,
    "document_type" TEXT NOT NULL,
    "document_no" TEXT NOT NULL,
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
    "reminder_level" INTEGER NOT NULL DEFAULT 0,
    "calculate_interest" INTEGER NOT NULL DEFAULT 0,
    "source_type" TEXT,
    "source_id" INTEGER,
    "journal_id" INTEGER,
    "created_at" TEXT,

    CONSTRAINT "cust_ledger_entry_pkey" PRIMARY KEY ("id")
);
CREATE INDEX "ix_cle_customer_open" ON "cust_ledger_entry"("customer_id", "open");
CREATE INDEX "ix_cle_due_date" ON "cust_ledger_entry"("due_date");
CREATE INDEX "ix_cle_document_no" ON "cust_ledger_entry"("document_no");
ALTER TABLE "cust_ledger_entry" ADD CONSTRAINT "cle_customer_fkey" FOREIGN KEY ("customer_id") REFERENCES "customer"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- CreateTable: Detailed Cust. Ledger Entry (BC Table 379).
CREATE TABLE "detailed_cust_ledger_entry" (
    "id" SERIAL NOT NULL,
    "cust_ledger_entry_id" INTEGER NOT NULL,
    "entry_type" TEXT NOT NULL,
    "posting_date" TEXT NOT NULL,
    "document_type" TEXT,
    "document_no" TEXT,
    "amount" BIGINT NOT NULL DEFAULT 0,
    "applied_cust_ledger_entry_id" INTEGER,
    "journal_id" INTEGER,
    "unapplied" INTEGER NOT NULL DEFAULT 0,
    "unapplied_by_entry_id" INTEGER,
    "created_at" TEXT,

    CONSTRAINT "detailed_cust_ledger_entry_pkey" PRIMARY KEY ("id")
);
CREATE INDEX "ix_dcle_cle" ON "detailed_cust_ledger_entry"("cust_ledger_entry_id");
CREATE INDEX "ix_dcle_applied" ON "detailed_cust_ledger_entry"("applied_cust_ledger_entry_id");
ALTER TABLE "detailed_cust_ledger_entry" ADD CONSTRAINT "dcle_cle_fkey" FOREIGN KEY ("cust_ledger_entry_id") REFERENCES "cust_ledger_entry"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- ========================================================================= cash receipt journal

-- CreateTable: Cash Receipt Header (a maker-checker Gen. Journal batch of customer payments).
CREATE TABLE "cash_receipt_header" (
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

    CONSTRAINT "cash_receipt_header_pkey" PRIMARY KEY ("id")
);
CREATE UNIQUE INDEX "cash_receipt_header_no_key" ON "cash_receipt_header"("no");
CREATE INDEX "ix_crh_status" ON "cash_receipt_header"("status");
CREATE INDEX "ix_crh_created_by" ON "cash_receipt_header"("created_by");
ALTER TABLE "cash_receipt_header" ADD CONSTRAINT "crh_bank_account_fkey" FOREIGN KEY ("bank_account_id") REFERENCES "bank_account"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- CreateTable: Cash Receipt Line.
CREATE TABLE "cash_receipt_line" (
    "id" SERIAL NOT NULL,
    "cash_receipt_header_id" INTEGER NOT NULL,
    "line_no" INTEGER NOT NULL,
    "customer_id" INTEGER NOT NULL,
    "amount" BIGINT NOT NULL DEFAULT 0,
    "payment_method_code" TEXT,
    "document_no" TEXT,
    "applies_to_doc_no" TEXT,
    "external_document_no" TEXT,
    "description" TEXT,

    CONSTRAINT "cash_receipt_line_pkey" PRIMARY KEY ("id")
);
CREATE UNIQUE INDEX "cash_receipt_line_header_lineno_key" ON "cash_receipt_line"("cash_receipt_header_id", "line_no");
ALTER TABLE "cash_receipt_line" ADD CONSTRAINT "crl_header_fkey" FOREIGN KEY ("cash_receipt_header_id") REFERENCES "cash_receipt_header"("id") ON DELETE CASCADE ON UPDATE NO ACTION;
ALTER TABLE "cash_receipt_line" ADD CONSTRAINT "crl_customer_fkey" FOREIGN KEY ("customer_id") REFERENCES "customer"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- ================================================================ reminders & finance charge memos

-- CreateTable: Reminder Header (BC Table 295 / 302 — consolidated, flips Open -> Issued in place).
CREATE TABLE "reminder_header" (
    "id" SERIAL NOT NULL,
    "document_type" TEXT NOT NULL DEFAULT 'Reminder',
    "no" TEXT NOT NULL,
    "customer_id" INTEGER NOT NULL,
    "posting_date" TEXT NOT NULL,
    "document_date" TEXT NOT NULL,
    "due_date" TEXT,
    "reminder_terms_code" TEXT,
    "fin_charge_terms_code" TEXT,
    "reminder_level" INTEGER NOT NULL DEFAULT 1,
    "customer_posting_group_code" TEXT,
    "use_header_level" INTEGER NOT NULL DEFAULT 1,
    "status" TEXT NOT NULL DEFAULT 'Open',
    "remaining_amount" BIGINT NOT NULL DEFAULT 0,
    "interest_amount" BIGINT NOT NULL DEFAULT 0,
    "additional_fee" BIGINT NOT NULL DEFAULT 0,
    "total_amount" BIGINT NOT NULL DEFAULT 0,
    "decision_reason" TEXT,
    "journal_id" INTEGER,
    "cust_ledger_entry_id" INTEGER,
    "issued_at" TEXT,
    "issued_by" TEXT,
    "created_at" TEXT,
    "created_by" TEXT,

    CONSTRAINT "reminder_header_pkey" PRIMARY KEY ("id")
);
CREATE UNIQUE INDEX "reminder_header_no_key" ON "reminder_header"("no");
CREATE INDEX "ix_rh_status" ON "reminder_header"("status");
CREATE INDEX "ix_rh_customer" ON "reminder_header"("customer_id");
ALTER TABLE "reminder_header" ADD CONSTRAINT "rh_customer_fkey" FOREIGN KEY ("customer_id") REFERENCES "customer"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- CreateTable: Reminder Line (BC Table 296 / 303).
CREATE TABLE "reminder_line" (
    "id" SERIAL NOT NULL,
    "reminder_header_id" INTEGER NOT NULL,
    "line_no" INTEGER NOT NULL,
    "type" TEXT NOT NULL DEFAULT 'Reminder Line',
    "cust_ledger_entry_id" INTEGER,
    "entry_document_type" TEXT,
    "entry_document_no" TEXT,
    "due_date" TEXT,
    "original_amount" BIGINT NOT NULL DEFAULT 0,
    "remaining_amount" BIGINT NOT NULL DEFAULT 0,
    "no" TEXT,
    "amount" BIGINT NOT NULL DEFAULT 0,
    "description" TEXT,
    "line_type" TEXT NOT NULL DEFAULT '',

    CONSTRAINT "reminder_line_pkey" PRIMARY KEY ("id")
);
CREATE UNIQUE INDEX "reminder_line_header_lineno_key" ON "reminder_line"("reminder_header_id", "line_no");
ALTER TABLE "reminder_line" ADD CONSTRAINT "rl_header_fkey" FOREIGN KEY ("reminder_header_id") REFERENCES "reminder_header"("id") ON DELETE CASCADE ON UPDATE NO ACTION;

-- ================================================================================ alter existing

-- Item lines on a sales document write an item_ledger_entry with no owning item_journal_line.
ALTER TABLE "item_ledger_entry" ALTER COLUMN "item_journal_line_id" DROP NOT NULL;

-- BC's Gen. Prod. Posting Group carries separate Sales and COGS accounts; this port folds them
-- onto product_posting_group (the "subledger side" group an Item already points at).
ALTER TABLE "product_posting_group" ADD COLUMN "sales_gl_account_id" INTEGER;
ALTER TABLE "product_posting_group" ADD COLUMN "cogs_gl_account_id" INTEGER;
ALTER TABLE "product_posting_group" ADD CONSTRAINT "ppg_sales_gl_fkey" FOREIGN KEY ("sales_gl_account_id") REFERENCES "gl_account"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE "product_posting_group" ADD CONSTRAINT "ppg_cogs_gl_fkey" FOREIGN KEY ("cogs_gl_account_id") REFERENCES "gl_account"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- ============================================================================== data back-fill

-- Chart of accounts.
INSERT INTO "gl_account" ("code", "name", "type", "parent_code", "is_postable", "account_type")
SELECT v.code, v.name, v.type, v.parent_code, v.is_postable, v.account_type
FROM (VALUES
  ('1240', 'TRADE AND OTHER RECEIVABLES', 'ASSET', NULL, 0, 'HEADING'),
  ('1250', 'Trade Receivables — Customers', 'ASSET', '1240', 1, 'POSTING'),
  ('4090', 'SALES AND SERVICE INCOME', 'INCOME', NULL, 0, 'HEADING'),
  ('4092', 'Rental Income', 'INCOME', '4090', 1, 'POSTING'),
  ('4094', 'Service and Sundry Income', 'INCOME', '4090', 1, 'POSTING'),
  ('4096', 'Merchandise Sales', 'INCOME', '4090', 1, 'POSTING'),
  ('4098', 'Interest on Overdue Receivables', 'INCOME', '4090', 1, 'POSTING'),
  ('4099', 'Late Payment and Reminder Fees', 'INCOME', '4090', 1, 'POSTING'),
  ('5090', 'Cost of Goods Sold', 'EXPENSE', '5000', 1, 'POSTING')
) AS v(code, name, type, parent_code, is_postable, account_type)
WHERE EXISTS (SELECT 1 FROM "organisation")
ON CONFLICT ("code") DO NOTHING;

-- 1250 is the Customer Posting Group control account — like the bank / savings / loan control
-- accounts, block it from a manual G/L journal line.
UPDATE "gl_account" SET "no_direct_posting" = 1
WHERE "code" = '1250' AND EXISTS (SELECT 1 FROM "organisation");

-- product_posting_group sales / COGS back-fill (existing inventory groups).
UPDATE "product_posting_group" SET
  "sales_gl_account_id" = (SELECT id FROM "gl_account" WHERE code = '4096'),
  "cogs_gl_account_id"  = (SELECT id FROM "gl_account" WHERE code = '5090')
WHERE "sales_gl_account_id" IS NULL AND EXISTS (SELECT 1 FROM "organisation");

-- Document number sequences (fallback for nextSequence() until placed on a No. Series).
INSERT INTO "sequence" ("name", "prefix", "next_no", "width")
SELECT * FROM (VALUES
  ('CUSTOMER', 'C', 1001, 5),
  ('SALES_QUOTE', 'SQ', 1, 6),
  ('SALES_ORDER', 'SO', 1, 6),
  ('SALES_INVOICE', 'SI', 1, 6),
  ('SALES_CREDIT_MEMO', 'SM', 1, 6),
  ('POSTED_SALES_SHIPMENT', 'PSHP', 1, 6),
  ('POSTED_SALES_INVOICE', 'PSI', 1, 6),
  ('POSTED_SALES_CREDIT_MEMO', 'PSM', 1, 6),
  ('CASH_RECEIPT', 'CR', 1, 6),
  ('REMINDER', 'REM', 1, 6),
  ('FIN_CHARGE_MEMO', 'FCM', 1, 6)
) AS v(name, prefix, next_no, width)
WHERE EXISTS (SELECT 1 FROM "organisation")
ON CONFLICT ("name") DO NOTHING;

-- No. Series (header + one open line + Admin Centre assignment row).
INSERT INTO "no_series" ("code", "description", "default_nos", "manual_nos", "date_order")
SELECT v.code, v.description, 1, 0, 0
FROM (VALUES
  ('CUSTOMER', 'Customer No.'),
  ('SALES_QUOTE', 'Sales Quote No.'),
  ('SALES_ORDER', 'Sales Order No.'),
  ('SALES_INVOICE', 'Sales Invoice No.'),
  ('SALES_CREDIT_MEMO', 'Sales Credit Memo No.'),
  ('POSTED_SALES_SHIPMENT', 'Posted Sales Shipment No.'),
  ('POSTED_SALES_INVOICE', 'Posted Sales Invoice No.'),
  ('POSTED_SALES_CREDIT_MEMO', 'Posted Sales Credit Memo No.'),
  ('CASH_RECEIPT', 'Cash Receipt No.'),
  ('REMINDER', 'Reminder No.'),
  ('FIN_CHARGE_MEMO', 'Finance Charge Memo No.')
) AS v(code, description)
WHERE EXISTS (SELECT 1 FROM "organisation")
ON CONFLICT ("code") DO NOTHING;

INSERT INTO "no_series_line" ("series_code", "line_no", "starting_date", "starting_no", "increment_by_no", "open", "allow_gaps")
SELECT s.name, 10000, NULL, s.prefix || LPAD(s.next_no::text, s.width, '0'), 1, 1, 0
FROM "sequence" s
WHERE s.name IN ('CUSTOMER','SALES_QUOTE','SALES_ORDER','SALES_INVOICE','SALES_CREDIT_MEMO','POSTED_SALES_SHIPMENT','POSTED_SALES_INVOICE','POSTED_SALES_CREDIT_MEMO','CASH_RECEIPT','REMINDER','FIN_CHARGE_MEMO')
  AND EXISTS (SELECT 1 FROM "organisation")
  AND NOT EXISTS (SELECT 1 FROM "no_series_line" l WHERE l.series_code = s.name);

INSERT INTO "no_series_setup" ("document_code", "label", "category", "sort", "series_code")
SELECT v.code, v.label, 'Receivables', v.sort, v.code
FROM (VALUES
  ('CUSTOMER', 'Customer No.', 40),
  ('SALES_QUOTE', 'Sales Quote No.', 41),
  ('SALES_ORDER', 'Sales Order No.', 42),
  ('SALES_INVOICE', 'Sales Invoice No.', 43),
  ('SALES_CREDIT_MEMO', 'Sales Credit Memo No.', 44),
  ('POSTED_SALES_SHIPMENT', 'Posted Sales Shipment No.', 45),
  ('POSTED_SALES_INVOICE', 'Posted Sales Invoice No.', 46),
  ('POSTED_SALES_CREDIT_MEMO', 'Posted Sales Credit Memo No.', 47),
  ('CASH_RECEIPT', 'Cash Receipt No.', 48),
  ('REMINDER', 'Reminder No.', 49),
  ('FIN_CHARGE_MEMO', 'Finance Charge Memo No.', 50)
) AS v(code, label, sort)
WHERE EXISTS (SELECT 1 FROM "organisation")
ON CONFLICT ("document_code") DO NOTHING;

-- Setup masters.
INSERT INTO "payment_terms" ("code", "description", "due_date_calculation", "discount_date_calculation", "discount_pct")
SELECT * FROM (VALUES
  ('COD', 'Cash on Delivery', '0D', '', 0),
  ('14 DAYS', 'Net 14 days', '14D', '', 0),
  ('30 DAYS', 'Net 30 days', '30D', '', 0),
  ('1M(8D)', 'Net 1 month, 2% 8 days', '1M', '8D', 2)
) AS v(code, description, due_date_calculation, discount_date_calculation, discount_pct)
WHERE EXISTS (SELECT 1 FROM "organisation")
ON CONFLICT ("code") DO NOTHING;

INSERT INTO "payment_method" ("code", "description", "bal_account_type", "bal_account_no")
SELECT * FROM (VALUES
  ('CASH', 'Cash', 'Bank Account', 'CASH'),
  ('BANK', 'Bank Transfer', 'Bank Account', 'BANK'),
  ('MPESA', 'M-Pesa', 'Bank Account', 'MPESA'),
  ('CHEQUE', 'Cheque', 'None', NULL)
) AS v(code, description, bal_account_type, bal_account_no)
WHERE EXISTS (SELECT 1 FROM "organisation")
ON CONFLICT ("code") DO NOTHING;

INSERT INTO "customer_posting_group" (
  "code", "description", "receivables_account_id", "service_charge_account_id", "additional_fee_account_id",
  "payment_disc_debit_account_id", "payment_disc_credit_account_id", "invoice_rounding_account_id"
)
SELECT v.code, v.description,
  (SELECT id FROM "gl_account" WHERE code = '1250'),
  (SELECT id FROM "gl_account" WHERE code = '4098'),
  (SELECT id FROM "gl_account" WHERE code = '4099'),
  (SELECT id FROM "gl_account" WHERE code = '5030'),
  (SELECT id FROM "gl_account" WHERE code = '4050'),
  (SELECT id FROM "gl_account" WHERE code = '4050')
FROM (VALUES
  ('TRADE', 'Trade Debtors'),
  ('TENANT', 'Tenants')
) AS v(code, description)
WHERE EXISTS (SELECT 1 FROM "organisation")
ON CONFLICT ("code") DO NOTHING;

INSERT INTO "reminder_terms" ("code", "description", "max_no_of_reminders", "post_interest", "post_additional_fee", "min_amount")
SELECT 'DOMESTIC', 'Domestic Reminders', 3, 1, 1, 10000
WHERE EXISTS (SELECT 1 FROM "organisation")
ON CONFLICT ("code") DO NOTHING;

INSERT INTO "reminder_level" ("reminder_terms_code", "level_no", "grace_period", "due_date_calculation", "calculate_interest", "additional_fee", "add_fee_per_line", "begin_text", "end_text")
SELECT v.terms, v.lvl, v.grace, v.due, v.interest, v.fee, v.perline, v.btext, v.etext
FROM (VALUES
  ('DOMESTIC', 1, '7D', '7D', 0, 0, 0, 'Our records show the following amounts as overdue. Please arrange payment.', 'If payment has already been made, please disregard this reminder.'),
  ('DOMESTIC', 2, '7D', '7D', 1, 50000, 0, 'This is our second reminder. The overdue amounts below now attract interest.', 'Please settle immediately to avoid further charges.'),
  ('DOMESTIC', 3, '7D', '7D', 1, 100000, 0, 'FINAL REMINDER. The account will be referred for collection if not settled.', 'Contact us immediately to make arrangements.')
) AS v(terms, lvl, grace, due, interest, fee, perline, btext, etext)
WHERE EXISTS (SELECT 1 FROM "organisation")
ON CONFLICT ("reminder_terms_code", "level_no") DO NOTHING;

INSERT INTO "finance_charge_terms" ("code", "description", "interest_rate", "min_amount", "additional_fee", "grace_period", "due_date_calculation", "interest_period_days", "post_interest", "post_additional_fee", "line_description")
SELECT '1.5%', '1.5% per month on overdue balances', 18.0, 10000, 0, '0D', '14D', 360, 1, 0, 'Finance charge on overdue balance'
WHERE EXISTS (SELECT 1 FROM "organisation")
ON CONFLICT ("code") DO NOTHING;

INSERT INTO "sales_receivables_setup" ("id", "default_customer_posting_group_code", "default_payment_terms_code", "default_reminder_terms_code", "default_fin_charge_terms_code", "updated_at", "updated_by")
SELECT 1, 'TRADE', '30 DAYS', 'DOMESTIC', '1.5%', NOW()::text, 'system'
WHERE EXISTS (SELECT 1 FROM "organisation")
ON CONFLICT ("id") DO NOTHING;

-- Permission backfill for the seeded roles (keyed by name; on a fresh DB no roles exist yet so
-- this JOIN inserts nothing and lib/seed.ts's expandActionsToLines() owns the grants).
INSERT INTO "permission_set_line"
  ("role_id", "object_type", "object_name", "read_perm", "insert_perm", "modify_perm", "delete_perm", "execute_perm")
SELECT r.id, g.object_type, g.object_name, g.r, g.i, g.m, g.d, g.e
FROM "role" r
JOIN (VALUES
  ('Branch Manager',  'PAGE',  'RECEIVABLES',                0,0,0,0,1),
  ('Branch Manager',  'TABLE', 'customer',                   1,0,0,0,0),
  ('Branch Manager',  'TABLE', 'sales_header',               1,0,1,0,0),
  ('Branch Manager',  'TABLE', 'sales_line',                 1,0,0,0,0),
  ('Branch Manager',  'TABLE', 'cust_ledger_entry',          1,0,0,0,0),
  ('Branch Manager',  'TABLE', 'posted_sales_document',      1,0,0,0,0),
  ('Branch Manager',  'TABLE', 'cash_receipt_header',        1,0,0,0,0),
  ('Branch Manager',  'TABLE', 'reminder_header',            1,0,0,0,0),
  ('Finance Officer', 'PAGE',  'RECEIVABLES',                0,0,0,0,1),
  ('Finance Officer', 'TABLE', 'customer',                   1,1,1,1,0),
  ('Finance Officer', 'TABLE', 'customer_posting_group',     1,1,1,1,0),
  ('Finance Officer', 'TABLE', 'payment_terms',              1,1,1,1,0),
  ('Finance Officer', 'TABLE', 'payment_method',             1,1,1,1,0),
  ('Finance Officer', 'TABLE', 'reminder_terms',             1,1,1,1,0),
  ('Finance Officer', 'TABLE', 'reminder_level',             1,1,1,1,0),
  ('Finance Officer', 'TABLE', 'finance_charge_terms',       1,1,1,1,0),
  ('Finance Officer', 'TABLE', 'sales_receivables_setup',    1,1,1,0,0),
  ('Finance Officer', 'TABLE', 'sales_header',               1,1,1,1,0),
  ('Finance Officer', 'TABLE', 'sales_line',                 1,1,1,1,0),
  ('Finance Officer', 'TABLE', 'posted_sales_document',      1,1,0,0,0),
  ('Finance Officer', 'TABLE', 'posted_sales_line',          1,1,0,0,0),
  ('Finance Officer', 'TABLE', 'cust_ledger_entry',          1,1,1,0,0),
  ('Finance Officer', 'TABLE', 'detailed_cust_ledger_entry', 1,1,1,0,0),
  ('Finance Officer', 'TABLE', 'cash_receipt_header',        1,1,1,1,0),
  ('Finance Officer', 'TABLE', 'cash_receipt_line',          1,1,1,1,0),
  ('Finance Officer', 'TABLE', 'reminder_header',            1,1,1,1,0),
  ('Finance Officer', 'TABLE', 'reminder_line',              1,1,1,1,0),
  ('Finance Officer', 'TABLE', 'item_ledger_entry',          1,1,1,0,0),
  ('Finance Officer', 'TABLE', 'item_application_entry',     1,1,0,0,0),
  ('Finance Officer', 'TABLE', 'stockkeeping_unit',          1,1,1,0,0),
  ('Finance Officer', 'TABLE', 'fa_ledger_entry',            1,1,0,0,0),
  ('Finance Officer', 'TABLE', 'fa_depreciation_book',       1,1,1,0,0),
  ('Finance Officer', 'TABLE', 'fixed_asset',                1,1,1,0,0),
  ('Finance Officer', 'TABLE', 'journal',                    0,1,0,0,0),
  ('Finance Officer', 'TABLE', 'journal_line',               0,1,0,0,0),
  ('Finance Officer', 'TABLE', 'workflow_task',              0,1,1,0,0),
  ('Finance Officer', 'TABLE', 'gl_account',                 1,0,0,0,0),
  ('Internal Auditor','PAGE',  'RECEIVABLES',                0,0,0,0,1),
  ('Internal Auditor','TABLE', 'customer',                   1,0,0,0,0),
  ('Internal Auditor','TABLE', 'customer_posting_group',     1,0,0,0,0),
  ('Internal Auditor','TABLE', 'payment_terms',              1,0,0,0,0),
  ('Internal Auditor','TABLE', 'payment_method',             1,0,0,0,0),
  ('Internal Auditor','TABLE', 'reminder_terms',             1,0,0,0,0),
  ('Internal Auditor','TABLE', 'reminder_level',             1,0,0,0,0),
  ('Internal Auditor','TABLE', 'finance_charge_terms',       1,0,0,0,0),
  ('Internal Auditor','TABLE', 'sales_receivables_setup',    1,0,0,0,0),
  ('Internal Auditor','TABLE', 'sales_header',               1,0,0,0,0),
  ('Internal Auditor','TABLE', 'sales_line',                 1,0,0,0,0),
  ('Internal Auditor','TABLE', 'posted_sales_document',      1,0,0,0,0),
  ('Internal Auditor','TABLE', 'posted_sales_line',          1,0,0,0,0),
  ('Internal Auditor','TABLE', 'cust_ledger_entry',          1,0,0,0,0),
  ('Internal Auditor','TABLE', 'detailed_cust_ledger_entry', 1,0,0,0,0),
  ('Internal Auditor','TABLE', 'cash_receipt_header',        1,0,0,0,0),
  ('Internal Auditor','TABLE', 'cash_receipt_line',          1,0,0,0,0),
  ('Internal Auditor','TABLE', 'reminder_header',            1,0,0,0,0),
  ('Internal Auditor','TABLE', 'reminder_line',              1,0,0,0,0)
) AS g(role_name, object_type, object_name, r, i, m, d, e) ON g.role_name = r.name
ON CONFLICT ("role_id", "object_type", "object_name") DO UPDATE SET
  "read_perm"    = GREATEST("permission_set_line"."read_perm",    EXCLUDED."read_perm"),
  "insert_perm"  = GREATEST("permission_set_line"."insert_perm",  EXCLUDED."insert_perm"),
  "modify_perm"  = GREATEST("permission_set_line"."modify_perm",  EXCLUDED."modify_perm"),
  "delete_perm"  = GREATEST("permission_set_line"."delete_perm",  EXCLUDED."delete_perm"),
  "execute_perm" = GREATEST("permission_set_line"."execute_perm", EXCLUDED."execute_perm");
