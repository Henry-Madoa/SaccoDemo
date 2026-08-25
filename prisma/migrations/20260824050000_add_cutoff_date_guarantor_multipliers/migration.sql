-- AlterTable
ALTER TABLE "loan_product" ADD COLUMN "repayment_cutoff_date" INTEGER NOT NULL DEFAULT 0;

-- AlterTable
ALTER TABLE "organisation" ADD COLUMN "guarantor_multiplier" DOUBLE PRECISION DEFAULT 1;
ALTER TABLE "organisation" ADD COLUMN "self_guarantor_multiplier" DOUBLE PRECISION DEFAULT 1;
