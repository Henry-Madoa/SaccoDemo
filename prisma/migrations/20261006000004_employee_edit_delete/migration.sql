-- Delete on an Open employee edit request (EMPLOYEE_EDITS_DELETE / SELF_SERVICE_RECORD_DELETE):
-- the request header and its proposed sub-entity rows. Granted to every permission set and
-- per-user line that can already raise edit requests (Modify on employee_edit_request), so nobody
-- who could create a draft is left unable to discard it. The grant is a separate action rather
-- than an addition to EMPLOYEE_EDITS_UPDATE, which would have revoked that action for any set
-- lacking the delete right.
INSERT INTO "permission_set_line"
  ("role_id", "object_type", "object_name", "read_perm", "insert_perm", "modify_perm", "delete_perm", "execute_perm")
SELECT l."role_id", 'TABLE', t.name, 0, 0, 0, 1, 0
FROM "permission_set_line" l
CROSS JOIN (VALUES
  ('employee_edit_request'), ('employee_edit_next_of_kin'), ('employee_edit_beneficiary'), ('employee_edit_dependant'),
  ('employee_edit_emergency_contact'), ('employee_edit_professional_body'), ('employee_edit_work_history'), ('employee_edit_bank_account')
) AS t(name)
WHERE l."object_type" = 'TABLE' AND l."object_name" = 'employee_edit_request' AND l."modify_perm" = 1
ON CONFLICT ("role_id", "object_type", "object_name") DO UPDATE SET "delete_perm" = 1;

INSERT INTO "user_permission_line"
  ("user_id", "object_type", "object_name", "read_perm", "insert_perm", "modify_perm", "delete_perm", "execute_perm", "created_at", "created_by")
SELECT l."user_id", 'TABLE', t.name, 0, 0, 0, 1, 0, l."created_at", l."created_by"
FROM "user_permission_line" l
CROSS JOIN (VALUES
  ('employee_edit_request'), ('employee_edit_next_of_kin'), ('employee_edit_beneficiary'), ('employee_edit_dependant'),
  ('employee_edit_emergency_contact'), ('employee_edit_professional_body'), ('employee_edit_work_history'), ('employee_edit_bank_account')
) AS t(name)
WHERE l."object_type" = 'TABLE' AND l."object_name" = 'employee_edit_request' AND l."modify_perm" = 1
ON CONFLICT ("user_id", "object_type", "object_name") DO UPDATE SET "delete_perm" = 1;
