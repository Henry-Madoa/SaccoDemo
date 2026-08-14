-- CreateTable
CREATE TABLE "member_application_signatory" (
    "id" SERIAL NOT NULL,
    "application_no" TEXT NOT NULL,
    "identification_no" TEXT,
    "name" TEXT NOT NULL,
    "designation" TEXT,
    "date_of_birth" TEXT,
    "email" TEXT,
    "phone" TEXT,

    CONSTRAINT "member_application_signatory_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "member_signatory" (
    "id" SERIAL NOT NULL,
    "member_id" INTEGER NOT NULL,
    "identification_no" TEXT,
    "name" TEXT NOT NULL,
    "designation" TEXT,
    "date_of_birth" TEXT,
    "email" TEXT,
    "phone" TEXT,

    CONSTRAINT "member_signatory_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "ix_app_signatory_no" ON "member_application_signatory"("application_no");

-- CreateIndex
CREATE INDEX "ix_signatory_member" ON "member_signatory"("member_id");

-- AddForeignKey
ALTER TABLE "member_application_signatory" ADD CONSTRAINT "member_application_signatory_application_no_fkey" FOREIGN KEY ("application_no") REFERENCES "member_application"("no") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "member_signatory" ADD CONSTRAINT "member_signatory_member_id_fkey" FOREIGN KEY ("member_id") REFERENCES "member"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;
