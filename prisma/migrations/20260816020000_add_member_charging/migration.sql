-- Member Charging: an ad-hoc charge posted straight against a member's own withdrawable
-- deposit account — Table 52204206 / Pages 52204262 & 52204263 / Codeunit 52204019 in the
-- source documentation. No approval workflow: whoever creates it also posts it, so status only
-- ever moves Open -> Posted.
CREATE TABLE "member_charging" (
    "no" TEXT NOT NULL,
    "description" TEXT NOT NULL,
    "member_id" INTEGER NOT NULL,
    "source_account_id" INTEGER NOT NULL,
    "transaction_charge_id" INTEGER NOT NULL,
    "no_of_pages" INTEGER,
    "amount_charged" BIGINT NOT NULL DEFAULT 0,
    "status" TEXT NOT NULL DEFAULT 'Open',
    "journal_id" INTEGER,
    "created_at" TEXT,
    "created_by" TEXT,
    "posted_at" TEXT,
    "posted_by" TEXT,

    CONSTRAINT "member_charging_pkey" PRIMARY KEY ("no")
);

-- CreateIndex
CREATE INDEX "ix_mc_member" ON "member_charging"("member_id");

-- CreateIndex
CREATE INDEX "ix_mc_status" ON "member_charging"("status", "created_at");

-- AddForeignKey
ALTER TABLE "member_charging" ADD CONSTRAINT "member_charging_member_id_fkey" FOREIGN KEY ("member_id") REFERENCES "member"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE "member_charging" ADD CONSTRAINT "member_charging_source_account_id_fkey" FOREIGN KEY ("source_account_id") REFERENCES "savings_account"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE "member_charging" ADD CONSTRAINT "member_charging_transaction_charge_id_fkey" FOREIGN KEY ("transaction_charge_id") REFERENCES "transaction_charge"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE "member_charging" ADD CONSTRAINT "member_charging_journal_id_fkey" FOREIGN KEY ("journal_id") REFERENCES "journal"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- No. Series: reuses the app's existing sequence-table mechanism (see lib/db.ts nextSequence)
INSERT INTO "sequence" ("name", "prefix", "next_no", "width") VALUES ('MEMBER_CHARGING', 'MC', 1, 6)
ON CONFLICT ("name") DO NOTHING;
