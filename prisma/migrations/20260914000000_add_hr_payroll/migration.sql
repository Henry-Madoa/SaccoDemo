-- Payroll — the third of three HR & Payroll modules ported from "Sacco ERP" AL. Unlike the AL
-- source (which only tags lines with a G/L account for an external export), Payroll here posts
-- real double-entry journal entries via the existing postJournal() engine on period close — this
-- app already has a first-class G/L every other financial module posts to (user-confirmed choice).
-- NSSF is modelled as correct Kenyan Tier I/Tier II tiered accumulation — the AL source only reads
-- its first tier row (a bug), not real NSSF rules. Seeded rates are 2024+ defaults; confirm against
-- the current KRA/NSSF gazette before go-live.

CREATE TABLE "hr_payroll_setup" (
    "id"                            INTEGER NOT NULL DEFAULT 1,
    "personal_relief_cents"         BIGINT  NOT NULL DEFAULT 240000,
    "insurance_relief_pct"          DOUBLE PRECISION NOT NULL DEFAULT 15,
    "max_relief_cents"              BIGINT  NOT NULL DEFAULT 6000000,
    "mortgage_relief_cents"         BIGINT  NOT NULL DEFAULT 3000000,
    "shif_pct"                      DOUBLE PRECISION NOT NULL DEFAULT 2.75,
    "shif_based_on"                 TEXT    NOT NULL DEFAULT 'GROSS',
    "nssf_employer_factor"          DOUBLE PRECISION NOT NULL DEFAULT 1,
    "housing_levy_enabled"          BOOLEAN NOT NULL DEFAULT true,
    "housing_levy_pct"              DOUBLE PRECISION NOT NULL DEFAULT 1.5,
    "housing_levy_based_on"         TEXT    NOT NULL DEFAULT 'GROSS',
    "minimum_relief_threshold_cents" BIGINT NOT NULL DEFAULT 0,
    "secondary_tax_pct"             DOUBLE PRECISION NOT NULL DEFAULT 30,
    "monthly_working_days"          INTEGER NOT NULL DEFAULT 22,
    "updated_at"                    TEXT,
    "updated_by"                    TEXT,
    CONSTRAINT "hr_payroll_setup_pkey" PRIMARY KEY ("id")
);
INSERT INTO "hr_payroll_setup" ("id") VALUES (1);

CREATE TABLE "payroll_posting_group" (
    "id"                                       SERIAL NOT NULL,
    "code"                                     TEXT   NOT NULL,
    "name"                                     TEXT   NOT NULL,
    "salary_expense_account_id"                INTEGER NOT NULL,
    "paye_payable_account_id"                  INTEGER NOT NULL,
    "net_pay_payable_account_id"               INTEGER NOT NULL,
    "nssf_employee_payable_account_id"         INTEGER NOT NULL,
    "nssf_employer_expense_account_id"         INTEGER NOT NULL,
    "nssf_employer_payable_account_id"         INTEGER NOT NULL,
    "shif_payable_account_id"                  INTEGER NOT NULL,
    "housing_levy_employee_payable_account_id" INTEGER NOT NULL,
    "housing_levy_employer_expense_account_id" INTEGER NOT NULL,
    "housing_levy_employer_payable_account_id" INTEGER NOT NULL,
    "created_at"                               TEXT,
    "created_by"                               TEXT,
    CONSTRAINT "payroll_posting_group_pkey" PRIMARY KEY ("id")
);
CREATE UNIQUE INDEX "payroll_posting_group_code_key" ON "payroll_posting_group"("code");
ALTER TABLE "payroll_posting_group" ADD CONSTRAINT "ppg_salary_expense_fkey" FOREIGN KEY ("salary_expense_account_id") REFERENCES "gl_account"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE "payroll_posting_group" ADD CONSTRAINT "ppg_paye_payable_fkey" FOREIGN KEY ("paye_payable_account_id") REFERENCES "gl_account"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE "payroll_posting_group" ADD CONSTRAINT "ppg_net_pay_payable_fkey" FOREIGN KEY ("net_pay_payable_account_id") REFERENCES "gl_account"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE "payroll_posting_group" ADD CONSTRAINT "ppg_nssf_employee_payable_fkey" FOREIGN KEY ("nssf_employee_payable_account_id") REFERENCES "gl_account"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE "payroll_posting_group" ADD CONSTRAINT "ppg_nssf_employer_expense_fkey" FOREIGN KEY ("nssf_employer_expense_account_id") REFERENCES "gl_account"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE "payroll_posting_group" ADD CONSTRAINT "ppg_nssf_employer_payable_fkey" FOREIGN KEY ("nssf_employer_payable_account_id") REFERENCES "gl_account"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE "payroll_posting_group" ADD CONSTRAINT "ppg_shif_payable_fkey" FOREIGN KEY ("shif_payable_account_id") REFERENCES "gl_account"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE "payroll_posting_group" ADD CONSTRAINT "ppg_hl_employee_payable_fkey" FOREIGN KEY ("housing_levy_employee_payable_account_id") REFERENCES "gl_account"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE "payroll_posting_group" ADD CONSTRAINT "ppg_hl_employer_expense_fkey" FOREIGN KEY ("housing_levy_employer_expense_account_id") REFERENCES "gl_account"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE "payroll_posting_group" ADD CONSTRAINT "ppg_hl_employer_payable_fkey" FOREIGN KEY ("housing_levy_employer_payable_account_id") REFERENCES "gl_account"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

ALTER TABLE "employee" ADD CONSTRAINT "employee_posting_group_fkey" FOREIGN KEY ("posting_group_id") REFERENCES "payroll_posting_group"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

CREATE TABLE "payroll_paye_band" (
    "id"               SERIAL NOT NULL,
    "sort_order"       INTEGER NOT NULL,
    "upper_bound_cents" BIGINT,
    "rate_pct"         DOUBLE PRECISION NOT NULL,
    CONSTRAINT "payroll_paye_band_pkey" PRIMARY KEY ("id")
);

CREATE TABLE "payroll_nssf_tier" (
    "id"                SERIAL NOT NULL,
    "tier_no"           INTEGER NOT NULL,
    "lower_limit_cents" BIGINT NOT NULL,
    "upper_limit_cents" BIGINT NOT NULL,
    "employee_rate_pct" DOUBLE PRECISION NOT NULL,
    "employer_rate_pct" DOUBLE PRECISION NOT NULL,
    CONSTRAINT "payroll_nssf_tier_pkey" PRIMARY KEY ("id")
);
CREATE UNIQUE INDEX "payroll_nssf_tier_tier_no_key" ON "payroll_nssf_tier"("tier_no");

CREATE TABLE "payroll_transaction_code" (
    "id"                  SERIAL NOT NULL,
    "code"                TEXT   NOT NULL,
    "name"                TEXT   NOT NULL,
    "type"                TEXT   NOT NULL DEFAULT 'INCOME',
    "taxable"             BOOLEAN NOT NULL DEFAULT true,
    "is_formula"          BOOLEAN NOT NULL DEFAULT false,
    "formula"             TEXT,
    "fixed_amount_cents"  BIGINT NOT NULL DEFAULT 0,
    "upper_limit_cents"   BIGINT,
    "balance_type"        TEXT   NOT NULL DEFAULT 'NONE',
    "special_type"        TEXT   NOT NULL DEFAULT 'NONE',
    "gl_account_id"       INTEGER,
    "employer_gl_account_id" INTEGER,
    "for_every_employee"  BOOLEAN NOT NULL DEFAULT false,
    "status"              TEXT   NOT NULL DEFAULT 'ACTIVE',
    "created_at"          TEXT,
    "created_by"          TEXT,
    CONSTRAINT "payroll_transaction_code_pkey" PRIMARY KEY ("id")
);
CREATE UNIQUE INDEX "payroll_transaction_code_code_key" ON "payroll_transaction_code"("code");
ALTER TABLE "payroll_transaction_code" ADD CONSTRAINT "ptc_gl_account_fkey" FOREIGN KEY ("gl_account_id") REFERENCES "gl_account"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE "payroll_transaction_code" ADD CONSTRAINT "ptc_employer_gl_account_fkey" FOREIGN KEY ("employer_gl_account_id") REFERENCES "gl_account"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

CREATE TABLE "payroll_period" (
    "id"              SERIAL NOT NULL,
    "period_name"     TEXT   NOT NULL,
    "start_date"      TEXT   NOT NULL,
    "end_date"        TEXT   NOT NULL,
    "status"          TEXT   NOT NULL DEFAULT 'OPEN',
    "decision_reason" TEXT,
    "closed_at"       TEXT,
    "closed_by"       TEXT,
    "created_at"      TEXT,
    "created_by"      TEXT,
    CONSTRAINT "payroll_period_pkey" PRIMARY KEY ("id")
);
CREATE UNIQUE INDEX "payroll_period_name_key" ON "payroll_period"("period_name");
-- "At most one Open/Pending-Approval period at a time" is enforced in lib/payroll.ts (a partial
-- unique index over a multi-value IN-list can't express that — it would only forbid two rows
-- sharing the exact same status, not one Open + one Pending Approval coexisting).

CREATE TABLE "employee_payroll_transaction" (
    "id"                    SERIAL NOT NULL,
    "employee_id"           INTEGER NOT NULL,
    "transaction_code_id"   INTEGER NOT NULL,
    "payroll_period_id"     INTEGER NOT NULL,
    "amount_cents"          BIGINT NOT NULL DEFAULT 0,
    "original_amount_cents" BIGINT,
    "balance_cents"         BIGINT,
    "no_of_periods"         INTEGER,
    "executed_periods"      INTEGER NOT NULL DEFAULT 0,
    "stopped"               BOOLEAN NOT NULL DEFAULT false,
    "temporary"             BOOLEAN NOT NULL DEFAULT false,
    "notes"                 TEXT,
    "created_at"            TEXT,
    "created_by"            TEXT,
    CONSTRAINT "employee_payroll_transaction_pkey" PRIMARY KEY ("id")
);
ALTER TABLE "employee_payroll_transaction" ADD CONSTRAINT "ept_employee_fkey" FOREIGN KEY ("employee_id") REFERENCES "employee"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE "employee_payroll_transaction" ADD CONSTRAINT "ept_transaction_code_fkey" FOREIGN KEY ("transaction_code_id") REFERENCES "payroll_transaction_code"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE "employee_payroll_transaction" ADD CONSTRAINT "ept_payroll_period_fkey" FOREIGN KEY ("payroll_period_id") REFERENCES "payroll_period"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;
CREATE INDEX "ix_ept_employee_period" ON "employee_payroll_transaction"("employee_id", "payroll_period_id");
CREATE INDEX "ix_ept_period" ON "employee_payroll_transaction"("payroll_period_id");

CREATE TABLE "payroll_period_line" (
    "id"                  SERIAL NOT NULL,
    "payroll_period_id"   INTEGER NOT NULL,
    "employee_id"         INTEGER NOT NULL,
    "transaction_code_id" INTEGER NOT NULL,
    "section"             TEXT   NOT NULL DEFAULT 'ALLOWANCE',
    "sort_order"          INTEGER NOT NULL DEFAULT 0,
    "amount_cents"        BIGINT NOT NULL DEFAULT 0,
    "gl_account_id"       INTEGER,
    "is_debit"            BOOLEAN NOT NULL DEFAULT true,
    CONSTRAINT "payroll_period_line_pkey" PRIMARY KEY ("id")
);
ALTER TABLE "payroll_period_line" ADD CONSTRAINT "ppl_payroll_period_fkey" FOREIGN KEY ("payroll_period_id") REFERENCES "payroll_period"("id") ON DELETE CASCADE ON UPDATE NO ACTION;
ALTER TABLE "payroll_period_line" ADD CONSTRAINT "ppl_employee_fkey" FOREIGN KEY ("employee_id") REFERENCES "employee"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE "payroll_period_line" ADD CONSTRAINT "ppl_transaction_code_fkey" FOREIGN KEY ("transaction_code_id") REFERENCES "payroll_transaction_code"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE "payroll_period_line" ADD CONSTRAINT "ppl_gl_account_fkey" FOREIGN KEY ("gl_account_id") REFERENCES "gl_account"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;
CREATE INDEX "ix_ppl_period_employee" ON "payroll_period_line"("payroll_period_id", "employee_id");

CREATE TABLE "payroll_p9_line" (
    "id"                    SERIAL NOT NULL,
    "employee_id"           INTEGER NOT NULL,
    "payroll_period_id"     INTEGER NOT NULL,
    "basic_pay_cents"       BIGINT NOT NULL DEFAULT 0,
    "gross_pay_cents"       BIGINT NOT NULL DEFAULT 0,
    "taxable_pay_cents"     BIGINT NOT NULL DEFAULT 0,
    "tax_charged_cents"     BIGINT NOT NULL DEFAULT 0,
    "insurance_relief_cents" BIGINT NOT NULL DEFAULT 0,
    "personal_relief_cents" BIGINT NOT NULL DEFAULT 0,
    "paye_cents"            BIGINT NOT NULL DEFAULT 0,
    "nssf_cents"            BIGINT NOT NULL DEFAULT 0,
    "shif_cents"            BIGINT NOT NULL DEFAULT 0,
    "housing_levy_cents"    BIGINT NOT NULL DEFAULT 0,
    "deductions_cents"      BIGINT NOT NULL DEFAULT 0,
    "net_pay_cents"         BIGINT NOT NULL DEFAULT 0,
    "created_at"            TEXT,
    CONSTRAINT "payroll_p9_line_pkey" PRIMARY KEY ("id")
);
ALTER TABLE "payroll_p9_line" ADD CONSTRAINT "p9_employee_fkey" FOREIGN KEY ("employee_id") REFERENCES "employee"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE "payroll_p9_line" ADD CONSTRAINT "p9_payroll_period_fkey" FOREIGN KEY ("payroll_period_id") REFERENCES "payroll_period"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;
CREATE UNIQUE INDEX "ux_p9_employee_period" ON "payroll_p9_line"("employee_id", "payroll_period_id");

-- ================================================================================ statutory seed

-- Kenyan PAYE bands (2024+ Finance Act): 24,000@10 / next 8,333@25 / next 467,667@30 /
-- next 300,000@32.5 / remainder@35. `upper_bound_cents` is each band's own width (cents), matching
-- the progressive-tax accumulation lib/payroll.ts implements; the last band's NULL means unbounded.
INSERT INTO "payroll_paye_band" ("sort_order", "upper_bound_cents", "rate_pct") VALUES
  (1, 2400000, 10),
  (2, 833300, 25),
  (3, 46766700, 30),
  (4, 30000000, 32.5),
  (5, NULL, 35);

-- NSSF Tier I (up to KES 8,000) and Tier II (8,000–72,000), both sides 6%.
INSERT INTO "payroll_nssf_tier" ("tier_no", "lower_limit_cents", "upper_limit_cents", "employee_rate_pct", "employer_rate_pct") VALUES
  (1, 0, 800000, 6, 6),
  (2, 800000, 7200000, 6, 6);
