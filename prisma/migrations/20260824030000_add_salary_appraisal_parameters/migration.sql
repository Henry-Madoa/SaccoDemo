-- AlterTable
ALTER TABLE "loan_product" ADD COLUMN "salary_based" INTEGER NOT NULL DEFAULT 0;

-- CreateTable
CREATE TABLE "salary_appraisal_parameter" (
    "id" SERIAL NOT NULL,
    "code" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "type" TEXT NOT NULL,
    "special_type" TEXT NOT NULL DEFAULT 'NONE',
    "sort_order" INTEGER NOT NULL DEFAULT 0,
    "status" TEXT NOT NULL DEFAULT 'ACTIVE',

    CONSTRAINT "salary_appraisal_parameter_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "loan_salary_appraisal_line" (
    "id" SERIAL NOT NULL,
    "loan_id" INTEGER NOT NULL,
    "parameter_id" INTEGER,
    "code" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "type" TEXT NOT NULL,
    "special_type" TEXT NOT NULL DEFAULT 'NONE',
    "amount" BIGINT NOT NULL DEFAULT 0,
    "editable" BOOLEAN NOT NULL DEFAULT true,

    CONSTRAINT "loan_salary_appraisal_line_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "salary_appraisal_parameter_code_key" ON "salary_appraisal_parameter"("code");

-- CreateIndex
CREATE INDEX "ix_lsal_loan" ON "loan_salary_appraisal_line"("loan_id");

-- CreateIndex
CREATE UNIQUE INDEX "loan_salary_appraisal_line_loan_id_code_key" ON "loan_salary_appraisal_line"("loan_id", "code");

-- AddForeignKey
ALTER TABLE "loan_salary_appraisal_line" ADD CONSTRAINT "loan_salary_appraisal_line_loan_id_fkey" FOREIGN KEY ("loan_id") REFERENCES "loan"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "loan_salary_appraisal_line" ADD CONSTRAINT "loan_salary_appraisal_line_parameter_id_fkey" FOREIGN KEY ("parameter_id") REFERENCES "salary_appraisal_parameter"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;
