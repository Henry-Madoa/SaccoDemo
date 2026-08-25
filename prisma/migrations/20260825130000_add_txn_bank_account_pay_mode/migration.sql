-- AlterTable: a loan disbursement/repayment paid out or received through a real Bank/Cashbook
-- account now records which one, and how (Pay Mode), instead of only the generic `channel` label.
ALTER TABLE "txn" ADD COLUMN "bank_account_id" INTEGER;
ALTER TABLE "txn" ADD COLUMN "pay_mode" TEXT;
ALTER TABLE "txn" ADD COLUMN "cheque_no" TEXT;
ALTER TABLE "txn" ADD COLUMN "cheque_date" TEXT;
ALTER TABLE "txn" ADD COLUMN "reference_no" TEXT;

-- CreateIndex
CREATE INDEX "ix_txn_bank_account" ON "txn"("bank_account_id");

-- AddForeignKey
ALTER TABLE "txn" ADD CONSTRAINT "txn_bank_account_id_fkey" FOREIGN KEY ("bank_account_id") REFERENCES "bank_account"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;
