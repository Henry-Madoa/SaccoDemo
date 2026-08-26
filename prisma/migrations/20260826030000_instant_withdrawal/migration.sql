-- Instant Withdrawal: admin-configured default charge + per-exit flag
ALTER TABLE "organisation" ADD COLUMN "instant_withdrawal_charge_id" INTEGER;
ALTER TABLE "organisation" ADD CONSTRAINT "organisation_instant_withdrawal_charge_id_fkey"
  FOREIGN KEY ("instant_withdrawal_charge_id") REFERENCES "transaction_charge"("id")
  ON DELETE NO ACTION ON UPDATE NO ACTION;

ALTER TABLE "member_exit" ADD COLUMN "is_instant" BOOLEAN NOT NULL DEFAULT false;
