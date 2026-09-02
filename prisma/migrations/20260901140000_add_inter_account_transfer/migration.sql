-- Inter Account Transfer — AL Tab52204093 / Pag52204163-4 / Cod52204019.PostInterAccountTransfer.
-- A maker-checker instruction to move cash from one member deposit account to another (the same
-- member's other account, or — with the cross-member right — a different member's account).
-- Posting withdraws from the source, deposits to the destination and deducts a configurable
-- transfer charge from the source. Only products flagged `allow_transfer` can be a source.

-- AlterTable: AL "Cash Transfer Allowed" (Vendor / Sacco Products) — which deposit products may
-- fund a transfer. Backfilled to allow_withdrawal so existing withdrawable products keep working.
ALTER TABLE "savings_product" ADD COLUMN "allow_transfer" INTEGER NOT NULL DEFAULT 1;
UPDATE "savings_product" SET "allow_transfer" = "allow_withdrawal";

-- AlterTable: AL General Ledger Setup "Inter Acc Transfer Charges" — the Transaction Charge
-- auto-applied to every inter-account transfer (mirrors instant_withdrawal_charge_id).
ALTER TABLE "organisation" ADD COLUMN "inter_account_transfer_charge_id" INTEGER;

-- CreateTable
CREATE TABLE "inter_account_transfer" (
    "no" TEXT NOT NULL,
    "source_member_id" INTEGER NOT NULL,
    "source_account_id" INTEGER NOT NULL,
    "destination_member_id" INTEGER NOT NULL,
    "destination_account_id" INTEGER NOT NULL,
    "amount_type" TEXT NOT NULL DEFAULT 'PARTIAL',
    "amount" BIGINT NOT NULL DEFAULT 0,
    "transaction_charge_id" INTEGER,
    "charge_amount" BIGINT NOT NULL DEFAULT 0,
    "narration" TEXT,
    "posting_date" TEXT NOT NULL,
    "status" TEXT NOT NULL DEFAULT 'Open',
    "decision_reason" TEXT,
    "posted" BOOLEAN NOT NULL DEFAULT false,
    "journal_id" INTEGER,
    "global_dimension_1_id" INTEGER,
    "global_dimension_2_id" INTEGER,
    "created_at" TEXT,
    "created_by" TEXT,
    "posted_at" TEXT,
    "posted_by" TEXT,

    CONSTRAINT "inter_account_transfer_pkey" PRIMARY KEY ("no")
);

-- CreateIndex
CREATE INDEX "ix_iat_source_member" ON "inter_account_transfer"("source_member_id");
CREATE INDEX "ix_iat_dest_member" ON "inter_account_transfer"("destination_member_id");
CREATE INDEX "ix_iat_source_account" ON "inter_account_transfer"("source_account_id");
CREATE INDEX "ix_iat_status" ON "inter_account_transfer"("status");
CREATE INDEX "ix_iat_created_by" ON "inter_account_transfer"("created_by");

-- AddForeignKey
ALTER TABLE "inter_account_transfer" ADD CONSTRAINT "iat_source_member_fkey" FOREIGN KEY ("source_member_id") REFERENCES "member"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE "inter_account_transfer" ADD CONSTRAINT "iat_dest_member_fkey" FOREIGN KEY ("destination_member_id") REFERENCES "member"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE "inter_account_transfer" ADD CONSTRAINT "iat_source_account_fkey" FOREIGN KEY ("source_account_id") REFERENCES "savings_account"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE "inter_account_transfer" ADD CONSTRAINT "iat_dest_account_fkey" FOREIGN KEY ("destination_account_id") REFERENCES "savings_account"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE "inter_account_transfer" ADD CONSTRAINT "iat_charge_fkey" FOREIGN KEY ("transaction_charge_id") REFERENCES "transaction_charge"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE "organisation" ADD CONSTRAINT "organisation_inter_account_transfer_charge_id_fkey" FOREIGN KEY ("inter_account_transfer_charge_id") REFERENCES "transaction_charge"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- Data: document number sequence
INSERT INTO "sequence" ("name", "prefix", "next_no", "width") VALUES ('INTER_ACCOUNT_TRANSFER', 'IAT', 1, 6)
ON CONFLICT ("name") DO NOTHING;

-- Permission backfill: grant the Inter Account Transfers page + table rights to the seeded roles,
-- keyed by name (mirrors the ROLES action lists in lib/seed.ts). GREATEST keeps any right already
-- held; System Administrator is is_system and bypasses permission lines entirely.
INSERT INTO "permission_set_line"
  ("role_id", "object_type", "object_name", "read_perm", "insert_perm", "modify_perm", "delete_perm", "execute_perm")
SELECT r.id, g.object_type, g.object_name, g.r, g.i, g.m, g.d, g.e
FROM "role" r
JOIN (VALUES
  ('Branch Manager',  'PAGE',  'INTER_ACCOUNT_TRANSFERS',  0,0,0,0,1),
  ('Branch Manager',  'TABLE', 'inter_account_transfer',   1,1,1,1,0),
  ('Branch Manager',  'TABLE', 'savings_account',          0,0,1,0,0),
  ('Branch Manager',  'TABLE', 'journal',                  0,1,0,0,0),
  ('Branch Manager',  'TABLE', 'journal_line',             0,1,0,0,0),
  ('Branch Manager',  'TABLE', 'txn',                      0,1,0,0,0),
  ('Teller',          'PAGE',  'INTER_ACCOUNT_TRANSFERS',  0,0,0,0,1),
  ('Teller',          'TABLE', 'inter_account_transfer',   1,1,1,1,0),
  ('Teller',          'TABLE', 'savings_account',          0,0,1,0,0),
  ('Teller',          'TABLE', 'journal',                  0,1,0,0,0),
  ('Teller',          'TABLE', 'journal_line',             0,1,0,0,0),
  ('Teller',          'TABLE', 'txn',                      0,1,0,0,0),
  ('Finance Officer', 'PAGE',  'INTER_ACCOUNT_TRANSFERS',  0,0,0,0,1),
  ('Finance Officer', 'TABLE', 'inter_account_transfer',   1,1,1,1,0),
  ('Finance Officer', 'TABLE', 'savings_account',          0,0,1,0,0),
  ('Finance Officer', 'TABLE', 'journal',                  0,1,0,0,0),
  ('Finance Officer', 'TABLE', 'journal_line',             0,1,0,0,0),
  ('Finance Officer', 'TABLE', 'txn',                      0,1,0,0,0),
  ('Internal Auditor','PAGE',  'INTER_ACCOUNT_TRANSFERS',  0,0,0,0,1),
  ('Internal Auditor','TABLE', 'inter_account_transfer',   1,0,0,0,0)
) AS g(role_name, object_type, object_name, r, i, m, d, e) ON g.role_name = r.name
ON CONFLICT ("role_id", "object_type", "object_name") DO UPDATE SET
  "read_perm"    = GREATEST("permission_set_line"."read_perm",    EXCLUDED."read_perm"),
  "insert_perm"  = GREATEST("permission_set_line"."insert_perm",  EXCLUDED."insert_perm"),
  "modify_perm"  = GREATEST("permission_set_line"."modify_perm",  EXCLUDED."modify_perm"),
  "delete_perm"  = GREATEST("permission_set_line"."delete_perm",  EXCLUDED."delete_perm"),
  "execute_perm" = GREATEST("permission_set_line"."execute_perm", EXCLUDED."execute_perm");
