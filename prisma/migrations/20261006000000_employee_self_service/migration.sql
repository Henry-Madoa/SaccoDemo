-- Employee Self Service, ported from the Sacco ERP AL:
--   * User Setup "Employee No." (Tab-Ext52203463) — which employee a login is. Every self-service
--     document reads it on insert (UserSetup.GET(UserId); TESTFIELD("Employee No."); Validate(
--     "Employee No", ...)) and every "SS" list page filters on it. One login per employee.
--   * A Role Centre profile and a matching permission set. The permission_set_line rows are
--     generated from the exact ACTION list lib/seed.ts uses for a fresh database, so the migration
--     and the seed cannot drift (the approach of 20260915000000_add_hr_payroll_role_centre).

ALTER TABLE "approval_user_setup" ADD COLUMN "employee_id" INTEGER;
CREATE UNIQUE INDEX "ux_approval_user_setup_employee" ON "approval_user_setup"("employee_id");
ALTER TABLE "approval_user_setup" ADD CONSTRAINT "approval_user_setup_employee_id_fkey"
  FOREIGN KEY ("employee_id") REFERENCES "employee"("id") ON DELETE SET NULL ON UPDATE NO ACTION;

INSERT INTO "profile" ("code", "name", "description", "role_centre", "icon", "sort", "is_default", "is_system", "created_by")
VALUES
  ('SELF_SERVICE', 'Employee Self Service', 'Your own payslips, P9, leave, imprests, petty cash and requisitions.', 'SELF_SERVICE', '🙋', 80, 0, 1, 'system')
ON CONFLICT ("code") DO NOTHING;

INSERT INTO "role" ("name", "description", "is_system")
VALUES
  ('Employee Self Service', 'An employee''s own payslips, P9, leave, imprests, petty cash and requisitions — pairs with the Employee Self Service role centre. Needs the login matched to an employee in User Setup.', 0)
ON CONFLICT ("name") DO NOTHING;

-- 32 permission_set_line rows for the Employee Self Service role.
INSERT INTO "permission_set_line"
  ("role_id", "object_type", "object_name", "read_perm", "insert_perm", "modify_perm", "delete_perm", "execute_perm")
SELECT r.id, g.object_type, g.object_name, g.r, g.i, g.m, g.d, g.e
FROM "role" r
JOIN (VALUES
  ('Employee Self Service', 'PAGE', 'SELF_SERVICE', 0, 0, 0, 0, 1),
  ('Employee Self Service', 'PAGE', 'SELF_SERVICE_PAYSLIPS', 0, 0, 0, 0, 1),
  ('Employee Self Service', 'PAGE', 'SELF_SERVICE_P9', 0, 0, 0, 0, 1),
  ('Employee Self Service', 'PAGE', 'SELF_SERVICE_LEAVE', 0, 0, 0, 0, 1),
  ('Employee Self Service', 'PAGE', 'SELF_SERVICE_LEAVE_PLANS', 0, 0, 0, 0, 1),
  ('Employee Self Service', 'PAGE', 'SELF_SERVICE_IMPREST', 0, 0, 0, 0, 1),
  ('Employee Self Service', 'PAGE', 'SELF_SERVICE_PETTY_CASH', 0, 0, 0, 0, 1),
  ('Employee Self Service', 'PAGE', 'SELF_SERVICE_REQUISITIONS', 0, 0, 0, 0, 1),
  ('Employee Self Service', 'PAGE', 'DASHBOARD', 0, 0, 0, 0, 1),
  ('Employee Self Service', 'PAGE', 'APPROVALS', 0, 0, 0, 0, 1),
  ('Employee Self Service', 'TABLE', 'employee', 1, 0, 0, 0, 0),
  ('Employee Self Service', 'TABLE', 'approval_user_setup', 1, 0, 0, 0, 0),
  ('Employee Self Service', 'TABLE', 'payroll_period', 1, 0, 0, 0, 0),
  ('Employee Self Service', 'TABLE', 'payroll_period_line', 1, 0, 0, 0, 0),
  ('Employee Self Service', 'TABLE', 'payroll_p9_line', 1, 0, 0, 0, 0),
  ('Employee Self Service', 'TABLE', 'hr_leave_application', 1, 1, 1, 1, 0),
  ('Employee Self Service', 'TABLE', 'hr_leave_ledger_entry', 1, 0, 0, 0, 0),
  ('Employee Self Service', 'TABLE', 'hr_leave_type', 1, 0, 0, 0, 0),
  ('Employee Self Service', 'TABLE', 'workflow_task', 0, 1, 1, 0, 0),
  ('Employee Self Service', 'TABLE', 'hr_leave_plan', 1, 1, 1, 1, 0),
  ('Employee Self Service', 'TABLE', 'hr_leave_plan_line', 1, 1, 0, 1, 0),
  ('Employee Self Service', 'TABLE', 'imprest_request', 1, 1, 1, 1, 0),
  ('Employee Self Service', 'TABLE', 'imprest_request_line', 1, 1, 1, 1, 0),
  ('Employee Self Service', 'TABLE', 'employee_ledger_entry', 1, 0, 0, 0, 0),
  ('Employee Self Service', 'TABLE', 'imprest_purpose', 1, 0, 0, 0, 0),
  ('Employee Self Service', 'TABLE', 'petty_cash', 1, 1, 1, 1, 0),
  ('Employee Self Service', 'TABLE', 'petty_cash_line', 1, 1, 1, 1, 0),
  ('Employee Self Service', 'TABLE', 'requisition', 1, 1, 1, 1, 0),
  ('Employee Self Service', 'TABLE', 'requisition_line', 1, 1, 1, 1, 0),
  ('Employee Self Service', 'TABLE', 'item', 1, 0, 0, 0, 0),
  ('Employee Self Service', 'TABLE', 'location', 1, 0, 0, 0, 0),
  ('Employee Self Service', 'TABLE', 'vendor', 1, 0, 0, 0, 0)
) AS g(role_name, object_type, object_name, r, i, m, d, e) ON g.role_name = r.name
WHERE EXISTS (SELECT 1 FROM "organisation")
ON CONFLICT ("role_id", "object_type", "object_name") DO NOTHING;

-- The System Administrator and whoever already had every profile keep getting the new one
-- assigned, the way the seed does for the admin login.
INSERT INTO "user_profile" ("user_id", "profile_id")
SELECT u.id, p.id
FROM "app_user" u
JOIN "role" r ON r.id = u.role_id AND r.name = 'System Administrator'
JOIN "profile" p ON p.code = 'SELF_SERVICE'
ON CONFLICT DO NOTHING;
