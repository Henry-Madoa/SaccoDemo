-- Workflow notifications for Sales and Purchase documents used to link to a list
-- (/receivables/sales-invoices, /payables/purchase-invoices); they now open the document
-- card. Existing rows still carry the old link, and the document number is only in the title
-- ("Approval needed: Sales Document SCM-0001", "Purchase Document PI-0007 approved"), so it
-- is lifted from there. Titles that do not fit the pattern are left as they are.
UPDATE "notification"
SET "link" = '/receivables/documents/' || substring("title" from 'Sales Document (\S+)')
WHERE "link" = '/receivables/sales-invoices' AND "title" ~ 'Sales Document \S+';

UPDATE "notification"
SET "link" = '/payables/documents/' || substring("title" from 'Purchase Document (\S+)')
WHERE "link" = '/payables/purchase-invoices' AND "title" ~ 'Purchase Document \S+';
