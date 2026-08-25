-- CreateTable
CREATE TABLE "standing_order" (
    "no" TEXT NOT NULL,
    "member_id" INTEGER NOT NULL,
    "account_id" INTEGER NOT NULL,
    "standing_order_class" TEXT NOT NULL,
    "amount_type" TEXT NOT NULL DEFAULT 'FIXED',
    "amount" BIGINT NOT NULL DEFAULT 0,
    "amount_limit" BIGINT NOT NULL DEFAULT 0,
    "destination_member_id" INTEGER,
    "destination_account_id" INTEGER,
    "destination_loan_id" INTEGER,
    "posting_description" TEXT,
    "run_type" TEXT NOT NULL DEFAULT 'DAILY',
    "run_from_day" INTEGER,
    "start_date" TEXT NOT NULL,
    "till_further_notice" BOOLEAN NOT NULL DEFAULT false,
    "period_months" INTEGER,
    "end_date" TEXT,
    "transaction_charge_id" INTEGER,
    "status" TEXT NOT NULL DEFAULT 'Open',
    "decision_reason" TEXT,
    "running" BOOLEAN NOT NULL DEFAULT false,
    "terminated" BOOLEAN NOT NULL DEFAULT false,
    "freezed" BOOLEAN NOT NULL DEFAULT false,
    "freeze_end_date" TEXT,
    "last_run_date" TEXT,
    "created_at" TEXT,
    "created_by" TEXT,

    CONSTRAINT "standing_order_pkey" PRIMARY KEY ("no")
);

-- CreateIndex
CREATE INDEX "ix_sto_member" ON "standing_order"("member_id");

-- CreateIndex
CREATE INDEX "ix_sto_status" ON "standing_order"("status");

-- CreateIndex
CREATE INDEX "ix_sto_running" ON "standing_order"("running", "terminated");

-- AddForeignKey
ALTER TABLE "standing_order" ADD CONSTRAINT "standing_order_member_id_fkey" FOREIGN KEY ("member_id") REFERENCES "member"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "standing_order" ADD CONSTRAINT "standing_order_destination_member_id_fkey" FOREIGN KEY ("destination_member_id") REFERENCES "member"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "standing_order" ADD CONSTRAINT "standing_order_account_id_fkey" FOREIGN KEY ("account_id") REFERENCES "savings_account"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "standing_order" ADD CONSTRAINT "standing_order_destination_account_id_fkey" FOREIGN KEY ("destination_account_id") REFERENCES "savings_account"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "standing_order" ADD CONSTRAINT "standing_order_destination_loan_id_fkey" FOREIGN KEY ("destination_loan_id") REFERENCES "loan"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "standing_order" ADD CONSTRAINT "standing_order_transaction_charge_id_fkey" FOREIGN KEY ("transaction_charge_id") REFERENCES "transaction_charge"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- Standing Order's own No. series, seeded in-migration the same way
-- 20260815050000_add_account_activation_request seeds ACCOUNT_ACTIVATION's.
INSERT INTO "sequence" ("name", "prefix", "next_no", "width") VALUES ('STANDING_ORDER', 'STO', 1, 6);
