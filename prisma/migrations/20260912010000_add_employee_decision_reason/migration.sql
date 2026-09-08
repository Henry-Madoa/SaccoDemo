-- A rejected onboarding (Pending Approval -> New) needs somewhere to carry the reviewer's reason,
-- the same shape every other maker-checker document's `decision_reason` column already has.
ALTER TABLE "employee" ADD COLUMN "decision_reason" TEXT;
