-- FOSA Tellering — grant the two new operational modules (and the Teller Setup / Denominations
-- masters) to the seeded roles, keyed by role NAME so this is deterministic on any install
-- regardless of which incidental grant the previous migration's heuristic backfill happened to
-- match. Mirrors the ROLES action lists in lib/seed.ts. GREATEST() keeps any right a role
-- already holds. System Administrator is is_system and bypasses permission lines entirely.

INSERT INTO "permission_set_line"
  ("role_id", "object_type", "object_name", "read_perm", "insert_perm", "modify_perm", "delete_perm", "execute_perm")
SELECT r.id, g.object_type, g.object_name, g.r, g.i, g.m, g.d, g.e
FROM "role" r
JOIN (VALUES
  -- Branch Manager: full maker-checker + post on both modules; manages Teller Setup; reads Denominations
  ('Branch Manager', 'PAGE',  'CASH_MANAGEMENT',           0,0,0,0,1),
  ('Branch Manager', 'PAGE',  'TELLER_TRANSACTIONS',       0,0,0,0,1),
  ('Branch Manager', 'PAGE',  'ADMIN_TELLER_SETUP',        0,0,0,0,1),
  ('Branch Manager', 'PAGE',  'ADMIN_POOL_DENOMINATIONS',  0,0,0,0,1),
  ('Branch Manager', 'TABLE', 'fosa_transaction',          1,1,1,1,0),
  ('Branch Manager', 'TABLE', 'teller_transaction',        1,1,1,1,0),
  ('Branch Manager', 'TABLE', 'cash_denomination_line',    1,1,1,1,0),
  ('Branch Manager', 'TABLE', 'bank_account_ledger_entry', 0,1,0,0,0),
  ('Branch Manager', 'TABLE', 'teller_setup',              1,1,1,1,0),
  ('Branch Manager', 'TABLE', 'denomination',              1,0,0,0,0),

  -- Teller: create + post on both modules (approval only where the amount forces it)
  ('Teller', 'PAGE',  'CASH_MANAGEMENT',           0,0,0,0,1),
  ('Teller', 'PAGE',  'TELLER_TRANSACTIONS',       0,0,0,0,1),
  ('Teller', 'TABLE', 'fosa_transaction',          1,1,1,1,0),
  ('Teller', 'TABLE', 'teller_transaction',        1,1,1,1,0),
  ('Teller', 'TABLE', 'cash_denomination_line',    1,1,1,1,0),
  ('Teller', 'TABLE', 'bank_account_ledger_entry', 0,1,0,0,0),

  -- Finance Officer: runs the vault (create/approve/post cash movements); approves teller txns
  ('Finance Officer', 'PAGE',  'CASH_MANAGEMENT',           0,0,0,0,1),
  ('Finance Officer', 'PAGE',  'TELLER_TRANSACTIONS',       0,0,0,0,1),
  ('Finance Officer', 'TABLE', 'fosa_transaction',          1,1,1,1,0),
  ('Finance Officer', 'TABLE', 'teller_transaction',        1,0,1,0,0),
  ('Finance Officer', 'TABLE', 'cash_denomination_line',    1,1,1,1,0),
  ('Finance Officer', 'TABLE', 'bank_account_ledger_entry', 0,1,0,0,0),

  -- Internal Auditor: read-only
  ('Internal Auditor', 'PAGE',  'CASH_MANAGEMENT',          0,0,0,0,1),
  ('Internal Auditor', 'PAGE',  'TELLER_TRANSACTIONS',      0,0,0,0,1),
  ('Internal Auditor', 'PAGE',  'ADMIN_TELLER_SETUP',       0,0,0,0,1),
  ('Internal Auditor', 'PAGE',  'ADMIN_POOL_DENOMINATIONS', 0,0,0,0,1),
  ('Internal Auditor', 'TABLE', 'fosa_transaction',         1,0,0,0,0),
  ('Internal Auditor', 'TABLE', 'teller_transaction',       1,0,0,0,0),
  ('Internal Auditor', 'TABLE', 'teller_setup',             1,0,0,0,0),
  ('Internal Auditor', 'TABLE', 'denomination',             1,0,0,0,0)
) AS g(role_name, object_type, object_name, r, i, m, d, e) ON g.role_name = r.name
ON CONFLICT ("role_id", "object_type", "object_name") DO UPDATE SET
  "read_perm"    = GREATEST("permission_set_line"."read_perm",    EXCLUDED."read_perm"),
  "insert_perm"  = GREATEST("permission_set_line"."insert_perm",  EXCLUDED."insert_perm"),
  "modify_perm"  = GREATEST("permission_set_line"."modify_perm",  EXCLUDED."modify_perm"),
  "delete_perm"  = GREATEST("permission_set_line"."delete_perm",  EXCLUDED."delete_perm"),
  "execute_perm" = GREATEST("permission_set_line"."execute_perm", EXCLUDED."execute_perm");
