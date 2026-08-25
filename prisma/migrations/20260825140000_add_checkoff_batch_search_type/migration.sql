-- AlterTable: which CSV column identifies each uploaded row's member, and how it's resolved —
-- ported from the AL reference's "CheckOff Search Type" enum. Defaults to PAYROLL_NO, matching
-- this port's existing CSV-matching behaviour before this column existed.
ALTER TABLE "checkoff_batch" ADD COLUMN "search_type" TEXT NOT NULL DEFAULT 'PAYROLL_NO';
