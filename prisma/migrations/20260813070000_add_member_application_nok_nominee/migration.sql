-- CreateTable
CREATE TABLE "member_application_next_of_kin" (
    "id" SERIAL NOT NULL,
    "application_no" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "relationship" TEXT,
    "phone" TEXT,

    CONSTRAINT "member_application_next_of_kin_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "member_application_nominee" (
    "id" SERIAL NOT NULL,
    "application_no" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "relationship" TEXT,
    "phone" TEXT,
    "percentage" DOUBLE PRECISION NOT NULL DEFAULT 0,
    "is_next_of_kin" INTEGER NOT NULL DEFAULT 0,

    CONSTRAINT "member_application_nominee_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "ix_app_nok_no" ON "member_application_next_of_kin"("application_no");

-- CreateIndex
CREATE INDEX "ix_app_nominee_no" ON "member_application_nominee"("application_no");

-- AddForeignKey
ALTER TABLE "member_application_next_of_kin" ADD CONSTRAINT "member_application_next_of_kin_application_no_fkey" FOREIGN KEY ("application_no") REFERENCES "member_application"("no") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "member_application_nominee" ADD CONSTRAINT "member_application_nominee_application_no_fkey" FOREIGN KEY ("application_no") REFERENCES "member_application"("no") ON DELETE NO ACTION ON UPDATE NO ACTION;
