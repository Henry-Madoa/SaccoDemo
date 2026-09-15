-- Payroll ↔ SACCO integration, ported from the AL:
--   * Employee "Member No." proposed on an Employee Editing request (HR-only Payroll Salary Card).
--   * Payroll Transaction Code "Loan Product" (Coop Parameter = loan) — Cod52204009 books each
--     checkoff loan product's deductions under its own code.
--   * "Loan Number" on the employee's period transactions and on the posted period lines, so the
--     run can refresh the Credit module's deductions and the post can repay the right loan
--     (Rep52204000 "Post Payroll").
ALTER TABLE "employee_edit_request" ADD COLUMN "member_id" INTEGER;
ALTER TABLE "employee_edit_request" ADD CONSTRAINT "employee_edit_request_member_id_fkey"
  FOREIGN KEY ("member_id") REFERENCES "member"("id") ON DELETE SET NULL ON UPDATE NO ACTION;
ALTER TABLE "payroll_transaction_code" ADD COLUMN "loan_product_id" INTEGER;
ALTER TABLE "employee_payroll_transaction" ADD COLUMN "loan_id" INTEGER;
ALTER TABLE "payroll_period_line" ADD COLUMN "loan_id" INTEGER;
