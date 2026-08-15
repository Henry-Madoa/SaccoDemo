-- Charge Management: Business Central-style transaction charges. A "Charge" is a reusable
-- fee code; a "Transaction Charge" attaches one or more prioritised, calculated components to
-- a document/transaction type; each component (Transaction Charges Setup) is either a direct
-- Calculation Scheme lookup or a percentage of another component, and posts to its own G/L
-- account when the engine runs it.

-- CreateTable
CREATE TABLE "charge" (
    "id" SERIAL NOT NULL,
    "code" TEXT NOT NULL,
    "description" TEXT NOT NULL,
    "status" TEXT NOT NULL DEFAULT 'ACTIVE',

    CONSTRAINT "charge_pkey" PRIMARY KEY ("id")
);
CREATE UNIQUE INDEX "charge_code_key" ON "charge"("code");

-- CreateTable
CREATE TABLE "transaction_charge" (
    "id" SERIAL NOT NULL,
    "code" TEXT NOT NULL,
    "description" TEXT NOT NULL,
    "transaction_type" TEXT NOT NULL,
    "status" TEXT NOT NULL DEFAULT 'ACTIVE',

    CONSTRAINT "transaction_charge_pkey" PRIMARY KEY ("id")
);
CREATE UNIQUE INDEX "transaction_charge_code_key" ON "transaction_charge"("code");
CREATE UNIQUE INDEX "transaction_charge_transaction_type_key" ON "transaction_charge"("transaction_type");

-- CreateTable
CREATE TABLE "transaction_charge_setup" (
    "id" SERIAL NOT NULL,
    "transaction_charge_id" INTEGER NOT NULL,
    "charge_id" INTEGER NOT NULL,
    "gl_account_id" INTEGER NOT NULL,
    "calculation_type" TEXT NOT NULL DEFAULT 'SCHEME',
    "source_setup_id" INTEGER,
    "priority" INTEGER NOT NULL DEFAULT 1,
    "status" TEXT NOT NULL DEFAULT 'ACTIVE',

    CONSTRAINT "transaction_charge_setup_pkey" PRIMARY KEY ("id")
);
CREATE INDEX "ix_tcs_charge" ON "transaction_charge_setup"("transaction_charge_id");

-- CreateTable
CREATE TABLE "transaction_calc_scheme" (
    "id" SERIAL NOT NULL,
    "transaction_charge_setup_id" INTEGER NOT NULL,
    "lower_limit" BIGINT NOT NULL DEFAULT 0,
    "upper_limit" BIGINT,
    "rate_type" TEXT NOT NULL DEFAULT 'FLAT',
    "flat_amount" BIGINT NOT NULL DEFAULT 0,
    "percentage_rate" DOUBLE PRECISION NOT NULL DEFAULT 0,
    "upper_charge_limit" BIGINT NOT NULL DEFAULT 0,
    "lower_charge_limit" BIGINT NOT NULL DEFAULT 0,

    CONSTRAINT "transaction_calc_scheme_pkey" PRIMARY KEY ("id")
);
CREATE INDEX "ix_tcalc_setup" ON "transaction_calc_scheme"("transaction_charge_setup_id");

-- AddForeignKey
ALTER TABLE "transaction_charge_setup" ADD CONSTRAINT "transaction_charge_setup_transaction_charge_id_fkey" FOREIGN KEY ("transaction_charge_id") REFERENCES "transaction_charge"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE "transaction_charge_setup" ADD CONSTRAINT "transaction_charge_setup_charge_id_fkey" FOREIGN KEY ("charge_id") REFERENCES "charge"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE "transaction_charge_setup" ADD CONSTRAINT "transaction_charge_setup_gl_account_id_fkey" FOREIGN KEY ("gl_account_id") REFERENCES "gl_account"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE "transaction_charge_setup" ADD CONSTRAINT "transaction_charge_setup_source_setup_id_fkey" FOREIGN KEY ("source_setup_id") REFERENCES "transaction_charge_setup"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE "transaction_calc_scheme" ADD CONSTRAINT "transaction_calc_scheme_transaction_charge_setup_id_fkey" FOREIGN KEY ("transaction_charge_setup_id") REFERENCES "transaction_charge_setup"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;
