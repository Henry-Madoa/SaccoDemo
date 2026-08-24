-- CreateTable
CREATE TABLE "loan_appraisal" (
    "id" SERIAL NOT NULL,
    "loan_id" INTEGER NOT NULL,
    "decision" TEXT NOT NULL,
    "score" INTEGER NOT NULL,
    "installment" BIGINT NOT NULL DEFAULT 0,
    "deposits" BIGINT NOT NULL DEFAULT 0,
    "exposure" BIGINT NOT NULL DEFAULT 0,
    "max_by_multiplier" BIGINT NOT NULL DEFAULT 0,
    "dsr" DOUBLE PRECISION NOT NULL DEFAULT 0,
    "monthly_obligations" BIGINT NOT NULL DEFAULT 0,
    "appraised_by" TEXT,
    "appraised_at" TEXT,

    CONSTRAINT "loan_appraisal_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "loan_appraisal_factor" (
    "id" SERIAL NOT NULL,
    "appraisal_id" INTEGER NOT NULL,
    "seq" INTEGER NOT NULL DEFAULT 0,
    "code" TEXT NOT NULL,
    "label" TEXT NOT NULL,
    "pass" BOOLEAN NOT NULL,
    "detail" TEXT,

    CONSTRAINT "loan_appraisal_factor_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "ix_lap_loan" ON "loan_appraisal"("loan_id");

-- CreateIndex
CREATE INDEX "ix_lapf_appraisal" ON "loan_appraisal_factor"("appraisal_id");

-- AddForeignKey
ALTER TABLE "loan_appraisal" ADD CONSTRAINT "loan_appraisal_loan_id_fkey" FOREIGN KEY ("loan_id") REFERENCES "loan"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "loan_appraisal_factor" ADD CONSTRAINT "loan_appraisal_factor_appraisal_id_fkey" FOREIGN KEY ("appraisal_id") REFERENCES "loan_appraisal"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;
