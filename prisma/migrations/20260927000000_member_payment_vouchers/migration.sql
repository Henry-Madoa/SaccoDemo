-- Member payments on the Payment Voucher — ported from the Nation CBS AL extension
-- (Sacco CBS/src): Enum-Ext52204001 "Payment Types", Tab-Ext52204017 "Payment Voucher"
-- (Member No.), Tab-Ext52204018 "Payment Voucher Lines" (Member No., Available Balance).
--
-- The AL relates a voucher line's Account No to a different table per Payment Type, so the type
-- chosen on the header decides what the lines may pay: a Member Payment pays out of one of the
-- member's own deposit accounts, a Supplier Payment pays a vendor, and so on.

ALTER TABLE "payment_voucher_header"
  ADD COLUMN "member_id"   INTEGER REFERENCES "member"("id"),
  ADD COLUMN "member_no"   TEXT,
  ADD COLUMN "member_name" TEXT;

CREATE INDEX "ix_pvh_member" ON "payment_voucher_header" ("member_id");

ALTER TABLE "payment_voucher_line"
  ADD COLUMN "member_id"          INTEGER REFERENCES "member"("id"),
  ADD COLUMN "savings_account_id" INTEGER REFERENCES "savings_account"("id"),
  -- AL "Available Balance": Balance − Uncleared Funds − the product's Minimum Balance, floored at
  -- zero. Snapshotted when the line is captured so the voucher shows what was drawable then, and
  -- re-checked at posting against the live balance.
  ADD COLUMN "available_balance"  BIGINT NOT NULL DEFAULT 0;

ALTER TABLE "posted_payment_voucher"
  ADD COLUMN "member_id"   INTEGER REFERENCES "member"("id"),
  ADD COLUMN "member_no"   TEXT,
  ADD COLUMN "member_name" TEXT;

ALTER TABLE "posted_payment_voucher_line"
  ADD COLUMN "member_id"          INTEGER REFERENCES "member"("id"),
  ADD COLUMN "savings_account_id" INTEGER REFERENCES "savings_account"("id"),
  ADD COLUMN "available_balance"  BIGINT NOT NULL DEFAULT 0;

-- pv_type was free text; it is now the AL's Payment Type and drives what a line may pay.
-- Anything already captured is left as it is and reads as Direct Expensing, which is what the
-- existing G/L-line vouchers are.
UPDATE "payment_voucher_header" SET "pv_type" = 'Direct Expensing'
  WHERE "pv_type" IS NULL OR "pv_type" NOT IN
    ('Member Payment', 'RTGS/SWIFT', 'Supplier Payment', 'Customer Refund', 'Bank Transfer',
     'Direct Expensing', 'Payroll Settlement', 'Remittance');
