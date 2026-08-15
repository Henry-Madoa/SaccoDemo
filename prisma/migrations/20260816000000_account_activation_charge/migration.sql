-- Account Activation now carries its own reactivation-fee Charge Code (a picked
-- transaction_charge, not the type-wide auto-resolve) and the savings account it's debited
-- from, so relax the one-charge-per-type constraint to let more than one Transaction Charge be
-- configured for ACCOUNT_ACTIVATION and let the request pick which applies.
DROP INDEX IF EXISTS "transaction_charge_transaction_type_key";
CREATE INDEX "ix_tc_type" ON "transaction_charge"("transaction_type");

-- AlterTable
ALTER TABLE "account_activation_request" ADD COLUMN "transaction_charge_id" INTEGER;
ALTER TABLE "account_activation_request" ADD COLUMN "debit_account_id" INTEGER;

-- AddForeignKey
ALTER TABLE "account_activation_request" ADD CONSTRAINT "account_activation_request_debit_account_id_fkey" FOREIGN KEY ("debit_account_id") REFERENCES "savings_account"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE "account_activation_request" ADD CONSTRAINT "account_activation_request_transaction_charge_id_fkey" FOREIGN KEY ("transaction_charge_id") REFERENCES "transaction_charge"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;
