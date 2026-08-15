-- Business Central-style G/L "Account Type": Posting (leaf, ledger-bearing), Heading,
-- Total, Begin-Total, End-Total. Existing rows are all either postable leaves or the old
-- flat headers, so the backfill is unambiguous; Total/Begin-Total/End-Total are new
-- authoring options going forward, entered through the account form.
ALTER TABLE "gl_account" ADD COLUMN "account_type" TEXT NOT NULL DEFAULT 'POSTING';
ALTER TABLE "gl_account" ADD COLUMN "totaling" TEXT;

UPDATE "gl_account" SET "account_type" = 'HEADING' WHERE "is_postable" = 0;
