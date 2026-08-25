-- AlterTable
ALTER TABLE "loan_calculator" ADD COLUMN "status" TEXT NOT NULL DEFAULT 'Open';
ALTER TABLE "loan_calculator" ADD COLUMN "converted_loan_id" INTEGER;
ALTER TABLE "loan_calculator" ADD COLUMN "converted_at" TEXT;
ALTER TABLE "loan_calculator" ADD COLUMN "converted_by" TEXT;

-- CreateIndex
CREATE INDEX "ix_lc_status" ON "loan_calculator"("status");

-- AddForeignKey
ALTER TABLE "loan_calculator" ADD CONSTRAINT "loan_calculator_converted_loan_id_fkey" FOREIGN KEY ("converted_loan_id") REFERENCES "loan"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;
