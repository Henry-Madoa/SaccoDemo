-- Replace workflow.status ('ACTIVE'/'INACTIVE') with a boolean workflow.enabled flag
DROP INDEX IF EXISTS "ix_workflow_doctype";

ALTER TABLE "workflow" ADD COLUMN "enabled" INTEGER NOT NULL DEFAULT 1;

UPDATE "workflow" SET "enabled" = CASE WHEN "status" = 'ACTIVE' THEN 1 ELSE 0 END;

ALTER TABLE "workflow" DROP COLUMN "status";

CREATE INDEX "ix_workflow_doctype" ON "workflow"("document_type", "enabled");
