-- CreateTable
CREATE TABLE "loan_product_charge" (
    "id" SERIAL NOT NULL,
    "product_id" INTEGER NOT NULL,
    "charge_id" INTEGER NOT NULL,
    "gl_account_id" INTEGER NOT NULL,
    "calculation_type" TEXT NOT NULL DEFAULT 'PERCENTAGE',
    "percentage_rate" DOUBLE PRECISION NOT NULL DEFAULT 0,
    "prorate" BOOLEAN NOT NULL DEFAULT false,
    "priority" INTEGER NOT NULL DEFAULT 1,
    "status" TEXT NOT NULL DEFAULT 'ACTIVE',

    CONSTRAINT "loan_product_charge_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "loan_product_charge_scheme" (
    "id" SERIAL NOT NULL,
    "loan_product_charge_id" INTEGER NOT NULL,
    "lower_limit" BIGINT NOT NULL DEFAULT 0,
    "upper_limit" BIGINT,
    "rate_type" TEXT NOT NULL DEFAULT 'FLAT',
    "flat_amount" BIGINT NOT NULL DEFAULT 0,
    "percentage_rate" DOUBLE PRECISION NOT NULL DEFAULT 0,
    "upper_charge_limit" BIGINT NOT NULL DEFAULT 0,
    "lower_charge_limit" BIGINT NOT NULL DEFAULT 0,

    CONSTRAINT "loan_product_charge_scheme_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "ix_lpc_product" ON "loan_product_charge"("product_id");

-- CreateIndex
CREATE INDEX "ix_lpcs_charge" ON "loan_product_charge_scheme"("loan_product_charge_id");

-- AddForeignKey
ALTER TABLE "loan_product_charge" ADD CONSTRAINT "loan_product_charge_product_id_fkey" FOREIGN KEY ("product_id") REFERENCES "loan_product"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "loan_product_charge" ADD CONSTRAINT "loan_product_charge_charge_id_fkey" FOREIGN KEY ("charge_id") REFERENCES "charge"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "loan_product_charge" ADD CONSTRAINT "loan_product_charge_gl_account_id_fkey" FOREIGN KEY ("gl_account_id") REFERENCES "gl_account"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "loan_product_charge_scheme" ADD CONSTRAINT "loan_product_charge_scheme_loan_product_charge_id_fkey" FOREIGN KEY ("loan_product_charge_id") REFERENCES "loan_product_charge"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- Backfill: ADMIN_PRODUCTS_LOANS_MANAGE (lib/permissions.ts) now bundles insert/modify/delete on
-- these two new tables alongside loan_product, so that whoever can already edit a loan product
-- can also configure its Loan Product Charges. Any role's Permission Set line already granting
-- insert on loan_product is exactly the set assembled from ADMIN_PRODUCTS_LOANS_MANAGE at seed
-- time — carry the same grant onto both new tables so existing installs don't lose "Edit
-- product" the moment that action starts requiring it too.
INSERT INTO "permission_set_line" ("role_id", "object_type", "object_name", "insert_perm", "modify_perm", "delete_perm")
SELECT "role_id", 'TABLE', 'loan_product_charge', 1, 1, 1
FROM "permission_set_line"
WHERE "object_type" = 'TABLE' AND "object_name" = 'loan_product' AND "insert_perm" = 1
ON CONFLICT ("role_id", "object_type", "object_name") DO UPDATE SET "insert_perm" = 1, "modify_perm" = 1, "delete_perm" = 1;

INSERT INTO "permission_set_line" ("role_id", "object_type", "object_name", "insert_perm", "modify_perm", "delete_perm")
SELECT "role_id", 'TABLE', 'loan_product_charge_scheme', 1, 1, 1
FROM "permission_set_line"
WHERE "object_type" = 'TABLE' AND "object_name" = 'loan_product' AND "insert_perm" = 1
ON CONFLICT ("role_id", "object_type", "object_name") DO UPDATE SET "insert_perm" = 1, "modify_perm" = 1, "delete_perm" = 1;
