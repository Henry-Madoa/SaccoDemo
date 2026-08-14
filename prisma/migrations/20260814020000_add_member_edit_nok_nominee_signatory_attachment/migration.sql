-- CreateTable
CREATE TABLE "member_edit_next_of_kin" (
    "id" SERIAL NOT NULL,
    "edit_no" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "relationship" TEXT,
    "phone" TEXT,

    CONSTRAINT "member_edit_next_of_kin_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "member_edit_nominee" (
    "id" SERIAL NOT NULL,
    "edit_no" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "relationship" TEXT,
    "phone" TEXT,
    "percentage" DOUBLE PRECISION NOT NULL DEFAULT 0,
    "is_next_of_kin" INTEGER NOT NULL DEFAULT 0,

    CONSTRAINT "member_edit_nominee_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "member_edit_signatory" (
    "id" SERIAL NOT NULL,
    "edit_no" TEXT NOT NULL,
    "identification_no" TEXT,
    "name" TEXT NOT NULL,
    "designation" TEXT,
    "date_of_birth" TEXT,
    "email" TEXT,
    "phone" TEXT,

    CONSTRAINT "member_edit_signatory_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "member_edit_attachment" (
    "id" SERIAL NOT NULL,
    "edit_no" TEXT NOT NULL,
    "public_id" TEXT NOT NULL,
    "url" TEXT NOT NULL,
    "filename" TEXT NOT NULL,
    "resource_type" TEXT NOT NULL DEFAULT 'image',
    "format" TEXT,
    "bytes" INTEGER NOT NULL DEFAULT 0,
    "category" TEXT,
    "uploaded_at" TEXT NOT NULL,
    "uploaded_by" TEXT NOT NULL,

    CONSTRAINT "member_edit_attachment_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "ix_edit_nok_no" ON "member_edit_next_of_kin"("edit_no");

-- CreateIndex
CREATE INDEX "ix_edit_nominee_no" ON "member_edit_nominee"("edit_no");

-- CreateIndex
CREATE INDEX "ix_edit_signatory_no" ON "member_edit_signatory"("edit_no");

-- CreateIndex
CREATE UNIQUE INDEX "member_edit_attachment_public_id_key" ON "member_edit_attachment"("public_id");

-- CreateIndex
CREATE INDEX "ix_edit_attachment_no" ON "member_edit_attachment"("edit_no");

-- AddForeignKey
ALTER TABLE "member_edit_next_of_kin" ADD CONSTRAINT "member_edit_next_of_kin_edit_no_fkey" FOREIGN KEY ("edit_no") REFERENCES "member_edit_request"("no") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "member_edit_nominee" ADD CONSTRAINT "member_edit_nominee_edit_no_fkey" FOREIGN KEY ("edit_no") REFERENCES "member_edit_request"("no") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "member_edit_signatory" ADD CONSTRAINT "member_edit_signatory_edit_no_fkey" FOREIGN KEY ("edit_no") REFERENCES "member_edit_request"("no") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "member_edit_attachment" ADD CONSTRAINT "member_edit_attachment_edit_no_fkey" FOREIGN KEY ("edit_no") REFERENCES "member_edit_request"("no") ON DELETE NO ACTION ON UPDATE NO ACTION;
