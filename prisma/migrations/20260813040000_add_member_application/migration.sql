-- CreateTable
CREATE TABLE "member_application" (
    "no" TEXT NOT NULL,
    "member_type" TEXT NOT NULL DEFAULT 'INDIVIDUAL',
    "member_category_id" INTEGER,
    "title" TEXT,
    "first_name" TEXT NOT NULL,
    "middle_name" TEXT,
    "last_name" TEXT NOT NULL,
    "national_id" TEXT,
    "kra_pin" TEXT,
    "date_of_birth" TEXT,
    "gender" TEXT,
    "marital_status" TEXT,
    "phone" TEXT,
    "email" TEXT,
    "postal_address" TEXT,
    "physical_address" TEXT,
    "county_id" INTEGER,
    "sub_county_id" INTEGER,
    "employer" TEXT,
    "employment_status" TEXT,
    "staff_no" TEXT,
    "gross_income" BIGINT NOT NULL DEFAULT 0,
    "other_deductions" BIGINT NOT NULL DEFAULT 0,
    "branch_id" INTEGER,
    "member_status" TEXT NOT NULL DEFAULT 'ACTIVE',
    "kyc_verified" INTEGER NOT NULL DEFAULT 0,
    "join_date" TEXT,
    "photo" TEXT,
    "front_id_image" TEXT,
    "back_id_image" TEXT,
    "signature_image" TEXT,
    "fingerprint1_image" TEXT,
    "fingerprint2_image" TEXT,
    "notes" TEXT,
    "status" TEXT NOT NULL DEFAULT 'Open',
    "decision_reason" TEXT,
    "member_id" INTEGER,
    "created_at" TEXT,
    "created_by" TEXT,

    CONSTRAINT "member_application_pkey" PRIMARY KEY ("no")
);

-- CreateIndex
CREATE INDEX "ix_app_status" ON "member_application"("status");

-- CreateIndex
CREATE INDEX "ix_app_county" ON "member_application"("county_id");

-- CreateIndex
CREATE INDEX "ix_app_sub_county" ON "member_application"("sub_county_id");

-- CreateIndex
CREATE INDEX "ix_app_category" ON "member_application"("member_category_id");

-- CreateIndex
CREATE INDEX "ix_app_branch" ON "member_application"("branch_id");

-- AddForeignKey
ALTER TABLE "member_application" ADD CONSTRAINT "member_application_member_category_id_fkey" FOREIGN KEY ("member_category_id") REFERENCES "member_category"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "member_application" ADD CONSTRAINT "member_application_county_id_fkey" FOREIGN KEY ("county_id") REFERENCES "county"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "member_application" ADD CONSTRAINT "member_application_sub_county_id_fkey" FOREIGN KEY ("sub_county_id") REFERENCES "sub_county"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "member_application" ADD CONSTRAINT "member_application_branch_id_fkey" FOREIGN KEY ("branch_id") REFERENCES "branch"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "member_application" ADD CONSTRAINT "member_application_member_id_fkey" FOREIGN KEY ("member_id") REFERENCES "member"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- No. Series: reuses the app's existing sequence-table mechanism (see lib/db.ts nextSequence)
INSERT INTO "sequence" ("name", "prefix", "next_no", "width") VALUES ('MEMBER_APPLICATION', 'APP', 1, 6)
ON CONFLICT ("name") DO NOTHING;
