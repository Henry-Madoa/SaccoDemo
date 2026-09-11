-- Business Central's "Applies-to Doc. No." on a sales document: the posted invoice a corrective
-- credit memo is raised against. Set when the memo is copied from an invoice, carried onto the
-- posted record, and used at posting to apply the credit memo against that invoice's customer
-- ledger entry so the invoice closes instead of both sitting open.
ALTER TABLE "sales_header" ADD COLUMN "applies_to_doc_no" TEXT;
ALTER TABLE "posted_sales_document" ADD COLUMN "applies_to_doc_no" TEXT;
