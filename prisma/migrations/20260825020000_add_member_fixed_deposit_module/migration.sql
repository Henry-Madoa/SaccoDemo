-- CreateTable
CREATE TABLE "member_fixed_deposit_type" (
    "id" SERIAL NOT NULL,
    "code" TEXT NOT NULL,
    "description" TEXT NOT NULL,
    "min_interest_rate" DOUBLE PRECISION NOT NULL DEFAULT 0,
    "max_interest_rate" DOUBLE PRECISION NOT NULL DEFAULT 0,
    "interest_calc_type" TEXT NOT NULL DEFAULT 'FLAT',
    "linked_product_id" INTEGER NOT NULL,
    "interest_expense_gl_id" INTEGER NOT NULL,
    "interest_payable_gl_id" INTEGER NOT NULL,
    "withholding_tax_rate" DOUBLE PRECISION NOT NULL DEFAULT 0,
    "withholding_tax_gl_id" INTEGER,
    "status" TEXT NOT NULL DEFAULT 'ACTIVE',

    CONSTRAINT "member_fixed_deposit_type_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "member_fixed_deposit_type_code_key" ON "member_fixed_deposit_type"("code");

-- AddForeignKey
ALTER TABLE "member_fixed_deposit_type" ADD CONSTRAINT "member_fixed_deposit_type_linked_product_id_fkey" FOREIGN KEY ("linked_product_id") REFERENCES "savings_product"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "member_fixed_deposit_type" ADD CONSTRAINT "member_fixed_deposit_type_interest_expense_gl_id_fkey" FOREIGN KEY ("interest_expense_gl_id") REFERENCES "gl_account"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "member_fixed_deposit_type" ADD CONSTRAINT "member_fixed_deposit_type_interest_payable_gl_id_fkey" FOREIGN KEY ("interest_payable_gl_id") REFERENCES "gl_account"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "member_fixed_deposit_type" ADD CONSTRAINT "member_fixed_deposit_type_withholding_tax_gl_id_fkey" FOREIGN KEY ("withholding_tax_gl_id") REFERENCES "gl_account"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- CreateTable
CREATE TABLE "member_fixed_deposit" (
    "no" TEXT NOT NULL,
    "member_id" INTEGER NOT NULL,
    "fd_type_id" INTEGER NOT NULL,
    "rate" DOUBLE PRECISION NOT NULL,
    "maturity_instructions" TEXT NOT NULL DEFAULT 'LIQUIDATE',
    "amount" BIGINT NOT NULL,
    "source_account_id" INTEGER NOT NULL,
    "fd_account_id" INTEGER,
    "start_date" TEXT NOT NULL,
    "term_months" INTEGER NOT NULL,
    "end_date" TEXT NOT NULL,
    "status" TEXT NOT NULL DEFAULT 'Open',
    "decision_reason" TEXT,
    "rolled_from_no" TEXT,
    "rolled_to_no" TEXT,
    "created_at" TEXT,
    "created_by" TEXT,
    "activated_at" TEXT,
    "activated_by" TEXT,
    "processed_at" TEXT,
    "processed_by" TEXT,

    CONSTRAINT "member_fixed_deposit_pkey" PRIMARY KEY ("no")
);

-- CreateIndex
CREATE INDEX "ix_mfd_member" ON "member_fixed_deposit"("member_id");

-- CreateIndex
CREATE INDEX "ix_mfd_status" ON "member_fixed_deposit"("status");

-- AddForeignKey
ALTER TABLE "member_fixed_deposit" ADD CONSTRAINT "member_fixed_deposit_member_id_fkey" FOREIGN KEY ("member_id") REFERENCES "member"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "member_fixed_deposit" ADD CONSTRAINT "member_fixed_deposit_fd_type_id_fkey" FOREIGN KEY ("fd_type_id") REFERENCES "member_fixed_deposit_type"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "member_fixed_deposit" ADD CONSTRAINT "member_fixed_deposit_source_account_id_fkey" FOREIGN KEY ("source_account_id") REFERENCES "savings_account"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "member_fixed_deposit" ADD CONSTRAINT "member_fixed_deposit_fd_account_id_fkey" FOREIGN KEY ("fd_account_id") REFERENCES "savings_account"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- CreateTable
CREATE TABLE "member_fixed_deposit_schedule" (
    "id" SERIAL NOT NULL,
    "fd_no" TEXT NOT NULL,
    "posting_date" TEXT NOT NULL,
    "description" TEXT,
    "amount" BIGINT NOT NULL DEFAULT 0,
    "transferred" BOOLEAN NOT NULL DEFAULT false,

    CONSTRAINT "member_fixed_deposit_schedule_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "ix_mfds_fd_no" ON "member_fixed_deposit_schedule"("fd_no");

-- AddForeignKey
ALTER TABLE "member_fixed_deposit_schedule" ADD CONSTRAINT "member_fixed_deposit_schedule_fd_no_fkey" FOREIGN KEY ("fd_no") REFERENCES "member_fixed_deposit"("no") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- CreateTable
CREATE TABLE "loan_fd_lien" (
    "id" SERIAL NOT NULL,
    "loan_id" INTEGER NOT NULL,
    "fd_no" TEXT NOT NULL,
    "guarantee" BIGINT NOT NULL,
    "status" TEXT NOT NULL DEFAULT 'ACTIVE',
    "created_at" TEXT,
    "created_by" TEXT,

    CONSTRAINT "loan_fd_lien_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "loan_fd_lien_loan_id_fd_no_key" ON "loan_fd_lien"("loan_id", "fd_no");

-- CreateIndex
CREATE INDEX "ix_lfl_fd_no" ON "loan_fd_lien"("fd_no");

-- AddForeignKey
ALTER TABLE "loan_fd_lien" ADD CONSTRAINT "loan_fd_lien_loan_id_fkey" FOREIGN KEY ("loan_id") REFERENCES "loan"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "loan_fd_lien" ADD CONSTRAINT "loan_fd_lien_fd_no_fkey" FOREIGN KEY ("fd_no") REFERENCES "member_fixed_deposit"("no") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- No. Series: reuses the app's existing sequence-table mechanism (see lib/db.ts nextSequence)
INSERT INTO "sequence" ("name", "prefix", "next_no", "width") VALUES ('FIXED_DEPOSIT', 'FD', 1, 6)
ON CONFLICT ("name") DO NOTHING;
