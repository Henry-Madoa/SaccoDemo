-- Financial Reports (Account Schedules) — a Business Central port.
--
-- A *Row Definition* (acc_schedule_name + acc_schedule_line) says which G/L accounts roll into
-- which line, plus formula lines. A *Column Layout* (column_layout_name + column_layout) says
-- which period each column measures (Net Change / Balance at Date / prior-year comparison /
-- formula). A *Financial Report* pairs one of each. The Finance Manager configures and prints
-- SASRA returns from this instead of asking a developer to hard-code them.

-- ============================================================================= column layouts

-- Business Central Table 334 "Column Layout Name".
CREATE TABLE "column_layout_name" (
    "id"          SERIAL NOT NULL,
    "name"        TEXT   NOT NULL,
    "description" TEXT   NOT NULL DEFAULT '',
    "created_at"  TEXT,
    "created_by"  TEXT,

    CONSTRAINT "column_layout_name_pkey" PRIMARY KEY ("id")
);
CREATE UNIQUE INDEX "column_layout_name_name_key" ON "column_layout_name"("name");

-- Business Central Table 333 "Column Layout".
CREATE TABLE "column_layout" (
    "id"                      SERIAL NOT NULL,
    "column_layout_name_id"   INTEGER NOT NULL,
    "line_no"                 INTEGER NOT NULL DEFAULT 0,
    "column_no"               TEXT   NOT NULL DEFAULT '',
    "column_header"           TEXT   NOT NULL DEFAULT '',
    -- NET_CHANGE | BALANCE_AT_DATE | BEGINNING_BALANCE | YEAR_TO_DATE | ENTIRE_FISCAL_YEAR | FORMULA
    "column_type"             TEXT   NOT NULL DEFAULT 'NET_CHANGE',
    -- ENTRIES (modelled; BUDGET_ENTRIES reserved — no G/L budgets yet)
    "ledger_entry_type"       TEXT   NOT NULL DEFAULT 'ENTRIES',
    -- NET_AMOUNT | DEBIT_AMOUNT | CREDIT_AMOUNT
    "amount_type"             TEXT   NOT NULL DEFAULT 'NET_AMOUNT',
    "formula"                 TEXT   NOT NULL DEFAULT '',
    -- Business Central "DateFormula", e.g. -1Y for a prior-year column (see lib/dateFormula.ts)
    "comparison_date_formula" TEXT   NOT NULL DEFAULT '',
    -- ALWAYS | NEVER | WHEN_POSITIVE | WHEN_NEGATIVE
    "show"                    TEXT   NOT NULL DEFAULT 'ALWAYS',
    -- NONE | 1 | 1000 | 1000000
    "rounding_factor"         TEXT   NOT NULL DEFAULT 'NONE',
    "created_at"              TEXT,
    "created_by"              TEXT,

    CONSTRAINT "column_layout_pkey" PRIMARY KEY ("id")
);
CREATE INDEX "ix_column_layout_name" ON "column_layout"("column_layout_name_id");
ALTER TABLE "column_layout" ADD CONSTRAINT "column_layout_column_layout_name_id_fkey"
    FOREIGN KEY ("column_layout_name_id") REFERENCES "column_layout_name"("id") ON DELETE CASCADE ON UPDATE NO ACTION;

-- ============================================================================= row definitions

-- Business Central Table 85 "Acc. Schedule Name" (the Row Definition).
CREATE TABLE "acc_schedule_name" (
    "id"                          SERIAL NOT NULL,
    "name"                        TEXT   NOT NULL,
    "description"                 TEXT   NOT NULL DEFAULT '',
    "default_column_layout_name"  TEXT,
    "created_at"                  TEXT,
    "created_by"                  TEXT,

    CONSTRAINT "acc_schedule_name_pkey" PRIMARY KEY ("id")
);
CREATE UNIQUE INDEX "acc_schedule_name_name_key" ON "acc_schedule_name"("name");

-- Business Central Table 86 "Acc. Schedule Line".
CREATE TABLE "acc_schedule_line" (
    "id"                    SERIAL NOT NULL,
    "acc_schedule_name_id"  INTEGER NOT NULL,
    "line_no"               INTEGER NOT NULL DEFAULT 0,
    "row_no"                TEXT   NOT NULL DEFAULT '',
    "description"           TEXT   NOT NULL DEFAULT '',
    -- POSTING_ACCOUNTS | TOTAL_ACCOUNTS | FORMULA | SET_BASE_FOR_PERCENT
    "totaling_type"         TEXT   NOT NULL DEFAULT 'POSTING_ACCOUNTS',
    -- G/L account filter "A..B|C" for account rows, or the expression for FORMULA rows
    "totaling"              TEXT   NOT NULL DEFAULT '',
    -- NET_AMOUNT | DEBIT_AMOUNT | CREDIT_AMOUNT
    "amount_type"           TEXT   NOT NULL DEFAULT 'NET_AMOUNT',
    -- NET_CHANGE | BALANCE_AT_DATE | BEGINNING_BALANCE (overrides the column's window when not NET_CHANGE)
    "row_type"              TEXT   NOT NULL DEFAULT 'NET_CHANGE',
    -- YES | NO | IF_ANY_NOT_ZERO | IF_ALL_ZERO
    "show"                  TEXT   NOT NULL DEFAULT 'YES',
    "bold"                  INTEGER NOT NULL DEFAULT 0,
    "italic"               INTEGER NOT NULL DEFAULT 0,
    "underline"            INTEGER NOT NULL DEFAULT 0,
    "double_underline"    INTEGER NOT NULL DEFAULT 0,
    "show_opposite_sign"  INTEGER NOT NULL DEFAULT 0,
    "new_page"            INTEGER NOT NULL DEFAULT 0,
    "indentation"        INTEGER NOT NULL DEFAULT 0,
    -- Global Dimension code filter expressions (see lib/gl.ts resolveDimensionFilterIds)
    "dimension_1_totaling" TEXT   NOT NULL DEFAULT '',
    "dimension_2_totaling" TEXT   NOT NULL DEFAULT '',
    "created_at"           TEXT,
    "created_by"           TEXT,

    CONSTRAINT "acc_schedule_line_pkey" PRIMARY KEY ("id")
);
CREATE INDEX "ix_acc_schedule_line_name" ON "acc_schedule_line"("acc_schedule_name_id");
ALTER TABLE "acc_schedule_line" ADD CONSTRAINT "acc_schedule_line_acc_schedule_name_id_fkey"
    FOREIGN KEY ("acc_schedule_name_id") REFERENCES "acc_schedule_name"("id") ON DELETE CASCADE ON UPDATE NO ACTION;

-- ============================================================================= financial report

-- Business Central Table 133 "Financial Report" — pairs a row group with a column group.
CREATE TABLE "financial_report" (
    "id"           SERIAL NOT NULL,
    "name"         TEXT   NOT NULL,
    "description"  TEXT   NOT NULL DEFAULT '',
    "row_group"    TEXT   NOT NULL DEFAULT '',
    "column_group" TEXT   NOT NULL DEFAULT '',
    "created_at"   TEXT,
    "created_by"   TEXT,

    CONSTRAINT "financial_report_pkey" PRIMARY KEY ("id")
);
CREATE UNIQUE INDEX "financial_report_name_key" ON "financial_report"("name");

-- ============================================================================= seed default content
-- Guarded on an existing organisation so a fresh DB is populated by lib/seed.ts instead, and an
-- already-seeded DB gets the same starter reports on migrate.

INSERT INTO "column_layout_name" ("name", "description", "created_by")
SELECT v.name, v.description, 'system'
FROM (VALUES
  ('DEFAULT',      'Single net-change column'),
  ('BALANCE',      'Single balance-at-date column'),
  ('THIS-VS-LAST', 'This year, last year and the % change'),
  ('YTD-BAL',      'Year to date and closing balance')
) AS v(name, description)
WHERE EXISTS (SELECT 1 FROM "organisation")
ON CONFLICT ("name") DO NOTHING;

INSERT INTO "column_layout"
  ("column_layout_name_id", "line_no", "column_no", "column_header", "column_type", "amount_type", "formula", "comparison_date_formula", "created_by")
SELECT n.id, v.line_no, v.column_no, v.column_header, v.column_type, v.amount_type, v.formula, v.cmp, 'system'
FROM "column_layout_name" n
JOIN (VALUES
  ('DEFAULT',      10000, 'NET', 'Net Change',   'NET_CHANGE',      'NET_AMOUNT', '',                '',   ''),
  ('BALANCE',      10000, 'BAL', 'Balance',      'BALANCE_AT_DATE', 'NET_AMOUNT', '',                '',   ''),
  ('THIS-VS-LAST', 10000, 'TY',  'This Year',    'NET_CHANGE',      'NET_AMOUNT', '',                '',   ''),
  ('THIS-VS-LAST', 20000, 'LY',  'Last Year',    'NET_CHANGE',      'NET_AMOUNT', '',                '-1Y', ''),
  ('THIS-VS-LAST', 30000, 'CHG', 'Change %',     'FORMULA',         'NET_AMOUNT', '(TY-LY)/LY*100',  '',   ''),
  ('YTD-BAL',      10000, 'YTD', 'Year to Date', 'YEAR_TO_DATE',    'NET_AMOUNT', '',                '',   ''),
  ('YTD-BAL',      20000, 'BAL', 'Balance',      'BALANCE_AT_DATE', 'NET_AMOUNT', '',                '',   '')
) AS v(layout, line_no, column_no, column_header, column_type, amount_type, formula, cmp, unused) ON v.layout = n.name
WHERE EXISTS (SELECT 1 FROM "organisation")
  AND NOT EXISTS (SELECT 1 FROM "column_layout" c WHERE c.column_layout_name_id = n.id);

INSERT INTO "acc_schedule_name" ("name", "description", "default_column_layout_name", "created_by")
SELECT v.name, v.description, v.dcl, 'system'
FROM (VALUES
  ('SACCO-BS',  'Statement of Financial Position', 'BALANCE'),
  ('SACCO-PL',  'Statement of Comprehensive Income', 'THIS-VS-LAST'),
  ('SASRA-CAP', 'Capital Adequacy ratios (SASRA)', 'DEFAULT'),
  ('SASRA-LIQ', 'Liquidity ratio (SASRA)', 'DEFAULT')
) AS v(name, description, dcl)
WHERE EXISTS (SELECT 1 FROM "organisation")
ON CONFLICT ("name") DO NOTHING;

INSERT INTO "acc_schedule_line"
  ("acc_schedule_name_id", "line_no", "row_no", "description", "totaling_type", "totaling", "row_type", "show", "bold", "double_underline", "indentation")
SELECT n.id, v.line_no, v.row_no, v.description, v.totaling_type, v.totaling, v.row_type, v.show, v.bold, v.dunder, v.indent
FROM "acc_schedule_name" n
JOIN (VALUES
  -- SACCO-BS  Statement of Financial Position
  ('SACCO-BS', 10000, 'CA',   'Current assets',                       'TOTAL_ACCOUNTS', '1000..1299', 'BALANCE_AT_DATE', 'YES',            0, 0, 1),
  ('SACCO-BS', 20000, 'PPE',  'Property, plant and equipment',        'TOTAL_ACCOUNTS', '1300..1499', 'BALANCE_AT_DATE', 'YES',            0, 0, 1),
  ('SACCO-BS', 30000, 'TA',   'Total assets',                         'FORMULA',        'CA+PPE',     'BALANCE_AT_DATE', 'YES',            1, 1, 0),
  ('SACCO-BS', 40000, 'DEP',  'Member deposits',                      'TOTAL_ACCOUNTS', '2000..2099', 'BALANCE_AT_DATE', 'YES',            0, 0, 1),
  ('SACCO-BS', 50000, 'OL',   'Other liabilities',                    'TOTAL_ACCOUNTS', '2100..2199', 'BALANCE_AT_DATE', 'YES',            0, 0, 1),
  ('SACCO-BS', 60000, 'TL',   'Total liabilities',                    'FORMULA',        'DEP+OL',     'BALANCE_AT_DATE', 'YES',            1, 0, 0),
  ('SACCO-BS', 70000, 'EQ',   'Capital and reserves',                 'TOTAL_ACCOUNTS', '3000..3099', 'BALANCE_AT_DATE', 'YES',            0, 0, 1),
  ('SACCO-BS', 80000, 'INC',  'Income (period)',                      'TOTAL_ACCOUNTS', '4000..4999', 'BALANCE_AT_DATE', 'NO',             0, 0, 0),
  ('SACCO-BS', 90000, 'EXP',  'Expenditure (period)',                 'TOTAL_ACCOUNTS', '5000..5999', 'BALANCE_AT_DATE', 'NO',             0, 0, 0),
  ('SACCO-BS', 100000, 'SURP', 'Surplus for the period',              'FORMULA',        'INC-EXP',    'BALANCE_AT_DATE', 'YES',            0, 0, 1),
  ('SACCO-BS', 110000, 'TE',   'Total equity',                        'FORMULA',        'EQ+SURP',    'BALANCE_AT_DATE', 'YES',            1, 0, 0),
  ('SACCO-BS', 120000, 'TLE',  'Total equity and liabilities',        'FORMULA',        'TL+TE',      'BALANCE_AT_DATE', 'YES',            1, 1, 0),
  ('SACCO-BS', 130000, 'CHK',  'Balance check (assets less equity and liabilities)', 'FORMULA', 'TA-TLE', 'BALANCE_AT_DATE', 'IF_ANY_NOT_ZERO', 0, 0, 0),
  -- SACCO-PL  Statement of Comprehensive Income
  ('SACCO-PL', 10000, 'II',   'Interest on member loans',             'POSTING_ACCOUNTS', '4010',       'NET_CHANGE', 'YES', 0, 0, 1),
  ('SACCO-PL', 20000, 'FEE',  'Fees, commissions and other income',   'TOTAL_ACCOUNTS',   '4020..4099', 'NET_CHANGE', 'YES', 0, 0, 1),
  ('SACCO-PL', 30000, 'TINC', 'Total income',                         'FORMULA',          'II+FEE',     'NET_CHANGE', 'YES', 1, 0, 0),
  ('SACCO-PL', 40000, 'FIN',  'Interest on member deposits',          'POSTING_ACCOUNTS', '5010',       'NET_CHANGE', 'YES', 0, 0, 1),
  ('SACCO-PL', 50000, 'STAFF','Staff costs',                          'POSTING_ACCOUNTS', '5020',       'NET_CHANGE', 'YES', 0, 0, 1),
  ('SACCO-PL', 60000, 'ADMIN','Administrative and other expenses',    'TOTAL_ACCOUNTS',   '5030..5099', 'NET_CHANGE', 'YES', 0, 0, 1),
  ('SACCO-PL', 70000, 'TEXP', 'Total expenditure',                    'FORMULA',          'FIN+STAFF+ADMIN', 'NET_CHANGE', 'YES', 1, 0, 0),
  ('SACCO-PL', 80000, 'SURP', 'Surplus for the period',               'FORMULA',          'TINC-TEXP',  'NET_CHANGE', 'YES', 1, 1, 0),
  -- SASRA-CAP  Capital Adequacy
  ('SASRA-CAP', 10000, 'CORE', 'Core capital',                        'TOTAL_ACCOUNTS', '3010..3020', 'BALANCE_AT_DATE', 'YES', 0, 0, 0),
  ('SASRA-CAP', 20000, 'INST', 'Institutional capital',               'TOTAL_ACCOUNTS', '3020..3030', 'BALANCE_AT_DATE', 'YES', 0, 0, 0),
  ('SASRA-CAP', 30000, 'TA',   'Total assets',                        'TOTAL_ACCOUNTS', '1000..1499', 'BALANCE_AT_DATE', 'YES', 0, 0, 0),
  ('SASRA-CAP', 40000, 'TD',   'Total deposits',                      'TOTAL_ACCOUNTS', '2000..2099', 'BALANCE_AT_DATE', 'YES', 0, 0, 0),
  ('SASRA-CAP', 50000, 'R1',   'Core capital / total assets (%) — min 10%',    'FORMULA', 'CORE/TA*100', 'BALANCE_AT_DATE', 'YES', 1, 0, 0),
  ('SASRA-CAP', 60000, 'R2',   'Core capital / total deposits (%) — min 8%',   'FORMULA', 'CORE/TD*100', 'BALANCE_AT_DATE', 'YES', 1, 0, 0),
  ('SASRA-CAP', 70000, 'R3',   'Institutional capital / total assets (%) — min 8%', 'FORMULA', 'INST/TA*100', 'BALANCE_AT_DATE', 'YES', 1, 0, 0),
  -- SASRA-LIQ  Liquidity
  ('SASRA-LIQ', 10000, 'LA',   'Liquid assets',                       'TOTAL_ACCOUNTS', '1000..1099', 'BALANCE_AT_DATE', 'YES', 0, 0, 0),
  ('SASRA-LIQ', 20000, 'DEP',  'Member deposits',                     'TOTAL_ACCOUNTS', '2000..2099', 'BALANCE_AT_DATE', 'YES', 0, 0, 0),
  ('SASRA-LIQ', 30000, 'PAY',  'Payables and accruals',               'TOTAL_ACCOUNTS', '2100..2199', 'BALANCE_AT_DATE', 'YES', 0, 0, 0),
  ('SASRA-LIQ', 40000, 'STL',  'Short-term liabilities',              'FORMULA',        'DEP+PAY',     'BALANCE_AT_DATE', 'YES', 1, 0, 0),
  ('SASRA-LIQ', 50000, 'RATIO','Liquidity ratio (%) — min 15%',       'FORMULA',        'LA/STL*100',  'BALANCE_AT_DATE', 'YES', 1, 0, 0)
) AS v(sched, line_no, row_no, description, totaling_type, totaling, row_type, show, bold, dunder, indent) ON v.sched = n.name
WHERE EXISTS (SELECT 1 FROM "organisation")
  AND NOT EXISTS (SELECT 1 FROM "acc_schedule_line" l WHERE l.acc_schedule_name_id = n.id);

INSERT INTO "financial_report" ("name", "description", "row_group", "column_group", "created_by")
SELECT v.name, v.description, v.row_group, v.column_group, 'system'
FROM (VALUES
  ('STMT-FIN-POSITION',      'Statement of Financial Position',   'SACCO-BS',  'BALANCE'),
  ('STMT-COMPR-INCOME',      'Statement of Comprehensive Income', 'SACCO-PL',  'THIS-VS-LAST'),
  ('SASRA-CAPITAL-ADEQUACY', 'SASRA Capital Adequacy Return',     'SASRA-CAP', 'DEFAULT'),
  ('SASRA-LIQUIDITY',        'SASRA Liquidity Return',            'SASRA-LIQ', 'DEFAULT')
) AS v(name, description, row_group, column_group)
WHERE EXISTS (SELECT 1 FROM "organisation")
ON CONFLICT ("name") DO NOTHING;

-- ============================================================================= permission backfill

INSERT INTO "permission_set_line"
  ("role_id", "object_type", "object_name", "read_perm", "insert_perm", "modify_perm", "delete_perm", "execute_perm")
SELECT r.id, g.object_type, g.object_name, g.r, g.i, g.m, g.d, g.e
FROM "role" r
JOIN (VALUES
  ('Finance Officer',  'PAGE',  'FINANCIAL_REPORTS',   0,0,0,0,1),
  ('Finance Officer',  'TABLE', 'column_layout_name',  1,1,1,1,0),
  ('Finance Officer',  'TABLE', 'column_layout',       1,1,1,1,0),
  ('Finance Officer',  'TABLE', 'acc_schedule_name',   1,1,1,1,0),
  ('Finance Officer',  'TABLE', 'acc_schedule_line',   1,1,1,1,0),
  ('Finance Officer',  'TABLE', 'financial_report',    1,1,1,1,0),
  ('Branch Manager',   'PAGE',  'FINANCIAL_REPORTS',   0,0,0,0,1),
  ('Branch Manager',   'TABLE', 'column_layout_name',  1,0,0,0,0),
  ('Branch Manager',   'TABLE', 'column_layout',       1,0,0,0,0),
  ('Branch Manager',   'TABLE', 'acc_schedule_name',   1,0,0,0,0),
  ('Branch Manager',   'TABLE', 'acc_schedule_line',   1,0,0,0,0),
  ('Branch Manager',   'TABLE', 'financial_report',    1,0,0,0,0),
  ('Internal Auditor', 'PAGE',  'FINANCIAL_REPORTS',   0,0,0,0,1),
  ('Internal Auditor', 'TABLE', 'column_layout_name',  1,0,0,0,0),
  ('Internal Auditor', 'TABLE', 'column_layout',       1,0,0,0,0),
  ('Internal Auditor', 'TABLE', 'acc_schedule_name',   1,0,0,0,0),
  ('Internal Auditor', 'TABLE', 'acc_schedule_line',   1,0,0,0,0),
  ('Internal Auditor', 'TABLE', 'financial_report',    1,0,0,0,0)
) AS g(role_name, object_type, object_name, r, i, m, d, e) ON g.role_name = r.name
ON CONFLICT ("role_id", "object_type", "object_name") DO UPDATE SET
  "read_perm"    = GREATEST("permission_set_line"."read_perm",    EXCLUDED."read_perm"),
  "insert_perm"  = GREATEST("permission_set_line"."insert_perm",  EXCLUDED."insert_perm"),
  "modify_perm"  = GREATEST("permission_set_line"."modify_perm",  EXCLUDED."modify_perm"),
  "delete_perm"  = GREATEST("permission_set_line"."delete_perm",  EXCLUDED."delete_perm"),
  "execute_perm" = GREATEST("permission_set_line"."execute_perm", EXCLUDED."execute_perm");
