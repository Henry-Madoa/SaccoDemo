-- AlterTable
ALTER TABLE "account_activation_request" ADD COLUMN     "journal_id" INTEGER;

-- AlterTable
ALTER TABLE "gl_account" ADD COLUMN     "no_direct_posting" INTEGER NOT NULL DEFAULT 0;

-- CreateTable
CREATE TABLE "bank_account" (
    "id" SERIAL NOT NULL,
    "code" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "gl_account_id" INTEGER NOT NULL,
    "bank_name" TEXT,
    "account_no" TEXT,
    "balance" BIGINT NOT NULL DEFAULT 0,
    "status" TEXT NOT NULL DEFAULT 'ACTIVE',
    "created_at" TEXT,

    CONSTRAINT "bank_account_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "bank_account_ledger_entry" (
    "id" SERIAL NOT NULL,
    "bank_account_id" INTEGER NOT NULL,
    "journal_id" INTEGER NOT NULL,
    "journal_line_id" INTEGER NOT NULL,
    "posting_date" TEXT NOT NULL,
    "description" TEXT,
    "amount" BIGINT NOT NULL,
    "running_balance" BIGINT NOT NULL,
    "reconciled" INTEGER NOT NULL DEFAULT 0,
    "bank_reconciliation_id" INTEGER,
    "created_at" TEXT,

    CONSTRAINT "bank_account_ledger_entry_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "bank_reconciliation" (
    "id" SERIAL NOT NULL,
    "bank_account_id" INTEGER NOT NULL,
    "statement_date" TEXT NOT NULL,
    "statement_balance" BIGINT NOT NULL,
    "status" TEXT NOT NULL DEFAULT 'OPEN',
    "created_by" TEXT,
    "created_at" TEXT,
    "completed_by" TEXT,
    "completed_at" TEXT,

    CONSTRAINT "bank_reconciliation_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "bank_account_code_key" ON "bank_account"("code");

-- CreateIndex
CREATE UNIQUE INDEX "bank_account_gl_account_id_key" ON "bank_account"("gl_account_id");

-- CreateIndex
CREATE INDEX "ix_bale_account" ON "bank_account_ledger_entry"("bank_account_id");

-- CreateIndex
CREATE INDEX "ix_bale_journal" ON "bank_account_ledger_entry"("journal_id");

-- CreateIndex
CREATE INDEX "ix_bale_reconciliation" ON "bank_account_ledger_entry"("bank_reconciliation_id");

-- CreateIndex
CREATE INDEX "ix_brec_account" ON "bank_reconciliation"("bank_account_id");

-- AddForeignKey
ALTER TABLE "bank_account" ADD CONSTRAINT "bank_account_gl_account_id_fkey" FOREIGN KEY ("gl_account_id") REFERENCES "gl_account"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "bank_account_ledger_entry" ADD CONSTRAINT "bank_account_ledger_entry_bank_account_id_fkey" FOREIGN KEY ("bank_account_id") REFERENCES "bank_account"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "bank_account_ledger_entry" ADD CONSTRAINT "bank_account_ledger_entry_journal_id_fkey" FOREIGN KEY ("journal_id") REFERENCES "journal"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "bank_account_ledger_entry" ADD CONSTRAINT "bank_account_ledger_entry_journal_line_id_fkey" FOREIGN KEY ("journal_line_id") REFERENCES "journal_line"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "bank_account_ledger_entry" ADD CONSTRAINT "bank_account_ledger_entry_bank_reconciliation_id_fkey" FOREIGN KEY ("bank_reconciliation_id") REFERENCES "bank_reconciliation"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "bank_reconciliation" ADD CONSTRAINT "bank_reconciliation_bank_account_id_fkey" FOREIGN KEY ("bank_account_id") REFERENCES "bank_account"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "account_activation_request" ADD CONSTRAINT "account_activation_request_journal_id_fkey" FOREIGN KEY ("journal_id") REFERENCES "journal"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;
