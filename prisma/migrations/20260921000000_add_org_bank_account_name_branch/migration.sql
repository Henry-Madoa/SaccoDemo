-- The bank details a sales invoice asks to be paid into. The AL Sales Invoice layout
-- (./ssrs/SalesInvoice.rdl) prints CompanyAccountName / CompanyBankName /
-- CompanyBankBranchName / CompanyAccountNumber together — a payer needs the account name and
-- the branch as much as the number, and the organisation record only carried the last two.
ALTER TABLE "organisation" ADD COLUMN "bank_account_name" TEXT;
ALTER TABLE "organisation" ADD COLUMN "bank_branch" TEXT;
