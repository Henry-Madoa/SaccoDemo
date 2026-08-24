-- Backfill: LOAN_CREATE (lib/permissions.ts) now bundles insert rights on the new
-- loan_appraisal / loan_appraisal_factor tables alongside loan_guarantor, so that whoever
-- could already capture a loan and its guarantors can also file an appraisal against it.
-- Any role's Permission Set line already granting insert on loan_guarantor is exactly the set
-- that was assembled from LOAN_CREATE at seed time — carry the same grant onto the two new
-- tables so existing installs don't silently lose "Run appraisal" the moment this ships.
INSERT INTO "permission_set_line" ("role_id", "object_type", "object_name", "insert_perm")
SELECT "role_id", 'TABLE', 'loan_appraisal', 1
FROM "permission_set_line"
WHERE "object_type" = 'TABLE' AND "object_name" = 'loan_guarantor' AND "insert_perm" = 1
ON CONFLICT ("role_id", "object_type", "object_name") DO UPDATE SET "insert_perm" = 1;

INSERT INTO "permission_set_line" ("role_id", "object_type", "object_name", "insert_perm")
SELECT "role_id", 'TABLE', 'loan_appraisal_factor', 1
FROM "permission_set_line"
WHERE "object_type" = 'TABLE' AND "object_name" = 'loan_guarantor' AND "insert_perm" = 1
ON CONFLICT ("role_id", "object_type", "object_name") DO UPDATE SET "insert_perm" = 1;
