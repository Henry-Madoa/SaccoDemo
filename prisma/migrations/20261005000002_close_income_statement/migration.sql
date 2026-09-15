-- Business Central's fiscal-year close and Close Income Statement.
--
-- accounting_period gains BC's Accounting Period fields: "New Fiscal Year" marks the period a
-- fiscal year starts on, "Closed" (fiscally_closed) is set by Close Year on every period of the
-- earliest open year and never cleared, and "Date Locked" pins those periods' dates. The existing
-- OPEN/CLOSED `status` is unchanged and keeps its job of gating postings — BC's Allow Posting
-- From/To, not its fiscal-year close.
ALTER TABLE "accounting_period" ADD COLUMN "new_fiscal_year" INTEGER NOT NULL DEFAULT 0;
ALTER TABLE "accounting_period" ADD COLUMN "fiscally_closed" INTEGER NOT NULL DEFAULT 0;
ALTER TABLE "accounting_period" ADD COLUMN "date_locked" INTEGER NOT NULL DEFAULT 0;

-- Periods are calendar months here, so the fiscal year starts on the period whose month is the
-- organisation's fiscal-year start month.
UPDATE "accounting_period" p
SET "new_fiscal_year" = 1
FROM "organisation" o
WHERE o.id = 1
  AND EXTRACT(MONTH FROM p."start_date"::date) = COALESCE(o."fy_start_month", 1);

-- BC's closing date ("C31/12/2025"): a journal posted by Close Income Statement is dated the last
-- day of the fiscal year but sits *after* it — outside a "..31/12/2025" filter, inside
-- "..01/01/2026". The flag is what every date-bounded G/L query reads to tell the two apart.
ALTER TABLE "journal" ADD COLUMN "closing_entry" INTEGER NOT NULL DEFAULT 0;

-- The Close Income Statement screen is a page of its own under General Ledger; every permission
-- set and per-user line that can open the module keeps opening all of it (as the other tabs were
-- backfilled in 20260930000000_module_tab_pages).
INSERT INTO "permission_set_line"
  ("role_id", "object_type", "object_name", "read_perm", "insert_perm", "modify_perm", "delete_perm", "execute_perm")
SELECT l."role_id", 'PAGE', 'GL_CLOSE_INCOME_STATEMENT', 0, 0, 0, 0, 1
FROM "permission_set_line" l
WHERE l."object_type" = 'PAGE' AND l."object_name" = 'GL' AND l."execute_perm" = 1
ON CONFLICT ("role_id", "object_type", "object_name") DO NOTHING;

INSERT INTO "user_permission_line"
  ("user_id", "object_type", "object_name", "read_perm", "insert_perm", "modify_perm", "delete_perm", "execute_perm", "created_at", "created_by")
SELECT l."user_id", 'PAGE', 'GL_CLOSE_INCOME_STATEMENT', 0, 0, 0, 0, 1, l."created_at", l."created_by"
FROM "user_permission_line" l
WHERE l."object_type" = 'PAGE' AND l."object_name" = 'GL' AND l."execute_perm" = 1
ON CONFLICT ("user_id", "object_type", "object_name") DO NOTHING;

-- Create Fiscal Year inserts periods; whoever could already close a period (accounting_period
-- Modify — GL_PERIOD_CLOSE) can also create the next year's.
INSERT INTO "permission_set_line"
  ("role_id", "object_type", "object_name", "read_perm", "insert_perm", "modify_perm", "delete_perm", "execute_perm")
SELECT l."role_id", 'TABLE', 'accounting_period', l."read_perm", 1, l."modify_perm", l."delete_perm", l."execute_perm"
FROM "permission_set_line" l
WHERE l."object_type" = 'TABLE' AND l."object_name" = 'accounting_period' AND l."modify_perm" = 1
ON CONFLICT ("role_id", "object_type", "object_name") DO UPDATE SET "insert_perm" = 1;
