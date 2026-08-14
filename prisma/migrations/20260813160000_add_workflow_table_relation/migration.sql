-- CreateTable
CREATE TABLE "workflow_table_relation" (
    "id" SERIAL NOT NULL,
    "document_type" TEXT NOT NULL,
    "table_name" TEXT NOT NULL,
    "created_at" TEXT,
    "created_by" TEXT,

    CONSTRAINT "workflow_table_relation_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "workflow_table_relation_field" (
    "id" SERIAL NOT NULL,
    "table_relation_id" INTEGER NOT NULL,
    "field_name" TEXT NOT NULL,

    CONSTRAINT "workflow_table_relation_field_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "workflow_table_relation_document_type_key" ON "workflow_table_relation"("document_type");

-- CreateIndex
CREATE UNIQUE INDEX "ux_table_relation_field" ON "workflow_table_relation_field"("table_relation_id", "field_name");

-- AddForeignKey
ALTER TABLE "workflow_table_relation_field" ADD CONSTRAINT "workflow_table_relation_field_table_relation_id_fkey" FOREIGN KEY ("table_relation_id") REFERENCES "workflow_table_relation"("id") ON DELETE CASCADE ON UPDATE NO ACTION;

-- Data migration: seed the document-type -> table mapping and condition-field whitelist that
-- previously lived as hardcoded constants (DOCUMENT_TABLE / CONDITION_FIELD_KEYS in
-- lib/workflowConstants.ts) as the initial admin-editable rows, so the workflow condition
-- editor keeps offering exactly the same fields it did before this became database-driven.
INSERT INTO "workflow_table_relation" ("document_type", "table_name") VALUES
  ('MEMBER_APPLICATION', 'member_application'),
  ('LOAN', 'loan'),
  ('JOURNAL', 'journal');

INSERT INTO "workflow_table_relation_field" ("table_relation_id", "field_name")
SELECT r."id", f."field_name"
FROM "workflow_table_relation" r
JOIN (VALUES
  ('MEMBER_APPLICATION', 'gross_income'),
  ('MEMBER_APPLICATION', 'other_deductions'),
  ('MEMBER_APPLICATION', 'member_category_id'),
  ('MEMBER_APPLICATION', 'global_dimension_1_id'),
  ('MEMBER_APPLICATION', 'global_dimension_2_id'),
  ('MEMBER_APPLICATION', 'county_id'),
  ('LOAN', 'principal'),
  ('LOAN', 'product_id'),
  ('LOAN', 'term_months'),
  ('JOURNAL', 'amount'),
  ('JOURNAL', 'global_dimension_1_id'),
  ('JOURNAL', 'global_dimension_2_id')
) AS f("document_type", "field_name") ON f."document_type" = r."document_type";
