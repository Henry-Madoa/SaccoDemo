-- CreateTable
CREATE TABLE "member_category" (
    "id" SERIAL NOT NULL,
    "code" TEXT NOT NULL,
    "description" TEXT NOT NULL,
    "category_type" TEXT NOT NULL,
    "registration_fee" BIGINT NOT NULL DEFAULT 0,
    "registration_fee_account_id" INTEGER,
    "status" TEXT NOT NULL DEFAULT 'ACTIVE',

    CONSTRAINT "member_category_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "member_category_default_account" (
    "id" SERIAL NOT NULL,
    "member_category_id" INTEGER NOT NULL,
    "savings_product_id" INTEGER NOT NULL,
    "description" TEXT NOT NULL,

    CONSTRAINT "member_category_default_account_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "member_category_code_key" ON "member_category"("code");

-- CreateIndex
CREATE INDEX "ix_mcda_product" ON "member_category_default_account"("savings_product_id");

-- CreateIndex
CREATE UNIQUE INDEX "member_category_default_account_member_category_id_savings__key" ON "member_category_default_account"("member_category_id", "savings_product_id");

-- AddForeignKey
ALTER TABLE "member_category" ADD CONSTRAINT "member_category_registration_fee_account_id_fkey" FOREIGN KEY ("registration_fee_account_id") REFERENCES "gl_account"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "member_category_default_account" ADD CONSTRAINT "member_category_default_account_member_category_id_fkey" FOREIGN KEY ("member_category_id") REFERENCES "member_category"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "member_category_default_account" ADD CONSTRAINT "member_category_default_account_savings_product_id_fkey" FOREIGN KEY ("savings_product_id") REFERENCES "savings_product"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;
