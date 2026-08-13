-- Data migration: preserve branch/department pick-list values as Global Dimension 1/2 values
-- before the branch and department tables are dropped.

-- Carry branch rows into global_dimension_1_value (skip if a value with the same code/name already exists)
INSERT INTO "global_dimension_1_value" ("code", "name", "status")
SELECT b."code", b."name", b."status"
FROM "branch" b
WHERE NOT EXISTS (
  SELECT 1 FROM "global_dimension_1_value" g WHERE g."code" = b."code" OR g."name" = b."name"
);

-- Carry department rows into global_dimension_2_value (skip if a value with the same code/name already exists)
INSERT INTO "global_dimension_2_value" ("code", "name", "status")
SELECT d."code", d."name", d."status"
FROM "department" d
WHERE NOT EXISTS (
  SELECT 1 FROM "global_dimension_2_value" g WHERE g."code" = d."code" OR g."name" = d."name"
);

-- Backfill member.global_dimension_1_id from its old branch_id, matching branches to the
-- global_dimension_1_value row carrying the same code. Only fills rows not already dimensioned.
UPDATE "member" m
SET "global_dimension_1_id" = g."id"
FROM "branch" b
JOIN "global_dimension_1_value" g ON g."code" = b."code"
WHERE m."branch_id" = b."id" AND m."global_dimension_1_id" IS NULL;

-- Same backfill for member_application.global_dimension_1_id
UPDATE "member_application" a
SET "global_dimension_1_id" = g."id"
FROM "branch" b
JOIN "global_dimension_1_value" g ON g."code" = b."code"
WHERE a."branch_id" = b."id" AND a."global_dimension_1_id" IS NULL;

-- DropForeignKey
ALTER TABLE "app_user" DROP CONSTRAINT "app_user_branch_id_fkey";
ALTER TABLE "member" DROP CONSTRAINT "member_branch_id_fkey";
ALTER TABLE "member_application" DROP CONSTRAINT "member_application_branch_id_fkey";

-- DropIndex
DROP INDEX "ix_app_branch";

-- DropColumn
ALTER TABLE "app_user" DROP COLUMN "branch_id";
ALTER TABLE "member" DROP COLUMN "branch_id";
ALTER TABLE "member_application" DROP COLUMN "branch_id";

-- DropTable
DROP TABLE "branch";
DROP TABLE "department";
