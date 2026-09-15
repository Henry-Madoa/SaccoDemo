-- AL Payroll Transaction Code "Include Employer Deduction" / "Is Formula for employer": a
-- deduction can carry an employer-side contribution — a factor of the employee's amount (2 =
-- the employer pays double), or its own formula — costed to the code's employer expense
-- account and credited to the same payable, never touching net pay.
ALTER TABLE "payroll_transaction_code"
  ADD COLUMN "employer_factor"  DOUBLE PRECISION NOT NULL DEFAULT 0,
  ADD COLUMN "employer_formula" TEXT;
