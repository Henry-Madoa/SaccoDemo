-- Removes the pre-Loan-Product-Charges flat processing-fee/insurance-% fallback (loans.ts's
-- calculateLoanProductCharges lines are now the only way a loan product charges anything), and
-- the loan_product.gl_fee_income_id account it posted to.

-- DropForeignKey
ALTER TABLE "loan_product" DROP CONSTRAINT "loan_product_gl_fee_income_id_fkey";

-- AlterTable
ALTER TABLE "loan_product" DROP COLUMN "processing_fee_pct",
DROP COLUMN "insurance_pct",
DROP COLUMN "gl_fee_income_id";
