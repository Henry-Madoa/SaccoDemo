-- A user's scanned signature, uploaded by an administrator on the User Setup card. Document
-- printouts (payment voucher, receipt, WHT certificate, deposit slip) stamp it above the name of
-- whoever prepared, approved or issued the document, so a printed copy carries the same
-- signatures the paper process used to collect by hand.
ALTER TABLE "app_user" ADD COLUMN "signature_image" TEXT;
