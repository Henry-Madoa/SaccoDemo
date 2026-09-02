-- No. Series Management — Business Central No. Series (Table 308), No. Series Line (Table 309)
-- and the "…Nos." setup fields (kept here on one Admin Centre card). See lib/noSeries.ts.

CREATE TABLE "no_series" (
    "code" TEXT NOT NULL,
    "description" TEXT NOT NULL DEFAULT '',
    "default_nos" INTEGER NOT NULL DEFAULT 1,
    "manual_nos" INTEGER NOT NULL DEFAULT 0,
    "date_order" INTEGER NOT NULL DEFAULT 0,

    CONSTRAINT "no_series_pkey" PRIMARY KEY ("code")
);

CREATE TABLE "no_series_line" (
    "id" SERIAL NOT NULL,
    "series_code" TEXT NOT NULL,
    "line_no" INTEGER NOT NULL DEFAULT 10000,
    "starting_date" TEXT,
    "starting_no" TEXT NOT NULL,
    "ending_no" TEXT,
    "last_no_used" TEXT,
    "last_date_used" TEXT,
    "warning_no" TEXT,
    "increment_by_no" INTEGER NOT NULL DEFAULT 1,
    "open" INTEGER NOT NULL DEFAULT 1,
    "allow_gaps" INTEGER NOT NULL DEFAULT 0,

    CONSTRAINT "no_series_line_pkey" PRIMARY KEY ("id")
);
CREATE INDEX "ix_no_series_line_series" ON "no_series_line"("series_code");
ALTER TABLE "no_series_line" ADD CONSTRAINT "no_series_line_series_code_fkey"
    FOREIGN KEY ("series_code") REFERENCES "no_series"("code") ON DELETE CASCADE ON UPDATE NO ACTION;

CREATE TABLE "no_series_setup" (
    "document_code" TEXT NOT NULL,
    "label" TEXT NOT NULL,
    "category" TEXT NOT NULL DEFAULT 'General',
    "sort" INTEGER NOT NULL DEFAULT 0,
    "series_code" TEXT,

    CONSTRAINT "no_series_setup_pkey" PRIMARY KEY ("document_code")
);
CREATE INDEX "ix_no_series_setup_series" ON "no_series_setup"("series_code");
ALTER TABLE "no_series_setup" ADD CONSTRAINT "no_series_setup_series_code_fkey"
    FOREIGN KEY ("series_code") REFERENCES "no_series"("code") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- Carry every existing flat counter over to a managed series (code == counter name). Starting No.
-- is set to the counter's current next number so the first GetNextNo continues without a gap.
INSERT INTO "no_series" ("code", "description", "default_nos", "manual_nos", "date_order")
SELECT s.name, s.name, 1, 0, 0 FROM "sequence" s
ON CONFLICT ("code") DO NOTHING;

INSERT INTO "no_series_line"
  ("series_code", "line_no", "starting_date", "starting_no", "increment_by_no", "open", "allow_gaps")
SELECT s.name, 10000, NULL,
       s.prefix || lpad(s.next_no::text, s.width, '0'), 1, 1, 0
FROM "sequence" s
WHERE NOT EXISTS (SELECT 1 FROM "no_series_line" l WHERE l.series_code = s.name);

-- The Admin Centre → No. Series card: one row per numbered document, grouped by module.
INSERT INTO "no_series_setup" ("document_code", "label", "category", "sort", "series_code")
SELECT v.code, v.label, v.category, v.sort,
       (SELECT ns.code FROM "no_series" ns WHERE ns.code = v.code)
FROM (VALUES
  ('MEMBER',                 'Member No.',                   'Membership', 1),
  ('MEMBER_APPLICATION',     'Membership Application No.',    'Membership', 2),
  ('MEMBER_EDIT',            'Member Amendment No.',          'Membership', 3),
  ('MEMBER_CHARGING',        'Member Charging No.',           'Membership', 4),
  ('MEMBER_EXIT',            'Member Exit No.',               'Membership', 5),
  ('MEMBER_ACTIVATION',      'Member Activation No.',         'Membership', 6),
  ('MEMBER_READMISSION',     'Member Re-admission No.',       'Membership', 7),
  ('SAVINGS_ACCOUNT',        'Savings Account No.',           'FOSA',       8),
  ('ACCOUNT_OPENING',        'Account Opening No.',           'FOSA',       9),
  ('ACCOUNT_DEACTIVATION',   'Account Deactivation No.',      'FOSA',       10),
  ('ACCOUNT_ACTIVATION',     'Account Activation No.',        'FOSA',       11),
  ('FOSA_TRANSACTION',       'FOSA Transaction No.',          'FOSA',       12),
  ('TELLER_TRANSACTION',     'Teller Transaction No.',        'FOSA',       13),
  ('MEMBER_LIEN',            'Lien / Hold No.',               'FOSA',       14),
  ('INTER_ACCOUNT_TRANSFER', 'Inter-Account Transfer No.',    'FOSA',       15),
  ('BANKERS_CHEQUE',         'Banker''s Cheque No.',          'FOSA',       16),
  ('CHEQUE_DEPOSIT',         'Cheque Deposit No.',            'FOSA',       17),
  ('STANDING_ORDER',         'Standing Order No.',            'FOSA',       18),
  ('FIXED_DEPOSIT',          'Fixed Deposit No.',             'FOSA',       19),
  ('LOAN',                   'Loan No.',                      'Credit',     20),
  ('LOAN_CALCULATOR',        'Loan Calculator No.',           'Credit',     21),
  ('GUARANTOR_CHANGE',       'Guarantor Change No.',          'Credit',     22),
  ('COLLATERAL_APPLICATION', 'Collateral Application No.',     'Credit',     23),
  ('COLLATERAL_RELEASE',     'Collateral Release No.',         'Credit',     24),
  ('CHECKOFF_BATCH',         'Checkoff Batch No.',            'Credit',     25),
  ('JOURNAL',                'Journal Voucher No.',           'Finance',    26),
  ('JOURNAL_DRAFT',          'Journal Draft No.',             'Finance',    27),
  ('TXN',                    'Ledger Transaction No.',        'Finance',    28)
) AS v(code, label, category, sort)
ON CONFLICT ("document_code") DO NOTHING;

-- Permission page + grants for the No. Series screen (Setup Pool -> General). Branch Manager only,
-- matching the ADMIN_POOL_SECTORS / ADMIN_PRODUCTS_* precedent.
INSERT INTO "permission_set_line"
  ("role_id", "object_type", "object_name", "read_perm", "insert_perm", "modify_perm", "delete_perm", "execute_perm")
SELECT r.id, 'PAGE', 'ADMIN_NO_SERIES', 0, 0, 0, 0, 1
FROM "role" r WHERE r.name = 'Branch Manager'
ON CONFLICT ("role_id", "object_type", "object_name") DO UPDATE SET "execute_perm" = GREATEST("permission_set_line"."execute_perm", EXCLUDED."execute_perm");

INSERT INTO "permission_set_line"
  ("role_id", "object_type", "object_name", "read_perm", "insert_perm", "modify_perm", "delete_perm", "execute_perm")
SELECT r.id, 'TABLE', t.name, 1, 1, 1, 1, 0
FROM "role" r
CROSS JOIN (VALUES ('no_series'), ('no_series_line'), ('no_series_setup')) AS t(name)
WHERE r.name = 'Branch Manager'
ON CONFLICT ("role_id", "object_type", "object_name") DO UPDATE SET
  "read_perm"   = GREATEST("permission_set_line"."read_perm",   EXCLUDED."read_perm"),
  "insert_perm" = GREATEST("permission_set_line"."insert_perm", EXCLUDED."insert_perm"),
  "modify_perm" = GREATEST("permission_set_line"."modify_perm", EXCLUDED."modify_perm"),
  "delete_perm" = GREATEST("permission_set_line"."delete_perm", EXCLUDED."delete_perm");
