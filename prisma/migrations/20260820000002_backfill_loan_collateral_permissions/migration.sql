-- Backfill: the Collateral module (20260817000000_add_collateral_module) added
-- loan_collateral insert/delete to LOAN_CREATE's required tables (lib/permissions.ts), but no
-- migration ever granted it to the roles that already carried LOAN_CREATE's other tables —
-- leaving LOAN_CREATE (and everything gated on it, including "New application") unreachable for
-- every seeded role ever since. Same technique as the loan_appraisal backfill above: any role
-- already granted insert on loan_guarantor is exactly the set assembled from LOAN_CREATE at seed
-- time, so carry the same grant onto loan_collateral.
INSERT INTO "permission_set_line" ("role_id", "object_type", "object_name", "insert_perm", "delete_perm")
SELECT "role_id", 'TABLE', 'loan_collateral', 1, 1
FROM "permission_set_line"
WHERE "object_type" = 'TABLE' AND "object_name" = 'loan_guarantor' AND "insert_perm" = 1
ON CONFLICT ("role_id", "object_type", "object_name") DO UPDATE SET "insert_perm" = 1, "delete_perm" = 1;
