-- Business Central-style Permission Sets: a role's access is now a set of
-- lines, each granting rights on one Object — a Table (Read/Insert/Modify/
-- Delete) or a Page (Execute) — instead of a flat JSON array of hand-picked
-- "RESOURCE:ACTION" strings. Replaces role.permissions entirely.

CREATE TABLE "permission_set_line" (
  "id" SERIAL PRIMARY KEY,
  "role_id" INTEGER NOT NULL REFERENCES "role"("id") ON DELETE CASCADE,
  "object_type" TEXT NOT NULL,
  "object_name" TEXT NOT NULL,
  "read_perm" INTEGER NOT NULL DEFAULT 0,
  "insert_perm" INTEGER NOT NULL DEFAULT 0,
  "modify_perm" INTEGER NOT NULL DEFAULT 0,
  "delete_perm" INTEGER NOT NULL DEFAULT 0,
  "execute_perm" INTEGER NOT NULL DEFAULT 0,
  CONSTRAINT "ux_permission_set_line" UNIQUE ("role_id", "object_type", "object_name")
);
CREATE INDEX "permission_set_line_role_id_idx" ON "permission_set_line"("role_id");

ALTER TABLE "role" DROP COLUMN "permissions";
