-- Cheque Deposit — AL Tab52204124 "Cheque Deposits" / Pag52204061-62 / Cod52204019.PostCheque /
-- Rep52204082 "Cheque Deposit Slip".
--
-- A member banks a third-party cheque. It is captured (Open), approved, then held until its
-- maturity date; on that date it is Cleared (funds credited to the member's account, clearing
-- charge deducted) or Bounced (bouncing charge deducted). Express clearing credits the funds
-- before maturity for an express charge and places a hold on the account until the real
-- maturity date (AL's "Uncleared Funds" effect).
--
-- Scope note: Cheque "Instructions" (pre-splitting cleared funds to other accounts / loan
-- repayment) and the "Clearance" document type are NOT ported.

-- AlterTable: Cheque Types gains an EXTERNAL variant (AL Cheque Type enum). BANKERS types keep
-- working for lib/bankersCheques.ts; EXTERNAL types back lib/chequeDeposits.ts.
ALTER TABLE "cheque_type" ADD COLUMN "type" TEXT NOT NULL DEFAULT 'BANKERS';
ALTER TABLE "cheque_type" ADD COLUMN "bouncing_charge_id" INTEGER;
ALTER TABLE "cheque_type" ADD COLUMN "express_charge_id" INTEGER;
-- AL "Maturity Period" (DateFormula) simplified to a plain calendar-day count, the same way the
-- rest of this port collapses DateFormula fields.
ALTER TABLE "cheque_type" ADD COLUMN "maturity_days" INTEGER NOT NULL DEFAULT 3;

ALTER TABLE "cheque_type" ADD CONSTRAINT "cheque_type_bouncing_charge_id_fkey" FOREIGN KEY ("bouncing_charge_id") REFERENCES "transaction_charge"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE "cheque_type" ADD CONSTRAINT "cheque_type_express_charge_id_fkey" FOREIGN KEY ("express_charge_id") REFERENCES "transaction_charge"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- CreateTable
CREATE TABLE "cheque_deposit" (
    "no" TEXT NOT NULL,
    "cheque_type_id" INTEGER NOT NULL,
    "description" TEXT,
    "member_id" INTEGER NOT NULL,
    "savings_account_id" INTEGER NOT NULL,
    "cheque_no" TEXT,
    "cheque_date" TEXT,
    "deposit_date" TEXT NOT NULL,
    "maturity_date" TEXT NOT NULL,
    "in_house" BOOLEAN NOT NULL DEFAULT false,
    "amount" BIGINT NOT NULL DEFAULT 0,
    "express_cheque" BOOLEAN NOT NULL DEFAULT false,
    "drawer_account_name" TEXT,
    "drawer_bank" TEXT,
    "drawer_branch" TEXT,
    "drawer_account_no" TEXT,
    "clearing_gl_account_id" INTEGER NOT NULL,
    "clearing_charge_id" INTEGER,
    "bouncing_charge_id" INTEGER,
    "express_charge_id" INTEGER,
    "charge_amount" BIGINT NOT NULL DEFAULT 0,
    "express_hold_amount" BIGINT NOT NULL DEFAULT 0,
    "status" TEXT NOT NULL DEFAULT 'Open',
    "decision_reason" TEXT,
    "cleared_by" TEXT,
    "clearance_date" TEXT,
    "journal_id" INTEGER,
    "global_dimension_1_id" INTEGER,
    "global_dimension_2_id" INTEGER,
    "created_at" TEXT,
    "created_by" TEXT,

    CONSTRAINT "cheque_deposit_pkey" PRIMARY KEY ("no")
);

CREATE INDEX "ix_cd_member" ON "cheque_deposit"("member_id");
CREATE INDEX "ix_cd_account" ON "cheque_deposit"("savings_account_id");
CREATE INDEX "ix_cd_status" ON "cheque_deposit"("status");
CREATE INDEX "ix_cd_created_by" ON "cheque_deposit"("created_by");
CREATE INDEX "ix_cd_maturity" ON "cheque_deposit"("maturity_date");

ALTER TABLE "cheque_deposit" ADD CONSTRAINT "cheque_deposit_cheque_type_id_fkey" FOREIGN KEY ("cheque_type_id") REFERENCES "cheque_type"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE "cheque_deposit" ADD CONSTRAINT "cheque_deposit_member_id_fkey" FOREIGN KEY ("member_id") REFERENCES "member"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE "cheque_deposit" ADD CONSTRAINT "cheque_deposit_savings_account_id_fkey" FOREIGN KEY ("savings_account_id") REFERENCES "savings_account"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE "cheque_deposit" ADD CONSTRAINT "cheque_deposit_clearing_gl_account_id_fkey" FOREIGN KEY ("clearing_gl_account_id") REFERENCES "gl_account"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE "cheque_deposit" ADD CONSTRAINT "cheque_deposit_clearing_charge_id_fkey" FOREIGN KEY ("clearing_charge_id") REFERENCES "transaction_charge"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- Data: document number sequence
INSERT INTO "sequence" ("name", "prefix", "next_no", "width") VALUES ('CHEQUE_DEPOSIT', 'CHQ', 1, 6)
ON CONFLICT ("name") DO NOTHING;

-- Data: a starter EXTERNAL cheque type cleared through the Cheque Clearing (Uncleared) account.
INSERT INTO "gl_account" ("code", "name", "type", "parent_code", "is_postable", "account_type")
SELECT '1050', 'Cheques in Clearing', 'ASSET', '1000', 1, 'POSTING'
WHERE NOT EXISTS (SELECT 1 FROM "gl_account" WHERE "code" = '1050');

INSERT INTO "cheque_type"
  ("code", "description", "maximum_amount", "clearing_gl_account_id", "clearing_charge_id", "in_house", "status", "type", "maturity_days", "created_at", "created_by")
SELECT 'EXT', 'Local Bank Cheque', 0, (SELECT "id" FROM "gl_account" WHERE "code" = '1050'), NULL, false, 'ACTIVE', 'EXTERNAL', 3, now()::text, 'system'
WHERE NOT EXISTS (SELECT 1 FROM "cheque_type" WHERE "code" = 'EXT');

-- Permission backfill (mirrors lib/seed.ts ROLES). GREATEST keeps any right already held.
INSERT INTO "permission_set_line"
  ("role_id", "object_type", "object_name", "read_perm", "insert_perm", "modify_perm", "delete_perm", "execute_perm")
SELECT r.id, g.object_type, g.object_name, g.r, g.i, g.m, g.d, g.e
FROM "role" r
JOIN (VALUES
  ('Branch Manager',  'PAGE',  'CHEQUE_DEPOSITS',   0,0,0,0,1),
  ('Branch Manager',  'TABLE', 'cheque_deposit',    1,1,1,1,0),
  ('Branch Manager',  'TABLE', 'cheque_type',       1,1,1,1,0),
  ('Branch Manager',  'TABLE', 'savings_account',   0,0,1,0,0),
  ('Branch Manager',  'TABLE', 'journal',           0,1,0,0,0),
  ('Branch Manager',  'TABLE', 'journal_line',      0,1,0,0,0),
  ('Branch Manager',  'TABLE', 'txn',               0,1,0,0,0),
  ('Teller',          'PAGE',  'CHEQUE_DEPOSITS',   0,0,0,0,1),
  ('Teller',          'TABLE', 'cheque_deposit',    1,1,1,1,0),
  ('Teller',          'TABLE', 'savings_account',   0,0,1,0,0),
  ('Teller',          'TABLE', 'journal',           0,1,0,0,0),
  ('Teller',          'TABLE', 'journal_line',      0,1,0,0,0),
  ('Teller',          'TABLE', 'txn',               0,1,0,0,0),
  ('Finance Officer', 'PAGE',  'CHEQUE_DEPOSITS',   0,0,0,0,1),
  ('Finance Officer', 'TABLE', 'cheque_deposit',    1,1,1,1,0),
  ('Finance Officer', 'TABLE', 'cheque_type',       1,1,1,1,0),
  ('Finance Officer', 'TABLE', 'savings_account',   0,0,1,0,0),
  ('Finance Officer', 'TABLE', 'journal',           0,1,0,0,0),
  ('Finance Officer', 'TABLE', 'journal_line',      0,1,0,0,0),
  ('Finance Officer', 'TABLE', 'txn',               0,1,0,0,0),
  ('Internal Auditor','PAGE',  'CHEQUE_DEPOSITS',   0,0,0,0,1),
  ('Internal Auditor','TABLE', 'cheque_deposit',    1,0,0,0,0),
  ('Internal Auditor','TABLE', 'cheque_type',       1,0,0,0,0)
) AS g(role_name, object_type, object_name, r, i, m, d, e) ON g.role_name = r.name
ON CONFLICT ("role_id", "object_type", "object_name") DO UPDATE SET
  "read_perm"    = GREATEST("permission_set_line"."read_perm",    EXCLUDED."read_perm"),
  "insert_perm"  = GREATEST("permission_set_line"."insert_perm",  EXCLUDED."insert_perm"),
  "modify_perm"  = GREATEST("permission_set_line"."modify_perm",  EXCLUDED."modify_perm"),
  "delete_perm"  = GREATEST("permission_set_line"."delete_perm",  EXCLUDED."delete_perm"),
  "execute_perm" = GREATEST("permission_set_line"."execute_perm", EXCLUDED."execute_perm");
