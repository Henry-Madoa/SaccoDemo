-- Leave Management — the second of three HR & Payroll modules ported from "Sacco ERP" AL. Leave
-- balance is always SUM(hr_leave_ledger_entry.quantity), an append-only signed ledger — never a
-- stored mutable column — matching both the AL design and this app's own ledger conventions.
-- Day-count exclusion (weekends/holidays) is computed by a pure function in lib/leaveManagement.ts
-- against hr_holiday + the leave type's inclusive-flags, not a per-day materialized calendar.

CREATE TABLE "hr_leave_type" (
    "id"                                 SERIAL NOT NULL,
    "code"                               TEXT   NOT NULL,
    "name"                               TEXT   NOT NULL,
    "standard_days"                      DOUBLE PRECISION NOT NULL DEFAULT 0,
    "accrues"                            BOOLEAN NOT NULL DEFAULT false,
    "days_to_accrue"                     DOUBLE PRECISION NOT NULL DEFAULT 0,
    "unlimited_days"                     BOOLEAN NOT NULL DEFAULT false,
    "gender"                             TEXT   NOT NULL DEFAULT 'ANY',
    "balance_treatment"                  TEXT   NOT NULL DEFAULT 'IGNORE',
    "max_carry_forward_days"             DOUBLE PRECISION NOT NULL DEFAULT 0,
    "inclusive_of_saturday"              BOOLEAN NOT NULL DEFAULT false,
    "inclusive_of_sunday"                BOOLEAN NOT NULL DEFAULT false,
    "inclusive_of_holidays"              BOOLEAN NOT NULL DEFAULT false,
    "fixed_days"                         BOOLEAN NOT NULL DEFAULT false,
    "is_annual"                          BOOLEAN NOT NULL DEFAULT false,
    "max_applicable_days"                DOUBLE PRECISION,
    "check_balance"                      BOOLEAN NOT NULL DEFAULT true,
    "is_sick_leave"                      BOOLEAN NOT NULL DEFAULT false,
    "requires_admin_approval"            BOOLEAN NOT NULL DEFAULT false,
    "leave_balance_notification_threshold" DOUBLE PRECISION,
    "disabled"                           BOOLEAN NOT NULL DEFAULT false,
    "status"                             TEXT   NOT NULL DEFAULT 'ACTIVE',
    "created_at"                         TEXT,
    "created_by"                         TEXT,
    CONSTRAINT "hr_leave_type_pkey" PRIMARY KEY ("id")
);
CREATE UNIQUE INDEX "hr_leave_type_code_key" ON "hr_leave_type"("code");
CREATE UNIQUE INDEX "ux_hr_leave_type_single_annual" ON "hr_leave_type" ((is_annual)) WHERE "is_annual" = true;

CREATE TABLE "hr_leave_calendar" (
    "id"          SERIAL NOT NULL,
    "code"        TEXT   NOT NULL,
    "start_date"  TEXT   NOT NULL,
    "end_date"    TEXT   NOT NULL,
    "is_current"  BOOLEAN NOT NULL DEFAULT false,
    "closed"      BOOLEAN NOT NULL DEFAULT false,
    "closed_at"   TEXT,
    "closed_by"   TEXT,
    "created_at"  TEXT,
    "created_by"  TEXT,
    CONSTRAINT "hr_leave_calendar_pkey" PRIMARY KEY ("id")
);
CREATE UNIQUE INDEX "hr_leave_calendar_code_key" ON "hr_leave_calendar"("code");
CREATE UNIQUE INDEX "ux_hr_leave_calendar_single_current" ON "hr_leave_calendar" ((is_current)) WHERE "is_current" = true;

CREATE TABLE "hr_holiday" (
    "id"         SERIAL NOT NULL,
    "date"       TEXT   NOT NULL,
    "reason"     TEXT   NOT NULL,
    "recurring"  BOOLEAN NOT NULL DEFAULT false,
    CONSTRAINT "hr_holiday_pkey" PRIMARY KEY ("id")
);
CREATE UNIQUE INDEX "hr_holiday_date_key" ON "hr_holiday"("date");

CREATE TABLE "hr_leave_days_to_accrue" (
    "id"                     SERIAL NOT NULL,
    "leave_type_id"          INTEGER NOT NULL,
    "job_grade_id"           INTEGER NOT NULL,
    "days_to_accrue"         DOUBLE PRECISION NOT NULL DEFAULT 0,
    "leave_day_worth_cents"  BIGINT NOT NULL DEFAULT 0,
    CONSTRAINT "hr_leave_days_to_accrue_pkey" PRIMARY KEY ("id")
);
CREATE UNIQUE INDEX "ux_hldta_type_grade" ON "hr_leave_days_to_accrue"("leave_type_id", "job_grade_id");
ALTER TABLE "hr_leave_days_to_accrue" ADD CONSTRAINT "hldta_leave_type_fkey" FOREIGN KEY ("leave_type_id") REFERENCES "hr_leave_type"("id") ON DELETE CASCADE ON UPDATE NO ACTION;
ALTER TABLE "hr_leave_days_to_accrue" ADD CONSTRAINT "hldta_job_grade_fkey" FOREIGN KEY ("job_grade_id") REFERENCES "hr_job_grade"("id") ON DELETE CASCADE ON UPDATE NO ACTION;

-- ===================================================================================== ledger

CREATE TABLE "hr_leave_ledger_entry" (
    "id"                SERIAL NOT NULL,
    "employee_id"       INTEGER NOT NULL,
    "leave_type_id"     INTEGER NOT NULL,
    "leave_calendar_id" INTEGER NOT NULL,
    "quantity"          DOUBLE PRECISION NOT NULL,
    "entry_type"        TEXT   NOT NULL,
    "posting_date"      TEXT   NOT NULL,
    "document_no"       TEXT,
    "source_type"       TEXT,
    "source_id"         TEXT,
    "closed"            BOOLEAN NOT NULL DEFAULT false,
    "description"       TEXT,
    "created_at"        TEXT,
    "created_by"        TEXT,
    CONSTRAINT "hr_leave_ledger_entry_pkey" PRIMARY KEY ("id")
);
ALTER TABLE "hr_leave_ledger_entry" ADD CONSTRAINT "hlle_employee_fkey" FOREIGN KEY ("employee_id") REFERENCES "employee"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE "hr_leave_ledger_entry" ADD CONSTRAINT "hlle_leave_type_fkey" FOREIGN KEY ("leave_type_id") REFERENCES "hr_leave_type"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE "hr_leave_ledger_entry" ADD CONSTRAINT "hlle_leave_calendar_fkey" FOREIGN KEY ("leave_calendar_id") REFERENCES "hr_leave_calendar"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;
CREATE INDEX "ix_hlle_employee_type" ON "hr_leave_ledger_entry"("employee_id", "leave_type_id");
CREATE INDEX "ix_hlle_calendar" ON "hr_leave_ledger_entry"("leave_calendar_id");

-- ================================================================================= applications

CREATE TABLE "hr_leave_application" (
    "no"                     TEXT   NOT NULL,
    "employee_id"            INTEGER NOT NULL,
    "leave_type_id"          INTEGER NOT NULL,
    "nature"                 TEXT   NOT NULL DEFAULT 'APPLICATION',
    "leave_calendar_id"      INTEGER NOT NULL,
    "start_date"             TEXT   NOT NULL,
    "end_date"               TEXT   NOT NULL,
    "days_applied"           DOUBLE PRECISION NOT NULL DEFAULT 0,
    "weekend_days"           DOUBLE PRECISION NOT NULL DEFAULT 0,
    "holiday_days"           DOUBLE PRECISION NOT NULL DEFAULT 0,
    "total_days"             DOUBLE PRECISION NOT NULL DEFAULT 0,
    "reliever_id"            INTEGER,
    "status"                 TEXT   NOT NULL DEFAULT 'Open',
    "decision_reason"        TEXT,
    "leave_allowance_payable" BOOLEAN NOT NULL DEFAULT false,
    "posted"                 BOOLEAN NOT NULL DEFAULT false,
    "posting_date"           TEXT,
    "days_dropped"           DOUBLE PRECISION,
    "days_to_reimburse"      DOUBLE PRECISION,
    "justification"          TEXT,
    "created_at"             TEXT,
    "created_by"             TEXT,
    CONSTRAINT "hr_leave_application_pkey" PRIMARY KEY ("no")
);
ALTER TABLE "hr_leave_application" ADD CONSTRAINT "hla_employee_fkey" FOREIGN KEY ("employee_id") REFERENCES "employee"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE "hr_leave_application" ADD CONSTRAINT "hla_leave_type_fkey" FOREIGN KEY ("leave_type_id") REFERENCES "hr_leave_type"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE "hr_leave_application" ADD CONSTRAINT "hla_leave_calendar_fkey" FOREIGN KEY ("leave_calendar_id") REFERENCES "hr_leave_calendar"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE "hr_leave_application" ADD CONSTRAINT "hla_reliever_fkey" FOREIGN KEY ("reliever_id") REFERENCES "employee"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;
CREATE INDEX "ix_hla_employee" ON "hr_leave_application"("employee_id");
CREATE INDEX "ix_hla_status" ON "hr_leave_application"("status");

CREATE TABLE "hr_leave_adjustment" (
    "no"              TEXT   NOT NULL,
    "leave_type_id"   INTEGER NOT NULL,
    "type"            TEXT   NOT NULL DEFAULT 'POSITIVE',
    "description"     TEXT,
    "days"            DOUBLE PRECISION NOT NULL DEFAULT 0,
    "status"          TEXT   NOT NULL DEFAULT 'Open',
    "decision_reason" TEXT,
    "created_at"      TEXT,
    "created_by"      TEXT,
    CONSTRAINT "hr_leave_adjustment_pkey" PRIMARY KEY ("no")
);
ALTER TABLE "hr_leave_adjustment" ADD CONSTRAINT "hladj_leave_type_fkey" FOREIGN KEY ("leave_type_id") REFERENCES "hr_leave_type"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;
CREATE INDEX "ix_hladj_status" ON "hr_leave_adjustment"("status");

CREATE TABLE "hr_leave_adjustment_line" (
    "id"             SERIAL NOT NULL,
    "adjustment_no"  TEXT   NOT NULL,
    "employee_id"    INTEGER NOT NULL,
    "days"           DOUBLE PRECISION NOT NULL DEFAULT 0,
    CONSTRAINT "hr_leave_adjustment_line_pkey" PRIMARY KEY ("id")
);
ALTER TABLE "hr_leave_adjustment_line" ADD CONSTRAINT "hladjl_adjustment_fkey" FOREIGN KEY ("adjustment_no") REFERENCES "hr_leave_adjustment"("no") ON DELETE CASCADE ON UPDATE NO ACTION;
ALTER TABLE "hr_leave_adjustment_line" ADD CONSTRAINT "hladjl_employee_fkey" FOREIGN KEY ("employee_id") REFERENCES "employee"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;
CREATE INDEX "ix_hladjl_adjustment" ON "hr_leave_adjustment_line"("adjustment_no");

CREATE TABLE "hr_leave_recall" (
    "no"              TEXT   NOT NULL,
    "employee_id"     INTEGER NOT NULL,
    "application_no"  TEXT   NOT NULL,
    "days_to_recall"  DOUBLE PRECISION NOT NULL DEFAULT 0,
    "status"          TEXT   NOT NULL DEFAULT 'Open',
    "decision_reason" TEXT,
    "created_at"      TEXT,
    "created_by"      TEXT,
    CONSTRAINT "hr_leave_recall_pkey" PRIMARY KEY ("no")
);
ALTER TABLE "hr_leave_recall" ADD CONSTRAINT "hlr_employee_fkey" FOREIGN KEY ("employee_id") REFERENCES "employee"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE "hr_leave_recall" ADD CONSTRAINT "hlr_application_fkey" FOREIGN KEY ("application_no") REFERENCES "hr_leave_application"("no") ON DELETE NO ACTION ON UPDATE NO ACTION;
CREATE INDEX "ix_hlr_employee" ON "hr_leave_recall"("employee_id");
CREATE INDEX "ix_hlr_status" ON "hr_leave_recall"("status");

CREATE TABLE "hr_leave_plan" (
    "no"                TEXT   NOT NULL,
    "employee_id"       INTEGER NOT NULL,
    "leave_calendar_id" INTEGER NOT NULL,
    "status"            TEXT   NOT NULL DEFAULT 'Open',
    "decision_reason"   TEXT,
    "created_at"        TEXT,
    "created_by"        TEXT,
    CONSTRAINT "hr_leave_plan_pkey" PRIMARY KEY ("no")
);
ALTER TABLE "hr_leave_plan" ADD CONSTRAINT "hlp_employee_fkey" FOREIGN KEY ("employee_id") REFERENCES "employee"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE "hr_leave_plan" ADD CONSTRAINT "hlp_leave_calendar_fkey" FOREIGN KEY ("leave_calendar_id") REFERENCES "hr_leave_calendar"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;
CREATE INDEX "ix_hlp_employee" ON "hr_leave_plan"("employee_id");
CREATE INDEX "ix_hlp_status" ON "hr_leave_plan"("status");

CREATE TABLE "hr_leave_plan_line" (
    "id"          SERIAL NOT NULL,
    "plan_no"     TEXT   NOT NULL,
    "start_date"  TEXT   NOT NULL,
    "end_date"    TEXT   NOT NULL,
    "days"        DOUBLE PRECISION NOT NULL DEFAULT 0,
    CONSTRAINT "hr_leave_plan_line_pkey" PRIMARY KEY ("id")
);
ALTER TABLE "hr_leave_plan_line" ADD CONSTRAINT "hlpl_plan_fkey" FOREIGN KEY ("plan_no") REFERENCES "hr_leave_plan"("no") ON DELETE CASCADE ON UPDATE NO ACTION;
CREATE INDEX "ix_hlpl_plan" ON "hr_leave_plan_line"("plan_no");

-- ==================================================================================== numbering

INSERT INTO "sequence" ("name", "prefix", "next_no", "width") VALUES
  ('LEAVE_APPLICATION', 'LVA', 1, 6),
  ('LEAVE_ADJUSTMENT', 'LVJ', 1, 6),
  ('LEAVE_RECALL', 'LVR', 1, 6),
  ('LEAVE_PLAN', 'LVP', 1, 6);
