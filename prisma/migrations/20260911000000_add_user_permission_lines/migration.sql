-- Per-user permission overrides (Role + User Permission model).
--
-- A user's permissions default to their role's Permission Set (permission_set_line). An admin can
-- then tune an individual user without touching the role: a user_permission_line row REPLACES the
-- role's line for that one object. Two users on the same role can therefore differ — one Loan
-- Clerk may approve, another may not; a third may get one extra screen. Same object model and
-- right columns as permission_set_line, keyed to the user instead of the role.

CREATE TABLE "user_permission_line" (
    "id"           SERIAL NOT NULL,
    "user_id"      INTEGER NOT NULL,
    "object_type"  TEXT   NOT NULL,  -- 'TABLE' | 'PAGE'
    "object_name"  TEXT   NOT NULL,  -- table name (e.g. 'loan') or page code (e.g. 'LOANS')
    "read_perm"    INTEGER NOT NULL DEFAULT 0,
    "insert_perm"  INTEGER NOT NULL DEFAULT 0,
    "modify_perm"  INTEGER NOT NULL DEFAULT 0,
    "delete_perm"  INTEGER NOT NULL DEFAULT 0,
    "execute_perm" INTEGER NOT NULL DEFAULT 0,
    "created_at"   TEXT,
    "created_by"   TEXT,

    CONSTRAINT "user_permission_line_pkey" PRIMARY KEY ("id")
);
CREATE UNIQUE INDEX "user_permission_line_user_id_object_type_object_name_key"
    ON "user_permission_line"("user_id", "object_type", "object_name");
CREATE INDEX "user_permission_line_user_id_idx" ON "user_permission_line"("user_id");
ALTER TABLE "user_permission_line" ADD CONSTRAINT "user_permission_line_user_id_fkey"
    FOREIGN KEY ("user_id") REFERENCES "app_user"("id") ON DELETE CASCADE ON UPDATE NO ACTION;

-- Business Central "User Permission Sets" (Access Control): a user may be granted MORE than one
-- Permission Set; their rights are the union of the primary role (app_user.role_id) plus every
-- additional set listed here. The user_permission_line overrides above then apply on top.
CREATE TABLE "user_permission_set" (
    "id"         SERIAL NOT NULL,
    "user_id"    INTEGER NOT NULL,
    "role_id"    INTEGER NOT NULL,
    "created_at" TEXT,
    "created_by" TEXT,

    CONSTRAINT "user_permission_set_pkey" PRIMARY KEY ("id")
);
CREATE UNIQUE INDEX "user_permission_set_user_id_role_id_key" ON "user_permission_set"("user_id", "role_id");
CREATE INDEX "user_permission_set_user_id_idx" ON "user_permission_set"("user_id");
ALTER TABLE "user_permission_set" ADD CONSTRAINT "user_permission_set_user_id_fkey"
    FOREIGN KEY ("user_id") REFERENCES "app_user"("id") ON DELETE CASCADE ON UPDATE NO ACTION;
ALTER TABLE "user_permission_set" ADD CONSTRAINT "user_permission_set_role_id_fkey"
    FOREIGN KEY ("role_id") REFERENCES "role"("id") ON DELETE CASCADE ON UPDATE NO ACTION;
