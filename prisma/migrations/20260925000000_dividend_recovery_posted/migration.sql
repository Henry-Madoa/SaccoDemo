-- A dividend payout over a whole membership is too large to post in one transaction against a
-- hosted database, so lib/dividends.ts posts it in chunks that each commit on their own and marks
-- what it has done as it goes. dividend_line already carries a "posted" flag for the member
-- credits; the loan recoveries need their own, because re-running a partly-posted payout must skip
-- a repayment that has already reached the loan rather than taking it twice.
ALTER TABLE "dividend_recovery" ADD COLUMN "posted" INTEGER NOT NULL DEFAULT 0;
CREATE INDEX "ix_dividend_recovery_posting" ON "dividend_recovery" ("dividend_id", "posted");
