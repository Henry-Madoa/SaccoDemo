-- CreateTable
CREATE TABLE "employer" (
    "id" SERIAL NOT NULL,
    "code" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "phone" TEXT,
    "email" TEXT,
    "payroll_no_mandatory" BOOLEAN NOT NULL DEFAULT false,
    "status" TEXT NOT NULL DEFAULT 'ACTIVE',

    CONSTRAINT "employer_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "employer_code_key" ON "employer"("code");

-- AlterTable
ALTER TABLE "member" ADD COLUMN "employer_id" INTEGER;

-- CreateIndex
CREATE INDEX "ix_member_employer" ON "member"("employer_id");

-- AddForeignKey
ALTER TABLE "member" ADD CONSTRAINT "member_employer_id_fkey" FOREIGN KEY ("employer_id") REFERENCES "employer"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AlterTable
ALTER TABLE "loan" ADD COLUMN "recovery_mode" TEXT NOT NULL DEFAULT 'DIRECT';

-- CreateIndex
CREATE INDEX "ix_loan_recovery_mode" ON "loan"("recovery_mode");

-- CreateTable
CREATE TABLE "checkoff_batch" (
    "no" TEXT NOT NULL,
    "batch_type" TEXT NOT NULL,
    "employer_id" INTEGER NOT NULL,
    "period" TEXT NOT NULL,
    "posting_date" TEXT,
    "description" TEXT,
    "status" TEXT NOT NULL DEFAULT 'Open',
    "decision_reason" TEXT,
    "processed_at" TEXT,
    "processed_by" TEXT,
    "created_at" TEXT,
    "created_by" TEXT,

    CONSTRAINT "checkoff_batch_pkey" PRIMARY KEY ("no")
);

-- CreateIndex
CREATE INDEX "ix_cob_employer" ON "checkoff_batch"("employer_id");

-- CreateIndex
CREATE INDEX "ix_cob_status" ON "checkoff_batch"("status");

-- AddForeignKey
ALTER TABLE "checkoff_batch" ADD CONSTRAINT "checkoff_batch_employer_id_fkey" FOREIGN KEY ("employer_id") REFERENCES "employer"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- CreateTable
CREATE TABLE "checkoff_batch_line" (
    "id" SERIAL NOT NULL,
    "batch_no" TEXT NOT NULL,
    "member_id" INTEGER NOT NULL,
    "payroll_no" TEXT,
    "expected_amount" BIGINT NOT NULL DEFAULT 0,
    "remitted_amount" BIGINT NOT NULL DEFAULT 0,
    "variance" BIGINT NOT NULL DEFAULT 0,

    CONSTRAINT "checkoff_batch_line_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "ux_cobl_batch_member" ON "checkoff_batch_line"("batch_no", "member_id");

-- AddForeignKey
ALTER TABLE "checkoff_batch_line" ADD CONSTRAINT "checkoff_batch_line_batch_no_fkey" FOREIGN KEY ("batch_no") REFERENCES "checkoff_batch"("no") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "checkoff_batch_line" ADD CONSTRAINT "checkoff_batch_line_member_id_fkey" FOREIGN KEY ("member_id") REFERENCES "member"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- No. Series: reuses the app's existing sequence-table mechanism (see lib/db.ts nextSequence)
INSERT INTO "sequence" ("name", "prefix", "next_no", "width") VALUES ('CHECKOFF_BATCH', 'CKO', 1, 6)
ON CONFLICT ("name") DO NOTHING;
