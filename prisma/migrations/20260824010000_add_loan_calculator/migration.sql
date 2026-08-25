-- CreateTable
CREATE TABLE "loan_calculator" (
    "id" SERIAL NOT NULL,
    "calc_no" TEXT NOT NULL,
    "member_id" INTEGER NOT NULL,
    "product_id" INTEGER NOT NULL,
    "principal" BIGINT NOT NULL DEFAULT 0,
    "interest_rate" DOUBLE PRECISION NOT NULL DEFAULT 0,
    "rate_type" TEXT NOT NULL DEFAULT 'AMORTISED',
    "term_months" INTEGER NOT NULL,
    "repayment_start_date" TEXT NOT NULL,
    "current_deposits" BIGINT NOT NULL DEFAULT 0,
    "deposit_multiplier_amount" BIGINT NOT NULL DEFAULT 0,
    "outstanding_loans" BIGINT NOT NULL DEFAULT 0,
    "deposit_appraisal" BIGINT NOT NULL DEFAULT 0,
    "installment" BIGINT NOT NULL DEFAULT 0,
    "total_interest" BIGINT NOT NULL DEFAULT 0,
    "created_at" TEXT,
    "created_by" TEXT,

    CONSTRAINT "loan_calculator_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "loan_calculator_line" (
    "id" SERIAL NOT NULL,
    "calculator_id" INTEGER NOT NULL,
    "installment_no" INTEGER NOT NULL,
    "due_date" TEXT NOT NULL,
    "opening_balance" BIGINT NOT NULL DEFAULT 0,
    "principal_due" BIGINT NOT NULL DEFAULT 0,
    "interest_due" BIGINT NOT NULL DEFAULT 0,
    "installment_amount" BIGINT NOT NULL DEFAULT 0,
    "closing_balance" BIGINT NOT NULL DEFAULT 0,

    CONSTRAINT "loan_calculator_line_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "loan_calculator_calc_no_key" ON "loan_calculator"("calc_no");

-- CreateIndex
CREATE INDEX "ix_lc_member" ON "loan_calculator"("member_id");

-- CreateIndex
CREATE INDEX "ix_lc_product" ON "loan_calculator"("product_id");

-- CreateIndex
CREATE INDEX "ix_lcl_calculator" ON "loan_calculator_line"("calculator_id", "installment_no");

-- AddForeignKey
ALTER TABLE "loan_calculator" ADD CONSTRAINT "loan_calculator_member_id_fkey" FOREIGN KEY ("member_id") REFERENCES "member"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "loan_calculator" ADD CONSTRAINT "loan_calculator_product_id_fkey" FOREIGN KEY ("product_id") REFERENCES "loan_product"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "loan_calculator_line" ADD CONSTRAINT "loan_calculator_line_calculator_id_fkey" FOREIGN KEY ("calculator_id") REFERENCES "loan_calculator"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- Sequence for the Loan Calculator's own No. series (Table 52204036's "No.", NoSeries "Calculator Nos").
INSERT INTO "sequence" ("name", "prefix", "next_no", "width") VALUES ('LOAN_CALCULATOR', 'LC', 1, 6);
