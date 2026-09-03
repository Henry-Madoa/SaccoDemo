-- VAT + Withholding Tax (Business Central VAT Posting Setup, reused for WHT the way the AL
-- "SACCODEMO" localization does — a VAT Product Posting Group carries a Type of VAT | WHT, and
-- VAT Posting Setup holds the % and the account for both). Input VAT is recognised on purchase
-- documents; Withholding Tax (income WHT + 2% withholding VAT) is deducted when a Payment Voucher
-- is posted, producing a supplier WHT certificate. No output VAT / VAT return netting.

-- ============================================================================= masters

-- Business Central Table 89 "VAT Business Posting Group".
CREATE TABLE "vat_business_posting_group" (
    "id" SERIAL NOT NULL,
    "code" TEXT NOT NULL,
    "description" TEXT NOT NULL DEFAULT '',
    "created_at" TEXT,
    "created_by" TEXT,

    CONSTRAINT "vat_business_posting_group_pkey" PRIMARY KEY ("id")
);
CREATE UNIQUE INDEX "vat_business_posting_group_code_key" ON "vat_business_posting_group"("code");

-- Business Central Table 324 "VAT Product Posting Group" (+ the AL "Type" field: VAT | WHT).
CREATE TABLE "vat_product_posting_group" (
    "id" SERIAL NOT NULL,
    "code" TEXT NOT NULL,
    "description" TEXT NOT NULL DEFAULT '',
    "tax_type" TEXT NOT NULL DEFAULT 'VAT',
    "created_at" TEXT,
    "created_by" TEXT,

    CONSTRAINT "vat_product_posting_group_pkey" PRIMARY KEY ("id")
);
CREATE UNIQUE INDEX "vat_product_posting_group_code_key" ON "vat_product_posting_group"("code");

-- Business Central Table 325 "VAT Posting Setup" (Bus. x Prod.). "tax_account_id" is the input
-- VAT account for VAT rows and the tax-payable account for WHT rows (AL "Purchase VAT Account").
CREATE TABLE "vat_posting_setup" (
    "id" SERIAL NOT NULL,
    "vat_bus_posting_group_code" TEXT NOT NULL,
    "vat_prod_posting_group_code" TEXT NOT NULL,
    "tax_type" TEXT NOT NULL DEFAULT 'VAT',
    "vat_pct" DOUBLE PRECISION NOT NULL DEFAULT 0,
    "vat_calculation_type" TEXT NOT NULL DEFAULT 'Normal',
    "tax_account_id" INTEGER,
    "wht_base" TEXT NOT NULL DEFAULT 'Net',
    "blocked" INTEGER NOT NULL DEFAULT 0,
    "created_at" TEXT,
    "created_by" TEXT,

    CONSTRAINT "vat_posting_setup_pkey" PRIMARY KEY ("id")
);
CREATE UNIQUE INDEX "vat_posting_setup_key" ON "vat_posting_setup"("vat_bus_posting_group_code", "vat_prod_posting_group_code");
ALTER TABLE "vat_posting_setup" ADD CONSTRAINT "vps_tax_account_fkey" FOREIGN KEY ("tax_account_id") REFERENCES "gl_account"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- Business Central Table 254 "VAT Entry" (trimmed: purchases + WHT only, LCY + FCY).
CREATE TABLE "vat_entry" (
    "id" SERIAL NOT NULL,
    "posting_date" TEXT NOT NULL,
    "document_type" TEXT NOT NULL DEFAULT '',
    "document_no" TEXT NOT NULL,
    "type" TEXT NOT NULL DEFAULT 'Purchase',
    "tax_type" TEXT NOT NULL DEFAULT 'VAT',
    "vat_bus_posting_group_code" TEXT,
    "vat_prod_posting_group_code" TEXT,
    "vat_pct" DOUBLE PRECISION NOT NULL DEFAULT 0,
    "base" BIGINT NOT NULL DEFAULT 0,
    "amount" BIGINT NOT NULL DEFAULT 0,
    "base_fcy" BIGINT NOT NULL DEFAULT 0,
    "amount_fcy" BIGINT NOT NULL DEFAULT 0,
    "currency_code" TEXT NOT NULL DEFAULT 'KES',
    "currency_factor" DOUBLE PRECISION NOT NULL DEFAULT 1,
    "bill_to_pay_to_no" TEXT,
    "vendor_pin" TEXT,
    "wht_certificate_no" TEXT,
    "journal_id" INTEGER,
    "source_type" TEXT,
    "source_id" INTEGER,
    "closed" INTEGER NOT NULL DEFAULT 0,
    "created_at" TEXT,

    CONSTRAINT "vat_entry_pkey" PRIMARY KEY ("id")
);
CREATE INDEX "ix_vat_entry_posting_date" ON "vat_entry"("posting_date");
CREATE INDEX "ix_vat_entry_tax_type_closed" ON "vat_entry"("tax_type", "closed");
CREATE INDEX "ix_vat_entry_document_no" ON "vat_entry"("document_no");
CREATE INDEX "ix_vat_entry_pay_to" ON "vat_entry"("bill_to_pay_to_no");

-- Kenya KRA withholding-tax certificate (AL Rep52203485 "Witholding Tax Certificate").
CREATE TABLE "wht_certificate" (
    "id" SERIAL NOT NULL,
    "no" TEXT NOT NULL,
    "vendor_id" INTEGER,
    "vendor_name" TEXT,
    "vendor_pin" TEXT,
    "payment_voucher_no" TEXT NOT NULL,
    "certificate_date" TEXT NOT NULL,
    "gross_amount" BIGINT NOT NULL DEFAULT 0,
    "total_wht" BIGINT NOT NULL DEFAULT 0,
    "remitted" INTEGER NOT NULL DEFAULT 0,
    "remittance_ref" TEXT,
    "created_at" TEXT,
    "created_by" TEXT,

    CONSTRAINT "wht_certificate_pkey" PRIMARY KEY ("id")
);
CREATE UNIQUE INDEX "wht_certificate_no_key" ON "wht_certificate"("no");
CREATE INDEX "ix_wht_certificate_pv" ON "wht_certificate"("payment_voucher_no");
CREATE INDEX "ix_wht_certificate_vendor" ON "wht_certificate"("vendor_id");
ALTER TABLE "wht_certificate" ADD CONSTRAINT "wht_cert_vendor_fkey" FOREIGN KEY ("vendor_id") REFERENCES "vendor"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

CREATE TABLE "wht_certificate_line" (
    "id" SERIAL NOT NULL,
    "wht_certificate_id" INTEGER NOT NULL,
    "line_no" INTEGER NOT NULL,
    "wht_code" TEXT NOT NULL,
    "description" TEXT,
    "rate" DOUBLE PRECISION NOT NULL DEFAULT 0,
    "base" BIGINT NOT NULL DEFAULT 0,
    "wht_amount" BIGINT NOT NULL DEFAULT 0,
    "vat_entry_id" INTEGER,

    CONSTRAINT "wht_certificate_line_pkey" PRIMARY KEY ("id")
);
CREATE INDEX "ix_wht_certificate_line_doc" ON "wht_certificate_line"("wht_certificate_id");
ALTER TABLE "wht_certificate_line" ADD CONSTRAINT "wht_cert_line_doc_fkey" FOREIGN KEY ("wht_certificate_id") REFERENCES "wht_certificate"("id") ON DELETE CASCADE ON UPDATE NO ACTION;

-- ============================================================================= ALTERs

ALTER TABLE "vendor"
  ADD COLUMN "vat_bus_posting_group_code" TEXT,
  ADD COLUMN "pin_no" TEXT,
  ADD COLUMN "wht_exempt" INTEGER NOT NULL DEFAULT 0;

ALTER TABLE "gl_account"
  ADD COLUMN "vat_bus_posting_group_code" TEXT,
  ADD COLUMN "vat_prod_posting_group_code" TEXT;

ALTER TABLE "purchase_header"
  ADD COLUMN "vat_bus_posting_group_code" TEXT,
  ADD COLUMN "amount_incl_vat" BIGINT NOT NULL DEFAULT 0;

ALTER TABLE "purchase_line"
  ADD COLUMN "vat_prod_posting_group_code" TEXT,
  ADD COLUMN "vat_pct" DOUBLE PRECISION NOT NULL DEFAULT 0,
  ADD COLUMN "vat_base_amount" BIGINT NOT NULL DEFAULT 0,
  ADD COLUMN "vat_amount" BIGINT NOT NULL DEFAULT 0,
  ADD COLUMN "amount_incl_vat" BIGINT NOT NULL DEFAULT 0;

ALTER TABLE "posted_purchase_document"
  ADD COLUMN "vat_bus_posting_group_code" TEXT,
  ADD COLUMN "amount_incl_vat" BIGINT NOT NULL DEFAULT 0;

ALTER TABLE "posted_purchase_line"
  ADD COLUMN "vat_prod_posting_group_code" TEXT,
  ADD COLUMN "vat_pct" DOUBLE PRECISION NOT NULL DEFAULT 0,
  ADD COLUMN "vat_base_amount" BIGINT NOT NULL DEFAULT 0,
  ADD COLUMN "vat_amount" BIGINT NOT NULL DEFAULT 0,
  ADD COLUMN "amount_incl_vat" BIGINT NOT NULL DEFAULT 0;

ALTER TABLE "purchases_payables_setup"
  ADD COLUMN "default_vat_bus_posting_group_code" TEXT,
  ADD COLUMN "prices_incl_vat" INTEGER NOT NULL DEFAULT 0;

ALTER TABLE "cash_management_setup"
  ADD COLUMN "default_vat_bus_posting_group_code" TEXT;

-- Historical purchase rows: incl-VAT == base, no VAT.
UPDATE "purchase_line" SET "amount_incl_vat" = "line_amount" WHERE "amount_incl_vat" = 0;
UPDATE "purchase_header" ph SET "amount_incl_vat" = "amount" WHERE "amount_incl_vat" = 0;
UPDATE "posted_purchase_line" SET "amount_incl_vat" = "line_amount" WHERE "amount_incl_vat" = 0;
UPDATE "posted_purchase_document" SET "amount_incl_vat" = "amount" WHERE "amount_incl_vat" = 0;

-- ============================================================================= chart of accounts

INSERT INTO "gl_account" ("code", "name", "type", "parent_code", "is_postable", "account_type")
SELECT v.code, v.name, v.type, v.parent_code, v.is_postable, v.account_type
FROM (VALUES
  ('1260', 'Input VAT (Recoverable)', 'ASSET', '1240', 1, 'POSTING'),
  ('2190', 'Withholding Tax Payable', 'LIABILITY', '2100', 1, 'POSTING'),
  ('2195', 'Withholding VAT Payable', 'LIABILITY', '2100', 1, 'POSTING')
) AS v(code, name, type, parent_code, is_postable, account_type)
WHERE EXISTS (SELECT 1 FROM "organisation")
ON CONFLICT ("code") DO NOTHING;

-- ============================================================================= seeds

INSERT INTO "vat_business_posting_group" ("code", "description")
SELECT 'STANDARD', 'Standard-rated domestic'
WHERE EXISTS (SELECT 1 FROM "organisation")
ON CONFLICT ("code") DO NOTHING;

INSERT INTO "vat_product_posting_group" ("code", "description", "tax_type")
SELECT * FROM (VALUES
  ('VAT16',    'VAT at 16%',           'VAT'),
  ('VAT0',     'Zero-rated',           'VAT'),
  ('EXEMPT',   'VAT exempt',           'VAT'),
  ('WHT-PROF', 'WHT — professional fees (5%)', 'WHT'),
  ('WHT-RENT', 'WHT — rent (10%)',     'WHT'),
  ('WHT-VAT',  'Withholding VAT (2%)', 'WHT')
) AS v(code, description, tax_type)
WHERE EXISTS (SELECT 1 FROM "organisation")
ON CONFLICT ("code") DO NOTHING;

INSERT INTO "vat_posting_setup"
  ("vat_bus_posting_group_code", "vat_prod_posting_group_code", "tax_type", "vat_pct", "vat_calculation_type", "tax_account_id", "wht_base")
SELECT v.bus, v.prod, v.tt, v.pct, v.calc,
  (SELECT id FROM "gl_account" WHERE code = v.acct), 'Net'
FROM (VALUES
  ('STANDARD', 'VAT16',    'VAT', 16.0, 'Normal',   '1260'),
  ('STANDARD', 'VAT0',     'VAT',  0.0, 'Zero VAT', '1260'),
  ('STANDARD', 'EXEMPT',   'VAT',  0.0, 'Exempt',   '1260'),
  ('STANDARD', 'WHT-PROF', 'WHT',  5.0, 'Normal',   '2190'),
  ('STANDARD', 'WHT-RENT', 'WHT', 10.0, 'Normal',   '2190'),
  ('STANDARD', 'WHT-VAT',  'WHT',  2.0, 'Normal',   '2195')
) AS v(bus, prod, tt, pct, calc, acct)
WHERE EXISTS (SELECT 1 FROM "organisation")
ON CONFLICT ("vat_bus_posting_group_code", "vat_prod_posting_group_code") DO NOTHING;

UPDATE "vendor" SET "vat_bus_posting_group_code" = 'STANDARD'
WHERE "vat_bus_posting_group_code" IS NULL
  AND EXISTS (SELECT 1 FROM "vat_business_posting_group" WHERE code = 'STANDARD');

UPDATE "purchases_payables_setup" SET "default_vat_bus_posting_group_code" = 'STANDARD'
WHERE "default_vat_bus_posting_group_code" IS NULL AND "id" = 1;

UPDATE "cash_management_setup" SET "default_vat_bus_posting_group_code" = 'STANDARD'
WHERE "default_vat_bus_posting_group_code" IS NULL AND "id" = 1;

-- No. Series for the WHT certificate.
INSERT INTO "sequence" ("name", "prefix", "next_no", "width")
SELECT 'WHT_CERTIFICATE', 'WHT', 1, 6
WHERE EXISTS (SELECT 1 FROM "organisation")
ON CONFLICT ("name") DO NOTHING;

INSERT INTO "no_series" ("code", "description", "default_nos", "manual_nos", "date_order")
SELECT 'WHT_CERTIFICATE', 'Withholding Tax Certificate No.', 1, 0, 0
WHERE EXISTS (SELECT 1 FROM "organisation")
ON CONFLICT ("code") DO NOTHING;

INSERT INTO "no_series_line" ("series_code", "line_no", "starting_date", "starting_no", "increment_by_no", "open", "allow_gaps")
SELECT s.name, 10000, NULL, s.prefix || LPAD(s.next_no::text, s.width, '0'), 1, 1, 0
FROM "sequence" s
WHERE s.name = 'WHT_CERTIFICATE'
  AND EXISTS (SELECT 1 FROM "organisation")
  AND NOT EXISTS (SELECT 1 FROM "no_series_line" l WHERE l.series_code = s.name);

INSERT INTO "no_series_setup" ("document_code", "label", "category", "sort", "series_code")
SELECT 'WHT_CERTIFICATE', 'Withholding Tax Certificate No.', 'Finance', 90, 'WHT_CERTIFICATE'
WHERE EXISTS (SELECT 1 FROM "organisation")
ON CONFLICT ("document_code") DO NOTHING;

-- ============================================================================= permission backfill

INSERT INTO "permission_set_line"
  ("role_id", "object_type", "object_name", "read_perm", "insert_perm", "modify_perm", "delete_perm", "execute_perm")
SELECT r.id, g.object_type, g.object_name, g.r, g.i, g.m, g.d, g.e
FROM "role" r
JOIN (VALUES
  ('Finance Officer', 'TABLE', 'vat_business_posting_group',  1,1,1,1,0),
  ('Finance Officer', 'TABLE', 'vat_product_posting_group',   1,1,1,1,0),
  ('Finance Officer', 'TABLE', 'vat_posting_setup',           1,1,1,1,0),
  ('Finance Officer', 'TABLE', 'vat_entry',                   1,1,1,0,0),
  ('Finance Officer', 'TABLE', 'wht_certificate',             1,1,1,0,0),
  ('Finance Officer', 'TABLE', 'wht_certificate_line',        1,1,1,0,0),
  ('Internal Auditor','TABLE', 'vat_business_posting_group',  1,0,0,0,0),
  ('Internal Auditor','TABLE', 'vat_product_posting_group',   1,0,0,0,0),
  ('Internal Auditor','TABLE', 'vat_posting_setup',           1,0,0,0,0),
  ('Internal Auditor','TABLE', 'vat_entry',                   1,0,0,0,0),
  ('Internal Auditor','TABLE', 'wht_certificate',             1,0,0,0,0),
  ('Internal Auditor','TABLE', 'wht_certificate_line',        1,0,0,0,0)
) AS g(role_name, object_type, object_name, r, i, m, d, e) ON g.role_name = r.name
ON CONFLICT ("role_id", "object_type", "object_name") DO UPDATE SET
  "read_perm"    = GREATEST("permission_set_line"."read_perm",    EXCLUDED."read_perm"),
  "insert_perm"  = GREATEST("permission_set_line"."insert_perm",  EXCLUDED."insert_perm"),
  "modify_perm"  = GREATEST("permission_set_line"."modify_perm",  EXCLUDED."modify_perm"),
  "delete_perm"  = GREATEST("permission_set_line"."delete_perm",  EXCLUDED."delete_perm"),
  "execute_perm" = GREATEST("permission_set_line"."execute_perm", EXCLUDED."execute_perm");
