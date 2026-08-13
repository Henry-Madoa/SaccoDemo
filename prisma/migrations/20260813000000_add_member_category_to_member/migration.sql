-- AlterTable
ALTER TABLE "member" ADD COLUMN "member_category_id" INTEGER;

-- CreateIndex
CREATE INDEX "ix_member_category" ON "member"("member_category_id");

-- AddForeignKey
ALTER TABLE "member" ADD CONSTRAINT "member_member_category_id_fkey" FOREIGN KEY ("member_category_id") REFERENCES "member_category"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;
