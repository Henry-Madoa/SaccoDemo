-- AlterTable
ALTER TABLE "loan_product" ADD COLUMN "min_salary_count" INTEGER NOT NULL DEFAULT 1;
ALTER TABLE "loan_product" ADD COLUMN "salary_appraisal_type" TEXT NOT NULL DEFAULT 'AVERAGE_NET';

-- Data fix: `salary_based` is being redefined from "show the manual Earnings/Deductions card"
-- to "verify income from actually-processed payroll (Checkoff & Salary Processing)". None of the
-- seeded demo loan products have real processed SALARY-type checkoff batches behind their
-- members, so leaving them flagged salary_based would make every appraisal referred for lack of
-- salary history. Flip the existing seeded products back to the manual-card path.
UPDATE "loan_product" SET "salary_based" = 0 WHERE "code" IN ('NORM', 'EMER', 'SCHL', 'DEV');
