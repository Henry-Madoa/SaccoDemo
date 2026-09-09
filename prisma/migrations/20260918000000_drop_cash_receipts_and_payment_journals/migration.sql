-- Drops the Receivables Cash Receipt and Payables Payment Journal modules.
--
-- Both were duplicates of Cash Management: a customer receipt is a Cash Management Receipt
-- (posted_receipt) and a vendor payment is a Payment Voucher (posted_payment_voucher). Those two
-- already carry the printouts and the maker-checker workflows, so the receivables/payables copies
-- were a second way to do the same posting.
--
-- Destructive: any rows still held in these four tables go with them. Nothing else references
-- them — the ledger entries the modules posted live in cust_ledger_entry / vendor_ledger_entry
-- and journal, and none of those carry a foreign key back here.

DROP TABLE IF EXISTS "cash_receipt_line";
DROP TABLE IF EXISTS "cash_receipt_header";
DROP TABLE IF EXISTS "payment_journal_line";
DROP TABLE IF EXISTS "payment_journal_header";

-- Their No. Series rows and any approval tasks still pointing at them.
DELETE FROM "workflow_task" WHERE "document_type" IN ('CASH_RECEIPT', 'PAYMENT_JOURNAL');
DELETE FROM "workflow" WHERE "document_type" IN ('CASH_RECEIPT', 'PAYMENT_JOURNAL');
DELETE FROM "workflow_table_relation" WHERE "document_type" IN ('CASH_RECEIPT', 'PAYMENT_JOURNAL');
DELETE FROM "sequence" WHERE "name" IN ('CASH_RECEIPT', 'PAYMENT_JOURNAL');
-- Per-user and per-role permission lines named the dropped tables directly.
DELETE FROM "user_permission_line" WHERE "object_type" = 'TABLE' AND "object_name" IN (
  'cash_receipt_header', 'cash_receipt_line', 'payment_journal_header', 'payment_journal_line'
);
DELETE FROM "permission_set_line" WHERE "object_type" = 'TABLE' AND "object_name" IN (
  'cash_receipt_header', 'cash_receipt_line', 'payment_journal_header', 'payment_journal_line'
);
