-- CreateTable
CREATE TABLE "workflow" (
    "id" SERIAL NOT NULL,
    "name" TEXT NOT NULL,
    "document_type" TEXT NOT NULL,
    "status" TEXT NOT NULL DEFAULT 'ACTIVE',
    "created_at" TEXT,
    "created_by" TEXT,

    CONSTRAINT "workflow_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "workflow_condition" (
    "id" SERIAL NOT NULL,
    "workflow_id" INTEGER NOT NULL,
    "field" TEXT NOT NULL,
    "operator" TEXT NOT NULL,
    "value" TEXT NOT NULL,
    "value2" TEXT,

    CONSTRAINT "workflow_condition_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "workflow_step" (
    "id" SERIAL NOT NULL,
    "workflow_id" INTEGER NOT NULL,
    "step_no" INTEGER NOT NULL,
    "approver_type" TEXT NOT NULL,
    "approver_user_id" INTEGER,
    "approver_group_id" INTEGER,
    "notify_email" INTEGER NOT NULL DEFAULT 1,

    CONSTRAINT "workflow_step_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "workflow_user_group" (
    "id" SERIAL NOT NULL,
    "name" TEXT NOT NULL,
    "status" TEXT NOT NULL DEFAULT 'ACTIVE',

    CONSTRAINT "workflow_user_group_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "workflow_user_group_member" (
    "id" SERIAL NOT NULL,
    "group_id" INTEGER NOT NULL,
    "user_id" INTEGER NOT NULL,

    CONSTRAINT "workflow_user_group_member_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "approval_user_setup" (
    "id" SERIAL NOT NULL,
    "user_id" INTEGER NOT NULL,
    "approver_id" INTEGER,
    "substitute_id" INTEGER,
    "is_approval_administrator" INTEGER NOT NULL DEFAULT 0,

    CONSTRAINT "approval_user_setup_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "workflow_task" (
    "id" SERIAL NOT NULL,
    "workflow_id" INTEGER,
    "workflow_step_id" INTEGER,
    "step_no" INTEGER NOT NULL,
    "document_type" TEXT NOT NULL,
    "entity_id" TEXT NOT NULL,
    "assigned_to_user_id" INTEGER,
    "assigned_to_group_id" INTEGER,
    "status" TEXT NOT NULL DEFAULT 'PENDING',
    "requested_by" TEXT NOT NULL,
    "requested_at" TEXT NOT NULL,
    "decided_by" TEXT,
    "decided_at" TEXT,
    "comment" TEXT,
    "amount" BIGINT NOT NULL DEFAULT 0,
    "payload" TEXT,

    CONSTRAINT "workflow_task_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "notification" (
    "id" SERIAL NOT NULL,
    "user_id" INTEGER NOT NULL,
    "type" TEXT NOT NULL,
    "title" TEXT NOT NULL,
    "body" TEXT,
    "link" TEXT,
    "is_read" INTEGER NOT NULL DEFAULT 0,
    "created_at" TEXT NOT NULL,

    CONSTRAINT "notification_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "ix_workflow_doctype" ON "workflow"("document_type", "status");

-- CreateIndex
CREATE INDEX "ix_condition_workflow" ON "workflow_condition"("workflow_id");

-- CreateIndex
CREATE INDEX "ix_step_workflow" ON "workflow_step"("workflow_id", "step_no");

-- CreateIndex
CREATE UNIQUE INDEX "workflow_user_group_name_key" ON "workflow_user_group"("name");

-- CreateIndex
CREATE UNIQUE INDEX "ux_group_member" ON "workflow_user_group_member"("group_id", "user_id");

-- CreateIndex
CREATE UNIQUE INDEX "approval_user_setup_user_id_key" ON "approval_user_setup"("user_id");

-- CreateIndex
CREATE INDEX "ix_approval_admin" ON "approval_user_setup"("is_approval_administrator");

-- CreateIndex
CREATE INDEX "ix_task_status" ON "workflow_task"("status");

-- CreateIndex
CREATE INDEX "ix_task_document" ON "workflow_task"("document_type", "entity_id");

-- CreateIndex
CREATE INDEX "ix_task_assignee" ON "workflow_task"("assigned_to_user_id");

-- CreateIndex
CREATE INDEX "ix_notification_user" ON "notification"("user_id", "is_read");

-- AddForeignKey
ALTER TABLE "workflow_condition" ADD CONSTRAINT "workflow_condition_workflow_id_fkey" FOREIGN KEY ("workflow_id") REFERENCES "workflow"("id") ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "workflow_step" ADD CONSTRAINT "workflow_step_workflow_id_fkey" FOREIGN KEY ("workflow_id") REFERENCES "workflow"("id") ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "workflow_user_group_member" ADD CONSTRAINT "workflow_user_group_member_group_id_fkey" FOREIGN KEY ("group_id") REFERENCES "workflow_user_group"("id") ON DELETE CASCADE ON UPDATE NO ACTION;
ALTER TABLE "workflow_user_group_member" ADD CONSTRAINT "workflow_user_group_member_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "app_user"("id") ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "approval_user_setup" ADD CONSTRAINT "approval_user_setup_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "app_user"("id") ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "workflow_task" ADD CONSTRAINT "workflow_task_workflow_id_fkey" FOREIGN KEY ("workflow_id") REFERENCES "workflow"("id") ON DELETE CASCADE ON UPDATE NO ACTION;
ALTER TABLE "workflow_task" ADD CONSTRAINT "workflow_task_workflow_step_id_fkey" FOREIGN KEY ("workflow_step_id") REFERENCES "workflow_step"("id") ON DELETE CASCADE ON UPDATE NO ACTION;
ALTER TABLE "workflow_task" ADD CONSTRAINT "workflow_task_assigned_to_group_id_fkey" FOREIGN KEY ("assigned_to_group_id") REFERENCES "workflow_user_group"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- Data migration: carry forward existing loan approval history as "legacy"
-- (unrouted) workflow_task rows — no admin-defined workflow existed before this
-- module, so these keep behaving as a static-permission decision (LOAN:APPROVE)
-- rather than being assigned to a specific approver.
INSERT INTO "workflow_task" (
  "workflow_id", "workflow_step_id", "step_no", "document_type", "entity_id",
  "assigned_to_user_id", "assigned_to_group_id", "status",
  "requested_by", "requested_at", "decided_by", "decided_at", "comment", "amount", "payload"
)
SELECT
  NULL, NULL, 1, 'LOAN', "entity_id"::text,
  NULL, NULL,
  CASE WHEN "decision" IN ('PENDING', 'APPROVED', 'REJECTED') THEN "decision" ELSE 'PENDING' END,
  "maker", "maker_at", "checker", "checker_at", "reason", COALESCE("amount", 0), NULL
FROM "approval_task"
WHERE "entity" = 'loan';

-- DropTable: approval_task is fully replaced by the generic workflow_task engine.
DROP TABLE "approval_task";
