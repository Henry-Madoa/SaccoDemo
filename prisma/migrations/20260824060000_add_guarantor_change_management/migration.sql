-- CreateTable
CREATE TABLE "loan_guarantor_change" (
    "no" TEXT NOT NULL,
    "loan_id" INTEGER NOT NULL,
    "member_id" INTEGER NOT NULL,
    "status" TEXT NOT NULL DEFAULT 'Open',
    "decision_reason" TEXT,
    "processed_at" TEXT,
    "processed_by" TEXT,
    "created_at" TEXT,
    "created_by" TEXT,

    CONSTRAINT "loan_guarantor_change_pkey" PRIMARY KEY ("no")
);

-- CreateTable
CREATE TABLE "loan_guarantor_change_line" (
    "id" SERIAL NOT NULL,
    "change_no" TEXT NOT NULL,
    "guarantor_member_id" INTEGER NOT NULL,
    "initial_guaranteed" BIGINT NOT NULL DEFAULT 0,
    "outstanding_guaranteed" BIGINT NOT NULL DEFAULT 0,
    "release" BOOLEAN NOT NULL DEFAULT false,

    CONSTRAINT "loan_guarantor_change_line_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "loan_guarantor_change_replacement" (
    "id" SERIAL NOT NULL,
    "line_id" INTEGER NOT NULL,
    "replacement_member_id" INTEGER NOT NULL,
    "amount" BIGINT NOT NULL DEFAULT 0,

    CONSTRAINT "loan_guarantor_change_replacement_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "ix_lgc_loan" ON "loan_guarantor_change"("loan_id");

-- CreateIndex
CREATE INDEX "ix_lgc_status" ON "loan_guarantor_change"("status");

-- CreateIndex
CREATE UNIQUE INDEX "ux_lgcl_change_member" ON "loan_guarantor_change_line"("change_no", "guarantor_member_id");

-- CreateIndex
CREATE INDEX "ix_lgcl_change" ON "loan_guarantor_change_line"("change_no");

-- CreateIndex
CREATE INDEX "ix_lgcr_line" ON "loan_guarantor_change_replacement"("line_id");

-- AddForeignKey
ALTER TABLE "loan_guarantor_change" ADD CONSTRAINT "loan_guarantor_change_loan_id_fkey" FOREIGN KEY ("loan_id") REFERENCES "loan"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "loan_guarantor_change" ADD CONSTRAINT "loan_guarantor_change_member_id_fkey" FOREIGN KEY ("member_id") REFERENCES "member"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "loan_guarantor_change_line" ADD CONSTRAINT "loan_guarantor_change_line_change_no_fkey" FOREIGN KEY ("change_no") REFERENCES "loan_guarantor_change"("no") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "loan_guarantor_change_line" ADD CONSTRAINT "loan_guarantor_change_line_guarantor_member_id_fkey" FOREIGN KEY ("guarantor_member_id") REFERENCES "member"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "loan_guarantor_change_replacement" ADD CONSTRAINT "loan_guarantor_change_replacement_line_id_fkey" FOREIGN KEY ("line_id") REFERENCES "loan_guarantor_change_line"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "loan_guarantor_change_replacement" ADD CONSTRAINT "loan_guarantor_change_replacement_replacement_member_id_fkey" FOREIGN KEY ("replacement_member_id") REFERENCES "member"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- No. Series: reuses the app's existing sequence-table mechanism (see lib/db.ts nextSequence)
INSERT INTO "sequence" ("name", "prefix", "next_no", "width") VALUES ('GUARANTOR_CHANGE', 'GCH', 1, 6)
ON CONFLICT ("name") DO NOTHING;
