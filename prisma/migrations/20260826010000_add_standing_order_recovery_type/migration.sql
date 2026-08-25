-- AlterTable: standing_order gains the two fields that let it be recovered through Checkoff &
-- Salary Processing's own Calculate step instead of (or as well as, if never tagged) the ordinary
-- daily Standing Order Run job.
ALTER TABLE "standing_order" ADD COLUMN "salary_based" BOOLEAN NOT NULL DEFAULT false;
ALTER TABLE "standing_order" ADD COLUMN "sto_type" TEXT;

-- AlterTable: transaction_recovery gains STANDING_ORDER's own "Recovery Code" equivalent, and
-- deduction_type becomes optional since STANDING_ORDER doesn't use it (a standing order's own
-- Amount Type already decides how much it recovers).
ALTER TABLE "transaction_recovery" ADD COLUMN "sto_type" TEXT;
ALTER TABLE "transaction_recovery" ALTER COLUMN "deduction_type" DROP NOT NULL;

-- AlterTable: checkoff_calculation gains the standing order reference a STANDING_ORDER entry
-- posts from at process time.
ALTER TABLE "checkoff_calculation" ADD COLUMN "standing_order_no" TEXT;

-- CreateIndex
CREATE INDEX "ix_cocalc_sto" ON "checkoff_calculation"("standing_order_no");

-- AddForeignKey
ALTER TABLE "checkoff_calculation" ADD CONSTRAINT "checkoff_calculation_standing_order_no_fkey" FOREIGN KEY ("standing_order_no") REFERENCES "standing_order"("no") ON DELETE NO ACTION ON UPDATE NO ACTION;
