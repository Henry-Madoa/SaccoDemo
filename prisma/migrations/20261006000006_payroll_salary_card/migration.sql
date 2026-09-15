-- AL Tab52203623 "Payroll Salary Card" on the employee (and proposed on an Employee Editing
-- request, where only HR may change it). Basic pay stays on the current employee_contract; the
-- cumulative figures (Cumm BasicPay / GrossPay / NetPay …) are FlowFields in AL and are computed
-- from payroll_p9_line / payroll_period_line here rather than stored.
ALTER TABLE "employee"
  ADD COLUMN "payment_mode" TEXT NOT NULL DEFAULT 'Bank Transfer',
  ADD COLUMN "payroll_currency_code" TEXT,
  ADD COLUMN "pays_nssf" BOOLEAN NOT NULL DEFAULT true,
  ADD COLUMN "pays_shif" BOOLEAN NOT NULL DEFAULT true,
  ADD COLUMN "pays_paye" BOOLEAN NOT NULL DEFAULT true,
  ADD COLUMN "payslip_message" TEXT,
  ADD COLUMN "suspend_pay" BOOLEAN NOT NULL DEFAULT false,
  ADD COLUMN "suspension_date" TEXT,
  ADD COLUMN "suspension_reasons" TEXT,
  ADD COLUMN "stop_relief" BOOLEAN NOT NULL DEFAULT false,
  ADD COLUMN "insurance_certificate" BOOLEAN NOT NULL DEFAULT false;

ALTER TABLE "employee_edit_request"
  ADD COLUMN "posting_group_id" INTEGER,
  ADD COLUMN "payment_mode" TEXT NOT NULL DEFAULT 'Bank Transfer',
  ADD COLUMN "payroll_currency_code" TEXT,
  ADD COLUMN "pays_nssf" BOOLEAN NOT NULL DEFAULT true,
  ADD COLUMN "pays_shif" BOOLEAN NOT NULL DEFAULT true,
  ADD COLUMN "pays_paye" BOOLEAN NOT NULL DEFAULT true,
  ADD COLUMN "payslip_message" TEXT,
  ADD COLUMN "suspend_pay" BOOLEAN NOT NULL DEFAULT false,
  ADD COLUMN "suspension_date" TEXT,
  ADD COLUMN "suspension_reasons" TEXT,
  ADD COLUMN "stop_relief" BOOLEAN NOT NULL DEFAULT false,
  ADD COLUMN "insurance_certificate" BOOLEAN NOT NULL DEFAULT false;
