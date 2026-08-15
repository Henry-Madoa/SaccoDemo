-- CreateTable
CREATE TABLE "account_deactivation_request" (
    "no" TEXT NOT NULL,
    "account_id" INTEGER NOT NULL,
    "reason" TEXT,
    "status" TEXT NOT NULL DEFAULT 'Open',
    "decision_reason" TEXT,
    "created_at" TEXT,
    "created_by" TEXT,
    "processed_at" TEXT,
    "processed_by" TEXT,

    CONSTRAINT "account_deactivation_request_pkey" PRIMARY KEY ("no")
);

-- CreateIndex
CREATE INDEX "ix_adr_account" ON "account_deactivation_request"("account_id");

-- CreateIndex
CREATE INDEX "ix_adr_status" ON "account_deactivation_request"("status");

-- AddForeignKey
ALTER TABLE "account_deactivation_request" ADD CONSTRAINT "account_deactivation_request_account_id_fkey" FOREIGN KEY ("account_id") REFERENCES "savings_account"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- No. Series: reuses the app's existing sequence-table mechanism (see lib/db.ts nextSequence)
INSERT INTO "sequence" ("name", "prefix", "next_no", "width") VALUES ('ACCOUNT_DEACTIVATION', 'ADR', 1, 6)
ON CONFLICT ("name") DO NOTHING;
