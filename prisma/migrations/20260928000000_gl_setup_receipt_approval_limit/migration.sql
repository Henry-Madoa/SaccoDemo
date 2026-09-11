-- Receipt Approval Limit moves to General Ledger Setup, where the AL keeps it
-- (GeneralLedgerSetup) and where the user asked for it.
--
-- It MOVES rather than being copied: two editable copies of one threshold is a way to have the
-- system enforce a figure nobody thinks is current. Cash Management Setup now shows it read-only
-- with a pointer. Whatever was already configured is carried across.
ALTER TABLE "organisation" ADD COLUMN "receipt_approval_limit" BIGINT NOT NULL DEFAULT 0;

UPDATE "organisation" o SET "receipt_approval_limit" = COALESCE(
  (SELECT s."receipt_approval_limit" FROM "cash_management_setup" s WHERE s."id" = 1), 0);
