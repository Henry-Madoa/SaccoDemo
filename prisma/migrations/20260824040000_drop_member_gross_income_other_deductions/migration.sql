-- Gross income / other deductions are now captured per-loan on the loan card's Salary
-- Appraisal section (loan_salary_appraisal_line), not once at member level — every loan
-- product is Salary based, so the itemised figures are always available before an
-- affordability check runs.

-- AlterTable
ALTER TABLE "member" DROP COLUMN "gross_income";
ALTER TABLE "member" DROP COLUMN "other_deductions";

-- AlterTable
ALTER TABLE "member_application" DROP COLUMN "gross_income";
ALTER TABLE "member_application" DROP COLUMN "other_deductions";

-- AlterTable
ALTER TABLE "member_edit_request" DROP COLUMN "gross_income";
ALTER TABLE "member_edit_request" DROP COLUMN "other_deductions";
