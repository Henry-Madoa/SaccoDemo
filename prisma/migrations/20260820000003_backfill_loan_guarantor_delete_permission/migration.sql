-- Backfill: LOAN_CREATE (lib/permissions.ts) now also bundles delete rights on loan_guarantor,
-- alongside its existing insert right, so that a loan officer who could already commit a
-- guarantor can also release one (the "Add guarantor" / "Release" pair on a loan's Guarantors
-- card, mirroring loan_collateral's existing insert+delete pair under the same action). Any
-- role's Permission Set line already granting insert on loan_guarantor is exactly the set
-- assembled from LOAN_CREATE at seed time — carry a matching delete grant onto that same row so
-- existing installs don't lose "New application"/loan capture the moment LOAN_CREATE starts
-- requiring it too.
UPDATE "permission_set_line" SET "delete_perm" = 1
WHERE "object_type" = 'TABLE' AND "object_name" = 'loan_guarantor' AND "insert_perm" = 1;
