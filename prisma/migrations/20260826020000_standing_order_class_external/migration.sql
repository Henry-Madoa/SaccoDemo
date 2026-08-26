-- Rename: standing_order_class's 'LOAN_REPAYMENT' value becomes 'LOAN' — a plain rename, no
-- behaviour change, made room for the new 'EXTERNAL' value alongside it.
UPDATE "standing_order" SET "standing_order_class" = 'LOAN' WHERE "standing_order_class" = 'LOAN_REPAYMENT';

-- AlterTable: standing_order's own Bank/Cashbook destination for an EXTERNAL-class order — the
-- same Payment Channel concept lib/loanService.ts's disburse() already uses for a bank payout.
ALTER TABLE "standing_order" ADD COLUMN "destination_bank_account_id" INTEGER;

-- AlterTable: transaction_recovery's own per-class filter for a STANDING_ORDER recovery — lets
-- an admin configure a separate priority per Standing Order Class for the same sto_type by
-- adding one recovery row per class.
ALTER TABLE "transaction_recovery" ADD COLUMN "standing_order_class" TEXT;

-- AddForeignKey
ALTER TABLE "standing_order" ADD CONSTRAINT "standing_order_destination_bank_account_id_fkey" FOREIGN KEY ("destination_bank_account_id") REFERENCES "bank_account"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;
