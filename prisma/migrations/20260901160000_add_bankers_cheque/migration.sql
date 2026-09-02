-- Bankers Cheque — AL Tab52204122 "Cheque Types" / Tab52204123 "Bankers Cheque" /
-- Pag52204056-58 / Cod52204019.PostBankersCheque / Rep52204097 "Bankers Cheque Schedule".
--
-- A member buys a banker's cheque: the SACCO debits the member's deposit account and credits a
-- configurable clearing G/L account (the cheque is the SACCO's liability until it clears the
-- bank). A configurable clearing charge is also deducted from the member's account. Maker-checker.

-- CreateTable: Cheque Types master (AL Tab52204122, only the "Bankers Cheque" type is ported).
CREATE TABLE "cheque_type" (
    "id" SERIAL NOT NULL,
    "code" TEXT NOT NULL,
    "description" TEXT NOT NULL,
    "maximum_amount" BIGINT NOT NULL DEFAULT 0,
    "clearing_gl_account_id" INTEGER NOT NULL,
    "clearing_charge_id" INTEGER,
    "in_house" BOOLEAN NOT NULL DEFAULT false,
    "status" TEXT NOT NULL DEFAULT 'ACTIVE',
    "created_at" TEXT,
    "created_by" TEXT,

    CONSTRAINT "cheque_type_pkey" PRIMARY KEY ("id")
);
CREATE UNIQUE INDEX "cheque_type_code_key" ON "cheque_type"("code");

ALTER TABLE "cheque_type" ADD CONSTRAINT "cheque_type_clearing_gl_account_id_fkey" FOREIGN KEY ("clearing_gl_account_id") REFERENCES "gl_account"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE "cheque_type" ADD CONSTRAINT "cheque_type_clearing_charge_id_fkey" FOREIGN KEY ("clearing_charge_id") REFERENCES "transaction_charge"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- CreateTable: the Bankers Cheque document (AL Tab52204123).
CREATE TABLE "bankers_cheque" (
    "no" TEXT NOT NULL,
    "cheque_type_id" INTEGER NOT NULL,
    "description" TEXT,
    "max_amount" BIGINT NOT NULL DEFAULT 0,
    "member_id" INTEGER NOT NULL,
    "savings_account_id" INTEGER NOT NULL,
    "payee_details" TEXT,
    "cheque_no" TEXT,
    "book_balance" BIGINT NOT NULL DEFAULT 0,
    "amount" BIGINT NOT NULL DEFAULT 0,
    "transaction_charge_id" INTEGER,
    "charge_amount" BIGINT NOT NULL DEFAULT 0,
    "net_amount" BIGINT NOT NULL DEFAULT 0,
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

    CONSTRAINT "bankers_cheque_pkey" PRIMARY KEY ("no")
);

CREATE INDEX "ix_bcq_member" ON "bankers_cheque"("member_id");
CREATE INDEX "ix_bcq_account" ON "bankers_cheque"("savings_account_id");
CREATE INDEX "ix_bcq_status" ON "bankers_cheque"("status");
CREATE INDEX "ix_bcq_created_by" ON "bankers_cheque"("created_by");
CREATE INDEX "ix_bcq_posting_date" ON "bankers_cheque"("posting_date");

ALTER TABLE "bankers_cheque" ADD CONSTRAINT "bankers_cheque_cheque_type_id_fkey" FOREIGN KEY ("cheque_type_id") REFERENCES "cheque_type"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE "bankers_cheque" ADD CONSTRAINT "bankers_cheque_member_id_fkey" FOREIGN KEY ("member_id") REFERENCES "member"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE "bankers_cheque" ADD CONSTRAINT "bankers_cheque_savings_account_id_fkey" FOREIGN KEY ("savings_account_id") REFERENCES "savings_account"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE "bankers_cheque" ADD CONSTRAINT "bankers_cheque_transaction_charge_id_fkey" FOREIGN KEY ("transaction_charge_id") REFERENCES "transaction_charge"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- Data: document number sequence (AL uses each Cheque Type's own No. Series; one global here).
INSERT INTO "sequence" ("name", "prefix", "next_no", "width") VALUES ('BANKERS_CHEQUE', 'BCQ', 1, 6)
ON CONFLICT ("name") DO NOTHING;

-- Permission backfill: grant the Bankers Cheques page + table rights to the seeded roles, keyed
-- by name (mirrors the ROLES action lists in lib/seed.ts). GREATEST keeps any right already held;
-- System Administrator is is_system and bypasses permission lines entirely.
INSERT INTO "permission_set_line"
  ("role_id", "object_type", "object_name", "read_perm", "insert_perm", "modify_perm", "delete_perm", "execute_perm")
SELECT r.id, g.object_type, g.object_name, g.r, g.i, g.m, g.d, g.e
FROM "role" r
JOIN (VALUES
  ('Branch Manager',  'PAGE',  'BANKERS_CHEQUES',        0,0,0,0,1),
  ('Branch Manager',  'TABLE', 'bankers_cheque',         1,1,1,1,0),
  ('Branch Manager',  'TABLE', 'cheque_type',            1,1,1,1,0),
  ('Branch Manager',  'TABLE', 'savings_account',        0,0,1,0,0),
  ('Branch Manager',  'TABLE', 'journal',                0,1,0,0,0),
  ('Branch Manager',  'TABLE', 'journal_line',           0,1,0,0,0),
  ('Branch Manager',  'TABLE', 'txn',                    0,1,0,0,0),
  ('Teller',          'PAGE',  'BANKERS_CHEQUES',        0,0,0,0,1),
  ('Teller',          'TABLE', 'bankers_cheque',         1,1,1,1,0),
  ('Teller',          'TABLE', 'savings_account',        0,0,1,0,0),
  ('Teller',          'TABLE', 'journal',                0,1,0,0,0),
  ('Teller',          'TABLE', 'journal_line',           0,1,0,0,0),
  ('Teller',          'TABLE', 'txn',                    0,1,0,0,0),
  ('Finance Officer', 'PAGE',  'BANKERS_CHEQUES',        0,0,0,0,1),
  ('Finance Officer', 'TABLE', 'bankers_cheque',         1,1,1,1,0),
  ('Finance Officer', 'TABLE', 'cheque_type',            1,1,1,1,0),
  ('Finance Officer', 'TABLE', 'savings_account',        0,0,1,0,0),
  ('Finance Officer', 'TABLE', 'journal',                0,1,0,0,0),
  ('Finance Officer', 'TABLE', 'journal_line',           0,1,0,0,0),
  ('Finance Officer', 'TABLE', 'txn',                    0,1,0,0,0),
  ('Internal Auditor','PAGE',  'BANKERS_CHEQUES',        0,0,0,0,1),
  ('Internal Auditor','TABLE', 'bankers_cheque',         1,0,0,0,0),
  ('Internal Auditor','TABLE', 'cheque_type',            1,0,0,0,0)
) AS g(role_name, object_type, object_name, r, i, m, d, e) ON g.role_name = r.name
ON CONFLICT ("role_id", "object_type", "object_name") DO UPDATE SET
  "read_perm"    = GREATEST("permission_set_line"."read_perm",    EXCLUDED."read_perm"),
  "insert_perm"  = GREATEST("permission_set_line"."insert_perm",  EXCLUDED."insert_perm"),
  "modify_perm"  = GREATEST("permission_set_line"."modify_perm",  EXCLUDED."modify_perm"),
  "delete_perm"  = GREATEST("permission_set_line"."delete_perm",  EXCLUDED."delete_perm"),
  "execute_perm" = GREATEST("permission_set_line"."execute_perm", EXCLUDED."execute_perm");
