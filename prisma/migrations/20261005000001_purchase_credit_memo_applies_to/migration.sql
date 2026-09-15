-- BC "Applies-to Doc. No." on the purchase side: a corrective credit memo remembers the posted
-- invoice it was raised against and settles it on posting, as sales_header already does.
ALTER TABLE "purchase_header" ADD COLUMN "applies_to_doc_no" TEXT;
ALTER TABLE "posted_purchase_document" ADD COLUMN "applies_to_doc_no" TEXT;
