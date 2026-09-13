-- Store & Purchase Requisitions — AL (Sacco ERP) Tab52203515 "Requisition Header",
-- Tab52203516 "Requisition Lines", Pag52203805/806 (Store Requisition card/list),
-- Pag52203808/809 (Purchase Requisition card/list), Pag52203556 "Requisitions Review",
-- Cod52203477.StoresManagement.IssueStoreItems, Cod52203478.ProcurementManagement.
--
-- One header table carries both requisition types (the AL's "Requisition Type" enum):
--   Store Requisition     an employee asks the store for stock items; once approved the store
--                         admin issues them (a Negative Adjmt. item journal line per issue) and
--                         the requester confirms receipt.
--   Purchase Requisition  an employee asks procurement to buy; once approved the procurement
--                         officer reviews each line (Decision: RFQ -> Purchase Quote, Order ->
--                         Purchase Order, Append to Order -> lines onto an open PO) and executes,
--                         which raises the documents in Payables and closes the PR.
CREATE TABLE "requisition" (
  "no"                      TEXT NOT NULL,
  -- 'Store Requisition' | 'Purchase Requisition'
  "requisition_type"        TEXT NOT NULL,
  "employee_id"             INTEGER NOT NULL,
  "title"                   TEXT NOT NULL,
  "description"             TEXT,
  "requisition_date"        TEXT NOT NULL,
  -- AL "Needed By Date" (>= Requisition Date), "Expiration Date", "Requested Delivery Date"
  "needed_by_date"          TEXT,
  "expiration_date"         TEXT,
  "requested_delivery_date" TEXT,
  "currency_code"           TEXT NOT NULL DEFAULT 'KES',
  -- AL "Store Location" / "Location Code": the store issuing (store req.) or receiving (purchase req.)
  "location_id"             INTEGER,
  -- Purchase requisitions only, Enum52203430: RFQ | RFP | Direct Procurement | Restricted Tendering | Open Tendering | Low Value Procurement
  "procurement_method"      TEXT,
  -- AL "Supplier No": the vendor the requester suggests
  "supplier_id"             INTEGER,
  -- Open | Pending Approval | Approved | Received (store: requester confirmed receipt)
  "status"                  TEXT NOT NULL DEFAULT 'Open',
  "decision_reason"         TEXT,
  -- Store requisitions: AL Posted / "Posted By" / "Posting Date", set once every line is issued in full
  "issued"                  BOOLEAN NOT NULL DEFAULT false,
  "issued_at"               TEXT,
  "issued_by"               TEXT,
  "received"                BOOLEAN NOT NULL DEFAULT false,
  "received_at"             TEXT,
  "received_by"             TEXT,
  -- Purchase requisitions: AL "PR Closed" / "PR Closed By" = Purchase Order | Direct Receipt of Goods/Services | Rejection
  "pr_closed"               BOOLEAN NOT NULL DEFAULT false,
  "pr_closed_by"            TEXT,
  "pr_closed_at"            TEXT,
  "pr_closed_by_user"       TEXT,
  "pr_close_reason"         TEXT,
  "po_generated_directly"   BOOLEAN NOT NULL DEFAULT false,
  "po_generated_by"         TEXT,
  "po_generated_at"         TEXT,
  -- AL "PO Number": the first document raised; every one is on purchase_header.requisition_no
  "po_number"               TEXT,
  "global_dimension_1_id"   INTEGER,
  "global_dimension_2_id"   INTEGER,
  "created_at"              TEXT,
  "created_by"              TEXT,
  CONSTRAINT "requisition_pkey" PRIMARY KEY ("no"),
  CONSTRAINT "rq_employee_fkey" FOREIGN KEY ("employee_id") REFERENCES "employee"("id") ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT "rq_location_fkey" FOREIGN KEY ("location_id") REFERENCES "location"("id") ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT "rq_supplier_fkey" FOREIGN KEY ("supplier_id") REFERENCES "vendor"("id") ON DELETE NO ACTION ON UPDATE NO ACTION
);
CREATE INDEX "ix_rq_type_status" ON "requisition"("requisition_type", "status");
CREATE INDEX "ix_rq_employee" ON "requisition"("employee_id");
CREATE INDEX "ix_rq_created_by" ON "requisition"("created_by");

CREATE TABLE "requisition_line" (
  "id"                  SERIAL NOT NULL,
  "requisition_no"      TEXT NOT NULL,
  "line_no"             INTEGER NOT NULL,
  -- 'Item' | 'G/L Account' | 'Fixed Asset' (store requisitions: always Item)
  "type"                TEXT NOT NULL DEFAULT 'Item',
  "no"                  TEXT NOT NULL,
  "description"         TEXT NOT NULL,
  "item_id"             INTEGER,
  "gl_account_id"       INTEGER,
  "unit_of_measure_id"  INTEGER,
  -- AL Quantity ("Quantity Requested"), "Quantity Approved" (<= Quantity), "Unit Price", Amount
  "quantity"            INTEGER NOT NULL DEFAULT 1,
  "quantity_approved"   INTEGER NOT NULL DEFAULT 0,
  "unit_price"          BIGINT NOT NULL DEFAULT 0,
  "amount"              BIGINT NOT NULL DEFAULT 0,
  "location_id"         INTEGER,
  -- Store: "Quantity To Issue" (<= approved - issued), "Quantity Issued", "Issued Date" / "Issued By"
  "quantity_to_issue"   INTEGER NOT NULL DEFAULT 0,
  "quantity_issued"     INTEGER NOT NULL DEFAULT 0,
  "issued_at"           TEXT,
  "issued_by"           TEXT,
  -- Purchase (Pag52203556 Requisitions Review): Decision '' | RFQ | Order | Append to Order;
  -- "Target No." is the vendor for RFQ/Order, the open Purchase Order for Append to Order.
  "decision"            TEXT NOT NULL DEFAULT '',
  "target_no"           TEXT,
  "processed"           BOOLEAN NOT NULL DEFAULT false,
  "order_no"            TEXT,
  CONSTRAINT "requisition_line_pkey" PRIMARY KEY ("id"),
  CONSTRAINT "rql_requisition_fkey" FOREIGN KEY ("requisition_no") REFERENCES "requisition"("no") ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT "rql_item_fkey" FOREIGN KEY ("item_id") REFERENCES "item"("id") ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT "rql_gl_fkey" FOREIGN KEY ("gl_account_id") REFERENCES "gl_account"("id") ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT "rql_uom_fkey" FOREIGN KEY ("unit_of_measure_id") REFERENCES "unit_of_measure"("id") ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT "rql_location_fkey" FOREIGN KEY ("location_id") REFERENCES "location"("id") ON DELETE NO ACTION ON UPDATE NO ACTION
);
CREATE INDEX "ix_rql_requisition" ON "requisition_line"("requisition_no");

-- AL Purchase Header "Requisition No": the PR a quote/order was raised from.
ALTER TABLE "purchase_header" ADD COLUMN "requisition_no" TEXT;
CREATE INDEX "ix_purchase_header_requisition" ON "purchase_header"("requisition_no");
-- The store issue that posted this Negative Adjmt. (Cod52203477.IssueStoreItems).
ALTER TABLE "item_journal_line" ADD COLUMN "requisition_line_id" INTEGER;

-- No. Series: AL Purchases & Payables Setup "Purchase Req No" / "Store Req No".
INSERT INTO "sequence" ("name", "prefix", "next_no", "width")
SELECT v.name, v.prefix, 1, 5 FROM (VALUES ('STORE_REQUISITION', 'SRQ'), ('PURCHASE_REQUISITION', 'PRQ')) AS v(name, prefix)
WHERE EXISTS (SELECT 1 FROM "organisation") ON CONFLICT ("name") DO NOTHING;
INSERT INTO "no_series" ("code", "description", "default_nos", "manual_nos", "date_order")
SELECT v.code, v.label, 1, 0, 0 FROM (VALUES ('STORE_REQUISITION', 'Store Requisition No.'), ('PURCHASE_REQUISITION', 'Purchase Requisition No.')) AS v(code, label)
WHERE EXISTS (SELECT 1 FROM "organisation") ON CONFLICT ("code") DO NOTHING;
INSERT INTO "no_series_line" ("series_code", "line_no", "starting_date", "starting_no", "increment_by_no", "open", "allow_gaps")
SELECT s.name, 10000, NULL, s.prefix || LPAD(s.next_no::text, s.width, '0'), 1, 1, 0
FROM "sequence" s WHERE s.name IN ('STORE_REQUISITION', 'PURCHASE_REQUISITION') AND EXISTS (SELECT 1 FROM "organisation")
  AND NOT EXISTS (SELECT 1 FROM "no_series_line" l WHERE l.series_code = s.name);
INSERT INTO "no_series_setup" ("document_code", "label", "category", "sort", "series_code")
SELECT v.code, v.label, 'Payables', v.sort, v.code
FROM (VALUES ('STORE_REQUISITION', 'Store Requisition No.', 59), ('PURCHASE_REQUISITION', 'Purchase Requisition No.', 60)) AS v(code, label, sort)
WHERE EXISTS (SELECT 1 FROM "organisation") ON CONFLICT ("document_code") DO NOTHING;

-- Permissions: the finance roles raise and review requisitions; the auditor reads.
INSERT INTO "permission_set_line"
  ("role_id", "object_type", "object_name", "read_perm", "insert_perm", "modify_perm", "delete_perm", "execute_perm")
SELECT r.id, g.object_type, g.object_name, g.r, g.i, g.m, g.d, g.e
FROM "role" r
JOIN (VALUES
  ('Finance Officer',  'PAGE',  'REQUISITIONS',      0,0,0,0,1),
  ('Finance Officer',  'TABLE', 'requisition',       1,1,1,1,0),
  ('Finance Officer',  'TABLE', 'requisition_line',  1,1,1,1,0),
  ('Finance Officer',  'TABLE', 'employee',          1,0,0,0,0),
  ('Finance Officer',  'TABLE', 'item',              1,0,1,0,0),
  ('Finance Officer',  'TABLE', 'location',          1,0,0,0,0),
  ('Finance Officer',  'TABLE', 'vendor',            1,0,0,0,0),
  ('Finance Officer',  'TABLE', 'purchase_header',   1,1,1,0,0),
  ('Finance Officer',  'TABLE', 'purchase_line',     1,1,1,1,0),
  ('Finance Officer',  'TABLE', 'item_journal_line', 1,1,1,0,0),
  ('Finance Officer',  'TABLE', 'item_ledger_entry', 1,1,0,0,0),
  ('Finance Officer',  'TABLE', 'stockkeeping_unit', 1,1,1,0,0),
  ('Finance Manager',  'PAGE',  'REQUISITIONS',      0,0,0,0,1),
  ('Finance Manager',  'TABLE', 'requisition',       1,1,1,1,0),
  ('Finance Manager',  'TABLE', 'requisition_line',  1,1,1,1,0),
  ('Finance Manager',  'TABLE', 'employee',          1,0,0,0,0),
  ('Finance Manager',  'TABLE', 'item',              1,0,1,0,0),
  ('Finance Manager',  'TABLE', 'location',          1,0,0,0,0),
  ('Finance Manager',  'TABLE', 'vendor',            1,0,0,0,0),
  ('Finance Manager',  'TABLE', 'purchase_header',   1,1,1,0,0),
  ('Finance Manager',  'TABLE', 'purchase_line',     1,1,1,1,0),
  ('Finance Manager',  'TABLE', 'item_journal_line', 1,1,1,0,0),
  ('Finance Manager',  'TABLE', 'item_ledger_entry', 1,1,0,0,0),
  ('Finance Manager',  'TABLE', 'stockkeeping_unit', 1,1,1,0,0),
  ('Accountant',       'PAGE',  'REQUISITIONS',      0,0,0,0,1),
  ('Accountant',       'TABLE', 'requisition',       1,1,1,1,0),
  ('Accountant',       'TABLE', 'requisition_line',  1,1,1,1,0),
  ('Accountant',       'TABLE', 'employee',          1,0,0,0,0),
  ('Accountant',       'TABLE', 'item',              1,0,0,0,0),
  ('Accountant',       'TABLE', 'location',          1,0,0,0,0),
  ('Accountant',       'TABLE', 'vendor',            1,0,0,0,0),
  ('Branch Manager',   'PAGE',  'REQUISITIONS',      0,0,0,0,1),
  ('Branch Manager',   'TABLE', 'requisition',       1,1,1,1,0),
  ('Branch Manager',   'TABLE', 'requisition_line',  1,1,1,1,0),
  ('Branch Manager',   'TABLE', 'employee',          1,0,0,0,0),
  ('Branch Manager',   'TABLE', 'item',              1,0,0,0,0),
  ('Branch Manager',   'TABLE', 'location',          1,0,0,0,0),
  ('Branch Manager',   'TABLE', 'vendor',            1,0,0,0,0),
  ('Internal Auditor', 'PAGE',  'REQUISITIONS',      0,0,0,0,1),
  ('Internal Auditor', 'TABLE', 'requisition',       1,0,0,0,0),
  ('Internal Auditor', 'TABLE', 'requisition_line',  1,0,0,0,0),
  ('Internal Auditor', 'TABLE', 'employee',          1,0,0,0,0),
  ('Internal Auditor', 'TABLE', 'item',              1,0,0,0,0),
  ('Internal Auditor', 'TABLE', 'location',          1,0,0,0,0),
  ('Internal Auditor', 'TABLE', 'vendor',            1,0,0,0,0)
) AS g(role_name, object_type, object_name, r, i, m, d, e) ON g.role_name = r.name
ON CONFLICT ("role_id", "object_type", "object_name") DO UPDATE SET
  "read_perm"    = GREATEST("permission_set_line"."read_perm",    EXCLUDED."read_perm"),
  "insert_perm"  = GREATEST("permission_set_line"."insert_perm",  EXCLUDED."insert_perm"),
  "modify_perm"  = GREATEST("permission_set_line"."modify_perm",  EXCLUDED."modify_perm"),
  "delete_perm"  = GREATEST("permission_set_line"."delete_perm",  EXCLUDED."delete_perm"),
  "execute_perm" = GREATEST("permission_set_line"."execute_perm", EXCLUDED."execute_perm");
