-- Company Organogram — AL Tab52203769 "Company Jobs" (the establishment: every position the
-- organisation has approved, how many posts it carries and which position it reports to), with
-- its Job Responsibilities (Tab52203780), Job Requirements (Tab52203772) and Job Qualifications
-- (Tab52203785). Employees are placed on a job (AL Employee."Job Code"); occupied and vacant
-- posts are counted from that, and the reporting lines between jobs draw the organogram.
CREATE TABLE "company_job" (
    "id"                    SERIAL  NOT NULL,
    "job_id"                TEXT    NOT NULL,
    "name"                  TEXT    NOT NULL,
    "objective"             TEXT,
    "reports_to_job_id"     INTEGER,
    "job_grade_id"          INTEGER,
    "global_dimension_1_id" INTEGER,
    "global_dimension_2_id" INTEGER,
    "no_of_posts"           INTEGER NOT NULL DEFAULT 1,
    "is_management"         BOOLEAN NOT NULL DEFAULT false,
    "profession"            TEXT,
    "skills_category"       TEXT,
    "skills_category_2"     TEXT,
    "skills_category_3"     TEXT,
    "status"                TEXT    NOT NULL DEFAULT 'Open',
    "decision_reason"       TEXT,
    "created_at"            TEXT,
    "created_by"            TEXT,
    "approved_at"           TEXT,
    "approved_by"           TEXT,
    CONSTRAINT "company_job_pkey" PRIMARY KEY ("id")
);
CREATE UNIQUE INDEX "company_job_job_id_key" ON "company_job"("job_id");
ALTER TABLE "company_job" ADD CONSTRAINT "cj_reports_to_fkey" FOREIGN KEY ("reports_to_job_id") REFERENCES "company_job"("id") ON DELETE SET NULL ON UPDATE NO ACTION;
ALTER TABLE "company_job" ADD CONSTRAINT "cj_job_grade_fkey" FOREIGN KEY ("job_grade_id") REFERENCES "hr_job_grade"("id") ON DELETE SET NULL ON UPDATE NO ACTION;
ALTER TABLE "company_job" ADD CONSTRAINT "cj_gd1_fkey" FOREIGN KEY ("global_dimension_1_id") REFERENCES "global_dimension_1_value"("id") ON DELETE SET NULL ON UPDATE NO ACTION;
ALTER TABLE "company_job" ADD CONSTRAINT "cj_gd2_fkey" FOREIGN KEY ("global_dimension_2_id") REFERENCES "global_dimension_2_value"("id") ON DELETE SET NULL ON UPDATE NO ACTION;
CREATE INDEX "ix_cj_reports_to" ON "company_job"("reports_to_job_id");

CREATE TABLE "company_job_responsibility" (
    "id"          SERIAL  NOT NULL,
    "job_id"      INTEGER NOT NULL,
    "line_no"     INTEGER NOT NULL DEFAULT 0,
    "description" TEXT    NOT NULL,
    CONSTRAINT "company_job_responsibility_pkey" PRIMARY KEY ("id")
);
ALTER TABLE "company_job_responsibility" ADD CONSTRAINT "cjr_job_fkey" FOREIGN KEY ("job_id") REFERENCES "company_job"("id") ON DELETE CASCADE ON UPDATE NO ACTION;
CREATE INDEX "ix_cjr_job" ON "company_job_responsibility"("job_id", "line_no");

CREATE TABLE "company_job_requirement" (
    "id"          SERIAL  NOT NULL,
    "job_id"      INTEGER NOT NULL,
    "line_no"     INTEGER NOT NULL DEFAULT 0,
    "description" TEXT    NOT NULL,
    CONSTRAINT "company_job_requirement_pkey" PRIMARY KEY ("id")
);
ALTER TABLE "company_job_requirement" ADD CONSTRAINT "cjq_job_fkey" FOREIGN KEY ("job_id") REFERENCES "company_job"("id") ON DELETE CASCADE ON UPDATE NO ACTION;
CREATE INDEX "ix_cjq_job" ON "company_job_requirement"("job_id", "line_no");

CREATE TABLE "company_job_qualification" (
    "id"                 SERIAL  NOT NULL,
    "job_id"             INTEGER NOT NULL,
    "qualification_type" TEXT    NOT NULL DEFAULT 'ACADEMIC',
    "qualification"      TEXT    NOT NULL,
    "description"        TEXT,
    "priority"           TEXT    NOT NULL DEFAULT 'MANDATORY',
    "competency_level"   TEXT,
    CONSTRAINT "company_job_qualification_pkey" PRIMARY KEY ("id")
);
ALTER TABLE "company_job_qualification" ADD CONSTRAINT "cjl_job_fkey" FOREIGN KEY ("job_id") REFERENCES "company_job"("id") ON DELETE CASCADE ON UPDATE NO ACTION;
CREATE INDEX "ix_cjl_job" ON "company_job_qualification"("job_id");

-- AL Employee."Job Code": the position an employee holds. On the live record and on an Employee
-- Editing request (HR proposes the move, approval applies it), like the other employment fields.
ALTER TABLE "employee" ADD COLUMN "company_job_id" INTEGER;
ALTER TABLE "employee" ADD CONSTRAINT "employee_company_job_fkey" FOREIGN KEY ("company_job_id") REFERENCES "company_job"("id") ON DELETE SET NULL ON UPDATE NO ACTION;
CREATE INDEX "ix_employee_company_job" ON "employee"("company_job_id");
ALTER TABLE "employee_edit_request" ADD COLUMN "company_job_id" INTEGER;

-- Numbering for the Job ID when none is typed (AL leaves it to the user; JOB0001 is offered).
INSERT INTO "sequence" ("name", "prefix", "next_no", "width") VALUES ('COMPANY_JOB', 'JOB', 1, 4)
ON CONFLICT DO NOTHING;

-- Permissions: whoever opens Employees opens Company Jobs and the Organogram; whoever may
-- create employees may draw up jobs; whoever approves employees approves jobs.
INSERT INTO "permission_set_line" ("role_id", "object_type", "object_name", "read_perm", "insert_perm", "modify_perm", "delete_perm", "execute_perm")
SELECT l."role_id", 'PAGE', p.page, 0, 0, 0, 0, 1
FROM "permission_set_line" l CROSS JOIN (VALUES ('COMPANY_JOBS'), ('ORGANOGRAM')) AS p(page)
WHERE l."object_type" = 'PAGE' AND l."object_name" = 'EMPLOYEES' AND l."execute_perm" = 1
ON CONFLICT ("role_id", "object_type", "object_name") DO NOTHING;
INSERT INTO "user_permission_line" ("user_id", "object_type", "object_name", "read_perm", "insert_perm", "modify_perm", "delete_perm", "execute_perm", "created_at", "created_by")
SELECT l."user_id", 'PAGE', p.page, 0, 0, 0, 0, 1, l."created_at", l."created_by"
FROM "user_permission_line" l CROSS JOIN (VALUES ('COMPANY_JOBS'), ('ORGANOGRAM')) AS p(page)
WHERE l."object_type" = 'PAGE' AND l."object_name" = 'EMPLOYEES' AND l."execute_perm" = 1
ON CONFLICT ("user_id", "object_type", "object_name") DO NOTHING;
INSERT INTO "permission_set_line" ("role_id", "object_type", "object_name", "read_perm", "insert_perm", "modify_perm", "delete_perm", "execute_perm")
SELECT l."role_id", 'TABLE', t.tbl, l."read_perm", l."insert_perm", l."modify_perm", l."delete_perm", 0
FROM "permission_set_line" l CROSS JOIN (VALUES ('company_job'), ('company_job_responsibility'), ('company_job_requirement'), ('company_job_qualification')) AS t(tbl)
WHERE l."object_type" = 'TABLE' AND l."object_name" = 'employee'
ON CONFLICT ("role_id", "object_type", "object_name") DO NOTHING;
INSERT INTO "user_permission_line" ("user_id", "object_type", "object_name", "read_perm", "insert_perm", "modify_perm", "delete_perm", "execute_perm", "created_at", "created_by")
SELECT l."user_id", 'TABLE', t.tbl, l."read_perm", l."insert_perm", l."modify_perm", l."delete_perm", 0, l."created_at", l."created_by"
FROM "user_permission_line" l CROSS JOIN (VALUES ('company_job'), ('company_job_responsibility'), ('company_job_requirement'), ('company_job_qualification')) AS t(tbl)
WHERE l."object_type" = 'TABLE' AND l."object_name" = 'employee'
ON CONFLICT ("user_id", "object_type", "object_name") DO NOTHING;
