-- The posted copy has to remember which Payment Type it was raised under: the printed voucher
-- varies by type (a member payment shows the member and the account drawn on, a supplier payment
-- shows the vendor and the tax split), and a reprint years later must still show the right one.
ALTER TABLE "posted_payment_voucher" ADD COLUMN "pv_type" TEXT;

UPDATE "posted_payment_voucher" p SET "pv_type" = COALESCE(
  (SELECT h."pv_type" FROM "payment_voucher_header" h WHERE h."no" = p."pv_no"), 'Direct Expensing')
WHERE p."pv_type" IS NULL;
