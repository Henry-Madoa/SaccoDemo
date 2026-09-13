-- Share Trading — AL Tab52204133 "Share Trading Setup", Tab52204134 "Share Floating",
-- Tab52204135 "Share Trading Lines", Tab52204136 "Share Transfer Receipt" and
-- Cod52204022 "Share Trading Mgmt".
--
-- A member floats some or all of their share capital for sale; other members bid; the highest
-- bid is awarded; the buyer pays from their deposit accounts; the shares move from seller to
-- buyer at par and the proceeds go to the seller at the bid price. The whole thing runs through
-- one Holding account that nets to zero on a completed trade, and a Clearing account that
-- carries the buyer's debt between the award and the payment.

-- ============================================================================= G/L accounts
-- Inside the existing Begin/End-Total brackets, as the dividend accounts were:
--   1255 sits inside TRADE AND OTHER RECEIVABLES (1240..1299) — what awarded buyers owe
--   2135 sits inside OTHER LIABILITIES           (2100..2199) — shares in transit
INSERT INTO "gl_account" ("code", "name", "type", "parent_code", "is_postable", "account_type", "indentation", "status")
SELECT * FROM (VALUES
  ('1255', 'Share Trading Clearing — Buyers', 'ASSET', '1240', 1, 'POSTING', 1, 'ACTIVE'),
  ('2135', 'Share Trading Holding', 'LIABILITY', '2100', 1, 'POSTING', 1, 'ACTIVE')
) AS v(code, name, type, parent_code, is_postable, account_type, indentation, status)
WHERE EXISTS (SELECT 1 FROM "organisation")
ON CONFLICT ("code") DO NOTHING;

-- ============================================================================= tables

-- AL Tab52204133: the market a floating is sold in. Only one is Published at a time.
CREATE TABLE "share_trading_window" (
  "no"                      TEXT NOT NULL,
  "description"             TEXT NOT NULL,
  "start_date"              TEXT NOT NULL,
  "end_date"                TEXT NOT NULL,
  -- Par value per share — what a share is worth on the books and the ceiling on any bid.
  "base_price"              BIGINT NOT NULL DEFAULT 0,
  -- The floor: a seller cannot ask less than this per share.
  "reserve_price"           BIGINT NOT NULL DEFAULT 0,
  "transaction_charge_id"   INTEGER,
  "clearing_account_id"     INTEGER NOT NULL,
  "holding_account_id"      INTEGER NOT NULL,
  -- Date formulas (30D, 2W, 1M …) — how long a published floating stays on the market, and how
  -- long an awarded buyer has to pay.
  "share_life"              TEXT,
  "tolerance_period"        TEXT,
  -- What happens to a floating that reaches its expiry with no bids.
  "on_no_bid"               TEXT NOT NULL DEFAULT 'Extend',
  "minimum_shares_to_float" INTEGER NOT NULL DEFAULT 0,
  "published"               BOOLEAN NOT NULL DEFAULT false,
  "status"                  TEXT NOT NULL DEFAULT 'New',
  "created_at"              TEXT,
  "created_by"              TEXT,
  CONSTRAINT "share_trading_window_pkey" PRIMARY KEY ("no"),
  CONSTRAINT "stw_charge_fkey" FOREIGN KEY ("transaction_charge_id") REFERENCES "transaction_charge"("id") ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT "stw_clearing_fkey" FOREIGN KEY ("clearing_account_id") REFERENCES "gl_account"("id") ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT "stw_holding_fkey" FOREIGN KEY ("holding_account_id") REFERENCES "gl_account"("id") ON DELETE NO ACTION ON UPDATE NO ACTION
);
CREATE INDEX "ix_stw_status" ON "share_trading_window"("status");

-- AL Tab52204134: one member's offer to sell.
CREATE TABLE "share_floating" (
  "no"                       TEXT NOT NULL,
  "window_no"                TEXT NOT NULL,
  "member_id"                INTEGER NOT NULL,
  -- The seller's share capital account: what the shares leave.
  "share_account_id"         INTEGER NOT NULL,
  "float_type"               TEXT NOT NULL DEFAULT 'Partial',
  -- Copied from the window when the floating is raised, so a later window edit never changes
  -- the terms of a sale already on the market.
  "par_value"                BIGINT NOT NULL DEFAULT 0,
  "reserve_price"            BIGINT NOT NULL DEFAULT 0,
  "share_life"               TEXT,
  "tolerance_period"         TEXT,
  "on_no_bid"                TEXT NOT NULL DEFAULT 'Extend',
  -- Whole shares the member holds when the floating is raised (balance / par).
  "total_shares"             INTEGER NOT NULL DEFAULT 0,
  "shares_to_float"          INTEGER NOT NULL DEFAULT 0,
  "minimum_acceptable_price" BIGINT NOT NULL DEFAULT 0,
  -- shares_to_float × par_value: what leaves the seller's account on publish.
  "floated_value"            BIGINT NOT NULL DEFAULT 0,
  -- The window's charge on the floated value; the buyer pays it on top of the bid.
  "charge_amount"            BIGINT NOT NULL DEFAULT 0,
  -- Where the seller's money goes on transfer: one of their own deposit accounts.
  "proceeds_type"            TEXT NOT NULL DEFAULT 'FOSA Account',
  "proceeds_account_id"      INTEGER,
  "payment_method_code"      TEXT,
  "external_reference_no"    TEXT,
  "payment_date"             TEXT,
  "source"                   TEXT NOT NULL DEFAULT 'Walking',
  "narration"                TEXT,
  -- Maker-checker, then the market flags AL keeps beside the status.
  "status"                   TEXT NOT NULL DEFAULT 'Open',
  "decision_reason"          TEXT,
  "published"                BOOLEAN NOT NULL DEFAULT false,
  "published_on"             TEXT,
  "expiry_date"              TEXT,
  "awarded"                  BOOLEAN NOT NULL DEFAULT false,
  "purchase_date"            TEXT,
  "payment_due_date"         TEXT,
  "archived"                 BOOLEAN NOT NULL DEFAULT false,
  -- How it ended: Transferred, Taken Down, or Reversed (expired with no bid).
  "outcome"                  TEXT,
  "publish_journal_id"       INTEGER,
  "purchase_journal_id"      INTEGER,
  "transfer_journal_id"      INTEGER,
  "takedown_journal_id"      INTEGER,
  "global_dimension_1_id"    INTEGER,
  "global_dimension_2_id"    INTEGER,
  "created_at"               TEXT,
  "created_by"               TEXT,
  "transferred_at"           TEXT,
  "transferred_by"           TEXT,
  CONSTRAINT "share_floating_pkey" PRIMARY KEY ("no"),
  CONSTRAINT "sfl_window_fkey" FOREIGN KEY ("window_no") REFERENCES "share_trading_window"("no") ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT "sfl_member_fkey" FOREIGN KEY ("member_id") REFERENCES "member"("id") ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT "sfl_share_account_fkey" FOREIGN KEY ("share_account_id") REFERENCES "savings_account"("id") ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT "sfl_proceeds_account_fkey" FOREIGN KEY ("proceeds_account_id") REFERENCES "savings_account"("id") ON DELETE NO ACTION ON UPDATE NO ACTION
);
CREATE INDEX "ix_sfl_member" ON "share_floating"("member_id");
CREATE INDEX "ix_sfl_window" ON "share_floating"("window_no");
CREATE INDEX "ix_sfl_status" ON "share_floating"("status");
CREATE INDEX "ix_sfl_created_by" ON "share_floating"("created_by");

-- AL Tab52204135: a member's bid on a floating. One per member per floating.
CREATE TABLE "share_bid" (
  "id"               SERIAL NOT NULL,
  "floating_no"      TEXT NOT NULL,
  "member_id"        INTEGER NOT NULL,
  -- The bidder's share capital account: where the shares land if they win.
  "share_account_id" INTEGER NOT NULL,
  "bid_price"        BIGINT NOT NULL DEFAULT 0,
  "bid_date"         TEXT NOT NULL,
  "shares"           INTEGER NOT NULL DEFAULT 0,
  "charges"          BIGINT NOT NULL DEFAULT 0,
  -- shares × bid_price + charges: what the winner pays.
  "total_amount"     BIGINT NOT NULL DEFAULT 0,
  "awarded"          BOOLEAN NOT NULL DEFAULT false,
  "bought"           BOOLEAN NOT NULL DEFAULT false,
  "source"           TEXT NOT NULL DEFAULT 'Walking',
  "created_by"       TEXT,
  CONSTRAINT "share_bid_pkey" PRIMARY KEY ("id"),
  CONSTRAINT "sbid_floating_fkey" FOREIGN KEY ("floating_no") REFERENCES "share_floating"("no") ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT "sbid_member_fkey" FOREIGN KEY ("member_id") REFERENCES "member"("id") ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT "sbid_share_account_fkey" FOREIGN KEY ("share_account_id") REFERENCES "savings_account"("id") ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT "sbid_one_per_member" UNIQUE ("floating_no", "member_id")
);
CREATE INDEX "ix_sbid_floating" ON "share_bid"("floating_no");

-- AL Tab52204136: how the awarded buyer pays — amounts allocated from their deposit accounts,
-- taken on transfer. They must add up to the winning bid's total before shares can move.
CREATE TABLE "share_transfer_receipt" (
  "id"                 SERIAL NOT NULL,
  "floating_no"        TEXT NOT NULL,
  "savings_account_id" INTEGER NOT NULL,
  "allocated_amount"   BIGINT NOT NULL DEFAULT 0,
  "description"        TEXT,
  "created_at"         TEXT,
  "created_by"         TEXT,
  CONSTRAINT "share_transfer_receipt_pkey" PRIMARY KEY ("id"),
  CONSTRAINT "str_floating_fkey" FOREIGN KEY ("floating_no") REFERENCES "share_floating"("no") ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT "str_account_fkey" FOREIGN KEY ("savings_account_id") REFERENCES "savings_account"("id") ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT "str_one_per_account" UNIQUE ("floating_no", "savings_account_id")
);

-- ============================================================================= No. Series
-- AL General Ledger Setup "Share Trading Nos." and "Share Bid Nos.".
INSERT INTO "sequence" ("name", "prefix", "next_no", "width")
SELECT * FROM (VALUES
  ('SHARE_TRADING_WINDOW', 'STW', 1, 4),
  ('SHARE_FLOATING', 'SFL', 1, 5)
) AS v(name, prefix, next_no, width)
WHERE EXISTS (SELECT 1 FROM "organisation")
ON CONFLICT ("name") DO NOTHING;

INSERT INTO "no_series" ("code", "description", "default_nos", "manual_nos", "date_order")
SELECT * FROM (VALUES
  ('SHARE_TRADING_WINDOW', 'Share Trading Window No.', 1, 0, 0),
  ('SHARE_FLOATING', 'Share Floating No.', 1, 0, 0)
) AS v(code, description, default_nos, manual_nos, date_order)
WHERE EXISTS (SELECT 1 FROM "organisation")
ON CONFLICT ("code") DO NOTHING;

INSERT INTO "no_series_line" ("series_code", "line_no", "starting_date", "starting_no", "increment_by_no", "open", "allow_gaps")
SELECT s.name, 10000, NULL, s.prefix || LPAD(s.next_no::text, s.width, '0'), 1, 1, 0
FROM "sequence" s
WHERE s.name IN ('SHARE_TRADING_WINDOW', 'SHARE_FLOATING')
  AND EXISTS (SELECT 1 FROM "organisation")
  AND NOT EXISTS (SELECT 1 FROM "no_series_line" l WHERE l.series_code = s.name);

INSERT INTO "no_series_setup" ("document_code", "label", "category", "sort", "series_code")
SELECT v.code, v.label, 'Finance', v.sort, v.code
FROM (VALUES
  ('SHARE_TRADING_WINDOW', 'Share Trading Window No.', 93),
  ('SHARE_FLOATING', 'Share Floating No.', 94)
) AS v(code, label, sort)
WHERE EXISTS (SELECT 1 FROM "organisation")
ON CONFLICT ("document_code") DO NOTHING;

-- ============================================================================= permission backfill
-- Mirrors the ROLES action lists in lib/seed.ts; GREATEST keeps any right already held.
INSERT INTO "permission_set_line"
  ("role_id", "object_type", "object_name", "read_perm", "insert_perm", "modify_perm", "delete_perm", "execute_perm")
SELECT r.id, g.object_type, g.object_name, g.r, g.i, g.m, g.d, g.e
FROM "role" r
JOIN (VALUES
  ('Finance Officer',  'PAGE',  'SHARE_TRADING',          0,0,0,0,1),
  ('Finance Officer',  'TABLE', 'share_trading_window',   1,1,1,1,0),
  ('Finance Officer',  'TABLE', 'share_floating',         1,1,1,1,0),
  ('Finance Officer',  'TABLE', 'share_bid',              1,1,1,1,0),
  ('Finance Officer',  'TABLE', 'share_transfer_receipt', 1,1,1,1,0),
  ('Finance Officer',  'TABLE', 'savings_account',        1,0,1,0,0),
  ('Finance Officer',  'TABLE', 'journal',                1,1,0,0,0),
  ('Finance Officer',  'TABLE', 'journal_line',           1,1,0,0,0),
  ('Finance Officer',  'TABLE', 'txn',                    1,1,0,0,0),
  ('Finance Manager',  'PAGE',  'SHARE_TRADING',          0,0,0,0,1),
  ('Finance Manager',  'TABLE', 'share_trading_window',   1,1,1,1,0),
  ('Finance Manager',  'TABLE', 'share_floating',         1,1,1,1,0),
  ('Finance Manager',  'TABLE', 'share_bid',              1,1,1,1,0),
  ('Finance Manager',  'TABLE', 'share_transfer_receipt', 1,1,1,1,0),
  ('Finance Manager',  'TABLE', 'savings_account',        1,0,1,0,0),
  ('Finance Manager',  'TABLE', 'journal',                1,1,0,0,0),
  ('Finance Manager',  'TABLE', 'journal_line',           1,1,0,0,0),
  ('Finance Manager',  'TABLE', 'txn',                    1,1,0,0,0),
  ('Branch Manager',   'PAGE',  'SHARE_TRADING',          0,0,0,0,1),
  ('Branch Manager',   'TABLE', 'share_trading_window',   1,0,0,0,0),
  ('Branch Manager',   'TABLE', 'share_floating',         1,1,1,1,0),
  ('Branch Manager',   'TABLE', 'share_bid',              1,1,1,1,0),
  ('Branch Manager',   'TABLE', 'share_transfer_receipt', 1,1,1,1,0),
  ('Branch Manager',   'TABLE', 'savings_account',        1,0,1,0,0),
  ('Branch Manager',   'TABLE', 'journal',                1,1,0,0,0),
  ('Branch Manager',   'TABLE', 'journal_line',           1,1,0,0,0),
  ('Branch Manager',   'TABLE', 'txn',                    1,1,0,0,0),
  ('Internal Auditor', 'PAGE',  'SHARE_TRADING',          0,0,0,0,1),
  ('Internal Auditor', 'TABLE', 'share_trading_window',   1,0,0,0,0),
  ('Internal Auditor', 'TABLE', 'share_floating',         1,0,0,0,0),
  ('Internal Auditor', 'TABLE', 'share_bid',              1,0,0,0,0),
  ('Internal Auditor', 'TABLE', 'share_transfer_receipt', 1,0,0,0,0)
) AS g(role_name, object_type, object_name, r, i, m, d, e) ON g.role_name = r.name
ON CONFLICT ("role_id", "object_type", "object_name") DO UPDATE SET
  "read_perm"    = GREATEST("permission_set_line"."read_perm",    EXCLUDED."read_perm"),
  "insert_perm"  = GREATEST("permission_set_line"."insert_perm",  EXCLUDED."insert_perm"),
  "modify_perm"  = GREATEST("permission_set_line"."modify_perm",  EXCLUDED."modify_perm"),
  "delete_perm"  = GREATEST("permission_set_line"."delete_perm",  EXCLUDED."delete_perm"),
  "execute_perm" = GREATEST("permission_set_line"."execute_perm", EXCLUDED."execute_perm");
