-- CreateTable
CREATE TABLE "county" (
    "id" SERIAL NOT NULL,
    "name" TEXT NOT NULL,
    "status" TEXT NOT NULL DEFAULT 'ACTIVE',

    CONSTRAINT "county_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "sub_county" (
    "id" SERIAL NOT NULL,
    "county_id" INTEGER NOT NULL,
    "name" TEXT NOT NULL,
    "status" TEXT NOT NULL DEFAULT 'ACTIVE',

    CONSTRAINT "sub_county_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "county_name_key" ON "county"("name");

-- CreateIndex
CREATE INDEX "ix_sub_county_county" ON "sub_county"("county_id");

-- CreateIndex
CREATE UNIQUE INDEX "sub_county_county_id_name_key" ON "sub_county"("county_id", "name");

-- AddForeignKey
ALTER TABLE "sub_county" ADD CONSTRAINT "sub_county_county_id_fkey" FOREIGN KEY ("county_id") REFERENCES "county"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- Seed the 47 counties of Kenya
INSERT INTO "county" ("name") VALUES
    ('Mombasa'), ('Kwale'), ('Kilifi'), ('Tana River'), ('Lamu'), ('Taita-Taveta'),
    ('Garissa'), ('Wajir'), ('Mandera'), ('Marsabit'), ('Isiolo'), ('Meru'),
    ('Tharaka-Nithi'), ('Embu'), ('Kitui'), ('Machakos'), ('Makueni'), ('Nyandarua'),
    ('Nyeri'), ('Kirinyaga'), ('Murang''a'), ('Kiambu'), ('Turkana'), ('West Pokot'),
    ('Samburu'), ('Trans Nzoia'), ('Uasin Gishu'), ('Elgeyo-Marakwet'), ('Nandi'),
    ('Baringo'), ('Laikipia'), ('Nakuru'), ('Narok'), ('Kajiado'), ('Kericho'),
    ('Bomet'), ('Kakamega'), ('Vihiga'), ('Bungoma'), ('Busia'), ('Siaya'), ('Kisumu'),
    ('Homa Bay'), ('Migori'), ('Kisii'), ('Nyamira'), ('Nairobi')
ON CONFLICT ("name") DO NOTHING;

-- AlterTable: replace the free-text county on member with a relation to county / sub_county
ALTER TABLE "member" ADD COLUMN "county_id" INTEGER;
ALTER TABLE "member" ADD COLUMN "sub_county_id" INTEGER;

-- Carry forward any existing free-text county values that aren't in the seed list above
INSERT INTO "county" ("name")
SELECT DISTINCT "county" FROM "member"
WHERE "county" IS NOT NULL AND "county" <> ''
ON CONFLICT ("name") DO NOTHING;

UPDATE "member" m SET "county_id" = c."id"
FROM "county" c WHERE c."name" = m."county";

ALTER TABLE "member" DROP COLUMN "county";

-- CreateIndex
CREATE INDEX "ix_member_county" ON "member"("county_id");

-- CreateIndex
CREATE INDEX "ix_member_sub_county" ON "member"("sub_county_id");

-- AddForeignKey
ALTER TABLE "member" ADD CONSTRAINT "member_county_id_fkey" FOREIGN KEY ("county_id") REFERENCES "county"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "member" ADD CONSTRAINT "member_sub_county_id_fkey" FOREIGN KEY ("sub_county_id") REFERENCES "sub_county"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;
