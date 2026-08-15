-- Account Opening never takes a deposit itself — the account always opens at a zero balance,
-- and funding it is a separate Savings & FOSA deposit. Drop the now-unused columns.
ALTER TABLE "account_opening_request" DROP COLUMN "opening_balance";
ALTER TABLE "account_opening_request" DROP COLUMN "channel";
