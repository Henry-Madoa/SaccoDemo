-- Flags a savings product as a Business account, which collects business details when opened.
ALTER TABLE "savings_product" ADD COLUMN "is_business_account" INTEGER NOT NULL DEFAULT 0;

-- Business-account fields (populated when the product is flagged is_business_account) and
-- Junior-account fields (populated when the product's category is 'JUNIOR ACCOUNT'). Both sets
-- are nullable — captured at Account Opening time, not required.
ALTER TABLE "savings_account" ADD COLUMN "business_name" TEXT;
ALTER TABLE "savings_account" ADD COLUMN "business_location" TEXT;
ALTER TABLE "savings_account" ADD COLUMN "business_paybill_till_no" TEXT;
ALTER TABLE "savings_account" ADD COLUMN "business_phone_no" TEXT;
ALTER TABLE "savings_account" ADD COLUMN "junior_name" TEXT;
ALTER TABLE "savings_account" ADD COLUMN "junior_birth_cert_no" TEXT;
ALTER TABLE "savings_account" ADD COLUMN "junior_date_of_birth" TEXT;
ALTER TABLE "savings_account" ADD COLUMN "junior_photo" TEXT;

-- Same 8 columns, staged on the request until it's processed onto the real savings_account row.
ALTER TABLE "account_opening_request" ADD COLUMN "business_name" TEXT;
ALTER TABLE "account_opening_request" ADD COLUMN "business_location" TEXT;
ALTER TABLE "account_opening_request" ADD COLUMN "business_paybill_till_no" TEXT;
ALTER TABLE "account_opening_request" ADD COLUMN "business_phone_no" TEXT;
ALTER TABLE "account_opening_request" ADD COLUMN "junior_name" TEXT;
ALTER TABLE "account_opening_request" ADD COLUMN "junior_birth_cert_no" TEXT;
ALTER TABLE "account_opening_request" ADD COLUMN "junior_date_of_birth" TEXT;
ALTER TABLE "account_opening_request" ADD COLUMN "junior_photo" TEXT;
