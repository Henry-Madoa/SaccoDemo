-- A Junior Account's Birth Notification/Certificate No. is its unique identifier: always
-- uppercase, and no two savings accounts may share one (multiple NULLs remain fine — every
-- non-Junior account leaves this null).
ALTER TABLE "savings_account" ALTER COLUMN "junior_birth_cert_no" TYPE VARCHAR(50);
ALTER TABLE "savings_account" ADD CONSTRAINT "ux_savings_account_junior_cert" UNIQUE ("junior_birth_cert_no");
ALTER TABLE "savings_account" ADD CONSTRAINT "ck_savings_account_junior_cert_upper"
  CHECK ("junior_birth_cert_no" = UPPER("junior_birth_cert_no"));

-- Same type/casing rule while it's still a staged Account Opening request — uniqueness across
-- requests is checked at the application layer instead (a request can cycle through Open ->
-- Pending -> Approved -> Open again on rejection, which a hard DB constraint can't express).
ALTER TABLE "account_opening_request" ALTER COLUMN "junior_birth_cert_no" TYPE VARCHAR(50);
ALTER TABLE "account_opening_request" ADD CONSTRAINT "ck_account_opening_request_junior_cert_upper"
  CHECK ("junior_birth_cert_no" = UPPER("junior_birth_cert_no"));
