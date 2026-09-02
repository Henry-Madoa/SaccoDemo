-- Cheque Instructions — AL Tab52204087 "Cheque Instructions". Instructions the depositing member
-- gives on a cheque deposit: when the cheque clears, move (part of) the funds from the deposit
-- account to another of THE SAME MEMBER's savings accounts and/or apply them to one of their
-- loans. The sum of the instructions may not exceed the cheque amount less the clearing charge
-- (AL OnBeforeSendForApproval).
--
-- In this port instructions execute when the funds are CONFIRMED: on normal clearing, or when the
-- hold from an express clearance is released at maturity.

CREATE TABLE "cheque_instruction" (
    "id" SERIAL NOT NULL,
    "cheque_deposit_no" TEXT NOT NULL,
    "line_no" INTEGER NOT NULL DEFAULT 0,
    "target_type" TEXT NOT NULL DEFAULT 'ACCOUNT',
    "savings_account_id" INTEGER,
    "loan_id" INTEGER,
    "amount" BIGINT NOT NULL DEFAULT 0,
    "created_at" TEXT,
    "created_by" TEXT,

    CONSTRAINT "cheque_instruction_pkey" PRIMARY KEY ("id")
);

CREATE INDEX "ix_ci_deposit" ON "cheque_instruction"("cheque_deposit_no");

ALTER TABLE "cheque_instruction" ADD CONSTRAINT "cheque_instruction_deposit_fkey" FOREIGN KEY ("cheque_deposit_no") REFERENCES "cheque_deposit"("no") ON DELETE CASCADE ON UPDATE NO ACTION;
ALTER TABLE "cheque_instruction" ADD CONSTRAINT "cheque_instruction_savings_account_id_fkey" FOREIGN KEY ("savings_account_id") REFERENCES "savings_account"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE "cheque_instruction" ADD CONSTRAINT "cheque_instruction_loan_id_fkey" FOREIGN KEY ("loan_id") REFERENCES "loan"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;
