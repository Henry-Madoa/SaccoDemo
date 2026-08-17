-- CreateTable
CREATE TABLE "collateral_type" (
    "id" SERIAL NOT NULL,
    "code" TEXT NOT NULL,
    "description" TEXT NOT NULL,
    "category" TEXT NOT NULL,
    "value_multiplier" DOUBLE PRECISION NOT NULL DEFAULT 0,
    "status" TEXT NOT NULL DEFAULT 'ACTIVE',

    CONSTRAINT "collateral_type_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "collateral_application" (
    "no" TEXT NOT NULL,
    "member_id" INTEGER NOT NULL,
    "category" TEXT NOT NULL,
    "collateral_type_id" INTEGER,
    "collateral_description" TEXT,
    "multiplier" DOUBLE PRECISION NOT NULL DEFAULT 0,
    "collateral_value" BIGINT NOT NULL DEFAULT 0,
    "guarantee" BIGINT NOT NULL DEFAULT 0,
    "serial_reg_no" TEXT,
    "multi_linking" INTEGER NOT NULL DEFAULT 0,
    "county_id" INTEGER,
    "last_valuation_date" TEXT,
    "joint_ownership" INTEGER NOT NULL DEFAULT 0,
    "owner_name" TEXT,
    "owner_id_no" TEXT,
    "owner_phone_no" TEXT,
    "insurance_expiry_date" TEXT,
    "car_track_due_date" TEXT,
    "cheque_no" TEXT,
    "status" TEXT NOT NULL DEFAULT 'Open',
    "decision_reason" TEXT,
    "processed_at" TEXT,
    "processed_by" TEXT,
    "created_at" TEXT,
    "created_by" TEXT,

    CONSTRAINT "collateral_application_pkey" PRIMARY KEY ("no")
);

-- CreateTable
CREATE TABLE "collateral_application_attachment" (
    "id" SERIAL NOT NULL,
    "application_no" TEXT NOT NULL,
    "public_id" TEXT NOT NULL,
    "url" TEXT NOT NULL,
    "filename" TEXT NOT NULL,
    "resource_type" TEXT NOT NULL DEFAULT 'image',
    "format" TEXT,
    "bytes" INTEGER NOT NULL DEFAULT 0,
    "category" TEXT,
    "uploaded_at" TEXT NOT NULL,
    "uploaded_by" TEXT NOT NULL,

    CONSTRAINT "collateral_application_attachment_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "collateral_register" (
    "no" TEXT NOT NULL,
    "member_id" INTEGER NOT NULL,
    "category" TEXT NOT NULL,
    "collateral_type_id" INTEGER,
    "collateral_description" TEXT,
    "collateral_value" BIGINT NOT NULL DEFAULT 0,
    "guarantee" BIGINT NOT NULL DEFAULT 0,
    "serial_reg_no" TEXT,
    "posting_date" TEXT,
    "county_id" INTEGER,
    "owner_name" TEXT,
    "owner_id_no" TEXT,
    "owner_phone_no" TEXT,
    "insurance_expiry_date" TEXT,
    "car_track_due_date" TEXT,
    "collected_at" TEXT,
    "created_at" TEXT,

    CONSTRAINT "collateral_register_pkey" PRIMARY KEY ("no")
);

-- CreateTable
CREATE TABLE "collateral_release" (
    "no" TEXT NOT NULL,
    "collateral_no" TEXT NOT NULL,
    "member_id" INTEGER NOT NULL,
    "collection_date" TEXT,
    "collected_by" TEXT,
    "collected_by_id_no" TEXT,
    "nationality" TEXT NOT NULL DEFAULT 'LOCAL',
    "domicile_country" TEXT,
    "comments" TEXT,
    "remarks" TEXT,
    "status" TEXT NOT NULL DEFAULT 'Open',
    "decision_reason" TEXT,
    "processed_at" TEXT,
    "processed_by" TEXT,
    "created_at" TEXT,
    "created_by" TEXT,

    CONSTRAINT "collateral_release_pkey" PRIMARY KEY ("no")
);

-- CreateTable
CREATE TABLE "loan_collateral" (
    "id" SERIAL NOT NULL,
    "loan_id" INTEGER NOT NULL,
    "collateral_no" TEXT NOT NULL,
    "guarantee" BIGINT NOT NULL,
    "status" TEXT NOT NULL DEFAULT 'ACTIVE',
    "created_at" TEXT,
    "created_by" TEXT,

    CONSTRAINT "loan_collateral_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "collateral_type_code_key" ON "collateral_type"("code");

-- CreateIndex
CREATE INDEX "ix_ctype_category" ON "collateral_type"("category");

-- CreateIndex
CREATE INDEX "ix_capp_member" ON "collateral_application"("member_id");

-- CreateIndex
CREATE INDEX "ix_capp_status" ON "collateral_application"("status");

-- CreateIndex
CREATE INDEX "ix_capp_serial" ON "collateral_application"("serial_reg_no");

-- CreateIndex
CREATE UNIQUE INDEX "collateral_application_attachment_public_id_key" ON "collateral_application_attachment"("public_id");

-- CreateIndex
CREATE INDEX "ix_capp_attachment_no" ON "collateral_application_attachment"("application_no");

-- CreateIndex
CREATE INDEX "ix_creg_member_type" ON "collateral_register"("member_id", "collateral_type_id");

-- CreateIndex
CREATE INDEX "ix_creg_serial" ON "collateral_register"("serial_reg_no");

-- CreateIndex
CREATE INDEX "ix_crel_collateral" ON "collateral_release"("collateral_no");

-- CreateIndex
CREATE INDEX "ix_crel_status" ON "collateral_release"("status");

-- CreateIndex
CREATE UNIQUE INDEX "ux_loan_collateral" ON "loan_collateral"("loan_id", "collateral_no");

-- CreateIndex
CREATE INDEX "ix_lc_collateral" ON "loan_collateral"("collateral_no");

-- CreateIndex
CREATE INDEX "ix_lc_loan" ON "loan_collateral"("loan_id");

-- AddForeignKey
ALTER TABLE "collateral_application" ADD CONSTRAINT "collateral_application_member_id_fkey" FOREIGN KEY ("member_id") REFERENCES "member"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "collateral_application" ADD CONSTRAINT "collateral_application_collateral_type_id_fkey" FOREIGN KEY ("collateral_type_id") REFERENCES "collateral_type"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "collateral_application" ADD CONSTRAINT "collateral_application_county_id_fkey" FOREIGN KEY ("county_id") REFERENCES "county"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "collateral_application_attachment" ADD CONSTRAINT "collateral_application_attachment_application_no_fkey" FOREIGN KEY ("application_no") REFERENCES "collateral_application"("no") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "collateral_register" ADD CONSTRAINT "collateral_register_no_fkey" FOREIGN KEY ("no") REFERENCES "collateral_application"("no") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "collateral_register" ADD CONSTRAINT "collateral_register_member_id_fkey" FOREIGN KEY ("member_id") REFERENCES "member"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "collateral_register" ADD CONSTRAINT "collateral_register_collateral_type_id_fkey" FOREIGN KEY ("collateral_type_id") REFERENCES "collateral_type"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "collateral_register" ADD CONSTRAINT "collateral_register_county_id_fkey" FOREIGN KEY ("county_id") REFERENCES "county"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "collateral_release" ADD CONSTRAINT "collateral_release_collateral_no_fkey" FOREIGN KEY ("collateral_no") REFERENCES "collateral_register"("no") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "collateral_release" ADD CONSTRAINT "collateral_release_member_id_fkey" FOREIGN KEY ("member_id") REFERENCES "member"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "loan_collateral" ADD CONSTRAINT "loan_collateral_loan_id_fkey" FOREIGN KEY ("loan_id") REFERENCES "loan"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "loan_collateral" ADD CONSTRAINT "loan_collateral_collateral_no_fkey" FOREIGN KEY ("collateral_no") REFERENCES "collateral_register"("no") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- No. Series: reuses the app's existing sequence-table mechanism (see lib/db.ts nextSequence)
INSERT INTO "sequence" ("name", "prefix", "next_no", "width") VALUES ('COLLATERAL_APPLICATION', 'CAP', 1, 6)
ON CONFLICT ("name") DO NOTHING;
INSERT INTO "sequence" ("name", "prefix", "next_no", "width") VALUES ('COLLATERAL_RELEASE', 'CRL', 1, 6)
ON CONFLICT ("name") DO NOTHING;
