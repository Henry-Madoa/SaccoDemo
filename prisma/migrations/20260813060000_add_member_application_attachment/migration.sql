-- CreateTable
CREATE TABLE "member_application_attachment" (
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

    CONSTRAINT "member_application_attachment_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "member_application_attachment_public_id_key" ON "member_application_attachment"("public_id");

-- CreateIndex
CREATE INDEX "ix_app_attachment_no" ON "member_application_attachment"("application_no");

-- AddForeignKey
ALTER TABLE "member_application_attachment" ADD CONSTRAINT "member_application_attachment_application_no_fkey" FOREIGN KEY ("application_no") REFERENCES "member_application"("no") ON DELETE NO ACTION ON UPDATE NO ACTION;
