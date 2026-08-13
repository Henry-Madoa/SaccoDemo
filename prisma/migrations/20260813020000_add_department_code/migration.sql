-- AlterTable
ALTER TABLE "department" ADD COLUMN "code" TEXT;

-- Backfill existing rows with a code derived from their name
UPDATE "department" SET "code" = upper(regexp_replace("name", '[^a-zA-Z0-9]+', '', 'g'));

ALTER TABLE "department" ALTER COLUMN "code" SET NOT NULL;

-- CreateIndex
CREATE UNIQUE INDEX "department_code_key" ON "department"("code");
