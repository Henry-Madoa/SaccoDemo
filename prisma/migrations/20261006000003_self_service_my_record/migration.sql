-- Employee Self Service "My Record": the employee's own record and Employee Editing requests
-- against it. Grants the new page and its tables to the Employee Self Service permission set,
-- generated from the same ACTION list lib/seed.ts uses; the module page's children were granted
-- to whoever could open the module in 20261006000000_employee_self_service.
INSERT INTO "permission_set_line"
  ("role_id", "object_type", "object_name", "read_perm", "insert_perm", "modify_perm", "delete_perm", "execute_perm")
SELECT r.id, g.object_type, g.object_name, g.r, g.i, g.m, g.d, g.e
FROM "role" r
JOIN (VALUES
  ('Employee Self Service', 'PAGE', 'SELF_SERVICE_RECORD', 0, 0, 0, 0, 1),
  ('Employee Self Service', 'TABLE', 'employee', 1, 0, 0, 0, 0),
  ('Employee Self Service', 'TABLE', 'employee_edit_request', 1, 1, 1, 0, 0),
  ('Employee Self Service', 'TABLE', 'employee_next_of_kin', 1, 0, 0, 0, 0),
  ('Employee Self Service', 'TABLE', 'employee_beneficiary', 1, 0, 0, 0, 0),
  ('Employee Self Service', 'TABLE', 'employee_dependant', 1, 0, 0, 0, 0),
  ('Employee Self Service', 'TABLE', 'employee_emergency_contact', 1, 0, 0, 0, 0),
  ('Employee Self Service', 'TABLE', 'employee_professional_body', 1, 0, 0, 0, 0),
  ('Employee Self Service', 'TABLE', 'employee_work_history', 1, 0, 0, 0, 0),
  ('Employee Self Service', 'TABLE', 'employee_bank_account', 1, 0, 0, 0, 0),
  ('Employee Self Service', 'TABLE', 'employee_contract', 1, 0, 0, 0, 0),
  ('Employee Self Service', 'TABLE', 'employee_edit_next_of_kin', 0, 1, 0, 1, 0),
  ('Employee Self Service', 'TABLE', 'employee_edit_beneficiary', 0, 1, 0, 1, 0),
  ('Employee Self Service', 'TABLE', 'employee_edit_dependant', 0, 1, 0, 1, 0),
  ('Employee Self Service', 'TABLE', 'employee_edit_emergency_contact', 0, 1, 0, 1, 0),
  ('Employee Self Service', 'TABLE', 'employee_edit_professional_body', 0, 1, 0, 1, 0),
  ('Employee Self Service', 'TABLE', 'employee_edit_work_history', 0, 1, 0, 1, 0),
  ('Employee Self Service', 'TABLE', 'employee_edit_bank_account', 0, 1, 0, 1, 0),
  ('Employee Self Service', 'TABLE', 'workflow_task', 0, 1, 1, 0, 0)
) AS g(role_name, object_type, object_name, r, i, m, d, e) ON g.role_name = r.name
ON CONFLICT ("role_id", "object_type", "object_name") DO UPDATE SET
  "read_perm" = GREATEST("permission_set_line"."read_perm", EXCLUDED."read_perm"),
  "insert_perm" = GREATEST("permission_set_line"."insert_perm", EXCLUDED."insert_perm"),
  "modify_perm" = GREATEST("permission_set_line"."modify_perm", EXCLUDED."modify_perm"),
  "delete_perm" = GREATEST("permission_set_line"."delete_perm", EXCLUDED."delete_perm"),
  "execute_perm" = GREATEST("permission_set_line"."execute_perm", EXCLUDED."execute_perm");

-- Any other permission set or per-user line that can open the Self Service module also gets
-- the new screen, as the module's other tabs were backfilled.
INSERT INTO "permission_set_line"
  ("role_id", "object_type", "object_name", "read_perm", "insert_perm", "modify_perm", "delete_perm", "execute_perm")
SELECT l."role_id", 'PAGE', 'SELF_SERVICE_RECORD', 0, 0, 0, 0, 1
FROM "permission_set_line" l
WHERE l."object_type" = 'PAGE' AND l."object_name" = 'SELF_SERVICE' AND l."execute_perm" = 1
ON CONFLICT ("role_id", "object_type", "object_name") DO NOTHING;

INSERT INTO "user_permission_line"
  ("user_id", "object_type", "object_name", "read_perm", "insert_perm", "modify_perm", "delete_perm", "execute_perm", "created_at", "created_by")
SELECT l."user_id", 'PAGE', 'SELF_SERVICE_RECORD', 0, 0, 0, 0, 1, l."created_at", l."created_by"
FROM "user_permission_line" l
WHERE l."object_type" = 'PAGE' AND l."object_name" = 'SELF_SERVICE' AND l."execute_perm" = 1
ON CONFLICT ("user_id", "object_type", "object_name") DO NOTHING;
