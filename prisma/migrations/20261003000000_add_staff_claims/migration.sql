-- Staff Claim — AL (Sacco ERP) Tab52203447 "Request Header" with Request Type "Staff Claim",
-- Pag52203468/471, Cod52203432.PostStaffClaim. An employee spent their own money on the SACCO's
-- business and claims it back: lines of what was spent, approval, then payment from a bank
-- account — or through payroll — posted through the same employee subledger as imprests.
CREATE TABLE "staff_claim" (
  "no"                     TEXT NOT NULL,
  "employee_id"            INTEGER NOT NULL,
  "claim_date"             TEXT NOT NULL,
  "description"            TEXT NOT NULL,
  "justification"          TEXT,
  "currency_code"          TEXT NOT NULL DEFAULT 'KES',
  -- Pay Now (from the bank account below) | Pay from Payroll
  "settlement"             TEXT NOT NULL DEFAULT 'Pay Now',
  "paying_bank_account_id" INTEGER,
  "pay_mode_code"          TEXT,
  "payment_tx_no"          TEXT,
  "status"                 TEXT NOT NULL DEFAULT 'Open',
  "decision_reason"        TEXT,
  "posted"                 BOOLEAN NOT NULL DEFAULT false,
  "posted_at"              TEXT,
  "posted_by"              TEXT,
  "journal_id"             INTEGER,
  -- AL "Payment Stopped": an approved claim held back from posting.
  "payment_stopped"        BOOLEAN NOT NULL DEFAULT false,
  "stopped_at"             TEXT,
  "stopped_by"             TEXT,
  "stop_reason"            TEXT,
  "transferred_to_payroll" BOOLEAN NOT NULL DEFAULT false,
  "payroll_transaction_id" INTEGER,
  "global_dimension_1_id"  INTEGER,
  "global_dimension_2_id"  INTEGER,
  "created_at"             TEXT,
  "created_by"             TEXT,
  CONSTRAINT "staff_claim_pkey" PRIMARY KEY ("no"),
  CONSTRAINT "scl_employee_fkey" FOREIGN KEY ("employee_id") REFERENCES "employee"("id") ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT "scl_paying_bank_fkey" FOREIGN KEY ("paying_bank_account_id") REFERENCES "bank_account"("id") ON DELETE NO ACTION ON UPDATE NO ACTION
);
CREATE INDEX "ix_scl_employee" ON "staff_claim"("employee_id");
CREATE INDEX "ix_scl_status" ON "staff_claim"("status");
CREATE INDEX "ix_scl_created_by" ON "staff_claim"("created_by");

CREATE TABLE "staff_claim_line" (
  "id"            SERIAL NOT NULL,
  "claim_no"      TEXT NOT NULL,
  "line_no"       INTEGER NOT NULL,
  "gl_account_id" INTEGER NOT NULL,
  "narration"     TEXT,
  "expense_date"  TEXT,
  "receipt_ref"   TEXT,
  "quantity"      INTEGER NOT NULL DEFAULT 1,
  "unit_cost"     BIGINT NOT NULL DEFAULT 0,
  "amount"        BIGINT NOT NULL DEFAULT 0,
  CONSTRAINT "staff_claim_line_pkey" PRIMARY KEY ("id"),
  CONSTRAINT "scll_claim_fkey" FOREIGN KEY ("claim_no") REFERENCES "staff_claim"("no") ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT "scll_gl_fkey" FOREIGN KEY ("gl_account_id") REFERENCES "gl_account"("id") ON DELETE NO ACTION ON UPDATE NO ACTION
);
CREATE INDEX "ix_scll_claim" ON "staff_claim_line"("claim_no");

-- No. Series — AL Advanced Finance Setup "Staff Claim Nos".
INSERT INTO "sequence" ("name", "prefix", "next_no", "width")
SELECT 'STAFF_CLAIM', 'SCL', 1, 5 WHERE EXISTS (SELECT 1 FROM "organisation") ON CONFLICT ("name") DO NOTHING;
INSERT INTO "no_series" ("code", "description", "default_nos", "manual_nos", "date_order")
SELECT 'STAFF_CLAIM', 'Staff Claim No.', 1, 0, 0 WHERE EXISTS (SELECT 1 FROM "organisation") ON CONFLICT ("code") DO NOTHING;
INSERT INTO "no_series_line" ("series_code", "line_no", "starting_date", "starting_no", "increment_by_no", "open", "allow_gaps")
SELECT s.name, 10000, NULL, s.prefix || LPAD(s.next_no::text, s.width, '0'), 1, 1, 0
FROM "sequence" s WHERE s.name = 'STAFF_CLAIM' AND EXISTS (SELECT 1 FROM "organisation")
  AND NOT EXISTS (SELECT 1 FROM "no_series_line" l WHERE l.series_code = s.name);
INSERT INTO "no_series_setup" ("document_code", "label", "category", "sort", "series_code")
SELECT 'STAFF_CLAIM', 'Staff Claim No.', 'Finance', 97, 'STAFF_CLAIM' WHERE EXISTS (SELECT 1 FROM "organisation") ON CONFLICT ("document_code") DO NOTHING;

-- Permissions: the roles that work imprests work claims.
INSERT INTO "permission_set_line"
  ("role_id", "object_type", "object_name", "read_perm", "insert_perm", "modify_perm", "delete_perm", "execute_perm")
SELECT r.id, g.object_type, g.object_name, g.r, g.i, g.m, g.d, g.e
FROM "role" r
JOIN (VALUES
  ('Finance Officer',    'TABLE', 'staff_claim',      1,1,1,1,0),
  ('Finance Officer',    'TABLE', 'staff_claim_line', 1,1,1,1,0),
  ('Finance Manager',    'TABLE', 'staff_claim',      1,1,1,1,0),
  ('Finance Manager',    'TABLE', 'staff_claim_line', 1,1,1,1,0),
  ('Accountant',         'TABLE', 'staff_claim',      1,1,1,1,0),
  ('Accountant',         'TABLE', 'staff_claim_line', 1,1,1,1,0),
  ('HR Payroll Officer', 'TABLE', 'staff_claim',      1,0,0,0,0),
  ('HR Payroll Officer', 'TABLE', 'staff_claim_line', 1,0,0,0,0),
  ('Internal Auditor',   'TABLE', 'staff_claim',      1,0,0,0,0),
  ('Internal Auditor',   'TABLE', 'staff_claim_line', 1,0,0,0,0)
) AS g(role_name, object_type, object_name, r, i, m, d, e) ON g.role_name = r.name
ON CONFLICT ("role_id", "object_type", "object_name") DO UPDATE SET
  "read_perm"    = GREATEST("permission_set_line"."read_perm",    EXCLUDED."read_perm"),
  "insert_perm"  = GREATEST("permission_set_line"."insert_perm",  EXCLUDED."insert_perm"),
  "modify_perm"  = GREATEST("permission_set_line"."modify_perm",  EXCLUDED."modify_perm"),
  "delete_perm"  = GREATEST("permission_set_line"."delete_perm",  EXCLUDED."delete_perm"),
  "execute_perm" = GREATEST("permission_set_line"."execute_perm", EXCLUDED."execute_perm");
