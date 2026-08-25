-- Backfill: two ACTIONS entries just picked up new tables — see lib/permissions.ts.
--   - CHECKOFF_BATCHES_CREATE now also requires checkoff_calculation insert/delete (Calculate,
--     a CSV upload, and a hand-edited remitted amount all write/clear that table — see
--     lib/checkoffBatches.ts's calculateCheckoffRecoveries()/applyCheckoffCsvUpload()/
--     recordRemittedAmount()).
--   - ADMIN_CHARGES_TRANSACTION_MANAGE now also requires transaction_recovery insert/delete
--     (replaceTransactionRecoveries() in lib/charges.ts).
-- Same technique as the standing_order backfill above: pick a table right unique to each action
-- among its siblings, and carry the same grant onto the new table for every role that already
-- has it. checkoff_batch_line modify is unique to CHECKOFF_BATCHES_CREATE (CHECKOFF_BATCHES_APPROVE
-- never modifies it); transaction_calc_scheme insert is unique to ADMIN_CHARGES_TRANSACTION_MANAGE.
INSERT INTO "permission_set_line" ("role_id", "object_type", "object_name", "insert_perm", "delete_perm")
SELECT "role_id", 'TABLE', 'checkoff_calculation', 1, 1
FROM "permission_set_line"
WHERE "object_type" = 'TABLE' AND "object_name" = 'checkoff_batch_line' AND "modify_perm" = 1
ON CONFLICT ("role_id", "object_type", "object_name") DO UPDATE SET "insert_perm" = 1, "delete_perm" = 1;

INSERT INTO "permission_set_line" ("role_id", "object_type", "object_name", "insert_perm", "delete_perm")
SELECT "role_id", 'TABLE', 'transaction_recovery', 1, 1
FROM "permission_set_line"
WHERE "object_type" = 'TABLE' AND "object_name" = 'transaction_calc_scheme' AND "insert_perm" = 1
ON CONFLICT ("role_id", "object_type", "object_name") DO UPDATE SET "insert_perm" = 1, "delete_perm" = 1;
