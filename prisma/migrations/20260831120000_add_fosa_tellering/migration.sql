-- FOSA Tellering — treasury/till cash movements (fosa_transaction), over-the-counter member
-- deposits & withdrawals (teller_transaction), the Teller Setup master, the cash Denomination
-- master + per-document breakdown lines, and a company-wide "Validate Cash Denomination" flag.

-- AlterTable
ALTER TABLE "bank_account" ADD COLUMN "account_type" TEXT NOT NULL DEFAULT 'OTHER';

-- AlterTable
ALTER TABLE "organisation" ADD COLUMN "validate_cash_denomination" BOOLEAN NOT NULL DEFAULT false;

-- CreateTable
CREATE TABLE "denomination" (
    "id" SERIAL NOT NULL,
    "code" TEXT NOT NULL,
    "description" TEXT NOT NULL,
    "value" BIGINT NOT NULL,
    "active" BOOLEAN NOT NULL DEFAULT true,
    "sort_order" INTEGER NOT NULL DEFAULT 0,

    CONSTRAINT "denomination_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "cash_denomination_line" (
    "id" SERIAL NOT NULL,
    "document_kind" TEXT NOT NULL,
    "document_no" TEXT NOT NULL,
    "denomination_id" INTEGER NOT NULL,
    "quantity" INTEGER NOT NULL DEFAULT 0,

    CONSTRAINT "cash_denomination_line_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "teller_setup" (
    "id" SERIAL NOT NULL,
    "user_username" TEXT NOT NULL,
    "setup_type" TEXT NOT NULL,
    "bank_account_id" INTEGER NOT NULL,
    "max_capacity" BIGINT NOT NULL DEFAULT 0,
    "min_capacity" BIGINT NOT NULL DEFAULT 0,
    "approval_limit" BIGINT NOT NULL DEFAULT 0,
    "created_at" TEXT,
    "created_by" TEXT,

    CONSTRAINT "teller_setup_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "fosa_transaction" (
    "no" TEXT NOT NULL,
    "document_type" TEXT NOT NULL,
    "source_bank_account_id" INTEGER NOT NULL,
    "destination_bank_account_id" INTEGER NOT NULL,
    "amount" BIGINT NOT NULL DEFAULT 0,
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

    CONSTRAINT "fosa_transaction_pkey" PRIMARY KEY ("no")
);

-- CreateTable
CREATE TABLE "teller_transaction" (
    "no" TEXT NOT NULL,
    "transaction_type" TEXT NOT NULL,
    "member_id" INTEGER NOT NULL,
    "savings_account_id" INTEGER NOT NULL,
    "till_bank_account_id" INTEGER NOT NULL,
    "teller_username" TEXT NOT NULL,
    "amount" BIGINT NOT NULL,
    "source_of_funds" TEXT,
    "transacted_by_name" TEXT,
    "transacted_by_id_no" TEXT,
    "transaction_charge_id" INTEGER,
    "charge_amount" BIGINT NOT NULL DEFAULT 0,
    "available_balance" BIGINT NOT NULL DEFAULT 0,
    "book_balance" BIGINT NOT NULL DEFAULT 0,
    "approval_required" BOOLEAN NOT NULL DEFAULT false,
    "status" TEXT NOT NULL DEFAULT 'Open',
    "decision_reason" TEXT,
    "posted" BOOLEAN NOT NULL DEFAULT false,
    "journal_id" INTEGER,
    "slip_emailed_at" TEXT,
    "global_dimension_1_id" INTEGER,
    "global_dimension_2_id" INTEGER,
    "created_at" TEXT,
    "created_by" TEXT,
    "posted_at" TEXT,
    "posted_by" TEXT,

    CONSTRAINT "teller_transaction_pkey" PRIMARY KEY ("no")
);

-- CreateIndex
CREATE UNIQUE INDEX "denomination_code_key" ON "denomination"("code");

-- CreateIndex
CREATE INDEX "ix_cdl_document" ON "cash_denomination_line"("document_kind", "document_no");

-- CreateIndex
CREATE UNIQUE INDEX "cash_denomination_line_document_kind_document_no_denominatio_key" ON "cash_denomination_line"("document_kind", "document_no", "denomination_id");

-- CreateIndex
CREATE INDEX "ix_ts_bank_account" ON "teller_setup"("bank_account_id");

-- CreateIndex
CREATE UNIQUE INDEX "teller_setup_user_username_setup_type_key" ON "teller_setup"("user_username", "setup_type");

-- CreateIndex
CREATE INDEX "ix_ft_type_status" ON "fosa_transaction"("document_type", "status");

-- CreateIndex
CREATE INDEX "ix_ft_created_by" ON "fosa_transaction"("created_by");

-- CreateIndex
CREATE INDEX "ix_tt_type_status" ON "teller_transaction"("transaction_type", "status");

-- CreateIndex
CREATE INDEX "ix_tt_member" ON "teller_transaction"("member_id");

-- CreateIndex
CREATE INDEX "ix_tt_created_by" ON "teller_transaction"("created_by");

-- AddForeignKey
ALTER TABLE "cash_denomination_line" ADD CONSTRAINT "cash_denomination_line_denomination_id_fkey" FOREIGN KEY ("denomination_id") REFERENCES "denomination"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "teller_setup" ADD CONSTRAINT "teller_setup_bank_account_id_fkey" FOREIGN KEY ("bank_account_id") REFERENCES "bank_account"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "fosa_transaction" ADD CONSTRAINT "fosa_transaction_source_bank_account_id_fkey" FOREIGN KEY ("source_bank_account_id") REFERENCES "bank_account"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "fosa_transaction" ADD CONSTRAINT "fosa_transaction_destination_bank_account_id_fkey" FOREIGN KEY ("destination_bank_account_id") REFERENCES "bank_account"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "fosa_transaction" ADD CONSTRAINT "fosa_transaction_journal_id_fkey" FOREIGN KEY ("journal_id") REFERENCES "journal"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "teller_transaction" ADD CONSTRAINT "teller_transaction_member_id_fkey" FOREIGN KEY ("member_id") REFERENCES "member"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "teller_transaction" ADD CONSTRAINT "teller_transaction_savings_account_id_fkey" FOREIGN KEY ("savings_account_id") REFERENCES "savings_account"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "teller_transaction" ADD CONSTRAINT "teller_transaction_till_bank_account_id_fkey" FOREIGN KEY ("till_bank_account_id") REFERENCES "bank_account"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "teller_transaction" ADD CONSTRAINT "teller_transaction_transaction_charge_id_fkey" FOREIGN KEY ("transaction_charge_id") REFERENCES "transaction_charge"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "teller_transaction" ADD CONSTRAINT "teller_transaction_journal_id_fkey" FOREIGN KEY ("journal_id") REFERENCES "journal"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- Data: sequences for the two new document numbers
INSERT INTO "sequence" ("name", "prefix", "next_no", "width") VALUES
    ('FOSA_TRANSACTION', 'FT', 1, 6),
    ('TELLER_TRANSACTION', 'TT', 1, 6)
ON CONFLICT ("name") DO NOTHING;

-- Data: cash denomination master (Kenyan notes & coins; value in cents)
INSERT INTO "denomination" ("code", "description", "value", "active", "sort_order") VALUES
    ('N1000', 'KSh 1,000 note', 100000, true, 1),
    ('N500',  'KSh 500 note',    50000, true, 2),
    ('N200',  'KSh 200 note',    20000, true, 3),
    ('N100',  'KSh 100 note',    10000, true, 4),
    ('N50',   'KSh 50 note',      5000, true, 5),
    ('C40',   'KSh 40 coin',      4000, true, 6),
    ('C20',   'KSh 20 coin',      2000, true, 7),
    ('C10',   'KSh 10 coin',      1000, true, 8),
    ('C5',    'KSh 5 coin',        500, true, 9),
    ('C1',    'KSh 1 coin',        100, true, 10)
ON CONFLICT ("code") DO NOTHING;

-- Data: mark the existing external bank account as the Main Bank
UPDATE "bank_account" SET "account_type" = 'MAIN' WHERE "code" = 'BANK';

-- Data: a branch Treasury vault + two tills, each on its own asset control account.
INSERT INTO "gl_account" ("code", "name", "type", "parent_code", "is_postable", "account_type", "no_direct_posting") VALUES
    ('1015', 'Main Vault — Treasury', 'ASSET', '1000', 1, 'POSTING', 1),
    ('1016', 'Till 01 — Cash',        'ASSET', '1000', 1, 'POSTING', 1),
    ('1017', 'Till 02 — Cash',        'ASSET', '1000', 1, 'POSTING', 1)
ON CONFLICT ("code") DO NOTHING;

INSERT INTO "bank_account" ("code", "name", "gl_account_id", "account_type", "balance", "status", "created_at")
SELECT v.code, v.name, g.id, v.account_type, 0, 'ACTIVE', NOW()::text
FROM (VALUES
    ('TREASURY', 'Main Vault — Treasury', '1015', 'TREASURY'),
    ('TILL-01',  'Till 01',               '1016', 'TILL'),
    ('TILL-02',  'Till 02',               '1017', 'TILL')
) AS v(code, name, gl_code, account_type)
JOIN "gl_account" g ON g.code = v.gl_code
ON CONFLICT ("code") DO NOTHING;

-- Data: Teller Setup for the demo users (teller -> Till 01; finance & manager -> Treasury)
INSERT INTO "teller_setup" ("user_username", "setup_type", "bank_account_id", "max_capacity", "min_capacity", "approval_limit", "created_at", "created_by")
SELECT s.username, s.setup_type, b.id, s.max_capacity::bigint, s.min_capacity::bigint, s.approval_limit::bigint, NOW()::text, 'system'
FROM (VALUES
    ('teller',  'TELLER',   'TILL-01',  500000000, 0,          20000000),
    ('finance', 'TREASURY', 'TREASURY', 5000000000, 100000000, 0),
    ('manager', 'TREASURY', 'TREASURY', 5000000000, 100000000, 0)
) AS s(username, setup_type, bank_code, max_capacity, min_capacity, approval_limit)
JOIN "bank_account" b ON b.code = s.bank_code
WHERE EXISTS (SELECT 1 FROM "app_user" u WHERE u.username = s.username)
ON CONFLICT ("user_username", "setup_type") DO NOTHING;

-- Permission backfill: give every role that can already reach Standing Orders the two new
-- operational pages + full rights on the new document tables (they already hold journal / GL /
-- savings_account / txn rights from the Savings action). Mirrors the standing_order backfill
-- technique — key off an existing grant unique to the target audience.
INSERT INTO "permission_set_line" ("role_id", "object_type", "object_name", "read_perm", "insert_perm", "modify_perm", "delete_perm", "execute_perm")
SELECT DISTINCT psl."role_id", 'PAGE', p.page, 0, 0, 0, 0, 1
FROM "permission_set_line" psl
CROSS JOIN (VALUES ('CASH_MANAGEMENT'), ('TELLER_TRANSACTIONS')) AS p(page)
WHERE psl."object_type" = 'PAGE' AND psl."object_name" = 'STANDING_ORDERS' AND psl."execute_perm" = 1
ON CONFLICT ("role_id", "object_type", "object_name") DO UPDATE SET "execute_perm" = 1;

INSERT INTO "permission_set_line" ("role_id", "object_type", "object_name", "read_perm", "insert_perm", "modify_perm", "delete_perm", "execute_perm")
SELECT DISTINCT psl."role_id", 'TABLE', t.name,
       1,
       CASE WHEN psl."insert_perm" = 1 THEN 1 ELSE 0 END,
       CASE WHEN psl."modify_perm" = 1 THEN 1 ELSE 0 END,
       CASE WHEN psl."delete_perm" = 1 THEN 1 ELSE 0 END,
       0
FROM "permission_set_line" psl
CROSS JOIN (VALUES ('fosa_transaction'), ('teller_transaction'), ('cash_denomination_line')) AS t(name)
WHERE psl."object_type" = 'TABLE' AND psl."object_name" = 'standing_order'
ON CONFLICT ("role_id", "object_type", "object_name")
DO UPDATE SET "read_perm" = 1,
             "insert_perm" = GREATEST("permission_set_line"."insert_perm", EXCLUDED."insert_perm"),
             "modify_perm" = GREATEST("permission_set_line"."modify_perm", EXCLUDED."modify_perm"),
             "delete_perm" = GREATEST("permission_set_line"."delete_perm", EXCLUDED."delete_perm");

-- Permission backfill: Teller Setup + Denominations admin pages/tables for whoever already
-- manages the Setup Pool masters (Member Categories).
INSERT INTO "permission_set_line" ("role_id", "object_type", "object_name", "read_perm", "insert_perm", "modify_perm", "delete_perm", "execute_perm")
SELECT DISTINCT psl."role_id", 'PAGE', p.page, 0, 0, 0, 0, 1
FROM "permission_set_line" psl
CROSS JOIN (VALUES ('ADMIN_TELLER_SETUP'), ('ADMIN_POOL_DENOMINATIONS')) AS p(page)
WHERE psl."object_type" = 'PAGE' AND psl."object_name" = 'ADMIN_POOL_CATEGORIES' AND psl."execute_perm" = 1
ON CONFLICT ("role_id", "object_type", "object_name") DO UPDATE SET "execute_perm" = 1;

INSERT INTO "permission_set_line" ("role_id", "object_type", "object_name", "read_perm", "insert_perm", "modify_perm", "delete_perm", "execute_perm")
SELECT DISTINCT psl."role_id", 'TABLE', t.name, 1, 1, 1, 1, 0
FROM "permission_set_line" psl
CROSS JOIN (VALUES ('teller_setup'), ('denomination')) AS t(name)
WHERE psl."object_type" = 'TABLE' AND psl."object_name" = 'member_category' AND psl."insert_perm" = 1
ON CONFLICT ("role_id", "object_type", "object_name")
DO UPDATE SET "read_perm" = 1, "insert_perm" = 1, "modify_perm" = 1, "delete_perm" = 1;
