-- CreateTable
CREATE TABLE "global_dimension_1_value" (
    "id" SERIAL NOT NULL,
    "code" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "status" TEXT NOT NULL DEFAULT 'ACTIVE',

    CONSTRAINT "global_dimension_1_value_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "global_dimension_2_value" (
    "id" SERIAL NOT NULL,
    "code" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "status" TEXT NOT NULL DEFAULT 'ACTIVE',

    CONSTRAINT "global_dimension_2_value_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "global_dimension_1_value_code_key" ON "global_dimension_1_value"("code");

-- CreateIndex
CREATE UNIQUE INDEX "global_dimension_1_value_name_key" ON "global_dimension_1_value"("name");

-- CreateIndex
CREATE UNIQUE INDEX "global_dimension_2_value_code_key" ON "global_dimension_2_value"("code");

-- CreateIndex
CREATE UNIQUE INDEX "global_dimension_2_value_name_key" ON "global_dimension_2_value"("name");

-- AlterTable: organisation captions (Business-Central-style renameable field labels)
ALTER TABLE "organisation" ADD COLUMN "global_dimension_1_caption" TEXT DEFAULT 'Global Dimension 1 Code';
ALTER TABLE "organisation" ADD COLUMN "global_dimension_2_caption" TEXT DEFAULT 'Global Dimension 2 Code';

-- AlterTable: member
ALTER TABLE "member" ADD COLUMN "global_dimension_1_id" INTEGER;
ALTER TABLE "member" ADD COLUMN "global_dimension_2_id" INTEGER;

-- CreateIndex
CREATE INDEX "ix_member_gd1" ON "member"("global_dimension_1_id");
CREATE INDEX "ix_member_gd2" ON "member"("global_dimension_2_id");

-- AddForeignKey
ALTER TABLE "member" ADD CONSTRAINT "member_global_dimension_1_id_fkey" FOREIGN KEY ("global_dimension_1_id") REFERENCES "global_dimension_1_value"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE "member" ADD CONSTRAINT "member_global_dimension_2_id_fkey" FOREIGN KEY ("global_dimension_2_id") REFERENCES "global_dimension_2_value"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AlterTable: member_application
ALTER TABLE "member_application" ADD COLUMN "global_dimension_1_id" INTEGER;
ALTER TABLE "member_application" ADD COLUMN "global_dimension_2_id" INTEGER;

-- CreateIndex
CREATE INDEX "ix_app_gd1" ON "member_application"("global_dimension_1_id");
CREATE INDEX "ix_app_gd2" ON "member_application"("global_dimension_2_id");

-- AddForeignKey
ALTER TABLE "member_application" ADD CONSTRAINT "member_application_global_dimension_1_id_fkey" FOREIGN KEY ("global_dimension_1_id") REFERENCES "global_dimension_1_value"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE "member_application" ADD CONSTRAINT "member_application_global_dimension_2_id_fkey" FOREIGN KEY ("global_dimension_2_id") REFERENCES "global_dimension_2_value"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AlterTable: journal (header default)
ALTER TABLE "journal" ADD COLUMN "global_dimension_1_id" INTEGER;
ALTER TABLE "journal" ADD COLUMN "global_dimension_2_id" INTEGER;

-- CreateIndex
CREATE INDEX "ix_journal_gd1" ON "journal"("global_dimension_1_id");
CREATE INDEX "ix_journal_gd2" ON "journal"("global_dimension_2_id");

-- AddForeignKey
ALTER TABLE "journal" ADD CONSTRAINT "journal_global_dimension_1_id_fkey" FOREIGN KEY ("global_dimension_1_id") REFERENCES "global_dimension_1_value"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE "journal" ADD CONSTRAINT "journal_global_dimension_2_id_fkey" FOREIGN KEY ("global_dimension_2_id") REFERENCES "global_dimension_2_value"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AlterTable: journal_line (the posted GL entry)
ALTER TABLE "journal_line" ADD COLUMN "global_dimension_1_id" INTEGER;
ALTER TABLE "journal_line" ADD COLUMN "global_dimension_2_id" INTEGER;

-- CreateIndex
CREATE INDEX "ix_jl_gd1" ON "journal_line"("global_dimension_1_id");
CREATE INDEX "ix_jl_gd2" ON "journal_line"("global_dimension_2_id");

-- AddForeignKey
ALTER TABLE "journal_line" ADD CONSTRAINT "journal_line_global_dimension_1_id_fkey" FOREIGN KEY ("global_dimension_1_id") REFERENCES "global_dimension_1_value"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE "journal_line" ADD CONSTRAINT "journal_line_global_dimension_2_id_fkey" FOREIGN KEY ("global_dimension_2_id") REFERENCES "global_dimension_2_value"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;
