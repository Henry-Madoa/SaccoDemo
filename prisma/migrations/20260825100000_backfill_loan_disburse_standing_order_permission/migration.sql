-- Backfill: LOAN_DISBURSE now also requires standing_order insert/modify (a STANDING_ORDER
-- recovery-mode loan auto-creates and activates its own recovery standing order the moment it's
-- disbursed — see lib/loanService.ts's disburse() and
-- lib/standingOrders.ts's createRecoveryStandingOrderForLoan()), but no migration ever granted
-- it to the roles that already carried LOAN_DISBURSE's other tables — leaving LOAN_DISBURSE (and
-- disbursement itself) unreachable for every seeded role ever since. Same technique as the
-- loan_collateral backfill above: loan_schedule insert is unique to LOAN_DISBURSE among the loan
-- actions (LOAN_CREATE never inserts it, LOAN_REPAY only modifies it), so any role already
-- granted insert on loan_schedule is exactly the set assembled from LOAN_DISBURSE at seed time —
-- carry the same grant onto standing_order.
INSERT INTO "permission_set_line" ("role_id", "object_type", "object_name", "insert_perm", "modify_perm")
SELECT "role_id", 'TABLE', 'standing_order', 1, 1
FROM "permission_set_line"
WHERE "object_type" = 'TABLE' AND "object_name" = 'loan_schedule' AND "insert_perm" = 1
ON CONFLICT ("role_id", "object_type", "object_name") DO UPDATE SET "insert_perm" = 1, "modify_perm" = 1;
