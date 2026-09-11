-- A posted invoice raised directly (not from an order) had nothing linking it back to the open
-- document it came from, so its approval trail — recorded against that number — was lost to the
-- printout. order_no still means the Order No. on the face of the document; this is the source.
ALTER TABLE "posted_sales_document" ADD COLUMN "source_no" TEXT;
ALTER TABLE "posted_purchase_document" ADD COLUMN "source_no" TEXT;
