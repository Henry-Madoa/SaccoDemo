-- Salary Grades & Scales, ported from the Sacco ERP AL:
--   * hr_salary_scale         = Tab52203636 "Salary Scale Pointers" — a notch on a job grade
--                               (AL "Employee Payroll Scales" = hr_job_grade) with its Basic Pay.
--   * hr_salary_scale_benefit = Tab52203627 "Income/Deduction Configuration" — the earnings and
--                               deductions the notch confers (transaction code + amount).
--   * employee.salary_scale_id = AL Employee "J-G Steps"; proposed on an Employee Editing request.
--   * employee_payroll_transaction.salary_scale_id marks lines the notch conferred.
CREATE TABLE "hr_salary_scale" (
  "id" SERIAL NOT NULL,
  "job_grade_id" INTEGER NOT NULL,
  "code" TEXT NOT NULL,
  "name" TEXT,
  "basic_pay_cents" BIGINT NOT NULL DEFAULT 0,
  "sequence" INTEGER NOT NULL DEFAULT 0,
  "status" TEXT NOT NULL DEFAULT 'ACTIVE',
  "created_at" TEXT,
  "created_by" TEXT,
  CONSTRAINT "hr_salary_scale_pkey" PRIMARY KEY ("id")
);
CREATE UNIQUE INDEX "ux_salary_scale_grade_code" ON "hr_salary_scale"("job_grade_id", "code");
CREATE INDEX "ix_salary_scale_grade" ON "hr_salary_scale"("job_grade_id");
ALTER TABLE "hr_salary_scale" ADD CONSTRAINT "hr_salary_scale_job_grade_fkey"
  FOREIGN KEY ("job_grade_id") REFERENCES "hr_job_grade"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

CREATE TABLE "hr_salary_scale_benefit" (
  "id" SERIAL NOT NULL,
  "salary_scale_id" INTEGER NOT NULL,
  "transaction_code_id" INTEGER NOT NULL,
  "amount_cents" BIGINT NOT NULL DEFAULT 0,
  "notes" TEXT,
  CONSTRAINT "hr_salary_scale_benefit_pkey" PRIMARY KEY ("id")
);
CREATE UNIQUE INDEX "ux_salary_scale_benefit" ON "hr_salary_scale_benefit"("salary_scale_id", "transaction_code_id");
ALTER TABLE "hr_salary_scale_benefit" ADD CONSTRAINT "hr_salary_scale_benefit_scale_fkey"
  FOREIGN KEY ("salary_scale_id") REFERENCES "hr_salary_scale"("id") ON DELETE CASCADE ON UPDATE NO ACTION;
ALTER TABLE "hr_salary_scale_benefit" ADD CONSTRAINT "hr_salary_scale_benefit_code_fkey"
  FOREIGN KEY ("transaction_code_id") REFERENCES "payroll_transaction_code"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

ALTER TABLE "employee" ADD COLUMN "salary_scale_id" INTEGER;
ALTER TABLE "employee" ADD CONSTRAINT "employee_salary_scale_fkey"
  FOREIGN KEY ("salary_scale_id") REFERENCES "hr_salary_scale"("id") ON DELETE SET NULL ON UPDATE NO ACTION;
ALTER TABLE "employee_edit_request" ADD COLUMN "salary_scale_id" INTEGER;
ALTER TABLE "employee_payroll_transaction" ADD COLUMN "salary_scale_id" INTEGER;
