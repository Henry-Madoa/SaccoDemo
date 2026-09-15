-- Payroll Salary Card "Basic Pay" on the employee and proposed on an Employee Editing request.
-- Backfilled from the current contract, which is what the payroll run has always read.
ALTER TABLE "employee" ADD COLUMN "basic_pay_cents" BIGINT NOT NULL DEFAULT 0;
ALTER TABLE "employee_edit_request" ADD COLUMN "basic_pay_cents" BIGINT NOT NULL DEFAULT 0;
UPDATE "employee" e SET "basic_pay_cents" = c."salary_cents"
FROM "employee_contract" c WHERE c."employee_id" = e."id" AND c."is_current" = true;
