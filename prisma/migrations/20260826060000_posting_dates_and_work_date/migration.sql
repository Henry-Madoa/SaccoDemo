-- BC-style global Allow Posting From/To (General Ledger Setup precedent).
ALTER TABLE "organisation" ADD COLUMN "allow_posting_from" TEXT;
ALTER TABLE "organisation" ADD COLUMN "allow_posting_to" TEXT;

-- Per-user override of the above (User Setup precedent), plus a time-of-day refinement on the
-- two boundary dates only.
ALTER TABLE "approval_user_setup" ADD COLUMN "allow_posting_from" TEXT;
ALTER TABLE "approval_user_setup" ADD COLUMN "allow_posting_to" TEXT;
ALTER TABLE "approval_user_setup" ADD COLUMN "allow_posting_from_time" TEXT;
ALTER TABLE "approval_user_setup" ADD COLUMN "allow_posting_to_time" TEXT;

-- BC's "Work Date" (My Settings) — the date a user's own new documents suggest by default.
ALTER TABLE "app_user" ADD COLUMN "work_date" TEXT;
