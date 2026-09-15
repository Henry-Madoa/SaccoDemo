-- AL Tab52203619 "Payroll Period Transaction": everything the run computes for an employee in a
-- period — basic pay, the allowances, gross pay, the tax workings, statutories, deductions,
-- employer costs and net pay — one row per line, grouped and ordered as the payslip reads.
-- Basic pay and the statutories are NOT Earnings & Deductions codes: they are written here by
-- the run under fixed codes (BPAY, GPAY, NSSF, SHIF, AHL, PAYE, NPAY …) with no
-- payroll_transaction_code behind them. Only an employee's Earnings & Deductions lines carry a
-- transaction_code_id. Replaces payroll_period_line.
CREATE TABLE "payroll_period_transaction" (
    "id"                    SERIAL  NOT NULL,
    "payroll_period_id"     INTEGER NOT NULL,
    "employee_id"           INTEGER NOT NULL,
    "transaction_code"      TEXT    NOT NULL,
    "transaction_code_id"   INTEGER,
    "transaction_name"      TEXT    NOT NULL,
    "transaction_type"      TEXT    NOT NULL DEFAULT 'INCOME',
    "group_text"            TEXT    NOT NULL,
    "group_order"           INTEGER NOT NULL DEFAULT 0,
    "sub_group_order"       INTEGER NOT NULL DEFAULT 0,
    "payslip_order"         INTEGER NOT NULL DEFAULT 0,
    "amount_cents"          BIGINT  NOT NULL DEFAULT 0,
    "balance_cents"         BIGINT,
    "original_amount_cents" BIGINT,
    "no_of_units"           DOUBLE PRECISION,
    "gl_account_id"         INTEGER,
    "post_as"               TEXT,
    "post_to_journal"       BOOLEAN NOT NULL DEFAULT false,
    "journal_account_type"  TEXT    NOT NULL DEFAULT 'GL',
    "company_deduction"     BOOLEAN NOT NULL DEFAULT false,
    "member_id"             INTEGER,
    "loan_id"               INTEGER,
    "imprest_no"            TEXT,
    "posting_group_id"      INTEGER,
    "payment_mode"          TEXT,
    "salary_scale_id"       INTEGER,
    "global_dimension_1_id" INTEGER,
    "global_dimension_2_id" INTEGER,
    "staff_name"            TEXT,
    "bank_code"             TEXT,
    "bank_branch"           TEXT,
    "bank_account_no"       TEXT,
    "created_at"            TEXT,
    CONSTRAINT "payroll_period_transaction_pkey" PRIMARY KEY ("id")
);
ALTER TABLE "payroll_period_transaction" ADD CONSTRAINT "ppt_payroll_period_fkey" FOREIGN KEY ("payroll_period_id") REFERENCES "payroll_period"("id") ON DELETE CASCADE ON UPDATE NO ACTION;
ALTER TABLE "payroll_period_transaction" ADD CONSTRAINT "ppt_employee_fkey" FOREIGN KEY ("employee_id") REFERENCES "employee"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE "payroll_period_transaction" ADD CONSTRAINT "ppt_transaction_code_fkey" FOREIGN KEY ("transaction_code_id") REFERENCES "payroll_transaction_code"("id") ON DELETE SET NULL ON UPDATE NO ACTION;
ALTER TABLE "payroll_period_transaction" ADD CONSTRAINT "ppt_gl_account_fkey" FOREIGN KEY ("gl_account_id") REFERENCES "gl_account"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE "payroll_period_transaction" ADD CONSTRAINT "ppt_loan_fkey" FOREIGN KEY ("loan_id") REFERENCES "loan"("id") ON DELETE SET NULL ON UPDATE NO ACTION;
CREATE INDEX "ix_ppt_period_employee" ON "payroll_period_transaction"("payroll_period_id", "employee_id", "group_order", "sub_group_order", "payslip_order");
CREATE INDEX "ix_ppt_employee_code" ON "payroll_period_transaction"("employee_id", "transaction_code");
CREATE INDEX "ix_ppt_period_code" ON "payroll_period_transaction"("payroll_period_id", "transaction_code");

-- Carry the lines already run across, so history, payslips and reports keep reading.
INSERT INTO "payroll_period_transaction"
  ("payroll_period_id", "employee_id", "transaction_code", "transaction_code_id", "transaction_name", "transaction_type",
   "group_text", "group_order", "sub_group_order", "amount_cents", "gl_account_id", "post_as", "post_to_journal",
   "company_deduction", "loan_id", "member_id", "posting_group_id", "payment_mode", "salary_scale_id",
   "global_dimension_1_id", "global_dimension_2_id", "staff_name", "created_at")
SELECT l."payroll_period_id", l."employee_id",
       CASE c."code" WHEN 'BASIC' THEN 'BPAY' WHEN 'NSSF_EE' THEN 'NSSF' WHEN 'NSSF_ER' THEN 'NSSF-ER'
                     WHEN 'HLEVY_EE' THEN 'AHL' WHEN 'HLEVY_ER' THEN 'AHL-ER' WHEN 'NETPAY' THEN 'NPAY' ELSE c."code" END,
       CASE WHEN c."code" IN ('BASIC','NSSF_EE','NSSF_ER','SHIF','HLEVY_EE','HLEVY_ER','PAYE','NETPAY') THEN NULL ELSE c."id" END,
       c."name",
       CASE l."section" WHEN 'BASIC' THEN 'INCOME' WHEN 'ALLOWANCE' THEN 'INCOME' WHEN 'EMPLOYER' THEN 'COMPANY_DEDUCTION' WHEN 'NET' THEN 'NET' ELSE 'DEDUCTION' END,
       CASE l."section" WHEN 'BASIC' THEN 'BASIC SALARY' WHEN 'ALLOWANCE' THEN 'ALLOWANCE' WHEN 'STATUTORY' THEN 'STATUTORIES'
                        WHEN 'DEDUCTION' THEN 'DEDUCTIONS' WHEN 'EMPLOYER' THEN 'EMPLOYER' WHEN 'NET' THEN 'NET PAY' ELSE l."section" END,
       CASE l."section" WHEN 'BASIC' THEN 1 WHEN 'ALLOWANCE' THEN 3 WHEN 'STATUTORY' THEN 7 WHEN 'DEDUCTION' THEN 8 WHEN 'EMPLOYER' THEN 10 WHEN 'NET' THEN 9 ELSE l."sort_order" END,
       l."sort_order", l."amount_cents", l."gl_account_id",
       CASE WHEN l."is_debit" THEN 'DEBIT' ELSE 'CREDIT' END, true,
       (l."section" = 'EMPLOYER'), l."loan_id", e."member_id", e."posting_group_id", e."payment_mode", e."salary_scale_id",
       e."global_dimension_1_id", e."global_dimension_2_id", (e."first_name" || ' ' || e."last_name"), NULL
FROM "payroll_period_line" l
JOIN "payroll_transaction_code" c ON c."id" = l."transaction_code_id"
JOIN "employee" e ON e."id" = l."employee_id";

DROP TABLE "payroll_period_line";

-- The run's own codes leave the Earnings & Deductions catalogue: delete where nothing refers to
-- them, otherwise retire them so they can no longer be picked.
DELETE FROM "payroll_transaction_code" c
 WHERE c."code" IN ('BASIC','NSSF_EE','NSSF_ER','SHIF','HLEVY_EE','HLEVY_ER','PAYE','NETPAY')
   AND NOT EXISTS (SELECT 1 FROM "employee_payroll_transaction" t WHERE t."transaction_code_id" = c."id")
   AND NOT EXISTS (SELECT 1 FROM "hr_salary_scale_benefit" b WHERE b."transaction_code_id" = c."id");
UPDATE "payroll_transaction_code" SET "status" = 'INACTIVE'
 WHERE "code" IN ('BASIC','NSSF_EE','NSSF_ER','SHIF','HLEVY_EE','HLEVY_ER','PAYE','NETPAY');

-- Formula codes (AL "Is Formula" / Formula / "Amount Preference"): the amount is computed from
-- the employee's period transactions written before it — [BPAY]*0.15, ([BPAY]+[HALLOW])*0.05 …
ALTER TABLE "payroll_transaction_code" ADD COLUMN "amount_preference" TEXT NOT NULL DEFAULT 'FORMULA';
