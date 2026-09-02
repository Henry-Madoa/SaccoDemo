-- Lien / Hold module — AL "Lien" (Tab52204192). A maker-checker instruction to hold or release
-- part of a member's deposit-account balance. No G/L posting; processing moves
-- savings_account.hold_amount, which every "available balance" calc already subtracts.

-- CreateTable
CREATE TABLE "member_lien" (
    "no" TEXT NOT NULL,
    "member_id" INTEGER NOT NULL,
    "savings_account_id" INTEGER NOT NULL,
    "transaction_type" TEXT NOT NULL,
    "amount" BIGINT NOT NULL DEFAULT 0,
    "narration" TEXT,
    "posting_date" TEXT NOT NULL,
    "status" TEXT NOT NULL DEFAULT 'Open',
    "decision_reason" TEXT,
    "processed" BOOLEAN NOT NULL DEFAULT false,
    "global_dimension_1_id" INTEGER,
    "global_dimension_2_id" INTEGER,
    "created_at" TEXT,
    "created_by" TEXT,
    "processed_at" TEXT,
    "processed_by" TEXT,

    CONSTRAINT "member_lien_pkey" PRIMARY KEY ("no")
);

-- CreateIndex
CREATE INDEX "ix_lien_member" ON "member_lien"("member_id");

-- CreateIndex
CREATE INDEX "ix_lien_account" ON "member_lien"("savings_account_id");

-- CreateIndex
CREATE INDEX "ix_lien_type_status" ON "member_lien"("transaction_type", "status");

-- CreateIndex
CREATE INDEX "ix_lien_created_by" ON "member_lien"("created_by");

-- AddForeignKey
ALTER TABLE "member_lien" ADD CONSTRAINT "member_lien_member_id_fkey" FOREIGN KEY ("member_id") REFERENCES "member"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "member_lien" ADD CONSTRAINT "member_lien_savings_account_id_fkey" FOREIGN KEY ("savings_account_id") REFERENCES "savings_account"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- Data: document number sequence
INSERT INTO "sequence" ("name", "prefix", "next_no", "width") VALUES ('MEMBER_LIEN', 'LIEN', 1, 6)
ON CONFLICT ("name") DO NOTHING;

-- Permission backfill: grant the Liens page + table rights to the seeded roles, keyed by name
-- (mirrors the ROLES action lists in lib/seed.ts). GREATEST keeps any right already held;
-- System Administrator is is_system and bypasses permission lines entirely.
INSERT INTO "permission_set_line"
  ("role_id", "object_type", "object_name", "read_perm", "insert_perm", "modify_perm", "delete_perm", "execute_perm")
SELECT r.id, g.object_type, g.object_name, g.r, g.i, g.m, g.d, g.e
FROM "role" r
JOIN (VALUES
  ('Branch Manager',  'PAGE',  'LIENS',           0,0,0,0,1),
  ('Branch Manager',  'TABLE', 'member_lien',     1,1,1,1,0),
  ('Branch Manager',  'TABLE', 'savings_account', 0,0,1,0,0),
  ('Teller',          'PAGE',  'LIENS',           0,0,0,0,1),
  ('Teller',          'TABLE', 'member_lien',     1,1,1,1,0),
  ('Teller',          'TABLE', 'savings_account', 0,0,1,0,0),
  ('Finance Officer', 'PAGE',  'LIENS',           0,0,0,0,1),
  ('Finance Officer', 'TABLE', 'member_lien',     1,1,1,1,0),
  ('Finance Officer', 'TABLE', 'savings_account', 0,0,1,0,0),
  ('Internal Auditor','PAGE',  'LIENS',           0,0,0,0,1),
  ('Internal Auditor','TABLE', 'member_lien',     1,0,0,0,0)
) AS g(role_name, object_type, object_name, r, i, m, d, e) ON g.role_name = r.name
ON CONFLICT ("role_id", "object_type", "object_name") DO UPDATE SET
  "read_perm"    = GREATEST("permission_set_line"."read_perm",    EXCLUDED."read_perm"),
  "insert_perm"  = GREATEST("permission_set_line"."insert_perm",  EXCLUDED."insert_perm"),
  "modify_perm"  = GREATEST("permission_set_line"."modify_perm",  EXCLUDED."modify_perm"),
  "delete_perm"  = GREATEST("permission_set_line"."delete_perm",  EXCLUDED."delete_perm"),
  "execute_perm" = GREATEST("permission_set_line"."execute_perm", EXCLUDED."execute_perm");
