-- The Imprest Purposes Setup Pool screen is a page of its own; the roles that manage the
-- purposes table need Execute on it.
INSERT INTO "permission_set_line"
  ("role_id", "object_type", "object_name", "read_perm", "insert_perm", "modify_perm", "delete_perm", "execute_perm")
SELECT r.id, 'PAGE', 'ADMIN_POOL_IMPREST_PURPOSES', 0, 0, 0, 0, 1
FROM "role" r WHERE r.name IN ('Finance Officer', 'Finance Manager', 'Accountant', 'Internal Auditor')
ON CONFLICT ("role_id", "object_type", "object_name") DO UPDATE SET "execute_perm" = 1;
