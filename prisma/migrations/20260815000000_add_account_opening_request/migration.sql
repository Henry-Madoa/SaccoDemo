-- CreateTable
CREATE TABLE "account_opening_request" (
    "no" TEXT NOT NULL,
    "member_id" INTEGER NOT NULL,
    "savings_product_id" INTEGER NOT NULL,
    "opening_balance" BIGINT NOT NULL DEFAULT 0,
    "channel" TEXT NOT NULL DEFAULT 'TELLER',
    "notes" TEXT,
    "status" TEXT NOT NULL DEFAULT 'Open',
    "decision_reason" TEXT,
    "account_id" INTEGER,
    "created_at" TEXT,
    "created_by" TEXT,
    "processed_at" TEXT,
    "processed_by" TEXT,

    CONSTRAINT "account_opening_request_pkey" PRIMARY KEY ("no")
);

-- CreateIndex
CREATE INDEX "ix_aor_member" ON "account_opening_request"("member_id");

-- CreateIndex
CREATE INDEX "ix_aor_product" ON "account_opening_request"("savings_product_id");

-- CreateIndex
CREATE INDEX "ix_aor_status" ON "account_opening_request"("status");

-- AddForeignKey
ALTER TABLE "account_opening_request" ADD CONSTRAINT "account_opening_request_member_id_fkey" FOREIGN KEY ("member_id") REFERENCES "member"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "account_opening_request" ADD CONSTRAINT "account_opening_request_savings_product_id_fkey" FOREIGN KEY ("savings_product_id") REFERENCES "savings_product"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "account_opening_request" ADD CONSTRAINT "account_opening_request_account_id_fkey" FOREIGN KEY ("account_id") REFERENCES "savings_account"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- No. Series: reuses the app's existing sequence-table mechanism (see lib/db.ts nextSequence)
INSERT INTO "sequence" ("name", "prefix", "next_no", "width") VALUES ('ACCOUNT_OPENING', 'AOR', 1, 6)
ON CONFLICT ("name") DO NOTHING;
