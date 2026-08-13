-- CreateTable
CREATE TABLE "member_next_of_kin" (
    "id" SERIAL NOT NULL,
    "member_id" INTEGER NOT NULL,
    "name" TEXT NOT NULL,
    "relationship" TEXT,
    "phone" TEXT,

    CONSTRAINT "member_next_of_kin_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "member_nominee" (
    "id" SERIAL NOT NULL,
    "member_id" INTEGER NOT NULL,
    "name" TEXT NOT NULL,
    "relationship" TEXT,
    "phone" TEXT,
    "percentage" DOUBLE PRECISION NOT NULL DEFAULT 0,
    "is_next_of_kin" INTEGER NOT NULL DEFAULT 0,

    CONSTRAINT "member_nominee_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "ix_nok_member" ON "member_next_of_kin"("member_id");

-- CreateIndex
CREATE INDEX "ix_nominee_member" ON "member_nominee"("member_id");

-- AddForeignKey
ALTER TABLE "member_next_of_kin" ADD CONSTRAINT "member_next_of_kin_member_id_fkey" FOREIGN KEY ("member_id") REFERENCES "member"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "member_nominee" ADD CONSTRAINT "member_nominee_member_id_fkey" FOREIGN KEY ("member_id") REFERENCES "member"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- Carry forward the existing single next-of-kin into the new repeatable table
INSERT INTO "member_next_of_kin" (member_id, name, relationship, phone)
SELECT id, "nok_name", "nok_relationship", "nok_phone" FROM "member"
WHERE "nok_name" IS NOT NULL AND "nok_name" <> '';

-- AlterTable
ALTER TABLE "member" DROP COLUMN "nok_name";
ALTER TABLE "member" DROP COLUMN "nok_relationship";
ALTER TABLE "member" DROP COLUMN "nok_phone";
