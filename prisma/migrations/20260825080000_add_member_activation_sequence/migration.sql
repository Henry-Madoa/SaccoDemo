-- Member Activation's own No. series — same "seed the sequence row in its own migration" pattern
-- 20260815050000_add_account_activation_request uses for ACCOUNT_ACTIVATION, since this needs to
-- exist on every already-migrated database, not just a fresh seedIfEmpty() run.
INSERT INTO "sequence" ("name", "prefix", "next_no", "width") VALUES ('MEMBER_ACTIVATION', 'MACT', 1, 6);
