-- AlterTable: a replacement can now be a GUARANTOR (existing), COLLATERAL, or FIXED_DEPOSIT —
-- AL's Det. Lines Security Type. replacement_member_id becomes optional; the two new columns are
-- each set only for their own type.
ALTER TABLE "loan_guarantor_change_replacement" ADD COLUMN "replacement_type" TEXT NOT NULL DEFAULT 'GUARANTOR';
ALTER TABLE "loan_guarantor_change_replacement" ALTER COLUMN "replacement_member_id" DROP NOT NULL;
ALTER TABLE "loan_guarantor_change_replacement" ADD COLUMN "replacement_collateral_no" TEXT;
ALTER TABLE "loan_guarantor_change_replacement" ADD COLUMN "replacement_fd_no" TEXT;

-- CreateIndex
CREATE INDEX "ix_lgcr_collateral" ON "loan_guarantor_change_replacement"("replacement_collateral_no");
CREATE INDEX "ix_lgcr_fd" ON "loan_guarantor_change_replacement"("replacement_fd_no");

-- AddForeignKey
ALTER TABLE "loan_guarantor_change_replacement" ADD CONSTRAINT "loan_guarantor_change_replacement_replacement_collateral_no_fkey" FOREIGN KEY ("replacement_collateral_no") REFERENCES "collateral_register"("no") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "loan_guarantor_change_replacement" ADD CONSTRAINT "loan_guarantor_change_replacement_replacement_fd_no_fkey" FOREIGN KEY ("replacement_fd_no") REFERENCES "member_fixed_deposit"("no") ON DELETE NO ACTION ON UPDATE NO ACTION;
