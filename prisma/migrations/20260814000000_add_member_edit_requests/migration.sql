-- CreateTable
CREATE TABLE "member_edit_request" (
    "no" TEXT NOT NULL,
    "member_id" INTEGER NOT NULL,
    "member_type" TEXT NOT NULL DEFAULT 'INDIVIDUAL',
    "member_category_id" INTEGER,
    "title" TEXT,
    "first_name" TEXT NOT NULL,
    "middle_name" TEXT,
    "last_name" TEXT NOT NULL,
    "identification_no" TEXT,
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
    "kyc_verified" INTEGER NOT NULL DEFAULT 0,
    "join_date" TEXT,
    "photo" TEXT,
    "front_id_image" TEXT,
    "back_id_image" TEXT,
    "signature_image" TEXT,
    "fingerprint1_image" TEXT,
    "fingerprint2_image" TEXT,
    "notes" TEXT,
    "group_name" TEXT,
    "registration_no" TEXT,
    "registration_date" TEXT,
    "contact_person_name" TEXT,
    "contact_person_phone" TEXT,
    "contact_person_email" TEXT,
    "member_count" INTEGER,
    "global_dimension_1_id" INTEGER,
    "global_dimension_2_id" INTEGER,
    "status" TEXT NOT NULL DEFAULT 'Open',
    "decision_reason" TEXT,
    "created_at" TEXT,
    "created_by" TEXT,

    CONSTRAINT "member_edit_request_pkey" PRIMARY KEY ("no")
);

-- CreateIndex
CREATE INDEX "ix_edit_member" ON "member_edit_request"("member_id");

-- CreateIndex
CREATE INDEX "ix_edit_status" ON "member_edit_request"("status");

-- CreateIndex
CREATE INDEX "ix_edit_county" ON "member_edit_request"("county_id");

-- CreateIndex
CREATE INDEX "ix_edit_sub_county" ON "member_edit_request"("sub_county_id");

-- CreateIndex
CREATE INDEX "ix_edit_category" ON "member_edit_request"("member_category_id");

-- CreateIndex
CREATE INDEX "ix_edit_gd1" ON "member_edit_request"("global_dimension_1_id");

-- CreateIndex
CREATE INDEX "ix_edit_gd2" ON "member_edit_request"("global_dimension_2_id");

-- AddForeignKey
ALTER TABLE "member_edit_request" ADD CONSTRAINT "member_edit_request_member_id_fkey" FOREIGN KEY ("member_id") REFERENCES "member"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "member_edit_request" ADD CONSTRAINT "member_edit_request_member_category_id_fkey" FOREIGN KEY ("member_category_id") REFERENCES "member_category"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "member_edit_request" ADD CONSTRAINT "member_edit_request_county_id_fkey" FOREIGN KEY ("county_id") REFERENCES "county"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "member_edit_request" ADD CONSTRAINT "member_edit_request_sub_county_id_fkey" FOREIGN KEY ("sub_county_id") REFERENCES "sub_county"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "member_edit_request" ADD CONSTRAINT "member_edit_request_global_dimension_1_id_fkey" FOREIGN KEY ("global_dimension_1_id") REFERENCES "global_dimension_1_value"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "member_edit_request" ADD CONSTRAINT "member_edit_request_global_dimension_2_id_fkey" FOREIGN KEY ("global_dimension_2_id") REFERENCES "global_dimension_2_value"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- No. Series: reuses the app's existing sequence-table mechanism (see lib/db.ts nextSequence)
INSERT INTO "sequence" ("name", "prefix", "next_no", "width") VALUES ('MEMBER_EDIT', 'MED', 1, 6)
ON CONFLICT ("name") DO NOTHING;
