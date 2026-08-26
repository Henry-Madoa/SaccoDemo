-- CreateTable
CREATE TABLE "member_readmission_request" (
    "no" TEXT NOT NULL,
    "member_id" INTEGER NOT NULL,
    "reason" TEXT,
    "pay_from_account_type" TEXT NOT NULL DEFAULT 'MEMBER_ACCOUNT',
    "payment_reference" TEXT,
    "transaction_charge_id" INTEGER,
    "debit_account_id" INTEGER,
    "status" TEXT NOT NULL DEFAULT 'Open',
    "decision_reason" TEXT,
    "created_at" TEXT,
    "created_by" TEXT,
    "processed_at" TEXT,
    "processed_by" TEXT,
    "journal_id" INTEGER,

    CONSTRAINT "member_readmission_request_pkey" PRIMARY KEY ("no")
);

-- CreateIndex
CREATE INDEX "ix_mrr_member" ON "member_readmission_request"("member_id");

-- CreateIndex
CREATE INDEX "ix_mrr_status" ON "member_readmission_request"("status");

-- AddForeignKey
ALTER TABLE "member_readmission_request" ADD CONSTRAINT "member_readmission_request_member_id_fkey" FOREIGN KEY ("member_id") REFERENCES "member"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "member_readmission_request" ADD CONSTRAINT "member_readmission_request_debit_account_id_fkey" FOREIGN KEY ("debit_account_id") REFERENCES "savings_account"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "member_readmission_request" ADD CONSTRAINT "member_readmission_request_transaction_charge_id_fkey" FOREIGN KEY ("transaction_charge_id") REFERENCES "transaction_charge"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "member_readmission_request" ADD CONSTRAINT "member_readmission_request_journal_id_fkey" FOREIGN KEY ("journal_id") REFERENCES "journal"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;
