-- AlterTable
ALTER TABLE "organisation" ADD COLUMN "member_exit_notice_days" INTEGER DEFAULT 30;

-- CreateTable
CREATE TABLE "member_exit" (
    "no" TEXT NOT NULL,
    "member_id" INTEGER NOT NULL,
    "exit_type" TEXT NOT NULL DEFAULT 'GENERAL',
    "payout_method" TEXT NOT NULL DEFAULT 'FOSA',
    "reason" TEXT,
    "transaction_charge_id" INTEGER,
    "exit_date" TEXT,
    "maturity_date" TEXT,
    "net_amount" BIGINT NOT NULL DEFAULT 0,
    "status" TEXT NOT NULL DEFAULT 'Open',
    "decision_reason" TEXT,
    "processed_at" TEXT,
    "processed_by" TEXT,
    "created_at" TEXT,
    "created_by" TEXT,

    CONSTRAINT "member_exit_pkey" PRIMARY KEY ("no")
);

-- CreateTable
CREATE TABLE "member_exit_line" (
    "id" SERIAL NOT NULL,
    "exit_no" TEXT NOT NULL,
    "entry_type" TEXT NOT NULL,
    "savings_account_id" INTEGER,
    "loan_id" INTEGER,
    "account_name" TEXT,
    "balance" BIGINT NOT NULL DEFAULT 0,
    "amount" BIGINT NOT NULL DEFAULT 0,
    "is_share_capital" BOOLEAN NOT NULL DEFAULT false,

    CONSTRAINT "member_exit_line_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "ix_mex_member" ON "member_exit"("member_id");

-- CreateIndex
CREATE INDEX "ix_mex_status" ON "member_exit"("status");

-- CreateIndex
CREATE INDEX "ix_mexl_exit" ON "member_exit_line"("exit_no");

-- AddForeignKey
ALTER TABLE "member_exit" ADD CONSTRAINT "member_exit_member_id_fkey" FOREIGN KEY ("member_id") REFERENCES "member"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "member_exit" ADD CONSTRAINT "member_exit_transaction_charge_id_fkey" FOREIGN KEY ("transaction_charge_id") REFERENCES "transaction_charge"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "member_exit_line" ADD CONSTRAINT "member_exit_line_exit_no_fkey" FOREIGN KEY ("exit_no") REFERENCES "member_exit"("no") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "member_exit_line" ADD CONSTRAINT "member_exit_line_savings_account_id_fkey" FOREIGN KEY ("savings_account_id") REFERENCES "savings_account"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "member_exit_line" ADD CONSTRAINT "member_exit_line_loan_id_fkey" FOREIGN KEY ("loan_id") REFERENCES "loan"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- No. Series: reuses the app's existing sequence-table mechanism (see lib/db.ts nextSequence)
INSERT INTO "sequence" ("name", "prefix", "next_no", "width") VALUES ('MEMBER_EXIT', 'MEXT', 1, 6)
ON CONFLICT ("name") DO NOTHING;
