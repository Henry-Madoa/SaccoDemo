-- Integration — Business Central "Web Services" (Page 810 / Tab2000000076): an object (Page,
-- Query or Codeunit) is registered under a Service Name and, once Published, becomes reachable
-- as an OData V4 entity set / unbound action and as a SOAP page/codeunit service. External
-- systems authenticate with a per-user Web Service Access Key (BC User Card → Web Service Access
-- Key) over HTTP Basic, and every call is logged.
CREATE TABLE "web_service" (
    "id"           SERIAL  NOT NULL,
    "object_type"  TEXT    NOT NULL,          -- PAGE | QUERY | CODEUNIT
    "object_id"    INTEGER NOT NULL,          -- object number in lib/webServices/objects.ts
    "object_name"  TEXT    NOT NULL,
    "service_name" TEXT    NOT NULL,          -- the URL segment, e.g. Members
    "published"    BOOLEAN NOT NULL DEFAULT false,
    "description"  TEXT,
    "created_at"   TEXT,
    "created_by"   TEXT,
    CONSTRAINT "web_service_pkey" PRIMARY KEY ("id")
);
CREATE UNIQUE INDEX "ux_web_service_name" ON "web_service" (LOWER("service_name"));
CREATE UNIQUE INDEX "ux_web_service_object" ON "web_service" ("object_type", "object_id");

-- One key per user, stored hashed; the plain key is shown once when generated (BC does the same).
CREATE TABLE "web_service_access_key" (
    "id"           SERIAL  NOT NULL,
    "user_id"      INTEGER NOT NULL,
    "key_hash"     TEXT    NOT NULL,
    "key_hint"     TEXT    NOT NULL,          -- last 4 characters, to recognise the key
    "expires_at"   TEXT,                      -- NULL = never expires
    "created_at"   TEXT    NOT NULL,
    "created_by"   TEXT,
    "last_used_at" TEXT,
    "revoked_at"   TEXT,
    CONSTRAINT "web_service_access_key_pkey" PRIMARY KEY ("id")
);
ALTER TABLE "web_service_access_key" ADD CONSTRAINT "wsak_user_fkey" FOREIGN KEY ("user_id") REFERENCES "app_user"("id") ON DELETE CASCADE ON UPDATE NO ACTION;
CREATE INDEX "ix_wsak_user" ON "web_service_access_key" ("user_id");

-- Every request answered by the OData / SOAP endpoints.
CREATE TABLE "web_service_log" (
    "id"           SERIAL  NOT NULL,
    "at"           TEXT    NOT NULL,
    "protocol"     TEXT    NOT NULL,          -- ODATA | SOAP
    "method"       TEXT    NOT NULL,          -- HTTP verb
    "service_name" TEXT,
    "operation"    TEXT,                      -- ReadMultiple, Create, $metadata, GetMemberBalance, …
    "path"         TEXT    NOT NULL,
    "username"     TEXT,
    "status"       INTEGER NOT NULL,
    "duration_ms"  INTEGER NOT NULL DEFAULT 0,
    "ip"           TEXT,
    "error"        TEXT,
    CONSTRAINT "web_service_log_pkey" PRIMARY KEY ("id")
);
CREATE INDEX "ix_wslog_at" ON "web_service_log" ("at");
CREATE INDEX "ix_wslog_service" ON "web_service_log" ("service_name", "at");

-- Permissions: whoever manages Users manages web services (System Administrators are is_system
-- and need no rows).
INSERT INTO "permission_set_line" ("role_id", "object_type", "object_name", "read_perm", "insert_perm", "modify_perm", "delete_perm", "execute_perm")
SELECT l."role_id", 'PAGE', 'ADMIN_WEB_SERVICES', 0, 0, 0, 0, 1
FROM "permission_set_line" l WHERE l."object_type" = 'PAGE' AND l."object_name" = 'ADMIN_USERS' AND l."execute_perm" = 1
ON CONFLICT ("role_id", "object_type", "object_name") DO NOTHING;
INSERT INTO "permission_set_line" ("role_id", "object_type", "object_name", "read_perm", "insert_perm", "modify_perm", "delete_perm", "execute_perm")
SELECT l."role_id", 'TABLE', t.tbl, 1, 1, 1, 1, 0
FROM "permission_set_line" l CROSS JOIN (VALUES ('web_service'), ('web_service_access_key'), ('web_service_log')) AS t(tbl)
WHERE l."object_type" = 'PAGE' AND l."object_name" = 'ADMIN_USERS' AND l."execute_perm" = 1
ON CONFLICT ("role_id", "object_type", "object_name") DO NOTHING;
