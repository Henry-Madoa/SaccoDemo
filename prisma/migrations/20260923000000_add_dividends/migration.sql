-- Dividend Module — ported from the Nation CBS AL extension (Sacco CBS/src):
--   Tab52204068 "Dividend Header"              -> dividend
--   Tab52204070 "Dividend Calculation Params"  -> dividend_param
--   Tab52204071 "Dividend Member List"         -> (transient; the member sweep writes lines directly)
--   Tab52204069 "Dividend Lines"               -> dividend_line
--   Tab52204073 "Dividend Det. Entries"        -> dividend_det_entry
--   Tab52204074 "Dividend Earned Entries"      -> dividend_earned_entry  (Manual Upload)
--   Tab52204067 "Dividend Recoveries"          -> dividend_recovery
--   Tab52204072 "Dividend Withdrawn Members"   -> dividend_withdrawn_member
--   Cod52204023 "Dividend Management"          -> lib/dividends.ts
--
-- Money is in cents throughout, matching every other module here; the AL keeps Decimals.

CREATE TABLE "dividend" (
  "id"                      SERIAL PRIMARY KEY,
  "no"                      TEXT NOT NULL UNIQUE,
  -- AL "Document Type": which book the dividend is declared out of.
  "document_type"           TEXT NOT NULL DEFAULT 'BOSA',
  "description"             TEXT NOT NULL,
  "posting_description"     TEXT,
  "dividend_year"           INTEGER NOT NULL,
  "start_date"              TEXT NOT NULL,
  "end_date"                TEXT NOT NULL,
  "posting_date"            TEXT NOT NULL,
  -- Provisioning raises the expense and the payable; Payout settles the payable to members.
  "posting_type"            TEXT NOT NULL DEFAULT 'Provisioning',
  -- Automatic walks the member ledgers month by month; Manual Upload takes the amounts as given.
  "computation_type"        TEXT NOT NULL DEFAULT 'Automatic',
  "transaction_charge_id"   INTEGER REFERENCES "transaction_charge"("id"),
  "expense_account_id"      INTEGER REFERENCES "gl_account"("id"),
  "payable_account_id"      INTEGER REFERENCES "gl_account"("id"),
  "recover_loans"           INTEGER NOT NULL DEFAULT 0,
  "boost_to_minimum"        INTEGER NOT NULL DEFAULT 0,
  "maximum_boost_amount"    BIGINT NOT NULL DEFAULT 0,
  "preferential_boost"      INTEGER NOT NULL DEFAULT 0,
  "global_dimension_1_id"   INTEGER REFERENCES "global_dimension_1_value"("id"),
  "global_dimension_2_id"   INTEGER REFERENCES "global_dimension_2_value"("id"),
  "status"                  TEXT NOT NULL DEFAULT 'Open',
  "decision_reason"         TEXT,
  "calculated_at"           TEXT,
  "posted"                  INTEGER NOT NULL DEFAULT 0,
  "posted_at"               TEXT,
  "posted_by"               TEXT,
  "journal_id"              INTEGER REFERENCES "journal"("id"),
  "created_at"              TEXT,
  "created_by"              TEXT
);

-- One row per savings product the dividend is declared on, with its own rate and treatment.
CREATE TABLE "dividend_param" (
  "id"                        SERIAL PRIMARY KEY,
  "dividend_id"               INTEGER NOT NULL REFERENCES "dividend"("id") ON DELETE CASCADE,
  "product_id"                INTEGER NOT NULL REFERENCES "savings_product"("id"),
  "posting_description"       TEXT NOT NULL,
  -- Annual rate as a percentage, e.g. 12.5.
  "rate"                      DOUBLE PRECISION NOT NULL DEFAULT 0,
  -- Proration Type: 'Pro Rated' (non-withdrawable deposits and share capital — opening balance
  -- earns the full year, later months earn on their own increase for the months remaining),
  -- 'Minimum Balance' (withdrawable accounts, the bank passbook rule — each month earns on the
  -- lowest balance held that month), or 'Straight Line' (flat rate on the closing balance).
  "rate_type"                 TEXT NOT NULL DEFAULT 'Pro Rated',
  -- Where the earning lands: the member's FOSA savings account, the earning account itself,
  -- or held as a payable.
  "post_to"                   TEXT NOT NULL DEFAULT 'Savings',
  "is_share_capital"          INTEGER NOT NULL DEFAULT 0,
  "minimum_balance"           BIGINT NOT NULL DEFAULT 0,
  "qualified_minimum_balance" BIGINT NOT NULL DEFAULT 0,
  "maximum_boost_amount"      BIGINT NOT NULL DEFAULT 0,
  UNIQUE ("dividend_id", "product_id")
);

-- One row per member account that earns. AL: "Dividend Lines".
CREATE TABLE "dividend_line" (
  "id"                    SERIAL PRIMARY KEY,
  "dividend_id"           INTEGER NOT NULL REFERENCES "dividend"("id") ON DELETE CASCADE,
  "member_id"             INTEGER NOT NULL REFERENCES "member"("id"),
  "member_no"             TEXT NOT NULL,
  "member_name"           TEXT NOT NULL,
  "product_id"            INTEGER NOT NULL REFERENCES "savings_product"("id"),
  "savings_account_id"    INTEGER NOT NULL REFERENCES "savings_account"("id"),
  "account_no"            TEXT NOT NULL,
  -- Where a Post To = Savings earning is credited; null when the member has no FOSA account.
  "destination_account_id" INTEGER REFERENCES "savings_account"("id"),
  "posting_description"   TEXT,
  "account_balance"       BIGINT NOT NULL DEFAULT 0,
  "amount_earned"         BIGINT NOT NULL DEFAULT 0,
  "total_recoveries"      BIGINT NOT NULL DEFAULT 0,
  "net_amount"            BIGINT NOT NULL DEFAULT 0,
  "preferential_boost"    INTEGER NOT NULL DEFAULT 0,
  "preferential_boost_pct" DOUBLE PRECISION NOT NULL DEFAULT 0,
  "deceased"              INTEGER NOT NULL DEFAULT 0,
  "blocked_account"       INTEGER NOT NULL DEFAULT 0,
  "phone_no"              TEXT,
  "posted"                INTEGER NOT NULL DEFAULT 0,
  UNIQUE ("dividend_id", "savings_account_id")
);
CREATE INDEX "ix_dividend_line_member" ON "dividend_line" ("dividend_id", "member_id");

-- The month-by-month working behind each line. AL: "Dividend Det. Entries".
CREATE TABLE "dividend_det_entry" (
  "id"                     SERIAL PRIMARY KEY,
  "dividend_id"            INTEGER NOT NULL REFERENCES "dividend"("id") ON DELETE CASCADE,
  "dividend_line_id"       INTEGER NOT NULL REFERENCES "dividend_line"("id") ON DELETE CASCADE,
  "member_id"              INTEGER NOT NULL REFERENCES "member"("id"),
  "savings_account_id"     INTEGER NOT NULL REFERENCES "savings_account"("id"),
  "month_no"               INTEGER NOT NULL,
  "year"                   INTEGER NOT NULL,
  "month_code"             TEXT NOT NULL,
  "description"            TEXT,
  "posting_type"           TEXT NOT NULL DEFAULT 'Pro Rated',
  "rate"                   DOUBLE PRECISION NOT NULL DEFAULT 0,
  "ratio"                  DOUBLE PRECISION NOT NULL DEFAULT 1,
  "min_balance"            BIGINT NOT NULL DEFAULT 0,
  "previous_month_balance" BIGINT NOT NULL DEFAULT 0,
  "current_month_balance"  BIGINT NOT NULL DEFAULT 0,
  "net_change"             BIGINT NOT NULL DEFAULT 0,
  "minimum_running_balance" BIGINT NOT NULL DEFAULT 0,
  "amount"                 BIGINT NOT NULL DEFAULT 0
);
CREATE INDEX "ix_dividend_det_line" ON "dividend_det_entry" ("dividend_line_id", "month_no");

-- Manual Upload amounts. AL: "Dividend Earned Entries".
CREATE TABLE "dividend_earned_entry" (
  "id"                 SERIAL PRIMARY KEY,
  "dividend_id"        INTEGER NOT NULL REFERENCES "dividend"("id") ON DELETE CASCADE,
  "member_id"          INTEGER NOT NULL REFERENCES "member"("id"),
  "savings_account_id" INTEGER NOT NULL REFERENCES "savings_account"("id"),
  "description"        TEXT,
  "amount"             BIGINT NOT NULL DEFAULT 0,
  "created_at"         TEXT,
  "created_by"         TEXT,
  UNIQUE ("dividend_id", "savings_account_id")
);

-- Everything deducted from, or added to, a line before it is paid. AL: "Dividend Recoveries".
CREATE TABLE "dividend_recovery" (
  "id"                 SERIAL PRIMARY KEY,
  "dividend_id"        INTEGER NOT NULL REFERENCES "dividend"("id") ON DELETE CASCADE,
  "dividend_line_id"   INTEGER NOT NULL REFERENCES "dividend_line"("id") ON DELETE CASCADE,
  "member_id"          INTEGER NOT NULL REFERENCES "member"("id"),
  -- CHARGES | PENALTY | INTEREST_ARREARS | PRINCIPAL_ARREARS | INTEREST_PAID | PRINCIPAL_PAID
  -- | BOOST | PREFERENTIAL_BOOST. PENALTY is not in the AL enum: this system keeps a separate
  -- loan penalty balance, and a recovery has to say which part of the debt it cleared.
  "entry_type"         TEXT NOT NULL,
  "recovery_code"      TEXT,
  "description"        TEXT NOT NULL,
  "loan_id"            INTEGER REFERENCES "loan"("id"),
  "target_account_id"  INTEGER REFERENCES "savings_account"("id"),
  "charge_id"          INTEGER REFERENCES "transaction_charge"("id"),
  -- Negative: every recovery reduces what the member is paid.
  "amount"             BIGINT NOT NULL DEFAULT 0,
  "priority"           INTEGER NOT NULL DEFAULT 0
);
CREATE INDEX "ix_dividend_recovery_line" ON "dividend_recovery" ("dividend_line_id", "entry_type");

-- Members whose exit matured inside the dividend year — flagged for the officer to review.
-- AL: "Dividend Withdrawn Members".
CREATE TABLE "dividend_withdrawn_member" (
  "id"           SERIAL PRIMARY KEY,
  "dividend_id"  INTEGER NOT NULL REFERENCES "dividend"("id") ON DELETE CASCADE,
  "member_id"    INTEGER NOT NULL REFERENCES "member"("id"),
  "member_no"    TEXT NOT NULL,
  "member_name"  TEXT NOT NULL,
  "exit_no"      TEXT,
  "maturity_date" TEXT,
  UNIQUE ("dividend_id", "member_id")
);

-- ============================================================================= No. Series

INSERT INTO "sequence" ("name", "prefix", "next_no", "width")
SELECT * FROM (VALUES
  ('BOSA_DIVIDEND', 'DIV', 1, 5),
  ('FOSA_DIVIDEND', 'FINT', 1, 5)
) AS v(name, prefix, next_no, width)
WHERE EXISTS (SELECT 1 FROM "organisation")
ON CONFLICT ("name") DO NOTHING;

INSERT INTO "no_series" ("code", "description", "default_nos", "manual_nos", "date_order")
SELECT * FROM (VALUES
  ('BOSA_DIVIDEND', 'BOSA Dividend No.', 1, 0, 0),
  ('FOSA_DIVIDEND', 'FOSA Interest Declaration No.', 1, 0, 0)
) AS v(code, description, default_nos, manual_nos, date_order)
WHERE EXISTS (SELECT 1 FROM "organisation")
ON CONFLICT ("code") DO NOTHING;

INSERT INTO "no_series_line" ("series_code", "line_no", "starting_date", "starting_no", "increment_by_no", "open", "allow_gaps")
SELECT s.name, 10000, NULL, s.prefix || LPAD(s.next_no::text, s.width, '0'), 1, 1, 0
FROM "sequence" s
WHERE s.name IN ('BOSA_DIVIDEND', 'FOSA_DIVIDEND')
  AND EXISTS (SELECT 1 FROM "organisation")
  AND NOT EXISTS (SELECT 1 FROM "no_series_line" l WHERE l.series_code = s.name);

INSERT INTO "no_series_setup" ("document_code", "label", "category", "sort", "series_code")
SELECT v.code, v.label, 'Finance', v.sort, v.code
FROM (VALUES
  ('BOSA_DIVIDEND', 'BOSA Dividend No.', 91),
  ('FOSA_DIVIDEND', 'FOSA Interest Declaration No.', 92)
) AS v(code, label, sort)
WHERE EXISTS (SELECT 1 FROM "organisation")
ON CONFLICT ("document_code") DO NOTHING;

-- ============================================================================= permission backfill

INSERT INTO "permission_set_line"
  ("role_id", "object_type", "object_name", "read_perm", "insert_perm", "modify_perm", "delete_perm", "execute_perm")
SELECT r.id, g.object_type, g.object_name, g.r, g.i, g.m, g.d, g.e
FROM "role" r
JOIN (VALUES
  ('Finance Officer',  'TABLE', 'dividend',                  1,1,1,1,0),
  ('Finance Officer',  'TABLE', 'dividend_param',            1,1,1,1,0),
  ('Finance Officer',  'TABLE', 'dividend_line',             1,1,1,1,0),
  ('Finance Officer',  'TABLE', 'dividend_det_entry',        1,1,1,1,0),
  ('Finance Officer',  'TABLE', 'dividend_earned_entry',     1,1,1,1,0),
  ('Finance Officer',  'TABLE', 'dividend_recovery',         1,1,1,1,0),
  ('Finance Officer',  'TABLE', 'dividend_withdrawn_member', 1,1,1,1,0),
  ('Internal Auditor', 'TABLE', 'dividend',                  1,0,0,0,0),
  ('Internal Auditor', 'TABLE', 'dividend_param',            1,0,0,0,0),
  ('Internal Auditor', 'TABLE', 'dividend_line',             1,0,0,0,0),
  ('Internal Auditor', 'TABLE', 'dividend_det_entry',        1,0,0,0,0),
  ('Internal Auditor', 'TABLE', 'dividend_earned_entry',     1,0,0,0,0),
  ('Internal Auditor', 'TABLE', 'dividend_recovery',         1,0,0,0,0),
  ('Internal Auditor', 'TABLE', 'dividend_withdrawn_member', 1,0,0,0,0)
) AS g(role_name, object_type, object_name, r, i, m, d, e) ON g.role_name = r.name
ON CONFLICT ("role_id", "object_type", "object_name") DO UPDATE SET
  "read_perm"    = GREATEST("permission_set_line"."read_perm",    EXCLUDED."read_perm"),
  "insert_perm"  = GREATEST("permission_set_line"."insert_perm",  EXCLUDED."insert_perm"),
  "modify_perm"  = GREATEST("permission_set_line"."modify_perm",  EXCLUDED."modify_perm"),
  "delete_perm"  = GREATEST("permission_set_line"."delete_perm",  EXCLUDED."delete_perm"),
  "execute_perm" = GREATEST("permission_set_line"."execute_perm", EXCLUDED."execute_perm");
