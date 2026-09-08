-- HR & Payroll Role Centre — the fourth and final piece of the HR & Payroll port. Seeds the
-- profile catalogue row (mirrors 20260910000000_add_role_centers's seeding of the original six)
-- plus a matching "HR Payroll Officer" Permission Set an admin can pair with it. The
-- permission_set_line rows are generated from the exact same ACTION list lib/seed.ts uses for a
-- fresh database (scripts/gen-role-center-perms.ts's approach), so the migration and the seed
-- can never drift.

INSERT INTO "profile" ("code", "name", "description", "role_centre", "icon", "sort", "is_default", "is_system", "created_by")
VALUES
  ('HR_PAYROLL', 'HR & Payroll Role Centre', 'Employee records, leave and payroll processing.', 'HR_PAYROLL', '🧑‍💼', 70, 0, 1, 'system')
ON CONFLICT ("code") DO NOTHING;

INSERT INTO "role" ("name", "description", "is_system")
VALUES
  ('HR Payroll Officer', 'Employee records, leave and payroll — pairs with the HR & Payroll role centre.', 0)
ON CONFLICT ("name") DO NOTHING;

-- 48 permission_set_line rows for the HR Payroll Officer role.
INSERT INTO "permission_set_line"
  ("role_id", "object_type", "object_name", "read_perm", "insert_perm", "modify_perm", "delete_perm", "execute_perm")
SELECT r.id, g.object_type, g.object_name, g.r, g.i, g.m, g.d, g.e
FROM "role" r
JOIN (VALUES
  ('HR Payroll Officer', 'PAGE', 'EMPLOYEES', 0, 0, 0, 0, 1),
  ('HR Payroll Officer', 'PAGE', 'EMPLOYEE_EDITS', 0, 0, 0, 0, 1),
  ('HR Payroll Officer', 'PAGE', 'EMPLOYEE_CONTRACT_CHANGES', 0, 0, 0, 0, 1),
  ('HR Payroll Officer', 'PAGE', 'EMPLOYEE_EXITS', 0, 0, 0, 0, 1),
  ('HR Payroll Officer', 'PAGE', 'LEAVE_APPLICATIONS', 0, 0, 0, 0, 1),
  ('HR Payroll Officer', 'PAGE', 'LEAVE_ADJUSTMENTS', 0, 0, 0, 0, 1),
  ('HR Payroll Officer', 'PAGE', 'LEAVE_RECALLS', 0, 0, 0, 0, 1),
  ('HR Payroll Officer', 'PAGE', 'LEAVE_PLANS', 0, 0, 0, 0, 1),
  ('HR Payroll Officer', 'PAGE', 'PAYROLL', 0, 0, 0, 0, 1),
  ('HR Payroll Officer', 'PAGE', 'PAYROLL_PERIODS', 0, 0, 0, 0, 1),
  ('HR Payroll Officer', 'PAGE', 'DASHBOARD', 0, 0, 0, 0, 1),
  ('HR Payroll Officer', 'PAGE', 'REPORTS', 0, 0, 0, 0, 1),
  ('HR Payroll Officer', 'PAGE', 'APPROVALS', 0, 0, 0, 0, 1),
  ('HR Payroll Officer', 'TABLE', 'employee', 1, 1, 1, 1, 0),
  ('HR Payroll Officer', 'TABLE', 'employee_next_of_kin', 1, 1, 0, 1, 0),
  ('HR Payroll Officer', 'TABLE', 'employee_beneficiary', 1, 1, 0, 1, 0),
  ('HR Payroll Officer', 'TABLE', 'employee_dependant', 1, 1, 0, 1, 0),
  ('HR Payroll Officer', 'TABLE', 'employee_emergency_contact', 1, 1, 0, 1, 0),
  ('HR Payroll Officer', 'TABLE', 'employee_professional_body', 1, 1, 0, 1, 0),
  ('HR Payroll Officer', 'TABLE', 'employee_work_history', 1, 1, 0, 1, 0),
  ('HR Payroll Officer', 'TABLE', 'employee_bank_account', 1, 1, 0, 1, 0),
  ('HR Payroll Officer', 'TABLE', 'employee_contract', 1, 1, 1, 0, 0),
  ('HR Payroll Officer', 'TABLE', 'workflow_task', 0, 1, 1, 0, 0),
  ('HR Payroll Officer', 'TABLE', 'employee_edit_request', 1, 1, 1, 0, 0),
  ('HR Payroll Officer', 'TABLE', 'employee_edit_next_of_kin', 0, 1, 0, 1, 0),
  ('HR Payroll Officer', 'TABLE', 'employee_edit_beneficiary', 0, 1, 0, 1, 0),
  ('HR Payroll Officer', 'TABLE', 'employee_edit_dependant', 0, 1, 0, 1, 0),
  ('HR Payroll Officer', 'TABLE', 'employee_edit_emergency_contact', 0, 1, 0, 1, 0),
  ('HR Payroll Officer', 'TABLE', 'employee_edit_professional_body', 0, 1, 0, 1, 0),
  ('HR Payroll Officer', 'TABLE', 'employee_edit_work_history', 0, 1, 0, 1, 0),
  ('HR Payroll Officer', 'TABLE', 'employee_edit_bank_account', 0, 1, 0, 1, 0),
  ('HR Payroll Officer', 'TABLE', 'employee_contract_change', 1, 1, 1, 1, 0),
  ('HR Payroll Officer', 'TABLE', 'employee_exit', 1, 1, 1, 0, 0),
  ('HR Payroll Officer', 'TABLE', 'employee_exit_final_due_line', 1, 1, 0, 1, 0),
  ('HR Payroll Officer', 'TABLE', 'employee_exit_clearance_line', 1, 1, 1, 0, 0),
  ('HR Payroll Officer', 'TABLE', 'hr_leave_application', 1, 1, 1, 1, 0),
  ('HR Payroll Officer', 'TABLE', 'hr_leave_ledger_entry', 1, 1, 0, 0, 0),
  ('HR Payroll Officer', 'TABLE', 'hr_leave_adjustment', 1, 1, 1, 1, 0),
  ('HR Payroll Officer', 'TABLE', 'hr_leave_adjustment_line', 1, 1, 0, 1, 0),
  ('HR Payroll Officer', 'TABLE', 'hr_leave_recall', 1, 1, 1, 1, 0),
  ('HR Payroll Officer', 'TABLE', 'hr_leave_plan', 1, 1, 1, 1, 0),
  ('HR Payroll Officer', 'TABLE', 'hr_leave_plan_line', 1, 1, 0, 1, 0),
  ('HR Payroll Officer', 'TABLE', 'employee_payroll_transaction', 1, 1, 1, 1, 0),
  ('HR Payroll Officer', 'TABLE', 'payroll_period_line', 1, 1, 1, 0, 0),
  ('HR Payroll Officer', 'TABLE', 'payroll_p9_line', 1, 1, 0, 0, 0),
  ('HR Payroll Officer', 'TABLE', 'payroll_period', 1, 1, 1, 0, 0),
  ('HR Payroll Officer', 'TABLE', 'journal', 0, 1, 0, 0, 0),
  ('HR Payroll Officer', 'TABLE', 'journal_line', 0, 1, 0, 0, 0)
) AS g(role_name, object_type, object_name, r, i, m, d, e) ON g.role_name = r.name
WHERE EXISTS (SELECT 1 FROM "organisation")
ON CONFLICT ("role_id", "object_type", "object_name") DO NOTHING;
