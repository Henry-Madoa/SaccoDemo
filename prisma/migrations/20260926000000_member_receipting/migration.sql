-- Member Receipting — ported from the Nation CBS AL extension (Sacco CBS/src):
--   Enum-Ext52204000 "Receipt Type"      adds the Member value
--   Tab-Ext52204014 "Receipt Header"     Member No./Name, Received Amount
--   Tab-Ext52204015 "Receipt Lines"      Member No., Loan No., the balance snapshot, Charge Code
--   Pag52204210     "Member Receipt Lines"
--   Cod52204021     "CBS Cash Management".PostReceipt, the Member branch
--
-- A Member receipt takes cash over the counter for one member: each line either tops up one of
-- their savings accounts or repays one of their loans, and the loan lines carry the balances the
-- teller quoted at the time so the printed receipt can show what was owed before the payment.

ALTER TABLE "receipt_header"
  ADD COLUMN "member_id"       INTEGER REFERENCES "member"("id"),
  ADD COLUMN "member_no"       TEXT,
  ADD COLUMN "member_name"     TEXT,
  -- AL "Received Amount": what the teller counted. Checked against the sum of the lines before
  -- the receipt may be sent for approval, so a miskeyed line cannot post.
  ADD COLUMN "received_amount" BIGINT NOT NULL DEFAULT 0;

CREATE INDEX "ix_receipt_header_member" ON "receipt_header" ("member_id");

ALTER TABLE "receipt_line"
  ADD COLUMN "member_id"          INTEGER REFERENCES "member"("id"),
  ADD COLUMN "savings_account_id" INTEGER REFERENCES "savings_account"("id"),
  ADD COLUMN "loan_id"            INTEGER REFERENCES "loan"("id"),
  -- The savings product category behind the line — AL's "Product Posting Type", which is what
  -- decides whether a Loan No. is required.
  ADD COLUMN "product_category"   TEXT,
  -- AL's balance snapshot, taken when the line is captured and printed on the receipt.
  ADD COLUMN "penalty_balance"    BIGINT NOT NULL DEFAULT 0,
  ADD COLUMN "accrued_interest"   BIGINT NOT NULL DEFAULT 0,
  ADD COLUMN "interest_balance"   BIGINT NOT NULL DEFAULT 0,
  ADD COLUMN "principal_balance"  BIGINT NOT NULL DEFAULT 0,
  ADD COLUMN "loan_balance"       BIGINT NOT NULL DEFAULT 0,
  -- AL's "Charge Code"/"Charge Amount": the loan repayment charge, deducted from the line before
  -- what is left is applied to the loan.
  ADD COLUMN "charge_id"          INTEGER REFERENCES "transaction_charge"("id"),
  ADD COLUMN "charge_amount"      BIGINT NOT NULL DEFAULT 0;

-- The posted copy keeps the same detail so a reprint years later still shows what was settled.
ALTER TABLE "posted_receipt"
  ADD COLUMN "member_id"   INTEGER REFERENCES "member"("id"),
  ADD COLUMN "member_no"   TEXT,
  ADD COLUMN "member_name" TEXT;

ALTER TABLE "posted_receipt_line"
  ADD COLUMN "member_id"          INTEGER REFERENCES "member"("id"),
  ADD COLUMN "savings_account_id" INTEGER REFERENCES "savings_account"("id"),
  ADD COLUMN "loan_id"            INTEGER REFERENCES "loan"("id"),
  ADD COLUMN "product_category"   TEXT,
  ADD COLUMN "penalty_balance"    BIGINT NOT NULL DEFAULT 0,
  ADD COLUMN "accrued_interest"   BIGINT NOT NULL DEFAULT 0,
  ADD COLUMN "interest_balance"   BIGINT NOT NULL DEFAULT 0,
  ADD COLUMN "principal_balance"  BIGINT NOT NULL DEFAULT 0,
  ADD COLUMN "loan_balance"       BIGINT NOT NULL DEFAULT 0,
  ADD COLUMN "charge_amount"      BIGINT NOT NULL DEFAULT 0;

-- AL reads the loan repayment charge off General Ledger Setup; here receipt behaviour is
-- configured on Cash Management Setup, which is where the receipt approval limit already lives.
ALTER TABLE "cash_management_setup"
  ADD COLUMN "loan_repayment_charge_id" INTEGER REFERENCES "transaction_charge"("id"),
  -- Where the remainder goes when a member pays more than their loan still owes. Null means the
  -- receipt refuses the overpayment instead of parking it somewhere the member did not choose.
  ADD COLUMN "unallocated_product_id"   INTEGER REFERENCES "savings_product"("id");
