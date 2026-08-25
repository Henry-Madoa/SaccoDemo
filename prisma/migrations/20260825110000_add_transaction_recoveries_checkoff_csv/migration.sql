-- AlterTable: checkoff_batch gets a Charge Code (SALARY only) that Calculate applies against.
ALTER TABLE "checkoff_batch" ADD COLUMN "transaction_charge_id" INTEGER;

-- AlterTable: checkoff_batch_line gets CSV-upload tally columns.
ALTER TABLE "checkoff_batch_line" ADD COLUMN "uploaded_amount" BIGINT NOT NULL DEFAULT 0;
ALTER TABLE "checkoff_batch_line" ADD COLUMN "uploaded_name" TEXT;
ALTER TABLE "checkoff_batch_line" ADD COLUMN "matched" BOOLEAN NOT NULL DEFAULT true;

-- CreateTable
CREATE TABLE "transaction_recovery" (
    "id" SERIAL NOT NULL,
    "transaction_charge_id" INTEGER NOT NULL,
    "recovery_type" TEXT NOT NULL,
    "deduction_type" TEXT NOT NULL,
    "savings_product_id" INTEGER,
    "priority" INTEGER NOT NULL DEFAULT 1,
    "description" TEXT,
    "status" TEXT NOT NULL DEFAULT 'ACTIVE',

    CONSTRAINT "transaction_recovery_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "checkoff_calculation" (
    "id" SERIAL NOT NULL,
    "batch_no" TEXT NOT NULL,
    "line_id" INTEGER NOT NULL,
    "entry_type" TEXT NOT NULL,
    "description" TEXT NOT NULL,
    "loan_id" INTEGER,
    "savings_account_id" INTEGER,
    "gl_account_id" INTEGER,
    "amount" BIGINT NOT NULL DEFAULT 0,

    CONSTRAINT "checkoff_calculation_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "ix_trec_tc" ON "transaction_recovery"("transaction_charge_id");

-- CreateIndex
CREATE INDEX "ix_cocalc_batch" ON "checkoff_calculation"("batch_no");

-- CreateIndex
CREATE INDEX "ix_cocalc_line" ON "checkoff_calculation"("line_id");

-- AddForeignKey
ALTER TABLE "checkoff_batch" ADD CONSTRAINT "checkoff_batch_transaction_charge_id_fkey" FOREIGN KEY ("transaction_charge_id") REFERENCES "transaction_charge"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "transaction_recovery" ADD CONSTRAINT "transaction_recovery_transaction_charge_id_fkey" FOREIGN KEY ("transaction_charge_id") REFERENCES "transaction_charge"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "transaction_recovery" ADD CONSTRAINT "transaction_recovery_savings_product_id_fkey" FOREIGN KEY ("savings_product_id") REFERENCES "savings_product"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "checkoff_calculation" ADD CONSTRAINT "checkoff_calculation_batch_no_fkey" FOREIGN KEY ("batch_no") REFERENCES "checkoff_batch"("no") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "checkoff_calculation" ADD CONSTRAINT "checkoff_calculation_line_id_fkey" FOREIGN KEY ("line_id") REFERENCES "checkoff_batch_line"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;
