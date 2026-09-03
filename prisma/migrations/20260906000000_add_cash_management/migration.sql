-- Cash Management (Business Central) under Finance + multi-currency at the trade & treasury
-- boundary. Adds: Currencies + Exchange Rates; Bank Acc. Posting Groups; External Banks/Branches;
-- the BC Bank Reconciliation model (statement no., lines, suggest, transfer-to-G/L, post); the
-- Receipt document (AL Tab52203423/424) with an official-receipt printout; the Payment Voucher
-- document (AL Tab52203439/440) with a voucher slip. Moves nothing at the DB level — Bank Accounts
-- relocate in the UI only.
--
-- Multi-currency: every new *_lcy column and currency_code/currency_factor defaults to KES /
-- factor 1, and every existing postJournal() caller passes no currency, so gl_account.balance and
-- every existing posting path are byte-for-byte unchanged. FCY only differs from LCY on the new
-- Cash Management documents and on AR/AP/Sales/Purchase entries a user explicitly marks foreign.
--
-- Data back-fills guarded by WHERE EXISTS (SELECT 1 FROM organisation) — a fresh DB takes none
-- (lib/seed.ts owns them); an already-seeded DB takes them here so the module works straight
-- after `prisma migrate deploy`.

-- ================================================================= currency (BC T4 / T330)

CREATE TABLE "currency" (
    "id" SERIAL NOT NULL,
    "code" TEXT NOT NULL,
    "description" TEXT NOT NULL,
    "symbol" TEXT,
    "iso_numeric_code" TEXT,
    "is_base" INTEGER NOT NULL DEFAULT 0,
    "amount_rounding_precision" BIGINT NOT NULL DEFAULT 1,
    "invoice_rounding_precision" BIGINT NOT NULL DEFAULT 0,
    "realized_gains_account_id" INTEGER,
    "realized_losses_account_id" INTEGER,
    "unrealized_gains_account_id" INTEGER,
    "unrealized_losses_account_id" INTEGER,
    "residual_gains_account_id" INTEGER,
    "residual_losses_account_id" INTEGER,
    "blocked" INTEGER NOT NULL DEFAULT 0,
    "created_at" TEXT,
    "created_by" TEXT,

    CONSTRAINT "currency_pkey" PRIMARY KEY ("id")
);
CREATE UNIQUE INDEX "currency_code_key" ON "currency"("code");
ALTER TABLE "currency" ADD CONSTRAINT "currency_realized_gains_fkey" FOREIGN KEY ("realized_gains_account_id") REFERENCES "gl_account"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE "currency" ADD CONSTRAINT "currency_realized_losses_fkey" FOREIGN KEY ("realized_losses_account_id") REFERENCES "gl_account"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE "currency" ADD CONSTRAINT "currency_unrealized_gains_fkey" FOREIGN KEY ("unrealized_gains_account_id") REFERENCES "gl_account"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE "currency" ADD CONSTRAINT "currency_unrealized_losses_fkey" FOREIGN KEY ("unrealized_losses_account_id") REFERENCES "gl_account"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE "currency" ADD CONSTRAINT "currency_residual_gains_fkey" FOREIGN KEY ("residual_gains_account_id") REFERENCES "gl_account"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE "currency" ADD CONSTRAINT "currency_residual_losses_fkey" FOREIGN KEY ("residual_losses_account_id") REFERENCES "gl_account"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

CREATE TABLE "currency_exchange_rate" (
    "id" SERIAL NOT NULL,
    "currency_code" TEXT NOT NULL,
    "starting_date" TEXT NOT NULL,
    "exchange_rate_amount" DOUBLE PRECISION NOT NULL DEFAULT 1,
    "relational_exch_rate_amount" DOUBLE PRECISION NOT NULL DEFAULT 1,
    "created_at" TEXT,
    "created_by" TEXT,

    CONSTRAINT "currency_exchange_rate_pkey" PRIMARY KEY ("id")
);
CREATE UNIQUE INDEX "currency_exchange_rate_ccy_date_key" ON "currency_exchange_rate"("currency_code", "starting_date");
ALTER TABLE "currency_exchange_rate" ADD CONSTRAINT "cer_currency_fkey" FOREIGN KEY ("currency_code") REFERENCES "currency"("code") ON DELETE CASCADE ON UPDATE NO ACTION;

-- ============================================================ multi-currency ALTERs (KES / 1)

ALTER TABLE "journal" ADD COLUMN "currency_code" TEXT NOT NULL DEFAULT 'KES';
ALTER TABLE "journal" ADD COLUMN "currency_factor" DOUBLE PRECISION NOT NULL DEFAULT 1;

ALTER TABLE "journal_line" ADD COLUMN "currency_code" TEXT NOT NULL DEFAULT 'KES';
ALTER TABLE "journal_line" ADD COLUMN "currency_factor" DOUBLE PRECISION NOT NULL DEFAULT 1;
ALTER TABLE "journal_line" ADD COLUMN "debit_lcy" BIGINT NOT NULL DEFAULT 0;
ALTER TABLE "journal_line" ADD COLUMN "credit_lcy" BIGINT NOT NULL DEFAULT 0;
UPDATE "journal_line" SET "debit_lcy" = "debit", "credit_lcy" = "credit";

ALTER TABLE "bank_account" ADD COLUMN "currency_code" TEXT NOT NULL DEFAULT 'KES';
ALTER TABLE "bank_account" ADD COLUMN "balance_lcy" BIGINT NOT NULL DEFAULT 0;
UPDATE "bank_account" SET "balance_lcy" = "balance";
ALTER TABLE "bank_account" ADD COLUMN "bank_acc_posting_group_code" TEXT;
ALTER TABLE "bank_account" ADD COLUMN "bank_branch_no" TEXT;
ALTER TABLE "bank_account" ADD COLUMN "bank_sort_code" TEXT;
ALTER TABLE "bank_account" ADD COLUMN "external_bank_code" TEXT;
ALTER TABLE "bank_account" ADD COLUMN "iban" TEXT;
ALTER TABLE "bank_account" ADD COLUMN "swift_code" TEXT;
ALTER TABLE "bank_account" ADD COLUMN "min_balance" BIGINT NOT NULL DEFAULT 0;
ALTER TABLE "bank_account" ADD COLUMN "last_statement_no" INTEGER NOT NULL DEFAULT 0;
ALTER TABLE "bank_account" ADD COLUMN "balance_last_statement" BIGINT NOT NULL DEFAULT 0;
ALTER TABLE "bank_account" ADD COLUMN "blocked" INTEGER NOT NULL DEFAULT 0;

ALTER TABLE "bank_account_ledger_entry" ADD COLUMN "currency_code" TEXT NOT NULL DEFAULT 'KES';
ALTER TABLE "bank_account_ledger_entry" ADD COLUMN "currency_factor" DOUBLE PRECISION NOT NULL DEFAULT 1;
ALTER TABLE "bank_account_ledger_entry" ADD COLUMN "amount_lcy" BIGINT NOT NULL DEFAULT 0;
UPDATE "bank_account_ledger_entry" SET "amount_lcy" = "amount";
ALTER TABLE "bank_account_ledger_entry" ADD COLUMN "document_type" TEXT NOT NULL DEFAULT '';
ALTER TABLE "bank_account_ledger_entry" ADD COLUMN "document_no" TEXT;
ALTER TABLE "bank_account_ledger_entry" ADD COLUMN "external_document_no" TEXT;
ALTER TABLE "bank_account_ledger_entry" ADD COLUMN "open" INTEGER NOT NULL DEFAULT 1;
ALTER TABLE "bank_account_ledger_entry" ADD COLUMN "statement_no" TEXT;
ALTER TABLE "bank_account_ledger_entry" ADD COLUMN "statement_line_no" INTEGER;
ALTER TABLE "bank_account_ledger_entry" ADD COLUMN "reversed" INTEGER NOT NULL DEFAULT 0;
UPDATE "bank_account_ledger_entry" SET "open" = 0 WHERE "reconciled" = 1;

ALTER TABLE "cust_ledger_entry" ADD COLUMN "currency_code" TEXT NOT NULL DEFAULT 'KES';
ALTER TABLE "cust_ledger_entry" ADD COLUMN "currency_factor" DOUBLE PRECISION NOT NULL DEFAULT 1;
ALTER TABLE "cust_ledger_entry" ADD COLUMN "amount_lcy" BIGINT NOT NULL DEFAULT 0;
ALTER TABLE "cust_ledger_entry" ADD COLUMN "remaining_amount_lcy" BIGINT NOT NULL DEFAULT 0;
ALTER TABLE "cust_ledger_entry" ADD COLUMN "original_amount_lcy" BIGINT NOT NULL DEFAULT 0;
UPDATE "cust_ledger_entry" SET "amount_lcy" = "amount", "remaining_amount_lcy" = "remaining_amount", "original_amount_lcy" = "original_amount";

ALTER TABLE "vendor_ledger_entry" ADD COLUMN "currency_code" TEXT NOT NULL DEFAULT 'KES';
ALTER TABLE "vendor_ledger_entry" ADD COLUMN "currency_factor" DOUBLE PRECISION NOT NULL DEFAULT 1;
ALTER TABLE "vendor_ledger_entry" ADD COLUMN "amount_lcy" BIGINT NOT NULL DEFAULT 0;
ALTER TABLE "vendor_ledger_entry" ADD COLUMN "remaining_amount_lcy" BIGINT NOT NULL DEFAULT 0;
ALTER TABLE "vendor_ledger_entry" ADD COLUMN "original_amount_lcy" BIGINT NOT NULL DEFAULT 0;
UPDATE "vendor_ledger_entry" SET "amount_lcy" = "amount", "remaining_amount_lcy" = "remaining_amount", "original_amount_lcy" = "original_amount";

ALTER TABLE "detailed_cust_ledger_entry" ADD COLUMN "amount_lcy" BIGINT NOT NULL DEFAULT 0;
UPDATE "detailed_cust_ledger_entry" SET "amount_lcy" = "amount";
ALTER TABLE "detailed_vendor_ledger_entry" ADD COLUMN "amount_lcy" BIGINT NOT NULL DEFAULT 0;
UPDATE "detailed_vendor_ledger_entry" SET "amount_lcy" = "amount";

ALTER TABLE "sales_header" ADD COLUMN "currency_code" TEXT NOT NULL DEFAULT 'KES';
ALTER TABLE "sales_header" ADD COLUMN "currency_factor" DOUBLE PRECISION NOT NULL DEFAULT 1;
ALTER TABLE "posted_sales_document" ADD COLUMN "currency_code" TEXT NOT NULL DEFAULT 'KES';
ALTER TABLE "posted_sales_document" ADD COLUMN "currency_factor" DOUBLE PRECISION NOT NULL DEFAULT 1;
ALTER TABLE "purchase_header" ADD COLUMN "currency_code" TEXT NOT NULL DEFAULT 'KES';
ALTER TABLE "purchase_header" ADD COLUMN "currency_factor" DOUBLE PRECISION NOT NULL DEFAULT 1;
ALTER TABLE "posted_purchase_document" ADD COLUMN "currency_code" TEXT NOT NULL DEFAULT 'KES';
ALTER TABLE "posted_purchase_document" ADD COLUMN "currency_factor" DOUBLE PRECISION NOT NULL DEFAULT 1;

ALTER TABLE "customer" ADD COLUMN "currency_code" TEXT;
ALTER TABLE "vendor" ADD COLUMN "currency_code" TEXT;

-- ===================================================================== bank masters

CREATE TABLE "bank_acc_posting_group" (
    "id" SERIAL NOT NULL,
    "code" TEXT NOT NULL,
    "description" TEXT NOT NULL,
    "gl_account_id" INTEGER NOT NULL,
    "created_at" TEXT,
    "created_by" TEXT,

    CONSTRAINT "bank_acc_posting_group_pkey" PRIMARY KEY ("id")
);
CREATE UNIQUE INDEX "bank_acc_posting_group_code_key" ON "bank_acc_posting_group"("code");
ALTER TABLE "bank_acc_posting_group" ADD CONSTRAINT "bapg_gl_account_fkey" FOREIGN KEY ("gl_account_id") REFERENCES "gl_account"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

CREATE TABLE "external_bank" (
    "id" SERIAL NOT NULL,
    "code" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "created_at" TEXT,
    "created_by" TEXT,

    CONSTRAINT "external_bank_pkey" PRIMARY KEY ("id")
);
CREATE UNIQUE INDEX "external_bank_code_key" ON "external_bank"("code");

CREATE TABLE "external_bank_branch" (
    "id" SERIAL NOT NULL,
    "bank_code" TEXT NOT NULL,
    "branch_code" TEXT NOT NULL,
    "branch_name" TEXT NOT NULL,

    CONSTRAINT "external_bank_branch_pkey" PRIMARY KEY ("id")
);
CREATE UNIQUE INDEX "external_bank_branch_key" ON "external_bank_branch"("bank_code", "branch_code");
ALTER TABLE "external_bank_branch" ADD CONSTRAINT "ebb_bank_fkey" FOREIGN KEY ("bank_code") REFERENCES "external_bank"("code") ON DELETE CASCADE ON UPDATE NO ACTION;

CREATE TABLE "cash_management_setup" (
    "id" INTEGER NOT NULL DEFAULT 1,
    "receipt_approval_limit" BIGINT NOT NULL DEFAULT 0,
    "pv_approval_limit" BIGINT NOT NULL DEFAULT 0,
    "bank_charges_account_id" INTEGER,
    "bank_interest_income_account_id" INTEGER,
    "default_receipt_bank_account_id" INTEGER,
    "allow_cm_posting_from" TEXT,
    "allow_cm_posting_to" TEXT,
    "updated_at" TEXT,
    "updated_by" TEXT,

    CONSTRAINT "cash_management_setup_pkey" PRIMARY KEY ("id")
);
ALTER TABLE "cash_management_setup" ADD CONSTRAINT "cms_bank_charges_fkey" FOREIGN KEY ("bank_charges_account_id") REFERENCES "gl_account"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE "cash_management_setup" ADD CONSTRAINT "cms_bank_interest_fkey" FOREIGN KEY ("bank_interest_income_account_id") REFERENCES "gl_account"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE "cash_management_setup" ADD CONSTRAINT "cms_default_bank_fkey" FOREIGN KEY ("default_receipt_bank_account_id") REFERENCES "bank_account"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- ================================================== bank reconciliation — BC model (T273/274)

ALTER TABLE "bank_reconciliation" ADD COLUMN "statement_no" TEXT;
ALTER TABLE "bank_reconciliation" ADD COLUMN "balance_last_statement" BIGINT NOT NULL DEFAULT 0;
ALTER TABLE "bank_reconciliation" ADD COLUMN "posted" BOOLEAN NOT NULL DEFAULT false;
ALTER TABLE "bank_reconciliation" ADD COLUMN "posted_by" TEXT;
ALTER TABLE "bank_reconciliation" ADD COLUMN "posted_at" TEXT;
ALTER TABLE "bank_reconciliation" ADD COLUMN "journal_id" INTEGER;
UPDATE "bank_reconciliation" SET "posted" = true, "posted_at" = "completed_at", "posted_by" = "completed_by", "status" = 'POSTED' WHERE "status" = 'COMPLETED';

CREATE TABLE "bank_rec_line" (
    "id" SERIAL NOT NULL,
    "bank_reconciliation_id" INTEGER NOT NULL,
    "line_no" INTEGER NOT NULL,
    "type" TEXT NOT NULL DEFAULT 'Bank Account Ledger Entry',
    "transaction_date" TEXT,
    "document_no" TEXT,
    "description" TEXT,
    "statement_amount" BIGINT NOT NULL DEFAULT 0,
    "applied_amount" BIGINT NOT NULL DEFAULT 0,
    "bank_account_ledger_entry_id" INTEGER,
    "gl_account_id" INTEGER,
    "applied" INTEGER NOT NULL DEFAULT 0,

    CONSTRAINT "bank_rec_line_pkey" PRIMARY KEY ("id")
);
CREATE UNIQUE INDEX "bank_rec_line_recon_lineno_key" ON "bank_rec_line"("bank_reconciliation_id", "line_no");
ALTER TABLE "bank_rec_line" ADD CONSTRAINT "brl_recon_fkey" FOREIGN KEY ("bank_reconciliation_id") REFERENCES "bank_reconciliation"("id") ON DELETE CASCADE ON UPDATE NO ACTION;
ALTER TABLE "bank_rec_line" ADD CONSTRAINT "brl_bale_fkey" FOREIGN KEY ("bank_account_ledger_entry_id") REFERENCES "bank_account_ledger_entry"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE "bank_rec_line" ADD CONSTRAINT "brl_gl_account_fkey" FOREIGN KEY ("gl_account_id") REFERENCES "gl_account"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- ================================================================= Receipt (AL T52203423/424)

CREATE TABLE "receipt_header" (
    "id" SERIAL NOT NULL,
    "no" TEXT NOT NULL,
    "receipt_type" TEXT NOT NULL DEFAULT 'G/L Account',
    "posting_date" TEXT NOT NULL DEFAULT '',
    "bank_account_id" INTEGER NOT NULL,
    "bank_account_name" TEXT,
    "pay_mode_code" TEXT,
    "external_document_no" TEXT,
    "manual_receipt_no" TEXT,
    "description" TEXT,
    "currency_code" TEXT NOT NULL DEFAULT 'KES',
    "currency_factor" DOUBLE PRECISION NOT NULL DEFAULT 1,
    "global_dimension_1_id" INTEGER,
    "global_dimension_2_id" INTEGER,
    "amount" BIGINT NOT NULL DEFAULT 0,
    "approval_limit" BIGINT NOT NULL DEFAULT 0,
    "status" TEXT NOT NULL DEFAULT 'Open',
    "posted" BOOLEAN NOT NULL DEFAULT false,
    "decision_reason" TEXT,
    "journal_id" INTEGER,
    "created_at" TEXT,
    "created_by" TEXT,
    "posted_at" TEXT,
    "posted_by" TEXT,

    CONSTRAINT "receipt_header_pkey" PRIMARY KEY ("id")
);
CREATE UNIQUE INDEX "receipt_header_no_key" ON "receipt_header"("no");
CREATE INDEX "ix_receipt_header_status" ON "receipt_header"("status");
CREATE INDEX "ix_receipt_header_created_by" ON "receipt_header"("created_by");
ALTER TABLE "receipt_header" ADD CONSTRAINT "receipt_header_bank_fkey" FOREIGN KEY ("bank_account_id") REFERENCES "bank_account"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

CREATE TABLE "receipt_line" (
    "id" SERIAL NOT NULL,
    "receipt_header_id" INTEGER NOT NULL,
    "line_no" INTEGER NOT NULL,
    "line_type" TEXT NOT NULL DEFAULT 'G/L Account',
    "account_no" TEXT,
    "account_name" TEXT,
    "description" TEXT,
    "amount" BIGINT NOT NULL DEFAULT 0,
    "applies_to_doc_no" TEXT,
    "global_dimension_1_id" INTEGER,
    "global_dimension_2_id" INTEGER,

    CONSTRAINT "receipt_line_pkey" PRIMARY KEY ("id")
);
CREATE UNIQUE INDEX "receipt_line_header_lineno_key" ON "receipt_line"("receipt_header_id", "line_no");
ALTER TABLE "receipt_line" ADD CONSTRAINT "receipt_line_header_fkey" FOREIGN KEY ("receipt_header_id") REFERENCES "receipt_header"("id") ON DELETE CASCADE ON UPDATE NO ACTION;

CREATE TABLE "posted_receipt" (
    "id" SERIAL NOT NULL,
    "no" TEXT NOT NULL,
    "receipt_no" TEXT NOT NULL,
    "receipt_type" TEXT NOT NULL,
    "bank_account_id" INTEGER NOT NULL,
    "bank_account_name" TEXT,
    "pay_mode_code" TEXT,
    "external_document_no" TEXT,
    "manual_receipt_no" TEXT,
    "description" TEXT,
    "currency_code" TEXT NOT NULL DEFAULT 'KES',
    "currency_factor" DOUBLE PRECISION NOT NULL DEFAULT 1,
    "posting_date" TEXT NOT NULL,
    "amount" BIGINT NOT NULL DEFAULT 0,
    "journal_id" INTEGER,
    "created_at" TEXT,
    "created_by" TEXT,

    CONSTRAINT "posted_receipt_pkey" PRIMARY KEY ("id")
);
CREATE UNIQUE INDEX "posted_receipt_no_key" ON "posted_receipt"("no");
CREATE INDEX "ix_posted_receipt_receipt_no" ON "posted_receipt"("receipt_no");
ALTER TABLE "posted_receipt" ADD CONSTRAINT "posted_receipt_bank_fkey" FOREIGN KEY ("bank_account_id") REFERENCES "bank_account"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

CREATE TABLE "posted_receipt_line" (
    "id" SERIAL NOT NULL,
    "posted_receipt_id" INTEGER NOT NULL,
    "line_no" INTEGER NOT NULL,
    "line_type" TEXT NOT NULL,
    "account_no" TEXT,
    "account_name" TEXT,
    "description" TEXT,
    "amount" BIGINT NOT NULL DEFAULT 0,
    "applies_to_doc_no" TEXT,

    CONSTRAINT "posted_receipt_line_pkey" PRIMARY KEY ("id")
);
CREATE INDEX "ix_prl_doc" ON "posted_receipt_line"("posted_receipt_id");
ALTER TABLE "posted_receipt_line" ADD CONSTRAINT "prl_doc_fkey" FOREIGN KEY ("posted_receipt_id") REFERENCES "posted_receipt"("id") ON DELETE CASCADE ON UPDATE NO ACTION;

-- ========================================================= Payment Voucher (AL T52203439/440)

CREATE TABLE "payment_voucher_header" (
    "id" SERIAL NOT NULL,
    "no" TEXT NOT NULL,
    "date" TEXT NOT NULL,
    "pv_type" TEXT,
    "pay_mode_code" TEXT,
    "cheque_no" TEXT,
    "cheque_date" TEXT,
    "cheque_received_by" TEXT,
    "paying_bank_account_id" INTEGER NOT NULL,
    "currency_code" TEXT NOT NULL DEFAULT 'KES',
    "currency_factor" DOUBLE PRECISION NOT NULL DEFAULT 1,
    "description" TEXT,
    "payee_name" TEXT,
    "payee_external_bank_code" TEXT,
    "payee_bank_branch_code" TEXT,
    "payee_account_no" TEXT,
    "global_dimension_1_id" INTEGER,
    "global_dimension_2_id" INTEGER,
    "total_amount" BIGINT NOT NULL DEFAULT 0,
    "approval_limit" BIGINT NOT NULL DEFAULT 0,
    "status" TEXT NOT NULL DEFAULT 'Open',
    "posted" BOOLEAN NOT NULL DEFAULT false,
    "decision_reason" TEXT,
    "prepared_by" TEXT,
    "journal_id" INTEGER,
    "created_at" TEXT,
    "created_by" TEXT,
    "posted_at" TEXT,
    "posted_by" TEXT,

    CONSTRAINT "payment_voucher_header_pkey" PRIMARY KEY ("id")
);
CREATE UNIQUE INDEX "payment_voucher_header_no_key" ON "payment_voucher_header"("no");
CREATE INDEX "ix_pvh_status" ON "payment_voucher_header"("status");
CREATE INDEX "ix_pvh_created_by" ON "payment_voucher_header"("created_by");
CREATE INDEX "ix_pvh_cheque_no" ON "payment_voucher_header"("cheque_no");
ALTER TABLE "payment_voucher_header" ADD CONSTRAINT "pvh_bank_fkey" FOREIGN KEY ("paying_bank_account_id") REFERENCES "bank_account"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

CREATE TABLE "payment_voucher_line" (
    "id" SERIAL NOT NULL,
    "payment_voucher_header_id" INTEGER NOT NULL,
    "line_no" INTEGER NOT NULL,
    "line_type" TEXT NOT NULL DEFAULT 'G/L Account',
    "account_no" TEXT,
    "account_name" TEXT,
    "description" TEXT,
    "amount" BIGINT NOT NULL DEFAULT 0,
    "applies_to_doc_no" TEXT,
    -- VAT + Withholding Tax (AL "Payment Voucher Lines" Tab52203440). "amount" is the gross
    -- (VAT-inclusive) figure entered; "net_amount" is the cash actually paid for the line.
    "vat_prod_posting_group_code" TEXT,
    "wht_code_one" TEXT,
    "wht_code_two" TEXT,
    "vat_amount" BIGINT NOT NULL DEFAULT 0,
    "wht_amount_one" BIGINT NOT NULL DEFAULT 0,
    "wht_amount_two" BIGINT NOT NULL DEFAULT 0,
    "wht_base" BIGINT NOT NULL DEFAULT 0,
    "net_amount" BIGINT NOT NULL DEFAULT 0,
    "purchase_invoice_amount" BIGINT NOT NULL DEFAULT 0,
    "global_dimension_1_id" INTEGER,
    "global_dimension_2_id" INTEGER,

    CONSTRAINT "payment_voucher_line_pkey" PRIMARY KEY ("id")
);
CREATE UNIQUE INDEX "payment_voucher_line_header_lineno_key" ON "payment_voucher_line"("payment_voucher_header_id", "line_no");
ALTER TABLE "payment_voucher_line" ADD CONSTRAINT "pvl_header_fkey" FOREIGN KEY ("payment_voucher_header_id") REFERENCES "payment_voucher_header"("id") ON DELETE CASCADE ON UPDATE NO ACTION;

CREATE TABLE "posted_payment_voucher" (
    "id" SERIAL NOT NULL,
    "no" TEXT NOT NULL,
    "pv_no" TEXT NOT NULL,
    "date" TEXT NOT NULL,
    "pay_mode_code" TEXT,
    "cheque_no" TEXT,
    "cheque_date" TEXT,
    "cheque_received_by" TEXT,
    "paying_bank_account_id" INTEGER NOT NULL,
    "currency_code" TEXT NOT NULL DEFAULT 'KES',
    "currency_factor" DOUBLE PRECISION NOT NULL DEFAULT 1,
    "description" TEXT,
    "payee_name" TEXT,
    "payee_external_bank_code" TEXT,
    "payee_bank_branch_code" TEXT,
    "payee_account_no" TEXT,
    "posting_date" TEXT NOT NULL,
    "total_amount" BIGINT NOT NULL DEFAULT 0,
    "journal_id" INTEGER,
    "prepared_by" TEXT,
    "approved_by" TEXT,
    "created_at" TEXT,
    "created_by" TEXT,

    CONSTRAINT "posted_payment_voucher_pkey" PRIMARY KEY ("id")
);
CREATE UNIQUE INDEX "posted_payment_voucher_no_key" ON "posted_payment_voucher"("no");
CREATE INDEX "ix_ppv_pv_no" ON "posted_payment_voucher"("pv_no");
ALTER TABLE "posted_payment_voucher" ADD CONSTRAINT "ppv_bank_fkey" FOREIGN KEY ("paying_bank_account_id") REFERENCES "bank_account"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

CREATE TABLE "posted_payment_voucher_line" (
    "id" SERIAL NOT NULL,
    "posted_payment_voucher_id" INTEGER NOT NULL,
    "line_no" INTEGER NOT NULL,
    "line_type" TEXT NOT NULL,
    "account_no" TEXT,
    "account_name" TEXT,
    "description" TEXT,
    "amount" BIGINT NOT NULL DEFAULT 0,
    "applies_to_doc_no" TEXT,
    "vat_prod_posting_group_code" TEXT,
    "wht_code_one" TEXT,
    "wht_code_two" TEXT,
    "vat_amount" BIGINT NOT NULL DEFAULT 0,
    "wht_amount_one" BIGINT NOT NULL DEFAULT 0,
    "wht_amount_two" BIGINT NOT NULL DEFAULT 0,
    "wht_base" BIGINT NOT NULL DEFAULT 0,
    "net_amount" BIGINT NOT NULL DEFAULT 0,

    CONSTRAINT "posted_payment_voucher_line_pkey" PRIMARY KEY ("id")
);
CREATE INDEX "ix_ppvl_doc" ON "posted_payment_voucher_line"("posted_payment_voucher_id");
ALTER TABLE "posted_payment_voucher_line" ADD CONSTRAINT "ppvl_doc_fkey" FOREIGN KEY ("posted_payment_voucher_id") REFERENCES "posted_payment_voucher"("id") ON DELETE CASCADE ON UPDATE NO ACTION;

-- ============================================================================== data back-fill

INSERT INTO "gl_account" ("code", "name", "type", "parent_code", "is_postable", "account_type")
SELECT v.code, v.name, v.type, v.parent_code, v.is_postable, v.account_type
FROM (VALUES
  ('2170', 'Cheques Not Presented', 'LIABILITY', '2145', 1, 'POSTING'),
  ('4070', 'Realized Exchange Gain', 'INCOME', '4000', 1, 'POSTING'),
  ('4072', 'Unrealized Exchange Gain', 'INCOME', '4000', 1, 'POSTING'),
  ('5085', 'Realized Exchange Loss', 'EXPENSE', '5000', 1, 'POSTING'),
  ('5087', 'Unrealized Exchange Loss', 'EXPENSE', '5000', 1, 'POSTING')
) AS v(code, name, type, parent_code, is_postable, account_type)
WHERE EXISTS (SELECT 1 FROM "organisation")
ON CONFLICT ("code") DO NOTHING;

INSERT INTO "currency" ("code", "description", "symbol", "iso_numeric_code", "is_base", "amount_rounding_precision")
SELECT 'KES', 'Kenya Shilling', 'KSh', '404', 1, 100
WHERE EXISTS (SELECT 1 FROM "organisation")
ON CONFLICT ("code") DO NOTHING;

INSERT INTO "currency" ("code", "description", "symbol", "iso_numeric_code", "is_base",
  "amount_rounding_precision", "realized_gains_account_id", "realized_losses_account_id",
  "unrealized_gains_account_id", "unrealized_losses_account_id", "residual_gains_account_id", "residual_losses_account_id")
SELECT v.code, v.description, v.symbol, v.iso, 0, 1,
  (SELECT id FROM "gl_account" WHERE code = '4070'), (SELECT id FROM "gl_account" WHERE code = '5085'),
  (SELECT id FROM "gl_account" WHERE code = '4072'), (SELECT id FROM "gl_account" WHERE code = '5087'),
  (SELECT id FROM "gl_account" WHERE code = '4070'), (SELECT id FROM "gl_account" WHERE code = '5085')
FROM (VALUES ('USD', 'US Dollar', '$', '840'), ('EUR', 'Euro', 'EUR', '978'), ('GBP', 'Pound Sterling', 'GBP', '826')) AS v(code, description, symbol, iso)
WHERE EXISTS (SELECT 1 FROM "organisation")
ON CONFLICT ("code") DO NOTHING;

INSERT INTO "external_bank" ("code", "name")
SELECT * FROM (VALUES
  ('COOP', 'Co-operative Bank of Kenya'), ('EQUITY', 'Equity Bank'), ('KCB', 'Kenya Commercial Bank'),
  ('NCBA', 'NCBA Bank'), ('ABSA', 'Absa Bank Kenya'), ('DTB', 'Diamond Trust Bank')
) AS v(code, name)
WHERE EXISTS (SELECT 1 FROM "organisation")
ON CONFLICT ("code") DO NOTHING;

INSERT INTO "external_bank_branch" ("bank_code", "branch_code", "branch_name")
SELECT * FROM (VALUES
  ('COOP', '11000', 'Co-op House'), ('COOP', '11151', 'Nakuru'),
  ('EQUITY', '68000', 'Equity Centre'), ('EQUITY', '68012', 'Nakuru'),
  ('KCB', '01100', 'Moi Avenue'), ('KCB', '01169', 'Nakuru'),
  ('NCBA', '07000', 'NCBA Centre')
) AS v(bank_code, branch_code, branch_name)
WHERE EXISTS (SELECT 1 FROM "organisation")
ON CONFLICT ("bank_code", "branch_code") DO NOTHING;

INSERT INTO "bank_acc_posting_group" ("code", "description", "gl_account_id")
SELECT v.code, v.description, (SELECT id FROM "gl_account" WHERE code = v.acc)
FROM (VALUES
  ('BANK', 'Bank current accounts', '1020'),
  ('CASH', 'Cash on hand', '1010'),
  ('MPESA', 'Mobile money settlement', '1030'),
  ('CLEARING', 'Check-off / clearing', '1040')
) AS v(code, description, acc)
WHERE EXISTS (SELECT 1 FROM "organisation")
ON CONFLICT ("code") DO NOTHING;

UPDATE "bank_account" SET "currency_code" = 'KES', "balance_lcy" = "balance"
WHERE EXISTS (SELECT 1 FROM "organisation");
UPDATE "bank_account" SET "bank_acc_posting_group_code" = 'BANK'
WHERE "code" IN ('BANK') AND EXISTS (SELECT 1 FROM "organisation");
UPDATE "bank_account" SET "bank_acc_posting_group_code" = 'CASH'
WHERE "code" IN ('CASH', 'TREASURY', 'TILL-01', 'TILL-02') AND EXISTS (SELECT 1 FROM "organisation");
UPDATE "bank_account" SET "bank_acc_posting_group_code" = 'MPESA'
WHERE "code" = 'MPESA' AND EXISTS (SELECT 1 FROM "organisation");
UPDATE "bank_account" SET "bank_acc_posting_group_code" = 'CLEARING'
WHERE "code" = 'CHECKOFF' AND EXISTS (SELECT 1 FROM "organisation");

INSERT INTO "cash_management_setup" ("id", "receipt_approval_limit", "pv_approval_limit",
  "bank_charges_account_id", "bank_interest_income_account_id", "default_receipt_bank_account_id", "updated_at", "updated_by")
SELECT 1, 5000000, 2000000,
  (SELECT id FROM "gl_account" WHERE code = '5030'),
  (SELECT id FROM "gl_account" WHERE code = '4050'),
  (SELECT id FROM "bank_account" WHERE code = 'BANK'),
  NOW()::text, 'system'
WHERE EXISTS (SELECT 1 FROM "organisation")
ON CONFLICT ("id") DO NOTHING;

INSERT INTO "sequence" ("name", "prefix", "next_no", "width")
SELECT * FROM (VALUES
  ('RECEIPT', 'RCT', 1, 6),
  ('POSTED_RECEIPT', 'PRCT', 1, 6),
  ('PAYMENT_VOUCHER', 'PV', 1, 6),
  ('POSTED_PAYMENT_VOUCHER', 'PPV', 1, 6),
  ('BANK_RECONCILIATION', 'BREC', 1, 6)
) AS v(name, prefix, next_no, width)
WHERE EXISTS (SELECT 1 FROM "organisation")
ON CONFLICT ("name") DO NOTHING;

INSERT INTO "no_series" ("code", "description", "default_nos", "manual_nos", "date_order")
SELECT v.code, v.description, 1, 0, 0
FROM (VALUES
  ('RECEIPT', 'Receipt No.'),
  ('POSTED_RECEIPT', 'Posted Receipt No.'),
  ('PAYMENT_VOUCHER', 'Payment Voucher No.'),
  ('POSTED_PAYMENT_VOUCHER', 'Posted Payment Voucher No.'),
  ('BANK_RECONCILIATION', 'Bank Reconciliation No.')
) AS v(code, description)
WHERE EXISTS (SELECT 1 FROM "organisation")
ON CONFLICT ("code") DO NOTHING;

INSERT INTO "no_series_line" ("series_code", "line_no", "starting_date", "starting_no", "increment_by_no", "open", "allow_gaps")
SELECT s.name, 10000, NULL, s.prefix || LPAD(s.next_no::text, s.width, '0'), 1, 1, 0
FROM "sequence" s
WHERE s.name IN ('RECEIPT','POSTED_RECEIPT','PAYMENT_VOUCHER','POSTED_PAYMENT_VOUCHER','BANK_RECONCILIATION')
  AND EXISTS (SELECT 1 FROM "organisation")
  AND NOT EXISTS (SELECT 1 FROM "no_series_line" l WHERE l.series_code = s.name);

INSERT INTO "no_series_setup" ("document_code", "label", "category", "sort", "series_code")
SELECT v.code, v.label, 'Cash Management', v.sort, v.code
FROM (VALUES
  ('RECEIPT', 'Receipt No.', 80),
  ('POSTED_RECEIPT', 'Posted Receipt No.', 81),
  ('PAYMENT_VOUCHER', 'Payment Voucher No.', 82),
  ('POSTED_PAYMENT_VOUCHER', 'Posted Payment Voucher No.', 83),
  ('BANK_RECONCILIATION', 'Bank Reconciliation No.', 84)
) AS v(code, label, sort)
WHERE EXISTS (SELECT 1 FROM "organisation")
ON CONFLICT ("document_code") DO NOTHING;

-- Permission backfill (keyed by role name; a fresh DB has no roles yet — lib/seed.ts owns it).
INSERT INTO "permission_set_line"
  ("role_id", "object_type", "object_name", "read_perm", "insert_perm", "modify_perm", "delete_perm", "execute_perm")
SELECT r.id, g.object_type, g.object_name, g.r, g.i, g.m, g.d, g.e
FROM "role" r
JOIN (VALUES
  ('Branch Manager',  'PAGE',  'CASH_MGMT',                    0,0,0,0,1),
  ('Branch Manager',  'TABLE', 'bank_account',                 1,0,0,0,0),
  ('Branch Manager',  'TABLE', 'bank_account_ledger_entry',    1,0,0,0,0),
  ('Branch Manager',  'TABLE', 'bank_reconciliation',          1,1,1,0,0),
  ('Branch Manager',  'TABLE', 'bank_rec_line',                1,1,1,1,0),
  ('Branch Manager',  'TABLE', 'receipt_header',               1,0,1,0,0),
  ('Branch Manager',  'TABLE', 'payment_voucher_header',       1,0,1,0,0),
  ('Finance Officer', 'PAGE',  'CASH_MGMT',                    0,0,0,0,1),
  ('Finance Officer', 'TABLE', 'bank_account',                 1,1,1,0,0),
  ('Finance Officer', 'TABLE', 'bank_acc_posting_group',       1,1,1,1,0),
  ('Finance Officer', 'TABLE', 'external_bank',                1,1,1,1,0),
  ('Finance Officer', 'TABLE', 'external_bank_branch',         1,1,1,1,0),
  ('Finance Officer', 'TABLE', 'currency',                     1,1,1,0,0),
  ('Finance Officer', 'TABLE', 'currency_exchange_rate',       1,1,1,1,0),
  ('Finance Officer', 'TABLE', 'cash_management_setup',        1,1,1,0,0),
  ('Finance Officer', 'TABLE', 'bank_account_ledger_entry',    1,1,1,0,0),
  ('Finance Officer', 'TABLE', 'bank_reconciliation',          1,1,1,0,0),
  ('Finance Officer', 'TABLE', 'bank_rec_line',                1,1,1,1,0),
  ('Finance Officer', 'TABLE', 'receipt_header',               1,1,1,1,0),
  ('Finance Officer', 'TABLE', 'receipt_line',                 1,1,1,1,0),
  ('Finance Officer', 'TABLE', 'posted_receipt',              1,1,0,0,0),
  ('Finance Officer', 'TABLE', 'posted_receipt_line',         1,1,0,0,0),
  ('Finance Officer', 'TABLE', 'payment_voucher_header',       1,1,1,1,0),
  ('Finance Officer', 'TABLE', 'payment_voucher_line',         1,1,1,1,0),
  ('Finance Officer', 'TABLE', 'posted_payment_voucher',       1,1,0,0,0),
  ('Finance Officer', 'TABLE', 'posted_payment_voucher_line',  1,1,0,0,0),
  ('Finance Officer', 'TABLE', 'cust_ledger_entry',            1,1,1,0,0),
  ('Finance Officer', 'TABLE', 'vendor_ledger_entry',          1,1,1,0,0),
  ('Finance Officer', 'TABLE', 'detailed_cust_ledger_entry',   1,1,1,0,0),
  ('Finance Officer', 'TABLE', 'detailed_vendor_ledger_entry', 1,1,1,0,0),
  ('Finance Officer', 'TABLE', 'customer',                     1,0,1,0,0),
  ('Finance Officer', 'TABLE', 'vendor',                       1,0,1,0,0),
  ('Finance Officer', 'TABLE', 'journal',                      0,1,0,0,0),
  ('Finance Officer', 'TABLE', 'journal_line',                 0,1,0,0,0),
  ('Finance Officer', 'TABLE', 'workflow_task',                0,1,1,0,0),
  ('Finance Officer', 'TABLE', 'gl_account',                   1,0,1,0,0),
  ('Internal Auditor','PAGE',  'CASH_MGMT',                    0,0,0,0,1),
  ('Internal Auditor','TABLE', 'bank_account',                 1,0,0,0,0),
  ('Internal Auditor','TABLE', 'bank_acc_posting_group',       1,0,0,0,0),
  ('Internal Auditor','TABLE', 'external_bank',                1,0,0,0,0),
  ('Internal Auditor','TABLE', 'external_bank_branch',         1,0,0,0,0),
  ('Internal Auditor','TABLE', 'currency',                     1,0,0,0,0),
  ('Internal Auditor','TABLE', 'currency_exchange_rate',       1,0,0,0,0),
  ('Internal Auditor','TABLE', 'cash_management_setup',        1,0,0,0,0),
  ('Internal Auditor','TABLE', 'bank_account_ledger_entry',    1,0,0,0,0),
  ('Internal Auditor','TABLE', 'bank_reconciliation',          1,0,0,0,0),
  ('Internal Auditor','TABLE', 'bank_rec_line',                1,0,0,0,0),
  ('Internal Auditor','TABLE', 'receipt_header',               1,0,0,0,0),
  ('Internal Auditor','TABLE', 'receipt_line',                 1,0,0,0,0),
  ('Internal Auditor','TABLE', 'posted_receipt',              1,0,0,0,0),
  ('Internal Auditor','TABLE', 'posted_receipt_line',         1,0,0,0,0),
  ('Internal Auditor','TABLE', 'payment_voucher_header',       1,0,0,0,0),
  ('Internal Auditor','TABLE', 'payment_voucher_line',         1,0,0,0,0),
  ('Internal Auditor','TABLE', 'posted_payment_voucher',       1,0,0,0,0),
  ('Internal Auditor','TABLE', 'posted_payment_voucher_line',  1,0,0,0,0)
) AS g(role_name, object_type, object_name, r, i, m, d, e) ON g.role_name = r.name
ON CONFLICT ("role_id", "object_type", "object_name") DO UPDATE SET
  "read_perm"    = GREATEST("permission_set_line"."read_perm",    EXCLUDED."read_perm"),
  "insert_perm"  = GREATEST("permission_set_line"."insert_perm",  EXCLUDED."insert_perm"),
  "modify_perm"  = GREATEST("permission_set_line"."modify_perm",  EXCLUDED."modify_perm"),
  "delete_perm"  = GREATEST("permission_set_line"."delete_perm",  EXCLUDED."delete_perm"),
  "execute_perm" = GREATEST("permission_set_line"."execute_perm", EXCLUDED."execute_perm");
