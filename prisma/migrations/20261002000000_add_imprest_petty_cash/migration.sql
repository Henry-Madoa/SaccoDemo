-- Petty Cash, Imprest Request and Imprest Surrender — AL (Sacco ERP) Tab52203444/445 "Petty
-- Cash Header/Details", Tab52203447/449 "Request Header/Lines" (Request Type Imprest → Surrender),
-- Tab52203660 "Imprest Purpose", Cod52203432 "Imprest Management", Cod52203434.PostPettyCash.
--
-- An employee is a subledger here, as in BC: every issue, surrender, refund, claim and payroll
-- recovery is an employee_ledger_entry against one control G/L account (1215), so an employee's
-- outstanding imprest balance is always the sum of their entries. Receipts gain an Employee type
-- (money in from staff) and Payment Vouchers an Employee Payment type (money out to staff), both
-- posting through the same control account.

-- ============================================================================= G/L + setup
INSERT INTO "gl_account" ("code", "name", "type", "parent_code", "is_postable", "account_type", "indentation", "status")
SELECT * FROM (VALUES
  ('1215', 'Staff Imprest and Advances', 'ASSET', '1200', 1, 'POSTING', 1, 'ACTIVE')
) AS v(code, name, type, parent_code, is_postable, account_type, indentation, status)
WHERE EXISTS (SELECT 1 FROM "organisation")
ON CONFLICT ("code") DO NOTHING;

-- AL General Ledger Setup: "Petty Cash Limit", "Max No Outstanding Imprests", and the control
-- account the Employee subledger posts through. The surrender period sets an issued imprest's
-- due date (AL leaves Due Date to the officer; a default is friendlier).
ALTER TABLE "organisation" ADD COLUMN "petty_cash_limit" BIGINT NOT NULL DEFAULT 0;
ALTER TABLE "organisation" ADD COLUMN "max_outstanding_imprests" INTEGER NOT NULL DEFAULT 1;
ALTER TABLE "organisation" ADD COLUMN "imprest_control_account_id" INTEGER;
ALTER TABLE "organisation" ADD COLUMN "imprest_surrender_period" TEXT NOT NULL DEFAULT '14D';
ALTER TABLE "organisation" ADD CONSTRAINT "organisation_imprest_control_account_id_fkey"
  FOREIGN KEY ("imprest_control_account_id") REFERENCES "gl_account"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;
UPDATE "organisation" SET "imprest_control_account_id" = (SELECT id FROM "gl_account" WHERE code = '1215')
WHERE "imprest_control_account_id" IS NULL;

-- ============================================================================= employee subledger
CREATE TABLE "employee_ledger_entry" (
  "id"           SERIAL NOT NULL,
  "employee_id"  INTEGER NOT NULL,
  -- IMPREST_ISSUE | IMPREST_SURRENDER | IMPREST_REFUND | CLAIM_PAID | PAYROLL_RECOVERY | PAYROLL_CLAIM
  -- | RECEIPT | PAYMENT | PETTY_CASH
  "entry_type"   TEXT NOT NULL,
  "document_no"  TEXT NOT NULL,
  "posting_date" TEXT NOT NULL,
  -- Positive: the employee owes the SACCO (an issue, a payment). Negative: settled or owed to them.
  "amount"       BIGINT NOT NULL DEFAULT 0,
  "description"  TEXT,
  "journal_id"   INTEGER,
  "created_at"   TEXT,
  "created_by"   TEXT,
  CONSTRAINT "employee_ledger_entry_pkey" PRIMARY KEY ("id"),
  CONSTRAINT "ele_employee_fkey" FOREIGN KEY ("employee_id") REFERENCES "employee"("id") ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT "ele_journal_fkey" FOREIGN KEY ("journal_id") REFERENCES "journal"("id") ON DELETE NO ACTION ON UPDATE NO ACTION
);
CREATE INDEX "ix_ele_employee" ON "employee_ledger_entry"("employee_id");
CREATE INDEX "ix_ele_document" ON "employee_ledger_entry"("document_no");

-- ============================================================================= imprest
-- AL Tab52203660.
CREATE TABLE "imprest_purpose" (
  "code"        TEXT NOT NULL,
  "description" TEXT NOT NULL,
  "status"      TEXT NOT NULL DEFAULT 'ACTIVE',
  CONSTRAINT "imprest_purpose_pkey" PRIMARY KEY ("code")
);

-- AL Tab52203447 with Request Type Imprest. One row carries the request and, once issued, its
-- surrender — the AL flips the same header's Request Type to Surrender on posting.
CREATE TABLE "imprest_request" (
  "no"                       TEXT NOT NULL,
  "employee_id"              INTEGER NOT NULL,
  "request_date"             TEXT NOT NULL,
  "purpose_code"             TEXT,
  "purpose"                  TEXT NOT NULL,
  "description"              TEXT,
  "request_for"              TEXT NOT NULL DEFAULT 'Self',
  "departure_location"       TEXT,
  "departure_date"           TEXT,
  "return_date"              TEXT,
  "total_days"               INTEGER NOT NULL DEFAULT 0,
  "justification"            TEXT,
  "phone_no"                 TEXT,
  "currency_code"            TEXT NOT NULL DEFAULT 'KES',
  -- How the imprest is paid out.
  "paying_bank_account_id"   INTEGER,
  "pay_mode_code"            TEXT,
  "payment_tx_no"            TEXT,
  "cheque_date"              TEXT,
  "due_date"                 TEXT,
  -- Maker-checker on the request.
  "status"                   TEXT NOT NULL DEFAULT 'Open',
  "decision_reason"          TEXT,
  "posted"                   BOOLEAN NOT NULL DEFAULT false,
  "posted_at"                TEXT,
  "posted_by"                TEXT,
  "posted_journal_id"        INTEGER,
  -- Issued by a Payment Voucher rather than posted here (the PV's Employee Payment line).
  "pv_no"                    TEXT,
  -- The surrender: its own approval and posting.
  "surrender_status"         TEXT NOT NULL DEFAULT 'Open',
  "surrender_date"           TEXT,
  "surrender_decision_reason" TEXT,
  "surrendered"              BOOLEAN NOT NULL DEFAULT false,
  "surrender_posted_at"      TEXT,
  "surrender_posted_by"      TEXT,
  "surrender_journal_id"     INTEGER,
  -- Receive Now | Deduct from Payroll (refund due) — Pay Now | Pay from Payroll (claim due)
  "settlement"               TEXT,
  "receiving_bank_account_id" INTEGER,
  "receipt_mode_code"        TEXT,
  "receipt_tx_no"            TEXT,
  "claim_paying_bank_account_id" INTEGER,
  "claim_pay_mode_code"      TEXT,
  "claim_payment_tx_no"      TEXT,
  -- AL "Transfer To Payroll" / "Transfered To Payroll".
  "transfer_to_payroll"      BOOLEAN NOT NULL DEFAULT false,
  "transferred_to_payroll"   BOOLEAN NOT NULL DEFAULT false,
  "payroll_transaction_id"   INTEGER,
  "payroll_transferred_at"   TEXT,
  "payroll_transferred_by"   TEXT,
  "global_dimension_1_id"    INTEGER,
  "global_dimension_2_id"    INTEGER,
  "created_at"               TEXT,
  "created_by"               TEXT,
  CONSTRAINT "imprest_request_pkey" PRIMARY KEY ("no"),
  CONSTRAINT "imr_employee_fkey" FOREIGN KEY ("employee_id") REFERENCES "employee"("id") ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT "imr_purpose_fkey" FOREIGN KEY ("purpose_code") REFERENCES "imprest_purpose"("code") ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT "imr_paying_bank_fkey" FOREIGN KEY ("paying_bank_account_id") REFERENCES "bank_account"("id") ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT "imr_receiving_bank_fkey" FOREIGN KEY ("receiving_bank_account_id") REFERENCES "bank_account"("id") ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT "imr_claim_bank_fkey" FOREIGN KEY ("claim_paying_bank_account_id") REFERENCES "bank_account"("id") ON DELETE NO ACTION ON UPDATE NO ACTION
);
CREATE INDEX "ix_imr_employee" ON "imprest_request"("employee_id");
CREATE INDEX "ix_imr_status" ON "imprest_request"("status");
CREATE INDEX "ix_imr_created_by" ON "imprest_request"("created_by");

-- AL Tab52203449.
CREATE TABLE "imprest_request_line" (
  "id"             SERIAL NOT NULL,
  "request_no"     TEXT NOT NULL,
  "line_no"        INTEGER NOT NULL,
  "gl_account_id"  INTEGER NOT NULL,
  "narration"      TEXT,
  "quantity"       INTEGER NOT NULL DEFAULT 1,
  "unit_cost"      BIGINT NOT NULL DEFAULT 0,
  "request_amount" BIGINT NOT NULL DEFAULT 0,
  -- Filled in on surrender.
  "actual_spent"   BIGINT NOT NULL DEFAULT 0,
  "surrender_note" TEXT,
  CONSTRAINT "imprest_request_line_pkey" PRIMARY KEY ("id"),
  CONSTRAINT "imrl_request_fkey" FOREIGN KEY ("request_no") REFERENCES "imprest_request"("no") ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT "imrl_gl_fkey" FOREIGN KEY ("gl_account_id") REFERENCES "gl_account"("id") ON DELETE NO ACTION ON UPDATE NO ACTION
);
CREATE INDEX "ix_imrl_request" ON "imprest_request_line"("request_no");

-- ============================================================================= petty cash
-- AL Tab52203444.
CREATE TABLE "petty_cash" (
  "no"                     TEXT NOT NULL,
  "employee_id"            INTEGER NOT NULL,
  "request_date"           TEXT NOT NULL,
  "posting_date"           TEXT,
  "paying_bank_account_id" INTEGER,
  "payment_to"             TEXT,
  "on_behalf_of"           TEXT,
  "payment_narration"      TEXT NOT NULL,
  "pay_mode_code"          TEXT,
  "payment_tx_no"          TEXT,
  "cheque_date"            TEXT,
  "currency_code"          TEXT NOT NULL DEFAULT 'KES',
  "status"                 TEXT NOT NULL DEFAULT 'Open',
  "decision_reason"        TEXT,
  "posted"                 BOOLEAN NOT NULL DEFAULT false,
  "posted_at"              TEXT,
  "posted_by"              TEXT,
  "journal_id"             INTEGER,
  "paid"                   BOOLEAN NOT NULL DEFAULT false,
  "paid_at"                TEXT,
  "paid_by"                TEXT,
  "global_dimension_1_id"  INTEGER,
  "global_dimension_2_id"  INTEGER,
  "created_at"             TEXT,
  "created_by"             TEXT,
  CONSTRAINT "petty_cash_pkey" PRIMARY KEY ("no"),
  CONSTRAINT "pc_employee_fkey" FOREIGN KEY ("employee_id") REFERENCES "employee"("id") ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT "pc_paying_bank_fkey" FOREIGN KEY ("paying_bank_account_id") REFERENCES "bank_account"("id") ON DELETE NO ACTION ON UPDATE NO ACTION
);
CREATE INDEX "ix_pc_employee" ON "petty_cash"("employee_id");
CREATE INDEX "ix_pc_status" ON "petty_cash"("status");
CREATE INDEX "ix_pc_created_by" ON "petty_cash"("created_by");

-- AL Tab52203445.
CREATE TABLE "petty_cash_line" (
  "id"            SERIAL NOT NULL,
  "petty_cash_no" TEXT NOT NULL,
  "line_no"       INTEGER NOT NULL,
  "gl_account_id" INTEGER NOT NULL,
  "description"   TEXT,
  "amount"        BIGINT NOT NULL DEFAULT 0,
  CONSTRAINT "petty_cash_line_pkey" PRIMARY KEY ("id"),
  CONSTRAINT "pcl_petty_cash_fkey" FOREIGN KEY ("petty_cash_no") REFERENCES "petty_cash"("no") ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT "pcl_gl_fkey" FOREIGN KEY ("gl_account_id") REFERENCES "gl_account"("id") ON DELETE NO ACTION ON UPDATE NO ACTION
);
CREATE INDEX "ix_pcl_petty_cash" ON "petty_cash_line"("petty_cash_no");

-- ============================================================================= receipts / vouchers
-- An Employee receipt type and an Employee Payment voucher type: the header names the employee,
-- the line's account_no carries the employee no., and posting goes through the imprest control.
ALTER TABLE "receipt_header" ADD COLUMN "employee_id" INTEGER;
ALTER TABLE "receipt_header" ADD CONSTRAINT "receipt_header_employee_id_fkey"
  FOREIGN KEY ("employee_id") REFERENCES "employee"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE "posted_receipt" ADD COLUMN "employee_id" INTEGER;
ALTER TABLE "payment_voucher_header" ADD COLUMN "employee_id" INTEGER;
ALTER TABLE "payment_voucher_header" ADD CONSTRAINT "payment_voucher_header_employee_id_fkey"
  FOREIGN KEY ("employee_id") REFERENCES "employee"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE "posted_payment_voucher" ADD COLUMN "employee_id" INTEGER;

-- ============================================================================= No. Series
-- AL Advanced Finance Setup "Imprest Nos" / "Petty Cash Nos".
INSERT INTO "sequence" ("name", "prefix", "next_no", "width")
SELECT * FROM (VALUES
  ('IMPREST_REQUEST', 'IMP', 1, 5),
  ('PETTY_CASH', 'PC', 1, 5)
) AS v(name, prefix, next_no, width)
WHERE EXISTS (SELECT 1 FROM "organisation")
ON CONFLICT ("name") DO NOTHING;

INSERT INTO "no_series" ("code", "description", "default_nos", "manual_nos", "date_order")
SELECT * FROM (VALUES
  ('IMPREST_REQUEST', 'Imprest Request No.', 1, 0, 0),
  ('PETTY_CASH', 'Petty Cash No.', 1, 0, 0)
) AS v(code, description, default_nos, manual_nos, date_order)
WHERE EXISTS (SELECT 1 FROM "organisation")
ON CONFLICT ("code") DO NOTHING;

INSERT INTO "no_series_line" ("series_code", "line_no", "starting_date", "starting_no", "increment_by_no", "open", "allow_gaps")
SELECT s.name, 10000, NULL, s.prefix || LPAD(s.next_no::text, s.width, '0'), 1, 1, 0
FROM "sequence" s
WHERE s.name IN ('IMPREST_REQUEST', 'PETTY_CASH')
  AND EXISTS (SELECT 1 FROM "organisation")
  AND NOT EXISTS (SELECT 1 FROM "no_series_line" l WHERE l.series_code = s.name);

INSERT INTO "no_series_setup" ("document_code", "label", "category", "sort", "series_code")
SELECT v.code, v.label, 'Finance', v.sort, v.code
FROM (VALUES
  ('IMPREST_REQUEST', 'Imprest Request No.', 95),
  ('PETTY_CASH', 'Petty Cash No.', 96)
) AS v(code, label, sort)
WHERE EXISTS (SELECT 1 FROM "organisation")
ON CONFLICT ("document_code") DO NOTHING;

-- ============================================================================= permission backfill
INSERT INTO "permission_set_line"
  ("role_id", "object_type", "object_name", "read_perm", "insert_perm", "modify_perm", "delete_perm", "execute_perm")
SELECT r.id, g.object_type, g.object_name, g.r, g.i, g.m, g.d, g.e
FROM "role" r
JOIN (VALUES
  ('Finance Officer',    'PAGE',  'IMPREST',               0,0,0,0,1),
  ('Finance Officer',    'TABLE', 'imprest_request',       1,1,1,1,0),
  ('Finance Officer',    'TABLE', 'imprest_request_line',  1,1,1,1,0),
  ('Finance Officer',    'TABLE', 'imprest_purpose',       1,1,1,1,0),
  ('Finance Officer',    'TABLE', 'petty_cash',            1,1,1,1,0),
  ('Finance Officer',    'TABLE', 'petty_cash_line',       1,1,1,1,0),
  ('Finance Officer',    'TABLE', 'employee_ledger_entry', 1,1,0,0,0),
  ('Finance Officer',    'TABLE', 'employee',              1,0,0,0,0),
  ('Finance Officer',    'TABLE', 'journal',               1,1,0,0,0),
  ('Finance Officer',    'TABLE', 'journal_line',          1,1,0,0,0),
  ('Finance Manager',    'PAGE',  'IMPREST',               0,0,0,0,1),
  ('Finance Manager',    'TABLE', 'imprest_request',       1,1,1,1,0),
  ('Finance Manager',    'TABLE', 'imprest_request_line',  1,1,1,1,0),
  ('Finance Manager',    'TABLE', 'imprest_purpose',       1,1,1,1,0),
  ('Finance Manager',    'TABLE', 'petty_cash',            1,1,1,1,0),
  ('Finance Manager',    'TABLE', 'petty_cash_line',       1,1,1,1,0),
  ('Finance Manager',    'TABLE', 'employee_ledger_entry', 1,1,0,0,0),
  ('Finance Manager',    'TABLE', 'employee',              1,0,0,0,0),
  ('Finance Manager',    'TABLE', 'journal',               1,1,0,0,0),
  ('Finance Manager',    'TABLE', 'journal_line',          1,1,0,0,0),
  ('Accountant',         'PAGE',  'IMPREST',               0,0,0,0,1),
  ('Accountant',         'TABLE', 'imprest_request',       1,1,1,1,0),
  ('Accountant',         'TABLE', 'imprest_request_line',  1,1,1,1,0),
  ('Accountant',         'TABLE', 'imprest_purpose',       1,0,0,0,0),
  ('Accountant',         'TABLE', 'petty_cash',            1,1,1,1,0),
  ('Accountant',         'TABLE', 'petty_cash_line',       1,1,1,1,0),
  ('Accountant',         'TABLE', 'employee_ledger_entry', 1,1,0,0,0),
  ('Accountant',         'TABLE', 'employee',              1,0,0,0,0),
  ('Accountant',         'TABLE', 'journal',               1,1,0,0,0),
  ('Accountant',         'TABLE', 'journal_line',          1,1,0,0,0),
  ('HR Payroll Officer', 'PAGE',  'IMPREST',               0,0,0,0,1),
  ('HR Payroll Officer', 'TABLE', 'imprest_request',       1,0,1,0,0),
  ('HR Payroll Officer', 'TABLE', 'imprest_request_line',  1,0,0,0,0),
  ('HR Payroll Officer', 'TABLE', 'employee_ledger_entry', 1,0,0,0,0),
  ('HR Payroll Officer', 'TABLE', 'employee_payroll_transaction', 1,1,1,1,0),
  ('Internal Auditor',   'PAGE',  'IMPREST',               0,0,0,0,1),
  ('Internal Auditor',   'TABLE', 'imprest_request',       1,0,0,0,0),
  ('Internal Auditor',   'TABLE', 'imprest_request_line',  1,0,0,0,0),
  ('Internal Auditor',   'TABLE', 'imprest_purpose',       1,0,0,0,0),
  ('Internal Auditor',   'TABLE', 'petty_cash',            1,0,0,0,0),
  ('Internal Auditor',   'TABLE', 'petty_cash_line',       1,0,0,0,0),
  ('Internal Auditor',   'TABLE', 'employee_ledger_entry', 1,0,0,0,0)
) AS g(role_name, object_type, object_name, r, i, m, d, e) ON g.role_name = r.name
ON CONFLICT ("role_id", "object_type", "object_name") DO UPDATE SET
  "read_perm"    = GREATEST("permission_set_line"."read_perm",    EXCLUDED."read_perm"),
  "insert_perm"  = GREATEST("permission_set_line"."insert_perm",  EXCLUDED."insert_perm"),
  "modify_perm"  = GREATEST("permission_set_line"."modify_perm",  EXCLUDED."modify_perm"),
  "delete_perm"  = GREATEST("permission_set_line"."delete_perm",  EXCLUDED."delete_perm"),
  "execute_perm" = GREATEST("permission_set_line"."execute_perm", EXCLUDED."execute_perm");
