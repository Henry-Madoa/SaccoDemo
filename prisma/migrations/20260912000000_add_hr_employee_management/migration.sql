-- Employee Management — the first of three HR & Payroll modules ported from the "Sacco ERP" AL
-- reference (object range 52203xxx), scoped "core-detailed": the employee master + the
-- sub-entities that matter for a SACCO's own staff (next of kin, beneficiaries, dependants,
-- emergency contacts, professional bodies, work history, bank accounts, contract history), the
-- maker-checker Employee Editing flow (mirrors member_edit_request's replace-all-shadow-table
-- pattern — see lib/memberEdits.ts), Contract/Salary change requests, and the Employee Exit +
-- clearance workflow. Leave Management and Payroll follow in their own migrations; `employee`
-- carries a nullable `posting_group_id` here with its FK added once payroll_posting_group exists.
--
-- Lifecycle status is a single unified enum (collapsing AL's two overlapping status fields):
-- New -> Pending Approval -> Active -> {On Leave, Pending Final Payment, Inactive, Terminated}.

-- ==================================================================================== masters

CREATE TABLE "hr_department" (
    "id"          SERIAL NOT NULL,
    "code"        TEXT   NOT NULL,
    "name"        TEXT   NOT NULL,
    "parent_id"   INTEGER,
    "status"      TEXT   NOT NULL DEFAULT 'ACTIVE',
    "created_at"  TEXT,
    "created_by"  TEXT,
    CONSTRAINT "hr_department_pkey" PRIMARY KEY ("id")
);
CREATE UNIQUE INDEX "hr_department_code_key" ON "hr_department"("code");
ALTER TABLE "hr_department" ADD CONSTRAINT "hr_department_parent_fkey" FOREIGN KEY ("parent_id") REFERENCES "hr_department"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

CREATE TABLE "hr_job_grade" (
    "id"                          SERIAL NOT NULL,
    "code"                        TEXT   NOT NULL,
    "name"                        TEXT   NOT NULL,
    "notice_period_days"          INTEGER NOT NULL DEFAULT 30,
    "probation_notice_period_days" INTEGER NOT NULL DEFAULT 7,
    "leave_allowance_amount"      BIGINT NOT NULL DEFAULT 0,
    "training_allowance_amount"   BIGINT NOT NULL DEFAULT 0,
    "overtime_allowance_amount"   BIGINT NOT NULL DEFAULT 0,
    "status"                      TEXT   NOT NULL DEFAULT 'ACTIVE',
    "created_at"                  TEXT,
    "created_by"                  TEXT,
    CONSTRAINT "hr_job_grade_pkey" PRIMARY KEY ("id")
);
CREATE UNIQUE INDEX "hr_job_grade_code_key" ON "hr_job_grade"("code");

CREATE TABLE "hr_employment_contract_type" (
    "id"                        SERIAL NOT NULL,
    "code"                      TEXT   NOT NULL,
    "name"                      TEXT   NOT NULL,
    "default_notice_period_days" INTEGER NOT NULL DEFAULT 30,
    "status"                    TEXT   NOT NULL DEFAULT 'ACTIVE',
    "created_at"                TEXT,
    "created_by"                TEXT,
    CONSTRAINT "hr_employment_contract_type_pkey" PRIMARY KEY ("id")
);
CREATE UNIQUE INDEX "hr_employment_contract_type_code_key" ON "hr_employment_contract_type"("code");

CREATE TABLE "hr_termination_reason" (
    "id"           SERIAL NOT NULL,
    "code"         TEXT   NOT NULL,
    "description"  TEXT   NOT NULL,
    "pay_gratuity" BOOLEAN NOT NULL DEFAULT false,
    "status"       TEXT   NOT NULL DEFAULT 'ACTIVE',
    "created_at"   TEXT,
    "created_by"   TEXT,
    CONSTRAINT "hr_termination_reason_pkey" PRIMARY KEY ("id")
);
CREATE UNIQUE INDEX "hr_termination_reason_code_key" ON "hr_termination_reason"("code");

CREATE TABLE "hr_clearance_section" (
    "id"          SERIAL NOT NULL,
    "code"        TEXT   NOT NULL,
    "name"        TEXT   NOT NULL,
    "owner_email" TEXT,
    "sort_order"  INTEGER NOT NULL DEFAULT 0,
    "status"      TEXT   NOT NULL DEFAULT 'ACTIVE',
    "created_at"  TEXT,
    "created_by"  TEXT,
    CONSTRAINT "hr_clearance_section_pkey" PRIMARY KEY ("id")
);
CREATE UNIQUE INDEX "hr_clearance_section_code_key" ON "hr_clearance_section"("code");

-- ==================================================================================== employee

CREATE TABLE "employee" (
    "id"                    SERIAL NOT NULL,
    "employee_no"           TEXT   NOT NULL,
    "first_name"            TEXT   NOT NULL,
    "middle_name"           TEXT,
    "last_name"             TEXT   NOT NULL,
    "gender"                TEXT,
    "date_of_birth"         TEXT,
    "national_id"           TEXT,
    "kra_pin"               TEXT,
    "nssf_no"               TEXT,
    "shif_no"               TEXT,
    "marital_status"        TEXT,
    "phone"                 TEXT,
    "alt_phone"             TEXT,
    "email"                 TEXT,
    "physical_address"      TEXT,
    "county_id"             INTEGER,
    "sub_county_id"         INTEGER,
    "department_id"         INTEGER,
    "job_title"             TEXT,
    "job_grade_id"          INTEGER,
    "contract_type_id"      INTEGER,
    "nature_of_employment"  TEXT   NOT NULL DEFAULT 'PERMANENT',
    "employee_type"         TEXT   NOT NULL DEFAULT 'STAFF',
    "employment_date"       TEXT   NOT NULL,
    "probation_period_months" INTEGER NOT NULL DEFAULT 3,
    "probation_end_date"    TEXT,
    "probation_status"      TEXT   NOT NULL DEFAULT 'ON_PROBATION',
    "confirmed_date"        TEXT,
    "manager_id"            INTEGER,
    "overview_manager_id"   INTEGER,
    "bank_code"             TEXT,
    "bank_branch"           TEXT,
    "bank_account_no"       TEXT,
    "posting_group_id"      INTEGER,
    "global_dimension_1_id" INTEGER,
    "global_dimension_2_id" INTEGER,
    "member_id"             INTEGER,
    "photo_url"             TEXT,
    "disabled"              BOOLEAN NOT NULL DEFAULT false,
    "disability_notes"      TEXT,
    "status"                TEXT   NOT NULL DEFAULT 'NEW',
    "termination_reason_id" INTEGER,
    "termination_date"      TEXT,
    "notes"                 TEXT,
    "created_at"            TEXT,
    "created_by"            TEXT,
    CONSTRAINT "employee_pkey" PRIMARY KEY ("id")
);
CREATE UNIQUE INDEX "employee_employee_no_key" ON "employee"("employee_no");
CREATE UNIQUE INDEX "ux_employee_national_id" ON "employee"("national_id") WHERE "national_id" IS NOT NULL AND "national_id" <> '';
CREATE UNIQUE INDEX "ux_employee_kra_pin" ON "employee"("kra_pin") WHERE "kra_pin" IS NOT NULL AND "kra_pin" <> '';
CREATE UNIQUE INDEX "ux_employee_nssf_no" ON "employee"("nssf_no") WHERE "nssf_no" IS NOT NULL AND "nssf_no" <> '';
CREATE UNIQUE INDEX "ux_employee_shif_no" ON "employee"("shif_no") WHERE "shif_no" IS NOT NULL AND "shif_no" <> '';

ALTER TABLE "employee" ADD CONSTRAINT "employee_county_fkey" FOREIGN KEY ("county_id") REFERENCES "county"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE "employee" ADD CONSTRAINT "employee_sub_county_fkey" FOREIGN KEY ("sub_county_id") REFERENCES "sub_county"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE "employee" ADD CONSTRAINT "employee_department_fkey" FOREIGN KEY ("department_id") REFERENCES "hr_department"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE "employee" ADD CONSTRAINT "employee_job_grade_fkey" FOREIGN KEY ("job_grade_id") REFERENCES "hr_job_grade"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE "employee" ADD CONSTRAINT "employee_contract_type_fkey" FOREIGN KEY ("contract_type_id") REFERENCES "hr_employment_contract_type"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE "employee" ADD CONSTRAINT "employee_manager_fkey" FOREIGN KEY ("manager_id") REFERENCES "employee"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE "employee" ADD CONSTRAINT "employee_overview_manager_fkey" FOREIGN KEY ("overview_manager_id") REFERENCES "employee"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE "employee" ADD CONSTRAINT "employee_global_dimension_1_fkey" FOREIGN KEY ("global_dimension_1_id") REFERENCES "global_dimension_1_value"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE "employee" ADD CONSTRAINT "employee_global_dimension_2_fkey" FOREIGN KEY ("global_dimension_2_id") REFERENCES "global_dimension_2_value"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE "employee" ADD CONSTRAINT "employee_member_fkey" FOREIGN KEY ("member_id") REFERENCES "member"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE "employee" ADD CONSTRAINT "employee_termination_reason_fkey" FOREIGN KEY ("termination_reason_id") REFERENCES "hr_termination_reason"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

CREATE INDEX "ix_employee_department" ON "employee"("department_id");
CREATE INDEX "ix_employee_status" ON "employee"("status");
CREATE INDEX "ix_employee_manager" ON "employee"("manager_id");

-- ============================================================================ employee sub-entities

CREATE TABLE "employee_next_of_kin" (
    "id"           SERIAL NOT NULL,
    "employee_id"  INTEGER NOT NULL,
    "full_name"    TEXT   NOT NULL,
    "relationship" TEXT,
    "id_no"        TEXT,
    "phone"        TEXT,
    "email"        TEXT,
    CONSTRAINT "employee_next_of_kin_pkey" PRIMARY KEY ("id")
);
ALTER TABLE "employee_next_of_kin" ADD CONSTRAINT "employee_next_of_kin_employee_fkey" FOREIGN KEY ("employee_id") REFERENCES "employee"("id") ON DELETE CASCADE ON UPDATE NO ACTION;
CREATE INDEX "ix_enok_employee" ON "employee_next_of_kin"("employee_id");

CREATE TABLE "employee_beneficiary" (
    "id"            SERIAL NOT NULL,
    "employee_id"   INTEGER NOT NULL,
    "full_name"     TEXT   NOT NULL,
    "id_no"         TEXT,
    "date_of_birth" TEXT,
    "relationship"  TEXT,
    "gender"        TEXT,
    "phone"         TEXT,
    "email"         TEXT,
    "percentage"    DOUBLE PRECISION NOT NULL DEFAULT 0,
    "is_minor"      BOOLEAN NOT NULL DEFAULT false,
    CONSTRAINT "employee_beneficiary_pkey" PRIMARY KEY ("id")
);
ALTER TABLE "employee_beneficiary" ADD CONSTRAINT "employee_beneficiary_employee_fkey" FOREIGN KEY ("employee_id") REFERENCES "employee"("id") ON DELETE CASCADE ON UPDATE NO ACTION;
CREATE INDEX "ix_ebnf_employee" ON "employee_beneficiary"("employee_id");

CREATE TABLE "employee_dependant" (
    "id"                    SERIAL NOT NULL,
    "employee_id"           INTEGER NOT NULL,
    "full_name"             TEXT   NOT NULL,
    "id_or_birth_cert_no"   TEXT,
    "date_of_birth"         TEXT,
    "relationship"          TEXT,
    "gender"                TEXT,
    "is_student"            BOOLEAN NOT NULL DEFAULT false,
    "status"                TEXT   NOT NULL DEFAULT 'ACTIVE',
    CONSTRAINT "employee_dependant_pkey" PRIMARY KEY ("id")
);
ALTER TABLE "employee_dependant" ADD CONSTRAINT "employee_dependant_employee_fkey" FOREIGN KEY ("employee_id") REFERENCES "employee"("id") ON DELETE CASCADE ON UPDATE NO ACTION;
CREATE INDEX "ix_edep_employee" ON "employee_dependant"("employee_id");

CREATE TABLE "employee_emergency_contact" (
    "id"           SERIAL NOT NULL,
    "employee_id"  INTEGER NOT NULL,
    "full_name"    TEXT   NOT NULL,
    "relationship" TEXT,
    "phone"        TEXT,
    "alt_phone"    TEXT,
    "email"        TEXT,
    CONSTRAINT "employee_emergency_contact_pkey" PRIMARY KEY ("id")
);
ALTER TABLE "employee_emergency_contact" ADD CONSTRAINT "employee_emergency_contact_employee_fkey" FOREIGN KEY ("employee_id") REFERENCES "employee"("id") ON DELETE CASCADE ON UPDATE NO ACTION;
CREATE INDEX "ix_eec_employee" ON "employee_emergency_contact"("employee_id");

CREATE TABLE "employee_professional_body" (
    "id"            SERIAL NOT NULL,
    "employee_id"   INTEGER NOT NULL,
    "body_name"     TEXT   NOT NULL,
    "membership_no" TEXT,
    "from_date"     TEXT,
    "to_date"       TEXT,
    CONSTRAINT "employee_professional_body_pkey" PRIMARY KEY ("id")
);
ALTER TABLE "employee_professional_body" ADD CONSTRAINT "employee_professional_body_employee_fkey" FOREIGN KEY ("employee_id") REFERENCES "employee"("id") ON DELETE CASCADE ON UPDATE NO ACTION;
CREATE INDEX "ix_epb_employee" ON "employee_professional_body"("employee_id");

CREATE TABLE "employee_work_history" (
    "id"                 SERIAL NOT NULL,
    "employee_id"        INTEGER NOT NULL,
    "institution"        TEXT   NOT NULL,
    "position_held"      TEXT,
    "from_date"          TEXT,
    "to_date"            TEXT,
    "reason_for_leaving" TEXT,
    CONSTRAINT "employee_work_history_pkey" PRIMARY KEY ("id")
);
ALTER TABLE "employee_work_history" ADD CONSTRAINT "employee_work_history_employee_fkey" FOREIGN KEY ("employee_id") REFERENCES "employee"("id") ON DELETE CASCADE ON UPDATE NO ACTION;
CREATE INDEX "ix_ewh_employee" ON "employee_work_history"("employee_id");

CREATE TABLE "employee_bank_account" (
    "id"          SERIAL NOT NULL,
    "employee_id" INTEGER NOT NULL,
    "bank_code"   TEXT,
    "branch"      TEXT,
    "account_no"  TEXT   NOT NULL,
    "percentage"  DOUBLE PRECISION NOT NULL DEFAULT 100,
    CONSTRAINT "employee_bank_account_pkey" PRIMARY KEY ("id")
);
ALTER TABLE "employee_bank_account" ADD CONSTRAINT "employee_bank_account_employee_fkey" FOREIGN KEY ("employee_id") REFERENCES "employee"("id") ON DELETE CASCADE ON UPDATE NO ACTION;
CREATE INDEX "ix_eba_employee" ON "employee_bank_account"("employee_id");

CREATE TABLE "employee_contract" (
    "id"                 SERIAL NOT NULL,
    "employee_id"        INTEGER NOT NULL,
    "contract_type_id"   INTEGER,
    "start_date"         TEXT   NOT NULL,
    "end_date"           TEXT,
    "job_title"          TEXT,
    "grade_id"           INTEGER,
    "salary_cents"       BIGINT NOT NULL DEFAULT 0,
    "notice_period_days" INTEGER,
    "is_current"         BOOLEAN NOT NULL DEFAULT true,
    "status"             TEXT   NOT NULL DEFAULT 'ACTIVE',
    "created_at"         TEXT,
    "created_by"         TEXT,
    CONSTRAINT "employee_contract_pkey" PRIMARY KEY ("id")
);
ALTER TABLE "employee_contract" ADD CONSTRAINT "employee_contract_employee_fkey" FOREIGN KEY ("employee_id") REFERENCES "employee"("id") ON DELETE CASCADE ON UPDATE NO ACTION;
ALTER TABLE "employee_contract" ADD CONSTRAINT "employee_contract_type_fkey" FOREIGN KEY ("contract_type_id") REFERENCES "hr_employment_contract_type"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE "employee_contract" ADD CONSTRAINT "employee_contract_grade_fkey" FOREIGN KEY ("grade_id") REFERENCES "hr_job_grade"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;
CREATE INDEX "ix_econ_employee" ON "employee_contract"("employee_id");

-- ======================================================================== employee editing (maker-checker)

-- Mirrors member_edit_request: one edit request per employee carrying the proposed bio-data
-- field values, plus a replace-all shadow table per sub-entity list (applied via replaceX() calls
-- on approval — see lib/employeeEdits.ts).
CREATE TABLE "employee_edit_request" (
    "no"                    TEXT   NOT NULL,
    "employee_id"           INTEGER NOT NULL,
    "first_name"            TEXT,
    "middle_name"           TEXT,
    "last_name"             TEXT,
    "gender"                TEXT,
    "date_of_birth"         TEXT,
    "national_id"           TEXT,
    "kra_pin"               TEXT,
    "nssf_no"               TEXT,
    "shif_no"               TEXT,
    "marital_status"        TEXT,
    "phone"                 TEXT,
    "alt_phone"             TEXT,
    "email"                 TEXT,
    "physical_address"      TEXT,
    "county_id"             INTEGER,
    "sub_county_id"         INTEGER,
    "department_id"         INTEGER,
    "job_title"             TEXT,
    "job_grade_id"          INTEGER,
    "bank_code"             TEXT,
    "bank_branch"           TEXT,
    "bank_account_no"       TEXT,
    "global_dimension_1_id" INTEGER,
    "global_dimension_2_id" INTEGER,
    "status"                TEXT   NOT NULL DEFAULT 'Open',
    "decision_reason"       TEXT,
    "created_at"            TEXT,
    "created_by"            TEXT,
    CONSTRAINT "employee_edit_request_pkey" PRIMARY KEY ("no")
);
ALTER TABLE "employee_edit_request" ADD CONSTRAINT "employee_edit_request_employee_fkey" FOREIGN KEY ("employee_id") REFERENCES "employee"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;
CREATE INDEX "ix_eer_employee" ON "employee_edit_request"("employee_id");
CREATE INDEX "ix_eer_status" ON "employee_edit_request"("status");

CREATE TABLE "employee_edit_next_of_kin" (
    "id"           SERIAL NOT NULL,
    "edit_no"      TEXT   NOT NULL,
    "full_name"    TEXT   NOT NULL,
    "relationship" TEXT,
    "id_no"        TEXT,
    "phone"        TEXT,
    "email"        TEXT,
    CONSTRAINT "employee_edit_next_of_kin_pkey" PRIMARY KEY ("id")
);
ALTER TABLE "employee_edit_next_of_kin" ADD CONSTRAINT "employee_edit_next_of_kin_edit_fkey" FOREIGN KEY ("edit_no") REFERENCES "employee_edit_request"("no") ON DELETE CASCADE ON UPDATE NO ACTION;
CREATE INDEX "ix_eenok_edit" ON "employee_edit_next_of_kin"("edit_no");

CREATE TABLE "employee_edit_beneficiary" (
    "id"            SERIAL NOT NULL,
    "edit_no"       TEXT   NOT NULL,
    "full_name"     TEXT   NOT NULL,
    "id_no"         TEXT,
    "date_of_birth" TEXT,
    "relationship"  TEXT,
    "gender"        TEXT,
    "phone"         TEXT,
    "email"         TEXT,
    "percentage"    DOUBLE PRECISION NOT NULL DEFAULT 0,
    "is_minor"      BOOLEAN NOT NULL DEFAULT false,
    CONSTRAINT "employee_edit_beneficiary_pkey" PRIMARY KEY ("id")
);
ALTER TABLE "employee_edit_beneficiary" ADD CONSTRAINT "employee_edit_beneficiary_edit_fkey" FOREIGN KEY ("edit_no") REFERENCES "employee_edit_request"("no") ON DELETE CASCADE ON UPDATE NO ACTION;
CREATE INDEX "ix_eebnf_edit" ON "employee_edit_beneficiary"("edit_no");

CREATE TABLE "employee_edit_dependant" (
    "id"                  SERIAL NOT NULL,
    "edit_no"             TEXT   NOT NULL,
    "full_name"           TEXT   NOT NULL,
    "id_or_birth_cert_no" TEXT,
    "date_of_birth"       TEXT,
    "relationship"        TEXT,
    "gender"              TEXT,
    "is_student"          BOOLEAN NOT NULL DEFAULT false,
    CONSTRAINT "employee_edit_dependant_pkey" PRIMARY KEY ("id")
);
ALTER TABLE "employee_edit_dependant" ADD CONSTRAINT "employee_edit_dependant_edit_fkey" FOREIGN KEY ("edit_no") REFERENCES "employee_edit_request"("no") ON DELETE CASCADE ON UPDATE NO ACTION;
CREATE INDEX "ix_eedep_edit" ON "employee_edit_dependant"("edit_no");

CREATE TABLE "employee_edit_emergency_contact" (
    "id"           SERIAL NOT NULL,
    "edit_no"      TEXT   NOT NULL,
    "full_name"    TEXT   NOT NULL,
    "relationship" TEXT,
    "phone"        TEXT,
    "alt_phone"    TEXT,
    "email"        TEXT,
    CONSTRAINT "employee_edit_emergency_contact_pkey" PRIMARY KEY ("id")
);
ALTER TABLE "employee_edit_emergency_contact" ADD CONSTRAINT "employee_edit_emergency_contact_edit_fkey" FOREIGN KEY ("edit_no") REFERENCES "employee_edit_request"("no") ON DELETE CASCADE ON UPDATE NO ACTION;
CREATE INDEX "ix_eeec_edit" ON "employee_edit_emergency_contact"("edit_no");

CREATE TABLE "employee_edit_professional_body" (
    "id"            SERIAL NOT NULL,
    "edit_no"       TEXT   NOT NULL,
    "body_name"     TEXT   NOT NULL,
    "membership_no" TEXT,
    "from_date"     TEXT,
    "to_date"       TEXT,
    CONSTRAINT "employee_edit_professional_body_pkey" PRIMARY KEY ("id")
);
ALTER TABLE "employee_edit_professional_body" ADD CONSTRAINT "employee_edit_professional_body_edit_fkey" FOREIGN KEY ("edit_no") REFERENCES "employee_edit_request"("no") ON DELETE CASCADE ON UPDATE NO ACTION;
CREATE INDEX "ix_eepb_edit" ON "employee_edit_professional_body"("edit_no");

CREATE TABLE "employee_edit_work_history" (
    "id"                 SERIAL NOT NULL,
    "edit_no"            TEXT   NOT NULL,
    "institution"        TEXT   NOT NULL,
    "position_held"      TEXT,
    "from_date"          TEXT,
    "to_date"            TEXT,
    "reason_for_leaving" TEXT,
    CONSTRAINT "employee_edit_work_history_pkey" PRIMARY KEY ("id")
);
ALTER TABLE "employee_edit_work_history" ADD CONSTRAINT "employee_edit_work_history_edit_fkey" FOREIGN KEY ("edit_no") REFERENCES "employee_edit_request"("no") ON DELETE CASCADE ON UPDATE NO ACTION;
CREATE INDEX "ix_eewh_edit" ON "employee_edit_work_history"("edit_no");

CREATE TABLE "employee_edit_bank_account" (
    "id"         SERIAL NOT NULL,
    "edit_no"    TEXT   NOT NULL,
    "bank_code"  TEXT,
    "branch"     TEXT,
    "account_no" TEXT   NOT NULL,
    "percentage" DOUBLE PRECISION NOT NULL DEFAULT 100,
    CONSTRAINT "employee_edit_bank_account_pkey" PRIMARY KEY ("id")
);
ALTER TABLE "employee_edit_bank_account" ADD CONSTRAINT "employee_edit_bank_account_edit_fkey" FOREIGN KEY ("edit_no") REFERENCES "employee_edit_request"("no") ON DELETE CASCADE ON UPDATE NO ACTION;
CREATE INDEX "ix_eeba_edit" ON "employee_edit_bank_account"("edit_no");

-- ============================================================== contract / salary change (maker-checker)

CREATE TABLE "employee_contract_change" (
    "no"                   TEXT   NOT NULL,
    "employee_id"          INTEGER NOT NULL,
    "nature"               TEXT   NOT NULL,
    "contract_type_id"     INTEGER,
    "proposed_start_date"  TEXT,
    "proposed_end_date"    TEXT,
    "proposed_salary_cents" BIGINT,
    "proposed_grade_id"    INTEGER,
    "reason"               TEXT,
    "status"               TEXT   NOT NULL DEFAULT 'Open',
    "decision_reason"      TEXT,
    "created_at"           TEXT,
    "created_by"           TEXT,
    CONSTRAINT "employee_contract_change_pkey" PRIMARY KEY ("no")
);
ALTER TABLE "employee_contract_change" ADD CONSTRAINT "employee_contract_change_employee_fkey" FOREIGN KEY ("employee_id") REFERENCES "employee"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE "employee_contract_change" ADD CONSTRAINT "employee_contract_change_contract_type_fkey" FOREIGN KEY ("contract_type_id") REFERENCES "hr_employment_contract_type"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE "employee_contract_change" ADD CONSTRAINT "employee_contract_change_grade_fkey" FOREIGN KEY ("proposed_grade_id") REFERENCES "hr_job_grade"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;
CREATE INDEX "ix_ecc_employee" ON "employee_contract_change"("employee_id");
CREATE INDEX "ix_ecc_status" ON "employee_contract_change"("status");

-- ===================================================================== employee exit (maker-checker)

CREATE TABLE "employee_exit" (
    "no"                              TEXT   NOT NULL,
    "employee_id"                     INTEGER NOT NULL,
    "termination_reason_id"           INTEGER,
    "date_of_notice"                  TEXT,
    "date_of_exit"                    TEXT,
    "notice_period_days"              INTEGER,
    "notice_fully_served"             BOOLEAN,
    "reasons_for_not_serving_notice"  TEXT,
    "can_be_reemployed"               BOOLEAN,
    "cleared"                         BOOLEAN NOT NULL DEFAULT false,
    "status"                          TEXT   NOT NULL DEFAULT 'Open',
    "decision_reason"                 TEXT,
    "created_at"                      TEXT,
    "created_by"                      TEXT,
    CONSTRAINT "employee_exit_pkey" PRIMARY KEY ("no")
);
ALTER TABLE "employee_exit" ADD CONSTRAINT "employee_exit_employee_fkey" FOREIGN KEY ("employee_id") REFERENCES "employee"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE "employee_exit" ADD CONSTRAINT "employee_exit_reason_fkey" FOREIGN KEY ("termination_reason_id") REFERENCES "hr_termination_reason"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;
CREATE INDEX "ix_eexit_employee" ON "employee_exit"("employee_id");
CREATE INDEX "ix_eexit_status" ON "employee_exit"("status");

CREATE TABLE "employee_exit_final_due_line" (
    "id"          SERIAL NOT NULL,
    "exit_no"     TEXT   NOT NULL,
    "due_type"    TEXT   NOT NULL,
    "description" TEXT,
    "amount_cents" BIGINT NOT NULL DEFAULT 0,
    CONSTRAINT "employee_exit_final_due_line_pkey" PRIMARY KEY ("id")
);
ALTER TABLE "employee_exit_final_due_line" ADD CONSTRAINT "employee_exit_final_due_line_exit_fkey" FOREIGN KEY ("exit_no") REFERENCES "employee_exit"("no") ON DELETE CASCADE ON UPDATE NO ACTION;
CREATE INDEX "ix_eefdl_exit" ON "employee_exit_final_due_line"("exit_no");

CREATE TABLE "employee_exit_clearance_line" (
    "id"         SERIAL NOT NULL,
    "exit_no"    TEXT   NOT NULL,
    "section_id" INTEGER NOT NULL,
    "cleared"    BOOLEAN NOT NULL DEFAULT false,
    "cleared_by" TEXT,
    "cleared_at" TEXT,
    "remarks"    TEXT,
    CONSTRAINT "employee_exit_clearance_line_pkey" PRIMARY KEY ("id")
);
ALTER TABLE "employee_exit_clearance_line" ADD CONSTRAINT "employee_exit_clearance_line_exit_fkey" FOREIGN KEY ("exit_no") REFERENCES "employee_exit"("no") ON DELETE CASCADE ON UPDATE NO ACTION;
ALTER TABLE "employee_exit_clearance_line" ADD CONSTRAINT "employee_exit_clearance_line_section_fkey" FOREIGN KEY ("section_id") REFERENCES "hr_clearance_section"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;
CREATE INDEX "ix_eecl_exit" ON "employee_exit_clearance_line"("exit_no");

-- ==================================================================================== document numbering

INSERT INTO "sequence" ("name", "prefix", "next_no", "width") VALUES
  ('EMPLOYEE', 'EMP', 1, 6),
  ('EMPLOYEE_EDIT', 'EDT', 1, 6),
  ('EMPLOYEE_CONTRACT_CHANGE', 'CTR', 1, 6),
  ('EMPLOYEE_EXIT', 'EXT', 1, 6);
