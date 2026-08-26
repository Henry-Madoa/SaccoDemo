-- Member Re-admission's own No. series — same "seed the sequence row in its own migration"
-- pattern 20260825080000_add_member_activation_sequence uses for MEMBER_ACTIVATION, since this
-- needs to exist on every already-migrated database, not just a fresh seedIfEmpty() run.
INSERT INTO "sequence" ("name", "prefix", "next_no", "width") VALUES ('MEMBER_READMISSION', 'MRAD', 1, 6);
