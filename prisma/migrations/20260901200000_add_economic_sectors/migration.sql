-- Economic Sectors — AL Tab52204077 "Economic Sectors" / Tab52204078 "Economic Subsectors" /
-- Tab52204079 "Economic Sub-subsector", and the "Sector Code" / "Sub Sector Code" /
-- "Sub-Subsector Code" fields on the loan (Tab52204014 fields 68-73). Backs the SASRA
-- Sectorial Lending Return (Rep52204034).

CREATE TABLE "economic_sector" (
    "code" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "created_at" TEXT,
    "created_by" TEXT,

    CONSTRAINT "economic_sector_pkey" PRIMARY KEY ("code")
);

CREATE TABLE "economic_subsector" (
    "id" SERIAL NOT NULL,
    "sector_code" TEXT NOT NULL,
    "code" TEXT NOT NULL,
    "name" TEXT NOT NULL,

    CONSTRAINT "economic_subsector_pkey" PRIMARY KEY ("id")
);
CREATE UNIQUE INDEX "economic_subsector_sector_code_code_key" ON "economic_subsector"("sector_code", "code");
ALTER TABLE "economic_subsector" ADD CONSTRAINT "economic_subsector_sector_code_fkey" FOREIGN KEY ("sector_code") REFERENCES "economic_sector"("code") ON DELETE CASCADE ON UPDATE NO ACTION;

CREATE TABLE "economic_subsubsector" (
    "id" SERIAL NOT NULL,
    "sector_code" TEXT NOT NULL,
    "subsector_code" TEXT NOT NULL,
    "code" TEXT NOT NULL,
    "description" TEXT NOT NULL,

    CONSTRAINT "economic_subsubsector_pkey" PRIMARY KEY ("id")
);
CREATE UNIQUE INDEX "economic_subsubsector_key" ON "economic_subsubsector"("sector_code", "subsector_code", "code");
ALTER TABLE "economic_subsubsector" ADD CONSTRAINT "economic_subsubsector_sector_code_fkey" FOREIGN KEY ("sector_code") REFERENCES "economic_sector"("code") ON DELETE CASCADE ON UPDATE NO ACTION;

-- AlterTable: the loan's sector classification (AL Tab52204014 fields 68 / 70 / 72).
ALTER TABLE "loan" ADD COLUMN "sector_code" TEXT;
ALTER TABLE "loan" ADD COLUMN "sub_sector_code" TEXT;
ALTER TABLE "loan" ADD COLUMN "sub_subsector_code" TEXT;
ALTER TABLE "loan" ADD CONSTRAINT "loan_sector_code_fkey" FOREIGN KEY ("sector_code") REFERENCES "economic_sector"("code") ON DELETE NO ACTION ON UPDATE NO ACTION;
CREATE INDEX "ix_loan_sector" ON "loan"("sector_code");

-- Data: the SACCO's official three-level economic classification (see the companion migration
-- 20260901210000 for the full sub-subsector list). Codes are the numeric 1000-8000 / 1100-8400
-- scheme.
INSERT INTO "economic_sector" ("code", "name", "created_at", "created_by") VALUES
  ('1000', 'Agriculture',                            now()::text, 'system'),
  ('2000', 'Trade',                                  now()::text, 'system'),
  ('3000', 'Manufacturing And Servicing Industries', now()::text, 'system'),
  ('4000', 'Education',                              now()::text, 'system'),
  ('5000', 'Human Health',                           now()::text, 'system'),
  ('6000', 'Land And Housing',                       now()::text, 'system'),
  ('7000', 'Finance, Investments And Insurance',     now()::text, 'system'),
  ('8000', 'Consumption And Social Services',        now()::text, 'system')
ON CONFLICT ("code") DO NOTHING;

-- Permission page + grants for the Economic Sectors setup screen (Setup Pool -> Credit) — mirrors
-- ADMIN_PRODUCTS_COLLATERAL_MANAGE's own precedent (Branch Manager only; no seeded role currently
-- reaches ADMIN_PRODUCTS_LOANS/SAVINGS either).
INSERT INTO "permission_set_line"
  ("role_id", "object_type", "object_name", "read_perm", "insert_perm", "modify_perm", "delete_perm", "execute_perm")
SELECT r.id, 'PAGE', 'ADMIN_POOL_SECTORS', 0, 0, 0, 0, 1
FROM "role" r WHERE r.name = 'Branch Manager'
ON CONFLICT ("role_id", "object_type", "object_name") DO UPDATE SET "execute_perm" = GREATEST("permission_set_line"."execute_perm", EXCLUDED."execute_perm");

INSERT INTO "permission_set_line"
  ("role_id", "object_type", "object_name", "read_perm", "insert_perm", "modify_perm", "delete_perm", "execute_perm")
SELECT r.id, 'TABLE', t.name, 1, 1, 1, 1, 0
FROM "role" r
CROSS JOIN (VALUES ('economic_sector'), ('economic_subsector'), ('economic_subsubsector')) AS t(name)
WHERE r.name = 'Branch Manager'
ON CONFLICT ("role_id", "object_type", "object_name") DO UPDATE SET
  "read_perm"   = GREATEST("permission_set_line"."read_perm",   EXCLUDED."read_perm"),
  "insert_perm" = GREATEST("permission_set_line"."insert_perm", EXCLUDED."insert_perm"),
  "modify_perm" = GREATEST("permission_set_line"."modify_perm", EXCLUDED."modify_perm"),
  "delete_perm" = GREATEST("permission_set_line"."delete_perm", EXCLUDED."delete_perm");
