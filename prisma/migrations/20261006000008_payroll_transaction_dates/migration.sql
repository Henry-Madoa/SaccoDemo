-- Start / End Date on an employee's payroll earning or deduction line: in force only for
-- periods that overlap the window, and dropped from the roll-forward once the window has closed.
ALTER TABLE "employee_payroll_transaction" ADD COLUMN "start_date" TEXT;
ALTER TABLE "employee_payroll_transaction" ADD COLUMN "end_date" TEXT;
