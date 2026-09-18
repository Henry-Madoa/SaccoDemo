-- Companies — the Companies list (Copy Company / Delete Company) for testing on a full copy of
-- the live data. A company is a PostgreSQL schema holding its own copy of every business table;
-- users, sessions, roles, permissions and profiles stay in "public" and are shared by all
-- companies. This registry lives in "public" too. The existing data is the default company.
CREATE TABLE "company" (
    "id"           SERIAL  NOT NULL,
    "code"         TEXT    NOT NULL,          -- URL/cookie-safe key, e.g. MAIN, TEST1
    "schema_name"  TEXT    NOT NULL,          -- public, or co_<code>
    "display_name" TEXT    NOT NULL,
    "is_default"   BOOLEAN NOT NULL DEFAULT false,
    "copied_from"  TEXT,                      -- source company code
    "created_at"   TEXT    NOT NULL,
    "created_by"   TEXT,
    CONSTRAINT "company_pkey" PRIMARY KEY ("id")
);
CREATE UNIQUE INDEX "ux_company_code" ON "company" (UPPER("code"));
CREATE UNIQUE INDEX "ux_company_schema" ON "company" ("schema_name");

INSERT INTO "company" ("code", "schema_name", "display_name", "is_default", "created_at", "created_by")
SELECT 'MAIN', 'public', COALESCE((SELECT "name" FROM "organisation" WHERE "id" = 1), 'Main Company'), true, NOW()::text, 'system'
WHERE NOT EXISTS (SELECT 1 FROM "company" WHERE "is_default");

-- Permissions: whoever manages Users manages companies (System Administrators are is_system).
INSERT INTO "permission_set_line" ("role_id", "object_type", "object_name", "read_perm", "insert_perm", "modify_perm", "delete_perm", "execute_perm")
SELECT l."role_id", 'PAGE', 'ADMIN_COMPANIES', 0, 0, 0, 0, 1
FROM "permission_set_line" l WHERE l."object_type" = 'PAGE' AND l."object_name" = 'ADMIN_USERS' AND l."execute_perm" = 1
ON CONFLICT ("role_id", "object_type", "object_name") DO NOTHING;
INSERT INTO "permission_set_line" ("role_id", "object_type", "object_name", "read_perm", "insert_perm", "modify_perm", "delete_perm", "execute_perm")
SELECT l."role_id", 'TABLE', 'company', 1, 1, 1, 1, 0
FROM "permission_set_line" l WHERE l."object_type" = 'PAGE' AND l."object_name" = 'ADMIN_USERS' AND l."execute_perm" = 1
ON CONFLICT ("role_id", "object_type", "object_name") DO NOTHING;
